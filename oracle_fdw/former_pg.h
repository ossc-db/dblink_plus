#ifndef FORMER_PG_H
#define FORMER_PG_H

#include "access/htup.h"
#include "access/tupdesc.h"

extern void TupleFormerInit(TupleFormer *former, TupleDesc desc);
extern HeapTuple TupleFormerTuple(TupleFormer *former);
extern Datum TupleFormerValue(TupleFormer *former, const char *str, int size, int col);

#endif   /* FORMER_PG_H */
