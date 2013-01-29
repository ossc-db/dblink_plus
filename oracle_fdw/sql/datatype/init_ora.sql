ALTER SESSION SET NLS_LANGUAGE = 'AMERICAN';
ALTER SESSION SET NLS_DATE_FORMAT = 'SYYYY-MM-DD HH24:MI:SS';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'SYYYY-MM-DD HH24:MI:SS.FF9';
ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT = 'SYYYY-MM-DD HH24:MI:SS.FF9 TZR';
ALTER SESSION SET NLS_TIME_FORMAT = 'HH24:MI:SS.FF9';
ALTER SESSION SET NLS_TIME_TZ_FORMAT = 'HH24:MI:SS.FF9 TZR';

TRUNCATE TABLE "oracle_fdw"."t_raw";
TRUNCATE TABLE "oracle_fdw"."t_longraw";
TRUNCATE TABLE "oracle_fdw"."t_blob";
TRUNCATE TABLE "oracle_fdw"."t_bfile";
TRUNCATE TABLE "oracle_fdw"."t_date";
TRUNCATE TABLE "oracle_fdw"."t_timestamp";
TRUNCATE TABLE "oracle_fdw"."t_timestamptz";
TRUNCATE TABLE "oracle_fdw"."t_timestampltz";
TRUNCATE TABLE "oracle_fdw"."t_interval_ym";
TRUNCATE TABLE "oracle_fdw"."t_interval_ds";
TRUNCATE TABLE "oracle_fdw"."t_large_raw";
TRUNCATE TABLE "oracle_fdw"."t_large_longraw";
TRUNCATE TABLE "oracle_fdw"."t_large_blob";
TRUNCATE TABLE "oracle_fdw"."t_large_bfile";
TRUNCATE TABLE "oracle_fdw"."t_large_long";
TRUNCATE TABLE "oracle_fdw"."t_large_clob";
TRUNCATE TABLE "oracle_fdw"."t_large_nclob";

-- datatype/binary
INSERT INTO "oracle_fdw"."t_raw"     VALUES(1, '414243444546', '414243444546');
INSERT INTO "oracle_fdw"."t_raw"     VALUES(2, '5C78414243444546', '5C78414243444546');
INSERT INTO "oracle_fdw"."t_raw"     VALUES(3, '', '');
INSERT INTO "oracle_fdw"."t_raw"     VALUES(4, NULL, NULL);
INSERT INTO "oracle_fdw"."t_longraw" VALUES(1, '414243444546');
INSERT INTO "oracle_fdw"."t_longraw" VALUES(2, '5C78414243444546');
INSERT INTO "oracle_fdw"."t_longraw" VALUES(3, '');
INSERT INTO "oracle_fdw"."t_longraw" VALUES(4, NULL);
INSERT INTO "oracle_fdw"."t_blob"    VALUES(1, '414243444546', '414243444546');
INSERT INTO "oracle_fdw"."t_blob"    VALUES(2, '5C78414243444546', '5C78414243444546');
INSERT INTO "oracle_fdw"."t_blob"    VALUES(3, '', '');
INSERT INTO "oracle_fdw"."t_blob"    VALUES(4, NULL, NULL);
INSERT INTO "oracle_fdw"."t_bfile"   VALUES(1, bfilename('DIR', 'bfile1.txt'),  bfilename('DIR', 'bfile1.txt'));
INSERT INTO "oracle_fdw"."t_bfile"   VALUES(1, bfilename('DIR', 'bfile1.txt'), bfilename('DIR', 'bfile1.txt'));
INSERT INTO "oracle_fdw"."t_bfile"   VALUES(3, '', '');
INSERT INTO "oracle_fdw"."t_bfile"   VALUES(4, NULL, NULL);

-- datatype/date
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

