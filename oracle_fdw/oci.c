/*
 * oracle_fdw_oci.c
 */
#define text	pg_text
#include "c.h"
#undef text


#include "postgres.h"
#include "pg_config.h"
#include "utils/memutils.h"

#include "fmgr.h"
#include "utils/elog.h"
#include "mb/pg_wchar.h"
#include "miscadmin.h"
#include "nodes/pg_list.h"

#include "oracle_fdw.h"
#include "former_ora.h"

#include <sys/time.h>
#include <oci.h>

#define COLUNM_SIZE			50
#define MSG_BUF_SIZE		1024
#define LOB_ALLOC_SIZE		32768
#define INTERVAL_ALLOC_SIZE	33
#define IS_SCROLLABLE(cur)	((cur)->max_value_len <= 0)

/*
 * ORAconn stores all the state data associated with a single connection to a
 * Oracle.
 */
struct ora_conn
{
	OCIEnv			   *env;
	OCIError		   *error;
	OCISvcCtx		   *svcctx;
	OCITrans		   *trans;
	OCIServer		   *server;
	OCISession		   *session;
	sword				trans_stat;
	ConnStatusType		status;
	char			   *msg;
	char			   *orauser;
	char			   *orapass;
	char			   *dbName;
	char			   *timezone;
	int					fetchsize;
	int					max_value_len;
	char			   *datestyle;
};

struct ora_result
{
	int					nfields;
	OCIStmt			   *stmt;
	OCIDefine		  **defnhp;
	char			  **values;
	sb2				   *indicator;
	ub4				   *allocsize;
	ub4				   *amountsize;
	sb4				   *data_type;
	OCILobLocator	  **lob_loc;
	OCIInterval		  **interval;
	int					max_value_len;
	ExecStatusType		resultStatus;
	ORAconn			   *conn;
	TupleFormer		   *former;
};

static ORAconn *oralink_connect(const char *user, const char *password, const char *dbname, const char *timezone, int fetchsize, int max_value_len);
static void oralink_disconnect(ORAconn *conn);
static int64 oralink_exec(ORAconn *conn, const char *sql);
static ORAresult *oralink_open(ORAconn *conn, const char *sql, int fetchsize, int max_value_len);
static bool oralink_fetch(ORAresult *cur);
static void oralink_close(ORAresult *cur);
static void oralink_lobread(ORAresult *cur, int field);
static void oralink_error(OCIError *errhp, sword status);
static void oralink_elog(OCIError *errhp, sword status);
static void oralink_message(char *message, int size, OCIError *errhp, sword status);
static void *oralink_malloc(size_t size);
static void *oralink_calloc(size_t nmemb, size_t size);
static void *oralink_realloc(void *ptr, size_t size);
static void oralink_free(void *ptr);

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
	//	"UTF8",				/* Unicode UTF8 */
		"AL32UTF8",				/* Unicode UTF8 */
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

static void
oralink_set_timezone(ORAconn *conn, const char *timezone)
{
	char	sql[1024];

	free(conn->timezone);
	conn->timezone = strdup(timezone);

	snprintf(sql, sizeof(sql), "ALTER SESSION SET TIME_ZONE = '%s'", timezone);
	oralink_exec(conn, sql);
}

