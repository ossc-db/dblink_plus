package jp.co.ntt.oss.mapper;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.sql.SQLException;
import java.sql.Types;

import jp.co.ntt.oss.mapper.stub.PreparedStatementStub;
import jp.co.ntt.oss.mapper.stub.RefStub;
import jp.co.ntt.oss.mapper.stub.ResultSetStub;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class RefDataMapperTest {

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
		RefDataMapper dm = new RefDataMapper();
		assertNotNull(dm);
		try {
			dm.getObject(rset, 123);
			assertEquals("getRef(123)", rset.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetObject() {
		PreparedStatementStub pstmt = new PreparedStatementStub();
		RefDataMapper dm = new RefDataMapper();
		assertNotNull(dm);
		try {
			dm.setObject(pstmt, 123, new RefStub());
			assertEquals("setRef(123, jp.co.ntt.oss.mapper.stub.RefStub)", pstmt
					.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testIsRefType() {
		assertFalse(RefDataMapper.isRefType(Types.ARRAY));
		assertFalse(RefDataMapper.isRefType(Types.BIGINT));
		assertFalse(RefDataMapper.isRefType(Types.BINARY));
		assertFalse(RefDataMapper.isRefType(Types.BIT));
		assertFalse(RefDataMapper.isRefType(Types.BLOB));
		assertFalse(RefDataMapper.isRefType(Types.BOOLEAN));
		assertFalse(RefDataMapper.isRefType(Types.CHAR));
		assertFalse(RefDataMapper.isRefType(Types.CLOB));
		assertFalse(RefDataMapper.isRefType(Types.DATALINK));
		assertFalse(RefDataMapper.isRefType(Types.DATE));
		assertFalse(RefDataMapper.isRefType(Types.DECIMAL));
		assertFalse(RefDataMapper.isRefType(Types.DISTINCT));
		assertFalse(RefDataMapper.isRefType(Types.DOUBLE));
		assertFalse(RefDataMapper.isRefType(Types.FLOAT));
		assertFalse(RefDataMapper.isRefType(Types.INTEGER));
		assertFalse(RefDataMapper.isRefType(Types.JAVA_OBJECT));
		assertFalse(RefDataMapper.isRefType(Types.LONGNVARCHAR));
		assertFalse(RefDataMapper.isRefType(Types.LONGVARBINARY));
		assertFalse(RefDataMapper.isRefType(Types.LONGVARCHAR));
		assertFalse(RefDataMapper.isRefType(Types.NCHAR));
		assertFalse(RefDataMapper.isRefType(Types.NCLOB));
		assertFalse(RefDataMapper.isRefType(Types.NULL));
		assertFalse(RefDataMapper.isRefType(Types.NUMERIC));
		assertFalse(RefDataMapper.isRefType(Types.NVARCHAR));
		assertFalse(RefDataMapper.isRefType(Types.OTHER));
		assertFalse(RefDataMapper.isRefType(Types.REAL));
		assertTrue(RefDataMapper.isRefType(Types.REF));
		assertFalse(RefDataMapper.isRefType(Types.ROWID));
		assertFalse(RefDataMapper.isRefType(Types.SMALLINT));
		assertFalse(RefDataMapper.isRefType(Types.SQLXML));
		assertFalse(RefDataMapper.isRefType(Types.STRUCT));
		assertFalse(RefDataMapper.isRefType(Types.TIME));
		assertFalse(RefDataMapper.isRefType(Types.TIMESTAMP));
		assertFalse(RefDataMapper.isRefType(Types.TINYINT));
		assertFalse(RefDataMapper.isRefType(Types.VARBINARY));
		assertFalse(RefDataMapper.isRefType(Types.VARCHAR));
	}
}
