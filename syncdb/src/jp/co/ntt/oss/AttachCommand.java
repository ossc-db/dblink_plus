package jp.co.ntt.oss;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.DatabaseMetaData;

import javax.transaction.Status;
import javax.transaction.UserTransaction;

import jp.co.ntt.oss.data.DatabaseResource;
import jp.co.ntt.oss.data.SyncDatabaseDAO;
import jp.co.ntt.oss.utility.PropertyCtrl;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.log4j.Logger;

public class AttachCommand implements SyncDatabaseCommand {
	private static Logger log = Logger.getLogger(AttachCommand.class);
	private static PropertyCtrl mProperty = PropertyCtrl.getInstance();

	private boolean showHelp = false;
	private String schema = null;
	private String table = null;
	private String master = null;
	private String server = null;
	private String query = null;
	private RefreshMode mode = RefreshMode.INCREMENTAL;

	public AttachCommand(final CommandLine commandLine)
			throws SyncDatabaseException {
		if (commandLine.hasOption("help")) {
			showHelp = true;
			return;
		}

		/* set argument */
		schema = commandLine.getOptionValue("schema");
		table = commandLine.getOptionValue("table");
		master = commandLine.getOptionValue("master");
		server = commandLine.getOptionValue("server");
		query = commandLine.getOptionValue("query");

		if (commandLine.hasOption("mode")) {
			mode = getRefreshMode(commandLine.getOptionValue("mode"));
		}

		/* checking necessary argument */
		if (!commandLine.hasOption("schema") || !commandLine.hasOption("table")
				|| !commandLine.hasOption("master")
				|| !commandLine.hasOption("server")) {
			showHelp();
			throw new SyncDatabaseException("error.command");
		}

		// input query
		if (!commandLine.hasOption("query") || query.equalsIgnoreCase("stdin")) {
			System.out.print(mProperty.getMessage("info.input_query"));

			final StringBuilder queryBuilder = new StringBuilder();
			final BufferedReader stdReader = new BufferedReader(
					new InputStreamReader(System.in));
			try {
				String line;
				while ((line = stdReader.readLine()) != null) {
					queryBuilder.append(line + " ");
				}

				stdReader.close();
			} catch (final IOException e) {
				throw new SyncDatabaseException("error.message", e.getMessage());
			}

			query = queryBuilder.toString();
			log.debug("input query:" + query);
		}
	}

	public final void execute() throws Exception {
		// show attach command help
		if (showHelp) {
			showHelp();
			return;
		}

		DatabaseResource replicaDB = null;
		DatabaseResource masterDB = null;
		Connection replicaConn = null;
		Connection masterConn = null;
		UserTransaction utx = null;
		long subsid = 0;

		try {
			// get replica server connection
			replicaDB = new DatabaseResource(server);
			replicaConn = replicaDB.getConnection();

			// get master server connection
			masterDB = new DatabaseResource(master);
			masterConn = masterDB.getConnection();

			// parse query
			final DatabaseMetaData dmd = masterConn.getMetaData();
			final String quoteString = dmd.getIdentifierQuoteString();
			final QueryParser parser = new QueryParser(query, quoteString);
			if (mode == RefreshMode.FULL) {
				parser.parseFull();
			} else {
				parser.parseIncremental();
			}

			// begin transaction
			utx = replicaDB.getUserTransaction();
			utx.begin();

			if (mode == RefreshMode.INCREMENTAL) {
				subsid = SyncDatabaseDAO.subscribeMlog(masterConn, parser
						.getSchema(), parser.getTable(), SyncDatabaseDAO
						.getDescription(replicaConn, server));
			}

			SyncDatabaseDAO.subscribeObserver(replicaConn, schema, table,
					subsid, master, query);

			// commit transaction
			utx.commit();
		} catch (final Exception e) {
			// rollback transaction
			if (utx != null && utx.getStatus() != Status.STATUS_NO_TRANSACTION) {
				utx.rollback();
			}

			throw e;
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

		if (mode == RefreshMode.FULL) {
			log.info(mProperty.getMessage("info.attach.full"));
		} else {
			log.info(mProperty.getMessage("info.attach.incremental", subsid));
		}
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
		} else {
			showHelp();
			throw new SyncDatabaseException("error.command");
		}
	}

	/* get attach command options */
	@SuppressWarnings("static-access")
	public static Options getOptions() {
		final Options options = new Options();
		options.addOption(null, "help", false, "show help");
		options.addOption(OptionBuilder.withLongOpt("master").withDescription(
				"master server name").hasArgs(1).withArgName(
				"master server name").create());
		options.addOption(OptionBuilder.withLongOpt("mode").withDescription(
				"attach mode, default is incremental").hasArgs(1).withArgName(
				"full|incr[emental]").create());
		options.addOption(OptionBuilder.withLongOpt("query").withDescription(
				"refresh query").hasArgs(1).withArgName("refresh query")
				.create());
		options.addOption(OptionBuilder.withLongOpt("schema").withDescription(
				"replica schema name").hasArgs(1).withArgName("schema name")
				.create());
		options.addOption(OptionBuilder.withLongOpt("server").withDescription(
				"replica server name").hasArgs(1).withArgName(
				"replica server name").create());
		options.addOption(OptionBuilder.withLongOpt("table").withDescription(
				"replica table name").hasArgs(1).withArgName("table name")
				.create());

		return options;
	}

	/* show attach command help */
	public static void showHelp() {
		final Options options = getOptions();
		final HelpFormatter f = new HelpFormatter();
		f.printHelp("SyncDatabase attach", options);
	}
}
