BEGIN;
-- DROP ROLE
DROP ROLE IF EXISTS createuser;
DROP ROLE IF EXISTS syncdbuser;

-- DROP OBJECT
DROP SCHEMA IF EXISTS test CASCADE;

DROP TABLE IF EXISTS public.tab1;
DROP TABLE IF EXISTS public.tab2;
DROP TABLE IF EXISTS public.foo;
DROP TABLE IF EXISTS public.bar;
DROP TABLE IF EXISTS public.ccc;
DROP TABLE IF EXISTS public.inc;
DROP TABLE IF EXISTS public.pk_test;
DROP TABLE IF EXISTS public.attach1;
DROP TABLE IF EXISTS public.detach1;
DROP TABLE IF EXISTS public.detach2;
DROP TABLE IF EXISTS public.detach3;
DROP TABLE IF EXISTS public.create1;
DROP TABLE IF EXISTS public.drop1;

TRUNCATE TABLE mlog.subscriber;
TRUNCATE TABLE mlog.master CASCADE;

-- CREATE ROLE
CREATE ROLE createuser;
CREATE ROLE syncdbuser SUPERUSER LOGIN;

-- CREATE OBJECT
CREATE SCHEMA test;

CREATE TABLE public.tab1 (pk1 smallint, pk2 integer,
bigint_val bigint,
integer_val integer,
real_val real,
double_val double precision,
numeric_val numeric,
serial_val serial,
bigserial_val bigserial,
varcahr_val character varying,
character_val character,
text_val text,
name_val name,
date_val date,
timestamp_val timestamp,
timestamptz_val timestamp with time zone,
time_val time,
interval_val interval,
bytea_val bytea,
-- money_val money,
boolean_val boolean,
point_val point,
lseg_val lseg,
box_val box,
path_val path,
polygon_val polygon,
circle_val circle,
cidr_val cidr,
inet_val inet,
macaddr_val macaddr,
-- bit_val bit,
varbit_val bit varying,
uuid_val uuid,
-- xml_val xml,
oid_val oid,
regproc_val regproc,
regprocedure_val regprocedure,
regoper_val regoper,
regoperator_val regoperator,
regclass_val regclass,
regtype_val regtype,
regconfig_val regconfig,
regdictionary_val regdictionary
);

