package jp.co.ntt.oss.data;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Hashtable;

import jp.co.ntt.oss.QueryParser;
import jp.co.ntt.oss.RefreshMode;
import jp.co.ntt.oss.SyncDatabaseException;

import org.apache.log4j.Logger;

public class SyncDatabaseDAO {
	private static Logger log = Logger.getLogger(SyncDatabaseDAO.class);

	public static final int MLOG_RECORD_NOT_FOUND = -1;

	public static String getTablePrint(final String schema, final String table)
			throws SyncDatabaseException {
		if (table == null) {
			throw new SyncDatabaseException("error.argument");
		}

		if (schema == null) {
			return table;
		}

		return schema + "." + table;
	}

	private static final int SUBSCRIPTION_NSPNAME = 1;
	private static final int SUBSCRIPTION_RELNAME = 2;
	private static final int SUBSCRIPTION_REPLTBL = 3;
	private static final int SUBSCRIPTION_ATTACHUSER = 4;
	private static final int SUBSCRIPTION_SUBSID = 5;
	private static final int SUBSCRIPTION_SRVNAME = 6;
	private static final int SUBSCRIPTION_UERY = 7;
	private static final int SUBSCRIPTION_LASTTIME = 8;
	private static final int SUBSCRIPTION_LASTTYPE = 9;

	public static Subscription getSubscription(final Connection conn,
			final String schema, final String table) throws SQLException,
			SyncDatabaseException {
		if (conn == null || schema == null || table == null) {
			throw new SyncDatabaseException("error.argument");
		}

		PreparedStatement pstmt = null;
		ResultSet rset = null;

		try {
			pstmt = conn.prepareStatement("SELECT * "
					+ "FROM observer.v$subscription "
					+ "WHERE nspname = ? AND relname = ?");
			pstmt.setString(1, schema);
			pstmt.setString(2, table);
			rset = pstmt.executeQuery();

			// not found
			if (!rset.next()) {
				throw new SyncDatabaseException("error.no_subscription",
						SyncDatabaseDAO.getTablePrint(schema, table));
			}

			return new Subscription(rset.getString(SUBSCRIPTION_NSPNAME), rset
					.getString(SUBSCRIPTION_RELNAME), rset
					.getString(SUBSCRIPTION_REPLTBL), rset
					.getString(SUBSCRIPTION_ATTACHUSER), rset
					.getLong(SUBSCRIPTION_SUBSID), rset
					.getString(SUBSCRIPTION_SRVNAME), rset
					.getString(SUBSCRIPTION_UERY), rset
					.getTimestamp(SUBSCRIPTION_LASTTIME), rset
					.getString(SUBSCRIPTION_LASTTYPE));
		} finally {
			if (rset != null) {
				rset.close();
			}
			if (pstmt != null) {
				pstmt.close();
			}
		}
	}

	private static final int SET_SUBSCRIPTION_SCHEMA_NAME = 1;
	private static final int SET_SUBSCRIPTION_REPLICA_NAME = 2;
	private static final int SET_SUBSCRIPTION_LAST_TYPE = 3;

	public static void setSubscription(final Connection conn,
			final Subscription subs) throws SQLException, SyncDatabaseException {
		if (conn == null || subs == null) {
			throw new SyncDatabaseException("error.argument");
		}

		CallableStatement cstmt = null;

		try {
			cstmt = conn
					.prepareCall("{call observer.set_subscription(?, ?, ?)}");
			cstmt.setString(SET_SUBSCRIPTION_SCHEMA_NAME, subs.getSchema());
			cstmt.setString(SET_SUBSCRIPTION_REPLICA_NAME, subs.getTable());
			cstmt.setObject(SET_SUBSCRIPTION_LAST_TYPE, subs.getLastType(),
					Types.CHAR);

			cstmt.executeUpdate();
		} finally {
			if (cstmt != null) {
				cstmt.close();
			}
		}
	}

