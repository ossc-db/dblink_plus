package jp.co.ntt.oss.data;

import java.sql.Timestamp;

public class Subscriber {
	public static final int NO_REFRESH = -1;

	private long subsID = 0;
	private String nspName = null;
	private String relName = null;
	private String masterTableName = null;
	private String mlogName = null;
	private String createUser = null;
	private String attachUser = null;
	private String description = null;
	private Timestamp lastTime = null;
	private String lastType = null;
	private long lastMlogID = 0;
	private long lastCount = 0;

	public Subscriber(final long setSubsID, final String setNspName,
			final String setRelName, final String setMasterTableName,
			final String setMlogName, final String setCreateUser,
			final String setAttachUser, final String setDescription,
			final Timestamp setLastTime, final String setLastType,
			final long setLastMlogID, final long setLastCount) {
		this.subsID = setSubsID;
		this.nspName = setNspName;
		this.relName = setRelName;
		this.masterTableName = setMasterTableName;
		this.mlogName = setMlogName;
		this.createUser = setCreateUser;
		this.attachUser = setAttachUser;
		this.description = setDescription;
		this.lastTime = setLastTime;
		this.lastType = setLastType;
		this.lastMlogID = setLastMlogID;
		this.lastCount = setLastCount;
	}

	public final long getSubsID() {
		return subsID;
	}

	public final void setSubsID(final long setSubsID) {
		this.subsID = setSubsID;
	}

	public final String getNspName() {
		return nspName;
	}

	public final void setNspName(final String setNspName) {
		this.nspName = setNspName;
	}

	public final String getRelName() {
		return relName;
	}

	public final void setRelName(final String setRelName) {
		this.relName = setRelName;
	}

	public final String getMasterTableName() {
		return masterTableName;
	}

	public final void setMasterTableName(final String setMasterTableName) {
		this.masterTableName = setMasterTableName;
	}

	public final String getMlogName() {
		return mlogName;
	}

	public final void setMlogName(final String setMlogName) {
		this.mlogName = setMlogName;
	}

	public final String getCreateUser() {
		return createUser;
	}

	public final void setCreateUser(final String setCreateUser) {
		this.createUser = setCreateUser;
	}

	public final String getAttachUser() {
		return attachUser;
	}

	public final void setAttachUser(final String setAttachUser) {
		this.attachUser = setAttachUser;
	}

	public final String getDescription() {
		return description;
	}

	public final void setDescription(final String setDescription) {
		this.description = setDescription;
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

	public final long getLastMlogID() {
		return lastMlogID;
	}

	public final void setLastMlogID(final long setLastMlogID) {
		this.lastMlogID = setLastMlogID;
	}

	public final long getLastCount() {
		return lastCount;
	}

	public final void setLastCount(final long setLastCount) {
		this.lastCount = setLastCount;
	}
}
