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

import jp.co.ntt.oss.data.DatabaseResource;
import jp.co.ntt.oss.mapper.IntegerDataMapper;
import jp.co.ntt.oss.mapper.MappingData;
import jp.co.ntt.oss.mapper.StringDataMapper;
import jp.co.ntt.oss.mapper.TimestampDataMapper;
import jp.co.ntt.oss.utility.PrivateAccessor;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;

public class FullReaderTest {
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
	public final void testFullReader() {
		FullReader reader;
		String actual;

		// null argument
		try {
			new FullReader(null, "query");
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		}
		try {
			new FullReader(masterConn, null);
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		}

		// SQLException
		try {
			new FullReader(masterConn, "aaa");
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
			reader = new FullReader(masterConn, "SELECT * FROM public.foo");
			assertNotNull(reader);

			Statement stmt = (Statement) PrivateAccessor.getPrivateField(
					reader, "stmt");
			assertNotNull(stmt);
			assertEquals(100, stmt.getFetchSize());

			ResultSet rset = (ResultSet) PrivateAccessor.getPrivateField(
					reader, "rset");
			assertNotNull(rset);
			assertTrue(rset.next());

			MappingData columnMapping = ((MappingData) PrivateAccessor
					.getPrivateField(reader, "columnMapping"));
			assertNotNull(columnMapping);
			assertEquals(3, columnMapping.getColumnCount());
			assertEquals(Types.INTEGER, columnMapping.getColumnType(0));
			assertEquals(Types.VARCHAR, columnMapping.getColumnType(1));
			assertEquals(Types.TIMESTAMP, columnMapping.getColumnType(2));
			assertEquals("int4", columnMapping.getColumnTypeName(0));
			assertEquals("text", columnMapping.getColumnTypeName(1));
			assertEquals("timestamp", columnMapping.getColumnTypeName(2));

			reader.close();
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testClose() {
		try {
			FullReader reader = new FullReader(masterConn,
					"SELECT * FROM public.foo");

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
			FullReader reader = new FullReader(masterConn,
					"SELECT * FROM public.foo");
			MappingData columnMapping = reader.getColumnMapping();
			columnMapping.setDataMapper(0, new IntegerDataMapper());
			columnMapping.setDataMapper(1, new StringDataMapper());
			columnMapping.setDataMapper(2, new TimestampDataMapper());

			Object[] columns = reader.getNextColumns();
			assertNotNull(columns);
			assertEquals(3, columns.length);
			assertEquals(new Integer(1), columns[0]);
			assertEquals("A", columns[1]);
			assertEquals(Timestamp.valueOf("2010-01-01 00:00:01"), columns[2]);

			reader.getNextColumns();
			reader.getNextColumns();
			reader.getNextColumns();
			reader.getNextColumns();
			reader.getNextColumns();

			columns = reader.getNextColumns();
			assertNotNull(columns);
			assertEquals(3, columns.length);
			assertEquals(Integer.valueOf(7), columns[0]);
			assertEquals("G", columns[1]);
			assertEquals(Timestamp.valueOf("2010-01-01 00:00:07"), columns[2]);

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
			FullReader reader = new FullReader(masterConn,
					"SELECT * FROM public.foo");

			int count = reader.getColumnCount();
			assertEquals(3, count);

			reader.close();
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetColumnMapping() {
		MappingData columnMapping = null;
		try {
			FullReader reader = new FullReader(masterConn,
					"SELECT * FROM public.foo");

			columnMapping = reader.getColumnMapping();

			assertEquals(3, columnMapping.getColumnCount());
			assertEquals(Types.INTEGER, columnMapping.getColumnType(0));
			assertEquals(Types.VARCHAR, columnMapping.getColumnType(1));
			assertEquals(Types.TIMESTAMP, columnMapping.getColumnType(2));
			assertEquals("int4", columnMapping.getColumnTypeName(0));
			assertEquals("text", columnMapping.getColumnTypeName(1));
			assertEquals("timestamp", columnMapping.getColumnTypeName(2));
			assertNotNull(columnMapping.getDataMappers());
			assertEquals(3, columnMapping.getDataMappers().length);
			assertNull(columnMapping.getDataMapper(0));

			reader.close();
		} catch (Exception e) {
			e.printStackTrace();
			fail("exception thrown");
		}
		try {
			columnMapping.getColumnType(3);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			columnMapping.getColumnTypeName(3);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			columnMapping.getDataMapper(3);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
	}
}
