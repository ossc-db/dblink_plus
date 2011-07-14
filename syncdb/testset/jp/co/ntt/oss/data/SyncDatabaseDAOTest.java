package jp.co.ntt.oss.data;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Hashtable;

import javax.transaction.SystemException;
import javax.transaction.UserTransaction;

import jp.co.ntt.oss.RefreshMode;
import jp.co.ntt.oss.SyncDatabaseException;
import jp.co.ntt.oss.utility.PrivateAccessor;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class SyncDatabaseDAOTest {
	private static DatabaseResource replicaDB = null;
	private static DatabaseResource masterDB = null;
	private static Connection replicaConn = null;
	private static Connection masterConn = null;
	private static DatabaseResource oraDB = null;
	private static Connection oraConn = null;

	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		masterDB = new DatabaseResource("postgres1");
		replicaDB = new DatabaseResource("postgres2");
		masterConn = masterDB.getConnection();
		replicaConn = replicaDB.getConnection();
		oraDB = new DatabaseResource("oracle");
		oraConn = oraDB.getConnection();
	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {
		replicaConn.close();
		masterConn.close();
		replicaDB.stop();
		masterDB.stop();
		oraConn.close();
		oraDB.stop();
	}

	@Before
	public void setUp() throws Exception {
		UserTransaction utx = replicaDB.getUserTransaction();
		utx.begin();
	}

	@After
	public void tearDown() throws Exception {
		UserTransaction utx = replicaDB.getUserTransaction();
		utx.rollback();
	}

	@Test
	public final void testGetTablePrint() {
		String actual;

		// null argument
		try {
			SyncDatabaseDAO.getTablePrint(null, null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		}
		try {
			SyncDatabaseDAO.getTablePrint("schema", null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		}

		// normal case
		try {
			// schema and table
			actual = SyncDatabaseDAO.getTablePrint(null, "table");
			assertEquals("table", actual);

			// table only
			actual = SyncDatabaseDAO.getTablePrint("schema", "table");
			assertEquals("schema.table", actual);
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetSubscription() {
		String actual;
		Subscription subs;

		// null argument
		try {
			SyncDatabaseDAO.getSubscription(replicaConn, null, "table");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.getSubscription(replicaConn, "schema", null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.getSubscription(null, "schema", "table");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		} catch (SQLException e) {
			fail("other exception thrown");
		}

		// not found
		try {
			SyncDatabaseDAO.getSubscription(replicaConn, "public", "no_table");
			fail("no exception");
		} catch (SQLException e1) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("public.no_table has no subscription", actual);
		}

		// normal case
		try {
			subs = SyncDatabaseDAO.getSubscription(replicaConn, "public",
					"rep_tab1");
			assertNotNull(subs);
			assertEquals("public", subs.getSchema());
			assertEquals("rep_tab1", subs.getTable());
			assertEquals(1, subs.getSubsID());
			assertEquals("postgres1", subs.getSrvname());
			assertEquals("SELECT * FROM public.tab1", subs.getQuery());
			assertNull(subs.getLastTime());
			assertNull(subs.getLastType());
			assertEquals("public.rep_tab1", subs.getReplicaTable());
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetSubscription() {
		String actual;
		Subscription setSubs = new Subscription("public", "rep_tab1",
				"replicaTable", "attachuser", 1, "srvname", "query", Timestamp
						.valueOf("2010-01-01 12:34:56"), "F");

		// null argument
		try {
			SyncDatabaseDAO.setSubscription(null, null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.setSubscription(replicaConn, null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.setSubscription(null, setSubs);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		} catch (SQLException e) {
			fail("other exception thrown");
		}

		// normal case
		Subscription subs = null;
		try {
			SyncDatabaseDAO.setSubscription(replicaConn, setSubs);

			subs = SyncDatabaseDAO.getSubscription(replicaConn, "public",
					"rep_tab1");
			assertNotNull(subs);
			assertEquals("public", subs.getSchema());
			assertEquals("rep_tab1", subs.getTable());
			assertEquals(1, subs.getSubsID());
			assertEquals("postgres1", subs.getSrvname());
			assertEquals("SELECT * FROM public.tab1", subs.getQuery());
			assertFalse(Timestamp.valueOf("2010-01-01 12:34:56").equals(
					subs.getLastTime()));
			assertEquals("F", subs.getLastType());
			assertEquals("public.rep_tab1", subs.getReplicaTable());
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetSubscriber() {
		String actual;
		Subscriber suber;

		// null argument
		try {
			SyncDatabaseDAO.getSubscriber(null, 1);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		} catch (SQLException e) {
			fail("other exception thrown");
		}

		// not found
		try {
			SyncDatabaseDAO.getSubscriber(masterConn, 123);
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("not found subscriber id 123", actual);
		}

		// normal case
		try {
			suber = SyncDatabaseDAO.getSubscriber(masterConn, 1);
			assertNotNull(suber);
			assertEquals(1, suber.getSubsID());
			assertEquals("public.tab1", suber.getMasterTableName());
			assertEquals("mlog.mlog$", suber.getMlogName().substring(0, 10));
			assertEquals("description1", suber.getDescription());
			assertEquals(Timestamp.valueOf("2010-01-01 12:34:56"), suber
					.getLastTime());
			assertNull(suber.getLastType());
			assertEquals(-1, suber.getLastMlogID());
			assertEquals(-1, suber.getLastCount());
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetSubscriber() {
		String actual;
		Subscriber setSuber = new Subscriber(1, "nspName", "relName",
				"masterTableName", "mlogName", "createUser", "attachUser",
				"description", Timestamp.valueOf("2010-01-01 12:34:56"), "F",
				456, 789);

		// null argument
		try {
			SyncDatabaseDAO.setSubscriber(masterConn, null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.setSubscriber(null, setSuber);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		} catch (SQLException e) {
			fail("other exception thrown");
		}

		// normal case
		Subscriber suber = null;
		try {
			setSuber.setSubsID(1);
			SyncDatabaseDAO.setSubscriber(masterConn, setSuber);

			suber = SyncDatabaseDAO.getSubscriber(masterConn, 1);
			assertNotNull(suber);
			assertEquals(1, suber.getSubsID());
			assertEquals("public.tab1", suber.getMasterTableName());
			assertEquals("mlog.mlog$", suber.getMlogName().substring(0, 10));
			assertEquals("description1", suber.getDescription());
			assertFalse(Timestamp.valueOf("2010-01-01 12:34:56").equals(
					suber.getLastTime()));
			assertEquals("F", suber.getLastType());
			assertEquals(456, suber.getLastMlogID());
			assertEquals(789, suber.getLastCount());
		} catch (Exception e) {
			e.printStackTrace();
			fail("exception thrown");
		}

		// not found
		try {
			setSuber.setSubsID(99999);
			SyncDatabaseDAO.setSubscriber(masterConn, setSuber);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			fail("other exception thrown");
		} catch (SQLException e) {
			actual = e.getMessage();
			assertEquals(
					"ERROR: subsid(99999) is not found in the mlog.subscriber",
					actual);
		}
	}

	@Test
	public final void testGetMasterStatus() {
		// argument error
		try {
			SyncDatabaseDAO.getMasterStatus(null, null, null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}

		// not specified schema and table
		try {
			UserTransaction utx = replicaDB.getUserTransaction();
			utx.rollback();

			ArrayList<MasterStatus> masters = SyncDatabaseDAO.getMasterStatus(
					masterConn, null, null);
			assertNotNull(masters);
			assertEquals(13, masters.size());

			int i = 0;
			MasterStatus status = masters.get(i++);
			assertEquals("public", status.getSchema());
			assertEquals("attach1", status.getTable());
			assertEquals(0, status.getLogCount());
			assertEquals(1, status.getSubscribers());
			assertEquals(Timestamp.valueOf("2010-01-01 12:34:56"), status
					.getOldestRefresh());
			assertEquals("desc attach1", status.getOldestReplica());

			status = masters.get(i++);
			assertEquals("bar", status.getTable());
			assertEquals(0, status.getLogCount());
			assertEquals(1, status.getSubscribers());

			status = masters.get(i++);
			assertEquals("ccc", status.getTable());
			assertEquals(1, status.getLogCount());
			assertEquals(1, status.getSubscribers());

			status = masters.get(i++);
			assertEquals("detach1", status.getTable());
			assertEquals(-1, status.getLogCount());
			assertEquals(0, status.getSubscribers());

			status = masters.get(i++);
			assertEquals("detach2", status.getTable());
			assertEquals(0, status.getLogCount());
			assertEquals(1, status.getSubscribers());

			status = masters.get(i++);
			assertEquals("detach3", status.getTable());
			assertEquals(0, status.getLogCount());
			assertEquals(1, status.getSubscribers());

			status = masters.get(i++);
			assertEquals("drop1", status.getTable());
			assertEquals(0, status.getLogCount());
			assertEquals(1, status.getSubscribers());

			status = masters.get(i++);
			assertEquals("foo", status.getTable());
			assertEquals(27, status.getLogCount());
			assertEquals(2, status.getSubscribers());

			status = masters.get(i++);
			assertEquals("inc", status.getTable());
			assertEquals(20, status.getLogCount());
			assertEquals(2, status.getSubscribers());

			status = masters.get(i++);
			assertEquals("tab1", status.getTable());
			assertEquals(123, status.getLogCount());
			assertEquals(1, status.getSubscribers());

			status = masters.get(i++);
			assertEquals("tab2", status.getTable());
			assertEquals(0, status.getLogCount());
			assertEquals(1, status.getSubscribers());

			status = masters.get(i++);
			assertEquals("foo", status.getTable());
			assertEquals(1, status.getLogCount());
			assertEquals(0, status.getSubscribers());

			status = masters.get(i++);
			assertNull(status.getSchema());
			assertNull(status.getTable());
			assertEquals(-1, status.getLogCount());
			assertEquals(1, status.getSubscribers());
			assertNull(status.getOldestRefresh());
			assertEquals("desc master droped", status.getOldestReplica());

			utx.begin();
		} catch (Exception e) {
			fail("exception thrown");
		}

		// schema specified
		try {
			ArrayList<MasterStatus> masters = SyncDatabaseDAO.getMasterStatus(
					masterConn, "test", null);
			assertNotNull(masters);
			assertEquals(1, masters.size());

			MasterStatus status = masters.get(0);
			assertEquals("test", status.getSchema());
			assertEquals("foo", status.getTable());
			assertEquals(1, status.getLogCount());
			assertEquals(0, status.getSubscribers());
			assertNull(status.getOldestRefresh());
			assertNull(status.getOldestReplica());
		} catch (Exception e) {
			fail("exception thrown");
		}

		// table specified
		try {
			ArrayList<MasterStatus> masters = SyncDatabaseDAO.getMasterStatus(
					masterConn, null, "foo");
			assertNotNull(masters);
			assertEquals(2, masters.size());

			MasterStatus status = masters.get(0);
			assertEquals("public", status.getSchema());
			assertEquals("foo", status.getTable());
			assertEquals(27, status.getLogCount());
			assertEquals(2, status.getSubscribers());
			assertEquals(Timestamp.valueOf("2010-01-01 12:34:56"), status
					.getOldestRefresh());
			assertEquals("postgres2", status.getOldestReplica());

			status = masters.get(1);
			assertEquals("test", status.getSchema());
			assertEquals("foo", status.getTable());
			assertEquals(1, status.getLogCount());
			assertEquals(0, status.getSubscribers());
			assertNull(status.getOldestRefresh());
			assertNull(status.getOldestReplica());
		} catch (Exception e) {
			fail("exception thrown");
		}

		// schema and table specified
		try {
			ArrayList<MasterStatus> masters = SyncDatabaseDAO.getMasterStatus(
					masterConn, "public", "inc");
			assertNotNull(masters);
			assertEquals(1, masters.size());

			MasterStatus status = masters.get(0);
			assertEquals("public", status.getSchema());
			assertEquals("inc", status.getTable());
			assertEquals(20, status.getLogCount());
			assertEquals(2, status.getSubscribers());
			assertEquals(Timestamp.valueOf("2010-01-01 12:34:56"), status
					.getOldestRefresh());
			assertEquals("incremental refresh test table 1", status
					.getOldestReplica());
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetLogCount() {
		UserTransaction utx = null;
		try {
			utx = replicaDB.getUserTransaction();
			utx.rollback();
		} catch (Exception e1) {
			fail("exception thrown");
		}

		long count;
		Subscriber suber1 = null;
		Subscriber suber2 = null;
		try {
			suber1 = SyncDatabaseDAO.getSubscriber(masterConn, 1);
			suber2 = SyncDatabaseDAO.getSubscriber(masterConn, 8);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// argument error
		try {
			SyncDatabaseDAO.getLogCount(null, suber1.getMlogName());
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			count = SyncDatabaseDAO.getLogCount(masterConn, null);
			assertEquals(MasterStatus.INVALID_LOG_COUNT, count);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// not found error
		try {
			count = SyncDatabaseDAO.getLogCount(masterConn, "aaa");
			assertEquals(MasterStatus.INVALID_LOG_COUNT, count);
		} catch (Exception e) {
			fail("exception thrown");
		}
		try {
			count = SyncDatabaseDAO.getLogCount(masterConn, "public.foo");
			assertEquals(MasterStatus.INVALID_LOG_COUNT, count);
		} catch (Exception e) {
			fail("exception thrown");
		}

		// normal case
		try {
			assertNotNull(suber1);
			count = SyncDatabaseDAO.getLogCount(masterConn, suber1
					.getMlogName());
			assertEquals(123, count);
			System.out.println(suber1.getMlogName());
		} catch (Exception e) {
			fail("exception thrown");
		}
		try {
			count = SyncDatabaseDAO.getLogCount(masterConn, suber2
					.getMlogName());
			assertEquals(27, count);
		} catch (Exception e) {
			fail("exception thrown");
		}

		try {
			utx.begin();
		} catch (Exception e1) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testEqualMaster() {
		boolean e;

		e = SyncDatabaseDAO.equalMaster(null, null, null, null);
		assertTrue(e);

		e = SyncDatabaseDAO.equalMaster(null, null, null, "table");
		assertFalse(e);

		e = SyncDatabaseDAO.equalMaster(null, null, "schema", null);
		assertFalse(e);

		e = SyncDatabaseDAO.equalMaster(null, "table", null, null);
		assertFalse(e);

		e = SyncDatabaseDAO.equalMaster("schema", null, null, null);
		assertFalse(e);

		e = SyncDatabaseDAO.equalMaster(null, null, "schema", "table");
		assertFalse(e);

		e = SyncDatabaseDAO.equalMaster(null, "table", null, "table");
		assertTrue(e);

		e = SyncDatabaseDAO.equalMaster(null, "table", null, "table_");
		assertFalse(e);

		e = SyncDatabaseDAO.equalMaster("schema", null, null, "table");
		assertFalse(e);

		e = SyncDatabaseDAO.equalMaster(null, "table", "schema", null);
		assertFalse(e);

		e = SyncDatabaseDAO.equalMaster("schema", null, "schema", null);
		assertTrue(e);

		e = SyncDatabaseDAO.equalMaster("schema", null, "schema_", null);
		assertFalse(e);

		e = SyncDatabaseDAO.equalMaster("schema", "table", null, null);
		assertFalse(e);

		e = SyncDatabaseDAO.equalMaster(null, "table", "schema", "table");
		assertFalse(e);

		e = SyncDatabaseDAO.equalMaster(null, "table", "schema", "table_");
		assertFalse(e);

		e = SyncDatabaseDAO.equalMaster("schema", null, "schema", "table");
		assertFalse(e);

		e = SyncDatabaseDAO.equalMaster("schema", null, "schema_", "table");
		assertFalse(e);

		e = SyncDatabaseDAO.equalMaster("schema", "table", null, "table");
		assertFalse(e);

		e = SyncDatabaseDAO.equalMaster("schema", "table", null, "table_");
		assertFalse(e);

		e = SyncDatabaseDAO.equalMaster("schema", "table", "schema", null);
		assertFalse(e);

		e = SyncDatabaseDAO.equalMaster("schema", "table", "schema_", null);
		assertFalse(e);

		e = SyncDatabaseDAO.equalMaster("schema", "table", "schema", "table");
		assertTrue(e);

		e = SyncDatabaseDAO.equalMaster("schema", "table", "schema_", "table");
		assertFalse(e);

		e = SyncDatabaseDAO.equalMaster("schema", "table", "schema", "table_");
		assertFalse(e);

		e = SyncDatabaseDAO.equalMaster("schema", "table", "schema_", "table_");
		assertFalse(e);
	}

	@Test
	public final void testGetReplicaStatus() {
		// argument error
		try {
			SyncDatabaseDAO.getReplicaStatus(null, null, null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}

		// not specified schema and table
		try {
			ArrayList<ReplicaStatus> replicas = SyncDatabaseDAO
					.getReplicaStatus(replicaConn, null, null);
			assertNotNull(replicas);
			assertEquals(18, replicas.size());

			int i = 0;
			ReplicaStatus replicaStatus = replicas.get(i++);
			assertEquals("public", replicaStatus.getSchema());
			assertEquals("rep_aaa", replicaStatus.getTable());
			assertNull(replicaStatus.getLastRefresh());
			assertEquals("aaa", replicaStatus.getMaster());
			assertEquals(1, replicaStatus.getSubsID());

			replicaStatus = replicas.get(i++);
			assertEquals("rep_bar", replicaStatus.getTable());

			replicaStatus = replicas.get(i++);
			assertEquals("rep_bbb", replicaStatus.getTable());

			replicaStatus = replicas.get(i++);
			assertEquals("rep_ccc", replicaStatus.getTable());

			replicaStatus = replicas.get(i++);
			assertEquals("rep_ddd", replicaStatus.getTable());

			replicaStatus = replicas.get(i++);
			assertEquals("rep_detach1", replicaStatus.getTable());

			replicaStatus = replicas.get(i++);
			assertEquals("rep_detach2", replicaStatus.getTable());

			replicaStatus = replicas.get(i++);
			assertEquals("rep_detach22", replicaStatus.getTable());

			replicaStatus = replicas.get(i++);
			assertEquals("rep_drop1", replicaStatus.getTable());

			replicaStatus = replicas.get(i++);
			assertEquals("rep_eee", replicaStatus.getTable());

			replicaStatus = replicas.get(i++);
			assertEquals("rep_fff", replicaStatus.getTable());

			replicaStatus = replicas.get(i++);
			assertEquals("rep_foo", replicaStatus.getTable());

			replicaStatus = replicas.get(i++);
			assertEquals("rep_foo_inc", replicaStatus.getTable());

			replicaStatus = replicas.get(i++);
			assertEquals("rep_inc1", replicaStatus.getTable());

			replicaStatus = replicas.get(i++);
			assertEquals("rep_inc2", replicaStatus.getTable());

			replicaStatus = replicas.get(i++);
			assertEquals("rep_tab1", replicaStatus.getTable());

			replicaStatus = replicas.get(i++);
			assertEquals("test", replicaStatus.getSchema());
			assertEquals("rep_foo", replicaStatus.getTable());
			assertEquals(Timestamp.valueOf("2010-01-01 12:34:56"),
					replicaStatus.getLastRefresh());
			assertEquals("postgres1", replicaStatus.getMaster());
			assertEquals(9, replicaStatus.getSubsID());
		} catch (Exception e) {
			fail("exception thrown");
		}

		// schema specified
		try {
			ArrayList<ReplicaStatus> replicas = SyncDatabaseDAO
					.getReplicaStatus(replicaConn, "test", null);
			assertNotNull(replicas);
			assertEquals(1, replicas.size());

			ReplicaStatus replicaStatus = replicas.get(0);
			assertEquals("test", replicaStatus.getSchema());
			assertEquals("rep_foo", replicaStatus.getTable());
			assertEquals(Timestamp.valueOf("2010-01-01 12:34:56"),
					replicaStatus.getLastRefresh());
			assertEquals("postgres1", replicaStatus.getMaster());
			assertEquals(9, replicaStatus.getSubsID());
		} catch (Exception e) {
			fail("exception thrown");
		}

		// table specified
		try {
			ArrayList<ReplicaStatus> replicas = SyncDatabaseDAO
					.getReplicaStatus(replicaConn, null, "rep_foo");
			assertNotNull(replicas);
			assertEquals(2, replicas.size());

			ReplicaStatus replicaStatus = replicas.get(0);
			assertEquals("public", replicaStatus.getSchema());
			assertEquals("rep_foo", replicaStatus.getTable());
			assertNull(replicaStatus.getLastRefresh());
			assertEquals("postgres1", replicaStatus.getMaster());
			assertEquals(6, replicaStatus.getSubsID());

			replicaStatus = replicas.get(1);
			assertEquals("test", replicaStatus.getSchema());
			assertEquals("rep_foo", replicaStatus.getTable());
			assertEquals(Timestamp.valueOf("2010-01-01 12:34:56"),
					replicaStatus.getLastRefresh());
			assertEquals("postgres1", replicaStatus.getMaster());
			assertEquals(9, replicaStatus.getSubsID());
		} catch (Exception e) {
			fail("exception thrown");
		}

		// schema and table specified
		try {
			ArrayList<ReplicaStatus> replicas = SyncDatabaseDAO
					.getReplicaStatus(replicaConn, "public", "rep_foo_inc");
			assertNotNull(replicas);
			assertEquals(1, replicas.size());

			ReplicaStatus replicaStatus = replicas.get(0);
			assertEquals("public", replicaStatus.getSchema());
			assertEquals("rep_foo_inc", replicaStatus.getTable());
			assertEquals(Timestamp.valueOf("2010-01-01 12:34:56"),
					replicaStatus.getLastRefresh());
			assertEquals("postgres1", replicaStatus.getMaster());
			assertEquals(8, replicaStatus.getSubsID());
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetMaxMlogID() {
		UserTransaction utx = null;
		try {
			utx = replicaDB.getUserTransaction();
			utx.rollback();
		} catch (Exception e1) {
		}

		String actual;
		long max;

		// null argument
		try {
			SyncDatabaseDAO.getMaxMlogID(null, null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.getMaxMlogID(masterConn, null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.getMaxMlogID(null, "public.tab1");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		} catch (SQLException e) {
			fail("other exception thrown");
		}

		// table not found
		try {
			max = SyncDatabaseDAO.getMaxMlogID(masterConn, "noTable");
			fail("no exception");
		} catch (SQLException e) {
			actual = e.getMessage();
			assertEquals(
					"ERROR: relation \"notable\" does not exist\n  Position: 25",
					actual);
		} catch (SyncDatabaseException e) {
			fail("other exception thrown");
		}

		// not mlog table
		try {
			max = SyncDatabaseDAO.getMaxMlogID(masterConn, "public.tab1");
			fail("no exception");
		} catch (SQLException e) {
			actual = e.getMessage();
			assertEquals(
					"ERROR: column \"mlogid\" does not exist\n  Position: 12",
					actual);
		} catch (SyncDatabaseException e) {
			fail("other exception thrown");
		}

		// log not found
		Subscriber suber = null;
		try {
			suber = SyncDatabaseDAO.getSubscriber(masterConn, 2);
			max = SyncDatabaseDAO.getMaxMlogID(masterConn, suber.getMlogName());
			assertEquals(-1, max);
		} catch (Exception e) {
			e.printStackTrace();
			fail("exception thrown");
		}

		// normal case
		try {
			suber = SyncDatabaseDAO.getSubscriber(masterConn, 1);
			max = SyncDatabaseDAO.getMaxMlogID(masterConn, suber.getMlogName());
			assertEquals(123, max);
		} catch (Exception e) {
			fail("exception thrown");
		}

		try {
			utx.begin();
		} catch (Exception e1) {
		}
	}

	@Test
	public final void testGetPKNames() {
		Hashtable<Short, String> PKNames;

		// argument error
		try {
			SyncDatabaseDAO.getPKNames(null, "public", "foo");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.getPKNames(replicaConn, null, "foo");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.getPKNames(replicaConn, "public", null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}

		// normal case
		try {
			PKNames = SyncDatabaseDAO.getPKNames(masterConn, "public",
					"pk_test");
			assertEquals(3, PKNames.size());
			assertEquals("\"P\"\"K\"\"_3\"\"\"", PKNames.get(Short
					.valueOf((short) 1)));
			assertEquals("\"pK_2\"", PKNames.get(Short.valueOf((short) 2)));
			assertEquals("\"pk_1\"", PKNames.get(Short.valueOf((short) 3)));

			PKNames = SyncDatabaseDAO.getPKNames(oraConn, "SYNCDB", "FOO");
			assertEquals(1, PKNames.size());
			assertEquals("\"VAL1\"", PKNames.get(Short.valueOf((short) 1)));
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetIncrementalRefreshCost() {
		UserTransaction utx = null;
		try {
			utx = replicaDB.getUserTransaction();
			utx.rollback();
		} catch (Exception e1) {
			fail("exception thrown");
		}

		Subscriber suber = null;
		Hashtable<Short, String> pkNames = null;
		try {
			suber = SyncDatabaseDAO.getSubscriber(masterConn, 8);
			pkNames = SyncDatabaseDAO.getPKNames(masterConn,
					suber.getNspName(), suber.getRelName());
		} catch (Exception e) {
			fail("exception thrown");
		}

		// argument error
		try {
			SyncDatabaseDAO.getIncrementalRefreshCost(null,
					suber.getMlogName(), 123, 123, pkNames);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.getIncrementalRefreshCost(masterConn, null, 123,
					123, pkNames);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}

		// not found
		try {
			SyncDatabaseDAO.getIncrementalRefreshCost(masterConn, "aaa", 123,
					123, pkNames);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			fail("other exception thrown");
		} catch (SQLException e) {
			assertEquals("ERROR: relation \"aaa\" does not exist\n"
					+ "  Position: 299", e.getMessage());
		}

		// RANDOM_SCAN_COST test
		SyncDatabaseDAO dao = new SyncDatabaseDAO();
		Double RANDOM_SCAN_COST = (Double) PrivateAccessor.getPrivateField(dao,
				"RANDOM_SCAN_COST");
		assertNotNull(RANDOM_SCAN_COST);
		double randomCost = RANDOM_SCAN_COST.doubleValue();
		assertEquals(150, (int) (randomCost * 100));

		double cost;
		// no refresh
		try {
			cost = SyncDatabaseDAO.getIncrementalRefreshCost(masterConn, suber
					.getMlogName(), -1, 123, pkNames);
			assertTrue(Double.isNaN(cost));
		} catch (Exception e) {
			fail("exception thrown");
		}
		try {
			cost = SyncDatabaseDAO.getIncrementalRefreshCost(masterConn, suber
					.getMlogName(), 123, -1, pkNames);
			assertTrue(Double.isNaN(cost));
		} catch (Exception e) {
			fail("exception thrown");
		}

		// mlog count == 0
		try {
			cost = SyncDatabaseDAO.getIncrementalRefreshCost(masterConn, suber
					.getMlogName(), 28, 10, pkNames);
			assertEquals(0, (int) (cost * 100));
		} catch (Exception e) {
			e.printStackTrace();
			fail("exception thrown");
		}

		// master count == 0
		try {
			cost = SyncDatabaseDAO.getIncrementalRefreshCost(masterConn, suber
					.getMlogName(), 20, 1, pkNames);
			assertTrue(Double.isNaN(cost));
		} catch (Exception e) {
			fail("exception thrown");
		}

		// normal case
		try {
			cost = SyncDatabaseDAO.getIncrementalRefreshCost(masterConn, suber
					.getMlogName(), 18, 79, pkNames);
			assertEquals((int) (12.5 * randomCost), (int) (cost * 100));
		} catch (Exception e) {
			fail("exception thrown");
		}

		// other normal case
		try {
			suber = SyncDatabaseDAO.getSubscriber(masterConn, 6);
			pkNames = SyncDatabaseDAO.getPKNames(masterConn,
					suber.getNspName(), suber.getRelName());
		} catch (Exception e) {
			fail("exception thrown");
		}
		try {
			cost = SyncDatabaseDAO.getIncrementalRefreshCost(masterConn, suber
					.getMlogName(), 5, 9, pkNames);
			assertEquals((int) (100 * randomCost), (int) (cost * 100));

			cost = SyncDatabaseDAO.getIncrementalRefreshCost(masterConn, suber
					.getMlogName(), 10, 10, pkNames);
			assertEquals((int) (100 * randomCost), (int) (cost * 100));

			cost = SyncDatabaseDAO.getIncrementalRefreshCost(masterConn, suber
					.getMlogName(), 15, 5, pkNames);
			assertEquals((int) (100 * randomCost), (int) (cost * 100));

			cost = SyncDatabaseDAO.getIncrementalRefreshCost(masterConn, suber
					.getMlogName(), 20, 3, pkNames);
			assertEquals((int) (100 * randomCost), (int) (cost * 100));
		} catch (Exception e) {
			fail("exception thrown");
		}
		try {
			suber = SyncDatabaseDAO.getSubscriber(masterConn, 7);
			pkNames = SyncDatabaseDAO.getPKNames(masterConn,
					suber.getNspName(), suber.getRelName());
		} catch (Exception e) {
			fail("exception thrown");
		}
		try {
			cost = SyncDatabaseDAO.getIncrementalRefreshCost(masterConn, suber
					.getMlogName(), 15, 6, pkNames);
			assertEquals(120, (int) (cost * 100));

			cost = SyncDatabaseDAO.getIncrementalRefreshCost(masterConn, suber
					.getMlogName(), 15, 7, pkNames);
			assertEquals((int) (100), (int) (cost * 100));

			cost = SyncDatabaseDAO.getIncrementalRefreshCost(masterConn, suber
					.getMlogName(), 15, 8, pkNames);
			assertEquals(85, (int) (cost * 100));
		} catch (Exception e) {
			fail("exception thrown");
		}

		try {
			utx.begin();
		} catch (Exception e1) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testChooseFastestMode() {
		String actual;
		Subscriber suber = null;

		// null argument
		try {
			SyncDatabaseDAO.chooseFastestMode(masterConn, null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.chooseFastestMode(null, suber);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		} catch (SQLException e) {
			fail("other exception thrown");
		}

		RefreshMode mode;
		// FULL refresh
		try {
			suber = SyncDatabaseDAO.getSubscriber(masterConn, 7);
			suber.setLastCount(6);
			mode = SyncDatabaseDAO.chooseFastestMode(masterConn, suber);
			assertEquals(mode, RefreshMode.FULL);

			suber.setLastCount(7);
			mode = SyncDatabaseDAO.chooseFastestMode(masterConn, suber);
			assertEquals(mode, RefreshMode.FULL);
		} catch (Exception e) {
			e.printStackTrace();
			fail("exception thrown");
		}

		// INCREMENTAL refresh
		try {
			suber.setLastCount(8);
			mode = SyncDatabaseDAO.chooseFastestMode(masterConn, suber);
			assertEquals(mode, RefreshMode.INCREMENTAL);
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testPurgeMlog() {
		String actual;

		// null argument
		try {
			SyncDatabaseDAO.purgeMlog(null, "public", "tab1");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.purgeMlog(masterConn, null, "tab1");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.purgeMlog(masterConn, "public", null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		} catch (SQLException e) {
			fail("other exception thrown");
		}

		// table not found
		try {
			SyncDatabaseDAO.purgeMlog(masterConn, "public", "noTable");
			fail("no exception");
		} catch (SQLException e) {
			actual = e.getMessage();
			assertEquals("ERROR: relation \"public.noTable\" does not exist\n"
					+ "  Where: PL/pgSQL function \"purge_mlog\" "
					+ "line 11 at assignment", actual);
		} catch (SyncDatabaseException e) {
			fail("other exception thrown");
		}

		UserTransaction utx = null;
		try {
			utx = replicaDB.getUserTransaction();
			utx.rollback();
			utx.begin();
		} catch (Exception e1) {
		}

		// normal case
		Statement stmt = null;
		ResultSet rset = null;
		try {
			Subscriber suber = SyncDatabaseDAO.getSubscriber(masterConn, 6);
			int beforeCount = 0;
			int afterCount = 0;

			stmt = masterConn.createStatement();
			rset = stmt.executeQuery("SELECT count(*) FROM "
					+ suber.getMlogName());
			assertTrue(rset.next());
			beforeCount = rset.getInt(1);

			SyncDatabaseDAO.purgeMlog(masterConn, suber.getNspName(), suber
					.getRelName());

			rset.close();
			rset = stmt.executeQuery("SELECT count(*) FROM "
					+ suber.getMlogName());
			assertTrue(rset.next());
			afterCount = rset.getInt(1);
			rset.close();
			stmt.close();

			assertEquals(20, beforeCount);
			assertEquals(15, afterCount);
		} catch (Exception e) {
			e.printStackTrace();
			fail("exception thrown");
		}
	}

	@Test
	public final void testTruncate() {
		String actual;

		// null argument
		try {
			SyncDatabaseDAO.truncate(null, null, true);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.truncate(replicaConn, null, true);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.truncate(null, "rep_tab1", true);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		} catch (SQLException e) {
			fail("other exception thrown");
		}

		Statement stmt = null;
		ResultSet rset = null;
		UserTransaction utx = null;

		// normal case
		try {
			utx = replicaDB.getUserTransaction();

			int beforeCount = 0;
			int afterCount = 0;

			stmt = replicaConn.createStatement();
			rset = stmt.executeQuery("SELECT count(*) FROM public.rep_tab1");
			assertTrue(rset.next());
			beforeCount = rset.getInt(1);

			// DELETE
			rset.close();
			rset = stmt.executeQuery("SELECT relfilenode FROM "
					+ "pg_catalog.pg_class WHERE relname = 'rep_tab1'");
			assertTrue(rset.next());
			String beforeFilenode = rset.getString(1);

			SyncDatabaseDAO.truncate(replicaConn, "public.rep_tab1", true);
			rset.close();
			rset = stmt.executeQuery("SELECT count(*) FROM public.rep_tab1");
			assertTrue(rset.next());
			afterCount = rset.getInt(1);

			assertEquals(3, beforeCount);
			assertEquals(0, afterCount);

			rset.close();
			rset = stmt.executeQuery("SELECT relfilenode FROM "
					+ "pg_catalog.pg_class WHERE relname = 'rep_tab1'");
			assertTrue(rset.next());
			String afterFilenode = rset.getString(1);
			assertTrue(beforeFilenode.equals(afterFilenode));

			utx.rollback();
			utx.begin();

			// TRUNCATE
			rset.close();
			rset = stmt.executeQuery("SELECT relfilenode FROM "
					+ "pg_catalog.pg_class WHERE relname = 'rep_tab1'");
			assertTrue(rset.next());
			beforeFilenode = rset.getString(1);

			rset.close();
			rset = stmt.executeQuery("SELECT count(*) FROM public.rep_tab1");
			if (rset.next())
				beforeCount = rset.getInt(1);
			else
				fail("SELECT error");

			SyncDatabaseDAO.truncate(replicaConn, "public.rep_tab1", false);
			rset.close();
			rset = stmt.executeQuery("SELECT count(*) FROM public.rep_tab1");
			if (rset.next())
				afterCount = rset.getInt(1);
			else
				fail("SELECT error");

			assertEquals(3, beforeCount);
			assertEquals(0, afterCount);

			rset.close();
			rset = stmt.executeQuery("SELECT relfilenode FROM "
					+ "pg_catalog.pg_class WHERE relname = 'rep_tab1'");
			assertTrue(rset.next());
			afterFilenode = rset.getString(1);
			assertFalse(beforeFilenode.endsWith(afterFilenode));
		} catch (Exception e) {
			fail("exception thrown");
		} finally {
			try {
				if (rset != null)
					rset.close();
				if (stmt != null)
					stmt.close();
			} catch (SQLException e) {
				fail("exception thrown");
			}
		}
	}

	@Test
	public final void testQuoteIdent() {
		String actual;
		try {
			actual = SyncDatabaseDAO.quoteIdent("\"", "a a a");
			assertEquals("\"a a a\"", actual);

			actual = SyncDatabaseDAO.quoteIdent("\"", "A A A");
			assertEquals("\"A A A\"", actual);

			actual = SyncDatabaseDAO.quoteIdent("\"", "a\"A\"a");
			assertEquals("\"a\"\"A\"\"a\"", actual);

			actual = SyncDatabaseDAO.quoteIdent(" ", "a\"A\"a");
			assertEquals("a\"A\"a", actual);
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSubscribeMlog() {
		UserTransaction utx = null;

		// argument test
		try {
			utx = replicaDB.getUserTransaction();
			SyncDatabaseDAO.subscribeMlog(null, "public", "foo", "description");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (Exception e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.subscribeMlog(masterConn, null, "foo",
					"description");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.subscribeMlog(masterConn, "public", null,
					"description");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}

		// not found
		try {
			SyncDatabaseDAO.subscribeMlog(masterConn, "public", "xxx",
					"description");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			fail("other exception thrown");
		} catch (SQLException e) {
			assertEquals(
					"ERROR: relation \"public.xxx\" does not exist\n"
							+ "  Where: PL/pgSQL function \"subscribe_mlog\" line 7 at assignment",
					e.getMessage());
		}

		try {
			utx.rollback();
			utx.begin();
			Statement stmt = masterConn.createStatement();
			ResultSet rset = stmt
					.executeQuery("SELECT setval('mlog.subscriber_subsid_seq', 100)");
			rset.close();
			stmt.close();
		} catch (Exception e1) {
			fail("exception thrown");
		}

		// normal case
		try {
			long subsid = SyncDatabaseDAO.subscribeMlog(masterConn, "public",
					"attach1", "description attach test");
			assertEquals(101, subsid);

			Subscriber suber = SyncDatabaseDAO
					.getSubscriber(masterConn, subsid);
			assertNotNull(suber);
			assertEquals("syncdbuser", suber.getAttachUser());
			assertEquals("description attach test", suber.getDescription());
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSubscribeObserver() {
		UserTransaction utx = null;

		// argument test
		try {
			utx = replicaDB.getUserTransaction();
			SyncDatabaseDAO.subscribeObserver(null, "public", "rep_attach1",
					101, "attach1", "SELECT * FROM attach1");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (Exception e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.subscribeObserver(replicaConn, null, "rep_attach1",
					101, "attach1", "SELECT * FROM attach1");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.subscribeObserver(replicaConn, "public", null, 101,
					"attach1", "SELECT * FROM attach1");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.subscribeObserver(replicaConn, "public",
					"rep_attach1", 101, null, "SELECT * FROM attach1");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.subscribeObserver(replicaConn, "public",
					"rep_attach1", 101, "attach1", null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}

		// not found
		try {
			SyncDatabaseDAO.subscribeObserver(replicaConn, "public", "xxx",
					101, "attach1", "SELECT * FROM attach1");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			fail("other exception thrown");
		} catch (SQLException e) {
			assertEquals(
					"ERROR: relation \"public.xxx\" does not exist\n"
							+ "  Where: PL/pgSQL function \"subscribe\" line 13 at assignment",
					e.getMessage());
		}

		try {
			utx.rollback();
			utx.begin();
		} catch (Exception e1) {
			fail("exception thrown");
		}

		// normal case
		try {
			SyncDatabaseDAO.subscribeObserver(replicaConn, "public",
					"rep_attach1", 101, "postgres1", "SELECT * FROM attach1");

			Subscription subs = SyncDatabaseDAO.getSubscription(replicaConn,
					"public", "rep_attach1");
			assertNotNull(subs);
			assertEquals("syncdbuser", subs.getAttachuser());
			assertEquals(101, subs.getSubsID());
			assertEquals("postgres1", subs.getSrvname());
			assertEquals("SELECT * FROM attach1", subs.getQuery());
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testUnSubscribeMlog() {
		String actual;
		UserTransaction utx = null;

		// argument test
		try {
			utx = replicaDB.getUserTransaction();
			SyncDatabaseDAO.unSubscribeMlog(null, 200);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (Exception e) {
			fail("other exception thrown");
		}

		// not found
		try {
			SyncDatabaseDAO.unSubscribeMlog(masterConn, 200);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			fail("other exception thrown");
		} catch (SQLException e) {
			assertEquals(
					"ERROR: subsid(200) is not found in the mlog.subscriber", e
							.getMessage());
		}

		try {
			utx.rollback();
			utx.begin();
		} catch (Exception e1) {
			fail("exception thrown");
		}

		// normal case
		try {
			SyncDatabaseDAO.unSubscribeMlog(masterConn, 12);
		} catch (Exception e) {
			fail("exception thrown");
		}
		try {
			SyncDatabaseDAO.getSubscriber(masterConn, 12);
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("not found subscriber id 12", actual);
		}
	}

	@Test
	public final void testCreateMlog() {
		UserTransaction utx = null;

		// argument test
		try {
			utx = replicaDB.getUserTransaction();
			SyncDatabaseDAO.createMlog(null, "public", "create1");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (Exception e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.createMlog(masterConn, null, "create1");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.createMlog(masterConn, "public", null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}

		// exist
		try {
			SyncDatabaseDAO.createMlog(masterConn, "public", "xxx");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			fail("other exception thrown");
		} catch (SQLException e) {
			assertEquals(
					"ERROR: relation \"public.xxx\" does not exist\n"
							+ "  Where: PL/pgSQL function \"create_mlog\" line 19 at assignment",
					e.getMessage());
		}

		try {
			utx.rollback();
			utx.begin();
		} catch (Exception e1) {
			fail("exception thrown");
		}

		// normal case
		try {
			SyncDatabaseDAO.createMlog(masterConn, "public", "create1");

			ArrayList<MasterStatus> status = SyncDatabaseDAO.getMasterStatus(
					masterConn, "public", "create1");
			assertEquals(1, status.size());
		} catch (Exception e1) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testDropMlog() {
		UserTransaction utx = null;

		// argument test
		try {
			utx = replicaDB.getUserTransaction();
			SyncDatabaseDAO.dropMlog(null, "public", "drop1");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (Exception e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.dropMlog(masterConn, null, "drop1");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.dropMlog(masterConn, "public", null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}

		// not found
		try {
			SyncDatabaseDAO.dropMlog(masterConn, "public", "xxx");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			fail("other exception thrown");
		} catch (SQLException e) {
			assertEquals(
					"ERROR: relation \"public.xxx\" does not exist\n"
							+ "  Where: PL/pgSQL function \"drop_mlog\" line 9 at assignment",
					e.getMessage());
		}

		try {
			utx.rollback();
			utx.begin();
		} catch (Exception e1) {
			fail("exception thrown");
		}

		// normal case
		try {
			SyncDatabaseDAO.dropMlog(masterConn, "public", "drop1");

			ArrayList<MasterStatus> status = SyncDatabaseDAO.getMasterStatus(
					masterConn, "public", "drop1");
			assertEquals(0, status.size());
		} catch (Exception e1) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testUnSubscribeObserver() {
		String actual;
		UserTransaction utx = null;

		// argument test
		try {
			utx = replicaDB.getUserTransaction();
			SyncDatabaseDAO.unSubscribeObserver(null, "public", "rep_attach2");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SystemException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.unSubscribeObserver(replicaConn, null,
					"rep_attach2");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}
		try {
			SyncDatabaseDAO.unSubscribeObserver(replicaConn, "public", null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}

		// not found
		try {
			SyncDatabaseDAO.unSubscribeObserver(replicaConn, "public", "xxx");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			fail("other exception thrown");
		} catch (SQLException e) {
			assertEquals(
					"ERROR: relation \"public.xxx\" does not exist\n"
							+ "  Where: PL/pgSQL function \"unsubscribe\" line 7 at assignment",
					e.getMessage());
		}

		try {
			utx.rollback();
			utx.begin();
		} catch (Exception e1) {
			fail("exception thrown");
		}

		// normal case
		try {
			SyncDatabaseDAO.unSubscribeObserver(replicaConn, "public",
					"rep_detach1");

			SyncDatabaseDAO.getSubscription(replicaConn, "public",
					"rep_detach1");
			fail("no exception");
		} catch (SQLException e) {
			fail("other exception thrown");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("public.rep_detach1 has no subscription", actual);
		}
	}

	@Test
	public final void testGetDescription() {
		// null argument
		try {
			SyncDatabaseDAO.getDescription(null, "postgres");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		} catch (SQLException e) {
			fail("other exception thrown");
		}

		// normal case
		try {
			String actual = SyncDatabaseDAO.getDescription(masterConn,
					"postgres1");
			assertNotNull(actual);
			assertTrue(actual
					.matches("resource name:\"postgres1\", DBMS:\"PostgreSQL\", URL:\"jdbc:postgresql://.+"));

			actual = SyncDatabaseDAO.getDescription(replicaConn, "postgres2");
			assertNotNull(actual);
			assertTrue(actual
					.matches("resource name:\"postgres2\", DBMS:\"PostgreSQL\", URL:\"jdbc:postgresql://.+"));

			actual = SyncDatabaseDAO.getDescription(oraConn, "oracle");
			assertNotNull(actual);
			assertTrue(actual
					.matches("resource name:\"oracle\", DBMS:\"Oracle\", URL:\"jdbc:oracle:thin:@.+"));
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testLockTable() {
		// argument error
		try {
			SyncDatabaseDAO.lockTable(null, "public.foo");
			fail("no exception");
		} catch (Exception e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			SyncDatabaseDAO.lockTable("postgres1", null);
			fail("no exception");
		} catch (Exception e) {
			assertEquals("argument error", e.getMessage());
		}

		// resource name error
		try {
			SyncDatabaseDAO.lockTable("aaa", "public.foo");
			fail("no exception");
		} catch (Exception e) {
			assertEquals("resource aaa not found", e.getMessage());
		}

		// class not found error
		try {
			SyncDatabaseDAO.lockTable("testName", "public.foo");
			fail("no exception");
		} catch (Exception e) {
			assertEquals("testClassName", e.getMessage());
		}

		// normal case
		try {
			Connection conn = SyncDatabaseDAO.lockTable("postgres1",
					"public.foo");
			assertFalse(conn.getAutoCommit());
			Statement stmt = conn.createStatement();
			ResultSet rset = stmt.executeQuery("SELECT count(*) FROM pg_locks "
					+ "WHERE relation = 'public.foo'::regclass "
					+ "AND mode = 'ShareLock' " + "AND locktype = 'relation'");
			assertTrue(rset.next());
			assertEquals(1, rset.getInt(1));
			rset.close();
			stmt.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
