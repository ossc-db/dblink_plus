package jp.co.ntt.oss;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Hashtable;

import jp.co.ntt.oss.mapper.MappingData;

import org.apache.log4j.Logger;

public class IncrementalReader implements Reader {
	private static Logger log = Logger.getLogger(IncrementalReader.class);

	// the number of rows to fetch
	private static final int FETCH_SIZE = 100;

	// flag column count (delete flag, insert flag and update flag)
	private static final int TYPE_COUNT = 3;

	private Statement stmt = null;
	private ResultSet rset = null;
	private int pkCount;
	private MappingData columnMapping = null;

	public IncrementalReader(final Connection conn, final String query,
			final int setPkCount) throws SQLException, SyncDatabaseException {
		if (conn == null || query == null || setPkCount < 1) {
			throw new SyncDatabaseException("error.argument");
		}

		try {
			this.pkCount = setPkCount;

			stmt = conn.createStatement();
			stmt.setFetchSize(FETCH_SIZE);
			rset = stmt.executeQuery(query);

			final ResultSetMetaData rmd = rset.getMetaData();

			final int columnCount = rmd.getColumnCount() - TYPE_COUNT;
			columnMapping = new MappingData(columnCount);
			for (int i = 0; i < columnCount; i++) {
				columnMapping.setColumnType(i, rmd.getColumnType(i + TYPE_COUNT
						+ 1));
				columnMapping.setColumnTypeName(i, rmd.getColumnTypeName(i
						+ TYPE_COUNT + 1));
			}
		} catch (final SQLException e) {
			if (rset != null) {
				rset.close();
			}
			if (stmt != null) {
				stmt.close();
			}

			throw e;
		}
	}

	public final void close() throws SQLException {
		if (rset != null) {
			rset.close();
		}
		if (stmt != null) {
			stmt.close();
		}
	}

	public final Object[] getNextColumns() throws SQLException,
			SyncDatabaseException {
		if (!rset.next()) {
			return null;
		}

		final Object[] columns = new Object[columnMapping.getColumnCount()
				+ TYPE_COUNT];

		int i;
		// get D, I ,U count
		for (i = 0; i < TYPE_COUNT; i++) {
			columns[i] = rset.getLong(i + 1);
		}

		// get PK data and select list data
		for (; i < columnMapping.getColumnCount() + TYPE_COUNT; i++) {
			columns[i] = columnMapping.getDataMapper(i - TYPE_COUNT).getObject(
					rset, i + 1);
		}

		return columns;
	}

	public final int getColumnCount() {
		return columnMapping.getColumnCount();
	}

	public final MappingData getColumnMapping() {
		return columnMapping;
	}

	public final int getPKCount() {
		return pkCount;
	}

	public static String getIncrementalQuery(final String mlogName,
			final String query, final Hashtable<Short, String> pkNames,
			final long lastMlogID) throws SQLException, SyncDatabaseException {
		if (mlogName == null || query == null || pkNames == null
				|| pkNames.size() < 1 || lastMlogID < 0) {
			throw new SyncDatabaseException("error.argument");
		}

		// get PK count
		final int pkCount = pkNames.size();

		/*
		 * generate get incremental data query
		 */
		final StringBuilder incrementalQuery = new StringBuilder();

		// delete, insert, update flag data
		incrementalQuery.append("SELECT m.d_cnt, m.i_cnt, m.u_cnt");

		// PK list
		for (short i = 1; i <= pkCount; i++) {
			incrementalQuery.append(", m.");
			incrementalQuery.append(pkNames.get(Short.valueOf(i)));
		}

		// refresh query list and flag count
		incrementalQuery.append(", d.* FROM ( SELECT ");
		incrementalQuery
				.append("SUM(CASE WHEN m.dmltype = 'D' THEN 1 ELSE 0 END) d_cnt, ");
		incrementalQuery
				.append("SUM(CASE WHEN m.dmltype = 'I' THEN 1 ELSE 0 END) i_cnt, ");
		incrementalQuery
				.append("SUM(CASE WHEN m.dmltype = 'U' THEN 1 ELSE 0 END) u_cnt");

		// PK list
		for (short i = 1; i <= pkCount; i++) {
			incrementalQuery.append(", m.");
			incrementalQuery.append(pkNames.get(Short.valueOf(i)));
		}
		// select from mlog table and mlog search condition
		incrementalQuery.append(" FROM ");
		incrementalQuery.append(mlogName);
		incrementalQuery.append(" m WHERE m.mlogid > ");
		incrementalQuery.append(lastMlogID);
		incrementalQuery.append(" GROUP BY ");

		// PK list
		for (short i = 1; i <= pkCount; i++) {
			if (i > 1) {
				incrementalQuery.append(", ");
			}

			incrementalQuery.append(pkNames.get(Short.valueOf(i)));
		}

		// joined refresh query
		incrementalQuery.append(") m LEFT OUTER JOIN ( ");
		incrementalQuery.append(query);
		incrementalQuery.append(") d ON ( ");

		// join condition
		for (short i = 1; i <= pkCount; i++) {
			if (i > 1) {
				incrementalQuery.append(" AND ");
			}
			incrementalQuery.append("m.");
			incrementalQuery.append(pkNames.get(Short.valueOf((short) i)));
			incrementalQuery.append(" = d.");
			incrementalQuery.append(pkNames.get(i));
		}

		incrementalQuery.append(")");
		log.debug("INCREMENTAL REFRESH reader query : "
				+ incrementalQuery.toString());

		return incrementalQuery.toString();
	}
}
