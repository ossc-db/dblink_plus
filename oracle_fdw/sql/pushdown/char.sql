\c contrib_regression_utf8

CREATE FOREIGN TABLE char10_char10 (id integer, val char(10))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'char10');
CREATE FOREIGN TABLE char10_char2(id integer, val char(2))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'char10');
CREATE FOREIGN TABLE char10_varchar10(id integer, val varchar(10))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'char10');
CREATE FOREIGN TABLE varchar10_varchar10 (id integer, val varchar(10))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'varchar10');
CREATE FOREIGN TABLE varchar10_varchar2 (id integer, val varchar(2))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'varchar10');
CREATE FOREIGN TABLE varchar10_char10 (id integer, val char(10))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'varchar10');
CREATE FOREIGN TABLE mix (
	id			integer,
	char_10		char(10),
	char_2 		char(2),
	varchar_10 	varchar(10),
	varchar_2 	varchar(2)
)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'mix');

SELECT id, val, length(val) FROM char10_char10;
SELECT id, val, length(val) FROM char10_char2;
SELECT id, val, length(val) FROM char10_char2 WHERE id = 5;
SELECT id, val, length(val) FROM char10_varchar10;
SELECT id, val, length(val) FROM varchar10_varchar10;
SELECT id, val, length(val) FROM varchar10_varchar2;
SELECT id, val, length(val) FROM varchar10_varchar2 WHERE id = 5;
SELECT id, val, length(val) FROM varchar10_char10;

EXPLAIN (COSTS FALSE) SELECT * FROM char10_char10 WHERE val = ' ';
EXPLAIN (COSTS FALSE) SELECT * FROM char10_char10 WHERE val = '' OR dummy();
SELECT * FROM char10_char10 WHERE val = 'あいう       ';
SELECT * FROM char10_char10 WHERE val = 'あいう        ';
SELECT * FROM char10_char10 WHERE val = '          ';
SELECT * FROM char10_char10 WHERE val = '           ';
SELECT * FROM char10_char10 WHERE val = 'あいう       ' OR dummy();
SELECT * FROM char10_char10 WHERE val = 'あいう        ' OR dummy();
SELECT * FROM char10_char10 WHERE val = '          ' OR dummy();
SELECT * FROM char10_char10 WHERE val = '           ' OR dummy();

SELECT * FROM char10_varchar10 WHERE val = 'あいう       ';
SELECT * FROM char10_varchar10 WHERE val = 'あいう        ';
SELECT * FROM char10_varchar10 WHERE val = '          ';
SELECT * FROM char10_varchar10 WHERE val = '           ';
SELECT * FROM char10_varchar10 WHERE val = 'あいう       ' OR dummy();
SELECT * FROM char10_varchar10 WHERE val = 'あいう        ' OR dummy();
SELECT * FROM char10_varchar10 WHERE val = '          ' OR dummy();
SELECT * FROM char10_varchar10 WHERE val = '           ' OR dummy();

SELECT * FROM varchar10_varchar10 WHERE val = 'あいう       ';
SELECT * FROM varchar10_varchar10 WHERE val = 'あいう        ';
SELECT * FROM varchar10_varchar10 WHERE val = '          ';
SELECT * FROM varchar10_varchar10 WHERE val = '           ';
SELECT * FROM varchar10_varchar10 WHERE val = 'あいう       ' OR dummy();
SELECT * FROM varchar10_varchar10 WHERE val = 'あいう        ' OR dummy();
SELECT * FROM varchar10_varchar10 WHERE val = '          ' OR dummy();
SELECT * FROM varchar10_varchar10 WHERE val = '           ' OR dummy();

SELECT * FROM varchar10_char10 WHERE val = 'あいう       ';
SELECT * FROM varchar10_char10 WHERE val = 'あいう        ';
SELECT * FROM varchar10_char10 WHERE val = '          ';
SELECT * FROM varchar10_char10 WHERE val = '           ';
SELECT * FROM varchar10_char10 WHERE val = 'あいう       ' OR dummy();
SELECT * FROM varchar10_char10 WHERE val = 'あいう        ' OR dummy();
SELECT * FROM varchar10_char10 WHERE val = '          ' OR dummy();
SELECT * FROM varchar10_char10 WHERE val = '           ' OR dummy();

EXPLAIN (COSTS FALSE) SELECT * FROM mix WHERE char_10 = char_2;
SELECT * FROM mix WHERE char_10 = char_2;
