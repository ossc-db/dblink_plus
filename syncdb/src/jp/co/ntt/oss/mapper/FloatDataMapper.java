package jp.co.ntt.oss.mapper;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

public class FloatDataMapper implements DataMapper {
	private int type = Types.REAL;

	public final void setType(final int setType) {
		this.type = setType;
	}

	@Override
	public final Object getObject(final ResultSet rset, final int columnIndex)
			throws SQLException {
		float result = rset.getFloat(columnIndex);
		if (result == 0 && rset.wasNull()) {
			return null;
		}

		return new Float(result);
	}

	@Override
	public final void setObject(final PreparedStatement pstmt,
			final int parameterIndex, final Object x) throws SQLException {
		if (x == null) {
			pstmt.setNull(parameterIndex, type);
		} else {
			pstmt.setFloat(parameterIndex, ((Float) x).floatValue());
		}
	}

	public static boolean isFloatType(final int columnType) {
		if (columnType == Types.REAL) {
			return true;
		}

		return false;
	}
}
