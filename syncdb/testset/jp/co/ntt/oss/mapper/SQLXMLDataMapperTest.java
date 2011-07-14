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
import jp.co.ntt.oss.mapper.stub.SQLXMLStub;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class SQLXMLDataMapperTest {

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
		SQLXMLDataMapper dm = new SQLXMLDataMapper();
		assertNotNull(dm);
		try {
			dm.getObject(rset, 123);
			assertEquals("getSQLXML(123)", rset.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetObject() {
		PreparedStatementStub pstmt = new PreparedStatementStub();
		SQLXMLDataMapper dm = new SQLXMLDataMapper();
		assertNotNull(dm);
		try {
			dm.setObject(pstmt, 123, new SQLXMLStub());
			assertEquals("setSQLXML(123, jp.co.ntt.oss.mapper.stub.SQLXMLStub)", pstmt
					.getCalled());
		} catch (SQLException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testIsSQLXMLType() {
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.ARRAY));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.BIGINT));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.BINARY));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.BIT));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.BLOB));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.BOOLEAN));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.CHAR));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.CLOB));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.DATALINK));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.DATE));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.DECIMAL));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.DISTINCT));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.DOUBLE));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.FLOAT));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.INTEGER));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.JAVA_OBJECT));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.LONGNVARCHAR));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.LONGVARBINARY));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.LONGVARCHAR));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.NCHAR));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.NCLOB));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.NULL));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.NUMERIC));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.NVARCHAR));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.OTHER));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.REAL));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.REF));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.ROWID));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.SMALLINT));
		assertTrue(SQLXMLDataMapper.isSQLXMLType(Types.SQLXML));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.STRUCT));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.TIME));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.TIMESTAMP));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.TINYINT));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.VARBINARY));
		assertFalse(SQLXMLDataMapper.isSQLXMLType(Types.VARCHAR));
	}
}
