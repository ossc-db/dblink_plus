package jp.co.ntt.oss.mapper;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.sql.SQLException;
import java.sql.Types;

import jp.co.ntt.oss.mapper.stub.NclobStub;
import jp.co.ntt.oss.mapper.stub.PreparedStatementStub;
import jp.co.ntt.oss.mapper.stub.ResultSetStub;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class NClobDataMapperTest {

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
		NClobDataMapper dm = new NClobDataMapper();
		assertNotNull(dm);
		try {
			dm.getObject(rset, 123);
			assertEquals("getNClob(123)", rset.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetObject() {
		PreparedStatementStub pstmt = new PreparedStatementStub();
		NClobDataMapper dm = new NClobDataMapper();
		assertNotNull(dm);
		try {
			dm.setObject(pstmt, 123, new NclobStub());
			assertEquals("setNClob(123, jp.co.ntt.oss.mapper.stub.NclobStub)", pstmt
					.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testIsNclobType() {
		assertFalse(NClobDataMapper.isNClobType(Types.ARRAY));
		assertFalse(NClobDataMapper.isNClobType(Types.BIGINT));
		assertFalse(NClobDataMapper.isNClobType(Types.BINARY));
		assertFalse(NClobDataMapper.isNClobType(Types.BIT));
		assertFalse(NClobDataMapper.isNClobType(Types.BLOB));
		assertFalse(NClobDataMapper.isNClobType(Types.BOOLEAN));
		assertFalse(NClobDataMapper.isNClobType(Types.CHAR));
		assertFalse(NClobDataMapper.isNClobType(Types.CLOB));
		assertFalse(NClobDataMapper.isNClobType(Types.DATALINK));
		assertFalse(NClobDataMapper.isNClobType(Types.DATE));
		assertFalse(NClobDataMapper.isNClobType(Types.DECIMAL));
		assertFalse(NClobDataMapper.isNClobType(Types.DISTINCT));
		assertFalse(NClobDataMapper.isNClobType(Types.DOUBLE));
		assertFalse(NClobDataMapper.isNClobType(Types.FLOAT));
		assertFalse(NClobDataMapper.isNClobType(Types.INTEGER));
		assertFalse(NClobDataMapper.isNClobType(Types.JAVA_OBJECT));
		assertFalse(NClobDataMapper.isNClobType(Types.LONGNVARCHAR));
		assertFalse(NClobDataMapper.isNClobType(Types.LONGVARBINARY));
		assertFalse(NClobDataMapper.isNClobType(Types.LONGVARCHAR));
		assertFalse(NClobDataMapper.isNClobType(Types.NCHAR));
		assertTrue(NClobDataMapper.isNClobType(Types.NCLOB));
		assertFalse(NClobDataMapper.isNClobType(Types.NULL));
		assertFalse(NClobDataMapper.isNClobType(Types.NUMERIC));
		assertFalse(NClobDataMapper.isNClobType(Types.NVARCHAR));
		assertFalse(NClobDataMapper.isNClobType(Types.OTHER));
		assertFalse(NClobDataMapper.isNClobType(Types.REAL));
		assertFalse(NClobDataMapper.isNClobType(Types.REF));
		assertFalse(NClobDataMapper.isNClobType(Types.ROWID));
		assertFalse(NClobDataMapper.isNClobType(Types.SMALLINT));
		assertFalse(NClobDataMapper.isNClobType(Types.SQLXML));
		assertFalse(NClobDataMapper.isNClobType(Types.STRUCT));
		assertFalse(NClobDataMapper.isNClobType(Types.TIME));
		assertFalse(NClobDataMapper.isNClobType(Types.TIMESTAMP));
		assertFalse(NClobDataMapper.isNClobType(Types.TINYINT));
		assertFalse(NClobDataMapper.isNClobType(Types.VARBINARY));
		assertFalse(NClobDataMapper.isNClobType(Types.VARCHAR));
	}
}
