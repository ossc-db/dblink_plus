/*-------------------------------------------------------------------------
 *
 * pgsql_fdw.c
 *		  foreign-data wrapper for remote PostgreSQL servers.
 *
 * Copyright (c) 2011-2012, NIPPON TELEGRAPH AND TELEPHONE CORPORATION
 *
 * IDENTIFICATION
 *		  pgsql_fdw/pgsql_fdw.c
 *
 *-------------------------------------------------------------------------
 */
#include "postgres.h"
#include "fmgr.h"

#include "catalog/pg_foreign_server.h"
#include "catalog/pg_foreign_table.h"
#include "commands/explain.h"
#include "foreign/fdwapi.h"
#include "funcapi.h"
#include "miscadmin.h"
#include "nodes/nodeFuncs.h"
#include "optimizer/cost.h"
#include "optimizer/pathnode.h"
#include "utils/lsyscache.h"
#include "utils/memutils.h"
#include "utils/rel.h"

#include "pgsql_fdw.h"
#include "connection.h"

PG_MODULE_MAGIC;

/*
 * Default fetch count for cursor.  This can be overridden by fetch_count FDW
 * option.
 */
#define DEFAULT_FETCH_COUNT			10000

/*
 * Cost to establish a connection.
 * XXX: should be configurable per server?
 */
#define CONNECTION_COSTS			100.0

/*
 * Cost to transfer 1 byte from remote server.
 * XXX: should be configurable per server?
 */
#define TRANSFER_COSTS_PER_BYTE		0.001

/*
 * Cursors which are used together in a local query require different name, so
 * we use simple incremental name for that purpose.  We don't care wrap around
 * of cursor_id because it's hard to imagine that 2^32 cursors are used in a
 * query.
 */
#define	CURSOR_NAME_FORMAT		"pgsql_fdw_cursor_%u"
static uint32 cursor_id = 0;

/*
 * Index of FDW-private items stored in FdwPlan.
 */
enum FdwPrivateIndex {
	FdwPrivateSelectSql,
	FdwPrivateDeclareSql,
	FdwPrivateFetchSql,
	FdwPrivateResetSql,
	FdwPrivateCloseSql,

	/* # of elements stored in the list fdw_private */
	FdwPrivateNum,
};

/*
 * Describes an execution state of a foreign scan against a foreign table
 * using pgsql_fdw.
 */
typedef struct PgsqlFdwExecutionState
{
	FdwPlan	   *fdwplan;		/* FDW-specific planning information */
	PGconn	   *conn;			/* connection for the scan */

	Oid		   *param_types;	/* type array of external parameter */
	const char **param_values;	/* value array of external parameter */

	int			attnum;			/* # of non-dropped attribute */
	char	  **col_values;		/* column value buffer */
	AttInMetadata *attinmeta;	/* attribute metadata */

	Tuplestorestate *tuples;	/* result of the scan */
	bool		cursor_opened;	/* true if cursor has been opened */
} PgsqlFdwExecutionState;

/*
 * SQL functions
 */
