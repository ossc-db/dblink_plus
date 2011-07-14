SET search_path = public;

BEGIN;

----------------------------------------------------------------------------
-- CREATE SCHEMA (mlog)
----------------------------------------------------------------------------
CREATE SCHEMA mlog;

----------------------------------------------------------------------------
-- CREATE TABLES (mlog)
----------------------------------------------------------------------------
----------------------------------------
-- mlog.master
----------------------------------------
CREATE TABLE mlog.master (
	masttbl regclass NOT NULL,
	createuser oid NOT NULL,
	PRIMARY KEY (masttbl)
);
COMMENT ON TABLE mlog.master
	IS 'syncdb (master) : master table information';

----------------------------------------
-- mlog.subscriber
----------------------------------------
CREATE TABLE mlog.subscriber (
	subsid bigserial,
	masttbl regclass NOT NULL,
	attachuser oid NOT NULL,
	description text,
	lasttime timestamptz default current_timestamp,
	lasttype "char" CHECK (lasttype IN ('F', 'I')),
	lastmlogid bigint DEFAULT -1,
	lastcount bigint DEFAULT -1,
	PRIMARY KEY (subsid),
	FOREIGN KEY (masttbl) REFERENCES mlog.master (masttbl) ON DELETE CASCADE
);
COMMENT ON TABLE mlog.subscriber
	IS 'syncdb (master) : subscriber information';

----------------------------------------------------------------------------
-- CREATE VIEWS (mlog)
----------------------------------------------------------------------------
----------------------------------------
-- mlog.v$subscriber
----------------------------------------
CREATE OR REPLACE VIEW mlog.v$subscriber AS
	SELECT
		s.subsid AS subsid,
		n.nspname AS nspname,
		c.relname AS relname,
		quote_ident(n.nspname) || '.' || quote_ident(c.relname) AS masttbl,
		'mlog.mlog$' || c.oid AS mlogname,
		r1.rolname AS createuser,
		r2.rolname AS attachuser,
		s.description AS description,
		s.lasttime AS lasttime,
		s.lasttype AS lasttype,
		s.lastmlogid AS lastmlogid,
		s.lastcount AS lastcount
	FROM mlog.master m
		LEFT OUTER JOIN mlog.subscriber s ON s.masttbl = m.masttbl
		LEFT OUTER JOIN pg_catalog.pg_class c ON m.masttbl = c.oid
		LEFT OUTER JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
		LEFT OUTER JOIN pg_catalog.pg_roles r1 ON r1.oid = m.createuser
		LEFT OUTER JOIN pg_catalog.pg_roles r2 ON r2.oid = s.attachuser;

----------------------------------------------------------------------------
-- CREATE MLOG FUNCTIONS (mlog)
----------------------------------------------------------------------------
----------------------------------------
-- mlog.create_mlog()
----------------------------------------
CREATE OR REPLACE FUNCTION mlog.create_mlog
	(IN schema_name name,
	 IN master_name name) RETURNS void AS
$BODY$
DECLARE
	fullname text;
	master_table regclass;
	mlog_name text;
	attr_num integer;
	trg_func_body text;
	attr_str text;
	create_attr_str text;
	trg_old_attr_str text;
	trg_new_attr_str text;
	trg_update_check_str text;
	trigger_func_name text;
	relinfo_data RECORD;
	create_user name;
	has_sel boolean;
	has_trg boolean;
