\c contrib_regression_utf8

SET DateStyle = 'ISO,YMD';
SET IntervalStyle = 'sql_standard';
SET TIMEZONE = 'Asia/Tokyo';

-- date '-' operator
-- 1140 : date_mi
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val - '2011-02-01' = 0;
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val - '2011-01-01' = 31;
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val - '2011-03-01' = -28;
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val - '2005-02-01' = -366;
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val - '2101-02-01' = -365;
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val - '2401-02-01' = -366;
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val - '2011-02-01 BC' = 1469022;
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val - '2011-02-01 BC' = 1468640;
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val - '2011-02-01' = -1469022;
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val - '2011-02-01' = -1468640;
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val - '2011-03-01 BC' = -28;

SELECT id FROM date_date WHERE val - '2011-02-01' = 0;
SELECT id FROM date_date WHERE val - '2011-02-01' = 0 OR dummy();
SELECT id FROM date_date WHERE val - '2011-01-01' = 31;
SELECT id FROM date_date WHERE val - '2011-01-01' = 31 OR dummy();
SELECT id FROM date_date WHERE val - '2011-03-01' = -28;
SELECT id FROM date_date WHERE val - '2011-03-01' = -28 OR dummy();
SELECT id FROM date_date WHERE val - '2005-02-01' = -366;
SELECT id FROM date_date WHERE val - '2005-02-01' = -366 OR dummy();
SELECT id FROM date_date WHERE val - '2101-02-01' = -365;
SELECT id FROM date_date WHERE val - '2101-02-01' = -365 OR dummy();
SELECT id FROM date_date WHERE val - '2401-02-01' = -366;
SELECT id FROM date_date WHERE val - '2401-02-01' = -366 OR dummy();
SELECT id FROM date_date WHERE val - '2011-02-01 BC' = 1469022;
SELECT id FROM date_date WHERE val - '2011-02-01 BC' = 1469022 OR dummy();
SELECT id FROM date_date WHERE val - '2011-02-01 BC' = 1468640;
SELECT id FROM date_date WHERE val - '2011-02-01 BC' = 1468640 OR dummy();
SELECT id FROM date_date WHERE val - '2011-02-01' = -1469022;
SELECT id FROM date_date WHERE val - '2011-02-01' = -1469022 OR dummy();
SELECT id FROM date_date WHERE val - '2011-02-01' = -1468640;
SELECT id FROM date_date WHERE val - '2011-02-01' = -1468640 OR dummy();
SELECT id FROM date_date WHERE val - '2011-03-01 BC' = -28;
SELECT id FROM date_date WHERE val - '2011-03-01 BC' = -28 OR dummy();

EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE '2011-02-01'::date - val = 0;
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE '2011-01-01'::date - val = 31;
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE '2011-03-01'::date - val = -28;
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE '2005-02-01'::date - val = -366;
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE '2101-02-01'::date - val = -365;
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE '2401-02-01'::date - val = -366;
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE '2011-02-01 BC'::date - val = 1469022;
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE '2011-02-01 BC'::date - val = 1468640;
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE '2011-02-01'::date - val = -1469022;
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE '2011-02-01'::date - val = -1468640;
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE '2011-03-01 BC'::date - val = -28;

SELECT id FROM date_date WHERE '2011-02-01'::date - val = 0;
SELECT id FROM date_date WHERE '2011-02-01'::date - val = 0 OR dummy();
SELECT id FROM date_date WHERE '2011-01-01'::date - val = -31;
SELECT id FROM date_date WHERE '2011-01-01'::date - val = -31 OR dummy();
SELECT id FROM date_date WHERE '2011-03-01'::date - val = 28;
SELECT id FROM date_date WHERE '2011-03-01'::date - val = 28 OR dummy();
SELECT id FROM date_date WHERE '2005-02-01'::date - val = 366;
SELECT id FROM date_date WHERE '2005-02-01'::date - val = 366 OR dummy();
SELECT id FROM date_date WHERE '2101-02-01'::date - val = 365;
SELECT id FROM date_date WHERE '2101-02-01'::date - val = 365 OR dummy();
SELECT id FROM date_date WHERE '2401-02-01'::date - val = 366;
SELECT id FROM date_date WHERE '2401-02-01'::date - val = 366 OR dummy();
SELECT id FROM date_date WHERE '2011-02-01 BC'::date - val = -1469022;
SELECT id FROM date_date WHERE '2011-02-01 BC'::date - val = -1469022 OR dummy();
SELECT id FROM date_date WHERE '2011-02-01 BC'::date - val = -1468640;
SELECT id FROM date_date WHERE '2011-02-01 BC'::date - val = -1468640 OR dummy();
SELECT id FROM date_date WHERE '2011-02-01'::date - val = 1469022;
SELECT id FROM date_date WHERE '2011-02-01'::date - val = 1469022 OR dummy();
SELECT id FROM date_date WHERE '2011-02-01'::date - val = 1468640;
SELECT id FROM date_date WHERE '2011-02-01'::date - val = 1468640 OR dummy();
SELECT id FROM date_date WHERE '2011-03-01 BC'::date - val = 28;
SELECT id FROM date_date WHERE '2011-03-01 BC'::date - val = 28 OR dummy();

EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE date_date_1 - date_date_2 = 31;

SELECT id FROM all_type WHERE date_date_1 - date_date_2 = 31;
SELECT id FROM all_type WHERE date_date_1 - date_date_2 = 31 OR dummy();

-- 1142 : date_mii
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val - 1.5 = '2011-01-01';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val - 1 = '2011-01-31';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val - 31 = '2011-01-01';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val - 365 = '2010-02-01';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val - 396 = '2010-01-01';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val - (-30) = '2004-03-02';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val - (-30) = '2100-03-03';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val - (-30) = '2400-03-02';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val - (-30) = '2011-03-03 BC';

SELECT id FROM date_date WHERE val - 1.5 = '2011-01-01';
SELECT id FROM date_date WHERE val - 1.5 = '2011-01-01' OR dummy();
SELECT id FROM date_date WHERE val - 1 = '2011-01-31';
SELECT id FROM date_date WHERE val - 1 = '2011-01-31' OR dummy();
SELECT id FROM date_date WHERE val - 31 = '2011-01-01';
SELECT id FROM date_date WHERE val - 31 = '2011-01-01' OR dummy();
SELECT id FROM date_date WHERE val - 365 = '2010-02-01';
SELECT id FROM date_date WHERE val - 365 = '2010-02-01' OR dummy();
SELECT id FROM date_date WHERE val - 396 = '2010-01-01';
SELECT id FROM date_date WHERE val - 396 = '2010-01-01' OR dummy();
SELECT id FROM date_date WHERE val - (-30) = '2004-03-02';
SELECT id FROM date_date WHERE val - (-30) = '2004-03-02' OR dummy();
SELECT id FROM date_date WHERE val - (-30) = '2100-03-03';
SELECT id FROM date_date WHERE val - (-30) = '2100-03-03' OR dummy();
SELECT id FROM date_date WHERE val - (-30) = '2400-03-02';
SELECT id FROM date_date WHERE val - (-30) = '2400-03-02' OR dummy();
SELECT id FROM date_date WHERE val - (-30) = '2011-03-03 BC';
SELECT id FROM date_date WHERE val - (-30) = '2011-03-03 BC' OR dummy();

-- 1170 : interval_mi
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val - '1 day' < '1 year 3 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val - '3 year 5 month' = '-2 year -2 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val - '2 year' = '-9 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val - '2 month' = '1 year 1 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val - '1 year 1 month' = '-2 year -4 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val - '-1 year -1 month' = '2 year 4 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val - '-1 year -1 month' = '-2 month';

EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val - '1 month' > '-1 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val - '2 day 23:45:12.234567' = '-1 day -11:10:16.111111';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val - '1 day' = '12:34:56.123456';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val - '12 hour' = '1 day 00:34:56.123456';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val - '34 minute' = '1 day 12:00:56.123456';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val - '56.123456 second' = '1 day 12:34:00.000000';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val - '2 day 11:11:11.111111' = '-3 day -23:46:07.234567';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val - '-1 day 12:34:56.123456' = '2 day 25:09:52.246912';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val - '-2 day -23:45:12.234567' = '1 day 11:10:16.111111';

EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE val - '2 day 23:45:12.234567' = '-1 day -11:10:16.111111';
EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE val - '2 day 23:45:12.234567' = '-1 day -11:10:16.111111' OR dummy();
EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE val - '2 day 23:45:12.234567' >= '-1 day -11:10:16.111111' AND val - '2 day 23:45:12.234567' < '-1 day -11:10:16.111110';
EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE val - '2 day 23:45:12.234567' >= '-1 day -11:10:16.111111' AND val - '2 day 23:45:12.234567' < '-1 day -11:10:16.111110' OR dummy();

