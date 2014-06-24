SET client_min_messages = warning;
\set ECHO none
\i dblink_plus.sql
\set ECHO all
RESET client_min_messages;
\! sh regress_init.sh
