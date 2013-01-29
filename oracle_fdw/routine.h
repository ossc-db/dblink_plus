/*-------------------------------------------------------------------------
 *
 * routine.h
 *	  support for routine mappings.
 *
 * Copyright (c) 2011, NIPPON TELEGRAPH AND TELEPHONE CORPORATION
 *
 * IDENTIFICATION
 *		  contrib/oracle_fdw/routine.h
 *
 *-------------------------------------------------------------------------
 */
#ifndef ROUTINE_H
#define ROUTINE_H

#include "access/transam.h"
#include "nodes/pg_list.h"

#define RoutineMappingRelationId FirstNormalObjectId	

/* ----------------
 * routine mapping definition.
 * ----------------
 */
typedef struct RoutineMapping
{
	Oid			procid;		/* procedure Oid */
	Oid			serverid;		/* server Oid */
	List	   *options;		/* rmoptions as DefElem list */
} RoutineMapping;

extern RoutineMapping *GetRoutineMapping(Oid routineid, Oid serverid);

#endif   /* ROUTINE_H */
