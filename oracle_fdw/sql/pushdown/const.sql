\c contrib_regression_utf8

EXPLAIN SELECT id FROM number_numeric1 WHERE val = '1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';
SELECT id FROM number_numeric1 WHERE val = '1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';

EXPLAIN (COSTS FALSE) SELECT * FROM tstz9_tstz WHERE val < '2011-02-03 12:34:56.123457 Asia/Tokyo' AND val >= '2011-02-03 12:34:56.123456 Asia/Tokyo';
SELECT * FROM tstz9_tstz WHERE val >= '2011-02-03 12:34:56.123456 Asia/Tokyo' AND val < '2011-02-03 12:34:56.123457 Asia/Tokyo';
SELECT * FROM tstz9_tstz WHERE val = '2011-02-03 12:34:56.123456 Asia/Tokyo';
SELECT * FROM tstz9_tstz WHERE val = '2011-02-03 12:34:56.123457 Asia/Tokyo';

\q
EXPLAIN SELECT val_date1 FROM t_pushdown2 WHERE val_intervalym =
'-1 years -1 mons';
EXPLAIN SELECT val_date1 FROM t_pushdown2 WHERE val_intervalym =
'1 years -1 mons';
EXPLAIN SELECT val_date1 FROM t_pushdown2 WHERE val_intervalym =
'1 mons 1 day';
SELECT val_date1 FROM t_pushdown2 WHERE val_intervalym =
'-1 years -1 mons';

SET timezone = 'Japan';
EXPLAIN SELECT val_date1 FROM t_pushdown2 WHERE val_date1 = 'infinity';
SELECT val_date1 FROM t_pushdown2 WHERE val_date1 = 'infinity';
EXPLAIN SELECT val_date1 FROM t_pushdown2 WHERE val_date1 = '-infinity';
SELECT val_date1 FROM t_pushdown2 WHERE val_date1 = '-infinity';
EXPLAIN SELECT val_date1 FROM t_pushdown2 WHERE val_date1 = '2011-01-02 BC';
SELECT val_date1 FROM t_pushdown2 WHERE val_date1 = '2011-01-02 BC';
EXPLAIN SELECT val_date1 FROM t_pushdown2 WHERE val_date2 = '2011-01-02 BC 12:34:56';
SELECT val_date1 FROM t_pushdown2 WHERE val_date2 = '2011-01-02 BC 12:34:56';
EXPLAIN SELECT val_date1 FROM t_pushdown2 WHERE val_timestamp = '2011-01-02 BC 12:34:56.123456';
SELECT val_date1 FROM t_pushdown2 WHERE val_timestamp = '2011-01-02 BC 12:34:56.123456';
EXPLAIN SELECT val_date1 FROM t_pushdown2 WHERE val_timestamptz = '2011-01-02 12:34:56.123456 Japan BC';
SELECT val_date1 FROM t_pushdown2 WHERE val_timestamptz = '2011-01-02 12:34:56.123456 Japan BC';
EXPLAIN SELECT val_date1 FROM t_pushdown2 WHERE val_timestampltz = '2011-01-02 BC 12:34:56.123456 Japan';
SELECT val_date1 FROM t_pushdown2 WHERE val_timestampltz = '2011-01-02 BC 12:34:56.123456 Japan';
EXPLAIN SELECT val_date1 FROM t_pushdown2 WHERE val_intervalym = '-177999999 year -11 month';
SELECT val_date1 FROM t_pushdown2 WHERE val_intervalym = '-177999999 year -11 month';
EXPLAIN SELECT val_date1 FROM t_pushdown2 WHERE val_intervalds = '-999999999 day -23:59:59.999999';
SELECT val_date1 FROM t_pushdown2 WHERE val_intervalds = '-999999999 day -23:59:59.999999';

EXPLAIN SELECT val_date1 FROM t_pushdown2 WHERE val_timestamptz = '2011-01-02 12:34:56.123456 Japan BC';
SELECT val_date1 FROM t_pushdown2 WHERE val_timestamptz = '2011-01-02 12:34:56.123456 Japan BC';
EXPLAIN SELECT val_date1 FROM t_pushdown2 WHERE val_timestampltz = '2011-01-02 BC 12:34:56.123456 Japan';
SELECT val_date1 FROM t_pushdown2 WHERE val_timestampltz = '2011-01-02 BC 12:34:56.123456 Japan';

EXPLAIN SELECT * FROM t_pushdown_num WHERE val_binary_float = 'nan'::real AND val_binary_double = 'nan';
SELECT * FROM t_pushdown_num WHERE val_binary_float = 'nan'::real AND val_binary_double = 'nan';
EXPLAIN SELECT * FROM t_pushdown_num WHERE val_binary_float = 'nan' AND val_binary_double = 'nan';
SELECT * FROM t_pushdown_num WHERE val_binary_float = 'nan' AND val_binary_double = 'nan';
EXPLAIN SELECT * FROM t_pushdown_num WHERE val_binary_float = 'infinity'::real AND val_binary_double = 'infinity';
SELECT * FROM t_pushdown_num WHERE val_binary_float = 'infinity'::real AND val_binary_double = 'infinity';
EXPLAIN SELECT * FROM t_pushdown_num WHERE val_binary_float = 'infinity' AND val_binary_double = 'infinity';
SELECT * FROM t_pushdown_num WHERE val_binary_float = 'infinity' AND val_binary_double = 'infinity';
EXPLAIN SELECT * FROM t_pushdown_num WHERE val_binary_float = '-infinity'::real AND val_binary_double = '-infinity';
SELECT * FROM t_pushdown_num WHERE val_binary_float = '-infinity'::real AND val_binary_double = '-infinity';
EXPLAIN SELECT * FROM t_pushdown_num WHERE val_binary_float = '-infinity' AND val_binary_double = '-infinity';
SELECT * FROM t_pushdown_num WHERE val_binary_float = '-infinity' AND val_binary_double = '-infinity';
