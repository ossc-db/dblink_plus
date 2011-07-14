package jp.co.ntt.oss;

import java.sql.SQLException;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;

public class HelpCommand implements SyncDatabaseCommand {

	public HelpCommand(final CommandLine commandLine)
			throws SyncDatabaseException {
	}

	@Override
	public final void execute() throws SQLException, SyncDatabaseException {
		showHelp();
	}

	/* get help command options */
	@SuppressWarnings("static-access")
	public static Options getOptions() {
		final Options options = new Options();
		options.addOption(null, "concurrent", false,
				"exclusive lock a replica table");
		options.addOption(null, "cost", false, "show cost");
		options.addOption(null, "force", false, "force detach");
		options.addOption(null, "help", false, "show help");
		options.addOption(OptionBuilder.withLongOpt("master").withDescription(
				"master server resource name").hasArgs(1).withArgName(
				"master name").create());
		options.addOption(OptionBuilder.withLongOpt("mode").withDescription(
				"refresh mode").hasArgs(1).create());
		options.addOption(OptionBuilder.withLongOpt("query").withDescription(
				"refresh query string").hasArgs(1).withArgName("query")
				.create());
		options.addOption(OptionBuilder.withLongOpt("schema").withDescription(
				"schema name").hasArgs(1).withArgName("schema name").create());
		options.addOption(OptionBuilder.withLongOpt("server").withDescription(
				"replica server resource name").hasArgs(1).withArgName(
				"replica name").create());
		options.addOption(OptionBuilder.withLongOpt("table").withDescription(
				"table name").hasArgs(1).withArgName("table name").create());
		options.addOption(null, "version", false, "show version");

		return options;
	}

	/* show help command help */
	public static void showHelp() {
		final Options options = getOptions();
		final HelpFormatter f = new HelpFormatter();
		f.printHelp("SyncDatabase create | drop | attach | detach | "
				+ "refresh | status [options]", options);
	}

}
