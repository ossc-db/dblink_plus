package jp.co.ntt.oss;

import java.sql.Connection;
import java.sql.SQLException;

import jp.co.ntt.oss.mapper.MappingData;

public interface Writer {
	void close() throws SQLException;

	void prepare(Connection conn, String quotedTable)
			throws SyncDatabaseException, SQLException;

	void setColumns(Object[] columns) throws SQLException,
			SyncDatabaseException;

	int getColumnCount();

	MappingData getColumnMapping();
}
