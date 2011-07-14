package jp.co.ntt.oss.mapper;

import java.sql.PreparedStatement;
import java.sql.Ref;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

public class RefDataMapper implements DataMapper {

	@Override
	public final Object getObject(final ResultSet rset, final int columnIndex)
			throws SQLException {
		return rset.getRef(columnIndex);
	}

	@Override
	public final void setObject(final PreparedStatement pstmt,
			final int parameterIndex, final Object x) throws SQLException {
		pstmt.setRef(parameterIndex, (Ref) x);
	}

	public static boolean isRefType(final int columnType) {
		if (columnType == Types.REF) {
			return true;
		}

		return false;
	}
}
