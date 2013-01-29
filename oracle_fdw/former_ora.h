#ifndef FORMER_ORA_H
#define FORMER_ORA_H

typedef enum
{
	OCI_BIN,
	OCI_HEX,
	OCI_STR
} OciFetchType;

typedef struct TupleFormer   TupleFormer;
extern TupleFormer *TupleFormerCreate(int nfields);
extern void TupleFormerTerm(TupleFormer *former);
extern void TupleFormerSetType(TupleFormer *former, int col, OciFetchType type);

#endif   /* FORMER_ORA_H */
