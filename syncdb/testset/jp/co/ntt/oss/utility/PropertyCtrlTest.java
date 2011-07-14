package jp.co.ntt.oss.utility;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import org.junit.Test;

public class PropertyCtrlTest {

	@Test
	public final void testGetInstance() {
		PropertyCtrl pctl1 = PropertyCtrl.getInstance();
		assertNotNull(pctl1);
		PropertyCtrl pctl2 = PropertyCtrl.getInstance();
		assertNotNull(pctl2);
		assertEquals(pctl1, pctl2);
	}

	@Test
	public final void testGetMessage() {
		String actual;

		PropertyCtrl pctl = PropertyCtrl.getInstance();
		// normal case
		actual = pctl.getMessage("error.not_implement", "aaa");
		assertEquals("aaa is not implement", actual);

		// null argument
		actual = pctl.getMessage(null);
		assertEquals("log message not found", actual);

		// argument error
		actual = pctl.getMessage("error.not_implement");
		assertEquals("{0} is not implement", actual);

		// argument over
		actual = pctl.getMessage("error.not_implement", "aaa", "bbb");
		assertEquals("aaa is not implement", actual);

		// no property
		actual = pctl.getMessage("no_message");
		assertEquals("log message not found", actual);
	}
}
