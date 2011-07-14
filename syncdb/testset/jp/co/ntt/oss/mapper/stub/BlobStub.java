package jp.co.ntt.oss.mapper.stub;

import java.io.InputStream;
import java.io.OutputStream;
import java.sql.Blob;
import java.sql.SQLException;

public class BlobStub implements Blob {

	@Override
	public void free() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

	@Override
	public InputStream getBinaryStream() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

	@Override
	public InputStream getBinaryStream(long pos, long length)
			throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

	@Override
	public byte[] getBytes(long pos, int length) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

	@Override
	public long length() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return 0;
	}

	@Override
	public long position(byte[] pattern, long start) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return 0;
	}

	@Override
	public long position(Blob pattern, long start) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return 0;
	}

	@Override
	public OutputStream setBinaryStream(long pos) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

	@Override
	public int setBytes(long pos, byte[] bytes) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return 0;
	}

	@Override
	public int setBytes(long pos, byte[] bytes, int offset, int len)
			throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return 0;
	}

	@Override
	public void truncate(long len) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

}
