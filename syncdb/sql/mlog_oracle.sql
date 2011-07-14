----------------------------------------------------------------------------
-- CREATE SCHEMA (mlog)
----------------------------------------------------------------------------
CREATE USER mlog IDENTIFIED BY mlog;
GRANT RESOURCE TO mlog;
GRANT SELECT ANY DICTIONARY To mlog;
GRANT SELECT ANY TABLE TO mlog;
GRANT CREATE ANY TRIGGER TO mlog;
GRANT CREATE SEQUENCE TO mlog;
GRANT CREATE TABLE TO mlog;

----------------------------------------------------------------------------
-- CREATE TABLES (mlog)
----------------------------------------------------------------------------
----------------------------------------
-- mlog.master
----------------------------------------
CREATE TABLE mlog.master (
	masttbl number NOT NULL,
	nspname varchar2(30) NOT NULL,
	relname varchar2(30) NOT NULL,
	createuser varchar2(30) NOT NULL,
	PRIMARY KEY (masttbl),
	UNIQUE(nspname, relname)
);
COMMENT ON TABLE mlog.master
	IS 'syncdb (master) : master table information';

----------------------------------------
-- mlog.subscriber
----------------------------------------
CREATE TABLE mlog.subscriber (
	subsid number NOT NULL,
	masttbl number NOT NULL,
	attachuser varchar2(30) NOT NULL,
	description varchar2(4000),
	lasttime timestamp with time zone DEFAULT SYSTIMESTAMP,
	lasttype char CHECK (lasttype IN ('F', 'I')),
	lastmlogid number DEFAULT -1,
	lastcount number DEFAULT -1,
	PRIMARY KEY (subsid),
	FOREIGN KEY (masttbl) REFERENCES mlog.master (masttbl) ON DELETE CASCADE
) INITRANS 255;
COMMENT ON TABLE mlog.subscriber
	IS 'syncdb (master) : subscriber information';

----------------------------------------------------------------------------
-- CREATE SEQUENCE (mlog)
----------------------------------------------------------------------------
----------------------------------------
-- mlog.master
----------------------------------------
CREATE SEQUENCE mlog.master_masttbl_seq NOCYCLE NOCACHE;

----------------------------------------
-- mlog.subscriber
----------------------------------------
CREATE SEQUENCE mlog.subscriber_subsid_seq NOCYCLE NOCACHE;

----------------------------------------------------------------------------
-- CREATE TRIGGER (mlog)
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- CREATE VIEWS (mlog)
----------------------------------------------------------------------------
----------------------------------------
-- mlog.v$subscriber
----------------------------------------
CREATE OR REPLACE VIEW mlog.v$subscriber AS
	SELECT
		s.subsid,
		u.username AS nspname,
		t.table_name AS relname,
		'"' || t.owner || '"."' || t.table_name || '"' AS masttbl,
		'MLOG.MLOG$' || m.masttbl AS mlogname,
		u1.username AS createuser,
		u2.username AS attachuser,
		s.description AS description,
		s.lasttime AS lasttime,
		s.lasttype AS lasttype,
		s.lastmlogid AS lastmlogid,
		s.lastcount AS lastcount
	FROM mlog.master m
		LEFT OUTER JOIN mlog.subscriber s ON s.masttbl = m.masttbl
		LEFT OUTER JOIN all_users u ON u.username = m.nspname
		LEFT OUTER JOIN all_tables t ON t.owner = m.nspname AND
										t.table_name = m.relname
		LEFT OUTER JOIN all_users u1 ON u1.username = m.createuser
		LEFT OUTER JOIN all_users u2 ON u2.username = s.attachuser;

----------------------------------------
-- mlog.v$role_privileges
----------------------------------------
CREATE OR REPLACE VIEW mlog.v$role_privileges AS
	SELECT granted_role FROM (
		SELECT null grantee, username granted_role FROM dba_users
			WHERE username = user
		UNION SELECT grantee, granted_role FROM dba_role_privs
		UNION SELECT grantee, privilege FROM dba_sys_privs
		UNION SELECT grantee, privilege || ' ' || owner || '.' || table_name FROM dba_tab_privs
	) START WITH grantee IS NULL
		CONNECT By grantee = PRIOR granted_role;

