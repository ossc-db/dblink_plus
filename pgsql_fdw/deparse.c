/*-------------------------------------------------------------------------
 *
 * deparse.c
 *		  query deparser for PostgreSQL
 *
 * Copyright (c) 2011-2012, NIPPON TELEGRAPH AND TELEPHONE CORPORATION
 *
 * IDENTIFICATION
 *		  pgsql_fdw/deparse.c
 *
 *-------------------------------------------------------------------------
 */
#include "postgres.h"

#include "access/transam.h"
#include "catalog/pg_class.h"
#include "catalog/pg_operator.h"
#include "catalog/pg_type.h"
#include "commands/defrem.h"
#include "foreign/foreign.h"
#include "lib/stringinfo.h"
#include "nodes/nodeFuncs.h"
#include "nodes/nodes.h"
#include "nodes/makefuncs.h"
#include "optimizer/clauses.h"
#include "optimizer/var.h"
#include "parser/parser.h"
#include "parser/parsetree.h"
#include "utils/builtins.h"
#include "utils/lsyscache.h"
#include "utils/rel.h"
#include "utils/syscache.h"

#include "pgsql_fdw.h"

/*
 * Context for walk-through the expression tree.
 */
typedef struct foreign_executable_cxt
{
	PlannerInfo	   *root;
	RelOptInfo	   *foreignrel;
	bool			has_param;
} foreign_executable_cxt;

/*
 * Get string representation which can be used in SQL statement from a node.
 */
static void deparseExpr(StringInfo buf, Expr *expr, PlannerInfo *root);
static void deparseRelation(StringInfo buf, Oid relid, PlannerInfo *root,
							bool need_prefix);
static void deparseVar(StringInfo buf, Var *node, PlannerInfo *root,
					   bool need_prefix);
static void deparseConst(StringInfo buf, Const *node, PlannerInfo *root);
static void deparseBoolExpr(StringInfo buf, BoolExpr *node, PlannerInfo *root);
static void deparseNullTest(StringInfo buf, NullTest *node, PlannerInfo *root);
static void deparseDistinctExpr(StringInfo buf, DistinctExpr *node,
								PlannerInfo *root);
static void deparseRelabelType(StringInfo buf, RelabelType *node,
							   PlannerInfo *root);
static void deparseFuncExpr(StringInfo buf, FuncExpr *node, PlannerInfo *root);
static void deparseParam(StringInfo buf, Param *node, PlannerInfo *root);
static void deparseScalarArrayOpExpr(StringInfo buf, ScalarArrayOpExpr *node,
									 PlannerInfo *root);
static void deparseOpExpr(StringInfo buf, OpExpr *node, PlannerInfo *root);
static void deparseArrayRef(StringInfo buf, ArrayRef *node, PlannerInfo *root);
static void deparseArrayExpr(StringInfo buf, ArrayExpr *node, PlannerInfo *root);

/*
 * Determine whether an expression can be evaluated on remote side safely.
 */
static bool is_foreign_expr(PlannerInfo *root, RelOptInfo *baserel, Expr *expr,
							bool *has_param);
static bool foreign_expr_walker(Node *node, foreign_executable_cxt *context);
static bool is_builtin(Oid procid);

/*
 * Deparse query representation into SQL statement which suits for remote
 * PostgreSQL server.  This function basically creates simple query string
 * which consists of only SELECT, FROM clauses.
 */
