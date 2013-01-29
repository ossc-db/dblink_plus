/*-------------------------------------------------------------------------
 *
 * deparse.c
 *		  query deparser for PostgreSQL
 *
 * Copyright (c) 2011, NIPPON TELEGRAPH AND TELEPHONE CORPORATION
 *
 * IDENTIFICATION
 *		  contrib/oracle_fdw/deparse.c
 *
 *-------------------------------------------------------------------------
 */
#include "postgres.h"

#include "catalog/pg_proc.h"
#include "catalog/pg_type.h"
#include "commands/variable.h"
#include "foreign/foreign.h"
#include "lib/stringinfo.h"
#include "miscadmin.h"
#include "nodes/nodeFuncs.h"
#include "optimizer/clauses.h"
#include "optimizer/var.h"
#include "parser/parsetree.h"
#include "utils/builtins.h"
#include "utils/date.h"
#include "utils/datetime.h"
#include "utils/formatting.h"
#include "utils/lsyscache.h"
#include "utils/syscache.h"
#include "utils/timestamp.h"

#include "deparse.h"
#include "oracle_fdw.h"
#include "routine.h"
#include "ruleutils.h"

#define HAS_NEGATIVE(tm, fsec) ((tm)->tm_year < 0 || (tm)->tm_mon < 0 || (tm)->tm_mday < 0 || (tm)->tm_hour < 0 || (tm)->tm_min < 0 || (tm)->tm_sec < 0 || (fsec) < 0)
#define HAS_POSITIVE(tm, fsec) ((tm)->tm_year > 0 || (tm)->tm_mon > 0 || (tm)->tm_mday > 0 || (tm)->tm_hour > 0 || (tm)->tm_min > 0 || (tm)->tm_sec > 0 || (fsec) > 0)
#define HAS_YEAR_MONTH(tm) ((tm)->tm_year != 0 || (tm)->tm_mon != 0)
#define HAS_DAY_TIME(tm, fsec) ((tm)->tm_mday != 0 || (tm)->tm_hour != 0 || (tm)->tm_min != 0 || (tm)->tm_sec != 0 || (fsec) != 0)
#define HAS_DAY(tm) ((tm)->tm_mday != 0)
#define SQL_STANDARD_VALUE(tm, fsec) (!(HAS_NEGATIVE((tm), (fsec)) && HAS_POSITIVE((tm), (fsec))) && !(HAS_YEAR_MONTH((tm)) && HAS_DAY_TIME((tm), (fsec))))

/* helper for deparsing a request into SQL statement */
static bool is_foreign_qual(PlannerInfo *root, RelOptInfo *baserel, ForeignTable *table, Expr *expr);
static bool foreign_qual_walker(Node *node, void *context);

/*
 * Deparse a var into column name, result is quoted if necessary.
 */
static void
deparse_var(PlannerInfo *root, StringInfo buf, Var *var)
{
	RangeTblEntry *rte;
	char *attname;

	if (var->varlevelsup != 0)
		elog(ERROR, "unexpected varlevelsup %d in remote query",
			 var->varlevelsup);

	if (var->varno < 1 || var->varno > list_length(root->parse->rtable))
		elog(ERROR, "unexpected varno %d in remote query", var->varno);
	rte = rt_fetch(var->varno, root->parse->rtable);

	attname  = get_rte_attribute_name(rte, var->varattno);
	appendStringInfoString(buf, ora_quote_identifier(attname));
}

typedef struct
{
	PlannerInfo	   *root;
	Oid				foreignrelid;
	Oid				serverid;
	RelOptInfo	   *foreignrel;
} remotely_executable_cxt;

typedef struct
{
	Oid		procid;
} routine_mapping;

