/*-------------------------------------------------------------------------
 *
 * connection.c
 *		  Connection management for oracle_fdw
 *
 * Copyright (c) 2011, NIPPON TELEGRAPH AND TELEPHONE CORPORATION
 *
 * IDENTIFICATION
 *		  contrib/oracle_fdw/connection.c
 *
 *-------------------------------------------------------------------------
 */
#include "postgres.h"

#include "catalog/pg_type.h"
#include "commands/variable.h"
#include "foreign/foreign.h"
#include "funcapi.h"
#include "libpq-fe.h"
#include "mb/pg_wchar.h"
#include "miscadmin.h"
#include "utils/array.h"
#include "utils/builtins.h"
#include "utils/hsearch.h"
#include "utils/memutils.h"
#include "utils/resowner.h"
#include "utils/tuplestore.h"

#include "connection.h"

/* ============================================================================
 * Connection management functions
 * ==========================================================================*/

/*
 * Connection cache entry managed with hash table.
 */
typedef struct ConnCacheEntry
{
	/* hash key must be first */
	Oid				serverid;	/* oid of foreign server */
	Oid				userid;		/* oid of local user */

	int				refs;		/* reference counter */
	ORAconn		   *conn;		/* foreign server connection */
} ConnCacheEntry;

/*
 * Hash table which is used to cache connection to PostgreSQL servers, will be
 * initialized before first attempt to connect PostgreSQL server by the backend.
 */
static HTAB *FSConnectionHash;

/* ----------------------------------------------------------------------------
 * prototype of private functions
 * --------------------------------------------------------------------------*/
static void
cleanup_connection(ResourceReleasePhase phase,
				   bool isCommit,
				   bool isTopLevel,
				   void *arg);
static ORAconn *connect_ora_server(ForeignServer *server, UserMapping *user);
static bool check_conn_params_change(ORAconn *conn,
									 ForeignServer *server,
									 UserMapping *user);

/*
 * Get a ORAconn which can be used to execute foreign query on the remote
 * PostgreSQL server with the user's authorization.  If this was the first
 * request for the server, new connection is established.
 */
ORAconn *
GetConnection(ForeignServer *server, UserMapping *user)
{
	bool			found;
	ConnCacheEntry *entry;
	ConnCacheEntry	key;
	ORAconn		   *conn = NULL;

	/* initialize connection cache if it isn't */
	if (FSConnectionHash == NULL)
	{
		HASHCTL		ctl;

		/* hash key is a pair of oids: serverid and userid */
		MemSet(&ctl, 0, sizeof(ctl));
		ctl.keysize = sizeof(Oid) + sizeof(Oid);
		ctl.entrysize = sizeof(ConnCacheEntry);
		ctl.hash = tag_hash;
		ctl.match = memcmp;
		ctl.keycopy = memcpy;
		/* allocate FSConnectionHash in the cache context */
		ctl.hcxt = CacheMemoryContext;
		FSConnectionHash = hash_create("Foreign Connections", 32,
									   &ctl,
									   HASH_ELEM | HASH_CONTEXT |
									   HASH_FUNCTION | HASH_COMPARE |
									   HASH_KEYCOPY);
	}

	/* Create key value for the entry. */
	MemSet(&key, 0, sizeof(key));
	key.serverid = server->serverid;
	key.userid = GetOuterUserId();

	/* Is there any cached and valid connection with such key? */
	entry = hash_search(FSConnectionHash, &key, HASH_ENTER, &found);
	if (found)
	{
		if (entry->conn != NULL)
		{
			if (check_conn_params_change(entry->conn, server, user))
			{
				const char *value;
				int			fetchsize;
				int			max_value_len;

				value = GetFdwOptionList(server->options, "fetchsize");
				fetchsize = value ? parse_int_value(value, "fetchsize") : 0;
				value = GetFdwOptionList(server->options, "max_value_len");
				max_value_len = value ? parse_int_value(value, "max_value_len") : 0;

				/* -1 is the terminal null character of the fetch buffer. */
				if (max_value_len > MAX_DATA_SIZE - 1)
				{
					ereport(ERROR,
							(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
							 errmsg("max_value_len cannot exceed %d", MAX_DATA_SIZE - 1)));
				}


				ORAsetFetchsize(entry->conn, fetchsize);
				ORAsetMaxValueLen(entry->conn, max_value_len);
				entry->refs++;
				elog(DEBUG1,
					 "reuse connection %u/%u (%d)",
					 entry->serverid,
					 entry->userid,
					 entry->refs);
				return entry->conn;
			}

			ORAfinish(entry->conn);
			entry->refs = 0;
			entry->conn = NULL;
		}

		/*
		 * Connection cache entry was found but connection in it is invalid.
		 * We reuse entry to store newly established connection later.
		 */
	}
	else
	{
		/*
		 * Use ResourceOwner to clean the connection up on error including
		 * user interrupt.
		 */
		elog(DEBUG1,
			 "create entry for %u/%u (%d)",
			 entry->serverid,
			 entry->userid,
			 entry->refs);
		entry->refs = 0;
		entry->conn = NULL;
		RegisterResourceReleaseCallback(cleanup_connection, entry);
	}

	/*
	 * Here we have to establish new connection.
	 * Use PG_TRY block to ensure closing connection on error.
	 */
	PG_TRY();
	{
		/* Connect to the foreign Oracle server */
		conn = connect_ora_server(server, user);

		/*
		 * Initialize the cache entry to keep new connection.
		 * Note: key items of entry has been initialized in
		 * hash_search(HASH_ENTER).
		 */
		entry->refs = 1;
		entry->conn = conn;
		elog(DEBUG1,
			 "connected to %u/%u (%d)",
			 entry->serverid,
			 entry->userid,
			 entry->refs);
	}
	PG_CATCH();
	{
		ORAfinish(conn);
		entry->refs = 0;
		entry->conn = NULL;
		PG_RE_THROW();
	}
	PG_END_TRY();

	return conn;
}

