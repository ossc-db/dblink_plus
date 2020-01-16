/*
 * dblink_oracle.c
 *
 * Copyright (c) 2011-2020, NIPPON TELEGRAPH AND TELEPHONE CORPORATION
 */
#ifdef ENABLE_ORACLE

#define text	pg_text
#include "c.h"
#undef text

#include "postgres.h"
#include "utils/memutils.h"

#include "utils/elog.h"
#include "mb/pg_wchar.h"
#include "dblink.h"
#include "dblink_internal.h"
#include <oci.h>
#include <xa.h>

#define COLUNM_SIZE			50
#define CALL_COLUNM_SIZE	8192
#define DEF_FETCH_SIZE		100

typedef struct oralink_connection
{
	dblink_connection	base;
	OCIEnv			   *env;
	OCIError		   *error;
	OCISvcCtx		   *svcctx;
	OCITrans		   *trans;
	OCIServer		   *server;
	OCISession		   *session;
	int					max_value_len;
	sword				trans_stat;
} oralink_connection;

typedef struct oralink_cursor
{
	dblink_cursor		base;
	OCIStmt			   *stmt;
	OCIStmt			   *org_stmt;		/* use dblink_call() */
	OCIDefine		  **defnhp;
	char			  **values;
	sb2				  **indicator;
	ub4				   *allocsize;
	sb4				   *data_type;
	OCILobLocator	  **lob_loc;
	int					max_value_len;
	sb4					fetchsize;
	sb4					rowcount;
	int					current;
	sword				status;
	oralink_connection *conn;
} oralink_cursor;

static void oralink_disconnect(oralink_connection *conn);
static int64 oralink_exec(oralink_connection *conn, const char *sql);
static oralink_cursor *oralink_open(oralink_connection *conn, const char *sql, int fetchsize, int max_value_len);
static bool oralink_command(oralink_connection *conn, dblink_command type);

static bool oralink_fetch(oralink_cursor *cur, const char *values[]);
static void oralink_close(oralink_cursor *cur);
static oralink_cursor *oralink_call(oralink_connection *conn, const char *func, int fetchsize, int max_value_len);

static oralink_connection *oralink_connection_new(void);
static oralink_cursor *oralink_cursor_new(void);
static void oralink_lobread(oralink_cursor *cur, int field);
static void oralink_error(OCIError *errhp, sword status);
static void oralink_elog(OCIError *errhp, sword status);
static void oralink_message(char *message, int size, OCIError *errhp, sword status);
static void *oralink_malloc(size_t size);
static void *oralink_calloc(size_t nmemb, size_t size);
static void *oralink_realloc(void *ptr, size_t size);
static void oralink_free(void *ptr);

static oralink_connection *
oralink_connection_new(void)
{
	oralink_connection  *p;

	p = calloc(sizeof(oralink_connection), 1);
	p->base.disconnect = (dblink_disconnect_t) oralink_disconnect;
	p->base.exec = (dblink_exec_t) oralink_exec;
	p->base.open = (dblink_open_t) oralink_open;
	p->base.call = (dblink_call_t) oralink_call;
	p->base.command = (dblink_command_t) oralink_command;

	return p;
}

static oralink_cursor *
oralink_cursor_new(void)
{
	oralink_cursor  *p;

	p = oralink_calloc(sizeof(oralink_cursor), 1);
	p->base.fetch = (dblink_fetch_t) oralink_fetch;
	p->base.close = (dblink_close_t) oralink_close;
	p->base.nfields = 0;

	return p;
}