static Oid support_operator[] = {
	/* '=' operator */
	63,	/* int2eq */
	65,	/* int4eq */
	67,	/* texteq */
	158,	/* int24eq */
	159,	/* int42eq */
	287,	/* float4eq */
	293,	/* float8eq */
	299,	/* float48eq */
	305,	/* float84eq */
	467,	/* int8eq */
	474,	/* int84eq */
	852,	/* int48eq */
	1048,	/* bpchareq */
	1086,	/* date_eq */
	1152,	/* timestamptz_eq */
	1162,	/* interval_eq */
	1718,	/* numeric_eq */
	1850,	/* int28eq */
	1856,	/* int82eq */
	1948,	/* byteaeq */
	2052,	/* timestamp_eq */
	2340,	/* date_eq_timestamp */
	2353,	/* date_eq_timestamptz */
	2366,	/* timestamp_eq_date */
	2379,	/* timestamptz_eq_date */
	2522,	/* timestamp_eq_timestamptz */
	2529,	/* timestamptz_eq_timestamp */
	/* '<>' operator */
	144,	/* int4ne */
	145,	/* int2ne */
	157,	/* textne */
	164,	/* int24ne */
	165,	/* int42ne */
	288,	/* float4ne */
	294,	/* float8ne */
	300,	/* float48ne */
	306,	/* float84ne */
	468,	/* int8ne */
	475,	/* int84ne */
	853,	/* int48ne */
	1053,	/* bpcharne */
	1091,	/* date_ne */
	1153,	/* timestamptz_ne */
	1163,	/* interval_ne */
	1719,	/* numeric_ne */
	1851,	/* int28ne */
	1857,	/* int82ne */
	1953,	/* byteane */
	2053,	/* timestamp_ne */
	2343,	/* date_ne_timestamp */
	2356,	/* date_ne_timestamptz */
	2369,	/* timestamp_ne_date */
	2382,	/* timestamptz_ne_date */
	2525,	/* timestamp_ne_timestamptz */
	2532,	/* timestamptz_ne_timestamp */
	/* '>' operator */
	146,	/* int2gt */
	147,	/* int4gt */
	162,	/* int24gt */
	163,	/* int42gt */
	291,	/* float4gt */
	297,	/* float8gt */
	303,	/* float48gt */
	309,	/* float84gt */
	470,	/* int8gt */
	477,	/* int84gt */
	742,	/* text_gt */
	855,	/* int48gt */
	1051,	/* bpchargt */
	1089,	/* date_gt */
	1157,	/* timestamptz_gt */
	1167,	/* interval_gt */
	1720,	/* numeric_gt */
	1853,	/* int28gt */
	1859,	/* int82gt */
	1951,	/* byteagt */
	2057,	/* timestamp_gt */
	2341,	/* date_gt_timestamp */
	2354,	/* date_gt_timestamptz */
	2367,	/* timestamp_gt_date */
	2380,	/* timestamptz_gt_date */
	2523,	/* timestamp_gt_timestamptz */
	2530,	/* timestamptz_gt_timestamp */
	/* '<' operator */
	64,	/* int2lt */
	66,	/* int4lt */
	160,	/* int24lt */
	161,	/* int42lt */
	289,	/* float4lt */
	295,	/* float8lt */
	301,	/* float48lt */
	307,	/* float84lt */
	469,	/* int8lt */
	476,	/* int84lt */
	740,	/* text_lt */
	854,	/* int48lt */
	1049,	/* bpcharlt */
	1087,	/* date_lt */
	1154,	/* timestamptz_lt */
	1164,	/* interval_lt */
	1722,	/* numeric_lt */
	1852,	/* int28lt */
	1858,	/* int82lt */
	1949,	/* bytealt */
	2054,	/* timestamp_lt */
	2338,	/* date_lt_timestamp */
	2351,	/* date_lt_timestamptz */
	2364,	/* timestamp_lt_date */
	2377,	/* timestamptz_lt_date */
	2520,	/* timestamp_lt_timestamptz */
	2527,	/* timestamptz_lt_timestamp */
	/* '>=' operator */
	150,	/* int4ge */
	151,	/* int2ge */
	168,	/* int24ge */
	169,	/* int42ge */
	292,	/* float4ge */
	298,	/* float8ge */
	304,	/* float48ge */
	310,	/* float84ge */
	472,	/* int8ge */
	479,	/* int84ge */
	743,	/* text_ge */
	857,	/* int48ge */
	1052,	/* bpcharge */
	1090,	/* date_ge */
	1156,	/* timestamptz_ge */
	1166,	/* interval_ge */
	1721,	/* numeric_ge */
	1855,	/* int28ge */
	1861,	/* int82ge */
	1952,	/* byteage */
	2056,	/* timestamp_ge */
	2342,	/* date_ge_timestamp */
	2355,	/* date_ge_timestamptz */
	2368,	/* timestamp_ge_date */
	2381,	/* timestamptz_ge_date */
	2524,	/* timestamp_ge_timestamptz */
	2531,	/* timestamptz_ge_timestamp */
	/* '<=' operator */
	148,	/* int2le */
	149,	/* int4le */
	166,	/* int24le */
	167,	/* int42le */
	290,	/* float4le */
	296,	/* float8le */
	302,	/* float48le */
	308,	/* float84le */
	471,	/* int8le */
	478,	/* int84le */
	741,	/* text_le */
	856,	/* int48le */
	1050,	/* bpcharle */
	1088,	/* date_le */
	1155,	/* timestamptz_le */
	1165,	/* interval_le */
	1723,	/* numeric_le */
	1854,	/* int28le */
	1860,	/* int82le */
	1950,	/* byteale */
	2055,	/* timestamp_le */
	2339,	/* date_le_timestamp */
	2352,	/* date_le_timestamptz */
	2365,	/* timestamp_le_date */
	2378,	/* timestamptz_le_date */
	2521,	/* timestamp_le_timestamptz */
	2528,	/* timestamptz_le_timestamp */
	/* '+' operator */
	176,	/* int2pl */
	177,	/* int4pl */
	178,	/* int24pl */
	179,	/* int42pl */
	204,	/* float4pl */
	218,	/* float8pl */
	281,	/* float48pl */
	285,	/* float84pl */
	463,	/* int8pl */
	837,	/* int82pl */
	841,	/* int28pl */
	1274,	/* int84pl */
	1278,	/* int48pl */
	1724,	/* numeric_add */
	1910,	/* int8up */
	1911,	/* int2up */
	1912,	/* int4up */
	1913,	/* float4up */
	1914,	/* float8up */
	1915,	/* numeric_uplus */
	/* '-' operator */
	180,	/* int2mi */
	181,	/* int4mi */
	182,	/* int24mi */
	183,	/* int42mi */
	205,	/* float4mi */
	206,	/* float4um */
	212,	/* int4um */
	213,	/* int2um */
	219,	/* float8mi */
	220,	/* float8um */
	282,	/* float48mi */
	286,	/* float84mi */
	462,	/* int8um */
	464,	/* int8mi */
	838,	/* int82mi */
	942,	/* int28mi */
	1275,	/* int84mi */
	1279,	/* int48mi */
	1725,	/* numeric_sub */
	1771,	/* numeric_uminus */
	/* '*' operator */
	141,	/* int4mul */
	152,	/* int2mul */
	170,	/* int24mul */
	171,	/* int42mul */
	202,	/* float4mul */
	216,	/* float8mul */
	279,	/* float48mul */
	283,	/* float84mul */
	465,	/* int8mul */
	839,	/* int82mul */
	943,	/* int28mul */
	1276,	/* int84mul */
	1280,	/* int48mul */
	1726,	/* numeric_mul */
	/* '/' operator */
	153,	/* int2div */
	154,	/* int4div */
	172,	/* int24div */
	173,	/* int42div */
	203,	/* float4div */
	217,	/* float8div */
	280,	/* float48div */
	284,	/* float84div */
	466,	/* int8div */
	840,	/* int82div */
	948,	/* int28div */
	1277,	/* int84div */
	1281,	/* int48div */
	1727,	/* numeric_div */
	/* '||' operator */
	1258,	/* textcat */
	/* 'LIKE' operator */
	850,	/* textlike */
	1631,	/* bpcharlike */
	/* 'NOT LIKE' operator */
	851,	/* textnlike */
	1632,	/* bpcharnlike */
	/* date / time '+' operator */
	1141,	/* date_pli */
	1169,	/* interval_pl */
	1189,	/* timestamptz_pl_interval */
	2032,	/* timestamp_pl_interval */
	2071,	/* date_pl_interval */
	2546,	/* interval_pl_date */
	2548,	/* interval_pl_timestamp */
	2549,	/* interval_pl_timestamptz */
	2550,	/* integer_pl_date */
	/* date / time '-' operator */
	1140,	/* date_mi */
	1142,	/* date_mii */
	1168,	/* interval_um */
	1170,	/* interval_mi */
	1188,	/* timestamptz_mi */
	1190,	/* timestamptz_mi_interval */
	2031,	/* timestamp_mi */
	2033,	/* timestamp_mi_interval */
	2072,	/* date_mi_interval */
	/* interval '*' operator */
	1618,	/* interval_mul */
	1624,	/* mul_d_interval */
	/* interval '/' operator */
	1326,	/* interval_div */
	InvalidOid
};

