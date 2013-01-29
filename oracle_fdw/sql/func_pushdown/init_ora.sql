ALTER SESSION SET NLS_LANGUAGE = 'AMERICAN';
ALTER SESSION SET NLS_DATE_FORMAT = 'SYYYY-MM-DD HH24:MI:SS';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'SYYYY-MM-DD HH24:MI:SS.FF9';
ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT = 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR';
ALTER SESSION SET NLS_TIME_FORMAT = 'HH24:MI:SS.FF9';
ALTER SESSION SET NLS_TIME_TZ_FORMAT = 'HH24:MI:SS.FF9 TZR';

TRUNCATE TABLE "oracle_fdw"."t_binary_float";
TRUNCATE TABLE "oracle_fdw"."t_binary_double";
TRUNCATE TABLE "oracle_fdw"."t_number_sma";
TRUNCATE TABLE "oracle_fdw"."t_number_int";
TRUNCATE TABLE "oracle_fdw"."t_number_big";
TRUNCATE TABLE "oracle_fdw"."t_number_num";
TRUNCATE TABLE "oracle_fdw"."t_char_b";
TRUNCATE TABLE "oracle_fdw"."t_char_c";
TRUNCATE TABLE "oracle_fdw"."t_nchar";
TRUNCATE TABLE "oracle_fdw"."t_varchar2_b";
TRUNCATE TABLE "oracle_fdw"."t_varchar2_c";
TRUNCATE TABLE "oracle_fdw"."t_nvarchar2";
TRUNCATE TABLE "oracle_fdw"."t_long";
TRUNCATE TABLE "oracle_fdw"."t_clob";
TRUNCATE TABLE "oracle_fdw"."t_nclob";
TRUNCATE TABLE "oracle_fdw"."t_date";
TRUNCATE TABLE "oracle_fdw"."t_timestamp";
TRUNCATE TABLE "oracle_fdw"."t_timestamptz";
TRUNCATE TABLE "oracle_fdw"."t_timestampltz";
TRUNCATE TABLE "oracle_fdw"."t_interval_ym";
TRUNCATE TABLE "oracle_fdw"."t_interval_ds";
TRUNCATE TABLE "oracle_fdw"."t_raw";
TRUNCATE TABLE "oracle_fdw"."t_longraw";
TRUNCATE TABLE "oracle_fdw"."t_blob";
TRUNCATE TABLE "oracle_fdw"."t_bfile";

INSERT INTO "oracle_fdw"."t_number_int" VALUES(1, NULL, NULL);
INSERT INTO "oracle_fdw"."t_number_int" VALUES(2, 2, 2);
INSERT INTO "oracle_fdw"."t_number_int" VALUES(3, 1, 2);
INSERT INTO "oracle_fdw"."t_number_int" VALUES(4, 0, 3);
INSERT INTO "oracle_fdw"."t_number_int" VALUES(5, -1, 4);
INSERT INTO "oracle_fdw"."t_number_int" VALUES(6, -2, 5);
INSERT INTO "oracle_fdw"."t_number_int" VALUES(7, 2, 1);
INSERT INTO "oracle_fdw"."t_number_int" VALUES(8, 2, 0);

INSERT INTO "oracle_fdw"."t_number_sma" VALUES(1, 2, -1);

INSERT INTO "oracle_fdw"."t_float" VALUES(1, 1.4, 2);

INSERT INTO "oracle_fdw"."t_char_b" VALUES(1, NULL, NULL);
INSERT INTO "oracle_fdw"."t_char_b" VALUES(2, '', '');
INSERT INTO "oracle_fdw"."t_char_b" VALUES(3, 'abcba', 'AbCbA');
INSERT INTO "oracle_fdw"."t_char_b" VALUES(4, 'あいういあ', 'あぁアァ');
INSERT INTO "oracle_fdw"."t_char_b" VALUES(5, ' abcba', ' AbCbA');
INSERT INTO "oracle_fdw"."t_char_b" VALUES(6, ' あいういあ', ' あぁアァ');
INSERT INTO "oracle_fdw"."t_char_b" VALUES(7, ' ＡａＢｂＣｃ', ' ＡａＢｂＣｃ');

INSERT INTO "oracle_fdw"."t_char_c" VALUES(1, NULL, NULL);
INSERT INTO "oracle_fdw"."t_char_c" VALUES(2, '', '');
INSERT INTO "oracle_fdw"."t_char_c" VALUES(3, 'abcba', 'AbCbA');
INSERT INTO "oracle_fdw"."t_char_c" VALUES(4, 'あいういあ', 'あぁアァ');
INSERT INTO "oracle_fdw"."t_char_c" VALUES(5, ' abcba', ' AbCbA');
INSERT INTO "oracle_fdw"."t_char_c" VALUES(6, ' あいういあ', ' あぁアァ');
INSERT INTO "oracle_fdw"."t_char_c" VALUES(7, ' ＡａＢｂＣｃ', ' ＡａＢｂＣｃ');

INSERT INTO "oracle_fdw"."t_nchar" VALUES(1, NULL, NULL);
INSERT INTO "oracle_fdw"."t_nchar" VALUES(2, '', '');
INSERT INTO "oracle_fdw"."t_nchar" VALUES(3, 'abcba', 'AbCbA');
INSERT INTO "oracle_fdw"."t_nchar" VALUES(4, 'あいういあ', 'あぁアァ');
INSERT INTO "oracle_fdw"."t_nchar" VALUES(5, ' abcba', ' AbCbA');
INSERT INTO "oracle_fdw"."t_nchar" VALUES(6, ' あいういあ', ' あぁアァ');
INSERT INTO "oracle_fdw"."t_nchar" VALUES(7, ' ＡａＢｂＣｃ', ' ＡａＢｂＣｃ');

INSERT INTO "oracle_fdw"."t_varchar2_b" VALUES(1, NULL, NULL);
INSERT INTO "oracle_fdw"."t_varchar2_b" VALUES(2, '', '');
INSERT INTO "oracle_fdw"."t_varchar2_b" VALUES(3, 'abcba', 'AbCbA');
INSERT INTO "oracle_fdw"."t_varchar2_b" VALUES(4, 'あいういあ', 'あぁアァ');
INSERT INTO "oracle_fdw"."t_varchar2_b" VALUES(5, ' abcba', ' AbCbA');
INSERT INTO "oracle_fdw"."t_varchar2_b" VALUES(6, ' あいういあ', ' あぁアァ');
INSERT INTO "oracle_fdw"."t_varchar2_b" VALUES(7, ' ＡａＢｂＣｃ', ' ＡａＢｂＣｃ');

INSERT INTO "oracle_fdw"."t_varchar2_c" VALUES(1, NULL, NULL);
INSERT INTO "oracle_fdw"."t_varchar2_c" VALUES(2, '', '');
INSERT INTO "oracle_fdw"."t_varchar2_c" VALUES(3, 'abcba', 'AbCbA');
INSERT INTO "oracle_fdw"."t_varchar2_c" VALUES(4, 'あいういあ', 'あぁアァ');
INSERT INTO "oracle_fdw"."t_varchar2_c" VALUES(5, ' abcba', ' AbCbA');
INSERT INTO "oracle_fdw"."t_varchar2_c" VALUES(6, ' あいういあ', ' あぁアァ');
INSERT INTO "oracle_fdw"."t_varchar2_c" VALUES(7, ' ＡａＢｂＣｃ', ' ＡａＢｂＣｃ');

INSERT INTO "oracle_fdw"."t_nvarchar2" VALUES(1, NULL, NULL);
INSERT INTO "oracle_fdw"."t_nvarchar2" VALUES(2, '', '');
INSERT INTO "oracle_fdw"."t_nvarchar2" VALUES(3, 'abcba', 'AbCbA');
INSERT INTO "oracle_fdw"."t_nvarchar2" VALUES(4, 'あいういあ', 'あぁアァ');
INSERT INTO "oracle_fdw"."t_nvarchar2" VALUES(5, ' abcba', ' AbCbA');
INSERT INTO "oracle_fdw"."t_nvarchar2" VALUES(6, ' あいういあ', ' あぁアァ');
INSERT INTO "oracle_fdw"."t_nvarchar2" VALUES(7, ' ＡａＢｂＣｃ', ' ＡａＢｂＣｃ');

INSERT INTO "oracle_fdw"."t_long" VALUES(1, NULL);
INSERT INTO "oracle_fdw"."t_long" VALUES(2, '');
INSERT INTO "oracle_fdw"."t_long" VALUES(3, 'abcba');
INSERT INTO "oracle_fdw"."t_long" VALUES(4, 'あいういあ');
INSERT INTO "oracle_fdw"."t_long" VALUES(5, ' abcba');
INSERT INTO "oracle_fdw"."t_long" VALUES(6, ' あいういあ');
INSERT INTO "oracle_fdw"."t_long" VALUES(7, ' ＡａＢｂＣｃ');

INSERT INTO "oracle_fdw"."t_clob" VALUES(1, NULL, NULL);
INSERT INTO "oracle_fdw"."t_clob" VALUES(2, '', '');
INSERT INTO "oracle_fdw"."t_clob" VALUES(3, 'abcba', 'AbCbA');
INSERT INTO "oracle_fdw"."t_clob" VALUES(4, 'あいういあ', 'あぁアァ');
INSERT INTO "oracle_fdw"."t_clob" VALUES(5, ' abcba', ' AbCbA');
INSERT INTO "oracle_fdw"."t_clob" VALUES(6, ' あいういあ', ' あぁアァ');
INSERT INTO "oracle_fdw"."t_clob" VALUES(7, ' ＡａＢｂＣｃ', ' ＡａＢｂＣｃ');

INSERT INTO "oracle_fdw"."t_nclob" VALUES(1, NULL, NULL);
INSERT INTO "oracle_fdw"."t_nclob" VALUES(2, '', '');
INSERT INTO "oracle_fdw"."t_nclob" VALUES(3, 'abcba', 'AbCbA');
INSERT INTO "oracle_fdw"."t_nclob" VALUES(4, 'あいういあ', 'あぁアァ');
INSERT INTO "oracle_fdw"."t_nclob" VALUES(5, ' abcba', ' AbCbA');
INSERT INTO "oracle_fdw"."t_nclob" VALUES(6, ' あいういあ', ' あぁアァ');
INSERT INTO "oracle_fdw"."t_nclob" VALUES(7, ' ＡａＢｂＣｃ', ' ＡａＢｂＣｃ');

INSERT INTO "oracle_fdw"."t_raw" VALUES(1, NULL, NULL);
INSERT INTO "oracle_fdw"."t_raw" VALUES(2, '', '');
INSERT INTO "oracle_fdw"."t_raw" VALUES(3, '0123456789', '0123456789');

INSERT INTO "oracle_fdw"."t_date" VALUES(1, TO_DATE('2011-02-03 12:34:56', 'SYYYY-MM-DD HH24:MI:SS'), '2011-02-03 12:34:56');
INSERT INTO "oracle_fdw"."t_date" VALUES(2, TO_DATE('-4712-01-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS'), '-4712-01-01 00:00:00');
INSERT INTO "oracle_fdw"."t_date" VALUES(3, TO_DATE('9999-12-31 23:59:59', 'SYYYY-MM-DD HH24:MI:SS'), '9999-12-31 23:59:59');

INSERT INTO "oracle_fdw"."t_timestamp" VALUES(1, TO_TIMESTAMP('2011-02-03 12:34:56.123456789', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'), '2011-02-03 12:34:56.123456789');
INSERT INTO "oracle_fdw"."t_timestamp" VALUES(2, TO_TIMESTAMP('-4712-01-01 00:00:00.000001234', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'), '-4712-01-01 00:00:00.000001234');
INSERT INTO "oracle_fdw"."t_timestamp" VALUES(3, TO_TIMESTAMP('9999-12-31 23:59:59.999998999', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'), '9999-12-31 23:59:59.999998999');

INSERT INTO "oracle_fdw"."t_timestamptz" VALUES(1, TO_TIMESTAMP_TZ('2011-02-03 12:34:56.123456789 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'), '2011-02-03 12:34:56.123456789 Asia/Tokyo');
INSERT INTO "oracle_fdw"."t_timestamptz" VALUES(2, TO_TIMESTAMP_TZ('-4712-01-01 00:00:00.000001234 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'), '-4712-01-01 00:00:00.000001234 Asia/Tokyo');
INSERT INTO "oracle_fdw"."t_timestamptz" VALUES(3, TO_TIMESTAMP_TZ('9999-12-31 23:59:59.999998999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'), '9999-12-31 23:59:59.999998999 Asia/Tokyo');

INSERT INTO "oracle_fdw"."t_timestampltz" VALUES(1, TO_TIMESTAMP_TZ('2011-02-03 12:34:56.123456789  Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'), '2011-02-03 12:34:56.123456789');
INSERT INTO "oracle_fdw"."t_timestampltz" VALUES(2, TO_TIMESTAMP_TZ('-4712-01-01 00:00:00.000001234 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'), '-4712-01-01 00:00:00.000001234');
INSERT INTO "oracle_fdw"."t_timestampltz" VALUES(3, TO_TIMESTAMP_TZ('9999-12-31 23:59:59.999998999 Asia/Tokyo', 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR'), '9999-12-31 23:59:59.999998999');

INSERT INTO "oracle_fdw"."t_interval_ym" VALUES(1, INTERVAL '178000000' YEAR(9), INTERVAL '178000000' YEAR(9));
INSERT INTO "oracle_fdw"."t_interval_ym" VALUES(2, INTERVAL '177999999-11' YEAR(9) TO MONTH, INTERVAL '177999999-11' YEAR(9) TO MONTH);

INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(1, INTERVAL '999999999 23:59:59.999998999' DAY(9) TO SECOND(9), INTERVAL '999999999 23:59:59.999998999' DAY(9) TO SECOND(9));
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(2, INTERVAL '999999999 23:59' DAY(9) TO MINUTE, INTERVAL '999999999 23:59' DAY(9) TO MINUTE);
