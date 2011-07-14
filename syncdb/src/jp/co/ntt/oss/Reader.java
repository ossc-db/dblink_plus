package jp.co.ntt.oss;

import java.sql.SQLException;

import jp.co.ntt.oss.mapper.MappingData;

public interface Reader {
	void close() throws SQLException;

	Object[] getNextColumns() throws SQLException, SyncDatabaseException;

	int getColumnCount();

	MappingData getColumnMapping();
}
