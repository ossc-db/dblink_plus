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

public class LongDataMapperTest {

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
		LongDataMapper dm = new LongDataMapper();
		Integer type = (Integer) PrivateAccessor.getPrivateField(dm, "type");
		assertNotNull(type);
		assertEquals(Types.BIGINT, type.intValue());

		dm.setType(Types.OTHER);
		type = (Integer) PrivateAccessor.getPrivateField(dm, "type");
		assertNotNull(type);
		assertEquals(Types.OTHER, type.intValue());
	}

	@Test
	public final void testGetObject() {
		ResultSetStub rset = new ResultSetStub();
		LongDataMapper dm = new LongDataMapper();
		assertNotNull(dm);
		try {
			Long result = (Long) dm.getObject(rset, 123);
			assertNotNull(result);
			assertEquals("getLong(123)", rset.getCalled());
			result = (Long) dm.getObject(rset, 999);
			assertNull(result);
			assertEquals("getLong(999)", rset.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetObject() {
		PreparedStatementStub pstmt = new PreparedStatementStub();
		LongDataMapper dm = new LongDataMapper();
		assertNotNull(dm);
		try {
			dm.setObject(pstmt, 123, new Long(1234));
			assertEquals("setLong(123, long)", pstmt.getCalled());
			dm.setObject(pstmt, 123, null);
			assertEquals("setNull(123, -5)", pstmt.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testIsLongType() {
		assertFalse(LongDataMapper.isLongType(Types.ARRAY));
		assertTrue(LongDataMapper.isLongType(Types.BIGINT));
		assertFalse(LongDataMapper.isLongType(Types.BINARY));
		assertFalse(LongDataMapper.isLongType(Types.BIT));
		assertFalse(LongDataMapper.isLongType(Types.BLOB));
		assertFalse(LongDataMapper.isLongType(Types.BOOLEAN));
		assertFalse(LongDataMapper.isLongType(Types.CHAR));
		assertFalse(LongDataMapper.isLongType(Types.CLOB));
		assertFalse(LongDataMapper.isLongType(Types.DATALINK));
		assertFalse(LongDataMapper.isLongType(Types.DATE));
		assertFalse(LongDataMapper.isLongType(Types.DECIMAL));
		assertFalse(LongDataMapper.isLongType(Types.DISTINCT));
		assertFalse(LongDataMapper.isLongType(Types.DOUBLE));
		assertFalse(LongDataMapper.isLongType(Types.FLOAT));
		assertFalse(LongDataMapper.isLongType(Types.INTEGER));
		assertFalse(LongDataMapper.isLongType(Types.JAVA_OBJECT));
		assertFalse(LongDataMapper.isLongType(Types.LONGNVARCHAR));
		assertFalse(LongDataMapper.isLongType(Types.LONGVARBINARY));
		assertFalse(LongDataMapper.isLongType(Types.LONGVARCHAR));
		assertFalse(LongDataMapper.isLongType(Types.NCHAR));
		assertFalse(LongDataMapper.isLongType(Types.NCLOB));
		assertFalse(LongDataMapper.isLongType(Types.NULL));
		assertFalse(LongDataMapper.isLongType(Types.NUMERIC));
		assertFalse(LongDataMapper.isLongType(Types.NVARCHAR));
		assertFalse(LongDataMapper.isLongType(Types.OTHER));
		assertFalse(LongDataMapper.isLongType(Types.REAL));
		assertFalse(LongDataMapper.isLongType(Types.REF));
		assertFalse(LongDataMapper.isLongType(Types.ROWID));
		assertFalse(LongDataMapper.isLongType(Types.SMALLINT));
		assertFalse(LongDataMapper.isLongType(Types.SQLXML));
		assertFalse(LongDataMapper.isLongType(Types.STRUCT));
		assertFalse(LongDataMapper.isLongType(Types.TIME));
		assertFalse(LongDataMapper.isLongType(Types.TIMESTAMP));
		assertFalse(LongDataMapper.isLongType(Types.TINYINT));
		assertFalse(LongDataMapper.isLongType(Types.VARBINARY));
		assertFalse(LongDataMapper.isLongType(Types.VARCHAR));
	}
}