SELECT id FROM itym_it WHERE val - '1 day' < '1 year 3 month';
SELECT id FROM itym_it WHERE val - '1 day' < '1 year 3 month' OR dummy();
SELECT id FROM itym_it WHERE val - '3 year 5 month' = '-2 year -2 month';
SELECT id FROM itym_it WHERE val - '3 year 5 month' = '-2 year -2 month' OR dummy();
SELECT id FROM itym_it WHERE val - '2 year' = '-9 month';
SELECT id FROM itym_it WHERE val - '2 year' = '-9 month' OR dummy();
SELECT id FROM itym_it WHERE val - '2 month' = '1 year 1 month';
SELECT id FROM itym_it WHERE val - '2 month' = '1 year 1 month' OR dummy();
SELECT id FROM itym_it WHERE val - '1 year 1 month' = '-2 year -4 month';
SELECT id FROM itym_it WHERE val - '1 year 1 month' = '-2 year -4 month' OR dummy();
SELECT id FROM itym_it WHERE val - '-1 year -1 month' = '2 year 4 month';
SELECT id FROM itym_it WHERE val - '-1 year -1 month' = '2 year 4 month' OR dummy();
SELECT id FROM itym_it WHERE val - '-1 year -1 month' = '-2 month';
SELECT id FROM itym_it WHERE val - '-1 year -1 month' = '-2 month' OR dummy();

SELECT id FROM itds6_it WHERE val - '1 month' > '-1 month';
SELECT id FROM itds6_it WHERE val - '1 month' > '-1 month' OR dummy();
SELECT id FROM itds6_it WHERE val - '2 day 23:45:12.234567' = '-1 day -11:10:16.111111';
SELECT id FROM itds6_it WHERE val - '2 day 23:45:12.234567' = '-1 day -11:10:16.111111' OR dummy();
SELECT id FROM itds6_it WHERE val - '1 day' = '12:34:56.123456';
SELECT id FROM itds6_it WHERE val - '1 day' = '12:34:56.123456' OR dummy();
SELECT id FROM itds6_it WHERE val - '12 hour' = '1 day 00:34:56.123456';
SELECT id FROM itds6_it WHERE val - '12 hour' = '1 day 00:34:56.123456' OR dummy();
SELECT id FROM itds6_it WHERE val - '34 minute' = '1 day 12:00:56.123456';
SELECT id FROM itds6_it WHERE val - '34 minute' = '1 day 12:00:56.123456' OR dummy();
SELECT id FROM itds6_it WHERE val - '56.123456 second' = '1 day 12:34:00.000000';
SELECT id FROM itds6_it WHERE val - '56.123456 second' = '1 day 12:34:00.000000' OR dummy();
SELECT id FROM itds6_it WHERE val - '2 day 11:11:11.111111' = '-3 day -23:46:07.234567';
SELECT id FROM itds6_it WHERE val - '2 day 11:11:11.111111' = '-3 day -23:46:07.234567' OR dummy();
SELECT id FROM itds6_it WHERE val - '-1 day 12:34:56.123456' = '2 day 25:09:52.246912';
SELECT id FROM itds6_it WHERE val - '-1 day 12:34:56.123456' = '2 day 25:09:52.246912' OR dummy();
SELECT id FROM itds6_it WHERE val - '-2 day -23:45:12.234567' = '1 day 11:10:16.111111';
SELECT id FROM itds6_it WHERE val - '-2 day -23:45:12.234567' = '1 day 11:10:16.111111' OR dummy();

SELECT id FROM itds9_it WHERE val - '2 day 23:45:12.234567' = '-1 day -11:10:16.111111';
SELECT id FROM itds9_it WHERE val - '2 day 23:45:12.234567' = '-1 day -11:10:16.111111' OR dummy();
SELECT id FROM itds9_it WHERE val - '2 day 23:45:12.234567' >= '-1 day -11:10:16.111111' AND val - '2 day 23:45:12.234567' < '-1 day -11:10:16.111110';
SELECT id FROM itds9_it WHERE val - '2 day 23:45:12.234567' >= '-1 day -11:10:16.111111' AND val - '2 day 23:45:12.234567' < '-1 day -11:10:16.111110' OR dummy();

EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '1 day' - val < '1 year 3 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '3 year 5 month' - val = '-2 year -2 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2 year' - val = '-9 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2 month' - val = '1 year 1 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '1 year 1 month' - val = '-2 year -4 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '-1 year -1 month' - val = '2 year 4 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '-1 year -1 month' - val = '-2 month';

EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '1 month' - val > '-1 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2 day 23:45:12.234567' - val = '-1 day -11:10:16.111111';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '1 day' - val = '12:34:56.123456';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '12 hour' - val = '1 day 00:34:56.123456';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '34 minute' - val = '1 day 12:00:56.123456';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '56.123456 second' - val = '1 day 12:34:00.000000';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2 day 11:11:11.111111' - val = '-3 day -23:46:07.234567';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '-1 day 12:34:56.123456' - val = '2 day 25:09:52.246912';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '-2 day -23:45:12.234567' - val = '1 day 11:10:16.111111';

EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE '2 day 23:45:12.234567' - val = '-1 day -11:10:16.111111';
EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE '2 day 23:45:12.234567' - val = '-1 day -11:10:16.111111' OR dummy();
EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE '2 day 23:45:12.234567' - val >= '-1 day -11:10:16.111111' AND '2 day 23:45:12.234567' - val < '-1 day -11:10:16.111110';
EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE '2 day 23:45:12.234567' - val >= '-1 day -11:10:16.111111' AND '2 day 23:45:12.234567' - val < '-1 day -11:10:16.111110' OR dummy();

SELECT id FROM itym_it WHERE '1 day' - val > '-1 year -3 month';
SELECT id FROM itym_it WHERE '1 day' - val > '-1 year -3 month' OR dummy();
SELECT id FROM itym_it WHERE '3 year 5 month' - val = '2 year 2 month';
SELECT id FROM itym_it WHERE '3 year 5 month' - val = '2 year 2 month' OR dummy();
SELECT id FROM itym_it WHERE '2 year' - val = '9 month';
SELECT id FROM itym_it WHERE '2 year' - val = '9 month' OR dummy();
SELECT id FROM itym_it WHERE '2 month' - val = '-1 year -1 month';
SELECT id FROM itym_it WHERE '2 month' - val = '-1 year -1 month' OR dummy();
SELECT id FROM itym_it WHERE '1 year 1 month' - val = '2 year 4 month';
SELECT id FROM itym_it WHERE '1 year 1 month' - val = '2 year 4 month' OR dummy();
SELECT id FROM itym_it WHERE '-1 year -1 month' - val = '-2 year -4 month';
SELECT id FROM itym_it WHERE '-1 year -1 month' - val = '-2 year -4 month' OR dummy();
SELECT id FROM itym_it WHERE '-1 year -1 month' - val = '2 month';
SELECT id FROM itym_it WHERE '-1 year -1 month' - val = '2 month' OR dummy();

SELECT id FROM itds6_it WHERE '1 month' - val < '1 month';
SELECT id FROM itds6_it WHERE '1 month' - val < '1 month' OR dummy();
SELECT id FROM itds6_it WHERE '2 day 23:45:12.234567' - val = '1 day 11:10:16.111111';
SELECT id FROM itds6_it WHERE '2 day 23:45:12.234567' - val = '1 day 11:10:16.111111' OR dummy();
SELECT id FROM itds6_it WHERE '1 day' - val = '-12:34:56.123456';
SELECT id FROM itds6_it WHERE '1 day' - val = '-12:34:56.123456' OR dummy();
SELECT id FROM itds6_it WHERE '12 hour' - val = '-1 day -00:34:56.123456';
SELECT id FROM itds6_it WHERE '12 hour' - val = '-1 day -00:34:56.123456' OR dummy();
SELECT id FROM itds6_it WHERE '34 minute' - val = '-1 day -12:00:56.123456';
SELECT id FROM itds6_it WHERE '34 minute' - val = '-1 day -12:00:56.123456' OR dummy();
SELECT id FROM itds6_it WHERE '56.123456 second' - val = '-1 day -12:34:00.000000';
SELECT id FROM itds6_it WHERE '56.123456 second' - val = '-1 day -12:34:00.000000' OR dummy();
SELECT id FROM itds6_it WHERE '2 day 11:11:11.111111' - val = '3 day 23:46:07.234567';
SELECT id FROM itds6_it WHERE '2 day 11:11:11.111111' - val = '3 day 23:46:07.234567' OR dummy();
SELECT id FROM itds6_it WHERE '-1 day 12:34:56.123456' - val = '-2 day -25:09:52.246912';
SELECT id FROM itds6_it WHERE '-1 day 12:34:56.123456' - val = '-2 day -25:09:52.246912' OR dummy();
SELECT id FROM itds6_it WHERE '-2 day -23:45:12.234567' - val = '-1 day -11:10:16.111111';
SELECT id FROM itds6_it WHERE '-2 day -23:45:12.234567' - val = '-1 day -11:10:16.111111' OR dummy();

