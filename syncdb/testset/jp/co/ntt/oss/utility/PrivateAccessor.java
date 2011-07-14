package jp.co.ntt.oss.utility;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.fail;

import java.lang.reflect.Field;
import java.lang.reflect.Method;

public class PrivateAccessor {
	public static Object getPrivateField(Object x, String fieldName) {
		assertNotNull(x);
		assertNotNull(fieldName);
		Field fields[] = x.getClass().getDeclaredFields();
		for (int i = 0; i < fields.length; i++) {
			if (fieldName.equals(fields[i].getName())) {
				try {
					fields[i].setAccessible(true);
					return fields[i].get(x);
				} catch (IllegalAccessException e) {
					fail("IllegalAccessException accessing " + fieldName);
				}
			}
		}

		fail("Field '" + fieldName + "' not found");
		return null;
	}

	public static void setPrivateField(Object x, String fieldName, Object value) {
		assertNotNull(x);
		assertNotNull(fieldName);
		Field fields[] = x.getClass().getDeclaredFields();
		for (int i = 0; i < fields.length; i++) {
			if (fieldName.equals(fields[i].getName())) {
				try {
					fields[i].setAccessible(true);
					fields[i].set(x, value);
					return;
				} catch (IllegalAccessException e) {
					fail("IllegalAccessException accessing " + fieldName);
				}
			}
		}

		fail("Field '" + fieldName + "' not found");
	}

	public static Method getPrivateMethod(Object x, String methodName) {
		assertNotNull(x);
		assertNotNull(methodName);
		Method methods[] = x.getClass().getDeclaredMethods();
		for (int i = 0; i < methods.length; i++) {
			if (methodName.equals(methods[i].getName())) {
				methods[i].setAccessible(true);
				return methods[i];
			}
		}

		fail("Method '" + methodName + "' not found");
		return null;
	}
}
