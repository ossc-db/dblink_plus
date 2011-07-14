package jp.co.ntt.oss.data;

import static org.junit.Assert.assertEquals;

import java.util.List;

import org.junit.Before;
import org.junit.Test;

public class JdbcResourcesTest {
	JdbcResources jdbcResources;

	@Before
	public void setUp() throws Exception {
		jdbcResources = new JdbcResources();
	}

	@Test
	public final void testAddJdbcResources() {
		jdbcResources.addJdbcResources(new JdbcResource());
		jdbcResources.addJdbcResources(new JdbcResource());
		jdbcResources.addJdbcResources(new JdbcResource());
	}

	@Test
	public final void testGetJdbcResources() {
		JdbcResource jdbcResource;

		jdbcResource = new JdbcResource();
		jdbcResource.setName("jdbcResource1");
		jdbcResources.addJdbcResources(jdbcResource);
		jdbcResource = new JdbcResource();
		jdbcResource.setName("jdbcResource2");
		jdbcResources.addJdbcResources(jdbcResource);
		jdbcResource = new JdbcResource();
		jdbcResource.setName("jdbcResource3");
		jdbcResources.addJdbcResources(jdbcResource);

		List<JdbcResource> list = jdbcResources.getJdbcResources();
		assertEquals(3, list.size());
		int i = 1;
		for (JdbcResource jr : list) {
			assertEquals("jdbcResource" + i, jr.getName());
			i++;
		}
	}

}
