package jp.co.ntt.oss.mapper;

import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

public class BigDecimalDataMapper implements DataMapper {

	@Override
	public final Object getObject(final ResultSet rset, final int columnIndex)
			throws SQLException {
		return rset.getBigDecimal(columnIndex);
	}

	@Override
	public final void setObject(final PreparedStatement pstmt,
			final int parameterIndex, final Object x) throws SQLException {
		pstmt.setBigDecimal(parameterIndex, (BigDecimal) x);
	}

	public static boolean isBigDecimalType(final int columnType) {
		if (columnType == Types.NUMERIC || columnType == Types.DECIMAL) {
			return true;
		}

		return false;
	}
}