	private static final int SUBSCRIBER_SUBSID = 1;
	private static final int SUBSCRIBER_NSPNAME = 2;
	private static final int SUBSCRIBER_RELNAME = 3;
	private static final int SUBSCRIBER_MASTTBL = 4;
	private static final int SUBSCRIBER_MLOGNAME = 5;
	private static final int SUBSCRIBER_CREATEUSER = 6;
	private static final int SUBSCRIBER_ATTACHUSER = 7;
	private static final int SUBSCRIBER_DESCRIPTION = 8;
	private static final int SUBSCRIBER_LASTTIME = 9;
	private static final int SUBSCRIBER_LASTTYPE = 10;
	private static final int SUBSCRIBER_LASTMLOGID = 11;
	private static final int SUBSCRIBER_LASTCOUNT = 12;

	public static Subscriber getSubscriber(final Connection conn,
			final long subsID) throws SQLException, SyncDatabaseException {
		if (conn == null) {
			throw new SyncDatabaseException("error.argument");
		}

		PreparedStatement pstmt = null;
		ResultSet rset = null;

		try {
			pstmt = conn.prepareStatement("SELECT * FROM mlog.v$subscriber "
					+ "WHERE subsid = ?");
			pstmt.setLong(1, subsID);
			rset = pstmt.executeQuery();

			// not found
			if (!rset.next()) {
				throw new SyncDatabaseException("error.no_subscriber", subsID);
			}

			return new Subscriber(rset.getLong(SUBSCRIBER_SUBSID), rset
					.getString(SUBSCRIBER_NSPNAME), rset
					.getString(SUBSCRIBER_RELNAME), rset
					.getString(SUBSCRIBER_MASTTBL), rset
					.getString(SUBSCRIBER_MLOGNAME), rset
					.getString(SUBSCRIBER_CREATEUSER), rset
					.getString(SUBSCRIBER_ATTACHUSER), rset
					.getString(SUBSCRIBER_DESCRIPTION), rset
					.getTimestamp(SUBSCRIBER_LASTTIME), rset
					.getString(SUBSCRIBER_LASTTYPE), rset
					.getLong(SUBSCRIBER_LASTMLOGID), rset
					.getLong(SUBSCRIBER_LASTCOUNT));
		} finally {
			if (rset != null) {
				rset.close();
			}
			if (pstmt != null) {
				pstmt.close();
			}
		}
	}

	private static final int SET_SUBSCRIBER_SUBSCRIBE_ID = 1;
	private static final int SET_SUBSCRIBER_LAST_TYPE = 2;
	private static final int SET_SUBSCRIBER_LAST_MLOGID = 3;
	private static final int SET_SUBSCRIBER_LAST_COUNT = 4;

	public static void setSubscriber(final Connection conn,
			final Subscriber suber) throws SQLException, SyncDatabaseException {
		if (conn == null || suber == null) {
			throw new SyncDatabaseException("error.argument");
		}

		CallableStatement cstmt = null;

		try {
			cstmt = conn.prepareCall("{call mlog.set_subscriber(?, ?, ?, ?)}");
			cstmt.setLong(SET_SUBSCRIBER_SUBSCRIBE_ID, suber.getSubsID());
			cstmt.setObject(SET_SUBSCRIBER_LAST_TYPE, suber.getLastType(),
					Types.CHAR);
			cstmt.setLong(SET_SUBSCRIBER_LAST_MLOGID, suber.getLastMlogID());
			cstmt.setLong(SET_SUBSCRIBER_LAST_COUNT, suber.getLastCount());

			cstmt.executeUpdate();
		} finally {
			if (cstmt != null) {
				cstmt.close();
			}
		}
	}

	private static final int MASTERSTATUS_NSPNAME = 1;
	private static final int MASTERSTATUS_RELNAME = 2;
	private static final int MASTERSTATUS_MLOGNAME = 3;
	private static final int MASTERSTATUS_SUBSID = 4;
	private static final int MASTERSTATUS_LASTTIME = 5;
	private static final int MASTERSTATUS_DESCRIPTION = 6;

