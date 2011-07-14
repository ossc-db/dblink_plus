package jp.co.ntt.oss.data;

import java.sql.Timestamp;

public class Subscription {
	public static final long NOT_HAVE_SUBSCRIBER = 0;

	private String schema = null;
	private String table = null;
	private String replicaTable = null;
	private String attachuser = null;
	private long subsID = 0;
	private String srvname = null;
	private String query = null;
	private Timestamp lastTime = null;
	private String lastType = null;

	public Subscription(final String setSchema, final String setTable,
			final String setReplicaTable, final String setAttachuser,
			final long setSubsID, final String setSrvname,
			final String setQuery, final Timestamp setLastTime,
			final String setLastType) {
		this.schema = setSchema;
		this.table = setTable;
		this.replicaTable = setReplicaTable;
		this.attachuser = setAttachuser;
		this.subsID = setSubsID;
		this.srvname = setSrvname;
		this.query = setQuery;
		this.lastTime = setLastTime;
		this.lastType = setLastType;
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

	public final String getReplicaTable() {
		return replicaTable;
	}

	public final void setReplicaTable(final String setSeplicaTable) {
		this.replicaTable = setSeplicaTable;
	}

	public final String getAttachuser() {
		return attachuser;
	}

	public final void setAttachuser(final String setAttachuser) {
		this.attachuser = setAttachuser;
	}

	public final long getSubsID() {
		return subsID;
	}

	public final void setSubsID(final long setSubsID) {
		this.subsID = setSubsID;
	}

	public final String getSrvname() {
		return srvname;
	}

	public final void setSrvname(final String setSrvname) {
		this.srvname = setSrvname;
	}

	public final String getQuery() {
		return query;
	}

	public final void setQuery(final String setQuery) {
		this.query = setQuery;
	}

	public final Timestamp getLastTime() {
		return lastTime;
	}

	public final void setLastTime(final Timestamp setLastTime) {
		this.lastTime = setLastTime;
	}

	public final String getLastType() {
		return lastType;
	}

	public final void setLastType(final String setLastType) {
		this.lastType = setLastType;
	}
}
