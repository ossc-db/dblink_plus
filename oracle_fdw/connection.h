/*-------------------------------------------------------------------------
 *
 * connection.h
 *		  Connection management for oracle_fdw
 *
 * Copyright (c) 2011, NIPPON TELEGRAPH AND TELEPHONE CORPORATION
 *
 * IDENTIFICATION
 *		  contrib/oracle_fdw/connection.h
 *
 *-------------------------------------------------------------------------
 */
#ifndef CONNECTION_H
#define CONNECTION_H

#include "foreign/foreign.h"
#include "oracle_fdw.h"

/*
 * Connection management
 */
ORAconn *GetConnection(ForeignServer *server, UserMapping *user);
void ReleaseConnection(ORAconn *conn);

#endif /* CONNECTION_H */
