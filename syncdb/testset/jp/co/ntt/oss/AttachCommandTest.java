package jp.co.ntt.oss;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.io.BufferedOutputStream;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.PrintStream;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
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

public class AttachCommandTest {
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

		help = "usage: SyncDatabase attach"
				+ newLine
				+ "    --help                           show help"
				+ newLine
				+ "    --master <master server name>    master server name"
				+ newLine
				+ "    --mode <full|incr[emental]>      attach mode, default is incremental"
				+ newLine
				+ "    --query <refresh query>          refresh query"
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
	public final void testAttachCommand() {
		String actual;
		AttachCommand command;
		Options options = new Options();
		options.addOption(null, "help", false, "");
		options.addOption(null, "schema", true, "");
		options.addOption(null, "table", true, "");
		options.addOption(null, "master", true, "");
		options.addOption(null, "server", true, "");
		options.addOption(null, "mode", true, "");
		options.addOption(null, "query", true, "");
		CommandLineParser parser = new BasicParser();

		// necessary argument error
		String[] args1 = { "--server", "serverName", "--schema", "schemaName",
				"--table", "tableName", "--mode", "full", "--query",
				"SELECT * FROM foo" };
		try {
			CommandLine commandLine = parser.parse(options, args1);
			new AttachCommand(commandLine);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("command error", actual);
		} catch (ParseException e) {
			fail("exception thrown");
		}
		String[] args2 = { "--master", "masterName", "--schema", "schemaName",
				"--table", "tableName", "--mode", "full", "--query",
				"SELECT * FROM foo" };
		try {
			CommandLine commandLine = parser.parse(options, args2);
			new AttachCommand(commandLine);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("command error", actual);
		} catch (ParseException e) {
			fail("exception thrown");
		}
		String[] args3 = { "--master", "masterName", "--server", "serverName",
				"--table", "tableName", "--mode", "full", "--query",
				"SELECT * FROM foo" };
		try {
			CommandLine commandLine = parser.parse(options, args3);
			new AttachCommand(commandLine);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("command error", actual);
		} catch (ParseException e) {
			fail("exception thrown");
		}
		String[] args4 = { "--master", "masterName", "--server", "serverName",
				"--schema", "schemaName", "--mode", "full", "--query",
				"SELECT * FROM foo" };
		try {
			CommandLine commandLine = parser.parse(options, args4);
			new AttachCommand(commandLine);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("command error", actual);
		} catch (ParseException e) {
			fail("exception thrown");
		}

		// refresh mode error
		String[] args5 = { "--master", "masterName", "--server", "serverName",
				"--schema", "schemaName", "--table", "tableName", "--mode",
				"aaa", "--query", "SELECT * FROM foo" };
		try {
			CommandLine commandLine = parser.parse(options, args5);
			new AttachCommand(commandLine);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("command error", actual);
		} catch (ParseException e) {
			fail("exception thrown");
		}

		// normal case : default value
		String[] args6 = { "--master", "masterName1", "--server",
				"serverName1", "--schema", "schemaName1", "--table",
				"tableName1", "--query", "SELECT * FROM foo1" };
		try {
			CommandLine commandLine = parser.parse(options, args6);
			command = new AttachCommand(commandLine);
			assertNotNull(command);

			String master = (String) PrivateAccessor.getPrivateField(command,
					"master");
			assertNotNull(master);
			assertEquals("masterName1", master);

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
			assertEquals(RefreshMode.INCREMENTAL, mode);

			String query = (String) PrivateAccessor.getPrivateField(command,
					"query");
			assertNotNull(query);
			assertEquals("SELECT * FROM foo1", query);

			Boolean showHelp = (Boolean) PrivateAccessor.getPrivateField(
					command, "showHelp");
			assertNotNull(showHelp);
			assertFalse(showHelp.booleanValue());
		} catch (Exception e) {
			fail("exception thrown");
		}

		// normal case : not default
		String[] args7 = { "--master", "masterName2", "--server",
				"serverName2", "--schema", "schemaName2", "--table",
				"tableName2", "--mode", "full", "--query", "SELECT * FROM foo2" };
		try {
			CommandLine commandLine = parser.parse(options, args7);
			command = new AttachCommand(commandLine);
			assertNotNull(command);

			String master = (String) PrivateAccessor.getPrivateField(command,
					"master");
			assertNotNull(master);
			assertEquals("masterName2", master);

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
			assertEquals(RefreshMode.FULL, mode);

			String query = (String) PrivateAccessor.getPrivateField(command,
					"query");
			assertNotNull(query);
			assertEquals("SELECT * FROM foo2", query);

			Boolean showHelp = (Boolean) PrivateAccessor.getPrivateField(
					command, "showHelp");
			assertNotNull(showHelp);
			assertFalse(showHelp.booleanValue());
		} catch (Exception e) {
			fail("exception thrown");
		}

		// normal case : help
		String[] args8 = { "--mode", "aaa", "--help" };
		try {
			CommandLine commandLine = parser.parse(options, args8);
			command = new AttachCommand(commandLine);
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

			RefreshMode mode = (RefreshMode) PrivateAccessor.getPrivateField(
					command, "mode");
			assertNotNull(mode);
			assertEquals(RefreshMode.INCREMENTAL, mode);

			String query = (String) PrivateAccessor.getPrivateField(command,
					"query");
			assertNull(query);

			Boolean showHelp = (Boolean) PrivateAccessor.getPrivateField(
					command, "showHelp");
			assertNotNull(showHelp);
			assertTrue(showHelp.booleanValue());
		} catch (Exception e) {
			fail("exception thrown");
		}

		ByteArrayInputStream _bais;
		InputStream _in;
		_in = System.in;

		// normal case : query input stdin
		String[] args9 = { "--master", "masterName3", "--server",
				"serverName3", "--schema", "schemaName3", "--table",
				"tableName3", "--mode", "incr", "--query", "sTdIn" };
		String inQuery1 = "SELECT\n" + "* FROM\n" + "AA\n" + "AA\n";
		try {
			_bais = new ByteArrayInputStream(inQuery1.getBytes());
			System.setIn(_bais);

			CommandLine commandLine = parser.parse(options, args9);
			command = new AttachCommand(commandLine);
			assertNotNull(command);

			String master = (String) PrivateAccessor.getPrivateField(command,
					"master");
			assertNotNull(master);
			assertEquals("masterName3", master);

			String server = (String) PrivateAccessor.getPrivateField(command,
					"server");
			assertNotNull(server);
			assertEquals("serverName3", server);

			String schema = (String) PrivateAccessor.getPrivateField(command,
					"schema");
			assertNotNull(schema);
			assertEquals("schemaName3", schema);

			String table = (String) PrivateAccessor.getPrivateField(command,
					"table");
			assertNotNull(table);
			assertEquals("tableName3", table);

			RefreshMode mode = (RefreshMode) PrivateAccessor.getPrivateField(
					command, "mode");
			assertNotNull(mode);
			assertEquals(RefreshMode.INCREMENTAL, mode);

			String query = (String) PrivateAccessor.getPrivateField(command,
					"query");
			assertNotNull(query);
			assertEquals("SELECT * FROM AA AA ", query);

			Boolean showHelp = (Boolean) PrivateAccessor.getPrivateField(
					command, "showHelp");
			assertNotNull(showHelp);
			assertFalse(showHelp.booleanValue());
		} catch (Exception e) {
			fail("exception thrown");
		}

		// normal case : no query option
		String[] args10 = { "--master", "masterName3", "--server",
				"serverName3", "--schema", "schemaName3", "--table",
				"tableName3", "--mode", "incremental" };
		String inQuery2 = "select\n" + "* from\n" + "aa\n" + "aa\n";
		try {
			_bais = new ByteArrayInputStream(inQuery2.getBytes());
			System.setIn(_bais);

			CommandLine commandLine = parser.parse(options, args10);
			command = new AttachCommand(commandLine);
			assertNotNull(command);

			String master = (String) PrivateAccessor.getPrivateField(command,
					"master");
			assertNotNull(master);
			assertEquals("masterName3", master);

			String server = (String) PrivateAccessor.getPrivateField(command,
					"server");
			assertNotNull(server);
			assertEquals("serverName3", server);

			String schema = (String) PrivateAccessor.getPrivateField(command,
					"schema");
			assertNotNull(schema);
			assertEquals("schemaName3", schema);

			String table = (String) PrivateAccessor.getPrivateField(command,
					"table");
			assertNotNull(table);
			assertEquals("tableName3", table);

			RefreshMode mode = (RefreshMode) PrivateAccessor.getPrivateField(
					command, "mode");
			assertNotNull(mode);
			assertEquals(RefreshMode.INCREMENTAL, mode);

			String query = (String) PrivateAccessor.getPrivateField(command,
					"query");
			assertNotNull(query);
			assertEquals("select * from aa aa ", query);

			Boolean showHelp = (Boolean) PrivateAccessor.getPrivateField(
					command, "showHelp");
			assertNotNull(showHelp);
			assertFalse(showHelp.booleanValue());
		} catch (Exception e) {
			fail("exception thrown");
		}

		System.setIn(_in);

		System.out.flush();
		actual = _baos.toString();
		assertEquals(help + help + help + help + help
				+ "input query : input query : ", actual);
	}

