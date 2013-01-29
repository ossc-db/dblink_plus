ALTER SESSION SET NLS_LANGUAGE = 'AMERICAN';
ALTER SESSION SET NLS_DATE_FORMAT = 'SYYYY-MM-DD HH24:MI:SS';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'SYYYY-MM-DD HH24:MI:SS.FF9';
ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT = 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR';
ALTER SESSION SET NLS_TIME_FORMAT = 'HH24:MI:SS.FF9';
ALTER SESSION SET NLS_TIME_TZ_FORMAT = 'HH24:MI:SS.FF9 TZR';

-- No.1
TRUNCATE TABLE "oracle_fdw"."binary_float_real";
INSERT INTO "oracle_fdw"."binary_float_real" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."binary_float_real" VALUES( 2, 0);
INSERT INTO "oracle_fdw"."binary_float_real" VALUES( 3, binary_float_nan);
INSERT INTO "oracle_fdw"."binary_float_real" VALUES( 4, binary_float_infinity);
INSERT INTO "oracle_fdw"."binary_float_real" VALUES( 5, -binary_float_infinity);
INSERT INTO "oracle_fdw"."binary_float_real" VALUES( 6, -3.40282E+38F);
INSERT INTO "oracle_fdw"."binary_float_real" VALUES( 7, 3.40282E+38F);
INSERT INTO "oracle_fdw"."binary_float_real" VALUES( 8, -1);
INSERT INTO "oracle_fdw"."binary_float_real" VALUES( 9, 1);

-- No.2
TRUNCATE TABLE "oracle_fdw"."binary_double_precision";
INSERT INTO "oracle_fdw"."binary_double_precision" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."binary_double_precision" VALUES( 2, 0);
INSERT INTO "oracle_fdw"."binary_double_precision" VALUES( 3, binary_double_nan);
INSERT INTO "oracle_fdw"."binary_double_precision" VALUES( 4, binary_double_infinity);
INSERT INTO "oracle_fdw"."binary_double_precision" VALUES( 5, -binary_double_infinity);
INSERT INTO "oracle_fdw"."binary_double_precision" VALUES( 6, -1.00000000000000E-130);
INSERT INTO "oracle_fdw"."binary_double_precision" VALUES( 7, 0.99999999999999E+126);
INSERT INTO "oracle_fdw"."binary_double_precision" VALUES( 8, -1);
INSERT INTO "oracle_fdw"."binary_double_precision" VALUES( 9, 1);

-- No.3
TRUNCATE TABLE "oracle_fdw"."number_smallint";
INSERT INTO "oracle_fdw"."number_smallint" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."number_smallint" VALUES( 2, 0);
INSERT INTO "oracle_fdw"."number_smallint" VALUES( 3, -32768);
INSERT INTO "oracle_fdw"."number_smallint" VALUES( 4, 32767);
INSERT INTO "oracle_fdw"."number_smallint" VALUES( 5, -1);
INSERT INTO "oracle_fdw"."number_smallint" VALUES( 6, 1);

-- No.4
TRUNCATE TABLE "oracle_fdw"."number_integer";
INSERT INTO "oracle_fdw"."number_integer" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."number_integer" VALUES( 2, 0);
INSERT INTO "oracle_fdw"."number_integer" VALUES( 3, -2147483648);
INSERT INTO "oracle_fdw"."number_integer" VALUES( 4, 2147483647);
INSERT INTO "oracle_fdw"."number_integer" VALUES( 5, -1);
INSERT INTO "oracle_fdw"."number_integer" VALUES( 6, 1);

-- No.5
TRUNCATE TABLE "oracle_fdw"."number_bigint";
INSERT INTO "oracle_fdw"."number_bigint" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."number_bigint" VALUES( 2, 0);
INSERT INTO "oracle_fdw"."number_bigint" VALUES( 3, -9223372036854775808);
INSERT INTO "oracle_fdw"."number_bigint" VALUES( 4, 9223372036854775807);
INSERT INTO "oracle_fdw"."number_bigint" VALUES( 5, -1);
INSERT INTO "oracle_fdw"."number_bigint" VALUES( 6, 1);

