/* pgsql_fdw/pgsql_fdw--1.0.sql */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION pgsql_fdw" to load this file. \quit

CREATE FUNCTION pgsql_fdw_handler()
RETURNS fdw_handler
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FUNCTION pgsql_fdw_validator(text[], oid)
RETURNS void
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FOREIGN DATA WRAPPER pgsql_fdw
  HANDLER pgsql_fdw_handler
  VALIDATOR pgsql_fdw_validator;

/* connection management functions and view */
CREATE FUNCTION pgsql_fdw_get_connections(out srvid oid, out usesysid oid)
RETURNS SETOF record
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FUNCTION pgsql_fdw_disconnect(oid, oid)
RETURNS text
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE VIEW pgsql_fdw_connections AS
SELECT c.srvid srvid,
       s.srvname srvname,
       c.usesysid usesysid,
       pg_get_userbyid(c.usesysid) usename
  FROM pgsql_fdw_get_connections() c
           JOIN pg_catalog.pg_foreign_server s ON (s.oid = c.srvid);

GRANT SELECT ON pgsql_fdw_connections TO public;

