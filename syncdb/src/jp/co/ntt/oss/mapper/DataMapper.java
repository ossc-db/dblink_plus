package jp.co.ntt.oss.mapper;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public interface DataMapper {

	/*
	 * Gets the value of the designated column in the current row of this
	 * ResultSet object.
	 */
	Object getObject(ResultSet rset, int columnIndex) throws SQLException;

	/*
	 * Sets the value of the designated parameter using the given object.
	 */
	void setObject(PreparedStatement pstmt, int parameterIndex, Object x)
			throws SQLException;
}