static ub2
oralink_charset_id(pg_enc pg_encode)
{
	OCIEnv	*envp;
	ub2		charset_id;
	static char *ora_enc[] = {
		"US7ASCII",			/* SQL/ASCII */
		"JA16EUC",			/* EUC for Japanese */
		"ZHT32EUC", 		/* EUC for Chinese */
		0,					/* EUC for Korean */
		0, 					/* EUC for Taiwan */
		0,					/* EUC-JIS-2004 */
		"UTF8",				/* Unicode UTF8 */
		0,					/* Mule internal code */
		"WE8ISO8859P1",		/* ISO-8859-1 Latin 1 */
		"EE8ISO8859P2",		/* ISO-8859-2 Latin 2 */
		"SE8ISO8859P3",		/* ISO-8859-3 Latin 3 */
		"NEE8ISO8859P4",	/* ISO-8859-4 Latin 4 */
		"WE8ISO8859P9",		/* ISO-8859-9 Latin 5 */
		"NE8ISO8859P10",	/* ISO-8859-10 Latin6 */
		"BLT8ISO8859P13",	/* ISO-8859-13 Latin7 */
		"CEL8ISO8859P14",	/* ISO-8859-14 Latin8 */
		"WE8ISO8859P15",	/* ISO-8859-15 Latin9 */
		0,					/* ISO-8859-16 Latin10 */
		"AR8MSWIN1256",		/* windows-1256 */
		"VN8MSWIN1258",		/* Windows-1258 */
		0,					/* (MS-DOS CP866) */
		0,					/* windows-874 */
		"CL8KOI8R",			/* KOI8-R */
		"CL8MSWIN1251",		/* windows-1251 */
		"WE8MSWIN1252",		/* windows-1252 */
		"CL8ISO8859P5",		/* ISO-8859-5 */
		"AR8ISO8859P6",		/* ISO-8859-6 */
		"EL8ISO8859P7",		/* ISO-8859-7 */
		"IW8ISO8859P8",		/* ISO-8859-8 */
		"EE8MSWIN1250",		/* windows-1250 */
		"EL8MSWIN1253",		/* windows-1253 */
		"TR8MSWIN1254",		/* windows-1254 */
		"IW8MSWIN1255",		/* windows-1255 */
		"BLT8MSWIN1257",	/* windows-1257 */
		"CL8KOI8U",			/* KOI8-U */
		"JA16SJISTILDE",	/* Shift JIS (Winindows-932) */
		"ZHT16BIG5",		/* Big5 (Windows-950) */
		"ZHS16GBK",			/* GBK (Windows-936) */
		0,					/* UHC (Windows-949) */
		0,					/* GB18030 */
		0,					/* EUC for Korean JOHAB */
		0					/* Shift-JIS-2004 */
	};

	if (pg_encode >= sizeof(ora_enc) / sizeof(char *))
		return 0;
	if (OCIEnvCreate(&envp, OCI_DEFAULT, NULL, 0, 0, 0, 0, NULL))
		return 0;
	charset_id = OCINlsCharSetNameToId(envp, (oratext *)ora_enc[pg_encode]);
	OCIHandleFree(envp, OCI_HTYPE_ENV);

	return charset_id;
}

