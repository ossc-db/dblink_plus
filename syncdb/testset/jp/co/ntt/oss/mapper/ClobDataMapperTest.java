package jp.co.ntt.oss.mapper;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.sql.SQLException;
import java.sql.Types;

import jp.co.ntt.oss.mapper.stub.ClobStub;
import jp.co.ntt.oss.mapper.stub.PreparedStatementStub;
import jp.co.ntt.oss.mapper.stub.ResultSetStub;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class ClobDataMapperTest {

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
		ClobDataMapper dm = new ClobDataMapper();
		assertNotNull(dm);
		try {
			dm.getObject(rset, 123);
			assertEquals("getClob(123)", rset.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetObject() {
		PreparedStatementStub pstmt = new PreparedStatementStub();
		ClobDataMapper dm = new ClobDataMapper();
		assertNotNull(dm);
		try {
			dm.setObject(pstmt, 123, new ClobStub());
			assertEquals("setClob(123, jp.co.ntt.oss.mapper.stub.ClobStub)", pstmt
					.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testIsClobType() {
		assertFalse(ClobDataMapper.isClobType(Types.ARRAY));
		assertFalse(ClobDataMapper.isClobType(Types.BIGINT));
		assertFalse(ClobDataMapper.isClobType(Types.BINARY));
		assertFalse(ClobDataMapper.isClobType(Types.BIT));
		assertFalse(ClobDataMapper.isClobType(Types.BLOB));
		assertFalse(ClobDataMapper.isClobType(Types.BOOLEAN));
		assertFalse(ClobDataMapper.isClobType(Types.CHAR));
		assertTrue(ClobDataMapper.isClobType(Types.CLOB));
		assertFalse(ClobDataMapper.isClobType(Types.DATALINK));
		assertFalse(ClobDataMapper.isClobType(Types.DATE));
		assertFalse(ClobDataMapper.isClobType(Types.DECIMAL));
		assertFalse(ClobDataMapper.isClobType(Types.DISTINCT));
		assertFalse(ClobDataMapper.isClobType(Types.DOUBLE));
		assertFalse(ClobDataMapper.isClobType(Types.FLOAT));
		assertFalse(ClobDataMapper.isClobType(Types.INTEGER));
		assertFalse(ClobDataMapper.isClobType(Types.JAVA_OBJECT));
		assertFalse(ClobDataMapper.isClobType(Types.LONGNVARCHAR));
		assertFalse(ClobDataMapper.isClobType(Types.LONGVARBINARY));
		assertFalse(ClobDataMapper.isClobType(Types.LONGVARCHAR));
		assertFalse(ClobDataMapper.isClobType(Types.NCHAR));
		assertFalse(ClobDataMapper.isClobType(Types.NCLOB));
		assertFalse(ClobDataMapper.isClobType(Types.NULL));
		assertFalse(ClobDataMapper.isClobType(Types.NUMERIC));
		assertFalse(ClobDataMapper.isClobType(Types.NVARCHAR));
		assertFalse(ClobDataMapper.isClobType(Types.OTHER));
		assertFalse(ClobDataMapper.isClobType(Types.REAL));
		assertFalse(ClobDataMapper.isClobType(Types.REF));
		assertFalse(ClobDataMapper.isClobType(Types.ROWID));
		assertFalse(ClobDataMapper.isClobType(Types.SMALLINT));
		assertFalse(ClobDataMapper.isClobType(Types.SQLXML));
		assertFalse(ClobDataMapper.isClobType(Types.STRUCT));
		assertFalse(ClobDataMapper.isClobType(Types.TIME));
		assertFalse(ClobDataMapper.isClobType(Types.TIMESTAMP));
		assertFalse(ClobDataMapper.isClobType(Types.TINYINT));
		assertFalse(ClobDataMapper.isClobType(Types.VARBINARY));
		assertFalse(ClobDataMapper.isClobType(Types.VARCHAR));
	}
}