void
deparseSimpleSql(StringInfo buf,
				 Oid relid,
			     PlannerInfo *root,
			     RelOptInfo *baserel)
{
	StringInfoData	foreign_relname;
	bool		first;
	AttrNumber	attr;
	List	   *attr_used = NIL;	/* List of AttNumber used in the query */

	initStringInfo(buf);
	initStringInfo(&foreign_relname);

	/*
	 * First of all, determine which column should be retrieved for this scan.
	 *
	 * We do this before deparsing SELECT clause because attributes which are
	 * not used in neither reltargetlist nor baserel->baserestrictinfo, quals
	 * evaluated on local, can be replaced with literal "NULL" in the SELECT
	 * clause to reduce overhead of tuple handling tuple and data transfer.
	 */
	if (baserel->baserestrictinfo != NIL)
	{
		ListCell   *lc;

		foreach (lc, baserel->baserestrictinfo)
		{
			RestrictInfo   *ri = (RestrictInfo *) lfirst(lc);
			List		   *attrs;

			/*
			 * We need to know which attributes are used in qual evaluated
			 * on the local server, because they should be listed in the
			 * SELECT clause of remote query.  We can ignore attributes
			 * which are referenced only in ORDER BY/GROUP BY clause because
			 * such attributes has already been kept in reltargetlist.
			 */
			attrs = pull_var_clause((Node *) ri->clause,
									PVC_RECURSE_AGGREGATES,
									PVC_RECURSE_PLACEHOLDERS);
			attr_used = list_union(attr_used, attrs);
		}
	}

	/*
	 * deparse SELECT clause
	 *
	 * List attributes which are in either target list or local restriction.
	 * Unused attributes are replaced with a literal "NULL" for optimization.
	 *
	 * Note that nothing is added for dropped columns, though tuple constructor
	 * function requires entries for dropped columns.  Such entries must be
	 * initialized with NULL before calling tuple constructor.
	 */
	appendStringInfo(buf, "SELECT ");
	attr_used = list_union(attr_used, baserel->reltargetlist);
	first = true;
	for (attr = 1; attr <= baserel->max_attr; attr++)
	{
		RangeTblEntry *rte = root->simple_rte_array[baserel->relid];
		Var		   *var = NULL;
		ListCell   *lc;

		/* Ignore dropped attributes. */
		if (get_rte_attribute_is_dropped(rte, attr))
			continue;

		if (!first)
			appendStringInfo(buf, ", ");
		first = false;

		/*
		 * We use linear search here, but it wouldn't be problem since
		 * attr_used seems to not become so large.
		 */
		foreach (lc, attr_used)
		{
			var = lfirst(lc);
			if (var->varattno == attr)
				break;
			var = NULL;
		}
		if (var != NULL)
			deparseVar(buf, var, root, false);
		else
			appendStringInfo(buf, "NULL");
	}
	appendStringInfoChar(buf, ' ');

	/*
	 * deparse FROM clause, including alias if any
	 */
	appendStringInfo(buf, "FROM ");
	deparseRelation(buf, relid, root, true);

	elog(DEBUG3, "Remote SQL: %s", buf->data);
}

/*
 * Examine each element in the list baserestrictinfo of baserel, and sort them
 * into three groups: remote_conds contains conditions which can be evaluated
 *   - remote_conds is push-down safe, and don't contain any Param node
 *   - param_conds is push-down safe, but contain some Param node
 *   - local_conds is not push-down safe
 *
 * Only remote_conds can be used in remote EXPLAIN, and remote_conds and
 * param_conds can be used in final remote query.
 */
void
sortConditions(PlannerInfo *root,
				   RelOptInfo *baserel,
				   List **remote_conds,
				   List **param_conds,
				   List **local_conds)
{
	ListCell	   *lc;
	bool			has_param;

	Assert(remote_conds);
	Assert(param_conds);
	Assert(local_conds);

	foreach(lc, baserel->baserestrictinfo)
	{
		RestrictInfo *ri = (RestrictInfo *) lfirst(lc);

		if (is_foreign_expr(root, baserel, ri->clause, &has_param))
		{
			if (has_param)
				*param_conds = lappend(*param_conds, ri);
			else
				*remote_conds = lappend(*remote_conds, ri);
		}
		else
			*local_conds = lappend(*local_conds, ri);
	}
}

/*
 * Deparse given expression into buf.  Actual string operation is delegated to
 * node-type-specific functions.
 *
 * Note that switch statement of this function MUST match the one in
 * foreign_expr_walker to avoid unsupported error..
 */
