package jp.co.ntt.oss;

import jp.co.ntt.oss.utility.PropertyCtrl;

public class VersionCommand implements SyncDatabaseCommand {
	private static PropertyCtrl mProperty = PropertyCtrl.getInstance();

	public VersionCommand() {
	}

	@Override
	public final void execute() {
		showVersion();
	}

	/* show help command help */
	public static void showVersion() {
		System.out.println(mProperty.getMessage("version.command", mProperty
				.getMessage("version.number")));
	}
}
