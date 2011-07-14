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

public class BooleanDataMapperTest {

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
		BooleanDataMapper dm = new BooleanDataMapper();
		Integer type = (Integer) PrivateAccessor.getPrivateField(dm, "type");
		assertNotNull(type);
		assertEquals(Types.BIT, type.intValue());

		dm.setType(Types.OTHER);
		type = (Integer) PrivateAccessor.getPrivateField(dm, "type");
		assertNotNull(type);
		assertEquals(Types.OTHER, type.intValue());
	}

	@Test
	public final void testGetObject() {
		ResultSetStub rset = new ResultSetStub();
		BooleanDataMapper dm = new BooleanDataMapper();
		assertNotNull(dm);
		try {
			Boolean result = (Boolean) dm.getObject(rset, 123);
			assertNotNull(result);
			assertEquals("getBoolean(123)", rset.getCalled());
			result = (Boolean) dm.getObject(rset, 999);
			assertNull(result);
			assertEquals("getBoolean(999)", rset.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetObject() {
		PreparedStatementStub pstmt = new PreparedStatementStub();
		BooleanDataMapper dm = new BooleanDataMapper();
		assertNotNull(dm);
		try {
			dm.setObject(pstmt, 123, Boolean.valueOf(true));
			assertEquals("setBoolean(123, boolean)", pstmt.getCalled());
			dm.setObject(pstmt, 123, null);
			assertEquals("setNull(123, -7)", pstmt.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testIsBooleanType() {
		assertFalse(BooleanDataMapper.isBooleanType(Types.ARRAY));
		assertFalse(BooleanDataMapper.isBooleanType(Types.BIGINT));
		assertFalse(BooleanDataMapper.isBooleanType(Types.BINARY));
		assertTrue(BooleanDataMapper.isBooleanType(Types.BIT));
		assertFalse(BooleanDataMapper.isBooleanType(Types.BLOB));
		assertTrue(BooleanDataMapper.isBooleanType(Types.BOOLEAN));
		assertFalse(BooleanDataMapper.isBooleanType(Types.CHAR));
		assertFalse(BooleanDataMapper.isBooleanType(Types.CLOB));
		assertFalse(BooleanDataMapper.isBooleanType(Types.DATALINK));
		assertFalse(BooleanDataMapper.isBooleanType(Types.DATE));
		assertFalse(BooleanDataMapper.isBooleanType(Types.DECIMAL));
		assertFalse(BooleanDataMapper.isBooleanType(Types.DISTINCT));
		assertFalse(BooleanDataMapper.isBooleanType(Types.DOUBLE));
		assertFalse(BooleanDataMapper.isBooleanType(Types.FLOAT));
		assertFalse(BooleanDataMapper.isBooleanType(Types.INTEGER));
		assertFalse(BooleanDataMapper.isBooleanType(Types.JAVA_OBJECT));
		assertFalse(BooleanDataMapper.isBooleanType(Types.LONGNVARCHAR));
		assertFalse(BooleanDataMapper.isBooleanType(Types.LONGVARBINARY));
		assertFalse(BooleanDataMapper.isBooleanType(Types.LONGVARCHAR));
		assertFalse(BooleanDataMapper.isBooleanType(Types.NCHAR));
		assertFalse(BooleanDataMapper.isBooleanType(Types.NCLOB));
		assertFalse(BooleanDataMapper.isBooleanType(Types.NULL));
		assertFalse(BooleanDataMapper.isBooleanType(Types.NUMERIC));
		assertFalse(BooleanDataMapper.isBooleanType(Types.NVARCHAR));
		assertFalse(BooleanDataMapper.isBooleanType(Types.OTHER));
		assertFalse(BooleanDataMapper.isBooleanType(Types.REAL));
		assertFalse(BooleanDataMapper.isBooleanType(Types.REF));
		assertFalse(BooleanDataMapper.isBooleanType(Types.ROWID));
		assertFalse(BooleanDataMapper.isBooleanType(Types.SMALLINT));
		assertFalse(BooleanDataMapper.isBooleanType(Types.SQLXML));
		assertFalse(BooleanDataMapper.isBooleanType(Types.STRUCT));
		assertFalse(BooleanDataMapper.isBooleanType(Types.TIME));
		assertFalse(BooleanDataMapper.isBooleanType(Types.TIMESTAMP));
		assertFalse(BooleanDataMapper.isBooleanType(Types.TINYINT));
		assertFalse(BooleanDataMapper.isBooleanType(Types.VARBINARY));
		assertFalse(BooleanDataMapper.isBooleanType(Types.VARCHAR));
	}
}