static void
deparseExpr(StringInfo buf, Expr *node, PlannerInfo *root)
{
	/*
	 * This part must be match foreign_expr_walker.
	 */
	switch (nodeTag(node))
	{
		case T_Const:
			deparseConst(buf, (Const *) node, root);
			break;
		case T_BoolExpr:
			deparseBoolExpr(buf, (BoolExpr *) node, root);
			break;
		case T_NullTest:
			deparseNullTest(buf, (NullTest *) node, root);
			break;
		case T_DistinctExpr:
			deparseDistinctExpr(buf, (DistinctExpr *) node, root);
			break;
		case T_RelabelType:
			deparseRelabelType(buf, (RelabelType *) node, root);
			break;
		case T_FuncExpr:
			deparseFuncExpr(buf, (FuncExpr *) node, root);
			break;
		case T_Param:
			deparseParam(buf, (Param *) node, root);
			break;
		case T_ScalarArrayOpExpr:
			deparseScalarArrayOpExpr(buf, (ScalarArrayOpExpr *) node, root);
			break;
		case T_OpExpr:
			deparseOpExpr(buf, (OpExpr *) node, root);
			break;
		case T_Var:
			deparseVar(buf, (Var *) node, root, false);
			break;
		case T_ArrayRef:
			deparseArrayRef(buf, (ArrayRef *) node, root);
			break;
		case T_ArrayExpr:
			deparseArrayExpr(buf, (ArrayExpr *) node, root);
			break;
		default:
			{
				ereport(ERROR,
						(errmsg("unsupported expression for deparse"),
						 errdetail("%s", nodeToString(node))));
			}
			break;
	}
}

/*
 * Deparse node into buf, with relation qualifier if need_prefix was true.  If
 * node is a column of a foreign table, use value of colname FDW option (if any)
 * instead of attribute name.
 */
static void
deparseVar(StringInfo buf,
		   Var *node,
		   PlannerInfo *root,
		   bool need_prefix)
{
	RangeTblEntry  *rte;
	char		   *colname = NULL;
	const char	   *q_colname = NULL;

	/* node must not be any of OUTER_VAR,INNER_VAR and INDEX_VAR. */
	Assert(node->varno >= 1 && node->varno <= root->simple_rel_array_size);

	/* Get RangeTblEntry from array in PlannerInfo. */
	rte = root->simple_rte_array[node->varno];

/* per-column FDW option is not supported before 9.2. */
#if PG_VERSION_NUM >= 90200
	/*
	 * If the node is a column of a foreign table, and it has colname FDW
	 * option, use its value.
	 */
	if (rte->relkind == RELKIND_FOREIGN_TABLE)
	{
		List		   *options;
		ListCell	   *lc;

		options = GetForeignColumnOptions(rte->relid, node->varattno);
		foreach(lc, options)
		{
			DefElem	   *def = (DefElem *) lfirst(lc);

			if (strcmp(def->defname, "colname") == 0)
			{
				colname = defGetString(def);
				break;
			}
		}
	}
#endif

	/*
	 * If the node refers a column of a regular table or it doesn't have colname
	 * FDW option, use attribute name.
	 */
	if (colname == NULL)
		colname = get_attname(rte->relid, node->varattno);

	if (need_prefix)
	{
		char *aliasname;
		const char *q_aliasname;

		if (rte->eref != NULL && rte->eref->aliasname != NULL)
			aliasname = rte->eref->aliasname;
		else if (rte->alias != NULL && rte->alias->aliasname != NULL)
			aliasname = rte->alias->aliasname;

		q_aliasname = quote_identifier(aliasname);
		appendStringInfo(buf, "%s.", q_aliasname);
	}

	q_colname = quote_identifier(colname);
	appendStringInfo(buf, "%s", q_colname);
}

/*
 * Deparse table which has relid as oid into buf, with schema qualifier if
 * need_prefix was true.  If relid points a foreign table, use value of relname
 * FDW option (if any) instead of relation's name.  Similarly, nspname FDW
 * option overrides schema name.
 */
static void
deparseRelation(StringInfo buf,
				Oid relid,
				PlannerInfo *root,
				bool need_prefix)
{
	int			i;
	RangeTblEntry *rte = NULL;
	ListCell   *lc;
	const char *nspname = NULL;		/* plain namespace name */
	const char *relname = NULL;		/* plain relation name */
	const char *q_nspname;			/* quoted namespace name */
	const char *q_relname;			/* quoted relation name */

	/* Find RangeTblEntry for the relation from PlannerInfo. */
	for (i = 1; i < root->simple_rel_array_size; i++)
	{
		if (root->simple_rte_array[i]->relid == relid)
		{
			rte = root->simple_rte_array[i];
			break;
		}
	}
	if (rte == NULL)
		elog(ERROR, "relation with OID %u is not used in the query", relid);

	/* If target is a foreign table, obtain additional catalog information. */
	if (rte->relkind == RELKIND_FOREIGN_TABLE)
	{
		ForeignTable *table = GetForeignTable(rte->relid);

		/*
		 * Use value of FDW options if any, instead of the name of object
		 * itself.
		 */
		foreach(lc, table->options)
		{
			DefElem	   *def = (DefElem *) lfirst(lc);

			if (need_prefix && strcmp(def->defname, "nspname") == 0)
				nspname = defGetString(def);
			else if (strcmp(def->defname, "relname") == 0)
				relname = defGetString(def);
		}
	}

	/* Quote each identifier, if necessary. */
	if (need_prefix)
	{
		if (nspname == NULL)
			nspname = get_namespace_name(get_rel_namespace(relid));
		q_nspname = quote_identifier(nspname);
	}

	if (relname == NULL)
		relname = get_rel_name(relid);
	q_relname = quote_identifier(relname);

	/* Construct relation reference into the buffer. */
	if (need_prefix)
		appendStringInfo(buf, "%s.", q_nspname);
	appendStringInfo(buf, "%s", q_relname);
}