static void
check_conn_params(const char *user, const char *password)
{
	/* if params contain a empty user */
	if (!user || user[0] == '\0')
		ereport(ERROR,
				(errcode(ERRCODE_S_R_E_PROHIBITED_SQL_STATEMENT_ATTEMPTED),
				 errmsg("user is required")));

	/* if params contain a empty password */
	if (!password || password[0] == '\0')
		ereport(ERROR,
				(errcode(ERRCODE_S_R_E_PROHIBITED_SQL_STATEMENT_ATTEMPTED),
				 errmsg("password is required")));
}

static ORAconn *
connect_ora_server(ForeignServer *server, UserMapping *user)
{
	const char	   *conname = server->servername;
	ORAconn		   *conn;
	const char	   *orauser;
	const char	   *password;
	const char	   *dbname;
	const char	   *value;
	int				fetchsize;
	int				max_value_len;

	/*
	 * Construct connection params from generic options of ForeignServer and
	 * UserMapping.  Generic options might not be a one of connection options.
	 */
	orauser = GetFdwOptionList(user->options, "user");
	password = GetFdwOptionList(user->options, "password");
	dbname = GetFdwOptionList(server->options, "dbname");
	value = GetFdwOptionList(server->options, "fetchsize");
	fetchsize = value ? parse_int_value(value, "fetchsize") : 0;
	value = GetFdwOptionList(server->options, "max_value_len");
	max_value_len = value ? parse_int_value(value, "max_value_len") : 0;

	/* -1 is the terminal null character of the fetch buffer. */
	if (max_value_len > MAX_DATA_SIZE - 1)
	{
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
				 errmsg("max_value_len cannot exceed %d", MAX_DATA_SIZE - 1)));
	}

	/* verify connection parameters and do connect */
	check_conn_params(orauser, password);
	conn = ORAsetdbLogin(orauser, password, dbname, show_timezone(), fetchsize, max_value_len);
	if (!conn || ORAstatus(conn) != CONNECTION_OK)
	{
		char   *msg;

		msg = pstrdup(ORAerrorMessage(conn));
		ORAfinish(conn);
		ereport(ERROR,
				(errcode(ERRCODE_SQLCLIENT_UNABLE_TO_ESTABLISH_SQLCONNECTION),
				 errmsg("could not connect to server \"%s\"", conname),
				 errdetail("%s", msg)));
	}

	return conn;
}

/*
 * Mark the connection as "unused", and close it if the caller was the last
 * user of the connection.
 */
void
ReleaseConnection(ORAconn *conn)
{
	HASH_SEQ_STATUS		scan;
	ConnCacheEntry	   *entry;

	if (conn == NULL)
		return;

	/*
	 * We need to scan sequentially since we use the address to find appropriate
	 * ORAconn from the hash table.
	 */ 
	hash_seq_init(&scan, FSConnectionHash);
	while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)))
	{
		if (entry->conn == conn)
			break;
	}
	if (entry != NULL)
		hash_seq_term(&scan);

	/*
	 * If the released connection was an orphan, just close it.
	 */
	if (entry == NULL)
	{
		ORAfinish(conn);
		return;
	}

	/* If the caller was the last referer, unregister it from cache. */
	entry->refs--;
}

/*
 * Clean the connection up via ResourceOwner.
 */
static void
cleanup_connection(ResourceReleasePhase phase,
				   bool isCommit,
				   bool isTopLevel,
				   void *arg)
{
	ConnCacheEntry *entry = (ConnCacheEntry *) arg;

	/* If the transaction was committed, don't close connections. */
	if (isCommit)
		return;

	/*
	 * We clean the connection up on post-lock because foreign connections are
	 * backend-internal resource.
	 */
	if (phase != RESOURCE_RELEASE_AFTER_LOCKS)
		return;

	/*
	 * We ignore cleanup for ResourceOwners other than transaction.  At this
	 * point, such a ResourceOwner is only Portal. 
	 */
	if (CurrentResourceOwner != CurTransactionResourceOwner)
		return;

	/*
	 * We don't care whether we are in TopTransaction or Subtransaction.
	 * Anyway, we close the connection and reset the reference counter.
	 */
	if (entry->conn != NULL)
	{
		elog(DEBUG1,
			 "closing connection %u/%u",
			 entry->serverid,
			 entry->userid);
		ORAfinish(entry->conn);
		entry->refs = 0;
		entry->conn = NULL;
	}
	else
		elog(DEBUG1,
			 "connection %u/%u already closed",
			 entry->serverid,
			 entry->userid);
}