----------------------------------------------------------------------------
-- CREATE MLOG FUNCTIONS (mlog)
----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE mlog.mlog AUTHID DEFINER AS
	TYPE column_defs_type IS RECORD
		(attnum number, attname varchar2(32), atttypename varchar2(4000), isprimary char);
	TYPE column_defs_type_array IS TABLE OF column_defs_type;

	PROCEDURE create_mlog(schema_name IN varchar2, master_name IN varchar2);
	PROCEDURE drop_mlog(schema_name IN varchar2, master_name IN varchar2);
	PROCEDURE purge_mlog;
	PROCEDURE purge_mlog(schema_name IN varchar2, master_name IN varchar2);
	PROCEDURE subscribe_mlog(schema_name IN varchar2, master_name IN varchar2, subscribe_info IN varchar2, subscribe_id OUT number);
	PROCEDURE unsubscribe_mlog(subscribe_id IN number);
	PROCEDURE set_subscriber(subscribe_id IN number, last_type IN char, last_mlogid IN number, last_count IN number);
	PROCEDURE log_reset(schema_name IN varchar2, master_name IN varchar2, masttbl_id IN number);
	FUNCTION column_defs(nspname IN varchar2, relname IN varchar2)
		RETURN column_defs_type_array PIPELINED;
END;
/

CREATE OR REPLACE PACKAGE BODY mlog.mlog AS
----------------------------------------
-- mlog.execute_ddl()
----------------------------------------
PROCEDURE execute_ddl
	(ddl_str IN varchar2)
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
	EXECUTE IMMEDIATE ddl_str;
	COMMIT;
END;

----------------------------------------
-- mlog.create_mlog()
----------------------------------------
PROCEDURE create_mlog
	(schema_name IN varchar2,
	 master_name IN varchar2)
IS
	table_space varchar2(30);
	fullname varchar2(80);
	masttbl_id number;
	mlog_name varchar2(80);
	wk_count number;
	mlog_seq_name varchar2(80);
	trigger_row_name varchar2(80);
	trigger_stmt_name varchar2(80);
	trg_row_body varchar2(32767);
	trg_stmt_body varchar2(32767);
	attr_str varchar2(32767);
	create_attr_str varchar2(32767);
	trg_old_attr_str varchar2(32767);
	trg_new_attr_str varchar2(32767);
	trg_update_check_str varchar2(32767);
