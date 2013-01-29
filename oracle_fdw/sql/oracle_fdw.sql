\c contrib_regression_utf8

SET DateStyle = 'Postgres, YMD';

-- プラン表示
EXPLAIN (COSTS FALSE) SELECT * FROM ft1 ORDER BY c1;

-- simple query
ALTER USER MAPPING FOR PUBLIC SERVER ora_server OPTIONS (SET user 'invalid_user');
SELECT * FROM ft1 ORDER BY c1; -- username ERROR

ALTER USER MAPPING FOR PUBLIC SERVER ora_server OPTIONS (DROP user);
SELECT * FROM ft1 ORDER BY c1;

ALTER USER MAPPING FOR PUBLIC SERVER ora_server OPTIONS (ADD user 'oracle_fdw');
SELECT * FROM ft1 ORDER BY c1;

ALTER SERVER ora_server OPTIONS (SET dbname 'aaa');
SELECT * FROM ft1 ORDER BY c1;
ALTER SERVER ora_server OPTIONS (DROP dbname);
SELECT * FROM ft1 ORDER BY c1;

ALTER FOREIGN TABLE ft1 OPTIONS (SET relname 't2');
EXPLAIN (COSTS FALSE) SELECT * FROM ft1 ORDER BY c1;
SELECT * FROM ft1 ORDER BY c1; -- colname ERROR

ALTER FOREIGN TABLE ft1 OPTIONS (SET relname 't1');

-- char(5) length
EXPLAIN (COSTS FALSE) SELECT c1, c2, length(c2), octet_length(c2), c3, length(c3), octet_length(c3), c4 FROM ft1 ORDER BY c1;
SELECT c1, c2, length(c2), octet_length(c2), c3, length(c3), octet_length(c3), c4 FROM ft1 ORDER BY c1;

-- query with projection
EXPLAIN (COSTS FALSE) SELECT c1 FROM ft1 ORDER BY c1;
SELECT c1 FROM ft1 ORDER BY c1;

EXPLAIN (COSTS FALSE) SELECT c1, length(c2), length(c3) FROM ft2 ORDER BY c1;
SELECT c1, length(c2), length(c3) FROM ft2 ORDER BY c1;

-- join two foreign tables
EXPLAIN (COSTS FALSE) SELECT * FROM ft1 JOIN ft2 ON (ft1.c1 = ft2.c1) ORDER BY ft1.c1;
--SELECT * FROM ft1 JOIN ft2 ON (ft1.c1 = ft2.c1) ORDER BY ft1.c1;

-- join itself
EXPLAIN (COSTS FALSE) SELECT * FROM ft1 t1 JOIN ft1 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c1;
SELECT * FROM ft1 t1 JOIN ft1 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c1;

-- outer join
EXPLAIN (COSTS FALSE) SELECT * FROM ft1 t1 LEFT JOIN ft2 t2 ON (t1.c1 = t2.c1) ORDER BY 1,2,3,4,5,6;
--SELECT * FROM ft1 t1 LEFT JOIN ft2 t2 ON (t1.c1 = t2.c1) ORDER BY 1,2,3,4,5,6;

-- WHERE clause
EXPLAIN (COSTS FALSE) SELECT * FROM ft1 WHERE c1 = 1 AND c2 < lower('AAA') AND c4 < now() and c4 < clock_timestamp();
SELECT * FROM ft1 WHERE c1 = 1 AND c2 < lower('AAA') AND c4 < now() and c4 < clock_timestamp();

-- prepared statement
PREPARE st(int) AS SELECT * FROM ft1 WHERE c1 > $1 ORDER BY c1;
EXPLAIN (COSTS FALSE) EXECUTE st(1);
EXECUTE st(1);
EXPLAIN (COSTS FALSE) EXECUTE st(2);
EXECUTE st(2);
DEALLOCATE st;

-- change datastyle
SET DATESTYLE = 'Postgres, MDY';
SELECT * FROM ft1 ORDER BY c4;

SET DATESTYLE = 'Postgres, DMY';
SELECT * FROM ft1 ORDER BY c4;

-- timestamp to text
ALTER FOREIGN TABLE ft1 ALTER c4 TYPE text;

-- simple query
EXPLAIN (COSTS FALSE) SELECT * FROM ft1 ORDER BY c1;
SELECT * FROM ft1 ORDER BY c1;

-- max_valu_len
ALTER SERVER ora_server OPTIONS (ADD max_value_len '1073741823');
ALTER SERVER ora_server OPTIONS (ADD max_value_len '1073741822');
ALTER SERVER ora_server OPTIONS (DROP max_value_len);
