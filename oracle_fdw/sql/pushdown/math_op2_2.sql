\c contrib_regression_utf8

SET DateStyle = 'ISO,YMD';
SET IntervalStyle = 'sql_standard';
SET TIMEZONE = 'Asia/Tokyo';

-- '-' operator
-- 180 : int2mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 - number_smallint_1 = 0;
-- 181 : int4mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 - number_integer_1 = 0;
-- 182 : int24mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 - number_integer_1 = 0;
-- 183 : int42mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 - number_smallint_1 = 0;
-- 205 : float4mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_float_real_1 - binary_float_real_1 = 0;
-- 206 : float4um
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE - binary_float_real_1 = -1;
-- 212 : int4um
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE - number_integer_1 = -1;
-- 213 : int2um
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE - number_smallint_1 = -1;
-- 219 : float8mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_double_precision_1 - binary_double_precision_1 = 0;
-- 220 : float8um
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE - binary_double_precision_1 = -1;
-- 282 : float48mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_float_real_1 - binary_double_precision_1 = 0;
-- 286 : float84m
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_double_precision_1 - binary_float_real_1 = 0;
-- 462 : int8um
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE - number_bigint_1 = -1;
-- 464 : int8mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 - number_bigint_1 = 0;
-- 838 : int82mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 - number_smallint_1 = 0;
-- 942 : int28mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 - number_bigint_1 = 0;
-- 1275 : int84mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 - number_integer_1 = 0;
-- 1279 : int48mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 - number_bigint_1 = 0;
-- 1725 : numeric_sub
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric3_1 - number_numeric3_1 = 0;
-- 1771 : numeric_uminus
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE - number_numeric3_1 = -1;

-- 180 : int2mi
SELECT id FROM all_type WHERE number_smallint_1 - number_smallint_1 = 0;
-- 181 : int4mi
SELECT id FROM all_type WHERE number_integer_1 - number_integer_1 = 0;
-- 182 : int24mi
SELECT id FROM all_type WHERE number_smallint_1 - number_integer_1 = 0;
-- 183 : int42mi
SELECT id FROM all_type WHERE number_integer_1 - number_smallint_1 = 0;
-- 205 : float4mi
SELECT id FROM all_type WHERE binary_float_real_1 - binary_float_real_1 = 0;
-- 206 : float4um
SELECT id FROM all_type WHERE - binary_float_real_1 = -1;
-- 212 : int4um
SELECT id FROM all_type WHERE - number_integer_1 = -1;
-- 213 : int2um
SELECT id FROM all_type WHERE - number_smallint_1 = -1;
-- 219 : float8mi
SELECT id FROM all_type WHERE binary_double_precision_1 - binary_double_precision_1 = 0;
-- 220 : float8um
SELECT id FROM all_type WHERE - binary_double_precision_1 = -1;
-- 282 : float48mi
SELECT id FROM all_type WHERE binary_float_real_1 - binary_double_precision_1 = 0;
-- 286 : float84m
SELECT id FROM all_type WHERE binary_double_precision_1 - binary_float_real_1 = 0;
-- 462 : int8um
SELECT id FROM all_type WHERE - number_bigint_1 = -1;
-- 464 : int8mi
SELECT id FROM all_type WHERE number_bigint_1 - number_bigint_1 = 0;
-- 838 : int82mi
SELECT id FROM all_type WHERE number_bigint_1 - number_smallint_1 = 0;
-- 942 : int28mi
SELECT id FROM all_type WHERE number_smallint_1 - number_bigint_1 = 0;
-- 1275 : int84mi
SELECT id FROM all_type WHERE number_bigint_1 - number_integer_1 = 0;
-- 1279 : int48mi
SELECT id FROM all_type WHERE number_integer_1 - number_bigint_1 = 0;
-- 1725 : numeric_sub
SELECT id FROM all_type WHERE number_numeric3_1 - number_numeric3_1 = 0;
-- 1771 : numeric_uminus
SELECT id FROM all_type WHERE - number_numeric3_1 = -1;

