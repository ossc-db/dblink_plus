/*
 * dblink.c
 *
 * Copyright (c) 2011-2025, NTT, Inc.
 */
#include "postgres.h"

#include "access/reloptions.h"
#include "access/xact.h"
#include "catalog/pg_foreign_server.h"
#include "catalog/pg_user_mapping.h"
#include "commands/trigger.h"
#include "executor/spi.h"
#include "foreign/foreign.h"
#include "funcapi.h"
#include "miscadmin.h"
#include "parser/scansup.h"
#include "utils/acl.h"
#include "utils/builtins.h"
#include "utils/memutils.h"

#include "dblink.h"
#include "dblink_internal.h"

#include <time.h>
#ifndef WIN32
#include <unistd.h>
#endif	/* ! WIN32 */

/* required to configure GUC paramer */
#include "utils/guc.h"

/*
 * TODO: replace elog() to ereport() with proper error codes.
 */

PG_MODULE_MAGIC;

#undef open

#define NameGetTextDatum(name)	CStringGetTextDatum(NameStr(name))

/* initial number of connection hashes */
#define NUMCONN		16

/* global transaction id */
#define DBLINK_GTRID_PREFIX		"dblink_plus_"
#define DBLINK_GTRID_MAXSIZE	32

typedef enum ConnStatus
{
	CS_UNUSED = 0,	/* unconnected */
	CS_IDLE,		/* connection idle */
	CS_USED,		/* in transaction */
	CS_PREPARED,	/* transaction is prepared and ready to commit */
} ConnStatus;

static const char *ConnStatusName[] =
{
	"unused",
	"idle",
	"used",
	"prepared",
};

typedef enum FetchType
{
	FT_QUERY = 0,
	FT_FETCH,
	FT_CALL
} FetchType;

typedef struct Conn
{
	NameData			name;
	dblink_connection  *connection;
	ConnStatus			status;
	Oid					server;		/* server oid (only for display) */
	bool				use_xa;		/* true iff use automatic transaction */
	bool				keep;		/* true iff connected by user */
} Conn;

typedef struct Cursor
{
	int32				id;
	dblink_cursor	   *cursor;
} Cursor;

PG_FUNCTION_INFO_V1(dblink_connect);
PG_FUNCTION_INFO_V1(dblink_connect_name);
PG_FUNCTION_INFO_V1(dblink_disconnect);
PG_FUNCTION_INFO_V1(dblink_query);
PG_FUNCTION_INFO_V1(dblink_exec);
PG_FUNCTION_INFO_V1(dblink_open);
PG_FUNCTION_INFO_V1(dblink_fetch);
PG_FUNCTION_INFO_V1(dblink_close);
PG_FUNCTION_INFO_V1(dblink_call);
PG_FUNCTION_INFO_V1(dblink_connections);
PG_FUNCTION_INFO_V1(dblink_atcommit);

