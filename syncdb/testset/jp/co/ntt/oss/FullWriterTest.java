package jp.co.ntt.oss;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.sql.Connection;
import java.sql.ParameterMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;

import javax.transaction.UserTransaction;

import jp.co.ntt.oss.data.DatabaseResource;
import jp.co.ntt.oss.mapper.IntegerDataMapper;
import jp.co.ntt.oss.mapper.MappingData;
import jp.co.ntt.oss.mapper.OtherDataMapper;
import jp.co.ntt.oss.mapper.StringDataMapper;
import jp.co.ntt.oss.mapper.TimestampDataMapper;
import jp.co.ntt.oss.utility.PrivateAccessor;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class FullWriterTest {
	private static DatabaseResource replicaDB = null;
	private static Connection replicaConn = null;

	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		replicaDB = new DatabaseResource("postgres2");
		replicaConn = replicaDB.getConnection();
	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {
		replicaConn.close();
		replicaDB.stop();
	}

	@Before
	public void setUp() throws Exception {
		UserTransaction utx = replicaDB.getUserTransaction();
		utx.begin();
	}

	@After
	public void tearDown() throws Exception {
		UserTransaction utx = replicaDB.getUserTransaction();
		utx.rollback();
	}

	@Test
	public final void testFullWriter() {
		FullWriter writer;
		String actual;

		// argument error
		try {
			new FullWriter(null, "public", "rep_foo", 3);
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		}
		try {
			new FullWriter(replicaConn, null, "rep_foo", 3);
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		}
		try {
			new FullWriter(replicaConn, "public", null, 3);
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		}
		try {
			new FullWriter(replicaConn, "public", "rep_foo", 0);
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		}

		// column count error
		try {
			new FullWriter(replicaConn, "public", "rep_foo", 2);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			String expected = "refresh query error";
			actual = e.getMessage();
			assertEquals(expected, actual);
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			new FullWriter(replicaConn, "public", "rep_foo", 4);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			String expected = "refresh query error";
			actual = e.getMessage();
			assertEquals(expected, actual);
		} catch (SQLException e) {
			fail("other exception thrown");
		}

		// normal case
		try {
			writer = new FullWriter(replicaConn, "public", "rep_foo", 3);
			assertNotNull(writer);

			Integer batchCount = (Integer) PrivateAccessor.getPrivateField(
					writer, "batchCount");
			assertNotNull(batchCount);
			assertEquals(0, batchCount.intValue());

			PreparedStatement pstmt = (PreparedStatement) PrivateAccessor
					.getPrivateField(writer, "pstmt");
			assertNull(pstmt);

			MappingData columnMapping = ((MappingData) PrivateAccessor
					.getPrivateField(writer, "columnMapping"));
			assertNotNull(columnMapping);
			assertEquals(3, columnMapping.getColumnCount());
			assertEquals(Types.INTEGER, columnMapping.getColumnType(0));
			assertEquals(Types.VARCHAR, columnMapping.getColumnType(1));
			assertEquals(Types.TIMESTAMP, columnMapping.getColumnType(2));
			assertEquals("int4", columnMapping.getColumnTypeName(0));
			assertEquals("text", columnMapping.getColumnTypeName(1));
			assertEquals("timestamp", columnMapping.getColumnTypeName(2));

			writer.close();
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testClose() {
		try {
			FullWriter writer = new FullWriter(replicaConn, "public",
					"rep_foo", 3);

			MappingData columnMapping = writer.getColumnMapping();
			columnMapping.setDataMapper(0, new IntegerDataMapper());
			columnMapping.setDataMapper(1, new StringDataMapper());
			columnMapping.setDataMapper(2, new TimestampDataMapper());
			writer.prepare(replicaConn, "public.rep_foo");

			Object[] columns = new Object[3];
			columns[1] = "abc";
			columns[2] = Timestamp.valueOf("2010-01-01 12:34:56");

			for (int i = 1; i <= 10; i++) {
				columns[0] = Integer.valueOf(i);
				writer.setColumns(columns);
			}

			int batchCount = ((Integer) PrivateAccessor.getPrivateField(writer,
					"batchCount")).intValue();
			assertEquals(10, batchCount);

			Statement stmt = replicaConn.createStatement();
			ResultSet rset = stmt
					.executeQuery("SELECT count(*) FROM public.rep_foo");
			assertTrue(rset.next());
			assertEquals(0, rset.getInt(1));
			rset.close();

			writer.close();

			batchCount = ((Integer) PrivateAccessor.getPrivateField(writer,
					"batchCount")).intValue();
			assertEquals(0, batchCount);

			rset = stmt
					.executeQuery("SELECT count(*), max(val1), min(val1) FROM public.rep_foo");
			assertTrue(rset.next());
			assertEquals(10, rset.getInt(1));
			assertEquals(10, rset.getInt(2));
			assertEquals(1, rset.getInt(3));
			rset.close();

			writer.close();

			batchCount = ((Integer) PrivateAccessor.getPrivateField(writer,
					"batchCount")).intValue();
			assertEquals(0, batchCount);

			rset = stmt
					.executeQuery("SELECT count(*), max(val1), min(val1) FROM public.rep_foo");
			assertTrue(rset.next());
			assertEquals(10, rset.getInt(1));
			assertEquals(10, rset.getInt(2));
			assertEquals(1, rset.getInt(3));
			rset.close();
			stmt.close();

		} catch (Exception e) {
			e.printStackTrace();
			fail("exception thrown");
		}
	}

	@Test
	public final void testPrepare() {
		FullWriter writer = null;

		try {
			writer = new FullWriter(replicaConn, "public", "rep_foo", 3);
			MappingData columnMapping = writer.getColumnMapping();
			columnMapping.setDataMapper(0, new IntegerDataMapper());
			columnMapping.setDataMapper(1, new StringDataMapper());
			columnMapping.setDataMapper(2, new TimestampDataMapper());
		} catch (Exception e) {
			fail("exception thrown");
		}

		// argument error
		try {
			writer.prepare(null, "public.rep_foo");
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			writer.prepare(replicaConn, null);
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}

		// normal case
		try {
			MappingData columnMapping = writer.getColumnMapping();
			columnMapping.setDataMapper(2, new OtherDataMapper());
			// columnMapping.setColumnTypeName(2, "INTERVAL");

			writer.prepare(replicaConn, "public.rep_foo");

			// System.out.flush();
			// assertEquals(
			// "DEBUG - FULL REFRESH writer query : INSERT INTO public.rep_foo VALUES(?,?,CAST(? AS timestamp))",
			// _baos.toString());

			PreparedStatement pstmt = (PreparedStatement) PrivateAccessor
					.getPrivateField(writer, "pstmt");
			assertNotNull(pstmt);
			ParameterMetaData pmd = pstmt.getParameterMetaData();
			assertEquals(3, pmd.getParameterCount());
			assertEquals(ParameterMetaData.parameterModeIn, pmd
					.getParameterMode(1));
			assertEquals(ParameterMetaData.parameterModeIn, pmd
					.getParameterMode(2));
			assertEquals(ParameterMetaData.parameterModeIn, pmd
					.getParameterMode(3));
			assertEquals(Types.INTEGER, pmd.getParameterType(1));
			assertEquals(Types.VARCHAR, pmd.getParameterType(2));
			assertEquals(Types.TIMESTAMP, pmd.getParameterType(3));

			writer.close();
		} catch (Exception e) {
			e.printStackTrace();
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetColumns() {
		FullWriter writer = null;

		try {
			writer = new FullWriter(replicaConn, "public", "rep_foo", 3);
			MappingData columnMapping = writer.getColumnMapping();
			columnMapping.setDataMapper(0, new IntegerDataMapper());
			columnMapping.setDataMapper(1, new StringDataMapper());
			columnMapping.setDataMapper(2, new TimestampDataMapper());
			writer.prepare(replicaConn, "rep_foo");
		} catch (Exception e) {
			fail("exception thrown");
		}

		// argument error
		try {
			writer.setColumns(null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			writer.setColumns(new Object[2]);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			writer.setColumns(new Object[4]);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}

		// normal case
		try {
			Statement stmt = null;
			ResultSet rset = null;
			stmt = replicaConn.createStatement();

			Object[] columns = new Object[3];
			columns[1] = "abc";
			columns[2] = Timestamp.valueOf("2010-01-01 12:34:56");
			int batchCount;

			for (int i = 1; i < 100; i++) {
				columns[0] = new Integer(i);
				writer.setColumns(columns);
				rset = stmt.executeQuery("SELECT count(*) FROM public.rep_foo");
				assertTrue(rset.next());
				assertEquals(0, rset.getInt(1));
				rset.close();

				batchCount = ((Integer) PrivateAccessor.getPrivateField(writer,
						"batchCount")).intValue();
				assertEquals(i, batchCount);
			}

			columns[0] = Integer.valueOf(100);
			writer.setColumns(columns);

			batchCount = ((Integer) PrivateAccessor.getPrivateField(writer,
					"batchCount")).intValue();
			assertEquals(0, batchCount);

			rset = stmt
					.executeQuery("SELECT count(*), max(val1), min(val1) FROM public.rep_foo");
			assertTrue(rset.next());
			assertEquals(100, rset.getInt(1));
			assertEquals(100, rset.getInt(2));
			assertEquals(1, rset.getInt(3));
			rset.close();

			rset = stmt
					.executeQuery("SELECT DISTINCT val2, val3 FROM public.rep_foo");
			assertTrue(rset.next());
			assertEquals("abc", rset.getString(1));
			assertEquals(Timestamp.valueOf("2010-01-01 12:34:56"), rset
					.getTimestamp(2));
			assertFalse(rset.next());
			assertFalse(rset.next());
			rset.close();
			stmt.close();

			writer.close();
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetColumnCount() {
		try {
			FullWriter writer = new FullWriter(replicaConn, "public",
					"rep_foo", 3);

			int count = writer.getColumnCount();
			assertEquals(3, count);

			writer.close();
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetColumnMapping() {
		MappingData columnMapping = null;
		try {
			FullWriter writer = new FullWriter(replicaConn, "public",
					"rep_foo", 3);

			columnMapping = writer.getColumnMapping();

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

			writer.close();
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