BEGIN
	fullname := '"' || schema_name || '"."' || master_name || '"';
	BEGIN
		SELECT tablespace_name INTO table_space FROM all_tables
			WHERE owner = schema_name AND table_name = master_name;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RAISE_APPLICATION_ERROR(-20000, fullname || ' is not found');
		WHEN OTHERS THEN
			RAISE;
	END;

	BEGIN
		SELECT masttbl INTO masttbl_id
			FROM mlog.master
				WHERE nspname = schema_name AND relname = master_name;

		IF SQL%ROWCOUNT > 0 THEN
			RAISE_APPLICATION_ERROR(-20000, fullname || ' was already registered');
		END IF;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
		WHEN OTHERS THEN
			RAISE;
	END;

	SELECT count(attname) INTO wk_count FROM TABLE(mlog.column_defs(schema_name, master_name))
		WHERE isprimary = 'y';

	IF wk_count = 0 THEN
		RAISE_APPLICATION_ERROR(-20000, fullname || ' does not have primary keys');
	END IF;

	SELECT master_masttbl_seq.NEXTVAL INTO masttbl_id FROM DUAL;

	mlog_name := 'mlog$' || masttbl_id;
	mlog_seq_name := mlog_name || '_mlogid_seq';

	/* authority check of master_tbl */
	/* XXX */
	IF user = schema_name THEN
		SELECT count(*) INTO wk_count FROM mlog.v$role_privileges
			WHERE granted_role = 'CREATE TRIGGER' OR granted_role = 'CREATE ANY TRIGGER';

		IF wk_count = 0 THEN
			RAISE_APPLICATION_ERROR(-20000, 'permission denied for mlog.create_mlog()');
		END IF;
	ELSE
		SELECT count(*) INTO wk_count FROM mlog.v$role_privileges
			WHERE granted_role = 'CREATE ANY TRIGGER';

		IF wk_count = 0 THEN
			RAISE_APPLICATION_ERROR(-20000, 'permission denied for mlog.create_mlog()');
		END IF;

		SELECT count(*) INTO wk_count FROM mlog.v$role_privileges
			WHERE granted_role = 'SELECT ANY TABLE' OR
			granted_role = 'SELECT ' || schema_name || '.' || master_name;

		IF wk_count = 0 THEN
			SELECT count(*) INTO wk_count FROM dba_tab_privs
				WHERE owner = schema_name AND table_name = master_name AND
					(grantee = 'PUBLIC' OR grantee = user) AND PRIVILEGE = 'SELECT';

			IF wk_count = 0 THEN
				RAISE_APPLICATION_ERROR(-20000, 'permission denied for mlog.create_mlog()');
			END IF;
		END IF;
	END IF;

	attr_str := '';
	create_attr_str := '';
	trg_old_attr_str := '';
	trg_new_attr_str := '';
	trg_update_check_str := '';

	FOR relinfo_data IN
		(SELECT attnum, attname, atttypename, isprimary
			FROM TABLE(mlog.column_defs(schema_name, master_name)))
	LOOP
		IF relinfo_data.isprimary = 'y' THEN
			/* build PK column info string (for create table command) */
			create_attr_str := create_attr_str || ', ' ||
					relinfo_data.attname ||
					' ' || relinfo_data.atttypename || ' NOT NULL';

			/* build PK column name string */
			attr_str := attr_str || ', ' || relinfo_data.attname;

			/* build PK column name string (for trigger function) */
			trg_old_attr_str := trg_old_attr_str || ', ' ||
					':OLD.' || relinfo_data.attname;
			trg_new_attr_str := trg_new_attr_str || ', ' ||
					':NEW.' || relinfo_data.attname;

			/* build value check string (for trigger function) */
			trg_update_check_str := trg_update_check_str ||
					'IF :OLD.' || relinfo_data.attname ||
					' <> :NEW.' || relinfo_data.attname ||
					' THEN update_key := 1; END IF; ';
		ELSE
			/* build value check string (for trigger function) */
			trg_update_check_str := trg_update_check_str ||
					'IF :OLD.' || relinfo_data.attname ||
					' <> :NEW.' || relinfo_data.attname ||
					' OR (:OLD.' || relinfo_data.attname ||
					' IS NULL AND :NEW.' || relinfo_data.attname ||
					' IS NOT NULL) OR (:OLD.' || relinfo_data.attname ||
					' IS NOT NULL AND :NEW.' || relinfo_data.attname ||
					' IS NULL) THEN update_value := 1; END IF; ';
		END IF;
	END LOOP;

	BEGIN
		/* create mlog table */
		mlog.execute_ddl('CREATE TABLE ' || 'mlog.' || mlog_name ||
			' (mlogid number, ' ||
			'dmltype char(1) NOT NULL CHECK (dmltype IN (''I'', ''U'', ''D''))' ||
			create_attr_str || ', PRIMARY KEY (mlogid))');
	EXCEPTION
		WHEN OTHERS THEN
			mlog.execute_ddl('DROP TABLE ' || 'mlog.' || mlog_name || ' CASCADE CONSTRAINTS');
			RAISE;
	END;

	BEGIN
		/* create index */
		mlog.execute_ddl('CREATE INDEX ' || 'mlog.' || mlog_name || '_idx ON ' ||
			'mlog.' || mlog_name || ' (dmltype' || attr_str || ')');
	EXCEPTION
		WHEN OTHERS THEN
			mlog.execute_ddl('DROP TABLE ' || 'mlog.' || mlog_name || ' CASCADE CONSTRAINTS');
			RAISE;
	END;

	BEGIN
		/* create sequence */
		mlog.execute_ddl('CREATE SEQUENCE mlog.' || mlog_seq_name || ' NOCYCLE NOCACHE');
	EXCEPTION
		WHEN OTHERS THEN
			mlog.execute_ddl('DROP TABLE ' || 'mlog.' || mlog_name || ' CASCADE CONSTRAINTS');
			mlog.execute_ddl('DROP SEQUENCE mlog.' || mlog_seq_name);
			RAISE;
	END;

	BEGIN
		/* grant "SELECT" on mlog_table to createuser */
		mlog.execute_ddl('GRANT SELECT ON mlog.' || mlog_name || ' TO "' || user || '"');
	EXCEPTION
		WHEN OTHERS THEN
			mlog.execute_ddl('DROP TABLE ' || 'mlog.' || mlog_name || ' CASCADE CONSTRAINTS');
			mlog.execute_ddl('DROP SEQUENCE mlog.' || mlog_seq_name);
			RAISE;
	END;

	trigger_row_name := 'mlog.z_' || mlog_name || '_trg_row';
	trigger_stmt_name := 'mlog.z_' || mlog_name || '_trg_stmt';

	trg_row_body := '
