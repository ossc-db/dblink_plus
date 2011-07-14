package jp.co.ntt.oss.mapper;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

public class DoubleDataMapper implements DataMapper {
	private int type = Types.DOUBLE;

	public final void setType(final int setType) {
		this.type = setType;
	}

	@Override
	public final Object getObject(final ResultSet rset, final int columnIndex)
			throws SQLException {
		double result = rset.getDouble(columnIndex);
		if (result == 0 && rset.wasNull()) {
			return null;
		}

		return new Double(result);
	}

	@Override
	public final void setObject(final PreparedStatement pstmt,
			final int parameterIndex, final Object x) throws SQLException {
		if (x == null) {
			pstmt.setNull(parameterIndex, type);
		} else {
			pstmt.setDouble(parameterIndex, ((Double) x).doubleValue());
		}
	}

	public static boolean isDoubleType(final int columnType) {
		if (columnType == Types.DOUBLE || columnType == Types.FLOAT) {
			return true;
		}

		return false;
	}
}
