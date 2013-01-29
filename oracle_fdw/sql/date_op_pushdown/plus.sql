\c contrib_regression_utf8

SET DateStyle = 'ISO,YMD';
SET IntervalStyle = 'sql_standard';
SET TIMEZONE = 'Asia/Tokyo';

-- date '+' operator
-- 1141 : date_pli
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val + 1.5 = '2011-01-01';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val + 30 = '2011-03-03';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val + 365 = '2012-02-01';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val + 395 = '2012-03-02';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val + 30 = '2004-03-02';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val + 30 = '2100-03-03';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val + 30 = '2400-03-02';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val + 30 = '2011-03-02 BC';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val + (-30) = '2011-01-02';

EXPLAIN (COSTS FALSE) SELECT id FROM number_integer WHERE '2011-01-31'::date + val = '2011-03-02';
EXPLAIN (COSTS FALSE) SELECT id FROM number_integer WHERE '2011-02-01'::date + val = '2012-02-01';
EXPLAIN (COSTS FALSE) SELECT id FROM number_integer WHERE '2011-02-01'::date + val = '2012-03-02';
EXPLAIN (COSTS FALSE) SELECT id FROM number_integer WHERE '2004-02-01'::date + val = '2004-03-02';
EXPLAIN (COSTS FALSE) SELECT id FROM number_integer WHERE '2100-02-01'::date + val = '2100-03-03';
EXPLAIN (COSTS FALSE) SELECT id FROM number_integer WHERE '2400-02-01'::date + val = '2400-03-02';
EXPLAIN (COSTS FALSE) SELECT id FROM number_integer WHERE '2011-02-01 BC'::date + val = '2011-03-03 BC';
EXPLAIN (COSTS FALSE) SELECT id FROM number_integer WHERE '2011-02-01'::date + val = '2011-01-02';

EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE date_date_1 + number_integer_1 = '2011-03-03';

SELECT id FROM date_date WHERE val + 1.5 = '2011-01-01';
SELECT id FROM date_date WHERE val + 30 = '2011-03-03';
SELECT id FROM date_date WHERE val + 30 = '2011-03-03' OR dummy();
SELECT id FROM date_date WHERE val + 365 = '2012-02-01';
SELECT id FROM date_date WHERE val + 365 = '2012-02-01' OR dummy();
SELECT id FROM date_date WHERE val + 395 = '2012-03-02';
SELECT id FROM date_date WHERE val + 395 = '2012-03-02' OR dummy();
SELECT id FROM date_date WHERE val + 30 = '2004-03-02';
SELECT id FROM date_date WHERE val + 30 = '2004-03-02' OR dummy();
SELECT id FROM date_date WHERE val + 30 = '2100-03-03';
SELECT id FROM date_date WHERE val + 30 = '2100-03-03' OR dummy();
SELECT id FROM date_date WHERE val + 30 = '2400-03-02';
SELECT id FROM date_date WHERE val + 30 = '2400-03-02' OR dummy();
SELECT id FROM date_date WHERE val + 30 = '2011-03-03 BC';
SELECT id FROM date_date WHERE val + 30 = '2011-03-03 BC' OR dummy();
SELECT id FROM date_date WHERE val + (-30) = '2011-01-02';
SELECT id FROM date_date WHERE val + (-30) = '2011-01-02' OR dummy();

SELECT id FROM number_integer WHERE '2011-02-01'::date + val = '2011-03-03';
SELECT id FROM number_integer WHERE '2011-02-01'::date + val = '2011-03-03' OR dummy();
SELECT id FROM number_integer WHERE '2011-02-01'::date + val = '2012-02-01';
SELECT id FROM number_integer WHERE '2011-02-01'::date + val = '2012-02-01' OR dummy();
SELECT id FROM number_integer WHERE '2011-02-01'::date + val = '2012-03-02';
SELECT id FROM number_integer WHERE '2011-02-01'::date + val = '2012-03-02' OR dummy();
SELECT id FROM number_integer WHERE '2004-02-01'::date + val = '2004-03-02';
SELECT id FROM number_integer WHERE '2004-02-01'::date + val = '2004-03-02' OR dummy();
SELECT id FROM number_integer WHERE '2100-02-01'::date + val = '2100-03-03';
SELECT id FROM number_integer WHERE '2100-02-01'::date + val = '2100-03-03' OR dummy();
SELECT id FROM number_integer WHERE '2400-02-01'::date + val = '2400-03-02';
SELECT id FROM number_integer WHERE '2400-02-01'::date + val = '2400-03-02' OR dummy();
SELECT id FROM number_integer WHERE '2011-02-01 BC'::date + val = '2011-03-03 BC';
SELECT id FROM number_integer WHERE '2011-02-01 BC'::date + val = '2011-03-03 BC' OR dummy();
SELECT id FROM number_integer WHERE '2011-02-01'::date + val = '2011-01-02';
SELECT id FROM number_integer WHERE '2011-02-01'::date + val = '2011-01-02' OR dummy();

SELECT id FROM all_type WHERE date_date_1 + number_integer_1 = '2011-03-03';
SELECT id FROM all_type WHERE date_date_1 + number_integer_1 = '2011-03-03' OR dummy();

-- 1169 : interval_pl
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '1 day' > '1 year 3 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '1 year 1 month' = '2 year 4 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '1 year' = '2 year 3 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '1 month' = '1 year 4 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '11 month' = '2 year 2 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '11 month' = '26 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '-4 month' = '11 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '-1 year -4 month' = '-1 month';

EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '1 month' > '1 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '1 day 01:02:03.123456' = '2 day 13:36:59.246912';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '1 day' = '2 day 12:34:56.123456';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '1 day' = '1 day 00:00:1.123456';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '1.123456 second' = '2.246912 second';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '-1 hour' = '23 hour';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '-1.123456 second' = '23:59:58.876544';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '-2 day 12:34:56.123456' = '-1 day';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '-2 day 12:34:56.123456' = '-1 day 12:34:56.123456';

EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE val + '1 day 01:02:03.123456' = '2 day 13:36:59.246912';
EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE val + '1 day 01:02:03.123456' >= '2 day 13:36:59.246912' AND val + '1 day 01:02:03.123456' < '2 day 13:36:59.246913';

EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '1 day' + val > '1 year 3 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '1 year 1 month' + val = '2 year 4 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '1 year' + val = '2 year 3 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '1 month' + val = '1 year 4 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '11 month' + val = '2 year 2 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '11 month' + val = '26 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '-4 month' + val = '11 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '-1 year -4 month' + val = '-1 month';

EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '1 month' + val > '1 month';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '1 day 01:02:03.123456' + val = '2 day 13:36:59.246912';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '1 day' + val = '2 day 12:34:56.123456';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '1 day' + val = '1 day 00:00:1.123456';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '1.123456 second' + val = '2.246912 second';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '-1 hour' + val = '23 hour';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '-1.123456 second' + val = '23:59:58.876544';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '-2 day 12:34:56.123456' + val = '-1 day';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '-2 day 12:34:56.123456' + val = '-1 day 12:34:56.123456';

EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE '1 day 01:02:03.123456' + val = '2 day 13:36:59.246912';
EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE '1 day 01:02:03.123456' + val >= '2 day 13:36:59.246912' AND '1 day 01:02:03.123456' + val < '2 day 13:36:59.246913';

EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE intervalym_interval_1 + intervalym_interval_2  = '3 year 3 month';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE intervalym_interval_1 + intervalds6_interval_2 > '2 year 1 month';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE intervalds6_interval_1 + intervalym_interval_2 > '2 year 1 month';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE intervalds6_interval_1 + intervalds6_interval_2 = '3 day 13:36:59.246912';

SELECT id FROM itym_it WHERE val + '1 day' > '1 year 3 month';
SELECT id FROM itym_it WHERE val + '1 day' > '1 year 3 month' OR dummy();
SELECT id FROM itym_it WHERE val + '1 year 1 month' = '2 year 4 month';
SELECT id FROM itym_it WHERE val + '1 year 1 month' = '2 year 4 month' OR dummy();
SELECT id FROM itym_it WHERE val + '1 year' = '2 year 3 month';
SELECT id FROM itym_it WHERE val + '1 year' = '2 year 3 month' OR dummy();
SELECT id FROM itym_it WHERE val + '1 month' = '1 year 4 month';
SELECT id FROM itym_it WHERE val + '1 month' = '1 year 4 month' OR dummy();
SELECT id FROM itym_it WHERE val + '11 month' = '2 year 2 month';
SELECT id FROM itym_it WHERE val + '11 month' = '2 year 2 month' OR dummy();
SELECT id FROM itym_it WHERE val + '11 month' = '26 month';
SELECT id FROM itym_it WHERE val + '11 month' = '26 month' OR dummy();
SELECT id FROM itym_it WHERE val + '-4 month' = '11 month';
SELECT id FROM itym_it WHERE val + '-4 month' = '11 month' OR dummy();
SELECT id FROM itym_it WHERE val + '-1 year -4 month' = '-1 month';
SELECT id FROM itym_it WHERE val + '-1 year -4 month' = '-1 month' OR dummy();

SELECT id FROM itds6_it WHERE val + '1 month' > '1 month';
SELECT id FROM itds6_it WHERE val + '1 month' > '1 month' OR dummy();
SELECT id FROM itds6_it WHERE val + '1 day 01:02:03.123456' = '2 day 13:36:59.246912';
SELECT id FROM itds6_it WHERE val + '1 day 01:02:03.123456' = '2 day 13:36:59.246912' OR dummy();
SELECT id FROM itds6_it WHERE val + '1 day' = '2 day 12:34:56.123456';
SELECT id FROM itds6_it WHERE val + '1 day' = '2 day 12:34:56.123456' OR dummy();
SELECT id FROM itds6_it WHERE val + '1 day' = '1 day 00:00:1.123456';
SELECT id FROM itds6_it WHERE val + '1 day' = '1 day 00:00:1.123456' OR dummy();
SELECT id FROM itds6_it WHERE val + '1.123456 second' = '2.246912 second';
SELECT id FROM itds6_it WHERE val + '1.123456 second' = '2.246912 second' OR dummy();
SELECT id FROM itds6_it WHERE val + '-1 hour' = '23 hour';
SELECT id FROM itds6_it WHERE val + '-1 hour' = '23 hour' OR dummy();
SELECT id FROM itds6_it WHERE val + '-1.123456 second' = '23:59:58.876544';
SELECT id FROM itds6_it WHERE val + '-1.123456 second' = '23:59:58.876544' OR dummy();
SELECT id FROM itds6_it WHERE val + '-2 day 12:34:56.123456' = '-1 day';
SELECT id FROM itds6_it WHERE val + '-2 day 12:34:56.123456' = '-1 day' OR dummy();
SELECT id FROM itds6_it WHERE val + '-2 day 12:34:56.123456' = '-1 day 12:34:56.123456';
SELECT id FROM itds6_it WHERE val + '-2 day 12:34:56.123456' = '-1 day 12:34:56.123456' OR dummy();

SELECT id FROM itds9_it WHERE val + '1 day 01:02:03.123456' = '2 day 13:36:59.246912';
SELECT id FROM itds9_it WHERE val + '1 day 01:02:03.123456' = '2 day 13:36:59.246912' OR dummy();
SELECT id FROM itds9_it WHERE val + '1 day 01:02:03.123456' >= '2 day 13:36:59.246912' AND val + '1 day 01:02:03.123456' < '2 day 13:36:59.246913';
SELECT id FROM itds9_it WHERE (val + '1 day 01:02:03.123456' >= '2 day 13:36:59.246912' AND val + '1 day 01:02:03.123456' < '2 day 13:36:59.246913') OR dummy();

