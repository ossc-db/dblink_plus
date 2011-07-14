package jp.co.ntt.oss.data;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import java.sql.Timestamp;

import jp.co.ntt.oss.utility.PrivateAccessor;

import org.junit.Test;

public class ReplicaStatusTest {

	@Test
	public final void testReplicaStatus() {
		ReplicaStatus status = new ReplicaStatus("schema", "table", Timestamp
				.valueOf("2010-01-01 12:34:56"), "master", 123);
		assertNotNull(status);

		String schema = (String) PrivateAccessor.getPrivateField(status,
				"schema");
		assertNotNull(schema);
		assertEquals("schema", schema);

		String table = (String) PrivateAccessor
				.getPrivateField(status, "table");
		assertNotNull(table);
		assertEquals("table", table);

		Timestamp lastRefresh = (Timestamp) PrivateAccessor.getPrivateField(
				status, "lastRefresh");
		assertNotNull(lastRefresh);
		assertEquals(Timestamp.valueOf("2010-01-01 12:34:56"), lastRefresh);

		String master = (String) PrivateAccessor.getPrivateField(status,
				"master");
		assertNotNull(master);
		assertEquals("master", master);

		Long subsID = (Long) PrivateAccessor.getPrivateField(status, "subsID");
		assertNotNull(subsID);
		assertEquals(123, subsID.longValue());

		assertEquals(5, ReplicaStatus.REPLICASTATUS_COLUMNS);

		assertEquals(5, ReplicaStatus.HEADERS.length);
		assertEquals("schema", ReplicaStatus.HEADERS[0]);
		assertEquals("table", ReplicaStatus.HEADERS[1]);
		assertEquals("last refresh", ReplicaStatus.HEADERS[2]);
		assertEquals("master", ReplicaStatus.HEADERS[3]);
		assertEquals("cost", ReplicaStatus.HEADERS[4]);
	}

	@Test
	public final void testGetSchema() {
		ReplicaStatus status = new ReplicaStatus("schema", "table", Timestamp
				.valueOf("2010-01-01 12:34:56"), "master", 123);

		String schema = status.getSchema();
		assertNotNull(schema);
		assertEquals("schema", schema);
	}

	@Test
	public final void testSetSchema() {
		ReplicaStatus status = new ReplicaStatus("schema", "table", Timestamp
				.valueOf("2010-01-01 12:34:56"), "master", 123);

		status.setSchema("change");
		String schema = status.getSchema();
		assertNotNull(schema);
		assertEquals("change", schema);
	}

	@Test
	public final void testGetTable() {
		ReplicaStatus status = new ReplicaStatus("schema", "table", Timestamp
				.valueOf("2010-01-01 12:34:56"), "master", 123);

		String table = status.getTable();
		assertNotNull(table);
		assertEquals("table", table);
	}

	@Test
	public final void testSetTable() {
		ReplicaStatus status = new ReplicaStatus("schema", "table", Timestamp
				.valueOf("2010-01-01 12:34:56"), "master", 123);

		status.setTable("change");
		String table = status.getTable();
		assertNotNull(table);
		assertEquals("change", table);
	}

	@Test
	public final void testGetLastRefresh() {
		ReplicaStatus status = new ReplicaStatus("schema", "table", Timestamp
				.valueOf("2010-01-01 12:34:56"), "master", 123);

		Timestamp lastRefresh = status.getLastRefresh();
		assertNotNull(lastRefresh);
		assertEquals(Timestamp.valueOf("2010-01-01 12:34:56"), lastRefresh);
	}

	@Test
	public final void testSetLastRefresh() {
		ReplicaStatus status = new ReplicaStatus("schema", "table", Timestamp
				.valueOf("2010-01-01 12:34:56"), "master", 123);

		status.setLastRefresh(Timestamp.valueOf("2010-01-02 12:34:56"));
		assertEquals(Timestamp.valueOf("2010-01-02 12:34:56"), status
				.getLastRefresh());
	}

	@Test
	public final void testGetMaster() {
		ReplicaStatus status = new ReplicaStatus("schema", "table", Timestamp
				.valueOf("2010-01-01 12:34:56"), "master", 123);

		String master = status.getMaster();
		assertNotNull(master);
		assertEquals("master", master);
	}

	@Test
	public final void testSetMaster() {
		ReplicaStatus status = new ReplicaStatus("schema", "table", Timestamp
				.valueOf("2010-01-01 12:34:56"), "master", 123);

		status.setMaster("change");
		String master = status.getMaster();
		assertNotNull(master);
		assertEquals("change", master);
	}

	@Test
	public final void testGetSubsID() {
		ReplicaStatus status = new ReplicaStatus("schema", "table", Timestamp
				.valueOf("2010-01-01 12:34:56"), "master", 123);

		long subsID = status.getSubsID();
		assertNotNull(subsID);
		assertEquals(123, subsID);
	}

	@Test
	public final void testSetSubsID() {
		ReplicaStatus status = new ReplicaStatus("schema", "table", Timestamp
				.valueOf("2010-01-01 12:34:56"), "master", 123);

		status.setSubsID(456);
		long subsID = status.getSubsID();
		assertNotNull(subsID);
		assertEquals(456, subsID);
	}

}
