package jp.co.ntt.oss;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.fail;

import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.util.List;

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

public class HelpCommandTest {

	private static String help;

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
	public void testHelpCommand() {
		Options options = new Options();
		CommandLineParser parser = new BasicParser();
		CommandLine commandLine = null;
		try {
			commandLine = parser.parse(options, new String[0]);
		} catch (ParseException e) {
			fail("exception thrown");
		}

		HelpCommand com = null;

		// null argument
		try {
			com = new HelpCommand(null);
			assertNotNull(com);
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}

		// commandLine argument
		try {
			com = new HelpCommand(commandLine);
			assertNotNull(com);
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}
	}

	@Test
	public void testExecute() {
		HelpCommand com = null;

		try {
			com = new HelpCommand(null);
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}
		try {
			com.execute();
		} catch (Exception e) {
			fail("exception thrown");
		}
		System.out.flush();
		String actual = _baos.toString();
		assertEquals(help, actual);
	}

	@SuppressWarnings("unchecked")
	@Test
	public void testGetOptions() {
		String expected;
		Option option;
		final Options options = HelpCommand.getOptions();
		assertNotNull(options);

		// option number
		final int size = options.getOptions().size();
		assertEquals(11, size);

		// required options
		final List list = options.getRequiredOptions();
		assertEquals(0, list.size());

		// concurrent option
		expected = "[ option: null concurrent  :: exclusive lock a replica table ]";
		option = options.getOption("concurrent");
		assertNotNull(option);
		assertEquals(expected, option.toString());

		// cost option
		expected = "[ option: null cost  :: show cost ]";
		option = options.getOption("cost");
		assertNotNull(option);
		assertEquals(expected, option.toString());

		// force option
		expected = "[ option: null force  :: force detach ]";
		option = options.getOption("force");
		assertNotNull(option);
		assertEquals(expected, option.toString());

		// help option
		expected = "[ option: null help  :: show help ]";
		option = options.getOption("help");
		assertNotNull(option);
		assertEquals(expected, option.toString());

		// master option
		expected = "[ option: null master  [ARG] :: master server resource name ]";
		option = options.getOption("master");
		assertNotNull(option);
		assertEquals(expected, option.toString());

		// mode option
		expected = "[ option: null mode  [ARG] :: refresh mode ]";
		option = options.getOption("mode");
		assertNotNull(option);
		assertEquals(expected, option.toString());

		// query option
		expected = "[ option: null query  [ARG] :: refresh query string ]";
		option = options.getOption("query");
		assertNotNull(option);
		assertEquals(expected, option.toString());

		// schema option
		expected = "[ option: null schema  [ARG] :: schema name ]";
		option = options.getOption("schema");
		assertNotNull(option);
		assertEquals(expected, option.toString());

		// server option
		expected = "[ option: null server  [ARG] :: replica server resource name ]";
		option = options.getOption("server");
		assertNotNull(option);
		assertEquals(expected, option.toString());

		// table option
		expected = "[ option: null table  [ARG] :: table name ]";
		option = options.getOption("table");
		assertNotNull(option);
		assertEquals(expected, option.toString());
	}

	@Test
	public void testShowHelp() {
		HelpCommand.showHelp();

		System.out.flush();
		final String actual = _baos.toString();
		assertEquals(help, actual);
	}

}
