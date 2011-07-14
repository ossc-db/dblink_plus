-- DROP OBJECT
DROP SCHEMA IF EXISTS test CASCADE;

DROP TABLE IF EXISTS public.rep_tab1;
DROP TABLE IF EXISTS public.rep_tab2;
DROP TABLE IF EXISTS public.rep_foo;
DROP TABLE IF EXISTS public.rep_bar;
DROP TABLE IF EXISTS public.rep_aaa;
DROP TABLE IF EXISTS public.rep_bbb;
DROP TABLE IF EXISTS public.rep_ccc;
DROP TABLE IF EXISTS public.rep_ddd;
DROP TABLE IF EXISTS public.rep_eee;
DROP TABLE IF EXISTS public.rep_fff;
DROP TABLE IF EXISTS public.rep_inc1;
DROP TABLE IF EXISTS public.rep_inc2;
DROP TABLE IF EXISTS public.rep_foo_inc;
DROP TABLE IF EXISTS public.rep_attach1;
DROP TABLE IF EXISTS public.rep_attach_inc;
DROP TABLE IF EXISTS public.rep_attach_full;
DROP TABLE IF EXISTS public.rep_detach1;
DROP TABLE IF EXISTS public.rep_detach2;
DROP TABLE IF EXISTS public.rep_detach22;
DROP TABLE IF EXISTS public.rep_drop1;

TRUNCATE TABLE observer.subscription;

-- CREATE OBJECT
CREATE SCHEMA test;

