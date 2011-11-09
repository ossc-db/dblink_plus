/*-------------------------------------------------------------------------
 *
 * connection.h
 *		  Connection management for pgsql_fdw
 *
 * Copyright (c) 2011, NIPPON TELEGRAPH AND TELEPHONE CORPORATION
 *
 * IDENTIFICATION
 *		  pgsql_fdw/connection.h
 *
 *-------------------------------------------------------------------------
 */
#ifndef CONNECTION_H
#define CONNECTION_H

#include "foreign/foreign.h"
#include "libpq-fe.h"

/*
 * Connection management
 */
PGconn *GetConnection(ForeignServer *server, UserMapping *user);
void ReleaseConnection(PGconn *conn);

#endif /* CONNECTION_H */