	public static ArrayList<MasterStatus> getMasterStatus(
			final Connection conn, final String schema, final String table)
			throws SQLException, SyncDatabaseException {
		if (conn == null) {
			throw new SyncDatabaseException("error.argument");
		}

		PreparedStatement pstmt = null;
		ResultSet rset = null;

		StringBuilder query = new StringBuilder();
		query.append("SELECT nspname, relname, mlogname, ");
		query.append("subsid, lasttime, description ");
		query.append("FROM mlog.v$subscriber ");
		if (schema != null) {
			query.append("WHERE nspname = ? ");
		}

		if (table != null) {
			if (schema != null) {
				query.append("AND relname = ? ");
			} else {
				query.append("WHERE relname = ? ");
			}
		}

		query.append("ORDER BY nspname, relname, lasttime, subsid");

		ArrayList<MasterStatus> masters = new ArrayList<MasterStatus>();
		try {
			pstmt = conn.prepareStatement(query.toString());
			if (schema != null) {
				pstmt.setString(1, schema);
			}

			if (table != null) {
				if (schema != null) {
					pstmt.setString(2, table);
				} else {
					pstmt.setString(1, table);
				}
			}

			MasterStatus status = null;

			rset = pstmt.executeQuery();
			if (rset.next()) {
				status = new MasterStatus(rset.getString(MASTERSTATUS_NSPNAME),
						rset.getString(MASTERSTATUS_RELNAME), getLogCount(conn,
								rset.getString(MASTERSTATUS_MLOGNAME)), 0, rset
								.getTimestamp(MASTERSTATUS_LASTTIME),
						getHost(rset.getString(MASTERSTATUS_DESCRIPTION)));
				if (rset.getLong(MASTERSTATUS_SUBSID) != 0) {
					status.incrSubscribers();
				}
			}

			while (rset.next()) {
				if (equalMaster(status.getSchema(), status.getTable(), rset
						.getString(MASTERSTATUS_NSPNAME), rset
						.getString(MASTERSTATUS_RELNAME))) {
					status.incrSubscribers();
					if (status.updateOldestRefresh(rset
							.getTimestamp(MASTERSTATUS_LASTTIME))) {
						status.setOldestReplica(getHost(rset
								.getString(MASTERSTATUS_DESCRIPTION)));
					}

					continue;
				}

				masters.add(status);
				status = new MasterStatus(rset.getString(MASTERSTATUS_NSPNAME),
						rset.getString(MASTERSTATUS_RELNAME), getLogCount(conn,
								rset.getString(MASTERSTATUS_MLOGNAME)), 0, rset
								.getTimestamp(MASTERSTATUS_LASTTIME),
						getHost(rset.getString(MASTERSTATUS_DESCRIPTION)));
				if (rset.getLong(MASTERSTATUS_SUBSID) != 0) {
					status.incrSubscribers();
				}
			}

			if (status != null) {
				masters.add(status);
			}
		} finally {
			if (rset != null) {
				rset.close();
			}
			if (pstmt != null) {
				pstmt.close();
			}
		}

		return masters;
	}

	protected static String getHost(final String description) {
		if (description == null) {
			return null;
		}

		Hashtable<String, String> desc = null;
		try {
			QueryParser parser = new QueryParser(description, "\"");
			desc = parser.parseDescription();
		} catch (SyncDatabaseException e) {
			return description;
		}

		return desc.get("resource name");
	}

	protected static long getLogCount(final Connection conn,
			final String mlogName) throws SyncDatabaseException, SQLException {
		if (conn == null) {
			throw new SyncDatabaseException("error.argument");
		}

		if (mlogName == null) {
			return MasterStatus.INVALID_LOG_COUNT;
		}

		Statement stmt = null;
		ResultSet rset = null;

		try {
			stmt = conn.createStatement();
			try {
				rset = stmt.executeQuery("SELECT "
						+ "max(mlogid) - min(mlogid) + 1 FROM " + mlogName);
			} catch (SQLException e) {
				return MasterStatus.INVALID_LOG_COUNT;
			}
			if (!rset.next()) {
				return MasterStatus.INVALID_LOG_COUNT;
			}

			return rset.getLong(1);
		} finally {
			if (rset != null) {
				rset.close();
			}
			if (stmt != null) {
				stmt.close();
			}
		}
	}

	protected static boolean equalMaster(final String schema1,
			final String table1, final String schema2, final String table2) {
		if (schema1 == null && schema2 == null) {
			if (table1 == null && table2 == null) {
				return true;
			}

			if (table1 != null && table1.equals(table2)) {
				return true;
			}
		}

		if (schema1 != null && schema1.equals(schema2)) {
			if (table1 == null && table2 == null) {
				return true;
			}

			if (table1 != null && table1.equals(table2)) {
				return true;
			}
		}

		return false;
	}

