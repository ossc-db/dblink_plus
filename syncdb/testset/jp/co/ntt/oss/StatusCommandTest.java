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
import java.sql.Timestamp;
import java.util.List;

import jp.co.ntt.oss.data.DatabaseResource;
import jp.co.ntt.oss.data.Subscription;
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

public class StatusCommandTest {

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

		help = "usage: SyncDatabase status" + newLine
				+ "    --cost                           show cost" + newLine
				+ "    --help                           show help" + newLine
				+ "    --master <master server name>    master server name"
				+ newLine
				+ "    --schema <schema name>           replica schema name"
				+ newLine
				+ "    --server <replica server name>   replica server name"
				+ newLine
				+ "    --table <table name>             replica table name"
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
	}

	@After
	public void tearDown() throws Exception {
		System.setOut(_out);
	}

	@Test
	public final void testStatusCommand() {
		String actual;
		StatusCommand command;
		Options options = new Options();
		options.addOption(null, "cost", false, "");
		options.addOption(null, "help", false, "");
		options.addOption(null, "schema", true, "");
		options.addOption(null, "table", true, "");
		options.addOption(null, "master", true, "");
		options.addOption(null, "server", true, "");
		CommandLineParser parser = new BasicParser();

		// necessary argument error
		String[] args1 = { "--schema", "schemaName", "--table", "tableName",
				"--cost", };
		try {
			CommandLine commandLine = parser.parse(options, args1);
			new StatusCommand(commandLine);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("command error", actual);
			System.out.flush();
			actual = _baos.toString();
			assertEquals(help, actual);
		} catch (ParseException e) {
			fail("exception thrown");
		}

		// normal case : default value : master only
		String[] args2 = { "--master", "masterName" };
		try {
			CommandLine commandLine = parser.parse(options, args2);
			command = new StatusCommand(commandLine);
			assertNotNull(command);

			String master = (String) PrivateAccessor.getPrivateField(command,
					"master");
			assertNotNull(master);
			assertEquals("masterName", master);

			String server = (String) PrivateAccessor.getPrivateField(command,
					"server");
			assertNull(server);

			String schema = (String) PrivateAccessor.getPrivateField(command,
					"schema");
			assertNull(schema);

			String table = (String) PrivateAccessor.getPrivateField(command,
					"table");
			assertNull(table);

			Boolean cost = (Boolean) PrivateAccessor.getPrivateField(command,
					"cost");
			assertNotNull(cost);
			assertFalse(cost.booleanValue());

			Boolean showHelp = (Boolean) PrivateAccessor.getPrivateField(
					command, "showHelp");
			assertNotNull(showHelp);
			assertFalse(showHelp.booleanValue());
		} catch (Exception e) {
			fail("exception thrown");
		}

		// normal case : default value : server only
		String[] args3 = { "--server", "serverName" };
		try {
			CommandLine commandLine = parser.parse(options, args3);
			command = new StatusCommand(commandLine);
			assertNotNull(command);

			String master = (String) PrivateAccessor.getPrivateField(command,
					"master");
			assertNull(master);

			String server = (String) PrivateAccessor.getPrivateField(command,
					"server");
			assertNotNull(server);
			assertEquals("serverName", server);

			String schema = (String) PrivateAccessor.getPrivateField(command,
					"schema");
			assertNull(schema);

			String table = (String) PrivateAccessor.getPrivateField(command,
					"table");
			assertNull(table);

			Boolean cost = (Boolean) PrivateAccessor.getPrivateField(command,
					"cost");
			assertNotNull(cost);
			assertFalse(cost.booleanValue());

			Boolean showHelp = (Boolean) PrivateAccessor.getPrivateField(
					command, "showHelp");
			assertNotNull(showHelp);
			assertFalse(showHelp.booleanValue());
		} catch (Exception e) {
			fail("exception thrown");
		}

		// normal case : not default
		String[] args4 = { "--master", "masterName", "--server", "serverName",
				"--schema", "schemaName", "--table", "tableName", "--cost", };
		try {
			CommandLine commandLine = parser.parse(options, args4);
			command = new StatusCommand(commandLine);
			assertNotNull(command);

			String master = (String) PrivateAccessor.getPrivateField(command,
					"master");
			assertNotNull(master);
			assertEquals("masterName", master);

			String server = (String) PrivateAccessor.getPrivateField(command,
					"server");
			assertNotNull(server);
			assertEquals("serverName", server);

			String schema = (String) PrivateAccessor.getPrivateField(command,
					"schema");
			assertNotNull(schema);
			assertEquals("schemaName", schema);

			String table = (String) PrivateAccessor.getPrivateField(command,
					"table");
			assertNotNull(table);
			assertEquals("tableName", table);

			Boolean cost = (Boolean) PrivateAccessor.getPrivateField(command,
					"cost");
			assertNotNull(cost);
			assertTrue(cost.booleanValue());

			Boolean showHelp = (Boolean) PrivateAccessor.getPrivateField(
					command, "showHelp");
			assertNotNull(showHelp);
			assertFalse(showHelp.booleanValue());
		} catch (Exception e) {
			fail("exception thrown");
		}

		// normal case : help
		String[] args5 = { "--master", "masterName", "--server", "serverName",
				"--schema", "schemaName", "--table", "tableName", "--cost",
				"--help" };
		try {
			CommandLine commandLine = parser.parse(options, args5);
			command = new StatusCommand(commandLine);
			assertNotNull(command);

			String master = (String) PrivateAccessor.getPrivateField(command,
					"master");
			assertNull(master);

			String server = (String) PrivateAccessor.getPrivateField(command,
					"server");
			assertNull(server);

			String schema = (String) PrivateAccessor.getPrivateField(command,
					"schema");
			assertNull(schema);

			String table = (String) PrivateAccessor.getPrivateField(command,
					"table");
			assertNull(table);

			Boolean cost = (Boolean) PrivateAccessor.getPrivateField(command,
					"cost");
			assertNotNull(cost);
			assertFalse(cost.booleanValue());

			Boolean showHelp = (Boolean) PrivateAccessor.getPrivateField(
					command, "showHelp");
			assertNotNull(showHelp);
			assertTrue(showHelp.booleanValue());
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testExecute() {
		String actual;
		StatusCommand com = null;
		Options options = new Options();
		options.addOption(null, "cost", false, "");
		options.addOption(null, "help", false, "");
		options.addOption(null, "schema", true, "");
		options.addOption(null, "table", true, "");
		options.addOption(null, "master", true, "");
		options.addOption(null, "server", true, "");
		CommandLineParser parser = new BasicParser();

		String[] args = { "--master", "masterName", "--server", "serverName",
				"--schema", "schemaName", "--table", "tableName", "--cost", };
		try {
			CommandLine commandLine = parser.parse(options, args);
			com = new StatusCommand(commandLine);
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

		// replica resource name error
		PrivateAccessor.setPrivateField(com, "master", null);
		try {
			com.execute();
			fail("no exception");
		} catch (Exception e) {
			actual = e.getMessage();
			assertEquals("resource serverName not found", actual);
		}

		// replica status
		PrivateAccessor.setPrivateField(com, "server", "postgres2");
		try {
			com.execute();
		} catch (Exception e) {
			actual = e.getMessage();
			assertEquals("resource serverName not found", actual);
		}

		// replica status
		PrivateAccessor.setPrivateField(com, "server", null);
		PrivateAccessor.setPrivateField(com, "master", "postgres1");
		try {
			com.execute();
		} catch (Exception e) {
			actual = e.getMessage();
			assertEquals("resource serverName not found", actual);
		}
	}

	@Test
	public final void testMasterStatus() {
		String expected;
		String actual;

		// argument error
		try {
			StatusCommand.masterStatus(null, null, null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (Exception e) {
			fail("other exception thrown");
		}

		// resource error
		try {
			StatusCommand.masterStatus("aaa", null, null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("resource aaa not found", e.getMessage());
		} catch (Exception e) {
			fail("other exception thrown");
		}

		// not specified schema and table
		try {
			expected = "master status\n"
					+ " schema | table   | logs | subs | oldest refresh      | oldest replica                   \n"
					+ "--------+---------+------+------+---------------------+----------------------------------\n"
					+ " public | attach1 |    0 |    1 | 2010-01-01 12:34:56 | desc attach1                     \n"
					+ " public | bar     |    0 |    1 | 2010-01-01 12:34:56 | description5                     \n"
					+ " public | ccc     |    1 |    1 | 2010-01-01 12:34:56 | description3                     \n"
					+ " public | detach1 |   -1 |    0 |                     |                                  \n"
					+ " public | detach2 |    0 |    1 | 2010-01-01 12:34:56 | desc detach2                     \n"
					+ " public | detach3 |    0 |    1 | 2010-01-01 12:34:56 | desc detach3                     \n"
					+ " public | drop1   |    0 |    1 | 2010-01-01 12:34:56 | desc drop1                       \n"
					+ " public | foo     |   27 |    2 | 2010-01-01 12:34:56 | postgres2                        \n"
					+ " public | inc     |   20 |    2 | 2010-01-01 12:34:56 | incremental refresh test table 1 \n"
					+ " public | tab1    |  123 |    1 | 2010-01-01 12:34:56 | description1                     \n"
					+ " public | tab2    |    0 |    1 | 2010-01-02 12:34:56 | description2                     \n"
					+ " test   | foo     |    1 |    0 |                     |                                  \n"
					+ "        |         |   -1 |    1 |                     | desc master droped               \n";
			actual = StatusCommand.masterStatus("postgres1", null, null);
			assertEquals(expected, actual);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// schema specified
		try {
			expected = "master status\n"
					+ " schema | table | logs | subs | oldest refresh      | oldest replica \n"
					+ "--------+-------+------+------+---------------------+----------------\n"
					+ " test   | foo   |    1 |    0 |                     |                \n";
			actual = StatusCommand.masterStatus("postgres1", "test", null);
			assertEquals(expected, actual);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// table specified
		try {
			expected = "master status\n"
					+ " schema | table | logs | subs | oldest refresh      | oldest replica \n"
					+ "--------+-------+------+------+---------------------+----------------\n"
					+ " public | foo   |   27 |    2 | 2010-01-01 12:34:56 | postgres2      \n"
					+ " test   | foo   |    1 |    0 |                     |                \n";
			actual = StatusCommand.masterStatus("postgres1", null, "foo");
			assertEquals(expected, actual);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// schema and table specified
		try {
			expected = "master status\n"
					+ " schema | table | logs | subs | oldest refresh      | oldest replica \n"
					+ "--------+-------+------+------+---------------------+----------------\n"
					+ " public | foo   |   27 |    2 | 2010-01-01 12:34:56 | postgres2      \n";
			actual = StatusCommand.masterStatus("postgres1", "public", "foo");
			assertEquals(expected, actual);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// not found
		try {
			expected = "master status\n"
					+ " schema | table | logs | subs | oldest refresh      | oldest replica \n"
					+ "--------+-------+------+------+---------------------+----------------\n";
			actual = StatusCommand.masterStatus("postgres1", "public", "aaa");
			assertEquals(expected, actual);
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testReplicaStatus() {
		String expected;
		String actual;

		// argument error
		try {
			StatusCommand.replicaStatus(null, null, null, true);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (Exception e) {
			fail("other exception thrown");
		}

		// resource error
		try {
			StatusCommand.replicaStatus("aaa", null, null, false);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("resource aaa not found", e.getMessage());
		} catch (Exception e) {
			fail("other exception thrown");
		}

		// not specified schema and table
		try {
			expected = "replica status\n"
					+ " schema | table        | last refresh        | master    \n"
					+ "--------+--------------+---------------------+-----------\n"
					+ " public | rep_aaa      |                     | aaa       \n"
					+ " public | rep_bar      |                     | postgres1 \n"
					+ " public | rep_bbb      |                     | postgres1 \n"
					+ " public | rep_ccc      |                     | postgres1 \n"
					+ " public | rep_ddd      |                     | postgres1 \n"
					+ " public | rep_detach1  | 2010-01-01 12:34:56 | postgres1 \n"
					+ " public | rep_detach2  | 2010-01-01 12:34:56 | postgres1 \n"
					+ " public | rep_detach22 | 2010-01-01 12:34:56 | postgres1 \n"
					+ " public | rep_drop1    | 2010-01-01 12:34:56 | postgres1 \n"
					+ " public | rep_eee      |                     | postgres1 \n"
					+ " public | rep_fff      |                     | postgres1 \n"
					+ " public | rep_foo      |                     | postgres1 \n"
					+ " public | rep_foo_inc  | 2010-01-01 12:34:56 | postgres1 \n"
					+ " public | rep_inc1     |                     | postgres1 \n"
					+ " public | rep_inc2     |                     | postgres1 \n"
					+ " public | rep_tab1     |                     | postgres1 \n"
					+ " test   | rep_foo      | 2010-01-01 12:34:56 | postgres1 \n"
					+ "        |              |                     | postgres1 \n";
			actual = StatusCommand
					.replicaStatus("postgres2", null, null, false);
			assertEquals(expected, actual);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// schema specified
		try {
			expected = "replica status\n"
					+ " schema | table   | last refresh        | master    \n"
					+ "--------+---------+---------------------+-----------\n"
					+ " test   | rep_foo | 2010-01-01 12:34:56 | postgres1 \n";
			actual = StatusCommand.replicaStatus("postgres2", "test", null,
					false);
			assertEquals(expected, actual);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// table specified
		try {
			expected = "replica status\n"
					+ " schema | table   | last refresh        | master    \n"
					+ "--------+---------+---------------------+-----------\n"
					+ " public | rep_foo |                     | postgres1 \n"
					+ " test   | rep_foo | 2010-01-01 12:34:56 | postgres1 \n";
			actual = StatusCommand.replicaStatus("postgres2", null, "rep_foo",
					false);
			assertEquals(expected, actual);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// schema and table specified
		try {
			expected = "replica status\n"
					+ " schema | table   | last refresh        | master    \n"
					+ "--------+---------+---------------------+-----------\n"
					+ " public | rep_foo |                     | postgres1 \n";
			actual = StatusCommand.replicaStatus("postgres2", "public",
					"rep_foo", false);
			assertEquals(expected, actual);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// on cost option
		try {
			expected = "replica status\n"
					+ " schema | table   | last refresh        | master    | cost \n"
					+ "--------+---------+---------------------+-----------+------\n"
					+ " public | rep_foo |                     | postgres1 | 1.50 \n";
			actual = StatusCommand.replicaStatus("postgres2", "public",
					"rep_foo", true);
			assertEquals(expected, actual);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// not found
		try {
			expected = "replica status\n"
					+ " schema | table | last refresh        | master | cost \n"
					+ "--------+-------+---------------------+--------+------\n";
			actual = StatusCommand.replicaStatus("postgres2", "public", "aaa",
					true);
			assertEquals(expected, actual);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// master not found
		try {
			expected = "replica status\n"
					+ " schema | table   | last refresh        | master    | cost \n"
					+ "--------+---------+---------------------+-----------+------\n"
					+ " public | rep_fff |                     | postgres1 |  Inf \n";
			actual = StatusCommand.replicaStatus("postgres2", "public",
					"rep_fff", true);
			assertEquals(expected, actual);
		} catch (Exception e) {
			fail("exception thrown");
		}

	}

	@Test
	public final void testGetCost() {
		double cost;

		// argument error
		try {
			cost = StatusCommand.getCost(null, 1);
			assertTrue(Double.isNaN(cost));
		} catch (Exception e) {
			fail("exception thrown");
		}
		try {
			cost = StatusCommand.getCost("postgres1",
					Subscription.NOT_HAVE_SUBSCRIBER);
			assertTrue(Double.isNaN(cost));
		} catch (Exception e) {
			fail("exception thrown");
		}

		// resource error
		try {
			cost = StatusCommand.getCost("aaa", 1);
		} catch (SyncDatabaseException e) {
			assertEquals("resource aaa not found", e.getMessage());
		} catch (Exception e) {
			fail("other exception thrown");
		}

		// subscriber not found
		try {
			cost = StatusCommand.getCost("postgres1", 999);
		} catch (SyncDatabaseException e) {
			assertEquals("not found subscriber id 999", e.getMessage());
		} catch (Exception e) {
			fail("other exception thrown");
		}

		// normal case
		try {
			cost = StatusCommand.getCost("postgres1", 6);
			assertEquals(150, (int) (cost * 100));
		} catch (Exception e) {
			fail("exception thrown");
		}

		// normal case : NaN
		try {
			cost = StatusCommand.getCost("postgres1", 1);
			assertTrue(Double.isNaN(cost));
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testAppendLongValue() {
		StringBuilder builder = new StringBuilder();

		// argument error
		try {
			StatusCommand.appendLongValue(null, 1, 5, false);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			StatusCommand.appendLongValue(builder, 1, 0, false);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}

		// normal case
		try {
			StatusCommand.appendLongValue(builder, -1, 5, false);
			assertEquals("    -1 |", builder.toString());
			StatusCommand.appendLongValue(builder, 1000, 3, true);
			assertEquals("    -1 | 1000 \n", builder.toString());
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testAppendDoubleValue() {
		StringBuilder builder = new StringBuilder();

		// argument error
		try {
			StatusCommand.appendDoubleValue(null, 1.1, 5, false);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			StatusCommand.appendDoubleValue(builder, 1.1, 0, false);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}

		// normal case
		try {
			StatusCommand.appendDoubleValue(builder, Double.NaN, 5, false);
			assertEquals("   Inf |", builder.toString());
			StatusCommand.appendDoubleValue(builder, 100.1, 10, false);
			assertEquals("   Inf | 100.100000 |", builder.toString());
			StatusCommand.appendDoubleValue(builder, Double.NaN, 1, true);
			assertEquals("   Inf | 100.100000 | Inf \n", builder.toString());
			StatusCommand.appendDoubleValue(builder, 1.1111, 1, true);
			assertEquals("   Inf | 100.100000 | Inf \n 1 \n", builder
					.toString());
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testAppendStringValue() {
		StringBuilder builder = new StringBuilder();

		// argument error
		try {
			StatusCommand.appendStringValue(null, "abc", 5, false);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			StatusCommand.appendStringValue(builder, "abc", 0, false);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}

		// normal case
		try {
			StatusCommand.appendStringValue(builder, null, 5, false);
			assertEquals("       |", builder.toString());
			StatusCommand.appendStringValue(builder, "abc", 10, false);
			assertEquals("       | abc        |", builder.toString());
			StatusCommand.appendStringValue(builder, null, 1, true);
			assertEquals("       | abc        |   \n", builder.toString());
			StatusCommand.appendStringValue(builder, "abc", 1, true);
			assertEquals("       | abc        |   \n abc \n", builder
					.toString());
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testAppendTimestampValue() {
		StringBuilder builder = new StringBuilder();

		// argument error
		try {
			StatusCommand.appendTimestampValue(null, Timestamp
					.valueOf("2010-01-01 12:34:56"), false);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}

		// normal case
		try {
			StatusCommand.appendTimestampValue(builder, null, false);
			assertEquals("                     |", builder.toString());
			StatusCommand.appendTimestampValue(builder, Timestamp
					.valueOf("2010-01-01 12:34:56"), false);
			assertEquals("                     | 2010-01-01 12:34:56 |",
					builder.toString());
			StatusCommand.appendTimestampValue(builder, null, true);
			assertEquals(
					"                     | 2010-01-01 12:34:56 |                     \n",
					builder.toString());
			StatusCommand.appendTimestampValue(builder, Timestamp
					.valueOf("2010-01-02 12:34:56"), true);
			assertEquals(
					"                     | 2010-01-01 12:34:56 |                     \n 2010-01-02 12:34:56 \n",
					builder.toString());
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testAppendSeparator() {
		StringBuilder builder = new StringBuilder();

		// argument error
		try {
			StatusCommand.appendSeparator(null, 5, false);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			StatusCommand.appendSeparator(builder, -1, false);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}

		// normal case
		try {
			StatusCommand.appendSeparator(builder, 5, false);
			assertEquals("-------+", builder.toString());

			StatusCommand.appendSeparator(builder, 10, false);
			assertEquals("-------+------------+", builder.toString());

			StatusCommand.appendSeparator(builder, 10, true);
			assertEquals("-------+------------+------------\n", builder
					.toString());
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}
	}

	@SuppressWarnings("unchecked")
	@Test
	public final void testGetOptions() {
		String expected;
		String actual;
		Option option;
		Options options = StatusCommand.getOptions();
		assertNotNull(options);

		// option number
		int size = options.getOptions().size();
		assertEquals(6, size);

		// required options
		List list = options.getRequiredOptions();
		assertEquals(0, list.size());

		// cost option
		expected = "[ option: null cost  :: show cost ]";
		option = options.getOption("cost");
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
		StatusCommand.showHelp();

		System.out.flush();
		String actual = _baos.toString();
		assertEquals(help, actual);
	}

}
