package jp.co.ntt.oss;

import java.sql.Connection;

import javax.transaction.Status;
import javax.transaction.UserTransaction;

import jp.co.ntt.oss.data.DatabaseResource;
import jp.co.ntt.oss.data.Subscriber;
import jp.co.ntt.oss.data.Subscription;
import jp.co.ntt.oss.data.SyncDatabaseDAO;
import jp.co.ntt.oss.utility.PropertyCtrl;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.log4j.Logger;

public class DetachCommand implements SyncDatabaseCommand {
	private static Logger log = Logger.getLogger(DetachCommand.class);
	private static PropertyCtrl mProperty = PropertyCtrl.getInstance();

	private boolean showHelp = false;
	private String schema = null;
	private String table = null;
	private String server = null;
	private boolean force = false;

	public DetachCommand(final CommandLine commandLine)
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
		if (commandLine.hasOption("force")) {
			force = true;
		}
	}

	@Override
	public final void execute() throws Exception {
		// show detach command help
		if (showHelp) {
			showHelp();
			return;
		}

		DatabaseResource replicaDB = null;
		DatabaseResource masterDB = null;
		Connection replicaConn = null;
		Connection masterConn = null;
		UserTransaction utx = null;
		boolean updated = false;
		boolean detached = false;

		try {
			Subscription subs = null;
			Subscriber suber = null;

			// get replica server connection
			replicaDB = new DatabaseResource(server);
			replicaConn = replicaDB.getConnection();

			// begin transaction
			utx = replicaDB.getUserTransaction();
			utx.begin();

			// get subscription data
			subs = SyncDatabaseDAO.getSubscription(replicaConn, schema, table);

			if (subs.getSubsID() != Subscription.NOT_HAVE_SUBSCRIBER) {
				// get master server connection
				try {
					masterDB = new DatabaseResource(subs.getSrvname());
					masterConn = masterDB.getConnection();
				} catch (Exception e) {
					if (!force) {
						throw e;
					}

					log.warn(e.getMessage());
				}
			}

			// unsubscribe replica
			SyncDatabaseDAO.unSubscribeObserver(replicaConn, schema, table);

			if (masterConn != null) {
				if (force) {
					utx.commit();
					updated = true;
					utx.begin();
				}

				// get subscriber data
				suber = SyncDatabaseDAO.getSubscriber(masterConn, subs
						.getSubsID());

				if (suber.getNspName() == null || suber.getRelName() == null) {
					log.warn(mProperty.getMessage("error.master.dropped", suber
							.getSubsID()));
				}

				// unsubscribe master
				SyncDatabaseDAO.unSubscribeMlog(masterConn, suber.getSubsID());
			}

			// commit transaction
			utx.commit();
			log.info(mProperty.getMessage("info.detach.success"));
			detached = true;

			// purge
			if (suber != null) {
				if (suber.getNspName() == null || suber.getRelName() == null) {
					log.debug("no purge");
					return;
				}

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

			if (!(detached || (force && updated))) {
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

	/* get detach command options */
	@SuppressWarnings("static-access")
	public static Options getOptions() {
		final Options options = new Options();
		options.addOption(null, "force", false, "force detach");
		options.addOption(null, "help", false, "show help");
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

	/* show detach command help */
	public static void showHelp() {
		final Options options = getOptions();
		final HelpFormatter f = new HelpFormatter();
		f.printHelp("SyncDatabase detach", options);
	}
}