-- No.6
TRUNCATE TABLE "oracle_fdw"."number_numeric1";
INSERT INTO "oracle_fdw"."number_numeric1" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."number_numeric1" VALUES( 2, 0);
INSERT INTO "oracle_fdw"."number_numeric1" VALUES( 3, -12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012);
INSERT INTO "oracle_fdw"."number_numeric1" VALUES( 4, 12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012);
INSERT INTO "oracle_fdw"."number_numeric1" VALUES( 5, -1e100);
INSERT INTO "oracle_fdw"."number_numeric1" VALUES( 6, 1e100);

TRUNCATE TABLE "oracle_fdw"."number_numeric2";
INSERT INTO "oracle_fdw"."number_numeric2" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."number_numeric2" VALUES( 2, 0);
INSERT INTO "oracle_fdw"."number_numeric2" VALUES( 3, -0.00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000123456789012345678901234567890123456789);
INSERT INTO "oracle_fdw"."number_numeric2" VALUES( 4,  0.00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000123456789012345678901234567890123456789);
INSERT INTO "oracle_fdw"."number_numeric2" VALUES( 5, -1e-100);
INSERT INTO "oracle_fdw"."number_numeric2" VALUES( 6, 1e-100);

TRUNCATE TABLE "oracle_fdw"."number_numeric3";
INSERT INTO "oracle_fdw"."number_numeric3" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."number_numeric3" VALUES( 2, 0);
INSERT INTO "oracle_fdw"."number_numeric3" VALUES( 3, -9223372036854775808);
INSERT INTO "oracle_fdw"."number_numeric3" VALUES( 4, 9223372036854775807);
INSERT INTO "oracle_fdw"."number_numeric3" VALUES( 5, -1);
INSERT INTO "oracle_fdw"."number_numeric3" VALUES( 6, 1);

-- No.7
TRUNCATE TABLE "oracle_fdw"."float_numeric1";
INSERT INTO "oracle_fdw"."float_numeric1" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."float_numeric1" VALUES( 2, 0);
INSERT INTO "oracle_fdw"."float_numeric1" VALUES( 3, -9223372036854775808);
INSERT INTO "oracle_fdw"."float_numeric1" VALUES( 4, 9223372036854775807);
INSERT INTO "oracle_fdw"."float_numeric1" VALUES( 5, -1);
INSERT INTO "oracle_fdw"."float_numeric1" VALUES( 6, 1);

TRUNCATE TABLE "oracle_fdw"."float_numeric2";
INSERT INTO "oracle_fdw"."float_numeric2" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."float_numeric2" VALUES( 2, 0);
INSERT INTO "oracle_fdw"."float_numeric2" VALUES( 3, -9223372036854775808);
INSERT INTO "oracle_fdw"."float_numeric2" VALUES( 4, 9223372036854775807);
INSERT INTO "oracle_fdw"."float_numeric2" VALUES( 5, -1);
INSERT INTO "oracle_fdw"."float_numeric2" VALUES( 6, 1);

-- No.8, 9
TRUNCATE TABLE "oracle_fdw"."char_b";
INSERT INTO "oracle_fdw"."char_b" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."char_b" VALUES( 2, '');
INSERT INTO "oracle_fdw"."char_b" VALUES( 3, 'aAあア亜阿');
INSERT INTO "oracle_fdw"."char_b" VALUES( 4, 'bBいイ異伊');
INSERT INTO "oracle_fdw"."char_b" VALUES( 5, 'cCうウ卯宇');

TRUNCATE TABLE "oracle_fdw"."char_c";
INSERT INTO "oracle_fdw"."char_c" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."char_c" VALUES( 2, '');
INSERT INTO "oracle_fdw"."char_c" VALUES( 3, 'aAあア亜阿');
INSERT INTO "oracle_fdw"."char_c" VALUES( 4, 'bBいイ異伊');
INSERT INTO "oracle_fdw"."char_c" VALUES( 5, 'cCうウ卯宇');

-- No.10, 11
TRUNCATE TABLE "oracle_fdw"."nchar_";
INSERT INTO "oracle_fdw"."nchar_" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."nchar_" VALUES( 2, '');
INSERT INTO "oracle_fdw"."nchar_" VALUES( 3, 'aAあア亜阿');
INSERT INTO "oracle_fdw"."nchar_" VALUES( 4, 'bBいイ異伊');
INSERT INTO "oracle_fdw"."nchar_" VALUES( 5, 'cCうウ卯宇');

