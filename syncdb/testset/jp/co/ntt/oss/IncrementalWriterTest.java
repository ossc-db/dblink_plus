package jp.co.ntt.oss;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.sql.Connection;
import java.sql.ParameterMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.Hashtable;

import javax.transaction.UserTransaction;

import jp.co.ntt.oss.data.DatabaseResource;
import jp.co.ntt.oss.data.SyncDatabaseDAO;
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

public class IncrementalWriterTest {
	private static DatabaseResource replicaDB = null;
	private static Connection replicaConn = null;

	protected ByteArrayOutputStream _baos;
	protected PrintStream _out;
	protected static String newLine;

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
		_baos = new ByteArrayOutputStream();
		_out = System.out;
		System.setOut(new PrintStream(new BufferedOutputStream(_baos)));

		UserTransaction utx = replicaDB.getUserTransaction();
		utx.begin();
	}

	@After
	public void tearDown() throws Exception {
		UserTransaction utx = replicaDB.getUserTransaction();
		utx.rollback();

		System.setOut(_out);
	}

	@SuppressWarnings("unchecked")
	@Test
	public final void testIncrementalWriter() {
		IncrementalWriter writer;
		Hashtable<Short, String> PKNames = new Hashtable<Short, String>();
		PKNames.put(new Short((short) 1), "\"val1\"");

		// argument error
		try {
			new IncrementalWriter(null, "public", "rep_foo", 4, PKNames);
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			new IncrementalWriter(replicaConn, null, "rep_foo", 4, PKNames);
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			new IncrementalWriter(replicaConn, "public", null, 4, PKNames);
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			new IncrementalWriter(replicaConn, "public", "rep_foo", 4, null);
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			new IncrementalWriter(replicaConn, "public", "rep_foo", 4,
					new Hashtable<Short, String>());
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			new IncrementalWriter(replicaConn, "public", "rep_foo", 1, PKNames);
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}

		// column count error
		try {
			new IncrementalWriter(replicaConn, "public", "rep_foo", 3, PKNames);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("refresh query error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			new IncrementalWriter(replicaConn, "public", "rep_foo", 5, PKNames);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("refresh query error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}

		// normal case
		try {
			writer = new IncrementalWriter(replicaConn, "public", "rep_foo", 4,
					PKNames);

			assertNotNull(writer);

			Integer batchCount = (Integer) PrivateAccessor.getPrivateField(
					writer, "batchCount");
			assertNotNull(batchCount);
			assertEquals(0, batchCount.intValue());

			PreparedStatement deletePstmt = (PreparedStatement) PrivateAccessor
					.getPrivateField(writer, "deletePstmt");
			assertNull(deletePstmt);

			PreparedStatement insertPstmt = (PreparedStatement) PrivateAccessor
					.getPrivateField(writer, "insertPstmt");
			assertNull(insertPstmt);

			PreparedStatement updatePstmt = (PreparedStatement) PrivateAccessor
					.getPrivateField(writer, "updatePstmt");
			assertNull(updatePstmt);

			Hashtable<Short, String> names = (Hashtable<Short, String>) PrivateAccessor
					.getPrivateField(writer, "pkNames");
			assertNotNull(names);
			assertEquals(1, names.size());
			assertEquals("\"val1\"", names.get(Short.valueOf((short) 1)));

			int[] PKPosition = (int[]) PrivateAccessor.getPrivateField(writer,
					"pkPosition");
			assertNotNull(PKPosition);
			assertEquals(1, PKPosition.length);
			assertEquals(0, PKPosition[0]);

			String[] columnNames = (String[]) PrivateAccessor.getPrivateField(
					writer, "columnNames");
			assertNotNull(columnNames);
			assertEquals(3, columnNames.length);
			assertEquals("\"val1\"", columnNames[0]);
			assertEquals("\"val2\"", columnNames[1]);
			assertEquals("\"val3\"", columnNames[2]);

			MappingData columnMapping = ((MappingData) PrivateAccessor
					.getPrivateField(writer, "columnMapping"));
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

			writer.close();
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testClose() {
		Hashtable<Short, String> PKNames = new Hashtable<Short, String>();
		PKNames.put(new Short((short) 1), "\"val1\"");

		try {
			IncrementalWriter writer = new IncrementalWriter(replicaConn,
					"public", "rep_foo_inc", 4, PKNames);

			MappingData columnMapping = writer.getColumnMapping();
			columnMapping.setDataMapper(0, new IntegerDataMapper());
			columnMapping.setDataMapper(1, new IntegerDataMapper());
			columnMapping.setDataMapper(2, new StringDataMapper());
			columnMapping.setDataMapper(3, new TimestampDataMapper());

			writer.prepare(replicaConn, "public.rep_foo_inc");

			Object[] columns = new Object[7];
			columns[5] = "abc";
			columns[6] = Timestamp.valueOf("2010-01-01 12:34:56");
			int batchCount;
			Long zero = Long.valueOf(0);
			Long one = Long.valueOf(1);

			columns[0] = columns[1] = columns[2] = one;
			columns[3] = columns[4] = Integer.valueOf(1);
			writer.setColumns(columns);

			columns[2] = one;
			columns[0] = columns[1] = zero;
			columns[3] = columns[4] = Integer.valueOf(2);
			writer.setColumns(columns);

			columns[4] = null;
			columns[0] = one;
			columns[1] = columns[2] = zero;

			for (int i = 3; i <= 20; i++) {
				columns[3] = Integer.valueOf(i);
				writer.setColumns(columns);
			}

			batchCount = ((Integer) PrivateAccessor.getPrivateField(writer,
					"batchCount")).intValue();
			assertEquals(20, batchCount);

			Statement stmt = replicaConn.createStatement();
			ResultSet rset = stmt
					.executeQuery("SELECT count(*) FROM public.rep_foo_inc WHERE val3 IS NOT NULL");
			assertTrue(rset.next());
			assertEquals(0, rset.getInt(1));
			rset.close();

			writer.close();

			batchCount = ((Integer) PrivateAccessor.getPrivateField(writer,
					"batchCount")).intValue();
			assertEquals(0, batchCount);
			assertEquals(20, writer.getExecCount());

			rset = stmt
					.executeQuery("SELECT count(*) FROM public.rep_foo_inc WHERE val3 IS NOT NULL");
			assertTrue(rset.next());
			assertEquals(2, rset.getInt(1));
			rset.close();

			rset = stmt
					.executeQuery("SELECT count(*), max(val1), min(val1) FROM public.rep_foo_inc");
			assertTrue(rset.next());
			assertEquals(2, rset.getInt(1));
			assertEquals(2, rset.getInt(2));
			assertEquals(1, rset.getInt(3));
			rset.close();

			writer.close();

			batchCount = ((Integer) PrivateAccessor.getPrivateField(writer,
					"batchCount")).intValue();
			assertEquals(0, batchCount);
			assertEquals(20, writer.getExecCount());

			rset = stmt
					.executeQuery("SELECT count(*), max(val1), min(val1) FROM public.rep_foo_inc");
			assertTrue(rset.next());
			assertEquals(2, rset.getInt(1));
			assertEquals(2, rset.getInt(2));
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
		Hashtable<Short, String> PKNames = new Hashtable<Short, String>();
		PKNames.put(Short.valueOf((short) 1), "\"val1\"");
		IncrementalWriter writer = null;

		try {
			writer = new IncrementalWriter(replicaConn, "public", "rep_foo", 4,
					PKNames);

			MappingData columnMapping = writer.getColumnMapping();
			columnMapping.setDataMapper(0, new IntegerDataMapper());
			columnMapping.setDataMapper(1, new IntegerDataMapper());
			columnMapping.setDataMapper(2, new StringDataMapper());
			columnMapping.setDataMapper(3, new TimestampDataMapper());
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
			columnMapping.setDataMapper(3, new OtherDataMapper());

			writer.prepare(replicaConn, "public.rep_foo");

			// System.out.flush();
			// assertEquals(
			// "DEBUG - FULL REFRESH writer query : INSERT INTO public.rep_foo VALUES(?,?,CAST(? AS timestamp))",
			// _baos.toString());

			// DELETE statement
			PreparedStatement deletePstmt = (PreparedStatement) PrivateAccessor
					.getPrivateField(writer, "deletePstmt");
			assertNotNull(deletePstmt);
			ParameterMetaData pmd = deletePstmt.getParameterMetaData();
			assertEquals(1, pmd.getParameterCount());
			assertEquals(ParameterMetaData.parameterModeIn, pmd
					.getParameterMode(1));
			assertEquals(Types.INTEGER, pmd.getParameterType(1));

			// INSERT statement
			PreparedStatement insertPstmt = (PreparedStatement) PrivateAccessor
					.getPrivateField(writer, "insertPstmt");
			assertNotNull(insertPstmt);
			pmd = insertPstmt.getParameterMetaData();
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

			// UPDATE statement
			PreparedStatement updatePstmt = (PreparedStatement) PrivateAccessor
					.getPrivateField(writer, "updatePstmt");
			assertNotNull(updatePstmt);
			pmd = updatePstmt.getParameterMetaData();
			assertEquals(4, pmd.getParameterCount());
			assertEquals(ParameterMetaData.parameterModeIn, pmd
					.getParameterMode(1));
			assertEquals(ParameterMetaData.parameterModeIn, pmd
					.getParameterMode(2));
			assertEquals(ParameterMetaData.parameterModeIn, pmd
					.getParameterMode(3));
			assertEquals(ParameterMetaData.parameterModeIn, pmd
					.getParameterMode(4));
			assertEquals(Types.INTEGER, pmd.getParameterType(1));
			assertEquals(Types.VARCHAR, pmd.getParameterType(2));
			assertEquals(Types.TIMESTAMP, pmd.getParameterType(3));
			assertEquals(Types.INTEGER, pmd.getParameterType(4));

			writer.close();
		} catch (Exception e) {
			e.printStackTrace();
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetColumns() {
		Hashtable<Short, String> PKNames = new Hashtable<Short, String>();
		PKNames.put(new Short((short) 1), "\"val1\"");
		IncrementalWriter writer = null;

		try {
			writer = new IncrementalWriter(replicaConn, "public",
					"rep_foo_inc", 4, PKNames);

			MappingData columnMapping = writer.getColumnMapping();
			columnMapping.setDataMapper(0, new IntegerDataMapper());
			columnMapping.setDataMapper(1, new IntegerDataMapper());
			columnMapping.setDataMapper(2, new StringDataMapper());
			columnMapping.setDataMapper(3, new TimestampDataMapper());
			writer.prepare(replicaConn, "rep_foo_inc");
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
			writer.setColumns(new Object[6]);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			writer.setColumns(new Object[8]);
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

			rset = stmt.executeQuery("SELECT * FROM public.rep_foo_inc");
			SyncDatabaseDAO.printResultSet(rset);
			rset.close();

			Object[] columns = new Object[7];
			columns[5] = "abc";
			columns[6] = Timestamp.valueOf("2010-01-01 12:34:56");
			int batchCount;
			Long zero = Long.valueOf(0);
			Long one = Long.valueOf(1);
			Long two = Long.valueOf(2);

			columns[0] = columns[1] = columns[2] = one;
			columns[3] = columns[4] = Integer.valueOf(1);
			writer.setColumns(columns);
			assertEquals(1, writer.getExecCount());
			assertEquals(1, writer.getDeleteCount());
			assertEquals(1, writer.getInsertCount());
			assertEquals(0, writer.getUpdateCount());
			assertEquals(0, writer.getDiffCount());

			columns[0] = columns[1] = one;
			columns[2] = zero;
			columns[3] = columns[4] = Integer.valueOf(2);
			writer.setColumns(columns);
			assertEquals(2, writer.getExecCount());
			assertEquals(2, writer.getDeleteCount());
			assertEquals(2, writer.getInsertCount());
			assertEquals(0, writer.getUpdateCount());
			assertEquals(0, writer.getDiffCount());

			columns[2] = one;
			columns[0] = columns[1] = zero;
			columns[3] = columns[4] = Integer.valueOf(3);
			writer.setColumns(columns);
			assertEquals(3, writer.getExecCount());
			assertEquals(2, writer.getDeleteCount());
			assertEquals(2, writer.getInsertCount());
			assertEquals(1, writer.getUpdateCount());
			assertEquals(0, writer.getDiffCount());

			columns[0] = columns[2] = one;
			columns[1] = two;
			columns[3] = columns[4] = Integer.valueOf(4);
			writer.setColumns(columns);
			assertEquals(4, writer.getExecCount());
			assertEquals(2, writer.getDeleteCount());
			assertEquals(3, writer.getInsertCount());
			assertEquals(1, writer.getUpdateCount());
			assertEquals(1, writer.getDiffCount());

			columns[0] = one;
			columns[1] = two;
			columns[2] = zero;
			columns[3] = columns[4] = Integer.valueOf(5);
			writer.setColumns(columns);
			assertEquals(5, writer.getExecCount());
			assertEquals(2, writer.getDeleteCount());
			assertEquals(4, writer.getInsertCount());
			assertEquals(1, writer.getUpdateCount());
			assertEquals(2, writer.getDiffCount());

			columns[1] = columns[2] = one;
			columns[0] = zero;
			columns[3] = columns[4] = Integer.valueOf(6);
			writer.setColumns(columns);
			assertEquals(6, writer.getExecCount());
			assertEquals(2, writer.getDeleteCount());
			assertEquals(5, writer.getInsertCount());
			assertEquals(1, writer.getUpdateCount());
			assertEquals(3, writer.getDiffCount());

			columns[1] = one;
			columns[0] = columns[2] = zero;
			columns[3] = columns[4] = Integer.valueOf(7);
			writer.setColumns(columns);
			assertEquals(7, writer.getExecCount());
			assertEquals(2, writer.getDeleteCount());
			assertEquals(6, writer.getInsertCount());
			assertEquals(1, writer.getUpdateCount());
			assertEquals(4, writer.getDiffCount());

			columns[4] = null;

			columns[0] = two;
			columns[1] = columns[2] = one;
			columns[3] = Integer.valueOf(8);
			writer.setColumns(columns);
			assertEquals(8, writer.getExecCount());
			assertEquals(3, writer.getDeleteCount());
			assertEquals(6, writer.getInsertCount());
			assertEquals(1, writer.getUpdateCount());
			assertEquals(3, writer.getDiffCount());

			columns[0] = two;
			columns[1] = one;
			columns[2] = zero;
			columns[3] = Integer.valueOf(9);
			writer.setColumns(columns);
			assertEquals(9, writer.getExecCount());
			assertEquals(4, writer.getDeleteCount());
			assertEquals(6, writer.getInsertCount());
			assertEquals(1, writer.getUpdateCount());
			assertEquals(2, writer.getDiffCount());

			columns[0] = columns[2] = one;
			columns[1] = zero;
			columns[3] = Integer.valueOf(10);
			writer.setColumns(columns);
			assertEquals(10, writer.getExecCount());
			assertEquals(5, writer.getDeleteCount());
			assertEquals(6, writer.getInsertCount());
			assertEquals(1, writer.getUpdateCount());
			assertEquals(1, writer.getDiffCount());

			columns[0] = one;
			columns[1] = columns[2] = zero;
			columns[3] = Integer.valueOf(11);
			writer.setColumns(columns);
			assertEquals(11, writer.getExecCount());
			assertEquals(6, writer.getDeleteCount());
			assertEquals(6, writer.getInsertCount());
			assertEquals(1, writer.getUpdateCount());
			assertEquals(0, writer.getDiffCount());

			columns[0] = columns[1] = columns[2] = one;
			columns[3] = Integer.valueOf(12);
			writer.setColumns(columns);
			assertEquals(12, writer.getExecCount());
			assertEquals(6, writer.getDeleteCount());
			assertEquals(6, writer.getInsertCount());
			assertEquals(1, writer.getUpdateCount());
			assertEquals(0, writer.getDiffCount());

			columns[0] = columns[1] = one;
			columns[2] = zero;
			columns[3] = Integer.valueOf(13);
			writer.setColumns(columns);
			assertEquals(13, writer.getExecCount());
			assertEquals(6, writer.getDeleteCount());
			assertEquals(6, writer.getInsertCount());
			assertEquals(1, writer.getUpdateCount());
			assertEquals(0, writer.getDiffCount());

			for (int i = 14; i < 100; i++) {
				columns[3] = Integer.valueOf(i);
				writer.setColumns(columns);
				assertEquals(i, writer.getExecCount());
				assertEquals(6, writer.getDeleteCount());
				assertEquals(6, writer.getInsertCount());
				assertEquals(1, writer.getUpdateCount());
				assertEquals(0, writer.getDiffCount());
				batchCount = ((Integer) PrivateAccessor.getPrivateField(writer,
						"batchCount")).intValue();
				assertEquals(i, batchCount);
			}

			rset = stmt
					.executeQuery("SELECT count(*) FROM public.rep_foo_inc WHERE val3 IS NOT NULL");
			assertTrue(rset.next());
			assertEquals(0, rset.getInt(1));
			rset.close();

			columns[3] = Integer.valueOf(100);
			writer.setColumns(columns);
			assertEquals(100, writer.getExecCount());
			assertEquals(6, writer.getDeleteCount());
			assertEquals(6, writer.getInsertCount());
			assertEquals(1, writer.getUpdateCount());
			assertEquals(0, writer.getDiffCount());
			batchCount = ((Integer) PrivateAccessor.getPrivateField(writer,
					"batchCount")).intValue();
			assertEquals(0, batchCount);

			rset = stmt
					.executeQuery("SELECT count(*) FROM public.rep_foo_inc WHERE val3 IS NOT NULL");
			assertTrue(rset.next());
			assertEquals(7, rset.getInt(1));
			rset.close();

			for (int i = 1; i <= 7; i++) {
				rset = stmt
						.executeQuery("SELECT * FROM public.rep_foo_inc WHERE val1 = '"
								+ i + "'");
				assertTrue(rset.next());
				assertEquals("abc", rset.getString(2));
				assertEquals(Timestamp.valueOf("2010-01-01 12:34:56"), rset
						.getTimestamp(3));
				rset.close();
			}
			rset.close();
			stmt.close();

			writer.close();
		} catch (Exception e) {
			e.printStackTrace();
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetColumnCount() {
		Hashtable<Short, String> PKNames = new Hashtable<Short, String>();
		PKNames.put(Short.valueOf((short) 1), "\"val1\"");
		IncrementalWriter writer = null;

		try {
			writer = new IncrementalWriter(replicaConn, "public", "rep_foo", 4,
					PKNames);

			int count = writer.getColumnCount();
			assertEquals(4, count);

			writer.close();
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetColumnMapping() {
		Hashtable<Short, String> PKNames = new Hashtable<Short, String>();
		PKNames.put(Short.valueOf((short) 1), "\"val1\"");
		IncrementalWriter writer = null;
		MappingData columnMapping = null;

		try {
			writer = new IncrementalWriter(replicaConn, "public", "rep_foo", 4,
					PKNames);

			columnMapping = writer.getColumnMapping();

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

			writer.close();
		} catch (Exception e) {
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
	public final void testGetExecCount() {
		Hashtable<Short, String> PKNames = new Hashtable<Short, String>();
		PKNames.put(Short.valueOf((short) 1), "\"val1\"");
		IncrementalWriter writer = null;

		try {
			writer = new IncrementalWriter(replicaConn, "public", "rep_foo", 4,
					PKNames);
		} catch (Exception e) {
			fail("exception thrown");
		}

		PrivateAccessor.setPrivateField(writer, "execCount", 1);
		assertEquals(1, writer.getExecCount());
		PrivateAccessor.setPrivateField(writer, "execCount", 100);
		assertEquals(100, writer.getExecCount());
	}

	@Test
	public final void testGetDeleteCount() {
		Hashtable<Short, String> PKNames = new Hashtable<Short, String>();
		PKNames.put(Short.valueOf((short) 1), "\"val1\"");
		IncrementalWriter writer = null;

		try {
			writer = new IncrementalWriter(replicaConn, "public", "rep_foo", 4,
					PKNames);
		} catch (Exception e) {
			fail("exception thrown");
		}

		PrivateAccessor.setPrivateField(writer, "deleteCount", 1);
		assertEquals(1, writer.getDeleteCount());
		PrivateAccessor.setPrivateField(writer, "deleteCount", 100);
		assertEquals(100, writer.getDeleteCount());
	}

	@Test
	public final void testGetInsertCount() {
		Hashtable<Short, String> PKNames = new Hashtable<Short, String>();
		PKNames.put(Short.valueOf((short) 1), "\"val1\"");
		IncrementalWriter writer = null;

		try {
			writer = new IncrementalWriter(replicaConn, "public", "rep_foo", 4,
					PKNames);
		} catch (Exception e) {
			fail("exception thrown");
		}

		PrivateAccessor.setPrivateField(writer, "insertCount", 1);
		assertEquals(1, writer.getInsertCount());
		PrivateAccessor.setPrivateField(writer, "insertCount", 100);
		assertEquals(100, writer.getInsertCount());
	}

	@Test
	public final void testGetUpdateCount() {
		Hashtable<Short, String> PKNames = new Hashtable<Short, String>();
		PKNames.put(Short.valueOf((short) 1), "\"val1\"");
		IncrementalWriter writer = null;

		try {
			writer = new IncrementalWriter(replicaConn, "public", "rep_foo", 4,
					PKNames);
		} catch (Exception e) {
			fail("exception thrown");
		}

		PrivateAccessor.setPrivateField(writer, "updateCount", 1);
		assertEquals(1, writer.getUpdateCount());
		PrivateAccessor.setPrivateField(writer, "updateCount", 100);
		assertEquals(100, writer.getUpdateCount());
	}
}
