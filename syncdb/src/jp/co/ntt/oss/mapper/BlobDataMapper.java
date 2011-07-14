package jp.co.ntt.oss.mapper;

import java.sql.Blob;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

public class BlobDataMapper implements DataMapper {

	@Override
	public final Object getObject(final ResultSet rset, final int columnIndex)
			throws SQLException {
		return rset.getBlob(columnIndex);
	}

	@Override
	public final void setObject(final PreparedStatement pstmt,
			final int parameterIndex, final Object x) throws SQLException {
		pstmt.setBlob(parameterIndex, (Blob) x);
	}

	public static boolean isBlobType(final int columnType) {
		if (columnType == Types.BLOB) {
			return true;
		}

		return false;
	}
}
