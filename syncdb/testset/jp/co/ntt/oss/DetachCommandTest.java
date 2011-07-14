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
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.List;

import jp.co.ntt.oss.data.DatabaseResource;
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

public class DetachCommandTest {
	private static String help;

	// need connection test
	private static DatabaseResource replicaDB = null;
	private static DatabaseResource masterDB = null;
	private static Connection replicaConn = null;
	private static Connection masterConn = null;
	private static DatabaseResource oraDB = null;
	private static Connection oraConn = null;

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

		// stdout test
		newLine = System.getProperty("line.separator");

		help = "usage: SyncDatabase detach" + newLine
				+ "    --force                  force detach" + newLine
				+ "    --help                   show help" + newLine
				+ "    --schema <schema name>   replica schema name" + newLine
				+ "    --server <server name>   replica server name" + newLine
				+ "    --table <table name>     replica table name" + newLine;
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
	}

	@After
	public void tearDown() throws Exception {
		System.setOut(_out);
	}

	@Test
	public final void testDetachCommand() {
		String actual;
		DetachCommand command;
		Options options = new Options();
		options.addOption(null, "force", false, "");
		options.addOption(null, "help", false, "");
		options.addOption(null, "schema", true, "");
		options.addOption(null, "table", true, "");
		options.addOption(null, "server", true, "");
		CommandLineParser parser = new BasicParser();

		// necessary argument error
		String[] args1 = { "--schema", "schemaName", "--table", "tableName",
				"--force", "false" };
		try {
			CommandLine commandLine = parser.parse(options, args1);
			new DetachCommand(commandLine);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("command error", actual);
		} catch (ParseException e) {
			fail("exception thrown");
		}
		String[] args2 = { "--server", "serverName", "--table", "tableName",
				"--force", "false" };
		try {
			CommandLine commandLine = parser.parse(options, args2);
			new DetachCommand(commandLine);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("command error", actual);
		} catch (ParseException e) {
			fail("exception thrown");
		}
		String[] args3 = { "--server", "serverName", "--schema", "schemaName",
				"--force", "false" };
		try {
			CommandLine commandLine = parser.parse(options, args3);
			new DetachCommand(commandLine);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("command error", actual);
		} catch (ParseException e) {
			fail("exception thrown");
		}

		// normal case : default value
		String[] args4 = { "--server", "serverName4", "--schema",
				"schemaName4", "--table", "tableName4" };

		try {
			CommandLine commandLine = parser.parse(options, args4);
			command = new DetachCommand(commandLine);
			assertNotNull(command);

			String server = (String) PrivateAccessor.getPrivateField(command,
					"server");
			assertNotNull(server);
			assertEquals("serverName4", server);

			String schema = (String) PrivateAccessor.getPrivateField(command,
					"schema");
			assertNotNull(schema);
			assertEquals("schemaName4", schema);

			String table = (String) PrivateAccessor.getPrivateField(command,
					"table");
			assertNotNull(table);
			assertEquals("tableName4", table);

			Boolean force = (Boolean) PrivateAccessor.getPrivateField(command,
					"force");
			assertNotNull(force);
			assertFalse(force.booleanValue());

			Boolean showHelp = (Boolean) PrivateAccessor.getPrivateField(
					command, "showHelp");
			assertNotNull(showHelp);
			assertFalse(showHelp.booleanValue());
		} catch (Exception e) {
			fail("exception thrown");
		}

		// normal case : not default
		String[] args5 = { "--server", "serverName5", "--schema",
				"schemaName5", "--table", "tableName5", "--force", "false" };

		try {
			CommandLine commandLine = parser.parse(options, args5);
			command = new DetachCommand(commandLine);
			assertNotNull(command);

			String server = (String) PrivateAccessor.getPrivateField(command,
					"server");
			assertNotNull(server);
			assertEquals("serverName5", server);

			String schema = (String) PrivateAccessor.getPrivateField(command,
					"schema");
			assertNotNull(schema);
			assertEquals("schemaName5", schema);

			String table = (String) PrivateAccessor.getPrivateField(command,
					"table");
			assertNotNull(table);
			assertEquals("tableName5", table);

			Boolean force = (Boolean) PrivateAccessor.getPrivateField(command,
					"force");
			assertNotNull(force);
			assertTrue(force.booleanValue());

			Boolean showHelp = (Boolean) PrivateAccessor.getPrivateField(
					command, "showHelp");
			assertNotNull(showHelp);
			assertFalse(showHelp.booleanValue());
		} catch (Exception e) {
			fail("exception thrown");
		}

		// normal case : help
		String[] args6 = { "--help" };
		try {
			CommandLine commandLine = parser.parse(options, args6);
			command = new DetachCommand(commandLine);
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

			Boolean force = (Boolean) PrivateAccessor.getPrivateField(command,
					"force");
			assertNotNull(force);
			assertFalse(force.booleanValue());

			Boolean showHelp = (Boolean) PrivateAccessor.getPrivateField(
					command, "showHelp");
			assertNotNull(showHelp);
			assertTrue(showHelp.booleanValue());
		} catch (Exception e) {
			fail("exception thrown");
		}

		System.out.flush();
		actual = _baos.toString();
		assertEquals(help + help + help, actual);
	}

	@Test
	public final void testExecute() {
		String actual;
		DetachCommand com = null;
		Options options = new Options();
		options.addOption(null, "force", false, "");
		options.addOption(null, "help", false, "");
		options.addOption(null, "schema", true, "");
		options.addOption(null, "table", true, "");
		options.addOption(null, "server", true, "");
		CommandLineParser parser = new BasicParser();

		String[] args = { "--server", "serverName", "--schema", "schemaName",
				"--table", "tableName" };
		try {
			CommandLine commandLine = parser.parse(options, args);
			com = new DetachCommand(commandLine);
			assertNotNull(com);
		} catch (Exception e) {
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

		// replica table name error
		PrivateAccessor.setPrivateField(com, "showHelp", new Boolean(false));
		PrivateAccessor.setPrivateField(com, "server", "postgres2");
		try {
			com.execute();
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("schemaName.tableName has no subscription", actual);
		} catch (Exception e) {
			fail("exception thrown");
		}

		PrivateAccessor.setPrivateField(com, "schema", "public");
		PrivateAccessor.setPrivateField(com, "table", "rep_aaa");
		// master resource name error
		try {
			com.execute();
			fail("no exception");
		} catch (Exception e) {
			actual = e.getMessage();
			assertEquals("resource aaa not found", actual);
		}

		// subscriber not found
		PrivateAccessor.setPrivateField(com, "table", "rep_detach1");
		try {
			com.execute();
			fail("no exception");
		} catch (Exception e) {
			actual = e.getMessage();
			assertEquals("not found subscriber id 11", actual);
		}

		// master resource name error
		PrivateAccessor.setPrivateField(com, "force", new Boolean(true));
		PrivateAccessor.setPrivateField(com, "table", "rep_aaa");
		try {
			SyncDatabaseDAO.getSubscription(replicaConn, "public", "rep_aaa");
			com.execute();
		} catch (Exception e) {
			fail("exception thrown");
		}

		try {
			SyncDatabaseDAO.getSubscription(replicaConn, "public", "rep_aaa");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("public.rep_aaa has no subscription", actual);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// subscriber not found, force detach
		PrivateAccessor.setPrivateField(com, "table", "rep_detach1");
		try {
			SyncDatabaseDAO.getSubscription(replicaConn, "public",
					"rep_detach1");
			com.execute();
		} catch (Exception e) {
			fail("exception thrown");
		}

		try {
			SyncDatabaseDAO.getSubscription(replicaConn, "public",
					"rep_detach1");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("public.rep_detach1 has no subscription", actual);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// no mlog mode (full refresh only)
		PrivateAccessor
				.setPrivateField(com, "showHelp", Boolean.valueOf(false));
		PrivateAccessor.setPrivateField(com, "table", "rep_detach22");
		try {
			SyncDatabaseDAO.getSubscription(replicaConn, "public",
					"rep_detach22");
		} catch (Exception e) {
			fail("exception thrown");
		}

		try {
			com.execute();
			SyncDatabaseDAO.getSubscription(replicaConn, "public",
					"rep_detach22");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("public.rep_detach22 has no subscription", actual);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// use mlog mode (mlog subscribe)
		Subscription subs = null;
		PrivateAccessor.setPrivateField(com, "table", "rep_detach2");
		try {
			subs = SyncDatabaseDAO.getSubscription(replicaConn, "public",
					"rep_detach2");
			SyncDatabaseDAO.getSubscriber(masterConn, subs.getSubsID());
		} catch (Exception e) {
			fail("exception thrown");
		}

		try {
			com.execute();
			SyncDatabaseDAO.getSubscription(replicaConn, "public",
					"rep_detach2");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("public.rep_detach2 has no subscription", actual);
		} catch (Exception e) {
			fail("exception thrown");
		}

		try {
			SyncDatabaseDAO.getSubscriber(masterConn, subs.getSubsID());
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("not found subscriber id " + subs.getSubsID(), actual);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// droped master
		/*
		 * マスタテーブルの削除を含むため、試験から除外する
		 * PrivateAccessor.setPrivateField(com, "table", "rep_fff"); try { subs
		 * = SyncDatabaseDAO.getSubscription(replicaConn, "public", "rep_fff");
		 * SyncDatabaseDAO.getSubscriber(masterConn, subs.getSubsID()); } catch
		 * (Exception e) { fail("exception thrown"); }
		 *
		 * try { com.execute(); SyncDatabaseDAO.getSubscription(replicaConn,
		 * "public", "rep_fff"); fail("no exception"); } catch
		 * (SyncDatabaseException e) { actual = e.getMessage();
		 * assertEquals("public.rep_fff has no subscription", actual); } catch
		 * (Exception e) { fail("exception thrown"); }
		 *
		 * try { SyncDatabaseDAO.getSubscriber(masterConn, subs.getSubsID());
		 * fail("no exception"); } catch (SyncDatabaseException e) { actual =
		 * e.getMessage(); assertEquals("not found subscriber id " +
		 * subs.getSubsID(), actual); } catch (Exception e) {
		 * fail("exception thrown"); }
		 */

		// recovery test data
		Statement stmt = null;
		try {
			stmt = replicaConn.createStatement();
			stmt.executeUpdate("INSERT INTO observer.subscription ("
					+ "SELECT 'public.rep_aaa', oid, 1, 'aaa', "
					+ "'SELECT * FROM public.tab1', "
					+ "NULL::timestamptz, NULL FROM "
					+ "(SELECT oid FROM pg_authid "
					+ "WHERE rolname = 'syncdbuser') AS a)");
			stmt.executeUpdate("INSERT INTO observer.subscription ("
					+ "SELECT 'public.rep_detach1', oid, 11, 'postgres1', "
					+ "'SELECT * FROM public.detach1', "
					+ "'2010-01-01 12:34:56'::timestamptz, 'I' FROM "
					+ "(SELECT oid FROM pg_authid "
					+ "WHERE rolname = 'syncdbuser') AS a)");
			stmt.executeUpdate("INSERT INTO observer.subscription ("
					+ "SELECT 'public.rep_detach2', oid, 12, 'postgres1', "
					+ "'SELECT * FROM public.detach2', "
					+ "'2010-01-01 12:34:56'::timestamptz, 'I' FROM "
					+ "(SELECT oid FROM pg_authid "
					+ "WHERE rolname = 'syncdbuser') AS a)");
			stmt.executeUpdate("INSERT INTO observer.subscription ("
					+ "SELECT 'public.rep_detach22', oid, NULL, 'postgres1', "
					+ "'SELECT * FROM public.detach2', "
					+ "'2010-01-01 12:34:56'::timestamptz, 'I' FROM "
					+ "(SELECT oid FROM pg_authid "
					+ "WHERE rolname = 'syncdbuser') AS a)");
			stmt.close();

			stmt = masterConn.createStatement();
			stmt.executeUpdate("INSERT INTO mlog.subscriber ("
					+ "SELECT 12, 'public.detach2', oid, 'desc detach2', "
					+ "'2010-01-01 12:34:56'::timestamptz, 'F', 2, 20 FROM "
					+ "(SELECT oid FROM pg_authid "
					+ "WHERE rolname = 'syncdbuser') AS a)");
			stmt.close();
		} catch (SQLException e) {
			e.printStackTrace();
			fail("exception thrown");
		}
	}

	@SuppressWarnings("unchecked")
	@Test
	public final void testGetOptions() {
		String expected;
		String actual;
		Option option;
		Options options = DetachCommand.getOptions();
		assertNotNull(options);

		// option number
		int size = options.getOptions().size();
		assertEquals(5, size);

		// required options
		List list = options.getRequiredOptions();
		assertEquals(0, list.size());

		// force option
		expected = "[ option: null force  :: force detach ]";
		option = options.getOption("force");
		assertNotNull(option);
		actual = option.toString();
		assertEquals(expected, actual);

		// help option
		expected = "[ option: null help  :: show help ]";
		option = options.getOption("help");
		assertNotNull(option);
		actual = option.toString();
		assertEquals(expected, actual);

		// server option
		expected = "[ option: null server  [ARG] :: replica server name ]";
		option = options.getOption("server");
		assertNotNull(option);
		actual = option.toString();
		assertEquals(expected, actual);

		// schema option
		expected = "[ option: null schema  [ARG] :: replica schema name ]";
		option = options.getOption("schema");
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
		DetachCommand.showHelp();

		System.out.flush();
		String actual = _baos.toString();
		assertEquals(help, actual);
	}
}
