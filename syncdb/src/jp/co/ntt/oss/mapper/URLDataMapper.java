package jp.co.ntt.oss.mapper;

import java.net.URL;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

public class URLDataMapper implements DataMapper {

	@Override
	public final Object getObject(final ResultSet rset, final int columnIndex)
			throws SQLException {
		return rset.getURL(columnIndex);
	}

	@Override
	public final void setObject(final PreparedStatement pstmt,
			final int parameterIndex, final Object x) throws SQLException {
		pstmt.setURL(parameterIndex, (URL) x);
	}

	public static boolean isURLType(final int columnType) {
		if (columnType == Types.DATALINK) {
			return true;
		}

		return false;
	}
}
