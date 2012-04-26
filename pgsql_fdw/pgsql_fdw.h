/*-------------------------------------------------------------------------
 *
 * pgsql_fdw.h
 *		  foreign-data wrapper for remote PostgreSQL servers.
 *
 * Copyright (c) 2011-2012, NIPPON TELEGRAPH AND TELEPHONE CORPORATION
 *
 * IDENTIFICATION
 *		  pgsql_fdw/pgsql_fdw.h
 *
 *-------------------------------------------------------------------------
 */

#ifndef PGSQL_FDW_H
#define PGSQL_FDW_H

#include "postgres.h"
#include "nodes/relation.h"

/* in option.c */
int ExtractConnectionOptions(List *defelems,
							 const char **keywords,
							 const char **values);
char *GetFdwOptionValue(Oid relid, const char *optname);

/* in deparse.c */
char *deparseSql(Oid relid, PlannerInfo *root, RelOptInfo *baserel);

/* in ruleutils.c */
List *deparse_context_for_rtelist(List *rtable);
char *deparse_expression_pg(Node *expr, List *dpcontext, bool forceprefix,
							bool showimplicit);


#endif /* PGSQL_FDW_H */