dblink_connection *
oralink_connect(const char *user,
				const char *password,
				const char *dbname,
				int max_value_len)
{
	oralink_connection   *conn;
	sword			status;
	ub2				charsetid;

	conn = oralink_connection_new();

	if (max_value_len <= 0)
		conn->max_value_len = 0;
	else
		conn->max_value_len = max_value_len;

	charsetid = oralink_charset_id(GetDatabaseEncoding());
	status = OCIEnvNlsCreate(&conn->env, OCI_DEFAULT,
		NULL, 0, 0, 0, 0, NULL, charsetid, charsetid);
	if (status != OCI_SUCCESS)
		return NULL;

	/* init error handle */
	OCIHandleAlloc(conn->env, (dvoid **)&conn->error, OCI_HTYPE_ERROR, 0, NULL);

	/* init server handle & attach */
	OCIHandleAlloc(conn->env, (void **) &conn->server,
		OCI_HTYPE_SERVER, 0, NULL);
	OCIServerAttach(conn->server, conn->error, 
		(OraText *) dbname, dbname ? strlen(dbname) : 0, OCI_DEFAULT);

	/* set the external name and internal name in server handle */
	OCIAttrSet(conn->server, OCI_HTYPE_SERVER,
		"dblink_exname", strlen("dblink_exname"),
		OCI_ATTR_EXTERNAL_NAME, conn->error);
	OCIAttrSet(conn->server, OCI_HTYPE_SERVER, 
		"dblink_inname", strlen("dblink_inname"),
		OCI_ATTR_INTERNAL_NAME, conn->error);

	/* init user session handle & set param */
	OCIHandleAlloc(conn->env, (void **) &conn->session, 
		OCI_HTYPE_SESSION, 0, NULL);
	OCIAttrSet(conn->session, OCI_HTYPE_SESSION, 
		(char *) user, user ? strlen(user) : 0,
		OCI_ATTR_USERNAME, conn->error);
	OCIAttrSet(conn->session, OCI_HTYPE_SESSION, 
		(char *) password, password ? strlen(password) : 0,
		OCI_ATTR_PASSWORD, conn->error);

	/* init service context handle & set param */
	OCIHandleAlloc(conn->env, (void **) &conn->svcctx, 
		OCI_HTYPE_SVCCTX, 0, NULL);
	OCIAttrSet(conn->svcctx, OCI_HTYPE_SVCCTX, 
		conn->server, 0, OCI_ATTR_SERVER, conn->error);
	OCIHandleAlloc(conn->env, (void **) &conn->trans, OCI_HTYPE_TRANS, 0, NULL);
	OCIAttrSet(conn->svcctx, OCI_HTYPE_SVCCTX, 
		conn->trans, 0, OCI_ATTR_TRANS, conn->error);

	status = OCISessionBegin (conn->svcctx, conn->error, conn->session, 
				OCI_CRED_RDBMS, 0);
	if (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)
	{
		char	message[1024];
		oralink_message(message, lengthof(message), conn->error, status);
		oralink_disconnect(conn);
		dblink_error(ERRCODE_SQLCLIENT_UNABLE_TO_ESTABLISH_SQLCONNECTION,
			"could not establish connection", message, NULL, NULL);
	}
	if (status == OCI_SUCCESS_WITH_INFO)
		oralink_elog(conn->error, status);

	OCIAttrSet(conn->svcctx, OCI_HTYPE_SVCCTX, 
		conn->session, 0, OCI_ATTR_SESSION, conn->error);

	return (dblink_connection *) conn;
}

static void
oralink_disconnect(oralink_connection *conn)
{
	sword		status;

	if (conn == NULL)
		return;

	status = OCISessionEnd(conn->svcctx, conn->error, conn->session, 0);
	if (status != OCI_SUCCESS)
		oralink_elog(conn->error, status);

	OCIServerDetach(conn->server, conn->error, OCI_DEFAULT);

	/* cleanup handles */
	if (conn->error)
		OCIHandleFree(conn->error, OCI_HTYPE_ERROR);
	if (conn->svcctx)
		OCIHandleFree(conn->svcctx, OCI_HTYPE_SVCCTX);
	if (conn->server)
		OCIHandleFree(conn->server, OCI_HTYPE_SERVER);
	if (conn->session)
		OCIHandleFree(conn->session, OCI_HTYPE_SESSION);
	if (conn->trans)
		OCIHandleFree(conn->trans, OCI_HTYPE_TRANS);
	if (conn->env)
		OCIHandleFree(conn->env, OCI_HTYPE_ENV);

	free(conn);
}

static OCIStmt *
stmt_create(oralink_connection *conn, const char *sql)
{
	OCIStmt		   *stmt = NULL;

	OCIHandleAlloc(conn->env, (dvoid **) &stmt, OCI_HTYPE_STMT, 0, NULL);
	OCIStmtPrepare(stmt, conn->error, (OraText *) sql, 
		strlen(sql), OCI_NTV_SYNTAX, OCI_DEFAULT);

	return stmt;
}

static int64
oralink_exec(oralink_connection *conn, const char *sql)
{
	sword	status;
	OCIStmt	*stmt;
	int		affected_rows;

	stmt = stmt_create(conn, sql);
	status = OCIStmtExecute(conn->svcctx, stmt, conn->error,
				1, 0, NULL, NULL, OCI_DEFAULT);
	if (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)
	{
		oralink_error(conn->error, status);
	}
	if (status == OCI_SUCCESS_WITH_INFO)
		oralink_elog(conn->error, status);

	OCIAttrGet(stmt, OCI_HTYPE_STMT, &affected_rows,
		0, OCI_ATTR_ROW_COUNT, conn->error);

	OCIHandleFree(stmt, OCI_HTYPE_STMT);

	return affected_rows;
}

