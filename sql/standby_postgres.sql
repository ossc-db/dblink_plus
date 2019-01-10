-- dblink.query() to test use_xa GUC parameter on Standby Server
BEGIN;
SET dblink_plus.use_xa TO 'on';
SHOW dblink_plus.use_xa;
SELECT * FROM dblink.query('server_postgres6789012345678901234567890123456789012345678901234567890', 'SELECT * FROM dblink.dblink_tbl ORDER BY id') AS t(id integer, value text) ORDER BY id;
COMMIT;
BEGIN;
SET dblink_plus.use_xa TO 'off';
SELECT * FROM dblink.query('server_postgres6789012345678901234567890123456789012345678901234567890', 'SELECT * FROM dblink.dblink_tbl ORDER BY id') AS t(id integer, value text) ORDER BY id;
COMMIT;
