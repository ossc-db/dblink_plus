package jp.co.ntt.oss;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.Hashtable;

import javax.transaction.Status;
import javax.transaction.UserTransaction;

import jp.co.ntt.oss.data.DatabaseResource;
import jp.co.ntt.oss.data.Subscriber;
import jp.co.ntt.oss.data.Subscription;
import jp.co.ntt.oss.data.SyncDatabaseDAO;
import jp.co.ntt.oss.mapper.MappingData;
import jp.co.ntt.oss.utility.PropertyCtrl;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.log4j.Logger;

public class RefreshCommand implements SyncDatabaseCommand {
	private static Logger log = Logger.getLogger(RefreshCommand.class);
	private static PropertyCtrl mProperty = PropertyCtrl.getInstance();

	private boolean showHelp = false;
	private String schema = null;
	private String table = null;
	private String server = null;
	private RefreshMode mode = RefreshMode.AUTO;
	private boolean concurrent = false;

	public RefreshCommand(final CommandLine commandLine)
			throws SyncDatabaseException {
		if (commandLine.hasOption("help")) {
			showHelp = true;
			return;
		}

		/* checking necessary argument */
		if (!commandLine.hasOption("server")
				|| !commandLine.hasOption("schema")
				|| !commandLine.hasOption("table")) {
			showHelp();
			throw new SyncDatabaseException("error.command");
		}

		/* set argument */
		schema = commandLine.getOptionValue("schema");
		table = commandLine.getOptionValue("table");
		server = commandLine.getOptionValue("server");

		if (commandLine.hasOption("concurrent")) {
			concurrent = true;
		}

		if (commandLine.hasOption("mode")) {
			mode = getRefreshMode(commandLine.getOptionValue("mode"));
		}
	}

