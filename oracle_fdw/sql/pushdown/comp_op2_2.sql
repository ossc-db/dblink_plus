\c contrib_regression_utf8

SET DateStyle = 'ISO,YMD';
SET IntervalStyle = 'sql_standard';
SET TIMEZONE = 'Asia/Tokyo';

-- '<>' operator
EXPLAIN (COSTS FALSE) SELECT * FROM binary_float_real WHERE 0 <> val;
SELECT * FROM binary_float_real WHERE 0 <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM binary_double_precision WHERE 0 <> val;
SELECT * FROM binary_double_precision WHERE 0 <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM number_smallint WHERE 0 <> val;
SELECT * FROM number_smallint WHERE 0 <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM number_integer WHERE 0 <> val;
SELECT * FROM number_integer WHERE 0 <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM number_bigint WHERE 0 <> val;
SELECT * FROM number_bigint WHERE 0 <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM number_numeric1 WHERE 0 <> val;
SELECT * FROM number_numeric1 WHERE 0 <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM number_numeric2 WHERE 0 <> val;
SELECT * FROM number_numeric2 WHERE 0 <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM number_numeric3 WHERE 0 <> val;
SELECT * FROM number_numeric3 WHERE 0 <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM float_numeric1 WHERE 0 <> val;
SELECT * FROM float_numeric1 WHERE 0 <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM float_numeric2 WHERE 0 <> val;
SELECT * FROM float_numeric2 WHERE 0 <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM char_char WHERE 'bBいイ異伊' <> val;
SELECT * FROM char_char WHERE 'bBいイ異伊' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM char_varchar WHERE 'bBいイ異伊' <> val;
SELECT * FROM char_varchar WHERE 'bBいイ異伊' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM char_varchar_ WHERE 'bBいイ異伊' <> val;
SELECT * FROM char_varchar_ WHERE 'bBいイ異伊' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM char_text WHERE 'bBいイ異伊' <> val;
SELECT * FROM char_text WHERE 'bBいイ異伊' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM nchar_char WHERE 'bBいイ異伊' <> val;
SELECT * FROM nchar_char WHERE 'bBいイ異伊' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM nchar_text WHERE 'bBいイ異伊' <> val;
SELECT * FROM nchar_text WHERE 'bBいイ異伊' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM vc2_vc WHERE 'bBいイ異伊' <> val;
SELECT * FROM vc2_vc WHERE 'bBいイ異伊' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM vc2_text WHERE 'bBいイ異伊' <> val;
SELECT * FROM vc2_text WHERE 'bBいイ異伊' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM nvc2_vc WHERE 'bBいイ異伊' <> val;
SELECT * FROM nvc2_vc WHERE 'bBいイ異伊' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM nvc2_text WHERE 'bBいイ異伊' <> val;
SELECT * FROM nvc2_text WHERE 'bBいイ異伊' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM long_vc WHERE 'bBいイ異伊' <> val;
SELECT * FROM long_vc WHERE 'bBいイ異伊' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM long_text WHERE 'bBいイ異伊' <> val;
SELECT * FROM long_text WHERE 'bBいイ異伊' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM clob_vc WHERE 'bBいイ異伊' <> val;
SELECT * FROM clob_vc WHERE 'bBいイ異伊' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM clob_text WHERE 'bBいイ異伊' <> val;
SELECT * FROM clob_text WHERE 'bBいイ異伊' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM nclob_vc WHERE 'bBいイ異伊' <> val;
SELECT * FROM nclob_vc WHERE 'bBいイ異伊' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM nclob_text WHERE 'bBいイ異伊' <> val;
SELECT * FROM nclob_text WHERE 'bBいイ異伊' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM date_date WHERE '0001-01-01' <> val;
SELECT * FROM date_date WHERE '0001-01-01' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM date_timestamp WHERE '0001-01-01 00:00:01' <> val;
SELECT * FROM date_timestamp WHERE '0001-01-01 00:00:01' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM ts6_ts WHERE '0001-01-01 00:00:00.000001' <> val;
SELECT * FROM ts6_ts WHERE '0001-01-01 00:00:00.000001' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM ts9_ts WHERE '0001-01-01 00:00:00.000001' <> val;
SELECT * FROM ts9_ts WHERE '0001-01-01 00:00:00.000001' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM tstz6_tstz WHERE '0001-01-01 00:00:00.000001 Asia/Tokyo' <> val;
SELECT * FROM tstz6_tstz WHERE '0001-01-01 00:00:00.000001 Asia/Tokyo' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM tstz9_tstz WHERE '0001-01-01 00:00:00.000001 Asia/Tokyo' <> val;
SELECT * FROM tstz9_tstz WHERE '0001-01-01 00:00:00.000001 Asia/Tokyo' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM tsltz6_tstz WHERE '0001-01-01 00:00:00.000001 Asia/Tokyo' <> val;
SELECT * FROM tsltz6_tstz WHERE '0001-01-01 00:00:00.000001 Asia/Tokyo' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM tsltz9_tstz WHERE '0001-01-01 00:00:00.000001 Asia/Tokyo' <> val;
SELECT * FROM tsltz9_tstz WHERE '0001-01-01 00:00:00.000001 Asia/Tokyo' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM itym_it WHERE '1 year' <> val;
SELECT * FROM itym_it WHERE '1 year' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM itds6_it WHERE '1 day' <> val;
SELECT * FROM itds6_it WHERE '1 day' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM itds9_it WHERE '1 day' <> val;
SELECT * FROM itds9_it WHERE '1 day' <> val;
EXPLAIN (COSTS FALSE) SELECT id, length(val) FROM rowid_text WHERE 'AAAbx1AAEAAACHoAAA' <> val;
SELECT id, length(val) FROM rowid_text WHERE 'AAAbx1AAEAAACHoAAA' <> val;
EXPLAIN (COSTS FALSE) SELECT id, length(val) FROM urowid_text WHERE '*BAEAj/wCwQL+' <> val;
SELECT id, length(val) FROM urowid_text WHERE '*BAEAj/wCwQL+' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM raw_bytea WHERE E'\\xAABBCC' <> val;
SELECT * FROM raw_bytea WHERE E'\\xAABBCC' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM long_raw_bytea WHERE E'\\xAABBCC' <> val;
SELECT * FROM long_raw_bytea WHERE E'\\xAABBCC' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM blob_bytea WHERE E'\\xAABBCC' <> val;
SELECT * FROM blob_bytea WHERE E'\\xAABBCC' <> val;
EXPLAIN (COSTS FALSE) SELECT * FROM bfile_bytea WHERE E'\\xAABBCC' <> val;
SELECT * FROM bfile_bytea WHERE E'\\xAABBCC' <> val;

