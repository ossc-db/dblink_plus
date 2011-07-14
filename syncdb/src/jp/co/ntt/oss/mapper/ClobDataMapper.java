package jp.co.ntt.oss.mapper;

import java.sql.Clob;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

public class ClobDataMapper implements DataMapper {

	@Override
	public final Object getObject(final ResultSet rset, final int columnIndex)
			throws SQLException {
		return rset.getClob(columnIndex);
	}

	@Override
	public final void setObject(final PreparedStatement pstmt,
			final int parameterIndex, final Object x) throws SQLException {
		pstmt.setClob(parameterIndex, (Clob) x);
	}

	public static boolean isClobType(final int columnType) {
		if (columnType == Types.CLOB) {
			return true;
		}

		return false;
	}
}
