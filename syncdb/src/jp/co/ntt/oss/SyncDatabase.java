package jp.co.ntt.oss;

import java.io.PrintWriter;
import java.io.StringWriter;

import org.apache.commons.cli.BasicParser;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.log4j.Logger;
import java.sql.SQLException;
import jp.co.ntt.oss.utility.PropertyCtrl;

public class SyncDatabase {
	private static Logger log = Logger.getLogger(SyncDatabase.class);
	private static PropertyCtrl mProperty = PropertyCtrl.getInstance();

	/**
	 * execute SyncDatabase.
	 */
	public static void main(final String[] args) {
		try {
			// construct command instance
			final SyncDatabaseCommand command = getSyncDatabaseCommand(args);

			// execute command
			command.execute();
		} catch (SQLException e) {
			log.debug(mProperty.getMessage("error.refresh"));
			log.error(mProperty.getMessage("error.refresh"));
		} catch (final Exception e) {
			String stackTrace = null;
			try {
				StringWriter sw = null;
				try {
					sw = new StringWriter();
					e.printStackTrace(new PrintWriter(sw));
					stackTrace = sw.toString();
				} finally {
					if (sw != null) {
						sw.close();
						sw = null;
					}
				}
			} catch (Exception e1) {
				stackTrace = e1.getMessage();
			}

			log.debug(stackTrace);
			log.error(e.getMessage());
			System.exit(1);
		}
	}

	protected static SyncDatabaseCommand getSyncDatabaseCommand(
			final String[] args) throws SyncDatabaseException, ParseException {
		// command not specified
		if (args == null || args.length < 1) {
			HelpCommand.showHelp();
			throw new SyncDatabaseException("error.command");
		}

		// version option
		for (String arg : args) {
			if (arg.equals("--version")) {
				return new VersionCommand();
			}
		}

		if (args[0].equals("create")) {
			final Options options = CreateCommand.getOptions();
			final CommandLine commandLine = parseCommandLine(args, options,
					"create");
			return new CreateCommand(commandLine);
		} else if (args[0].equals("drop")) {
			final Options options = DropCommand.getOptions();
			final CommandLine commandLine = parseCommandLine(args, options,
					"drop");
			return new DropCommand(commandLine);
		} else if (args[0].equals("attach")) {
			final Options options = AttachCommand.getOptions();
			final CommandLine commandLine = parseCommandLine(args, options,
					"attach");
			return new AttachCommand(commandLine);
		} else if (args[0].equals("detach")) {
			final Options options = DetachCommand.getOptions();
			final CommandLine commandLine = parseCommandLine(args, options,
					"detach");
			return new DetachCommand(commandLine);
		} else if (args[0].equals("refresh")) {
			final Options options = RefreshCommand.getOptions();
			final CommandLine commandLine = parseCommandLine(args, options,
					"refresh");
			return new RefreshCommand(commandLine);
		} else if (args[0].equals("status")) {
			final Options options = StatusCommand.getOptions();
			final CommandLine commandLine = parseCommandLine(args, options,
					"status");
			return new StatusCommand(commandLine);
		} else if (args[0].equals("help") || args[0].equals("--help")) {
			final Options options = HelpCommand.getOptions();
			final CommandLine commandLine = parseCommandLine(args, options,
					"help");
			return new HelpCommand(commandLine);
		} else {
			HelpCommand.showHelp();
			throw new SyncDatabaseException("error.command");
		}
	}

	protected static CommandLine parseCommandLine(final String[] args,
			final Options options, final String command)
			throws SyncDatabaseException, ParseException {
		if (args == null || options == null || command == null) {
			throw new SyncDatabaseException("error.argument");
		}

		final CommandLineParser parser = new BasicParser();
		final CommandLine commandLine = parser.parse(options, args);

		if (!command.equals("help")
				&& (commandLine.getArgs().length != 1 || !command
						.equals(commandLine.getArgs()[0]))) {
			throw new SyncDatabaseException("error.option");
		}

		return commandLine;
	}
}