static ORAconn *
oralink_connect(const char *user,
				const char *password,
				const char *dbname,
				const char *timezone,
				int fetchsize,
				int max_value_len)
{
	ORAconn		   *conn;
	sword			status;
	ub2				charsetid;

	conn = calloc(sizeof(ORAconn), 1);
	if (conn == NULL)
		return NULL;

	conn->status = CONNECTION_BAD;
	conn->msg = calloc(sizeof(char), MSG_BUF_SIZE);
	conn->orauser = user ? strdup(user) : NULL;
	conn->orapass = password ? strdup(password) : NULL;
	conn->dbName = dbname ? strdup(dbname) : NULL;

	/* set commmon fetchsize by this connection */
	if (fetchsize > 0)
		conn->fetchsize = fetchsize;

	/* set commmon max_value_len by this connection */
	if (max_value_len > 0)
		conn->max_value_len = max_value_len;

	charsetid = oralink_charset_id(GetDatabaseEncoding());
	status = OCIEnvNlsCreate(&conn->env, OCI_DEFAULT,
		NULL, 0, 0, 0, 0, NULL, charsetid, charsetid);
	if (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)
	{
		oralink_message(conn->msg, MSG_BUF_SIZE, conn->error, status);
		return conn;
	}

	/* init error handle */
	OCIHandleAlloc(conn->env, (dvoid **)&conn->error, OCI_HTYPE_ERROR, 0, NULL);

	/* init server handle & attach */
	OCIHandleAlloc(conn->env, (void **) &conn->server,
		OCI_HTYPE_SERVER, 0, NULL);
	status = OCIServerAttach(conn->server, conn->error, 
		(OraText *) dbname, dbname ? strlen(dbname) : 0, OCI_DEFAULT);
	if (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)
	{
		oralink_message(conn->msg, MSG_BUF_SIZE, conn->error, status);
		return conn;
	}

	/* set the external name and internal name in server handle */
	OCIAttrSet(conn->server, OCI_HTYPE_SERVER,
		"oracle_fdw_ex", strlen("oracle_fdw_ex"),
		OCI_ATTR_EXTERNAL_NAME, conn->error);
	OCIAttrSet(conn->server, OCI_HTYPE_SERVER, 
		"oracle_fdw_in", strlen("oracle_fdw_in"),
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
		ora_ereport(ERRCODE_SQLCLIENT_UNABLE_TO_ESTABLISH_SQLCONNECTION,
			"could not establish connection", message, NULL, NULL);
	}
	if (status == OCI_SUCCESS_WITH_INFO)
		oralink_elog(conn->error, status);

	OCIAttrSet(conn->svcctx, OCI_HTYPE_SVCCTX, 
		conn->session, 0, OCI_ATTR_SESSION, conn->error);

	/* set NLS parameter */
	oralink_exec(conn, "ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD BC HH24:MI:SS'");
	oralink_exec(conn, "ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD BC HH24:MI:SS.FF6'");
	oralink_exec(conn, "ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT = 'YYYY-MM-DD BC HH24:MI:SS.FF6 TZR'");
	oralink_exec(conn, "ALTER SESSION SET NLS_TIME_FORMAT = 'HH24:MI:SS.FF6'");
	oralink_exec(conn, "ALTER SESSION SET NLS_TIME_TZ_FORMAT = 'HH24:MI:SS.FF6 TZR'");
	oralink_exec(conn, "ALTER SESSION SET NLS_DATE_LANGUAGE = 'AMERICAN'");
	oralink_exec(conn, "ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '.,'");
	oralink_set_timezone(conn, timezone);

	/* start transaction */
	status = OCITransStart(conn->svcctx, conn->error, 60, OCI_TRANS_NEW);
	if (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)
	{
		oralink_elog(conn->error, status);
		return conn;
	}

	conn->status = CONNECTION_OK;

	return conn;
}

static void
oralink_disconnect(ORAconn *conn)
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

	free(conn->msg);
	free(conn->orauser);
	free(conn->orapass);
	free(conn->dbName);
	free(conn->timezone);
	free(conn);
}

static OCIStmt *
stmt_create(ORAconn *conn, const char *sql)
{
	OCIStmt		   *stmt = NULL;
	sword			status;

	OCIHandleAlloc(conn->env, (dvoid **) &stmt, OCI_HTYPE_STMT, 0, NULL);
	status = OCIStmtPrepare(stmt, conn->error, (OraText *) sql, 
		strlen(sql), OCI_NTV_SYNTAX, OCI_DEFAULT);

	if (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)
	{
		oralink_error(conn->error, status);
	}

	return stmt;
}

static int64
oralink_exec(ORAconn *conn, const char *sql)
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

