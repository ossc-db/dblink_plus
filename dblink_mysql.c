/*
 * dblink_mysql.c
 *
 * Copyright (c) 2011-2017, NIPPON TELEGRAPH AND TELEPHONE CORPORATION
 */
#ifdef ENABLE_MYSQL

#include "postgres.h"
#include "lib/stringinfo.h"
#include "mb/pg_wchar.h"

#include "dblink.h"
#include "dblink_internal.h"

#include <mysql/mysql.h>

typedef struct mylink_connection
{
	dblink_connection	base;
	MYSQL				conn;
	bool				use_xa;		/* true iff use automatic transaction */
} mylink_connection;

typedef struct mylink_cursor
{
	dblink_cursor	base;
	MYSQL_RES	   *res;
} mylink_cursor;

static void mylink_disconnect(mylink_connection *conn);
static int64 mylink_exec(mylink_connection *conn, const char *sql);
static mylink_cursor *mylink_open(mylink_connection *conn, const char *sql, int fetchsize, int max_value_len);
static mylink_cursor *mylink_call(mylink_connection *conn, const char *func, int fetchsize, int max_value_len);
static bool mylink_command(mylink_connection *conn, dblink_command type);

static bool mylink_fetch(mylink_cursor *cur, const char *values[]);
static void mylink_close(mylink_cursor *cur);

static mylink_connection *mylink_connection_new(void);
static mylink_cursor *mylink_cursor_new(MYSQL_RES *res);
static void mylink_error(MYSQL *conn, const char *message);

static mylink_connection *
mylink_connection_new(void)
{
	mylink_connection  *p;

	p = malloc(sizeof(mylink_connection));
	p->base.disconnect = (dblink_disconnect_t) mylink_disconnect;
	p->base.exec = (dblink_exec_t) mylink_exec;
	p->base.open = (dblink_open_t) mylink_open;
	p->base.call = (dblink_call_t) mylink_call;
	p->base.command = (dblink_command_t) mylink_command;
	mysql_init(&p->conn);

	return p;
}

static mylink_cursor *
mylink_cursor_new(MYSQL_RES *res)
{
	mylink_cursor  *p;

	p = malloc(sizeof(mylink_cursor));
	p->base.fetch = (dblink_fetch_t) mylink_fetch;
	p->base.close = (dblink_close_t) mylink_close;
	p->base.nfields = mysql_num_fields(res);
	p->res = res;

	return p;
}

dblink_connection *
mylink_connect(const char *user, const char *password, const char *dbname,
			   const char *host, int port)
{
	mylink_connection  *conn;
	StringInfoData		sql;
	const char		   *encoding;

	conn = mylink_connection_new();
	if (NULL == mysql_real_connect(&conn->conn,
		host, user, password, dbname, port, NULL, 0))
	{
		const char *message = mysql_error(&conn->conn);
		if (message)
			message = pstrdup(message);
		mylink_disconnect(conn);
		dblink_error(ERRCODE_SQLCLIENT_UNABLE_TO_ESTABLISH_SQLCONNECTION,
			"could not establish connection", message, NULL, NULL);
	}

	/* set character encodings */
	encoding = GetDatabaseEncodingName();

	initStringInfo(&sql);
	appendStringInfo(&sql, "set character_set_client = %s", encoding);
	mysql_query(&conn->conn, sql.data);

	resetStringInfo(&sql);
	appendStringInfo(&sql, "set character_set_results = %s", encoding);
	mysql_query(&conn->conn, sql.data);

	resetStringInfo(&sql);
	appendStringInfo(&sql, "set character_set_connection = %s", encoding);
	mysql_query(&conn->conn, sql.data);

	return (dblink_connection *) conn;
}

static void
mylink_disconnect(mylink_connection *conn)
{
	if (conn != NULL)
	{
		mysql_close(&conn->conn);
		free(conn);
	}
}

