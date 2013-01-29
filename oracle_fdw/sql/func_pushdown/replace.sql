\c contrib_regression_utf8

-- replace
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_char_b WHERE replace(val1, 'a', 'A') = 'AbcbA' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE replace(val1, 'a', 'A') = 'AbcbA' ORDER BY id;
EXPLAIN (COSTS FALSE) 
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE replace(val1, 'a', 'A') = 'AbcbA' ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE replace(val1, 'a', 'A') = 'AbcbA' ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE replace(val1, '', 'ABC') = 'abcba' ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE replace(val1, '', 'ABC') = 'abcba' ORDER BY id;

EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_char_b WHERE replace(val1, NULL, 'ABC') IS NULL ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE replace(val1, NULL, 'ABC') IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE replace(val1, NULL, 'ABC') IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE replace(val1, 'abc', '') IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE replace(val1, 'abc', '') IS NULL ORDER BY id;

EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_char_b WHERE replace(val1, 'abc', NULL) IS NULL ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE replace(val1, 'abc', NULL) IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE replace(val1, 'abc', NULL) IS NULL ORDER BY id;

--
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_char_b WHERE replace('AAabcbaAA', val1, 'X') = 'AAXAA' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE replace('AAabcbaAA', val1, 'X') = 'AAXAA' ORDER BY id;
EXPLAIN (COSTS FALSE) 
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE replace('AAabcbaAA', val1, 'X') = 'AAXAA' ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE replace('AAabcbaAA', val1, 'X') = 'AAXAA' ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE replace('', val1, 'X') IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE replace('', val1, 'X') IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE replace('', val1, '') IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE replace('', val1, '') IS NULL ORDER BY id;

EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_char_b WHERE replace(NULL, val1, 'X') IS NULL ORDER BY id;

EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_char_b WHERE replace('AAabcbaAA', val1, NULL) IS NULL ORDER BY id;

--
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_char_b WHERE replace('XYZ', 'X', val1) = 'abcbaYZ' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE replace('XYZ', 'X', val1) = 'abcbaYZ' ORDER BY id;
EXPLAIN (COSTS FALSE) 
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE replace('XYZ', 'X', val1) = 'abcbaYZ' ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE replace('XYZ', 'X', val1) = 'abcbaYZ' ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE replace('', 'X', val1) IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE replace('', 'X', val1) IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE replace('XYZ', '', val1) IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE replace('XYZ', '', val1) IS NULL ORDER BY id;

EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_char_b WHERE replace(NULL, 'X', val1) IS NULL ORDER BY id;

EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_char_b WHERE replace('XYZ', NULL, val1) IS NULL ORDER BY id;

-- varchar2
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace(val1, 'a', 'A') = 'AbcbA' ORDER BY id;
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace(val1, 'a', 'A') = 'AbcbA' ORDER BY id;
EXPLAIN (COSTS FALSE) 
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace(val1, 'a', 'A') = 'AbcbA' ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace(val1, 'a', 'A') = 'AbcbA' ORDER BY id;

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace(val1, '', 'ABC') = 'abcba' ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace(val1, '', 'ABC') = 'abcba' ORDER BY id;

EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace(val1, NULL, 'ABC') IS NULL ORDER BY id;
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace(val1, NULL, 'ABC') IS NULL ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace(val1, NULL, 'ABC') IS NULL ORDER BY id;

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace(val1, 'abc', '') IS NULL ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace(val1, 'abc', '') IS NULL ORDER BY id;

EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace(val1, 'abc', NULL) IS NULL ORDER BY id;
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace(val1, 'abc', NULL) IS NULL ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace(val1, 'abc', NULL) IS NULL ORDER BY id;

--
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace('AAabcbaAA', val1, 'X') = 'AAXAA' ORDER BY id;
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace('AAabcbaAA', val1, 'X') = 'AAXAA' ORDER BY id;
EXPLAIN (COSTS FALSE) 
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace('AAabcbaAA', val1, 'X') = 'AAXAA' ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace('AAabcbaAA', val1, 'X') = 'AAXAA' ORDER BY id;

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace('', val1, 'X') IS NULL ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace('', val1, 'X') IS NULL ORDER BY id;

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace('', val1, '') IS NULL ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace('', val1, '') IS NULL ORDER BY id;

EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace(NULL, val1, 'X') IS NULL ORDER BY id;

EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace('AAabcbaAA', val1, NULL) IS NULL ORDER BY id;

