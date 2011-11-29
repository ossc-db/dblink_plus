-- ===================================================================
-- create FDW objects
-- ===================================================================

CREATE EXTENSION pgsql_fdw;

CREATE SERVER loopback1 FOREIGN DATA WRAPPER pgsql_fdw;
CREATE SERVER loopback2 FOREIGN DATA WRAPPER pgsql_fdw
  OPTIONS (dbname 'contrib_regression');

CREATE USER MAPPING FOR public SERVER loopback1
	OPTIONS (user 'value', password 'value');
CREATE USER MAPPING FOR public SERVER loopback2;

CREATE FOREIGN TABLE ft1 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 timestamptz,
	c5 timestamp,
	c6 varchar(10),
	c7 char(10)
) SERVER loopback2;

CREATE FOREIGN TABLE ft2 (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 timestamptz,
	c5 timestamp,
	c6 varchar(10),
	c7 char(10)
) SERVER loopback2;

-- ===================================================================
-- create objects used through FDW
-- ===================================================================
CREATE SCHEMA "S 1";
CREATE TABLE "S 1"."T 1" (
	c1 int NOT NULL,
	c2 int NOT NULL,
	c3 text,
	c4 timestamptz,
	c5 timestamp,
	c6 varchar(10),
	c7 char(10),
	CONSTRAINT t1_pkey PRIMARY KEY (c1)
);
CREATE TABLE "S 1"."T 2" (
	c1 int NOT NULL,
	c2 text,
	CONSTRAINT t2_pkey PRIMARY KEY (c1)
);

BEGIN;
TRUNCATE "S 1"."T 1";
INSERT INTO "S 1"."T 1"
	SELECT id,
	       id % 10,
	       to_char(id, 'FM00000'),
	       '1970-01-01'::timestamptz + ((id % 100) || ' days')::interval,
	       '1970-01-01'::timestamp + ((id % 100) || ' days')::interval,
	       id % 10,
	       id % 10
	FROM generate_series(1, 1000) id;
TRUNCATE "S 1"."T 2";
INSERT INTO "S 1"."T 2"
	SELECT id,
	       'AAA' || to_char(id, 'FM000')
	FROM generate_series(1, 100) id;
COMMIT;

-- ===================================================================
-- tests for pgsql_fdw_validator
-- ===================================================================
ALTER FOREIGN DATA WRAPPER pgsql_fdw OPTIONS (host 'value');    -- ERROR
-- requiressl, krbsrvname and gsslib are omitted because they depend on
-- configure option
ALTER SERVER loopback1 OPTIONS (
	authtype 'value',
	service 'value',
	connect_timeout 'value',
	dbname 'value',
	host 'value',
	hostaddr 'value',
	port 'value',
	--client_encoding 'value',
	tty 'value',
	options 'value',
	application_name 'value',
	--fallback_application_name 'value',
	keepalives 'value',
	keepalives_idle 'value',
	keepalives_interval 'value',
	-- requiressl 'value',
	sslmode 'value',
	sslcert 'value',
	sslkey 'value',
	sslrootcert 'value',
	sslcrl 'value'
	--requirepeer 'value',
	-- krbsrvname 'value',
	-- gsslib 'value',
	--replication 'value'
);
ALTER SERVER loopback1 OPTIONS (user 'value');                  -- ERROR
ALTER SERVER loopback2 OPTIONS (ADD fetch_count '2');
ALTER USER MAPPING FOR public SERVER loopback1
	OPTIONS (DROP user, DROP password);
ALTER USER MAPPING FOR public SERVER loopback1
	OPTIONS (host 'value');                                     -- ERROR
ALTER FOREIGN TABLE ft1 OPTIONS (nspname 'S 1', relname 'T 1');
ALTER FOREIGN TABLE ft2 OPTIONS (nspname 'S 1', relname 'T 1', fetch_count '100');
ALTER FOREIGN TABLE ft1 OPTIONS (invalid 'value');              -- ERROR
ALTER FOREIGN TABLE ft1 OPTIONS (fetch_count 'a');              -- ERROR
ALTER FOREIGN TABLE ft1 OPTIONS (fetch_count '0');              -- ERROR
ALTER FOREIGN TABLE ft1 OPTIONS (fetch_count '-1');             -- ERROR
\dew+
\des+
\deu+
\det+