---------- function body string start ----------
DECLARE
	update_key number(1);
	update_value number(1);
	mlog_id number;
BEGIN
	IF (DELETING) THEN
		SELECT ' || mlog_seq_name || '.NEXTVAL INTO mlog_id FROM DUAL;
		INSERT INTO mlog.' || mlog_name || ' (mlogid, dmltype ' || attr_str || ') SELECT mlog_id, ''D'' ' || trg_old_attr_str || ' FROM DUAL;
	ELSIF (UPDATING) THEN
		update_key := 0;
		update_value := 0;
		' || trg_update_check_str || '
		IF update_key <> 0 THEN
			SELECT ' || mlog_seq_name || '.NEXTVAL INTO mlog_id FROM DUAL;
			INSERT INTO mlog.' || mlog_name || ' (mlogid, dmltype ' || attr_str || ') SELECT mlog_id, ''D'' ' || trg_old_attr_str || ' FROM DUAL;
			SELECT ' || mlog_seq_name || '.NEXTVAL INTO mlog_id FROM DUAL;
			INSERT INTO mlog.' || mlog_name || ' (mlogid, dmltype ' || attr_str || ') SELECT mlog_id, ''I'' ' || trg_new_attr_str || ' FROM DUAL;
		ELSIF update_value <> 0 THEN
			SELECT ' || mlog_seq_name || '.NEXTVAL INTO mlog_id FROM DUAL;
			INSERT INTO mlog.' || mlog_name || ' (mlogid, dmltype ' || attr_str || ') SELECT mlog_id, ''U'' ' || trg_old_attr_str || ' FROM DUAL;
		END IF;
	ELSIF (INSERTING) THEN
		SELECT ' || mlog_seq_name || '.NEXTVAL INTO mlog_id FROM DUAL;
		INSERT INTO mlog.' || mlog_name || ' (mlogid, dmltype ' || attr_str || ') SELECT mlog_id, ''I'' ' || trg_new_attr_str || ' FROM DUAL;
	END IF;
END;
---------- function body string end ----------
';

	trg_stmt_body := '
---------- function body string start ----------
DECLARE
BEGIN
	IF ora_dict_obj_type = ''TABLE'' AND ora_dict_obj_name = ' || DBMS_ASSERT.ENQUOTE_LITERAL(master_name) || ' THEN
		mlog.log_reset(' || DBMS_ASSERT.ENQUOTE_LITERAL(schema_name) || ', ' || DBMS_ASSERT.ENQUOTE_LITERAL(master_name) || ', ' || masttbl_id || ');
	END IF;
END;
---------- function body string end ----------
';

	BEGIN
		/* create trigger (insert/update/delete) */
		mlog.execute_ddl('CREATE OR REPLACE TRIGGER ' || trigger_row_name ||
			' AFTER INSERT OR UPDATE OR DELETE ON ' || fullname ||
			' FOR EACH ROW ' || trg_row_body);
	EXCEPTION
		WHEN OTHERS THEN
			mlog.execute_ddl('DROP TABLE ' || 'mlog.' || mlog_name || ' CASCADE CONSTRAINTS');
			mlog.execute_ddl('DROP SEQUENCE mlog.' || mlog_seq_name);
			mlog.execute_ddl('DROP TRIGGER ' || trigger_row_name);
			RAISE;
	END;

	BEGIN
		/* create trigger (truncate) */
		mlog.execute_ddl('CREATE OR REPLACE TRIGGER ' || trigger_stmt_name ||
			' AFTER TRUNCATE ON "' || schema_name || '".SCHEMA ' || trg_stmt_body);

		/* insert mlog.master */
		INSERT INTO mlog.master (masttbl, nspname, relname, createuser)
			VALUES (masttbl_id, schema_name, master_name, user);
	EXCEPTION
		WHEN OTHERS THEN
			mlog.execute_ddl('DROP TABLE ' || 'mlog.' || mlog_name || ' CASCADE CONSTRAINTS');
			mlog.execute_ddl('DROP SEQUENCE mlog.' || mlog_seq_name);
			mlog.execute_ddl('DROP TRIGGER ' || trigger_row_name);
			mlog.execute_ddl('DROP TRIGGER ' || trigger_stmt_name);
			RAISE;
	END;
