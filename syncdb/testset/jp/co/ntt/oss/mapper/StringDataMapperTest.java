package jp.co.ntt.oss.mapper;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.sql.SQLException;
import java.sql.Types;

import jp.co.ntt.oss.mapper.stub.PreparedStatementStub;
import jp.co.ntt.oss.mapper.stub.ResultSetStub;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class StringDataMapperTest {

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
		StringDataMapper dm = new StringDataMapper();
		assertNotNull(dm);
		try {
			dm.getObject(rset, 123);
			assertEquals("getString(123)", rset.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetObject() {
		PreparedStatementStub pstmt = new PreparedStatementStub();
		StringDataMapper dm = new StringDataMapper();
		assertNotNull(dm);
		try {
			dm.setObject(pstmt, 123, "1234");
			assertEquals("setString(123, java.lang.String)", pstmt.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testIsStringType() {
		assertFalse(StringDataMapper.isStringType(Types.ARRAY));
		assertFalse(StringDataMapper.isStringType(Types.BIGINT));
		assertFalse(StringDataMapper.isStringType(Types.BINARY));
		assertFalse(StringDataMapper.isStringType(Types.BIT));
		assertFalse(StringDataMapper.isStringType(Types.BLOB));
		assertFalse(StringDataMapper.isStringType(Types.BOOLEAN));
		assertTrue(StringDataMapper.isStringType(Types.CHAR));
		assertFalse(StringDataMapper.isStringType(Types.CLOB));
		assertFalse(StringDataMapper.isStringType(Types.DATALINK));
		assertFalse(StringDataMapper.isStringType(Types.DATE));
		assertFalse(StringDataMapper.isStringType(Types.DECIMAL));
		assertFalse(StringDataMapper.isStringType(Types.DISTINCT));
		assertFalse(StringDataMapper.isStringType(Types.DOUBLE));
		assertFalse(StringDataMapper.isStringType(Types.FLOAT));
		assertFalse(StringDataMapper.isStringType(Types.INTEGER));
		assertFalse(StringDataMapper.isStringType(Types.JAVA_OBJECT));
		assertTrue(StringDataMapper.isStringType(Types.LONGNVARCHAR));
		assertFalse(StringDataMapper.isStringType(Types.LONGVARBINARY));
		assertTrue(StringDataMapper.isStringType(Types.LONGVARCHAR));
		assertTrue(StringDataMapper.isStringType(Types.NCHAR));
		assertFalse(StringDataMapper.isStringType(Types.NCLOB));
		assertFalse(StringDataMapper.isStringType(Types.NULL));
		assertFalse(StringDataMapper.isStringType(Types.NUMERIC));
		assertTrue(StringDataMapper.isStringType(Types.NVARCHAR));
		assertFalse(StringDataMapper.isStringType(Types.OTHER));
		assertFalse(StringDataMapper.isStringType(Types.REAL));
		assertFalse(StringDataMapper.isStringType(Types.REF));
		assertFalse(StringDataMapper.isStringType(Types.ROWID));
		assertFalse(StringDataMapper.isStringType(Types.SMALLINT));
		assertFalse(StringDataMapper.isStringType(Types.SQLXML));
		assertFalse(StringDataMapper.isStringType(Types.STRUCT));
		assertFalse(StringDataMapper.isStringType(Types.TIME));
		assertFalse(StringDataMapper.isStringType(Types.TIMESTAMP));
		assertFalse(StringDataMapper.isStringType(Types.TINYINT));
		assertFalse(StringDataMapper.isStringType(Types.VARBINARY));
		assertTrue(StringDataMapper.isStringType(Types.VARCHAR));
	}
}