/*
 * return true if typeid can be push down in foreign server.
 */
static bool
is_const_remotely_pushdown(Const *constval)
{
	/* assume that only data type to support can be pushed down. */
	switch (constval->consttype)
	{
		case UNKNOWNOID:
		case INT2OID:
		case INT4OID:
		case INT8OID:
		case FLOAT4OID:
		case FLOAT8OID:
		case NUMERICOID:
		case CHAROID:
		case BPCHAROID:
		case VARCHAROID:
		case TEXTOID:
		case BYTEAOID:
		case TIMESTAMPOID:
		case TIMESTAMPTZOID:
			return true;

		case INTERVALOID:
			{
				Interval   *span = DatumGetIntervalP(constval->constvalue);
				struct		pg_tm tt,
						   *tm = &tt;
				fsec_t		fsec;

				if (interval2tm(*span, tm, &fsec) != 0)
					elog(ERROR, "could not convert interval to tm");

				if ((HAS_NEGATIVE(tm, fsec) || HAS_POSITIVE(tm, fsec)) &&
					SQL_STANDARD_VALUE(tm, fsec))
					return true;
			}
			break;

		case DATEOID:
			{
				DateADT		date = DatumGetDateADT(constval->constvalue);

				if (!DATE_NOT_FINITE(date))
					return true;
			}
			break;

		default:
			break;
	}

	return false;
}