static oralink_cursor *
oralink_open(oralink_connection *conn, const char *sql, int fetchsize, int max_value_len)
{
	oralink_cursor *cur;
	sword			status;
	int				i;
	ub4				mode;

	cur = oralink_cursor_new();
	cur->conn = conn;
	cur->stmt = stmt_create(conn, sql);
	cur->fetchsize = (fetchsize > 0) ? fetchsize : DEF_FETCH_SIZE;
	cur->rowcount = 0;
	cur->current = 0;

	if (max_value_len < 0)
		cur->max_value_len = conn->max_value_len;
	else
		cur->max_value_len = max_value_len;

	if (cur->max_value_len <= 0)
		mode = OCI_STMT_SCROLLABLE_READONLY;
	else
		mode = OCI_DEFAULT;

	status = OCIStmtExecute(conn->svcctx, cur->stmt, conn->error, 
				0, 0, NULL, NULL, mode);
	if (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)
	{
		oralink_close(cur);
		oralink_error(conn->error, status);
	}
	if (status == OCI_SUCCESS_WITH_INFO)
		oralink_elog(conn->error, status);

	status = OCIAttrGet(cur->stmt, OCI_HTYPE_STMT,
				&cur->base.nfields, 0, OCI_ATTR_PARAM_COUNT, conn->error);
	if (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)
	{
		oralink_close(cur);
		oralink_error(conn->error, status);
	}
	if (status == OCI_SUCCESS_WITH_INFO)
		oralink_elog(conn->error, status);

	/* Declare define handle */
	cur->defnhp = oralink_calloc(cur->base.nfields * sizeof(OCIDefine *), 1);
	cur->values = oralink_calloc(cur->base.nfields * sizeof(char *), 1);
	cur->indicator = oralink_calloc(cur->base.nfields * sizeof(sb2 *), 1);
	cur->allocsize = oralink_calloc(cur->base.nfields * sizeof(ub4), 1);
	cur->data_type = oralink_calloc(cur->base.nfields * sizeof(sb4), 1);
	cur->lob_loc = oralink_calloc(cur->base.nfields * sizeof(OCILobLocator *), 1);

	for (i = 0;  i < cur->base.nfields; i++)
	{
		OCIParam *hp = 0;

		status = OCIParamGet(cur->stmt, OCI_HTYPE_STMT,
				conn->error, (dvoid **)&hp, i + 1);
		status = OCIAttrGet(hp, OCI_DTYPE_PARAM,
				&cur->data_type[i], 0, OCI_ATTR_DATA_TYPE, conn->error);

		switch (cur->data_type[i])
		{
			case SQLT_CLOB:
				OCIDescriptorAlloc((dvoid *)conn->env,
					(dvoid **)&cur->lob_loc[i],
					(ub4)OCI_DTYPE_LOB, (size_t)0, (dvoid **)0);
				cur->fetchsize = 1;
				break;
			case SQLT_LNG:
			case SQLT_BIN:
			case SQLT_LBI:
			case SQLT_BLOB:
			case SQLT_BFILE:
				dblink_error(ERRCODE_EXTERNAL_ROUTINE_EXCEPTION,
					"Not supported data type.", NULL, NULL, NULL);
				break;
			default:
				cur->data_type[i] = SQLT_STR;
				break;
		}
	}

	for (i = 0;  i < cur->base.nfields; i++)
	{
		if (cur->max_value_len <= 0)
			cur->allocsize[i] = COLUNM_SIZE;
		else
			cur->allocsize[i] = cur->max_value_len + 1;

		cur->values[i] = oralink_malloc(cur->allocsize[i] * cur->fetchsize);
		cur->indicator[i] = oralink_calloc(sizeof(sb2) * cur->fetchsize, 1);

		status = OCIDefineByPos(cur->stmt,
					&cur->defnhp[i],
					conn->error,
					(ub4) i + 1,
					(cur->data_type[i] == SQLT_STR) ? (dvoid *)cur->values[i]
													: (dvoid *)&cur->lob_loc[i],
					(cur->data_type[i] == SQLT_STR) ? cur->allocsize[i] : 0,
					cur->data_type[i],
					(dvoid *) cur->indicator[i],
					(ub2 *) 0, (ub2 *) 0, OCI_DEFAULT);

		if (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)
		{
			oralink_close(cur);
			oralink_error(conn->error, status);
		}
		if (status == OCI_SUCCESS_WITH_INFO)
			oralink_elog(conn->error, status);
	}

	return cur;
}

