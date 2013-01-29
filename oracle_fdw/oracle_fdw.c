/*-------------------------------------------------------------------------
 *
 * oracle_fdw.c
 *		  foreign-data wrapper for remote Oracle servers.
 *
 * Copyright (c) 2011, NIPPON TELEGRAPH AND TELEPHONE CORPORATION
 *
 * IDENTIFICATION
 *		  contrib/oracle_fdw/oracle_fdw.c
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
#include "optimizer/cost.h"
#include "utils/lsyscache.h"
#include "utils/memutils.h"
#include "utils/rel.h"

#include "oracle_fdw.h"
#include "former_pg.h"
#include "deparse.h"
#include "connection.h"

PG_MODULE_MAGIC;

/*
 * Default fetch size for cursor.  This can be overrideen by fetchsize FDW
 * option.
 */
#define DEFAULT_FETCHSIZE			100

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
 * Oracle specific portion of a foreign query request
 */
typedef struct OraFdwExecutionState
{
	FdwPlan	   *fdwplan;	/* FDW-specific planning information */
	ORAconn	   *conn;		/* connection for the scan */
	ORAresult   *res;		/* result of the scan, held until the scan ends */
} OraFdwExecutionState;

/*
 * SQL functions
 */
extern Datum oracle_fdw_handler(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(oracle_fdw_handler);

/*
 * FDW callback routines
 */
static FdwPlan *oraPlanForeignScan(Oid foreigntableid,
								   PlannerInfo *root,
								   RelOptInfo *baserel);
static void oraExplainForeignScan(ForeignScanState *node, ExplainState *es);
static void oraBeginForeignScan(ForeignScanState *node, int eflags);
static TupleTableSlot *oraIterateForeignScan(ForeignScanState *node);
static void oraReScanForeignScan(ForeignScanState *node);
static void oraEndForeignScan(ForeignScanState *node);

/*
 * Helper functions
 */
static void estimate_costs(PlannerInfo *root,
						   RelOptInfo *baserel,
						   const char *sql,
						   Cost *startup_cost,
						   Cost *total_cost);
static void execute_query(ForeignScanState *node);
static void store_result(TupleTableSlot *slot, ORAresult *res);

/*
 * Foreign-data wrapper handler function: return a struct with pointers
 * to my callback routines.
 */
Datum
oracle_fdw_handler(PG_FUNCTION_ARGS)
{
	FdwRoutine *fdwroutine = makeNode(FdwRoutine);

	fdwroutine->PlanForeignScan = oraPlanForeignScan;
	fdwroutine->ExplainForeignScan = oraExplainForeignScan;
	fdwroutine->BeginForeignScan = oraBeginForeignScan;
	fdwroutine->IterateForeignScan = oraIterateForeignScan;
	fdwroutine->ReScanForeignScan = oraReScanForeignScan;
	fdwroutine->EndForeignScan = oraEndForeignScan;

	PG_RETURN_POINTER(fdwroutine);
}

/*
 * oraPlanForeignScan
 *		Create a FdwPlan for a scan on the foreign table
 */
static FdwPlan *
oraPlanForeignScan(Oid foreigntableid,
				   PlannerInfo *root,
				   RelOptInfo *baserel)
{
	FdwPlan	   *fdwplan;
	char	   *sql;

	/* Construct FdwPlan with cost estimates */
	fdwplan = makeNode(FdwPlan);
	sql = deparseSql(foreigntableid, root, baserel);
	estimate_costs(root, baserel, sql,
				   &fdwplan->startup_cost, &fdwplan->total_cost);

	/*
	 * Store plain SELECT statement in private area of FdwPlan.  This will be
	 * used for executing remote query and explaining scan.
	 */
	fdwplan->fdw_private = list_make1(makeString(sql));

	return fdwplan;
}

/*
 * oraExplainForeignScan
 *		Produce extra output for EXPLAIN
 */
static void 
oraExplainForeignScan(ForeignScanState *node, struct ExplainState *es)
{
	FdwPlan	   *fdwplan;
	char	   *sql;

	fdwplan = ((ForeignScan *) node->ss.ps.plan)->fdwplan;
	sql = strVal(list_nth(fdwplan->fdw_private, 0));
	ExplainPropertyText("Remote SQL", sql, es);
}

/*
 * oraBeginForeignScan
 *		Initiate access to a foreign Oracle table.
 */
static void
oraBeginForeignScan(ForeignScanState *node, int eflags)
{
	OraFdwExecutionState *festate;
	ORAconn		   *conn;
	Oid				relid;
	ForeignTable   *table;
	ForeignServer  *server;
	UserMapping	   *user;

	/*
	 * Do nothing in EXPLAIN (no ANALYZE) case.  node->fdw_state stays NULL.
	 */
	if (eflags & EXEC_FLAG_EXPLAIN_ONLY)
		return;

	/*
	 * Save state in node->fdw_state.
	 */
	festate = (OraFdwExecutionState *) palloc(sizeof(OraFdwExecutionState));
	festate->fdwplan = ((ForeignScan *) node->ss.ps.plan)->fdwplan;

	/*
	 * Get connection to the foreign server.  Connection manager would
	 * establish new connection if necessary.
	 */
	relid = RelationGetRelid(node->ss.ss_currentRelation);
	table = GetForeignTable(relid);
	server = GetForeignServer(table->serverid);
	user = GetUserMapping(GetOuterUserId(), server->serverid);
	conn = GetConnection(server, user);
	festate->conn = conn;

	/* Result will be filled in first Iterate call. */
	festate->res = NULL;

	/* Store FDW-specific state into ForeignScanState */
	node->fdw_state = (void *) festate;

	return;
}

/*
 * oraIterateForeignScan
 *		Retrieve next row from the result set, or clear tuple slot to indicate
 *		EOF.
 */
static TupleTableSlot *
oraIterateForeignScan(ForeignScanState *node)
{
	OraFdwExecutionState *festate;
	TupleTableSlot *slot = node->ss.ss_ScanTupleSlot;

	festate = (OraFdwExecutionState *) node->fdw_state;

	/*
	 * If this is the first call after Begin, we need to execute remote query.
	 * If the query needs cursor, we declare a cursor at first call and fetch
	 * from it in later calls.
	 */
	if (festate->res == NULL)
		execute_query(node);


	if (ORAhasNext(festate->res))
	{
		store_result(slot, festate->res);
		return slot;
	}

	/* We don't have any result even in remote server cursor. */
	ExecClearTuple(slot);
	return slot;
}

/*
 * oraReScanForeignScan
 *   - Restart this scan by resetting fetch location.
 */
static void
oraReScanForeignScan(ForeignScanState *node)
{
	OraFdwExecutionState *festate;

	festate = (OraFdwExecutionState *) node->fdw_state;

	if (festate->res);
		ORAclear(festate->res);

	execute_query(node);
}

/*
 * oraEndForeignScan
 *		Finish scanning foreign table and dispose objects used for this scan
 */
static void
oraEndForeignScan(ForeignScanState *node)
{
	OraFdwExecutionState *festate;

	festate = (OraFdwExecutionState *) node->fdw_state;

	/* if festate is NULL, we are in EXPLAIN; nothing to do */
	if (festate == NULL)
		return;

	if (festate->res);
		ORAclear(festate->res);

	//ReleaseConnection(festate->conn);
}

/*
 * Estimate costs of scanning a foreign table.
 */
static void
estimate_costs(PlannerInfo *root, RelOptInfo *baserel,
			   const char *sql,
			   Cost *startup_cost, Cost *total_cost)
{
	/* TODO Selectivity of quals pushed down should be considered. */

	*startup_cost += CONNECTION_COSTS;
	*total_cost += CONNECTION_COSTS;

	/* add cost to transfer result. */
	*total_cost += TRANSFER_COSTS_PER_BYTE * baserel->width * baserel->tuples;
	*total_cost += cpu_tuple_cost * baserel->tuples;
}

/*
 * Execute remote query with current parameters.
 */
static void
execute_query(ForeignScanState *node)
{
	OraFdwExecutionState *festate;
	ORAconn		   *conn;
	FdwPlan		   *fdwplan;
	char		   *sql;
	Oid				relid;
	ForeignTable   *table;
	const char	   *value;
	int				fetchsize;
	int				max_value_len;
	ORAresult	   *res;
	MemoryContext	oldcontext;

	festate = (OraFdwExecutionState *) node->fdw_state;

	/*
	 * Execute remote query with parameters.
	 */
	conn = festate->conn;
	fdwplan = ((ForeignScan *) node->ss.ps.plan)->fdwplan;
	sql = strVal(list_nth(fdwplan->fdw_private, 0));

	relid = RelationGetRelid(node->ss.ss_currentRelation);
	table = GetForeignTable(relid);

	value = GetFdwOptionList(table->options, "fetchsize");
	fetchsize = value ? parse_int_value(value, "fetchsize") :
							ORAfetchsize(conn);
	fetchsize = (fetchsize > 0) ? fetchsize : DEFAULT_FETCHSIZE;

	value = GetFdwOptionList(table->options, "max_value_len");
	max_value_len = value ? parse_int_value(value, "max_value_len") :
							ORAmax_value_len(conn);

	/* -1 is the terminal null character of the fetch buffer. */
	if (max_value_len > MAX_DATA_SIZE - 1)
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
				 errmsg("max_value_len cannot exceed %d", MAX_DATA_SIZE - 1)));

	oldcontext = MemoryContextSwitchTo(node->ss.ps.state->es_query_cxt);
	res = ORAopen(conn, sql, fetchsize, max_value_len);
	MemoryContextSwitchTo(oldcontext);

	/*
	 * If the query has failed, reporting details is enough here.
	 * Connections which are used by this query (including other scans) will
	 * be cleaned up by the foreign connection manager.
	 */
	if (!res || ORAresultStatus(res) != PGRES_TUPLES_OK)
	{
		char *msg;

		msg = pstrdup(ORAerrorMessage(conn));
		ORAclear(res);
		ereport(ERROR,
				(errmsg("could not execute foreign query"),
				 errdetail("%s", msg),
				 errhint("%s", sql)));
	}

	oldcontext = MemoryContextSwitchTo(node->ss.ps.state->es_query_cxt);
	TupleFormerInit(ORAgetTupleFormer(res),
		node->ss.ss_ScanTupleSlot->tts_tupleDescriptor);
	MemoryContextSwitchTo(oldcontext);

	festate->res = res;
}

