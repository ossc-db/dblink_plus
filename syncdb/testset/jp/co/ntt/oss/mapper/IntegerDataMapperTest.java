package jp.co.ntt.oss.mapper;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.sql.SQLException;
import java.sql.Types;

import jp.co.ntt.oss.mapper.stub.PreparedStatementStub;
import jp.co.ntt.oss.mapper.stub.ResultSetStub;
import jp.co.ntt.oss.utility.PrivateAccessor;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class IntegerDataMapperTest {

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
	public final void testSetTypes() {
		IntegerDataMapper dm = new IntegerDataMapper();
		Integer type = (Integer) PrivateAccessor.getPrivateField(dm, "type");
		assertNotNull(type);
		assertEquals(Types.INTEGER, type.intValue());

		dm.setType(Types.OTHER);
		type = (Integer) PrivateAccessor.getPrivateField(dm, "type");
		assertNotNull(type);
		assertEquals(Types.OTHER, type.intValue());
	}

	@Test
	public final void testGetObject() {
		ResultSetStub rset = new ResultSetStub();
		IntegerDataMapper dm = new IntegerDataMapper();
		assertNotNull(dm);
		try {
			Integer result = (Integer) dm.getObject(rset, 123);
			assertNotNull(result);
			assertEquals("getInt(123)", rset.getCalled());
			result = (Integer) dm.getObject(rset, 999);
			assertNull(result);
			assertEquals("getInt(999)", rset.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetObject() {
		PreparedStatementStub pstmt = new PreparedStatementStub();
		IntegerDataMapper dm = new IntegerDataMapper();
		assertNotNull(dm);
		try {
			dm.setObject(pstmt, 123, new Integer(1234));
			assertEquals("setInt(123, int)", pstmt.getCalled());
			dm.setObject(pstmt, 123, null);
			assertEquals("setNull(123, 4)", pstmt.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testIsIntegerType() {
		assertFalse(IntegerDataMapper.isIntegerType(Types.ARRAY));
		assertFalse(IntegerDataMapper.isIntegerType(Types.BIGINT));
		assertFalse(IntegerDataMapper.isIntegerType(Types.BINARY));
		assertFalse(IntegerDataMapper.isIntegerType(Types.BIT));
		assertFalse(IntegerDataMapper.isIntegerType(Types.BLOB));
		assertFalse(IntegerDataMapper.isIntegerType(Types.BOOLEAN));
		assertFalse(IntegerDataMapper.isIntegerType(Types.CHAR));
		assertFalse(IntegerDataMapper.isIntegerType(Types.CLOB));
		assertFalse(IntegerDataMapper.isIntegerType(Types.DATALINK));
		assertFalse(IntegerDataMapper.isIntegerType(Types.DATE));
		assertFalse(IntegerDataMapper.isIntegerType(Types.DECIMAL));
		assertFalse(IntegerDataMapper.isIntegerType(Types.DISTINCT));
		assertFalse(IntegerDataMapper.isIntegerType(Types.DOUBLE));
		assertFalse(IntegerDataMapper.isIntegerType(Types.FLOAT));
		assertTrue(IntegerDataMapper.isIntegerType(Types.INTEGER));
		assertFalse(IntegerDataMapper.isIntegerType(Types.JAVA_OBJECT));
		assertFalse(IntegerDataMapper.isIntegerType(Types.LONGNVARCHAR));
		assertFalse(IntegerDataMapper.isIntegerType(Types.LONGVARBINARY));
		assertFalse(IntegerDataMapper.isIntegerType(Types.LONGVARCHAR));
		assertFalse(IntegerDataMapper.isIntegerType(Types.NCHAR));
		assertFalse(IntegerDataMapper.isIntegerType(Types.NCLOB));
		assertFalse(IntegerDataMapper.isIntegerType(Types.NULL));
		assertFalse(IntegerDataMapper.isIntegerType(Types.NUMERIC));
		assertFalse(IntegerDataMapper.isIntegerType(Types.NVARCHAR));
		assertFalse(IntegerDataMapper.isIntegerType(Types.OTHER));
		assertFalse(IntegerDataMapper.isIntegerType(Types.REAL));
		assertFalse(IntegerDataMapper.isIntegerType(Types.REF));
		assertFalse(IntegerDataMapper.isIntegerType(Types.ROWID));
		assertTrue(IntegerDataMapper.isIntegerType(Types.SMALLINT));
		assertFalse(IntegerDataMapper.isIntegerType(Types.SQLXML));
		assertFalse(IntegerDataMapper.isIntegerType(Types.STRUCT));
		assertFalse(IntegerDataMapper.isIntegerType(Types.TIME));
		assertFalse(IntegerDataMapper.isIntegerType(Types.TIMESTAMP));
		assertTrue(IntegerDataMapper.isIntegerType(Types.TINYINT));
		assertFalse(IntegerDataMapper.isIntegerType(Types.VARBINARY));
		assertFalse(IntegerDataMapper.isIntegerType(Types.VARCHAR));
	}
}