END;

----------------------------------------
-- mlog.drop_mlog()
----------------------------------------
PROCEDURE drop_mlog
	(schema_name IN varchar2,
	 master_name IN varchar2)
IS
	table_space varchar2(30);
	fullname varchar2(80);
	masttbl_id number;
	create_user varchar2(30);
	mlog_name varchar2(30);
BEGIN
	fullname := '"' || schema_name || '"."' || master_name || '"';
	BEGIN
		SELECT tablespace_name INTO table_space FROM all_tables
			WHERE owner = schema_name AND table_name = master_name;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RAISE_APPLICATION_ERROR(-20000, fullname || ' is not found');
		WHEN OTHERS THEN
			RAISE;
	END;

	BEGIN
		SELECT masttbl, createuser INTO masttbl_id, create_user
			FROM mlog.master
				WHERE nspname = schema_name AND relname = master_name;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RAISE_APPLICATION_ERROR(-20000, fullname || ' is not found in the mlog.master');
		WHEN OTHERS THEN
			RAISE;
	END;

	IF user <> create_user THEN
		RAISE_APPLICATION_ERROR(-20000, 'permission denied for mlog.drop_mlog()');
	END IF;

	mlog_name := 'mlog$' || masttbl_id;

	BEGIN
		/* drop trigger */
		mlog.execute_ddl('DROP TRIGGER mlog.z_' || mlog_name || '_trg_row');
		mlog.execute_ddl('DROP TRIGGER mlog.z_' || mlog_name || '_trg_stmt');

		/* drop mlog table */
		mlog.execute_ddl('DROP TABLE mlog.' || mlog_name);

		/* drop mlog sequence */
		mlog.execute_ddl('DROP SEQUENCE mlog.' || mlog_name || '_mlogid_seq');

		/* delete master table info */
		DELETE FROM mlog.master WHERE masttbl = masttbl_id;

	EXCEPTION
		WHEN OTHERS THEN
			RAISE;
	END;
END;

----------------------------------------
-- mlog.purge_mlog()
----------------------------------------
PROCEDURE purge_mlog
IS
BEGIN
	FOR info_data IN
		(SELECT nspname, relname FROM mlog.master)
	LOOP
		mlog.purge_mlog(info_data.nspname, info_data.relname);
	END LOOP;
END;

----------------------------------------
-- mlog.purge_mlog()
----------------------------------------
PROCEDURE purge_mlog
	(schema_name IN varchar2,
	 master_name IN varchar2)
IS
	table_space varchar2(30);
	fullname varchar2(80);
	masttbl_id number;
	accept_users number;
	last_logid number;
	delete_count number;
BEGIN
	fullname := '"' || schema_name || '"."' || master_name || '"';
	BEGIN
		SELECT tablespace_name INTO table_space FROM all_tables
			WHERE owner = schema_name AND table_name = master_name;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RAISE_APPLICATION_ERROR(-20000, fullname || ' is not found');
		WHEN OTHERS THEN
			RAISE;
	END;

	BEGIN
		SELECT masttbl INTO masttbl_id
			FROM mlog.master
				WHERE nspname = schema_name AND relname = master_name;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RAISE_APPLICATION_ERROR(-20000, fullname || ' is not found in the mlog.master');
		WHEN OTHERS THEN
			RAISE;
	END;

	/* accept user */
	SELECT count(*) INTO accept_users
		FROM mlog.master m FULL JOIN mlog.subscriber s ON m.masttbl = s.masttbl
	WHERE m.masttbl = masttbl_id
		AND (m.createuser = user OR s.attachuser = user);

	IF accept_users = 0 THEN
		RETURN;
	END IF;

	BEGIN
		SELECT min(lastmlogid) INTO last_logid
			FROM mlog.subscriber WHERE masttbl = masttbl_id AND lastmlogid >= 0;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RETURN;
		WHEN OTHERS THEN
			RAISE;
	END;

	IF last_logid IS NULL THEN
		RETURN;
	END IF;

	/* delete mlog */
	EXECUTE IMMEDIATE 'DELETE FROM mlog.mlog$' || masttbl_id ||
		' WHERE mlogid <= :last_logid' USING last_logid;

	delete_count := SQL%ROWCOUNT;