static bool
oralink_fetch(oralink_cursor *cur, const char *values[])
{
	int		i;
	int		n;
	int		rev_count = 0;
	ub4		fetch_mode = OCI_FETCH_NEXT;

	while (cur->current == 0)
	{
		text	errbuf[512];
		sb4		errcode = 0;
		int		realloc_count = 0;

		for (i = 0; i < cur->base.nfields; i++)
			memset(cur->indicator[i], 0, sizeof(sb2) * cur->fetchsize);

		cur->status = OCIStmtFetch2(cur->stmt, cur->conn->error,
				cur->fetchsize, fetch_mode, rev_count, OCI_DEFAULT);

		if (cur->status == OCI_ERROR)
		{
			OCIErrorGet ((void  *) cur->conn->error, (ub4) 1, (text *) NULL,
				&errcode, errbuf, (ub4) sizeof(errbuf), (ub4) OCI_HTYPE_ERROR);
			if (errcode != 1406)
				oralink_error(cur->conn->error, cur->status);
		}

		if (cur->status == OCI_NO_DATA)
		{
			ub4	size = sizeof(size);
			OCIAttrGet(cur->stmt, OCI_HTYPE_STMT, (dvoid *)&cur->rowcount, 
				(ub4 *)&size, (ub4)OCI_ATTR_ROWS_FETCHED, cur->conn->error);

			if (cur->rowcount == 0)
				return false;
		}
		else
			cur->rowcount = cur->fetchsize;

		for (i = 0; i < cur->base.nfields; i++)
		{
			sb2	w_indicator = 0;

			for (n = 0; n < cur->rowcount; n++)
			{
				if (*(cur->indicator[i] + n) == -2)
				{
					w_indicator = -2;
					break;
				}
				if (w_indicator < *(cur->indicator[i] + n))
					w_indicator = *(cur->indicator[i] + n);
			}
			if (w_indicator > 0)
				if (cur->allocsize[i] >= w_indicator + 1)
					cur->allocsize[i]++;
				else
					cur->allocsize[i] = w_indicator + 1;
			else if (w_indicator == -2)
				cur->allocsize[i] += USHRT_MAX;
			else
				continue;

			realloc_count++;
			cur->values[i] = oralink_realloc(cur->values[i],
								cur->allocsize[i] * cur->fetchsize);
			cur->status = OCIDefineByPos(cur->stmt,
						&cur->defnhp[i],
						cur->conn->error,
						(ub4)i + 1,
						(dvoid *)cur->values[i],
						cur->allocsize[i],
						SQLT_STR,
						(dvoid *)cur->indicator[i],
						(ub2 *) 0, (ub2 *) 0, OCI_DEFAULT);
			if (cur->status != OCI_SUCCESS &&
					cur->status != OCI_SUCCESS_WITH_INFO)
			{
				oralink_error(cur->conn->error, cur->status);
			}
			if (cur->status == OCI_SUCCESS_WITH_INFO)
				oralink_elog(cur->conn->error, cur->status);
		}
		if (realloc_count == 0)
			break;

		fetch_mode = OCI_FETCH_RELATIVE;
		rev_count = 1 - cur->rowcount;
	}

	if (cur->status == OCI_NO_DATA && cur->current == cur->rowcount)
	{
		cur->current = 0;
		return false;
	}

	for (i = 0; i < cur->base.nfields; i++)
	{
		if (*(cur->indicator[i] + cur->current) == -1)
		{
			values[i] = 0;
			continue;
		}

		if (cur->data_type[i] == SQLT_STR)
			values[i] = cur->values[i] + cur->allocsize[i] * cur->current;
		else
		{
			oralink_lobread(cur, i);
			values[i] = cur->values[i];
		}
	}

	cur->current++;
	if (cur->current == cur->fetchsize)
		cur->current = 0;

	return true;
}

