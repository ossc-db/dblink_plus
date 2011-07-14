package jp.co.ntt.oss.mapper;

import java.sql.Array;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

public class ArrayDataMapper implements DataMapper {

	@Override
	public final Object getObject(final ResultSet rset, final int columnIndex)
			throws SQLException {
		return rset.getArray(columnIndex);
	}

	@Override
	public final void setObject(final PreparedStatement pstmt,
			final int parameterIndex, final Object x) throws SQLException {
		pstmt.setArray(parameterIndex, (Array) x);
	}

	public static boolean isArrayType(final int columnType) {
		if (columnType == Types.ARRAY) {
			return true;
		}

		return false;
	}
}