CREATE TABLE public.tab2 (LIKE public.tab1);
CREATE TABLE public.foo (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.bar (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.ccc (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.fff (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.inc (pk1 integer, pk2 char(5), val1 timestamp, noval text);
CREATE TABLE public.pk_test (pk_1 integer, "pK_2" integer, "P""K""_3""" integer);
CREATE TABLE public.attach1 (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.detach1 (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.detach2 (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.detach3 (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.create1 (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.drop1 (val1 integer, val2 text, val3 timestamp);
CREATE TABLE test.foo (val1 integer, val2 text, val3 timestamp);

ALTER TABLE public.tab1 ADD PRIMARY KEY (pk1, pk2);
ALTER TABLE public.tab2 ADD PRIMARY KEY (pk1, pk2);
ALTER TABLE public.foo ADD PRIMARY KEY (val1);
ALTER TABLE public.bar ADD PRIMARY KEY (val1);
ALTER TABLE public.ccc ADD PRIMARY KEY (val1);
ALTER TABLE public.inc ADD PRIMARY KEY (pk1, pk2);
ALTER TABLE public.pk_test ADD PRIMARY KEY ("P""K""_3""", "pK_2", pk_1);
ALTER TABLE public.attach1 ADD PRIMARY KEY (val1);
ALTER TABLE public.detach1 ADD PRIMARY KEY (val1);
ALTER TABLE public.detach2 ADD PRIMARY KEY (val1);
ALTER TABLE public.detach3 ADD PRIMARY KEY (val1);
ALTER TABLE public.create1 ADD PRIMARY KEY (val1);
ALTER TABLE public.drop1 ADD PRIMARY KEY (val1);
ALTER TABLE test.foo ADD PRIMARY KEY (val1);

-- LOAD DATA
SELECT setval('mlog.subscriber_subsid_seq', 100);

INSERT INTO mlog.master (
SELECT * FROM (VALUES
('public.tab1'),
('public.tab2'),
('public.bar'),
('public.ccc'),
('public.fff'),
('public.foo'),
('public.inc'),
('public.attach1'),
('public.detach1'),
('public.detach2'),
('public.detach3'),
('test.foo')
) AS a(a),
(SELECT oid FROM pg_authid WHERE rolname = 'createuser') AS b);

INSERT INTO mlog.master (
SELECT 'public.drop1', oid FROM (SELECT oid FROM pg_authid WHERE rolname = 'syncdbuser') AS a);

COMMIT;
BEGIN;
INSERT INTO mlog.subscriber (
SELECT b.a, b.b, a.a, b.c, b.d, b.e, b.f, b.g FROM
(SELECT oid FROM pg_roles WHERE rolname = 'syncdbuser') AS a(a),
(VALUES
(1, 'public.tab1', 'description1', '2010-01-01 12:34:56'::timestamptz, NULL, -1, -1),
(2, 'public.tab2', 'description2', '2010-01-02 12:34:56'::timestamptz, NULL, 0, 0),
(3, 'public.bar', 'description5', '2010-01-01 12:34:56'::timestamptz, NULL, 0, 100),
(4, 'public.ccc', 'description3', '2010-01-01 12:34:56'::timestamptz, NULL, 100, 100),
(5, 'public.foo', 'resource name:"postgres2", DBMS:"PostgreSQL", URL:"jdbc:postgresql://"', '2010-01-01 12:34:56'::timestamptz, NULL, 0, 100),
(6, 'public.inc', 'incremental refresh test table 1', '2010-01-01 12:34:56'::timestamptz, 'F', 10, 10),
(7, 'public.inc', 'incremental refresh test table 2', '2010-01-01 12:34:57'::timestamptz, 'F', 15, 5),
(8, 'public.foo', 'description7', '2010-01-01 12:34:56'::timestamptz, 'F', 1, 7),
(10, 'public.attach1', 'desc attach1', '2010-01-01 12:34:56'::timestamptz, 'F', 1, 7),
(12, 'public.detach2', 'desc detach2', '2010-01-01 12:34:56'::timestamptz, 'F', 2, 20),
(13, 'public.detach3', 'desc detach3', '2010-01-01 12:34:56'::timestamptz, 'F', 3, 30),
(14, 'public.drop1', 'desc drop1', '2010-01-01 12:34:56'::timestamptz, 'F', 1, 10),
(15, 'public.fff', 'desc master droped', NULL::timestamptz, NULL, 1, 1)
) AS b(a,b,c,d,e,f,g));
DROP TABLE IF EXISTS public.fff;

INSERT INTO public.tab1 VALUES
(0,1,2,3,'1.2','3.4','5.6',7,8,'a','b','c','d','2010-01-01','2010-01-02 12:34:56','2010-01-03 12:34:56','11:11:11','12 year 3month',
E'\\001',
-- MONEY '123',
TRUE,'(1,2)','((1, 2), (3, 4))','((5, 6), (7, 8))','((11, 12), (13, 14), (15, 16))','((21, 22), (23, 24), (25, 26))',
'<(1, 2), 3>','192.168.100.128/25','192.168.101.128/25','08:00:2b:01:02:03',
-- BIT B'1',
B'10101','a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
-- '<foo>bar</foo>'::xml,
999,'byteaout','byteaout(bytea)','!','!!(NONE,bigint)','pg_am','"any"','english','english_stem');

INSERT INTO public.foo VALUES
('1', 'A', '2010-01-01 00:00:01'),
('2', 'B', '2010-01-01 00:00:02'),
('3', 'C', '2010-01-01 00:00:03'),
('4', 'D', '2010-01-01 00:00:04'),
('5', 'E', '2010-01-01 00:00:05'),
('6', 'F', '2010-01-01 00:00:06'),
('7', 'G', '2010-01-01 00:00:07');

INSERT INTO public.bar VALUES
('1', 'a', '2010-01-01 00:00:01'),
('2', 'b', '2010-01-01 00:00:02');

INSERT INTO public.inc VALUES
(1, 'a', '2010-01-01 00:00:01', 'aaa'),
(2, 'b', '2010-01-01 00:00:02', 'bbb'),
(4, 'd', '2010-01-01 00:00:04', 'ddd'),
(5, 'e', '2010-01-01 00:00:05', 'eee'),
(6, 'f', '2010-01-01 00:00:06', 'fff'),
(7, 'g', '2010-01-01 00:00:07', 'ggg'),
(8, 'h', '2010-01-01 00:00:08', 'hhh'),
(9, 'i', '2010-01-01 00:00:09', 'iii'),
(10, 'j', '2010-01-01 00:00:10', 'jjj');

COMMIT;
