/*
 * dblink_sqlite3.c
 *
 * Copyright (c) 2009, NIPPON TELEGRAPH AND TELEPHONE CORPORATION
 */
#ifdef ENABLE_SQLITE3

#include "postgres.h"
#include "lib/stringinfo.h"
#include "mb/pg_wchar.h"
#include "miscadmin.h"

#include "dblink.h"
#include "dblink_internal.h"

#include <sqlite3.h>

typedef struct sq3link_connection
{
	dblink_connection	base;
	sqlite3			   *db;
} sq3link_connection;

typedef struct sq3link_row
{
	struct sq3link_row *next;

	char		   *values[1];
} sq3link_row;

typedef struct sq3link_cursor
{
	dblink_cursor	base;
	sq3link_row	   *head;
	sq3link_row	   *iter;
} sq3link_cursor;

static sq3link_connection *sq3link_connection_new(sqlite3 *db);
static void sq3link_disconnect(sq3link_connection *conn);
static int64 sq3link_exec(sq3link_connection *conn, const char *sql);
static sq3link_cursor *sq3link_open(sq3link_connection *conn, const char *func, int32 fetchsize, int32 max_value_len);
static sq3link_cursor *sq3link_call(sq3link_connection *conn, const char *sql, int32 fetchsize, int32 max_value_len);
static bool sq3link_command(sq3link_connection *conn, dblink_command type);

static sq3link_cursor *sq3link_cursor_new(void);
static bool sq3link_fetch(sq3link_cursor *cur, const char *values[]);
static void sq3link_close(sq3link_cursor *cur);

static int sq3link_callback(void *userdata, int argc, char **argv, char **columns);
static void sq3link_error(sqlite3 *db, const char *message);

dblink_connection *
sq3link_connect(const char *location)
{
	sqlite3			   *db = NULL;
	int					rc;

	rc = sqlite3_open(location, &db);

	if (rc != 0)
	{
		if (db)
			sqlite3_close(db);
		dblink_error(ERRCODE_SQLCLIENT_UNABLE_TO_ESTABLISH_SQLCONNECTION,
			"could not establish connection", location, NULL, NULL);
	}

	return (dblink_connection *) sq3link_connection_new(db);
}

static sq3link_connection *
sq3link_connection_new(sqlite3 *db)
{
	sq3link_connection  *p;

	p = malloc(sizeof(sq3link_connection));
	p->base.disconnect = (dblink_disconnect_t) sq3link_disconnect;
	p->base.exec = (dblink_exec_t) sq3link_exec;
	p->base.open = (dblink_open_t) sq3link_open;
	p->base.call = (dblink_call_t) sq3link_call;
	p->base.command = (dblink_command_t) sq3link_command;
	p->db = db;

	return p;
}

static void
sq3link_disconnect(sq3link_connection *conn)
{
	if (conn->db)
		sqlite3_close(conn->db);
	free(conn);
}

static int64
sq3link_exec(sq3link_connection *conn, const char *sql)
{
	char	   *sql_utf8;
	char	   *message;
	int			rc;
	int64		ntuples;

	sql_utf8 = (char *) pg_do_encoding_conversion((unsigned char *) sql,
								strlen(sql), GetDatabaseEncoding(), PG_UTF8);
	rc = sqlite3_exec(conn->db, sql_utf8, NULL, NULL, &message);

	switch (rc)
	{
		case SQLITE_OK:
			ntuples = sqlite3_changes(conn->db);
			break;
		default:
			sq3link_error(conn->db, message);
			return 0;	/* keep compiler quiet */
	}

	return ntuples;
}

static sq3link_cursor *
sq3link_open(sq3link_connection *conn, const char *sql, int32 fetchsize, int32 max_value_len)
{
	sq3link_cursor *cur;
	char		   *sql_utf8;
	char		   *message;
	int				rc;

	cur = sq3link_cursor_new();

	sql_utf8 = (char *) pg_do_encoding_conversion((unsigned char *) sql,
								strlen(sql), GetDatabaseEncoding(), PG_UTF8);
	rc = sqlite3_exec(conn->db, sql_utf8, sq3link_callback, cur, &message);
	if (rc == SQLITE_OK)
	{
		cur->iter = cur->head;
		return cur;
	}

	sq3link_close(cur);
	sq3link_error(conn->db, message);
	return NULL;	/* keep compiler quiet */
}

static sq3link_cursor *
sq3link_call(sq3link_connection *conn, const char *func, int32 fetchsize, int32 max_value_len)
{
	StringInfoData	sql;

	initStringInfo(&sql);
	appendStringInfoString(&sql, "SELECT ");
	appendStringInfoString(&sql, func);

	return sq3link_open(conn, sql.data, fetchsize, max_value_len);
}

static bool
sq3link_command(sq3link_connection *conn, dblink_command type)
{
	const char *sql;
	int			rc;
	char	   *message;

	/* SQLite3 doesn't support 2PC. */
	switch (type)
	{
		case DBLINK_BEGIN:
		case DBLINK_XA_START:
			sql = "BEGIN";
			break;
		case DBLINK_COMMIT:
		case DBLINK_XA_PREPARE:
			sql = "COMMIT";
			break;
		case DBLINK_ROLLBACK:
			sql = "ROLLBACK";
			break;
		case DBLINK_XA_COMMIT:
			return true;
		case DBLINK_XA_ROLLBACK:
		default:
			return false;
	}

	rc = sqlite3_exec(conn->db, sql, NULL, NULL, &message);

	return rc == SQLITE_OK;
}