ORAresult *
oralink_open(ORAconn *conn, const char *sql, int fetchsize, int max_value_len)
{
	OCIStmt		   *stmt;
	ORAresult	   *cur;
	sword			status;
	int				i;
	ub4				mode;
	ub4				size;

	stmt = stmt_create(conn, sql);

	cur = oralink_calloc(sizeof(ORAresult), 1);
	cur->nfields = 0;
	cur->conn = conn;
	cur->stmt = stmt;
	cur->resultStatus = PGRES_FATAL_ERROR;
	cur->max_value_len = max_value_len;

	if (IS_SCROLLABLE(cur))
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

	status = OCIAttrSet(cur->stmt, OCI_HTYPE_STMT,
				&fetchsize, 0, OCI_ATTR_PREFETCH_ROWS, conn->error);
	if (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)
	{
		oralink_close(cur);
		oralink_error(conn->error, status);
	}

	size = MAX_DATA_SIZE / 10;
	status = OCIAttrSet(cur->stmt, OCI_HTYPE_STMT,
				&size, 0, OCI_ATTR_PREFETCH_MEMORY, conn->error);
	if (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)
	{
		oralink_close(cur);
		oralink_error(conn->error, status);
	}

	status = OCIAttrGet(cur->stmt, OCI_HTYPE_STMT,
				&cur->nfields, 0, OCI_ATTR_PARAM_COUNT, conn->error);
	if (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)
	{
		oralink_close(cur);
		oralink_error(conn->error, status);
	}
	if (status == OCI_SUCCESS_WITH_INFO)
		oralink_elog(conn->error, status);

	/* Declare define handle */
	cur->defnhp = oralink_calloc(cur->nfields * sizeof(OCIDefine *), 1);
	cur->values = oralink_calloc(cur->nfields * sizeof(char *), 1);
	cur->indicator = oralink_calloc(cur->nfields * sizeof(sb2), 1);
	cur->allocsize = oralink_calloc(cur->nfields * sizeof(ub4), 1);
	cur->amountsize = oralink_calloc(cur->nfields * sizeof(ub4), 1);
	cur->data_type = oralink_calloc(cur->nfields * sizeof(sb4), 1);
	cur->lob_loc = oralink_calloc(cur->nfields * sizeof(OCILobLocator *), 1);
	cur->interval = oralink_calloc(cur->nfields * sizeof(OCIInterval *), 1);
	cur->former = TupleFormerCreate(cur->nfields);

	for (i = 0;  i < cur->nfields; i++)
	{
		OCIParam *hp = 0;

		status = OCIParamGet(cur->stmt, OCI_HTYPE_STMT,
				conn->error, (dvoid **)&hp, i + 1);
		status = OCIAttrGet(hp, OCI_DTYPE_PARAM,
				&cur->data_type[i], 0, OCI_ATTR_DATA_TYPE, conn->error);

		/*
		 * OCI doesn't support LONG and LONG RAW data type on scrollable
		 * cursors.
		 */
		if ((cur->data_type[i] == SQLT_LBI ||
			cur->data_type[i] == SQLT_LNG) &&
			mode == OCI_STMT_SCROLLABLE_READONLY)
		{
			oralink_close(cur);
			ora_ereport(ERRCODE_FEATURE_NOT_SUPPORTED,
				"max_value_len is required",
				"Doesn't support automatic expansion of the column buffer if "
				"LONG data type or LONG RAW data type is part of the foreign "
				"table.",
				"You must specify value more than maximum data size of all "
				"rows of foreign table in max_value_len for the row buffer.",
				NULL);
		}

		if (cur->data_type[i] == SQLT_BIN ||
			cur->data_type[i] == SQLT_LBI)
		{
			/* If raw data type, set TupleFormer to HEX */
			TupleFormerSetType(cur->former, i, OCI_HEX);
		}
		else if (cur->data_type[i] == SQLT_BFILE ||
				 cur->data_type[i] == SQLT_BLOB)
		{
			/* If binary data type, set TupleFormer to binary */
			TupleFormerSetType(cur->former, i, OCI_BIN);
		}
		else
			TupleFormerSetType(cur->former, i, OCI_STR);

		/*
		 * If not LOB, not binary data type and INTERVAL DAY TO SECOND, set
		 * fetch data type to string.
		 */
		if (cur->data_type[i] != SQLT_BFILE &&
			cur->data_type[i] != SQLT_BLOB && 
			cur->data_type[i] != SQLT_CLOB && 
			cur->data_type[i] != SQLT_INTERVAL_DS)
			cur->data_type[i] = SQLT_STR;

		/* If LOB data type, initialize lob locator. */
		if (cur->data_type[i] == SQLT_BFILE ||
			cur->data_type[i] == SQLT_BLOB || 
			cur->data_type[i] == SQLT_CLOB)
			OCIDescriptorAlloc((dvoid *)conn->env,
				(dvoid **)&cur->lob_loc[i],
				(ub4)OCI_DTYPE_LOB, (size_t)0, (dvoid **)0);

		/* If INTERVAL DAY TO SECOND data type, own convert to string. */
		if (cur->data_type[i] == SQLT_INTERVAL_DS)
		{
			OCIDescriptorAlloc(conn->env, (dvoid **)&cur->interval[i],
							   OCI_DTYPE_INTERVAL_DS, 0, 0);
		}
	}

	for (i = 0;  i < cur->nfields; i++)
	{
		dvoid  *valuep;
		sb4		value_sz;

		switch (cur->data_type[i])
		{
			case SQLT_CLOB:
			case SQLT_BLOB:
			case SQLT_BFILE:
				cur->allocsize[i] = LOB_ALLOC_SIZE;
				cur->values[i] = oralink_malloc(cur->allocsize[i]);

				valuep =  (dvoid *)&cur->lob_loc[i];
				value_sz = 0;
				break;
			case SQLT_INTERVAL_DS:
				cur->allocsize[i] = INTERVAL_ALLOC_SIZE;
				cur->values[i] = oralink_malloc(cur->allocsize[i]);

				valuep =  (dvoid *)&cur->interval[i];
				value_sz = sizeof(OCIInterval *);
				break;
			default:
				if (IS_SCROLLABLE(cur))
					cur->allocsize[i] = COLUNM_SIZE;
				else
					cur->allocsize[i] = cur->max_value_len + 1;

				cur->values[i] = oralink_malloc(cur->allocsize[i]);

				valuep = (dvoid *)cur->values[i];
				value_sz = cur->allocsize[i];
				break;
		}

		status = OCIDefineByPos(cur->stmt,
					&cur->defnhp[i],
					conn->error,
					(ub4) i + 1,
					valuep,
					value_sz,
					cur->data_type[i],
					(dvoid *)&cur->indicator[i],
					(ub2 *) 0, (ub2 *) 0, OCI_DEFAULT);

		if (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)
		{
			oralink_close(cur);
			oralink_error(conn->error, status);
		}
		if (status == OCI_SUCCESS_WITH_INFO)
		{
			oralink_elog(conn->error, status);
		}
	}

	cur->resultStatus = PGRES_TUPLES_OK;

	return cur;
}

