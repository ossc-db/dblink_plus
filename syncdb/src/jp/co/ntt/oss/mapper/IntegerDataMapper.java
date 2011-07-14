package jp.co.ntt.oss.mapper;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

public class IntegerDataMapper implements DataMapper {
	private int type = Types.INTEGER;

	public final void setType(final int setType) {
		this.type = setType;
	}

	@Override
	public final Object getObject(final ResultSet rset, final int columnIndex)
			throws SQLException {
		int result = rset.getInt(columnIndex);
		if (result == 0 && rset.wasNull()) {
			return null;
		}

		return Integer.valueOf(result);
	}

	@Override
	public final void setObject(final PreparedStatement pstmt,
			final int parameterIndex, final Object x) throws SQLException {
		if (x == null) {
			pstmt.setNull(parameterIndex, type);
		} else {
			pstmt.setInt(parameterIndex, ((Integer) x).intValue());
		}
	}

	public static boolean isIntegerType(final int columnType) {
		if (columnType == Types.INTEGER || columnType == Types.TINYINT
				|| columnType == Types.SMALLINT) {
			return true;
		}

		return false;
	}
}
