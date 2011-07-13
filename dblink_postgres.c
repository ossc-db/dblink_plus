/*
 * dblink_postgres.c
 *
 * Copyright (c) 2009, NIPPON TELEGRAPH AND TELEPHONE CORPORATION
 */
#include "postgres.h"

#include "fmgr.h"
#include "mb/pg_wchar.h"
#include "lib/stringinfo.h"
#include "nodes/parsenodes.h"
#include "libpq-fe.h"

extern Datum postgresql_fdw_validator(PG_FUNCTION_ARGS);

#include "dblink.h"

typedef struct pglink_connection
{
	dblink_connection	base;
	PGconn			   *conn;
} pglink_connection;

/* PQresult wrapper cursor */
typedef struct pglink_cursor
{
	dblink_cursor	base;
	PGresult	   *res;
	int				row;
} pglink_cursor;

/* Server-side cursor */
typedef struct pglink_srvcur
{
	pglink_cursor	base;
	PGconn		   *conn;
	int				fetchsize;
	char			name[NAMEDATALEN];	/* cursor name */
} pglink_srvcur;

PG_FUNCTION_INFO_V1(dblink_postgres);
extern Datum dblink_postgres(PG_FUNCTION_ARGS);

static pglink_connection *pglink_connection_new(PGconn *conn);
static void pglink_disconnect(pglink_connection *conn);
static int64 pglink_exec(pglink_connection *conn, const char *sql);
static pglink_cursor *pglink_open(pglink_connection *conn, const char *sql, int32 fetchsize, int32 max_value_len);
static pglink_cursor *pglink_call(pglink_connection *conn, const char *func, int32 fetchsize, int32 max_value_len);
static bool pglink_command(pglink_connection *conn, dblink_command type);

static pglink_cursor *pglink_cursor_new(void);
static bool pglink_fetch(pglink_cursor *cur, const char *values[]);
static void pglink_close(pglink_cursor *cur);

static pglink_srvcur *pglink_srvcur_new(void);
static bool pglink_fetch_srvcur(pglink_srvcur *cur, const char *values[]);
static void pglink_close_srvcur(pglink_srvcur *cur);

static void pglink_error(PGconn *conn, PGresult *res);

/*
 * Escaping libpq connect parameter strings.
 *
 * Replaces "'" with "\'" and "\" with "\\".
 */
static char *
escape_param_str(const char *str)
{
	const char *cp;
	StringInfo	buf = makeStringInfo();

	for (cp = str; *cp; cp++)
	{
		if (*cp == '\\' || *cp == '\'')
			appendStringInfoChar(buf, '\\');
		appendStringInfoChar(buf, *cp);
	}

	return buf->data;
}

static char *
join_options(List *options)
{
	ListCell	   *cell;
	StringInfoData	buf;

	initStringInfo(&buf);
	foreach(cell, options)
	{
		DefElem    *def = lfirst(cell);

		appendStringInfo(&buf, "%s='%s' ", def->defname,
						 escape_param_str(strVal(def->arg)));
	}

	return buf.data;
}

Datum
dblink_postgres(PG_FUNCTION_ARGS)
{
	dblink_connection **connection;
	PGconn			   *conn;

	if (PG_GETARG_OID(1) != DBLINKOID)
		return postgresql_fdw_validator(fcinfo);

	connection = (dblink_connection **) PG_GETARG_POINTER(2);
	if (!connection)
		PG_RETURN_BOOL(false);

	conn = PQconnectdb(join_options((List *) PG_GETARG_POINTER(3)));

	if (PQstatus(conn) == CONNECTION_BAD)
	{
		char *detail = pstrdup(PQerrorMessage(conn));
		PQfinish(conn);

		ereport(ERROR,
			(errcode(ERRCODE_SQLCLIENT_UNABLE_TO_ESTABLISH_SQLCONNECTION),
			errmsg("could not establish connection"),
			errdetail("%s", detail)));
	}

	PQsetClientEncoding(conn, GetDatabaseEncodingName());

	*connection = (dblink_connection *) pglink_connection_new(conn);
	PG_RETURN_BOOL(true);
}

static pglink_connection *
pglink_connection_new(PGconn *conn)
{
	pglink_connection  *p;

	p = malloc(sizeof(pglink_connection));
	p->base.disconnect = (dblink_disconnect_t) pglink_disconnect;
	p->base.exec = (dblink_exec_t) pglink_exec;
	p->base.open = (dblink_open_t) pglink_open;
	p->base.call = (dblink_call_t) pglink_call;
	p->base.command = (dblink_command_t) pglink_command;
	p->conn = conn;

	return p;
}