	private static final int REPLICASTATUS_NSPNAME = 1;
	private static final int REPLICASTATUS_RELNAME = 2;
	private static final int REPLICASTATUS_LASTTIME = 3;
	private static final int REPLICASTATUS_SRVNAME = 4;
	private static final int REPLICASTATUS_SUBSID = 5;

	public static ArrayList<ReplicaStatus> getReplicaStatus(
			final Connection conn, final String schema, final String table)
			throws SQLException, SyncDatabaseException {
		if (conn == null) {
			throw new SyncDatabaseException("error.argument");
		}

		PreparedStatement pstmt = null;
		ResultSet rset = null;

		StringBuilder query = new StringBuilder();
		query.append("SELECT nspname, relname, lasttime, srvname, subsid ");
		query.append("FROM observer.v$subscription ");
		if (schema != null) {
			query.append("WHERE nspname = ? ");
		}

		if (table != null) {
			if (schema != null) {
				query.append("AND relname = ? ");
			} else {
				query.append("WHERE relname = ? ");
			}
		}

		query.append("ORDER BY nspname, relname");

		ArrayList<ReplicaStatus> replicas = new ArrayList<ReplicaStatus>();
		try {
			pstmt = conn.prepareStatement(query.toString());
			if (schema != null) {
				pstmt.setString(1, schema);
			}

			if (table != null) {
				if (schema != null) {
					pstmt.setString(2, table);
				} else {
					pstmt.setString(1, table);
				}
			}

			ReplicaStatus status = null;

			rset = pstmt.executeQuery();

			while (rset.next()) {
				status = new ReplicaStatus(rset
						.getString(REPLICASTATUS_NSPNAME), rset
						.getString(REPLICASTATUS_RELNAME), rset
						.getTimestamp(REPLICASTATUS_LASTTIME), rset
						.getString(REPLICASTATUS_SRVNAME), rset
						.getLong(REPLICASTATUS_SUBSID));
				replicas.add(status);
			}
		} finally {
			if (rset != null) {
				rset.close();
			}
			if (pstmt != null) {
				pstmt.close();
			}
		}

		return replicas;
	}

	public static long getMaxMlogID(final Connection conn, final String mlogName)
			throws SQLException, SyncDatabaseException {
		if (conn == null || mlogName == null) {
			throw new SyncDatabaseException("error.argument");
		}

		Statement stmt = null;
		ResultSet rset = null;

		try {
			stmt = conn.createStatement();
			rset = stmt.executeQuery("SELECT max(mlogid) FROM " + mlogName);
			if (!rset.next() || rset.getString(1) == null) {
				return MLOG_RECORD_NOT_FOUND;
			}

			return rset.getLong(1);
		} finally {
			if (rset != null) {
				rset.close();
			}
			if (stmt != null) {
				stmt.close();
			}
		}
	}

	public static Hashtable<Short, String> getPKNames(final Connection conn,
			final String schema, final String table) throws SQLException,
			SyncDatabaseException {
		if (conn == null || schema == null || table == null) {
			throw new SyncDatabaseException("error.argument");
		}

		// get replica table primary key definition
		final DatabaseMetaData dmd = conn.getMetaData();
		ResultSet rset = null;
		try {
			final String quoteString = dmd.getIdentifierQuoteString();
			rset = dmd.getPrimaryKeys(null, schema, table);

			final Hashtable<Short, String> pkNames = new Hashtable<Short, String>();

			while (rset.next()) {
				String columnName = rset.getString("COLUMN_NAME");
				columnName = quoteIdent(quoteString, columnName);
				final short keySeq = rset.getShort("KEY_SEQ");
				pkNames.put(keySeq, columnName);
			}

			log.debug(pkNames.toString());
			return pkNames;
		} finally {
			if (rset != null) {
				rset.close();
			}
		}
	}

	// TODO mlog scan の重み付け
	private static final double RANDOM_SCAN_COST = 1.5;

	private static final int REFRESH_COST_PK_COUNT = 1;
	private static final int REFRESH_COST_EXEC_COUNT = 2;
	private static final int REFRESH_COST_DIFF_COUNT = 3;