static int64
mylink_exec(mylink_connection *conn, const char *sql)
{
	if (mysql_query(&conn->conn, sql))
		mylink_error(&conn->conn, "sql failed");

	return (int64) mysql_affected_rows(&conn->conn);
}

static mylink_cursor *
mylink_open(mylink_connection *conn, const char *sql, int fetchsize, int max_value_len)
{
	MYSQL_RES	   *res;

	if (mysql_query(&conn->conn, sql))
		mylink_error(&conn->conn, "sql failed");

	/* next all rows */
	res = mysql_store_result(&conn->conn);

	return mylink_cursor_new(res);
}

static mylink_cursor *
mylink_call(mylink_connection *conn, const char *func, int fetchsize, int max_value_len)
{
	StringInfoData	sql;

	initStringInfo(&sql);
	appendStringInfoString(&sql, "SELECT ");
	appendStringInfoString(&sql, func);

	return mylink_open(conn, sql.data, fetchsize, max_value_len);
}

static bool
mylink_command(mylink_connection *conn, dblink_command type)
{
	char		sql[256];
	MYSQL_RES  *res;

	switch (type)
	{
		case DBLINK_BEGIN:
			conn->use_xa = false;
			strlcpy(sql, "BEGIN", lengthof(sql));
			break;
		case DBLINK_COMMIT:
			return mysql_commit(&conn->conn);
		case DBLINK_ROLLBACK:
			if (!conn->use_xa)
				return mysql_rollback(&conn->conn);

			set_dblink_gtrid(sql, lengthof(sql),
				"XA END '%s'", conn->base);
			if (mysql_query(&conn->conn, sql))
				return false;
			/* XXX: need this? */
			res = mysql_store_result(&conn->conn);
			mysql_free_result(res);

			set_dblink_gtrid(sql, lengthof(sql),
				"XA ROLLBACK '%s'", conn->base);
			break;
		case DBLINK_XA_START:
			conn->use_xa = true;
			set_dblink_gtrid(sql, lengthof(sql),
				"XA START '%s'", conn->base);
			break;
		case DBLINK_XA_PREPARE:
			set_dblink_gtrid(sql, lengthof(sql),
				"XA END '%s'", conn->base);
			if (mysql_query(&conn->conn, sql))
				return false;
			/* XXX: need this? */
			res = mysql_store_result(&conn->conn);
			mysql_free_result(res);

			set_dblink_gtrid(sql, lengthof(sql),
				"XA PREPARE '%s'", conn->base);
			break;
		case DBLINK_XA_COMMIT:
			set_dblink_gtrid(sql, lengthof(sql),
				"XA COMMIT '%s'", conn->base);
			break;
		case DBLINK_XA_ROLLBACK:
			set_dblink_gtrid(sql, lengthof(sql),
				"XA ROLLBACK '%s'", conn->base);
			break;
		default:
			return false;
	}

	if (mysql_query(&conn->conn, sql))
		return false;
	/* XXX: need this? */
	res = mysql_store_result(&conn->conn);
	mysql_free_result(res);

	return true;
}

static bool
mylink_fetch(mylink_cursor *cur, const char *values[])
{
	MYSQL_ROW				row;
	const unsigned long	   *lengths;
	int						nfields;
	int						c;

	nfields = mysql_num_fields(cur->res);
	row = mysql_fetch_row(cur->res);
	if (row == NULL)
		return false;

	lengths = mysql_fetch_lengths(cur->res);

	for (c = 0; c < nfields; c++)
	{
		if (row[c])
			values[c] = pnstrdup(row[c], lengths[c]);
		else
			values[c] = NULL;
	}
	return true;
}

static void
mylink_close(mylink_cursor *cur)
{
	mysql_free_result(cur->res);
}

static void
mylink_error(MYSQL *conn, const char *message)
{
	int	sqlstate = ERRCODE_EXTERNAL_ROUTINE_EXCEPTION;
	/* TODO: implement mapping */
	/* sqlstate = mysql_errno(&conn->conn); */

	dblink_error(sqlstate, message, mysql_error(conn), NULL, NULL);
}

#endif
