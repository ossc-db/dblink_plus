-- =============================================================================
-- cleanup
-- =============================================================================
\set ECHO none
SET client_min_messages = warning;

DROP DATABASE IF EXISTS contrib_regression_utf8;
CREATE DATABASE contrib_regression_utf8 ENCODING 'UTF-8' TEMPLATE template0
	 LC_COLLATE='C' LC_CTYPE='C';
ALTER DATABASE contrib_regression_utf8 SET lc_messages TO 'C';
ALTER DATABASE contrib_regression_utf8 SET lc_monetary TO 'C';
ALTER DATABASE contrib_regression_utf8 SET lc_numeric TO 'C';
ALTER DATABASE contrib_regression_utf8 SET lc_time TO 'C';

SET client_min_messages = fatal;
\set ECHO all

-- =============================================================================
-- Prepare section
-- =============================================================================
\c contrib_regression_utf8
CREATE EXTENSION oracle_fdw;
CREATE SERVER ora_server FOREIGN DATA WRAPPER oracle_fdw OPTIONS (dbname 'orcl');
CREATE USER MAPPING FOR PUBLIC SERVER ora_server OPTIONS (user 'oracle_fdw', password 'oracle_fdw');

-- =============================================================================
-- reset result directry
-- =============================================================================
\! rm -rf results/format
\! rm -rf results/func_pushdown
\! rm -rf results/datatype
\! rm -rf results/pushdown
\! rm -rf results/date_op_pushdown
\! rm -rf results/sample

\! mkdir -p results/format
\! mkdir -p results/func_pushdown
\! mkdir -p results/datatype
\! mkdir -p results/pushdown
\! mkdir -p results/date_op_pushdown
\! mkdir -p results/sample

-- =============================================================================
-- common table create
-- =============================================================================
CREATE TABLE t_interval (key integer, val interval);

-- =============================================================================
-- return false function. use it to avoid push downe.
-- =============================================================================
CREATE FUNCTION dummy()
 RETURNS boolean
	AS '
		BEGIN
			RETURN false;
		END;
	'
 LANGUAGE PLPGSQL
 VOLATILE;

-- =============================================================================
-- CREATE FOREIGN TABLE
-- =============================================================================
CREATE FOREIGN TABLE binary_float_real (id integer, val real)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'binary_float_real');
CREATE FOREIGN TABLE binary_double_precision (id integer, val double precision)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'binary_double_precision');
CREATE FOREIGN TABLE number_smallint (id integer, val smallint)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'number_smallint');
CREATE FOREIGN TABLE number_integer (id integer, val integer)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'number_integer');
CREATE FOREIGN TABLE number_bigint (id integer, val bigint)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'number_bigint');
CREATE FOREIGN TABLE number_numeric1 (id integer, val numeric)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'number_numeric1');
CREATE FOREIGN TABLE number_numeric2 (id integer, val numeric)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'number_numeric2');
CREATE FOREIGN TABLE number_numeric3 (id integer, val numeric)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'number_numeric3');
CREATE FOREIGN TABLE float_numeric1 (id integer, val numeric)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'float_numeric1');
CREATE FOREIGN TABLE float_numeric2 (id integer, val numeric)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'float_numeric2');

CREATE FOREIGN TABLE char_char (id integer, val char(2000))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'char_b');
CREATE FOREIGN TABLE char_varchar (id integer, val varchar(2000))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'char_c');
CREATE FOREIGN TABLE char_varchar_ (id integer, val varchar)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'char_b');
CREATE FOREIGN TABLE char_text (id integer, val text)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'char_c');

