package jp.co.ntt.oss.mapper;

import java.sql.Types;

import jp.co.ntt.oss.SyncDatabaseException;

import org.apache.log4j.Logger;

public class MappingData {
	private static Logger log = Logger.getLogger(MappingData.class);

	private int columnCount;
	private DataMapper[] dms = null;
	private int[] columnTypes = null;
	private String[] columnTypeNames = null;

	public MappingData(final int setColumnCount) throws SyncDatabaseException {
		if (setColumnCount < 1) {
			throw new SyncDatabaseException("error.argument");
		}

		this.columnCount = setColumnCount;
		dms = new DataMapper[setColumnCount];
		columnTypes = new int[setColumnCount];
		columnTypeNames = new String[setColumnCount];
	}

	public final int getColumnCount() {
		return columnCount;
	}

	public final DataMapper[] getDataMappers() {
		return dms;
	}

	public final void setDataMappers(final DataMapper[] dataMappers) {
		this.dms = dataMappers;
	}

	public final DataMapper getDataMapper(final int index)
			throws SyncDatabaseException {
		if (index < 0 || index >= this.columnCount) {
			throw new SyncDatabaseException("error.argument");
		}

		return dms[index];
	}

	public final void setDataMapper(final int index, final DataMapper dataMapper)
			throws SyncDatabaseException {
		if (index < 0 || index >= this.columnCount || dataMapper == null) {
			throw new SyncDatabaseException("error.argument");
		}

		this.dms[index] = dataMapper;
	}

	public final int getColumnType(final int index)
			throws SyncDatabaseException {
		if (index < 0 || index >= this.columnCount) {
			throw new SyncDatabaseException("error.argument");
		}

		return columnTypes[index];
	}

	public final void setColumnType(final int index, final int columnType)
			throws SyncDatabaseException {
		if (index < 0 || index >= this.columnCount) {
			throw new SyncDatabaseException("error.argument");
		}

		this.columnTypes[index] = columnType;
	}

	public final String getColumnTypeName(final int index)
			throws SyncDatabaseException {
		if (index < 0 || index >= this.columnCount) {
			throw new SyncDatabaseException("error.argument");
		}

		return columnTypeNames[index];
	}

	public final void setColumnTypeName(final int index,
			final String columnTypeName) throws SyncDatabaseException {
		if (index < 0 || index >= this.columnCount || columnTypeName == null) {
			throw new SyncDatabaseException("error.argument");
		}

		this.columnTypeNames[index] = columnTypeName;
	}