static void
pglink_disconnect(pglink_connection *conn)
{
	PQfinish(conn->conn);
	free(conn);
}

static int64
pglink_exec(pglink_connection *conn, const char *sql)
{
	PGresult	   *res;
	int64			ntuples;

	res = PQexec(conn->conn, sql);

	switch (PQresultStatus(res))
	{
		case PGRES_COMMAND_OK:
			ntuples = atoi(PQcmdTuples(res));
			PQclear(res);
			break;
		case PGRES_TUPLES_OK:
			ntuples = PQntuples(res);
			PQclear(res);
			break;
		default:
		pglink_error(conn->conn, res);
		return 0;	/* keep compiler quiet */
	}

	return ntuples;
}

static bool
fetch_forward(pglink_srvcur *cur)
{
	char			sql[NAMEDATALEN + 64];
	PGresult	   *res;
	ExecStatusType	code;

	PQclear(cur->base.res);
	cur->base.res = NULL;

	if (!cur->name[0])
		return false;	/* already done */

	snprintf(sql, lengthof(sql), "FETCH FORWARD %d FROM %s", cur->fetchsize, cur->name);
	res = PQexec(cur->conn, sql);
	code = PQresultStatus(res);
	if (code != PGRES_COMMAND_OK && code != PGRES_TUPLES_OK)
		pglink_error(cur->conn, res);

	if (PQntuples(res) <= 0)
	{
		/* no more tuples */
		PQclear(res);
		snprintf(sql, lengthof(sql), "CLOSE %s", cur->name);
		PQclear(PQexec(cur->conn, sql));
		cur->name[0] = '\0';
		return false;
	}

	cur->base.res = res;
	cur->base.row = 0;
	return true;
}

static pglink_cursor *
pglink_open(pglink_connection *conn, const char *sql, int32 fetchsize, int32 max_value_len)
{
	PGresult	   *res;
	ExecStatusType	code;

	if (fetchsize > 0)
	{
		char			name[NAMEDATALEN];
		StringInfoData	buf;

		initStringInfo(&buf);

		/* TODO: Use less conflict cursor name. */
		snprintf(name, NAMEDATALEN, "dblink_plus_%d", rand());
		appendStringInfo(&buf, "DECLARE %s CURSOR FOR %s", name, sql);
		res = PQexec(conn->conn, buf.data);
		code = PQresultStatus(res);

		if (code == PGRES_COMMAND_OK)
		{
			pglink_srvcur *cur;

			PQclear(res);

			cur = pglink_srvcur_new();
			cur->conn = conn->conn;
			cur->fetchsize = fetchsize;
			strlcpy(cur->name, name, NAMEDATALEN);
			if (!fetch_forward(cur))
			{
				pglink_close_srvcur(cur);
				return NULL;
			}
			cur->base.base.nfields = PQnfields(cur->base.res);

			return (pglink_cursor *) cur;
		}
	}
	else
	{
		res = PQexec(conn->conn, sql);
		code = PQresultStatus(res);

		if (code == PGRES_COMMAND_OK || code == PGRES_TUPLES_OK)
		{
			pglink_cursor  *cur;

			cur = pglink_cursor_new();
			cur->base.nfields = PQnfields(res);
			cur->res = res;
			return cur;
		}
	}

	pglink_error(conn->conn, res);
	return NULL;	/* keep compiler quiet */
}

static pglink_cursor *
pglink_call(pglink_connection *conn, const char *func, int32 fetchsize, int32 max_value_len)
{
	StringInfoData	sql;

	initStringInfo(&sql);
	appendStringInfoString(&sql, "SELECT * FROM ");
	appendStringInfoString(&sql, func);

	return pglink_open(conn, sql.data, fetchsize, max_value_len);
}

