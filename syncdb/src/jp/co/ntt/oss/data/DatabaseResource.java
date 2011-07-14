package jp.co.ntt.oss.data;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

import javax.naming.NamingException;
import javax.sql.XAConnection;
import javax.sql.XADataSource;
import javax.transaction.SystemException;
import javax.transaction.UserTransaction;

import jp.co.ntt.oss.SyncDatabaseException;

import org.apache.log4j.Logger;
import org.enhydra.jdbc.standard.StandardXADataSource;
import org.objectweb.jotm.Jotm;
import org.objectweb.transaction.jta.TMService;

public class DatabaseResource {
	private static Logger log = Logger.getLogger(DatabaseResource.class);

	// resource file name
	protected static final String RESOURCE_FILE_NAME = "jdbcResource.xml";

	// default transaction timeout
	public static final int DEFAULT_TIMEOUT = Integer.MAX_VALUE;

	private TMService jotm = null;
	private XADataSource xads = null;
	private XAConnection xaconn = null;

	/**
	 * Constructor for DatabaseResource.
	 */
	public DatabaseResource(final String name) throws SyncDatabaseException,
			IOException, NamingException, SQLException {
		if (name == null) {
			throw new SyncDatabaseException("error.argument");
		}

		final JdbcResource jdbcResource = JdbcResource.getJdbcResource(
				RESOURCE_FILE_NAME, name);
		if (jdbcResource == null) {
			throw new SyncDatabaseException("error.resource_notfound", name);
		}

		log.debug(jdbcResource.getName() + " configuration:"
				+ jdbcResource.getUsername() + "/" + jdbcResource.getUrl()
				+ "/" + jdbcResource.getClassName());

		/*
		 * Get a transaction manager. creates an instance of JOTM with a local
		 * transaction factory. which is not bound to a registry.
		 */
		try {
			jotm = new Jotm(true, false);

			xads = new StandardXADataSource();
			((StandardXADataSource) xads).setDriverName(jdbcResource
					.getClassName());
			((StandardXADataSource) xads).setUrl(jdbcResource.getUrl());
			((StandardXADataSource) xads).setTransactionManager(jotm
					.getTransactionManager());

			xaconn = xads.getXAConnection(jdbcResource.getUsername(),
					jdbcResource.getPassword());
		} catch (final Exception e) {
			if (jotm != null) {
				jotm.stop();
			}

			throw new SyncDatabaseException("error.message", e.getMessage());
		}
	}

	public final UserTransaction getUserTransaction() throws SystemException {
		UserTransaction utx = jotm.getUserTransaction();
		utx.setTransactionTimeout(DEFAULT_TIMEOUT);
		return utx;
	}

	public final Connection getConnection() throws SQLException {
		return xaconn.getConnection();
	}

	public final void stop() throws SQLException {
		xaconn.close();
		jotm.stop();
		xaconn = null;
		xads = null;
		jotm = null;
	}
}