/*
 * return true if procid can be operator in foreign server.
 */
static bool
is_operator_remotely_pushdown(Oid procid)
{
	int	i;

	/* assume that only operator to support can be pushed down. */
	for (i = 0; support_operator[i] != InvalidOid; i++)
	{
		if (procid == support_operator[i])
			return true;
	}

	elog(DEBUG1, "procid %d doesn't support", procid);

	return false;
}

static void
required_error(RoutineMapping *rm, char *keyword)
{
	ereport(ERROR,
			(errcode(ERRCODE_S_R_E_PROHIBITED_SQL_STATEMENT_ATTEMPTED),
			 errmsg("%s option is not specified in routine mapping mapped by %s of foreign server %d.",
				keyword, format_procedure(rm->procid), rm->serverid)));
}

/*
 * return true if procid can be operator in foreign server.
 */
static bool
is_function_remotely_pushdown(FuncExpr *func, remotely_executable_cxt *context)
{
	RoutineMapping *rm;
	HeapTuple		proctup;
	Form_pg_proc	procform;
	bool			is_valiadic;

	rm = GetRoutineMapping(func->funcid, context->serverid);
	if (!rm)
		return false;

	proctup = SearchSysCache1(PROCOID, ObjectIdGetDatum(func->funcid));
	if (!HeapTupleIsValid(proctup))
		elog(ERROR, "cache lookup failed for function %u", func->funcid);
	procform = (Form_pg_proc) GETSTRUCT(proctup);
	is_valiadic = OidIsValid(procform->provariadic);
	ReleaseSysCache(proctup);

	if (GetFdwOptionList(rm->options, "format") == NULL)
		required_error(rm, "format");

	/*
	 * If function is valiadic function, we do push down only when nargs
	 * FDW-options accords with the number of arguments of the function.
	 */
	if (is_valiadic)
	{
		const char *value;
		int			v;

		if ((value = GetFdwOptionList(rm->options, "nargs")) == NULL)
			required_error(rm, "nargs");

		v = parse_int_value(value, "nargs");

		if (list_length(func->args) != v)
			return false;
	}

	return true;
}

/*
 * return true if node can NOT be evaluatated in foreign server.
 *
 * An expression which consists of expressions below can be evaluated in
 * the foreign server.
 *  - constant value
 *  - variable (foreign table column)
 *  - bool expression (AND/OR/NOT)
 *  - NULL test (IS [NOT] NULL)
 *  - operator
 *    - IMMUTABLE or STABLE only
 *    - It is required that the meaning of the operator be the same as the
 *      local server in the foreign server.
 */
