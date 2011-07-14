package jp.co.ntt.oss.mapper;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;

public class TimestampDataMapper implements DataMapper {

	@Override
	public final Object getObject(final ResultSet rset, final int columnIndex)
			throws SQLException {
		return rset.getTimestamp(columnIndex);
	}

	@Override
	public final void setObject(final PreparedStatement pstmt,
			final int parameterIndex, final Object x) throws SQLException {
		pstmt.setTimestamp(parameterIndex, (Timestamp) x);
	}

	public static boolean isTimestampType(final int columnType) {
		if (columnType == Types.TIMESTAMP) {
			return true;
		}

		return false;
	}
}
