package jp.co.ntt.oss;

import static jp.co.ntt.oss.data.MasterStatus.MASTERSTATUS_LOGS;
import static jp.co.ntt.oss.data.MasterStatus.MASTERSTATUS_OLDEST_REFRESH;
import static jp.co.ntt.oss.data.MasterStatus.MASTERSTATUS_OLDEST_REPLICA;
import static jp.co.ntt.oss.data.MasterStatus.MASTERSTATUS_SCHEMA;
import static jp.co.ntt.oss.data.MasterStatus.MASTERSTATUS_SUBS;
import static jp.co.ntt.oss.data.MasterStatus.MASTERSTATUS_TABLE;
import static jp.co.ntt.oss.data.ReplicaStatus.REPLICASTATUS_COLUMNS;
import static jp.co.ntt.oss.data.ReplicaStatus.REPLICASTATUS_COST;
import static jp.co.ntt.oss.data.ReplicaStatus.REPLICASTATUS_LAST_REFRESH;
import static jp.co.ntt.oss.data.ReplicaStatus.REPLICASTATUS_MASTER;
import static jp.co.ntt.oss.data.ReplicaStatus.REPLICASTATUS_SCHEMA;
import static jp.co.ntt.oss.data.ReplicaStatus.REPLICASTATUS_TABLE;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;

import javax.naming.NamingException;

import jp.co.ntt.oss.data.DatabaseResource;
import jp.co.ntt.oss.data.MasterStatus;
import jp.co.ntt.oss.data.ReplicaStatus;
import jp.co.ntt.oss.data.Subscriber;
import jp.co.ntt.oss.data.Subscription;
import jp.co.ntt.oss.data.SyncDatabaseDAO;
import jp.co.ntt.oss.utility.PropertyCtrl;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.log4j.Logger;

public class StatusCommand implements SyncDatabaseCommand {
	private static Logger log = Logger.getLogger(StatusCommand.class);
	private static PropertyCtrl mProperty = PropertyCtrl.getInstance();

	// yyyy-mm-dd hh:mm:ss
	private static final int TIMESTAMP_WIDTH = 19;

	private boolean showHelp = false;
	private String schema = null;
	private String table = null;
	private String master = null;
	private String server = null;
	private boolean cost = false;

	public StatusCommand(final CommandLine commandLine)
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
		if (commandLine.hasOption("cost")) {
			cost = true;
		}