bool
oralink_fetch(ORAresult *cur)
{
	int		i;
	sword	status;
	ub4		fetch_mode = OCI_FETCH_NEXT;

	while (1)
	{
		int		realloc_count = 0;
		int		max_value_len = 0;

		memset(cur->indicator, 0, sizeof(sb2) * cur->nfields);

		status = OCIStmtFetch2(cur->stmt, cur->conn->error,
				1, fetch_mode, 0, OCI_DEFAULT);

		if (status == OCI_ERROR)
		{
			text	errbuf[512];
			sb4		errcode = 0;

			OCIErrorGet ((void  *) cur->conn->error, (ub4) 1, (text *) NULL,
				&errcode, errbuf, (ub4) sizeof(errbuf), (ub4) OCI_HTYPE_ERROR);
			if (errcode != 1406)
				oralink_error(cur->conn->error, status);
		}

		if (status == OCI_NO_DATA)
		{
			return false;
		}

		for (i = 0; i < cur->nfields; i++)
		{
			/* indicator 0 is full value, indicator -1 is NULL value */
			if (cur->indicator[i] == 0 || cur->indicator[i] == -1)
				continue;

			if (cur->allocsize[i] >= MAX_DATA_SIZE)
			{
				ora_ereport(ERRCODE_EXTERNAL_ROUTINE_EXCEPTION,
					"fetch data buffer overflowed.", NULL, NULL, NULL);
			}

			if (cur->indicator[i] > 0)
				if (cur->allocsize[i] >= cur->indicator[i] + 1)
					cur->allocsize[i]++;
				else
					cur->allocsize[i] = cur->indicator[i] + 1;
			else if (cur->indicator[i] == -2)
				cur->allocsize[i] += USHRT_MAX;
			else
				ora_elog(ERROR, "invalid fetch indicator");

			if (cur->allocsize[i] > MAX_DATA_SIZE)
				cur->allocsize[i] = MAX_DATA_SIZE;

			realloc_count++;
			cur->values[i] = oralink_realloc(cur->values[i], cur->allocsize[i]);

			if (cur->allocsize[i] > max_value_len)
				max_value_len = cur->allocsize[i];

			status = OCIDefineByPos(cur->stmt,
						&cur->defnhp[i],
						cur->conn->error,
						(ub4)i + 1,
						(dvoid *)cur->values[i],
						cur->allocsize[i],
						cur->data_type[i],
						(dvoid *)&cur->indicator[i],
						(ub2 *) 0, (ub2 *) 0, OCI_DEFAULT);
			if (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)
			{
				oralink_error(cur->conn->error, status);
			}
			if (status == OCI_SUCCESS_WITH_INFO)
				oralink_elog(cur->conn->error, status);
		}
		if (realloc_count == 0)
			break;

		if (!IS_SCROLLABLE(cur))
		{
			snprintf(cur->conn->msg, MSG_BUF_SIZE,
					 "You must specify value %d or more in max_value_len",
					 max_value_len);

			ora_ereport(ERRCODE_STRING_DATA_RIGHT_TRUNCATION,
						"value too long for max_value_len",
						NULL, cur->conn->msg, NULL);
		}

		fetch_mode = OCI_FETCH_RELATIVE;
	}

	return true;
}

