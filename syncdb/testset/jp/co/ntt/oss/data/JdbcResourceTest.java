package jp.co.ntt.oss.data;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.fail;
import jp.co.ntt.oss.data.JdbcResource;

import org.junit.Test;

public class JdbcResourceTest {

	@Test
	public final void testGetName() {
		try {
			JdbcResource resource = JdbcResource.getJdbcResource(
					"jdbcResource.xml", "testName");
			assertEquals("testName", resource.getName());
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetName() {
		try {
			JdbcResource resource = JdbcResource.getJdbcResource(
					"jdbcResource.xml", "testName");
			resource.setName("aaa");
			assertEquals("aaa", resource.getName());
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetClassName() {
		try {
			JdbcResource resource = JdbcResource.getJdbcResource(
					"jdbcResource.xml", "testName");
			assertEquals("testClassName", resource.getClassName());
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetClassName() {
		try {
			JdbcResource resource = JdbcResource.getJdbcResource(
					"jdbcResource.xml", "testName");
			resource.setClassName("bbb");
			assertEquals("bbb", resource.getClassName());
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetUrl() {
		try {
			JdbcResource resource = JdbcResource.getJdbcResource(
					"jdbcResource.xml", "testName");
			assertEquals("testUrl", resource.getUrl());
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetUrl() {
		try {
			JdbcResource resource = JdbcResource.getJdbcResource(
					"jdbcResource.xml", "testName");
			resource.setUrl("ccc");
			assertEquals("ccc", resource.getUrl());
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetUsername() {
		try {
			JdbcResource resource = JdbcResource.getJdbcResource(
					"jdbcResource.xml", "testName");
			assertEquals("testUsername", resource.getUsername());
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetUsername() {
		try {
			JdbcResource resource = JdbcResource.getJdbcResource(
					"jdbcResource.xml", "testName");
			resource.setUsername("ddd");
			assertEquals("ddd", resource.getUsername());
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetPassword() {
		try {
			JdbcResource resource = JdbcResource.getJdbcResource(
					"jdbcResource.xml", "testName");
			assertEquals("testPassword", resource.getPassword());
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetPassword() {
		try {
			JdbcResource resource = JdbcResource.getJdbcResource(
					"jdbcResource.xml", "testName");
			resource.setPassword("eee");
			assertEquals("eee", resource.getPassword());
		} catch (Exception e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetServer() {
		JdbcResource resource = null;

		// normal case
		try {
			resource = JdbcResource.getJdbcResource("jdbcResource.xml",
					"testName");
			assertNotNull(resource);
			assertEquals("testName", resource.getName());
		} catch (Exception e) {
			fail("exception thrown");
		}

		// not exist filename
		try {
			resource = JdbcResource.getJdbcResource("jdbcResource.xm",
					"testName");
			fail("no exception");
		} catch (Exception e) {
			assertEquals("resource file jdbcResource.xm not found", e
					.getMessage());
		}

		// format error xml file
		try {
			resource = JdbcResource.getJdbcResource("jdbcResourceNG.xml",
					"testName");
			fail("no exception");
		} catch (Exception e) {
			assertEquals("resource testName not found", e.getMessage());
		}

		// not exist resource name
		try {
			resource = JdbcResource.getJdbcResource("jdbcResource.xml",
					"noName");
			fail("no exception");
		} catch (Exception e) {
			assertEquals("resource noName not found", e.getMessage());
		}

		// null argument
		try {
			resource = JdbcResource.getJdbcResource(null, "testName");
			fail("no exception");
		} catch (Exception e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			resource = JdbcResource.getJdbcResource("jdbcResource.xml", null);
			fail("no exception");
		} catch (Exception e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			resource = JdbcResource.getJdbcResource(null, null);
			fail("no exception");
		} catch (Exception e) {
			assertEquals("argument error", e.getMessage());
		}
	}

}