CREATE FOREIGN TABLE nchar_char (id integer, val char(2000))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'nchar_');
CREATE FOREIGN TABLE nchar_text (id integer, val text)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'nchar_');
CREATE FOREIGN TABLE vc2_char (id integer, val char(4000))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'varchar2_');
CREATE FOREIGN TABLE vc2_vc (id integer, val varchar(4000))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'varchar2_');
CREATE FOREIGN TABLE vc2_vc_b (id integer, val varchar(4000))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'varchar2_b');
CREATE FOREIGN TABLE vc2_text (id integer, val text)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'varchar2_');
CREATE FOREIGN TABLE nvc2_vc (id integer, val varchar(4000))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'nvarchar2_');
CREATE FOREIGN TABLE nvc2_text (id integer, val text)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'nvarchar2_');
CREATE FOREIGN TABLE long_vc (id integer, val varchar(8000))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'long_', max_value_len '8000');
CREATE FOREIGN TABLE long_text (id integer, val text)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'long_', max_value_len '8000');
CREATE FOREIGN TABLE clob_vc (id integer, val varchar(8000))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'clob_');
CREATE FOREIGN TABLE clob_text (id integer, val text)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'clob_');
CREATE FOREIGN TABLE nclob_vc (id integer, val varchar(8000))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'nclob_');
CREATE FOREIGN TABLE nclob_text (id integer, val text)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'nclob_');
CREATE FOREIGN TABLE date_date (id integer, val date)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'date_');
CREATE FOREIGN TABLE date_timestamp (id integer, val timestamp(0))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'date_');
CREATE FOREIGN TABLE ts6_ts (id integer, val timestamp(6))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'timestamp_6');
CREATE FOREIGN TABLE ts9_ts (id integer, val timestamp(6))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'timestamp_9');
CREATE FOREIGN TABLE tstz6_tstz (id integer, val timestamp(6) with time zone)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'timestamptz_6');
CREATE FOREIGN TABLE tstz9_tstz (id integer, val timestamp(6) with time zone)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'timestamptz_9');
CREATE FOREIGN TABLE tsltz6_tstz (id integer, val timestamp(6) with time zone)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'timestampltz_6');
CREATE FOREIGN TABLE tsltz9_tstz (id integer, val timestamp(6) with time zone)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'timestampltz_9');
CREATE FOREIGN TABLE itym_it (id integer, val interval)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'intervalym_');
CREATE FOREIGN TABLE itds6_it (id integer, val interval)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'intervalds_6');
CREATE FOREIGN TABLE itds9_it (id integer, val interval)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'intervalds_9');
CREATE FOREIGN TABLE rowid_text (id integer, val text)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'rowid_');
CREATE FOREIGN TABLE urowid_text (id integer, val text)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'urowid_');
CREATE FOREIGN TABLE raw_bytea (id integer, val bytea)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'raw_');
CREATE FOREIGN TABLE long_raw_bytea (id integer, val bytea)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'long_raw_', max_value_len '8000');
CREATE FOREIGN TABLE blob_bytea (id integer, val bytea)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'blob_');
CREATE FOREIGN TABLE bfile_bytea (id integer, val bytea)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'bfile_');

