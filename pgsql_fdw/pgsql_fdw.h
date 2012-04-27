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
#include "lib/stringinfo.h"
#include "nodes/relation.h"
#include "utils/relcache.h"

/* in option.c */
int ExtractConnectionOptions(List *defelems,
							 const char **keywords,
							 const char **values);
char *GetFdwOptionValue(Oid relid, const char *optname);

/* in deparse.c */
void deparseSimpleSql(StringInfo buf,
					  Oid relid,
					  PlannerInfo *root,
					  RelOptInfo *baserel);
void appendWhereClause(StringInfo buf,
					   bool has_where,
					   List *exprs,
					   PlannerInfo *root);
void sortConditions(PlannerInfo *root,
					RelOptInfo *baserel,
					List **remote_conds,
					List **param_conds,
					List **local_conds);

#endif /* PGSQL_FDW_H */