	public final void execute() throws Exception {
		// show refresh command help
		if (showHelp) {
			showHelp();
			return;
		}

		DatabaseResource replicaDB = null;
		DatabaseResource masterDB = null;
		Connection replicaConn = null;
		Connection masterConn = null;
		UserTransaction utx = null;
		RefreshMode executeMode;
		String result;
		boolean refreshed = false;

		try {
			Subscription subs = null;
			Subscriber suber = null;
			long maxMlogID = SyncDatabaseDAO.MLOG_RECORD_NOT_FOUND;

			// get replica server connection
			replicaDB = new DatabaseResource(server);
			replicaConn = replicaDB.getConnection();

			// begin transaction
			utx = replicaDB.getUserTransaction();
			utx.begin();

			// get subscription data
			subs = SyncDatabaseDAO.getSubscription(replicaConn, schema, table);
			if (subs.getSchema() == null || subs.getTable() == null) {
				throw new SyncDatabaseException("error.replica.dropped",
						SyncDatabaseDAO.getTablePrint(schema, table));
			}

			// get master server connection
			masterDB = new DatabaseResource(subs.getSrvname());
			masterConn = masterDB.getConnection();

			if (subs.getSubsID() != Subscription.NOT_HAVE_SUBSCRIBER) {
				Connection masterLockConn = null;

				// get subscriber data
				suber = SyncDatabaseDAO.getSubscriber(masterConn, subs
						.getSubsID());

				if (suber.getNspName() == null || suber.getRelName() == null) {
					throw new SyncDatabaseException("error.master.dropped",
							suber.getSubsID());
				}

				try {
					masterLockConn = SyncDatabaseDAO.lockTable(subs
							.getSrvname(), suber.getMasterTableName());

					// reset transaction
					utx.rollback();
					utx.setTransactionTimeout(DatabaseResource.DEFAULT_TIMEOUT);
					utx.begin();

					masterConn
							.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);

					// first query
					maxMlogID = SyncDatabaseDAO.getMaxMlogID(masterConn, suber
							.getMlogName());

					masterLockConn.rollback();
				} finally {
					// close connection
					if (masterLockConn != null) {
						masterLockConn.close();
					}
				}

				if (maxMlogID == SyncDatabaseDAO.MLOG_RECORD_NOT_FOUND) {
					if (suber.getLastMlogID() == Subscriber.NO_REFRESH) {
						maxMlogID = 0;
					} else {
						maxMlogID = suber.getLastMlogID();
					}
				}

				if (maxMlogID < suber.getLastMlogID()) {
					log.debug("max mlog ID:" + maxMlogID + " / last mlog ID:"
							+ suber.getLastMlogID());
					throw new SyncDatabaseException("error.mlog_illegal");
				}
			}

			// get execute refresh mode
			executeMode = getExecuteMode(masterConn, suber, subs, mode);

			if (executeMode == RefreshMode.FULL) {
				// full-refresh
				result = fullRefresh(masterConn, replicaConn, suber, subs,
						concurrent);
			} else {
				// incremental-refresh
				result = incrementalRefresh(masterConn, replicaConn, suber,
						subs);
			}

			/* update subscription */
			SyncDatabaseDAO.setSubscription(replicaConn, subs);

			/* update subscriber */
			if (suber != null) {
				suber.setLastMlogID(maxMlogID);
				SyncDatabaseDAO.setSubscriber(masterConn, suber);
			}

			// commit transaction
			utx.commit();
			log.info(result);
			refreshed = true;

			// purge
			if (suber != null) {
				utx.setTransactionTimeout(DatabaseResource.DEFAULT_TIMEOUT);
				utx.begin();
				SyncDatabaseDAO.purgeMlog(masterConn, suber.getNspName(), suber
						.getRelName());

				// commit transaction
				utx.commit();
			}

		} catch (final Exception e) {
			// rollback transaction
			if (utx != null && utx.getStatus() != Status.STATUS_NO_TRANSACTION) {
				utx.rollback();
			}

			if (!refreshed) {
				throw e;
			}

			log.warn(e.getMessage());
		} finally {
			// release resources
			if (replicaConn != null) {
				replicaConn.close();
			}
			if (replicaDB != null) {
				replicaDB.stop();
			}
			if (masterConn != null) {
				masterConn.close();
			}
			if (masterDB != null) {
				masterDB.stop();
			}
		}
	}

	protected static String fullRefresh(final Connection masterConn,
			final Connection replicaConn, final Subscriber suber,
			final Subscription subs, final boolean concurrent)
			throws SQLException, SyncDatabaseException {
		if (masterConn == null || replicaConn == null || subs == null) {
			throw new SyncDatabaseException("error.argument");
		}

		FullReader reader = null;
		FullWriter writer = null;
		long count = 0;

		try {
			// truncate replica table
			SyncDatabaseDAO.truncate(replicaConn, subs.getReplicaTable(),
					concurrent);

			reader = new FullReader(masterConn, subs.getQuery());
			writer = new FullWriter(replicaConn, subs.getSchema(), subs
					.getTable(), reader.getColumnCount());

			// set DataMapper
			MappingData.createDataMappers(reader.getColumnMapping(), writer
					.getColumnMapping());
			writer.prepare(replicaConn, subs.getReplicaTable());

			// Reader thread
			// - Writer thread 間は Object の配列でデータを受け渡す
			Object[] columns;

			while ((columns = reader.getNextColumns()) != null) {
				// Write row data
				writer.setColumns(columns);
				count++;
			}
		} finally {
			if (reader != null) {
				reader.close();
			}
			if (writer != null) {
				writer.close();
			}
		}

		subs.setLastType("F");
		if (suber != null) {
			suber.setLastType("F");
			suber.setLastCount(count);
		}

		return mProperty.getMessage("info.full", count);
	}

	protected static String incrementalRefresh(final Connection masterConn,
			final Connection replicaConn, final Subscriber suber,
			final Subscription subs) throws SQLException, SyncDatabaseException {
		if (masterConn == null || replicaConn == null || suber == null
				|| subs == null) {
			throw new SyncDatabaseException("error.argument");
		}

		IncrementalReader reader = null;
		IncrementalWriter writer = null;

		try {
			Hashtable<Short, String> pkNames = SyncDatabaseDAO.getPKNames(
					masterConn, suber.getNspName(), suber.getRelName());
			final String incrementalQuery = IncrementalReader
					.getIncrementalQuery(suber.getMlogName(), subs.getQuery(),
							pkNames, suber.getLastMlogID());
			reader = new IncrementalReader(masterConn, incrementalQuery,
					pkNames.size());

			pkNames = SyncDatabaseDAO.getPKNames(replicaConn, subs.getSchema(),
					subs.getTable());
			writer = new IncrementalWriter(replicaConn, subs.getSchema(), subs
					.getTable(), reader.getColumnCount(), pkNames);

			// set DataMapper
			MappingData.createDataMappers(reader.getColumnMapping(), writer
					.getColumnMapping());
			writer.prepare(replicaConn, subs.getReplicaTable());

			// Reader thread
			// - Writer thread 間は Object の配列でデータを受け渡す
			Object[] columns;

			while ((columns = reader.getNextColumns()) != null) {
				// Write row data
				writer.setColumns(columns);
			}
		} finally {
			if (reader != null) {
				reader.close();
			}
			if (writer != null) {
				writer.close();
			}
		}

		subs.setLastType("I");
		suber.setLastType("I");
		suber.setLastCount(suber.getLastCount() + writer.getInsertCount()
				- writer.getDeleteCount());

		log.debug("INSERT:" + writer.getInsertCount() + "/DELETE:"
				+ writer.getDeleteCount() + "/UPDATE:"
				+ writer.getUpdateCount() + "/PK COUNT:"
				+ writer.getExecCount());

		return mProperty.getMessage("info.incremental",
				writer.getInsertCount(), writer.getUpdateCount(), writer
						.getDeleteCount());
	}

	private RefreshMode getExecuteMode(final Connection masterConn,
			final Subscriber suber, final Subscription subs,
			final RefreshMode optMode) throws SyncDatabaseException,
			SQLException {
		if (masterConn == null || subs == null) {
			throw new SyncDatabaseException("error.argument");
		}

		if (optMode == RefreshMode.FULL) {
			return RefreshMode.FULL;
		}

		if (subs.getSubsID() == Subscription.NOT_HAVE_SUBSCRIBER) {
			/* has no subscriber info */
			if (optMode == RefreshMode.INCREMENTAL) {
				throw new SyncDatabaseException("error.full");
			}

			return RefreshMode.FULL;
		}

		/* not have subscriber info */
		if (suber == null) {
			throw new SyncDatabaseException("error.no_subscriber", subs
					.getSubsID());
		}

		/* not yet first refresh or it is refresh after TRUNCATE. */
		if (suber.getLastMlogID() == Subscriber.NO_REFRESH) {
			if (optMode == RefreshMode.INCREMENTAL) {
				throw new SyncDatabaseException("error.full");
			}

			return RefreshMode.FULL;
		}

		if (optMode == RefreshMode.INCREMENTAL) {
			return RefreshMode.INCREMENTAL;
		}

		return SyncDatabaseDAO.chooseFastestMode(masterConn, suber);
	}

	/* parse refresh mode */
	protected static RefreshMode getRefreshMode(final String mode)
			throws SyncDatabaseException {
		if (mode == null) {
			throw new SyncDatabaseException("error.argument");
		}

		if (mode.equals("full")) {
			return RefreshMode.FULL;
		} else if (mode.equals("incr") || mode.equals("incremental")) {
			return RefreshMode.INCREMENTAL;
		} else if (mode.equals("auto")) {
			return RefreshMode.AUTO;
		} else {
			showHelp();
			throw new SyncDatabaseException("error.command");
		}
	}

	/* get refresh command options */
	@SuppressWarnings("static-access")
	public static Options getOptions() {
		final Options options = new Options();
		options.addOption(null, "concurrent", false,
				"without taking exclusive lock on the replica table");
		options.addOption(null, "help", false, "show help");
		options.addOption(OptionBuilder.withLongOpt("mode").withDescription(
				"refresh mode, default is auto").hasArgs(1).withArgName(
				"full|incr|auto").create());
		options.addOption(OptionBuilder.withLongOpt("schema").withDescription(
				"replica schema name").hasArgs(1).withArgName("schema name")
				.create());
		options.addOption(OptionBuilder.withLongOpt("server").withDescription(
				"replica server name").hasArgs(1).withArgName("server name")
				.create());
		options.addOption(OptionBuilder.withLongOpt("table").withDescription(
				"replica table name").hasArgs(1).withArgName("table name")
				.create());

		return options;
	}

	/* show refresh command help */
	public static void showHelp() {
		final Options options = getOptions();
		final HelpFormatter f = new HelpFormatter();
		f.printHelp("SyncDatabase refresh", options);
	}
}