CREATE FOREIGN TABLE all_type (
	id integer,
	binary_float_real_1			real,
	binary_float_real_2			real,
	binary_double_precision_1	double precision,
	binary_double_precision_2	double precision,
	number_smallint_1			smallint,
	number_smallint_2			smallint,
	number_integer_1			integer,
	number_integer_2			integer,
	number_bigint_1				bigint,
	number_bigint_2				bigint,
	number_numeric1_1			numeric(122, 0),
	number_numeric1_2			numeric(122, 0),
	number_numeric2_1			numeric(127, 127),
	number_numeric2_2			numeric(127, 127),
	number_numeric3_1			numeric,
	number_numeric3_2			numeric,
	float_numeric1_1			numeric,
	float_numeric1_2			numeric,
	float_numeric2_1			numeric,
	float_numeric2_2			numeric,
	char_char_1					char(2000),
	char_char_2					char(2000),
	nchar_char_1				char(2000),
	nchar_char_2				char(2000),
	varchar2_varchar_1			varchar(2000),
	varchar2_varchar_2			varchar(2000),
	nvarchar2_varchar_1			varchar(2000),
	nvarchar2_varchar_2			varchar(2000),
	long_text_1					text,
	--long_text_2					text,
	clob_text_1					text,
	clob_text_2					text,
	nclob_text_1				text,
	nclob_text_2				text,
	date_date_1					date,
	date_date_2					date,
	date_timestamp_1			timestamp(0),
	date_timestamp_2			timestamp(0),
	timestamp6_timestamp_1		timestamp(6),
	timestamp6_timestamp_2		timestamp(6),
	timestamp9_timestamp_1		timestamp(6),
	timestamp9_timestamp_2		timestamp(6),
	timestamptz6_timestamptz_1	timestamp(6) with time zone,
	timestamptz6_timestamptz_2	timestamp(6) with time zone,
	timestamptz9_timestamptz_1	timestamp(6) with time zone,
	timestamptz9_timestamptz_2	timestamp(6) with time zone,
	timestampltz6_timestamptz_1	timestamp(6) with time zone,
	timestampltz6_timestamptz_2	timestamp(6) with time zone,
	timestampltz9_timestamptz_1	timestamp(6) with time zone,
	timestampltz9_timestamptz_2	timestamp(6) with time zone,
	intervalym_interval_1		interval,
	intervalym_interval_2		interval,
	intervalds6_interval_1		interval,
	intervalds6_interval_2		interval,
	intervalds9_interval_1		interval,
	intervalds9_interval_2		interval,
	raw_bytea_1					bytea,
	raw_bytea_2					bytea,
	--long_raw_bytea_1			bytea,
	--long_raw_bytea_2			bytea,
	blob_bytea_1				bytea,
	blob_bytea_2				bytea,
	bfile_bytea_1				bytea,
	bfile_bytea_2				bytea
)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 'all_type');

CREATE FOREIGN TABLE ft1 (
	c1 integer,
	c2 text,
	c3 text,
	c4 timestamp
) SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't1');
CREATE FOREIGN TABLE ft2 (
	c1 integer,
	c2 text,
	c3 text
) SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't2');

-- Numeric Types
CREATE FOREIGN TABLE ft_binary_float (id integer, val1 real, val2 real)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_binary_float');
CREATE FOREIGN TABLE ft_binary_double (id integer, val1 double precision, val2 double precision)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_binary_double');
CREATE FOREIGN TABLE ft_number_sma (id integer, val1 smallint, val2 smallint)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_number_sma');
CREATE FOREIGN TABLE ft_number_int (id integer, val1 integer, val2 integer)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_number_int');
CREATE FOREIGN TABLE ft_number_big (id integer, val1 bigint, val2 bigint)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_number_big');
CREATE FOREIGN TABLE ft_number_num (id integer, val1 numeric, val2 numeric)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_number_num');
CREATE FOREIGN TABLE ft_float (id integer, val1 numeric, val2 numeric)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_float');

-- Character Types
CREATE FOREIGN TABLE ft_char_b (id integer, val1 char(2000), val2 char(2000))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_char_b');
CREATE FOREIGN TABLE ft_char_c (id integer, val1 char(2000), val2 char(2000))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_char_c');
CREATE FOREIGN TABLE ft_nchar (id integer, val1 char(2000), val2 char(2000))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_nchar');

CREATE FOREIGN TABLE ft_varchar2_b_varchar (id integer, val1 varchar(4000), val2 varchar(4000))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_varchar2_b');
CREATE FOREIGN TABLE ft_varchar2_b_text (id integer, val1 text, val2 text)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_varchar2_b');
CREATE FOREIGN TABLE ft_varchar2_c_varchar (id integer, val1 varchar(4000), val2 varchar(4000))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_varchar2_c');
CREATE FOREIGN TABLE ft_varchar2_c_text (id integer, val1 text, val2 text)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_varchar2_c');
CREATE FOREIGN TABLE ft_nvarchar2_varchar (id integer, val1 varchar(4000), val2 varchar(4000))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_nvarchar2');
CREATE FOREIGN TABLE ft_nvarchar2_text (id integer, val1 text, val2 text)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_nvarchar2');