SELECT id FROM itds9_it WHERE '2 day 23:45:12.234567' - val = '1 day 11:10:16.111111';
SELECT id FROM itds9_it WHERE '2 day 23:45:12.234567' - val = '1 day 11:10:16.111111' OR dummy();

SELECT id FROM all_type WHERE intervalym_interval_1 - intervalym_interval_2 = '3 year 3 month';
SELECT id FROM all_type WHERE intervalds6_interval_1 - intervalds6_interval_2 = '3 day 13:36:59.246912';

-- 1188 : timestamptz_mi
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '2010-02-01 00:00:00.000001 Asia/Tokyo' = '365 day';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '2011-01-01 00:00:00.000001 Asia/Tokyo' = '31 day';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '2011-01-31 12:00:00.000001 Asia/Tokyo' = '12 hour';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '2011-01-31 23:30:00.000001 Asia/Tokyo' = '30 minute';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '2011-01-31 23:59:30.123456 Asia/Tokyo' = '29.876545 second';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '2011-03-01 00:00:00.000001 Asia/Tokyo' = '-28 day';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '2011-02-01 00:00:00.000001 Asia/Tokyo' = '-1469022 day 00:18:00';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '2011-02-01 00:00:00.000001 Asia/Tokyo' = '-1468640 day 00:18:59';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '2011-02-01 BC 00:00:00.000001 Asia/Tokyo' = '1469022 day 00:18:00';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '2011-02-01 BC 00:00:00.000001 Asia/Tokyo' = '1468640 day 00:18:59';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '2011-02-01 00:00:00.000001 UTC' = '-9 hour';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '2005-02-01 00:00:00.000001 Asia/Tokyo' = '-366 day';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '2101-02-01 00:00:00.000001 Asia/Tokyo' = '-365 day';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '2401-02-01 00:00:00.000001 Asia/Tokyo' = '-366 day';

EXPLAIN (COSTS FALSE) SELECT id FROM tstz9_tstz WHERE val - '2010-02-01 00:00:00.000001 Asia/Tokyo' = '365 day';

SELECT id FROM tstz6_tstz WHERE val - '2010-02-01 00:00:00.000001 Asia/Tokyo' = '365 day';
SELECT id FROM tstz6_tstz WHERE val - '2010-02-01 00:00:00.000001 Asia/Tokyo' = '365 day' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '2011-01-01 00:00:00.000001 Asia/Tokyo' = '31 day';
SELECT id FROM tstz6_tstz WHERE val - '2011-01-01 00:00:00.000001 Asia/Tokyo' = '31 day' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '2011-01-31 12:00:00.000001 Asia/Tokyo' = '12 hour';
SELECT id FROM tstz6_tstz WHERE val - '2011-01-31 12:00:00.000001 Asia/Tokyo' = '12 hour' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '2011-01-31 23:30:00.000001 Asia/Tokyo' = '30 minute';
SELECT id FROM tstz6_tstz WHERE val - '2011-01-31 23:30:00.000001 Asia/Tokyo' = '30 minute' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '2011-01-31 23:59:30.123456 Asia/Tokyo' = '29.876545 second';
SELECT id FROM tstz6_tstz WHERE val - '2011-01-31 23:59:30.123456 Asia/Tokyo' = '29.876545 second' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '2011-03-01 00:00:00.000001 Asia/Tokyo' = '-28 day';
SELECT id FROM tstz6_tstz WHERE val - '2011-03-01 00:00:00.000001 Asia/Tokyo' = '-28 day' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '2011-02-01 00:00:00.000001 Asia/Tokyo' = '-1469022 day 00:18:00';
SELECT id FROM tstz6_tstz WHERE val - '2011-02-01 00:00:00.000001 Asia/Tokyo' = '-1469022 day 00:18:00' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '2011-02-01 00:00:00.000001 Asia/Tokyo' = '-1468640 day 00:18:59';
SELECT id FROM tstz6_tstz WHERE val - '2011-02-01 00:00:00.000001 Asia/Tokyo' = '-1468640 day 00:18:59' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '2011-02-01 BC 00:00:00.000001 Asia/Tokyo' = '1469022 day 00:18:00';
SELECT id FROM tstz6_tstz WHERE val - '2011-02-01 BC 00:00:00.000001 Asia/Tokyo' = '1469022 day 00:18:00' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '2011-02-01 BC 00:00:00.000001 Asia/Tokyo' = '1468640 day 00:18:59';
SELECT id FROM tstz6_tstz WHERE val - '2011-02-01 BC 00:00:00.000001 Asia/Tokyo' = '1468640 day 00:18:59' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '2011-02-01 00:00:00.000001 UTC' = '-9 hour';
SELECT id FROM tstz6_tstz WHERE val - '2011-02-01 00:00:00.000001 UTC' = '-9 hour' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '2005-02-01 00:00:00.000001 Asia/Tokyo' = '-366 day';
SELECT id FROM tstz6_tstz WHERE val - '2005-02-01 00:00:00.000001 Asia/Tokyo' = '-366 day' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '2101-02-01 00:00:00.000001 Asia/Tokyo' = '-365 day';
SELECT id FROM tstz6_tstz WHERE val - '2101-02-01 00:00:00.000001 Asia/Tokyo' = '-365 day' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '2401-02-01 00:00:00.000001 Asia/Tokyo' = '-366 day';
SELECT id FROM tstz6_tstz WHERE val - '2401-02-01 00:00:00.000001 Asia/Tokyo' = '-366 day' OR dummy();

SELECT id FROM tstz9_tstz WHERE val - '2010-02-01 00:00:00.000001 Asia/Tokyo' = '365 day';
SELECT id FROM tstz9_tstz WHERE val - '2010-02-01 00:00:00.000001 Asia/Tokyo' = '365 day' OR dummy();

EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '2010-02-01 00:00:00.000001 Asia/Tokyo' = '365 day';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '2011-01-01 00:00:00.000001 Asia/Tokyo' = '31 day';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '2011-01-31 12:00:00.000001 Asia/Tokyo' = '12 hour';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '2011-01-31 23:30:00.000001 Asia/Tokyo' = '30 minute';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '2011-01-31 23:59:30.123456 Asia/Tokyo' = '29.876545 second';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '2011-03-01 00:00:00.000001 Asia/Tokyo' = '-28 day';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '2011-02-01 00:00:00.000001 Asia/Tokyo' = '-1469022 day';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '2011-02-01 00:00:00.000001 Asia/Tokyo' = '-1468640 day 00:18:59';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '2011-02-01 BC 00:00:00.000001 Asia/Tokyo' = '1469022 day';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '2011-02-01 BC 00:00:00.000001 Asia/Tokyo' = '1468640 day 00:18:59';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '2011-02-01 00:00:00.000001 UTC' = '-9 hour';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '2005-02-01 00:00:00.000001 Asia/Tokyo' = '-366 day';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '2101-02-01 00:00:00.000001 Asia/Tokyo' = '-365 day';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '2401-02-01 00:00:00.000001 Asia/Tokyo' = '-366 day';

EXPLAIN (COSTS FALSE) SELECT id FROM tsltz9_tstz WHERE val - '2010-02-01 00:00:00.000001 Asia/Tokyo' = '365 day';