-- datatype/date
INSERT INTO "oracle_fdw"."t_interval_ym" VALUES(1, INTERVAL '178000000' YEAR(9), INTERVAL '178000000' YEAR(9));
INSERT INTO "oracle_fdw"."t_interval_ym" VALUES(2, INTERVAL '177999999-11' YEAR(9) TO MONTH, INTERVAL '177999999-11' YEAR(9) TO MONTH);
INSERT INTO "oracle_fdw"."t_interval_ym" VALUES(3, INTERVAL '178000000-1' YEAR(9) TO MONTH, INTERVAL '178000000-1' YEAR(9) TO MONTH);
INSERT INTO "oracle_fdw"."t_interval_ym" VALUES(4, INTERVAL '-178000000' YEAR(9), INTERVAL '-178000000' YEAR(9));
INSERT INTO "oracle_fdw"."t_interval_ym" VALUES(5, INTERVAL '-177999999-11' YEAR(9) TO MONTH, INTERVAL '-177999999-11' YEAR(9) TO MONTH);
INSERT INTO "oracle_fdw"."t_interval_ym" VALUES(6, INTERVAL '-178000000-1' YEAR(9) TO MONTH, INTERVAL '-178000000-1' YEAR(9) TO MONTH);
INSERT INTO "oracle_fdw"."t_interval_ym" VALUES(7, INTERVAL '1-1' YEAR(9) TO MONTH, INTERVAL '1-1' YEAR(9) TO MONTH);
INSERT INTO "oracle_fdw"."t_interval_ym" VALUES(8, INTERVAL '1' YEAR(9), INTERVAL '1' YEAR(9));
INSERT INTO "oracle_fdw"."t_interval_ym" VALUES(9, INTERVAL '1' MONTH(9), INTERVAL '1' MONTH(9));
INSERT INTO "oracle_fdw"."t_interval_ym" VALUES(10, INTERVAL '-1-1' YEAR(9) TO MONTH, INTERVAL '-1-1' YEAR(9) TO MONTH);
INSERT INTO "oracle_fdw"."t_interval_ym" VALUES(11, INTERVAL '-1' YEAR(9), INTERVAL '-1' YEAR(9));
INSERT INTO "oracle_fdw"."t_interval_ym" VALUES(12, INTERVAL '-1' MONTH(9), INTERVAL '-1' MONTH(9));

INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(1, INTERVAL '999999999 23:59:59.999998999' DAY(9) TO SECOND(9), INTERVAL '999999999 23:59:59.999998999' DAY(9) TO SECOND(9));
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(2, INTERVAL '999999999 23:59' DAY(9) TO MINUTE, INTERVAL '999999999 23:59' DAY(9) TO MINUTE);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(3, INTERVAL '23:59:59.999998999' HOUR TO SECOND(9), INTERVAL '23:59:59.999998999' HOUR TO SECOND(9));
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(4, INTERVAL '999999999 23' DAY(9) TO HOUR, INTERVAL '999999999 23' DAY(9) TO HOUR);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(5, INTERVAL '23:59' HOUR TO MINUTE, INTERVAL '23:59' HOUR TO MINUTE);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(6, INTERVAL '59:59.999998999' MINUTE TO SECOND(9), INTERVAL '59:59.999998999' MINUTE TO SECOND(9));
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(7, INTERVAL '999999999' DAY(9), INTERVAL '999999999' DAY(9));
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(8, INTERVAL '23' HOUR, INTERVAL '23' HOUR);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(9, INTERVAL '59' MINUTE, INTERVAL '59' MINUTE);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(10, INTERVAL '00:59.999998999' MINUTE TO SECOND(9), INTERVAL '00:59.999998999' MINUTE TO SECOND(9));
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(11, INTERVAL '-999999999 23:59:59.999998999' DAY(9) TO SECOND(9), INTERVAL '-999999999 23:59:59.999998999' DAY(9) TO SECOND(9));
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(12, INTERVAL '-999999999 23:59' DAY(9) TO MINUTE, NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(13, INTERVAL '-23:59:59.999998999' HOUR TO SECOND(9), NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(14, INTERVAL '-999999999 23' DAY(9) TO HOUR, NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(15, INTERVAL '-23:59' HOUR TO MINUTE, NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(16, INTERVAL '-59:59.999998999' MINUTE TO SECOND(9), NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(17, INTERVAL '-999999999' DAY(9), NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(18, INTERVAL '-23' HOUR, NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(19, INTERVAL '-59' MINUTE, NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(20, INTERVAL '-00:59.999998999' MINUTE TO SECOND(9), NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(21, INTERVAL '1 1:1:0.000001234' DAY(9) TO SECOND(9), NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(22, INTERVAL '1 1:1' DAY(9) TO MINUTE, NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(23, INTERVAL '1:1:0.000001234' HOUR TO SECOND(9), NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(24, INTERVAL '1 1' DAY(9) TO HOUR, NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(25, INTERVAL '1:1' HOUR TO MINUTE, NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(26, INTERVAL '1:0.000001234' MINUTE TO SECOND(9), NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(27, INTERVAL '1' DAY(9), NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(28, INTERVAL '1' HOUR, NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(29, INTERVAL '1' MINUTE, NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(30, INTERVAL '00:0.000001234' MINUTE TO SECOND(9), NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(31, INTERVAL '-1 1:1:0.000001234' DAY(9) TO SECOND(9), NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(32, INTERVAL '-1 1:1' DAY(9) TO MINUTE, NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(33, INTERVAL '-1:1:0.000001234' HOUR TO SECOND(9), NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(34, INTERVAL '-1 1' DAY(9) TO HOUR, NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(35, INTERVAL '-1:1' HOUR TO MINUTE, NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(36, INTERVAL '-1:0.000001234' MINUTE TO SECOND(9), NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(37, INTERVAL '-1' DAY(9), NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(38, INTERVAL '-1' HOUR, NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(39, INTERVAL '-1' MINUTE, NULL);
INSERT INTO "oracle_fdw"."t_interval_ds" VALUES(40, INTERVAL '-00:0.000001234' MINUTE TO SECOND(9), NULL);

-- datatype/large
INSERT INTO "oracle_fdw"."t_large_raw"     VALUES(LPAD('A', 4000, 'A'));
DECLARE
	wk_vchar	LONG RAW;
BEGIN
	wk_vchar := LPAD('A', 32767, 'A');
	INSERT INTO "oracle_fdw"."t_large_longraw" VALUES (wk_vchar);
	COMMIT;
END;
/

DECLARE
	wk_blob		BLOB;
	wk_bfile	BFILE;
BEGIN
	INSERT INTO "oracle_fdw"."t_large_blob" VALUES (empty_blob());
	SELECT "val1" INTO wk_blob FROM "oracle_fdw"."t_large_blob" WHERE ROWNUM = 1;
	wk_bfile := bfilename('DIR', 'large_bfile.txt');
	DBMS_LOB.FILEOPEN( wk_bfile, DBMS_LOB.FILE_READONLY );
	DBMS_LOB.LOADFROMFILE(wk_blob, wk_bfile, DBMS_LOB.GETLENGTH(wk_bfile));
	DBMS_LOB.FILECLOSE(wk_bfile);
END;
/
INSERT INTO "oracle_fdw"."t_large_bfile" VALUES(bfilename('DIR', 'large_bfile.txt'));

DECLARE
	wk_vchar	VARCHAR2(32767);
BEGIN
	wk_vchar := LPAD('A', 32767, 'A');
	INSERT INTO "oracle_fdw"."t_large_long" VALUES(wk_vchar);
	COMMIT;
END;
/

DECLARE
	wk_clob	CLOB;
BEGIN
	wk_clob := '';
	FOR i IN 1..10240 LOOP
		wk_clob := wk_clob  || LPAD('A', 1024, 'A');
	END LOOP;
	INSERT INTO "oracle_fdw"."t_large_clob" VALUES (wk_clob);
END;
/
INSERT INTO "oracle_fdw"."t_large_nclob" SELECT * FROM "oracle_fdw"."t_large_clob";

GRANT SELECT ANY TABLE TO oracle_fdw;