SELECT id FROM itym_it WHERE '1 day' + val > '1 year 3 month';
SELECT id FROM itym_it WHERE '1 day' + val > '1 year 3 month' OR dummy();
SELECT id FROM itym_it WHERE '1 year 1 month' + val = '2 year 4 month';
SELECT id FROM itym_it WHERE '1 year 1 month' + val = '2 year 4 month' OR dummy();
SELECT id FROM itym_it WHERE '1 year' + val = '2 year 3 month';
SELECT id FROM itym_it WHERE '1 year' + val = '2 year 3 month' OR dummy();
SELECT id FROM itym_it WHERE '1 month' + val = '1 year 4 month';
SELECT id FROM itym_it WHERE '1 month' + val = '1 year 4 month' OR dummy();
SELECT id FROM itym_it WHERE '11 month' + val = '2 year 2 month';
SELECT id FROM itym_it WHERE '11 month' + val = '2 year 2 month' OR dummy();
SELECT id FROM itym_it WHERE '11 month' + val = '26 month';
SELECT id FROM itym_it WHERE '11 month' + val = '26 month' OR dummy();
SELECT id FROM itym_it WHERE '-4 month' + val = '11 month';
SELECT id FROM itym_it WHERE '-4 month' + val = '11 month' OR dummy();
SELECT id FROM itym_it WHERE '-1 year -4 month' + val = '-1 month';
SELECT id FROM itym_it WHERE '-1 year -4 month' + val = '-1 month' OR dummy();

SELECT id FROM itds6_it WHERE '1 month' + val > '1 month';
SELECT id FROM itds6_it WHERE '1 month' + val > '1 month' OR dummy();
SELECT id FROM itds6_it WHERE '1 day 01:02:03.123456' + val = '2 day 13:36:59.246912';
SELECT id FROM itds6_it WHERE '1 day 01:02:03.123456' + val = '2 day 13:36:59.246912' OR dummy();
SELECT id FROM itds6_it WHERE '1 day' + val = '2 day 12:34:56.123456';
SELECT id FROM itds6_it WHERE '1 day' + val = '2 day 12:34:56.123456' OR dummy();
SELECT id FROM itds6_it WHERE '1 day' + val = '1 day 00:00:1.123456';
SELECT id FROM itds6_it WHERE '1 day' + val = '1 day 00:00:1.123456' OR dummy();
SELECT id FROM itds6_it WHERE '1.123456 second' + val = '2.246912 second';
SELECT id FROM itds6_it WHERE '1.123456 second' + val = '2.246912 second' OR dummy();
SELECT id FROM itds6_it WHERE '-1 hour' + val = '23 hour';
SELECT id FROM itds6_it WHERE '-1 hour' + val = '23 hour' OR dummy();
SELECT id FROM itds6_it WHERE '-1.123456 second' + val = '23:59:58.876544';
SELECT id FROM itds6_it WHERE '-1.123456 second' + val = '23:59:58.876544' OR dummy();
SELECT id FROM itds6_it WHERE '-2 day 12:34:56.123456' + val = '-1 day';
SELECT id FROM itds6_it WHERE '-2 day 12:34:56.123456' + val = '-1 day' OR dummy();
SELECT id FROM itds6_it WHERE '-2 day 12:34:56.123456' + val = '-1 day 12:34:56.123456';
SELECT id FROM itds6_it WHERE '-2 day 12:34:56.123456' + val = '-1 day 12:34:56.123456' OR dummy();

SELECT id FROM itds9_it WHERE '1 day 01:02:03.123456' + val = '2 day 13:36:59.246912';
SELECT id FROM itds9_it WHERE '1 day 01:02:03.123456' + val = '2 day 13:36:59.246912' OR dummy();
SELECT id FROM itds9_it WHERE '1 day 01:02:03.123456' + val >= '2 day 13:36:59.246912' AND '1 day 01:02:03.123456' + val < '2 day 13:36:59.246913';
SELECT id FROM itds9_it WHERE ('1 day 01:02:03.123456' + val >= '2 day 13:36:59.246912' AND '1 day 01:02:03.123456' + val < '2 day 13:36:59.246913') OR dummy();

SELECT id FROM all_type WHERE intervalym_interval_1 + intervalym_interval_2 = '3 year 3 month';
SELECT id FROM all_type WHERE intervalym_interval_1 + intervalym_interval_2 = '3 year 3 month' OR dummy();
SELECT id FROM all_type WHERE intervalym_interval_1 + intervalds6_interval_2 > '2 year 1 month';
SELECT id FROM all_type WHERE intervalym_interval_1 + intervalds6_interval_2 > '2 year 1 month' OR dummy();
SELECT id FROM all_type WHERE intervalds6_interval_1 + intervalym_interval_2 > '2 year 1 month';
SELECT id FROM all_type WHERE intervalds6_interval_1 + intervalym_interval_2 > '2 year 1 month' OR dummy();
SELECT id FROM all_type WHERE intervalds6_interval_1 + intervalds6_interval_2 = '3 day 13:36:59.246912';
SELECT id FROM all_type WHERE intervalds6_interval_1 + intervalds6_interval_2 = '3 day 13:36:59.246912' OR dummy();

-- 1189 : timestamptz_pl_interval
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val + '1 year 3 month' = '2012-05-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val + '1 year' = '2012-02-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val + '3 month' = '2011-05-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val + '30 day 12:34:56.123456' = '2011-03-03 12:34:56.123457 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val + '30 day' = '2011-03-03 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val + '1 hour' = '2011-02-01 01:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val + '1 minute' = '2011-02-01 00:01:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val + '1.000001 second' = '2011-02-01 00:00:01.000002 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val + '-1 year -3 month' = '2009-11-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val + '-30 day -12:34:56.123456' = '2011-01-01 11:25:03.876545 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val + '1 year 3 month' = '2010-05-01 BC 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE val + '30 day 12:34:56.123456' = '2011-03-03 BC 12:34:56.123457 Asia/Tokyo';

EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val + '1 year 3 month' = '2012-05-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val + '1 year' = '2012-02-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val + '3 month' = '2011-05-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val + '30 day 12:34:56.123456' = '2011-03-03 12:34:56.123457 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val + '30 day' = '2011-03-03 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val + '1 hour' = '2011-02-01 01:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val + '1 minute' = '2011-02-01 00:01:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val + '1.000001 second' = '2011-02-01 00:00:01.000002 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val + '-1 year -3 month' = '2009-11-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val + '-30 day -12:34:56.123456' = '2011-01-01 11:25:03.876545 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val + '1 year 3 month' = '2010-05-01 BC 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE val + '30 day 12:34:56.123456' = '2011-03-03 BC 12:34:56.123457 Asia/Tokyo';

EXPLAIN (COSTS FALSE) SELECT id FROM tstz9_tstz WHERE val + '1 year' = '2012-02-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz9_tstz WHERE val + '1 year' >= '2012-02-01 00:00:00.000001 Asia/Tokyo' AND val + '1 year' < '2012-02-01 00:00:00.000002 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz9_tstz WHERE val + '1 year' = '2012-02-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz9_tstz WHERE val + '1 year' >= '2012-02-01 00:00:00.000001 Asia/Tokyo' AND val + '1 year' < '2012-02-01 00:00:00.000002 Asia/Tokyo';

SELECT id FROM tstz6_tstz WHERE val + '1 year 3 month' = '2012-05-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val + '1 year 3 month' = '2012-05-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE val + '1 year' = '2012-02-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val + '1 year' = '2012-02-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE val + '3 month' = '2011-05-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val + '3 month' = '2011-05-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE val + '30 day 12:34:56.123456' = '2011-03-03 12:34:56.123457 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val + '30 day 12:34:56.123456' = '2011-03-03 12:34:56.123457 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE val + '30 day' = '2011-03-03 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val + '30 day' = '2011-03-03 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE val + '1 hour' = '2011-02-01 01:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val + '1 hour' = '2011-02-01 01:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE val + '1 minute' = '2011-02-01 00:01:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val + '1 minute' = '2011-02-01 00:01:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE val + '1.000001 second' = '2011-02-01 00:00:01.000002 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val + '1.000001 second' = '2011-02-01 00:00:01.000002 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE val + '-1 year -3 month' = '2009-11-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val + '-1 year -3 month' = '2009-11-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE val + '-30 day -12:34:56.123456' = '2011-01-01 11:25:03.876545 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val + '-30 day -12:34:56.123456' = '2011-01-01 11:25:03.876545 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE val + '1 year 3 month' = '2010-05-01 BC 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val + '1 year 3 month' = '2010-05-01 BC 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE val + '30 day 12:34:56.123456' = '2011-03-03 BC 12:34:56.123457 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE val + '30 day 12:34:56.123456' = '2011-03-03 BC 12:34:56.123457 Asia/Tokyo' OR dummy();

SELECT id FROM tsltz6_tstz WHERE val + '1 year 3 month' = '2012-05-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val + '1 year 3 month' = '2012-05-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val + '1 year' = '2012-02-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val + '1 year' = '2012-02-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val + '3 month' = '2011-05-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val + '3 month' = '2011-05-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val + '30 day 12:34:56.123456' = '2011-03-03 12:34:56.123457 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val + '30 day 12:34:56.123456' = '2011-03-03 12:34:56.123457 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val + '30 day' = '2011-03-03 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val + '30 day' = '2011-03-03 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val + '1 hour' = '2011-02-01 01:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val + '1 hour' = '2011-02-01 01:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val + '1 minute' = '2011-02-01 00:01:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val + '1 minute' = '2011-02-01 00:01:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val + '1.000001 second' = '2011-02-01 00:00:01.000002 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val + '1.000001 second' = '2011-02-01 00:00:01.000002 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val + '-1 year -3 month' = '2009-11-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val + '-1 year -3 month' = '2009-11-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val + '-30 day -12:34:56.123456' = '2011-01-01 11:25:03.876545 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val + '-30 day -12:34:56.123456' = '2011-01-01 11:25:03.876545 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val + '1 year 3 month' = '2010-05-01 BC 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val + '1 year 3 month' = '2010-05-01 BC 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE val + '30 day 12:34:56.123456' = '2011-03-03 BC 12:34:56.123457 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE val + '30 day 12:34:56.123456' = '2011-03-03 BC 12:34:56.123457 Asia/Tokyo' OR dummy();

SELECT id FROM tstz9_tstz WHERE val + '1 year' = '2012-02-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz9_tstz WHERE val + '1 year' = '2012-02-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz9_tstz WHERE val + '1 year' >= '2012-02-01 00:00:00.000001 Asia/Tokyo' AND val + '1 year' < '2012-02-01 00:00:00.000002 Asia/Tokyo';
SELECT id FROM tsltz9_tstz WHERE val + '1 year' = '2012-02-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz9_tstz WHERE val + '1 year' = '2012-02-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz9_tstz WHERE val + '1 year' >= '2012-02-01 00:00:00.000001 Asia/Tokyo' AND val + '1 year' < '2012-02-01 00:00:00.000002 Asia/Tokyo';

EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2012-05-02 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2012-02-02 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-05-02 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2009-11-02 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02 BC 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2010-05-02 BC 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02 BC 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2013-11-02 BC 00:00:00.000001 Asia/Tokyo';

EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-02-02 12:34:56.123457 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-02-02 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-02-01 01:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-02-01 00:01:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-02-01 00:00:01.123457 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-01-30 11:25:03.876545 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 BC 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-02-02 BC 12:34:56.123457 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 BC 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-01-30 BC 11:25:03.876545 Asia/Tokyo';

EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-02-02 12:34:56.123457 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-02-02 12:34:56.123457 Asia/Tokyo' OR dummy();
EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val >= '2011-02-02 12:34:56.123457 Asia/Tokyo' AND '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val < '2011-02-02 12:34:56.123458 Asia/Tokyo';

EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE timestamptz6_timestamptz_1 + intervalym_interval_2 = '2011-05-02 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE timestamptz6_timestamptz_1 + intervalds6_interval_2 = '2011-02-02 13:36:59.246913 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE timestampltz6_timestamptz_1 + intervalym_interval_2 = '2011-05-02 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE timestampltz6_timestamptz_1 + intervalds6_interval_2 = '2011-02-02 13:36:59.246913 Asia/Tokyo';

SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2012-05-02 00:00:00.000001 Asia/Tokyo';
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2012-05-02 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2012-02-02 00:00:00.000001 Asia/Tokyo';
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2012-02-02 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-05-02 00:00:00.000001 Asia/Tokyo';
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-05-02 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2009-11-02 00:00:00.000001 Asia/Tokyo';
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2009-11-02 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM itym_it WHERE '2011-02-02 BC 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2010-05-02 BC 00:00:00.000001 Asia/Tokyo';
SELECT id FROM itym_it WHERE '2011-02-02 BC 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2010-05-02 BC 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM itym_it WHERE '2011-02-02 BC 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2013-11-02 BC 00:00:00.000001 Asia/Tokyo';
SELECT id FROM itym_it WHERE '2011-02-02 BC 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2013-11-02 BC 00:00:00.000001 Asia/Tokyo' OR dummy();

SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-02-02 12:34:56.123457 Asia/Tokyo';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-02-02 12:34:56.123457 Asia/Tokyo' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-02-02 00:00:00.000001 Asia/Tokyo';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-02-02 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-02-01 01:00:00.000001 Asia/Tokyo';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-02-01 01:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-02-01 00:01:00.000001 Asia/Tokyo';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-02-01 00:01:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-02-01 00:00:01.123457 Asia/Tokyo';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-02-01 00:00:01.123457 Asia/Tokyo' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-01-30 11:25:03.876545 Asia/Tokyo';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-01-30 11:25:03.876545 Asia/Tokyo' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 BC 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-02-02 BC 12:34:56.123457 Asia/Tokyo';
SELECT id FROM itds6_it WHERE '2011-02-01 BC 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-02-02 BC 12:34:56.123457 Asia/Tokyo' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 BC 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-01-30 BC 11:25:03.876545 Asia/Tokyo';
SELECT id FROM itds6_it WHERE '2011-02-01 BC 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-01-30 BC 11:25:03.876545 Asia/Tokyo' OR dummy();

SELECT id FROM itds9_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-02-02 12:34:56.123457 Asia/Tokyo';
SELECT id FROM itds9_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val = '2011-02-02 12:34:56.123457 Asia/Tokyo' OR dummy();
SELECT id FROM itds9_it WHERE '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val >= '2011-02-02 12:34:56.123457 Asia/Tokyo' AND '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz + val < '2011-02-02 12:34:56.123458 Asia/Tokyo';

SELECT id FROM all_type WHERE timestamptz6_timestamptz_1 + intervalym_interval_2 = '2011-05-02 00:00:00.000001 Asia/Tokyo';
SELECT id FROM all_type WHERE timestamptz6_timestamptz_1 + intervalym_interval_2 = '2011-05-02 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM all_type WHERE timestamptz6_timestamptz_1 + intervalds6_interval_2 = '2011-02-02 13:36:59.246913 Asia/Tokyo';
SELECT id FROM all_type WHERE timestamptz6_timestamptz_1 + intervalds6_interval_2 = '2011-02-02 13:36:59.246913 Asia/Tokyo' OR dummy();
SELECT id FROM all_type WHERE timestampltz6_timestamptz_1 + intervalym_interval_2 = '2011-05-02 00:00:00.000001 Asia/Tokyo';
SELECT id FROM all_type WHERE timestampltz6_timestamptz_1 + intervalym_interval_2 = '2011-05-02 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM all_type WHERE timestampltz6_timestamptz_1 + intervalds6_interval_2 = '2011-02-02 13:36:59.246913 Asia/Tokyo';
SELECT id FROM all_type WHERE timestampltz6_timestamptz_1 + intervalds6_interval_2 = '2011-02-02 13:36:59.246913 Asia/Tokyo' OR dummy();

-- Leap second
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2008-12-31 23:59:59.000000 UTC'::timestamptz + val = '2009-01-01 00:00:00.123456 UTC';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2009-01-01 00:00:00.123456 UTC'::timestamptz + val = '2008-12-31 23:59:59.000000 UTC';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2008-12-31 23:59:60.000000 UTC'::timestamptz + val = '2009-01-01 00:00:01.123456 UTC';

SELECT id FROM itds6_it WHERE '2008-12-31 23:59:59.000000 UTC'::timestamptz + val = '2009-01-01 00:00:00.123456 UTC';
SELECT id FROM itds6_it WHERE '2008-12-31 23:59:59.000000 UTC'::timestamptz + val = '2009-01-01 00:00:00.123456 UTC' OR dummy();
SELECT id FROM itds6_it WHERE '2009-01-01 00:00:00.123456 UTC'::timestamptz + val = '2008-12-31 23:59:59.000000 UTC';
SELECT id FROM itds6_it WHERE '2009-01-01 00:00:00.123456 UTC'::timestamptz + val = '2008-12-31 23:59:59.000000 UTC' OR dummy();
SELECT id FROM itds6_it WHERE '2008-12-31 23:59:60.000000 UTC'::timestamptz + val = '2009-01-01 00:00:01.123456 UTC';
SELECT id FROM itds6_it WHERE '2008-12-31 23:59:60.000000 UTC'::timestamptz + val = '2009-01-01 00:00:01.123456 UTC' OR dummy();

-- 2032 : timestamp_pl_interval
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val + '1 year 3 month' = '2012-05-01 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val + '1 year' = '2012-02-01 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val + '3 month' = '2011-05-01 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val + '30 day 12:34:56.123456' = '2011-03-03 12:34:56.123457';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val + '30 day' = '2011-03-03 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val + '1 hour' = '2011-02-01 01:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val + '1 minute' = '2011-02-01 00:01:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val + '1.000001 second' = '2011-02-01 00:00:01.000002';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val + '-1 year -3 month' = '2009-11-01 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val + '-30 day -12:34:56.123456' = '2011-01-01 11:25:03.876545';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val + '1 year 3 month' = '2010-05-01 BC 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE val + '30 day 12:34:56.123456' = '2011-03-03 BC 12:34:56.123457';

EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val + '1 year 3 month' = '2012-05-01 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val + '1 year' = '2012-02-01 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val + '3 month' = '2011-05-01 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val + '30 day 12:34:56.123456' = '2011-03-03 12:34:56.123456';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val + '30 day' = '2011-03-03 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val + '1 hour' = '2011-02-01 01:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val + '1 minute' = '2011-02-01 00:01:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val + '1.000001 second' = '2011-02-01 00:00:01.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val + '-1 year -3 month' = '2009-11-01 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val + '-30 day -12:34:56.123456' = '2011-01-01 11:25:03.876544';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val + '1 year 3 month' = '2010-05-01 BC 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE val + '30 day 12:34:56.123456' = '2011-03-03 BC 12:34:56.123456';

EXPLAIN (COSTS FALSE) SELECT id FROM ts9_ts WHERE val + '1 year' = '2012-02-01 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts9_ts WHERE val + '1 year' >= '2012-02-01 00:00:00.000001' AND val + '1 year' < '2012-02-01 00:00:00.000002';

SELECT id FROM ts6_ts WHERE val + '1 year 3 month' = '2012-05-01 00:00:00.000001';
SELECT id FROM ts6_ts WHERE val + '1 year 3 month' = '2012-05-01 00:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE val + '1 year' = '2012-02-01 00:00:00.000001';
SELECT id FROM ts6_ts WHERE val + '1 year' = '2012-02-01 00:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE val + '3 month' = '2011-05-01 00:00:00.000001';
SELECT id FROM ts6_ts WHERE val + '3 month' = '2011-05-01 00:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE val + '30 day 12:34:56.123456' = '2011-03-03 12:34:56.123457';
SELECT id FROM ts6_ts WHERE val + '30 day 12:34:56.123456' = '2011-03-03 12:34:56.123457' OR dummy();
SELECT id FROM ts6_ts WHERE val + '30 day' = '2011-03-03 00:00:00.000001';
SELECT id FROM ts6_ts WHERE val + '30 day' = '2011-03-03 00:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE val + '1 hour' = '2011-02-01 01:00:00.000001';
SELECT id FROM ts6_ts WHERE val + '1 hour' = '2011-02-01 01:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE val + '1 minute' = '2011-02-01 00:01:00.000001';
SELECT id FROM ts6_ts WHERE val + '1 minute' = '2011-02-01 00:01:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE val + '1.000001 second' = '2011-02-01 00:00:01.000002';
SELECT id FROM ts6_ts WHERE val + '1.000001 second' = '2011-02-01 00:00:01.000002' OR dummy();
SELECT id FROM ts6_ts WHERE val + '-1 year -3 month' = '2009-11-01 00:00:00.000001';
SELECT id FROM ts6_ts WHERE val + '-1 year -3 month' = '2009-11-01 00:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE val + '-30 day -12:34:56.123456' = '2011-01-01 11:25:03.876545';
SELECT id FROM ts6_ts WHERE val + '-30 day -12:34:56.123456' = '2011-01-01 11:25:03.876545' OR dummy();
SELECT id FROM ts6_ts WHERE val + '1 year 3 month' = '2010-05-01 BC 00:00:00.000001';
SELECT id FROM ts6_ts WHERE val + '1 year 3 month' = '2010-05-01 BC 00:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE val + '30 day 12:34:56.123456' = '2011-03-03 BC 12:34:56.123457';
SELECT id FROM ts6_ts WHERE val + '30 day 12:34:56.123456' = '2011-03-03 BC 12:34:56.123457' OR dummy();

SELECT id FROM date_timestamp WHERE val + '1 year 3 month' = '2012-05-01 00:00:00';
SELECT id FROM date_timestamp WHERE val + '1 year 3 month' = '2012-05-01 00:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE val + '1 year' = '2012-02-01 00:00:00';
SELECT id FROM date_timestamp WHERE val + '1 year' = '2012-02-01 00:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE val + '3 month' = '2011-05-01 00:00:00';
SELECT id FROM date_timestamp WHERE val + '3 month' = '2011-05-01 00:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE val + '30 day 12:34:56.123456' = '2011-03-03 12:34:56.123456';
SELECT id FROM date_timestamp WHERE val + '30 day 12:34:56.123456' = '2011-03-03 12:34:56.123456' OR dummy();
SELECT id FROM date_timestamp WHERE val + '30 day' = '2011-03-03 00:00:00';
SELECT id FROM date_timestamp WHERE val + '30 day' = '2011-03-03 00:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE val + '1 hour' = '2011-02-01 01:00:00';
SELECT id FROM date_timestamp WHERE val + '1 hour' = '2011-02-01 01:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE val + '1 minute' = '2011-02-01 00:01:00';
SELECT id FROM date_timestamp WHERE val + '1 minute' = '2011-02-01 00:01:00' OR dummy();
SELECT id FROM date_timestamp WHERE val + '1.000001 second' = '2011-02-01 00:00:01.000001';
SELECT id FROM date_timestamp WHERE val + '1.000001 second' = '2011-02-01 00:00:01.000001' OR dummy();
SELECT id FROM date_timestamp WHERE val + '-1 year -3 month' = '2009-11-01 00:00:00';
SELECT id FROM date_timestamp WHERE val + '-1 year -3 month' = '2009-11-01 00:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE val + '-30 day -12:34:56.123456' = '2011-01-01 11:25:03.876544';
SELECT id FROM date_timestamp WHERE val + '-30 day -12:34:56.123456' = '2011-01-01 11:25:03.876544' OR dummy();
SELECT id FROM date_timestamp WHERE val + '1 year 3 month' = '2010-05-01 BC 00:00:00';
SELECT id FROM date_timestamp WHERE val + '1 year 3 month' = '2010-05-01 BC 00:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE val + '30 day 12:34:56.123456' = '2011-03-03 BC 12:34:56.123456';
SELECT id FROM date_timestamp WHERE val + '30 day 12:34:56.123456' = '2011-03-03 BC 12:34:56.123456' OR dummy();

