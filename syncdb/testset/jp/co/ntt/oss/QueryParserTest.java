package jp.co.ntt.oss;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.fail;

import java.util.Hashtable;

import jp.co.ntt.oss.utility.PrivateAccessor;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class QueryParserTest {

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
	public final void testQueryParser() {
		QueryParser parser = null;

		// argument error
		try {
			new QueryParser(null, "\"");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			new QueryParser("SELECT * FROM foo", null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			new QueryParser("", "\"");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			new QueryParser("SELECT * FROM foo", "");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			new QueryParser("SELECT * FROM foo", "\"\"");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}

		// normal case
		try {
			parser = new QueryParser("SELECT * FROM foo", "\"");
			Character quoteChar = (Character) PrivateAccessor.getPrivateField(
					parser, "quoteChar");
			assertNotNull(quoteChar);
			assertEquals('"', quoteChar.charValue());
			String query = (String) PrivateAccessor.getPrivateField(parser,
					"query");
			assertNotNull(query);
			assertEquals("SELECT * FROM foo", query);
		} catch (SyncDatabaseException e) {
			assertEquals("syntax error", e.getMessage());
		}
	}

	@Test
	public final void testParseFull() {
		QueryParser parser = null;

		// SELECT error
		try {
			parser = new QueryParser("INSERT INTO foo VALUES(1)", "\"");
			parser.parseFull();
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals(
					"refresh query syntax error at 'INSERT INTO foo VALUES(1)'",
					e.getMessage());
		}
		try {
			parser = new QueryParser("WITH SELECT * FROM public.foo", "\"");
			parser.parseFull();
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals(
					"refresh query syntax error at 'WITH SELECT * FROM public.foo'",
					e.getMessage());
		}

		// normal case
		try {
			parser = new QueryParser("SELECT 1,2,3 FROM \"public\".\"foo\"",
					"\"");
			parser.parseFull();

			String schema = (String) PrivateAccessor.getPrivateField(parser,
					"schema");
			assertNull(schema);

			String table = (String) PrivateAccessor.getPrivateField(parser,
					"table");
			assertNull(table);
		} catch (SyncDatabaseException e) {
			assertEquals("syntax error at ' SELECT  FROM public.foo'", e
					.getMessage());
		}
	}

	@Test
	public final void testParseIncremental() {
		QueryParser parser = null;

		// SELECT error
		try {
			parser = new QueryParser("INSERT INTO foo VALUES(1)", "\"");
			parser.parseIncremental();
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals(
					"refresh query syntax error at 'INSERT INTO foo VALUES(1)'",
					e.getMessage());
		}
		try {
			parser = new QueryParser("WITH SELECT * FROM public.foo", "\"");
			parser.parseIncremental();
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals(
					"refresh query syntax error at 'WITH SELECT * FROM public.foo'",
					e.getMessage());
		}

		// FROM error
		try {
			parser = new QueryParser("SELECT * FROMA public.foo", "\"");
			parser.parseIncremental();
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals(
					"incremental refresh query syntax error at 'SELECT * FROMA public.foo'",
					e.getMessage());
		}
		try {
			parser = new QueryParser("SELECT * FRO public.foo", "\"");
			parser.parseIncremental();
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals(
					"incremental refresh query syntax error at 'SELECT * FRO public.foo'",
					e.getMessage());
		}
		try {
			parser = new QueryParser("SELECT FROM public.foo", "\"");
			parser.parseIncremental();
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals(
					"incremental refresh query syntax error at 'SELECT FROM public.foo'",
					e.getMessage());
		}
		try {
			parser = new QueryParser("SELECT * FROM", "\"");
			parser.parseIncremental();
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals(
					"incremental refresh query syntax error at 'SELECT * FROM'",
					e.getMessage());
		}

		// schema error
		try {
			parser = new QueryParser("SELECT * FROM \"public\"", "\"");
			parser.parseIncremental();
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals(
					"incremental refresh query syntax error at 'SELECT * FROM \"public\"'",
					e.getMessage());
		}

		// table error
		try {
			parser = new QueryParser("SELECT * FROM \"public\".   ", "\"");
			parser.parseIncremental();
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals(
					"incremental refresh query syntax error at 'SELECT * FROM \"public\".   '",
					e.getMessage());
		}
		// WHERE clause error
		try {
			parser = new QueryParser(
					"SELECT * FROM \"public\".\"foo\" WHERE id = 1", "\"");
			parser.parseIncremental();
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals(
					"incremental refresh query syntax error at 'SELECT * FROM \"public\".\"foo\" WHERE id = 1'",
					e.getMessage());
		}

		// schema quoted identifier error
		try {
			parser = new QueryParser("SELECT * FROM public.foo", "\"");
			parser.parseIncremental();
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("schema name is specified in quoted identifier", e
					.getMessage());
		}

		// table quoted identifier error
		try {
			parser = new QueryParser("SELECT * FROM \"public\".foo", "\"");
			parser.parseIncremental();
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("table name is specified in quoted identifier", e
					.getMessage());
		}

		// identifier error
		// * only
		try {
			parser = new QueryParser("SELECT *  	", "\"");
			parser.parseIncremental();
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("refresh query syntax error at 'SELECT *  	'", e
					.getMessage());
		}
		// column name continues after *
		try {
			parser = new QueryParser("SELECT *.id FROM \"public\".\"foo\"",
					"\"");
			parser.parseIncremental();
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals(
					"refresh query syntax error at 'SELECT *.id FROM \"public\".\"foo\"'",
					e.getMessage());
		}
		// no space after *
		try {
			parser = new QueryParser("SELECT *FROM \"public\".\"foo\"", "\"");
			parser.parseIncremental();
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals(
					"refresh query syntax error at 'SELECT *FROM \"public\".\"foo\"'",
					e.getMessage());
		}
		// no close quoted identifier
		try {
			parser = new QueryParser("SELECT * FROM \"public\".\"foo", "\"");
			parser.parseIncremental();
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals(
					"refresh query syntax error at 'SELECT * FROM \"public\".\"foo'",
					e.getMessage());
		}
		// zero length identifier
		try {
			parser = new QueryParser("SELECT * FROM \"public\".\"\"", "\"");
			parser.parseIncremental();
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals(
					"refresh query syntax error at 'SELECT * FROM \"public\".\"\"'",
					e.getMessage());
		}

		// normal case
		try {
			parser = new QueryParser("SELECT * FROM \"public\".\"foo\"", "\"");
			parser.parseIncremental();

			String schema = (String) PrivateAccessor.getPrivateField(parser,
					"schema");
			assertNotNull(schema);
			assertEquals("public", schema);

			String table = (String) PrivateAccessor.getPrivateField(parser,
					"table");
			assertNotNull(table);
			assertEquals("foo", table);
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testParseDescription() {
		QueryParser parser = null;
		Hashtable<String, String> description = null;
		// SELECT error
		try {
			parser = new QueryParser(
					"resource name:\"postgres\", DBMS:\"PostgreSQL\", URL:\"jdbc:postgresql://localhost:5432/syncdb\"",
					"\"");
			description = parser.parseDescription();
			assertNotNull(description);
			assertEquals(3, description.size());
			assertEquals("postgres", description.get("resource name"));
			assertEquals("PostgreSQL", description.get("DBMS"));
			assertEquals("jdbc:postgresql://localhost:5432/syncdb", description
					.get("URL"));
		} catch (SyncDatabaseException e) {
			assertEquals(
					"refresh query syntax error at 'INSERT INTO foo VALUES(1)'",
					e.getMessage());
		}
	}

	@Test
	public final void testGetSchema() {
		QueryParser parser = null;

		try {
			parser = new QueryParser("SELECT 1", "\"");
			assertNull(parser.getSchema());

			parser.parseFull();
			assertNull(parser.getSchema());

			parser = new QueryParser(
					"SELECT * FROM \"p\\UbLi\"\"c\".\"f\\O\"\"o\"", "\"");
			assertNull(parser.getSchema());

			parser.parseIncremental();
			assertEquals("p\\UbLi\"c", parser.getSchema());
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetTable() {
		QueryParser parser = null;

		try {
			parser = new QueryParser("SELECT 1", "\"");
			assertNull(parser.getTable());

			parser.parseFull();
			assertNull(parser.getTable());

			parser = new QueryParser(
					"SELECT * FROM \"p\\UbLi\"\"c\".\"f\\O\"\"o\"", "\"");
			assertNull(parser.getTable());

			parser.parseIncremental();
			assertEquals("f\\O\"o", parser.getTable());
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}
	}
}
