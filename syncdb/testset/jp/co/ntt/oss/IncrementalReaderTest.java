package jp.co.ntt.oss;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.Hashtable;

import jp.co.ntt.oss.data.DatabaseResource;
import jp.co.ntt.oss.mapper.IntegerDataMapper;
import jp.co.ntt.oss.mapper.MappingData;
import jp.co.ntt.oss.mapper.StringDataMapper;
import jp.co.ntt.oss.mapper.TimestampDataMapper;
import jp.co.ntt.oss.utility.PrivateAccessor;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;

public class IncrementalReaderTest {
	private static DatabaseResource masterDB = null;
	private static Connection masterConn = null;

	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		masterDB = new DatabaseResource("postgres1");
		masterConn = masterDB.getConnection();
	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {
		masterConn.close();
		masterDB.stop();
	}

	@Test
	public final void testIncrementalReader() {
		IncrementalReader reader;
		String actual;

		// argument error
		try {
			new IncrementalReader(null,
					"SELECT '1', '2', '3', val1, * FROM inc", 1);
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			new IncrementalReader(null,
					"SELECT '1', '2', '3', val1, * FROM inc", 1);
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			new IncrementalReader(masterConn,
					"SELECT '1', '2', '3', val1, * FROM inc", 0);
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}

		// SQLException
		try {
			new IncrementalReader(masterConn, "aaa", 1);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			fail("other exception thrown");
		} catch (SQLException e) {
			String expected = "ERROR: syntax error at or near \"aaa\"\n"
					+ "  Position: 1";
			actual = e.getMessage();
			assertEquals(expected, actual);
		}

		// normal case
		try {
			reader = new IncrementalReader(masterConn,
					"SELECT '1', '2', '3', val1, * FROM foo", 1);
			assertNotNull(reader);

			Statement stmt = (Statement) PrivateAccessor.getPrivateField(
					reader, "stmt");
			assertNotNull(stmt);
			assertEquals(100, stmt.getFetchSize());

			ResultSet rset = (ResultSet) PrivateAccessor.getPrivateField(
					reader, "rset");
			assertNotNull(rset);
			assertTrue(rset.next());

			Integer pkCount = (Integer) PrivateAccessor.getPrivateField(reader,
					"pkCount");
			assertNotNull(pkCount);
			assertEquals(1, pkCount.intValue());

			MappingData columnMapping = ((MappingData) PrivateAccessor
					.getPrivateField(reader, "columnMapping"));
			assertNotNull(columnMapping);
			assertEquals(4, columnMapping.getColumnCount());
			assertEquals(Types.INTEGER, columnMapping.getColumnType(0));
			assertEquals(Types.INTEGER, columnMapping.getColumnType(1));
			assertEquals(Types.VARCHAR, columnMapping.getColumnType(2));
			assertEquals(Types.TIMESTAMP, columnMapping.getColumnType(3));
			assertEquals("int4", columnMapping.getColumnTypeName(0));
			assertEquals("int4", columnMapping.getColumnTypeName(1));
			assertEquals("text", columnMapping.getColumnTypeName(2));
			assertEquals("timestamp", columnMapping.getColumnTypeName(3));

			reader.close();
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testClose() {
		try {
			IncrementalReader reader = new IncrementalReader(masterConn,
					"SELECT '1', '2', '3', val1, * FROM foo", 1);

			ResultSet rset = (ResultSet) PrivateAccessor.getPrivateField(
					reader, "rset");
			assertFalse(rset.isClosed());

			reader.close();

			assertTrue(rset.isClosed());
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetNextColumns() {
		try {
			IncrementalReader reader = new IncrementalReader(masterConn,
					"SELECT '1', '2', '3', val1, * FROM foo", 1);
			MappingData columnMapping = reader.getColumnMapping();
			columnMapping.setDataMapper(0, new IntegerDataMapper());
			columnMapping.setDataMapper(1, new IntegerDataMapper());
			columnMapping.setDataMapper(2, new StringDataMapper());
			columnMapping.setDataMapper(3, new TimestampDataMapper());

			Object[] columns = reader.getNextColumns();
			assertNotNull(columns);
			assertEquals(7, columns.length);
			assertEquals(Long.valueOf(1), columns[0]);
			assertEquals(Long.valueOf(2), columns[1]);
			assertEquals(Long.valueOf(3), columns[2]);
			assertEquals(new Integer(1), columns[3]);
			assertEquals(new Integer(1), columns[4]);
			assertEquals("A", columns[5]);
			assertEquals(Timestamp.valueOf("2010-01-01 00:00:01"), columns[6]);

			reader.getNextColumns();
			reader.getNextColumns();
			reader.getNextColumns();
			reader.getNextColumns();
			reader.getNextColumns();

			columns = reader.getNextColumns();
			assertNotNull(columns);
			assertEquals(7, columns.length);
			assertEquals(Long.valueOf((short) 1), columns[0]);
			assertEquals(Long.valueOf((short) 2), columns[1]);
			assertEquals(Long.valueOf((short) 3), columns[2]);
			assertEquals(Integer.valueOf(7), columns[3]);
			assertEquals(Integer.valueOf(7), columns[4]);
			assertEquals("G", columns[5]);
			assertEquals(Timestamp.valueOf("2010-01-01 00:00:07"), columns[6]);

			columns = reader.getNextColumns();
			assertNull(columns);

			reader.close();
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetColumnCount() {
		try {
			IncrementalReader reader = new IncrementalReader(masterConn,
					"SELECT '1', '2', '3', val1, * FROM foo", 1);

			int count = reader.getColumnCount();
			assertEquals(4, count);

			reader.close();
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetColumnMapping() {
		MappingData columnMapping = null;
		try {
			IncrementalReader reader = new IncrementalReader(masterConn,
					"SELECT '1', '2', '3', val1, * FROM foo", 1);

			columnMapping = reader.getColumnMapping();

			assertEquals(4, columnMapping.getColumnCount());
			assertEquals(Types.INTEGER, columnMapping.getColumnType(0));
			assertEquals(Types.INTEGER, columnMapping.getColumnType(1));
			assertEquals(Types.VARCHAR, columnMapping.getColumnType(2));
			assertEquals(Types.TIMESTAMP, columnMapping.getColumnType(3));
			assertEquals("int4", columnMapping.getColumnTypeName(0));
			assertEquals("int4", columnMapping.getColumnTypeName(1));
			assertEquals("text", columnMapping.getColumnTypeName(2));
			assertEquals("timestamp", columnMapping.getColumnTypeName(3));
			assertNotNull(columnMapping.getDataMappers());
			assertEquals(4, columnMapping.getDataMappers().length);
			assertNull(columnMapping.getDataMapper(0));

			reader.close();
		} catch (Exception e) {
			e.printStackTrace();
			fail("exception thrown");
		}
		try {
			columnMapping.getColumnType(4);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			columnMapping.getColumnTypeName(4);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			columnMapping.getDataMapper(4);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
	}

	@Test
	public final void testGetPKCount() {
		try {
			IncrementalReader reader = new IncrementalReader(masterConn,
					"SELECT '1', '2', '3', val1, * FROM foo", 1);

			int count = reader.getPKCount();
			assertEquals(1, count);

			reader.close();
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetIncrementalQuery() {
		Hashtable<Short, String> PKNames = new Hashtable<Short, String>();
		PKNames.put(new Short((short) 1), "PK1");

		String query = null;

		// argument error
		try {
			IncrementalReader
					.getIncrementalQuery(null, "[query]", PKNames, 999);
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			IncrementalReader.getIncrementalQuery("mlogName", null, PKNames,
					999);
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			IncrementalReader.getIncrementalQuery("mlogName", "[query]", null,
					999);
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			IncrementalReader.getIncrementalQuery("mlogName", "[query]",
					new Hashtable<Short, String>(), 999);
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			IncrementalReader.getIncrementalQuery("mlogName", "[query]",
					PKNames, -1);
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}

		// normal case : ont column pk
		try {
			query = IncrementalReader.getIncrementalQuery("mlogName",
					"[query]", PKNames, 999);
			assertEquals(
					"SELECT m.d_cnt, m.i_cnt, m.u_cnt, m.PK1, d.* FROM ( "
							+ "SELECT SUM(CASE WHEN m.dmltype = 'D' THEN 1 ELSE 0 END) d_cnt, "
							+ "SUM(CASE WHEN m.dmltype = 'I' THEN 1 ELSE 0 END) i_cnt, "
							+ "SUM(CASE WHEN m.dmltype = 'U' THEN 1 ELSE 0 END) u_cnt, "
							+ "m.PK1 FROM mlogName m WHERE m.mlogid > 999 GROUP BY PK1) m "
							+ "LEFT OUTER JOIN ( [query]) d ON ( m.PK1 = d.PK1)",
					query);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// normal case : multi column pk
		PKNames.put(Short.valueOf((short) 2), "PK2");
		try {
			query = IncrementalReader.getIncrementalQuery("mlogName",
					"[query]", PKNames, 999);
			assertEquals(
					"SELECT m.d_cnt, m.i_cnt, m.u_cnt, m.PK1, m.PK2, d.* FROM ( "
							+ "SELECT SUM(CASE WHEN m.dmltype = 'D' THEN 1 ELSE 0 END) d_cnt, "
							+ "SUM(CASE WHEN m.dmltype = 'I' THEN 1 ELSE 0 END) i_cnt, "
							+ "SUM(CASE WHEN m.dmltype = 'U' THEN 1 ELSE 0 END) u_cnt, "
							+ "m.PK1, m.PK2 FROM mlogName m WHERE m.mlogid > 999 GROUP BY PK1, PK2) m "
							+ "LEFT OUTER JOIN ( [query]) d ON ( m.PK1 = d.PK1 AND m.PK2 = d.PK2)",
					query);
		} catch (Exception e) {
			fail("exception thrown");
		}
	}
}