SELECT id FROM ts9_ts WHERE val + '1 year' = '2012-02-01 00:00:00000001';
SELECT id FROM ts9_ts WHERE val + '1 year' = '2012-02-01 00:00:00.000001' OR dummy();
SELECT id FROM ts9_ts WHERE val + '1 year' >= '2012-02-01 00:00:00.000001' AND val + '1 year' < '2012-02-01 00:00:00.000002';

EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001'::timestamp + val = '2012-05-02 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001'::timestamp + val = '2012-02-02 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001'::timestamp + val = '2011-05-02 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001'::timestamp + val = '2009-11-02 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02 BC 00:00:00.000001'::timestamp + val = '2010-05-02 BC 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02 BC 00:00:00.000001'::timestamp + val = '2013-11-02 BC 00:00:00.000001';

EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp + val = '2011-02-02 12:34:56.123457';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp + val = '2011-02-02 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp + val = '2011-02-01 01:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp + val = '2011-02-01 00:01:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp + val = '2011-02-01 00:00:01.123457';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp + val = '2011-01-30 11:25:03.876545';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 BC 00:00:00.000001'::timestamp + val = '2011-02-02 BC 12:34:56.123457';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 BC 00:00:00.000001'::timestamp + val = '2011-01-30 BC 11:25:03.876545';

EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE '2011-02-01 00:00:00.000001'::timestamp + val = '2011-02-02 12:34:56.123457';
EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE '2011-02-01 00:00:00.000001'::timestamp + val = '2011-02-02 12:34:56.123457' OR dummy();
EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE '2011-02-01 00:00:00.000001'::timestamp + val >= '2011-02-02 12:34:56.123457' AND '2011-02-01 00:00:00.000001'::timestamp + val < '2011-02-02 12:34:56.123458';

EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE timestamptz6_timestamptz_1 + intervalym_interval_2 = '2011-05-02 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE timestamptz6_timestamptz_1 + intervalds6_interval_2 = '2011-02-02 13:36:59.246913';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE timestampltz6_timestamptz_1 + intervalym_interval_2 = '2011-05-02 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE timestampltz6_timestamptz_1 + intervalds6_interval_2 = '2011-02-02 13:36:59.246913';

SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001'::timestamp + val = '2012-05-02 00:00:00.000001';
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001'::timestamp + val = '2012-05-02 00:00:00.000001' OR dummy();
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001'::timestamp + val = '2012-02-02 00:00:00.000001';
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001'::timestamp + val = '2012-02-02 00:00:00.000001' OR dummy();
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001'::timestamp + val = '2011-05-02 00:00:00.000001';
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001'::timestamp + val = '2011-05-02 00:00:00.000001' OR dummy();
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001'::timestamp + val = '2009-11-02 00:00:00.000001';
SELECT id FROM itym_it WHERE '2011-02-02 00:00:00.000001'::timestamp + val = '2009-11-02 00:00:00.000001' OR dummy();
SELECT id FROM itym_it WHERE '2011-02-02 BC 00:00:00.000001'::timestamp + val = '2010-05-02 BC 00:00:00.000001';
SELECT id FROM itym_it WHERE '2011-02-02 BC 00:00:00.000001'::timestamp + val = '2010-05-02 BC 00:00:00.000001' OR dummy();
SELECT id FROM itym_it WHERE '2011-02-02 BC 00:00:00.000001'::timestamp + val = '2013-11-02 BC 00:00:00.000001';
SELECT id FROM itym_it WHERE '2011-02-02 BC 00:00:00.000001'::timestamp + val = '2013-11-02 BC 00:00:00.000001' OR dummy();

SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp + val = '2011-02-02 12:34:56.123457';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp + val = '2011-02-02 12:34:56.123457' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp + val = '2011-02-02 00:00:00.000001';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp + val = '2011-02-02 00:00:00.000001' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp + val = '2011-02-01 01:00:00.000001';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp + val = '2011-02-01 01:00:00.000001' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp + val = '2011-02-01 00:01:00.000001';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp + val = '2011-02-01 00:01:00.000001' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp + val = '2011-02-01 00:00:01.123457';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp + val = '2011-02-01 00:00:01.123457' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp + val = '2011-01-30 11:25:03.876545';
SELECT id FROM itds6_it WHERE '2011-02-01 00:00:00.000001'::timestamp + val = '2011-01-30 11:25:03.876545' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 BC 00:00:00.000001'::timestamp + val = '2011-02-02 BC 12:34:56.123457';
SELECT id FROM itds6_it WHERE '2011-02-01 BC 00:00:00.000001'::timestamp + val = '2011-02-02 BC 12:34:56.123457' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 BC 00:00:00.000001'::timestamp + val = '2011-01-30 BC 11:25:03.876545';
SELECT id FROM itds6_it WHERE '2011-02-01 BC 00:00:00.000001'::timestamp + val = '2011-01-30 BC 11:25:03.876545' OR dummy();

SELECT id FROM itds9_it WHERE '2011-02-01 00:00:00.000001'::timestamp + val = '2011-02-02 12:34:56.123457';
SELECT id FROM itds9_it WHERE '2011-02-01 00:00:00.000001'::timestamp + val = '2011-02-02 12:34:56.123457' OR dummy();
SELECT id FROM itds9_it WHERE '2011-02-01 00:00:00.000001'::timestamp + val >= '2011-02-02 12:34:56.123457' AND '2011-02-01 00:00:00.000001'::timestamp + val < '2011-02-02 12:34:56.123458';

SELECT id FROM all_type WHERE timestamptz6_timestamptz_1 + intervalym_interval_2 = '2011-05-02 00:00:00.000001';
SELECT id FROM all_type WHERE timestamptz6_timestamptz_1 + intervalym_interval_2 = '2011-05-02 00:00:00.000001' OR dummy();
SELECT id FROM all_type WHERE timestamptz6_timestamptz_1 + intervalds6_interval_2 = '2011-02-02 13:36:59.246913';
SELECT id FROM all_type WHERE timestamptz6_timestamptz_1 + intervalds6_interval_2 = '2011-02-02 13:36:59.246913' OR dummy();
SELECT id FROM all_type WHERE timestampltz6_timestamptz_1 + intervalym_interval_2 = '2011-05-02 00:00:00.000001';
SELECT id FROM all_type WHERE timestampltz6_timestamptz_1 + intervalym_interval_2 = '2011-05-02 00:00:00.000001' OR dummy();
SELECT id FROM all_type WHERE timestampltz6_timestamptz_1 + intervalds6_interval_2 = '2011-02-02 13:36:59.246913';
SELECT id FROM all_type WHERE timestampltz6_timestamptz_1 + intervalds6_interval_2 = '2011-02-02 13:36:59.246913' OR dummy();

-- 2071 : date_pl_interval
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val + '1 year 3 month'::interval = '2012-05-01';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val + '1 year'::interval = '2012-02-01';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val + '3 month'::interval = '2011-05-01';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val + '30 day 12:34:56.123456'::interval = '2011-03-03 12:34:56.123456';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val + '30 day'::interval = '2011-03-03';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val + '1 hour'::interval = '2011-02-01 01:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val + '1 minute'::interval = '2011-02-01 00:01:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val + '1.000001 second'::interval = '2011-02-01 00:00:01.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val + '-1 year -3 month'::interval = '2009-11-01';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val + '-30 day -12:34:56.123456'::interval = '2011-01-01 11:25:03.876544';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val + '1 year 3 month'::interval = '2010-05-01 BC';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE val + '30 day 12:34:56.123456'::interval = '2011-03-03 BC 12:34:56.123456';

SELECT id FROM date_date WHERE val + '1 year 3 month'::interval = '2012-05-01';
SELECT id FROM date_date WHERE val + '1 year 3 month'::interval = '2012-05-01' OR dummy();
SELECT id FROM date_date WHERE val + '1 year'::interval = '2012-02-01';
SELECT id FROM date_date WHERE val + '1 year'::interval = '2012-02-01' OR dummy();
SELECT id FROM date_date WHERE val + '3 month'::interval = '2011-05-01';
SELECT id FROM date_date WHERE val + '3 month'::interval = '2011-05-01' OR dummy();
SELECT id FROM date_date WHERE val + '30 day 12:34:56.123456'::interval = '2011-03-03 12:34:56.123456';
SELECT id FROM date_date WHERE val + '30 day 12:34:56.123456'::interval = '2011-03-03 12:34:56.123456' OR dummy();
SELECT id FROM date_date WHERE val + '30 day'::interval = '2011-03-03';
SELECT id FROM date_date WHERE val + '30 day'::interval = '2011-03-03' OR dummy();
SELECT id FROM date_date WHERE val + '1 hour'::interval = '2011-02-01 01:00:00';
SELECT id FROM date_date WHERE val + '1 hour'::interval = '2011-02-01 01:00:00' OR dummy();
SELECT id FROM date_date WHERE val + '1 minute'::interval = '2011-02-01 00:01:00';
SELECT id FROM date_date WHERE val + '1 minute'::interval = '2011-02-01 00:01:00' OR dummy();
SELECT id FROM date_date WHERE val + '1.000001 second'::interval = '2011-02-01 00:00:01.000001';
SELECT id FROM date_date WHERE val + '1.000001 second'::interval = '2011-02-01 00:00:01.000001' OR dummy();
SELECT id FROM date_date WHERE val + '-1 year -3 month'::interval = '2009-11-01';
SELECT id FROM date_date WHERE val + '-1 year -3 month'::interval = '2009-11-01' OR dummy();
SELECT id FROM date_date WHERE val + '-30 day -12:34:56.123456'::interval = '2011-01-01 11:25:03.876544';
SELECT id FROM date_date WHERE val + '-30 day -12:34:56.123456'::interval = '2011-01-01 11:25:03.876544' OR dummy();
SELECT id FROM date_date WHERE val + '1 year 3 month'::interval = '2010-05-01 BC';
SELECT id FROM date_date WHERE val + '1 year 3 month'::interval = '2010-05-01 BC' OR dummy();
SELECT id FROM date_date WHERE val + '30 day 12:34:56.123456'::interval = '2011-03-03 BC 12:34:56.123456';
SELECT id FROM date_date WHERE val + '30 day 12:34:56.123456'::interval = '2011-03-03 BC 12:34:56.123456' OR dummy();

EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02'::date + val = '2012-05-02';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02'::date + val = '2012-02-02';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02'::date + val = '2011-05-02';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02'::date + val = '2009-11-02';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02 BC'::date + val = '2010-05-02 BC';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE '2011-02-02 BC'::date + val = '2013-11-02 BC';

EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01'::date + val = '2011-02-02 12:34:56.123456';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01'::date + val = '2011-02-02';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01'::date + val = '2011-02-01 01:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01'::date + val = '2011-02-01 00:01:00';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01'::date + val = '2011-02-01 00:00:01.123456';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01'::date + val = '2011-01-30 11:25:03.876544';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 BC'::date + val = '2011-02-02 BC 12:34:56.123456';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE '2011-02-01 BC'::date + val = '2011-01-30 BC 11:25:03.876544';

EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE '2011-02-01'::date + val = '2011-02-02 12:34:56.123456';
EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE '2011-02-01'::date + val = '2011-02-02 12:34:56.123456' OR dummy();
EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE '2011-02-01'::date + val >= '2011-02-02 12:34:56' AND '2011-02-01'::date + val < '2011-02-02 12:34:57';
EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE ('2011-02-01'::date + val >= '2011-02-02 12:34:56' AND '2011-02-01'::date + val < '2011-02-02 12:34:57') OR dummy();

EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE timestamptz6_timestamptz_1 + intervalym_interval_2 = '2011-05-01';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE timestamptz6_timestamptz_1 + intervalds6_interval_2 = '2011-02-01 13:36:59.246912';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE date_date_1 + intervalds6_interval_2 >= '2011-02-01 13:36:59' AND date_date_1 + intervalds6_interval_2 < '2011-02-01 13:37:00';

SELECT id FROM itym_it WHERE '2011-02-02'::date + val = '2012-05-02';
SELECT id FROM itym_it WHERE '2011-02-02'::date + val = '2012-05-02' OR dummy();
SELECT id FROM itym_it WHERE '2011-02-02'::date + val = '2012-02-02';
SELECT id FROM itym_it WHERE '2011-02-02'::date + val = '2012-02-02' OR dummy();
SELECT id FROM itym_it WHERE '2011-02-02'::date + val = '2011-05-02';
SELECT id FROM itym_it WHERE '2011-02-02'::date + val = '2011-05-02' OR dummy();
SELECT id FROM itym_it WHERE '2011-02-02'::date + val = '2009-11-02';
SELECT id FROM itym_it WHERE '2011-02-02'::date + val = '2009-11-02' OR dummy();
SELECT id FROM itym_it WHERE '2011-02-02 BC'::date + val = '2010-05-02 BC';
SELECT id FROM itym_it WHERE '2011-02-02 BC'::date + val = '2010-05-02 BC' OR dummy();
SELECT id FROM itym_it WHERE '2011-02-02 BC'::date + val = '2013-11-02 BC';
SELECT id FROM itym_it WHERE '2011-02-02 BC'::date + val = '2013-11-02 BC' OR dummy();

SELECT id FROM itds6_it WHERE '2011-02-01'::date + val = '2011-02-02 12:34:56.123456';
SELECT id FROM itds6_it WHERE '2011-02-01'::date + val = '2011-02-02 12:34:56.123456' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01'::date + val = '2011-02-02';
SELECT id FROM itds6_it WHERE '2011-02-01'::date + val = '2011-02-02' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01'::date + val = '2011-02-01 01:00:00';
SELECT id FROM itds6_it WHERE '2011-02-01'::date + val = '2011-02-01 01:00:00' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01'::date + val = '2011-02-01 00:01:00';
SELECT id FROM itds6_it WHERE '2011-02-01'::date + val = '2011-02-01 00:01:00' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01'::date + val = '2011-02-01 00:00:01.000001';
SELECT id FROM itds6_it WHERE '2011-02-01'::date + val = '2011-02-01 00:00:01.123456' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01'::date + val = '2011-01-30 11:25:03.876544';
SELECT id FROM itds6_it WHERE '2011-02-01'::date + val = '2011-01-30 11:25:03.876544' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 BC'::date + val = '2011-02-02 BC 12:34:56.123456';
SELECT id FROM itds6_it WHERE '2011-02-01 BC'::date + val = '2011-02-02 BC 12:34:56.123456' OR dummy();
SELECT id FROM itds6_it WHERE '2011-02-01 BC'::date + val = '2011-01-30 BC 11:25:03.876544';
SELECT id FROM itds6_it WHERE '2011-02-01 BC'::date + val = '2011-01-30 BC 11:25:03.876544' OR dummy();

SELECT id FROM itds9_it WHERE '2011-02-01'::date + val = '2011-02-02 12:34:56.123456';
SELECT id FROM itds9_it WHERE '2011-02-01'::date + val = '2011-02-02 12:34:56.123456' OR dummy();
SELECT id FROM itds9_it WHERE '2011-02-01'::date + val >= '2011-02-02 12:34:56' AND '2011-02-01'::date + val < '2011-02-02 12:34:57';
SELECT id FROM itds9_it WHERE ('2011-02-01'::date + val >= '2011-02-02 12:34:56' AND '2011-02-01'::date + val < '2011-02-02 12:34:57') OR dummy();

SELECT id FROM all_type WHERE date_date_1 + intervalym_interval_2 = '2011-05-01';
SELECT id FROM all_type WHERE date_date_1 + intervalym_interval_2 = '2011-05-01' OR dummy();
SELECT id FROM all_type WHERE date_date_1 + intervalds6_interval_2 = '2011-02-01 13:36:59.246912';
SELECT id FROM all_type WHERE date_date_1 + intervalds6_interval_2 = '2011-02-01 13:36:59.246912' OR dummy();
SELECT id FROM all_type WHERE date_date_1 + intervalds6_interval_2 >= '2011-02-01 13:36:59' AND date_date_1 + intervalds6_interval_2 < '2011-02-01 13:37:00';
SELECT id FROM all_type WHERE (date_date_1 + intervalds6_interval_2 >= '2011-02-01 13:36:59' AND date_date_1 + intervalds6_interval_2 < '2011-02-01 13:37:00') OR dummy();

-- 2546 : interval_pl_date
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE '1 year 3 month'::interval + val = '2012-05-01';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE '1 year'::interval + val = '2012-02-01';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE '3 month'::interval + val = '2011-05-01';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE '30 day 12:34:56.123456'::interval + val = '2011-03-03 12:34:56.123456';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE '30 day'::interval + val = '2011-03-03';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE '1 hour'::interval + val = '2011-02-01 01:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE '1 minute'::interval + val = '2011-02-01 00:01:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE '1.000001 second'::interval + val = '2011-02-01 00:00:01.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE '-1 year -3 month'::interval + val = '2009-11-01';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE '-30 day -12:34:56.123456'::interval + val = '2011-01-01 11:25:03.876544';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE '1 year 3 month'::interval + val = '2010-05-01 BC';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE '30 day 12:34:56.123456'::interval + val = '2011-03-03 BC 12:34:56.123456';

SELECT id FROM date_date WHERE '1 year 3 month'::interval + val = '2012-05-01';
SELECT id FROM date_date WHERE '1 year 3 month'::interval + val = '2012-05-01' OR dummy();
SELECT id FROM date_date WHERE '1 year'::interval + val = '2012-02-01';
SELECT id FROM date_date WHERE '1 year'::interval + val = '2012-02-01' OR dummy();
SELECT id FROM date_date WHERE '3 month'::interval + val = '2011-05-01';
SELECT id FROM date_date WHERE '3 month'::interval + val = '2011-05-01' OR dummy();
SELECT id FROM date_date WHERE '30 day 12:34:56.123456'::interval + val = '2011-03-03 12:34:56.123456';
SELECT id FROM date_date WHERE '30 day 12:34:56.123456'::interval + val = '2011-03-03 12:34:56.123456' OR dummy();
SELECT id FROM date_date WHERE '30 day'::interval + val = '2011-03-03';
SELECT id FROM date_date WHERE '30 day'::interval + val = '2011-03-03' OR dummy();
SELECT id FROM date_date WHERE '1 hour'::interval + val = '2011-02-01 01:00:00';
SELECT id FROM date_date WHERE '1 hour'::interval + val = '2011-02-01 01:00:00' OR dummy();
SELECT id FROM date_date WHERE '1 minute'::interval + val = '2011-02-01 00:01:00';
SELECT id FROM date_date WHERE '1 minute'::interval + val = '2011-02-01 00:01:00' OR dummy();
SELECT id FROM date_date WHERE '1.000001 second'::interval + val = '2011-02-01 00:00:01.000001';
SELECT id FROM date_date WHERE '1.000001 second'::interval + val = '2011-02-01 00:00:01.000001' OR dummy();
SELECT id FROM date_date WHERE '-1 year -3 month'::interval + val = '2009-11-01';
SELECT id FROM date_date WHERE '-1 year -3 month'::interval + val = '2009-11-01' OR dummy();
SELECT id FROM date_date WHERE '-30 day -12:34:56.123456'::interval + val = '2011-01-01 11:25:03.876544';
SELECT id FROM date_date WHERE '-30 day -12:34:56.123456'::interval + val = '2011-01-01 11:25:03.876544' OR dummy();
SELECT id FROM date_date WHERE '1 year 3 month'::interval + val = '2010-05-01 BC';
SELECT id FROM date_date WHERE '1 year 3 month'::interval + val = '2010-05-01 BC' OR dummy();
SELECT id FROM date_date WHERE '30 day 12:34:56.123456'::interval + val = '2011-03-03 BC 12:34:56.123456';
SELECT id FROM date_date WHERE '30 day 12:34:56.123456'::interval + val = '2011-03-03 BC 12:34:56.123456' OR dummy();

EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '2011-02-02'::date = '2012-05-02';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '2011-02-02'::date = '2012-02-02';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '2011-02-02'::date = '2011-05-02';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '2011-02-02'::date = '2009-11-02';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '2011-02-02 BC'::date = '2010-05-02 BC';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '2011-02-02 BC'::date = '2013-11-02 BC';

EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '2011-02-01'::date = '2011-02-02 12:34:56.123456';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '2011-02-01'::date = '2011-02-02';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '2011-02-01'::date = '2011-02-01 01:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '2011-02-01'::date = '2011-02-01 00:01:00';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '2011-02-01'::date = '2011-02-01 00:00:01.123456';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '2011-02-01'::date = '2011-01-30 11:25:03.876544';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '2011-02-01 BC'::date = '2011-02-02 BC 12:34:56.123456';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '2011-02-01 BC'::date = '2011-01-30 BC 11:25:03.876544';

EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE val + '2011-02-01'::date = '2011-02-02 12:34:56.123456';
EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE val + '2011-02-01'::date = '2011-02-02 12:34:56.123456' OR dummy();
EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE val + '2011-02-01'::date >= '2011-02-02 12:34:56' AND '2011-02-01'::date + val < '2011-02-02 12:34:57';
EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE (val + '2011-02-01'::date >= '2011-02-02 12:34:56' AND val + '2011-02-01'::date < '2011-02-02 12:34:57') OR dummy();

SELECT id FROM itym_it WHERE val + '2011-02-02'::date = '2012-05-02';
SELECT id FROM itym_it WHERE val + '2011-02-02'::date = '2012-05-02' OR dummy();
SELECT id FROM itym_it WHERE val + '2011-02-02'::date = '2012-02-02';
SELECT id FROM itym_it WHERE val + '2011-02-02'::date = '2012-02-02' OR dummy();
SELECT id FROM itym_it WHERE val + '2011-02-02'::date = '2011-05-02';
SELECT id FROM itym_it WHERE val + '2011-02-02'::date = '2011-05-02' OR dummy();
SELECT id FROM itym_it WHERE val + '2011-02-02'::date = '2009-11-02';
SELECT id FROM itym_it WHERE val + '2011-02-02'::date = '2009-11-02' OR dummy();
SELECT id FROM itym_it WHERE val + '2011-02-02 BC'::date = '2010-05-02 BC';
SELECT id FROM itym_it WHERE val + '2011-02-02 BC'::date = '2010-05-02 BC' OR dummy();
SELECT id FROM itym_it WHERE val + '2011-02-02 BC'::date = '2013-11-02 BC';
SELECT id FROM itym_it WHERE val + '2011-02-02 BC'::date = '2013-11-02 BC' OR dummy();

