\c contrib_regression_utf8
\! sqlplus -s system/manager@orcl @sql/format/init_ora.sql

DELETE FROM oracle_fdw.pg_routine_mapping
 WHERE rmserver = (SELECT oid FROM pg_foreign_server WHERE srvname = 'ora_server');
INSERT INTO oracle_fdw.pg_routine_mapping
SELECT
	t.rmproc, s.oid, t.rmoptions
  FROM pg_foreign_server s,
(
SELECT *
  FROM oracle_fdw.pg_routine_mapping, pg_foreign_server
 WHERE srvname = 'oracle_fdw_template_server'
) t 
 WHERE s.srvname = 'ora_server';

SELECT rmproc, rmoptions
  FROM oracle_fdw.pg_routine_mapping r, pg_foreign_server s
 WHERE r.rmserver = s.oid
   AND srvname = 'ora_server'
 ORDER BY rmproc;