/*
 * Deparse given constant value into buf.  This function have to be kept in
 * sync with get_const_expr.
 */
static void
deparseConst(StringInfo buf,
			 Const *node,
			 PlannerInfo *root)
{
	Oid			typoutput;
	bool		typIsVarlena;
	char	   *extval;
	bool		isfloat = false;
	bool		needlabel;

	if (node->constisnull)
	{
		appendStringInfo(buf, "NULL");
		return;
	}

	getTypeOutputInfo(node->consttype,
					  &typoutput, &typIsVarlena);
	extval = OidOutputFunctionCall(typoutput, node->constvalue);

	switch (node->consttype)
	{
		case ANYARRAYOID:
		case ANYNONARRAYOID:
			elog(ERROR, "anyarray and anyenum are not supported");
			break;
		case INT2OID:
		case INT4OID:
		case INT8OID:
		case OIDOID:
		case FLOAT4OID:
		case FLOAT8OID:
		case NUMERICOID:
			{
				/*
				 * No need to quote unless they contain special values such as
				 * 'Nan'.
				 */
				if (strspn(extval, "0123456789+-eE.") == strlen(extval))
				{
					if (extval[0] == '+' || extval[0] == '-')
						appendStringInfo(buf, "(%s)", extval);
					else
						appendStringInfoString(buf, extval);
					if (strcspn(extval, "eE.") != strlen(extval))
						isfloat = true;	/* it looks like a float */
				}
				else
					appendStringInfo(buf, "'%s'", extval);
			}
			break;
		case BITOID:
		case VARBITOID:
			appendStringInfo(buf, "B'%s'", extval);
			break;
		case BOOLOID:
			if (strcmp(extval, "t") == 0)
				appendStringInfoString(buf, "true");
			else
				appendStringInfoString(buf, "false");
			break;

		default:
			{
				const char *valptr;

				appendStringInfoChar(buf, '\'');
				for (valptr = extval; *valptr; valptr++)
				{
					char		ch = *valptr;

					/*
					 * standard_conforming_strings of remote session should be
					 * set to similar value as local session.
					 */
					if (SQL_STR_DOUBLE(ch, !standard_conforming_strings))
						appendStringInfoChar(buf, ch);
					appendStringInfoChar(buf, ch);
				}
				appendStringInfoChar(buf, '\'');
			}
			break;
	}

	/*
	 * Append ::typename unless the constant will be implicitly typed as the
	 * right type when it is read in.
	 *
	 * XXX this code has to be kept in sync with the behavior of the parser,
	 * especially make_const.
	 */
	switch (node->consttype)
	{
		case BOOLOID:
		case INT4OID:
		case UNKNOWNOID:
			needlabel = false;
			break;
		case NUMERICOID:
			needlabel = !isfloat || (node->consttypmod >= 0);
			break;
		default:
			needlabel = true;
			break;
	}
	if (needlabel)
	{
		appendStringInfo(buf, "::%s",
						 format_type_with_typemod(node->consttype,
												  node->consttypmod));
	}
}

static void
deparseBoolExpr(StringInfo buf,
				BoolExpr *node,
				PlannerInfo *root)
{
	ListCell   *lc;
	char	   *op = NULL;
	bool		first;

	switch (node->boolop)
	{
		case AND_EXPR:
			op = "AND";
			break;
		case OR_EXPR:
			op = "OR";
			break;
		case NOT_EXPR:
			appendStringInfo(buf, "(NOT ");
			deparseExpr(buf, list_nth(node->args, 0), root);
			appendStringInfo(buf, ")");
			return;
	}
	Assert(op != NULL);

	first = true;
	appendStringInfo(buf, "(");
	foreach(lc, node->args)
	{
		if (!first)
			appendStringInfo(buf, " %s ", op);
		deparseExpr(buf, (Expr *) lfirst(lc), root);
		first = false;
	}
	appendStringInfo(buf, ")");
}

