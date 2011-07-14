package jp.co.ntt.oss.mapper;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.net.MalformedURLException;
import java.net.URL;
import java.sql.SQLException;
import java.sql.Types;

import jp.co.ntt.oss.mapper.stub.PreparedStatementStub;
import jp.co.ntt.oss.mapper.stub.ResultSetStub;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class URLDataMapperTest {

	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {
	}

	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public final void testGetObject() {
		ResultSetStub rset = new ResultSetStub();
		URLDataMapper dm = new URLDataMapper();
		assertNotNull(dm);
		try {
			dm.getObject(rset, 123);
			assertEquals("getURL(123)", rset.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetObject() {
		PreparedStatementStub pstmt = new PreparedStatementStub();
		URLDataMapper dm = new URLDataMapper();
		assertNotNull(dm);
		try {
			try {
				dm.setObject(pstmt, 123, new URL(
						"https://www.oss.ecl.ntt.co.jp/"));
			} catch (MalformedURLException e) {
			}
			assertEquals("setURL(123, java.net.URL)", pstmt
					.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testIsURLType() {
		assertFalse(URLDataMapper.isURLType(Types.ARRAY));
		assertFalse(URLDataMapper.isURLType(Types.BIGINT));
		assertFalse(URLDataMapper.isURLType(Types.BINARY));
		assertFalse(URLDataMapper.isURLType(Types.BIT));
		assertFalse(URLDataMapper.isURLType(Types.BLOB));
		assertFalse(URLDataMapper.isURLType(Types.BOOLEAN));
		assertFalse(URLDataMapper.isURLType(Types.CHAR));
		assertFalse(URLDataMapper.isURLType(Types.CLOB));
		assertTrue(URLDataMapper.isURLType(Types.DATALINK));
		assertFalse(URLDataMapper.isURLType(Types.DATE));
		assertFalse(URLDataMapper.isURLType(Types.DECIMAL));
		assertFalse(URLDataMapper.isURLType(Types.DISTINCT));
		assertFalse(URLDataMapper.isURLType(Types.DOUBLE));
		assertFalse(URLDataMapper.isURLType(Types.FLOAT));
		assertFalse(URLDataMapper.isURLType(Types.INTEGER));
		assertFalse(URLDataMapper.isURLType(Types.JAVA_OBJECT));
		assertFalse(URLDataMapper.isURLType(Types.LONGNVARCHAR));
		assertFalse(URLDataMapper.isURLType(Types.LONGVARBINARY));
		assertFalse(URLDataMapper.isURLType(Types.LONGVARCHAR));
		assertFalse(URLDataMapper.isURLType(Types.NCHAR));
		assertFalse(URLDataMapper.isURLType(Types.NCLOB));
		assertFalse(URLDataMapper.isURLType(Types.NULL));
		assertFalse(URLDataMapper.isURLType(Types.NUMERIC));
		assertFalse(URLDataMapper.isURLType(Types.NVARCHAR));
		assertFalse(URLDataMapper.isURLType(Types.OTHER));
		assertFalse(URLDataMapper.isURLType(Types.REAL));
		assertFalse(URLDataMapper.isURLType(Types.REF));
		assertFalse(URLDataMapper.isURLType(Types.ROWID));
		assertFalse(URLDataMapper.isURLType(Types.SMALLINT));
		assertFalse(URLDataMapper.isURLType(Types.SQLXML));
		assertFalse(URLDataMapper.isURLType(Types.STRUCT));
		assertFalse(URLDataMapper.isURLType(Types.TIME));
		assertFalse(URLDataMapper.isURLType(Types.TIMESTAMP));
		assertFalse(URLDataMapper.isURLType(Types.TINYINT));
		assertFalse(URLDataMapper.isURLType(Types.VARBINARY));
		assertFalse(URLDataMapper.isURLType(Types.VARCHAR));
	}
}
