package jp.co.ntt.oss.mapper.stub;

import java.io.InputStream;
import java.io.OutputStream;
import java.io.Reader;
import java.io.Writer;
import java.sql.SQLException;
import java.sql.SQLXML;

import javax.xml.transform.Result;
import javax.xml.transform.Source;

public class SQLXMLStub implements SQLXML {

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
	public Reader getCharacterStream() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

	@Override
	public <T extends Source> T getSource(Class<T> sourceClass)
			throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

	@Override
	public String getString() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

	@Override
	public OutputStream setBinaryStream() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

	@Override
	public Writer setCharacterStream() throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

	@Override
	public <T extends Result> T setResult(Class<T> resultClass)
			throws SQLException {
		// TODO 自動生成されたメソッド・スタブ
		return null;
	}

	@Override
	public void setString(String value) throws SQLException {
		// TODO 自動生成されたメソッド・スタブ

	}

}
