package jp.co.ntt.oss.mapper;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.RowId;
import java.sql.SQLException;
import java.sql.Types;

public class RowIdDataMapper implements DataMapper {

	@Override
	public final Object getObject(final ResultSet rset, final int columnIndex)
			throws SQLException {
		return rset.getRowId(columnIndex);
	}

	@Override
	public final void setObject(final PreparedStatement pstmt,
			final int parameterIndex, final Object x) throws SQLException {
		pstmt.setRowId(parameterIndex, (RowId) x);
	}

	public static boolean isRowIdType(final int columnType) {
		if (columnType == Types.ROWID) {
			return true;
		}

		return false;
	}
}
