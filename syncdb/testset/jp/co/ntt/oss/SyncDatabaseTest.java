package jp.co.ntt.oss;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class SyncDatabaseTest {
	private static String help;
	String version = "SyncDatabase 1.0.0";

	protected ByteArrayOutputStream _baos;
	protected PrintStream _out;
	protected static String newLine;

	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		newLine = System.getProperty("line.separator");

		help = "usage: SyncDatabase create | drop | attach | detach | refresh | status"
				+ newLine
				+ "                    [options]"
				+ newLine
				+ "    --concurrent              exclusive lock a replica table"
				+ newLine
				+ "    --cost                    show cost"
				+ newLine
				+ "    --force                   force detach"
				+ newLine
				+ "    --help                    show help"
				+ newLine
				+ "    --master <master name>    master server resource name"
				+ newLine
				+ "    --mode <arg>              refresh mode"
				+ newLine
				+ "    --query <query>           refresh query string"
				+ newLine
				+ "    --schema <schema name>    schema name"
				+ newLine
				+ "    --server <replica name>   replica server resource name"
				+ newLine
				+ "    --table <table name>      table name"
				+ newLine
				+ "    --version                 show version"
				+ newLine;

	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {
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
	public final void testMain() {
		String actual = null;
		String[] args1 = { "help" };

		// getSyncDatabaseCommand error
		SyncDatabase.main(args1);

		System.out.flush();
		actual = _baos.toString();
		assertEquals(help, actual);

		String[] args2 = { "--version" };

		// getSyncDatabaseCommand error
		SyncDatabase.main(args2);

		System.out.flush();
		actual = _baos.toString();
		assertEquals(help + version + newLine, actual);
	}

	@Test
	public final void testGetSyncDatabaseCommand() {
		String actual = null;
		SyncDatabaseCommand command = null;

		// null argument
		try {
			SyncDatabase.getSyncDatabaseCommand(null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			System.out.flush();
			actual = _baos.toString();
			assertEquals(help, actual);

			actual = e.getMessage();
			assertEquals("command error", actual);
		} catch (ParseException e) {
			fail("other exception thrown");
		}

		// no argument
		try {
			SyncDatabase.getSyncDatabaseCommand(new String[0]);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			System.out.flush();
			actual = _baos.toString();
			assertEquals(help + help, actual);

			actual = e.getMessage();
			assertEquals("command error", actual);
		} catch (ParseException e) {
			fail("other exception thrown");
		}

		// not exist command
		String[] arg1 = { "aaa" };
		try {
			SyncDatabase.getSyncDatabaseCommand(arg1);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			System.out.flush();
			actual = _baos.toString();
			assertEquals(help + help + help, actual);

			actual = e.getMessage();
			assertEquals("command error", actual);
		} catch (ParseException e) {
			fail("other exception thrown");
		}

		// attach command
		String[] args_attach1 = { "attach", "--error" };
		try {
			SyncDatabase.getSyncDatabaseCommand(args_attach1);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			fail("other exception thrown");
		} catch (ParseException e) {
			actual = e.getMessage();
			assertEquals("Unrecognized option: --error", actual);
		}
		String[] args_attach2 = { "attach", "--master", "masterName2",
				"--server", "serverName2", "--schema", "schemaName2",
				"--table", "tableName2", "--mode", "incremental", "--help" };
		try {
			command = SyncDatabase.getSyncDatabaseCommand(args_attach2);
			assertEquals("jp.co.ntt.oss.AttachCommand", command.getClass()
					.getName());
		} catch (Exception e) {
			fail("exception thrown");
		}

		// refresh command
		String[] args_refresh1 = { "refresh", "--error" };
		try {
			SyncDatabase.getSyncDatabaseCommand(args_refresh1);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			fail("other exception thrown");
		} catch (ParseException e) {
			actual = e.getMessage();
			assertEquals("Unrecognized option: --error", actual);
		}
		String[] args_refresh2 = { "refresh", "--server", "serverName2",
				"--schema", "schemaName2", "--table", "tableName2",
				"--concurrent", "--mode", "incremental", "--help" };
		try {
			command = SyncDatabase.getSyncDatabaseCommand(args_refresh2);
			assertEquals("jp.co.ntt.oss.RefreshCommand", command.getClass()
					.getName());
		} catch (Exception e) {
			fail("exception thrown");
		}

		// status command
		String[] args_status1 = { "status", "--error" };
		try {
			SyncDatabase.getSyncDatabaseCommand(args_status1);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			fail("other exception thrown");
		} catch (ParseException e) {
			actual = e.getMessage();
			assertEquals("Unrecognized option: --error", actual);
		}
		String[] args_status2 = { "status", "--server", "serverName2",
				"--schema", "schemaName2", "--table", "tableName2", };
		try {
			command = SyncDatabase.getSyncDatabaseCommand(args_status2);
			assertEquals("jp.co.ntt.oss.StatusCommand", command.getClass()
					.getName());
		} catch (Exception e) {
			fail("exception thrown");
		}

		// detach command
		String[] args_detach1 = { "detach", "--error" };
		try {
			SyncDatabase.getSyncDatabaseCommand(args_detach1);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			fail("other exception thrown");
		} catch (ParseException e) {
			actual = e.getMessage();
			assertEquals("Unrecognized option: --error", actual);
		}
		String[] args_detach2 = { "detach", "--server", "serverName2",
				"--schema", "schemaName2", "--table", "tableName2" };
		try {
			command = SyncDatabase.getSyncDatabaseCommand(args_detach2);
			assertEquals("jp.co.ntt.oss.DetachCommand", command.getClass()
					.getName());
		} catch (Exception e) {
			fail("exception thrown");
		}

		// drop command
		String[] args_drop1 = { "drop", "--error" };
		try {
			SyncDatabase.getSyncDatabaseCommand(args_drop1);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			fail("other exception thrown");
		} catch (ParseException e) {
			actual = e.getMessage();
			assertEquals("Unrecognized option: --error", actual);
		}
		String[] args_drop2 = { "drop", "--master", "masterName2", "--schema",
				"schemaName2", "--table", "tableName2" };
		try {
			command = SyncDatabase.getSyncDatabaseCommand(args_drop2);
			assertEquals("jp.co.ntt.oss.DropCommand", command.getClass()
					.getName());
		} catch (Exception e) {
			fail("exception thrown");
		}

		// create command
		String[] args_create1 = { "create", "--error" };
		try {
			SyncDatabase.getSyncDatabaseCommand(args_create1);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			fail("other exception thrown");
		} catch (ParseException e) {
			actual = e.getMessage();
			assertEquals("Unrecognized option: --error", actual);
		}
		String[] args_create2 = { "create", "--master", "masterName2",
				"--schema", "schemaName2", "--table", "tableName2" };
		try {
			command = SyncDatabase.getSyncDatabaseCommand(args_create2);
			assertEquals("jp.co.ntt.oss.CreateCommand", command.getClass()
					.getName());
		} catch (Exception e) {
			fail("exception thrown");
		}

		// help command
		String[] args_help1 = { "help", "--error" };
		try {
			SyncDatabase.getSyncDatabaseCommand(args_help1);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			fail("other exception thrown");
		} catch (ParseException e) {
			actual = e.getMessage();
			assertEquals("Unrecognized option: --error", actual);
		}
		String[] args_help2 = { "help", "--server", "serverName2", "--schema",
				"schemaName2", "--table", "tableName2", "--concurrent",
				"--mode", "incremental", "--help" };
		try {
			command = SyncDatabase.getSyncDatabaseCommand(args_help2);
			assertEquals("jp.co.ntt.oss.HelpCommand", command.getClass()
					.getName());
		} catch (Exception e) {
			fail("exception thrown");
		}

		// version command
		String[] args_version1 = { "aaa", "--help", "--version", "--error" };
		try {
			command = SyncDatabase.getSyncDatabaseCommand(args_version1);
			assertEquals("jp.co.ntt.oss.VersionCommand", command.getClass()
					.getName());
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testParseCommandLine() {
		String[] args = {};
		Options options = new Options();
		options.addOption("a", true, "option test");
		String actual;

		// null argument
		try {
			SyncDatabase.parseCommandLine(null, options, "command");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		} catch (ParseException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabase.parseCommandLine(args, null, "command");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		} catch (ParseException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabase.parseCommandLine(args, options, null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		} catch (ParseException e) {
			fail("other exception thrown");
		}

		// parse error
		String[] args1 = { "command", "-a" };
		try {
			SyncDatabase.parseCommandLine(args1, options, "command");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			fail("other exception thrown");
		} catch (ParseException e) {
			actual = e.getMessage();
			assertEquals("Missing argument for option: a", actual);
		}

		// no command error
		String[] args2 = { "-a", "str" };
		try {
			SyncDatabase.parseCommandLine(args2, options, "command");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("option error", actual);
		} catch (ParseException e) {
			fail("other exception thrown");
		}

		// miss match command error
		String[] args3 = { "-a", "str" };
		try {
			SyncDatabase.parseCommandLine(args3, options, "command");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("option error", actual);
		} catch (ParseException e) {
			fail("other exception thrown");
		}

		// normal case
		String[] args4 = { "command", "-a", "str" };
		try {
			CommandLine commandLine = SyncDatabase.parseCommandLine(args4,
					options, "command");
			assertTrue(commandLine.hasOption("a"));
			assertEquals("str", commandLine.getOptionValue("a"));
		} catch (Exception e) {
			fail("exception thrown");
		}
	}
}
