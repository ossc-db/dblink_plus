CREATE FOREIGN DATA WRAPPER sqlite3 VALIDATOR dblink.sqlite3;
CREATE SERVER server_sqlite3 FOREIGN DATA WRAPPER sqlite3 OPTIONS (location ':memory');
CREATE USER MAPPING FOR CURRENT_USER SERVER server_sqlite3;

-- dblink.connect()
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
SELECT dblink.connect('conn_sqlite3', 'server_sqlite3');
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;

-- dblink.exec() with an existing connection
SELECT dblink.exec('conn_sqlite3', 'DROP TABLE IF EXISTS dblink_tbl');
SELECT dblink.exec('conn_sqlite3', 'CREATE TABLE dblink_tbl (id integer, value text)');
SELECT dblink.exec('conn_sqlite3', 'INSERT INTO dblink_tbl VALUES(1, ''X'')');
SELECT dblink.exec('conn_sqlite3', 'INSERT INTO dblink_tbl VALUES(2, ''BB'')');
SELECT dblink.exec('conn_sqlite3', 'INSERT INTO dblink_tbl VALUES(3, ''CCC'')');
SELECT dblink.exec('conn_sqlite3', 'INSERT INTO dblink_tbl VALUES(4, ''DDDD'')');

SELECT * FROM dblink.query('server_sqlite3', 'SELECT * FROM dblink_tbl ORDER BY id') AS (id integer, value text);

BEGIN;
SELECT dblink.exec('conn_sqlite3', 'UPDATE dblink_tbl SET value = ''A'' WHERE id = 1');
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
ROLLBACK;

SELECT * FROM dblink.query('server_sqlite3', 'SELECT * FROM dblink_tbl ORDER BY id') AS (id integer, value text);

BEGIN;
SELECT dblink.exec('conn_sqlite3', 'UPDATE dblink_tbl SET value = ''A'' WHERE id = 1');
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
COMMIT;

SELECT * FROM dblink.query('server_sqlite3', 'SELECT * FROM dblink_tbl ORDER BY id') AS (id integer, value text);

-- dblink.query() with an existing connection
BEGIN;
SELECT * FROM dblink.query('conn_sqlite3', 'SELECT * FROM dblink_tbl ORDER BY id') AS t(id integer, value text) ORDER BY id;
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
COMMIT;

-- dblink.open() with an existing connection
SELECT * FROM dblink.cursor_test(dblink.open('conn_sqlite3', 'SELECT * FROM dblink_tbl ORDER BY id'), 100);
SELECT * FROM dblink.cursor_test(dblink.open('conn_sqlite3', 'SELECT * FROM dblink_tbl ORDER BY id'), 2);
SELECT * FROM dblink.cursor_test(dblink.open('conn_sqlite3', 'SELECT * FROM dblink_tbl ORDER BY id'), 1);

-- dblink.disconnect()
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
SELECT dblink.disconnect('conn_sqlite3');
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;

-- dblink.query() with an anonymous connection
BEGIN;
SELECT * FROM dblink.query('server_sqlite3', 'SELECT * FROM dblink_tbl ORDER BY id') AS t(id integer, value text) ORDER BY id;
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
COMMIT;
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;

-- dblink.exec() with an anonymous connection
BEGIN;
SELECT dblink.exec('server_sqlite3', 'UPDATE dblink_tbl SET value = value WHERE id < 3');
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
COMMIT;
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;

-- dblink.open() with an anonymous connection
SELECT * FROM dblink.cursor_test(dblink.open('server_sqlite3', 'SELECT * FROM dblink_tbl ORDER BY id'), 100);
SELECT * FROM dblink.cursor_test(dblink.open('server_sqlite3', 'SELECT * FROM dblink_tbl ORDER BY id'), 2);
SELECT * FROM dblink.cursor_test(dblink.open('server_sqlite3', 'SELECT * FROM dblink_tbl ORDER BY id'), 1);
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;

-- dblink.query() with max_value_len option
SELECT * FROM dblink.query('server_sqlite3', 'SELECT * FROM dblink_tbl ORDER BY id', 0, 1) AS (id integer, value text);

-- dblink.open() with max_value_len option
SELECT * FROM dblink.cursor_test(dblink.open('server_sqlite3', 'SELECT * FROM dblink_tbl ORDER BY id', 100, 1), 100);

-- connection without automatic transaction management
SELECT dblink.connect('conn_sqlite3', 'server_sqlite3', false);
SELECT dblink.exec('conn_sqlite3', 'VACUUM dblink_tbl');
SELECT dblink.disconnect('conn_sqlite3');

SELECT dblink.exec('server_sqlite3', 'DROP TABLE IF EXISTS dblink_tbl');