/* TODO: Use less conflict and more human-readable XA-ID. */
static bool
pglink_command(pglink_connection *conn, dblink_command type)
{
	char		sql[256];
	PGresult   *res;
	bool		ok;

	switch (type)
	{
		case DBLINK_BEGIN:
		case DBLINK_XA_START:
			strlcpy(sql, "BEGIN", lengthof(sql));
			break;
		case DBLINK_COMMIT:
			strlcpy(sql, "COMMIT", lengthof(sql));
			break;
		case DBLINK_ROLLBACK:
			strlcpy(sql, "ROLLBACK", lengthof(sql));
			break;
		case DBLINK_XA_PREPARE:
			set_dblink_gtrid(sql, lengthof(sql),
				"PREPARE TRANSACTION '%s'", conn->base);
			break;
		case DBLINK_XA_COMMIT:
			set_dblink_gtrid(sql, lengthof(sql),
				"COMMIT PREPARED '%s'", conn->base);
			break;
		case DBLINK_XA_ROLLBACK:
			set_dblink_gtrid(sql, lengthof(sql),
				"ROLLBACK PREPARED '%s'", conn->base);
			break;
		default:
			return false;
	}

	res = PQexec(conn->conn, sql);
	ok = (PQresultStatus(res) == PGRES_COMMAND_OK);
	PQclear(res);

	return ok;
}

static pglink_cursor *
pglink_cursor_new(void)
{
	pglink_cursor  *p;

	p = malloc(sizeof(pglink_cursor));
	p->base.fetch = (dblink_fetch_t) pglink_fetch;
	p->base.close = (dblink_close_t) pglink_close;
	p->base.nfields = 0;
	p->row = 0;
	p->res = NULL;

	return p;
}

static bool
pglink_fetch(pglink_cursor *cur, const char *values[])
{
	int		c;

	if (cur->row >= PQntuples(cur->res))
		return false;

	for (c = 0; c < cur->base.nfields; c++)
	{
		if (PQgetisnull(cur->res, cur->row, c))
			values[c] = NULL;
		else
			values[c] = PQgetvalue(cur->res, cur->row, c);
	}
	cur->row++;
	return true;
}

static void
pglink_close(pglink_cursor *cur)
{
	PQclear(cur->res);
	free(cur);
}

static pglink_srvcur *
pglink_srvcur_new(void)
{
	pglink_srvcur  *p;

	p = malloc(sizeof(pglink_srvcur));
	p->base.base.fetch = (dblink_fetch_t) pglink_fetch_srvcur;
	p->base.base.close = (dblink_close_t) pglink_close_srvcur;
	p->base.base.nfields = 0;
	p->base.row = 0;
	p->base.res = NULL;
	p->conn = NULL;
	p->name[0] = '\0';

	return p;
}

static bool
pglink_fetch_srvcur(pglink_srvcur *cur, const char *values[])
{
	if (cur->base.res == NULL || cur->base.row >= PQntuples(cur->base.res))
	{
		if (!fetch_forward(cur))
			return false;
		else if (cur->base.base.nfields != PQnfields(cur->base.res))
			elog(ERROR, "nfields should not be changed");
	}

	return pglink_fetch(&cur->base, values);
}

static void
pglink_close_srvcur(pglink_srvcur *cur)
{
	PQclear(cur->base.res);
	if (cur->name[0] && cur->conn)
	{
		char	sql[NAMEDATALEN + 64];

		snprintf(sql, lengthof(sql), "CLOSE %s", cur->name);
		PQclear(PQexec(cur->conn, sql));
	}
	free(cur);
}

static void
pglink_error(PGconn *conn, PGresult *res)
{
	const char *diag_sqlstate = PQresultErrorField(res, PG_DIAG_SQLSTATE);
	const char *message = PQresultErrorField(res, PG_DIAG_MESSAGE_PRIMARY);
	const char *detail = PQresultErrorField(res, PG_DIAG_MESSAGE_DETAIL);
	const char *hint = PQresultErrorField(res, PG_DIAG_MESSAGE_HINT);
	const char *context = PQresultErrorField(res, PG_DIAG_CONTEXT);
	int			sqlstate;

	if (res)
		PQclear(res);

	if (diag_sqlstate)
		sqlstate = MAKE_SQLSTATE(diag_sqlstate[0],
								 diag_sqlstate[1],
								 diag_sqlstate[2],
								 diag_sqlstate[3],
								 diag_sqlstate[4]);
	else
		sqlstate = ERRCODE_CONNECTION_FAILURE;

	message = message ? pstrdup(message) : NULL;
	detail = detail ? pstrdup(detail) : NULL;
	hint = hint ? pstrdup(hint) : NULL;
	context = context ? pstrdup(context) : NULL;

	ereport(ERROR, (errcode(sqlstate),
		message ? errmsg("%s", message) : errmsg("unknown error"),
		detail ? errdetail("%s", detail) : 0,
		hint ? errhint("%s", hint) : 0,
		context ? errcontext("%s", context) : 0));
}