static void
oralink_close(ORAresult *cur)
{
	int i;

	if (cur->lob_loc)
	{
		for (i = 0; i < cur->nfields; i++)
		{
			if (cur->lob_loc[i])
				OCIDescriptorFree(cur->lob_loc[i], OCI_DTYPE_LOB);
		}
		oralink_free(cur->lob_loc);
	}
	if (cur->stmt)
		OCIHandleFree(cur->stmt, OCI_HTYPE_STMT);
	if (cur->defnhp)
		oralink_free(cur->defnhp);
	if (cur->values)
	{
		for (i = 0; i < cur->nfields; i++)
		{
			if (cur->values[i])
				oralink_free(cur->values[i]);
		}
		oralink_free(cur->values);
	}
	if (cur->indicator)
		oralink_free(cur->indicator);
	if (cur->allocsize)
		oralink_free(cur->allocsize);
	if (cur->data_type)
		oralink_free(cur->data_type);
	if (cur->interval)
		oralink_free(cur->interval);
	if (cur->former)
		TupleFormerTerm(cur->former);
	oralink_free(cur);
}

static void
oralink_lobread(ORAresult *cur, int field)
{
#define MAX_LOB_SIZE	MAX_DATA_SIZE
	ORAconn *conn = cur->conn;
	sword	status;
	ub1		csfrm;
	ub4		amount = MAX_LOB_SIZE;
	ub4		offset = 0;
	char	*ptr;

	status = OCILobOpen(conn->svcctx, conn->error,
			cur->lob_loc[field], OCI_LOB_READONLY);
	if (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)
		oralink_error(conn->error, status);

	status = OCILobCharSetForm(conn->env, conn->error,
				cur->lob_loc[field], &csfrm);

	if (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)
		oralink_error(conn->error, status);

	while (1)
	{
		status = OCILobRead(conn->svcctx, conn->error, cur->lob_loc[field],
				&amount, offset + 1, (dvoid *)(cur->values[field] + offset),
				cur->allocsize[field] - offset - 1, (dvoid *)0,
				0, (ub2)0, csfrm);
		if (status != OCI_NEED_DATA)
		{
			if (status != OCI_SUCCESS && status != OCI_SUCCESS_WITH_INFO)
				oralink_error(conn->error, status);

			*(cur->values[field] + offset + amount) = 0;
			cur->amountsize[field] = offset + amount;
			break;
		}

		if (cur->allocsize[field] >= MAX_LOB_SIZE)
		{
			OCIBreak(conn->svcctx, conn->error);
			ora_ereport(ERRCODE_EXTERNAL_ROUTINE_EXCEPTION,
				"LOB data buffer overflowed.", NULL, NULL, NULL);
		}

		cur->allocsize[field] += LOB_ALLOC_SIZE;
		if (cur->allocsize[field] > MAX_LOB_SIZE)
			cur->allocsize[field] = MAX_LOB_SIZE;

		ptr = oralink_realloc(cur->values[field], cur->allocsize[field]);
		if (ptr == NULL)
		{
			OCIBreak(conn->svcctx, conn->error);
			ora_ereport(ERRCODE_EXTERNAL_ROUTINE_EXCEPTION,
				"LOB data buffer allocate error.", NULL, NULL, NULL);
		}
		cur->values[field] = ptr;
		offset += amount;
	}

	OCILobClose(conn->svcctx, conn->error, cur->lob_loc[field]);
}

