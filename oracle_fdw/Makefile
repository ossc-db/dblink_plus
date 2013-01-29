# contrib/oracle_fdw/Makefile

MODULE_big = oracle_fdw
OBJS	= oracle_fdw.o oci.o former.o option.o deparse.o connection.o ruleutils.o routine.o
PG_CPPFLAGS = -I$(libpq_srcdir)
SHLIB_LINK = $(libpq)

PG_CPPFLAGS += -DENABLE_ORACLE
ifeq ($(PORTNAME),win32)
PG_CPPFLAGS += -I$(ORACLE_HOME)/oci/include
SHLIB_LINK += -L$(ORACLE_HOME)/lib -loci
else
PG_CPPFLAGS += -I$(ORACLE_HOME)/rdbms/public
SHLIB_LINK += -L$(ORACLE_HOME)/lib -lclntsh
endif

EXTENSION = oracle_fdw
DATA = oracle_fdw--1.0.sql

REGRESS = fini init oracle_fdw format/init format/to_date format/to_timestamp format/to_number func_pushdown/init func_pushdown/trim func_pushdown/length func_pushdown/upper func_pushdown/lower func_pushdown/replace func_pushdown/substr func_pushdown/substring func_pushdown/translate func_pushdown/concat func_pushdown/insert datatype/init datatype/binary datatype/date datatype/interval datatype/large pushdown/init pushdown/const pushdown/char pushdown/null_op1 pushdown/null_op2 pushdown/null_op3 pushdown/null_op4 pushdown/logical_op1 pushdown/math_op1_1 pushdown/math_op1_2 pushdown/math_op2_1 pushdown/math_op2_2 pushdown/math_op3_1 pushdown/math_op3_2 pushdown/math_op4_1 pushdown/math_op4_2 pushdown/math_op_other pushdown/comp_op1_1 pushdown/comp_op1_2 pushdown/comp_op2_1 pushdown/comp_op2_2 pushdown/comp_op3_1 pushdown/comp_op3_2 pushdown/comp_op4_1 pushdown/comp_op4_2 pushdown/comp_op5_1 pushdown/comp_op5_2 pushdown/comp_op6_1 pushdown/comp_op6_2 pushdown/comp_op7 pushdown/comp_op8 pushdown/str_op pushdown/like_op date_op_pushdown/init date_op_pushdown/plus date_op_pushdown/minus date_op_pushdown/mul date_op_pushdown/div
#REGRESS = fini init oracle_fdw format/init format/to_date format/to_timestamp format/to_number func_pushdown/insert
#REGRESS = format/init format/to_date format/to_timestamp format/to_number func_pushdown/insert

ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
else
subdir = contrib/oracle_fdw
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif
