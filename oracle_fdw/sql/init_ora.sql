ALTER SESSION SET NLS_LANGUAGE = 'AMERICAN';
ALTER SESSION SET NLS_DATE_FORMAT = 'SYYYY-MM-DD HH24:MI:SS';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'SYYYY-MM-DD HH24:MI:SS.FF9';
ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT = 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR';
ALTER SESSION SET NLS_TIME_FORMAT = 'HH24:MI:SS.FF9';
ALTER SESSION SET NLS_TIME_TZ_FORMAT = 'HH24:MI:SS.FF9 TZR';

CREATE USER "oracle_fdw" IDENTIFIED BY schema_user;
GRANT UNLIMITED TABLESPACE TO "oracle_fdw";
CREATE USER oracle_fdw IDENTIFIED BY oracle_fdw;

CREATE TABLE "oracle_fdw"."binary_float_real"(
	"id"	number(2),
	"val"	binary_float
);

CREATE TABLE "oracle_fdw"."binary_double_precision"(
	"id"	number(2),
	"val"	binary_double
);

CREATE TABLE "oracle_fdw"."number_smallint"(
	"id"	number(2),
	"val"	number(5)
);

CREATE TABLE "oracle_fdw"."number_integer"(
	"id"	number(2),
	"val"	number(10)
);

CREATE TABLE "oracle_fdw"."number_bigint"(
	"id"	number(2),
	"val"	number(19)
);

CREATE TABLE "oracle_fdw"."number_numeric1"(
	"id"	number(2),
	"val"	number(38,-84)
);
CREATE TABLE "oracle_fdw"."number_numeric2"(
	"id"	number(2),
	"val"	number(38,127)
);
CREATE TABLE "oracle_fdw"."number_numeric3"(
	"id"	number(2),
	"val"	number
);

CREATE TABLE "oracle_fdw"."float_numeric1"(
	"id"	number(2),
	"val"	float(126)
);
CREATE TABLE "oracle_fdw"."float_numeric2"(
	"id"	number(2),
	"val"	float
);

CREATE TABLE "oracle_fdw"."char_b"(
	"id"	number(2),
	"val"	char(2000 BYTE)
);
CREATE TABLE "oracle_fdw"."char_c"(
	"id"	number(2),
	"val"	char(2000 CHAR)
);

CREATE TABLE "oracle_fdw"."nchar_"(
	"id"	number(2),
	"val"	nchar(1000)
);

CREATE TABLE "oracle_fdw"."varchar2_"(
	"id"	number(2),
	"val"	varchar2(4000 CHAR)
);
CREATE TABLE "oracle_fdw"."varchar2_b"(
	"id"	number(2),
	"val"	varchar2(4000 BYTE)
);

CREATE TABLE "oracle_fdw"."nvarchar2_"(
	"id"	number(2),
	"val"	nvarchar2(2000)
);

CREATE TABLE "oracle_fdw"."long_"(
	"id"	number(2),
	"val"	long
);

CREATE TABLE "oracle_fdw"."clob_"(
	"id"	number(2),
	"val"	clob
);

CREATE TABLE "oracle_fdw"."nclob_"(
	"id"	number(2),
	"val"	nclob
);

CREATE TABLE "oracle_fdw"."date_"(
	"id"	number(2),
	"val"	date
);

CREATE TABLE "oracle_fdw"."timestamp_6"(
	"id"	number(2),
	"val"	timestamp(6)
);
CREATE TABLE "oracle_fdw"."timestamp_9"(
	"id"	number(2),
	"val"	timestamp(9)
);

CREATE TABLE "oracle_fdw"."timestamptz_6"(
	"id"	number(2),
	"val"	timestamp(6) with time zone
);
CREATE TABLE "oracle_fdw"."timestamptz_9"(
	"id"	number(2),
	"val"	timestamp(9) with time zone
);

CREATE TABLE "oracle_fdw"."timestampltz_6"(
	"id"	number(2),
	"val"	timestamp(6) with local time zone
);
CREATE TABLE "oracle_fdw"."timestampltz_9"(
	"id"	number(2),
	"val"	timestamp(9) with local time zone
);

CREATE TABLE "oracle_fdw"."intervalym_"(
	"id"	number(2),
	"val"	interval year(9) to month
);

CREATE TABLE "oracle_fdw"."intervalds_6"(
	"id"	number(2),
	"val"	interval day(9) to second(6)
);
CREATE TABLE "oracle_fdw"."intervalds_9"(
	"id"	number(2),
	"val"	interval day(9) to second(9)
);

CREATE VIEW "oracle_fdw"."rowid_" AS(
SELECT
	"id",
	rowid AS "val"
FROM "oracle_fdw"."number_integer"
);

CREATE TABLE "oracle_fdw"."t_urowid"(
	"id"	number(2) PRIMARY KEY
)
ORGANIZATION INDEX;
CREATE VIEW "oracle_fdw"."urowid_" AS(
SELECT
	"id",
	rowid AS "val"
FROM "oracle_fdw"."t_urowid"
);

CREATE TABLE "oracle_fdw"."raw_"(
	"id"	number(2),
	"val"	raw(2000)
);

CREATE TABLE "oracle_fdw"."long_raw_"(
	"id"	number(2),
	"val"	long raw
);

CREATE TABLE "oracle_fdw"."blob_"(
	"id"	number(2),
	"val"	blob
);

CREATE TABLE "oracle_fdw"."bfile_"(
	"id"	number(2),
	"val"	bfile
);

CREATE TABLE "oracle_fdw"."t1"(
	"c1" number(4),
	"c2" nvarchar2(5),
	"c3" char(5),
	"c4" timestamp
);

CREATE TABLE "oracle_fdw"."t2" (
	"c1" number(4),
	"c2" nclob,
	"c3" nclob
);

INSERT INTO "oracle_fdw"."t1" VALUES(1, 'A', 'a', '2011-01-01 12:34:56');
INSERT INTO "oracle_fdw"."t1" VALUES(2, 'BB', 'bb', '2011-01-02 12:34:56');
INSERT INTO "oracle_fdw"."t1" VALUES(3, 'CCC', 'ccc', '2011-01-03 12:34:56');
INSERT INTO "oracle_fdw"."t1" VALUES(4, 'DDDD', 'dddd', '2011-01-04 12:34:56');
INSERT INTO "oracle_fdw"."t1" VALUES(5, 'あ', 'ア', '2011-01-05 12:34:56');
INSERT INTO "oracle_fdw"."t1" VALUES(6, '  A  ', 'abcba', '2011-01-05 12:34:56');

INSERT INTO "oracle_fdw"."t2" VALUES(1, LPAD('Z', 2000, 'Z'), LPAD('z', 1000, 'z'));
INSERT INTO "oracle_fdw"."t2" VALUES(2, LPAD('Y', 4000, 'Y'), LPAD('y', 3000, 'y'));

CREATE TABLE "oracle_fdw"."all_type" (
	"id" number(4),
	"binary_float_real_1"			binary_float,
	"binary_float_real_2"			binary_float,
	"binary_double_precision_1"	binary_double,
	"binary_double_precision_2"	binary_double,
	"number_smallint_1"			number(5),
	"number_smallint_2"			number(5),
	"number_integer_1"			number(10),
	"number_integer_2"			number(10),
	"number_bigint_1"				number(19),
	"number_bigint_2"				number(19),
	"number_numeric1_1"			number(38, -84),
	"number_numeric1_2"			number(38, -84),
	"number_numeric2_1"			number(38, 127),
	"number_numeric2_2"			number(38, 127),
	"number_numeric3_1"			number,
	"number_numeric3_2"			number,
	"float_numeric1_1"			float(126),
	"float_numeric1_2"			float(126),
	"float_numeric2_1"			float,
	"float_numeric2_2"			float,
	"char_char_1"					char(2000 CHAR),
	"char_char_2"					char(2000 CHAR),
	"nchar_char_1"				char(2000 CHAR),
	"nchar_char_2"				char(2000 CHAR),
	"varchar2_varchar_1"			varchar2(4000 CHAR),
	"varchar2_varchar_2"			varchar2(4000 CHAR),
	"nvarchar2_varchar_1"			varchar2(4000 CHAR),
	"nvarchar2_varchar_2"			varchar2(4000 CHAR),
	"long_text_1"					long,
	--long_text_2					long,
	"clob_text_1"					clob,
	"clob_text_2"					clob,
	"nclob_text_1"				nclob,
	"nclob_text_2"				nclob,
	"date_date_1"					date,
	"date_date_2"					date,
	"date_timestamp_1"			date,
	"date_timestamp_2"			date,
	"timestamp6_timestamp_1"		timestamp(6),
	"timestamp6_timestamp_2"		timestamp(6),
	"timestamp9_timestamp_1"		timestamp(9),
	"timestamp9_timestamp_2"		timestamp(9),
	"timestamptz6_timestamptz_1"	timestamp(6) with time zone,
	"timestamptz6_timestamptz_2"	timestamp(6) with time zone,
	"timestamptz9_timestamptz_1"	timestamp(9) with time zone,
	"timestamptz9_timestamptz_2"	timestamp(9) with time zone,
	"timestampltz6_timestamptz_1"	timestamp(6) with local time zone,
	"timestampltz6_timestamptz_2"	timestamp(6) with local time zone,
	"timestampltz9_timestamptz_1"	timestamp(9) with local time zone,
	"timestampltz9_timestamptz_2"	timestamp(9) with local time zone,
	"intervalym_interval_1"		interval year(9) to month,
	"intervalym_interval_2"		interval year(9) to month,
	"intervalds6_interval_1"		interval day(9) to second(6),
	"intervalds6_interval_2"		interval day(9) to second(6),
	"intervalds9_interval_1"		interval day(9) to second(9),
	"intervalds9_interval_2"		interval day(9) to second(9),
	"raw_bytea_1"					raw(200),
	"raw_bytea_2"					raw(200),
	--long_raw_bytea_1			long raw,
	--long_raw_bytea_2			long raw,
	"blob_bytea_1"				blob,
	"blob_bytea_2"				blob,
	"bfile_bytea_1"				bfile,
	"bfile_bytea_2"				bfile
);

CREATE DIRECTORY DIR as '/tmp/oracle_fdw'; 

GRANT READ ON DIRECTORY DIR TO oracle_fdw WITH GRANT OPTION;
GRANT CREATE SESSION TO oracle_fdw;
GRANT SELECT ANY TABLE TO oracle_fdw;

-- Numeric Types
CREATE TABLE "oracle_fdw"."t_binary_float"  ("id" number(2), "val1" binary_float, "val2" binary_float);
CREATE TABLE "oracle_fdw"."t_binary_double" ("id" number(2), "val1" binary_double, "val2" binary_double);
CREATE TABLE "oracle_fdw"."t_number_sma"    ("id" number(2), "val1" number, "val2" number);
CREATE TABLE "oracle_fdw"."t_number_int"    ("id" number(2), "val1" number, "val2" number);
CREATE TABLE "oracle_fdw"."t_number_big"    ("id" number(2), "val1" number, "val2" number);
CREATE TABLE "oracle_fdw"."t_number_num"    ("id" number(2), "val1" number, "val2" number);
CREATE TABLE "oracle_fdw"."t_float"         ("id" number(2), "val1" float, "val2" float);

-- Character Types
CREATE TABLE "oracle_fdw"."t_char_b"("id" number(2), "val1" char(2000 BYTE), "val2" char(2000 BYTE));
CREATE TABLE "oracle_fdw"."t_char_c"("id" number(2), "val1" char(2000 CHAR), "val2" char(2000 CHAR));
CREATE TABLE "oracle_fdw"."t_nchar"("id" number(2), "val1" nchar(1000), "val2" nchar(1000));
CREATE TABLE "oracle_fdw"."t_varchar2_b"("id" number(2), "val1" varchar2(4000 BYTE), "val2" varchar2(4000 BYTE));
CREATE TABLE "oracle_fdw"."t_varchar2_c"("id" number(2), "val1" varchar2(4000 CHAR), "val2" varchar2(4000 CHAR));
CREATE TABLE "oracle_fdw"."t_nvarchar2"("id" number(2), "val1" nvarchar2(2000), "val2" nvarchar2(2000));
CREATE TABLE "oracle_fdw"."t_long"("id" number(2), "val1" long);
CREATE TABLE "oracle_fdw"."t_clob"("id" number(2), "val1" clob, "val2" clob);
CREATE TABLE "oracle_fdw"."t_nclob"("id" number(2), "val1" nclob, "val2" nclob);

-- Date/Time Types
CREATE TABLE "oracle_fdw"."t_date"        ("id" number(2), "val1" date, "val2" date);
CREATE TABLE "oracle_fdw"."t_timestamp"   ("id" number(2), "val1" timestamp(9), "val2" timestamp(9));
CREATE TABLE "oracle_fdw"."t_timestamptz" ("id" number(2), "val1" timestamp(9) with time zone, "val2" timestamp(9) with time zone);
CREATE TABLE "oracle_fdw"."t_timestampltz"("id" number(2), "val1" timestamp(9) with local time zone, "val2" timestamp(9) with local time zone);

CREATE TABLE "oracle_fdw"."t_interval_ym"("id" number(2), "val1" interval year(9) to month, "val2" interval year(9) to month);
CREATE TABLE "oracle_fdw"."t_interval_ds"("id" number(2), "val1" interval day(9) to second(9), "val2" interval day(9) to second(9));

-- Binary Data Types
CREATE TABLE "oracle_fdw"."t_raw"     ("id" number(2), "val1" raw(2000), "val2" raw(2000));
CREATE TABLE "oracle_fdw"."t_longraw" ("id" number(2), "val1" long raw);
CREATE TABLE "oracle_fdw"."t_blob"    ("id" number(2), "val1" blob, "val2" blob);
CREATE TABLE "oracle_fdw"."t_bfile"   ("id" number(2), "val1" bfile, "val2" bfile);

-- Large Data Types
CREATE TABLE "oracle_fdw"."t_large_long"   ("val1" long);
CREATE TABLE "oracle_fdw"."t_large_clob"   ("val1" clob);
CREATE TABLE "oracle_fdw"."t_large_nclob"  ("val1" nclob);

CREATE TABLE "oracle_fdw"."t_large_raw"    ("val1" raw(2000));
CREATE TABLE "oracle_fdw"."t_large_longraw"("val1" long raw);
CREATE TABLE "oracle_fdw"."t_large_blob"   ("val1" blob);
CREATE TABLE "oracle_fdw"."t_large_bfile"  ("val1" bfile);

-- Use Character Types test
CREATE TABLE "oracle_fdw"."char10"   ("id" number(2), "val" char(10 CHAR));
CREATE TABLE "oracle_fdw"."varchar10"("id" number(2), "val" varchar2(10 CHAR));
CREATE TABLE "oracle_fdw"."mix"      ("id" number(2),
	"char_10"		char(10 CHAR),
	"char_2"		char(2 CHAR),
	"varchar_10"	varchar2(10 CHAR),
	"varchar_2"		varchar2(2 CHAR)
);

-- char
INSERT INTO "oracle_fdw"."char10" VALUES(1, 'abc');
INSERT INTO "oracle_fdw"."char10" VALUES(2, 'ABC');
INSERT INTO "oracle_fdw"."char10" VALUES(3, 'あいう');
INSERT INTO "oracle_fdw"."char10" VALUES(4, 'アイウ');
INSERT INTO "oracle_fdw"."char10" VALUES(5, '   ');
INSERT INTO "oracle_fdw"."char10" VALUES(6, '　　　');

INSERT INTO "oracle_fdw"."varchar10" VALUES(1, 'abc');
INSERT INTO "oracle_fdw"."varchar10" VALUES(2, 'ABC');
INSERT INTO "oracle_fdw"."varchar10" VALUES(3, 'あいう');
INSERT INTO "oracle_fdw"."varchar10" VALUES(4, 'アイウ');
INSERT INTO "oracle_fdw"."varchar10" VALUES(5, '   ');
INSERT INTO "oracle_fdw"."varchar10" VALUES(6, '　　　');
INSERT INTO "oracle_fdw"."varchar10" VALUES(11, 'abc   ');
INSERT INTO "oracle_fdw"."varchar10" VALUES(12, 'ABC   ');
INSERT INTO "oracle_fdw"."varchar10" VALUES(13, 'あいう   ');
INSERT INTO "oracle_fdw"."varchar10" VALUES(14, 'アイウ   ');
INSERT INTO "oracle_fdw"."varchar10" VALUES(15, '      ');
INSERT INTO "oracle_fdw"."varchar10" VALUES(16, '　　　   ');

INSERT INTO "oracle_fdw"."mix" VALUES(1, 'a', 'a', 'a', 'a');
INSERT INTO "oracle_fdw"."mix" VALUES(2, 'a         ', 'a ', 'a         ', 'a ');
EXIT
