CREATE FOREIGN DATA WRAPPER oracle VALIDATOR dblink.oracle;
CREATE SERVER server_oracle FOREIGN DATA WRAPPER oracle OPTIONS (dbname 'dbt');
CREATE USER MAPPING FOR CURRENT_USER SERVER server_oracle OPTIONS (user 'scott', password 'tiger');

CREATE SERVER server_oracle2 FOREIGN DATA WRAPPER oracle OPTIONS (dbname 'dbt', max_value_len '4');
CREATE USER MAPPING FOR CURRENT_USER SERVER server_oracle2 OPTIONS (user 'scott', password 'tiger');

CREATE SERVER server_oracle3 FOREIGN DATA WRAPPER oracle OPTIONS (dbname 'dbt', max_value_len '3');
CREATE USER MAPPING FOR CURRENT_USER SERVER server_oracle3 OPTIONS (user 'scott', password 'tiger');

SELECT dblink.connect('conn_ora', 'server_oracle', false);
SELECT dblink.exec('conn_ora', 'CREATE TABLE dblink_tbl (id NUMBER(4), value VARCHAR2(100))');
SELECT dblink.exec('conn_ora', 'CREATE TABLE lob_test (id NUMBER(5), value CLOB, value2 CLOB)');
SELECT dblink.disconnect('conn_ora');
SELECT dblink.exec('server_oracle', 'INSERT INTO dblink_tbl VALUES(1, ''X'')');
SELECT dblink.exec('server_oracle', 'INSERT INTO dblink_tbl VALUES(2, ''BB'')');
SELECT dblink.exec('server_oracle', 'INSERT INTO dblink_tbl VALUES(3, ''CCC'')');
SELECT dblink.exec('server_oracle', 'INSERT INTO dblink_tbl VALUES(4, ''DDDD'')');

CREATE TABLE dblink_tmp_ora (LIKE dblink_tbl);

CREATE FUNCTION dblink.cursor_test_ora(cursor integer, howmany integer)
RETURNS SETOF dblink_tmp_ora AS
$$
TRUNCATE dblink_tmp_ora;
INSERT INTO dblink_tmp_ora SELECT * FROM dblink.fetch($1, $2) AS t(id integer, value text);
INSERT INTO dblink_tmp_ora SELECT * FROM dblink.fetch($1, $2) AS t(id integer, value text);
INSERT INTO dblink_tmp_ora SELECT * FROM dblink.fetch($1, $2) AS t(id integer, value text);
SELECT * FROM dblink_tmp_ora;
$$
LANGUAGE sql;


-- dblink.connect()
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
SELECT dblink.connect('conn_oracle', 'server_oracle');
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;

-- dblink.exec() with an existing connection
SELECT * FROM dblink.query('conn_oracle', 'SELECT * FROM dblink_tbl ORDER BY id') AS t(i int, v text);

BEGIN;
SELECT dblink.exec('conn_oracle', 'UPDATE dblink_tbl SET value = ''A'' WHERE id = 1');
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
ROLLBACK;

SELECT * FROM dblink.query('conn_oracle', 'SELECT * FROM dblink_tbl ORDER BY id') AS t(i int, v text);

BEGIN;
SELECT dblink.exec('conn_oracle', 'UPDATE dblink_tbl SET value = ''A'' WHERE id = 1');
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
COMMIT;

SELECT * FROM dblink.query('conn_oracle', 'SELECT * FROM dblink_tbl ORDER BY id') AS t(i int, v text);

-- dblink.query() with an existing connection
BEGIN;
SELECT * FROM dblink.query('conn_oracle', 'SELECT * FROM dblink_tbl ORDER BY id') AS t(id integer, value text) ORDER BY id;
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
COMMIT;

