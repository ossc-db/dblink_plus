package jp.co.ntt.oss.mapper;

import java.sql.NClob;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

public class NClobDataMapper implements DataMapper {

	@Override
	public final Object getObject(final ResultSet rset, final int columnIndex)
			throws SQLException {
		return rset.getNClob(columnIndex);
	}

	@Override
	public final void setObject(final PreparedStatement pstmt,
			final int parameterIndex, final Object x) throws SQLException {
		pstmt.setNClob(parameterIndex, (NClob) x);
	}

	public static boolean isNClobType(final int columnType) {
		if (columnType == Types.NCLOB) {
			return true;
		}

		return false;
	}
}