/*
 * Create tuples from ORAresult and store them into slot.
 */
static void
store_result(TupleTableSlot *slot, ORAresult *res)
{
	int					i;
	int					nfields;
	Datum	   *dvalues;
	bool	   *nulls;
	Form_pg_attribute  *attrs;
	TupleDesc	tupdesc = slot->tts_tupleDescriptor;

	nfields = ORAnfields(res);
	attrs = tupdesc->attrs;

	/* buffer should include dropped columns */
	dvalues = (Datum *) palloc(tupdesc->natts * sizeof(Datum));
	nulls = (bool *) palloc(tupdesc->natts * sizeof(bool));

	/* put all tuples into the tuplestore */
	{
		int			j;
		HeapTuple	tuple;

		for (i = 0, j = 0; i < tupdesc->natts; i++)
		{
			/* skip dropped columns. */
			if (attrs[i]->attisdropped)
			{
				nulls[i] = true;
				continue;
			}

			if (ORAgetisnull(res, j))
				nulls[i] = true;
			else
			{
				char   *value;
				int		size;

				value = ORAgetvalue(res, j);
				size = ORAgetamountsize(res, j);
				dvalues[i] = TupleFormerValue(ORAgetTupleFormer(res),
								value, size, j);
				nulls[i] = false;
			}

			j++;
		}

		/*
		 * Build the tuple and put it into the slot.
		 * We don't have to free the tuple explicitly because it's been
		 * allocated in the per-tuple context.
		 */
		tuple = heap_form_tuple(tupdesc, dvalues, nulls);
		ExecStoreTuple(tuple, slot, InvalidBuffer, false);
	}

	pfree(dvalues);
	pfree(nulls);
}

void
ora_ereport(int sqlstate,
			 const char *message,
			 const char *detail,
			 const char *hint,
			 const char *context)
{
	ereport(ERROR, (errcode(sqlstate),
		message ? errmsg("%s", message) : errmsg("unknown error"),
		detail ? errdetail("%s", detail) : 0,
		hint ? errhint("%s", hint) : 0,
		context ? errcontext("%s", context) : 0));
}

void
ora_elog(int level, const char *message)
{
	elog(level, "%s", message);
}
