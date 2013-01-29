/* contrib/oracle_fdw/oracle_fdw--1.0.sql */

CREATE FUNCTION oracle_fdw_handler()
RETURNS fdw_handler
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FUNCTION oracle_fdw_validator(text[], oid)
RETURNS void
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FOREIGN DATA WRAPPER oracle_fdw
  HANDLER oracle_fdw_handler
  VALIDATOR oracle_fdw_validator;

/* connection management functions and view */
CREATE FUNCTION oracle_fdw_get_connections(out srvid oid, out usesysid oid)
RETURNS SETOF record
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FUNCTION oracle_fdw_disconnect(oid, oid)
RETURNS text
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE VIEW oracle_fdw_connections AS
SELECT c.srvid srvid,
       s.srvname srvname,
       c.usesysid usesysid,
       pg_get_userbyid(c.usesysid) usename
  FROM oracle_fdw_get_connections() c
           JOIN pg_catalog.pg_foreign_server s ON (s.oid = c.srvid);
GRANT SELECT ON oracle_fdw_connections TO public;

CREATE SCHEMA oracle_fdw;
GRANT USAGE ON SCHEMA oracle_fdw TO public;

CREATE TABLE oracle_fdw.pg_routine_mapping (
	rmproc		regprocedure,
	rmserver	oid,
	rmoptions	text[],
	PRIMARY KEY (rmproc, rmserver)
);
GRANT SELECT ON oracle_fdw.pg_routine_mapping TO public;

CREATE SERVER oracle_fdw_template_server FOREIGN DATA WRAPPER oracle_fdw;

INSERT INTO oracle_fdw.pg_routine_mapping
SELECT r.rmproc, s.oid, r.rmoptions
  FROM pg_foreign_server s, (
VALUES
	('concat("any")'::regprocedure, '{format=CONCAT(%s\,%s),nargs=2}'::text[]),
	('length(text)', '{format=LENGTH(%s)}'),
	('length(character)', '{format=LENGTH(RTRIM(%s))}'),
	('char_length(character)', '{format=LENGTH(RTRIM(%s))}'),
	('char_length(text)', '{format=LENGTH(%s)}'),
	('character_length(character)', '{format=LENGTH(RTRIM(%s))}'),
	('character_length(text)', '{format=LENGTH(%s)}'),
	('octet_length(text)', '{format=LENGTHB(%s)}'),
	('octet_length(character)', '{format=LENGTHB(%s)}'),
	('bit_length(text)', '{format=LENGTHB(%s)*8}'),
	('lower(text)', '{format=LOWER(%s)}'),
	('upper(text)', '{format=UPPER(%s)}'),
	('replace(text,text,text)', '{format=REPLACE(%s\,%s\,%s)}'),
	('"substring"(text,integer)', '{format=(CASE WHEN %2$s < 1 THEN SUBSTR(%1$s\,1) ELSE SUBSTR(%1$s\,%2$s) END)}'),
	('"substring"(text,integer,integer)', '{format=(CASE WHEN %2$s < 1 THEN SUBSTR(%1$s\,1\,%2$s + %3$s - 1) ELSE SUBSTR(%1$s\,%2$s\,%3$s) END)}'),
	('substr(text,integer)', '{format=(CASE WHEN %2$s < 1 THEN SUBSTR(%1$s\,1) ELSE SUBSTR(%1$s\,%2$s) END)}'),
	('substr(text,integer,integer)', '{format=(CASE WHEN %2$s < 1 THEN SUBSTR(%1$s\,1\,%2$s + %3$s - 1) ELSE SUBSTR(%1$s\,%2$s\,%3$s) END)}'),
	('translate(text,text,text)', '{format=TRANSLATE(%s\,%s\,%s)}'),
	('btrim(text)', '{format=TRIM(%s)}'),
	('btrim(text,text)', '{format=RTRIM(LTRIM(%1$s\,%2$s)\,%2$s)}'),
	('ltrim(text)', '{format=LTRIM(%s)}'),
	('ltrim(text,text)', '{format=LTRIM(%s\,%s)}'),
	('text(character)', '{format=RTRIM(%s)}'),
	('rtrim(text)', '{format=RTRIM(%s)}'),
	('rtrim(text,text)', '{format=RTRIM(%s\,%s)}'),
	('to_number(text,text)', '{format=TO_NUMBER(%s\,%s)}'),
	('to_date(text,text)', '{format=TO_DATE(%s\,%s)}'),
	('to_char(timestamp with time zone,text)', '{format=TO_CHAR(%s\,%s)}'),
	('to_char(timestamp without time zone,text)', '{format=TO_CHAR(%s\,%s)}'),
	('to_char(bigint,text)', '{format=TO_CHAR(%s\,%s)}'),
	('to_char(integer,text)', '{format=TO_CHAR(%s\,%s)}'),
	('to_char(double precision,text)', '{format=TO_CHAR(%s\,%s)}'),
	('to_char(real,text)', '{format=TO_CHAR(%s\,%s)}'),
	('to_char(numeric,text)', '{format=TO_CHAR(%s\,%s)}'),
	('to_timestamp(text,text)', '{format=TO_TIMESTAMP(%s\,%s)}')
) AS r (rmproc, rmoptions)
 WHERE s.srvname = 'oracle_fdw_template_server'
 ORDER BY rmproc;

ANALYZE oracle_fdw.pg_routine_mapping;
