\c contrib_regression_utf8

SET DateStyle = 'ISO,YMD';
SET IntervalStyle = 'sql_standard';
SET TIMEZONE = 'Asia/Tokyo';

-- '*' operator
-- 141 : int4mul
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 * number_integer_1 = 1;
-- 152 : int2mul
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 * number_smallint_1 = 1;
-- 170 : int24mul
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 * number_integer_1 = 1;
-- 171 : int42mul
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 * number_smallint_1 = 1;
-- 202 : float4mul
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_float_real_1 * binary_float_real_1 = 1;
-- 216 : float8mul
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_double_precision_1 * binary_double_precision_1 = 1;
-- 279 : float48mul
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_float_real_1 * binary_double_precision_1 = 1;
-- 283 : float84mul
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_double_precision_1 * binary_float_real_1 = 1;
-- 465 : int8mul
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 * number_bigint_1 = 1;
-- 839 : int82mul
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 * number_smallint_1 = 1;
-- 943 : int28mul
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 * number_bigint_1 = 1;
-- 1276 : int84mul
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 * number_integer_1 = 1;
-- 1280 : int48mul
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 * number_bigint_1 = 1;
-- 1726 : numeric_mul
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric3_1 * number_numeric3_1 = 1;

-- 141 : int4mul
SELECT id FROM all_type WHERE number_integer_1 * number_integer_1 = 1;
-- 152 : int2mul
SELECT id FROM all_type WHERE number_smallint_1 * number_smallint_1 = 1;
-- 170 : int24mul
SELECT id FROM all_type WHERE number_smallint_1 * number_integer_1 = 1;
-- 171 : int42mul
SELECT id FROM all_type WHERE number_integer_1 * number_smallint_1 = 1;
-- 202 : float4mul
SELECT id FROM all_type WHERE binary_float_real_1 * binary_float_real_1 = 1;
-- 216 : float8mul
SELECT id FROM all_type WHERE binary_double_precision_1 * binary_double_precision_1 = 1;
-- 279 : float48mul
SELECT id FROM all_type WHERE binary_float_real_1 * binary_double_precision_1 = 1;
-- 283 : float84mul
SELECT id FROM all_type WHERE binary_double_precision_1 * binary_float_real_1 = 1;
-- 465 : int8mul
SELECT id FROM all_type WHERE number_bigint_1 * number_bigint_1 = 1;
-- 839 : int82mul
SELECT id FROM all_type WHERE number_bigint_1 * number_smallint_1 = 1;
-- 943 : int28mul
SELECT id FROM all_type WHERE number_smallint_1 * number_bigint_1 = 1;
-- 1276 : int84mul
SELECT id FROM all_type WHERE number_bigint_1 * number_integer_1 = 1;
-- 1280 : int48mul
SELECT id FROM all_type WHERE number_integer_1 * number_bigint_1 = 1;
-- 1726 : numeric_mul
SELECT id FROM all_type WHERE number_numeric3_1 * number_numeric3_1 = 1;