extern Datum dblink_connect(PG_FUNCTION_ARGS);
extern Datum dblink_connect_name(PG_FUNCTION_ARGS);
extern Datum dblink_disconnect(PG_FUNCTION_ARGS);
extern Datum dblink_query(PG_FUNCTION_ARGS);
extern Datum dblink_exec(PG_FUNCTION_ARGS);
extern Datum dblink_open(PG_FUNCTION_ARGS);
extern Datum dblink_fetch(PG_FUNCTION_ARGS);
extern Datum dblink_close(PG_FUNCTION_ARGS);
extern Datum dblink_call(PG_FUNCTION_ARGS);
extern Datum dblink_connections(PG_FUNCTION_ARGS);
extern Datum dblink_atcommit(PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(dblink_mysql);
PG_FUNCTION_INFO_V1(dblink_oracle);
PG_FUNCTION_INFO_V1(dblink_sqlite3);

extern Datum dblink_mysql(PG_FUNCTION_ARGS);
extern Datum dblink_oracle(PG_FUNCTION_ARGS);
extern Datum dblink_sqlite3(PG_FUNCTION_ARGS);

extern void _PG_init(void);

static Conn *searchLink(const text *name, HASHACTION action, bool *found);
static Conn *searchLinkByName(const NameData *name, HASHACTION action, bool *found);
static Conn *doConnect(const text *name, const text *servername, bool *isNew);
static Conn *doTransaction(const text *name);
static ForeignServer *getServerByName(const char *name);
static List *getConnectionParams(ForeignServer *server, ForeignDataWrapper *fdw);
static void closeCursors(void);

static void AtCommit_dblink(void);
static void AtEOXact_dblink(XactEvent event, void *arg);
static void RegisterCommitCallback(void);

static HTAB	   *connections;	/* all connections managed by the module */
static List	   *cursors;		/* all cursors managed by the module */
static int32	next_cursor_id = 0;

#define INVALID_CURSOR		0

/* This variable is use by a custom GUC parameter dblink_plus.use_xa. 
 * This parameter is true as default in order to maintain the previous behavior.*/
bool use_xa;

/*
 * Module load callback
 */

void
_PG_init(void)
{
        /*  Define custom GUC variables. */
        DefineCustomBoolVariable("dblink_plus.use_xa",
                                                           "Parameter used for dblink_plus.",
                                                           NULL,
                                                           &use_xa,
                                                           true,
                                                           PGC_USERSET,
                                                           0,
#if PG_VERSION_NUM >= 90100
                                                           NULL,
#endif
                                                           NULL, NULL);

      EmitWarningsOnPlaceholders("dblink_plus");

      srandom((unsigned int) time(NULL));

}

/*
 * dblink_connect(server text) : boolean
 */
Datum
dblink_connect(PG_FUNCTION_ARGS)
{
	text   *name = PG_GETARG_TEXT_PP(0);
	Conn   *conn;
	bool	isNew;

	conn = doConnect(name, name, &isNew);
	conn->use_xa = PG_GETARG_BOOL(1);
	conn->keep = true;

	PG_RETURN_BOOL(isNew);
}

/*
 * dblink_connect_name(name text, server text) : boolean
 */
Datum
dblink_connect_name(PG_FUNCTION_ARGS)
{
	text   *name = PG_GETARG_TEXT_PP(0);
	text   *server = PG_GETARG_TEXT_PP(1);
	Conn   *conn;
	bool	isNew;

	conn = doConnect(name, server, &isNew);
	conn->use_xa = PG_GETARG_BOOL(2);
	conn->keep = true;

	PG_RETURN_BOOL(isNew);
}

/*
 * dblink_disconnect(name text) : boolean
 */
Datum
dblink_disconnect(PG_FUNCTION_ARGS)
{
	text	   *name = PG_GETARG_TEXT_PP(0);
	Conn	   *conn;

	conn = searchLink(name, HASH_FIND, NULL);
	if (conn == NULL)
		PG_RETURN_BOOL(false);	/* not found */

	/*
	 * set to unkeep, but actual disconnection is postponed to
	 * the end of transaction.
	 */
	conn->keep = false;
	PG_RETURN_BOOL(true);
}

typedef struct query_context
{
	dblink_cursor	   *cursor;
	const char		  **values;
} query_context;

static Datum
generic_fetch(FetchType fetch_type, PG_FUNCTION_ARGS)
{
	query_context	   *context;
	FuncCallContext	   *fctx;
	AttInMetadata	   *attinmeta;

	if (SRF_IS_FIRSTCALL())
	{
		Conn		   *conn;
		TupleDesc		tupdesc;
		MemoryContext	mctx;
		dblink_cursor  *cursor;
		int				nfields;

		/* Build a tuple descriptor for our result type */
		if (get_call_result_type(fcinfo, NULL, &tupdesc) != TYPEFUNC_COMPOSITE)
			elog(ERROR, "return type must be a row type");

		fctx = SRF_FIRSTCALL_INIT();

		if (fetch_type != FT_FETCH)
		{
			char   *sql = text_to_cstring(PG_GETARG_TEXT_PP(1));
			int32	fetchsize = PG_GETARG_INT32(2);
			int32	max_value_len = PG_GETARG_INT32(3);

			conn = doTransaction(PG_GETARG_TEXT_PP(0));
			if (fetch_type == FT_QUERY)
				cursor = conn->connection->open(conn->connection, sql, fetchsize, max_value_len);
			else
				cursor = conn->connection->call(conn->connection, sql, fetchsize, max_value_len);
		}
		else
		{
			int32		id = PG_GETARG_INT32(0);
			int32		howmany = PG_GETARG_INT32(1);
			ListCell   *cell;

			if (howmany < 1)
				SRF_RETURN_DONE(fctx);	/* no rows required */
			fctx->max_calls = howmany;

			cursor = NULL;
			foreach(cell, cursors)
			{
				Cursor *cur = (Cursor *) lfirst(cell);
				if (cur->id == id)
				{
					cursor = cur->cursor;
					break;
				}
			}
		}

		if (cursor == NULL)
			SRF_RETURN_DONE(fctx);	/* cursor not found or no tuples */

		nfields = cursor->nfields;
		if (nfields < 1)
			SRF_RETURN_DONE(fctx);	/* no fields */

		mctx = MemoryContextSwitchTo(fctx->multi_call_memory_ctx);
		context = palloc(sizeof(query_context));
		context->cursor = cursor;
		context->values = palloc(nfields * sizeof(char *));

		/* make sure we have a persistent copy of the tupdesc */
		tupdesc = CreateTupleDescCopy(tupdesc);

		/* store needed metadata for subsequent calls */
		attinmeta = TupleDescGetAttInMetadata(tupdesc);
		fctx->attinmeta = attinmeta;

		fctx->user_fctx = context;
		MemoryContextSwitchTo(mctx);
	}
	else
	{
		fctx = SRF_PERCALL_SETUP();
		attinmeta = fctx->attinmeta;
		context = fctx->user_fctx;
	}

	/* Exit if fetch limit exceeded. Don't close cursor in this case. */
	if (fetch_type == FT_FETCH && fctx->call_cntr >= fctx->max_calls)
		SRF_RETURN_DONE(fctx);

	if (context->cursor->fetch(context->cursor, context->values))
	{
		HeapTuple	tuple;
		Datum		result;
		
		tuple = BuildTupleFromCStrings(attinmeta, (char **) context->values);
		result = HeapTupleGetDatum(tuple);

		SRF_RETURN_NEXT(fctx, result);
	}
	else
	{
		ListCell   *cell;
#if PG_VERSION_NUM < 130000
		ListCell   *prev;
#endif

		context->cursor->close(context->cursor);

		/* forget cursor */
#if PG_VERSION_NUM < 130000
		prev = NULL;
#endif
		foreach(cell, cursors)
		{
			Cursor *cur = (Cursor *) lfirst(cell);

			if (cur->cursor == context->cursor)
			{
#if PG_VERSION_NUM < 130000
				cursors = list_delete_cell(cursors, cell, prev);
#else
				cursors = foreach_delete_current(cursors, cell);
#endif
				break;
			}

#if PG_VERSION_NUM < 130000
			prev = cell;
#endif
		}

		SRF_RETURN_DONE(fctx);
	}
}

/*
 * dblink_query(name text, sql text) : SETOF record
 */
Datum
dblink_query(PG_FUNCTION_ARGS)
{
	return generic_fetch(FT_QUERY, fcinfo);
}

/*
 * dblink_exec(name text, sql text) : bigint
 */
Datum
dblink_exec(PG_FUNCTION_ARGS)
{
	Conn	*conn = doTransaction(PG_GETARG_TEXT_PP(0));
	char	*sql = text_to_cstring(PG_GETARG_TEXT_PP(1));
	int64	ntuples;

	ntuples = conn->connection->exec(conn->connection, sql);

	PG_RETURN_INT64(ntuples);
}

/*
 * dblink_open(name text, sql text, fetchsize integer) : cursor
 */
Datum
dblink_open(PG_FUNCTION_ARGS)
{
	Conn		   *conn;
	dblink_cursor  *cursor;
	char		   *sql = text_to_cstring(PG_GETARG_TEXT_PP(1));
	int32			fetchsize = PG_GETARG_INT32(2);
	int32			max_value_len = PG_GETARG_INT32(3);
	MemoryContext	ctx;
	Cursor		   *cur;

	conn = doTransaction(PG_GETARG_TEXT_PP(0));
	cursor = conn->connection->open(conn->connection, sql, fetchsize, max_value_len);
	if (cursor == NULL)
		PG_RETURN_INT32(INVALID_CURSOR);

	ctx = MemoryContextSwitchTo(TopMemoryContext);
	cur = (Cursor *) palloc(sizeof(Cursor));
	cur->id = ++next_cursor_id;
	if (cur->id == INVALID_CURSOR)
		cur->id = ++next_cursor_id;	/* reassign if invalid */
	cur->cursor = cursor;
	cursors = lappend(cursors, cur);
	MemoryContextSwitchTo(ctx);

	PG_RETURN_INT32(cur->id);
}

/*
 * dblink_fetch(cursor, howmany integer) : SETOF record
 */
Datum
dblink_fetch(PG_FUNCTION_ARGS)
{
	return generic_fetch(FT_FETCH, fcinfo);
}

/*
 * dblink_close(cur cursor) : boolean
 */
Datum
dblink_close(PG_FUNCTION_ARGS)
{
	int32		id = PG_GETARG_INT32(0);
	ListCell   *cell;

#if PG_VERSION_NUM < 130000
	ListCell   *prev;
	/* forget cursor */
	prev = NULL;
#endif
	foreach(cell, cursors)
	{
		Cursor *cur = (Cursor *) lfirst(cell);

		if (cur->id == id)
		{
			cur->cursor->close(cur->cursor);
#if PG_VERSION_NUM < 130000
			cursors = list_delete_cell(cursors, cell, prev);
#else
			cursors = foreach_delete_current(cursors, cell);
#endif
			PG_RETURN_BOOL(true);
		}
#if PG_VERSION_NUM < 130000
		prev = cell;
#endif
	}

	PG_RETURN_BOOL(false);
}

/*
 * dblink_call(name text, sql text) : SETOF record
 */
Datum
dblink_call(PG_FUNCTION_ARGS)
{
	return generic_fetch(FT_CALL, fcinfo);
}

/*
 * dblink_connections() :
 * SETOF (name text, server oid, status text, keep boolean)
 */
#define DBLINK_COLS		5
Datum
dblink_connections(PG_FUNCTION_ARGS)
{
	ReturnSetInfo	   *rsinfo = (ReturnSetInfo *) fcinfo->resultinfo;
	TupleDesc			tupdesc;
	Tuplestorestate	   *tupstore;
	MemoryContext		per_query_ctx;
	MemoryContext		oldcontext;

	/* check to see if caller supports us returning a tuplestore */
	if (rsinfo == NULL || !IsA(rsinfo, ReturnSetInfo))
		ereport(ERROR,
				(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
				 errmsg("set-valued function called in context that cannot accept a set")));
	if (!(rsinfo->allowedModes & SFRM_Materialize))
		ereport(ERROR,
				(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
				 errmsg("materialize mode required, but it is not " \
						"allowed in this context")));

	/* Build a tuple descriptor for our result type */
	if (get_call_result_type(fcinfo, NULL, &tupdesc) != TYPEFUNC_COMPOSITE)
		elog(ERROR, "return type must be a row type");

	per_query_ctx = rsinfo->econtext->ecxt_per_query_memory;
	oldcontext = MemoryContextSwitchTo(per_query_ctx);

	tupstore = tuplestore_begin_heap(true, false, work_mem);
	rsinfo->returnMode = SFRM_Materialize;
	rsinfo->setResult = tupstore;
	rsinfo->setDesc = tupdesc;

	if (connections)
	{
		HASH_SEQ_STATUS seq;
		Conn  *conn;

		hash_seq_init(&seq, connections);
		while ((conn = (Conn *) hash_seq_search(&seq)) != NULL)
		{
			Datum		values[DBLINK_COLS];
			bool		nulls[DBLINK_COLS];
			int			i = 0;

			/* generate junk in short-term context */
			MemoryContextSwitchTo(oldcontext);

			memset(values, 0, sizeof(values));
			memset(nulls, 0, sizeof(nulls));

			/* use query for server type */
			values[i++] = CStringGetTextDatum(NameStr(conn->name));
			values[i++] = ObjectIdGetDatum(conn->server);
			values[i++] = CStringGetTextDatum(ConnStatusName[conn->status]);
			values[i++] = BoolGetDatum(conn->use_xa);
			values[i++] = BoolGetDatum(conn->keep);

			Assert(i == DBLINK_COLS);

			/* switch to appropriate context while storing the tuple */
			MemoryContextSwitchTo(per_query_ctx);
			tuplestore_putvalues(tupstore, tupdesc, values, nulls);
		}
	}

	MemoryContextSwitchTo(oldcontext);

	return (Datum) 0;
}

Datum
dblink_atcommit(PG_FUNCTION_ARGS)
{
	TriggerData	   *trigdata = (TriggerData *) fcinfo->context;

	/* make sure it's called as a trigger at all */
	if (!CALLED_AS_TRIGGER(fcinfo) ||
		!TRIGGER_FIRED_AFTER(trigdata->tg_event) ||
		!TRIGGER_FIRED_FOR_STATEMENT(trigdata->tg_event))
		elog(ERROR, "invalid trigger call");

	AtCommit_dblink();

	PG_RETURN_POINTER(NULL);
}

/*
 * search a connection by text type
 */
static Conn *
searchLink(const text *name, HASHACTION action, bool *found)
{
	char	   *short_name;
	NameData	key;

	/*
	 * Truncate name if it's too long for identifier.  If this is a call for
	 * a new connection, warn user that the new connection has truncated name.
	 */
	short_name = text_to_cstring(name);
	truncate_identifier(short_name, strlen(short_name), action == HASH_ENTER);
	MemSet(key.data, 0, NAMEDATALEN);
	strncpy(key.data, short_name, strlen(short_name));

	return searchLinkByName(&key, action, found);
}

/*
 * search a connection by name type
 */
static Conn *
searchLinkByName(const NameData *name, HASHACTION action, bool *found)
{
	if (!connections)
	{
		HASHCTL		ctl;

		ctl.keysize = NAMEDATALEN;
		ctl.entrysize = sizeof(Conn);
		connections = hash_create("dblink", NUMCONN, &ctl, HASH_ELEM);

		/* register transaction callbacks */
		RegisterXactCallback(AtEOXact_dblink, 0);
	}

	return (Conn *) hash_search(connections, name, action, found);
}

static Conn *
doConnect(const text *name, const text *servername, bool *isNew)
{
	char			   *short_name;
	Conn			   *conn;
	bool				found;
	ForeignServer	   *server;
	ForeignDataWrapper *fdw;
	List			   *params;

	/*
	 * Truncate server name if it's too long for identifier because catalog
	 * lookup functions assumes that the given name is shorter than
	 * NAMEDATALEN.  We don't warn users about this truncation, to make the
	 * behavior to be identical to contrib/dblink.
	 */
	short_name = text_to_cstring(servername);
	truncate_identifier(short_name, strlen(short_name), false);
	server = getServerByName(short_name);
	fdw = GetForeignDataWrapper(server->fdwid);

	if (fdw->fdwvalidator == InvalidOid)
		elog(ERROR, "server '%s' and foreign data wrapper '%s' have no connector",
			server->servername, fdw->fdwname);

	params = getConnectionParams(server, fdw);

	conn = searchLink(name, HASH_ENTER, &found);
	if (found && conn->status != CS_UNUSED)
	{
		if (conn->server != server->serverid)
			elog(ERROR, "same name for different server");
	}
	else
	{
		conn->status = CS_UNUSED;
		conn->server = server->serverid;
		/* assign value setting in postgresql.conf dblink_plus.use_xa variable to connection use_xa.*/
		conn->use_xa = use_xa;
	}

	if (conn->status == CS_UNUSED)
	{
		dblink_connection *connection = NULL;

		/* call validator with DBLINKOID mode with dummy parameters. */
		OidFunctionCall4(fdw->fdwvalidator,
			PointerGetDatum(NULL),
			ObjectIdGetDatum(DBLINKOID),
			PointerGetDatum(&connection),
			PointerGetDatum(params));

		if (connection == NULL)
			elog(ERROR, "foreign data wrapper '%s' is not a connector", fdw->fdwname);

		conn->connection = connection;
		conn->status = CS_IDLE;
		conn->keep = false;
	}

	if (isNew)
		*isNew = !found;

	return conn;
}

static Conn *
doTransaction(const text *name)
{
	Conn	   *conn;

	conn = searchLink(name, HASH_FIND, NULL);
	if (conn == NULL)
		conn = doConnect(name, name, NULL);

	switch (conn->status)
	{
	case CS_IDLE:
		if (conn->use_xa)
		{
			/* set gtrid parts */
			conn->connection->gtrid.pid = (int) getpid();
			conn->connection->gtrid.rand = (int) random();
			/* start transaction automatically */
			if (!conn->connection->command(conn->connection, DBLINK_XA_START))
				elog(ERROR, "DBLINK_XA_START failed for '%s'", NameStr(conn->name));
			conn->status = CS_USED;
			RegisterCommitCallback();
		}
		break;
	case CS_USED:
		/* noop */
		break;
	default:
		elog(ERROR, "unexpected status: %d", conn->status);
		break;
	}

	return conn;
}

/*
 * get foreign server by name and check acl.
 */
static ForeignServer *
getServerByName(const char *name)
{
	ForeignServer  *server;
	AclResult		aclresult;

	server = GetForeignServerByName(name, false);

	/* Check permissions, user must have usage on the server. */
#if PG_VERSION_NUM >= 160000
	aclresult = object_aclcheck(ForeignServerRelationId, server->serverid, GetUserId(), ACL_USAGE);
#else
	aclresult = pg_foreign_server_aclcheck(server->serverid, GetUserId(), ACL_USAGE);
#endif
	if (aclresult != ACLCHECK_OK)

#if PG_VERSION_NUM < 110000
		aclcheck_error(aclresult, ACL_KIND_FOREIGN_SERVER, server->servername);
#else
		aclcheck_error(aclresult, OBJECT_FOREIGN_SERVER, server->servername);
#endif /* PG_VERSION_NUM */

	return server;
}

static void
RegisterCommitCallback(void)
{
	/* this DELETE is only for registering two-phase trigger. */
	SPI_connect();
	SPI_exec("DELETE FROM dblink.atcommit", 1);
	SPI_finish();
}

/*
 * Commit all remote transaction with 2PC.
 */
static void
AtCommit_dblink(void)
{
	closeCursors();
	if (connections)
	{
		HASH_SEQ_STATUS seq;
		Conn		   *conn;

		hash_seq_init(&seq, connections);
		while ((conn = (Conn *) hash_seq_search(&seq)) != NULL)
		{
			if (conn->status == CS_USED)
			{
				if (!conn->connection->command(conn->connection, DBLINK_XA_PREPARE))
					elog(ERROR, "DBLINK_XA_PREPARE failed for '%s'", NameStr(conn->name));
				conn->status = CS_PREPARED;
			}
		}

		hash_seq_init(&seq, connections);
		while ((conn = (Conn *) hash_seq_search(&seq)) != NULL)
		{
			if (conn->status == CS_PREPARED)
			{
				if (!conn->connection->command(conn->connection, DBLINK_XA_COMMIT))
				{
					/* XXX: or FATAL? */
					elog(WARNING, "DBLINK_XA_COMMIT failed for '%s'", NameStr(conn->name));
				}
				conn->status = CS_IDLE;
			}
		}
	}
}

/*
 * Rollback all remote transaction on error.
 */
static void
AtEOXact_dblink(XactEvent event, void *arg)
{
	HASH_SEQ_STATUS seq;
	Conn		   *conn;

	closeCursors();
	if (connections == NULL || hash_get_num_entries(connections) < 1)
		return;

	hash_seq_init(&seq, connections);
	while ((conn = (Conn *) hash_seq_search(&seq)) != NULL)
	{
		switch (conn->status)
		{
		case CS_USED:
			conn->connection->command(conn->connection, DBLINK_ROLLBACK);
			conn->status = CS_IDLE;
			break;
		case CS_PREPARED:
			conn->connection->command(conn->connection, DBLINK_XA_ROLLBACK);
			conn->status = CS_IDLE;
			break;
		default:
			break;
		}

		/* disconnect automatic connections */
		if (conn->status == CS_IDLE && !conn->keep)
		{
			conn->connection->disconnect(conn->connection);
			conn->status = CS_UNUSED;
		}

		/* remove if unused */
		if (conn->status == CS_UNUSED)
			searchLinkByName(&conn->name, HASH_REMOVE, NULL);
	}
}

/*
 * Obtain connection string for a foreign server
 */
static List *
getConnectionParams(ForeignServer *server, ForeignDataWrapper *fdw)
{
	UserMapping *user_mapping;
	Oid			serverid;
	Oid			fdwid;
	Oid			userid;
	List	   *result;

	serverid = server->serverid;
	fdwid = server->fdwid;
	userid = GetUserId();
	user_mapping = GetUserMapping(userid, serverid);
	fdw = GetForeignDataWrapper(fdwid);

	result = list_copy(fdw->options);
	result = list_concat(result, list_copy(server->options));
	result = list_concat(result, list_copy(user_mapping->options));

	return result;
}

static void
closeCursors(void)
{
	ListCell *cell;

	if (cursors != NIL)
	{
		foreach(cell, cursors)
		{
			Cursor *cur = (Cursor *) lfirst(cell);
			cur->cursor->close(cur->cursor);
		}
		list_free(cursors);
		cursors = NIL;
	}
}

void
dblink_error(int sqlstate,
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

void dblink_elog(int level, const char *message)
{
	elog(level, "%s", message);
}

void
set_dblink_gtrid(char *str,
				 size_t size,
				 const char *format,
				 dblink_connection base)
{
	char	gtrid[DBLINK_GTRID_MAXSIZE+1];

	/* set global transaction id from gtrid parts */
	snprintf(gtrid, lengthof(gtrid), "%s%010d%010d",
		DBLINK_GTRID_PREFIX, base.gtrid.pid, base.gtrid.rand);
	snprintf(str, size, format, gtrid);
}

/*
 * connectors
 */

typedef struct Option
{
	const char *optname;
	Oid			optcontext;		/* Oid of catalog in which option may appear */
} Option;

static bool
is_conninfo_option(const char *option, Oid context, const Option options[])
{
	const Option *opt;

	for (opt = options; opt->optname; opt++)
		if ((context == opt->optcontext || context == InvalidOid) && strcmp(opt->optname, option) == 0)
			return true;
	return false;
}

static bool
validate_options(Datum options_datum, Oid catalog, const Option options[])
{
	List	   *options_list;
	ListCell   *cell;

	options_list = untransformRelOptions(options_datum);

	foreach(cell, options_list)
	{
		DefElem    *def = lfirst(cell);

		if (!is_conninfo_option(def->defname, catalog, options))
		{
			const Option *opt;
			StringInfoData buf;

			/*
			 * Unknown option specified, complain about it. Provide a hint
			 * with list of valid options for the object.
			 */
			initStringInfo(&buf);
			for (opt = options; opt->optname; opt++)
				if (catalog == InvalidOid || catalog == opt->optcontext)
					appendStringInfo(&buf, "%s%s", (buf.len > 0) ? ", " : "",
									 opt->optname);

			ereport(ERROR,
					(errcode(ERRCODE_SYNTAX_ERROR),
					 errmsg("invalid option \"%s\"", def->defname),
				errhint("Valid options in this context are: %s", buf.data)));

			return false;
		}
	}

	return true;
}

#if defined(ENABLE_MYSQL) || defined(ENABLE_ORACLE) || defined(ENABLE_SQLITE3)
static void 
parse_options(List *args, const Option options[], const char *params[])
{
	int		i;

	for (i = 0; options[i].optname; i++)
	{
		ListCell	   *cell;

		params[i] = NULL;
		foreach(cell, args)
		{
			DefElem    *def = lfirst(cell);

			if (pg_strcasecmp(def->defname, options[i].optname) == 0)
			{
				params[i] = strVal(def->arg);
				break;
			}
		}
	}
}
#endif

Datum
dblink_mysql(PG_FUNCTION_ARGS)
{
	static const Option mysql_options[] = {
		{"user", UserMappingRelationId},
		{"password", UserMappingRelationId},
		{"dbname", ForeignServerRelationId},
		{"host", ForeignServerRelationId},
		{"port", ForeignServerRelationId},
		{NULL, InvalidOid}
	};

	Oid			catalog = PG_GETARG_OID(1);

	if (catalog == DBLINKOID)
	{
#ifdef ENABLE_MYSQL
		dblink_connection **connection;
		const char		   *params[5];

		connection = (dblink_connection **) PG_GETARG_POINTER(2);
		if (!connection)
			PG_RETURN_BOOL(false);

		parse_options((List *) PG_GETARG_POINTER(3), mysql_options, params);

		*connection = mylink_connect(params[0], params[1], params[2],
			params[3], params[4] ? atoi(params[4]) : 0);
		PG_RETURN_BOOL(*connection != NULL);
#else
		elog(ERROR, "dblink.mysql is disabled");
		PG_RETURN_BOOL(false);
#endif
	}
	else
	{
		PG_RETURN_BOOL(validate_options(
			PG_GETARG_DATUM(0), catalog, mysql_options));
	}
}

Datum
dblink_oracle(PG_FUNCTION_ARGS)
{
	static const Option oracle_options[] = {
		{"user", UserMappingRelationId},
		{"password", UserMappingRelationId},
		{"dbname", ForeignServerRelationId},
		{"max_value_len", ForeignServerRelationId},
		{NULL, InvalidOid}
	};

	Oid			catalog = PG_GETARG_OID(1);

	if (catalog == DBLINKOID)
	{
#ifdef ENABLE_ORACLE
		dblink_connection **connection;
		const char		   *params[4];
		int64				val;
		int32				max_value_len;
		char			   *endptr;

		connection = (dblink_connection **) PG_GETARG_POINTER(2);
		if (!connection)
			PG_RETURN_BOOL(false);

		parse_options((List *) PG_GETARG_POINTER(3), oracle_options, params);

		/* get max_value_len */
		max_value_len = -1;
		if (params[3])
		{
			errno = 0;
			val = strtol(params[3], &endptr, 0);
			if (endptr == params[3] || errno == ERANGE ||
				val != (int64) ((int32) val))
			{
				elog(ERROR,
					 "dblink.oracle: invalid value for parameter \"%s\": \"%s\"",
					 oracle_options[3].optname, params[3]);
				PG_RETURN_BOOL(false);
			}
			max_value_len = (int32) val;
		}

		*connection = oralink_connect(params[0], params[1], params[2], max_value_len);
		PG_RETURN_BOOL(*connection != NULL);
#else
		elog(ERROR, "dblink.oracle is disabled");
		PG_RETURN_BOOL(false);
#endif
	}
	else
	{
		PG_RETURN_BOOL(validate_options(
			PG_GETARG_DATUM(0), catalog, oracle_options));
	}
}

Datum
dblink_sqlite3(PG_FUNCTION_ARGS)
{
	static const Option sqlite3_options[] = {
		{"location", ForeignServerRelationId},
		{NULL, InvalidOid}
	};

	Oid			catalog = PG_GETARG_OID(1);

	if (catalog == DBLINKOID)
	{
#ifdef ENABLE_SQLITE3
		dblink_connection **connection;
		const char		   *params[1];

		connection = (dblink_connection **) PG_GETARG_POINTER(2);
		if (!connection)
			PG_RETURN_BOOL(false);

		parse_options((List *) PG_GETARG_POINTER(3), sqlite3_options, params);

		*connection = sq3link_connect(params[0]);
		PG_RETURN_BOOL(*connection != NULL);
#else
		elog(ERROR, "dblink.sqlite3 is disabled");
		PG_RETURN_BOOL(false);
#endif
	}
	else
	{
		PG_RETURN_BOOL(validate_options(
			PG_GETARG_DATUM(0), catalog, sqlite3_options));
	}
}
