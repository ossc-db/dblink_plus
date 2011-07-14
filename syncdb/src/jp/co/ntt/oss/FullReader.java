package jp.co.ntt.oss;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;

import jp.co.ntt.oss.mapper.MappingData;

public class FullReader implements Reader {
	// the number of rows to fetch
	private static final int FETCH_SIZE = 100;

	private Statement stmt = null;
	private ResultSet rset = null;
	private MappingData columnMapping = null;

	public FullReader(final Connection conn, final String query)
			throws SQLException, SyncDatabaseException {
		if (conn == null || query == null) {
			throw new SyncDatabaseException("error.argument");
		}

		try {
			stmt = conn.createStatement();
			stmt.setFetchSize(FETCH_SIZE);
			rset = stmt.executeQuery(query);

			final ResultSetMetaData rmd = rset.getMetaData();
			final int columnCount = rmd.getColumnCount();
			columnMapping = new MappingData(columnCount);
			for (int i = 0; i < columnCount; i++) {
				columnMapping.setColumnType(i, rmd.getColumnType(i + 1));
				columnMapping
						.setColumnTypeName(i, rmd.getColumnTypeName(i + 1));
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

		final Object[] columns = new Object[columnMapping.getColumnCount()];

		// get column data
		for (int i = 0; i < columnMapping.getColumnCount(); i++) {
			columns[i] = columnMapping.getDataMapper(i).getObject(rset, i + 1);
		}

		return columns;
	}

	public final int getColumnCount() {
		return columnMapping.getColumnCount();
	}

	public final MappingData getColumnMapping() {
		return columnMapping;
	}

}
