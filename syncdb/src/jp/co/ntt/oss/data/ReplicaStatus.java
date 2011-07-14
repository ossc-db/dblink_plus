package jp.co.ntt.oss.data;

import java.sql.Timestamp;

public class ReplicaStatus {
	public static final int REPLICASTATUS_SCHEMA = 0;
	public static final int REPLICASTATUS_TABLE = 1;
	public static final int REPLICASTATUS_LAST_REFRESH = 2;
	public static final int REPLICASTATUS_MASTER = 3;
	public static final int REPLICASTATUS_COST = 4;
	public static final int REPLICASTATUS_COLUMNS = 5;
	public static final String[] HEADERS = { "schema", "table", "last refresh",
			"master", "cost" };

	private String schema;
	private String table;
	private Timestamp lastRefresh;
	private String master;
	private long subsID;

	public ReplicaStatus(final String setSchema, final String setTable,
			final Timestamp setLastRefresh, final String setMaster,
			final long setSubsID) {
		this.schema = setSchema;
		this.table = setTable;
		this.lastRefresh = setLastRefresh;
		this.master = setMaster;
		this.subsID = setSubsID;
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

	public final Timestamp getLastRefresh() {
		return lastRefresh;
	}

	public final void setLastRefresh(final Timestamp setLastRefresh) {
		this.lastRefresh = setLastRefresh;
	}

	public final String getMaster() {
		return master;
	}

	public final void setMaster(final String setMaster) {
		this.master = setMaster;
	}

	public final long getSubsID() {
		return subsID;
	}

	public final void setSubsID(final long setSubsID) {
		this.subsID = setSubsID;
	}
}