static bool
foreign_qual_walker(Node *node, void *context)
{
	remotely_executable_cxt	   *r_context;

	if (node == NULL)
		return false;

	switch (nodeTag(node))
	{
		case T_BoolExpr:
		case T_RelabelType:
		case T_NullTest:
			/*
			 * These type of nodes are known as safe to be pushed down.
			 * Of course the subtree of the node, if any, should be checked
			 * continuously.
			 */
			break;
		case T_Const:
			{
				Const  *co = (Const *) node;

				if (!is_const_remotely_pushdown(co))
					return true;
			}
			break;
		case T_OpExpr:
			{
				OpExpr	   *op = (OpExpr *) node;

				if (!is_operator_remotely_pushdown(op->opfuncid))
					return true;
				/* arguments are checked later via walker */
			}
			break;
		case T_Var:
			{
				/*
				 * Var can be pushed down if it is in the foreign table.
				 * XXX Var of other relation can be here?
				 */
				Var *var = (Var *) node;

				r_context = (remotely_executable_cxt *) context;
				if (var->varno != r_context->foreignrel->relid ||
					var->varlevelsup != 0)
					return true;
			}
			break;
		case T_FuncExpr:
			{
				FuncExpr *func = (FuncExpr *) node;

				r_context = (remotely_executable_cxt *) context;
				if (!is_function_remotely_pushdown(func, r_context))
					return true;
				/* arguments are checked later via walker */
			}
			break;
		default:
			/* Other expression can't be pushed down */
			elog(DEBUG1, "node is too complex");
			elog(DEBUG1, "%s", nodeToString(node));
			return true;
	}

	return expression_tree_walker(node, foreign_qual_walker, context);
}


/*
 * Check whether the ExprState node can be evaluated in foreign server.
 *
 * Actual check is implemented in foreign_qual_walker.
 */
static bool
is_foreign_qual(PlannerInfo *root, RelOptInfo *baserel, ForeignTable *table, Expr *expr)
{
	remotely_executable_cxt context;

	context.root = root;
	context.foreignrelid = table->relid;
	context.serverid = table->serverid;
	context.foreignrel = baserel;

	/*
	 * Check that the expression consists of nodes which are known as safe to
	 * be pushed down.
	 */
	if (foreign_qual_walker((Node *) expr, &context))
		return false;

	/* Check that the expression doesn't include any volatile function. */
	if (contain_volatile_functions((Node *) expr))
		return false;

	return true;
}

/*
 * Deparse query request into SQL statement.
 *
 * If an expression in PlanState.qual list satisfies is_foreign_qual(), the
 * expression is:
 *   - deparsed into WHERE clause of remote SQL statement to evaluate that
 *     expression on remote side
 *   - removed from PlanState.qual list to avoid duplicate evaluation, on
 *     remote side and local side
 */
