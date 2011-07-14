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
import jp.co.ntt.oss.mapper.stub.RowIdStub;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class RowIdDataMapperTest {

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
		RowIdDataMapper dm = new RowIdDataMapper();
		assertNotNull(dm);
		try {
			dm.getObject(rset, 123);
			assertEquals("getRowId(123)", rset.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetObject() {
		PreparedStatementStub pstmt = new PreparedStatementStub();
		RowIdDataMapper dm = new RowIdDataMapper();
		assertNotNull(dm);
		try {
			dm.setObject(pstmt, 123, new RowIdStub());
			assertEquals("setRowId(123, jp.co.ntt.oss.mapper.stub.RowIdStub)", pstmt
					.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testIsRowIdType() {
		assertFalse(RowIdDataMapper.isRowIdType(Types.ARRAY));
		assertFalse(RowIdDataMapper.isRowIdType(Types.BIGINT));
		assertFalse(RowIdDataMapper.isRowIdType(Types.BINARY));
		assertFalse(RowIdDataMapper.isRowIdType(Types.BIT));
		assertFalse(RowIdDataMapper.isRowIdType(Types.BLOB));
		assertFalse(RowIdDataMapper.isRowIdType(Types.BOOLEAN));
		assertFalse(RowIdDataMapper.isRowIdType(Types.CHAR));
		assertFalse(RowIdDataMapper.isRowIdType(Types.CLOB));
		assertFalse(RowIdDataMapper.isRowIdType(Types.DATALINK));
		assertFalse(RowIdDataMapper.isRowIdType(Types.DATE));
		assertFalse(RowIdDataMapper.isRowIdType(Types.DECIMAL));
		assertFalse(RowIdDataMapper.isRowIdType(Types.DISTINCT));
		assertFalse(RowIdDataMapper.isRowIdType(Types.DOUBLE));
		assertFalse(RowIdDataMapper.isRowIdType(Types.FLOAT));
		assertFalse(RowIdDataMapper.isRowIdType(Types.INTEGER));
		assertFalse(RowIdDataMapper.isRowIdType(Types.JAVA_OBJECT));
		assertFalse(RowIdDataMapper.isRowIdType(Types.LONGNVARCHAR));
		assertFalse(RowIdDataMapper.isRowIdType(Types.LONGVARBINARY));
		assertFalse(RowIdDataMapper.isRowIdType(Types.LONGVARCHAR));
		assertFalse(RowIdDataMapper.isRowIdType(Types.NCHAR));
		assertFalse(RowIdDataMapper.isRowIdType(Types.NCLOB));
		assertFalse(RowIdDataMapper.isRowIdType(Types.NULL));
		assertFalse(RowIdDataMapper.isRowIdType(Types.NUMERIC));
		assertFalse(RowIdDataMapper.isRowIdType(Types.NVARCHAR));
		assertFalse(RowIdDataMapper.isRowIdType(Types.OTHER));
		assertFalse(RowIdDataMapper.isRowIdType(Types.REAL));
		assertFalse(RowIdDataMapper.isRowIdType(Types.REF));
		assertTrue(RowIdDataMapper.isRowIdType(Types.ROWID));
		assertFalse(RowIdDataMapper.isRowIdType(Types.SMALLINT));
		assertFalse(RowIdDataMapper.isRowIdType(Types.SQLXML));
		assertFalse(RowIdDataMapper.isRowIdType(Types.STRUCT));
		assertFalse(RowIdDataMapper.isRowIdType(Types.TIME));
		assertFalse(RowIdDataMapper.isRowIdType(Types.TIMESTAMP));
		assertFalse(RowIdDataMapper.isRowIdType(Types.TINYINT));
		assertFalse(RowIdDataMapper.isRowIdType(Types.VARBINARY));
		assertFalse(RowIdDataMapper.isRowIdType(Types.VARCHAR));
	}
}