SELECT id FROM tsltz6_tstz WHERE val - '2010-02-01 00:00:00.000001 Asia/Tokyo' = '365 day';
SELECT id FROM tsltz6_tstz WHERE val - '2010-02-01 00:00:00.000001 Asia/Tokyo' = '365 day' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '2011-01-01 00:00:00.000001 Asia/Tokyo' = '31 day';
SELECT id FROM tsltz6_tstz WHERE val - '2011-01-01 00:00:00.000001 Asia/Tokyo' = '31 day' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '2011-01-31 12:00:00.000001 Asia/Tokyo' = '12 hour';
SELECT id FROM tsltz6_tstz WHERE val - '2011-01-31 12:00:00.000001 Asia/Tokyo' = '12 hour' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '2011-01-31 23:30:00.000001 Asia/Tokyo' = '30 minute';
SELECT id FROM tsltz6_tstz WHERE val - '2011-01-31 23:30:00.000001 Asia/Tokyo' = '30 minute' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '2011-01-31 23:59:30.123456 Asia/Tokyo' = '29.876545 second';
SELECT id FROM tsltz6_tstz WHERE val - '2011-01-31 23:59:30.123456 Asia/Tokyo' = '29.876545 second' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '2011-03-01 00:00:00.000001 Asia/Tokyo' = '-28 day';
SELECT id FROM tsltz6_tstz WHERE val - '2011-03-01 00:00:00.000001 Asia/Tokyo' = '-28 day' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '2011-02-01 00:00:00.000001 Asia/Tokyo' = '-1469022 day';
SELECT id FROM tsltz6_tstz WHERE val - '2011-02-01 00:00:00.000001 Asia/Tokyo' = '-1469022 day' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '2011-02-01 00:00:00.000001 Asia/Tokyo' = '-1468640 day 00:18:59';
SELECT id FROM tsltz6_tstz WHERE val - '2011-02-01 00:00:00.000001 Asia/Tokyo' = '-1468640 day 00:18:59' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '2011-02-01 BC 00:00:00.000001 Asia/Tokyo' = '1469022 day';
SELECT id FROM tsltz6_tstz WHERE val - '2011-02-01 BC 00:00:00.000001 Asia/Tokyo' = '1469022 day' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '2011-02-01 BC 00:00:00.000001 Asia/Tokyo' = '1468640 day 00:18:59';
SELECT id FROM tsltz6_tstz WHERE val - '2011-02-01 BC 00:00:00.000001 Asia/Tokyo' = '1468640 day 00:18:59' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '2011-02-01 00:00:00.000001 UTC' = '-9 hour';
SELECT id FROM tsltz6_tstz WHERE val - '2011-02-01 00:00:00.000001 UTC' = '-9 hour' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '2005-02-01 00:00:00.000001 Asia/Tokyo' = '-366 day';
SELECT id FROM tsltz6_tstz WHERE val - '2005-02-01 00:00:00.000001 Asia/Tokyo' = '-366 day' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '2101-02-01 00:00:00.000001 Asia/Tokyo' = '-365 day';
SELECT id FROM tsltz6_tstz WHERE val - '2101-02-01 00:00:00.000001 Asia/Tokyo' = '-365 day' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '2401-02-01 00:00:00.000001 Asia/Tokyo' = '-366 day';
SELECT id FROM tsltz6_tstz WHERE val - '2401-02-01 00:00:00.000001 Asia/Tokyo' = '-366 day' OR dummy();

SELECT id FROM tsltz9_tstz WHERE val - '2010-02-01 00:00:00.000001 Asia/Tokyo' = '365 day';
SELECT id FROM tsltz9_tstz WHERE val - '2010-02-01 00:00:00.000001 Asia/Tokyo' = '365 day' OR dummy();

EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '2010-02-01 00:00:00.000001 Asia/Tokyo' - val = '365 day';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '2011-01-01 00:00:00.000001 Asia/Tokyo' - val = '31 day';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '2011-01-31 12:00:00.000001 Asia/Tokyo' - val = '12 hour';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '2011-01-31 23:30:00.000001 Asia/Tokyo' - val = '30 minute';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '2011-01-31 23:59:30.123456 Asia/Tokyo' - val = '29.876545 second';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '2011-03-01 00:00:00.000001 Asia/Tokyo' - val = '-28 day';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo' - val = '-1469022 day 00:18:00';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo' - val = '-1468640 day 00:18:59';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '2011-02-01 BC 00:00:00.000001 Asia/Tokyo' - val = '1469022 day 00:18:00';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '2011-02-01 BC 00:00:00.000001 Asia/Tokyo' - val = '1468640 day 00:18:59';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '2011-02-01 00:00:00.000001 UTC' - val = '-9 hour';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '2005-02-01 00:00:00.000001 Asia/Tokyo' - val = '-366 day';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '2101-02-01 00:00:00.000001 Asia/Tokyo' - val = '-365 day';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '2401-02-01 00:00:00.000001 Asia/Tokyo' - val = '-366 day';

EXPLAIN (COSTS FALSE) SELECT id FROM tstz9_tstz WHERE '2010-02-01 00:00:00.000001 Asia/Tokyo' - val = '365 day';

SELECT id FROM tstz6_tstz WHERE '2010-02-01 00:00:00.000001 Asia/Tokyo' - val = '-365 day';
SELECT id FROM tstz6_tstz WHERE '2010-02-01 00:00:00.000001 Asia/Tokyo' - val = '-365 day' OR dummy();
SELECT id FROM tstz6_tstz WHERE '2011-01-01 00:00:00.000001 Asia/Tokyo' - val = '-31 day';
SELECT id FROM tstz6_tstz WHERE '2011-01-01 00:00:00.000001 Asia/Tokyo' - val = '-31 day' OR dummy();
SELECT id FROM tstz6_tstz WHERE '2011-01-31 12:00:00.000001 Asia/Tokyo' - val = '-12 hour';
SELECT id FROM tstz6_tstz WHERE '2011-01-31 12:00:00.000001 Asia/Tokyo' - val = '-12 hour' OR dummy();
SELECT id FROM tstz6_tstz WHERE '2011-01-31 23:30:00.000001 Asia/Tokyo' - val = '-30 minute';
SELECT id FROM tstz6_tstz WHERE '2011-01-31 23:30:00.000001 Asia/Tokyo' - val = '-30 minute' OR dummy();
SELECT id FROM tstz6_tstz WHERE '2011-01-31 23:59:30.123456 Asia/Tokyo' - val = '-29.876545 second';
SELECT id FROM tstz6_tstz WHERE '2011-01-31 23:59:30.123456 Asia/Tokyo' - val = '-29.876545 second' OR dummy();
SELECT id FROM tstz6_tstz WHERE '2011-03-01 00:00:00.000001 Asia/Tokyo' - val = '28 day';
SELECT id FROM tstz6_tstz WHERE '2011-03-01 00:00:00.000001 Asia/Tokyo' - val = '28 day' OR dummy();
SELECT id FROM tstz6_tstz WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo' - val = '1469022 day 00:18:00';
SELECT id FROM tstz6_tstz WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo' - val = '1469022 day 00:18:00' OR dummy();
SELECT id FROM tstz6_tstz WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo' - val = '1468640 day 00:18:59';
SELECT id FROM tstz6_tstz WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo' - val = '1468640 day 00:18:59' OR dummy();
SELECT id FROM tstz6_tstz WHERE '2011-02-01 BC 00:00:00.000001 Asia/Tokyo' - val = '-1469022 day 00:18:00';
SELECT id FROM tstz6_tstz WHERE '2011-02-01 BC 00:00:00.000001 Asia/Tokyo' - val = '-1469022 day 00:18:00' OR dummy();
SELECT id FROM tstz6_tstz WHERE '2011-02-01 BC 00:00:00.000001 Asia/Tokyo' - val = '-1468640 day 00:18:59';
SELECT id FROM tstz6_tstz WHERE '2011-02-01 BC 00:00:00.000001 Asia/Tokyo' - val = '-1468640 day 00:18:59' OR dummy();
SELECT id FROM tstz6_tstz WHERE '2011-02-01 00:00:00.000001 UTC' - val = '9 hour';
SELECT id FROM tstz6_tstz WHERE '2011-02-01 00:00:00.000001 UTC' - val = '9 hour' OR dummy();
SELECT id FROM tstz6_tstz WHERE '2005-02-01 00:00:00.000001 Asia/Tokyo' - val = '366 day';
SELECT id FROM tstz6_tstz WHERE '2005-02-01 00:00:00.000001 Asia/Tokyo' - val = '366 day' OR dummy();
SELECT id FROM tstz6_tstz WHERE '2101-02-01 00:00:00.000001 Asia/Tokyo' - val = '365 day';
SELECT id FROM tstz6_tstz WHERE '2101-02-01 00:00:00.000001 Asia/Tokyo' - val = '365 day' OR dummy();
SELECT id FROM tstz6_tstz WHERE '2401-02-01 00:00:00.000001 Asia/Tokyo' - val = '366 day';
SELECT id FROM tstz6_tstz WHERE '2401-02-01 00:00:00.000001 Asia/Tokyo' - val = '366 day' OR dummy();

SELECT id FROM tstz9_tstz WHERE '2010-02-01 00:00:00.000001 Asia/Tokyo' - val = '-365 day';
SELECT id FROM tstz9_tstz WHERE '2010-02-01 00:00:00.000001 Asia/Tokyo' - val = '-365 day' OR dummy();

EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '2010-02-01 00:00:00.000001 Asia/Tokyo' - val = '-365 day';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '2011-01-01 00:00:00.000001 Asia/Tokyo' - val = '-31 day';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '2011-01-31 12:00:00.000001 Asia/Tokyo' - val = '-12 hour';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '2011-01-31 23:30:00.000001 Asia/Tokyo' - val = '-30 minute';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '2011-01-31 23:59:30.123456 Asia/Tokyo' - val = '-29.876545 second';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '2011-03-01 00:00:00.000001 Asia/Tokyo' - val = '28 day';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo' - val = '1469022 day 00:18:00';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo' - val = '1468640 day 00:18:59';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '2011-02-01 BC 00:00:00.000001 Asia/Tokyo' - val = '-1469022 day 00:18:00';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '2011-02-01 BC 00:00:00.000001 Asia/Tokyo' - val = '-1468640 day 00:18:59';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '2011-02-01 00:00:00.000001 UTC' - val = '9 hour';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '2005-02-01 00:00:00.000001 Asia/Tokyo' - val = '366 day';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '2101-02-01 00:00:00.000001 Asia/Tokyo' - val = '365 day';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '2401-02-01 00:00:00.000001 Asia/Tokyo' - val = '366 day';

EXPLAIN (COSTS FALSE) SELECT id FROM tsltz9_tstz WHERE '2010-02-01 00:00:00.000001 Asia/Tokyo' - val = '365 day';

SELECT id FROM tsltz6_tstz WHERE '2010-02-01 00:00:00.000001 Asia/Tokyo' - val = '-365 day';
SELECT id FROM tsltz6_tstz WHERE '2010-02-01 00:00:00.000001 Asia/Tokyo' - val = '-365 day' OR dummy();
SELECT id FROM tsltz6_tstz WHERE '2011-01-01 00:00:00.000001 Asia/Tokyo' - val = '-31 day';
SELECT id FROM tsltz6_tstz WHERE '2011-01-01 00:00:00.000001 Asia/Tokyo' - val = '-31 day' OR dummy();
SELECT id FROM tsltz6_tstz WHERE '2011-01-31 12:00:00.000001 Asia/Tokyo' - val = '-12 hour';
SELECT id FROM tsltz6_tstz WHERE '2011-01-31 12:00:00.000001 Asia/Tokyo' - val = '-12 hour' OR dummy();
SELECT id FROM tsltz6_tstz WHERE '2011-01-31 23:30:00.000001 Asia/Tokyo' - val = '-30 minute';
SELECT id FROM tsltz6_tstz WHERE '2011-01-31 23:30:00.000001 Asia/Tokyo' - val = '-30 minute' OR dummy();
SELECT id FROM tsltz6_tstz WHERE '2011-01-31 23:59:30.123456 Asia/Tokyo' - val = '-29.876545 second';
SELECT id FROM tsltz6_tstz WHERE '2011-01-31 23:59:30.123456 Asia/Tokyo' - val = '-29.876545 second' OR dummy();
SELECT id FROM tsltz6_tstz WHERE '2011-03-01 00:00:00.000001 Asia/Tokyo' - val = '28 day';
SELECT id FROM tsltz6_tstz WHERE '2011-03-01 00:00:00.000001 Asia/Tokyo' - val = '28 day' OR dummy();
SELECT id FROM tsltz6_tstz WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo' - val = '1469022 day 00:18:00';
SELECT id FROM tsltz6_tstz WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo' - val = '1469022 day 00:18:00' OR dummy();
SELECT id FROM tsltz6_tstz WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo' - val = '1468640 day 00:18:59';
SELECT id FROM tsltz6_tstz WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo' - val = '1468640 day 00:18:59' OR dummy();
SELECT id FROM tsltz6_tstz WHERE '2011-02-01 BC 00:00:00.000001 Asia/Tokyo' - val = '-1469022 day 00:18:00';
SELECT id FROM tsltz6_tstz WHERE '2011-02-01 BC 00:00:00.000001 Asia/Tokyo' - val = '-1469022 day 00:18:00' OR dummy();
SELECT id FROM tsltz6_tstz WHERE '2011-02-01 BC 00:00:00.000001 Asia/Tokyo' - val = '-1468640 day 00:18:59';
SELECT id FROM tsltz6_tstz WHERE '2011-02-01 BC 00:00:00.000001 Asia/Tokyo' - val = '-1468640 day 00:18:59' OR dummy();
SELECT id FROM tsltz6_tstz WHERE '2011-02-01 00:00:00.000001 UTC' - val = '9 hour';
SELECT id FROM tsltz6_tstz WHERE '2011-02-01 00:00:00.000001 UTC' - val = '9 hour' OR dummy();
SELECT id FROM tsltz6_tstz WHERE '2005-02-01 00:00:00.000001 Asia/Tokyo' - val = '366 day';
SELECT id FROM tsltz6_tstz WHERE '2005-02-01 00:00:00.000001 Asia/Tokyo' - val = '366 day' OR dummy();
SELECT id FROM tsltz6_tstz WHERE '2101-02-01 00:00:00.000001 Asia/Tokyo' - val = '365 day';
SELECT id FROM tsltz6_tstz WHERE '2101-02-01 00:00:00.000001 Asia/Tokyo' - val = '365 day' OR dummy();
SELECT id FROM tsltz6_tstz WHERE '2401-02-01 00:00:00.000001 Asia/Tokyo' - val = '366 day';
SELECT id FROM tsltz6_tstz WHERE '2401-02-01 00:00:00.000001 Asia/Tokyo' - val = '366 day' OR dummy();

SELECT id FROM tsltz9_tstz WHERE '2010-02-01 00:00:00.000001 Asia/Tokyo' - val = '-365 day';
SELECT id FROM tsltz9_tstz WHERE '2010-02-01 00:00:00.000001 Asia/Tokyo' - val = '-365 day' OR dummy();

-- 1190 : timestamptz_mi_interval
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '1 year'::interval = '2010-02-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '1 month'::interval = '2011-01-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '365 day'::interval = '2010-02-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '31 day'::interval = '2011-01-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '12 hour'::interval = '2011-01-31 12:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '30 minute'::interval = '2011-01-31 23:30:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '29.876545 second'::interval = '2011-01-31 23:59:30.123456 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '-1 month'::interval = '2011-03-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '-28 day'::interval = '2011-03-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '-2011 year'::interval = '0001-02-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '2011 year'::interval = '0001-02-01 BC 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '-9 hour'::interval = '2011-02-01 00:00:00.000001 UTC';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '-1 year'::interval = '2005-02-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '-1 year'::interval = '2101-02-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val - '-1 year'::interval = '2401-02-01 00:00:00.000001 Asia/Tokyo';

EXPLAIN (COSTS FALSE) SELECT id FROM tstz9_tstz WHERE val - '1 year'::interval = '2010-02-01 00:00:00.000001 Asia/Tokyo';

SELECT id FROM tstz6_tstz WHERE val - '1 year'::interval = '2010-02-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val - '1 year'::interval = '2010-02-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '1 month'::interval = '2011-01-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val - '1 month'::interval = '2011-01-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '365 day'::interval = '2010-02-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val - '365 day'::interval = '2010-02-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '31 day'::interval = '2011-01-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val - '31 day'::interval = '2011-01-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '12 hour'::interval = '2011-01-31 12:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val - '12 hour'::interval = '2011-01-31 12:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '30 minute'::interval = '2011-01-31 23:30:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val - '30 minute'::interval = '2011-01-31 23:30:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '29.876545 second'::interval = '2011-01-31 23:59:30.123456 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val - '29.876545 second'::interval = '2011-01-31 23:59:30.123456 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '-1 month'::interval = '2011-03-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val - '-1 month'::interval = '2011-03-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '-28 day'::interval = '2011-03-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val - '-28 day'::interval = '2011-03-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '-2011 year'::interval = '0001-02-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val - '-2011 year'::interval = '0001-02-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '2011 year'::interval = '0001-02-01 BC 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val - '2011 year'::interval = '0001-02-01 BC 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '-9 hour'::interval = '2011-02-01 00:00:00.000001 UTC';
SELECT id FROM tstz6_tstz WHERE val - '-9 hour'::interval = '2011-02-01 00:00:00.000001 UTC' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '-1 year'::interval = '2005-02-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val - '-1 year'::interval = '2005-02-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '-1 year'::interval = '2101-02-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val - '-1 year'::interval = '2101-02-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE val - '-1 year'::interval = '2401-02-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val - '-1 year'::interval = '2401-02-01 00:00:00.000001 Asia/Tokyo' OR dummy();

