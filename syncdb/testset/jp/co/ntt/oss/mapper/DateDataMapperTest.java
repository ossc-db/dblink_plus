package jp.co.ntt.oss.mapper;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.sql.Date;
import java.sql.SQLException;
import java.sql.Types;

import jp.co.ntt.oss.mapper.stub.PreparedStatementStub;
import jp.co.ntt.oss.mapper.stub.ResultSetStub;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class DateDataMapperTest {

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
		DateDataMapper dm = new DateDataMapper();
		assertNotNull(dm);
		try {
			dm.getObject(rset, 123);
			assertEquals("getDate(123)", rset.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetObject() {
		PreparedStatementStub pstmt = new PreparedStatementStub();
		DateDataMapper dm = new DateDataMapper();
		assertNotNull(dm);
		try {
			dm.setObject(pstmt, 123, new Date(1234));
			assertEquals("setDate(123, java.sql.Date)", pstmt
					.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testIsDateType() {
		assertFalse(DateDataMapper.isDateType(Types.ARRAY));
		assertFalse(DateDataMapper.isDateType(Types.BIGINT));
		assertFalse(DateDataMapper.isDateType(Types.BINARY));
		assertFalse(DateDataMapper.isDateType(Types.BIT));
		assertFalse(DateDataMapper.isDateType(Types.BLOB));
		assertFalse(DateDataMapper.isDateType(Types.BOOLEAN));
		assertFalse(DateDataMapper.isDateType(Types.CHAR));
		assertFalse(DateDataMapper.isDateType(Types.CLOB));
		assertFalse(DateDataMapper.isDateType(Types.DATALINK));
		assertTrue(DateDataMapper.isDateType(Types.DATE));
		assertFalse(DateDataMapper.isDateType(Types.DECIMAL));
		assertFalse(DateDataMapper.isDateType(Types.DISTINCT));
		assertFalse(DateDataMapper.isDateType(Types.DOUBLE));
		assertFalse(DateDataMapper.isDateType(Types.FLOAT));
		assertFalse(DateDataMapper.isDateType(Types.INTEGER));
		assertFalse(DateDataMapper.isDateType(Types.JAVA_OBJECT));
		assertFalse(DateDataMapper.isDateType(Types.LONGNVARCHAR));
		assertFalse(DateDataMapper.isDateType(Types.LONGVARBINARY));
		assertFalse(DateDataMapper.isDateType(Types.LONGVARCHAR));
		assertFalse(DateDataMapper.isDateType(Types.NCHAR));
		assertFalse(DateDataMapper.isDateType(Types.NCLOB));
		assertFalse(DateDataMapper.isDateType(Types.NULL));
		assertFalse(DateDataMapper.isDateType(Types.NUMERIC));
		assertFalse(DateDataMapper.isDateType(Types.NVARCHAR));
		assertFalse(DateDataMapper.isDateType(Types.OTHER));
		assertFalse(DateDataMapper.isDateType(Types.REAL));
		assertFalse(DateDataMapper.isDateType(Types.REF));
		assertFalse(DateDataMapper.isDateType(Types.ROWID));
		assertFalse(DateDataMapper.isDateType(Types.SMALLINT));
		assertFalse(DateDataMapper.isDateType(Types.SQLXML));
		assertFalse(DateDataMapper.isDateType(Types.STRUCT));
		assertFalse(DateDataMapper.isDateType(Types.TIME));
		assertFalse(DateDataMapper.isDateType(Types.TIMESTAMP));
		assertFalse(DateDataMapper.isDateType(Types.TINYINT));
		assertFalse(DateDataMapper.isDateType(Types.VARBINARY));
		assertFalse(DateDataMapper.isDateType(Types.VARCHAR));
	}
}
