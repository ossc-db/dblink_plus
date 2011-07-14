package jp.co.ntt.oss.data;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import java.sql.Timestamp;

import org.junit.Test;

public class SubscriptionTest {

	@Test
	public final void testSubscription() {
		Subscription subs = new Subscription("schema", "table", "replicaTable",
				"attachuser", 123, "srvname", "query", Timestamp
						.valueOf("2010-01-01 12:34:56"), "lastType");
		assertNotNull(subs);
	}

	@Test
	public final void testGetSchema() {
		Subscription subs = new Subscription("schema", "table", "replicaTable",
				"attachuser", 123, "srvname", "query", Timestamp
						.valueOf("2010-01-01 12:34:56"), "lastType");
		assertEquals("schema", subs.getSchema());
	}

	@Test
	public final void testSetSchema() {
		Subscription subs = new Subscription("schema", "table", "replicaTable",
				"attachuser", 123, "srvname", "query", Timestamp
						.valueOf("2010-01-01 12:34:56"), "lastType");
		subs.setSchema("change");
		assertEquals("change", subs.getSchema());
	}

	@Test
	public final void testGetTable() {
		Subscription subs = new Subscription("schema", "table", "replicaTable",
				"attachuser", 123, "srvname", "query", Timestamp
						.valueOf("2010-01-01 12:34:56"), "lastType");
		assertEquals("table", subs.getTable());
	}

	@Test
	public final void testSetTable() {
		Subscription subs = new Subscription("schema", "table", "replicaTable",
				"attachuser", 123, "srvname", "query", Timestamp
						.valueOf("2010-01-01 12:34:56"), "lastType");
		subs.setTable("change");
		assertEquals("change", subs.getTable());
	}

	@Test
	public final void testGetReplicaTable() {
		Subscription subs = new Subscription("schema", "table", "replicaTable",
				"attachuser", 123, "srvname", "query", Timestamp
						.valueOf("2010-01-01 12:34:56"), "lastType");
		assertEquals("replicaTable", subs.getReplicaTable());
	}

	@Test
	public final void testSetReplicaTable() {
		Subscription subs = new Subscription("schema", "table", "replicaTable",
				"attachuser", 123, "srvname", "query", Timestamp
						.valueOf("2010-01-01 12:34:56"), "lastType");
		subs.setReplicaTable("change");
		assertEquals("change", subs.getReplicaTable());
	}

	@Test
	public final void testGetAttachuser() {
		Subscription subs = new Subscription("schema", "table", "replicaTable",
				"attachuser", 123, "srvname", "query", Timestamp
						.valueOf("2010-01-01 12:34:56"), "lastType");
		assertEquals("attachuser", subs.getAttachuser());
	}

	@Test
	public final void testSetAttachuser() {
		Subscription subs = new Subscription("schema", "table", "replicaTable",
				"attachuser", 123, "srvname", "query", Timestamp
						.valueOf("2010-01-01 12:34:56"), "lastType");
		subs.setAttachuser("change");
		assertEquals("change", subs.getAttachuser());
	}

	@Test
	public final void testGetSubsID() {
		Subscription subs = new Subscription("schema", "table", "replicaTable",
				"attachuser", 123, "srvname", "query", Timestamp
						.valueOf("2010-01-01 12:34:56"), "lastType");
		assertEquals(123, subs.getSubsID());
	}

	@Test
	public final void testSetSubsID() {
		Subscription subs = new Subscription("schema", "table", "replicaTable",
				"attachuser", 123, "srvname", "query", Timestamp
						.valueOf("2010-01-01 12:34:56"), "lastType");
		subs.setSubsID(321);
		assertEquals(321, subs.getSubsID());
	}

	@Test
	public final void testGetSrvname() {
		Subscription subs = new Subscription("schema", "table", "replicaTable",
				"attachuser", 123, "srvname", "query", Timestamp
						.valueOf("2010-01-01 12:34:56"), "lastType");
		assertEquals("srvname", subs.getSrvname());
	}

	@Test
	public final void testSetSrvname() {
		Subscription subs = new Subscription("schema", "table", "replicaTable",
				"attachuser", 123, "srvname", "query", Timestamp
						.valueOf("2010-01-01 12:34:56"), "lastType");
		subs.setSrvname("change");
		assertEquals("change", subs.getSrvname());
	}

	@Test
	public final void testGetQuery() {
		Subscription subs = new Subscription("schema", "table", "replicaTable",
				"attachuser", 123, "srvname", "query", Timestamp
						.valueOf("2010-01-01 12:34:56"), "lastType");
		assertEquals("query", subs.getQuery());
	}

	@Test
	public final void testSetQuery() {
		Subscription subs = new Subscription("schema", "table", "replicaTable",
				"attachuser", 123, "srvname", "query", Timestamp
						.valueOf("2010-01-01 12:34:56"), "lastType");
		subs.setQuery("change");
		assertEquals("change", subs.getQuery());
	}

	@Test
	public final void testGetLastTime() {
		Subscription subs = new Subscription("schema", "table", "replicaTable",
				"attachuser", 123, "srvname", "query", Timestamp
						.valueOf("2010-01-01 12:34:56"), "lastType");
		assertEquals(Timestamp.valueOf("2010-01-01 12:34:56"), subs
				.getLastTime());
	}

	@Test
	public final void testSetLastTime() {
		Subscription subs = new Subscription("schema", "table", "replicaTable",
				"attachuser", 123, "srvname", "query", Timestamp
						.valueOf("2010-01-01 12:34:56"), "lastType");
		subs.setLastTime(Timestamp.valueOf("2010-01-02 12:34:56"));
		assertEquals(Timestamp.valueOf("2010-01-02 12:34:56"), subs
				.getLastTime());
	}

	@Test
	public final void testGetLastType() {
		Subscription subs = new Subscription("schema", "table", "replicaTable",
				"attachuser", 123, "srvname", "query", Timestamp
						.valueOf("2010-01-01 12:34:56"), "lastType");
		assertEquals("lastType", subs.getLastType());
	}

	@Test
	public final void testSetLastType() {
		Subscription subs = new Subscription("schema", "table", "replicaTable",
				"attachuser", 123, "srvname", "query", Timestamp
						.valueOf("2010-01-01 12:34:56"), "lastType");
		subs.setLastType("change");
		assertEquals("change", subs.getLastType());
	}
}
