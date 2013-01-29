\c contrib_regression_utf8

SET DateStyle = 'ISO,YMD';
SET IntervalStyle = 'sql_standard';
SET TIMEZONE = 'Asia/Tokyo';

-- '-' operator
-- 180 : int2mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 - 1::smallint = 0;
-- 181 : int4mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 - 1::integer = 0;
-- 182 : int24mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 - 1::integer = 0;
-- 183 : int42mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 - 1::smallint = 0;
-- 205 : float4mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_float_real_1 - 1.1::real < -1;
-- 206 : float4um
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE - binary_float_real_1 = -1;
-- 212 : int4um
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE - number_integer_1 = -1;
-- 213 : int2um
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE - number_smallint_1 = -1;
-- 219 : float8mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_double_precision_1 - 1.1::double precision < -1;
-- 220 : float8um
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE - binary_double_precision_1 = -1;
-- 282 : float48mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_float_real_1 - 1.1::double precision < -1;
-- 286 : float84mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_double_precision_1 - 1.1::real < -1;
-- 462 : int8um
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE - number_bigint_1 = -1;
-- 464 : int8mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 - 1::bigint = 0;
-- 838 : int82mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 - 1::smallint = 0;
-- 942 : int28mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 - 1::bigint = 0;
-- 1275 : int84mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 - 1::integer = 0;
-- 1279 : int48mi
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 - 1::bigint = 0;
-- 1725 : numeric_sub
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric3_1 - 1.1::numeric = -0.1;
-- 1771 : numeric_uminus
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE - number_numeric3_1 = -1.0;

EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_float_real_1 - 1.1 < -1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_double_precision_1 - 1.1 < -1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 - 1 = 0;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 - 1 = 0;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 - 1 = 0;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric1_1 - 1e100 = 0;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric2_1 - 1e-100 = 0;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric3_1 - 1.1 = -0.1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE float_numeric1_1 - 1.1 = -0.1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE float_numeric2_1 - 1.1 = -0.1;

EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_float_real_1 - '1.1' < -1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_double_precision_1 - '1.1' < -1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 - '1' = 0;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 - '1' = 0;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 - '1' = 0;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric1_1 - '1e100' = 0;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric2_1 - '1e-100' = 0;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric3_1 - '1.1' = -0.1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE float_numeric1_1 - '1.1' = -0.1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE float_numeric2_1 - '1.1' = -0.1;

-- 180 : int2mi
SELECT id FROM all_type WHERE number_smallint_1 - 1::smallint = 0;
-- 181 : int4mi
SELECT id FROM all_type WHERE number_integer_1 - 1::integer = 0;
-- 182 : int24mi
SELECT id FROM all_type WHERE number_smallint_1 - 1::integer = 0;
-- 183 : int42mi
SELECT id FROM all_type WHERE number_integer_1 - 1::smallint = 0;
-- 205 : float4mi
SELECT id FROM all_type WHERE binary_float_real_1 - 1.1::real < -1;
-- 206 : float4um
SELECT id FROM all_type WHERE - binary_float_real_1 = -1;
-- 212 : int4um
SELECT id FROM all_type WHERE - number_integer_1 = -1;
-- 213 : int2um
SELECT id FROM all_type WHERE - number_smallint_1 = -1;
-- 219 : float8mi
SELECT id FROM all_type WHERE binary_double_precision_1 - 1.1::double precision < -1;
-- 220 : float8um
SELECT id FROM all_type WHERE - binary_double_precision_1 = -1;
-- 282 : float48mi
SELECT id FROM all_type WHERE binary_float_real_1 - 1.1::double precision < -1;
-- 286 : float84mi
SELECT id FROM all_type WHERE binary_double_precision_1 - 1.1::real < -1;
-- 462 : int8um
SELECT id FROM all_type WHERE - number_bigint_1 = -1;
-- 464 : int8mi
SELECT id FROM all_type WHERE number_bigint_1 - 1::bigint = 0;
-- 838 : int82mi
SELECT id FROM all_type WHERE number_bigint_1 - 1::smallint = 0;
-- 942 : int28mi
SELECT id FROM all_type WHERE number_smallint_1 - 1::bigint = 0;
-- 1275 : int84mi
SELECT id FROM all_type WHERE number_bigint_1 - 1::integer = 0;
-- 1279 : int48mi
SELECT id FROM all_type WHERE number_integer_1 - 1::bigint = 0;
-- 1725 : numeric_sub
SELECT id FROM all_type WHERE number_numeric3_1 - 1.1::numeric = -0.1;
-- 1771 : numeric_uminus
SELECT id FROM all_type WHERE - number_numeric3_1 = -1.0;

SELECT id FROM all_type WHERE binary_float_real_1 - 1.1 < -1;
SELECT id FROM all_type WHERE binary_double_precision_1 - 1.1 < -1;
SELECT id FROM all_type WHERE number_smallint_1 - 1 = 0;
SELECT id FROM all_type WHERE number_integer_1 - 1 = 0;
SELECT id FROM all_type WHERE number_bigint_1 - 1 = 0;
SELECT id FROM all_type WHERE number_numeric1_1 - 1e100 = 0;
SELECT id FROM all_type WHERE number_numeric2_1 - 1e-100 = 0;
SELECT id FROM all_type WHERE number_numeric3_1 - 1.1 = -0.1;
SELECT id FROM all_type WHERE float_numeric1_1 - 1.1 = -0.1;
SELECT id FROM all_type WHERE float_numeric2_1 - 1.1 = -0.1;

SELECT id FROM all_type WHERE binary_float_real_1 - '1.1' < -1;
SELECT id FROM all_type WHERE binary_double_precision_1 - '1.1' < -1;
SELECT id FROM all_type WHERE number_smallint_1 - '1' = 0;
SELECT id FROM all_type WHERE number_integer_1 - '1' = 0;
SELECT id FROM all_type WHERE number_bigint_1 - '1' = 0;
SELECT id FROM all_type WHERE number_numeric1_1 - '1e100' = 0;
SELECT id FROM all_type WHERE number_numeric2_1 - '1e-100' = 0;
SELECT id FROM all_type WHERE number_numeric3_1 - '1.1' = -0.1;
SELECT id FROM all_type WHERE float_numeric1_1 - '1.1' = -0.1;
SELECT id FROM all_type WHERE float_numeric2_1 - '1.1' = -0.1;