	public static double getIncrementalRefreshCost(final Connection conn,
			final String mlogName, final long lastMlogID, final long lastCount,
			final Hashtable<Short, String> pkNames)
			throws SyncDatabaseException, SQLException {
		if (conn == null || mlogName == null || pkNames == null
				|| pkNames.size() < 1) {
			throw new SyncDatabaseException("error.argument");
		}

		if (lastMlogID < 0 || lastCount < 0) {
			return Double.NaN;
		}

		StringBuilder query = new StringBuilder();
		query.append("SELECT COUNT(*), ");
		query.append("SUM(LEAST(1, m.d_cnt)) + ");
		query.append("SUM(LEAST(1, m.i_cnt)) + ");
		query.append("SUM(LEAST(1, m.u_cnt)), ");
		query.append("SUM(m.i_cnt) - SUM(m.d_cnt) ");
		query.append("FROM (SELECT ");
		query.append("SUM(CASE WHEN dmltype = 'D' THEN 1 ELSE 0 END) d_cnt, ");
		query.append("SUM(CASE WHEN dmltype = 'I' THEN 1 ELSE 0 END) i_cnt, ");
		query.append("SUM(CASE WHEN dmltype = 'U' THEN 1 ELSE 0 END) u_cnt ");
		query.append("FROM ");
		query.append(mlogName);
		query.append(" WHERE mlogid > ? GROUP BY ");
		// PK list
		for (short i = 1; i <= pkNames.size(); i++) {
			if (i > 1) {
				query.append(", ");
			}
			query.append(pkNames.get(Short.valueOf(i)));
		}
		query.append(") m");

		PreparedStatement pstmt = null;
		ResultSet rset = null;

		try {
			pstmt = conn.prepareStatement(query.toString());
			pstmt.setLong(1, lastMlogID);
			rset = pstmt.executeQuery();
			if (!rset.next()) {
				throw new SyncDatabaseException("error.argument");
			}

			long pkCount = rset.getLong(REFRESH_COST_PK_COUNT);
			long execQueryCount = rset.getLong(REFRESH_COST_EXEC_COUNT);
			long diffCount = rset.getLong(REFRESH_COST_DIFF_COUNT);

			log.debug("mlog PK count : " + pkCount
					+ " / execute query count : " + execQueryCount
					+ " / difference count : " + diffCount);

			if (lastCount + diffCount <= 0) {
				return Double.NaN;
			}

			return (execQueryCount * RANDOM_SCAN_COST)
					/ ((double) lastCount + diffCount);
		} finally {
			if (rset != null) {
				rset.close();
			}
			if (pstmt != null) {
				pstmt.close();
			}
		}
	}

	public static RefreshMode chooseFastestMode(final Connection conn,
			final Subscriber suber) throws SyncDatabaseException, SQLException {
		if (conn == null || suber == null) {
			throw new SyncDatabaseException("error.argument");
		}

		double cost = getIncrementalRefreshCost(conn, suber.getMlogName(),
				suber.getLastMlogID(), suber.getLastCount(), getPKNames(conn,
						suber.getNspName(), suber.getRelName()));

		if (Double.isNaN(cost) || cost >= 1) {
			return RefreshMode.FULL;
		}

		return RefreshMode.INCREMENTAL;
	}

	public static void purgeMlog(final Connection conn, final String schema,
			final String table) throws SyncDatabaseException, SQLException {
		if (conn == null || schema == null || table == null) {
			throw new SyncDatabaseException("error.argument");
		}

		CallableStatement cstmt = null;

		try {
			cstmt = conn.prepareCall("{call mlog.purge_mlog(?, ?)}");
			cstmt.setString(1, schema);
			cstmt.setString(2, table);

			cstmt.executeUpdate();
		} finally {
			if (cstmt != null) {
				cstmt.close();
			}
		}
	}

	public static void truncate(final Connection conn,
			final String quotedTable, final boolean concurrent)
			throws SQLException, SyncDatabaseException {
		if (conn == null || quotedTable == null) {
			throw new SyncDatabaseException("error.argument");
		}

		Statement stmt = null;
		try {
			stmt = conn.createStatement();
			if (concurrent) {
				stmt.executeUpdate("DELETE FROM " + quotedTable);
			} else {
				stmt.executeUpdate("TRUNCATE TABLE " + quotedTable);
			}
		} finally {
			if (stmt != null) {
				stmt.close();
			}
		}
	}

