MODULE_big = dblink_plus
DATA_built = dblink_plus.sql
DATA = uninstall_dblink_plus.sql
OBJS = dblink.o dblink_postgres.o
REGRESS = init postgres
PG_CPPFLAGS = -I$(libpq_srcdir)
SHLIB_LINK = $(libpq)

ifneq ($(MYSQL),0)
OBJS += dblink_mysql.o
REGRESS += mysql
PG_CPPFLAGS += -DENABLE_MYSQL
SHLIB_LINK += -lmysqlclient
endif

ifneq ($(ORACLE),0)
OBJS += dblink_oracle.o
REGRESS += oracle
PG_CPPFLAGS += -DENABLE_ORACLE
PG_CPPFLAGS += -I$(ORACLE_HOME)/oci/include/	# win32
PG_CPPFLAGS += -I$(ORACLE_HOME)/rdbms/public	# linux
endif

ifneq ($(SQLITE3),0)
OBJS += dblink_sqlite3.o
REGRESS += sqlite3
PG_CPPFLAGS += -DENABLE_SQLITE3
SHLIB_LINK += -lsqlite3
endif

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

ifneq ($(ORACLE),0)
ifeq ($(PORTNAME),win32)
SHLIB_LINK += -L$(ORACLE_HOME)/lib -loci
else
SHLIB_LINK += -L$(ORACLE_HOME)/lib -lclntsh
endif
endif
