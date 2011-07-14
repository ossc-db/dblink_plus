package jp.co.ntt.oss.mapper;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

public class StringDataMapper implements DataMapper {

	@Override
	public final Object getObject(final ResultSet rset, final int columnIndex)
			throws SQLException {
		return rset.getString(columnIndex);
	}

	@Override
	public final void setObject(final PreparedStatement pstmt,
			final int parameterIndex, final Object x) throws SQLException {
		pstmt.setString(parameterIndex, (String) x);
	}

	public static boolean isStringType(final int columnType) {
		if (columnType == Types.CHAR || columnType == Types.VARCHAR
				|| columnType == Types.LONGVARCHAR || columnType == Types.NCHAR
				|| columnType == Types.NVARCHAR
				|| columnType == Types.LONGNVARCHAR) {
			return true;
		}

		return false;
	}
}