static void
oralink_close(oralink_cursor *cur)
{
	int i;

	if (cur->lob_loc)
	{
		for (i = 0; i < cur->base.nfields; i++)
		{
			if (cur->lob_loc[i])
				OCIDescriptorFree(cur->lob_loc[i], OCI_DTYPE_LOB);
		}
		oralink_free(cur->lob_loc);
	}
	if (cur->stmt)
		OCIHandleFree(cur->stmt, OCI_HTYPE_STMT);
	if (cur->org_stmt)
		OCIHandleFree(cur->org_stmt, OCI_HTYPE_STMT);
	if (cur->defnhp)
		oralink_free(cur->defnhp);
	if (cur->values)
	{
		for (i = 0; i < cur->base.nfields; i++)
		{
			if (cur->values[i])
				oralink_free(cur->values[i]);
		}
		oralink_free(cur->values);
	}
	if (cur->indicator)
	{
		for (i = 0; i < cur->base.nfields; i++)
		{
			if (cur->indicator[i])
				oralink_free(cur->indicator[i]);
		}
		oralink_free(cur->indicator);
	}
	if (cur->allocsize)
		oralink_free(cur->allocsize);
	if (cur->data_type)
		oralink_free(cur->data_type);
	oralink_free(cur);
}

static oralink_cursor *
oralink_call(oralink_connection *conn, const char *func, int fetchsize, int max_value_len)
{
	oralink_cursor *cur;
	sword			status;
	int				i;
	char		   *str;
	char		   *sql;
	char			*p;
	OCIBind			*bnd1p;

	str = strdup(func);
	if ((p = strchr(str, '(')))
		*p++ = 0;
	else
		return false;
	/* sql needs extra length (here rounded to 64) for fixed content */
	sql = calloc(strlen(str) + strlen(p) + 64, 1);
	snprintf(sql, strlen(str) + strlen(p) + 64, "BEGIN %s(:cursor, %s; END;",
			 str, p);
	free(str);

	cur = oralink_cursor_new();
	cur->conn = conn;
	cur->org_stmt = stmt_create(conn, sql);
	cur->fetchsize = (fetchsize > 0) ? fetchsize : 1;
	cur->rowcount = 0;
	cur->current = 0;
	free(sql);

	if (max_value_len < 0)
		cur->max_value_len = conn->max_value_len;
	else
		cur->max_value_len = max_value_len;

	OCIHandleAlloc(conn->env, (dvoid **)&cur->stmt, OCI_HTYPE_STMT, 0, NULL);
	status = OCIBindByName(cur->org_stmt, (OCIBind **)&bnd1p,
		conn->error, (OraText *)":cursor", -1,
		(dvoid *)&cur->stmt, (sb4)0, SQLT_RSET, (dvoid *)0,
		(ub2 *)0, (ub2 *)0, (ub4)0, (ub4 *)0, (ub4)OCI_DEFAULT);
	if (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)
	{
		oralink_close(cur);
		oralink_error(conn->error, status);
	}

	status = OCIStmtExecute(conn->svcctx, cur->org_stmt, conn->error,
				1, 0, NULL, NULL, OCI_DEFAULT);
	if (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)
	{
		oralink_close(cur);
		oralink_error(conn->error, status);
	}
	if (status == OCI_SUCCESS_WITH_INFO)
		oralink_elog(conn->error, status);

	status = OCIAttrGet(cur->stmt, OCI_HTYPE_STMT,
				&cur->base.nfields, 0, OCI_ATTR_PARAM_COUNT, conn->error);
	if (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)
	{
		oralink_close(cur);
		oralink_error(conn->error, status);
	}

	cur->defnhp = oralink_calloc(cur->base.nfields * sizeof(OCIDefine *), 1);
	cur->values = oralink_calloc(cur->base.nfields * sizeof(char *), 1);
	cur->indicator = oralink_calloc(cur->base.nfields * sizeof(sb2 *), 1);
	cur->allocsize = oralink_calloc(cur->base.nfields * sizeof(ub4), 1);
	cur->data_type = oralink_calloc(cur->base.nfields * sizeof(sb4), 1);
	cur->lob_loc = oralink_calloc(cur->base.nfields * sizeof(OCILobLocator *), 1);

	for (i = 0;  i < cur->base.nfields; i++)
	{
		if (cur->max_value_len <= 0)
			cur->allocsize[i] = CALL_COLUNM_SIZE;
		else
			cur->allocsize[i] = cur->max_value_len + 1;

		cur->values[i] = oralink_malloc(cur->allocsize[i] * cur->fetchsize);
		cur->indicator[i] = oralink_calloc(sizeof(sb2) * cur->fetchsize, 1);
		cur->data_type[i] = SQLT_STR;

		status = OCIDefineByPos(cur->stmt,
					&cur->defnhp[i],
					conn->error,
					(ub4) i + 1,
					(dvoid *) cur->values[i],
					cur->allocsize[i],
					cur->data_type[i],
					(dvoid *) cur->indicator[i],
					(ub2 *) 0, (ub2 *) 0, OCI_DEFAULT);

		if (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)
		{
			oralink_close(cur);
			oralink_error(conn->error, status);
		}
		if (status == OCI_SUCCESS_WITH_INFO)
			oralink_elog(conn->error, status);
	}

	return cur;
}

