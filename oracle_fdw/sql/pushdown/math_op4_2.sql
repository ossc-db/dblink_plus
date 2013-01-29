\c contrib_regression_utf8

SET DateStyle = 'ISO,YMD';
SET IntervalStyle = 'sql_standard';
SET TIMEZONE = 'Asia/Tokyo';

-- '/' operator
-- 153 : int2div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 <> 0 AND number_smallint_1 / number_smallint_1 = 1;
-- 154 : int4div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 <> 0 AND number_integer_1 / number_integer_1 = 1;
-- 172 : int24div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 <> 0 AND number_smallint_1 / number_integer_1 = 1;
-- 173 : int42div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 <> 0 AND number_integer_1 / number_smallint_1 = 1;
-- 203 : float4div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_float_real_1 <> 0 AND binary_float_real_1 / binary_float_real_1 = 1;
-- 217 : float8div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_double_precision_1 <> 0 AND binary_double_precision_1 / binary_double_precision_1 = 1;
-- 280 : float48div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_double_precision_1 <> 0 AND binary_float_real_1 / binary_double_precision_1 = 1;
-- 284 : float84div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_float_real_1 <> 0 AND binary_double_precision_1 / binary_float_real_1 = 1;
-- 466 : int8div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 <> 0 AND number_bigint_1 / number_bigint_1 = 1;
-- 840 : int82div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 <> 0 AND number_bigint_1 / number_smallint_1 = 1;
-- 948 : int28div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 <> 0 AND number_smallint_1 / number_bigint_1 = 1;
-- 1277 : int84div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 <> 0 AND number_bigint_1 / number_integer_1 = 1;
-- 1281 : int48div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 <> 0 AND number_integer_1 / number_bigint_1 = 1;
-- 1727 : numeric_div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric3_1 <> 0 AND number_numeric3_1 / number_numeric3_1 = 1;

-- 153 : int2div
SELECT id FROM all_type WHERE number_smallint_1 <> 0 AND number_smallint_1 / number_smallint_1 = 1;
-- 154 : int4div
SELECT id FROM all_type WHERE number_integer_1 <> 0 AND number_integer_1 / number_integer_1 = 1;
-- 172 : int24div
SELECT id FROM all_type WHERE number_integer_1 <> 0 AND number_smallint_1 / number_integer_1 = 1;
-- 173 : int42div
SELECT id FROM all_type WHERE number_smallint_1 <> 0 AND number_integer_1 / number_smallint_1 = 1;
-- 203 : float4div
SELECT id FROM all_type WHERE binary_float_real_1 <> 0 AND binary_float_real_1 / binary_float_real_1 = 1;
-- 217 : float8div
SELECT id FROM all_type WHERE binary_double_precision_1 <> 0 AND binary_double_precision_1 / binary_double_precision_1 = 1;
-- 280 : float48div
SELECT id FROM all_type WHERE binary_double_precision_1 <> 0 AND binary_float_real_1 / binary_double_precision_1 = 1;
-- 284 : float84div
SELECT id FROM all_type WHERE binary_float_real_1 <> 0 AND binary_double_precision_1 / binary_float_real_1 = 1;
-- 466 : int8div
SELECT id FROM all_type WHERE number_bigint_1 <> 0 AND number_bigint_1 / number_bigint_1 = 1;
-- 840 : int82div
SELECT id FROM all_type WHERE number_smallint_1 <> 0 AND number_bigint_1 / number_smallint_1 = 1;
-- 948 : int28div
SELECT id FROM all_type WHERE number_bigint_1 <> 0 AND number_smallint_1 / number_bigint_1 = 1;
-- 1277 : int84div
SELECT id FROM all_type WHERE number_integer_1 <> 0 AND number_bigint_1 / number_integer_1 = 1;
-- 1281 : int48div
SELECT id FROM all_type WHERE number_bigint_1 <> 0 AND number_integer_1 / number_bigint_1 = 1;
-- 1727 : numeric_div
SELECT id FROM all_type WHERE number_numeric3_1 <> 0 AND number_numeric3_1 / number_numeric3_1 = 1;