/*
 * Deparse given IS [NOT] NULL test expression into buf.
 */
static void
deparseNullTest(StringInfo buf,
				NullTest *node,
				PlannerInfo *root)
{
	appendStringInfoChar(buf, '(');
	deparseExpr(buf, node->arg, root);
	if (node->nulltesttype == IS_NULL)
		appendStringInfo(buf, " IS NULL)");
	else
		appendStringInfo(buf, " IS NOT NULL)");
}

static void
deparseDistinctExpr(StringInfo buf,
					DistinctExpr *node,
					PlannerInfo *root)
{
	Assert(list_length(node->args) == 2);

	deparseExpr(buf, linitial(node->args), root);
	appendStringInfo(buf, " IS DISTINCT FROM ");
	deparseExpr(buf, lsecond(node->args), root);
}

static void
deparseRelabelType(StringInfo buf,
				   RelabelType *node,
				   PlannerInfo *root)
{
	char	   *typname;

	Assert(node->arg);

	/* We don't need to deparse cast when argument has same type as result. */
	if (IsA(node->arg, Const) &&
		((Const *) node->arg)->consttype == node->resulttype &&
		((Const *) node->arg)->consttypmod == -1)
	{
		deparseExpr(buf, node->arg, root);
		return;
	}

	typname = format_type_with_typemod(node->resulttype, node->resulttypmod);
	appendStringInfoChar(buf, '(');
	deparseExpr(buf, node->arg, root);
	appendStringInfo(buf, ")::%s", typname);
}

/*
 * Deparse given node which represents a function call into buf.  We treat only
 * explicit function call and explicit cast (coerce), because others are
 * processed on remote side if necessary.
 *
 * Function name (and type name) is always qualified by schema name to avoid
 * problems caused by different setting of search_path on remote side.
 */
static void
deparseFuncExpr(StringInfo buf,
				FuncExpr *node,
				PlannerInfo *root)
{
	Oid				pronamespace;
	const char	   *schemaname;
	const char	   *funcname;
	ListCell	   *arg;
	bool			first;

	pronamespace = get_func_namespace(node->funcid);
	schemaname = quote_identifier(get_namespace_name(pronamespace));
	funcname = quote_identifier(get_func_name(node->funcid));

	if (node->funcformat == COERCE_EXPLICIT_CALL)
	{
		/* Function call, deparse all arguments recursively. */
		appendStringInfo(buf, "%s.%s(", schemaname, funcname);
		first = true;
		foreach(arg, node->args)
		{
			if (!first)
				appendStringInfo(buf, ", ");
			deparseExpr(buf, lfirst(arg), root);
			first = false;
		}
		appendStringInfoChar(buf, ')');
	}
	else if (node->funcformat == COERCE_EXPLICIT_CAST)
	{
		/* Explicit cast, deparse only first argument. */
		appendStringInfoChar(buf, '(');
		deparseExpr(buf, linitial(node->args), root);
		appendStringInfo(buf, ")::%s", funcname);
	}
	else
	{
		/* Implicit cast, deparse only first argument. */
		deparseExpr(buf, linitial(node->args), root);
	}
}

/*
 * Deparse given Param node into buf.
 *
 * We don't renumber parameter id, because skipping $1 is not cause problem
 * as far as we pass through all arguments.
 */
static void
deparseParam(StringInfo buf,
			 Param *node,
			 PlannerInfo *root)
{
	Assert(node->paramkind == PARAM_EXTERN);

	appendStringInfo(buf, "$%d", node->paramid);
}

/*
 * Deparse given ScalarArrayOpExpr expression into buf.  To avoid problems
 * around priority of operations, we always parenthesize the arguments.  Also we
 * use OPERATOR(schema.operator) notation to determine remote operator exactly.
 */
