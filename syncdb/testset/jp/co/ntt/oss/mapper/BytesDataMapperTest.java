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

public class BytesDataMapperTest {

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
		BytesDataMapper dm = new BytesDataMapper();
		assertNotNull(dm);
		try {
			dm.getObject(rset, 123);
			assertEquals("getBytes(123)", rset.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetObject() {
		PreparedStatementStub pstmt = new PreparedStatementStub();
		BytesDataMapper dm = new BytesDataMapper();
		assertNotNull(dm);
		try {
			dm.setObject(pstmt, 123, new byte[1234]);
			assertEquals("setBytes(123, byte[])", pstmt
					.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testIsBytesType() {
		assertFalse(BytesDataMapper.isBytesType(Types.ARRAY));
		assertFalse(BytesDataMapper.isBytesType(Types.BIGINT));
		assertTrue(BytesDataMapper.isBytesType(Types.BINARY));
		assertFalse(BytesDataMapper.isBytesType(Types.BIT));
		assertFalse(BytesDataMapper.isBytesType(Types.BLOB));
		assertFalse(BytesDataMapper.isBytesType(Types.BOOLEAN));
		assertFalse(BytesDataMapper.isBytesType(Types.CHAR));
		assertFalse(BytesDataMapper.isBytesType(Types.CLOB));
		assertFalse(BytesDataMapper.isBytesType(Types.DATALINK));
		assertFalse(BytesDataMapper.isBytesType(Types.DATE));
		assertFalse(BytesDataMapper.isBytesType(Types.DECIMAL));
		assertFalse(BytesDataMapper.isBytesType(Types.DISTINCT));
		assertFalse(BytesDataMapper.isBytesType(Types.DOUBLE));
		assertFalse(BytesDataMapper.isBytesType(Types.FLOAT));
		assertFalse(BytesDataMapper.isBytesType(Types.INTEGER));
		assertFalse(BytesDataMapper.isBytesType(Types.JAVA_OBJECT));
		assertFalse(BytesDataMapper.isBytesType(Types.LONGNVARCHAR));
		assertTrue(BytesDataMapper.isBytesType(Types.LONGVARBINARY));
		assertFalse(BytesDataMapper.isBytesType(Types.LONGVARCHAR));
		assertFalse(BytesDataMapper.isBytesType(Types.NCHAR));
		assertFalse(BytesDataMapper.isBytesType(Types.NCLOB));
		assertFalse(BytesDataMapper.isBytesType(Types.NULL));
		assertFalse(BytesDataMapper.isBytesType(Types.NUMERIC));
		assertFalse(BytesDataMapper.isBytesType(Types.NVARCHAR));
		assertFalse(BytesDataMapper.isBytesType(Types.OTHER));
		assertFalse(BytesDataMapper.isBytesType(Types.REAL));
		assertFalse(BytesDataMapper.isBytesType(Types.REF));
		assertFalse(BytesDataMapper.isBytesType(Types.ROWID));
		assertFalse(BytesDataMapper.isBytesType(Types.SMALLINT));
		assertFalse(BytesDataMapper.isBytesType(Types.SQLXML));
		assertFalse(BytesDataMapper.isBytesType(Types.STRUCT));
		assertFalse(BytesDataMapper.isBytesType(Types.TIME));
		assertFalse(BytesDataMapper.isBytesType(Types.TIMESTAMP));
		assertFalse(BytesDataMapper.isBytesType(Types.TINYINT));
		assertTrue(BytesDataMapper.isBytesType(Types.VARBINARY));
		assertFalse(BytesDataMapper.isBytesType(Types.VARCHAR));
	}
}