static bool
oralink_command(oralink_connection *conn, dblink_command type)
{
	sword	status;
	XID		gxid;
	char	str[XIDDATASIZE];
	int		i;

	switch (type)
	{
		case DBLINK_BEGIN:
			status = OCITransStart(conn->svcctx, conn->error, 60, OCI_TRANS_NEW);
			break;
		case DBLINK_XA_START:
			/* set format id = 1000 */
			gxid.formatID = 1000;

			/* set global transaction id from gtrid parts */
			set_dblink_gtrid(str, lengthof(str), "%s", conn->base);
			gxid.gtrid_length = strlen(str);

			for (i = 0; i < gxid.gtrid_length; i++)
				gxid.data[i] = str[i];

			/* set branch id = 1 */
			gxid.bqual_length = 1;
			gxid.data[i] = 1;

			/* set XID */
			OCIAttrSet(conn->trans, OCI_HTYPE_TRANS, &gxid, sizeof(XID),
				OCI_ATTR_XID, conn->error);

			status = OCITransStart(conn->svcctx, conn->error, 60, OCI_TRANS_NEW);
			conn->trans_stat = OCI_SUCCESS;
			break;
		case DBLINK_COMMIT:
			status = OCITransCommit(conn->svcctx, conn->error, OCI_DEFAULT);
			break;
		case DBLINK_ROLLBACK:
			status = OCITransRollback(conn->svcctx, conn->error, OCI_DEFAULT);
			break;
		case DBLINK_XA_PREPARE:
			status = OCITransPrepare(conn->svcctx, conn->error, OCI_DEFAULT);
			conn->trans_stat = status;
			break;
		case DBLINK_XA_COMMIT:
			if (conn->trans_stat != OCI_SUCCESS_WITH_INFO)
				status = OCITransCommit(conn->svcctx,
								conn->error, OCI_TRANS_TWOPHASE);
			else
				status = OCI_SUCCESS;
			break;
		case DBLINK_XA_ROLLBACK:
			status = OCITransForget(conn->svcctx, conn->error, OCI_DEFAULT);
			break;
		default:
			return false;
	}

	if (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)
	{
		oralink_elog(conn->error, status);
		return false;
	}

	return true;
}

