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

public class FloatDataMapperTest {

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
		FloatDataMapper dm = new FloatDataMapper();
		Integer type = (Integer) PrivateAccessor.getPrivateField(dm, "type");
		assertNotNull(type);
		assertEquals(Types.REAL, type.intValue());

		dm.setType(Types.OTHER);
		type = (Integer) PrivateAccessor.getPrivateField(dm, "type");
		assertNotNull(type);
		assertEquals(Types.OTHER, type.intValue());
	}

	@Test
	public final void testGetObject() {
		ResultSetStub rset = new ResultSetStub();
		FloatDataMapper dm = new FloatDataMapper();
		assertNotNull(dm);
		try {
			Float result = (Float) dm.getObject(rset, 123);
			assertNotNull(result);
			assertEquals("getFloat(123)", rset.getCalled());
			result = (Float) dm.getObject(rset, 999);
			assertNull(result);
			assertEquals("getFloat(999)", rset.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetObject() {
		PreparedStatementStub pstmt = new PreparedStatementStub();
		FloatDataMapper dm = new FloatDataMapper();
		assertNotNull(dm);
		try {
			dm.setObject(pstmt, 123, new Float(1234));
			assertEquals("setFloat(123, float)", pstmt.getCalled());
			dm.setObject(pstmt, 123, null);
			assertEquals("setNull(123, 7)", pstmt.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testIsFloatType() {
		assertFalse(FloatDataMapper.isFloatType(Types.ARRAY));
		assertFalse(FloatDataMapper.isFloatType(Types.BIGINT));
		assertFalse(FloatDataMapper.isFloatType(Types.BINARY));
		assertFalse(FloatDataMapper.isFloatType(Types.BIT));
		assertFalse(FloatDataMapper.isFloatType(Types.BLOB));
		assertFalse(FloatDataMapper.isFloatType(Types.BOOLEAN));
		assertFalse(FloatDataMapper.isFloatType(Types.CHAR));
		assertFalse(FloatDataMapper.isFloatType(Types.CLOB));
		assertFalse(FloatDataMapper.isFloatType(Types.DATALINK));
		assertFalse(FloatDataMapper.isFloatType(Types.DATE));
		assertFalse(FloatDataMapper.isFloatType(Types.DECIMAL));
		assertFalse(FloatDataMapper.isFloatType(Types.DISTINCT));
		assertFalse(FloatDataMapper.isFloatType(Types.DOUBLE));
		assertFalse(FloatDataMapper.isFloatType(Types.FLOAT));
		assertFalse(FloatDataMapper.isFloatType(Types.INTEGER));
		assertFalse(FloatDataMapper.isFloatType(Types.JAVA_OBJECT));
		assertFalse(FloatDataMapper.isFloatType(Types.LONGNVARCHAR));
		assertFalse(FloatDataMapper.isFloatType(Types.LONGVARBINARY));
		assertFalse(FloatDataMapper.isFloatType(Types.LONGVARCHAR));
		assertFalse(FloatDataMapper.isFloatType(Types.NCHAR));
		assertFalse(FloatDataMapper.isFloatType(Types.NCLOB));
		assertFalse(FloatDataMapper.isFloatType(Types.NULL));
		assertFalse(FloatDataMapper.isFloatType(Types.NUMERIC));
		assertFalse(FloatDataMapper.isFloatType(Types.NVARCHAR));
		assertFalse(FloatDataMapper.isFloatType(Types.OTHER));
		assertTrue(FloatDataMapper.isFloatType(Types.REAL));
		assertFalse(FloatDataMapper.isFloatType(Types.REF));
		assertFalse(FloatDataMapper.isFloatType(Types.ROWID));
		assertFalse(FloatDataMapper.isFloatType(Types.SMALLINT));
		assertFalse(FloatDataMapper.isFloatType(Types.SQLXML));
		assertFalse(FloatDataMapper.isFloatType(Types.STRUCT));
		assertFalse(FloatDataMapper.isFloatType(Types.TIME));
		assertFalse(FloatDataMapper.isFloatType(Types.TIMESTAMP));
		assertFalse(FloatDataMapper.isFloatType(Types.TINYINT));
		assertFalse(FloatDataMapper.isFloatType(Types.VARBINARY));
		assertFalse(FloatDataMapper.isFloatType(Types.VARCHAR));
	}
}
