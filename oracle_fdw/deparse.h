/*
 * deparse.h
 *
 * contrib/postgresql_fdw/deparse.h
 * Copyright (c) 2011, PostgreSQL Global Development Group
 * ALL RIGHTS RESERVED;
 *
 */

#ifndef DEPARSE_H
#define DEPARSE_H

/*
 * deparse.c: deparsing query-tree into SQL statement
 */
char *deparseSql(Oid foreigntableid, PlannerInfo *root, RelOptInfo *baserel);
void deparseBytea(StringInfo buf, Datum val);
void deparseInterval(StringInfo buf, Datum val);
void deparseDate(StringInfo buf, Datum val);
void deparseTimestamp(StringInfo buf, Datum val);
void deparseTimestamptz(StringInfo buf, Datum val);

#endif   /* DEPARSE_H */