extern Datum pgsql_fdw_handler(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(pgsql_fdw_handler);

/*
 * FDW callback routines
 */
static FdwPlan *pgsqlPlanForeignScan(Oid foreigntableid,
									 PlannerInfo *root,
									 RelOptInfo *baserel);
static void pgsqlExplainForeignScan(ForeignScanState *node, ExplainState *es);
static void pgsqlBeginForeignScan(ForeignScanState *node, int eflags);
static TupleTableSlot *pgsqlIterateForeignScan(ForeignScanState *node);
static void pgsqlReScanForeignScan(ForeignScanState *node);
static void pgsqlEndForeignScan(ForeignScanState *node);

/*
 * Helper functions
 */
static void get_remote_estimate(const char *sql,
								PGconn *conn,
								double *rows,
								int *width,
								Cost *startup_cost,
								Cost *total_cost);
static void adjust_costs(double rows, int width,
						 Cost *startup_cost, Cost *total_cost);
static void execute_query(ForeignScanState *node);
static PGresult *fetch_result(ForeignScanState *node);
static void store_result(ForeignScanState *node, PGresult *res);

/*
 * Foreign-data wrapper handler function: return a struct with pointers
 * to my callback routines.
 */
Datum
pgsql_fdw_handler(PG_FUNCTION_ARGS)
{
	FdwRoutine *fdwroutine = makeNode(FdwRoutine);

	fdwroutine->PlanForeignScan = pgsqlPlanForeignScan;
	fdwroutine->ExplainForeignScan = pgsqlExplainForeignScan;
	fdwroutine->BeginForeignScan = pgsqlBeginForeignScan;
	fdwroutine->IterateForeignScan = pgsqlIterateForeignScan;
	fdwroutine->ReScanForeignScan = pgsqlReScanForeignScan;
	fdwroutine->EndForeignScan = pgsqlEndForeignScan;

	PG_RETURN_POINTER(fdwroutine);
}

/*
 * pgsqlPlanForeignScan
 *		Create a FdwPlan for a scan on the foreign table
 */
static FdwPlan *
pgsqlPlanForeignScan(Oid foreigntableid,
					PlannerInfo *root,
					RelOptInfo *baserel)
{
	FdwPlan		   *fdwplan;
	StringInfoData	sql;
	ForeignTable   *table;
	ForeignServer  *server;
	UserMapping	   *user;
	PGconn		   *conn;
	double			rows;
	int				width;
	Cost			startup_cost;
	Cost			total_cost;
	List		   *fdw_private = NIL;
	List		   *param_conds = NIL;
	List		   *local_conds = NIL;
	Selectivity		sel;
	bool			is_first = true;

	/* stuffs for cursor definition */
	char			name[128];	/* must be larger than format + 10 */
	StringInfoData	cursor;
	const char	   *fetch_count_str;
	int				fetch_count = DEFAULT_FETCH_COUNT;
	List		   *remote_conds = NIL;

	/*
	 * We use FdwPlan to pass various information to subsequent functions.
	 */
	fdwplan = makeNode(FdwPlan);
	initStringInfo(&sql);

	/* Retrieve catalog objects which are necessary to estimate rows. */
	table = GetForeignTable(foreigntableid);
	server = GetForeignServer(table->serverid);
	user = GetUserMapping(GetOuterUserId(), server->serverid);

	/*
	 * Construct remote query which consists of SELECT, FROM, and WHERE
	 * clauses, but conditions contain any Param node are excluded because
	 * placeholder can't be used in EXPLAIN statement.  Such conditions are
	 * appended later.
	 */
	sortConditions(root, baserel, &remote_conds, &param_conds, &local_conds);
	deparseSimpleSql(&sql, foreigntableid, root, baserel);
	if (list_length(remote_conds) > 0)
	{
		appendWhereClause(&sql, is_first, remote_conds, root);
		is_first = false;
	}
	conn = GetConnection(server, user, false);
	get_remote_estimate(sql.data, conn, &rows, &width,
						&startup_cost, &total_cost);
	ReleaseConnection(conn);
	if (list_length(param_conds) > 0)
	{
		appendWhereClause(&sql, is_first, param_conds, root);
		is_first = false;
	}

	/* Give estimated costs to planner via FdwPlan. */
	adjust_costs(baserel->rows, baserel->width, &startup_cost, &total_cost);
	fdwplan->startup_cost = startup_cost;
	fdwplan->total_cost = total_cost;

	/*
	 * Estimate selectivity of conditions which are not used in remote EXPLAIN
	 * by calling clauselist_selectivity().  The best we can do for
	 * parameterized condition is to estimate selectivity on the basis of local
	 * statistics.  When we actually obtain result rows, such conditions are
	 * deparsed into remote query and reduce rows transferred.
	 */
	sel = 1.0;
	sel *= clauselist_selectivity(root, param_conds,
								  baserel->relid, JOIN_INNER, NULL);
	sel *= clauselist_selectivity(root, local_conds,
								  baserel->relid, JOIN_INNER, NULL);
	baserel->rows = rows * sel;
	baserel->width = width;

	/*
	 * Store plain SELECT statement in private area of FdwPlan.  This will be
	 * used for executing remote query and explaining scan.
	 */
	fdw_private = list_make1(makeString(sql.data));

	/* Use specified fetch_count instead of default value, if any. */
	fetch_count_str = GetFdwOptionValue(foreigntableid,
										"fetch_count");
	if (fetch_count_str != NULL)
		fetch_count = strtol(fetch_count_str, NULL, 10);
	elog(DEBUG1,
		 "relid=%u fetch_count=%d",
		 foreigntableid,
		 fetch_count);

	/*
	 * We store some more information in FdwPlan to pass them beyond the
	 * boundary between planner and executor.  Finally FdwPlan using cursor
	 * would hold items below:
	 *
	 * 1) plain SELECT statement (already added above)
	 * 2) SQL statement used to declare cursor
	 * 3) SQL statement used to fetch rows from cursor
	 * 4) SQL statement used to reset cursor
	 * 5) SQL statement used to close cursor
	 *
	 * These items are indexed with the enum FdwPrivateIndex, so an item
	 * can be accessed directly via list_nth().  For example of FETCH
	 * statement:
	 *      list_nth(fdw_private, FdwPrivateFetchSql)
	 */

	/* Construct cursor name from sequential value */
	sprintf(name, CURSOR_NAME_FORMAT, cursor_id++);

	/* Construct statement to declare cursor */
	initStringInfo(&cursor);
	appendStringInfo(&cursor, "DECLARE %s SCROLL CURSOR FOR %s",
					 name, sql.data);
	fdw_private = lappend(fdw_private, makeString(cursor.data));

	/* Construct statement to fetch rows from cursor */
	initStringInfo(&cursor);
	appendStringInfo(&cursor, "FETCH %d FROM %s", fetch_count, name);
	fdw_private = lappend(fdw_private, makeString(cursor.data));

	/* Construct statement to reset cursor */
	initStringInfo(&cursor);
	appendStringInfo(&cursor, "MOVE ABSOLUTE 0 FROM %s", name);
	fdw_private = lappend(fdw_private, makeString(cursor.data));

	/* Construct statement to close cursor */
	initStringInfo(&cursor);
	appendStringInfo(&cursor, "CLOSE %s", name);
	fdw_private = lappend(fdw_private, makeString(cursor.data));

	/* Store FDW private information into FdwPlan */
	fdwplan->fdw_private = fdw_private;

	return fdwplan;
}

/*
 * pgsqlExplainForeignScan
 *		Produce extra output for EXPLAIN
 */
static void
pgsqlExplainForeignScan(ForeignScanState *node, ExplainState *es)
{
	FdwPlan	   *fdwplan;
	char	   *sql;

	fdwplan = ((ForeignScan *) node->ss.ps.plan)->fdwplan;
	sql = strVal(list_nth(fdwplan->fdw_private, FdwPrivateDeclareSql));
	ExplainPropertyText("Remote SQL", sql, es);
}

/*
 * pgsqlBeginForeignScan
 *		Initiate access to a foreign PostgreSQL table.
 */
static void
pgsqlBeginForeignScan(ForeignScanState *node, int eflags)
{
	PgsqlFdwExecutionState *festate;
	MemoryContext	oldcontext;
	PGconn		   *conn;
	Oid				relid;
	ForeignTable   *table;
	ForeignServer  *server;
	UserMapping	   *user;
	TupleTableSlot *slot = node->ss.ss_ScanTupleSlot;

	/*
	 * Do nothing in EXPLAIN (no ANALYZE) case.  node->fdw_state stays NULL.
	 */
	if (eflags & EXEC_FLAG_EXPLAIN_ONLY)
		return;

	/*
	 * Save state in node->fdw_state.
	 */
	festate = (PgsqlFdwExecutionState *) palloc(sizeof(PgsqlFdwExecutionState));
	festate->fdwplan = ((ForeignScan *) node->ss.ps.plan)->fdwplan;

	/*
	 * Get connection to the foreign server.  Connection manager would
	 * establish new connection if necessary.
	 */
	relid = RelationGetRelid(node->ss.ss_currentRelation);
	table = GetForeignTable(relid);
	server = GetForeignServer(table->serverid);
	user = GetUserMapping(GetOuterUserId(), server->serverid);
	conn = GetConnection(server, user, true);
	festate->conn = conn;

	/*
	 * Create tuplestore in current transaction context in order to ensure that
	 * contents are valid until the end of this scan.  It might seem that
	 * transaction context is too long, but result rows must be available even
	 * after the end of current message. We need to do this here, because first
	 * Iterate might be called after SAVEPOINT; rolling-back to such SAVEPOINT
	 * might cause unexpected release of tuplestore.
	 *
	 * Result will be filled in first Iterate call.
	 */
	oldcontext = MemoryContextSwitchTo(CurTransactionContext);
	festate->tuples = tuplestore_begin_heap(false, false, work_mem);
	MemoryContextSwitchTo(oldcontext);
	festate->cursor_opened = false;

	/* Allocate buffers for column values. */
	{
		TupleDesc	tupdesc = slot->tts_tupleDescriptor;
		festate->col_values = palloc(sizeof(char *) * tupdesc->natts);
		festate->attinmeta = TupleDescGetAttInMetadata(tupdesc);
	}

	/* Allocate buffers for query parameters. */
	{
		ParamListInfo	params = node->ss.ps.state->es_param_list_info;
		int				numParams = params ? params->numParams : 0;

		if (numParams > 0)
		{
			festate->param_types = palloc0(sizeof(Oid) * numParams);
			festate->param_values = palloc0(sizeof(char *) * numParams);
		}
		else
		{
			festate->param_types = NULL;
			festate->param_values = NULL;
		}
	}


	/* Store FDW-specific state into ForeignScanState */
	node->fdw_state = (void *) festate;

	return;
}

/*
 * pgsqlIterateForeignScan
 *		Retrieve next row from the result set, or clear tuple slot to indicate
 *		EOF.
 *
 *		Note that using per-query context when retrieving tuples from
 *		tuplestore to ensure that returned tuples can survive until next
 *		iteration because the tuple is released implicitly via ExecClearTuple.
 *		Retrieving a tuple from tuplestore in CurrentMemoryContext (it's a
 *		per-tuple context), ExecClearTuple will free dangling pointer.
 */
static TupleTableSlot *
pgsqlIterateForeignScan(ForeignScanState *node)
{
	PgsqlFdwExecutionState *festate;
	TupleTableSlot *slot = node->ss.ss_ScanTupleSlot;
	PGresult	   *res;
	MemoryContext	oldcontext = CurrentMemoryContext;

	festate = (PgsqlFdwExecutionState *) node->fdw_state;

	/*
	 * If this is the first call after Begin, we need to execute remote query.
	 */
	if (!festate->cursor_opened)
		execute_query(node);

	/*
	 * If enough tuples are left in tuplestore, just return next tuple from it.
	 */
	MemoryContextSwitchTo(node->ss.ps.state->es_query_cxt);
	if (tuplestore_gettupleslot(festate->tuples, true, false, slot))
	{
		MemoryContextSwitchTo(oldcontext);
		return slot;
	}
	MemoryContextSwitchTo(oldcontext);

	/*
	 * Here we need to clear partial result and fetch next bunch of tuples from
	 * from the cursor for the scan.  If the fetch returns no tuple, the scan
	 * has reached the end.
	 */
	res = fetch_result(node);
	PG_TRY();
	{
		store_result(node, res);
		PQclear(res);
		res = NULL;
	}
	PG_CATCH();
	{
		PQclear(res);
		PG_RE_THROW();
	}
	PG_END_TRY();

	/*
	 * If we got more tuples from the server cursor, return next tuple from
	 * tuplestore.
	 */
	MemoryContextSwitchTo(node->ss.ps.state->es_query_cxt);
	if (tuplestore_gettupleslot(festate->tuples, true, false, slot))
	{
		MemoryContextSwitchTo(oldcontext);
		return slot;
	}
	MemoryContextSwitchTo(oldcontext);

	/* We don't have any result even in remote server cursor. */
	ExecClearTuple(slot);
	return slot;
}

/*
 * pgsqlReScanForeignScan
 *   - Restart this scan by resetting fetch location.
 */
static void
pgsqlReScanForeignScan(ForeignScanState *node)
{
	List	   *fdw_private;
	char	   *sql;
	PGconn	   *conn;
	PGresult   *res;
	PgsqlFdwExecutionState *festate;

	festate = (PgsqlFdwExecutionState *) node->fdw_state;

	/* If we have not opened cursor yet, nothing to do. */
	if (!festate->cursor_opened)
		return;

	/* Discard fetch results if any. */
	if (festate->tuples != NULL)
		tuplestore_clear(festate->tuples);

	/* Reset cursor */
	fdw_private = festate->fdwplan->fdw_private;
	conn = festate->conn;
	sql = strVal(list_nth(fdw_private, FdwPrivateResetSql));
	res = PQexec(conn, sql);
	PG_TRY();
	{
		if (PQresultStatus(res) != PGRES_COMMAND_OK)
		{
			ereport(ERROR,
					(errmsg("could not rewind cursor"),
					 errdetail("%s", PQerrorMessage(conn)),
					 errhint("%s", sql)));
		}
		PQclear(res);
		res = NULL;
	}
	PG_CATCH();
	{
		PQclear(res);
		PG_RE_THROW();
	}
	PG_END_TRY();
}

/*
 * pgsqlEndForeignScan
 *		Finish scanning foreign table and dispose objects used for this scan
 */
static void
pgsqlEndForeignScan(ForeignScanState *node)
{
	List	   *fdw_private;
	char	   *sql;
	PGconn	   *conn;
	PGresult   *res;
	PgsqlFdwExecutionState *festate;

	festate = (PgsqlFdwExecutionState *) node->fdw_state;

	/* if festate is NULL, we are in EXPLAIN; nothing to do */
	if (festate == NULL)
		return;

	/* If we have not opened cursor yet, nothing to do. */
	if (!festate->cursor_opened)
		return;

	/* Discard fetch results */
	if (festate->tuples != NULL)
	{
		tuplestore_end(festate->tuples);
		festate->tuples = NULL;
	}

	/* Close cursor */
	fdw_private = festate->fdwplan->fdw_private;
	conn = festate->conn;
	sql = strVal(list_nth(fdw_private, FdwPrivateCloseSql));
	res = PQexec(conn, sql);
	PG_TRY();
	{
		if (PQresultStatus(res) != PGRES_COMMAND_OK)
		{
			ereport(ERROR,
					(errmsg("could not close cursor"),
					 errdetail("%s", PQerrorMessage(conn)),
					 errhint("%s", sql)));
		}
		PQclear(res);
		res = NULL;
	}
	PG_CATCH();
	{
		PQclear(res);
		PG_RE_THROW();
	}
	PG_END_TRY();

	ReleaseConnection(festate->conn);
}

/*
 * Estimate costs of executing given SQL statement.
 */
static void
get_remote_estimate(const char *sql, PGconn *conn,
					double *rows, int *width,
					Cost *startup_cost, Cost *total_cost)
{
	PGresult	   *res = NULL;
	StringInfoData  buf;
	char		   *plan;
	char		   *p;
	int				n;

	/*
	 * Construct EXPLAIN statement with given SQL statement.
	 */
	initStringInfo(&buf);
	appendStringInfo(&buf, "EXPLAIN %s", sql);

	/* PGresult must be released before leaving this function. */
	PG_TRY();
	{
		res = PQexec(conn, buf.data);
		if (PQresultStatus(res) != PGRES_TUPLES_OK || PQntuples(res) == 0)
		{
			char *msg;

			msg = pstrdup(PQerrorMessage(conn));
			ereport(ERROR,
					(errmsg("could not execute EXPLAIN for cost estimation"),
					 errdetail("%s", msg),
					 errhint("%s", sql)));
		}

		/*
		 * Find estimation portion from top plan node. Here we search opening
		 * parentheses from the end of the line to avoid finding unexpected
		 * parentheses.
		 */
		plan = PQgetvalue(res, 0, 0);
		p = strrchr(plan, '(');
		if (p == NULL)
			elog(ERROR, "wrong EXPLAIN output: %s", plan);
		n = sscanf(p,
				   "(cost=%lf..%lf rows=%lf width=%d)",
				   startup_cost, total_cost, rows, width);
		if (n != 4)
			elog(ERROR, "could not get estimation from EXPLAIN output");

		PQclear(res);
		res = NULL;
	}
	PG_CATCH();
	{
		PQclear(res);
		PG_RE_THROW();
	}
	PG_END_TRY();
}

/*
 * Adjust costs estimated on remote end with some overheads such as connection
 * and data transfer.
 */
static void
adjust_costs(double rows, int width, Cost *startup_cost, Cost *total_cost)
{
	/* add cost to establish connection. */
	*startup_cost += CONNECTION_COSTS;
	*total_cost += CONNECTION_COSTS;

	/* add cost to transfer result. */
	*total_cost += TRANSFER_COSTS_PER_BYTE * width * rows;
	*total_cost += cpu_tuple_cost * rows;
}
/*
 * Execute remote query with current parameters.
 */
static void
execute_query(ForeignScanState *node)
{
	FdwPlan		   *fdwplan;
	PgsqlFdwExecutionState *festate;
	ParamListInfo	params = node->ss.ps.state->es_param_list_info;
	int				numParams = params ? params->numParams : 0;
	Oid			   *types = NULL;
	const char	  **values = NULL;
	char		   *sql;
	PGconn		   *conn;
	PGresult	   *res;

	festate = (PgsqlFdwExecutionState *) node->fdw_state;
	types = festate->param_types;
	values = festate->param_values;

	/*
	 * Construct parameter array in text format.  We don't release memory for
	 * the arrays explicitly, because the memory usage would not be very large,
	 * and anyway they will be released in context cleanup.
	 */
	if (numParams > 0)
	{
		int i;

		for (i = 0; i < numParams; i++)
		{
			types[i] = params->params[i].ptype;
			if (params->params[i].isnull)
				values[i] = NULL;
			else
			{
				Oid			out_func_oid;	
				bool		isvarlena;
				FmgrInfo	func;

				getTypeOutputInfo(types[i], &out_func_oid, &isvarlena);
				fmgr_info(out_func_oid, &func);
				values[i] = OutputFunctionCall(&func, params->params[i].value);
			}
		}
	}

	/*
	 * Execute remote query with parameters.
	 */
	conn = festate->conn;
	fdwplan = ((ForeignScan *) node->ss.ps.plan)->fdwplan;
	sql = strVal(list_nth(fdwplan->fdw_private, FdwPrivateDeclareSql));
	res = PQexecParams(conn, sql, numParams, types, values, NULL, NULL, 0);
	PG_TRY();
	{
		/*
		 * If the query has failed, reporting details is enough here.
		 * Connection(s) which are used by this query (at least used by
		 * pgsql_fdw) will be cleaned up by the foreign connection manager.
		 */
		if (PQresultStatus(res) != PGRES_COMMAND_OK)
		{
			ereport(ERROR,
					(errmsg("could not declare cursor"),
					 errdetail("%s", PQerrorMessage(conn)),
					 errhint("%s", sql)));
		}

		/* Mark that this scan has opened a cursor. */
		festate->cursor_opened = true;

		/* Discard result of CURSOR statement and fetch first bunch. */
		PQclear(res);
		res = fetch_result(node);

		/*
		 * Store the result of the query into tuplestore.
		 * We must release PGresult here to avoid memory leak.
		 */
		store_result(node, res);
		PQclear(res);
		res = NULL;
	}
	PG_CATCH();
	{
		PQclear(res);
		PG_RE_THROW();
	}
	PG_END_TRY();
}

/*
 * Fetch next partial result from remote server.
 */
static PGresult *
fetch_result(ForeignScanState *node)
{
	PgsqlFdwExecutionState *festate;
	List		   *fdw_private;
	char		   *sql;
	PGconn		   *conn;
	PGresult	   *res;

	festate = (PgsqlFdwExecutionState *) node->fdw_state;

	/* retrieve information for fetching result. */
	fdw_private = festate->fdwplan->fdw_private;
	sql = strVal(list_nth(fdw_private, FdwPrivateFetchSql));
	conn = festate->conn;
	res = PQexec(conn, sql);
	if (PQresultStatus(res) != PGRES_TUPLES_OK)
	{
		ereport(ERROR,
				(errmsg("could not fetch rows from foreign server"),
				 errdetail("%s", PQerrorMessage(conn)),
				 errhint("%s", sql)));
	}

	return res;
}

/*
 * Create tuples from PGresult and store them into tuplestore.
 */
static void
store_result(ForeignScanState *node, PGresult *res)
{
	int					rows;
	int					row;
	int					i;
	int					nfields;
	int					attnum;		/* number of non-dropped columns */
	Form_pg_attribute  *attrs;
	TupleTableSlot *slot = node->ss.ss_ScanTupleSlot;
	TupleDesc	tupdesc = slot->tts_tupleDescriptor;
	PgsqlFdwExecutionState *festate;

	festate = (PgsqlFdwExecutionState *) node->fdw_state;
	rows = PQntuples(res);
	nfields = PQnfields(res);
	attrs = tupdesc->attrs;

	/* First, make the tuplestore empty. */
	tuplestore_clear(festate->tuples);

	/* count non-dropped columns */
	for (attnum = 0, i = 0; i < tupdesc->natts; i++)
		if (!attrs[i]->attisdropped)
			attnum++;

	/* check result and tuple descriptor have the same number of columns */
	if (attnum > 0 && attnum != nfields)
		ereport(ERROR,
				(errcode(ERRCODE_DATATYPE_MISMATCH),
				 errmsg("remote query result rowtype does not match "
						"the specified FROM clause rowtype"),
				 errdetail("expected %d, actual %d", attnum, nfields)));

	/* put a tuples into the slot */
	for (row = 0; row < rows; row++)
	{
		int			j;
		HeapTuple	tuple;

		for (i = 0, j = 0; i < tupdesc->natts; i++)
		{
			/* skip dropped columns. */
			if (attrs[i]->attisdropped)
			{
				festate->col_values[i] = NULL;
				continue;
			}

			if (PQgetisnull(res, row, j))
				festate->col_values[i] = NULL;
			else
				festate->col_values[i] = PQgetvalue(res, row, j);
			j++;
		}

		/*
		 * Build the tuple and put it into the slot.
		 * We don't have to free the tuple explicitly because it's been
		 * allocated in the per-tuple context.
		 */
		tuple = BuildTupleFromCStrings(festate->attinmeta, festate->col_values);
		tuplestore_puttuple(festate->tuples, tuple);
	}

	tuplestore_donestoring(festate->tuples);
}