char *
deparseSql(Oid foreigntableid, PlannerInfo *root, RelOptInfo *baserel)
{
	AttrNumber		attr;
	List		   *attr_used = NIL;
	List		   *context;
	List		   *foreign_expr = NIL;
	StringInfoData	sql;
	ForeignTable   *table = GetForeignTable(foreigntableid);
	ListCell   *lc;
	bool		first;
	char	   *nspname = NULL;
	char	   *relname = NULL;
	RangeTblEntry  *rte;

	/* extract ForeignScan and RangeTblEntry */

	/* prepare to deparse plan */
	initStringInfo(&sql);

	context = deparse_context_for("oracle_fdw_foreigntable", foreigntableid);

	/*
	 * Determine which qual can be pushed down.
	 *
	 * The expressions which satisfy is_foreign_qual() are deparsed into WHERE
	 * clause of result SQL string, and they could be removed from qual of
	 * PlanState to avoid duplicate evaluation at ExecScan().
	 *
	 * We never change the qual in the Plan node which was made by PREPARE
	 * statement to make following EXECUTE statements work properly.  The Plan
	 * node is used repeatedly to create PlanState for each EXECUTE statement.
	 *
	 * We do this before deparsing SELECT clause because attributes which
	 * aren't used in neither reltargetlist nor baserel->baserestrictinfo,
	 * quals evaluated on local, can be replaced with NULL in the SELECT
	 * clause.
	 */
	if (baserel->baserestrictinfo)
	{
		List	   *local_qual = NIL;
		ListCell   *lc;

		/*
		 * Divide qual of PlanState into two lists, one for local evaluation
		 * and one for foreign evaluation.
		 */
		foreach (lc, baserel->baserestrictinfo)
		{
			RestrictInfo *ri = (RestrictInfo *) lfirst(lc);

			if (is_foreign_qual(root, baserel, table, ri->clause))
			{
				/* XXX: deparse and add to sql here */
				foreign_expr = lappend(foreign_expr, ri->clause);
			}
			else
				local_qual = lappend(local_qual, ri);
		}
		/*
		 * XXX: If the remote side is not reliable enough, we can keep the qual
		 * in PlanState as is and evaluate them on local side too.  If so, just
		 * omit replacement below.
		 */
		baserel->baserestrictinfo = local_qual;

	}

	/* Collect used columns from restrict information and target list */
	attr_used = list_union(attr_used, baserel->reltargetlist);
	foreach (lc, baserel->baserestrictinfo)
	{
		List		   *l;
		RestrictInfo   *ri = lfirst(lc);

		l = pull_var_clause((Node *) ri->clause, PVC_RECURSE_AGGREGATES, PVC_RECURSE_PLACEHOLDERS);
		attr_used = list_union(attr_used, l);
	}

	/* deparse SELECT target list */
	appendStringInfoString(&sql, "SELECT ");
	first = true;
	rte = planner_rt_fetch(baserel->relid, root);
	for (attr = 1; attr <= baserel->max_attr; attr++)
	{
		Var *var = NULL;

		if (get_rte_attribute_is_dropped(rte, attr))
			continue;

		if (!first)
			appendStringInfoString(&sql, ", ");
		first = false;

		/* Use "NULL" for unused columns. */
		foreach (lc, attr_used)
		{
			var = lfirst(lc);
			if (var->varattno == attr)
				break;
			var = NULL;
		}

		if (var != NULL)
			deparse_var(root, &sql, var);
		else
			appendStringInfo(&sql, "NULL");
	}

	/*
	 * Deparse FROM
	 *
	 * If the foreign table has generic option "nspname" and/or "relname", use
	 * them in the foreign query.  Otherwise, use local catalog names.
	 */
	foreach(lc, table->options)
	{
		DefElem *opt = lfirst(lc);
		if (strcmp(opt->defname, "nspname") == 0)
			nspname = pstrdup(strVal(opt->arg));
		else if (strcmp(opt->defname, "relname") == 0)
			relname = pstrdup(strVal(opt->arg));
	}
	if (nspname == NULL)
		nspname = get_namespace_name(get_rel_namespace(foreigntableid));
	if (relname == NULL)
		relname = get_rel_name(foreigntableid);
	appendStringInfo(&sql, " FROM %s.%s",
					 ora_quote_identifier(nspname),
					 ora_quote_identifier(relname));

	/*
	 * deparse WHERE if some quals can be pushed down
	 */
	if (foreign_expr != NIL)
	{
		Node   *node;
		node = (Node *) make_ands_explicit(foreign_expr);
		appendStringInfo(&sql, " WHERE %s",
			ora_deparse_expression(node, context, false, false));

		/*
		 * The contents of the list MUST NOT be free-ed because they are
		 * referenced from Plan.qual list.
		 */
		list_free(foreign_expr);
	}

	elog(DEBUG1, "deparsed SQL is \"%s\"", sql.data);

	return sql.data;
}

static const char hextbl[] = "0123456789ABCDEF";

/*
 * Given internal format bytea, convert to binary literals of the Oracle.
 */
void
deparseBytea(StringInfo buf, Datum val)
{
	bytea  *vlena = DatumGetByteaPP(val);
	char   *src;
	int		len;
	int		i;


	src = VARDATA_ANY(vlena);
	len = VARSIZE_ANY_EXHDR(vlena);

	/* the binary data is represented in hexadecimal form. */
	appendStringInfoChar(buf, '\'');
	for (i = 0; i < len; i++)
	{
		appendStringInfoChar(buf, hextbl[(*src >> 4) & 0xF]);
		appendStringInfoChar(buf, hextbl[*src & 0xF]);
		src++;
	}
	appendStringInfoChar(buf, '\'');
}

