package jp.co.ntt.oss;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Hashtable;

import jp.co.ntt.oss.data.SyncDatabaseDAO;
import jp.co.ntt.oss.mapper.MappingData;

import org.apache.log4j.Logger;

public class IncrementalWriter implements Writer {
	private static Logger log = Logger.getLogger(IncrementalWriter.class);

	// the number of rows to batch
	private static final int BATCH_SIZE = 100;

	// flag column count (delete flag, insert flag and update flag)
	private static final int TYPE_COUNT = 3;

	private int batchCount = 0;
	private PreparedStatement deletePstmt = null;
	private PreparedStatement insertPstmt = null;
	private PreparedStatement updatePstmt = null;
	private Hashtable<Short, String> pkNames;
	private int[] pkPosition;
	private String[] columnNames;
	private MappingData columnMapping = null;
	private int execCount = 0;
	private int diffCount = 0;
	private int deleteCount = 0;
	private int insertCount = 0;
	private int updateCount = 0;

	public IncrementalWriter(final Connection conn, final String schema,
			final String table, final int columnCount,
			final Hashtable<Short, String> setPkNames) throws SQLException,
			SyncDatabaseException {
		if (conn == null || schema == null || table == null
				|| setPkNames == null || setPkNames.size() < 1
				|| columnCount < setPkNames.size() * 2) {
			throw new SyncDatabaseException("error.argument");
		}

		ResultSet rset = null;

		try {
			this.pkNames = setPkNames;
			final int pkCount = setPkNames.size();
			pkPosition = new int[pkCount];
			columnNames = new String[columnCount - pkCount];
			columnMapping = new MappingData(columnCount);

			// get database meta data
			final DatabaseMetaData dmd = conn.getMetaData();
			final String quoteString = dmd.getIdentifierQuoteString();

			// get replica table column definition
			rset = dmd.getColumns(null, schema, table, null);
			for (int i = pkCount; i < columnCount; i++) {
				if (!rset.next()) {
					throw new SyncDatabaseException("error.refreshquery");
				}

				columnMapping.setColumnType(i, rset.getInt("DATA_TYPE"));
				columnMapping.setColumnTypeName(i, rset.getString("TYPE_NAME"));
				columnNames[i - pkCount] = SyncDatabaseDAO.quoteIdent(
						quoteString, rset.getString("COLUMN_NAME"));

				// get replica table primary key definition
				for (int j = 0; j < pkCount; j++) {
					if (setPkNames.get(Short.valueOf((short) (j + 1))).equals(
							columnNames[i - pkCount])) {
						pkPosition[j] = i - pkCount;
						columnMapping
								.setColumnType(j, rset.getInt("DATA_TYPE"));
						columnMapping.setColumnTypeName(j, rset
								.getString("TYPE_NAME"));
						break;
					}
				}
			}

			if (rset.next()) {
				throw new SyncDatabaseException("error.refreshquery");
			}
		} finally {
			if (rset != null) {
				rset.close();
			}
		}
	}

	public final void close() throws SQLException {
		if (deletePstmt != null) {
			if (batchCount > 0) {
				deletePstmt.executeBatch();
			}
			deletePstmt.close();
		}
		if (insertPstmt != null) {
			if (batchCount > 0) {
				insertPstmt.executeBatch();
			}
			insertPstmt.close();
		}
		if (updatePstmt != null) {
			if (batchCount > 0) {
				updatePstmt.executeBatch();
			}
			updatePstmt.close();
		}

		batchCount = 0;
	}

	public final void prepare(final Connection conn, final String quotedTable)
			throws SyncDatabaseException, SQLException {
		if (conn == null || quotedTable == null) {
			throw new SyncDatabaseException("error.argument");
		}

		final int pkCount = pkNames.size();

		// DELETE
		StringBuilder sql = new StringBuilder("DELETE FROM " + quotedTable
				+ " WHERE ");
		for (int i = 0; i < pkCount; i++) {
			if (i > 0) {
				sql.append(" AND ");
			}

			sql.append(pkNames.get(Short.valueOf((short) (i + 1))) + " = ");
			if (columnMapping.getDataMapper(i).getClass().getName().equals(
					"jp.co.ntt.oss.mapper.OtherDataMapper")) {
				sql.append("CAST(? AS " + columnMapping.getColumnTypeName(i)
						+ ")");
			} else {
				sql.append("?");
			}
		}

		log.debug("INCREMENTAL REFRESH writer " + "delete query : "
				+ sql.toString());
		deletePstmt = conn.prepareStatement(sql.toString());

		// INSERT
		sql = new StringBuilder("INSERT INTO " + quotedTable + " VALUES(");
		for (int i = pkCount; i < columnMapping.getColumnCount(); i++) {
			if (i > pkCount) {
				sql.append(", ");
			}

			if (columnMapping.getDataMapper(i).getClass().getName().equals(
					"jp.co.ntt.oss.mapper.OtherDataMapper")) {
				sql.append("CAST(? AS " + columnMapping.getColumnTypeName(i)
						+ ")");
			} else {
				sql.append("?");
			}
		}
		sql.append(")");

		log.debug("INCREMENTAL REFRESH writer " + "insert query : "
				+ sql.toString());
		insertPstmt = conn.prepareStatement(sql.toString());

		// UPDATE
		sql = new StringBuilder("UPDATE " + quotedTable + " SET ");
		for (int i = pkCount; i < columnMapping.getColumnCount(); i++) {
			if (i > pkCount) {
				sql.append(", ");
			}

			sql.append(columnNames[i - pkCount] + " = ");
			if (columnMapping.getDataMapper(i).getClass().getName().equals(
					"jp.co.ntt.oss.mapper.OtherDataMapper")) {
				sql.append("CAST(? AS " + columnMapping.getColumnTypeName(i)
						+ ")");
			} else {
				sql.append("?");
			}
		}

		sql.append(" WHERE ");
		for (int i = 0; i < pkCount; i++) {
			if (i > 0) {
				sql.append(" AND ");
			}

			sql.append(pkNames.get(Short.valueOf((short) (i + 1))) + " = ");
			if (columnMapping.getDataMapper(i).getClass().getName().equals(
					"jp.co.ntt.oss.mapper.OtherDataMapper")) {
				sql.append("CAST(? AS " + columnMapping.getColumnTypeName(i)
						+ ")");
			} else {
				sql.append("?");
			}
		}

		log.debug("INCREMENTAL REFRESH writer " + "update query : "
				+ sql.toString());
		updatePstmt = conn.prepareStatement(sql.toString());
	}

	public final void setColumns(final Object[] columns) throws SQLException,
			SyncDatabaseException {
		if (columns == null
				|| columns.length != columnMapping.getColumnCount()
						+ TYPE_COUNT) {
			throw new SyncDatabaseException("error.argument");
		}

		execCount++;
		batchCount++;
		final int pkCount = pkNames.size();

		long deletes = ((Long) columns[0]).longValue();
		long inserts = ((Long) columns[1]).longValue();
		long updates = ((Long) columns[2]).longValue();
		boolean haveMasterData = columns[TYPE_COUNT + pkCount + pkPosition[0]] != null;
		diffCount += inserts - deletes;

		// DELETE
		if (deletes >= 1) {
			// set PK
			for (int i = 0; i < pkCount; i++) {
				columnMapping.getDataMapper(i).setObject(deletePstmt, i + 1,
						columns[i + TYPE_COUNT]);
			}

			deletePstmt.addBatch();
			// we do count up only in the case of really delete it.
			if (deletes > inserts || (deletes == inserts && haveMasterData)) {
				deleteCount++;
			}
		}

		// have SELECT list data
		if (haveMasterData) {
			if (inserts >= 1) {
				// INSERT
				// set value
				for (int i = 0; i < columnMapping.getColumnCount() - pkCount; i++) {
					columnMapping.getDataMapper(i + pkCount).setObject(
							insertPstmt, i + 1,
							columns[i + TYPE_COUNT + pkCount]);
				}

				insertPstmt.addBatch();
				insertCount++;
			} else if (updates >= 1) {
				// UPDATE
				// set value
				for (int i = 0; i < columnMapping.getColumnCount() - pkCount; i++) {
					columnMapping.getDataMapper(i + pkCount).setObject(
							updatePstmt, i + 1,
							columns[i + TYPE_COUNT + pkCount]);
				}

				// set PK
				for (int i = 0; i < pkCount; i++) {
					columnMapping.getDataMapper(i).setObject(updatePstmt,
							i + columnMapping.getColumnCount() - pkCount + 1,
							columns[i + TYPE_COUNT]);
				}

				updatePstmt.addBatch();
				updateCount++;
			} else {
				throw new SyncDatabaseException("error.mlog_illegal");
			}
		}

		if (batchCount >= BATCH_SIZE) {
			deletePstmt.executeBatch();
			insertPstmt.executeBatch();
			updatePstmt.executeBatch();
			batchCount = 0;
		}
	}

	public final int getColumnCount() {
		return columnMapping.getColumnCount();
	}

	public final MappingData getColumnMapping() {
		return columnMapping;
	}

	public final int getExecCount() {
		return execCount;
	}

	public final int getDiffCount() {
		return diffCount;
	}

	public final long getDeleteCount() {
		return deleteCount;
	}

	public final long getInsertCount() {
		return insertCount;
	}

	public final int getUpdateCount() {
		return updateCount;
	}
}
