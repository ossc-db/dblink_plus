----------------------------------------------------------------------------
-- CREATE SCHEMA (observer)
----------------------------------------------------------------------------
CREATE USER observer IDENTIFIED BY observer;
GRANT RESOURCE TO observer;
GRANT SELECT ANY DICTIONARY TO observer;
GRANT SELECT ANY TABLE TO observer;

----------------------------------------------------------------------------
-- CREATE TABLES (observer)
----------------------------------------------------------------------------
CREATE TABLE observer.subscription (
	repltbl number NOT NULL,
	nspname varchar2(30) NOT NULL,
	relname varchar2(30) NOT NULL,
	attachuser varchar2(30) NOT NULL,
	subsid number,
	srvname varchar2(4000) NOT NULL,
	query varchar2(4000) NOT NULL,
	lasttime timestamp with time zone DEFAULT SYSTIMESTAMP,
	lasttype char CHECK (lasttype IN ('F', 'I')),
	PRIMARY KEY (repltbl),
	UNIQUE (nspname, relname)
);
COMMENT ON TABLE observer.subscription
	IS 'syncdb (replica) : subscription information';

----------------------------------------------------------------------------
-- CREATE SEQUENCE (observer)
----------------------------------------------------------------------------
CREATE SEQUENCE observer.subscription_repltbl_seq NOCYCLE NOCACHE;

----------------------------------------------------------------------------
-- CREATE TRIGGER (observer)
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- CREATE VIEWS (observer)
----------------------------------------------------------------------------
----------------------------------------
-- observer.v$subscription
----------------------------------------
CREATE OR REPLACE VIEW observer.v$subscription AS
	SELECT
		u.username AS nspname,
		t.table_name AS relname,
		'"' || t.owner || '"."' || t.table_name || '"' AS repltbl,
		u1.username AS attachuser,
		subsid AS subsid,
		srvname AS srvname,
		query AS query,
		lasttime AS lasttime,
		lasttype AS lasttype
	FROM observer.subscription s
		LEFT OUTER JOIN all_users u ON u.username = s.nspname
		LEFT OUTER JOIN all_tables t ON t.owner = s.nspname AND
										t.table_name = s.relname
		LEFT OUTER JOIN all_users u1 ON u1.username = s.attachuser;

----------------------------------------
-- observer.v$role_privileges
----------------------------------------
CREATE OR REPLACE VIEW observer.v$role_privileges AS
	SELECT granted_role FROM (
		SELECT null grantee, username granted_role FROM dba_users
			WHERE username = user
		UNION SELECT grantee, granted_role FROM dba_role_privs
		UNION SELECT grantee, privilege FROM dba_sys_privs
		UNION SELECT grantee, privilege || ' ' || owner || '.' || table_name FROM dba_tab_privs
	) START WITH grantee IS NULL
		CONNECT By grantee = PRIOR granted_role;

----------------------------------------------------------------------------
-- CREATE FUNCTIONS (ovserver)
----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE observer.observer AUTHID DEFINER AS
	PROCEDURE subscribe(schema_name IN varchar2, replica_name IN varchar2, subscribe_id IN number, server_name IN varchar2, exec_query IN varchar2);
	PROCEDURE unsubscribe(schema_name IN varchar2, replica_name IN varchar2);
	PROCEDURE set_subscription(schema_name IN varchar2, replica_name IN varchar2, last_type IN char);
END;
/

CREATE OR REPLACE PACKAGE BODY observer.observer AS
----------------------------------------
-- observer.subscribe()
----------------------------------------
PROCEDURE subscribe
	(schema_name IN varchar2,
	 replica_name IN varchar2,
	 subscribe_id IN number,
	 server_name IN varchar2,
	 exec_query IN varchar2)
IS
	table_space varchar2(30);
	fullname varchar2(80);
	repl_id number;
	wk_count number;
