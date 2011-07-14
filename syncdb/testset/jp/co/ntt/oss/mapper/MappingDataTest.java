package jp.co.ntt.oss.mapper;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.fail;

import java.sql.Types;

import jp.co.ntt.oss.SyncDatabaseException;
import jp.co.ntt.oss.utility.PrivateAccessor;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class MappingDataTest {

	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {
	}

	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public final void testMappingData() {
		String actual;

		// invalid argument
		try {
			new MappingData(0);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			actual = e.getMessage();
			assertEquals("argument error", actual);
		}

		// normal case
		try {
			MappingData mappingData = new MappingData(1);
			assertNotNull(mappingData);

			int columnCount = ((Integer) PrivateAccessor.getPrivateField(
					mappingData, "columnCount")).intValue();
			assertNotNull(columnCount);
			assertEquals(1, columnCount);

			DataMapper[] dms = (DataMapper[]) PrivateAccessor.getPrivateField(
					mappingData, "dms");
			assertNotNull(dms);
			assertEquals(1, dms.length);

			int[] columnTypes = (int[]) PrivateAccessor.getPrivateField(
					mappingData, "columnTypes");
			assertNotNull(columnTypes);
			assertEquals(1, columnTypes.length);

			String[] columnTypeNames = (String[]) PrivateAccessor
					.getPrivateField(mappingData, "columnTypeNames");
			assertNotNull(columnTypeNames);
			assertEquals(1, columnTypeNames.length);
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetColumnCount() {
		MappingData mappingData = null;
		try {
			mappingData = new MappingData(1);
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}

		// normal case
		assertEquals(1, mappingData.getColumnCount());
	}

	@Test
	public final void testGetDataMappers() {
		MappingData mappingData = null;
		try {
			mappingData = new MappingData(1);
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}

		// normal case
		DataMapper[] dms = mappingData.getDataMappers();
		assertNotNull(dms);
		assertEquals(1, dms.length);
	}

	@Test
	public final void testSetDataMappers() {
		// normal case
		MappingData mappingData = null;
		try {
			mappingData = new MappingData(1);
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}

		DataMapper[] dms = mappingData.getDataMappers();
		assertNotNull(dms);
		assertEquals(1, dms.length);
	}

	@Test
	public final void testGetDataMapper() {
		MappingData mappingData = null;

		DataMapper[] dms = new DataMapper[2];
		dms[0] = new IntegerDataMapper();
		dms[1] = new StringDataMapper();

		try {
			mappingData = new MappingData(2);
			PrivateAccessor.setPrivateField(mappingData, "dms", dms);
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}

		DataMapper dataMapper = null;

		// argument error
		try {
			mappingData.getDataMapper(-1);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			mappingData.getDataMapper(2);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}

		// normal case
		try {
			dataMapper = mappingData.getDataMapper(0);
			assertNotNull(dataMapper);
			assertEquals("jp.co.ntt.oss.mapper.IntegerDataMapper", dataMapper
					.getClass().getName());

			dataMapper = mappingData.getDataMapper(1);
			assertNotNull(dataMapper);
			assertEquals("jp.co.ntt.oss.mapper.StringDataMapper", dataMapper
					.getClass().getName());
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetDataMapper() {
		MappingData mappingData = null;

		try {
			mappingData = new MappingData(2);
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}

		DataMapper dataMapper = null;

		// argument error
		try {
			mappingData.setDataMapper(-1, new TimeDataMapper());
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			mappingData.setDataMapper(2, new TimeDataMapper());
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			mappingData.setDataMapper(0, null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}

		// normal case
		try {
			mappingData.setDataMapper(0, new IntegerDataMapper());
			mappingData.setDataMapper(1, new StringDataMapper());
			dataMapper = mappingData.getDataMapper(0);
			assertNotNull(dataMapper);
			assertEquals("jp.co.ntt.oss.mapper.IntegerDataMapper", dataMapper
					.getClass().getName());

			dataMapper = mappingData.getDataMapper(1);
			assertNotNull(dataMapper);
			assertEquals("jp.co.ntt.oss.mapper.StringDataMapper", dataMapper
					.getClass().getName());
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetColumnType() {
		MappingData mappingData = null;

		int[] columnTypes = new int[2];
		columnTypes[0] = Types.INTEGER;
		columnTypes[1] = Types.VARCHAR;

		try {
			mappingData = new MappingData(2);
			PrivateAccessor.setPrivateField(mappingData, "columnTypes",
					columnTypes);
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}

		int columnType;

		// argument error
		try {
			mappingData.getColumnType(-1);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			mappingData.getColumnType(2);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}

		// normal case
		try {
			columnType = mappingData.getColumnType(0);
			assertEquals(Types.INTEGER, columnType);

			columnType = mappingData.getColumnType(1);
			assertEquals(Types.VARCHAR, columnType);
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetColumnType() {
		MappingData mappingData = null;

		try {
			mappingData = new MappingData(2);
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}

		int columnType;

		// argument error
		try {
			mappingData.setColumnType(-1, Types.TIMESTAMP);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			mappingData.setColumnType(2, Types.TIMESTAMP);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}

		// normal case
		try {
			mappingData.setColumnType(0, Types.INTEGER);
			mappingData.setColumnType(1, Types.VARCHAR);

			columnType = mappingData.getColumnType(0);
			assertEquals(Types.INTEGER, columnType);

			columnType = mappingData.getColumnType(1);
			assertEquals(Types.VARCHAR, columnType);
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testGetColumnTypeName() {
		MappingData mappingData = null;

		String[] columnTypeNames = new String[2];
		columnTypeNames[0] = "integer";
		columnTypeNames[1] = "text";

		try {
			mappingData = new MappingData(2);
			PrivateAccessor.setPrivateField(mappingData, "columnTypeNames",
					columnTypeNames);
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}

		String columnTypeName;

		// argument error
		try {
			mappingData.getColumnTypeName(-1);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			mappingData.getColumnTypeName(2);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}

		// normal case
		try {
			columnTypeName = mappingData.getColumnTypeName(0);
			assertEquals("integer", columnTypeName);

			columnTypeName = mappingData.getColumnTypeName(1);
			assertEquals("text", columnTypeName);
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testSetColumnTypeName() {
		MappingData mappingData = null;

		try {
			mappingData = new MappingData(2);
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}

		String columnTypeName;

		// argument error
		try {
			mappingData.setColumnTypeName(-1, "timestamp");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			mappingData.setColumnTypeName(2, "timestamp");
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			mappingData.setColumnTypeName(0, null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}

		// normal case
		try {
			mappingData.setColumnTypeName(0, "integer");
			mappingData.setColumnTypeName(1, "text");

			columnTypeName = mappingData.getColumnTypeName(0);
			assertEquals("integer", columnTypeName);

			columnTypeName = mappingData.getColumnTypeName(1);
			assertEquals("text", columnTypeName);
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}
	}

	@Test
	public final void testCreateDataMappers() {
		MappingData fromData = null;
		MappingData toData1 = null;
		MappingData toData2 = null;
		MappingData ngData = null;
		try {
			fromData = new MappingData(22);
			toData1 = new MappingData(22);
			toData2 = new MappingData(22);
			ngData = new MappingData(1);

			fromData.setColumnType(0, Types.ARRAY);
			fromData.setColumnType(1, Types.DECIMAL);
			fromData.setColumnType(2, Types.BLOB);
			fromData.setColumnType(3, Types.BIT);
			fromData.setColumnType(4, Types.BINARY);
			fromData.setColumnType(5, Types.CLOB);
			fromData.setColumnType(6, Types.DATE);
			fromData.setColumnType(7, Types.DOUBLE);
			fromData.setColumnType(8, Types.REAL);
			fromData.setColumnType(9, Types.INTEGER);
			fromData.setColumnType(10, Types.BIGINT);
			fromData.setColumnType(11, Types.NCLOB);
			fromData.setColumnType(12, Types.REF);
			fromData.setColumnType(13, Types.ROWID);
			fromData.setColumnType(14, Types.SQLXML);
			fromData.setColumnType(15, Types.CHAR);
			fromData.setColumnType(16, Types.STRUCT);
			fromData.setColumnType(17, Types.TIME);
			fromData.setColumnType(18, Types.TIMESTAMP);
			fromData.setColumnType(19, Types.DATALINK);
			fromData.setColumnType(20, -1111);
			fromData.setColumnType(21, Types.OTHER);
			toData1.setColumnType(0, Types.ARRAY);
			toData1.setColumnType(1, Types.DECIMAL);
			toData1.setColumnType(2, Types.BLOB);
			toData1.setColumnType(3, Types.BIT);
			toData1.setColumnType(4, Types.BINARY);
			toData1.setColumnType(5, Types.CLOB);
			toData1.setColumnType(6, Types.DATE);
			toData1.setColumnType(7, Types.DOUBLE);
			toData1.setColumnType(8, Types.REAL);
			toData1.setColumnType(9, Types.INTEGER);
			toData1.setColumnType(10, Types.BIGINT);
			toData1.setColumnType(11, Types.NCLOB);
			toData1.setColumnType(12, Types.REF);
			toData1.setColumnType(13, Types.ROWID);
			toData1.setColumnType(14, Types.SQLXML);
			toData1.setColumnType(15, Types.CHAR);
			toData1.setColumnType(16, Types.STRUCT);
			toData1.setColumnType(17, Types.TIME);
			toData1.setColumnType(18, Types.TIMESTAMP);
			toData1.setColumnType(19, Types.DATALINK);
			toData1.setColumnType(20, -1111);
			toData1.setColumnType(21, Types.OTHER);
			toData2.setColumnType(1, Types.ARRAY);
			toData2.setColumnType(2, Types.DECIMAL);
			toData2.setColumnType(3, Types.BLOB);
			toData2.setColumnType(4, Types.BIT);
			toData2.setColumnType(5, Types.BINARY);
			toData2.setColumnType(6, Types.CLOB);
			toData2.setColumnType(7, Types.DATE);
			toData2.setColumnType(8, Types.DOUBLE);
			toData2.setColumnType(9, Types.REAL);
			toData2.setColumnType(10, Types.INTEGER);
			toData2.setColumnType(11, Types.BIGINT);
			toData2.setColumnType(12, Types.NCLOB);
			toData2.setColumnType(13, Types.REF);
			toData2.setColumnType(14, Types.ROWID);
			toData2.setColumnType(15, Types.SQLXML);
			toData2.setColumnType(16, Types.CHAR);
			toData2.setColumnType(17, Types.STRUCT);
			toData2.setColumnType(18, Types.TIME);
			toData2.setColumnType(19, Types.TIMESTAMP);
			toData2.setColumnType(20, Types.DATALINK);
			toData2.setColumnType(21, -1111);
			toData2.setColumnType(0, Types.OTHER);
		} catch (SyncDatabaseException e) {
			fail("exception thrown");
		}

		// argument error
		try {
			MappingData.createDataMappers(null, toData1);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			MappingData.createDataMappers(fromData, null);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}
		try {
			MappingData.createDataMappers(fromData, ngData);
			fail("no exception");
		} catch (SyncDatabaseException e) {
			assertEquals("argument error", e.getMessage());
		}

		// normal case
		Integer type;
		try {
			MappingData.createDataMappers(fromData, toData1);

			assertEquals("jp.co.ntt.oss.mapper.ArrayDataMapper", fromData
					.getDataMapper(0).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.BigDecimalDataMapper", fromData
					.getDataMapper(1).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.BlobDataMapper", fromData
					.getDataMapper(2).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.BooleanDataMapper", fromData
					.getDataMapper(3).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.BytesDataMapper", fromData
					.getDataMapper(4).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.ClobDataMapper", fromData
					.getDataMapper(5).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.DateDataMapper", fromData
					.getDataMapper(6).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.DoubleDataMapper", fromData
					.getDataMapper(7).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.FloatDataMapper", fromData
					.getDataMapper(8).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.IntegerDataMapper", fromData
					.getDataMapper(9).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.LongDataMapper", fromData
					.getDataMapper(10).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.NClobDataMapper", fromData
					.getDataMapper(11).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.RefDataMapper", fromData
					.getDataMapper(12).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.RowIdDataMapper", fromData
					.getDataMapper(13).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.SQLXMLDataMapper", fromData
					.getDataMapper(14).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.StringDataMapper", fromData
					.getDataMapper(15).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.StructDataMapper", fromData
					.getDataMapper(16).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.TimeDataMapper", fromData
					.getDataMapper(17).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.TimestampDataMapper", fromData
					.getDataMapper(18).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.URLDataMapper", fromData
					.getDataMapper(19).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.ObjectDataMapper", fromData
					.getDataMapper(20).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", fromData
					.getDataMapper(21).getClass().getName());

			assertEquals("jp.co.ntt.oss.mapper.ArrayDataMapper", toData1
					.getDataMapper(0).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.BigDecimalDataMapper", toData1
					.getDataMapper(1).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.BlobDataMapper", toData1
					.getDataMapper(2).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.BooleanDataMapper", toData1
					.getDataMapper(3).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.BytesDataMapper", toData1
					.getDataMapper(4).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.ClobDataMapper", toData1
					.getDataMapper(5).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.DateDataMapper", toData1
					.getDataMapper(6).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.DoubleDataMapper", toData1
					.getDataMapper(7).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.FloatDataMapper", toData1
					.getDataMapper(8).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.IntegerDataMapper", toData1
					.getDataMapper(9).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.LongDataMapper", toData1
					.getDataMapper(10).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.NClobDataMapper", toData1
					.getDataMapper(11).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.RefDataMapper", toData1
					.getDataMapper(12).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.RowIdDataMapper", toData1
					.getDataMapper(13).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.SQLXMLDataMapper", toData1
					.getDataMapper(14).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.StringDataMapper", toData1
					.getDataMapper(15).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.StructDataMapper", toData1
					.getDataMapper(16).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.TimeDataMapper", toData1
					.getDataMapper(17).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.TimestampDataMapper", toData1
					.getDataMapper(18).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.URLDataMapper", toData1
					.getDataMapper(19).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.ObjectDataMapper", toData1
					.getDataMapper(20).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", toData1
					.getDataMapper(21).getClass().getName());

			type = (Integer) PrivateAccessor.getPrivateField(fromData
					.getDataMapper(3), "type");
			assertNotNull(type);
			assertEquals(Types.BIT, type.intValue());
			type = (Integer) PrivateAccessor.getPrivateField(fromData
					.getDataMapper(7), "type");
			assertNotNull(type);
			assertEquals(Types.DOUBLE, type.intValue());
			type = (Integer) PrivateAccessor.getPrivateField(fromData
					.getDataMapper(8), "type");
			assertNotNull(type);
			assertEquals(Types.REAL, type.intValue());
			type = (Integer) PrivateAccessor.getPrivateField(fromData
					.getDataMapper(9), "type");
			assertNotNull(type);
			assertEquals(Types.INTEGER, type.intValue());
			type = (Integer) PrivateAccessor.getPrivateField(fromData
					.getDataMapper(10), "type");
			assertNotNull(type);
			assertEquals(Types.BIGINT, type.intValue());

			type = (Integer) PrivateAccessor.getPrivateField(toData1
					.getDataMapper(3), "type");
			assertNotNull(type);
			assertEquals(Types.BIT, type.intValue());
			type = (Integer) PrivateAccessor.getPrivateField(toData1
					.getDataMapper(7), "type");
			assertNotNull(type);
			assertEquals(Types.DOUBLE, type.intValue());
			type = (Integer) PrivateAccessor.getPrivateField(toData1
					.getDataMapper(8), "type");
			assertNotNull(type);
			assertEquals(Types.REAL, type.intValue());
			type = (Integer) PrivateAccessor.getPrivateField(toData1
					.getDataMapper(9), "type");
			assertNotNull(type);
			assertEquals(Types.INTEGER, type.intValue());
			type = (Integer) PrivateAccessor.getPrivateField(toData1
					.getDataMapper(10), "type");
			assertNotNull(type);
			assertEquals(Types.BIGINT, type.intValue());

			MappingData.createDataMappers(fromData, toData2);

			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", fromData
					.getDataMapper(0).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", fromData
					.getDataMapper(1).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", fromData
					.getDataMapper(2).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", fromData
					.getDataMapper(3).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", fromData
					.getDataMapper(4).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", fromData
					.getDataMapper(5).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", fromData
					.getDataMapper(6).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", fromData
					.getDataMapper(7).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", fromData
					.getDataMapper(8).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", fromData
					.getDataMapper(9).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", fromData
					.getDataMapper(10).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", fromData
					.getDataMapper(11).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", fromData
					.getDataMapper(12).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", fromData
					.getDataMapper(13).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", fromData
					.getDataMapper(14).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", fromData
					.getDataMapper(15).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", fromData
					.getDataMapper(16).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", fromData
					.getDataMapper(17).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", fromData
					.getDataMapper(18).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", fromData
					.getDataMapper(19).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", fromData
					.getDataMapper(20).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", fromData
					.getDataMapper(21).getClass().getName());

			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", toData2
					.getDataMapper(0).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", toData2
					.getDataMapper(1).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", toData2
					.getDataMapper(2).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", toData2
					.getDataMapper(3).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", toData2
					.getDataMapper(4).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", toData2
					.getDataMapper(5).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", toData2
					.getDataMapper(6).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", toData2
					.getDataMapper(7).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", toData2
					.getDataMapper(8).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", toData2
					.getDataMapper(9).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", toData2
					.getDataMapper(10).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", toData2
					.getDataMapper(11).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", toData2
					.getDataMapper(12).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", toData2
					.getDataMapper(13).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", toData2
					.getDataMapper(14).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", toData2
					.getDataMapper(15).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", toData2
					.getDataMapper(16).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", toData2
					.getDataMapper(17).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", toData2
					.getDataMapper(18).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", toData2
					.getDataMapper(19).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", toData2
					.getDataMapper(20).getClass().getName());
			assertEquals("jp.co.ntt.oss.mapper.OtherDataMapper", toData2
					.getDataMapper(21).getClass().getName());

		} catch (Exception e) {
			fail("exception thrown");
		}
	}
}
