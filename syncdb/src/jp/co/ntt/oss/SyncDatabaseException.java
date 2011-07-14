package jp.co.ntt.oss;

import jp.co.ntt.oss.utility.PropertyCtrl;

@SuppressWarnings("serial")
public class SyncDatabaseException extends Exception {
	private static PropertyCtrl mProperty = PropertyCtrl.getInstance();

	public SyncDatabaseException(final String pattern,
			final Object... arguments) {
		super(mProperty.getMessage(pattern, arguments));
	}
}
