package jp.co.ntt.oss;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.List;

import javax.transaction.UserTransaction;

import jp.co.ntt.oss.data.DatabaseResource;
import jp.co.ntt.oss.data.Subscriber;
import jp.co.ntt.oss.data.Subscription;
import jp.co.ntt.oss.data.SyncDatabaseDAO;
import jp.co.ntt.oss.utility.PrivateAccessor;

import org.apache.commons.cli.BasicParser;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class RefreshCommandTest {
	private static String help;

	// need connection test
	private static DatabaseResource replicaDB = null;
	private static DatabaseResource masterDB = null;
	private static Connection replicaConn = null;
	private static Connection masterConn = null;
	private static DatabaseResource oraDB = null;
	private static Connection oraConn = null;

	// private method test
	private static RefreshCommand com = null;

	// stdout test
	protected ByteArrayOutputStream _baos;
	protected PrintStream _out;
	protected static String newLine;

	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		// need connection test
		masterDB = new DatabaseResource("postgres1");
		replicaDB = new DatabaseResource("postgres2");
		masterConn = masterDB.getConnection();
		replicaConn = replicaDB.getConnection();
		oraDB = new DatabaseResource("oracle");
		oraConn = oraDB.getConnection();

		// private method test
		String[] args = { "refresh", "--server", "postgres2", "--schema",
				"public", "--table", "rep_tab1", "--mode", "full" };
		Options options = RefreshCommand.getOptions();
		try {
			CommandLineParser parser = new BasicParser();
			CommandLine commandLine = parser.parse(options, args);
			com = new RefreshCommand(commandLine);
			assertNotNull(com);
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}

		// stdout test
		newLine = System.getProperty("line.separator");

		help = "usage: SyncDatabase refresh"
				+ newLine
				+ "    --concurrent              without taking exclusive lock on the replica"
				+ newLine + "                              table" + newLine
				+ "    --help                    show help" + newLine
				+ "    --mode <full|incr|auto>   refresh mode, default is auto"
				+ newLine + "    --schema <schema name>    replica schema name"
				+ newLine + "    --server <server name>    replica server name"
				+ newLine + "    --table <table name>      replica table name"
				+ newLine;

	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {
		replicaConn.close();
		masterConn.close();
		replicaDB.stop();
		masterDB.stop();
		oraConn.close();
		oraDB.stop();
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
		System.setOut(_out);

		UserTransaction utx = replicaDB.getUserTransaction();
		utx.rollback();
	}

	@Test
	public final void testRefreshCommand() {
		String actual;
		RefreshCommand command;
		Options options = new Options();
		options.addOption(null, "help", false, "");
		options.addOption(null, "schema", true, "");
		options.addOption(null, "table", true, "");
		options.addOption(null, "server", true, "");
		options.addOption(null, "mode", true, "");
		options.addOption(null, "concurrent", false, "");
		CommandLineParser parser = new BasicParser();

		// necessary argument error
		String[] args1 = { "--schema", "schemaName", "--table", "tableName" };
		try {
			CommandLine commandLine = parser.parse(options, args1);
			new RefreshCommand(commandLine);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("command error", actual);
		} catch (ParseException e) {
			fail("exception thrown");
		}
		String[] args2 = { "--server", "serverName", "--table", "tableName" };
		try {
			CommandLine commandLine = parser.parse(options, args2);
			new RefreshCommand(commandLine);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("command error", actual);
		} catch (ParseException e) {
			fail("exception thrown");
		}
		String[] args3 = { "--server", "serverName", "--schema", "schemaName" };
		try {
			CommandLine commandLine = parser.parse(options, args3);
			new RefreshCommand(commandLine);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("command error", actual);
		} catch (ParseException e) {
			fail("exception thrown");
		}

		// refresh mode error
		String[] args4 = { "--server", "serverName", "--schema", "schemaName",
				"--table", "tableName", "--mode", "FULL" };
		try {
			CommandLine commandLine = parser.parse(options, args4);
			new RefreshCommand(commandLine);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("command error", actual);
		} catch (ParseException e) {
			fail("exception thrown");
		}

		// normal case : default value
		String[] args5 = { "--server", "serverName1", "--schema",
				"schemaName1", "--table", "tableName1" };
		try {
			CommandLine commandLine = parser.parse(options, args5);
			command = new RefreshCommand(commandLine);
			assertNotNull(command);

			String server = (String) PrivateAccessor.getPrivateField(command,
					"server");
			assertNotNull(server);
			assertEquals("serverName1", server);

			String schema = (String) PrivateAccessor.getPrivateField(command,
					"schema");
			assertNotNull(schema);
			assertEquals("schemaName1", schema);

			String table = (String) PrivateAccessor.getPrivateField(command,
					"table");
			assertNotNull(table);
			assertEquals("tableName1", table);

			RefreshMode mode = (RefreshMode) PrivateAccessor.getPrivateField(
					command, "mode");
			assertNotNull(mode);
			assertEquals(RefreshMode.AUTO, mode);

			boolean concurrent = ((Boolean) PrivateAccessor.getPrivateField(
					command, "concurrent")).booleanValue();
			assertFalse(concurrent);

			boolean showHelp = ((Boolean) PrivateAccessor.getPrivateField(
					command, "showHelp")).booleanValue();
			assertFalse(showHelp);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// normal case : not default
		String[] args6 = { "--server", "serverName2", "--schema",
				"schemaName2", "--table", "tableName2", "--concurrent",
				"--mode", "incremental" };
		try {
			CommandLine commandLine = parser.parse(options, args6);
			command = new RefreshCommand(commandLine);
			assertNotNull(command);

			String server = (String) PrivateAccessor.getPrivateField(command,
					"server");
			assertNotNull(server);
			assertEquals("serverName2", server);

			String schema = (String) PrivateAccessor.getPrivateField(command,
					"schema");
			assertNotNull(schema);
			assertEquals("schemaName2", schema);

			String table = (String) PrivateAccessor.getPrivateField(command,
					"table");
			assertNotNull(table);
			assertEquals("tableName2", table);

			RefreshMode mode = (RefreshMode) PrivateAccessor.getPrivateField(
					command, "mode");
			assertNotNull(mode);
			assertEquals(RefreshMode.INCREMENTAL, mode);

			boolean concurrent = ((Boolean) PrivateAccessor.getPrivateField(
					command, "concurrent")).booleanValue();
			assertTrue(concurrent);

			boolean showHelp = ((Boolean) PrivateAccessor.getPrivateField(
					command, "showHelp")).booleanValue();
			assertFalse(showHelp);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// normal case : help
		String[] args7 = { "--help", "--mode", "aaa" };
		try {
			CommandLine commandLine = parser.parse(options, args7);
			command = new RefreshCommand(commandLine);
			assertNotNull(command);

			String server = (String) PrivateAccessor.getPrivateField(command,
					"server");
			assertNull(server);

			String schema = (String) PrivateAccessor.getPrivateField(command,
					"schema");
			assertNull(schema);

			String table = (String) PrivateAccessor.getPrivateField(command,
					"table");
			assertNull(table);

			RefreshMode mode = (RefreshMode) PrivateAccessor.getPrivateField(
					command, "mode");
			assertNotNull(mode);
			assertEquals(RefreshMode.AUTO, mode);

			boolean concurrent = ((Boolean) PrivateAccessor.getPrivateField(
					command, "concurrent")).booleanValue();
			assertFalse(concurrent);

			boolean showHelp = ((Boolean) PrivateAccessor.getPrivateField(
					command, "showHelp")).booleanValue();
			assertTrue(showHelp);
		} catch (Exception e) {
			fail("exception thrown");
		}

		System.out.flush();
		actual = _baos.toString();
		assertEquals(help + help + help + help, actual);
	}

	@Test
	public final void testExecute() {
		String actual;

		UserTransaction utx = null;
		try {
			utx = replicaDB.getUserTransaction();
			utx.rollback();
		} catch (Exception e1) {
			fail("exception thrown");
		}

		// show help
		PrivateAccessor.setPrivateField(com, "showHelp", new Boolean(true));
		try {
			com.execute();

			System.out.flush();
			actual = _baos.toString();
			assertEquals(help, actual);

		} catch (Exception e) {
			fail("exception thrown");
		}

		// replica resource name error
		PrivateAccessor
				.setPrivateField(com, "showHelp", Boolean.valueOf(false));
		PrivateAccessor.setPrivateField(com, "server", "aaa");
		try {
			com.execute();
			fail("no exception");
		} catch (Exception e) {
			actual = e.getMessage();
			assertEquals("resource aaa not found", actual);
		}

		// transaction error
		PrivateAccessor.setPrivateField(com, "table", "foo");
		PrivateAccessor.setPrivateField(com, "server", "postgres2");
		try {
			UserTransaction localUtx = replicaDB.getUserTransaction();
			localUtx.begin();
			com.execute();
			fail("no exception");
		} catch (Exception e) {
			actual = e.getMessage();
			assertEquals("Nested transactions not supported", actual);
		}

		// no subscription error
		PrivateAccessor.setPrivateField(com, "table", "aaa");
		try {
			com.execute();
			fail("no exception");
		} catch (Exception e) {
			actual = e.getMessage();
			assertEquals("public.aaa has no subscription", actual);
		}

		// drop replica error
		PrivateAccessor.setPrivateField(com, "table", "rep_ggg");
		try {
			com.execute();
			fail("no exception");
		} catch (Exception e) {
			actual = e.getMessage();
			e.printStackTrace();
			assertEquals("public.rep_ggg has no subscription", actual);
		}

		// drop master error
		PrivateAccessor.setPrivateField(com, "table", "rep_fff");
		try {
			com.execute();
			fail("no exception");
		} catch (Exception e) {
			actual = e.getMessage();
			e.printStackTrace();
			assertEquals("master table was dropped, subscribe id : 15", actual);
		}

		// master resource name error
		PrivateAccessor.setPrivateField(com, "table", "rep_aaa");
		try {
			com.execute();
			fail("no exception");
		} catch (Exception e) {
			actual = e.getMessage();
			assertEquals("resource aaa not found", actual);
		}

		// no subscriber error
		PrivateAccessor.setPrivateField(com, "table", "rep_bbb");
		try {
			com.execute();
			fail("no exception");
		} catch (Exception e) {
			actual = e.getMessage();
			assertEquals("not found subscriber id 999", actual);
		}

		// last mlog id error
		PrivateAccessor.setPrivateField(com, "table", "rep_ccc");
		try {
			com.execute();
			fail("no exception");
		} catch (Exception e) {
			actual = e.getMessage();
			assertEquals("mlog information is illegal", actual);
		}

		// getExecuteMode error
		PrivateAccessor.setPrivateField(com, "table", "rep_eee");
		PrivateAccessor.setPrivateField(com, "mode", RefreshMode.INCREMENTAL);
		try {
			com.execute();
			fail("no exception");
		} catch (Exception e) {
			actual = e.getMessage();
			assertEquals("full refresh only", actual);
		}

		// normal case
		/*
		 * 再実行可能な仕組みを作成する PrivateAccessor.setPrivateField(com, "table",
		 * "rep_foo"); PrivateAccessor.setPrivateField(com, "mode",
		 * RefreshMode.FULL); try {
		 *
		 * Statement stmt = null; ResultSet rset = null; try { stmt =
		 * replicaConn.createStatement(); rset =
		 * stmt.executeQuery("SELECT relfilenode FROM " +
		 * "pg_catalog.pg_class WHERE relname = 'rep_foo'");
		 * assertTrue(rset.next()); String beforeFilenode = rset.getString(1);
		 *
		 * com.execute();
		 *
		 * rset.close(); rset = stmt.executeQuery("SELECT relfilenode FROM " +
		 * "pg_catalog.pg_class WHERE relname = 'rep_foo'");
		 * assertTrue(rset.next()); String afterFilenode = rset.getString(1);
		 * assertFalse(beforeFilenode.equalsIgnoreCase(afterFilenode));
		 *
		 * rset.close(); rset =
		 * stmt.executeQuery("SELECT * FROM public.rep_foo");
		 *
		 * assertTrue(rset.next()); assertEquals(1, rset.getInt(1));
		 * assertEquals("a", rset.getString(2));
		 * assertEquals(Timestamp.valueOf("2010-01-01 00:00:01"), rset
		 * .getTimestamp(3));
		 *
		 * assertTrue(rset.next()); assertEquals(2, rset.getInt(1));
		 * assertEquals("b", rset.getString(2));
		 * assertEquals(Timestamp.valueOf("2010-01-01 00:00:02"), rset
		 * .getTimestamp(3));
		 *
		 * assertFalse(rset.next()); } catch (Exception e) {
		 * e.printStackTrace(); fail("exception thrown"); } finally { try { if
		 * (stmt != null) stmt.close(); if (rset != null) rset.close(); } catch
		 * (SQLException e) { fail("exception thrown"); } } } catch (Exception
		 * e) { fail("exception thrown"); }
		 */
		try {
			utx.begin();
		} catch (Exception e1) {
			fail("exception thrown");
		}

	}

	/*
	 * 再実行可能な仕組みを作成する
	 */
	// @Test
	public final void testExecute_IncrementalRefresh() {
		UserTransaction utx = null;
		try {
			utx = replicaDB.getUserTransaction();
			utx.rollback();
		} catch (Exception e1) {
			fail("exception thrown");
		}

		// normal case
		PrivateAccessor.setPrivateField(com, "table", "rep_foo_inc");
		PrivateAccessor.setPrivateField(com, "mode", RefreshMode.INCREMENTAL);
		ResultSet rset = null;
		try {
			Subscriber suber = SyncDatabaseDAO.getSubscriber(masterConn, 8);
			assertEquals(7, suber.getLastCount());
			assertEquals("F", suber.getLastType());
			assertEquals(1, suber.getLastMlogID());
			String suberTime = suber.getLastTime().toString();

			Subscription subs = SyncDatabaseDAO.getSubscription(replicaConn,
					"public", "rep_foo_inc");
			assertEquals("F", subs.getLastType());
			String subsTime = subs.getLastTime().toString();

			Statement stmt = replicaConn.createStatement();

			com.execute();

			rset = stmt
					.executeQuery("SELECT * FROM public.rep_foo_inc ORDER BY val1");

			assertTrue(rset.next());
			assertEquals(1, rset.getInt(1));
			assertEquals("A", rset.getString(2));
			assertEquals(Timestamp.valueOf("2010-01-01 00:00:01"), rset
					.getTimestamp(3));

			assertTrue(rset.next());
			assertEquals(2, rset.getInt(1));
			assertEquals("B", rset.getString(2));
			assertEquals(Timestamp.valueOf("2010-01-01 00:00:02"), rset
					.getTimestamp(3));

			assertTrue(rset.next());
			assertEquals(3, rset.getInt(1));
			assertEquals("C", rset.getString(2));
			assertEquals(Timestamp.valueOf("2010-01-01 00:00:03"), rset
					.getTimestamp(3));

			assertTrue(rset.next());
			assertEquals(4, rset.getInt(1));
			assertEquals("D", rset.getString(2));
			assertEquals(Timestamp.valueOf("2010-01-01 00:00:04"), rset
					.getTimestamp(3));

			assertTrue(rset.next());
			assertEquals(5, rset.getInt(1));
			assertEquals("E", rset.getString(2));
			assertEquals(Timestamp.valueOf("2010-01-01 00:00:05"), rset
					.getTimestamp(3));

			assertTrue(rset.next());
			assertEquals(6, rset.getInt(1));
			assertEquals("F", rset.getString(2));
			assertEquals(Timestamp.valueOf("2010-01-01 00:00:06"), rset
					.getTimestamp(3));

			assertTrue(rset.next());
			assertEquals(7, rset.getInt(1));
			assertEquals("G", rset.getString(2));
			assertEquals(Timestamp.valueOf("2010-01-01 00:00:07"), rset
					.getTimestamp(3));

			assertFalse(rset.next());

			suber = SyncDatabaseDAO.getSubscriber(masterConn, 8);
			assertEquals(7, suber.getLastCount());
			assertEquals("I", suber.getLastType());
			assertEquals(28, suber.getLastMlogID());
			assertFalse(suber.getLastTime().toString().equals(suberTime));

			subs = SyncDatabaseDAO.getSubscription(replicaConn, "public",
					"rep_foo_inc");
			assertEquals("I", subs.getLastType());
			assertFalse(subs.getLastTime().toString().equals(subsTime));

			rset.close();
			stmt.close();
		} catch (Exception e) {
			e.printStackTrace();
			fail("exception thrown");
		}

		try {
			utx.begin();
		} catch (Exception e1) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testFullRefresh() {
		String actual;
		Subscription subs = new Subscription("public", "rep_foo",
				"public.rep_foo", "attachuser", 1, "srvname",
				"SELECT * FROM public.foo", Timestamp
						.valueOf("2010-01-01 12:34:56"), "F");

		Subscriber suber = null;
		try {
			suber = SyncDatabaseDAO.getSubscriber(masterConn, 5);
		} catch (Exception e) {
			fail("exception thrown");
		}

		Method method = PrivateAccessor.getPrivateMethod(com, "fullRefresh");

		// null argument
		try {
			method.invoke(com, null, replicaConn, suber, subs, true);
			fail("no exception");
		} catch (InvocationTargetException e) {
			actual = e.getTargetException().getMessage();
			assertEquals("argument error", actual);
		} catch (Exception e) {
			fail("exception thrown");
		}
		try {
			method.invoke(com, masterConn, null, suber, subs, true);
			fail("no exception");
		} catch (InvocationTargetException e) {
			actual = e.getTargetException().getMessage();
			assertEquals("argument error", actual);
		} catch (Exception e) {
			fail("exception thrown");
		}
		try {
			method.invoke(com, masterConn, replicaConn, suber, null, true);
			fail("no exception");
		} catch (InvocationTargetException e) {
			actual = e.getTargetException().getMessage();
			assertEquals("argument error", actual);
		} catch (Exception e) {
			fail("exception thrown");
		}
		Statement stmt = null;
		ResultSet rset = null;
		try {
			stmt = replicaConn.createStatement();
			rset = stmt.executeQuery("SELECT relfilenode FROM "
					+ "pg_catalog.pg_class WHERE relname = 'rep_foo'");
			assertTrue(rset.next());
			String beforeFilenode = rset.getString(1);

			String result = RefreshCommand.fullRefresh(masterConn, replicaConn,
					suber, subs, false);
			assertEquals("full refresh (insert:7)", result);

			rset.close();
			rset = stmt.executeQuery("SELECT relfilenode FROM "
					+ "pg_catalog.pg_class WHERE relname = 'rep_foo'");
			assertTrue(rset.next());
			String afterFilenode = rset.getString(1);
			assertFalse(beforeFilenode.equalsIgnoreCase(afterFilenode));

			rset.close();
			rset = stmt.executeQuery("SELECT * FROM public.rep_foo");

			assertTrue(rset.next());
			assertEquals(1, rset.getInt(1));
			assertEquals("A", rset.getString(2));
			assertEquals(Timestamp.valueOf("2010-01-01 00:00:01"), rset
					.getTimestamp(3));

			assertTrue(rset.next());
			assertEquals(2, rset.getInt(1));
			assertEquals("B", rset.getString(2));
			assertEquals(Timestamp.valueOf("2010-01-01 00:00:02"), rset
					.getTimestamp(3));

			assertTrue(rset.next());
			assertEquals(3, rset.getInt(1));
			assertEquals("C", rset.getString(2));
			assertEquals(Timestamp.valueOf("2010-01-01 00:00:03"), rset
					.getTimestamp(3));

			assertTrue(rset.next());
			assertEquals(4, rset.getInt(1));
			assertEquals("D", rset.getString(2));
			assertEquals(Timestamp.valueOf("2010-01-01 00:00:04"), rset
					.getTimestamp(3));

			assertTrue(rset.next());
			assertEquals(5, rset.getInt(1));
			assertEquals("E", rset.getString(2));
			assertEquals(Timestamp.valueOf("2010-01-01 00:00:05"), rset
					.getTimestamp(3));

			assertTrue(rset.next());
			assertEquals(6, rset.getInt(1));
			assertEquals("F", rset.getString(2));
			assertEquals(Timestamp.valueOf("2010-01-01 00:00:06"), rset
					.getTimestamp(3));

			assertTrue(rset.next());
			assertEquals(7, rset.getInt(1));
			assertEquals("G", rset.getString(2));
			assertEquals(Timestamp.valueOf("2010-01-01 00:00:07"), rset
					.getTimestamp(3));

			assertFalse(rset.next());

			// Subscriber
			assertEquals(5, suber.getSubsID());
			assertEquals("public.foo", suber.getMasterTableName());
			assertEquals("mlog.mlog$", suber.getMlogName().substring(0, 10));
			assertEquals(
					"resource name:\"postgres2\", DBMS:\"PostgreSQL\", URL:\"jdbc:postgresql://\"",
					suber.getDescription());
			assertEquals(Timestamp.valueOf("2010-01-01 12:34:56"), suber
					.getLastTime());
			assertEquals("F", suber.getLastType());
			assertEquals(0, suber.getLastMlogID());
			assertEquals(7, suber.getLastCount());

			// Subscription
			assertEquals("public", subs.getSchema());
			assertEquals("rep_foo", subs.getTable());
			assertEquals(1, subs.getSubsID());
			assertEquals("srvname", subs.getSrvname());
			assertEquals("SELECT * FROM public.foo", subs.getQuery());
			assertEquals(Timestamp.valueOf("2010-01-01 12:34:56"), subs
					.getLastTime());
			assertEquals("F", subs.getLastType());
			assertEquals("public.rep_foo", subs.getReplicaTable());
		} catch (Exception e) {
			fail("exception thrown");
		} finally {
			try {
				if (stmt != null)
					stmt.close();
				if (rset != null)
					rset.close();
			} catch (SQLException e) {
				fail("exception thrown");
			}
		}
	}

	@Test
	public final void testIncrementalRefresh() {
		Subscription subs = null;
		Subscriber suber = null;
		try {
			subs = SyncDatabaseDAO.getSubscription(replicaConn, "public",
					"rep_foo_inc");
			suber = SyncDatabaseDAO.getSubscriber(masterConn, 8);
		} catch (Exception e1) {
			fail("exception thrown");
		}

		// argument error
		try {
			RefreshCommand.incrementalRefresh(null, replicaConn, suber, subs);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (Exception e) {
			fail("other exception thrown");
		}
		try {
			RefreshCommand.incrementalRefresh(masterConn, null, suber, subs);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (Exception e) {
			fail("other exception thrown");
		}
		try {
			RefreshCommand.incrementalRefresh(masterConn, replicaConn, null,
					subs);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (Exception e) {
			fail("other exception thrown");
		}
		try {
			RefreshCommand.incrementalRefresh(masterConn, replicaConn, suber,
					null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (Exception e) {
			fail("other exception thrown");
		}

		// normal case
		try {
			subs.setLastType("a");
			suber.setLastType("a");
			suber.setLastCount(100);
			suber.setLastMlogID(100);

			String result = RefreshCommand.incrementalRefresh(masterConn,
					replicaConn, suber, subs);

			assertEquals("incremental refresh (insert:0 update:0 delete:0)",
					result);
			assertEquals("I", subs.getLastType());
			assertEquals("I", suber.getLastType());
			assertEquals(100, suber.getLastCount());

			subs.setLastType("a");
			suber.setLastType("a");
			suber.setLastCount(100);
			suber.setLastMlogID(0);

			result = RefreshCommand.incrementalRefresh(masterConn, replicaConn,
					suber, subs);

			assertEquals("incremental refresh (insert:6 update:1 delete:6)",
					result);
			assertEquals("I", subs.getLastType());
			assertEquals("I", suber.getLastType());
			assertEquals(100, suber.getLastCount());
		} catch (Exception e) {
			e.printStackTrace();
			fail("other exception thrown");
		}
	}

	@Test
	public final void testGetExecuteMode() {
		RefreshMode mode;
		Subscription subs = new Subscription("public", "rep_tab1",
				"replicaTable", "attachuser", 1, "srvname",
				"SELECT * FROM public.foo", Timestamp
						.valueOf("2010-01-01 12:34:56"), "F");
		Subscriber suber = null;
		try {
			suber = SyncDatabaseDAO.getSubscriber(masterConn, 6);
			suber.setLastType("F");
		} catch (Exception e2) {
			fail("exception thrown");
		}

		// static value
		assertEquals(-1, Subscriber.NO_REFRESH);

		String actual;
		Method method = PrivateAccessor.getPrivateMethod(com, "getExecuteMode");

		// null argument
		try {
			method.invoke(com, masterConn, suber, null, RefreshMode.FULL);
			fail("no exception");
		} catch (InvocationTargetException e) {
			actual = e.getTargetException().getMessage();
			assertEquals("argument error", actual);
		} catch (Exception e) {
			fail("exception thrown");
		}
		try {
			method.invoke(com, null, suber, subs, RefreshMode.FULL);
			fail("no exception");
		} catch (InvocationTargetException e) {
			actual = e.getTargetException().getMessage();
			assertEquals("argument error", actual);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// FULL refresh
		try {
			mode = (RefreshMode) method.invoke(com, masterConn, suber, subs,
					RefreshMode.FULL);
			assertEquals(RefreshMode.FULL, mode);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// not have subscriber
		try {
			// FULL refresh
			subs.setSubsID(Subscription.NOT_HAVE_SUBSCRIBER);
			mode = (RefreshMode) method.invoke(com, masterConn, suber, subs,
					RefreshMode.AUTO);
			assertEquals(RefreshMode.FULL, mode);
		} catch (Exception e) {
			fail("exception thrown");
		}
		try {
			// FULL refresh only
			mode = (RefreshMode) method.invoke(com, masterConn, suber, subs,
					RefreshMode.INCREMENTAL);
			fail("no exception");
		} catch (InvocationTargetException e) {
			actual = e.getTargetException().getMessage();
			assertEquals("full refresh only", actual);
		} catch (Exception e) {
			fail("exception thrown");
		}
		subs.setSubsID(123);

		// no subscriber
		try {
			mode = (RefreshMode) method.invoke(com, masterConn, null, subs,
					RefreshMode.AUTO);
			assertEquals(RefreshMode.FULL, mode);
			fail("no exception");
		} catch (InvocationTargetException e) {
			actual = e.getTargetException().getMessage();
			assertEquals("not found subscriber id 123", actual);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// not yet first refresh
		try {
			// FULL refresh
			suber.setLastMlogID(Subscriber.NO_REFRESH);
			mode = (RefreshMode) method.invoke(com, masterConn, suber, subs,
					RefreshMode.AUTO);
			assertEquals(RefreshMode.FULL, mode);
		} catch (Exception e) {
			fail("exception thrown");
		}
		try {
			// FULL refresh only
			mode = (RefreshMode) method.invoke(com, masterConn, suber, subs,
					RefreshMode.INCREMENTAL);
			fail("no exception");
		} catch (InvocationTargetException e) {
			actual = e.getTargetException().getMessage();
			assertEquals("full refresh only", actual);
		} catch (Exception e) {
			fail("exception thrown");
		}
		suber.setLastMlogID(456);

		// INCREMENTAL refresh
		try {
			mode = (RefreshMode) method.invoke(com, masterConn, suber, subs,
					RefreshMode.INCREMENTAL);
			assertEquals(RefreshMode.INCREMENTAL, mode);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// choose Fastest Mode -> FULL refresh
		try {
			suber.setLastCount(0);
			suber.setLastMlogID(1);
			mode = (RefreshMode) method.invoke(com, masterConn, suber, subs,
					RefreshMode.AUTO);
			assertEquals(RefreshMode.FULL, mode);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// choose Fastest Mode -> INCREMENTAL refresh
		try {
			suber.setLastCount(1000000);
			mode = (RefreshMode) method.invoke(com, masterConn, suber, subs,
					RefreshMode.AUTO);
			assertEquals(RefreshMode.INCREMENTAL, mode);
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetRefreshMode() {
		RefreshMode mode = RefreshMode.INCREMENTAL;

		// normal case
		try {
			// FULL refresh
			mode = RefreshCommand.getRefreshMode("full");
			assertEquals(RefreshMode.FULL, mode);

			// INCREMENTAL refresh
			mode = RefreshCommand.getRefreshMode("incr");
			assertEquals(RefreshMode.INCREMENTAL, mode);

			// INCREMENTAL refresh
			mode = RefreshCommand.getRefreshMode("incremental");
			assertEquals(RefreshMode.INCREMENTAL, mode);
			// AUTO refresh
			mode = RefreshCommand.getRefreshMode("auto");
			assertEquals(RefreshMode.AUTO, mode);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// mode string error
		try {
			mode = RefreshCommand.getRefreshMode("incrementa");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("command error", e.getMessage());
		}

		// null argument
		try {
			mode = RefreshCommand.getRefreshMode(null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
	}

	@SuppressWarnings("unchecked")
	@Test
	public final void testGetOptions() {
		String expected;
		String actual;
		Option option;
		Options options = RefreshCommand.getOptions();
		assertNotNull(options);

		// option number
		int size = options.getOptions().size();
		assertEquals(6, size);

		// required options
		List list = options.getRequiredOptions();
		assertEquals(0, list.size());

		// concurrent option
		expected = "[ option: null concurrent  :: without taking exclusive lock on the replica table ]";
		option = options.getOption("concurrent");
		assertNotNull(option);
		actual = option.toString();
		assertEquals(expected, actual);

		// help option
		expected = "[ option: null help  :: show help ]";
		option = options.getOption("help");
		assertNotNull(option);
		actual = option.toString();
		assertEquals(expected, actual);

		// mode option
		expected = "[ option: null mode  [ARG] :: refresh mode, default is auto ]";
		option = options.getOption("mode");
		assertNotNull(option);
		actual = option.toString();
		assertEquals(expected, actual);

		// schema option
		expected = "[ option: null schema  [ARG] :: replica schema name ]";
		option = options.getOption("schema");
		assertNotNull(option);
		actual = option.toString();
		assertEquals(expected, actual);

		// server option
		expected = "[ option: null server  [ARG] :: replica server name ]";
		option = options.getOption("server");
		assertNotNull(option);
		actual = option.toString();
		assertEquals(expected, actual);

		// table option
		expected = "[ option: null table  [ARG] :: replica table name ]";
		option = options.getOption("table");
		assertNotNull(option);
		actual = option.toString();
		assertEquals(expected, actual);
	}

	@Test
	public final void testShowHelp() {
		RefreshCommand.showHelp();

		System.out.flush();
		String actual = _baos.toString();
		assertEquals(help, actual);
	}
}
