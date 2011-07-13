CREATE FOREIGN DATA WRAPPER mysql VALIDATOR dblink.mysql;
CREATE SERVER server_mysql FOREIGN DATA WRAPPER mysql OPTIONS (dbname 'mysql');
CREATE USER MAPPING FOR CURRENT_USER SERVER server_mysql OPTIONS (user 'root', password 'mysql');

SELECT dblink.connect('conn_mysql', 'server_mysql', false);
SELECT dblink.exec('conn_mysql', 'DROP TABLE IF EXISTS dblink_tbl');
SELECT dblink.exec('conn_mysql', 'CREATE TABLE dblink_tbl (id integer, value text) ENGINE = InnoDB');
SELECT dblink.disconnect('conn_mysql');

-- dblink.connect()
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
SELECT dblink.connect('conn_mysql', 'server_mysql');
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;

-- dblink.exec() with an existing connection
SELECT dblink.exec('conn_mysql', 'INSERT INTO dblink_tbl VALUES(1, ''X'')');
SELECT dblink.exec('conn_mysql', 'INSERT INTO dblink_tbl VALUES(2, ''BB'')');
SELECT dblink.exec('conn_mysql', 'INSERT INTO dblink_tbl VALUES(3, ''CCC'')');
SELECT dblink.exec('conn_mysql', 'INSERT INTO dblink_tbl VALUES(4, ''DDDD'')');

SELECT * FROM dblink.query('conn_mysql', 'SELECT * FROM dblink_tbl ORDER BY id') AS (id integer, value text);

BEGIN;
SELECT dblink.exec('conn_mysql', 'UPDATE dblink_tbl SET value = ''A'' WHERE id = 1');
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
ROLLBACK;

SELECT * FROM dblink.query('conn_mysql', 'SELECT * FROM dblink_tbl ORDER BY id') AS (id integer, value text);

BEGIN;
SELECT dblink.exec('conn_mysql', 'UPDATE dblink_tbl SET value = ''A'' WHERE id = 1');
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
COMMIT;

SELECT * FROM dblink.query('conn_mysql', 'SELECT * FROM dblink_tbl ORDER BY id') AS (id integer, value text);

-- dblink.query() with an existing connection
BEGIN;
SELECT * FROM dblink.query('conn_mysql', 'SELECT * FROM dblink_tbl ORDER BY id') AS t(id integer, value text) ORDER BY id;
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
COMMIT;

-- dblink.open() with an existing connection
SELECT * FROM dblink.cursor_test(dblink.open('conn_mysql', 'SELECT * FROM dblink_tbl ORDER BY id'), 100);
SELECT * FROM dblink.cursor_test(dblink.open('conn_mysql', 'SELECT * FROM dblink_tbl ORDER BY id'), 2);
SELECT * FROM dblink.cursor_test(dblink.open('conn_mysql', 'SELECT * FROM dblink_tbl ORDER BY id'), 1);

-- dblink.disconnect()
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
SELECT dblink.disconnect('conn_mysql');
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;

-- dblink.query() with an anonymous connection
BEGIN;
SELECT * FROM dblink.query('server_mysql', 'SELECT * FROM dblink_tbl ORDER BY id') AS t(id integer, value text) ORDER BY id;
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
COMMIT;
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;

-- dblink.exec() with an anonymous connection
BEGIN;
SELECT dblink.exec('server_mysql', 'UPDATE dblink_tbl SET value = value WHERE id < 3');
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;
COMMIT;
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;

-- dblink.open() with an anonymous connection
SELECT * FROM dblink.cursor_test(dblink.open('server_mysql', 'SELECT * FROM dblink_tbl ORDER BY id'), 100);
SELECT * FROM dblink.cursor_test(dblink.open('server_mysql', 'SELECT * FROM dblink_tbl ORDER BY id'), 2);
SELECT * FROM dblink.cursor_test(dblink.open('server_mysql', 'SELECT * FROM dblink_tbl ORDER BY id'), 1);
SELECT name, srvname, status, keep FROM dblink.connections, pg_foreign_server WHERE server = oid;

-- dblink.query() with max_value_len option
SELECT * FROM dblink.query('server_mysql', 'SELECT * FROM dblink_tbl ORDER BY id', 0, 1) AS (id integer, value text);

-- dblink.open() with max_value_len option
SELECT * FROM dblink.cursor_test(dblink.open('server_mysql', 'SELECT * FROM dblink_tbl ORDER BY id', 100, 1), 100);

-- connection without automatic transaction management
SELECT dblink.connect('conn_mysql', 'server_mysql', false);
SELECT dblink.exec('conn_mysql', 'DROP TABLE IF EXISTS dblink_tbl');
SELECT dblink.disconnect('conn_mysql');

