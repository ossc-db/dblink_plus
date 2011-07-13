/*
 * dblink.h
 *
 * Copyright (c) 2009, NIPPON TELEGRAPH AND TELEPHONE CORPORATION
 */
#ifndef DBLINK_H
#define DBLINK_H

#define DBLINKOID				0xFFFFFFFF

typedef enum dblink_command
{
	DBLINK_BEGIN,
	DBLINK_COMMIT,
	DBLINK_ROLLBACK,
	DBLINK_XA_START,
	DBLINK_XA_PREPARE,
	DBLINK_XA_COMMIT,
	DBLINK_XA_ROLLBACK
} dblink_command;

typedef struct dblink_connection	dblink_connection;
typedef struct dblink_cursor		dblink_cursor;
typedef struct dblink_gtrid			dblink_gtrid;

/*
 * gtrid parts
 */
struct dblink_gtrid
{
	int		pid;	/* process id */
	int		rand;	/* random number */
};

/*
 * interface dblink_connection
 */

typedef void (*dblink_disconnect_t)(dblink_connection *conn);
typedef int64 (*dblink_exec_t)(dblink_connection *conn, const char *sql);
typedef dblink_cursor *(*dblink_open_t)(dblink_connection *conn, const char *sql, int32 fetchsize, int max_value_len);
typedef dblink_cursor *(*dblink_call_t)(dblink_connection *conn, const char *func, int32 fetchsize, int max_value_len);
typedef bool (*dblink_command_t)(dblink_connection *conn, dblink_command type);

struct dblink_connection
{
	dblink_disconnect_t	disconnect;
	dblink_exec_t		exec;
	dblink_open_t		open;
	dblink_call_t		call;
	dblink_command_t	command;
	dblink_gtrid		gtrid;
};

/*
 * interface dblink_cursor
 */

typedef bool (*dblink_fetch_t)(dblink_cursor *cur, const char *values[]);
typedef void (*dblink_close_t)(dblink_cursor *cur);

struct dblink_cursor
{
	dblink_fetch_t		fetch;
	dblink_close_t		close;
	int					nfields;
};

/*
 * internal utility functions
 */

extern void dblink_error(int sqlstate,
						 const char *message,
						 const char *detail,
						 const char *hint,
						 const char *context);
extern void dblink_elog(int level, const char *message);
extern void set_dblink_gtrid(char *str,
						 size_t size,
						 const char *format,
						 dblink_connection base);

#endif   /* DBLINK_H */