static void
oralink_lobread(oralink_cursor *cur, int field)
{
#define LOB_ALLOC_SIZE	32768
#define MAX_LOB_SIZE	0xFFFFFFFFU
	oralink_connection *conn = cur->conn;
	sword	status;
	ub4		amount = MAX_LOB_SIZE;
	ub4		offset = 0;
	char	*ptr;

	status = OCILobOpen(conn->svcctx, conn->error,
			cur->lob_loc[field], OCI_LOB_READONLY);
	if (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)
		oralink_error(conn->error, status);

	if (cur->allocsize[field] < LOB_ALLOC_SIZE)
	{
		cur->allocsize[field] = LOB_ALLOC_SIZE;
		cur->values[field] = oralink_realloc(cur->values[field], cur->allocsize[field]);
	}

	while (1)
	{
		status = OCILobRead(conn->svcctx, conn->error, cur->lob_loc[field],
				&amount, offset + 1, (dvoid *)(cur->values[field] + offset),
				cur->allocsize[field] - offset, (dvoid *)0,
				0, (ub2)0, (ub1)SQLCS_IMPLICIT);
		if (status != OCI_NEED_DATA)
		{
			if (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)
				oralink_error(conn->error, status);

			*(cur->values[field] + offset + amount) = 0;
			break;
		}
		if (MAX_LOB_SIZE - cur->allocsize[field] < LOB_ALLOC_SIZE)
		{
			OCIBreak(conn->svcctx, conn->error);
			OCILobClose(conn->svcctx, conn->error, cur->lob_loc[field]);
			dblink_error(ERRCODE_EXTERNAL_ROUTINE_EXCEPTION,
				"LOB data buffer overflowed.", NULL, NULL, NULL);
		}
		cur->allocsize[field] += LOB_ALLOC_SIZE;
		ptr = oralink_realloc(cur->values[field], cur->allocsize[field]);
		if (ptr == NULL)
		{
			OCIBreak(conn->svcctx, conn->error);
			OCILobClose(conn->svcctx, conn->error, cur->lob_loc[field]);
			dblink_error(ERRCODE_EXTERNAL_ROUTINE_EXCEPTION,
				"LOB data buffer allocate error.", NULL, NULL, NULL);
		}
		cur->values[field] = ptr;
		offset += amount;
	}

	OCILobClose(conn->svcctx, conn->error, cur->lob_loc[field]);
}

static void
oralink_error(OCIError *errhp, sword status)
{
	char	message[1024];

	oralink_message(message, lengthof(message), errhp, status);
	dblink_error(ERRCODE_EXTERNAL_ROUTINE_EXCEPTION, message, NULL, NULL, NULL);
}

static void
oralink_elog(OCIError *errhp, sword status)
{
	char	message[1024];

	oralink_message(message, lengthof(message), errhp, status);
	dblink_elog(LOG, message);
}

static void
oralink_message(char *message, int size, OCIError *errhp, sword status)
{
	text	errbuf[512];
	sb4		oracode = 0;

	switch (status)
	{
		case OCI_NEED_DATA:
			strlcpy(message, "OCI_NEED_DATA", size);
			break;
		case OCI_NO_DATA:
			strlcpy(message, "OCI_NO_DATA", size);
			break;
		case OCI_ERROR:
			OCIErrorGet ((void  *) errhp, (ub4) 1, (text *) NULL, &oracode,
				errbuf, (ub4) sizeof(errbuf), (ub4) OCI_HTYPE_ERROR);
			snprintf(message, size, "OCI_ERROR - %s", errbuf);
			break;
		case OCI_SUCCESS_WITH_INFO:
			OCIErrorGet ((void  *) errhp, (ub4) 1, (text *) NULL, &oracode,
				errbuf, (ub4) sizeof(errbuf), (ub4) OCI_HTYPE_ERROR);
			snprintf(message, size, "OCI_SUCCESS_WITH_INFO - %s", errbuf);
			break;
		case OCI_INVALID_HANDLE:
			strlcpy(message, "OCI_INVALID_HANDLE", size);
			break;
		case OCI_STILL_EXECUTING:
			strlcpy(message, "OCI_STILL_EXECUTING", size);
			break;
		case OCI_CONTINUE:
			strlcpy(message, "OCI_CONTINUE", size);
			break;
		default:
			snprintf(message, size, "OCI: %d", status);
			break;
	}
}

static void *oralink_malloc(size_t size)
{
	MemoryContext old_context;
	void	*p;

	old_context = MemoryContextSwitchTo(TopTransactionContext);
	p = palloc(size);
	MemoryContextSwitchTo(old_context);
	return p;
}

static void *oralink_calloc(size_t nmemb, size_t size)
{
	MemoryContext old_context;
	void	*p;

	old_context = MemoryContextSwitchTo(TopTransactionContext);
	p = palloc0(nmemb * size);
	MemoryContextSwitchTo(old_context);
	return p;
}

static void *oralink_realloc(void *ptr, size_t size)
{
	MemoryContext old_context;
	void	*p;

	old_context = MemoryContextSwitchTo(TopTransactionContext);
	p = repalloc(ptr, size);
	MemoryContextSwitchTo(old_context);
	return p;
}

static void oralink_free(void *ptr)
{
	if (ptr)
		pfree(ptr);
}

#endif
