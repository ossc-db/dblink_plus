package jp.co.ntt.oss.mapper;

import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

public class DateDataMapper implements DataMapper {

	@Override
	public final Object getObject(final ResultSet rset, final int columnIndex)
			throws SQLException {
		return rset.getDate(columnIndex);
	}

	@Override
	public final void setObject(final PreparedStatement pstmt,
			final int parameterIndex, final Object x) throws SQLException {
		pstmt.setDate(parameterIndex, (Date) x);
	}

	public static boolean isDateType(final int columnType) {
		if (columnType == Types.DATE) {
			return true;
		}

		return false;
	}
}