END;

----------------------------------------
-- mlog.subscribe_mlog()
----------------------------------------
PROCEDURE subscribe_mlog
	(schema_name IN varchar2,
	 master_name IN varchar2,
	 subscribe_info IN varchar2,
	 subscribe_id OUT number)
IS
	table_space varchar2(30);
	fullname varchar2(80);
	masttbl_id number;
	wk_count number;
BEGIN
	fullname := '"' || schema_name || '"."' || master_name || '"';
	BEGIN
		SELECT tablespace_name INTO table_space FROM all_tables
			WHERE owner = schema_name AND table_name = master_name;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RAISE_APPLICATION_ERROR(-20000, fullname || ' is not found');
		WHEN OTHERS THEN
			RAISE;
	END;

	BEGIN
		SELECT masttbl INTO masttbl_id
			FROM mlog.master
				WHERE nspname = schema_name AND relname = master_name;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RAISE_APPLICATION_ERROR(-20000, fullname || ' is not found in the mlog.master');
		WHEN OTHERS THEN
			RAISE;
	END;

	IF user != schema_name THEN
		SELECT count(*) INTO wk_count FROM mlog.v$role_privileges
			WHERE granted_role = 'SELECT ANY TABLE' OR
			granted_role = 'SELECT ' || schema_name || '.' || master_name;

		IF wk_count = 0 THEN
			SELECT count(*) INTO wk_count FROM dba_tab_privs
				WHERE owner = schema_name AND table_name = master_name AND
					(grantee = 'PUBLIC' OR grantee = user) AND PRIVILEGE = 'SELECT';

			IF wk_count = 0 THEN
				RAISE_APPLICATION_ERROR(-20000, 'permission denied for mlog.subscribe_mlog()');
			END IF;
		END IF;
	END IF;

	BEGIN
		/* grant "SELECT" on mlog_table to attachuser */
		mlog.execute_ddl('GRANT SELECT ON mlog.mlog$' || masttbl_id ||
							' TO "' || user || '"');
	EXCEPTION
		WHEN OTHERS THEN
			RAISE;
	END;

	SELECT subscriber_subsid_seq.NEXTVAL INTO subscribe_id FROM DUAL;

	/* insert mlog.subscriber */
	INSERT INTO mlog.subscriber
		(subsid, masttbl, attachuser, description, lasttime)
		VALUES (
			subscribe_id,
			masttbl_id,
			user,
			subscribe_info,
			NULL);
END;

----------------------------------------
-- mlog.unsubscribe_mlog()
----------------------------------------
PROCEDURE unsubscribe_mlog
	(subscribe_id IN number)
IS
	attach_user varchar2(30);
	masttbl_id number;
BEGIN
	BEGIN
		SELECT masttbl, attachuser INTO masttbl_id, attach_user
			FROM mlog.subscriber
				WHERE subsid = subscribe_id;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RAISE_APPLICATION_ERROR(-20000, 'subsid(' || subscribe_id || ') is not found in the mlog.subscriber');
		WHEN OTHERS THEN
			RAISE;
	END;

	IF user <> attach_user THEN
		RAISE_APPLICATION_ERROR(-20000, 'permission denied for mlog.unsubscribe_mlog()');
	END IF;

	/* delete mlog.subscriber */
	DELETE FROM mlog.subscriber WHERE subsid = subscribe_id;

	IF SQL%ROWCOUNT = 0 THEN
		RAISE_APPLICATION_ERROR(-20000, 'subsid(' || subscribe_id || ') is not found in the mlog.subscriber');
	END IF;
END;

----------------------------------------
-- mlog.set_subscriber()
----------------------------------------
PROCEDURE set_subscriber
	(subscribe_id IN number,
	 last_type IN char,
	 last_mlogid IN number,
	 last_count IN number)
IS
BEGIN
	BEGIN
		/* update mlog.subscriber */
		UPDATE mlog.subscriber
		SET
			lasttime = current_timestamp,
			lasttype = last_type,
			lastmlogid = last_mlogid,
			lastcount = last_count
		WHERE subsid = subscribe_id
			AND attachuser = user;

		IF SQL%ROWCOUNT = 0 THEN
			RAISE_APPLICATION_ERROR(-20000, 'subsid(' || subscribe_id || ') is not found in the mlog.subscriber');
		END IF;

	EXCEPTION
		WHEN OTHERS THEN
			RAISE;
	END;