BEGIN
	fullname := '"' || schema_name || '"."' || replica_name || '"';
	BEGIN
		SELECT tablespace_name INTO table_space FROM all_tables
			WHERE owner = schema_name AND table_name = replica_name;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RAISE_APPLICATION_ERROR(-20000, fullname || ' is not found');
		WHEN OTHERS THEN
			RAISE;
	END;

	/* authority check of replica_tbl */
	/* XXX */
	IF user = schema_name THEN
		SELECT count(*) INTO wk_count FROM observer.v$role_privileges
			WHERE granted_role = 'CREATE TABLE' OR granted_role = 'CREATE ANY TABLE';
	ELSE
		SELECT count(*) INTO wk_count FROM observer.v$role_privileges
			WHERE granted_role = 'SELECT ANY TABLE' OR
			granted_role = 'SELECT ' || schema_name || '.' || replica_name;

		IF wk_count = 0 THEN
			SELECT count(*) INTO wk_count FROM dba_tab_privs
				WHERE owner = schema_name AND table_name = replica_name AND
					(grantee = 'PUBLIC' OR grantee = user) AND PRIVILEGE = 'SELECT';

			IF wk_count = 0 THEN
				RAISE_APPLICATION_ERROR(-20000, 'permission denied for observer.subscribe()');
			END IF;
		END IF;

		SELECT count(*) INTO wk_count FROM observer.v$role_privileges
			WHERE granted_role = 'CREATE ANY TABLE';
	END IF;

	IF wk_count = 0 THEN
		SELECT count(*) INTO wk_count FROM observer.v$role_privileges
			WHERE granted_role = 'DROP ANY TABLE';

		IF wk_count = 0 THEN
			RAISE_APPLICATION_ERROR(-20000, 'permission denied for observer.subscribe()');
		END IF;

		SELECT count(*) INTO wk_count FROM observer.v$role_privileges
			WHERE granted_role = 'UPDATE ANY TABLE' OR
				granted_role = 'UPDATE ' || schema_name || '.' || replica_name;

		IF wk_count = 0 THEN
			RAISE_APPLICATION_ERROR(-20000, 'permission denied for observer.subscribe()');
		END IF;

		SELECT count(*) INTO wk_count FROM observer.v$role_privileges
			WHERE granted_role = 'INSERT ANY TABLE' OR
				granted_role = 'INSERT ' || schema_name || '.' || replica_name;

		IF wk_count = 0 THEN
			RAISE_APPLICATION_ERROR(-20000, 'permission denied for observer.subscribe()');
		END IF;

		SELECT count(*) INTO wk_count FROM observer.v$role_privileges
			WHERE granted_role = 'DELETE ANY TABLE' OR
				granted_role = 'DELETE ' || schema_name || '.' || replica_name;

		IF wk_count = 0 THEN
			RAISE_APPLICATION_ERROR(-20000, 'permission denied for observer.subscribe()');
		END IF;
	END IF;

	SELECT subscription_repltbl_seq.NEXTVAL INTO repl_id FROM DUAL;

	/* insert observer.subscription */
	INSERT INTO observer.subscription
		(repltbl, nspname, relname, attachuser, subsid, srvname, query, lasttime)
		VALUES (
			repl_id,
			schema_name,
			replica_name,
			user,
			subscribe_id,
			server_name,
			exec_query,
			NULL);
END;

----------------------------------------
-- observer.unsubscribe()
----------------------------------------
PROCEDURE unsubscribe
	(schema_name IN varchar2,
	 replica_name IN varchar2)
IS
	table_space varchar2(30);
	fullname varchar2(80);
BEGIN
	fullname := '"' || schema_name || '"."' || replica_name || '"';
	BEGIN
		SELECT tablespace_name INTO table_space FROM all_tables
			WHERE owner = schema_name AND table_name = replica_name;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RAISE_APPLICATION_ERROR(-20000, fullname || ' is not found');
		WHEN OTHERS THEN
			RAISE;
	END;

	BEGIN
		/* delete observer.subscription */
		DELETE FROM observer.subscription
			WHERE nspname = schema_name AND relname = replica_name AND attachuser = user;

		IF SQL%ROWCOUNT = 0 THEN
			RAISE_APPLICATION_ERROR(-20000, 'can not delete row from observer.subscription');
		END IF;

	EXCEPTION
		WHEN OTHERS THEN
			RAISE;
	END;
END;

----------------------------------------
-- observer.set_subscription()
----------------------------------------
PROCEDURE set_subscription
	(schema_name IN varchar2,
	 replica_name IN varchar2,
	 last_type IN char)
IS
	table_space varchar2(30);
	fullname varchar2(80);
BEGIN
	fullname := '"' || schema_name || '"."' || replica_name || '"';
	BEGIN
		SELECT tablespace_name INTO table_space FROM all_tables
			WHERE owner = schema_name AND table_name = replica_name;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RAISE_APPLICATION_ERROR(-20000, fullname || ' is not found');
		WHEN OTHERS THEN
			RAISE;
	END;

	BEGIN
		/* update observer.subscription */
		UPDATE observer.subscription
			SET lasttime = current_timestamp,
			    lasttype = last_type
			WHERE
				nspname = schema_name
				AND relname = replica_name
				AND attachuser = user;

		IF SQL%ROWCOUNT = 0 THEN
			RAISE_APPLICATION_ERROR(-20000, 'can not update row of observer.subscription');
		END IF;

	EXCEPTION
		WHEN OTHERS THEN
			RAISE;
	END;
END;

END observer;
/

----------------------------------------------------------------------------
-- GRANT/REVOKE (observer)
----------------------------------------------------------------------------
CREATE PUBLIC SYNONYM observer FOR observer.observer;

----------------------------------------
-- GRANT
----------------------------------------
GRANT EXECUTE ON observer.observer TO PUBLIC;
GRANT SELECT ON observer.subscription TO PUBLIC;

GRANT SELECT ON observer.v$subscription TO PUBLIC;

----------------------------------------
-- REVOKE
----------------------------------------

----------------------------------------------------------------------------
--
----------------------------------------------------------------------------

COMMIT;

EXIT