-- dblink.open() with an existing connection
SELECT * FROM dblink.cursor_test_ora(dblink.open('conn_oracle', 'SELECT * FROM dblink_tbl ORDER BY id'), 100);
SELECT * FROM dblink.cursor_test_ora(dblink.open('conn_oracle', 'SELECT * FROM dblink_tbl ORDER BY id'), 2);
SELECT * FROM dblink.cursor_test_ora(dblink.open('conn_oracle', 'SELECT * FROM dblink_tbl ORDER BY id'), 1);

-- dblink.disconnect()
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
SELECT dblink.disconnect('conn_oracle');
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;

-- dblink.query() with an anonymous connection
BEGIN;
SELECT * FROM dblink.query('server_oracle', 'SELECT * FROM dblink_tbl ORDER BY id') AS t(id integer, value text) ORDER BY id;
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
COMMIT;
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;

-- dblink.exec() with an anonymous connection
BEGIN;
SELECT dblink.exec('server_oracle', 'UPDATE dblink_tbl SET value = value WHERE id < 3');
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
COMMIT;
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;

-- dblink.open() with an anonymous connection
SELECT * FROM dblink.cursor_test_ora(dblink.open('server_oracle', 'SELECT * FROM dblink_tbl ORDER BY id'), 100);
SELECT * FROM dblink.cursor_test_ora(dblink.open('server_oracle', 'SELECT * FROM dblink_tbl ORDER BY id'), 2);
SELECT * FROM dblink.cursor_test_ora(dblink.open('server_oracle', 'SELECT * FROM dblink_tbl ORDER BY id'), 1);
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;

-- CLOB data read
SELECT dblink.exec('server_oracle', 'insert into lob_test values(1, lpad(''Z'', 2000, ''Z''), lpad(''z'', 1000, ''z''))');
SELECT dblink.exec('server_oracle', 'insert into lob_test values(2, lpad(''Y'', 4000, ''Y''), lpad(''y'', 3000, ''y''))');
SELECT id, length(value), length(value2) from dblink.query('server_oracle', 'select * from lob_test') as (id integer, value text, value2 text) order by id;

-- dblink.query() with max_value_len option
SELECT * FROM dblink.query('server_oracle2', 'SELECT * FROM dblink_tbl ORDER BY id') AS t(id integer, value text) ORDER BY id;
SELECT * FROM dblink.query('server_oracle3', 'SELECT * FROM dblink_tbl ORDER BY id', 0, 4) AS t(id integer, value text) ORDER BY id;

-- dblink.open() with max_value_len option
SELECT * FROM dblink.cursor_test_ora(dblink.open('server_oracle', 'SELECT * FROM dblink_tbl ORDER BY id', 100, 4), 100);

-- connection without automatic transaction management
SELECT dblink.connect('conn_oracle', 'server_oracle', false);
SELECT dblink.exec('conn_oracle', 'DROP TABLE dblink_tbl');
SELECT dblink.exec('conn_oracle', 'DROP TABLE lob_test');
SELECT dblink.disconnect('conn_oracle');


SELECT dblink.connect('conn_oracle', 'server_oracle', false);
SELECT dblink.exec('conn_oracle', 'CREATE OR REPLACE PACKAGE dblink AS TYPE RT1 IS RECORD ( ret NUMBER ); TYPE RCT1 IS REF CURSOR RETURN RT1; PROCEDURE f_test(RC1 IN OUT RCT1, num IN NUMBER); END;');
SELECT dblink.exec('conn_oracle', 'CREATE OR REPLACE PACKAGE BODY dblink AS PROCEDURE f_test(RC1 IN OUT RCT1, num IN NUMBER) AS BEGIN OPEN RC1 FOR select num + 1000 from dual; END f_test; END;');
SELECT dblink.disconnect('conn_oracle');

-- dblink.call() with an anonymous connection
SELECT * FROM dblink.call('server_oracle', 'dblink.f_test(1)') AS t(a integer);

--  dblink.call() with max_value_len option
SELECT * FROM dblink.call('server_oracle2', 'dblink.f_test(1)') AS t(a integer);
SELECT * FROM dblink.call('server_oracle3', 'dblink.f_test(1)', 0, 4) AS t(a integer);
