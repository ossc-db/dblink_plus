package jp.co.ntt.oss.mapper;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.sql.Types;

import jp.co.ntt.oss.mapper.stub.PreparedStatementStub;
import jp.co.ntt.oss.mapper.stub.ResultSetStub;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class BigDecimalDataMapperTest {

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
		BigDecimalDataMapper dm = new BigDecimalDataMapper();
		assertNotNull(dm);
		try {
			dm.getObject(rset, 123);
			assertEquals("getBigDecimal(123)", rset.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetObject() {
		PreparedStatementStub pstmt = new PreparedStatementStub();
		BigDecimalDataMapper dm = new BigDecimalDataMapper();
		assertNotNull(dm);
		try {
			dm.setObject(pstmt, 123, new BigDecimal(1234));
			assertEquals(
					"setBigDecimal(123, java.math.BigDecimal)",
					pstmt.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testIsBigDecimalType() {
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.ARRAY));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.BIGINT));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.BINARY));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.BIT));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.BLOB));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.BOOLEAN));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.CHAR));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.CLOB));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.DATALINK));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.DATE));
		assertTrue(BigDecimalDataMapper.isBigDecimalType(Types.DECIMAL));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.DISTINCT));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.DOUBLE));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.FLOAT));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.INTEGER));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.JAVA_OBJECT));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.LONGNVARCHAR));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.LONGVARBINARY));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.LONGVARCHAR));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.NCHAR));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.NCLOB));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.NULL));
		assertTrue(BigDecimalDataMapper.isBigDecimalType(Types.NUMERIC));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.NVARCHAR));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.OTHER));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.REAL));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.REF));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.ROWID));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.SMALLINT));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.SQLXML));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.STRUCT));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.TIME));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.TIMESTAMP));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.TINYINT));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.VARBINARY));
		assertFalse(BigDecimalDataMapper.isBigDecimalType(Types.VARCHAR));
	}
}
