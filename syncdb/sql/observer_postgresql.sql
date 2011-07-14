SET search_path = public;

BEGIN;

----------------------------------------------------------------------------
-- CREATE SCHEMA (observer)
----------------------------------------------------------------------------
CREATE SCHEMA observer;

----------------------------------------------------------------------------
-- CREATE TABLES (observer)
----------------------------------------------------------------------------
CREATE TABLE observer.subscription (
	repltbl regclass NOT NULL,
	attachuser oid NOT NULL,
	subsid bigint,
	srvname text NOT NULL,
	query text NOT NULL,
	lasttime timestamptz default current_timestamp,
	lasttype "char" CHECK (lasttype IN ('F', 'I')),
	PRIMARY KEY (repltbl)
);
COMMENT ON TABLE observer.subscription
	IS 'syncdb (replica) : subscription information';

----------------------------------------------------------------------------
-- CREATE VIEWS (observer)
----------------------------------------------------------------------------
----------------------------------------
-- observer.v$subscription
----------------------------------------
CREATE OR REPLACE VIEW observer.v$subscription AS
	SELECT
		n.nspname AS nspname,
		c.relname AS relname,
		quote_ident(n.nspname) || '.' || quote_ident(c.relname) AS repltbl,
		r.rolname AS attachuser,
		s.subsid AS subsid,
		s.srvname AS srvname,
		s.query AS query,
		s.lasttime AS lasttime,
		s.lasttype AS lasttype
	FROM observer.subscription s
		LEFT OUTER JOIN pg_catalog.pg_class c ON s.repltbl = c.oid
		LEFT OUTER JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
		LEFT OUTER JOIN pg_catalog.pg_roles r ON r.oid = s.attachuser;

----------------------------------------------------------------------------
-- CREATE FUNCTIONS (observer)
----------------------------------------------------------------------------
----------------------------------------
-- observer.subscribe()
----------------------------------------
CREATE OR REPLACE FUNCTION observer.subscribe
	(IN schema_name name,
	 IN replica_name name,
	 IN subscribe_id bigint,
	 IN server_name text,
	 IN exec_query text) RETURNS void AS
$BODY$
DECLARE
	fullname text;
	replica_table regclass;

	has_sel boolean;
	has_upd boolean;
	has_ins boolean;
	has_del boolean;
	has_trc boolean;

BEGIN
	fullname := quote_ident(schema_name) || '.' || quote_ident(replica_name);
	replica_table := fullname::regclass;

	/* authority check of replica_tbl (SELECT, UPDATE, INSERT, DELETE, TRUNCATE) */
	SELECT
		has_table_privilege(session_user, replica_table, 'SELECT'),
		has_table_privilege(session_user, replica_table, 'UPDATE'),
		has_table_privilege(session_user, replica_table, 'INSERT'),
		has_table_privilege(session_user, replica_table, 'DELETE'),
		has_table_privilege(session_user, replica_table, 'TRUNCATE')
		INTO has_sel, has_upd, has_ins, has_del, has_trc;

	IF has_sel = FALSE OR has_upd = FALSE OR has_ins = FALSE OR has_del = FALSE OR has_trc = FALSE THEN
		RAISE EXCEPTION 'permission denied for observer.subscribe()';
	END IF;

	/* insert observer.subscription */
	INSERT INTO observer.subscription
		(repltbl, attachuser, subsid, srvname, query, lasttime)
		VALUES (
			replica_table,
			(SELECT oid FROM pg_catalog.pg_roles WHERE rolname = session_user),
			subscribe_id,
			server_name,
			exec_query,
			NULL);

	RETURN;
END;
$BODY$ LANGUAGE plpgsql VOLATILE EXTERNAL SECURITY DEFINER;

----------------------------------------
-- observer.unsubscribe()
----------------------------------------
CREATE OR REPLACE FUNCTION observer.unsubscribe
	(IN schema_name name, IN replica_name name) RETURNS void AS
$BODY$
DECLARE
	fullname text;
	replica_table regclass;
	curtime timestamp := now();
BEGIN
	fullname := quote_ident(schema_name) || '.' || quote_ident(replica_name);
	replica_table := fullname::regclass;

	/* delete observer.subscription */
	DELETE FROM observer.subscription WHERE repltbl = replica_table
		AND attachuser = ANY(SELECT oid FROM pg_catalog.pg_roles WHERE rolname = session_user);

	IF NOT FOUND THEN
		RAISE EXCEPTION 'can not delete row from observer.subscription';
	END IF;

	RETURN;
END;
$BODY$ LANGUAGE plpgsql VOLATILE EXTERNAL SECURITY DEFINER;

----------------------------------------
-- observer.set_subscription()
----------------------------------------
CREATE OR REPLACE FUNCTION observer.set_subscription
	(IN schema_name name,
	 IN replica_name name,
	 IN last_type char(1)) RETURNS void AS
$BODY$
DECLARE
	fullname text;
	replica_table regclass;
	curtime timestamp := now();
BEGIN
	fullname := quote_ident(schema_name) || '.' || quote_ident(replica_name);
	replica_table := fullname::regclass;

	/* update observer.subscription */
	UPDATE observer.subscription
			SET lasttime = curtime, lasttype = last_type
		WHERE repltbl = replica_table
			AND attachuser = ANY(SELECT oid FROM pg_catalog.pg_roles WHERE rolname = session_user);

	IF NOT FOUND THEN
		RAISE EXCEPTION 'can not update row of observer.subscription';
	END IF;
END;
$BODY$ LANGUAGE plpgsql VOLATILE EXTERNAL SECURITY DEFINER;

----------------------------------------------------------------------------
-- GRANT/REVOKE (observer)
----------------------------------------------------------------------------
----------------------------------------
-- GRANT
----------------------------------------
GRANT USAGE ON SCHEMA observer TO PUBLIC;

GRANT SELECT ON TABLE observer.subscription TO PUBLIC;
GRANT SELECT ON observer.v$subscription TO PUBLIC;

GRANT EXECUTE ON FUNCTION observer.subscribe(name, name, bigint, text, text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION observer.unsubscribe(name, name) TO PUBLIC;
GRANT EXECUTE ON FUNCTION observer.set_subscription(name, name, char(1)) TO PUBLIC;

----------------------------------------
-- REVOKE
----------------------------------------

----------------------------------------------------------------------------
--
----------------------------------------------------------------------------

COMMIT;