	@Test
	public final void testExecute() {
		String actual;
		AttachCommand com = null;
		Options options = new Options();
		options.addOption(null, "help", false, "");
		options.addOption(null, "schema", true, "");
		options.addOption(null, "table", true, "");
		options.addOption(null, "master", true, "");
		options.addOption(null, "server", true, "");
		options.addOption(null, "mode", true, "");
		options.addOption(null, "query", true, "");
		CommandLineParser parser = new BasicParser();

		String[] args = { "--master", "masterName", "--server", "serverName",
				"--schema", "schemaName", "--table", "tableName", "--mode",
				"full", "--query", "INSERT INTO foo" };
		try {
			CommandLine commandLine = parser.parse(options, args);
			com = new AttachCommand(commandLine);
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

		// replica resource name error
		PrivateAccessor
				.setPrivateField(com, "showHelp", Boolean.valueOf(false));
		try {
			com.execute();
			fail("no exception");
		} catch (Exception e) {
			actual = e.getMessage();
			assertEquals("resource serverName not found", actual);
		}

		// master resource name error
		PrivateAccessor.setPrivateField(com, "server", "postgres2");
		try {
			com.execute();
			fail("no exception");
		} catch (Exception e) {
			actual = e.getMessage();
			assertEquals("resource masterName not found", actual);
		}

		// full attach parse error
		PrivateAccessor.setPrivateField(com, "master", "postgres1");
		try {
			com.execute();
			fail("no exception");
		} catch (Exception e) {
			actual = e.getMessage();
			assertEquals("refresh query syntax error at 'INSERT INTO foo'",
					actual);
		}

		// incremental attach parse error
		PrivateAccessor.setPrivateField(com, "mode", RefreshMode.INCREMENTAL);
		PrivateAccessor.setPrivateField(com, "query",
				"SELECT * FROM \"public\".\"foo\" WHERE 1 = 1");
		try {
			com.execute();
			fail("no exception");
		} catch (Exception e) {
			actual = e.getMessage();
			assertEquals(
					"incremental refresh query syntax error at 'SELECT * FROM \"public\".\"foo\" WHERE 1 = 1'",
					actual);
		}

		// transaction error
		PrivateAccessor.setPrivateField(com, "query",
				"SELECT * FROM \"public\".\"noTable\"");
		try {
			UserTransaction localUtx = replicaDB.getUserTransaction();
			localUtx.begin();
			com.execute();
			fail("no exception");
		} catch (Exception e) {
			actual = e.getMessage();
			assertEquals("Nested transactions not supported", actual);
		}

		// subscribeObserver error
		try {
			com.execute();
			fail("no exception");
		} catch (Exception e) {
			actual = e.getMessage();
			assertEquals(
					"ERROR: relation \"public.noTable\" does not exist\n"
							+ "  Where: PL/pgSQL function \"subscribe_mlog\" line 7 at assignment",
					actual);
		}

		Statement stmt = null;
		ResultSet rset = null;
		try {
			stmt = masterConn.createStatement();
			rset = stmt
					.executeQuery("SELECT setval('mlog.subscriber_subsid_seq', 100)");
			rset.close();
			stmt.close();
		} catch (SQLException e1) {
			fail("exception thrown");
		}

		// subscribeObserver error
		PrivateAccessor.setPrivateField(com, "query",
				"SELECT * FROM \"public\".\"attach1\"");
		try {
			com.execute();
			fail("no exception");
		} catch (Exception e) {
			actual = e.getMessage();
			assertEquals(
					"ERROR: schema \"schemaName\" does not exist\n"
							+ "  Where: PL/pgSQL function \"subscribe\" line 13 at assignment",
					actual);

			// rollback ?
			try {
				SyncDatabaseDAO.getSubscriber(masterConn, 101);
			} catch (SQLException e1) {
				fail("other exception thrown");
			} catch (SyncDatabaseException e1) {
				assertEquals("not found subscriber id 101", e1.getMessage());
			}
		}

		// normal case : incremental
		PrivateAccessor.setPrivateField(com, "schema", "public");
		PrivateAccessor.setPrivateField(com, "table", "rep_attach_inc");
		try {
			com.execute();
			Subscription subs = SyncDatabaseDAO.getSubscription(replicaConn,
					"public", "rep_attach_inc");
			assertEquals("public", subs.getSchema());
			assertEquals("rep_attach_inc", subs.getTable());
			assertEquals("public.rep_attach_inc", subs.getReplicaTable());
			assertEquals("syncdbuser", subs.getAttachuser());
			assertEquals(102, subs.getSubsID());
			assertEquals("postgres1", subs.getSrvname());
			assertEquals("SELECT * FROM \"public\".\"attach1\"", subs
					.getQuery());
			// assertNull(subs.getLastTime());
			assertNull(subs.getLastType());

			Subscriber suber = SyncDatabaseDAO.getSubscriber(masterConn, subs
					.getSubsID());
			assertEquals(102, suber.getSubsID());
			assertEquals("public", suber.getNspName());
			assertEquals("attach1", suber.getRelName());
			assertEquals("public.attach1", suber.getMasterTableName());
			assertEquals("mlog.mlog$", suber.getMlogName().substring(0, 10));
			assertEquals("createuser", suber.getCreateUser());
			assertEquals("syncdbuser", suber.getAttachUser());
			assertTrue(suber
					.getDescription()
					.matches(
							"resource name:\"postgres2\", DBMS:\"PostgreSQL\", URL:\"jdbc:postgresql://.+"));
			assertNull(suber.getLastTime());
			assertNull(suber.getLastType());
			assertEquals(-1, suber.getLastMlogID());
			assertEquals(-1, suber.getLastCount());
		} catch (Exception e) {
			e.printStackTrace();
			fail("exception thrown");
		}

		// normal case : full
		PrivateAccessor.setPrivateField(com, "mode", RefreshMode.FULL);
		PrivateAccessor.setPrivateField(com, "table", "rep_attach_full");
		try {
			com.execute();
			Subscription subs = SyncDatabaseDAO.getSubscription(replicaConn,
					"public", "rep_attach_full");
			assertEquals("public", subs.getSchema());
			assertEquals("rep_attach_full", subs.getTable());
			assertEquals("public.rep_attach_full", subs.getReplicaTable());
			assertEquals("syncdbuser", subs.getAttachuser());
			assertEquals(0, subs.getSubsID());
			assertEquals("postgres1", subs.getSrvname());
			assertEquals("SELECT * FROM \"public\".\"attach1\"", subs
					.getQuery());
			// assertNull(subs.getLastTime());
			assertNull(subs.getLastType());
		} catch (Exception e) {
			e.printStackTrace();
			fail("exception thrown");
		}

		// cleanup
		try {
			stmt = masterConn.createStatement();
			stmt.executeUpdate("DELETE FROM mlog.subscriber "
					+ "WHERE subsid = 102");
			stmt.close();

			stmt = replicaConn.createStatement();
			stmt.executeUpdate("DELETE FROM observer.subscription "
					+ "WHERE repltbl "
					+ "IN('public.rep_attach_full'::regclass, "
					+ "'public.rep_attach_inc'::regclass)");
			stmt.close();
		} catch (SQLException e) {
			e.printStackTrace();
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetRefreshMode() {
		RefreshMode mode = RefreshMode.INCREMENTAL;

		// argument error
		try {
			mode = RefreshCommand.getRefreshMode(null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}

		// mode string error
		try {
			mode = RefreshCommand.getRefreshMode("incrementa");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("command error", e.getMessage());
		}

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
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@SuppressWarnings("unchecked")
	@Test
	public final void testGetOptions() {
		String expected;
		String actual;
		Option option;
		Options options = AttachCommand.getOptions();
		assertNotNull(options);

		// option number
		int size = options.getOptions().size();
		assertEquals(7, size);

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

		// mode option
		expected = "[ option: null mode  [ARG] :: attach mode, default is incremental ]";
		option = options.getOption("mode");
		assertNotNull(option);
		actual = option.toString();
		assertEquals(expected, actual);

		// query option
		expected = "[ option: null query  [ARG] :: refresh query ]";
		option = options.getOption("query");
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
		AttachCommand.showHelp();

		System.out.flush();
		String actual = _baos.toString();
		assertEquals(help, actual);
	}

}
