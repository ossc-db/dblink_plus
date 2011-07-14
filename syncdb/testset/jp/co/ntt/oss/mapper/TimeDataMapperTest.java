package jp.co.ntt.oss.mapper;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.sql.SQLException;
import java.sql.Time;
import java.sql.Types;

import jp.co.ntt.oss.mapper.stub.PreparedStatementStub;
import jp.co.ntt.oss.mapper.stub.ResultSetStub;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class TimeDataMapperTest {

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
		TimeDataMapper dm = new TimeDataMapper();
		assertNotNull(dm);
		try {
			dm.getObject(rset, 123);
			assertEquals("getTime(123)", rset.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetObject() {
		PreparedStatementStub pstmt = new PreparedStatementStub();
		TimeDataMapper dm = new TimeDataMapper();
		assertNotNull(dm);
		try {
			dm.setObject(pstmt, 123, new Time(1234));
			assertEquals("setTime(123, java.sql.Time)", pstmt
					.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testIsTimeType() {
		assertFalse(TimeDataMapper.isTimeType(Types.ARRAY));
		assertFalse(TimeDataMapper.isTimeType(Types.BIGINT));
		assertFalse(TimeDataMapper.isTimeType(Types.BINARY));
		assertFalse(TimeDataMapper.isTimeType(Types.BIT));
		assertFalse(TimeDataMapper.isTimeType(Types.BLOB));
		assertFalse(TimeDataMapper.isTimeType(Types.BOOLEAN));
		assertFalse(TimeDataMapper.isTimeType(Types.CHAR));
		assertFalse(TimeDataMapper.isTimeType(Types.CLOB));
		assertFalse(TimeDataMapper.isTimeType(Types.DATALINK));
		assertFalse(TimeDataMapper.isTimeType(Types.DATE));
		assertFalse(TimeDataMapper.isTimeType(Types.DECIMAL));
		assertFalse(TimeDataMapper.isTimeType(Types.DISTINCT));
		assertFalse(TimeDataMapper.isTimeType(Types.DOUBLE));
		assertFalse(TimeDataMapper.isTimeType(Types.FLOAT));
		assertFalse(TimeDataMapper.isTimeType(Types.INTEGER));
		assertFalse(TimeDataMapper.isTimeType(Types.JAVA_OBJECT));
		assertFalse(TimeDataMapper.isTimeType(Types.LONGNVARCHAR));
		assertFalse(TimeDataMapper.isTimeType(Types.LONGVARBINARY));
		assertFalse(TimeDataMapper.isTimeType(Types.LONGVARCHAR));
		assertFalse(TimeDataMapper.isTimeType(Types.NCHAR));
		assertFalse(TimeDataMapper.isTimeType(Types.NCLOB));
		assertFalse(TimeDataMapper.isTimeType(Types.NULL));
		assertFalse(TimeDataMapper.isTimeType(Types.NUMERIC));
		assertFalse(TimeDataMapper.isTimeType(Types.NVARCHAR));
		assertFalse(TimeDataMapper.isTimeType(Types.OTHER));
		assertFalse(TimeDataMapper.isTimeType(Types.REAL));
		assertFalse(TimeDataMapper.isTimeType(Types.REF));
		assertFalse(TimeDataMapper.isTimeType(Types.ROWID));
		assertFalse(TimeDataMapper.isTimeType(Types.SMALLINT));
		assertFalse(TimeDataMapper.isTimeType(Types.SQLXML));
		assertFalse(TimeDataMapper.isTimeType(Types.STRUCT));
		assertTrue(TimeDataMapper.isTimeType(Types.TIME));
		assertFalse(TimeDataMapper.isTimeType(Types.TIMESTAMP));
		assertFalse(TimeDataMapper.isTimeType(Types.TINYINT));
		assertFalse(TimeDataMapper.isTimeType(Types.VARBINARY));
		assertFalse(TimeDataMapper.isTimeType(Types.VARCHAR));
	}
}