SELECT id FROM tstz9_tstz WHERE val - '1 year'::interval = '2010-02-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz9_tstz WHERE val - '1 year'::interval = '2010-02-01 00:00:00.000001 Asia/Tokyo' OR dummy();

EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '1 year'::interval = '2010-02-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '1 month'::interval = '2011-01-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '365 day'::interval = '2010-02-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '31 day'::interval = '2011-01-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '12 hour'::interval = '2011-01-31 12:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '30 minute'::interval = '2011-01-31 23:30:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '29.876545 second'::interval = '2011-01-31 23:59:30.123456 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '-1 month'::interval = '2011-03-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '-28 day'::interval = '2011-03-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '-2011 year'::interval = '0001-02-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '2011 year'::interval = '0001-02-01 BC 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '-9 hour'::interval = '2011-02-01 00:00:00.000001 UTC';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '-1 year'::interval = '2005-02-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '-1 year'::interval = '2101-02-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val - '-1 year'::interval = '2401-02-01 00:00:00.000001 Asia/Tokyo';

EXPLAIN (COSTS FALSE) SELECT id FROM tsltz9_tstz WHERE val - '1 year'::interval = '2010-02-01 00:00:00.000001 Asia/Tokyo';

SELECT id FROM tsltz6_tstz WHERE val - '1 year'::interval = '2010-02-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val - '1 year'::interval = '2010-02-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '1 month'::interval = '2011-01-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val - '1 month'::interval = '2011-01-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '365 day'::interval = '2010-02-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val - '365 day'::interval = '2010-02-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '31 day'::interval = '2011-01-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val - '31 day'::interval = '2011-01-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '12 hour'::interval = '2011-01-31 12:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val - '12 hour'::interval = '2011-01-31 12:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '30 minute'::interval = '2011-01-31 23:30:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val - '30 minute'::interval = '2011-01-31 23:30:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '29.876545 second'::interval = '2011-01-31 23:59:30.123456 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val - '29.876545 second'::interval = '2011-01-31 23:59:30.123456 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '-1 month'::interval = '2011-03-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val - '-1 month'::interval = '2011-03-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '-28 day'::interval = '2011-03-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val - '-28 day'::interval = '2011-03-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '-2011 year'::interval = '0001-02-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val - '-2011 year'::interval = '0001-02-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '2011 year'::interval = '0001-02-01 BC 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val - '2011 year'::interval = '0001-02-01 BC 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '-9 hour'::interval = '2011-02-01 00:00:00.000001 UTC';
SELECT id FROM tsltz6_tstz WHERE val - '-9 hour'::interval = '2011-02-01 00:00:00.000001 UTC' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '-1 year'::interval = '2005-02-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val - '-1 year'::interval = '2005-02-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '-1 year'::interval = '2101-02-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val - '-1 year'::interval = '2101-02-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val - '-1 year'::interval = '2401-02-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val - '-1 year'::interval = '2401-02-01 00:00:00.000001 Asia/Tokyo' OR dummy();

SELECT id FROM tsltz9_tstz WHERE val - '1 year'::interval = '2010-02-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz9_tstz WHERE val - '1 year'::interval = '2010-02-01 00:00:00.000001 Asia/Tokyo' OR dummy();



EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2009-11-02 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2010-02-02 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2010-11-02 00:00:00.000001 Asia/Tokyo';

EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2011-01-30 11:25:03.876545 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2011-01-31 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2011-01-31 23:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2011-01-31 23:59:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2011-01-31 23:59:58.876545 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2011-02-02 12:34:56.123457 Asia/Tokyo';

EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2011-01-30 11:25:03.876545 Asia/Tokyo';

SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2009-11-02 00:00:00.000001 Asia/Tokyo';
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2009-11-02 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2010-02-02 00:00:00.000001 Asia/Tokyo';
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2010-02-02 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2010-11-02 00:00:00.000001 Asia/Tokyo';
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2010-11-02 00:00:00.000001 Asia/Tokyo' OR dummy();

SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2011-01-30 11:25:03.876545 Asia/Tokyo';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2011-01-30 11:25:03.876545 Asia/Tokyo' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2011-01-31 00:00:00.000001 Asia/Tokyo';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2011-01-31 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2011-01-31 23:00:00.000001 Asia/Tokyo';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2011-01-31 23:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2011-01-31 23:59:00.000001 Asia/Tokyo';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2011-01-31 23:59:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2011-01-31 23:59:58.876545 Asia/Tokyo';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2011-01-31 23:59:58.876545 Asia/Tokyo' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2011-02-02 12:34:56.123457 Asia/Tokyo';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2011-02-02 12:34:56.123457 Asia/Tokyo' OR dummy();

SELECT id FROM itds9_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2011-01-30 11:25:03.876545 Asia/Tokyo';
SELECT id FROM itds9_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz - val = '2011-01-30 11:25:03.876545 Asia/Tokyo' OR dummy();

-- 2031 : timestamp_mi
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '2010-02-01 00:00:00.000001' = '365 day';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '2011-01-01 00:00:00.000001' = '31 day';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '2011-01-31 12:00:00.000001' = '12 hour';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '2011-01-31 23:30:00.000001' = '30 minute';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '2011-01-31 23:59:30.123456' = '29.876545 second';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '2011-03-01 00:00:00.000001' = '-28 day';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '2011-02-01 00:00:00.000001' = '-1469022 day 00:18:00';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '2011-02-01 00:00:00.000001' = '-1468640 day 00:18:59';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '2011-02-01 BC 00:00:00.000001' = '1469022 day 00:18:00';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '2011-02-01 BC 00:00:00.000001' = '1468640 day 00:18:59';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '2005-02-01 00:00:00.000001' = '-366 day';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '2101-02-01 00:00:00.000001' = '-365 day';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '2401-02-01 00:00:00.000001' = '-366 day';

EXPLAIN (COSTS FALSE) SELECT id FROM ts9_ts WHERE val - '2010-02-01 00:00:00.000001' = '365 day';

SELECT id FROM ts6_ts WHERE val - '2010-02-01 00:00:00.000001' = '365 day';
SELECT id FROM ts6_ts WHERE val - '2010-02-01 00:00:00.000001' = '365 day' OR dummy();
SELECT id FROM ts6_ts WHERE val - '2011-01-01 00:00:00.000001' = '31 day';
SELECT id FROM ts6_ts WHERE val - '2011-01-01 00:00:00.000001' = '31 day' OR dummy();
SELECT id FROM ts6_ts WHERE val - '2011-01-31 12:00:00.000001' = '12 hour';
SELECT id FROM ts6_ts WHERE val - '2011-01-31 12:00:00.000001' = '12 hour' OR dummy();
SELECT id FROM ts6_ts WHERE val - '2011-01-31 23:30:00.000001' = '30 minute';
SELECT id FROM ts6_ts WHERE val - '2011-01-31 23:30:00.000001' = '30 minute' OR dummy();
SELECT id FROM ts6_ts WHERE val - '2011-01-31 23:59:30.123456' = '29.876545 second';
SELECT id FROM ts6_ts WHERE val - '2011-01-31 23:59:30.123456' = '29.876545 second' OR dummy();
SELECT id FROM ts6_ts WHERE val - '2011-03-01 00:00:00.000001' = '-28 day';
SELECT id FROM ts6_ts WHERE val - '2011-03-01 00:00:00.000001' = '-28 day' OR dummy();
SELECT id FROM ts6_ts WHERE val - '2011-02-01 00:00:00.000001' = '-1469022 day';
SELECT id FROM ts6_ts WHERE val - '2011-02-01 00:00:00.000001' = '-1469022 day' OR dummy();
SELECT id FROM ts6_ts WHERE val - '2011-02-01 00:00:00.000001' = '-1468640 day';
SELECT id FROM ts6_ts WHERE val - '2011-02-01 00:00:00.000001' = '-1468640 day' OR dummy();
SELECT id FROM ts6_ts WHERE val - '2011-02-01 BC 00:00:00.000001' = '1469022 day';
SELECT id FROM ts6_ts WHERE val - '2011-02-01 BC 00:00:00.000001' = '1469022 day' OR dummy();
SELECT id FROM ts6_ts WHERE val - '2011-02-01 BC 00:00:00.000001' = '1468640 day';
SELECT id FROM ts6_ts WHERE val - '2011-02-01 BC 00:00:00.000001' = '1468640 day' OR dummy();
SELECT id FROM ts6_ts WHERE val - '2005-02-01 00:00:00.000001' = '-366 day';
SELECT id FROM ts6_ts WHERE val - '2005-02-01 00:00:00.000001' = '-366 day' OR dummy();
SELECT id FROM ts6_ts WHERE val - '2101-02-01 00:00:00.000001' = '-365 day';
SELECT id FROM ts6_ts WHERE val - '2101-02-01 00:00:00.000001' = '-365 day' OR dummy();
SELECT id FROM ts6_ts WHERE val - '2401-02-01 00:00:00.000001' = '-366 day';
SELECT id FROM ts6_ts WHERE val - '2401-02-01 00:00:00.000001' = '-366 day' OR dummy();

