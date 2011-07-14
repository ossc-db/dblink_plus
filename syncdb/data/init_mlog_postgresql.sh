#!/bin/sh
#:set -x

psql postgres <<EOF 2>&1 | grep -i error
DROP DATABASE syncdb1;
DROP DATABASE syncdb2;
CREATE DATABASE syncdb1;
CREATE DATABASE syncdb2;
EOF
createlang plpgsql syncdb1 2>&1 | grep -i error
psql syncdb1 -f sql/mlog_postgresql.sql  2>&1 | grep -i error
psql syncdb1 -f data/init_mlog_postgresql.sql 2>&1 | grep -i error
createlang plpgsql syncdb2 2>&1 | grep -i error
psql syncdb2 -f sql/observer_postgresql.sql 2>&1 | grep -i error
psql syncdb2 -f data/init_observer_postgresql.sql 2>&1 | grep -i error

DBNAME=syncdb1

TABLES="
tab1
tab2
foo
bar
ccc
"
get_oid (){
test
	if [ -z "$2" ] ; then
		SCHEMA="public"
	else
		SCHEMA=$2
	fi
	OID=`psql -tA $DBNAME -c "SELECT c.oid FROM pg_class c, pg_namespace n WHERE c.relnamespace = n.oid AND relname = '$1' AND n.nspname = '$SCHEMA'"`
psql -tA $DBNAME -c "DROP TABLE IF EXISTS mlog.\"mlog\$${OID}\"" 2>&1 | grep -i error
	echo "mlog.mlog\$${OID}"
}

TABLE=`get_oid tab1`
psql $DBNAME <<EOF 2>&1 | grep -i error
CREATE TABLE ${TABLE} (mlogid bigint PRIMARY KEY, dmltype "char", pk1 integer, pk2 integer);
INSERT INTO ${TABLE} VALUES
(1, 'I', 1, 100),
(2, 'U', 1, 100),
(3, 'D', 1, 100),
(123, 'I', 1, 100);
EOF

TABLE=`get_oid tab2`
psql $DBNAME <<EOF 2>&1 | grep -i error
CREATE TABLE ${TABLE} (mlogid bigint PRIMARY KEY, dmltype "char", pk1 integer, pk2 integer);
EOF

TABLE=`get_oid foo`
psql $DBNAME <<EOF 2>&1 | grep -i error
CREATE TABLE ${TABLE} (mlogid bigint PRIMARY KEY, dmltype "char", val1 integer);
INSERT INTO ${TABLE} VALUES
(28, 'D', 1),
(2, 'D', 2),
(3, 'D', 4),
(4, 'D', 5),
(5, 'D', 8),
(6, 'D', 9),
(7, 'D', 10),
(8, 'D', 11),
(9, 'D', 12),
(10, 'D', 13),
(11, 'I', 1),
(12, 'I', 2),
(13, 'I', 4),
(14, 'I', 5),
(15, 'I', 6),
(16, 'I', 7),
(17, 'I', 8),
(18, 'I', 9),
(19, 'I', 12),
(20, 'I', 13),
(21, 'U', 1),
(22, 'U', 3),
(23, 'U', 4),
(24, 'U', 6),
(25, 'U', 8),
(26, 'U', 10),
(27, 'U', 12);
EOF

TABLE=`get_oid bar`
psql $DBNAME <<EOF 2>&1 | grep -i error
CREATE TABLE ${TABLE} (mlogid bigint PRIMARY KEY, dmltype "char", val1 integer);
EOF

TABLE=`get_oid ccc`
psql $DBNAME <<EOF 2>&1 | grep -i error
CREATE TABLE ${TABLE} (mlogid bigint PRIMARY KEY, dmltype "char", val1 integer);
INSERT INTO ${TABLE} VALUES
(1, 'I', 1);
EOF

TABLE=`get_oid inc`
psql $DBNAME <<EOF 2>&1 | grep -i error
CREATE TABLE ${TABLE} (mlogid bigint PRIMARY KEY, dmltype "char", pk1 integer, pk2 char(5));
INSERT INTO ${TABLE} VALUES
(6, 'I', 6, 'f'),
(7, 'I', 7, 'g'),
(8, 'I', 8, 'h'),
(9, 'I', 9, 'i'),
(10, 'I', 10, 'j'),
(11, 'I', 11, 'k'),
(12, 'D', 11, 'k'),
(13, 'U', 6, 'f'),
(14, 'D', 6, 'f'),
(15, 'I', 6, 'f'),
(16, 'I', 12, 'l'),
(17, 'D', 12, 'l'),
(18, 'D', 3, 'c'),
(19, 'U', 3, 'c'),
(20, 'U', 3, 'c'),
(21, 'U', 3, 'c'),
(22, 'U', 3, 'c'),
(23, 'I', 12, 'l'),
(24, 'D', 12, 'l'),
(25, 'U', 3, 'c')
;
EOF

TABLE=`get_oid attach1`
psql $DBNAME <<EOF 2>&1 | grep -i error
CREATE TABLE ${TABLE} (mlogid bigint PRIMARY KEY, dmltype "char", val1 integer);
EOF

TABLE=`get_oid foo test`
psql $DBNAME <<EOF 2>&1 | grep -i error
CREATE TABLE ${TABLE} (mlogid bigint PRIMARY KEY, dmltype "char", val1 integer);
INSERT INTO ${TABLE} VALUES
(1, 'I', 1);
EOF

#TABLE=`get_oid detach1`
#psql $DBNAME <<EOF 2>&1 | grep -i error
#CREATE TABLE ${TABLE} (mlogid bigint PRIMARY KEY, dmltype "char", val1 integer);
#EOF

TABLE=`get_oid detach2`
psql $DBNAME <<EOF 2>&1 | grep -i error
CREATE TABLE ${TABLE} (mlogid bigint PRIMARY KEY, dmltype "char", val1 integer);
EOF

TABLE=`get_oid detach3`
psql $DBNAME <<EOF 2>&1 | grep -i error
CREATE TABLE ${TABLE} (mlogid bigint PRIMARY KEY, dmltype "char", val1 integer);
EOF

TABLE=`get_oid drop1`
psql $DBNAME <<EOF 2>&1 | grep -i error
CREATE TABLE ${TABLE} (mlogid bigint PRIMARY KEY, dmltype "char", val1 integer);
CREATE FUNCTION  ${TABLE}_trg_fnc() RETURNS void AS '' LANGUAGE sql;
EOF

exit 0