static sq3link_cursor *
sq3link_cursor_new(void)
{
	sq3link_cursor  *p;

	p = malloc(sizeof(sq3link_cursor));
	p->base.fetch = (dblink_fetch_t) sq3link_fetch;
	p->base.close = (dblink_close_t) sq3link_close;
	p->base.nfields = 0;
	p->head = p->iter = NULL;

	return p;
}

static bool
sq3link_fetch(sq3link_cursor *cur, const char *values[])
{
	if (cur->iter == NULL)
		return false;

	memcpy(values, cur->iter->values, sizeof(char * ) * cur->base.nfields);
	cur->iter = cur->iter->next;
	return true;
}

static void
sq3link_close(sq3link_cursor *cur)
{
	sq3link_row	   *i = cur->head;

	while (i != NULL)
	{
		int				c;
		sq3link_row	   *prev;

		for (c = 0; c < cur->base.nfields; c++)
			free(i->values[c]);

		prev = i;
		i = i->next;
		free(prev);
	}
	free(cur);
}

static char *
strdup_utf8(const char *utf8)
{
	if (utf8 == NULL)
		return NULL;
	else if (GetDatabaseEncoding() == PG_UTF8)
		return strdup(utf8);
	else
	{
		elog(WARNING, "sq3link: non-utf8 encoding is not supported");
		return strdup(utf8);
	}
}

static int
sq3link_callback(void *userdata, int argc, char **argv, char **columns)
{
	sq3link_cursor *cur = (sq3link_cursor *) userdata;
	sq3link_row	   *row;
	int				i;

	/* CHECK_FOR_INTERRUPTS */
#ifdef WIN32
	if (UNBLOCKED_SIGNAL_QUEUE())
		pgwin32_dispatch_queued_signals();
#endif
	if (InterruptPending)
		return SQLITE_ABORT;

	row = malloc(offsetof(sq3link_row, values) + sizeof(char * ) * argc);
	row->next = NULL;
	for (i = 0; i < argc; i++)
		row->values[i] = strdup_utf8(argv[i]);

	cur->base.nfields = argc;
	if (cur->iter)
	{
		cur->iter->next = row;
		cur->iter = row;
	}
	else
	{
		cur->head = cur->iter = row;
	}

	return SQLITE_OK;
}

static void
sq3link_error(sqlite3 *db, const char *message)
{
	int	code = sqlite3_errcode(db);
	int	sqlstate;

	switch (code)
	{
		case SQLITE_ERROR:      /* SQL error or missing database */
			sqlstate = ERRCODE_CONNECTION_EXCEPTION;
			break;
		case SQLITE_INTERNAL:   /* Internal logic error in SQLite */
			sqlstate = ERRCODE_INTERNAL_ERROR;
			break;
		case SQLITE_PERM:       /* Access permission denied */
		case SQLITE_ABORT:      /* Callback routine requested an abort */
		case SQLITE_BUSY:       /* The database file is locked */
		case SQLITE_LOCKED:     /* A table in the database is locked */
		case SQLITE_NOMEM:      /* A malloc() failed */
		case SQLITE_READONLY:   /* Attempt to write a readonly database */
		case SQLITE_INTERRUPT:  /* Operation terminated by sqlite3_interrupt()*/
		case SQLITE_IOERR:      /* Some kind of disk I/O error occurred */
		case SQLITE_CORRUPT:    /* The database disk image is malformed */
		case SQLITE_NOTFOUND:   /* NOT USED. Table or record not found */
		case SQLITE_FULL:       /* Insertion failed because database is full */
		case SQLITE_CANTOPEN:   /* Unable to open the database file */
		case SQLITE_PROTOCOL:   /* NOT USED. Database lock protocol error */
		case SQLITE_EMPTY:      /* Database is empty */
		case SQLITE_SCHEMA:     /* The database schema changed */
		case SQLITE_TOOBIG:     /* String or BLOB exceeds size limit */
		case SQLITE_CONSTRAINT: /* Abort due to constraint violation */
		case SQLITE_MISMATCH:   /* Data type mismatch */
		case SQLITE_MISUSE:     /* Library used incorrectly */
		case SQLITE_NOLFS:      /* Uses OS features not supported on host */
		case SQLITE_AUTH:       /* Authorization denied */
		case SQLITE_FORMAT:     /* Auxiliary database format error */
		case SQLITE_RANGE:      /* 2nd parameter to sqlite3_bind out of range */
		case SQLITE_NOTADB:     /* File opened that is not a database file */
		case SQLITE_ROW:        /* sqlite3_step() has another row ready */
		case SQLITE_DONE:       /* sqlite3_step() has finished executing */
		default:
			sqlstate = ERRCODE_EXTERNAL_ROUTINE_EXCEPTION;
			break;
	}

	dblink_error(sqlstate, message, NULL, NULL, NULL);
}

#endif
