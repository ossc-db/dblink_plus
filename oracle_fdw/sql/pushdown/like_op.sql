\c contrib_regression_utf8

SET DateStyle = 'ISO,YMD';
SET IntervalStyle = 'sql_standard';
SET TIMEZONE = 'Asia/Tokyo';

-- 'LIKE' operator
-- 850 : textlike
EXPLAIN (COSTS FALSE) SELECT id FROM vc2_vc WHERE val LIKE 'aAあア亜阿';
EXPLAIN (COSTS FALSE) SELECT id FROM vc2_vc WHERE val LIKE 'a_あ%阿%';
EXPLAIN (COSTS FALSE) SELECT id FROM vc2_vc WHERE val LIKE 'aE_あE%阿E%EE';
EXPLAIN (COSTS FALSE) SELECT id FROM vc2_vc WHERE val LIKE E'a\\_あ\\%阿\\%\\\\';
EXPLAIN (COSTS FALSE) SELECT id FROM vc2_vc WHERE val LIKE 'aAあア亜阿' ESCAPE 'E';
EXPLAIN (COSTS FALSE) SELECT id FROM vc2_vc WHERE val LIKE 'a_あ%阿%' ESCAPE 'E';
EXPLAIN (COSTS FALSE) SELECT id FROM vc2_vc WHERE val LIKE E'a\\_あ\\%阿\\%\\\\' ESCAPE 'E';
EXPLAIN (COSTS FALSE) SELECT id FROM vc2_vc WHERE val LIKE 'aE_あE%阿E%EE' ESCAPE 'E';

EXPLAIN (COSTS FALSE) SELECT id FROM clob_text WHERE val LIKE 'aAあア亜阿';
EXPLAIN (COSTS FALSE) SELECT id FROM clob_text WHERE val LIKE 'a_あ%阿%';
EXPLAIN (COSTS FALSE) SELECT id FROM clob_text WHERE val LIKE 'aE_あE%阿E%EE';
EXPLAIN (COSTS FALSE) SELECT id FROM clob_text WHERE val LIKE E'a\\_あ\\%阿\\%\\\\';
EXPLAIN (COSTS FALSE) SELECT id FROM clob_text WHERE val LIKE 'aAあア亜阿' ESCAPE 'E';
EXPLAIN (COSTS FALSE) SELECT id FROM clob_text WHERE val LIKE 'a_あ%阿%' ESCAPE 'E';
EXPLAIN (COSTS FALSE) SELECT id FROM clob_text WHERE val LIKE E'a\\_あ\\%阿\\%\\\\' ESCAPE 'E';
EXPLAIN (COSTS FALSE) SELECT id FROM clob_text WHERE val LIKE 'aE_あE%阿E%EE' ESCAPE 'E';

SELECT id FROM vc2_vc WHERE val LIKE 'aAあア亜阿';
SELECT id FROM vc2_vc WHERE val LIKE 'a_あ%阿%';
SELECT id FROM vc2_vc WHERE val LIKE 'aE_あE%阿E%EE';
SELECT id FROM vc2_vc WHERE val LIKE E'a\\_あ\\%阿\\%\\\\';
SELECT id FROM vc2_vc WHERE val LIKE 'aAあア亜阿' ESCAPE 'E';
SELECT id FROM vc2_vc WHERE val LIKE 'a_あ%阿%' ESCAPE 'E';
SELECT id FROM vc2_vc WHERE val LIKE E'a\\_あ\\%阿\\%\\\\' ESCAPE 'E';
SELECT id FROM vc2_vc WHERE val LIKE 'aE_あE%阿E%EE' ESCAPE 'E';

SELECT id FROM clob_text WHERE val LIKE 'aAあア亜阿';
SELECT id FROM clob_text WHERE val LIKE 'a_あ%阿%';
SELECT id FROM clob_text WHERE val LIKE 'aE_あE%阿E%EE';
SELECT id FROM clob_text WHERE val LIKE E'a\\_あ\\%阿\\%\\\\';
SELECT id FROM clob_text WHERE val LIKE 'aAあア亜阿' ESCAPE 'E';
SELECT id FROM clob_text WHERE val LIKE 'a_あ%阿%' ESCAPE 'E';
SELECT id FROM clob_text WHERE val LIKE E'a\\_あ\\%阿\\%\\\\' ESCAPE 'E';
SELECT id FROM clob_text WHERE val LIKE 'aE_あE%阿E%EE' ESCAPE 'E';