static void
deparseScalarArrayOpExpr(StringInfo buf,
						 ScalarArrayOpExpr *node,
						 PlannerInfo *root)
{
	HeapTuple	tuple;
	Form_pg_operator form;
	const char *opnspname;
	char	   *opname;
	Expr	   *arg1;
	Expr	   *arg2;

	/* Retrieve necessary information about the operator from system catalog. */
	tuple = SearchSysCache1(OPEROID, ObjectIdGetDatum(node->opno));
	if (!HeapTupleIsValid(tuple))
		elog(ERROR, "cache lookup failed for operator %u", node->opno);
	form = (Form_pg_operator) GETSTRUCT(tuple);
	/* opname is not a SQL identifier, so we don't need to quote it. */
	opname = NameStr(form->oprname);
	opnspname = quote_identifier(get_namespace_name(form->oprnamespace));
	ReleaseSysCache(tuple);

	/* Sanity check. */
	Assert(list_length(node->args) == 2);

	/* Always parenthesize the expression. */
	appendStringInfoChar(buf, '(');

	/* Extract operands. */
	arg1 = linitial(node->args);
	arg2 = lsecond(node->args);

	/* Deparse fully qualified operator name. */
	deparseExpr(buf, arg1, root);
	appendStringInfo(buf, " OPERATOR(%s.%s) %s (",
					 opnspname, opname, node->useOr ? "ANY" : "ALL");
	deparseExpr(buf, arg2, root);
	appendStringInfoChar(buf, ')');

	/* Always parenthesize the expression. */
	appendStringInfoChar(buf, ')');
}

/*
 * Deparse given operator expression into buf.  To avoid problems around
 * priority of operations, we always parenthesize the arguments.  Also we use
 * OPERATOR(schema.operator) notation to determine remote operator exactly.
 */
static void
deparseOpExpr(StringInfo buf,
			  OpExpr *node,
			  PlannerInfo *root)
{
	HeapTuple	tuple;
	Form_pg_operator form;
	const char *opnspname;
	char	   *opname;
	char		oprkind;
	ListCell   *arg;

	/* Retrieve necessary information about the operator from system catalog. */
	tuple = SearchSysCache1(OPEROID, ObjectIdGetDatum(node->opno));
	if (!HeapTupleIsValid(tuple))
		elog(ERROR, "cache lookup failed for operator %u", node->opno);
	form = (Form_pg_operator) GETSTRUCT(tuple);
	opnspname = quote_identifier(get_namespace_name(form->oprnamespace));
	/* opname is not a SQL identifier, so we don't need to quote it. */
	opname = NameStr(form->oprname);
	oprkind = form->oprkind;
	ReleaseSysCache(tuple);

	/* Sanity check. */
	Assert((oprkind == 'r' && list_length(node->args) == 1) ||
		   (oprkind == 'l' && list_length(node->args) == 1) ||
		   (oprkind == 'b' && list_length(node->args) == 2));

	/* Always parenthesize the expression. */
	appendStringInfoChar(buf, '(');

	/* Deparse first operand. */
	arg = list_head(node->args);
	if (oprkind == 'r' || oprkind == 'b')
	{
		deparseExpr(buf, lfirst(arg), root);
		appendStringInfoChar(buf, ' ');
	}

	/* Deparse fully qualified operator name. */
	appendStringInfo(buf, "OPERATOR(%s.%s)", opnspname, opname);

	/* Deparse last operand. */
	arg = list_tail(node->args);
	if (oprkind == 'l' || oprkind == 'b')
	{
		appendStringInfoChar(buf, ' ');
		deparseExpr(buf, lfirst(arg), root);
	}

	appendStringInfoChar(buf, ')');
}

static void
deparseArrayRef(StringInfo buf,
				ArrayRef *node,
				PlannerInfo *root)
{
	ListCell	   *lowlist_item;
	ListCell	   *uplist_item;

	/* Always parenthesize the expression. */
	appendStringInfoChar(buf, '(');

	/* Deparse referenced array expression first. */
	appendStringInfoChar(buf, '(');
	deparseExpr(buf, node->refexpr, root);
	appendStringInfoChar(buf, ')');

	/* Deparse subscripts expression. */
	lowlist_item = list_head(node->reflowerindexpr);	/* could be NULL */
	foreach(uplist_item, node->refupperindexpr)
	{
		appendStringInfoChar(buf, '[');
		if (lowlist_item)
		{
			deparseExpr(buf, lfirst(lowlist_item), root);
			appendStringInfoChar(buf, ':');
			lowlist_item = lnext(lowlist_item);
		}
		deparseExpr(buf, lfirst(uplist_item), root);
		appendStringInfoChar(buf, ']');
	}

	appendStringInfoChar(buf, ')');
}


