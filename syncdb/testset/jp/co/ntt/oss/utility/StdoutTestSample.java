package jp.co.ntt.oss.utility;

import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;

public class StdoutTestSample {

	protected ByteArrayOutputStream _baos;
	protected PrintStream _out;
	protected static String newLine;

	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		newLine = System.getProperty("line.separator");
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

}