--
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace('XYZ', 'X', val1) = 'abcbaYZ' ORDER BY id;
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace('XYZ', 'X', val1) = 'abcbaYZ' ORDER BY id;
EXPLAIN (COSTS FALSE) 
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace('XYZ', 'X', val1) = 'abcbaYZ' ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace('XYZ', 'X', val1) = 'abcbaYZ' ORDER BY id;

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace('', 'X', val1) IS NULL ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace('', 'X', val1) IS NULL ORDER BY id;

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace('XYZ', '', val1) IS NULL ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace('XYZ', '', val1) IS NULL ORDER BY id;

EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace(NULL, 'X', val1) IS NULL ORDER BY id;

EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE replace('XYZ', NULL, val1) IS NULL ORDER BY id;

-- nclob
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_nclob_text WHERE replace(val1, 'a', 'A') = 'AbcbA' ORDER BY id;
SELECT id, val1 FROM ft_nclob_text WHERE replace(val1, 'a', 'A') = 'AbcbA' ORDER BY id;
EXPLAIN (COSTS FALSE) 
WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE replace(val1, 'a', 'A') = 'AbcbA' ORDER BY id;
WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE replace(val1, 'a', 'A') = 'AbcbA' ORDER BY id;

SELECT id, val1 FROM ft_nclob_text WHERE replace(val1, '', 'ABC') = 'abcba' ORDER BY id;
WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE replace(val1, '', 'ABC') = 'abcba' ORDER BY id;

EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_nclob_text WHERE replace(val1, NULL, 'ABC') IS NULL ORDER BY id;
SELECT id, val1 FROM ft_nclob_text WHERE replace(val1, NULL, 'ABC') IS NULL ORDER BY id;
WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE replace(val1, NULL, 'ABC') IS NULL ORDER BY id;

SELECT id, val1 FROM ft_nclob_text WHERE replace(val1, 'abc', '') IS NULL ORDER BY id;
WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE replace(val1, 'abc', '') IS NULL ORDER BY id;

EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_nclob_text WHERE replace(val1, 'abc', NULL) IS NULL ORDER BY id;
SELECT id, val1 FROM ft_nclob_text WHERE replace(val1, 'abc', NULL) IS NULL ORDER BY id;
WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE replace(val1, 'abc', NULL) IS NULL ORDER BY id;

--
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_nclob_text WHERE replace('AAabcbaAA', val1, 'X') = 'AAXAA' ORDER BY id;
SELECT id, val1 FROM ft_nclob_text WHERE replace('AAabcbaAA', val1, 'X') = 'AAXAA' ORDER BY id;
EXPLAIN (COSTS FALSE) 
WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE replace('AAabcbaAA', val1, 'X') = 'AAXAA' ORDER BY id;
WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE replace('AAabcbaAA', val1, 'X') = 'AAXAA' ORDER BY id;

SELECT id, val1 FROM ft_nclob_text WHERE replace('', val1, 'X') IS NULL ORDER BY id;
WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE replace('', val1, 'X') IS NULL ORDER BY id;

SELECT id, val1 FROM ft_nclob_text WHERE replace('', val1, '') IS NULL ORDER BY id;
WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE replace('', val1, '') IS NULL ORDER BY id;

EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_nclob_text WHERE replace(NULL, val1, 'X') IS NULL ORDER BY id;

EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_nclob_text WHERE replace('AAabcbaAA', val1, NULL) IS NULL ORDER BY id;

--
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_nclob_text WHERE replace('XYZ', 'X', val1) = 'abcbaYZ' ORDER BY id;
SELECT id, val1 FROM ft_nclob_text WHERE replace('XYZ', 'X', val1) = 'abcbaYZ' ORDER BY id;
EXPLAIN (COSTS FALSE) 
WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE replace('XYZ', 'X', val1) = 'abcbaYZ' ORDER BY id;
WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE replace('XYZ', 'X', val1) = 'abcbaYZ' ORDER BY id;

SELECT id, val1 FROM ft_nclob_text WHERE replace('', 'X', val1) IS NULL ORDER BY id;
WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE replace('', 'X', val1) IS NULL ORDER BY id;

SELECT id, val1 FROM ft_nclob_text WHERE replace('XYZ', '', val1) IS NULL ORDER BY id;
WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE replace('XYZ', '', val1) IS NULL ORDER BY id;

EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_nclob_text WHERE replace(NULL, 'X', val1) IS NULL ORDER BY id;

EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_nclob_text WHERE replace('XYZ', NULL, val1) IS NULL ORDER BY id;