/*
 * Deparse given array of something into buf.
 */
static void
deparseArrayExpr(StringInfo buf,
				 ArrayExpr *node,
				 PlannerInfo *root)
{
	ListCell	   *lc;
	bool			first = true;

	appendStringInfo(buf, "ARRAY[");
	foreach(lc, node->elements)
	{
		if (!first)
			appendStringInfo(buf, ", ");
		deparseExpr(buf, lfirst(lc), root);

		first = false;
	}
	appendStringInfoChar(buf, ']');

	/* If the array is empty, we need explicit cast to the array type. */
	if (node->elements == NIL)
	{
		char	   *typname;

		typname = format_type_with_typemod(node->array_typeid, -1);
		appendStringInfo(buf, "::%s", typname);
	}
}

/*
 * Returns true if given expr is safe to evaluate on the foreign server.  If
 * result is true, extra information has_param tells whether given expression
 * contains any Param node.  This is useful to determine whether the expression
 * can be used in remote EXPLAIN.
 */
static bool
is_foreign_expr(PlannerInfo *root,
				RelOptInfo *baserel,
				Expr *expr,
				bool *has_param)
{
	foreign_executable_cxt	context;
	context.root = root;
	context.foreignrel = baserel;
	context.has_param = false;

	/*
	 * An expression which includes any mutable function can't be pushed down
	 * because it's result is not stable.  For example, pushing now() down to
	 * remote side would cause confusion from the clock offset.
	 * If we have routine mapping infrastructure in future release, we will be
	 * able to choose function to be pushed down in finer granularity.
	 */
	if (contain_mutable_functions((Node *) expr))
		return false;

	/*
	 * Check that the expression consists of nodes which are known as safe to
	 * be pushed down.
	 */
	if (foreign_expr_walker((Node *) expr, &context))
		return false;

	/*
	 * Tell caller whether the given expression contains any Param node, which
	 * can't be used in EXPLAIN statement before executor starts.
	 */
	*has_param = context.has_param;

	return true;
}

/*
 * Return true if node includes any node which is not known as safe to be
 * pushed down.
 */
