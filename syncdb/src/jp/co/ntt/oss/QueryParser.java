package jp.co.ntt.oss;

import java.util.Hashtable;

import org.apache.log4j.Logger;

public class QueryParser {
	private static Logger log = Logger.getLogger(QueryParser.class);

	private String schema = null;
	private String table = null;
	private final char quoteChar;
	private final String query;
	private char[] str;
	private int cur;
	private int length;

	public QueryParser(final String setQuery, final String quoteString)
			throws SyncDatabaseException {
		if (setQuery == null || quoteString == null || setQuery.length() == 0
				|| quoteString.length() != 1) {
			throw new SyncDatabaseException("error.argument");
		}

		this.quoteChar = quoteString.charAt(0);
		this.query = setQuery;
	}

	public final void parseFull() throws SyncDatabaseException {
		final String[] queryArray = query.split(
				"\\s*[Ss][Ee][Ll][Ee][Cc][Tt]\\s+", 2);
		if (queryArray.length == 1 || queryArray[0].length() != 0) {
			throw new SyncDatabaseException("error.syntax", query);
		}
	}

	private static final int FROM_LEN = 4;
	private static final int FROM_F_IND = 0;
	private static final int FROM_R_IND = 1;
	private static final int FROM_O_IND = 2;
	private static final int FROM_M_IND = 3;

	public final void parseIncremental() throws SyncDatabaseException {
		final String[] queryArray = query.split(
				"\\s*[Ss][Ee][Ll][Ee][Cc][Tt]\\s+", 2);
		if (queryArray.length == 1 || queryArray[0].length() != 0) {
			throw new SyncDatabaseException("error.syntax", query);
		}

		str = queryArray[1].toCharArray();
		length = str.length;
		int count = 0;

		// parse column list
		cur = 0;
		while (cur < length) {
			final String column = getIdentifier(str, quoteChar, length, true);
			count++;
			log.debug("column [" + count + "] : " + column);

			for (; cur < length; cur++) {
				if (!Character.isWhitespace(str[cur])) {
					break;
				}
			}

			if (str[cur] != ',' && str[cur] != '.') {
				break;
			}

			for (cur++; cur < length; cur++) {
				if (!Character.isWhitespace(str[cur])) {
					break;
				}
			}
		}

		log.debug("column count : " + count);

		// parse FROM clause
		if (cur + FROM_LEN >= length
				|| !Character.isWhitespace(str[cur - 1])
				|| (str[cur + FROM_F_IND] != 'F' && str[cur + FROM_F_IND] != 'f')
				|| (str[cur + FROM_R_IND] != 'R' && str[cur + FROM_R_IND] != 'r')
				|| (str[cur + FROM_O_IND] != 'O' && str[cur + FROM_O_IND] != 'o')
				|| (str[cur + FROM_M_IND] != 'M' && str[cur + FROM_M_IND] != 'm')
				|| !Character.isWhitespace(str[cur + FROM_LEN])) {
			throw new SyncDatabaseException("error.syntax.incremental", query);
		}

		for (cur += FROM_LEN + 1; cur < length; cur++) {
			if (!Character.isWhitespace(str[cur])) {
				break;
			}
		}

		// parse schema name
		if (cur >= length || str[cur] != '"') {
			throw new SyncDatabaseException("error.identifier", "schema");
		}
		schema = getIdentifier(str, quoteChar, length, false);

		for (; cur < length; cur++) {
			if (!Character.isWhitespace(str[cur])) {
				break;
			}
		}

		if (cur >= length || str[cur] != '.') {
			throw new SyncDatabaseException("error.syntax.incremental", query);
		}

		for (cur++; cur < length; cur++) {
			if (!Character.isWhitespace(str[cur])) {
				break;
			}
		}

		if (cur >= length) {
			throw new SyncDatabaseException("error.syntax.incremental", query);
		}

		// parse table name
		if (str[cur] != '"') {
			throw new SyncDatabaseException("error.identifier", "table");
		}
		table = getIdentifier(str, quoteChar, str.length, false);

		for (; cur < length; cur++) {
			if (!Character.isWhitespace(str[cur])) {
				break;
			}
		}

		if (cur < length) {
			throw new SyncDatabaseException("error.syntax.incremental", query);
		}
	}

	private static final int DBMS_DELIM_LEN = 8;
	private static final int URL_DELIM_LEN = 7;

	public final Hashtable<String, String> parseDescription()
			throws SyncDatabaseException {
		final String[] descArray = query.split("resource name:", 2);
		if (descArray.length == 1 || descArray[0].length() != 0) {
			throw new SyncDatabaseException("error.syntax.description", query);
		}

		final Hashtable<String, String> description = new Hashtable<String, String>();

		str = descArray[1].toCharArray();
		length = str.length;

		// parse resource name
		cur = 0;
		description.put("resource name", getIdentifier(str, quoteChar, length,
				true));

		// parse DBMS name
		if (cur + DBMS_DELIM_LEN >= length || str[cur++] != ','
				|| str[cur++] != ' ' || str[cur++] != 'D' || str[cur++] != 'B'
				|| str[cur++] != 'M' || str[cur++] != 'S' || str[cur++] != ':') {
			throw new SyncDatabaseException("error.syntax.description", query);
		}

		description.put("DBMS", getIdentifier(str, quoteChar, length, true));

		// parse URL
		if (cur + URL_DELIM_LEN >= length || str[cur++] != ','
				|| str[cur++] != ' ' || str[cur++] != 'U' || str[cur++] != 'R'
				|| str[cur++] != 'L' || str[cur++] != ':') {
			throw new SyncDatabaseException("error.syntax.description", query);
		}

		description.put("URL", getIdentifier(str, quoteChar, length, true));

		if (cur != length) {
			throw new SyncDatabaseException("error.syntax.description", query);
		}

		return description;
	}

	private String getIdentifier(final char[] setStr, final char setQuoteChar,
			final int setLength, final boolean isColumn)
			throws SyncDatabaseException {
		if (cur == setLength) {
			throw new SyncDatabaseException("error.syntax", query);
		}

		if (setStr[cur] == '*') {
			if (!isColumn) {
				throw new SyncDatabaseException("error.syntax.incremental",
						query);
			}

			for (cur++; cur < setLength; cur++) {
				if (!Character.isWhitespace(setStr[cur])) {
					break;
				}
			}

			if (cur >= setLength
					|| (setStr[cur] != ',' && !Character
							.isWhitespace(setStr[cur - 1]))) {
				throw new SyncDatabaseException("error.syntax", query);
			}

			return "*";
		}

		final StringBuilder identifier = new StringBuilder();
		if (setStr[cur] == setQuoteChar) {
			// quoted identifier
			cur++;
			for (; cur < setLength; cur++) {
				if (setStr[cur] == setQuoteChar) {
					if (cur + 1 == setLength || setStr[cur + 1] != setQuoteChar) {
						break;
					}
					cur++;
				}

				identifier.append(setStr[cur]);
			}

			if (cur >= setLength) {
				throw new SyncDatabaseException("error.syntax", query);
			}

			cur++;
		} else {
			// no quoted identifier
			for (; cur < setLength; cur++) {
				if (setStr[cur] == ',' || setStr[cur] == '.'
						|| Character.isWhitespace(setStr[cur])) {
					break;
				}
				identifier.append(setStr[cur]);
			}
		}

		if (identifier.length() == 0) {
			throw new SyncDatabaseException("error.syntax", query);
		}

		return identifier.toString();
	}

	public final String getSchema() {
		return schema;
	}

	public final String getTable() {
		return table;
	}

}