/*
 * Convert a Oracle interval day to second value to postgres interval format.
 */
static void
intervalds_parse(ORAresult *res, int field)
{
	sb4		dy;
	sb4		hr;
	sb4		mm;
	sb4		ss;
	sb4		fsec;
	int		minus = 0;
	int		len = 0;
	char   *value;

	OCIIntervalGetDaySecond(res->conn->env, res->conn->error,
							&dy, &hr, &mm, &ss, &fsec, res->interval[field]);

	if (hr < 0 || mm < 0 || ss < 0 || fsec < 0)
	{
		hr *= -1;
		mm *= -1;
		ss *= -1;
		fsec *= -1;
		minus = 1;
	}

	value = res->values[field];

	/* part on a day */
	if (dy != 0)
		len = snprintf(value, res->allocsize[field], "%d days ", dy);

	/* part on a time */
	if (hr != 0 || mm != 0 || ss != 0 || fsec != 0)
	{
		snprintf(value + len, res->allocsize[field] - len,
				 "%s%02d:%02d:%02d.%06d",
				 (minus ? "-" : ""), hr, mm, ss, fsec / 1000);
	}
	else if (dy == 0)
		snprintf(value, res->allocsize[field], "0");
}

static void
oralink_error(OCIError *errhp, sword status)
{
	char	message[1024];

	oralink_message(message, lengthof(message), errhp, status);
	ora_ereport(ERRCODE_EXTERNAL_ROUTINE_EXCEPTION, message, NULL, NULL, NULL);
}

static void
oralink_elog(OCIError *errhp, sword status)
{
	char	message[1024];

	oralink_message(message, lengthof(message), errhp, status);
	ora_elog(LOG, message);
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

	old_context = MemoryContextSwitchTo(CurTransactionContext);
	p = palloc(size);
	MemoryContextSwitchTo(old_context);
	return p;
}

static void *oralink_calloc(size_t nmemb, size_t size)
{
	MemoryContext old_context;
	void	*p;

	old_context = MemoryContextSwitchTo(CurTransactionContext);
	p = palloc0(nmemb * size);
	MemoryContextSwitchTo(old_context);
	return p;
}

