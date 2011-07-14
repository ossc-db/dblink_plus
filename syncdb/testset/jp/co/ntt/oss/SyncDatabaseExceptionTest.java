package jp.co.ntt.oss;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import org.junit.Test;

public class SyncDatabaseExceptionTest {

	@Test
	public final void testSyncDatabaseException() {
		String actual;
		SyncDatabaseException e;

		// null argument
		e = new SyncDatabaseException(null);
		assertNotNull(e);
		actual = e.getMessage();
		assertEquals("log message not found", actual);

		// empty argument
		e = new SyncDatabaseException("");
		assertNotNull(e);
		actual = e.getMessage();
		assertEquals("log message not found", actual);

		// no property
		e = new SyncDatabaseException("no.property");
		assertNotNull(e);
		actual = e.getMessage();
		assertEquals("log message not found", actual);

		// not have argument
		e = new SyncDatabaseException("error.parse");
		assertNotNull(e);
		actual = e.getMessage();
		assertEquals("parse error", actual);

		// no argument
		e = new SyncDatabaseException("error.not_implement");
		assertNotNull(e);
		actual = e.getMessage();
		assertEquals("{0} is not implement", actual);

		// have argument
		e = new SyncDatabaseException("error.not_implement", "test");
		assertNotNull(e);
		actual = e.getMessage();
		assertEquals("test is not implement", actual);

		// More than one argument
		e = new SyncDatabaseException("error.not_implement", "test1", "test2",
				"test3");
		assertNotNull(e);
		actual = e.getMessage();
		assertEquals("test1 is not implement", actual);
	}
}
