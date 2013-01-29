\c contrib_regression_utf8

SET DateStyle = 'ISO,YMD';
SET IntervalStyle = 'sql_standard';
SET TIMEZONE = 'Asia/Tokyo';

-- interval '/' operator
-- 1326 : interval_div
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val / 1 = '1 year 3 month'::interval;
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val / 2 = '7 month'::interval;
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val / 0.5 = '2 year 6 month'::interval;
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val / 'Inf' = '1 year 3 month'::interval;
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val / 'NaN' = '1 year 3 month'::interval;
SELECT id FROM itym_it WHERE val / 1 = '1 year 3 month'::interval;
SELECT id FROM itym_it WHERE val / 1 = '1 year 3 month'::interval OR dummy();
SELECT id FROM itym_it WHERE val / 2 = '7 month'::interval;
SELECT id FROM itym_it WHERE val / 2 = '7 month 15 day'::interval OR dummy();
SELECT id FROM itym_it WHERE val / 0.5 = '2 year 6 month'::interval;
SELECT id FROM itym_it WHERE val / 0.5 = '2 year 6 month'::interval OR dummy();
SELECT id FROM itym_it WHERE val / 'Inf' = '1 year 3 month'::interval;
SELECT id FROM itym_it WHERE val / 'Inf' = '1 year 3 month'::interval OR dummy();
SELECT id FROM itym_it WHERE val / 'NaN' = '1 year 3 month'::interval;
SELECT id FROM itym_it WHERE val / 'NaN' = '1 year 3 month'::interval OR dummy();

EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val / 1 = '-1 day 12:34:56.123456'::interval;
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val / 2 = '-18:17:28.061728'::interval;
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val / 0.5 = '-73:09:52.246912'::interval;
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val / 'Inf' = '-2 days -25:09:52.246912'::interval;
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val / 'NaN' = '-2 days -25:09:52.246912'::interval;
SELECT id FROM itds6_it WHERE val / 1 = '-1 day 12:34:56.123456'::interval;
SELECT id FROM itds6_it WHERE val / 1 = '-1 day 12:34:56.123456'::interval OR dummy();
SELECT id FROM itds6_it WHERE val / 2 = '-18:17:28.061728'::interval;
SELECT id FROM itds6_it WHERE val / 2 = '-18:17:28.061728'::interval OR dummy();
SELECT id FROM itds6_it WHERE val / 0.5 = '-73:09:52.246912'::interval;
SELECT id FROM itds6_it WHERE val / 0.5 = '-73:09:52.246912'::interval OR dummy();
SELECT id FROM itds6_it WHERE val / 'Inf' = '-2 days -25:09:52.246912'::interval;
SELECT id FROM itds6_it WHERE val / 'Inf' = '-2 days -25:09:52.246912'::interval OR dummy();
SELECT id FROM itds6_it WHERE val / 'NaN' = '-2 days -25:09:52.246912'::interval;
SELECT id FROM itds6_it WHERE val / 'NaN' = '-2 days -25:09:52.246912'::interval OR dummy();

EXPLAIN (COSTS FALSE) SELECT id FROM binary_double_precision WHERE '-1 year -3 month'::interval / val = '-7 month'::interval;
EXPLAIN (COSTS FALSE) SELECT id FROM binary_double_precision WHERE '-1 year'::interval / val = '-6 month'::interval;
EXPLAIN (COSTS FALSE) SELECT id FROM binary_double_precision WHERE '-1 month'::interval / val = '-2 month'::interval;
EXPLAIN (COSTS FALSE) SELECT id FROM binary_double_precision WHERE '-1 day -12:34:56.123456'::interval / val = '-18:17:28.061728'::interval;
EXPLAIN (COSTS FALSE) SELECT id FROM binary_double_precision WHERE '-1 day'::interval / val = '-12:00:00'::interval;
EXPLAIN (COSTS FALSE) SELECT id FROM binary_double_precision WHERE '-1 hour'::interval / val = '-00:30:00'::interval;
EXPLAIN (COSTS FALSE) SELECT id FROM binary_double_precision WHERE '-1 minute'::interval / val = '-00:00:30'::interval;
EXPLAIN (COSTS FALSE) SELECT id FROM binary_double_precision WHERE '-1 second'::interval / val = '-00:00:00.5'::interval;
EXPLAIN (COSTS FALSE) SELECT id FROM binary_double_precision WHERE '-0.000005 second'::interval / val BETWEEN '-00:00:00.000003'::interval AND '-00:00:00.000002'::interval;
SELECT id FROM binary_double_precision WHERE '-1 year -3 month'::interval / val = '-7 month'::interval;
SELECT id FROM binary_double_precision WHERE '-1 year -3 month'::interval / val = '-7 month -15 day'::interval OR dummy();
SELECT id FROM binary_double_precision WHERE '-1 year'::interval / val = '-6 month'::interval;
SELECT id FROM binary_double_precision WHERE '-1 year'::interval / val = '-6 month'::interval OR dummy();
SELECT id FROM binary_double_precision WHERE '-1 month'::interval / val = '-2 month'::interval;
SELECT id FROM binary_double_precision WHERE '-1 month'::interval / val = '-2 month'::interval OR dummy();
SELECT id FROM binary_double_precision WHERE '-1 day -12:34:56.123456'::interval / val = '-18:17:28.061728'::interval;
SELECT id FROM binary_double_precision WHERE '-1 day -12:34:56.123456'::interval / val = '-18:17:28.061728'::interval OR dummy();
SELECT id FROM binary_double_precision WHERE '-1 day'::interval / val = '-12:00:00'::interval;
SELECT id FROM binary_double_precision WHERE '-1 day'::interval / val = '-12:00:00'::interval OR dummy();
SELECT id FROM binary_double_precision WHERE '-1 hour'::interval / val = '-00:30:00'::interval;
SELECT id FROM binary_double_precision WHERE '-1 hour'::interval / val = '-00:30:00'::interval OR dummy();
SELECT id FROM binary_double_precision WHERE '-1 minute'::interval / val = '-00:00:30'::interval;
SELECT id FROM binary_double_precision WHERE '-1 minute'::interval / val = '-00:00:30'::interval OR dummy();
SELECT id FROM binary_double_precision WHERE '-1 second'::interval / val = '-00:00:00.5'::interval;
SELECT id FROM binary_double_precision WHERE '-1 second'::interval / val = '-00:00:00.5'::interval OR dummy();
SELECT id FROM binary_double_precision WHERE '-0.000005 second'::interval / val BETWEEN '-00:00:00.000003'::interval AND '-00:00:00.000002'::interval;
SELECT id FROM binary_double_precision WHERE '-0.000005 second'::interval / val BETWEEN '-00:00:00.000003'::interval AND '-00:00:00.000002'::interval OR dummy();

EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE intervalym_interval_1 / binary_double_precision_1 = '-2 year -4 month'::interval;
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE intervalds6_interval_1 / binary_double_precision_1 = '-2 day -25:09:52.246912'::interval;
SELECT id FROM all_type WHERE intervalym_interval_1 / binary_double_precision_1 = '-2 year -4 month'::interval;
SELECT id FROM all_type WHERE intervalym_interval_1 / binary_double_precision_1 = '-2 year -4 month'::interval OR dummy();
SELECT id FROM all_type WHERE intervalds6_interval_1 / binary_double_precision_1 = '-2 day -25:09:52.246912'::interval;
SELECT id FROM all_type WHERE intervalds6_interval_1 / binary_double_precision_1 = '-2 day -25:09:52.246912'::interval OR dummy();