static bool
equal_value(const char *val1, const char *val2)
{
	if (val1 == NULL && val2 == NULL)
		return true;

	if (val1 == NULL || val2 == NULL)
		return false;

	if (strcmp(val1, val2) == 0)
		return true;

	return false;
}

static bool
check_conn_params_change(ORAconn *conn, ForeignServer *server, UserMapping *user)
{
	if (equal_value(GetFdwOptionList(user->options, "user"),
					ORAuser(conn)) &&
		equal_value(GetFdwOptionList(user->options, "password"),
					ORApass(conn)) &&
		equal_value(GetFdwOptionList(server->options, "dbname"),
					ORAdb(conn)) &&
		equal_value(show_timezone(), ORAtimezone(conn)))
		return true;

	return false;
}

/*
 * Get list of connections currently active.
 */
Datum oracle_fdw_get_connections(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(oracle_fdw_get_connections);
Datum
oracle_fdw_get_connections(PG_FUNCTION_ARGS)
{
	ReturnSetInfo	   *rsinfo = (ReturnSetInfo *) fcinfo->resultinfo;
	HASH_SEQ_STATUS		scan;
	ConnCacheEntry	   *entry;
	MemoryContext		oldcontext = CurrentMemoryContext;
	Tuplestorestate	   *tuplestore;
	TupleDesc			tupdesc;

	/* We return list of connection with storing them in a Tuplestore. */
	rsinfo->returnMode = SFRM_Materialize;
	rsinfo->setResult = NULL;
	rsinfo->setDesc = NULL;

	/* Create tuplestore and copy of TupleDesc in per-query context. */
	MemoryContextSwitchTo(rsinfo->econtext->ecxt_per_query_memory);

	tupdesc = CreateTemplateTupleDesc(2, false);
	TupleDescInitEntry(tupdesc, 1, "srvid", OIDOID, -1, 0);
	TupleDescInitEntry(tupdesc, 2, "usesysid", OIDOID, -1, 0);
	rsinfo->setDesc = tupdesc;

	tuplestore = tuplestore_begin_heap(false, false, work_mem);
	rsinfo->setResult = tuplestore;

	MemoryContextSwitchTo(oldcontext);

	/*
	 * We need to scan sequentially since we use the address to find
	 * appropriate ORAconn from the hash table.
	 */ 
	if (FSConnectionHash != NULL)
	{
		hash_seq_init(&scan, FSConnectionHash);
		while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)))
		{
			Datum		values[2];
			bool		nulls[2];
			HeapTuple	tuple;

			elog(DEBUG1, "found: %u/%u", entry->serverid, entry->userid);

			/* Ignore inactive connections */
			if (ORAstatus(entry->conn) != CONNECTION_OK)
				continue;

			/*
			 * Ignore other users' connections if current user isn't a
			 * superuser.
			 */
			if (!superuser() && entry->userid != GetUserId())
				continue;

			values[0] = ObjectIdGetDatum(entry->serverid);
			values[1] = ObjectIdGetDatum(entry->userid);
			nulls[0] = false;
			nulls[1] = false;

			tuple = heap_formtuple(tupdesc, values, nulls);
			tuplestore_puttuple(tuplestore, tuple);
		}
	}
	tuplestore_donestoring(tuplestore);

	PG_RETURN_VOID();
}

/*
 * Discard persistent connection designated by given connection name.
 */
Datum oracle_fdw_disconnect(PG_FUNCTION_ARGS);
PG_FUNCTION_INFO_V1(oracle_fdw_disconnect);
Datum
oracle_fdw_disconnect(PG_FUNCTION_ARGS)
{
	Oid					serverid = PG_GETARG_OID(0);
	Oid					userid = PG_GETARG_OID(1);
	ConnCacheEntry		key;
	ConnCacheEntry	   *entry = NULL;
	bool				found;

	/* Non-superuser can't discard other users' connection. */
	if (!superuser() && userid != GetOuterUserId())
		ereport(ERROR,
				(errcode(ERRCODE_INSUFFICIENT_RESOURCES),
				 errmsg("only superuser can discard other user's connection")));

	/*
	 * If no connection has been established, or no such connections, just
	 * return "NG" to indicate nothing has done.
	 */
	if (FSConnectionHash == NULL)
		PG_RETURN_TEXT_P(cstring_to_text("NG"));

	key.serverid = serverid;
	key.userid = userid;
	entry = hash_search(FSConnectionHash, &key, HASH_FIND, &found);
	if (!found)
		PG_RETURN_TEXT_P(cstring_to_text("NG"));

	/* Discard cached connection, and clear reference counter. */
	ORAfinish(entry->conn);
	entry->refs = 0;
	entry->conn = NULL;
	elog(DEBUG1, "closed connection %u/%u", serverid, userid);

	PG_RETURN_TEXT_P(cstring_to_text("OK"));
}