BEGIN
	fullname := quote_ident(schema_name) || '.' || quote_ident(master_name);
	master_table := fullname::regclass;

	SELECT createuser INTO create_user FROM mlog.master
		WHERE masttbl = master_table;

	IF FOUND THEN
		RAISE EXCEPTION '% was already registered', fullname;
	END IF;

	SELECT attnum INTO attr_num FROM mlog.column_defs(master_table)
		WHERE isprimary = TRUE;

	IF NOT FOUND THEN
		RAISE EXCEPTION '% does not have primary keys', fullname;
	END IF;

	mlog_name := 'mlog$' || master_table::oid;

	/* authority check of master_tbl */
	SELECT has_table_privilege(session_user, master_table, 'SELECT'),
		has_table_privilege(session_user, master_table, 'TRIGGER')
		INTO has_sel, has_trg;

	IF has_sel = FALSE OR has_trg = FALSE THEN
		RAISE EXCEPTION 'permission denied for mlog.create_mlog()';
	END IF;

	attr_str := '';
	create_attr_str := '';
	trg_old_attr_str := '';
	trg_new_attr_str := '';
	trg_update_check_str := '';

	FOR relinfo_data IN
		SELECT attnum, attname, atttypename, isprimary
			FROM mlog.column_defs(master_table)
	LOOP
		IF relinfo_data.isprimary = TRUE THEN
			/* build PK column info string (for create table command) */
			create_attr_str := create_attr_str || ', ' ||
					relinfo_data.attname ||
					' ' || relinfo_data.atttypename || ' NOT NULL';

			/* build PK column name string */
			attr_str := attr_str || ', ' || relinfo_data.attname;

			/* build PK column name string (for trigger function) */
			trg_old_attr_str := trg_old_attr_str || ', ' ||
					'OLD.' || relinfo_data.attname;
			trg_new_attr_str := trg_new_attr_str || ', ' ||
					'NEW.' || relinfo_data.attname;

			/* build value check string (for trigger function) */
			trg_update_check_str := trg_update_check_str ||
					'IF OLD.' || relinfo_data.attname ||
					' <> NEW.' || relinfo_data.attname ||
					' THEN update_key = 1; END IF; ';
		ELSE
			/* build value check string (for trigger function) */
			trg_update_check_str := trg_update_check_str ||
					'IF OLD.' || relinfo_data.attname ||
					' <> NEW.' || relinfo_data.attname ||
					' OR OLD.' || relinfo_data.attname ||
					' IS DISTINCT FROM NEW.' || relinfo_data.attname ||
					' THEN update_value = 1; END IF; ';
		END IF;
	END LOOP;

	SET LOCAL client_min_messages = WARNING;

	/* create mlog table */
	EXECUTE 'CREATE TABLE mlog.' || mlog_name || ' (mlogid BIGSERIAL, ' ||
		'dmltype "char" NOT NULL CHECK (dmltype IN (''I'', ''U'', ''D''))' ||
		create_attr_str || ', PRIMARY KEY (mlogid))';
	EXECUTE 'CREATE INDEX ' || mlog_name || '_idx ON ' ||
		'mlog.' || mlog_name || ' (dmltype' || attr_str || ')';

	/* grant "SELECT" on mlog_table to createuser */
	EXECUTE 'GRANT SELECT ON TABLE mlog.' || mlog_name ||
		' TO ' || quote_ident(session_user);

	trg_func_body := '
---------- function body string start ----------
DECLARE
	update_key integer;
	update_value integer;
BEGIN
	IF TG_OP = ''TRUNCATE'' THEN
		EXECUTE ''TRUNCATE mlog.' || mlog_name || ''';
		UPDATE mlog.subscriber SET lastmlogid = -1 WHERE masttbl = ' || quote_literal(master_table::text) || '::regclass;
	ELSIF TG_OP = ''DELETE'' THEN
		INSERT INTO mlog.' || mlog_name || ' (dmltype ' || attr_str || ') SELECT ''D'' ' || trg_old_attr_str || ';
	ELSIF TG_OP = ''UPDATE'' THEN
		update_key = 0;
		update_value = 0;
		' || trg_update_check_str || '
		IF update_key <> 0 THEN
			INSERT INTO mlog.' || mlog_name || ' (dmltype ' || attr_str || ') SELECT ''D'' ' || trg_old_attr_str || ';
			INSERT INTO mlog.' || mlog_name || ' (dmltype ' || attr_str || ') SELECT ''I'' ' || trg_new_attr_str || ';
		ELSIF update_value <> 0 THEN
			INSERT INTO mlog.' || mlog_name || ' (dmltype ' || attr_str || ') SELECT ''U'' ' || trg_old_attr_str || ';
		END IF;
	ELSIF TG_OP = ''INSERT'' THEN
		INSERT INTO mlog.' || mlog_name || ' (dmltype ' || attr_str || ') SELECT ''I'' ' || trg_new_attr_str || ';
	END IF;
	RETURN NULL;
