package jp.co.ntt.oss.data;

import java.util.ArrayList;
import java.util.List;

public class JdbcResources {
	private final List<JdbcResource> jdbcResources = new ArrayList<JdbcResource>();

	public final void addJdbcResources(final JdbcResource jdbcResource) {
		jdbcResources.add(jdbcResource);
	}

	public final List<JdbcResource> getJdbcResources() {
		return jdbcResources;
	}
}
