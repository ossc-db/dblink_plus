\c contrib_regression_utf8

DELETE FROM oracle_fdw.pg_routine_mapping
 WHERE rmproc = 'abs(integer)'::regprocedure;

EXPLAIN SELECT * FROM ft1 WHERE abs(c1) = 1;
SELECT * FROM ft1 WHERE abs(c1) = 1;

INSERT INTO oracle_fdw.pg_routine_mapping
SELECT 'abs(integer)', oid, '{format=ABS(%s)}'
  FROM pg_foreign_server
 WHERE srvname = 'ora_server';

EXPLAIN SELECT * FROM ft1 WHERE abs(c1) = 1;
SELECT * FROM ft1 WHERE abs(c1) = 1;
