package jp.co.ntt.oss.data;

import java.sql.Timestamp;

public class MasterStatus {
	public static final int MASTERSTATUS_SCHEMA = 0;
	public static final int MASTERSTATUS_TABLE = 1;
	public static final int MASTERSTATUS_LOGS = 2;
	public static final int MASTERSTATUS_SUBS = 3;
	public static final int MASTERSTATUS_OLDEST_REFRESH = 4;
	public static final int MASTERSTATUS_OLDEST_REPLICA = 5;
	public static final int MASTERSTATUS_COLUMNS = 6;
	public static final String[] HEADERS = { "schema", "table", "logs", "subs",
			"oldest refresh", "oldest replica" };
	public static final long INVALID_LOG_COUNT = -1;

	private String schema;
	private String table;
	private long logCount;
	private long subscribers;
	private Timestamp oldestRefresh;
	private String oldestReplica;

	public MasterStatus(final String setSchema, final String setTable,
			final long setLogCount, final long setSubscribers,
			final Timestamp setOldestRefresh, final String setOldestReplica) {
		this.schema = setSchema;
		this.table = setTable;
		this.logCount = setLogCount;
		this.subscribers = setSubscribers;
		this.oldestRefresh = setOldestRefresh;
		this.oldestReplica = setOldestReplica;
	}

	public final String getSchema() {
		return schema;
	}

	public final void setSchema(final String setSchema) {
		this.schema = setSchema;
	}

	public final String getTable() {
		return table;
	}

	public final void setTable(final String setTable) {
		this.table = setTable;
	}

	public final long getLogCount() {
		return logCount;
	}

	public final void setLogCount(final long setLogCount) {
		this.logCount = setLogCount;
	}

	public final long getSubscribers() {
		return subscribers;
	}

	public final void setSubscribers(final long setSubscribers) {
		this.subscribers = setSubscribers;
	}

	public final void incrSubscribers() {
		this.subscribers++;
	}

	public final Timestamp getOldestRefresh() {
		return oldestRefresh;
	}

	public final void setOldestRefresh(final Timestamp setOldestRefresh) {
		this.oldestRefresh = setOldestRefresh;
	}

	public final boolean updateOldestRefresh(final Timestamp refreshTime) {
		if (refreshTime == null) {
			return false;
		}

		if (this.oldestRefresh == null) {
			this.oldestRefresh = refreshTime;
			return true;
		}

		if (this.oldestRefresh.after(refreshTime)) {
			this.oldestRefresh = refreshTime;
			return true;
		}

		return false;
	}

	public final String getOldestReplica() {
		return oldestReplica;
	}

	public final void setOldestReplica(final String setOldestReplica) {
		this.oldestReplica = setOldestReplica;
	}
}
