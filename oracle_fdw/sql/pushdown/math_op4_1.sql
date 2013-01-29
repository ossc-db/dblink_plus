\c contrib_regression_utf8

SET DateStyle = 'ISO,YMD';
SET IntervalStyle = 'sql_standard';
SET TIMEZONE = 'Asia/Tokyo';

-- '/' operator
-- 153 : int2div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 / -1::smallint = 1;
-- 154 : int4div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 / -1::integer = 1;
-- 172 : int24div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 / -1::integer = 1;
-- 173 : int42div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 / -1::smallint = 1;
-- 203 : float4div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_float_real_1 / -0.5::real = -2;
-- 217 : float8div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_double_precision_1 / -0.5::double precision = -2;
-- 280 : float48div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_float_real_1 / -0.5::double precision = -2;
-- 284 : float84div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_double_precision_1 / -0.5::real = -2;
-- 466 : int8div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 / -1::bigint = 1;
-- 840 : int82div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 / -1::smallint = 1;
-- 948 : int28div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 / -1::bigint = 1;
-- 1277 : int84div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 / -1::integer = 1;
-- 1281 : int48div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 / -1::bigint = 1;
-- 1727 : numeric_div
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric3_1 / -0.5::numeric = -2;

EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_float_real_1 / -0.5 = -2;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_double_precision_1 / -0.5 = -2;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 / -1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 / -1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 / -1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric1_1 / -1 = 1e100;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric2_1 / -1 = 1e-100;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric3_1 / -1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE float_numeric1_1 / -0.5 = -2;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE float_numeric2_1 / -0.5 = -2;

EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_float_real_1 / '-0.5' = -2;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_double_precision_1 / '-0.5' = -2;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 / '-1' = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 / '-1' = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 / '-1' = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric1_1 / '-1' = 1e100;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric2_1 / '-1' = 1e-100;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric3_1 / '-0.5' = -2;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE float_numeric1_1 / '-0.5' = -2;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE float_numeric2_1 / '-0.5' = -2;

-- 153 : int2div
SELECT id FROM all_type WHERE number_smallint_1 / -1::smallint = 1;
-- 154 : int4div
SELECT id FROM all_type WHERE number_integer_1 / -1::integer = 1;
-- 172 : int24div
SELECT id FROM all_type WHERE number_smallint_1 / -1::integer = 1;
-- 173 : int42div
SELECT id FROM all_type WHERE number_integer_1 / -1::smallint = 1;
-- 203 : float4div
SELECT id FROM all_type WHERE binary_float_real_1 / -0.5::real = -2;
-- 217 : float8div
SELECT id FROM all_type WHERE binary_double_precision_1 / -0.5::double precision = -2;
-- 280 : float48div
SELECT id FROM all_type WHERE binary_float_real_1 / -0.5::double precision = -2;
-- 284 : float84div
SELECT id FROM all_type WHERE binary_double_precision_1 / -0.5::real = -2;
-- 466 : int8div
SELECT id FROM all_type WHERE number_bigint_1 / -1::bigint = 1;
-- 840 : int82div
SELECT id FROM all_type WHERE number_bigint_1 / -1::smallint = 1;
-- 948 : int28div
SELECT id FROM all_type WHERE number_smallint_1 / -1::bigint = 1;
-- 1277 : int84div
SELECT id FROM all_type WHERE number_bigint_1 / -1::integer = 1;
-- 1281 : int48div
SELECT id FROM all_type WHERE number_integer_1 / -1::bigint = 1;
-- 1727 : numeric_div
SELECT id FROM all_type WHERE number_numeric3_1 / -0.5::numeric = -2;

SELECT id FROM all_type WHERE binary_float_real_1 / -0.5 = -2;
SELECT id FROM all_type WHERE binary_double_precision_1 / -0.5 = -2;
SELECT id FROM all_type WHERE number_smallint_1 / -1 = 1;
SELECT id FROM all_type WHERE number_integer_1 / -1 = 1;
SELECT id FROM all_type WHERE number_bigint_1 / -1 = 1;
SELECT id FROM all_type WHERE number_numeric1_1 / -1 = 1e100;
SELECT id FROM all_type WHERE number_numeric2_1 / -1 = 1e-100;
SELECT id FROM all_type WHERE number_numeric3_1 / -1 = 1;
SELECT id FROM all_type WHERE float_numeric1_1 / -0.5 = -2;
SELECT id FROM all_type WHERE float_numeric2_1 / -0.5 = -2;

SELECT id FROM all_type WHERE binary_float_real_1 / '-0.5' = -2;
SELECT id FROM all_type WHERE binary_double_precision_1 / '-0.5' = -2;
SELECT id FROM all_type WHERE number_smallint_1 / '-1' = 1;
SELECT id FROM all_type WHERE number_integer_1 / '-1' = 1;
SELECT id FROM all_type WHERE number_bigint_1 / '-1' = 1;
SELECT id FROM all_type WHERE number_numeric1_1 / '-1' = 1e100;
SELECT id FROM all_type WHERE number_numeric2_1 / '-1' = 1e-100;
SELECT id FROM all_type WHERE number_numeric3_1 / '-0.5' = -2;
SELECT id FROM all_type WHERE float_numeric1_1 / '-0.5' = -2;
SELECT id FROM all_type WHERE float_numeric2_1 / '-0.5' = -2;

