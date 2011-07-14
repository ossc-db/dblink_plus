package jp.co.ntt.oss.mapper;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;

import jp.co.ntt.oss.mapper.stub.PreparedStatementStub;
import jp.co.ntt.oss.mapper.stub.ResultSetStub;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class TimestampDataMapperTest {

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
		TimestampDataMapper dm = new TimestampDataMapper();
		assertNotNull(dm);
		try {
			dm.getObject(rset, 123);
			assertEquals("getTimestamp(123)", rset.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetObject() {
		PreparedStatementStub pstmt = new PreparedStatementStub();
		TimestampDataMapper dm = new TimestampDataMapper();
		assertNotNull(dm);
		try {
			dm.setObject(pstmt, 123, new Timestamp(1234));
			assertEquals("setTimestamp(123, java.sql.Timestamp)",
					pstmt.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testIsTimestampType() {
		assertFalse(TimestampDataMapper.isTimestampType(Types.ARRAY));
		assertFalse(TimestampDataMapper.isTimestampType(Types.BIGINT));
		assertFalse(TimestampDataMapper.isTimestampType(Types.BINARY));
		assertFalse(TimestampDataMapper.isTimestampType(Types.BIT));
		assertFalse(TimestampDataMapper.isTimestampType(Types.BLOB));
		assertFalse(TimestampDataMapper.isTimestampType(Types.BOOLEAN));
		assertFalse(TimestampDataMapper.isTimestampType(Types.CHAR));
		assertFalse(TimestampDataMapper.isTimestampType(Types.CLOB));
		assertFalse(TimestampDataMapper.isTimestampType(Types.DATALINK));
		assertFalse(TimestampDataMapper.isTimestampType(Types.DATE));
		assertFalse(TimestampDataMapper.isTimestampType(Types.DECIMAL));
		assertFalse(TimestampDataMapper.isTimestampType(Types.DISTINCT));
		assertFalse(TimestampDataMapper.isTimestampType(Types.DOUBLE));
		assertFalse(TimestampDataMapper.isTimestampType(Types.FLOAT));
		assertFalse(TimestampDataMapper.isTimestampType(Types.INTEGER));
		assertFalse(TimestampDataMapper.isTimestampType(Types.JAVA_OBJECT));
		assertFalse(TimestampDataMapper.isTimestampType(Types.LONGNVARCHAR));
		assertFalse(TimestampDataMapper.isTimestampType(Types.LONGVARBINARY));
		assertFalse(TimestampDataMapper.isTimestampType(Types.LONGVARCHAR));
		assertFalse(TimestampDataMapper.isTimestampType(Types.NCHAR));
		assertFalse(TimestampDataMapper.isTimestampType(Types.NCLOB));
		assertFalse(TimestampDataMapper.isTimestampType(Types.NULL));
		assertFalse(TimestampDataMapper.isTimestampType(Types.NUMERIC));
		assertFalse(TimestampDataMapper.isTimestampType(Types.NVARCHAR));
		assertFalse(TimestampDataMapper.isTimestampType(Types.OTHER));
		assertFalse(TimestampDataMapper.isTimestampType(Types.REAL));
		assertFalse(TimestampDataMapper.isTimestampType(Types.REF));
		assertFalse(TimestampDataMapper.isTimestampType(Types.ROWID));
		assertFalse(TimestampDataMapper.isTimestampType(Types.SMALLINT));
		assertFalse(TimestampDataMapper.isTimestampType(Types.SQLXML));
		assertFalse(TimestampDataMapper.isTimestampType(Types.STRUCT));
		assertFalse(TimestampDataMapper.isTimestampType(Types.TIME));
		assertTrue(TimestampDataMapper.isTimestampType(Types.TIMESTAMP));
		assertFalse(TimestampDataMapper.isTimestampType(Types.TINYINT));
		assertFalse(TimestampDataMapper.isTimestampType(Types.VARBINARY));
		assertFalse(TimestampDataMapper.isTimestampType(Types.VARCHAR));
	}
}
