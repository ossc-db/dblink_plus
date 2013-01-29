\c contrib_regression_utf8

SET DateStyle = 'ISO,YMD';
SET IntervalStyle = 'sql_standard';
SET TIMEZONE = 'Asia/Tokyo';

-- '+' operator
-- 176 : int2pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 + 1::smallint = 1;
-- 177 : int4pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 + 1::integer = 1;
-- 178 : int24pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 + 1::integer = 1;
-- 179 : int42pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 + 1::smallint = 1;
-- 204 : float4pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_float_real_1 + 1.1::real = 1.1;
-- 218 : float8pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_double_precision_1 + 1.1::double precision = 1.1;
-- 281 : float48pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_float_real_1 + 1.1::double precision = 1.1;
-- 285 : float84pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_double_precision_1 + 1.1::real = 1.1;
-- 463 : int8pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 + 1::bigint = 1;
-- 837 : int82pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 + 1::smallint = 1;
-- 841 : int28pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 + 1::bigint = 1;
-- 1274 : int84pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 + 1::integer = 1;
-- 1278 : int48pl
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 + 1::bigint = 1;
-- 1724 : numeric_add
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric3_1 + 1.1::numeric = 1.1;
-- 1910 : int8up
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE + number_bigint_1 = 1;
-- 1911 : int2up
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE + number_smallint_1 = 1;
-- 1912 : int4up
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE + number_integer_1 = 1;
-- 1913 : float4up
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE + binary_float_real_1 = 1.0;
-- 1914 : float8up
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE + binary_double_precision_1 = 1.0;
-- 1915 : numeric_uplus
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE + number_numeric3_1 = 1.0;

EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_float_real_1 + 1.1 = 1.1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_double_precision_1 + 1.1 = 1.1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 + 1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 + 1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 + 1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric1_1 + 1.1 = 1.1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric2_1 + 1.1 = 1.1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric3_1 + 1.1 = 1.1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE float_numeric1_1 + 1.1 = 1.1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE float_numeric2_1 + 1.1 = 1.1;

EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_float_real_1 + '1.1' = 1.1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_double_precision_1 + '1.1' = 1.1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 + '1' = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 + '1' = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 + '1' = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric1_1 + '1.1' = 1.1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric2_1 + '1.1' = 1.1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric3_1 + '1.1' = 1.1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE float_numeric1_1 + '1.1' = 1.1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE float_numeric2_1 + '1.1' = 1.1;

-- 176 : int2pl
SELECT id FROM all_type WHERE number_smallint_1 + 1::smallint = 1;
-- 177 : int4pl
SELECT id FROM all_type WHERE number_integer_1 + 1::integer = 1;
-- 178 : int24pl
SELECT id FROM all_type WHERE number_smallint_1 + 1::integer = 1;
-- 179 : int42pl
SELECT id FROM all_type WHERE number_integer_1 + 1::smallint = 1;
-- 204 : float4pl
SELECT id FROM all_type WHERE binary_float_real_1 + 1.1::real = 1.1;
-- 218 : float8pl
SELECT id FROM all_type WHERE binary_double_precision_1 + 1.1::double precision = 1.1;
-- 281 : float48pl
SELECT id FROM all_type WHERE binary_float_real_1 + 1.1::double precision = 1.1;
-- 285 : float84pl
SELECT id FROM all_type WHERE binary_double_precision_1 + 1.1::real = 1.1;
-- 463 : int8pl
SELECT id FROM all_type WHERE number_bigint_1 + 1::bigint = 1;
-- 837 : int82pl
SELECT id FROM all_type WHERE number_bigint_1 + 1::smallint = 1;
-- 841 : int28pl
SELECT id FROM all_type WHERE number_smallint_1 + 1::bigint = 1;
-- 1274 : int84pl
SELECT id FROM all_type WHERE number_bigint_1 + 1::integer = 1;
-- 1278 : int48pl
SELECT id FROM all_type WHERE number_integer_1 + 1::bigint = 1;
-- 1724 : numeric_add
SELECT id FROM all_type WHERE number_numeric3_1 + 1.1::numeric = 1.1;
-- 1910 : int8up
SELECT id FROM all_type WHERE + number_bigint_1 = 1;
-- 1911 : int2up
SELECT id FROM all_type WHERE + number_smallint_1 = 1;
-- 1912 : int4up
SELECT id FROM all_type WHERE + number_integer_1 = 1;
-- 1913 : float4up
SELECT id FROM all_type WHERE + binary_float_real_1 = 1.0;
-- 1914 : float8up
SELECT id FROM all_type WHERE + binary_double_precision_1 = 1.0;
-- 1915 : numeric_uplus
SELECT id FROM all_type WHERE + number_numeric3_1 = 1.0;

SELECT id FROM all_type WHERE binary_float_real_1 + 1.1 = 1.1;
SELECT id FROM all_type WHERE binary_double_precision_1 + 1.1 = 1.1;
SELECT id FROM all_type WHERE number_smallint_1 + 1 = 1;
SELECT id FROM all_type WHERE number_integer_1 + 1 = 1;
SELECT id FROM all_type WHERE number_bigint_1 + 1 = 1;
SELECT id FROM all_type WHERE number_numeric1_1 + 1.1 = 1.1;
SELECT id FROM all_type WHERE number_numeric2_1 + 1.1 = 1.1;
SELECT id FROM all_type WHERE number_numeric3_1 + 1.1 = 1.1;
SELECT id FROM all_type WHERE float_numeric1_1 + 1.1 = 1.1;
SELECT id FROM all_type WHERE float_numeric2_1 + 1.1 = 1.1;

SELECT id FROM all_type WHERE binary_float_real_1 + '1.1' = 1.1;
SELECT id FROM all_type WHERE binary_double_precision_1 + '1.1' = 1.1;
SELECT id FROM all_type WHERE number_smallint_1 + '1' = 1;
SELECT id FROM all_type WHERE number_integer_1 + '1' = 1;
SELECT id FROM all_type WHERE number_bigint_1 + '1' = 1;
SELECT id FROM all_type WHERE number_numeric1_1 + '1.1' = 1.1;
SELECT id FROM all_type WHERE number_numeric2_1 + '1.1' = 1.1;
SELECT id FROM all_type WHERE number_numeric3_1 + '1.1' = 1.1;
SELECT id FROM all_type WHERE float_numeric1_1 + '1.1' = 1.1;
SELECT id FROM all_type WHERE float_numeric2_1 + '1.1' = 1.1;

