package jp.co.ntt.oss.mapper;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

public class BytesDataMapper implements DataMapper {

	@Override
	public final Object getObject(final ResultSet rset, final int columnIndex)
			throws SQLException {
		return rset.getBytes(columnIndex);
	}

	@Override
	public final void setObject(final PreparedStatement pstmt,
			final int parameterIndex, final Object x) throws SQLException {
		pstmt.setBytes(parameterIndex, (byte[]) x);
	}

	public static boolean isBytesType(final int columnType) {
		if (columnType == Types.BINARY || columnType == Types.VARBINARY
				|| columnType == Types.LONGVARBINARY) {
			return true;
		}

		return false;
	}
}
