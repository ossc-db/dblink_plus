package jp.co.ntt.oss.mapper;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

public class LongDataMapper implements DataMapper {
	private int type = Types.BIGINT;

	public final void setType(final int setType) {
		this.type = setType;
	}

	@Override
	public final Object getObject(final ResultSet rset, final int columnIndex)
			throws SQLException {
		long result = rset.getLong(columnIndex);
		if (result == 0 && rset.wasNull()) {
			return null;
		}

		return Long.valueOf(result);
	}

	@Override
	public final void setObject(final PreparedStatement pstmt,
			final int parameterIndex, final Object x) throws SQLException {
		if (x == null) {
			pstmt.setNull(parameterIndex, type);
		} else {
			pstmt.setLong(parameterIndex, ((Long) x).longValue());
		}
	}

	public static boolean isLongType(final int columnType) {
		if (columnType == Types.BIGINT) {
			return true;
		}

		return false;
	}
}
