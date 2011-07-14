package jp.co.ntt.oss;

/*
 * refresh mode option
 */
public enum RefreshMode {
	FULL, // full refresh
	INCREMENTAL, // incremental refresh
	AUTO; // choose a refresh method of fast one in full and incremental
}
