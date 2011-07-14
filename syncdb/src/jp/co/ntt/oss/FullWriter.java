package jp.co.ntt.oss;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jp.co.ntt.oss.mapper.MappingData;

import org.apache.log4j.Logger;

public class FullWriter implements Writer {
	private static Logger log = Logger.getLogger(FullWriter.class);

	// the number of rows to batch
	private static final int BATCH_SIZE = 100;

	private int batchCount = 0;
	private PreparedStatement pstmt = null;
	private MappingData columnMapping = null;

	public FullWriter(final Connection conn, final String schema,
			final String table, final int columnCount) throws SQLException,
			SyncDatabaseException {
		if (conn == null || schema == null || table == null || columnCount < 1) {
			throw new SyncDatabaseException("error.argument");
		}

		ResultSet rset = null;

		try {
			columnMapping = new MappingData(columnCount);

			// get database meta data
			final DatabaseMetaData dmd = conn.getMetaData();
			rset = dmd.getColumns(null, schema, table, null);
			int i = 0;
			while (rset.next()) {
				if (i >= columnCount) {
					throw new SyncDatabaseException("error.refreshquery");
				}

				columnMapping.setColumnType(i, rset.getInt("DATA_TYPE"));
				columnMapping.setColumnTypeName(i, rset.getString("TYPE_NAME"));
				i++;
			}

			if (i < columnCount) {
				throw new SyncDatabaseException("error.refreshquery");
			}
		} finally {
			if (rset != null) {
				rset.close();
			}
		}
	}

	public final void close() throws SQLException {
		if (pstmt != null) {
			if (batchCount > 0) {
				pstmt.executeBatch();
			}
			pstmt.close();
		}

		batchCount = 0;
	}

	public final void prepare(final Connection conn, final String quotedTable)
			throws SyncDatabaseException, SQLException {
		if (conn == null || quotedTable == null) {
			throw new SyncDatabaseException("error.argument");
		}

		final StringBuilder sql = new StringBuilder("INSERT INTO "
				+ quotedTable + " VALUES(");
		for (int i = 0; i < columnMapping.getColumnCount(); i++) {
			if (i > 0) {
				sql.append(",");
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
		log.debug("FULL REFRESH writer query : " + sql.toString());

		pstmt = conn.prepareStatement(sql.toString());
	}

	public final void setColumns(final Object[] columns) throws SQLException,
			SyncDatabaseException {
		if (columns == null || columns.length != columnMapping.getColumnCount()) {
			throw new SyncDatabaseException("error.argument");
		}

		batchCount++;
		// set column data
		for (int i = 0; i < columnMapping.getColumnCount(); i++) {
			columnMapping.getDataMapper(i).setObject(pstmt, i + 1, columns[i]);
		}

		pstmt.addBatch();
		if (batchCount >= BATCH_SIZE) {
			pstmt.executeBatch();
			batchCount = 0;
		}
	}

	public final int getColumnCount() {
		return columnMapping.getColumnCount();
	}

	public final MappingData getColumnMapping() {
		return columnMapping;
	}
}
