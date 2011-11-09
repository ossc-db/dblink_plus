# pgsql_fdw/Makefile

MODULE_big = pgsql_fdw
OBJS	= pgsql_fdw.o option.o deparse.o connection.o ruleutils.o
PG_CPPFLAGS = -I$(libpq_srcdir)
SHLIB_LINK = $(libpq)

EXTENSION = pgsql_fdw
DATA = pgsql_fdw--1.0.sql

REGRESS = pgsql_fdw

ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
else
subdir = contrib/pgsql_fdw
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif
