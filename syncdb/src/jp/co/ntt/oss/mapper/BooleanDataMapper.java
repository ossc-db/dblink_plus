package jp.co.ntt.oss.mapper;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

public class BooleanDataMapper implements DataMapper {
	private int type = Types.BIT;

	public final void setType(final int setType) {
		this.type = setType;
	}

	@Override
	public final Object getObject(final ResultSet rset, final int columnIndex)
			throws SQLException {
		boolean result = rset.getBoolean(columnIndex);
		if (!result && rset.wasNull()) {
			return null;
		}

		return Boolean.valueOf(result);
	}

	@Override
	public final void setObject(final PreparedStatement pstmt,
			final int parameterIndex, final Object x) throws SQLException {
		if (x == null) {
			pstmt.setNull(parameterIndex, type);
		} else {
			pstmt.setBoolean(parameterIndex, ((Boolean) x).booleanValue());
		}
	}

	public static boolean isBooleanType(final int columnType) {
		if (columnType == Types.BIT || columnType == Types.BOOLEAN) {
			return true;
		}

		return false;
	}
}
