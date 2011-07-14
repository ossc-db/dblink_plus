package jp.co.ntt.oss.mapper;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.sql.SQLException;
import java.sql.Types;

import jp.co.ntt.oss.mapper.stub.BlobStub;
import jp.co.ntt.oss.mapper.stub.PreparedStatementStub;
import jp.co.ntt.oss.mapper.stub.ResultSetStub;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class BlobDataMapperTest {

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
		BlobDataMapper dm = new BlobDataMapper();
		assertNotNull(dm);
		try {
			dm.getObject(rset, 123);
			assertEquals("getBlob(123)", rset.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetObject() {
		PreparedStatementStub pstmt = new PreparedStatementStub();
		BlobDataMapper dm = new BlobDataMapper();
		assertNotNull(dm);
		try {
			dm.setObject(pstmt, 123, new BlobStub());
			assertEquals("setBlob(123, jp.co.ntt.oss.mapper.stub.BlobStub)", pstmt
					.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testIsBlobType() {
		assertFalse(BlobDataMapper.isBlobType(Types.ARRAY));
		assertFalse(BlobDataMapper.isBlobType(Types.BIGINT));
		assertFalse(BlobDataMapper.isBlobType(Types.BINARY));
		assertFalse(BlobDataMapper.isBlobType(Types.BIT));
		assertTrue(BlobDataMapper.isBlobType(Types.BLOB));
		assertFalse(BlobDataMapper.isBlobType(Types.BOOLEAN));
		assertFalse(BlobDataMapper.isBlobType(Types.CHAR));
		assertFalse(BlobDataMapper.isBlobType(Types.CLOB));
		assertFalse(BlobDataMapper.isBlobType(Types.DATALINK));
		assertFalse(BlobDataMapper.isBlobType(Types.DATE));
		assertFalse(BlobDataMapper.isBlobType(Types.DECIMAL));
		assertFalse(BlobDataMapper.isBlobType(Types.DISTINCT));
		assertFalse(BlobDataMapper.isBlobType(Types.DOUBLE));
		assertFalse(BlobDataMapper.isBlobType(Types.FLOAT));
		assertFalse(BlobDataMapper.isBlobType(Types.INTEGER));
		assertFalse(BlobDataMapper.isBlobType(Types.JAVA_OBJECT));
		assertFalse(BlobDataMapper.isBlobType(Types.LONGNVARCHAR));
		assertFalse(BlobDataMapper.isBlobType(Types.LONGVARBINARY));
		assertFalse(BlobDataMapper.isBlobType(Types.LONGVARCHAR));
		assertFalse(BlobDataMapper.isBlobType(Types.NCHAR));
		assertFalse(BlobDataMapper.isBlobType(Types.NCLOB));
		assertFalse(BlobDataMapper.isBlobType(Types.NULL));
		assertFalse(BlobDataMapper.isBlobType(Types.NUMERIC));
		assertFalse(BlobDataMapper.isBlobType(Types.NVARCHAR));
		assertFalse(BlobDataMapper.isBlobType(Types.OTHER));
		assertFalse(BlobDataMapper.isBlobType(Types.REAL));
		assertFalse(BlobDataMapper.isBlobType(Types.REF));
		assertFalse(BlobDataMapper.isBlobType(Types.ROWID));
		assertFalse(BlobDataMapper.isBlobType(Types.SMALLINT));
		assertFalse(BlobDataMapper.isBlobType(Types.SQLXML));
		assertFalse(BlobDataMapper.isBlobType(Types.STRUCT));
		assertFalse(BlobDataMapper.isBlobType(Types.TIME));
		assertFalse(BlobDataMapper.isBlobType(Types.TIMESTAMP));
		assertFalse(BlobDataMapper.isBlobType(Types.TINYINT));
		assertFalse(BlobDataMapper.isBlobType(Types.VARBINARY));
		assertFalse(BlobDataMapper.isBlobType(Types.VARCHAR));
	}
}
