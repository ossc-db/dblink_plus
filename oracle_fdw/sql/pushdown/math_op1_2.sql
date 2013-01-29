\c contrib_regression_utf8

SET DateStyle = 'ISO,YMD';
SET IntervalStyle = 'sql_standard';
SET TIMEZONE = 'Asia/Tokyo';

-- '+' operator
-- 176 : int2pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 + number_smallint_1 >= 0;
-- 177 : int4pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 + number_integer_1 >= 0;
-- 178 : int24pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 + number_integer_1 >= 0;
-- 179 : int42pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 + number_smallint_1 >= 0;
-- 204 : float4pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_float_real_1 + binary_float_real_1 >= 0;
-- 218 : float8pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_double_precision_1 + binary_double_precision_1 >= 0;
-- 281 : float48pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_float_real_1 + binary_double_precision_1 >= 0;
-- 285 : float84pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_double_precision_1 + binary_float_real_1 >= 0;
-- 463 : int8pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 + number_bigint_1 >= 0;
-- 837 : int82pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 + number_smallint_1 >= 0;
-- 841 : int28pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 + number_bigint_1 >= 0;
-- 1274 : int84pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 + number_integer_1 >= 0;
-- 1278 : int48pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 + number_bigint_1 >= 0;
-- 1724 : numeric_add
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric3_1 + number_numeric3_1 >= 0;
-- 1910 : int8up
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE + number_bigint_1 >= 0;
-- 1911 : int2up
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE + number_smallint_1 >= 0;
-- 1912 : int4up
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE + number_integer_1 >= 0;
-- 1913 : float4up
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE + binary_float_real_1 >= 0;
-- 1914 : float8up
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE + binary_double_precision_1 >= 0;
-- 1915 : numeric_uplus
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE + number_numeric3_1 >= 0;

-- 176 : int2pl
SELECT id FROM all_type WHERE number_smallint_1 + number_smallint_1 >= 0;
-- 177 : int4pl
SELECT id FROM all_type WHERE number_integer_1 + number_integer_1 >= 0;
-- 178 : int24pl
SELECT id FROM all_type WHERE number_smallint_1 + number_integer_1 >= 0;
-- 179 : int42pl
SELECT id FROM all_type WHERE number_integer_1 + number_smallint_1 >= 0;
-- 204 : float4pl
SELECT id FROM all_type WHERE binary_float_real_1 + binary_float_real_1 >= 0;
-- 218 : float8pl
SELECT id FROM all_type WHERE binary_double_precision_1 + binary_double_precision_1 >= 0;
-- 281 : float48pl
SELECT id FROM all_type WHERE binary_float_real_1 + binary_double_precision_1 >= 0;
-- 285 : float84pl
SELECT id FROM all_type WHERE binary_double_precision_1 + binary_float_real_1 >= 0;
-- 463 : int8pl
SELECT id FROM all_type WHERE number_bigint_1 + number_bigint_1 >= 0;
-- 837 : int82pl
SELECT id FROM all_type WHERE number_bigint_1 + number_smallint_1 >= 0;
-- 841 : int28pl
SELECT id FROM all_type WHERE number_smallint_1 + number_bigint_1 >= 0;
-- 1274 : int84pl
SELECT id FROM all_type WHERE number_bigint_1 + number_integer_1 >= 0;
-- 1278 : int48pl
SELECT id FROM all_type WHERE number_integer_1 + number_bigint_1 >= 0;
-- 1724 : numeric_add
SELECT id FROM all_type WHERE number_numeric3_1 + number_numeric3_1 >= 0;
-- 1910 : int8up
SELECT id FROM all_type WHERE + number_bigint_1 >= 0;
-- 1911 : int2up
SELECT id FROM all_type WHERE + number_smallint_1 >= 0;
-- 1912 : int4up
SELECT id FROM all_type WHERE + number_integer_1 >= 0;
-- 1913 : float4up
SELECT id FROM all_type WHERE + binary_float_real_1 >= 0;
-- 1914 : float8up
SELECT id FROM all_type WHERE + binary_double_precision_1 >= 0;
-- 1915 : numeric_uplus
SELECT id FROM all_type WHERE + number_numeric3_1 >= 0;