	public static String quoteIdent(final String quoteString,
			final String identifier) throws SyncDatabaseException, SQLException {
		if (identifier == null) {
			throw new SyncDatabaseException("error.argument");
		}

		if (quoteString.equals(" ")) {
			return identifier;
		}

		StringBuilder quotedIdentifier = new StringBuilder();
		quotedIdentifier.append(quoteString);
		for (int i = 0; i < identifier.length(); i++) {
			if (identifier.charAt(i) == quoteString.charAt(0)) {
				quotedIdentifier.append(quoteString);
			}
			quotedIdentifier.append(identifier.charAt(i));
		}

		quotedIdentifier.append(quoteString);
		return quotedIdentifier.toString();
	}

	private static final int SUBSCRIBE_MLOG_SCHEMA_NAME = 1;
	private static final int SUBSCRIBE_MLOG_MASTER_NAME = 2;
	private static final int SUBSCRIBE_MLOG_SUBSCRIBE_INFO = 3;
	private static final int SUBSCRIBE_MLOG_SUBSCRIBE_ID = 4;

	public static long subscribeMlog(final Connection conn,
			final String schema, final String table, final String description)
			throws SyncDatabaseException, SQLException {
		if (conn == null || schema == null || table == null) {
			throw new SyncDatabaseException("error.argument");
		}

		CallableStatement cstmt = null;

		try {
			cstmt = conn.prepareCall("{call mlog.subscribe_mlog(?, ?, ?, ?)}");
			cstmt.setString(SUBSCRIBE_MLOG_SCHEMA_NAME, schema);
			cstmt.setString(SUBSCRIBE_MLOG_MASTER_NAME, table);
			cstmt.setString(SUBSCRIBE_MLOG_SUBSCRIBE_INFO, description);
			cstmt.registerOutParameter(SUBSCRIBE_MLOG_SUBSCRIBE_ID,
					Types.BIGINT);

			cstmt.executeUpdate();
			return cstmt.getLong(SUBSCRIBE_MLOG_SUBSCRIBE_ID);
		} finally {
			if (cstmt != null) {
				cstmt.close();
			}
		}
	}

	public static void unSubscribeMlog(final Connection conn, final long subsID)
			throws SyncDatabaseException, SQLException {
		if (conn == null) {
			throw new SyncDatabaseException("error.argument");
		}

		CallableStatement cstmt = null;

		try {
			cstmt = conn.prepareCall("{call mlog.unsubscribe_mlog(?)}");
			cstmt.setLong(1, subsID);

			cstmt.executeUpdate();
		} finally {
			if (cstmt != null) {
				cstmt.close();
			}
		}
	}

	public static void createMlog(final Connection conn, final String schema,
			final String table) throws SyncDatabaseException, SQLException {
		if (conn == null || schema == null || table == null) {
			throw new SyncDatabaseException("error.argument");
		}

		CallableStatement cstmt = null;

		try {
			cstmt = conn.prepareCall("{call mlog.create_mlog(?, ?)}");
			cstmt.setString(1, schema);
			cstmt.setString(2, table);

			cstmt.executeUpdate();
		} finally {
			if (cstmt != null) {
				cstmt.close();
			}
		}
	}

	public static void dropMlog(final Connection conn, final String schema,
			final String table) throws SyncDatabaseException, SQLException {
		if (conn == null || schema == null || table == null) {
			throw new SyncDatabaseException("error.argument");
		}

		CallableStatement cstmt = null;

		try {
			cstmt = conn.prepareCall("{call mlog.drop_mlog(?, ?)}");
			cstmt.setString(1, schema);
			cstmt.setString(2, table);

			cstmt.executeUpdate();
		} finally {
			if (cstmt != null) {
				cstmt.close();
			}
		}
	}

	private static final int OBSERVER_SUBSCRIBE_SCHEMA_NAME = 1;
	private static final int OBSERVER_SUBSCRIBE_REPLICA_NAME = 2;
	private static final int OBSERVER_SUBSCRIBE_SUBSCRIBE_ID = 3;
	private static final int OBSERVER_SUBSCRIBE_SERVER_NAME = 4;
	private static final int OBSERVER_SUBSCRIBE_EXEC_QUERY = 5;

