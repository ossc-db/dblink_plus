#include "postgres.h"
#include "access/tupdesc.h"
#include "access/attnum.h"
#include "fmgr.h"
#include "utils/lsyscache.h"

#include "former_ora.h"
#include "former_pg.h"

struct TupleFormer
{
	TupleDesc		desc;		/**< descriptor */
	Datum		   *values;		/**< array[desc->natts] of values */
	bool		   *isnull;		/**< array[desc->natts] of NULL marker */
	OciFetchType   *fetchtype;	/**< array of fetch data type */

	FmgrInfo	   *typInput;	/**< array[desc->natts] of type input functions */
	Oid			   *typIOParam;	/**< array[desc->natts] of type information */
	Oid			   *typMod;		/**< array[desc->natts] of type modifiers */
	Oid			   *typId;		/**< array[desc->natts] of type oid */
};

TupleFormer *
TupleFormerCreate(int nfields)
{
	TupleFormer	   *former;

	former = palloc(sizeof(TupleFormer));
	former->desc = NULL;

	/*
	 * allocate buffer to store columns or function arguments
	 */
	former->values = palloc(sizeof(Datum) * nfields);
	former->isnull = palloc(sizeof(bool) * nfields);
	MemSet(former->isnull, true, sizeof(bool) * nfields);

	former->fetchtype = palloc(sizeof(OciFetchType) * nfields);

	/*
	 * get column information of the target relation
	 */
	former->typInput = (FmgrInfo *) palloc(nfields * sizeof(FmgrInfo));
	former->typIOParam = (Oid *) palloc(nfields * sizeof(Oid));
	former->typMod = (Oid *) palloc(nfields * sizeof(Oid));
	former->typId = (Oid *) palloc(nfields * sizeof(Oid));

	return former;
}

void
TupleFormerTerm(TupleFormer *former)
{
	if (former->desc)
		FreeTupleDesc(former->desc);

	if (former->values)
		pfree(former->values);

	if (former->isnull)
		pfree(former->isnull);

	if (former->fetchtype)
		pfree(former->fetchtype);

	if (former->typInput)
		pfree(former->typInput);

	if (former->typIOParam)
		pfree(former->typIOParam);

	if (former->typMod)
		pfree(former->typMod);

	if (former->typId)
		pfree(former->typId);

	pfree(former);
}

void
TupleFormerSetType(TupleFormer *former, int col, OciFetchType type)
{
	former->fetchtype[col] = type;
}

void
TupleFormerInit(TupleFormer *former, TupleDesc desc)
{
	int	i;
	int	j;

	former->desc = CreateTupleDescCopy(desc);

	for (i = 0, j = 0; i < desc->natts; i++)
	{
		Oid	in_func_oid;

		/* ignore dropped columns */
		if (desc->attrs[i]->attisdropped)
			continue;

		/* get type information and input function */
		getTypeInputInfo(desc->attrs[i]->atttypid,
						 &in_func_oid, &former->typIOParam[j]);
		fmgr_info(in_func_oid, &former->typInput[j]);

		former->typMod[j] = desc->attrs[i]->atttypmod;
		former->typId[j] = desc->attrs[i]->atttypid;

		j++;
	}
}

HeapTuple
TupleFormerTuple(TupleFormer *former)
{
	return heap_form_tuple(former->desc, former->values, former->isnull);
}

static const int8 hexlookup[128] = {
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, -1, -1, -1, -1, -1, -1,
	-1, 10, 11, 12, 13, 14, 15, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, 10, 11, 12, 13, 14, 15, -1, -1, -1, -1, -1, -1, -1, -1, -1,
	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
};

static inline char
get_hex(char c)
{
	int			res = -1;

	if (c > 0 && c < 127)
		res = hexlookup[(unsigned char) c];

	if (res < 0)
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
				 errmsg("invalid hexadecimal digit: \"%c\"", c)));

	return (char) res;
}

/* Read null-terminated string and convert to internal format */
Datum
TupleFormerValue(TupleFormer *former, const char *inputText, int size, int col)
{
	Datum	result;

	if (former->fetchtype[col] == OCI_BIN)
	{
		bytea  *vlena;

		vlena = palloc(size + VARHDRSZ);
		memcpy(VARDATA(vlena), inputText, size);
		SET_VARSIZE(vlena, size + VARHDRSZ);

		result = PointerGetDatum(vlena);
	}
	else if (former->fetchtype[col] == OCI_HEX)
	{
		int		i;
		int		bc;
		bytea  *vlena;
		char   *rp;

		bc = strlen(inputText) / 2;
		vlena = palloc(bc + VARHDRSZ);
		SET_VARSIZE(vlena, bc + VARHDRSZ);
		rp = VARDATA(vlena);
		for (i = 0; i < bc; i++)
		{
			rp[i] = get_hex(*inputText++) << 4;
			rp[i] |= get_hex(*inputText++);
		}

		result = PointerGetDatum(vlena);
	}
	else
	{
		result = FunctionCall3(&former->typInput[col],
					CStringGetDatum(inputText),
					ObjectIdGetDatum(former->typIOParam[col]),
					Int32GetDatum(former->typMod[col]));
	}

	if (former->fetchtype[col])
		memset((void *) inputText, 0, strlen(inputText));

	return result;
}
