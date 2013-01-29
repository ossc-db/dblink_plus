\c contrib_regression_utf8

SET DateStyle = 'ISO,YMD';
SET IntervalStyle = 'sql_standard';
SET TIMEZONE = 'Asia/Tokyo';

EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 / binary_float_real_1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 / binary_double_precision_1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_smallint_1 / number_numeric3_1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 / binary_float_real_1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 / binary_double_precision_1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 / number_numeric3_1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 / binary_float_real_1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 / binary_double_precision_1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_bigint_1 / number_numeric3_1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_float_real_1 / number_smallint_1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_float_real_1 / number_integer_1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_float_real_1 / number_bigint_1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_float_real_1 / number_numeric3_1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_double_precision_1 / number_smallint_1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_double_precision_1 / number_integer_1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_double_precision_1 / number_bigint_1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE binary_double_precision_1 / number_numeric3_1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric3_1 / number_smallint_1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric3_1 / number_integer_1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric3_1 / number_bigint_1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric3_1 / binary_float_real_1 = 1;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_numeric3_1 / binary_double_precision_1 = 1;

SELECT id, number_numeric1_1 FROM all_type WHERE number_numeric1_1 + 1 = 1;
SELECT id, number_numeric2_1 FROM all_type WHERE number_numeric2_1 + 1 = 1;
SELECT id, number_numeric3_1 FROM all_type WHERE number_numeric3_1 + 1 = 1;

