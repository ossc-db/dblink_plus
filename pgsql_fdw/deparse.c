/*-------------------------------------------------------------------------
 *
 * deparse.c
 *		  query deparser for PostgreSQL
 *
 * Copyright (c) 2011, NIPPON TELEGRAPH AND TELEPHONE CORPORATION
 *
 * IDENTIFICATION
 *		  pgsql_fdw/deparse.c
 *
 *-------------------------------------------------------------------------
 */
#include "postgres.h"

#include "access/transam.h"
#include "foreign/foreign.h"
#include "lib/stringinfo.h"
#include "nodes/nodeFuncs.h"
#include "nodes/nodes.h"
#include "nodes/makefuncs.h"
#include "optimizer/clauses.h"
#include "optimizer/var.h"
#include "parser/parsetree.h"
#include "utils/builtins.h"
#include "utils/lsyscache.h"

#include "pgsql_fdw.h"

/*
 * Context for walk-through the expression tree.
 */
typedef struct foreign_executable_cxt
{
	PlannerInfo	   *root;
	RelOptInfo	   *foreignrel;
} foreign_executable_cxt;

static bool is_foreign_expr(PlannerInfo *root, RelOptInfo *baserel, Expr *expr);
static bool foreign_expr_walker(Node *node, foreign_executable_cxt *context);
static bool is_builtin(Oid procid);

/*
 * Deparse query representation into SQL statement which suits for remote
 * PostgreSQL server.  Also some of quals in WHERE clause will be pushed down
 * If they are safe to be evaluated on the remote side.
 */
char *
deparseSql(Oid relid, PlannerInfo *root, RelOptInfo *baserel)
{
	StringInfoData	foreign_relname;
	StringInfoData	sql;			/* builder for SQL statement */
	bool		first;
	AttrNumber	attr;
	List	   *attr_used = NIL;	/* List of AttNumber used in the query */
	const char *nspname = NULL;		/* plain namespace name */
	const char *relname = NULL;		/* plain relation name */
	const char *q_nspname;			/* quoted namespace name */
	const char *q_relname;			/* quoted relation name */
	List	   *foreign_expr = NIL;	/* list of Expr* evaluated on remote */
	int			i;
	List	   *rtable = NIL;
	List	   *context = NIL;

	initStringInfo(&sql);
	initStringInfo(&foreign_relname);

	/*
	 * First of all, determine which qual can be pushed down.
	 *
	 * The expressions which satisfy is_foreign_expr() are deparsed into WHERE
	 * clause of result SQL string, and they could be removed from PlanState
	 * to avoid duplicate evaluation at ExecScan().
	 *
	 * We never change the quals in the Plan node, because this execution might
	 * be for a PREPAREd statement, thus the quals in the Plan node might be
	 * reused to construct another PlanState for subsequent EXECUTE statement.
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

			/* Determine whether the qual can be pushed down or not. */
			if (is_foreign_expr(root, baserel, ri->clause))
				foreign_expr = lappend(foreign_expr, ri->clause);

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
	 * Determine foreign relation's qualified name.  This is necessary for
	 * FROM clause and SELECT clause.
	 */
	nspname = GetFdwOptionValue(relid, "nspname");
	if (nspname == NULL)
		nspname = get_namespace_name(get_rel_namespace(relid));
	q_nspname = quote_identifier(nspname);

	relname = GetFdwOptionValue(relid, "relname");
	if (relname == NULL)
		relname = get_rel_name(relid);
	q_relname = quote_identifier(relname);

	appendStringInfo(&foreign_relname, "%s.%s", q_nspname, q_relname);

	/*
	 * We need to replace aliasname and colnames of the target relation so that
	 * constructed remote query is valid.
	 * 
	 * Note that we skip first empty element of simple_rel_array.  See also
	 * comments of simple_rel_array and simple_rte_array for the rationale.
	 */
	for (i = 1; i < root->simple_rel_array_size; i++)
	{
		RangeTblEntry  *rte = copyObject(root->simple_rte_array[i]);
		List		   *newcolnames = NIL;

		if (i == baserel->relid)
		{
			/*
			 * Create new list of column names which is used to deparse remote
			 * query from specified names or local column names.  This list is
			 * used by deparse_expression_pg.
			 */
			for (attr = 1; attr <= baserel->max_attr; attr++)
			{
				char	   *colname;

				/* Ignore dropped attributes. */
				if (get_rte_attribute_is_dropped(rte, attr))
					continue;

				colname = strVal(list_nth(rte->eref->colnames, attr - 1));
				newcolnames = lappend(newcolnames, makeString(colname));
			}
			rte->alias = makeAlias(relname, newcolnames);
		}
		rtable = lappend(rtable, rte);
	}
	context = deparse_context_for_rtelist(rtable);

	/*
	 * deparse SELECT clause
	 *
	 * List attributes which are in either target list or local restriction.
	 * Unused attributes are replaced with a literal "NULL" for optimization.
	 */
	appendStringInfo(&sql, "SELECT ");
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
			appendStringInfo(&sql, ", ");
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
			appendStringInfo(&sql, "%s",
				deparse_expression_pg((Node *) var, context, false, false));
		else
			appendStringInfo(&sql, "NULL");
	}
	appendStringInfoChar(&sql, ' ');

	/*
	 * deparse FROM clause, including alias if any
	 */
	appendStringInfo(&sql, "FROM %s", foreign_relname.data);

	/*
	 * deparse WHERE clause
	 */
	if (foreign_expr != NIL)
	{
		Node	   *node;

		node = (Node *) make_ands_explicit(foreign_expr);
		appendStringInfo(&sql, " WHERE %s ",
			deparse_expression_pg(node, context, false, false));
		list_free(foreign_expr);
		foreign_expr = NIL;
	}

	elog(DEBUG3, "Remote SQL: %s", sql.data);
	return sql.data;
}

/*
 * Returns true if expr is safe to be evaluated on the foreign server.
 */
static bool
is_foreign_expr(PlannerInfo *root, RelOptInfo *baserel, Expr *expr)
{
	foreign_executable_cxt	context;
	context.root = root;
	context.foreignrel = baserel;

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

	switch (nodeTag(node))
	{
		case T_Const:
		case T_ArrayExpr:
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
		case T_Param:
			/*
			 * Only external parameters can be pushed down.:
			 */
			{
				if (((Param *) node)->paramkind != PARAM_EXTERN)
					return true;
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

				/* operands are checked later */
			}
			break;
		case T_FuncExpr:
			/*
			 * Only built-in functions can be pushed down.  In addition,
			 * functions must be immutable, but we don't check volatility here;
			 * such check must be done already with contain_mutable_functions.
			 */
			{
				FuncExpr   *fe = (FuncExpr *) node;

				if (!is_builtin(fe->funcid))
					return true;

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

