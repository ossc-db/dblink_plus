/*-------------------------------------------------------------------------
 *
 * routine.c
 *		  routine mapping management for oracle_fdw
 *
 * Copyright (c) 2011, NIPPON TELEGRAPH AND TELEPHONE CORPORATION
 *
 * IDENTIFICATION
 *		  contrib/oracle_fdw/routine.c
 *
 *-------------------------------------------------------------------------
 */
#include "postgres.h"

#include "access/htup.h"
#include "access/reloptions.h"
#include "catalog/pg_type.h"
#include "executor/spi.h"
#include "fmgr.h"
#include "nodes/makefuncs.h"
#include "postgres_ext.h"
#include "utils/array.h"
#include "utils/builtins.h"

#include "oracle_fdw.h"
#include "routine.h"

/*
 * Convert the text-array format of reloptions into a List of DefElem.
 * This is the inverse of transformRelOptions().
 */
List *
untransformRelOptions(Datum options)
{
	List	   *result = NIL;
	ArrayType  *array;
	Datum	   *optiondatums;
	int			noptions;
	int			i;

	/* Nothing to do if no options */
	if (!PointerIsValid(DatumGetPointer(options)))
		return result;

	array = DatumGetArrayTypeP(options);

	Assert(ARR_ELEMTYPE(array) == TEXTOID);

	deconstruct_array(array, TEXTOID, -1, false, 'i',
					  &optiondatums, NULL, &noptions);

	for (i = 0; i < noptions; i++)
	{
		char	   *s;
		char	   *p;
		Node	   *val = NULL;

		s = TextDatumGetCString(optiondatums[i]);
		p = strchr(s, '=');
		if (p)
		{
			*p++ = '\0';
			val = (Node *) makeString(pstrdup(p));
		}
		result = lappend(result, makeDefElem(pstrdup(s), val));
	}

	return result;
}

/*
 * GetRoutineMapping - look up the routine mapping.
 */
RoutineMapping *
GetRoutineMapping(Oid procid, Oid serverid)
{
	int			ret;
	Datum		values[2];
	Oid			argtypes[2] = {OIDOID, OIDOID};
	TupleDesc	tupdesc;
	HeapTuple	tuple;
	Datum		datum;
	bool		isnull = false;
	List	   *options;
	MemoryContext	cxt = CurrentMemoryContext;
	RoutineMapping *rm;

	/*
	 * Connect to SPI manager
	 */
	if ((ret = SPI_connect()) != SPI_OK_CONNECT)
		elog(ERROR, "SPI_connect failed: %s", SPI_result_code_string(ret));

	/* Create a cursor for the query */
	values[0] = ObjectIdGetDatum(procid);
	values[1] = ObjectIdGetDatum(serverid);
	ret = SPI_execute_with_args("SELECT rmoptions "
								"  FROM oracle_fdw.pg_routine_mapping "
								" WHERE rmproc = $1 "
								"   AND rmserver = $2",
								2, argtypes, values, NULL, true, 1);

	if (ret != SPI_OK_SELECT)
		elog(ERROR, "SPI_execute_with_args failed: %s",
			 SPI_result_code_string(ret));

	tupdesc = SPI_tuptable->tupdesc;

	if (SPI_tuptable == NULL || tupdesc == NULL)
		elog(ERROR, "SPI error");

	if (SPI_processed <= 0)
	{
		SPI_finish();
		return NULL;
	}

	if (SPI_processed != 1 || tupdesc->natts != 1)
		elog(ERROR, "SPI error");

	tuple = SPI_copytuple(SPI_tuptable->vals[0]);
	datum = heap_getattr(tuple, 1, tupdesc, &isnull);

	/* Extract the rmoptions */
	if (isnull)
		options = NIL;
	else
	{
		MemoryContext	old;

		old = MemoryContextSwitchTo(cxt);
		options = untransformRelOptions(datum);
		MemoryContextSwitchTo(old);
	}

	SPI_finish();

	rm = (RoutineMapping *) palloc(sizeof(RoutineMapping));
	rm->procid = procid;
	rm->serverid = serverid;
	rm->options = options;

	/*
	 * Validate the generic options given to a routine mapping.
	 */
	DirectFunctionCall2(oracle_fdw_validator, PointerGetDatum(datum),
						ObjectIdGetDatum(RoutineMappingRelationId));

	return rm;
}
