package jp.co.ntt.oss.data;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import java.sql.Timestamp;

import org.junit.Test;

public class SubscriberTest {

	@Test
	public final void testSubscriber() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		assertNotNull(suber);
	}

	@Test
	public final void testGetSubsID() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		assertEquals(123, suber.getSubsID());
	}

	@Test
	public final void testSetSubsID() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		suber.setSubsID(321);
		assertEquals(321, suber.getSubsID());
	}

	@Test
	public final void testGetNspName() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		assertEquals("nspName", suber.getNspName());
	}

	@Test
	public final void testSetNspName() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		suber.setNspName("change");
		assertEquals("change", suber.getNspName());
	}

	@Test
	public final void testGetRelName() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		assertEquals("relName", suber.getRelName());
	}

	@Test
	public final void testSetRelName() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		suber.setRelName("change");
		assertEquals("change", suber.getRelName());
	}

	@Test
	public final void testGetMasterTableName() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		assertEquals("masterTableName", suber.getMasterTableName());
	}

	@Test
	public final void testSetMasterTableName() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		suber.setMasterTableName("change");
		assertEquals("change", suber.getMasterTableName());
	}

	@Test
	public final void testGetMlogName() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		assertEquals("mlogName", suber.getMlogName());
	}

	@Test
	public final void testSetMlogName() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		suber.setMlogName("change");
		assertEquals("change", suber.getMlogName());
	}

	@Test
	public final void testGetCreateUser() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		assertEquals("createUser", suber.getCreateUser());
	}

	@Test
	public final void testSetCreateUser() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		suber.setCreateUser("change");
		assertEquals("change", suber.getCreateUser());
	}

	@Test
	public final void testGetAttachUser() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		assertEquals("attachUser", suber.getAttachUser());
	}

	@Test
	public final void testSetAttachUser() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		suber.setAttachUser("change");
		assertEquals("change", suber.getAttachUser());
	}

	@Test
	public final void testGetDescription() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		assertEquals("description", suber.getDescription());
	}

	@Test
	public final void testSetDescription() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		suber.setDescription("change");
		assertEquals("change", suber.getDescription());
	}

	@Test
	public final void testGetLastTime() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		assertEquals(Timestamp.valueOf("2010-01-01 12:34:56"), suber.getLastTime());
	}

	@Test
	public final void testSetLastTime() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		suber.setLastTime(Timestamp.valueOf("2010-01-02 12:34:56"));
		assertEquals(Timestamp.valueOf("2010-01-02 12:34:56"), suber.getLastTime());
	}

	@Test
	public final void testGetLastType() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		assertEquals("lastType", suber.getLastType());
	}

	@Test
	public final void testSetLastType() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		suber.setLastType("change");
		assertEquals("change", suber.getLastType());
	}

	@Test
	public final void testGetLastMlogID() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		assertEquals(456, suber.getLastMlogID());
	}

	@Test
	public final void testSetLastMlogID() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		suber.setLastMlogID(321);
		assertEquals(321, suber.getLastMlogID());
	}

	@Test
	public final void testGetLastCount() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		assertEquals(789, suber.getLastCount());
	}

	@Test
	public final void testSetLastCount() {
		Subscriber suber = new Subscriber(123, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"),
				"lastType", 456, 789);
		suber.setLastCount(321);
		assertEquals(321, suber.getLastCount());
	}

}