-- ===================================================================
-- simple queries
-- ===================================================================
-- single table, with/without alias
EXPLAIN (VERBOSE, COSTS false) SELECT * FROM ft1 ORDER BY c3, c1 OFFSET 100 LIMIT 10;
SELECT * FROM ft1 ORDER BY c3, c1 OFFSET 100 LIMIT 10;
EXPLAIN (VERBOSE, COSTS false) SELECT * FROM ft1 t1 ORDER BY t1.c3, t1.c1 OFFSET 100 LIMIT 10;
SELECT * FROM ft1 t1 ORDER BY t1.c3, t1.c1 OFFSET 100 LIMIT 10;
-- with WHERE clause
EXPLAIN (VERBOSE, COSTS false) SELECT * FROM ft1 t1 WHERE t1.c1 = 101 AND t1.c6 = '1' AND t1.c7 = '1';
SELECT * FROM ft1 t1 WHERE t1.c1 = 101 AND t1.c6 = '1' AND t1.c7 = '1';
-- aggregate
SELECT COUNT(*) FROM ft1 t1;
-- join two tables
SELECT t1.c1 FROM ft1 t1 JOIN ft2 t2 ON (t1.c1 = t2.c1) ORDER BY t1.c3, t1.c1 OFFSET 100 LIMIT 10;
-- subquery
SELECT * FROM ft1 t1 WHERE t1.c3 IN (SELECT c3 FROM ft2 t2 WHERE c1 <= 10) ORDER BY c1;
-- subquery+MAX
SELECT * FROM ft1 t1 WHERE t1.c3 = (SELECT MAX(c3) FROM ft2 t2) ORDER BY c1;
-- used in CTE
WITH t1 AS (SELECT * FROM ft1 WHERE c1 <= 10) SELECT t2.c1, t2.c2, t2.c3, t2.c4 FROM t1, ft2 t2 WHERE t1.c1 = t2.c1 ORDER BY t1.c1;
-- fixed values
SELECT 'fixed', NULL FROM ft1 t1 WHERE c1 = 1;
-- user-defined operator/function
CREATE FUNCTION pgsql_fdw_abs(int) RETURNS int AS $$
BEGIN
RETURN abs($1);
END
$$ LANGUAGE plpgsql IMMUTABLE;
CREATE OPERATOR === (
    LEFTARG = int,
    RIGHTARG = int,
    PROCEDURE = int4eq,
    COMMUTATOR = ===,
    NEGATOR = !==
);
EXPLAIN (COSTS false) SELECT * FROM ft1 t1 WHERE t1.c1 = pgsql_fdw_abs(t1.c2);
EXPLAIN (COSTS false) SELECT * FROM ft1 t1 WHERE t1.c1 === t1.c2;
EXPLAIN (COSTS false) SELECT * FROM ft1 t1 WHERE t1.c1 = abs(t1.c2);
EXPLAIN (COSTS false) SELECT * FROM ft1 t1 WHERE t1.c1 = t1.c2;
DROP OPERATOR === (int, int) CASCADE;
DROP FUNCTION pgsql_fdw_abs(int);

-- ===================================================================
-- parameterized queries
-- ===================================================================
-- simple join
PREPARE st1(int, int) AS SELECT t1.c3, t2.c3 FROM ft1 t1, ft2 t2 WHERE t1.c1 = $1 AND t2.c1 = $2;
EXPLAIN (COSTS false) EXECUTE st1(1, 2);
EXECUTE st1(1, 1);
EXECUTE st1(101, 101);
-- subquery using stable function (can't be pushed down)
PREPARE st2(int) AS SELECT * FROM ft1 t1 WHERE t1.c1 < $2 AND t1.c3 IN (SELECT c3 FROM ft2 t2 WHERE c1 > $1 AND EXTRACT(dow FROM c4) = 6) ORDER BY c1;
EXPLAIN (COSTS false) EXECUTE st2(10, 20);
EXECUTE st2(10, 20);
EXECUTE st1(101, 101);
-- subquery using immutable function (can be pushed down)
PREPARE st3(int) AS SELECT * FROM ft1 t1 WHERE t1.c1 < $2 AND t1.c3 IN (SELECT c3 FROM ft2 t2 WHERE c1 > $1 AND EXTRACT(dow FROM c5) = 6) ORDER BY c1;
EXPLAIN (COSTS false) EXECUTE st3(10, 20);
EXECUTE st3(10, 20);
EXECUTE st3(20, 30);
-- fixed costs
PREPARE st4(int) AS SELECT NULL FROM ft1 t1 WHERE t1.c1 = $1;
EXPLAIN (COSTS true) EXECUTE st4(1);
-- cleanup
DEALLOCATE st1;
DEALLOCATE st2;
DEALLOCATE st3;
DEALLOCATE st4;

-- ===================================================================
-- connection management
-- ===================================================================
SELECT srvname, usename FROM pgsql_fdw_connections;
SELECT pgsql_fdw_disconnect(srvid, usesysid) FROM pgsql_fdw_get_connections();
SELECT srvname, usename FROM pgsql_fdw_connections;

-- ===================================================================
-- cleanup
-- ===================================================================
DROP EXTENSION pgsql_fdw CASCADE;

