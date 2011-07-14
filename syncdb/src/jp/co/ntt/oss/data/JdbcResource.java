package jp.co.ntt.oss.data;

import java.io.IOException;
import java.io.InputStream;

import jp.co.ntt.oss.SyncDatabaseException;

import org.apache.commons.digester.Digester;

public class JdbcResource {
	private String name;
	private String className;
	private String url;
	private String username;
	private String password;

	public final String getName() {
		return name;
	}

	public final void setName(final String setName) {
		this.name = setName;
	}

	public final String getClassName() {
		return className;
	}

	public final void setClassName(final String setClassName) {
		this.className = setClassName;
	}

	public final String getUrl() {
		return url;
	}

	public final void setUrl(final String setUrl) {
		this.url = setUrl;
	}

	public final String getUsername() {
		return username;
	}

	public final void setUsername(final String setUsername) {
		this.username = setUsername;
	}

	public final String getPassword() {
		return password;
	}

	public final void setPassword(final String setPassword) {
		this.password = setPassword;
	}

	public static JdbcResource getJdbcResource(final String fileName,
			final String name) throws SyncDatabaseException, IOException {
		if (fileName == null || name == null) {
			throw new SyncDatabaseException("error.argument");
		}

		final Digester digester = new Digester();

		digester.addObjectCreate("SyncDatabase", JdbcResources.class);
		digester.addObjectCreate("SyncDatabase/jdbcResource",
				JdbcResource.class);
		digester.addSetNext("SyncDatabase/jdbcResource", "addJdbcResources");

		digester.addBeanPropertySetter("SyncDatabase/jdbcResource/name");
		digester.addBeanPropertySetter("SyncDatabase/jdbcResource/className");
		digester.addBeanPropertySetter("SyncDatabase/jdbcResource/url");
		digester.addBeanPropertySetter("SyncDatabase/jdbcResource/username");
		digester.addBeanPropertySetter("SyncDatabase/jdbcResource/password");

		final InputStream is = JdbcResource.class.getClassLoader()
				.getResourceAsStream(fileName);
		if (is == null) {
			throw new SyncDatabaseException("error.resourcefile_notfound",
					fileName);
		}

		JdbcResources resources = null;
		try {
			resources = (JdbcResources) digester.parse(is);
		} catch (final Exception e) {
			throw new SyncDatabaseException("error.resourcefile_parse", e
					.getMessage());
		} finally {
			is.close();
		}

		if (resources == null) {
			throw new SyncDatabaseException("error.resource_notfound", name);
		}

		for (final JdbcResource resource : resources.getJdbcResources()) {
			if (resource.getName().equals(name)) {
				return resource;
			}
		}

		throw new SyncDatabaseException("error.resource_notfound", name);
	}
}
