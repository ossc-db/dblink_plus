/*-------------------------------------------------------------------------
 *
 * oracle_fdw.h
 *		  foreign-data wrapper for remote Oracle servers.
 *
 * Copyright (c) 2011, NIPPON TELEGRAPH AND TELEPHONE CORPORATION
 *
 * IDENTIFICATION
 *		  contrib/oracle_fdw/oracle_fdw.h
 *
 *-------------------------------------------------------------------------
 */

#ifndef ORACLE_FDW_H
#define ORACLE_FDW_H

#include "libpq-fe.h"

#include "former_ora.h"

/* maximum of max_value_len. same as maximum of VARSIZE_4B */
#define MAX_DATA_SIZE		0x3FFFFFFF

/*
 * ORAconn encapsulates a connection to the Oracle.
 * The contents of this struct are not supposed to be known to applications.
 */
typedef struct ora_conn ORAconn;

/*
 * ORAresult encapsulates the result of a query.
 * The contents of this struct are not supposed to be known to applications.
 */
typedef struct ora_result ORAresult;

/* in option.c */
extern Datum oracle_fdw_validator(PG_FUNCTION_ARGS);
extern const char *GetFdwOption(Oid relid, const char *optname);
extern const char *GetFdwOptionList(List *defelems, const char *optname);
extern int parse_int_value(const char *value, const char *keyword);

/* make a new client connection to the backend */
extern ORAconn *ORAsetdbLogin(const char *user, const char *password, const char *dbname, const char *timezone, int fetchsize, int max_value_len);

/* close the current connection and free the PGconn data structure */
extern void ORAfinish(ORAconn *conn);

/* Accessor functions for ORAconn objects */
extern char *ORAdb(const ORAconn *conn);
extern char *ORAuser(const ORAconn *conn);
extern char *ORApass(const ORAconn *conn);
extern char *ORAtimezone(const ORAconn *conn);
extern int ORAfetchsize(const ORAconn *conn);
extern int ORAmax_value_len(const ORAconn *conn);
extern ConnStatusType ORAstatus(const ORAconn *conn);
extern char *ORAerrorMessage(const ORAconn *conn);

/* Cursor  */
extern ORAresult *ORAopen(ORAconn *conn, const char *sql, int fetchsize, int max_value_len);
extern bool ORAhasNext(ORAresult *cur);

/* set fetchsize */
void ORAsetFetchsize(ORAconn *conn, int fetchsize);
/* set max_value_len */
void ORAsetMaxValueLen(ORAconn *conn, int max_value_len);

/* Accessor functions for PGresult objects */
extern ExecStatusType ORAresultStatus(ORAresult *res);
extern int ORAnfields(const ORAresult *res);
extern char *ORAgetvalue(ORAresult *res, int field_num);
extern int ORAgetisnull(const ORAresult *res, int field_num);
extern int ORAgetamountsize(ORAresult *res, int field_num);

/* Delete a ORAresult */
extern void ORAclear(ORAresult *res);

/* get TupleFormer */
extern TupleFormer *ORAgetTupleFormer(ORAresult *res);

extern void ora_ereport(int sqlstate, const char *message, const char *detail, const char *hint, const char *context);
extern void ora_elog(int level, const char *message);

const char *get_timezone(void);

#endif   /* ORACLE_FDW_H */