END;

----------------------------------------
-- mlog.log_reset()
----------------------------------------
PROCEDURE log_reset
	(schema_name IN varchar2,
	 master_name IN varchar2,
	 masttbl_id IN number)
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	table_space varchar2(30);
	fullname varchar2(80);
BEGIN
	fullname := '"' || schema_name || '"."' || master_name || '"';
	BEGIN
		SELECT tablespace_name INTO table_space FROM all_tables
			WHERE owner = schema_name AND table_name = master_name;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RAISE_APPLICATION_ERROR(-20000, fullname || ' is not found');
		WHEN OTHERS THEN
			RAISE;
	END;

	/* cannot use 'TRUNCATE' in the trigger */
	UPDATE mlog.subscriber SET lastmlogid = -1
		WHERE masttbl = (SELECT masttbl FROM mlog.master
			WHERE nspname = schema_name AND relname = master_name);
	EXECUTE IMMEDIATE 'DELETE FROM mlog.mlog$' || masttbl_id;

	COMMIT;
END;

----------------------------------------
-- mlog.column_defs
----------------------------------------
FUNCTION column_defs
	(nspname IN varchar2,
	 relname IN varchar2) RETURN column_defs_type_array PIPELINED
IS
	table_space varchar2(30);
	fullname varchar2(80);
	i number := 1;
	rec_test column_defs_type_array;
BEGIN
	rec_test := column_defs_type_array();

	fullname := '"' || nspname || '"."' || relname || '"';
	BEGIN
		SELECT tablespace_name INTO table_space FROM all_tables
			WHERE owner = nspname AND table_name = relname;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RAISE_APPLICATION_ERROR(-20000, fullname || ' is not found');
		WHEN OTHERS THEN
			RAISE;
	END;

	FOR rec IN (
		SELECT t1.column_id AS attnum, t1.column_name AS attname,
			CASE
				WHEN t1.data_type IN('VARCHAR', 'VARCHAR2', 'CHAR', 'NVARCHAR2', 'NCHAR', 'RAW')
					THEN t1.data_type || '(' || to_char(t1.data_length) || ')'
				WHEN t1.data_type = 'NUMBER' AND t1.data_precision IS NOT NULL
					THEN t1.data_type || '(' || to_char(t1.data_precision) || ', ' || to_char(t1.data_scale) || ')'
				ELSE t1.data_type END AS atttypename,
			CASE t2.isprimary WHEN 'P' THEN 'y' ELSE NULL END AS isprimary
		FROM all_tab_columns t1 LEFT JOIN
			(
				SELECT c.table_name AS table_name, cc.column_name AS column_name,
					c.constraint_type AS isprimary
				FROM all_constraints c INNER JOIN all_cons_columns cc
					ON c.table_name = cc.table_name AND c.constraint_name = cc.constraint_name
				WHERE c.constraint_type = 'P' AND
					c.owner = nspname AND c.table_name = relname
			) t2
			ON t1.table_name = t2.table_name AND t1.column_name = t2.column_name
		WHERE t1.owner = nspname AND t1.table_name = relname
		ORDER BY t1.column_id ASC
	) LOOP
		rec_test.extend;
		rec_test(i).attnum := rec.attnum;
		rec_test(i).attname := '"' || rec.attname || '"';
		rec_test(i).atttypename := rec.atttypename;
		rec_test(i).isprimary := rec.isprimary;

		PIPE ROW(rec_test(i));
		i := i + 1;
	END LOOP;

	RETURN;
END;

END mlog;
/

----------------------------------------------------------------------------
-- GRANT/REVOKE (mlog)
----------------------------------------------------------------------------
CREATE PUBLIC SYNONYM mlog FOR mlog.mlog;

----------------------------------------
-- GRANT
----------------------------------------
GRANT EXECUTE ON mlog.mlog TO PUBLIC;
GRANT SELECT ON mlog.master TO PUBLIC;
GRANT SELECT ON mlog.subscriber TO PUBLIC;

GRANT SELECT ON mlog.v$subscriber TO PUBLIC;

----------------------------------------
-- REVOKE
----------------------------------------

----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
COMMIT;

EXIT
