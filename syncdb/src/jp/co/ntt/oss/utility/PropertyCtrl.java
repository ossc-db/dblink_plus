package jp.co.ntt.oss.utility;

import java.io.IOException;
import java.io.InputStream;
import java.text.MessageFormat;
import java.util.Properties;

/**
 * property and a message acquisition class.
 */
public class PropertyCtrl {
	/** message filename. */
	private static final String BATCH_MESSAGE_FILE = "message.properties";

	/** A message when there is not a message to fall under. */
	private static final String MESSAGE_NOT_FOUND = "log message not found";

	/** own instance. */
	private static PropertyCtrl mInstance = null;

	/** Properties class. */
	private static Properties mMessageProperties = null;

	/**
	 * Constructor.
	 */
	protected PropertyCtrl() {
	}

	/**
	 * get BatchProperties instance.
	 */
	public static synchronized PropertyCtrl getInstance() {
		if (mInstance == null) {
			mInstance = new PropertyCtrl();

			try {
				mMessageProperties = getProperties(BATCH_MESSAGE_FILE);
			} catch (Exception e) {
				e.printStackTrace();
				System.out.println("get properties file:" + e.getMessage());
				System.exit(1);
			}
		}
		return mInstance;
	}

	/**
	 * get message.
	 */
	public final synchronized String getMessage(final String messageId,
			final Object... args) {
		if (messageId == null) {
			return MESSAGE_NOT_FOUND;
		}

		String property = mMessageProperties.getProperty(messageId);
		if (property != null) {
			return MessageFormat.format(property, args);
		} else {
			// return property;
			return MESSAGE_NOT_FOUND;
		}
	}

	/**
	 * get properties.
	 */
	private static Properties getProperties(final String propertyFileName)
			throws IOException {
		Properties propertis = new Properties();
		InputStream is = PropertyCtrl.class.getClassLoader()
				.getResourceAsStream(propertyFileName);
		try {
			propertis.load(is);
			return propertis;
		} finally {
			if (is != null) {
				is.close();
			}
		}
	}
}