CREATE TABLE public.rep_tab1 (pk1 smallint, pk2 integer,
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
--money_val money,
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
CREATE TABLE public.rep_tab2 (LIKE public.rep_tab1);

CREATE TABLE public.rep_foo (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.rep_bar (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.rep_aaa (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.rep_bbb (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.rep_ccc (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.rep_ddd (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.rep_eee (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.rep_fff (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.rep_ggg (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.rep_inc1 (pk1 integer, pk2 char(5), val1 timestamp, noval text);
CREATE TABLE public.rep_inc2 (val1_copy timestamp, changename1_val1 timestamp, changename_pk2 char(5), changename_pk1 integer, changename2_val1 timestamp, pk2_copy char(5), pk1_copy integer);
CREATE TABLE public.rep_foo_inc (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.rep_attach1 (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.rep_attach_inc (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.rep_attach_full (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.rep_detach1 (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.rep_detach2 (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.rep_detach22 (val1 integer, val2 text, val3 timestamp);
CREATE TABLE public.rep_drop1 (val1 integer, val2 text, val3 timestamp);
CREATE TABLE test.rep_foo (val1 integer, val2 text, val3 timestamp);

ALTER TABLE public.rep_tab1 ADD PRIMARY KEY (pk1, pk2);
ALTER TABLE public.rep_tab2 ADD PRIMARY KEY (pk2, pk1);
ALTER TABLE public.rep_foo ADD PRIMARY KEY (val1);
ALTER TABLE public.rep_bar ADD PRIMARY KEY (val1);
ALTER TABLE public.rep_aaa ADD PRIMARY KEY (val1);
ALTER TABLE public.rep_bbb ADD PRIMARY KEY (val1);
ALTER TABLE public.rep_ccc ADD PRIMARY KEY (val1);
ALTER TABLE public.rep_ddd ADD PRIMARY KEY (val1);
ALTER TABLE public.rep_eee ADD PRIMARY KEY (val1);
ALTER TABLE public.rep_fff ADD PRIMARY KEY (val1);
ALTER TABLE public.rep_inc1 ADD PRIMARY KEY (pk1, pk2);
ALTER TABLE public.rep_inc2 ADD PRIMARY KEY (changename_pk1, changename_pk2);
ALTER TABLE public.rep_foo_inc ADD PRIMARY KEY (val1);
ALTER TABLE public.rep_attach1 ADD PRIMARY KEY (val1);
ALTER TABLE public.rep_attach_inc ADD PRIMARY KEY (val1);
ALTER TABLE public.rep_attach_full ADD PRIMARY KEY (val1);
ALTER TABLE public.rep_detach1 ADD PRIMARY KEY (val1);
ALTER TABLE public.rep_detach2 ADD PRIMARY KEY (val1);
ALTER TABLE public.rep_detach22 ADD PRIMARY KEY (val1);
ALTER TABLE public.rep_drop1 ADD PRIMARY KEY (val1);
ALTER TABLE test.rep_foo ADD PRIMARY KEY (val1);

-- LOAD DATA
INSERT INTO observer.subscription (
SELECT b.a, a.a, b.b, b.c, b.d, b.e, b.f FROM 
(SELECT oid FROM pg_authid WHERE rolname = 'syncdbuser') AS a(a),
(VALUES
('public.rep_tab1', 1, 'postgres1', 'SELECT * FROM public.tab1', NULL::timestamptz, NULL),
('public.rep_foo', 6, 'postgres1', 'SELECT * FROM public.foo', NULL::timestamptz, NULL),
('public.rep_bar', 1, 'postgres1', 'SELECT * FROM public.bar', NULL::timestamptz, NULL),
('public.rep_aaa', 1, 'aaa', 'SELECT * FROM public.tab1', NULL::timestamptz, NULL),
('public.rep_bbb', 999, 'postgres1', 'SELECT * FROM public.tab1', NULL::timestamptz, NULL),
('public.rep_ccc', 4, 'postgres1', 'SELECT * FROM public.ccc', NULL::timestamptz, NULL),
('public.rep_ddd', 3, 'postgres1', 'SELECT * FROM public.tab1', NULL::timestamptz, NULL),
('public.rep_eee', 1, 'postgres1', 'SELECT * FROM public.tab1', NULL::timestamptz, NULL),
('public.rep_fff', 15, 'postgres1', 'SELECT * FROM public.fff', NULL::timestamptz, NULL),
('public.rep_ggg', NULL, 'postgres1', 'SELECT * FROM public.ggg', NULL::timestamptz, NULL),
('public.rep_inc1', 6, 'postgres1', 'SELECT * FROM public.inc', NULL::timestamptz, NULL),
('public.rep_inc2', 7, 'postgres1', 'SELECT val1, val1, pk2, pk1, val1, pk2 as a, pk1 as b FROM public.inc', NULL::timestamptz, NULL),
('public.rep_foo_inc', 8, 'postgres1', 'SELECT * FROM public.foo', '2010-01-01 12:34:56'::timestamptz, 'F'),
('public.rep_detach1', 11, 'postgres1', 'SELECT * FROM public.detach1', '2010-01-01 12:34:56'::timestamptz, 'I'),
('public.rep_detach2', 12, 'postgres1', 'SELECT * FROM public.detach2', '2010-01-01 12:34:56'::timestamptz, 'I'),
('public.rep_detach22', NULL, 'postgres1', 'SELECT * FROM public.detach2', '2010-01-01 12:34:56'::timestamptz, 'F'),
('public.rep_drop1', 14, 'postgres1', 'SELECT * FROM public.drop1', '2010-01-01 12:34:56'::timestamptz, 'F'),
('test.rep_foo', 9, 'postgres1', 'SELECT * FROM public.foo', '2010-01-01 12:34:56'::timestamptz, 'F')
) AS b(a,b,c,d,e,f));
DROP TABLE IF EXISTS public.rep_ggg;

INSERT INTO public.rep_tab1 VALUES
(1,1),
(1,2),
(1,3);

INSERT INTO public.rep_inc1 VALUES
(1, 'a', '2010-01-01 00:00:01', 'aaa'),
(2, 'b', '2010-01-01 00:00:02', 'bbb'),
(3, 'c', '2010-01-01 00:00:03', 'ccc'),
(4, 'd', '2010-01-01 00:00:04', 'ddd'),
(5, 'e', '2010-01-01 00:00:05', 'eee');

INSERT INTO public.rep_foo_inc VALUES
(1, 'org', null),
(2, 'org', null),
(3, 'org', null),
(8, 'org', null),
(9, 'org', null),
(10, 'org', null),
(11, 'org', null);
