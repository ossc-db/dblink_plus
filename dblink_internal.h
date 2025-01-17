/*
 * dblink_internal.h
 *
 * Copyright (c) 2025, NIPPON TELEGRAPH AND TELEPHONE CORPORATION
 */
#ifndef DBLINK_INTERNAL_H
#define DBLINK_INTERNAL_H

#ifdef ENABLE_MYSQL
extern dblink_connection *mylink_connect(
	const char *user,
	const char *password,
	const char *dbname,
	const char *host,
	int port);
#endif

#ifdef ENABLE_ORACLE
extern dblink_connection *oralink_connect(
	const char *user,
	const char *password,
	const char *dbname,
	int max_value_len);
#endif

#ifdef ENABLE_SQLITE3
extern dblink_connection *sq3link_connect(
	const char *location);
#endif

#endif   /* DBLINK_INTERNAL_H */
