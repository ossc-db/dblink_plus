CREATE FOREIGN DATA WRAPPER postgres VALIDATOR dblink.postgres;
CREATE SERVER server_postgres FOREIGN DATA WRAPPER postgres OPTIONS (dbname 'contrib_regression');
CREATE USER MAPPING FOR CURRENT_USER SERVER server_postgres OPTIONS (user 'postgres');

CREATE TABLE dblink_tbl (id integer, value text);
INSERT INTO dblink_tbl VALUES(1, 'X');
INSERT INTO dblink_tbl VALUES(2, 'BB');
INSERT INTO dblink_tbl VALUES(3, 'CCC');
INSERT INTO dblink_tbl VALUES(4, 'DDDD');

CREATE TABLE dblink_tmp (LIKE dblink_tbl);

CREATE FUNCTION dblink.cursor_test(cursor integer, howmany integer)
RETURNS SETOF dblink_tmp AS
$$
TRUNCATE dblink_tmp;
INSERT INTO dblink_tmp SELECT * FROM dblink.fetch($1, $2) AS t(id integer, value text);
INSERT INTO dblink_tmp SELECT * FROM dblink.fetch($1, $2) AS t(id integer, value text);
INSERT INTO dblink_tmp SELECT * FROM dblink.fetch($1, $2) AS t(id integer, value text);
SELECT * FROM dblink_tmp;
$$
LANGUAGE sql;

-- dblink.connect()
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
SELECT dblink.connect('conn_postgres', 'server_postgres');
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;

-- dblink.exec() with an existing connection
SELECT * FROM dblink_tbl ORDER BY id;

BEGIN;
SELECT dblink.exec('conn_postgres', 'UPDATE dblink_tbl SET value = ''A'' WHERE id = 1');
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
ROLLBACK;

SELECT * FROM dblink_tbl ORDER BY id;

BEGIN;
SELECT dblink.exec('conn_postgres', 'UPDATE dblink_tbl SET value = ''A'' WHERE id = 1');
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
COMMIT;

SELECT * FROM dblink_tbl ORDER BY id;

-- dblink.query() with an existing connection
BEGIN;
SELECT * FROM dblink.query('conn_postgres', 'SELECT * FROM dblink_tbl ORDER BY id') AS t(id integer, value text) ORDER BY id;
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
COMMIT;

-- dblink.open() with an existing connection
SELECT * FROM dblink.cursor_test(dblink.open('conn_postgres', 'SELECT * FROM dblink_tbl ORDER BY id'), 100);
SELECT * FROM dblink.cursor_test(dblink.open('conn_postgres', 'SELECT * FROM dblink_tbl ORDER BY id'), 2);
SELECT * FROM dblink.cursor_test(dblink.open('conn_postgres', 'SELECT * FROM dblink_tbl ORDER BY id'), 1);

-- dblink.disconnect()
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
SELECT dblink.disconnect('conn_postgres');
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;

-- dblink.query() with an anonymous connection
BEGIN;
SELECT * FROM dblink.query('server_postgres', 'SELECT * FROM dblink_tbl ORDER BY id') AS t(id integer, value text) ORDER BY id;
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
COMMIT;
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;

-- dblink.exec() with an anonymous connection
BEGIN;
SELECT dblink.exec('server_postgres', 'UPDATE dblink_tbl SET value = value WHERE id < 3');
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
COMMIT;
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;

-- dblink.open() with an anonymous connection
SELECT * FROM dblink.cursor_test(dblink.open('server_postgres', 'SELECT * FROM dblink_tbl ORDER BY id'), 100);
SELECT * FROM dblink.cursor_test(dblink.open('server_postgres', 'SELECT * FROM dblink_tbl ORDER BY id'), 2);
SELECT * FROM dblink.cursor_test(dblink.open('server_postgres', 'SELECT * FROM dblink_tbl ORDER BY id'), 1);
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;

-- dblink.query() with max_value_len option
SELECT * FROM dblink.query('server_postgres', 'SELECT * FROM dblink_tbl ORDER BY id', 0, 1) AS t(id integer, value text) ORDER BY id;

-- dblink.open() with max_value_len option
SELECT * FROM dblink.cursor_test(dblink.open('server_postgres', 'SELECT * FROM dblink_tbl ORDER BY id', 100, 1), 100);

-- connection without automatic transaction management
SELECT dblink.connect('conn_postgres', 'server_postgres', false);
SELECT dblink.exec('conn_postgres', 'VACUUM dblink_tbl');
SELECT dblink.disconnect('conn_postgres');

create function dblink.f_test(num integer)
returns integer as
$$
  select $1 + 1000;
$$
language 'sql';

-- dblink.call() with an anonymous connection
SELECT * FROM dblink.call('server_postgres', 'dblink.f_test(1)') AS t(a integer);

--  dblink.call() with max_value_len option
SELECT * FROM dblink.call('server_postgres', 'dblink.f_test(1)', 0, 1) AS t(a integer);