/*
 * Given internal format interval, convert to interval literals of the Oracle.
 */
void
deparseInterval(StringInfo buf, Datum val)
{
	Interval   *span = DatumGetIntervalP(val);
	struct pg_tm tt,
			   *tm = &tt;
	fsec_t		fsec;
	char		i_buf[MAXDATELEN + 1];

	if (interval2tm(*span, tm, &fsec) != 0)
		elog(ERROR, "could not convert interval to tm");

	if (tm->tm_hour >= 24 || tm->tm_hour <= -24)
	{
		tm->tm_mday += tm->tm_hour / 24;
		tm->tm_hour = tm->tm_hour % 24;
	}

	EncodeInterval(tm, fsec, INTSTYLE_SQL_STANDARD, i_buf);

	if ((!HAS_NEGATIVE(tm, fsec) && !HAS_POSITIVE(tm, fsec)) ||
		!SQL_STANDARD_VALUE(tm, fsec))
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
				 errmsg("invalid input syntax for interval of the Oracle: \"%s\"",
						i_buf)));

	appendStringInfo(buf, "INTERVAL '%s' ", i_buf);
	if (HAS_YEAR_MONTH(tm))
		appendStringInfo(buf, "YEAR(9) TO MONTH");
	else if (HAS_DAY(tm))
		appendStringInfo(buf, "DAY(9) TO SECOND(6)");
	else
		appendStringInfo(buf, "HOUR TO SECOND(6)");
}

/*
 * Convert reserved date values to string.
 */
static void
EncodeSpecialDate(DateADT dt, char *str)
{
	if (DATE_IS_NOBEGIN(dt))
		strcpy(str, EARLY);
	else if (DATE_IS_NOEND(dt))
		strcpy(str, LATE);
	else	/* shouldn't happen */
		elog(ERROR, "invalid argument for EncodeSpecialDate");
}

/*
 * Given internal format bytea, convert to binary literals of the Oracle.
 */
void
deparseDate(StringInfo buf, Datum val)
{
	DateADT		date = DatumGetDateADT(val);
	struct pg_tm tt,
			   *tm = &tt;
	char		d_buf[MAXDATELEN + 1];

	if (DATE_NOT_FINITE(date))
	{
		EncodeSpecialDate(date, d_buf);
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
				 errmsg("invalid input syntax for date of the Oracle: \"%s\"",
						d_buf)));
	}

	j2date(date + POSTGRES_EPOCH_JDATE,
		   &(tm->tm_year), &(tm->tm_mon), &(tm->tm_mday));
	EncodeDateOnly(tm, USE_ISO_DATES, d_buf);

	appendStringInfo(buf, "TO_DATE('%s', 'YYYY-MM-DD", d_buf);

	if (tm->tm_year <= 0)
		appendStringInfo(buf, " BC");

	appendStringInfo(buf, "')");
}

void
deparseTimestamp(StringInfo buf, Datum val)
{
	text	   *fmt = cstring_to_text("YYYY-MM-DD BC HH24:MI:SS.US");
	text	   *res;
	char	   *str;

	res = DatumGetTextP(DirectFunctionCall2(timestamp_to_char, val,
											PointerGetDatum(fmt)));
	str = text_to_cstring(res);
	appendStringInfo(buf,
		"TO_TIMESTAMP('%s', 'YYYY-MM-DD BC HH24:MI:SS.FF6')",
		str);
}

void
deparseTimestamptz(StringInfo buf, Datum val)
{
	text	   *fmt = cstring_to_text("YYYY-MM-DD BC HH24:MI:SS.US");
	text	   *res;
	char	   *str;

	res = DatumGetTextP(DirectFunctionCall2(timestamptz_to_char, val,
											PointerGetDatum(fmt)));
	str = text_to_cstring(res);
	appendStringInfo(buf,
		"TO_TIMESTAMP_TZ('%s %s', 'YYYY-MM-DD BC HH24:MI:SS.FF6 TZR')",
		str, show_timezone());
}