-- 1631	: bpcharlike
EXPLAIN (COSTS FALSE) SELECT id FROM char_char WHERE val LIKE 'aAあア亜阿';
EXPLAIN (COSTS FALSE) SELECT id FROM char_char WHERE val LIKE 'a_あ%阿%';
EXPLAIN (COSTS FALSE) SELECT id FROM char_char WHERE val LIKE 'aE_あE%阿E%EE';
EXPLAIN (COSTS FALSE) SELECT id FROM char_char WHERE val LIKE E'a\\_あ\\%阿\\%\\\\';
EXPLAIN (COSTS FALSE) SELECT id FROM char_char WHERE val LIKE 'aAあア亜阿' ESCAPE 'E';
EXPLAIN (COSTS FALSE) SELECT id FROM char_char WHERE val LIKE 'a_あ%阿%' ESCAPE 'E';
EXPLAIN (COSTS FALSE) SELECT id FROM char_char WHERE val LIKE E'a\\_あ\\%阿\\%\\\\' ESCAPE 'E';
EXPLAIN (COSTS FALSE) SELECT id FROM char_char WHERE val LIKE 'aE_あE%阿E%EE' ESCAPE 'E';

SELECT id FROM char_char WHERE val LIKE 'aAあア亜阿';
SELECT id FROM char_char WHERE val LIKE 'a_あ%阿%';
SELECT id FROM char_char WHERE val LIKE 'aE_あE%阿E%EE';
SELECT id FROM char_char WHERE val LIKE E'a\\_あ\\%阿\\%\\\\';
SELECT id FROM char_char WHERE val LIKE 'aAあア亜阿' ESCAPE 'E';
SELECT id FROM char_char WHERE val LIKE 'a_あ%阿%' ESCAPE 'E';
SELECT id FROM char_char WHERE val LIKE E'a\\_あ\\%阿\\%\\\\' ESCAPE 'E';
SELECT id FROM char_char WHERE val LIKE 'aE_あE%阿E%EE' ESCAPE 'E';

EXPLAIN (COSTS FALSE) SELECT id FROM char_char WHERE val LIKE E'\\';
SELECT id FROM char_char WHERE val LIKE E'\\';
SELECT id FROM vc2_vc WHERE val LIKE E'\\';
SELECT id FROM clob_text WHERE val LIKE E'\\';

EXPLAIN (COSTS FALSE) SELECT id FROM char_char WHERE val LIKE E'\\E';
SELECT id FROM char_char WHERE val LIKE E'\\E';
SELECT id FROM vc2_vc WHERE val LIKE E'\\E';
SELECT id FROM clob_text WHERE val LIKE E'\\E';

EXPLAIN (COSTS FALSE) SELECT id FROM char_char WHERE val LIKE E'\\_';
SELECT id FROM char_char WHERE val LIKE E'\\_';
SELECT id FROM vc2_vc WHERE val LIKE E'\\_';
SELECT id FROM clob_text WHERE val LIKE E'\\_';

EXPLAIN (COSTS FALSE) SELECT id FROM char_char WHERE val LIKE E'\\%';
SELECT id FROM char_char WHERE val LIKE E'\\%';
SELECT id FROM vc2_vc WHERE val LIKE E'\\%';
SELECT id FROM clob_text WHERE val LIKE E'\\%';

EXPLAIN (COSTS FALSE) SELECT id FROM char_char WHERE val LIKE E'\\\\';
SELECT id FROM char_char WHERE val LIKE E'\\\\';
SELECT id FROM vc2_vc WHERE val LIKE E'\\\\';
SELECT id FROM clob_text WHERE val LIKE E'\\\\';

SELECT id FROM char_char WHERE val LIKE '%';
SELECT id FROM char_char WHERE val LIKE 'aaaあああaaaあああaあaあ''''''\_\_\_\%\%\%                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       ';
SELECT id FROM char_char WHERE val LIKE 'aaaあああaaaあああaあaあ''''''\_\_\_\%\%\%%';
