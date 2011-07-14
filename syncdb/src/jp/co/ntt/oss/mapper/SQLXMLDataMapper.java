package jp.co.ntt.oss.mapper;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLXML;
import java.sql.Types;

public class SQLXMLDataMapper implements DataMapper {

	@Override
	public final Object getObject(final ResultSet rset, final int columnIndex)
			throws SQLException {
		return rset.getSQLXML(columnIndex);
	}

	@Override
	public final void setObject(final PreparedStatement pstmt,
			final int parameterIndex, final Object x) throws SQLException {
		pstmt.setSQLXML(parameterIndex, (SQLXML) x);
	}

	public static boolean isSQLXMLType(final int columnType) {
		if (columnType == Types.SQLXML) {
			return true;
		}

		return false;
	}
}