static void *oralink_realloc(void *ptr, size_t size)
{
	MemoryContext old_context;
	void	*p;

	old_context = MemoryContextSwitchTo(CurTransactionContext);
	p = repalloc(ptr, size);
	MemoryContextSwitchTo(old_context);
	return p;
}

static void oralink_free(void *ptr)
{
	if (ptr)
		pfree(ptr);
}

ORAconn *
ORAsetdbLogin(const char *user, const char *password, const char *dbname, const char *timezone, int fetchsize, int max_value_len)
{
	return oralink_connect(user, password, dbname, timezone, fetchsize, max_value_len);
}

/*
 * PQfinish
 * ORAfinish: properly close a connection to the backend. Also frees
 * the PGconn data structure so it shouldn't be re-used after this.
 */
void
ORAfinish(ORAconn *conn)
{
	oralink_disconnect(conn);
}

/* =========== accessor functions for ORAconn ========= */
char *
ORAdb(const ORAconn *conn)
{
	if (!conn)
		return NULL;
	return conn->dbName;
}

char *
ORAuser(const ORAconn *conn)
{
	if (!conn)
		return NULL;
	return conn->orauser;
}

char *
ORApass(const ORAconn *conn)
{
	if (!conn)
		return NULL;
	return conn->orapass;
}

char *
ORAtimezone(const ORAconn *conn)
{
	if (!conn)
		return NULL;
	return conn->timezone;
}

int
ORAfetchsize(const ORAconn *conn)
{
	if (!conn)
		return 0;
	return conn->fetchsize;
}

int
ORAmax_value_len(const ORAconn *conn)
{
	if (!conn)
		return 0;
	return conn->max_value_len;
}

ConnStatusType
ORAstatus(const ORAconn *conn)
{
	if (!conn)
		return CONNECTION_BAD;

	return conn->status;
}

char *
ORAerrorMessage(const ORAconn *conn)
{
	if (!conn)
		return "invalid connection";

	return conn->msg;
}

void
ORAsetFetchsize(ORAconn *conn, int fetchsize)
{
	conn->fetchsize = fetchsize;
}

void
ORAsetMaxValueLen(ORAconn *conn, int max_value_len)
{
	conn->max_value_len = max_value_len;
}

ORAresult *
ORAopen(ORAconn *conn, const char *sql, int fetchsize, int max_value_len)
{
	return oralink_open(conn, sql, fetchsize, max_value_len);
}

bool
ORAhasNext(ORAresult *res)
{
	if (!res)
		return PGRES_FATAL_ERROR;

	return oralink_fetch(res);
}

ExecStatusType
ORAresultStatus(ORAresult *res)
{
	if (!res)
		return PGRES_FATAL_ERROR;

	return res->resultStatus;
}

int
ORAnfields(const ORAresult *res)
{
	if (!res)
		return 0;

	return res->nfields;
}

/*
 * ORAgetvalue:
 *	return the value of field 'field_num' of current row
 */
char *
ORAgetvalue(ORAresult *res, int field_num)
{
	if (!res)
		return NULL;

	switch (res->data_type[field_num])
	{
		case SQLT_CLOB:
		case SQLT_BLOB:
		case SQLT_BFILE:
			oralink_lobread(res, field_num);
			break;
		case SQLT_INTERVAL_DS:
			intervalds_parse(res, field_num);
			break;
		default:
			break;
	}

	return res->values[field_num];
}

/*
 *	returns the null status of a field value.
 */
int
ORAgetisnull(const ORAresult *res, int field_num)
{
	if (!res)
		return true;

	if (res->indicator[field_num] == -1)
		return true;

	return false;
}

/*
 *	returns the amount size of a field value.
 */
int
ORAgetamountsize(ORAresult *res, int field_num)
{
	return res->amountsize[field_num];
}

/*
 * ORAclear -
 *	  free's the memory associated with a ORAresult
 */
void
ORAclear(ORAresult *res)
{
	if (!res)
		return;

	oralink_close(res);
}

TupleFormer *
ORAgetTupleFormer(ORAresult *res)
{
	return res->former;
}