END;
---------- function body string end ----------
';

	trigger_func_name := 'mlog.' || mlog_name || '_trg_fnc()';

	/* create trigger function */
	EXECUTE 'CREATE OR REPLACE FUNCTION ' ||
		trigger_func_name || ' RETURNS TRIGGER AS ' ||
		quote_literal (trg_func_body) || ' LANGUAGE plpgsql EXTERNAL SECURITY DEFINER;';

	/* create trigger (insert/update/delete) */
	EXECUTE 'CREATE TRIGGER z_' || mlog_name || '_trg_row' ||
		' AFTER INSERT OR UPDATE OR DELETE ON ' || master_table ||
		' FOR EACH ROW EXECUTE PROCEDURE ' || trigger_func_name;

	/* create trigger (truncate) */
	EXECUTE 'CREATE TRIGGER z_' || mlog_name || '_trg_stmt' ||
		' AFTER TRUNCATE ON ' || master_table ||
		' FOR EACH STATEMENT EXECUTE PROCEDURE ' || trigger_func_name;

	RESET client_min_messages;

	/* insert mlog.master */
	INSERT INTO mlog.master (masttbl, createuser)
		VALUES (
			master_table,
			(SELECT oid FROM pg_catalog.pg_roles WHERE rolname = session_user));

	RETURN;
END;
$BODY$ LANGUAGE plpgsql VOLATILE STRICT EXTERNAL SECURITY DEFINER;

----------------------------------------
-- mlog.drop_mlog()
----------------------------------------
CREATE OR REPLACE FUNCTION mlog.drop_mlog
	(IN schema_name name,
	 IN master_name name) RETURNS void AS
$BODY$
DECLARE
	fullname text;
	master_table regclass;
	mlog_name text;
	mlog_table regclass;
	create_user name;
BEGIN
	fullname := quote_ident(schema_name) || '.' || quote_ident(master_name);
	master_table := fullname::regclass;

	SELECT masttbl INTO master_table FROM mlog.master
		WHERE masttbl = master_table;

	IF NOT FOUND THEN
		RAISE EXCEPTION '% is not found in the mlog.master', fullname;
	END IF;

	mlog_name := 'mlog$' || master_table::oid;

	SELECT createuser INTO create_user
		FROM mlog.master
	WHERE masttbl = master_table
		AND createuser = ANY(SELECT oid FROM pg_catalog.pg_roles WHERE rolname = session_user);

	IF NOT FOUND THEN
		RAISE EXCEPTION 'permission denied for mlog.drop_mlog()';
	END IF;

	SET LOCAL client_min_messages = WARNING;

	/* drop trigger function */
	EXECUTE 'DROP FUNCTION mlog.' || mlog_name || '_trg_fnc() CASCADE';

	/* drop mlog table */
	EXECUTE 'DROP TABLE mlog.' || mlog_name;

	RESET client_min_messages;

	/* delete master table info */
	DELETE FROM mlog.master WHERE masttbl = master_table;

	RETURN;
END;
$BODY$ LANGUAGE plpgsql VOLATILE EXTERNAL SECURITY DEFINER;

----------------------------------------
-- mlog.purge_mlog()
----------------------------------------
CREATE OR REPLACE FUNCTION mlog.purge_mlog
	( ) RETURNS void AS
$BODY$
DECLARE
	delete_count bigint;
BEGIN
	SELECT sum(mlog.purge_mlog(n.nspname, c.relname)) INTO delete_count
		FROM mlog.master m
			JOIN pg_catalog.pg_class c ON m.masttbl = c.oid
			JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace;

	RETURN;
END;
$BODY$ LANGUAGE plpgsql VOLATILE EXTERNAL SECURITY DEFINER;

----------------------------------------
-- mlog.purge_mlog()
----------------------------------------
CREATE OR REPLACE FUNCTION mlog.purge_mlog
	(IN schema_name name,
	 IN master_name name) RETURNS void AS
$BODY$
DECLARE
	fullname text;
	master_table regclass;
	last_logid bigint;
	subs_id bigint;
	create_user name;
	attach_user name;
	delete_count bigint;
