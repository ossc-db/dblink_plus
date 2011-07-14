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
import jp.co.ntt.oss.mapper.stub.StructStub;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class StructDataMapperTest {

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
		StructDataMapper dm = new StructDataMapper();
		assertNotNull(dm);
		try {
			dm.getObject(rset, 123);
			assertEquals("getObject(123)", rset.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetObject() {
		PreparedStatementStub pstmt = new PreparedStatementStub();
		StructDataMapper dm = new StructDataMapper();
		assertNotNull(dm);
		try {
			dm.setObject(pstmt, 123, new StructStub());
			assertEquals("setObject(123, jp.co.ntt.oss.mapper.stub.StructStub)", pstmt
					.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testIsStructType() {
		assertFalse(StructDataMapper.isStructType(Types.ARRAY));
		assertFalse(StructDataMapper.isStructType(Types.BIGINT));
		assertFalse(StructDataMapper.isStructType(Types.BINARY));
		assertFalse(StructDataMapper.isStructType(Types.BIT));
		assertFalse(StructDataMapper.isStructType(Types.BLOB));
		assertFalse(StructDataMapper.isStructType(Types.BOOLEAN));
		assertFalse(StructDataMapper.isStructType(Types.CHAR));
		assertFalse(StructDataMapper.isStructType(Types.CLOB));
		assertFalse(StructDataMapper.isStructType(Types.DATALINK));
		assertFalse(StructDataMapper.isStructType(Types.DATE));
		assertFalse(StructDataMapper.isStructType(Types.DECIMAL));
		assertFalse(StructDataMapper.isStructType(Types.DISTINCT));
		assertFalse(StructDataMapper.isStructType(Types.DOUBLE));
		assertFalse(StructDataMapper.isStructType(Types.FLOAT));
		assertFalse(StructDataMapper.isStructType(Types.INTEGER));
		assertFalse(StructDataMapper.isStructType(Types.JAVA_OBJECT));
		assertFalse(StructDataMapper.isStructType(Types.LONGNVARCHAR));
		assertFalse(StructDataMapper.isStructType(Types.LONGVARBINARY));
		assertFalse(StructDataMapper.isStructType(Types.LONGVARCHAR));
		assertFalse(StructDataMapper.isStructType(Types.NCHAR));
		assertFalse(StructDataMapper.isStructType(Types.NCLOB));
		assertFalse(StructDataMapper.isStructType(Types.NULL));
		assertFalse(StructDataMapper.isStructType(Types.NUMERIC));
		assertFalse(StructDataMapper.isStructType(Types.NVARCHAR));
		assertFalse(StructDataMapper.isStructType(Types.OTHER));
		assertFalse(StructDataMapper.isStructType(Types.REAL));
		assertFalse(StructDataMapper.isStructType(Types.REF));
		assertFalse(StructDataMapper.isStructType(Types.ROWID));
		assertFalse(StructDataMapper.isStructType(Types.SMALLINT));
		assertFalse(StructDataMapper.isStructType(Types.SQLXML));
		assertTrue(StructDataMapper.isStructType(Types.STRUCT));
		assertFalse(StructDataMapper.isStructType(Types.TIME));
		assertFalse(StructDataMapper.isStructType(Types.TIMESTAMP));
		assertFalse(StructDataMapper.isStructType(Types.TINYINT));
		assertFalse(StructDataMapper.isStructType(Types.VARBINARY));
		assertFalse(StructDataMapper.isStructType(Types.VARCHAR));
	}
}
