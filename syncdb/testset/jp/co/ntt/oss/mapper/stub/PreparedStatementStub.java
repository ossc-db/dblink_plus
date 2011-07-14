package jp.co.ntt.oss.mapper.stub;

import java.io.InputStream;
import java.io.Reader;
import java.math.BigDecimal;
import java.net.URL;
import java.sql.Array;
import java.sql.Blob;
import java.sql.Clob;
import java.sql.Connection;
import java.sql.Date;
import java.sql.NClob;
import java.sql.ParameterMetaData;
import java.sql.PreparedStatement;
import java.sql.Ref;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.RowId;
import java.sql.SQLException;
import java.sql.SQLWarning;
import java.sql.SQLXML;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.Calendar;

public class PreparedStatementStub implements PreparedStatement {
	String called = "not call";

	public String getCalled() {
		return called;
	}

	public void setCalled(String called) {
		this.called = called;
	}

	@Override
	public void addBatch() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void clearParameters() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public boolean execute() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return false;
	}

	@Override
	public ResultSet executeQuery() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

	@Override
	public int executeUpdate() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return 0;
	}

	@Override
	public ResultSetMetaData getMetaData() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

	@Override
	public ParameterMetaData getParameterMetaData() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

	@Override
	public void setArray(int parameterIndex, Array x) throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", " + x.getClass().getName() + ")";
	}

	@Override
	public void setAsciiStream(int parameterIndex, InputStream x)
			throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", " + x.getClass().getName() + ")";
	}

	@Override
	public void setAsciiStream(int parameterIndex, InputStream x, int length)
			throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void setAsciiStream(int parameterIndex, InputStream x, long length)
			throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void setBigDecimal(int parameterIndex, BigDecimal x)
			throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", " + x.getClass().getName() + ")";
	}

	@Override
	public void setBinaryStream(int parameterIndex, InputStream x)
			throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", " + x.getClass().getName() + ")";
	}

	@Override
	public void setBinaryStream(int parameterIndex, InputStream x, int length)
			throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void setBinaryStream(int parameterIndex, InputStream x, long length)
			throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void setBlob(int parameterIndex, Blob x) throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", " + x.getClass().getName() + ")";
	}

	@Override
	public void setBlob(int parameterIndex, InputStream inputStream)
			throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", "
				+ inputStream.getClass().getName() + ")";
	}

	@Override
	public void setBlob(int parameterIndex, InputStream inputStream, long length)
			throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void setBoolean(int parameterIndex, boolean x) throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", boolean)";
	}

	@Override
	public void setByte(int parameterIndex, byte x) throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", byte)";
	}

	@Override
	public void setBytes(int parameterIndex, byte[] x) throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", byte[])";
	}

	@Override
	public void setCharacterStream(int parameterIndex, Reader reader)
			throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", " + reader.getClass().getName()
				+ ")";
	}

	@Override
	public void setCharacterStream(int parameterIndex, Reader reader, int length)
			throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void setCharacterStream(int parameterIndex, Reader reader,
			long length) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void setClob(int parameterIndex, Clob x) throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", " + x.getClass().getName() + ")";
	}

	@Override
	public void setClob(int parameterIndex, Reader reader) throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", " + reader.getClass().getName()
				+ ")";
	}

	@Override
	public void setClob(int parameterIndex, Reader reader, long length)
			throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void setDate(int parameterIndex, Date x) throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", " + x.getClass().getName() + ")";
	}

	@Override
	public void setDate(int parameterIndex, Date x, Calendar cal)
			throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void setDouble(int parameterIndex, double x) throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", double)";
	}

	@Override
	public void setFloat(int parameterIndex, float x) throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", float)";
	}

	@Override
	public void setInt(int parameterIndex, int x) throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", int)";
	}

	@Override
	public void setLong(int parameterIndex, long x) throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", long)";
	}

	@Override
	public void setNCharacterStream(int parameterIndex, Reader value)
			throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", " + value.getClass().getName()
				+ ")";
	}

	@Override
	public void setNCharacterStream(int parameterIndex, Reader value,
			long length) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void setNClob(int parameterIndex, NClob value) throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", " + value.getClass().getName()
				+ ")";
	}

	@Override
	public void setNClob(int parameterIndex, Reader reader) throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", " + reader.getClass().getName()
				+ ")";
	}

	@Override
	public void setNClob(int parameterIndex, Reader reader, long length)
			throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void setNString(int parameterIndex, String value)
			throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", " + value.getClass().getName()
				+ ")";
	}

	@Override
	public void setNull(int parameterIndex, int sqlType) throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", " + sqlType + ")";
	}

	@Override
	public void setNull(int parameterIndex, int sqlType, String typeName)
			throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void setObject(int parameterIndex, Object x) throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", " + x.getClass().getName() + ")";
	}

	@Override
	public void setObject(int parameterIndex, Object x, int targetSqlType)
			throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void setObject(int parameterIndex, Object x, int targetSqlType,
			int scaleOrLength) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void setRef(int parameterIndex, Ref x) throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", " + x.getClass().getName() + ")";
	}

	@Override
	public void setRowId(int parameterIndex, RowId x) throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", " + x.getClass().getName() + ")";
	}

	@Override
	public void setSQLXML(int parameterIndex, SQLXML xmlObject)
			throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", " + xmlObject.getClass().getName()
				+ ")";
	}

	@Override
	public void setShort(int parameterIndex, short x) throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", short)";
	}

	@Override
	public void setString(int parameterIndex, String x) throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", " + x.getClass().getName() + ")";
	}

	@Override
	public void setTime(int parameterIndex, Time x) throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", " + x.getClass().getName() + ")";
	}

	@Override
	public void setTime(int parameterIndex, Time x, Calendar cal)
			throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void setTimestamp(int parameterIndex, Timestamp x)
			throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", " + x.getClass().getName() + ")";
	}

	@Override
	public void setTimestamp(int parameterIndex, Timestamp x, Calendar cal)
			throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void setURL(int parameterIndex, URL x) throws SQLException {
		called = Thread.currentThread().getStackTrace()[1].getMethodName()
				+ "(" + parameterIndex + ", " + x.getClass().getName() + ")";
	}

	@Override
	public void setUnicodeStream(int parameterIndex, InputStream x, int length)
			throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void addBatch(String arg0) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void cancel() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void clearBatch() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void clearWarnings() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void close() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public boolean execute(String arg0) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return false;
	}

	@Override
	public boolean execute(String arg0, int arg1) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return false;
	}

	@Override
	public boolean execute(String arg0, int[] arg1) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return false;
	}

	@Override
	public boolean execute(String arg0, String[] arg1) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return false;
	}

	@Override
	public int[] executeBatch() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

	@Override
	public ResultSet executeQuery(String arg0) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

	@Override
	public int executeUpdate(String arg0) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return 0;
	}

	@Override
	public int executeUpdate(String arg0, int arg1) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return 0;
	}

	@Override
	public int executeUpdate(String arg0, int[] arg1) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return 0;
	}

	@Override
	public int executeUpdate(String arg0, String[] arg1) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return 0;
	}

	@Override
	public Connection getConnection() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

	@Override
	public int getFetchDirection() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return 0;
	}

	@Override
	public int getFetchSize() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return 0;
	}

	@Override
	public ResultSet getGeneratedKeys() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

	@Override
	public int getMaxFieldSize() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return 0;
	}

	@Override
	public int getMaxRows() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return 0;
	}

	@Override
	public boolean getMoreResults() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return false;
	}

	@Override
	public boolean getMoreResults(int arg0) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return false;
	}

	@Override
	public int getQueryTimeout() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return 0;
	}

	@Override
	public ResultSet getResultSet() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

	@Override
	public int getResultSetConcurrency() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return 0;
	}

	@Override
	public int getResultSetHoldability() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return 0;
	}

	@Override
	public int getResultSetType() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return 0;
	}

	@Override
	public int getUpdateCount() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return 0;
	}

	@Override
	public SQLWarning getWarnings() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

	@Override
	public boolean isClosed() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return false;
	}

	@Override
	public boolean isPoolable() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return false;
	}

	@Override
	public void setCursorName(String arg0) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void setEscapeProcessing(boolean arg0) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void setFetchDirection(int arg0) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void setFetchSize(int arg0) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void setMaxFieldSize(int arg0) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void setMaxRows(int arg0) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void setPoolable(boolean arg0) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public void setQueryTimeout(int arg0) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public boolean isWrapperFor(Class<?> iface) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return false;
	}

	@Override
	public <T> T unwrap(Class<T> iface) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

}
