package jp.co.ntt.oss.data;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.fail;

import java.sql.Connection;
import java.sql.SQLException;

import javax.transaction.Status;
import javax.transaction.SystemException;
import javax.transaction.UserTransaction;

import jp.co.ntt.oss.SyncDatabaseException;

import org.junit.Test;

public class DatabaseResourceTest {

	@Test
	public final void testDatabaseResource() {
		String actual;

		// null argument
		try {
			new DatabaseResource(null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		} catch (Exception e) {
			fail("other exception thrown");
		}

		// on JdbcResource.getJdbcResource exception
		try {
			new DatabaseResource("noName");
			fail("no exception");
		} catch (Exception e) {
			actual = e.getMessage();
			assertEquals("resource noName not found", actual);
		}

		// resource setting error
		try {
			new DatabaseResource("testName");
			fail("no exception");
		} catch (Exception e) {
			actual = e.getMessage();
			assertEquals(
					"Error trying to load driver: testClassName : testClassName",
					actual);
		}

		// normal case
		try {
			DatabaseResource db = new DatabaseResource("postgres1");
			assertNotNull(db);
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetUserTransaction() {
		try {
			DatabaseResource db = new DatabaseResource("postgres1");
			UserTransaction utx = db.getUserTransaction();
			assertNotNull(utx);
			utx.begin();

			Connection conn = db.getConnection();
			java.sql.Statement stmt = conn.createStatement();
			stmt.executeQuery("SELECT pg_sleep(61)");

			assertEquals(Status.STATUS_ACTIVE, utx.getStatus());
			utx.rollback();
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetConnection() {
		try {
			DatabaseResource db = new DatabaseResource("postgres1");
			Connection conn = db.getConnection();
			assertNotNull(conn);
			conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
			conn.close();
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testStop() {
		DatabaseResource db = null;
		try {
			db = new DatabaseResource("postgres1");
			Connection conn = db.getConnection();
			conn.close();
			db.stop();
		} catch (Exception e) {
			fail("exception thrown");
		}

		try {
			db.getConnection();
			fail("no exception");
		} catch (NullPointerException e) {
			// OK
		} catch (SQLException e) {
			fail("other exception thrown");
		}

		try {
			db.getUserTransaction();
			fail("no exception");
		} catch (NullPointerException e) {
			// OK
		} catch (SystemException e) {
			fail("other exception thrown");
		}

		try {
			db.stop();
			fail("no exception");
		} catch (NullPointerException e) {
			// OK
		} catch (SQLException e) {
			fail("other exception thrown");
		}
	}
}