CREATE FOREIGN TABLE ft_long_varchar (id integer, val1 varchar)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_long');
CREATE FOREIGN TABLE ft_long_text (id integer, val1 text)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_long');

CREATE FOREIGN TABLE ft_clob_varchar (id integer, val1 varchar, val2 varchar)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_clob');
CREATE FOREIGN TABLE ft_clob_text (id integer, val1 text, val2 text)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_clob');

CREATE FOREIGN TABLE ft_nclob_varchar (id integer, val1 varchar, val2 varchar)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_nclob');
CREATE FOREIGN TABLE ft_nclob_text (id integer, val1 text, val2 text)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_nclob');

-- Date/Time Types
CREATE FOREIGN TABLE ft_date_date (id integer, val1 date, val2 date)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_date');
CREATE FOREIGN TABLE ft_date_timestamp (id integer, val1 timestamp(6), val2 timestamp(6))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_date');
CREATE FOREIGN TABLE ft_timestamp (id integer, val1 timestamp(6), val2 timestamp(6))
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_timestamp');
CREATE FOREIGN TABLE ft_timestamptz (id integer, val1 timestamp(6) with time zone, val2 timestamp(6) with time zone)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_timestamptz');
CREATE FOREIGN TABLE ft_timestampltz (id integer, val1 timestamp(6) with time zone, val2 timestamp(6) with time zone)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_timestampltz');

CREATE FOREIGN TABLE ft_interval_ym (id integer, val1 interval, val2 interval)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_interval_ym');
CREATE FOREIGN TABLE ft_interval_ds (id integer, val1 interval, val2 interval)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_interval_ds');

-- Binary Data Types
CREATE FOREIGN TABLE ft_bytea (id integer, val1 bytea, val2 bytea)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_bytea');
CREATE FOREIGN TABLE ft_bytea (id integer, val1 bytea, val2 bytea)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_bytea');

CREATE FOREIGN TABLE ft_raw (id integer, val1 bytea, val2 bytea)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_raw');
CREATE FOREIGN TABLE ft_longraw (id integer, val1 bytea)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_longraw');
CREATE FOREIGN TABLE ft_blob (id integer, val1 bytea, val2 bytea)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_blob');
CREATE FOREIGN TABLE ft_bfile (id integer, val1 bytea, val2 bytea)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_bfile');

CREATE FOREIGN TABLE ft_raw_text (id integer, val1 text, val2 text)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_raw');
CREATE FOREIGN TABLE ft_longraw_text (id integer, val1 text)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_longraw');
CREATE FOREIGN TABLE ft_blob_text (id integer, val1 text, val2 text)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_blob');
CREATE FOREIGN TABLE ft_bfile_text (id integer, val1 text, val2 text)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_bfile');

CREATE TABLE rt_interval_ym (id integer, val1 interval, val2 interval);
CREATE TABLE rt_interval_ds (id integer, val1 interval, val2 interval);

CREATE FOREIGN TABLE large_raw (val1 bytea)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_large_raw');
CREATE FOREIGN TABLE large_longraw (val1 bytea)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_large_longraw', max_value_len '10485760');
CREATE FOREIGN TABLE large_blob (val1 bytea)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_large_blob');
CREATE FOREIGN TABLE large_bfile (val1 bytea)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_large_bfile');
CREATE FOREIGN TABLE large_long (val1 text)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_large_long', max_value_len '10485760');
CREATE FOREIGN TABLE large_clob (val1 text)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_large_clob');
CREATE FOREIGN TABLE large_nclob (val1 text)
SERVER ora_server OPTIONS (nspname 'oracle_fdw', relname 't_large_nclob');

-- =============================================================================
-- Oracle initialize
-- =============================================================================
\! rm -rf /tmp/oracle_fdw
\! mkdir -p /tmp/oracle_fdw
\! cp data/*.txt /tmp/oracle_fdw/

\! sqlplus -s system/manager@orcl @sql/init_ora.sql