	public static void createDataMappers(final MappingData fromData,
			final MappingData toData) throws SyncDatabaseException {
		if (fromData == null || toData == null
				|| fromData.getColumnCount() != toData.getColumnCount()) {
			throw new SyncDatabaseException("error.argument");
		}

		for (int i = 0; i < fromData.getColumnCount(); i++) {
			int fromType = fromData.getColumnType(i);
			int toType = toData.getColumnType(i);
			DataMapper fromDataMapper = null;
			DataMapper toDataMapper = null;
			log.debug(fromType + " / " + toType);

			if (ArrayDataMapper.isArrayType(fromType)) {
				if (ArrayDataMapper.isArrayType(toType)) {
					// Array Type
					fromDataMapper = new ArrayDataMapper();
					toDataMapper = new ArrayDataMapper();
				}
			} else if (BigDecimalDataMapper.isBigDecimalType(fromType)) {
				if (BigDecimalDataMapper.isBigDecimalType(toType)) {
					// BigDecimal Type
					fromDataMapper = new BigDecimalDataMapper();
					toDataMapper = new BigDecimalDataMapper();
				}
			} else if (BlobDataMapper.isBlobType(fromType)) {
				if (BlobDataMapper.isBlobType(toType)) {
					// Blob Type
					fromDataMapper = new BlobDataMapper();
					toDataMapper = new BlobDataMapper();
				}
			} else if (BooleanDataMapper.isBooleanType(fromType)) {
				if (BooleanDataMapper.isBooleanType(toType)) {
					// Boolean Type
					fromDataMapper = new BooleanDataMapper();
					toDataMapper = new BooleanDataMapper();
					((BooleanDataMapper) fromDataMapper).setType(fromType);
					((BooleanDataMapper) toDataMapper).setType(toType);
				}
			} else if (BytesDataMapper.isBytesType(fromType)) {
				if (BytesDataMapper.isBytesType(toType)) {
					// Bytes Type
					fromDataMapper = new BytesDataMapper();
					toDataMapper = new BytesDataMapper();
				}
			} else if (ClobDataMapper.isClobType(fromType)) {
				if (ClobDataMapper.isClobType(toType)) {
					// Clob Type
					fromDataMapper = new ClobDataMapper();
					toDataMapper = new ClobDataMapper();
				}
			} else if (DateDataMapper.isDateType(fromType)) {
				if (DateDataMapper.isDateType(toType)) {
					// Date Type
					fromDataMapper = new DateDataMapper();
					toDataMapper = new DateDataMapper();
				}
			} else if (DoubleDataMapper.isDoubleType(fromType)) {
				if (DoubleDataMapper.isDoubleType(toType)) {
					// Double Type
					fromDataMapper = new DoubleDataMapper();
					toDataMapper = new DoubleDataMapper();
					((DoubleDataMapper) fromDataMapper).setType(fromType);
					((DoubleDataMapper) toDataMapper).setType(toType);
				}
			} else if (FloatDataMapper.isFloatType(fromType)) {
				if (FloatDataMapper.isFloatType(toType)) {
					// Float Type
					fromDataMapper = new FloatDataMapper();
					toDataMapper = new FloatDataMapper();
					((FloatDataMapper) fromDataMapper).setType(fromType);
					((FloatDataMapper) toDataMapper).setType(toType);
				}
			} else if (IntegerDataMapper.isIntegerType(fromType)) {
				if (IntegerDataMapper.isIntegerType(toType)) {
					// Integer Type
					fromDataMapper = new IntegerDataMapper();
					toDataMapper = new IntegerDataMapper();
					((IntegerDataMapper) fromDataMapper).setType(fromType);
					((IntegerDataMapper) toDataMapper).setType(toType);
				}
			} else if (LongDataMapper.isLongType(fromType)) {
				if (LongDataMapper.isLongType(toType)) {
					// Long Type
					fromDataMapper = new LongDataMapper();
					toDataMapper = new LongDataMapper();
					((LongDataMapper) fromDataMapper).setType(fromType);
					((LongDataMapper) toDataMapper).setType(toType);
				}
			} else if (NClobDataMapper.isNClobType(fromType)) {
				if (NClobDataMapper.isNClobType(toType)) {
					// NClob Type
					fromDataMapper = new NClobDataMapper();
					toDataMapper = new NClobDataMapper();
				}
			} else if (RefDataMapper.isRefType(fromType)) {
				if (RefDataMapper.isRefType(toType)) {
					// NString Type
					fromDataMapper = new RefDataMapper();
					toDataMapper = new RefDataMapper();
				}
			} else if (RowIdDataMapper.isRowIdType(fromType)) {
				if (RowIdDataMapper.isRowIdType(toType)) {
					// RowId Type
					fromDataMapper = new RowIdDataMapper();
					toDataMapper = new RowIdDataMapper();
				}
			} else if (SQLXMLDataMapper.isSQLXMLType(fromType)) {
				if (SQLXMLDataMapper.isSQLXMLType(toType)) {
					// SQLXML Type
					fromDataMapper = new SQLXMLDataMapper();
					toDataMapper = new SQLXMLDataMapper();
				}
			} else if (StringDataMapper.isStringType(fromType)) {
				if (StringDataMapper.isStringType(toType)) {
					// String Type
					fromDataMapper = new StringDataMapper();
					toDataMapper = new StringDataMapper();
				}
			} else if (StructDataMapper.isStructType(fromType)) {
				if (StructDataMapper.isStructType(toType)) {
					// Struct Type
					fromDataMapper = new StructDataMapper();
					toDataMapper = new StructDataMapper();
				}
			} else if (TimeDataMapper.isTimeType(fromType)) {
				if (TimeDataMapper.isTimeType(toType)) {
					// Time Type
					fromDataMapper = new TimeDataMapper();
					toDataMapper = new TimeDataMapper();
				}
			} else if (TimestampDataMapper.isTimestampType(fromType)) {
				if (TimestampDataMapper.isTimestampType(toType)) {
					// Timestamp Type
					fromDataMapper = new TimestampDataMapper();
					toDataMapper = new TimestampDataMapper();
				}
			} else if (URLDataMapper.isURLType(fromType)) {
				if (URLDataMapper.isURLType(toType)) {
					// URL Type
					fromDataMapper = new URLDataMapper();
					toDataMapper = new URLDataMapper();
				}
			} else if (fromType != Types.OTHER && toType != Types.OTHER
					&& fromType == toType) {
				// Type same as not OTHER type toType and toType
				fromDataMapper = new ObjectDataMapper();
				toDataMapper = new ObjectDataMapper();
			}

			if (fromDataMapper == null || toDataMapper == null) {
				// Other Type
				fromDataMapper = new OtherDataMapper();
				toDataMapper = new OtherDataMapper();
			}

			fromData.setDataMapper(i, fromDataMapper);
			toData.setDataMapper(i, toDataMapper);
		}
	}
}
