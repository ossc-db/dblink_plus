\c contrib_regression_utf8
\! sqlplus -s system/manager@orcl @sql/func_pushdown/init_ora.sql

DELETE FROM oracle_fdw.pg_routine_mapping
 WHERE rmserver = (SELECT oid FROM pg_foreign_server WHERE srvname = 'ora_server');

INSERT INTO oracle_fdw.pg_routine_mapping
SELECT t.rmproc, s1.oid, t.rmoptions
  FROM pg_foreign_server s1,
(
SELECT *
  FROM oracle_fdw.pg_routine_mapping r, pg_foreign_server s2
 WHERE srvname = 'oracle_fdw_template_server'
   AND s2.oid = r.rmserver
) t
 WHERE s1.srvname = 'ora_server';

SELECT rmproc, rmoptions
  FROM oracle_fdw.pg_routine_mapping r, pg_foreign_server s
 WHERE r.rmserver = s.oid
   AND srvname = 'ora_server'
 ORDER BY rmproc;