BEGIN
	fullname := quote_ident(schema_name) || '.' || quote_ident(master_name);
	master_table := fullname::regclass;

	SELECT masttbl INTO master_table FROM mlog.master
		WHERE masttbl = master_table;

	IF NOT FOUND THEN
		RAISE EXCEPTION '% is not found in the mlog.master', fullname;
	END IF;

	/* accept user */
	SELECT m.createuser, s.attachuser INTO create_user, attach_user
		FROM mlog.master m FULL JOIN mlog.subscriber s ON m.masttbl = s.masttbl
	WHERE m.masttbl = master_table
		AND (m.createuser = ANY(SELECT oid FROM pg_catalog.pg_roles WHERE rolname = session_user)
		OR s.attachuser = ANY(SELECT oid FROM pg_catalog.pg_roles WHERE rolname = session_user));

	IF NOT FOUND THEN
		/* RAISE WARNING 'permission denied for mlog.purge_mlog()'; */
		RETURN;
	END IF;

	SELECT min(lastmlogid) INTO last_logid
		FROM mlog.subscriber WHERE masttbl = master_table AND lastmlogid >= 0;

	IF NOT FOUND OR last_logid IS NULL THEN
		/* RAISE WARNING '% is not found in the mlog.subscriber', master_table; */
		RETURN;
	END IF;

	/* delete mlog */
	EXECUTE 'DELETE FROM ' || 'mlog.mlog$' || master_table::oid ||
		' WHERE mlogid <= $1' USING last_logid;
	GET DIAGNOSTICS delete_count = ROW_COUNT;

	RETURN;
END;
$BODY$ LANGUAGE plpgsql VOLATILE EXTERNAL SECURITY DEFINER;

----------------------------------------
-- mlog.subscribe_mlog()
----------------------------------------
CREATE OR REPLACE FUNCTION mlog.subscribe_mlog
	(IN schema_name name,
	 IN master_name name,
	 IN subscribe_info text DEFAULT NULL,
	 OUT subscribe_id bigint) AS
$BODY$
DECLARE
	fullname text;
	master_table regclass;
	has_sel boolean;
BEGIN
	fullname := quote_ident(schema_name) || '.' || quote_ident(master_name);
	master_table := fullname::regclass;

	SELECT masttbl INTO master_table FROM mlog.master
		WHERE masttbl = master_table;

	IF NOT FOUND THEN
		RAISE EXCEPTION '% is not found in the mlog.master', fullname;
	END IF;

	/* authority check of master_tbl */
	SELECT has_table_privilege(session_user, master_table, 'SELECT')
		INTO has_sel;

	IF has_sel = FALSE THEN
		RAISE EXCEPTION 'permission denied for mlog.subscribe_mlog()';
	END IF;

	/* insert mlog.subscriber */
	INSERT INTO mlog.subscriber
		(masttbl, attachuser, description, lasttime)
		VALUES (
			master_table,
			(SELECT oid FROM pg_catalog.pg_roles WHERE rolname = session_user),
			subscribe_info,
			NULL)
	RETURNING subsid INTO subscribe_id;

	/* grant "SELECT" on mlog_table to attachuser */
	EXECUTE 'GRANT SELECT ON TABLE ' || 'mlog.mlog$' || master_table::oid ||
		' TO ' || quote_ident(session_user);

	RETURN;
END;
$BODY$ LANGUAGE plpgsql VOLATILE EXTERNAL SECURITY DEFINER;

----------------------------------------
-- mlog.unsubscribe_mlog()
----------------------------------------

CREATE OR REPLACE FUNCTION mlog.unsubscribe_mlog
	(IN subscribe_id bigint) RETURNS void AS
$BODY$
DECLARE
	attach_user name;
	master_table regclass;
BEGIN
	SELECT masttbl INTO master_table
		FROM mlog.subscriber
			WHERE subsid = subscribe_id;
	IF FOUND THEN
		SELECT attachuser INTO attach_user
			FROM mlog.subscriber
		WHERE subsid = subscribe_id
			AND attachuser = ANY(SELECT oid FROM pg_catalog.pg_roles WHERE rolname = session_user);

		IF NOT FOUND THEN
			RAISE EXCEPTION 'permission denied for mlog.unsubscribe_mlog()';
		END IF;

		/* delete mlog.subscriber */
		DELETE FROM mlog.subscriber WHERE subsid = subscribe_id;
		IF FOUND THEN
			RETURN;
		END IF;
	END IF;

	RAISE EXCEPTION 'subsid(%) is not found in the mlog.subscriber', subscribe_id;