SELECT id FROM ts9_ts WHERE val - '2010-02-01 00:00:00.000001' = '365 day';
SELECT id FROM ts9_ts WHERE val - '2010-02-01 00:00:00.000001' = '365 day' OR dummy();

EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '2010-02-01 00:00:00.000001' - val = '365 day';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '2011-01-01 00:00:00.000001' - val = '31 day';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '2011-01-31 12:00:00.000001' - val = '12 hour';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '2011-01-31 23:30:00.000001' - val = '30 minute';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '2011-01-31 23:59:30.123456' - val = '29.876545 second';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '2011-03-01 00:00:00.000001' - val = '-28 day';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '2011-02-01 00:00:00.000001' - val = '-1469022 day 00:18:00';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '2011-02-01 00:00:00.000001' - val = '-1468640 day 00:18:59';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '2011-02-01 BC 00:00:00.000001' - val = '1469022 day 00:18:00';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '2011-02-01 BC 00:00:00.000001' - val = '1468640 day 00:18:59';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '2005-02-01 00:00:00.000001' - val = '-366 day';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '2101-02-01 00:00:00.000001' - val = '-365 day';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '2401-02-01 00:00:00.000001' - val = '-366 day';

EXPLAIN (COSTS FALSE) SELECT id FROM ts9_ts WHERE '2010-02-01 00:00:00.000001' - val = '365 day';

SELECT id FROM ts6_ts WHERE '2010-02-01 00:00:00.000001' - val = '-365 day';
SELECT id FROM ts6_ts WHERE '2010-02-01 00:00:00.000001' - val = '-365 day' OR dummy();
SELECT id FROM ts6_ts WHERE '2011-01-01 00:00:00.000001' - val = '-31 day';
SELECT id FROM ts6_ts WHERE '2011-01-01 00:00:00.000001' - val = '-31 day' OR dummy();
SELECT id FROM ts6_ts WHERE '2011-01-31 12:00:00.000001' - val = '-12 hour';
SELECT id FROM ts6_ts WHERE '2011-01-31 12:00:00.000001' - val = '-12 hour' OR dummy();
SELECT id FROM ts6_ts WHERE '2011-01-31 23:30:00.000001' - val = '-30 minute';
SELECT id FROM ts6_ts WHERE '2011-01-31 23:30:00.000001' - val = '-30 minute' OR dummy();
SELECT id FROM ts6_ts WHERE '2011-01-31 23:59:30.123456' - val = '-29.876545 second';
SELECT id FROM ts6_ts WHERE '2011-01-31 23:59:30.123456' - val = '-29.876545 second' OR dummy();
SELECT id FROM ts6_ts WHERE '2011-03-01 00:00:00.000001' - val = '28 day';
SELECT id FROM ts6_ts WHERE '2011-03-01 00:00:00.000001' - val = '28 day' OR dummy();
SELECT id FROM ts6_ts WHERE '2011-02-01 00:00:00.000001' - val = '1469022 day 00:18:00';
SELECT id FROM ts6_ts WHERE '2011-02-01 00:00:00.000001' - val = '1469022 day 00:18:00' OR dummy();
SELECT id FROM ts6_ts WHERE '2011-02-01 00:00:00.000001' - val = '1468640 day 00:18:59';
SELECT id FROM ts6_ts WHERE '2011-02-01 00:00:00.000001' - val = '1468640 day 00:18:59' OR dummy();
SELECT id FROM ts6_ts WHERE '2011-02-01 BC 00:00:00.000001' - val = '-1469022 day 00:18:00';
SELECT id FROM ts6_ts WHERE '2011-02-01 BC 00:00:00.000001' - val = '-1469022 day 00:18:00' OR dummy();
SELECT id FROM ts6_ts WHERE '2011-02-01 BC 00:00:00.000001' - val = '-1468640 day 00:18:59';
SELECT id FROM ts6_ts WHERE '2011-02-01 BC 00:00:00.000001' - val = '-1468640 day 00:18:59' OR dummy();
SELECT id FROM ts6_ts WHERE '2011-02-01 00:00:00.000001 UTC' - val = '9 hour';
SELECT id FROM ts6_ts WHERE '2011-02-01 00:00:00.000001 UTC' - val = '9 hour' OR dummy();
SELECT id FROM ts6_ts WHERE '2005-02-01 00:00:00.000001' - val = '366 day';
SELECT id FROM ts6_ts WHERE '2005-02-01 00:00:00.000001' - val = '366 day' OR dummy();
SELECT id FROM ts6_ts WHERE '2101-02-01 00:00:00.000001' - val = '365 day';
SELECT id FROM ts6_ts WHERE '2101-02-01 00:00:00.000001' - val = '365 day' OR dummy();
SELECT id FROM ts6_ts WHERE '2401-02-01 00:00:00.000001' - val = '366 day';
SELECT id FROM ts6_ts WHERE '2401-02-01 00:00:00.000001' - val = '366 day' OR dummy();

SELECT id FROM ts9_ts WHERE '2010-02-01 00:00:00.000001' - val = '-365 day';
SELECT id FROM ts9_ts WHERE '2010-02-01 00:00:00.000001' - val = '-365 day' OR dummy();

-- 2033 : timestamp_mi_interval
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '1 year'::interval = '2010-02-01 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '1 month'::interval = '2011-01-01 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '365 day'::interval = '2010-02-01 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '31 day'::interval = '2011-01-01 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '12 hour'::interval = '2011-01-31 12:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '30 minute'::interval = '2011-01-31 23:30:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '29.876545 second'::interval = '2011-01-31 23:59:30.123456';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '-1 month'::interval = '2011-03-01 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '-28 day'::interval = '2011-03-01 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '-2011 year'::interval = '0001-02-01 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '2011 year'::interval = '0001-02-01 BC 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '-1 year'::interval = '2005-02-01 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '-1 year'::interval = '2101-02-01 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val - '-1 year'::interval = '2401-02-01 00:00:00.000001';

EXPLAIN (COSTS FALSE) SELECT id FROM ts9_ts WHERE val - '1 year'::interval = '2010-02-01 00:00:00.000001';

SELECT id FROM ts6_ts WHERE val - '1 year'::interval = '2010-02-01 00:00:00.000001';
SELECT id FROM ts6_ts WHERE val - '1 year'::interval = '2010-02-01 00:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE val - '1 month'::interval = '2011-01-01 00:00:00.000001';
SELECT id FROM ts6_ts WHERE val - '1 month'::interval = '2011-01-01 00:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE val - '365 day'::interval = '2010-02-01 00:00:00.000001';
SELECT id FROM ts6_ts WHERE val - '365 day'::interval = '2010-02-01 00:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE val - '31 day'::interval = '2011-01-01 00:00:00.000001';
SELECT id FROM ts6_ts WHERE val - '31 day'::interval = '2011-01-01 00:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE val - '12 hour'::interval = '2011-01-31 12:00:00.000001';
SELECT id FROM ts6_ts WHERE val - '12 hour'::interval = '2011-01-31 12:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE val - '30 minute'::interval = '2011-01-31 23:30:00.000001';
SELECT id FROM ts6_ts WHERE val - '30 minute'::interval = '2011-01-31 23:30:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE val - '29.876545 second'::interval = '2011-01-31 23:59:30.123456';
SELECT id FROM ts6_ts WHERE val - '29.876545 second'::interval = '2011-01-31 23:59:30.123456' OR dummy();
SELECT id FROM ts6_ts WHERE val - '-1 month'::interval = '2011-03-01 00:00:00.000001';
SELECT id FROM ts6_ts WHERE val - '-1 month'::interval = '2011-03-01 00:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE val - '-28 day'::interval = '2011-03-01 00:00:00.000001';
SELECT id FROM ts6_ts WHERE val - '-28 day'::interval = '2011-03-01 00:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE val - '-2011 year'::interval = '0001-02-01 00:00:00.000001';
SELECT id FROM ts6_ts WHERE val - '-2011 year'::interval = '0001-02-01 00:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE val - '2011 year'::interval = '0001-02-01 BC 00:00:00.000001';
SELECT id FROM ts6_ts WHERE val - '2011 year'::interval = '0001-02-01 BC 00:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE val - '-1 year'::interval = '2005-02-01 00:00:00.000001';
SELECT id FROM ts6_ts WHERE val - '-1 year'::interval = '2005-02-01 00:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE val - '-1 year'::interval = '2101-02-01 00:00:00.000001';
SELECT id FROM ts6_ts WHERE val - '-1 year'::interval = '2101-02-01 00:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE val - '-1 year'::interval = '2401-02-01 00:00:00.000001';
SELECT id FROM ts6_ts WHERE val - '-1 year'::interval = '2401-02-01 00:00:00.000001' OR dummy();

