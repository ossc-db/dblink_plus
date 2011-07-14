package jp.co.ntt.oss.mapper;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.sql.SQLException;
import java.sql.Types;

import jp.co.ntt.oss.mapper.stub.ArrayStub;
import jp.co.ntt.oss.mapper.stub.PreparedStatementStub;
import jp.co.ntt.oss.mapper.stub.ResultSetStub;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class ArrayDataMapperTest {

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
		ArrayDataMapper dm = new ArrayDataMapper();
		assertNotNull(dm);
		try {
			dm.getObject(rset, 123);
			assertEquals("getArray(123)", rset.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetObject() {
		PreparedStatementStub pstmt = new PreparedStatementStub();
		ArrayDataMapper dm = new ArrayDataMapper();
		assertNotNull(dm);
		try {
			dm.setObject(pstmt, 123, new ArrayStub());
			assertEquals("setArray(123, jp.co.ntt.oss.mapper.stub.ArrayStub)", pstmt
					.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testIsArrayType() {
		assertTrue(ArrayDataMapper.isArrayType(Types.ARRAY));
		assertFalse(ArrayDataMapper.isArrayType(Types.BIGINT));
		assertFalse(ArrayDataMapper.isArrayType(Types.BINARY));
		assertFalse(ArrayDataMapper.isArrayType(Types.BIT));
		assertFalse(ArrayDataMapper.isArrayType(Types.BLOB));
		assertFalse(ArrayDataMapper.isArrayType(Types.BOOLEAN));
		assertFalse(ArrayDataMapper.isArrayType(Types.CHAR));
		assertFalse(ArrayDataMapper.isArrayType(Types.CLOB));
		assertFalse(ArrayDataMapper.isArrayType(Types.DATALINK));
		assertFalse(ArrayDataMapper.isArrayType(Types.DATE));
		assertFalse(ArrayDataMapper.isArrayType(Types.DECIMAL));
		assertFalse(ArrayDataMapper.isArrayType(Types.DISTINCT));
		assertFalse(ArrayDataMapper.isArrayType(Types.DOUBLE));
		assertFalse(ArrayDataMapper.isArrayType(Types.FLOAT));
		assertFalse(ArrayDataMapper.isArrayType(Types.INTEGER));
		assertFalse(ArrayDataMapper.isArrayType(Types.JAVA_OBJECT));
		assertFalse(ArrayDataMapper.isArrayType(Types.LONGNVARCHAR));
		assertFalse(ArrayDataMapper.isArrayType(Types.LONGVARBINARY));
		assertFalse(ArrayDataMapper.isArrayType(Types.LONGVARCHAR));
		assertFalse(ArrayDataMapper.isArrayType(Types.NCHAR));
		assertFalse(ArrayDataMapper.isArrayType(Types.NCLOB));
		assertFalse(ArrayDataMapper.isArrayType(Types.NULL));
		assertFalse(ArrayDataMapper.isArrayType(Types.NUMERIC));
		assertFalse(ArrayDataMapper.isArrayType(Types.NVARCHAR));
		assertFalse(ArrayDataMapper.isArrayType(Types.OTHER));
		assertFalse(ArrayDataMapper.isArrayType(Types.REAL));
		assertFalse(ArrayDataMapper.isArrayType(Types.REF));
		assertFalse(ArrayDataMapper.isArrayType(Types.ROWID));
		assertFalse(ArrayDataMapper.isArrayType(Types.SMALLINT));
		assertFalse(ArrayDataMapper.isArrayType(Types.SQLXML));
		assertFalse(ArrayDataMapper.isArrayType(Types.STRUCT));
		assertFalse(ArrayDataMapper.isArrayType(Types.TIME));
		assertFalse(ArrayDataMapper.isArrayType(Types.TIMESTAMP));
		assertFalse(ArrayDataMapper.isArrayType(Types.TINYINT));
		assertFalse(ArrayDataMapper.isArrayType(Types.VARBINARY));
		assertFalse(ArrayDataMapper.isArrayType(Types.VARCHAR));
	}
}