static bool
foreign_expr_walker(Node *node, foreign_executable_cxt *context)
{
	if (node == NULL)
		return false;

	/*
	 * Special case handling for List; expression_tree_walker handles List as
	 * well as other Expr nodes.  For instance, List is used in RestrictInfo
	 * for args of FuncExpr node.
	 *
	 * Although the comments of expression_tree_walker mention that
	 * RangeTblRef, FromExpr, JoinExpr, and SetOperationStmt are handled as
	 * well, but we don't care them because they are not used in RestrictInfo.
	 * If one of them was passed into, default label catches it and give up
	 * traversing.
	 */
	if (IsA(node, List))
	{
		ListCell	   *lc;

		foreach(lc, (List *) node)
		{
			if (foreign_expr_walker(lfirst(lc), context))
				return true;
		}
		return false;
	}

	/*
	 * If return type of given expression is not built-in, it can't be pushed
	 * down because it might has incompatible semantics on remote side.
	 */
	if (!is_builtin(exprType(node)))
		return true;

	switch (nodeTag(node))
	{
		case T_Const:
			/*
			 * Using anyarray and/or anyenum in remote query is not supported.
			 */
			if (((Const *) node)->consttype == ANYARRAYOID ||
				((Const *) node)->consttype == ANYNONARRAYOID)
				return true;
			break;
		case T_BoolExpr:
		case T_NullTest:
		case T_DistinctExpr:
		case T_RelabelType:
			/*
			 * These type of nodes are known as safe to be pushed down.
			 * Of course the subtree of the node, if any, should be checked
			 * continuously at the tail of this function.
			 */
			break;
		/*
		 * If function used by the expression is not built-in, it can't be
		 * pushed down because it might has incompatible semantics on remote
		 * side.
		 */
		case T_FuncExpr:
			{
				FuncExpr	   *fe = (FuncExpr *) node;
				if (!is_builtin(fe->funcid))
					return true;
			}
			break;
		case T_Param:
			/*
			 * Only external parameters can be pushed down.:
			 */
			{
				if (((Param *) node)->paramkind != PARAM_EXTERN)
					return true;

				/* Mark that this expression contains Param node. */
				context->has_param = true;
			}
			break;
		case T_ScalarArrayOpExpr:
			/*
			 * Only built-in operators can be pushed down.  In addition,
			 * underlying function must be built-in and immutable, but we don't
			 * check volatility here; such check must be done already with
			 * contain_mutable_functions.
			 */
			{
				ScalarArrayOpExpr   *oe = (ScalarArrayOpExpr *) node;

				if (!is_builtin(oe->opno) || !is_builtin(oe->opfuncid))
					return true;

				/*
				 * If the operator takes collatable type as operands, we push
				 * down only "=" and "<>" which are not affected by collation.
				 * Other operators might be safe about collation, but these two
				 * seem enough to cover practical use cases.
				 */
				if (exprInputCollation(node) != InvalidOid)
				{
					char   *opname = get_opname(oe->opno);

					if (strcmp(opname, "=") != 0 && strcmp(opname, "<>") != 0)
						return true;
				}

				/* operands are checked later */
			}
			break;
		case T_OpExpr:
			/*
			 * Only built-in operators can be pushed down.  In addition,
			 * underlying function must be built-in and immutable, but we don't
			 * check volatility here; such check must be done already with
			 * contain_mutable_functions.
			 */
			{
				OpExpr	   *oe = (OpExpr *) node;

				if (!is_builtin(oe->opno) || !is_builtin(oe->opfuncid))
					return true;

				/*
				 * If the operator takes collatable type as operands, we push
				 * down only "=" and "<>" which are not affected by collation.
				 * Other operators might be safe about collation, but these two
				 * seem enough to cover practical use cases.
				 */
				if (exprInputCollation(node) != InvalidOid)
				{
					char   *opname = get_opname(oe->opno);

					if (strcmp(opname, "=") != 0 && strcmp(opname, "<>") != 0)
						return true;
				}

				/* operands are checked later */
			}
			break;
		case T_Var:
			/*
			 * Var can be pushed down if it is in the foreign table.
			 * XXX Var of other relation can be here?
			 */
			{
				Var	   *var = (Var *) node;
				foreign_executable_cxt *f_context;

				f_context = (foreign_executable_cxt *) context;
				if (var->varno != f_context->foreignrel->relid ||
					var->varlevelsup != 0)
					return true;
			}
			break;
		case T_ArrayRef:
			/*
			 * ArrayRef which holds non-built-in typed elements can't be pushed
			 * down.
			 */
			{
				ArrayRef	   *ar = (ArrayRef *) node;;

				if (!is_builtin(ar->refelemtype))
					return true;

				/* Assignment should not be in restrictions. */
				if (ar->refassgnexpr != NULL)
					return true;
			}
			break;
		case T_ArrayExpr:
			/*
			 * ArrayExpr which holds non-built-in typed elements can't be pushed
			 * down.
			 */
			{
				if (!is_builtin(((ArrayExpr *) node)->element_typeid))
					return true;
			}
			break;
		default:
			{
				ereport(DEBUG3,
						(errmsg("expression is too complex"),
						 errdetail("%s", nodeToString(node))));
				return true;
			}
			break;
	}

	return expression_tree_walker(node, foreign_expr_walker, context);
}

/*
 * Return true if given object is one of built-in objects.
 */
static bool
is_builtin(Oid oid)
{
	return (oid < FirstNormalObjectId);
}

/*
 * Deparse WHERE clause from given list of RestrictInfo and append them to buf.
 * We assume that buf already holds a SQL statement which ends with valid WHERE
 * clause.
 *
 * Only when calling the first time for a statement, is_first should be true.
 */
void
appendWhereClause(StringInfo buf,
				  bool is_first,
				  List *exprs,
				  PlannerInfo *root)
{
	bool			first = true;
	ListCell	   *lc;

	foreach(lc, exprs)
	{
		RestrictInfo   *ri = (RestrictInfo *) lfirst(lc);

		/* Connect expressions with "AND" and parenthesize whole condition. */
		if (is_first && first)
			appendStringInfo(buf, " WHERE ");
		else
			appendStringInfo(buf, " AND ");

		appendStringInfoChar(buf, '(');
		deparseExpr(buf, ri->clause, root);
		appendStringInfoChar(buf, ')');

		first = false;
	}
}