SELECT id FROM ts9_ts WHERE val - '1 year'::interval = '2010-02-01 00:00:00.000001';
SELECT id FROM ts9_ts WHERE val - '1 year'::interval = '2010-02-01 00:00:00.000001' OR dummy();

EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001'::timestamp - val = '2009-11-02 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001'::timestamp - val = '2010-02-02 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001'::timestamp - val = '2010-11-02 00:00:00.000001';

EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp - val = '2011-01-30 11:25:03.876545';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp - val = '2011-01-31 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp - val = '2011-01-31 23:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp - val = '2011-01-31 23:59:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp - val = '2011-01-31 23:59:58.876545';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp - val = '2011-02-02 12:34:56.123457';

EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE '2011-02-01 00:00:00.000001'::timestamp - val = '2011-01-30 11:25:03.876545';

SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001'::timestamp - val = '2009-11-02 00:00:00.000001';
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001'::timestamp - val = '2009-11-02 00:00:00.000001' OR dummy();
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001'::timestamp - val = '2010-02-02 00:00:00.000001';
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001'::timestamp - val = '2010-02-02 00:00:00.000001';
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001'::timestamp - val = '2010-11-02 00:00:00.000001';
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001'::timestamp - val = '2010-11-02 00:00:00.000001';

SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp - val = '2011-01-30 11:25:03.876545';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp - val = '2011-01-30 11:25:03.876545' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp - val = '2011-01-31 00:00:00.000001';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp - val = '2011-01-31 00:00:00.000001' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp - val = '2011-01-31 23:00:00.000001';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp - val = '2011-01-31 23:00:00.000001' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp - val = '2011-01-31 23:59:00.000001';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp - val = '2011-01-31 23:59:00.000001' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp - val = '2011-01-31 23:59:58.876545';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp - val = '2011-01-31 23:59:58.876545' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp - val = '2011-02-02 12:34:56.123457';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp - val = '2011-02-02 12:34:56.123457' OR dummy();

SELECT id FROM itds9_it WHERE '2011-02-01 00:00:00.000001'::timestamp - val = '2011-01-30 11:25:03.876545';
SELECT id FROM itds9_it WHERE '2011-02-01 00:00:00.000001'::timestamp - val = '2011-01-30 11:25:03.876545' OR dummy();

-- 2072 : date_mi_interval
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val - '1 year'::interval = '2010-02-01 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val - '1 month'::interval = '2011-01-01 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val - '365 day'::interval = '2010-02-01 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val - '31 day'::interval = '2011-01-01 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val - '12 hour'::interval = '2011-01-31 12:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val - '30 minute'::interval = '2011-01-31 23:30:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val - '30 second'::interval = '2011-01-31 23:59:30';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val - '-1 month'::interval = '2011-03-01 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val - '-28 day'::interval = '2011-03-01 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val - '-2011 year'::interval = '0001-02-01 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val - '2011 year'::interval = '0001-02-01 BC 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val - '-1 year'::interval = '2005-02-01 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val - '-1 year'::interval = '2101-02-01 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val - '-1 year'::interval = '2401-02-01 00:00:00';

SELECT id FROM date_timestamp WHERE val - '1 year'::interval = '2010-02-01 00:00:00';
SELECT id FROM date_timestamp WHERE val - '1 year'::interval = '2010-02-01 00:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE val - '1 month'::interval = '2011-01-01 00:00:00';
SELECT id FROM date_timestamp WHERE val - '1 month'::interval = '2011-01-01 00:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE val - '365 day'::interval = '2010-02-01 00:00:00';
SELECT id FROM date_timestamp WHERE val - '365 day'::interval = '2010-02-01 00:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE val - '31 day'::interval = '2011-01-01 00:00:00';
SELECT id FROM date_timestamp WHERE val - '31 day'::interval = '2011-01-01 00:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE val - '12 hour'::interval = '2011-01-31 12:00:00';
SELECT id FROM date_timestamp WHERE val - '12 hour'::interval = '2011-01-31 12:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE val - '30 minute'::interval = '2011-01-31 23:30:00';
SELECT id FROM date_timestamp WHERE val - '30 minute'::interval = '2011-01-31 23:30:00' OR dummy();
SELECT id FROM date_timestamp WHERE val - '30 second'::interval = '2011-01-31 23:59:30';
SELECT id FROM date_timestamp WHERE val - '30 second'::interval = '2011-01-31 23:59:30' OR dummy();
SELECT id FROM date_timestamp WHERE val - '-1 month'::interval = '2011-03-01 00:00:00';
SELECT id FROM date_timestamp WHERE val - '-1 month'::interval = '2011-03-01 00:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE val - '-28 day'::interval = '2011-03-01 00:00:00';
SELECT id FROM date_timestamp WHERE val - '-28 day'::interval = '2011-03-01 00:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE val - '-2011 year'::interval = '0001-02-01 00:00:00';
SELECT id FROM date_timestamp WHERE val - '-2011 year'::interval = '0001-02-01 00:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE val - '2011 year'::interval = '0001-02-01 BC 00:00:00';
SELECT id FROM date_timestamp WHERE val - '2011 year'::interval = '0001-02-01 BC 00:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE val - '-1 year'::interval = '2005-02-01 00:00:00';
SELECT id FROM date_timestamp WHERE val - '-1 year'::interval = '2005-02-01 00:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE val - '-1 year'::interval = '2101-02-01 00:00:00';
SELECT id FROM date_timestamp WHERE val - '-1 year'::interval = '2101-02-01 00:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE val - '-1 year'::interval = '2401-02-01 00:00:00';
SELECT id FROM date_timestamp WHERE val - '-1 year'::interval = '2401-02-01 00:00:00' OR dummy();

EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02 00:00:00'::timestamp - val = '2009-11-02 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02 00:00:00'::timestamp - val = '2010-02-02 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02 00:00:00'::timestamp - val = '2010-11-02 00:00:00';

EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00'::timestamp - val = '2011-01-30 11:25:03.876544';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00'::timestamp - val = '2011-01-31 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00'::timestamp - val = '2011-01-31 23:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00'::timestamp - val = '2011-01-31 23:59:00';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00'::timestamp - val = '2011-01-31 23:59:58';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00'::timestamp - val = '2011-02-02 12:34:56';

EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE '2011-02-01 00:00:00'::timestamp - val = '2011-01-30 11:25:03.876544';

SELECT id FROM itym_it WHERE '2011-02-02 00:00:00'::timestamp - val = '2009-11-02 00:00:00';
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00'::timestamp - val = '2009-11-02 00:00:00' OR dummy();
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00'::timestamp - val = '2010-02-02 00:00:00';
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00'::timestamp - val = '2010-02-02 00:00:00';
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00'::timestamp - val = '2010-11-02 00:00:00';
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00'::timestamp - val = '2010-11-02 00:00:00';

SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00'::timestamp - val = '2011-01-30 11:25:03.876544';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00'::timestamp - val = '2011-01-30 11:25:03.876544' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00'::timestamp - val = '2011-01-31 00:00:00';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00'::timestamp - val = '2011-01-31 00:00:00' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00'::timestamp - val = '2011-01-31 23:00:00';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00'::timestamp - val = '2011-01-31 23:00:00' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00'::timestamp - val = '2011-01-31 23:59:00';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00'::timestamp - val = '2011-01-31 23:59:00' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00'::timestamp - val = '2011-01-31 23:59:58.876544';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00'::timestamp - val = '2011-01-31 23:59:58.876544' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00'::timestamp - val = '2011-02-02 12:34:56.123456';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00'::timestamp - val = '2011-02-02 12:34:56.123456' OR dummy();

SELECT id FROM itds9_it WHERE '2011-02-01 00:00:00'::timestamp - val = '2011-01-30 11:25:03.876544';
SELECT id FROM itds9_it WHERE '2011-02-01 00:00:00'::timestamp - val = '2011-01-30 11:25:03.876544' OR dummy();