		/* checking necessary argument */
		if (!commandLine.hasOption("master")
				&& !commandLine.hasOption("server")) {
			showHelp();
			throw new SyncDatabaseException("error.command");
		}
	}

	@Override
	public final void execute() throws Exception {
		// show status command help
		if (showHelp) {
			showHelp();
			return;
		}

		if (master != null) {
			log.info(masterStatus(master, schema, table));
		}

		if (server != null) {
			log.info(replicaStatus(server, schema, table, cost));
		}
	}

	protected static String masterStatus(final String master,
			final String schema, final String table)
			throws SyncDatabaseException, IOException, NamingException,
			SQLException {
		if (master == null) {
			throw new SyncDatabaseException("error.argument");
		}

		DatabaseResource db = null;
		Connection conn = null;

		try {
			// get replica server connection
			db = new DatabaseResource(master);
			conn = db.getConnection();

			final ArrayList<MasterStatus> masters = SyncDatabaseDAO
					.getMasterStatus(conn, schema, table);

			final StringBuilder status = new StringBuilder();
			status.append("master status\n");

			// get display size
			final int[] widths = new int[MasterStatus.MASTERSTATUS_COLUMNS];
			for (int i = 0; i < MasterStatus.MASTERSTATUS_COLUMNS; i++) {
				widths[i] = MasterStatus.HEADERS[i].length();
			}

			widths[MASTERSTATUS_OLDEST_REFRESH] = TIMESTAMP_WIDTH;
			for (final MasterStatus masterStatus : masters) {
				if (masterStatus.getSchema() != null) {
					widths[MASTERSTATUS_SCHEMA] = Math.max(
							widths[MASTERSTATUS_SCHEMA], masterStatus
									.getSchema().getBytes().length);
				}

				if (masterStatus.getTable() != null) {
					widths[MASTERSTATUS_TABLE] = Math.max(
							widths[MASTERSTATUS_TABLE], masterStatus.getTable()
									.getBytes().length);
				}

				widths[MASTERSTATUS_LOGS] = Math.max(widths[MASTERSTATUS_LOGS],
						Long.toString(masterStatus.getLogCount()).length());

				widths[MASTERSTATUS_SUBS] = Math.max(widths[MASTERSTATUS_SUBS],
						Long.toString(masterStatus.getSubscribers()).length());

				if (masterStatus.getOldestReplica() != null) {
					widths[MASTERSTATUS_OLDEST_REPLICA] = Math.max(
							widths[MASTERSTATUS_OLDEST_REPLICA], masterStatus
									.getOldestReplica().getBytes().length);
				}
			}

			// append header
			int i;
			for (i = 0; i < MasterStatus.MASTERSTATUS_COLUMNS - 1; i++) {
				appendStringValue(status, MasterStatus.HEADERS[i], widths[i],
						false);
			}
			appendStringValue(status, MasterStatus.HEADERS[i], widths[i], true);

			// append separator
			for (i = 0; i < MasterStatus.MASTERSTATUS_COLUMNS - 1; i++) {
				appendSeparator(status, widths[i], false);
			}
			appendSeparator(status, widths[i], true);

			// append subscription data
			for (final MasterStatus masterStatus : masters) {
				appendStringValue(status, masterStatus.getSchema(),
						widths[MASTERSTATUS_SCHEMA], false);
				appendStringValue(status, masterStatus.getTable(),
						widths[MASTERSTATUS_TABLE], false);
				appendLongValue(status, masterStatus.getLogCount(),
						widths[MASTERSTATUS_LOGS], false);
				appendLongValue(status, masterStatus.getSubscribers(),
						widths[MASTERSTATUS_SUBS], false);
				appendTimestampValue(status, masterStatus.getOldestRefresh(),
						false);
				appendStringValue(status, masterStatus.getOldestReplica(),
						widths[MASTERSTATUS_OLDEST_REPLICA], true);
			}

			return status.toString();
		} finally {
			// release resources
			if (conn != null) {
				conn.close();
			}
			if (db != null) {
				db.stop();
			}
		}
	}

	protected static String replicaStatus(final String server,
			final String schema, final String table, final boolean cost)
			throws SyncDatabaseException, IOException, NamingException,
			SQLException {
		if (server == null) {
			throw new SyncDatabaseException("error.argument");
		}

		DatabaseResource db = null;
		Connection conn = null;

		try {
			// get replica server connection
			db = new DatabaseResource(server);
			conn = db.getConnection();

			final ArrayList<ReplicaStatus> replicas = SyncDatabaseDAO
					.getReplicaStatus(conn, schema, table);
			final StringBuilder status = new StringBuilder();
			status.append("replica status\n");

			// get display size
			final int[] widths = new int[REPLICASTATUS_COLUMNS];
			for (int i = 0; i < REPLICASTATUS_COLUMNS; i++) {
				widths[i] = ReplicaStatus.HEADERS[i].length();
			}

			widths[REPLICASTATUS_LAST_REFRESH] = TIMESTAMP_WIDTH;
			for (final ReplicaStatus replicaStatus : replicas) {
				if (replicaStatus.getSchema() != null) {
					widths[REPLICASTATUS_SCHEMA] = Math.max(
							widths[REPLICASTATUS_SCHEMA], replicaStatus
									.getSchema().getBytes().length);
				}

				if (replicaStatus.getTable() != null) {
					widths[REPLICASTATUS_TABLE] = Math.max(
							widths[REPLICASTATUS_TABLE], replicaStatus
									.getTable().getBytes().length);
				}

				widths[REPLICASTATUS_MASTER] = Math.max(
						widths[REPLICASTATUS_MASTER], replicaStatus.getMaster()
								.getBytes().length);
			}

			// append header
			int i;
			for (i = 0; i < REPLICASTATUS_MASTER; i++) {
				appendStringValue(status, ReplicaStatus.HEADERS[i], widths[i],
						false);
			}
			appendStringValue(status,
					ReplicaStatus.HEADERS[REPLICASTATUS_MASTER],
					widths[REPLICASTATUS_MASTER], !cost);
			if (cost) {
				appendStringValue(status,
						ReplicaStatus.HEADERS[REPLICASTATUS_COST],
						widths[REPLICASTATUS_COST], true);
			}

			// append separator
			for (i = 0; i < REPLICASTATUS_MASTER; i++) {
				appendSeparator(status, widths[i], false);
			}
			appendSeparator(status, widths[REPLICASTATUS_MASTER], !cost);
			if (cost) {
				appendSeparator(status, widths[REPLICASTATUS_COST], true);
			}

			// append subscription data
			for (final ReplicaStatus replicaStatus : replicas) {
				appendStringValue(status, replicaStatus.getSchema(),
						widths[REPLICASTATUS_SCHEMA], false);
				appendStringValue(status, replicaStatus.getTable(),
						widths[REPLICASTATUS_TABLE], false);
				appendTimestampValue(status, replicaStatus.getLastRefresh(),
						false);
				appendStringValue(status, replicaStatus.getMaster(),
						widths[REPLICASTATUS_MASTER], !cost);
				if (cost) {
					double incrementalCost = Double.NaN;
					try {
						incrementalCost = getCost(replicaStatus.getMaster(),
								replicaStatus.getSubsID());
					} catch (Exception e) {
						log.debug(e.getMessage());
						log.warn(mProperty
								.getMessage("warning.master.broken",
										SyncDatabaseDAO.getTablePrint(
												replicaStatus.getSchema(),
												replicaStatus.getTable())));
					}
					appendDoubleValue(status, incrementalCost,
							widths[REPLICASTATUS_COST], true);
				}
			}

			return status.toString();
		} finally {
			// release resources
			if (conn != null) {
				conn.close();
			}
			if (db != null) {
				db.stop();
			}
		}
	}

	protected static double getCost(final String master, final long subsid)
			throws SyncDatabaseException, IOException, NamingException,
			SQLException {
		if (master == null || subsid == Subscription.NOT_HAVE_SUBSCRIBER) {
			return Double.NaN;
		}

		DatabaseResource db = null;
		Connection conn = null;
		double cost;

		try {
			// get master server connection
			db = new DatabaseResource(master);
			conn = db.getConnection();

			Subscriber suber = SyncDatabaseDAO.getSubscriber(conn, subsid);

			if (suber.getNspName() == null || suber.getRelName() == null) {
				throw new SyncDatabaseException("error.master.dropped", subsid);
			}

			cost = SyncDatabaseDAO.getIncrementalRefreshCost(conn, suber
					.getMlogName(), suber.getLastMlogID(),
					suber.getLastCount(), SyncDatabaseDAO.getPKNames(conn,
							suber.getNspName(), suber.getRelName()));
		} finally {
			// release resources
			if (conn != null) {
				conn.close();
			}
			if (db != null) {
				db.stop();
			}
		}

		return cost;
	}

	protected static void appendLongValue(final StringBuilder builder,
			final long value, final int width, final boolean endColumn)
			throws SyncDatabaseException {
		if (builder == null || width <= 0) {
			throw new SyncDatabaseException("error.argument");
		}

		builder.append(String.format(" %1$" + width + "d ", value));

		if (endColumn) {
			builder.append("\n");
		} else {
			builder.append("|");
		}
	}

	protected static void appendDoubleValue(final StringBuilder builder,
			final double value, final int width, final boolean endColumn)
			throws SyncDatabaseException {
		if (builder == null || width <= 0) {
			throw new SyncDatabaseException("error.argument");
		}

		if (Double.isNaN(value)) {
			builder.append(String.format(" %1$" + width + "s ", "Inf"));
		} else {
			builder.append(String.format(" %1$." + (width - 1) + "g ", value));
		}

		if (endColumn) {
			builder.append("\n");
		} else {
			builder.append("|");
		}
	}

	protected static void appendStringValue(final StringBuilder builder,
			final String value, final int width, final boolean endColumn)
			throws SyncDatabaseException {
		if (builder == null || width <= 0) {
			throw new SyncDatabaseException("error.argument");
		}

		if (value == null) {
			builder.append(String.format(" %1$" + width + "s ", " "));
		} else {
			builder.append(String.format(" %1$-" + width + "s ", value));
		}

		if (endColumn) {
			builder.append("\n");
		} else {
			builder.append("|");
		}
	}

	protected static void appendTimestampValue(final StringBuilder builder,
			final Timestamp value, final boolean endColumn)
			throws SyncDatabaseException {
		if (builder == null) {
			throw new SyncDatabaseException("error.argument");
		}

		if (value == null) {
			builder.append(String.format(" %1$19s ", " "));
		} else {
			// convert Timestamp to Date
			final Date date = new Date(value.getTime());
			builder.append(String.format(" %1$tF %1$tT ", date));
		}
		if (endColumn) {
			builder.append("\n");
		} else {
			builder.append("|");
		}
	}

	protected static void appendSeparator(final StringBuilder builder,
			final int width, final boolean endColumn)
			throws SyncDatabaseException {
		if (builder == null || width < 0) {
			throw new SyncDatabaseException("error.argument");
		}

		for (int i = 0; i < width + 2; i++) {
			builder.append("-");
		}

		if (endColumn) {
			builder.append("\n");
		} else {
			builder.append("+");
		}
	}

	/* get status command options */
	@SuppressWarnings("static-access")
	public static Options getOptions() {
		final Options options = new Options();
		options.addOption(null, "cost", false, "show cost");
		options.addOption(null, "help", false, "show help");
		options.addOption(OptionBuilder.withLongOpt("master").withDescription(
				"master server name").hasArgs(1).withArgName(
				"master server name").create());
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

	/* show status command help */
	public static void showHelp() {
		final Options options = getOptions();
		final HelpFormatter f = new HelpFormatter();
		f.printHelp("SyncDatabase status", options);
	}
}
