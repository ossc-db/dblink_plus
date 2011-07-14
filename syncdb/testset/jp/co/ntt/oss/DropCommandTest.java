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
import java.util.ArrayList;
import java.util.List;

import jp.co.ntt.oss.data.DatabaseResource;
import jp.co.ntt.oss.data.MasterStatus;
import jp.co.ntt.oss.data.Subscriber;
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

public class DropCommandTest {
	private static String help;

	// need connection test
	private static DatabaseResource masterDB = null;
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
		masterConn = masterDB.getConnection();
		oraDB = new DatabaseResource("oracle");
		oraConn = oraDB.getConnection();

		// stdout test
		newLine = System.getProperty("line.separator");

		help = "usage: SyncDatabase drop" + newLine
				+ "    --help                          show help" + newLine
				+ "    --master <master server name>   master server name"
				+ newLine
				+ "    --schema <schema name>          master schema name"
				+ newLine
				+ "    --table <table name>            master table name"
				+ newLine;
	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {
		masterConn.close();
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
	public final void testDropCommand() {
		String actual;
		DropCommand command;
		Options options = new Options();
		options.addOption(null, "help", false, "");
		options.addOption(null, "schema", true, "");
		options.addOption(null, "table", true, "");
		options.addOption(null, "master", true, "");
		CommandLineParser parser = new BasicParser();

		// necessary argument error
		String[] args1 = { "--schema", "schemaName", "--table", "tableName" };
		try {
			CommandLine commandLine = parser.parse(options, args1);
			new DropCommand(commandLine);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("command error", actual);
		} catch (ParseException e) {
			fail("exception thrown");
		}
		String[] args2 = { "--master", "masterName", "--table", "tableName" };
		try {
			CommandLine commandLine = parser.parse(options, args2);
			new DropCommand(commandLine);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("command error", actual);
		} catch (ParseException e) {
			fail("exception thrown");
		}
		String[] args3 = { "--master", "masterName", "--schema", "schemaName" };
		try {
			CommandLine commandLine = parser.parse(options, args3);
			new DropCommand(commandLine);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("command error", actual);
		} catch (ParseException e) {
			fail("exception thrown");
		}

		// normal case : default value
		String[] args4 = { "--master", "masterName4", "--schema",
				"schemaName4", "--table", "tableName4" };

		try {
			CommandLine commandLine = parser.parse(options, args4);
			command = new DropCommand(commandLine);
			assertNotNull(command);

			String master = (String) PrivateAccessor.getPrivateField(command,
					"master");
			assertNotNull(master);
			assertEquals("masterName4", master);

			String schema = (String) PrivateAccessor.getPrivateField(command,
					"schema");
			assertNotNull(schema);
			assertEquals("schemaName4", schema);

			String table = (String) PrivateAccessor.getPrivateField(command,
					"table");
			assertNotNull(table);
			assertEquals("tableName4", table);

			Boolean showHelp = (Boolean) PrivateAccessor.getPrivateField(
					command, "showHelp");
			assertNotNull(showHelp);
			assertFalse(showHelp.booleanValue());
		} catch (Exception e) {
			fail("exception thrown");
		}

		// normal case : help
		String[] args5 = { "--help" };
		try {
			CommandLine commandLine = parser.parse(options, args5);
			command = new DropCommand(commandLine);
			assertNotNull(command);

			String master = (String) PrivateAccessor.getPrivateField(command,
					"master");
			assertNull(master);

			String schema = (String) PrivateAccessor.getPrivateField(command,
					"schema");
			assertNull(schema);

			String table = (String) PrivateAccessor.getPrivateField(command,
					"table");
			assertNull(table);

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
		DropCommand com = null;
		Options options = new Options();
		options.addOption(null, "help", false, "");
		options.addOption(null, "schema", true, "");
		options.addOption(null, "table", true, "");
		options.addOption(null, "master", true, "");
		CommandLineParser parser = new BasicParser();

		// necessary argument error
		String[] args = { "--master", "masterName", "--schema", "schemaName",
				"--table", "tableName" };
		try {
			CommandLine commandLine = parser.parse(options, args);
			com = new DropCommand(commandLine);
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

		// master resource name error
		PrivateAccessor
				.setPrivateField(com, "showHelp", Boolean.valueOf(false));
		try {
			com.execute();
			fail("no exception");
		} catch (Exception e) {
			actual = e.getMessage();
			assertEquals("resource masterName not found", actual);
		}

		// master schema name error
		PrivateAccessor.setPrivateField(com, "master", "postgres1");
		try {
			com.execute();
			fail("no exception");
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		} catch (Exception e) {
			assertEquals(
					"ERROR: schema \"schemaName\" does not exist\n"
							+ "  Where: PL/pgSQL function \"drop_mlog\" line 9 at assignment",
					e.getMessage());
		}

		// normal case
		PrivateAccessor.setPrivateField(com, "schema", "public");
		PrivateAccessor.setPrivateField(com, "table", "drop1");
		Subscriber suber = null;
		try {
			suber = SyncDatabaseDAO.getSubscriber(masterConn, 14);

			com.execute();

			ArrayList<MasterStatus> status = SyncDatabaseDAO.getMasterStatus(
					masterConn, "public", "drop1");
			assertEquals(0, status.size());
		} catch (Exception e) {
			e.printStackTrace();
			fail("exception thrown");
		}

		// recovery test data
		Statement stmt = null;
		try {
			stmt = masterConn.createStatement();
			stmt.executeUpdate("INSERT INTO mlog.master ("
					+ "SELECT 'public.drop1', oid "
					+ "FROM (SELECT oid FROM pg_authid "
					+ "WHERE rolname = 'syncdbuser') AS a)");
			stmt.executeUpdate("INSERT INTO mlog.subscriber ("
					+ "SELECT 14, 'public.drop1', oid, 'desc drop1', "
					+ "'2010-01-01 12:34:56'::timestamptz, 'F', 1, 10 FROM "
					+ "(SELECT oid FROM pg_authid "
					+ "WHERE rolname = 'syncdbuser') AS a)");
			stmt.executeUpdate("CREATE TABLE " + suber.getMlogName()
					+ " (mlogid bigint PRIMARY KEY, "
					+ "dmltype \"char\", val1 integer)");
			stmt.executeUpdate("CREATE FUNCTION  " + suber.getMlogName()
					+ "_trg_fnc() RETURNS void AS '' LANGUAGE sql");
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
		Options options = DropCommand.getOptions();
		assertNotNull(options);

		// option number
		int size = options.getOptions().size();
		assertEquals(4, size);

		// required options
		List list = options.getRequiredOptions();
		assertEquals(0, list.size());

		// help option
		expected = "[ option: null help  :: show help ]";
		option = options.getOption("help");
		assertNotNull(option);
		actual = option.toString();
		assertEquals(expected, actual);

		// master option
		expected = "[ option: null master  [ARG] :: master server name ]";
		option = options.getOption("master");
		assertNotNull(option);
		actual = option.toString();
		assertEquals(expected, actual);

		// schema option
		expected = "[ option: null schema  [ARG] :: master schema name ]";
		option = options.getOption("schema");
		assertNotNull(option);
		actual = option.toString();
		assertEquals(expected, actual);

		// table option
		expected = "[ option: null table  [ARG] :: master table name ]";
		option = options.getOption("table");
		assertNotNull(option);
		actual = option.toString();
		assertEquals(expected, actual);
	}

	@Test
	public final void testShowHelp() {
		DropCommand.showHelp();

		System.out.flush();
		String actual = _baos.toString();
		assertEquals(help, actual);
	}

}