END;
$BODY$ LANGUAGE plpgsql VOLATILE STRICT EXTERNAL SECURITY DEFINER;

----------------------------------------
-- mlog.set_subscriber()
----------------------------------------
CREATE OR REPLACE FUNCTION mlog.set_subscriber
	(IN subscribe_id bigint,
	 IN last_type char(1),
	 IN last_mlogid bigint,
	 IN last_count bigint) RETURNS void AS
$BODY$
DECLARE
	attach_user name;
BEGIN
	/* update mlog.subscriber */
	UPDATE mlog.subscriber
	SET
		lasttime = current_timestamp,
		lasttype = last_type,
		lastmlogid = last_mlogid,
		lastcount = last_count
	WHERE subsid = subscribe_id
		AND attachuser = ANY (SELECT oid FROM pg_catalog.pg_roles WHERE rolname = session_user);

	IF NOT FOUND THEN
		RAISE EXCEPTION 'subsid(%) is not found in the mlog.subscriber', subscribe_id;
	END IF;
END;
$BODY$ LANGUAGE plpgsql VOLATILE EXTERNAL SECURITY DEFINER;

----------------------------------------
-- mlog.column_defs
----------------------------------------
CREATE OR REPLACE FUNCTION mlog.column_defs
	(IN rel regclass,
	 OUT attnum smallint,
	 OUT attname text,
	 OUT atttypename text,
	 OUT isprimary boolean) RETURNS SETOF RECORD AS
$BODY$
DECLARE
	rel_data RECORD;
BEGIN
	FOR rel_data IN
		SELECT a.attnum AS num, quote_ident(a.attname) AS name,
			pg_catalog.format_type(a.atttypid, a.atttypmod) AS typename,
			CASE ct.contype WHEN 'p' THEN TRUE::boolean ELSE NULL::boolean END AS primary
		FROM pg_catalog.pg_class c
			JOIN pg_catalog.pg_attribute a ON a.attrelid = c.oid
			LEFT JOIN pg_catalog.pg_constraint ct ON ct.conrelid = c.oid
				AND a.attnum = ANY (ct.conkey)
		WHERE a.attnum > 0 AND c.oid = rel
			ORDER BY a.attnum ASC
	LOOP
		attnum := rel_data.num;
		attname := rel_data.name;
		atttypename := rel_data.typename;
		isprimary := rel_data.primary;

		RETURN NEXT;
	END LOOP;

	RETURN;
END;
$BODY$ LANGUAGE plpgsql STABLE STRICT;

----------------------------------------------------------------------------
-- GRANT/REVOKE (mlog)
----------------------------------------------------------------------------
----------------------------------------
-- GRANT
----------------------------------------
GRANT USAGE ON SCHEMA mlog TO PUBLIC;

GRANT SELECT ON TABLE mlog.master TO PUBLIC;
GRANT SELECT ON TABLE mlog.subscriber TO PUBLIC;
GRANT SELECT ON mlog.v$subscriber TO PUBLIC;

GRANT EXECUTE ON FUNCTION mlog.create_mlog(name, name) TO PUBLIC;
GRANT EXECUTE ON FUNCTION mlog.drop_mlog(name, name) TO PUBLIC;
GRANT EXECUTE ON FUNCTION mlog.purge_mlog() TO PUBLIC;
GRANT EXECUTE ON FUNCTION mlog.purge_mlog(name, name) TO PUBLIC;
GRANT EXECUTE ON FUNCTION mlog.subscribe_mlog(name, name, text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION mlog.unsubscribe_mlog(bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION mlog.set_subscriber(bigint, char(1), bigint, bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION mlog.column_defs(regclass) TO PUBLIC;

----------------------------------------
-- REVOKE
----------------------------------------

----------------------------------------------------------------------------
--
----------------------------------------------------------------------------

COMMIT;