	public static void subscribeObserver(final Connection conn,
			final String schema, final String table, final long subsid,
			final String master, final String query)
			throws SyncDatabaseException, SQLException {
		if (conn == null || schema == null || table == null || master == null
				|| query == null) {
			throw new SyncDatabaseException("error.argument");
		}

		CallableStatement cstmt = null;

		try {
			cstmt = conn
					.prepareCall("{call observer.subscribe(?, ?, ?, ?, ?)}");
			cstmt.setString(OBSERVER_SUBSCRIBE_SCHEMA_NAME, schema);
			cstmt.setString(OBSERVER_SUBSCRIBE_REPLICA_NAME, table);
			if (subsid == 0) {
				cstmt.setNull(OBSERVER_SUBSCRIBE_SUBSCRIBE_ID, Types.BIGINT);
			} else {
				cstmt.setLong(OBSERVER_SUBSCRIBE_SUBSCRIBE_ID, subsid);
			}
			cstmt.setString(OBSERVER_SUBSCRIBE_SERVER_NAME, master);
			cstmt.setString(OBSERVER_SUBSCRIBE_EXEC_QUERY, query);

			cstmt.executeUpdate();
		} finally {
			if (cstmt != null) {
				cstmt.close();
			}
		}
	}

	public static void unSubscribeObserver(final Connection conn,
			final String schema, final String table)
			throws SyncDatabaseException, SQLException {
		if (conn == null || schema == null || table == null) {
			throw new SyncDatabaseException("error.argument");
		}

		CallableStatement cstmt = null;

		try {
			cstmt = conn.prepareCall("{call observer.unsubscribe(?, ?)}");
			cstmt.setString(1, schema);
			cstmt.setString(2, table);

			cstmt.executeUpdate();
		} finally {
			if (cstmt != null) {
				cstmt.close();
			}
		}
	}

	public static String getDescription(final Connection conn,
			final String resource) throws SQLException, SyncDatabaseException {
		if (conn == null) {
			throw new SyncDatabaseException("error.argument");
		}

		StringBuilder desc = new StringBuilder();
		DatabaseMetaData dmd = conn.getMetaData();

		desc.append("resource name:");
		desc.append(quoteIdent("\"", resource));
		desc.append(", DBMS:");
		desc.append(quoteIdent("\"", dmd.getDatabaseProductName()));
		desc.append(", URL:");
		desc.append(quoteIdent("\"", dmd.getURL()));

		return desc.toString();
	}

	public static Connection lockTable(final String name,
			final String quotedTable) throws Exception {
		if (name == null || quotedTable == null) {
			throw new SyncDatabaseException("error.argument");
		}

		Connection conn = null;
		Statement stmt = null;

		try {
			JdbcResource jdbcResource = JdbcResource.getJdbcResource(
					DatabaseResource.RESOURCE_FILE_NAME, name);

			Class.forName(jdbcResource.getClassName());
			conn = DriverManager.getConnection(jdbcResource.getUrl(),
					jdbcResource.getUsername(), jdbcResource.getPassword());
			conn.setAutoCommit(false);

			stmt = conn.createStatement();
			stmt.executeUpdate("LOCK TABLE " + quotedTable + " IN SHARE MODE");
		} catch (Exception e) {
			if (conn != null) {
				conn.close();
			}

			throw e;
		} finally {
			if (stmt != null) {
				stmt.close();
			}
		}
		return conn;
	}

	/*
	 * ResultSet の内容を全て表示する。 デバッグ用
	 */
	public static void printResultSet(final ResultSet rset) throws SQLException {
		ResultSetMetaData rsMetaData = rset.getMetaData();
		int columnSize = rset.getMetaData().getColumnCount();

		StringBuilder buf = new StringBuilder("|*Column Names");
		for (int i = 1; i < columnSize; i++) {
			buf.append("|*" + rsMetaData.getColumnName(i));
		}
		System.out.println(buf.append("|"));

		int j = 0;
		while (rset.next()) {
			j++;
			buf = new StringBuilder("|").append(rset.getRow());
			for (int i = 1; i <= columnSize; i++) {
				buf.append("|" + rset.getObject(i));
			}
			System.out.println(buf.append("|"));
		}
	}
}
