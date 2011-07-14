package jp.co.ntt.oss.data;

import static org.junit.Assert.*;

import java.sql.Timestamp;

import jp.co.ntt.oss.utility.PrivateAccessor;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class MasterStatusTest {

	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {
	}

	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public final void testMasterStatus() {
		MasterStatus status = new MasterStatus("schema", "table", 123, 456,
				Timestamp.valueOf("2010-01-01 12:34:56"), "oldestReplica");
		assertNotNull(status);

		String schema = (String) PrivateAccessor.getPrivateField(status,
				"schema");
		assertNotNull(schema);
		assertEquals("schema", schema);

		String table = (String) PrivateAccessor
				.getPrivateField(status, "table");
		assertNotNull(table);
		assertEquals("table", table);

		Long logCount = (Long) PrivateAccessor.getPrivateField(status,
				"logCount");
		assertNotNull(logCount);
		assertEquals(123, logCount.longValue());

		Long subscribers = (Long) PrivateAccessor.getPrivateField(status,
				"subscribers");
		assertNotNull(subscribers);
		assertEquals(456, subscribers.longValue());

		Timestamp oldestRefresh = (Timestamp) PrivateAccessor.getPrivateField(
				status, "oldestRefresh");
		assertNotNull(oldestRefresh);
		assertEquals(Timestamp.valueOf("2010-01-01 12:34:56"), oldestRefresh);

		String oldestReplica = (String) PrivateAccessor.getPrivateField(status,
				"oldestReplica");
		assertNotNull(oldestReplica);
		assertEquals("oldestReplica", oldestReplica);

		assertEquals(6, MasterStatus.MASTERSTATUS_COLUMNS);

		assertEquals(6, MasterStatus.HEADERS.length);
		assertEquals("schema", MasterStatus.HEADERS[0]);
		assertEquals("table", MasterStatus.HEADERS[1]);
		assertEquals("logs", MasterStatus.HEADERS[2]);
		assertEquals("subs", MasterStatus.HEADERS[3]);
		assertEquals("oldest refresh", MasterStatus.HEADERS[4]);
		assertEquals("oldest replica", MasterStatus.HEADERS[5]);

		assertEquals(-1, MasterStatus.INVALID_LOG_COUNT);
	}

	@Test
	public final void testGetSchema() {
		MasterStatus status = new MasterStatus("schema", "table", 123, 456,
				Timestamp.valueOf("2010-01-01 12:34:56"), "oldestReplica");

		String schema = status.getSchema();
		assertNotNull(schema);
		assertEquals("schema", schema);
	}

	@Test
	public final void testSetSchema() {
		MasterStatus status = new MasterStatus("schema", "table", 123, 456,
				Timestamp.valueOf("2010-01-01 12:34:56"), "oldestReplica");

		status.setSchema("change");
		String schema = status.getSchema();
		assertNotNull(schema);
		assertEquals("change", schema);
	}

	@Test
	public final void testGetTable() {
		MasterStatus status = new MasterStatus("schema", "table", 123, 456,
				Timestamp.valueOf("2010-01-01 12:34:56"), "oldestReplica");

		String table = status.getTable();
		assertNotNull(table);
		assertEquals("table", table);
	}

	@Test
	public final void testSetTable() {
		MasterStatus status = new MasterStatus("schema", "table", 123, 456,
				Timestamp.valueOf("2010-01-01 12:34:56"), "oldestReplica");

		status.setTable("change");
		String table = status.getTable();
		assertNotNull(table);
		assertEquals("change", table);
	}

	@Test
	public final void testGetLogCount() {
		MasterStatus status = new MasterStatus("schema", "table", 123, 456,
				Timestamp.valueOf("2010-01-01 12:34:56"), "oldestReplica");

		long logCount = status.getLogCount();
		assertEquals(123, logCount);
	}

	@Test
	public final void testSetLogCount() {
		MasterStatus status = new MasterStatus("schema", "table", 123, 456,
				Timestamp.valueOf("2010-01-01 12:34:56"), "oldestReplica");

		status.setLogCount(789);
		long logCount = status.getLogCount();
		assertEquals(789, logCount);
	}

	@Test
	public final void testGetSubscribers() {
		MasterStatus status = new MasterStatus("schema", "table", 123, 456,
				Timestamp.valueOf("2010-01-01 12:34:56"), "oldestReplica");

		long subscribers = status.getSubscribers();
		assertEquals(456, subscribers);
	}

	@Test
	public final void testSetSubscribers() {
		MasterStatus status = new MasterStatus("schema", "table", 123, 456,
				Timestamp.valueOf("2010-01-01 12:34:56"), "oldestReplica");

		status.setSubscribers(789);
		long subscribers = status.getSubscribers();
		assertEquals(789, subscribers);
	}

	@Test
	public final void testIncrSubscribers() {
		MasterStatus status = new MasterStatus("schema", "table", 123, 456,
				Timestamp.valueOf("2010-01-01 12:34:56"), "oldestReplica");

		status.incrSubscribers();
		long subscribers = status.getSubscribers();
		assertEquals(457, subscribers);

		status.incrSubscribers();
		subscribers = status.getSubscribers();
		assertEquals(458, subscribers);
	}

	@Test
	public final void testGetOldestRefresh() {
		MasterStatus status = new MasterStatus("schema", "table", 123, 456,
				Timestamp.valueOf("2010-01-01 12:34:56"), "oldestReplica");

		Timestamp oldestRefresh = status.getOldestRefresh();
		assertNotNull(oldestRefresh);
		assertEquals(Timestamp.valueOf("2010-01-01 12:34:56"), oldestRefresh);
	}

	@Test
	public final void testSetOldestRefresh() {
		MasterStatus status = new MasterStatus("schema", "table", 123, 456,
				Timestamp.valueOf("2010-01-01 12:34:56"), "oldestReplica");

		status.setOldestRefresh(Timestamp.valueOf("2010-01-02 12:34:56"));
		Timestamp oldestRefresh = status.getOldestRefresh();
		assertNotNull(oldestRefresh);
		assertEquals(Timestamp.valueOf("2010-01-02 12:34:56"), oldestRefresh);
	}

	@Test
	public final void testUpdateOldestRefresh() {
		MasterStatus status = new MasterStatus("schema", "table", 123, 456,
				null, "oldestReplica");

		status.updateOldestRefresh(null);
		Timestamp oldestRefresh = status.getOldestRefresh();
		assertNull(oldestRefresh);

		status.updateOldestRefresh(Timestamp.valueOf("2010-01-02 12:34:56"));
		oldestRefresh = status.getOldestRefresh();
		assertNotNull(oldestRefresh);
		assertEquals(Timestamp.valueOf("2010-01-02 12:34:56"), oldestRefresh);

		status.updateOldestRefresh(Timestamp.valueOf("2010-01-03 12:34:56"));
		oldestRefresh = status.getOldestRefresh();
		assertNotNull(oldestRefresh);
		assertEquals(Timestamp.valueOf("2010-01-02 12:34:56"), oldestRefresh);

		status.updateOldestRefresh(Timestamp.valueOf("2010-01-01 12:34:56"));
		oldestRefresh = status.getOldestRefresh();
		assertNotNull(oldestRefresh);
		assertEquals(Timestamp.valueOf("2010-01-01 12:34:56"), oldestRefresh);
	}

	@Test
	public final void testGetOldestReplica() {
		MasterStatus status = new MasterStatus("schema", "table", 123, 456,
				Timestamp.valueOf("2010-01-01 12:34:56"), "oldestReplica");

		String oldestReplica = status.getOldestReplica();
		assertNotNull(oldestReplica);
		assertEquals("oldestReplica", oldestReplica);
	}

	@Test
	public final void testSetOldestReplica() {
		MasterStatus status = new MasterStatus("schema", "table", 123, 456,
				Timestamp.valueOf("2010-01-01 12:34:56"), "oldestReplica");

		status.setOldestReplica("change");
		String oldestReplica = status.getOldestReplica();
		assertNotNull(oldestReplica);
		assertEquals("change", oldestReplica);
	}

}
