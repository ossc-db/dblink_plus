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

public class DoubleDataMapperTest {

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
		DoubleDataMapper dm = new DoubleDataMapper();
		Integer type = (Integer) PrivateAccessor.getPrivateField(dm, "type");
		assertNotNull(type);
		assertEquals(Types.DOUBLE, type.intValue());

		dm.setType(Types.OTHER);
		type = (Integer) PrivateAccessor.getPrivateField(dm, "type");
		assertNotNull(type);
		assertEquals(Types.OTHER, type.intValue());
	}

	@Test
	public final void testGetObject() {
		ResultSetStub rset = new ResultSetStub();
		DoubleDataMapper dm = new DoubleDataMapper();
		assertNotNull(dm);
		try {
			Double result = (Double) dm.getObject(rset, 123);
			assertNotNull(result);
			assertEquals("getDouble(123)", rset.getCalled());
			result = (Double) dm.getObject(rset, 999);
			assertNull(result);
			assertEquals("getDouble(999)", rset.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetObject() {
		PreparedStatementStub pstmt = new PreparedStatementStub();
		DoubleDataMapper dm = new DoubleDataMapper();
		assertNotNull(dm);
		try {
			dm.setObject(pstmt, 123, new Double(1234));
			assertEquals("setDouble(123, double)", pstmt.getCalled());
			dm.setObject(pstmt, 123, null);
			assertEquals("setNull(123, 8)", pstmt.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testIsDoubleType() {
		assertFalse(DoubleDataMapper.isDoubleType(Types.ARRAY));
		assertFalse(DoubleDataMapper.isDoubleType(Types.BIGINT));
		assertFalse(DoubleDataMapper.isDoubleType(Types.BINARY));
		assertFalse(DoubleDataMapper.isDoubleType(Types.BIT));
		assertFalse(DoubleDataMapper.isDoubleType(Types.BLOB));
		assertFalse(DoubleDataMapper.isDoubleType(Types.BOOLEAN));
		assertFalse(DoubleDataMapper.isDoubleType(Types.CHAR));
		assertFalse(DoubleDataMapper.isDoubleType(Types.CLOB));
		assertFalse(DoubleDataMapper.isDoubleType(Types.DATALINK));
		assertFalse(DoubleDataMapper.isDoubleType(Types.DATE));
		assertFalse(DoubleDataMapper.isDoubleType(Types.DECIMAL));
		assertFalse(DoubleDataMapper.isDoubleType(Types.DISTINCT));
		assertTrue(DoubleDataMapper.isDoubleType(Types.DOUBLE));
		assertTrue(DoubleDataMapper.isDoubleType(Types.FLOAT));
		assertFalse(DoubleDataMapper.isDoubleType(Types.INTEGER));
		assertFalse(DoubleDataMapper.isDoubleType(Types.JAVA_OBJECT));
		assertFalse(DoubleDataMapper.isDoubleType(Types.LONGNVARCHAR));
		assertFalse(DoubleDataMapper.isDoubleType(Types.LONGVARBINARY));
		assertFalse(DoubleDataMapper.isDoubleType(Types.LONGVARCHAR));
		assertFalse(DoubleDataMapper.isDoubleType(Types.NCHAR));
		assertFalse(DoubleDataMapper.isDoubleType(Types.NCLOB));
		assertFalse(DoubleDataMapper.isDoubleType(Types.NULL));
		assertFalse(DoubleDataMapper.isDoubleType(Types.NUMERIC));
		assertFalse(DoubleDataMapper.isDoubleType(Types.NVARCHAR));
		assertFalse(DoubleDataMapper.isDoubleType(Types.OTHER));
		assertFalse(DoubleDataMapper.isDoubleType(Types.REAL));
		assertFalse(DoubleDataMapper.isDoubleType(Types.REF));
		assertFalse(DoubleDataMapper.isDoubleType(Types.ROWID));
		assertFalse(DoubleDataMapper.isDoubleType(Types.SMALLINT));
		assertFalse(DoubleDataMapper.isDoubleType(Types.SQLXML));
		assertFalse(DoubleDataMapper.isDoubleType(Types.STRUCT));
		assertFalse(DoubleDataMapper.isDoubleType(Types.TIME));
		assertFalse(DoubleDataMapper.isDoubleType(Types.TIMESTAMP));
		assertFalse(DoubleDataMapper.isDoubleType(Types.TINYINT));
		assertFalse(DoubleDataMapper.isDoubleType(Types.VARBINARY));
		assertFalse(DoubleDataMapper.isDoubleType(Types.VARCHAR));
	}
}