SELECT id FROM itds6_it WHERE val + '2011-02-01'::date = '2011-02-02 12:34:56.123456';
SELECT id FROM itds6_it WHERE val + '2011-02-01'::date = '2011-02-02 12:34:56.123456' OR dummy();
SELECT id FROM itds6_it WHERE val + '2011-02-01'::date = '2011-02-02';
SELECT id FROM itds6_it WHERE val + '2011-02-01'::date = '2011-02-02' OR dummy();
SELECT id FROM itds6_it WHERE val + '2011-02-01'::date = '2011-02-01 01:00:00';
SELECT id FROM itds6_it WHERE val + '2011-02-01'::date = '2011-02-01 01:00:00' OR dummy();
SELECT id FROM itds6_it WHERE val + '2011-02-01'::date = '2011-02-01 00:01:00';
SELECT id FROM itds6_it WHERE val + '2011-02-01'::date = '2011-02-01 00:01:00' OR dummy();
SELECT id FROM itds6_it WHERE val + '2011-02-01'::date = '2011-02-01 00:00:01.000001';
SELECT id FROM itds6_it WHERE val + '2011-02-01'::date = '2011-02-01 00:00:01.123456' OR dummy();
SELECT id FROM itds6_it WHERE val + '2011-02-01'::date = '2011-01-30 11:25:03.876544';
SELECT id FROM itds6_it WHERE val + '2011-02-01'::date = '2011-01-30 11:25:03.876544' OR dummy();
SELECT id FROM itds6_it WHERE val + '2011-02-01 BC'::date = '2011-02-02 BC 12:34:56.123456';
SELECT id FROM itds6_it WHERE val + '2011-02-01 BC'::date = '2011-02-02 BC 12:34:56.123456' OR dummy();
SELECT id FROM itds6_it WHERE val + '2011-02-01 BC'::date = '2011-01-30 BC 11:25:03.876544';
SELECT id FROM itds6_it WHERE val + '2011-02-01 BC'::date = '2011-01-30 BC 11:25:03.876544' OR dummy();

SELECT id FROM itds9_it WHERE val + '2011-02-01'::date = '2011-02-02 12:34:56.123456';
SELECT id FROM itds9_it WHERE val + '2011-02-01'::date = '2011-02-02 12:34:56.123456' OR dummy();
SELECT id FROM itds9_it WHERE val + '2011-02-01'::date >= '2011-02-02 12:34:56' AND '2011-02-01'::date + val < '2011-02-02 12:34:57';
SELECT id FROM itds9_it WHERE (val + '2011-02-01'::date >= '2011-02-02 12:34:56' AND val + '2011-02-01'::date < '2011-02-02 12:34:57') OR dummy();

EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE intervalym_interval_2 + timestamptz6_timestamptz_1 = '2011-05-01';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE intervalds6_interval_2 + timestamptz6_timestamptz_1 = '2011-02-01 13:36:59.246912';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE intervalds6_interval_2 + date_date_1 >= '2011-02-01 13:36:59' AND date_date_1 + intervalds6_interval_2 < '2011-02-01 13:37:00';

SELECT id FROM all_type WHERE intervalym_interval_2 + date_date_1 = '2011-05-01';
SELECT id FROM all_type WHERE intervalym_interval_2 + date_date_1 = '2011-05-01' OR dummy();
SELECT id FROM all_type WHERE intervalds6_interval_2 + date_date_1 = '2011-02-01 13:36:59.246912';
SELECT id FROM all_type WHERE intervalds6_interval_2 + date_date_1 = '2011-02-01 13:36:59.246912' OR dummy();
SELECT id FROM all_type WHERE intervalds6_interval_2 + date_date_1 >= '2011-02-01 13:36:59' AND intervalds6_interval_2 + date_date_1< '2011-02-01 13:37:00';
SELECT id FROM all_type WHERE (intervalds6_interval_2 + date_date_1 >= '2011-02-01 13:36:59' AND intervalds6_interval_2 + date_date_1< '2011-02-01 13:37:00') OR dummy();

-- 2548 : interval_pl_timestamp
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '1 year 3 month' + val = '2012-05-01 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '1 year' + val = '2012-02-01 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '3 month' + val = '2011-05-01 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '30 day 12:34:56.123456' + val = '2011-03-03 12:34:56.123457';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '30 day' + val = '2011-03-03 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '1 hour' + val = '2011-02-01 01:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '1 minute' + val = '2011-02-01 00:01:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '1.000001 second' + val = '2011-02-01 00:00:01.000002';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '-1 year -3 month' + val = '2009-11-01 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '-30 day -12:34:56.123456' + val = '2011-01-01 11:25:03.876545';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '1 year 3 month' + val = '2010-05-01 BC 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts6_ts WHERE '30 day 12:34:56.123456' + val = '2011-03-03 BC 12:34:56.123457';

EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE '1 year 3 month' + val = '2012-05-01 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE '1 year' + val = '2012-02-01 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE '3 month' + val = '2011-05-01 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE '30 day 12:34:56.123456' + val = '2011-03-03 12:34:56.123456';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE '30 day' + val = '2011-03-03 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE '1 hour' + val = '2011-02-01 01:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE '1 minute' + val = '2011-02-01 00:01:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE '1.000001 second' + val = '2011-02-01 00:00:01.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE '-1 year -3 month' + val = '2009-11-01 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE '-30 day -12:34:56.123456' + val = '2011-01-01 11:25:03.876544';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE '1 year 3 month' + val = '2010-05-01 BC 00:00:00';
EXPLAIN (COSTS FALSE) SELECT id FROM date_timestamp WHERE '30 day 12:34:56.123456' + val = '2011-03-03 BC 12:34:56.123456';

EXPLAIN (COSTS FALSE) SELECT id FROM ts9_ts WHERE '1 year' + val = '2012-02-01 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM ts9_ts WHERE '1 year' + val >= '2012-02-01 00:00:00.000001' AND '1 year' + val < '2012-02-01 00:00:00.000002';

SELECT id FROM ts6_ts WHERE '1 year 3 month' + val = '2012-05-01 00:00:00.000001';
SELECT id FROM ts6_ts WHERE '1 year 3 month' + val = '2012-05-01 00:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE '1 year' + val = '2012-02-01 00:00:00.000001';
SELECT id FROM ts6_ts WHERE '1 year' + val = '2012-02-01 00:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE '3 month' + val = '2011-05-01 00:00:00.000001';
SELECT id FROM ts6_ts WHERE '3 month' + val = '2011-05-01 00:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE '30 day 12:34:56.123456' + val = '2011-03-03 12:34:56.123457';
SELECT id FROM ts6_ts WHERE '30 day 12:34:56.123456' + val = '2011-03-03 12:34:56.123457' OR dummy();
SELECT id FROM ts6_ts WHERE '30 day' + val = '2011-03-03 00:00:00.000001';
SELECT id FROM ts6_ts WHERE '30 day' + val = '2011-03-03 00:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE '1 hour' + val = '2011-02-01 01:00:00.000001';
SELECT id FROM ts6_ts WHERE '1 hour' + val = '2011-02-01 01:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE '1 minute' + val = '2011-02-01 00:01:00.000001';
SELECT id FROM ts6_ts WHERE '1 minute' + val = '2011-02-01 00:01:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE '1.000001 second' + val = '2011-02-01 00:00:01.000002';
SELECT id FROM ts6_ts WHERE '1.000001 second' + val = '2011-02-01 00:00:01.000002' OR dummy();
SELECT id FROM ts6_ts WHERE '-1 year -3 month' + val = '2009-11-01 00:00:00.000001';
SELECT id FROM ts6_ts WHERE '-1 year -3 month' + val = '2009-11-01 00:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE '-30 day -12:34:56.123456' + val = '2011-01-01 11:25:03.876545';
SELECT id FROM ts6_ts WHERE '-30 day -12:34:56.123456' + val = '2011-01-01 11:25:03.876545' OR dummy();
SELECT id FROM ts6_ts WHERE '1 year 3 month' + val = '2010-05-01 BC 00:00:00.000001';
SELECT id FROM ts6_ts WHERE '1 year 3 month' + val = '2010-05-01 BC 00:00:00.000001' OR dummy();
SELECT id FROM ts6_ts WHERE '30 day 12:34:56.123456' + val = '2011-03-03 BC 12:34:56.123457';
SELECT id FROM ts6_ts WHERE '30 day 12:34:56.123456' + val = '2011-03-03 BC 12:34:56.123457' OR dummy();

SELECT id FROM date_timestamp WHERE '1 year 3 month' + val = '2012-05-01 00:00:00';
SELECT id FROM date_timestamp WHERE '1 year 3 month' + val = '2012-05-01 00:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE '1 year' + val = '2012-02-01 00:00:00';
SELECT id FROM date_timestamp WHERE '1 year' + val = '2012-02-01 00:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE '3 month' + val = '2011-05-01 00:00:00';
SELECT id FROM date_timestamp WHERE '3 month' + val = '2011-05-01 00:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE '30 day 12:34:56.123456' + val = '2011-03-03 12:34:56.123456';
SELECT id FROM date_timestamp WHERE '30 day 12:34:56.123456' + val = '2011-03-03 12:34:56.123456' OR dummy();
SELECT id FROM date_timestamp WHERE '30 day' + val = '2011-03-03 00:00:00';
SELECT id FROM date_timestamp WHERE '30 day' + val = '2011-03-03 00:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE '1 hour' + val = '2011-02-01 01:00:00';
SELECT id FROM date_timestamp WHERE '1 hour' + val = '2011-02-01 01:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE '1 minute' + val = '2011-02-01 00:01:00';
SELECT id FROM date_timestamp WHERE '1 minute' + val = '2011-02-01 00:01:00' OR dummy();
SELECT id FROM date_timestamp WHERE '1.000001 second' + val = '2011-02-01 00:00:01.000001';
SELECT id FROM date_timestamp WHERE '1.000001 second' + val = '2011-02-01 00:00:01.000001' OR dummy();
SELECT id FROM date_timestamp WHERE '-1 year -3 month' + val = '2009-11-01 00:00:00';
SELECT id FROM date_timestamp WHERE '-1 year -3 month' + val = '2009-11-01 00:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE '-30 day -12:34:56.123456' + val = '2011-01-01 11:25:03.876544';
SELECT id FROM date_timestamp WHERE '-30 day -12:34:56.123456' + val = '2011-01-01 11:25:03.876544' OR dummy();
SELECT id FROM date_timestamp WHERE '1 year 3 month' + val = '2010-05-01 BC 00:00:00';
SELECT id FROM date_timestamp WHERE '1 year 3 month' + val = '2010-05-01 BC 00:00:00' OR dummy();
SELECT id FROM date_timestamp WHERE '30 day 12:34:56.123456' + val = '2011-03-03 BC 12:34:56.123456';
SELECT id FROM date_timestamp WHERE '30 day 12:34:56.123456' + val = '2011-03-03 BC 12:34:56.123456' OR dummy();

SELECT id FROM ts9_ts WHERE '1 year' + val = '2012-02-01 00:00:00000001';
SELECT id FROM ts9_ts WHERE '1 year' + val = '2012-02-01 00:00:00.000001' OR dummy();
SELECT id FROM ts9_ts WHERE '1 year' + val >= '2012-02-01 00:00:00.000001' AND '1 year' + val < '2012-02-01 00:00:00.000002';

EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '2011-02-02 00:00:00.000001'::timestamp = '2012-05-02 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '2011-02-02 00:00:00.000001'::timestamp = '2012-02-02 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '2011-02-02 00:00:00.000001'::timestamp = '2011-05-02 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '2011-02-02 00:00:00.000001'::timestamp = '2009-11-02 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '2011-02-02 BC 00:00:00.000001'::timestamp = '2010-05-02 BC 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '2011-02-02 BC 00:00:00.000001'::timestamp = '2013-11-02 BC 00:00:00.000001';

EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001'::timestamp = '2011-02-02 12:34:56.123457';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001'::timestamp = '2011-02-02 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001'::timestamp = '2011-02-01 01:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001'::timestamp = '2011-02-01 00:01:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001'::timestamp = '2011-02-01 00:00:01.123457';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001'::timestamp = '2011-01-30 11:25:03.876545';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '2011-02-01 BC 00:00:00.000001'::timestamp = '2011-02-02 BC 12:34:56.123457';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '2011-02-01 BC 00:00:00.000001'::timestamp = '2011-01-30 BC 11:25:03.876545';

EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE val + '2011-02-01 00:00:00.000001'::timestamp = '2011-02-02 12:34:56.123457';
EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE val + '2011-02-01 00:00:00.000001'::timestamp = '2011-02-02 12:34:56.123457' OR dummy();
EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE val + '2011-02-01 00:00:00.000001'::timestamp >= '2011-02-02 12:34:56.123457' AND '2011-02-01 00:00:00.000001'::timestamp < '2011-02-02 12:34:56.123458';

EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE intervalym_interval_2 + timestamptz6_timestamptz_1 = '2011-05-02 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE intervalds6_interval_2 + timestamptz6_timestamptz_1 = '2011-02-02 13:36:59.246913';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE intervalym_interval_2 + timestampltz6_timestamptz_1 = '2011-05-02 00:00:00.000001';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE intervalds6_interval_2 + timestampltz6_timestamptz_1 = '2011-02-02 13:36:59.246913';

SELECT id FROM itym_it WHERE val + '2011-02-02 00:00:00.000001'::timestamp = '2012-05-02 00:00:00.000001';
SELECT id FROM itym_it WHERE val + '2011-02-02 00:00:00.000001'::timestamp = '2012-05-02 00:00:00.000001' OR dummy();
SELECT id FROM itym_it WHERE val + '2011-02-02 00:00:00.000001'::timestamp = '2012-02-02 00:00:00.000001';
SELECT id FROM itym_it WHERE val + '2011-02-02 00:00:00.000001'::timestamp = '2012-02-02 00:00:00.000001' OR dummy();
SELECT id FROM itym_it WHERE val + '2011-02-02 00:00:00.000001'::timestamp = '2011-05-02 00:00:00.000001';
SELECT id FROM itym_it WHERE val + '2011-02-02 00:00:00.000001'::timestamp = '2011-05-02 00:00:00.000001' OR dummy();
SELECT id FROM itym_it WHERE val + '2011-02-02 00:00:00.000001'::timestamp = '2009-11-02 00:00:00.000001';
SELECT id FROM itym_it WHERE val + '2011-02-02 00:00:00.000001'::timestamp = '2009-11-02 00:00:00.000001' OR dummy();
SELECT id FROM itym_it WHERE val + '2011-02-02 BC 00:00:00.000001'::timestamp = '2010-05-02 BC 00:00:00.000001';
SELECT id FROM itym_it WHERE val + '2011-02-02 BC 00:00:00.000001'::timestamp = '2010-05-02 BC 00:00:00.000001' OR dummy();
SELECT id FROM itym_it WHERE val + '2011-02-02 BC 00:00:00.000001'::timestamp = '2013-11-02 BC 00:00:00.000001';
SELECT id FROM itym_it WHERE val + '2011-02-02 BC 00:00:00.000001'::timestamp = '2013-11-02 BC 00:00:00.000001' OR dummy();

SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001'::timestamp = '2011-02-02 12:34:56.123457';
SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001'::timestamp = '2011-02-02 12:34:56.123457' OR dummy();
SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001'::timestamp = '2011-02-02 00:00:00.000001';
SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001'::timestamp = '2011-02-02 00:00:00.000001' OR dummy();
SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001'::timestamp = '2011-02-01 01:00:00.000001';
SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001'::timestamp = '2011-02-01 01:00:00.000001' OR dummy();
SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001'::timestamp = '2011-02-01 00:01:00.000001';
SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001'::timestamp = '2011-02-01 00:01:00.000001' OR dummy();
SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001'::timestamp = '2011-02-01 00:00:01.123457';
SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001'::timestamp = '2011-02-01 00:00:01.123457' OR dummy();
SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001'::timestamp = '2011-01-30 11:25:03.876545';
SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001'::timestamp = '2011-01-30 11:25:03.876545' OR dummy();
SELECT id FROM itds6_it WHERE val + '2011-02-01 BC 00:00:00.000001'::timestamp = '2011-02-02 BC 12:34:56.123457';
SELECT id FROM itds6_it WHERE val + '2011-02-01 BC 00:00:00.000001'::timestamp = '2011-02-02 BC 12:34:56.123457' OR dummy();
SELECT id FROM itds6_it WHERE val + '2011-02-01 BC 00:00:00.000001'::timestamp = '2011-01-30 BC 11:25:03.876545';
SELECT id FROM itds6_it WHERE val + '2011-02-01 BC 00:00:00.000001'::timestamp = '2011-01-30 BC 11:25:03.876545' OR dummy();

SELECT id FROM itds9_it WHERE val + '2011-02-01 00:00:00.000001'::timestamp = '2011-02-02 12:34:56.123457';
SELECT id FROM itds9_it WHERE val + '2011-02-01 00:00:00.000001'::timestamp = '2011-02-02 12:34:56.123457' OR dummy();
SELECT id FROM itds9_it WHERE val + '2011-02-01 00:00:00.000001'::timestamp >= '2011-02-02 12:34:56.123457' AND '2011-02-01 00:00:00.000001'::timestamp < '2011-02-02 12:34:56.123458';

SELECT id FROM all_type WHERE intervalym_interval_2 + timestamptz6_timestamptz_1= '2011-05-02 00:00:00.000001';
SELECT id FROM all_type WHERE intervalym_interval_2 + timestamptz6_timestamptz_1= '2011-05-02 00:00:00.000001' OR dummy();
SELECT id FROM all_type WHERE intervalds6_interval_2 + timestamptz6_timestamptz_1= '2011-02-02 13:36:59.246913';
SELECT id FROM all_type WHERE intervalds6_interval_2 + timestamptz6_timestamptz_1= '2011-02-02 13:36:59.246913' OR dummy();
SELECT id FROM all_type WHERE intervalym_interval_2 + timestampltz6_timestamptz_1 = '2011-05-02 00:00:00.000001';
SELECT id FROM all_type WHERE intervalym_interval_2 + timestampltz6_timestamptz_1 = '2011-05-02 00:00:00.000001' OR dummy();
SELECT id FROM all_type WHERE intervalds6_interval_2 + timestampltz6_timestamptz_1 = '2011-02-02 13:36:59.246913';
SELECT id FROM all_type WHERE intervalds6_interval_2 + timestampltz6_timestamptz_1 = '2011-02-02 13:36:59.246913' OR dummy();

-- 2549 : interval_pl_timestamptz
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '1 year 3 month' + val = '2012-05-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '1 year' + val = '2012-02-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '3 month' + val = '2011-05-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '30 day 12:34:56.123456' + val = '2011-03-03 12:34:56.123457 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '30 day' + val = '2011-03-03 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '1 hour' + val = '2011-02-01 01:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '1 minute' + val = '2011-02-01 00:01:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '1.000001 second' + val = '2011-02-01 00:00:01.000002 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '-1 year -3 month' + val = '2009-11-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '-30 day -12:34:56.123456' + val = '2011-01-01 11:25:03.876545 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '1 year 3 month' + val = '2010-05-01 BC 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz6_tstz WHERE '30 day 12:34:56.123456' + val = '2011-03-03 BC 12:34:56.123457 Asia/Tokyo';

EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '1 year 3 month' + val = '2012-05-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '1 year' + val = '2012-02-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '3 month' + val = '2011-05-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '30 day 12:34:56.123456' + val = '2011-03-03 12:34:56.123457 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '30 day' + val = '2011-03-03 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '1 hour' + val = '2011-02-01 01:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '1 minute' + val = '2011-02-01 00:01:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '1.000001 second' + val = '2011-02-01 00:00:01.000002 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '-1 year -3 month' + val = '2009-11-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '-30 day -12:34:56.123456' + val = '2011-01-01 11:25:03.876545 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '1 year 3 month' + val = '2010-05-01 BC 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz6_tstz WHERE '30 day 12:34:56.123456' + val = '2011-03-03 BC 12:34:56.123457 Asia/Tokyo';

EXPLAIN (COSTS FALSE) SELECT id FROM tstz9_tstz WHERE '1 year' + val = '2012-02-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tstz9_tstz WHERE '1 year' + val >= '2012-02-01 00:00:00.000001 Asia/Tokyo' AND '1 year' + val < '2012-02-01 00:00:00.000002 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz9_tstz WHERE '1 year' + val = '2012-02-01 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM tsltz9_tstz WHERE '1 year' + val >= '2012-02-01 00:00:00.000001 Asia/Tokyo' AND '1 year' + val < '2012-02-01 00:00:00.000002 Asia/Tokyo';

SELECT id FROM tstz6_tstz WHERE '1 year 3 month' + val = '2012-05-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE '1 year 3 month' + val = '2012-05-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE '1 year' + val = '2012-02-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE '1 year' + val = '2012-02-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE '3 month' + val = '2011-05-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE '3 month' + val = '2011-05-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE '30 day 12:34:56.123456' + val = '2011-03-03 12:34:56.123457 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE '30 day 12:34:56.123456' + val = '2011-03-03 12:34:56.123457 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE '30 day' + val = '2011-03-03 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE '30 day' + val = '2011-03-03 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE '1 hour' + val = '2011-02-01 01:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE '1 hour' + val = '2011-02-01 01:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE '1 minute' + val = '2011-02-01 00:01:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE '1 minute' + val = '2011-02-01 00:01:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE '1.000001 second' + val = '2011-02-01 00:00:01.000002 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE '1.000001 second' + val = '2011-02-01 00:00:01.000002 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE '-1 year -3 month' + val = '2009-11-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE '-1 year -3 month' + val = '2009-11-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE '-30 day -12:34:56.123456' + val = '2011-01-01 11:25:03.876545 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE '-30 day -12:34:56.123456' + val = '2011-01-01 11:25:03.876545 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE '1 year 3 month' + val = '2010-05-01 BC 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE '1 year 3 month' + val = '2010-05-01 BC 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz6_tstz WHERE '30 day 12:34:56.123456' + val = '2011-03-03 BC 12:34:56.123457 Asia/Tokyo';
SELECT id FROM tstz6_tstz WHERE '30 day 12:34:56.123456' + val = '2011-03-03 BC 12:34:56.123457 Asia/Tokyo' OR dummy();

SELECT id FROM tsltz6_tstz WHERE '1 year 3 month' + val = '2012-05-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE '1 year 3 month' + val = '2012-05-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE '1 year' + val = '2012-02-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE '1 year' + val = '2012-02-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE '3 month' + val = '2011-05-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE '3 month' + val = '2011-05-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE '30 day 12:34:56.123456' + val = '2011-03-03 12:34:56.123457 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE '30 day 12:34:56.123456' + val = '2011-03-03 12:34:56.123457 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE '30 day' + val = '2011-03-03 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE '30 day' + val = '2011-03-03 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE '1 hour' + val = '2011-02-01 01:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE '1 hour' + val = '2011-02-01 01:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE '1 minute' + val = '2011-02-01 00:01:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE '1 minute' + val = '2011-02-01 00:01:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE '1.000001 second' + val = '2011-02-01 00:00:01.000002 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE '1.000001 second' + val = '2011-02-01 00:00:01.000002 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE '-1 year -3 month' + val = '2009-11-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE '-1 year -3 month' + val = '2009-11-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE '-30 day -12:34:56.123456' + val = '2011-01-01 11:25:03.876545 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE '-30 day -12:34:56.123456' + val = '2011-01-01 11:25:03.876545 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE '1 year 3 month' + val = '2010-05-01 BC 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE '1 year 3 month' + val = '2010-05-01 BC 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz6_tstz WHERE '30 day 12:34:56.123456' + val = '2011-03-03 BC 12:34:56.123457 Asia/Tokyo';
SELECT id FROM tsltz6_tstz WHERE '30 day 12:34:56.123456' + val = '2011-03-03 BC 12:34:56.123457 Asia/Tokyo' OR dummy();

