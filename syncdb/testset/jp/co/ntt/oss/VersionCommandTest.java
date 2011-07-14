package jp.co.ntt.oss;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class VersionCommandTest {

	protected String version = "SyncDatabase 1.0.0";
	protected ByteArrayOutputStream _baos;
	protected PrintStream _out;
	protected static String newLine;

	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		newLine = System.getProperty("line.separator");
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
	public void testVersionCommand() {
		VersionCommand com = new VersionCommand();
		assertNotNull(com);
	}

	@Test
	public void testExecute() {
		VersionCommand com = new VersionCommand();
		com.execute();

		System.out.flush();
		String actual = _baos.toString();
		assertEquals(version + newLine, actual);
	}

	@Test
	public void testShowVersion() {
		VersionCommand.showVersion();

		System.out.flush();
		String actual = _baos.toString();
		assertEquals(version + newLine, actual);
	}

}