-- No.12, 13
TRUNCATE TABLE "oracle_fdw"."varchar2_";
INSERT INTO "oracle_fdw"."varchar2_" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."varchar2_" VALUES( 2, '');
INSERT INTO "oracle_fdw"."varchar2_" VALUES( 3, 'aAあア亜阿');
INSERT INTO "oracle_fdw"."varchar2_" VALUES( 4, 'bBいイ異伊');
INSERT INTO "oracle_fdw"."varchar2_" VALUES( 5, 'cCうウ卯宇');
TRUNCATE TABLE "oracle_fdw"."varchar2_b";
INSERT INTO "oracle_fdw"."varchar2_b" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."varchar2_b" VALUES( 2, '');
INSERT INTO "oracle_fdw"."varchar2_b" VALUES( 3, 'aAあア亜阿');
INSERT INTO "oracle_fdw"."varchar2_b" VALUES( 4, 'bBいイ異伊');
INSERT INTO "oracle_fdw"."varchar2_b" VALUES( 5, 'cCうウ卯宇');

-- No.14, 15
TRUNCATE TABLE "oracle_fdw"."nvarchar2_";
INSERT INTO "oracle_fdw"."nvarchar2_" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."nvarchar2_" VALUES( 2, '');
INSERT INTO "oracle_fdw"."nvarchar2_" VALUES( 3, 'aAあア亜阿');
INSERT INTO "oracle_fdw"."nvarchar2_" VALUES( 4, 'bBいイ異伊');
INSERT INTO "oracle_fdw"."nvarchar2_" VALUES( 5, 'cCうウ卯宇');

-- No.16, 17
TRUNCATE TABLE "oracle_fdw"."long_";
INSERT INTO "oracle_fdw"."long_" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."long_" VALUES( 2, '');
INSERT INTO "oracle_fdw"."long_" VALUES( 3, 'aAあア亜阿');
INSERT INTO "oracle_fdw"."long_" VALUES( 4, 'bBいイ異伊');
INSERT INTO "oracle_fdw"."long_" VALUES( 5, 'cCうウ卯宇');

-- No.18, 19
TRUNCATE TABLE "oracle_fdw"."clob_";
INSERT INTO "oracle_fdw"."clob_" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."clob_" VALUES( 2, '');
INSERT INTO "oracle_fdw"."clob_" VALUES( 3, 'aAあア亜阿');
INSERT INTO "oracle_fdw"."clob_" VALUES( 4, 'bBいイ異伊');
INSERT INTO "oracle_fdw"."clob_" VALUES( 5, 'cCうウ卯宇');

-- No.20, 21
TRUNCATE TABLE "oracle_fdw"."nclob_";
INSERT INTO "oracle_fdw"."nclob_" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."nclob_" VALUES( 2, '');
INSERT INTO "oracle_fdw"."nclob_" VALUES( 3, 'aAあア亜阿');
INSERT INTO "oracle_fdw"."nclob_" VALUES( 4, 'bBいイ異伊');
INSERT INTO "oracle_fdw"."nclob_" VALUES( 5, 'cCうウ卯宇');

-- TODO  値
-- No.22, 23
TRUNCATE TABLE "oracle_fdw"."date_";
INSERT INTO "oracle_fdw"."date_" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."date_" VALUES( 2, TO_DATE('0001-01-01', 'SYYYY-MM-DD'));
INSERT INTO "oracle_fdw"."date_" VALUES( 3, TO_DATE('0001-01-01 00:00:01', 'SYYYY-MM-DD HH24:MI:SS'));
INSERT INTO "oracle_fdw"."date_" VALUES( 4, TO_DATE('-4712-01-01', 'SYYYY-MM-DD'));
INSERT INTO "oracle_fdw"."date_" VALUES( 5, TO_DATE('-4712-01-01 00:00:01', 'SYYYY-MM-DD HH24:MI:SS'));
INSERT INTO "oracle_fdw"."date_" VALUES( 6, TO_DATE('9999-12-31', 'SYYYY-MM-DD'));
INSERT INTO "oracle_fdw"."date_" VALUES( 7, TO_DATE('9999-12-31 23:59:59', 'SYYYY-MM-DD HH24:MI:SS'));
INSERT INTO "oracle_fdw"."date_" VALUES( 8, TO_DATE('-0001-01-01', 'SYYYY-MM-DD'));
INSERT INTO "oracle_fdw"."date_" VALUES( 9, TO_DATE('-0001-01-01 00:00:01', 'SYYYY-MM-DD HH24:MI:SS'));
INSERT INTO "oracle_fdw"."date_" VALUES(10, TO_DATE('0001-01-02', 'SYYYY-MM-DD'));
INSERT INTO "oracle_fdw"."date_" VALUES(11, TO_DATE('0001-01-02 00:00:01', 'SYYYY-MM-DD HH24:MI:SS'));

-- No.24, 25
TRUNCATE TABLE "oracle_fdw"."timestamp_6";
INSERT INTO "oracle_fdw"."timestamp_6" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."timestamp_6" VALUES( 2, TO_TIMESTAMP('0001-01-01 00:00:00.000001', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'));
INSERT INTO "oracle_fdw"."timestamp_6" VALUES( 3, TO_TIMESTAMP('-4712-01-01 00:00:00.000001', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'));
INSERT INTO "oracle_fdw"."timestamp_6" VALUES( 4, TO_TIMESTAMP('9999-12-31 23:59:59.999999', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'));
INSERT INTO "oracle_fdw"."timestamp_6" VALUES( 5, TO_TIMESTAMP('-0001-01-01 00:00:00.000001', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'));
INSERT INTO "oracle_fdw"."timestamp_6" VALUES( 6, TO_TIMESTAMP('0001-01-02 00:00:00.000001', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'));

TRUNCATE TABLE "oracle_fdw"."timestamp_9";
INSERT INTO "oracle_fdw"."timestamp_9" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."timestamp_9" VALUES( 2, TO_TIMESTAMP('0001-01-01 00:00:00.000001999', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'));
INSERT INTO "oracle_fdw"."timestamp_9" VALUES( 3, TO_TIMESTAMP('-4712-01-01 00:00:00.000001999', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'));
INSERT INTO "oracle_fdw"."timestamp_9" VALUES( 4, TO_TIMESTAMP('9999-12-31 23:59:59.999999999', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'));
INSERT INTO "oracle_fdw"."timestamp_9" VALUES( 5, TO_TIMESTAMP('-0001-01-01 00:00:00.000001999', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'));
INSERT INTO "oracle_fdw"."timestamp_9" VALUES( 6, TO_TIMESTAMP('0001-01-02 00:00:00.000001999', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'));

-- No.26, 27
TRUNCATE TABLE "oracle_fdw"."timestamptz_6";
INSERT INTO "oracle_fdw"."timestamptz_6" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."timestamptz_6" VALUES( 2, TO_TIMESTAMP_TZ('0001-01-01 00:00:00.000001 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'));
INSERT INTO "oracle_fdw"."timestamptz_6" VALUES( 3, TO_TIMESTAMP_TZ('-4712-01-01 00:00:00.000001 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'));
INSERT INTO "oracle_fdw"."timestamptz_6" VALUES( 4, TO_TIMESTAMP_TZ('9999-12-31 23:59:59.999999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'));
INSERT INTO "oracle_fdw"."timestamptz_6" VALUES( 5, TO_TIMESTAMP_TZ('-0001-01-01 00:00:00.000001 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'));
INSERT INTO "oracle_fdw"."timestamptz_6" VALUES( 6, TO_TIMESTAMP_TZ('0001-01-02 00:00:00.000001 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'));

TRUNCATE TABLE "oracle_fdw"."timestamptz_9";
INSERT INTO "oracle_fdw"."timestamptz_9" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."timestamptz_9" VALUES( 2, TO_TIMESTAMP_TZ('0001-01-01 00:00:00.000001999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'));
INSERT INTO "oracle_fdw"."timestamptz_9" VALUES( 3, TO_TIMESTAMP_TZ('-4712-01-01 00:00:00.000001999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'));
INSERT INTO "oracle_fdw"."timestamptz_9" VALUES( 4, TO_TIMESTAMP_TZ('9999-12-31 23:59:59.999999999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'));
INSERT INTO "oracle_fdw"."timestamptz_9" VALUES( 5, TO_TIMESTAMP_TZ('-0001-01-01 00:00:00.000001999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'));
INSERT INTO "oracle_fdw"."timestamptz_9" VALUES( 6, TO_TIMESTAMP_TZ('0001-01-02 00:00:00.000001999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'));

-- No.28, 29
TRUNCATE TABLE "oracle_fdw"."timestampltz_6";
INSERT INTO "oracle_fdw"."timestampltz_6" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."timestampltz_6" VALUES( 2, TO_TIMESTAMP_TZ('0001-01-01 00:00:00.000001 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'));
INSERT INTO "oracle_fdw"."timestampltz_6" VALUES( 3, TO_TIMESTAMP_TZ('-4712-01-01 00:00:00.000001 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'));
INSERT INTO "oracle_fdw"."timestampltz_6" VALUES( 4, TO_TIMESTAMP_TZ('9999-12-31 23:59:59.999999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'));
INSERT INTO "oracle_fdw"."timestampltz_6" VALUES( 5, TO_TIMESTAMP_TZ('-0001-01-01 00:00:00.000001 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'));
INSERT INTO "oracle_fdw"."timestampltz_6" VALUES( 6, TO_TIMESTAMP_TZ('0001-01-02 00:00:00.000001 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'));

TRUNCATE TABLE "oracle_fdw"."timestampltz_9";
INSERT INTO "oracle_fdw"."timestampltz_9" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."timestampltz_9" VALUES( 2, TO_TIMESTAMP_TZ('0001-01-01 00:00:00.000001999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'));
INSERT INTO "oracle_fdw"."timestampltz_9" VALUES( 3, TO_TIMESTAMP_TZ('-4712-01-01 00:00:00.000001999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'));
INSERT INTO "oracle_fdw"."timestampltz_9" VALUES( 4, TO_TIMESTAMP_TZ('9999-12-31 23:59:59.999999999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'));
INSERT INTO "oracle_fdw"."timestampltz_9" VALUES( 5, TO_TIMESTAMP_TZ('-0001-01-01 00:00:00.000001999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'));
INSERT INTO "oracle_fdw"."timestampltz_9" VALUES( 6, TO_TIMESTAMP_TZ('0001-01-02 00:00:00.000001999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'));

-- No.30
TRUNCATE TABLE "oracle_fdw"."intervalym_";
INSERT INTO "oracle_fdw"."intervalym_" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."intervalym_" VALUES( 2, INTERVAL '1' YEAR);
INSERT INTO "oracle_fdw"."intervalym_" VALUES( 3, INTERVAL '-177999999-11' YEAR(9) TO MONTH);
INSERT INTO "oracle_fdw"."intervalym_" VALUES( 4, INTERVAL '177999999-11' YEAR(9) TO MONTH);
INSERT INTO "oracle_fdw"."intervalym_" VALUES( 5, INTERVAL '-1' YEAR);
INSERT INTO "oracle_fdw"."intervalym_" VALUES( 6, INTERVAL '2' YEAR);

-- No.31
TRUNCATE TABLE "oracle_fdw"."intervalds_6";
INSERT INTO "oracle_fdw"."intervalds_6" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."intervalds_6" VALUES( 2, INTERVAL '1' DAY);
INSERT INTO "oracle_fdw"."intervalds_6" VALUES( 3, INTERVAL '-999999999 23:59:59.999999' DAY(9) TO SECOND(6));
INSERT INTO "oracle_fdw"."intervalds_6" VALUES( 4, INTERVAL '999999999 23:59:59.999999' DAY(9) TO SECOND(6));
INSERT INTO "oracle_fdw"."intervalds_6" VALUES( 5, INTERVAL '-1 00:00:00.000001' DAY TO SECOND(9));
INSERT INTO "oracle_fdw"."intervalds_6" VALUES( 6, INTERVAL '2 00:00:00.000001' DAY TO SECOND(9));

TRUNCATE TABLE "oracle_fdw"."intervalds_9";
INSERT INTO "oracle_fdw"."intervalds_9" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."intervalds_9" VALUES( 2, INTERVAL '1' DAY);
INSERT INTO "oracle_fdw"."intervalds_9" VALUES( 3, INTERVAL '-999999999 23:59:59.999999999' DAY(9) TO SECOND(9));
INSERT INTO "oracle_fdw"."intervalds_9" VALUES( 4, INTERVAL '999999999 23:59:59.999999999' DAY(9) TO SECOND(9));
INSERT INTO "oracle_fdw"."intervalds_9" VALUES( 5, INTERVAL '-1 00:00:00.000001999' DAY TO SECOND(9));
INSERT INTO "oracle_fdw"."intervalds_9" VALUES( 6, INTERVAL '2 00:00:00.000001999' DAY TO SECOND(9));

-- No.32

-- No.33
TRUNCATE TABLE "oracle_fdw"."t_urowid";
INSERT INTO "oracle_fdw"."t_urowid" VALUES(1);
INSERT INTO "oracle_fdw"."t_urowid" VALUES(2);
INSERT INTO "oracle_fdw"."t_urowid" VALUES(3);

-- No.34
TRUNCATE TABLE "oracle_fdw"."raw_";
INSERT INTO "oracle_fdw"."raw_" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."raw_" VALUES( 2, '');
INSERT INTO "oracle_fdw"."raw_" VALUES( 3, 'AABBCC');
INSERT INTO "oracle_fdw"."raw_" VALUES( 4, 'AAAAAA');
INSERT INTO "oracle_fdw"."raw_" VALUES( 5, 'FFFFFF');
INSERT INTO "oracle_fdw"."raw_" VALUES( 6, 'BBBBBB');
INSERT INTO "oracle_fdw"."raw_" VALUES( 7, 'CCCCCC');

-- No.35
TRUNCATE TABLE "oracle_fdw"."long_raw_";
INSERT INTO "oracle_fdw"."long_raw_" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."long_raw_" VALUES( 2, '');
INSERT INTO "oracle_fdw"."long_raw_" VALUES( 3, 'AABBCC');
INSERT INTO "oracle_fdw"."long_raw_" VALUES( 4, 'AAAAAA');
INSERT INTO "oracle_fdw"."long_raw_" VALUES( 5, 'FFFFFF');
INSERT INTO "oracle_fdw"."long_raw_" VALUES( 6, 'BBBBBB');
INSERT INTO "oracle_fdw"."long_raw_" VALUES( 7, 'CCCCCC');

-- No.36
TRUNCATE TABLE "oracle_fdw"."blob_";
INSERT INTO "oracle_fdw"."blob_" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."blob_" VALUES( 2, '');
INSERT INTO "oracle_fdw"."blob_" VALUES( 3, 'AABBCC');
INSERT INTO "oracle_fdw"."blob_" VALUES( 4, 'AAAAAA');
INSERT INTO "oracle_fdw"."blob_" VALUES( 5, 'FFFFFF');
INSERT INTO "oracle_fdw"."blob_" VALUES( 6, 'BBBBBB');
INSERT INTO "oracle_fdw"."blob_" VALUES( 7, 'CCCCCC');

-- No.37
TRUNCATE TABLE "oracle_fdw"."bfile_";
INSERT INTO "oracle_fdw"."bfile_" VALUES( 1, NULL);
INSERT INTO "oracle_fdw"."bfile_" VALUES( 2, '');
INSERT INTO "oracle_fdw"."bfile_" VALUES( 3, bfilename('DIR', 'bfile1.txt'));
INSERT INTO "oracle_fdw"."bfile_" VALUES( 4, bfilename('DIR', 'bfile2.txt'));
INSERT INTO "oracle_fdw"."bfile_" VALUES( 5, bfilename('DIR', 'bfile3.txt'));
INSERT INTO "oracle_fdw"."bfile_" VALUES( 6, bfilename('DIR', 'bfile4.txt'));
INSERT INTO "oracle_fdw"."bfile_" VALUES( 7, bfilename('DIR', 'bfile5.txt'));

INSERT INTO "oracle_fdw"."all_type" VALUES(
	1,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL
);
INSERT INTO "oracle_fdw"."all_type" VALUES(
	2,
	binary_float_nan,
	NULL,
	binary_double_nan,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL
);
INSERT INTO "oracle_fdw"."all_type" VALUES(
	3,
	binary_float_infinity,
	NULL,
	binary_double_infinity,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL
);
INSERT INTO "oracle_fdw"."all_type" VALUES(
	4,
	-binary_float_infinity,
	NULL,
	-binary_double_infinity,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL
);
INSERT INTO "oracle_fdw"."all_type" VALUES(
	5,
	-1, 0,
	-1, 0,
	-1, 0,
	-1, 0,
	-1, 0,
	-1e100, 0,
	-1e-100, 0,
	-1, 0,
	-1, 0,
	-1, 0,
	'aAあア亜阿', 'bBいイ異伊',
	'aAあア亜阿', 'bBいイ異伊',
	'aAあア亜阿', 'bBいイ異伊',
	'aAあア亜阿', 'bBいイ異伊',
	'aAあア亜阿',
	'aAあア亜阿', 'bBいイ異伊',
	'aAあア亜阿', 'bBいイ異伊',
	TO_DATE('-0001-01-01', 'SYYYY-MM-DD'), TO_DATE('0001-01-01', 'SYYYY-MM-DD'),
	TO_TIMESTAMP('-0001-01-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS'),
	TO_TIMESTAMP('0001-01-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS'),
	TO_TIMESTAMP('-0001-01-01 00:00:00.000001', 'SYYYY-MM-DD HH24:MI:SS.FF6'),
	TO_TIMESTAMP('0001-01-01 00:00:00.000001', 'SYYYY-MM-DD HH24:MI:SS.FF6'),
	TO_TIMESTAMP('-0001-01-01 00:00:00.000001999', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'),
	TO_TIMESTAMP('0001-01-01 00:00:00.000001999', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'),
	TO_TIMESTAMP_TZ('-0001-01-01 00:00:00.000001 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'),
	TO_TIMESTAMP_TZ('0001-01-01 00:00:00.000001 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'),
	TO_TIMESTAMP_TZ('-0001-01-01 00:00:00.000001999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'),
	TO_TIMESTAMP_TZ('0001-01-01 00:00:00.000001999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'),
	TO_TIMESTAMP_TZ('-0001-01-01 00:00:00.000001 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'),
	TO_TIMESTAMP_TZ('0001-01-01 00:00:00.000001 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'),
	TO_TIMESTAMP_TZ('-0001-01-01 00:00:00.000001999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'),
	TO_TIMESTAMP_TZ('0001-01-01 00:00:00.000001999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'),
	INTERVAL '-1' YEAR,	INTERVAL '1' YEAR,
	INTERVAL '-1 00:00:00.000001' DAY TO SECOND(6), INTERVAL '1' DAY,
	INTERVAL '-1 00:00:00.000001999' DAY TO SECOND(9), INTERVAL '1' DAY,
	'AAAAAA', 'BBBBBB',
	'AAAAAA', 'BBBBBB',
	bfilename('DIR', 'data/bfile1.txt'), bfilename('DIR', 'data/bfile2.txt')
);
INSERT INTO "oracle_fdw"."all_type" VALUES(
	6,
	0, 0,
	0, 0,
	0, 0,
	0, 0,
	0, 0,
	0, 0,
	0, 0,
	0, 0,
	0, 0,
	0, 0,
	'bBいイ異伊', 'bBいイ異伊',
	'bBいイ異伊', 'bBいイ異伊',
	'bBいイ異伊', 'bBいイ異伊',
	'bBいイ異伊', 'bBいイ異伊',
	'bBいイ異伊',
	'bBいイ異伊', 'bBいイ異伊',
	'bBいイ異伊', 'bBいイ異伊',
	TO_DATE('0001-01-01', 'SYYYY-MM-DD'), TO_DATE('0001-01-01', 'SYYYY-MM-DD'),
	TO_TIMESTAMP('0001-01-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS'),
	TO_TIMESTAMP('0001-01-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS'),
	TO_TIMESTAMP('0001-01-01 00:00:00.000001', 'SYYYY-MM-DD HH24:MI:SS.FF6'),
	TO_TIMESTAMP('0001-01-01 00:00:00.000001', 'SYYYY-MM-DD HH24:MI:SS.FF6'),
	TO_TIMESTAMP('0001-01-01 00:00:00.000001999', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'),
	TO_TIMESTAMP('0001-01-01 00:00:00.000001999', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'),
	TO_TIMESTAMP_TZ('0001-01-01 00:00:00.000001 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'),
	TO_TIMESTAMP_TZ('0001-01-01 00:00:00.000001 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'),
	TO_TIMESTAMP_TZ('0001-01-01 00:00:00.000001999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'),
	TO_TIMESTAMP_TZ('0001-01-01 00:00:00.000001999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'),
	TO_TIMESTAMP_TZ('0001-01-01 00:00:00.000001 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'),
	TO_TIMESTAMP_TZ('0001-01-01 00:00:00.000001 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'),
	TO_TIMESTAMP_TZ('0001-01-01 00:00:00.000001999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'),
	TO_TIMESTAMP_TZ('0001-01-01 00:00:00.000001999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'),
	INTERVAL '1' YEAR,	INTERVAL '1' YEAR,
	INTERVAL '1' DAY, INTERVAL '1' DAY,
	INTERVAL '1' DAY, INTERVAL '1' DAY,
	'BBBBBB', 'BBBBBB',
	'BBBBBB', 'BBBBBB',
	bfilename('DIR', 'data/bfile2.txt'), bfilename('DIR', 'data/bfile2.txt')
);
INSERT INTO "oracle_fdw"."all_type" VALUES(
	7,
	1, 0,
	1, 0,
	1, 0,
	1, 0,
	1, 0,
	1e100, 0,
	1e-100, 0,
	1, 0,
	1, 0,
	1, 0,
	'cCうウ卯宇', 'bBいイ異伊',
	'cCうウ卯宇', 'bBいイ異伊',
	'cCうウ卯宇', 'bBいイ異伊',
	'cCうウ卯宇', 'bBいイ異伊',
	'cCうウ卯宇',
	'cCうウ卯宇', 'bBいイ異伊',
	'cCうウ卯宇', 'bBいイ異伊',
	TO_DATE('0001-01-01', 'SYYYY-MM-DD'), TO_DATE('0001-01-01', 'SYYYY-MM-DD'),
	TO_TIMESTAMP('0001-01-02 00:00:00', 'SYYYY-MM-DD HH24:MI:SS'),
	TO_TIMESTAMP('0001-01-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS'),
	TO_TIMESTAMP('0001-01-02 00:00:00.000001', 'SYYYY-MM-DD HH24:MI:SS.FF6'),
	TO_TIMESTAMP('0001-01-01 00:00:00.000001', 'SYYYY-MM-DD HH24:MI:SS.FF6'),
	TO_TIMESTAMP('0001-01-02 00:00:00.000001999', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'),
	TO_TIMESTAMP('0001-01-01 00:00:00.000001999', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'),
	TO_TIMESTAMP_TZ('0001-01-02 00:00:00.000001 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'),
	TO_TIMESTAMP_TZ('0001-01-01 00:00:00.000001 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'),
	TO_TIMESTAMP_TZ('0001-01-02 00:00:00.000001999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'),
	TO_TIMESTAMP_TZ('0001-01-01 00:00:00.000001999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'),
	TO_TIMESTAMP_TZ('0001-01-02 00:00:00.000001 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'),
	TO_TIMESTAMP_TZ('0001-01-01 00:00:00.000001 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF6 TZR'),
	TO_TIMESTAMP_TZ('0001-01-02 00:00:00.000001999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'),
	TO_TIMESTAMP_TZ('0001-01-01 00:00:00.000001999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'),
	INTERVAL '2' YEAR,	INTERVAL '1' YEAR,
	INTERVAL '2 00:00:00.000001' DAY TO SECOND(6), INTERVAL '1' DAY,
	INTERVAL '2 00:00:00.000001999' DAY TO SECOND(9), INTERVAL '1' DAY,
	'CCCCCC', 'BBBBBB',
	'CCCCCC', 'BBBBBB',
	bfilename('DIR', 'data/bfile3.txt'), bfilename('DIR', 'data/bfile2.txt')
);

INSERT INTO "oracle_fdw"."char_b" VALUES(6, 'aaaあああaaaあああaあaあ''''''___%%%   ');
INSERT INTO "oracle_fdw"."varchar2_" VALUES(6, 'aaaあああaaaあああaあaあ''''''___%%%   ');
INSERT INTO "oracle_fdw"."clob_" VALUES(6, 'aaaあああaaaあああaあaあ''''''___%%%   ');

EXIT