SELECT id FROM tstz9_tstz WHERE '1 year' + val = '2012-02-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tstz9_tstz WHERE '1 year' + val = '2012-02-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tstz9_tstz WHERE '1 year' + val >= '2012-02-01 00:00:00.000001 Asia/Tokyo' AND '1 year' + val < '2012-02-01 00:00:00.000002 Asia/Tokyo';
SELECT id FROM tsltz9_tstz WHERE '1 year' + val = '2012-02-01 00:00:00.000001 Asia/Tokyo';
SELECT id FROM tsltz9_tstz WHERE '1 year' + val = '2012-02-01 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM tsltz9_tstz WHERE '1 year' + val >= '2012-02-01 00:00:00.000001 Asia/Tokyo' AND '1 year' + val < '2012-02-01 00:00:00.000002 Asia/Tokyo';

EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz = '2012-05-02 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz = '2012-02-02 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-05-02 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz = '2009-11-02 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '2011-02-02 BC 00:00:00.000001 Asia/Tokyo'::timestamptz = '2010-05-02 BC 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itym_it WHERE val + '2011-02-02 BC 00:00:00.000001 Asia/Tokyo'::timestamptz = '2013-11-02 BC 00:00:00.000001 Asia/Tokyo';

EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-02-02 12:34:56.123457 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-02-02 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-02-01 01:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-02-01 00:01:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-02-01 00:00:01.123457 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-01-30 11:25:03.876545 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '2011-02-01 BC 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-02-02 BC 12:34:56.123457 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itds6_it WHERE val + '2011-02-01 BC 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-01-30 BC 11:25:03.876545 Asia/Tokyo';

EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-02-02 12:34:56.123457 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-02-02 12:34:56.123457 Asia/Tokyo' OR dummy();
EXPLAIN (COSTS FALSE) SELECT id FROM itds9_it WHERE val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz >= '2011-02-02 12:34:56.123457 Asia/Tokyo' AND val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz < '2011-02-02 12:34:56.123458 Asia/Tokyo';

EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE intervalym_interval_2 + timestamptz6_timestamptz_1 = '2011-05-02 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE intervalds6_interval_2 + timestamptz6_timestamptz_1 = '2011-02-02 13:36:59.246913 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE intervalym_interval_2 + timestampltz6_timestamptz_1 = '2011-05-02 00:00:00.000001 Asia/Tokyo';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE intervalds6_interval_2 + timestampltz6_timestamptz_1 = '2011-02-02 13:36:59.246913 Asia/Tokyo';

SELECT id FROM itym_it WHERE val + '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz = '2012-05-02 00:00:00.000001 Asia/Tokyo';
SELECT id FROM itym_it WHERE val + '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz = '2012-05-02 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM itym_it WHERE val + '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz = '2012-02-02 00:00:00.000001 Asia/Tokyo';
SELECT id FROM itym_it WHERE val + '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz = '2012-02-02 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM itym_it WHERE val + '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-05-02 00:00:00.000001 Asia/Tokyo';
SELECT id FROM itym_it WHERE val + '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-05-02 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM itym_it WHERE val + '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz = '2009-11-02 00:00:00.000001 Asia/Tokyo';
SELECT id FROM itym_it WHERE val + '2011-02-02 00:00:00.000001 Asia/Tokyo'::timestamptz = '2009-11-02 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM itym_it WHERE val + '2011-02-02 BC 00:00:00.000001 Asia/Tokyo'::timestamptz = '2010-05-02 BC 00:00:00.000001 Asia/Tokyo';
SELECT id FROM itym_it WHERE val + '2011-02-02 BC 00:00:00.000001 Asia/Tokyo'::timestamptz = '2010-05-02 BC 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM itym_it WHERE val + '2011-02-02 BC 00:00:00.000001 Asia/Tokyo'::timestamptz = '2013-11-02 BC 00:00:00.000001 Asia/Tokyo';
SELECT id FROM itym_it WHERE val + '2011-02-02 BC 00:00:00.000001 Asia/Tokyo'::timestamptz = '2013-11-02 BC 00:00:00.000001 Asia/Tokyo' OR dummy();

SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-02-02 12:34:56.123457 Asia/Tokyo';
SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-02-02 12:34:56.123457 Asia/Tokyo' OR dummy();
SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-02-02 00:00:00.000001 Asia/Tokyo';
SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-02-02 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-02-01 01:00:00.000001 Asia/Tokyo';
SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-02-01 01:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-02-01 00:01:00.000001 Asia/Tokyo';
SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-02-01 00:01:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-02-01 00:00:01.123457 Asia/Tokyo';
SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-02-01 00:00:01.123457 Asia/Tokyo' OR dummy();
SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-01-30 11:25:03.876545 Asia/Tokyo';
SELECT id FROM itds6_it WHERE val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-01-30 11:25:03.876545 Asia/Tokyo' OR dummy();
SELECT id FROM itds6_it WHERE val + '2011-02-01 BC 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-02-02 BC 12:34:56.123457 Asia/Tokyo';
SELECT id FROM itds6_it WHERE val + '2011-02-01 BC 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-02-02 BC 12:34:56.123457 Asia/Tokyo' OR dummy();
SELECT id FROM itds6_it WHERE val + '2011-02-01 BC 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-01-30 BC 11:25:03.876545 Asia/Tokyo';
SELECT id FROM itds6_it WHERE val + '2011-02-01 BC 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-01-30 BC 11:25:03.876545 Asia/Tokyo' OR dummy();

SELECT id FROM itds9_it WHERE val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-02-02 12:34:56.123457 Asia/Tokyo';
SELECT id FROM itds9_it WHERE val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz = '2011-02-02 12:34:56.123457 Asia/Tokyo' OR dummy();
SELECT id FROM itds9_it WHERE val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz >= '2011-02-02 12:34:56.123457 Asia/Tokyo' AND val + '2011-02-01 00:00:00.000001 Asia/Tokyo'::timestamptz < '2011-02-02 12:34:56.123458 Asia/Tokyo';

SELECT id FROM all_type WHERE intervalym_interval_2 + timestamptz6_timestamptz_1 = '2011-05-02 00:00:00.000001 Asia/Tokyo';
SELECT id FROM all_type WHERE intervalym_interval_2 + timestamptz6_timestamptz_1 = '2011-05-02 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM all_type WHERE intervalds6_interval_2 + timestamptz6_timestamptz_1 = '2011-02-02 13:36:59.246913 Asia/Tokyo';
SELECT id FROM all_type WHERE intervalds6_interval_2 + timestamptz6_timestamptz_1 = '2011-02-02 13:36:59.246913 Asia/Tokyo' OR dummy();
SELECT id FROM all_type WHERE intervalym_interval_2 + timestampltz6_timestamptz_1 = '2011-05-02 00:00:00.000001 Asia/Tokyo';
SELECT id FROM all_type WHERE intervalym_interval_2 + timestampltz6_timestamptz_1 = '2011-05-02 00:00:00.000001 Asia/Tokyo' OR dummy();
SELECT id FROM all_type WHERE intervalds6_interval_2 + timestampltz6_timestamptz_1 = '2011-02-02 13:36:59.246913 Asia/Tokyo';
SELECT id FROM all_type WHERE intervalds6_interval_2 + timestampltz6_timestamptz_1 = '2011-02-02 13:36:59.246913 Asia/Tokyo' OR dummy();

-- 2550 : integer_pl_date
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE 1.5 + val = '2011-01-01';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE 30 + val = '2011-03-03';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE 365 + val = '2012-02-01';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE 395 + val = '2012-03-02';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE 30 + val = '2004-03-02';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE 30 + val = '2100-03-03';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE 30 + val = '2400-03-02';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE 30 + val = '2011-03-02 BC';
EXPLAIN (COSTS FALSE) SELECT id FROM date_date WHERE (-30) + val = '2011-01-02';

EXPLAIN (COSTS FALSE) SELECT id FROM number_integer WHERE val + '2011-01-31'::date = '2011-03-02';
EXPLAIN (COSTS FALSE) SELECT id FROM number_integer WHERE val + '2011-02-01'::date = '2012-02-01';
EXPLAIN (COSTS FALSE) SELECT id FROM number_integer WHERE val + '2011-02-01'::date = '2012-03-02';
EXPLAIN (COSTS FALSE) SELECT id FROM number_integer WHERE val + '2004-02-01'::date = '2004-03-02';
EXPLAIN (COSTS FALSE) SELECT id FROM number_integer WHERE val + '2100-02-01'::date = '2100-03-03';
EXPLAIN (COSTS FALSE) SELECT id FROM number_integer WHERE val + '2400-02-01'::date = '2400-03-02';
EXPLAIN (COSTS FALSE) SELECT id FROM number_integer WHERE val + '2011-02-01 BC'::date = '2011-03-03 BC';
EXPLAIN (COSTS FALSE) SELECT id FROM number_integer WHERE val + '2011-02-01'::date = '2011-01-02';

EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE number_integer_1 + date_date_1 = '2011-03-03';

SELECT id FROM date_date WHERE 1.5 + val = '2011-01-01';
SELECT id FROM date_date WHERE 30 + val = '2011-03-03';
SELECT id FROM date_date WHERE 30 + val = '2011-03-03' OR dummy();
SELECT id FROM date_date WHERE 365 + val = '2012-02-01';
SELECT id FROM date_date WHERE 365 + val = '2012-02-01' OR dummy();
SELECT id FROM date_date WHERE 395 + val = '2012-03-02';
SELECT id FROM date_date WHERE 395 + val = '2012-03-02' OR dummy();
SELECT id FROM date_date WHERE 30 + val = '2004-03-02';
SELECT id FROM date_date WHERE 30 + val = '2004-03-02' OR dummy();
SELECT id FROM date_date WHERE 30 + val = '2100-03-03';
SELECT id FROM date_date WHERE 30 + val = '2100-03-03' OR dummy();
SELECT id FROM date_date WHERE 30 + val = '2400-03-02';
SELECT id FROM date_date WHERE 30 + val = '2400-03-02' OR dummy();
SELECT id FROM date_date WHERE 30 + val = '2011-03-03 BC';
SELECT id FROM date_date WHERE 30 + val = '2011-03-03 BC' OR dummy();
SELECT id FROM date_date WHERE (-30) + val = '2011-01-02';
SELECT id FROM date_date WHERE (-30) + val = '2011-01-02' OR dummy();

SELECT id FROM number_integer WHERE val + '2011-02-01'::date = '2011-03-03';
SELECT id FROM number_integer WHERE val + '2011-02-01'::date = '2011-03-03' OR dummy();
SELECT id FROM number_integer WHERE val + '2011-02-01'::date = '2012-02-01';
SELECT id FROM number_integer WHERE val + '2011-02-01'::date = '2012-02-01' OR dummy();
SELECT id FROM number_integer WHERE val + '2011-02-01'::date = '2012-03-02';
SELECT id FROM number_integer WHERE val + '2011-02-01'::date = '2012-03-02' OR dummy();
SELECT id FROM number_integer WHERE val + '2004-02-01'::date = '2004-03-02';
SELECT id FROM number_integer WHERE val + '2004-02-01'::date = '2004-03-02' OR dummy();
SELECT id FROM number_integer WHERE val + '2100-02-01'::date = '2100-03-03';
SELECT id FROM number_integer WHERE val + '2100-02-01'::date = '2100-03-03' OR dummy();
SELECT id FROM number_integer WHERE val + '2400-02-01'::date = '2400-03-02';
SELECT id FROM number_integer WHERE val + '2400-02-01'::date = '2400-03-02' OR dummy();
SELECT id FROM number_integer WHERE val + '2011-02-01 BC'::date = '2011-03-03 BC';
SELECT id FROM number_integer WHERE val + '2011-02-01 BC'::date = '2011-03-03 BC' OR dummy();
SELECT id FROM number_integer WHERE val + '2011-02-01'::date = '2011-01-02';
SELECT id FROM number_integer WHERE val + '2011-02-01'::date = '2011-01-02' OR dummy();

SELECT id FROM all_type WHERE number_integer_1 + date_date_1 = '2011-03-03';
SELECT id FROM all_type WHERE number_integer_1 + date_date_1 = '2011-03-03' OR dummy();
