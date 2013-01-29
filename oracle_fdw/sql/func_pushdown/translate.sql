\c contrib_regression_utf8

-- translate(text,text,text) char_b
EXPLAIN (COSTS FALSE) 
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE translate(val1, 'あいう', 'アイウ') = 'アイウイア' ORDER BY id;
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_char_b WHERE translate(val1, 'あいう', 'アイウ') = 'アイウイア' ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE translate(val1, 'あいう', 'アイウ') = 'アイウイア' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE translate(val1, 'あいう', 'アイウ') = 'アイウイア' ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE translate(val1, 'あ', 'アイウ') = 'アいういア' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE translate(val1, 'あ', 'アイウ') = 'アいういア' ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE translate(val1, 'あい', 'ア') = 'アうア' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE translate(val1, 'あい', 'ア') = 'アうア' ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE translate(val1, 'ういあ', 'ABC') = 'CBABC' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE translate(val1, 'ういあ', 'ABC') = 'CBABC' ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE translate(val1, 'abcde', 'アイウ') = 'アイウイア' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE translate(val1, 'abcde', 'アイウ') = 'アイウイア' ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE translate(val1, 'うaい', 'AあB') = 'あBABあ' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE translate(val1, 'うaい', 'AあB') = 'あBABあ' ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE translate(val1, 'ああいいうう', 'ABCDEF') = 'ACECA' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE translate(val1, 'ああいいうう', 'ABCDEF') = 'ACECA' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE translate(val1, 'あい', '') = 'う' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE translate(val1, 'あい', '') = 'う' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE translate(val1, 'あい', '') IS NULL ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE translate(val1, 'あい', '') IS NULL ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE translate(val1, '', 'アイウ') = 'あいういあ' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE translate(val1, '', 'アイウ') = 'あいういあ' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE translate(val1, '', 'アイウ') IS NULL ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE translate(val1, '', 'アイウ') IS NULL ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE translate(val1, NULL, 'アイウ') IS NULL ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE translate(val1, NULL, 'アイウ') IS NULL ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE translate(val1, 'あいう', NULL) IS NULL ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE translate(val1, 'あいう', NULL) IS NULL ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE translate('あいういあ', val1, 'アイウ') = 'アイウイア' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE translate('あいういあ', val1, 'アイウ') = 'アイウイア' ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE translate('あ', val1, 'アイウ') = 'ア' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE translate('あ', val1, 'アイウ') = 'ア' ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE translate('あ', val1, 'アイウエオカキクケコ') = 'ア' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE translate('あ', val1, 'アイウエオカキクケコ') = 'ア' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE translate('', val1, 'アイウエオカキクケコ') = '' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE translate('', val1, 'アイウエオカキクケコ') = '' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE translate('', val1, 'アイウエオカキクケコ') IS NULL ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE translate('', val1, 'アイウエオカキクケコ') IS NULL ORDER BY id;

-- translate(text,text,text) varchar_c
EXPLAIN (COSTS FALSE) 
WITH ft_varchar2_c_text AS (SELECT id, val1 FROM ft_varchar2_c_text)
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, 'あいう', 'アイウ') = 'アイウイア' ORDER BY id;
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, 'あいう', 'アイウ') = 'アイウイア' ORDER BY id;
WITH ft_varchar2_c_text AS (SELECT id, val1 FROM ft_varchar2_c_text)
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, 'あいう', 'アイウ') = 'アイウイア' ORDER BY id;
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, 'あいう', 'アイウ') = 'アイウイア' ORDER BY id;

WITH ft_varchar2_c_text AS (SELECT id, val1 FROM ft_varchar2_c_text)
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, 'あ', 'アイウ') = 'アいういア' ORDER BY id;
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, 'あ', 'アイウ') = 'アいういア' ORDER BY id;

WITH ft_varchar2_c_text AS (SELECT id, val1 FROM ft_varchar2_c_text)
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, 'あい', 'ア') = 'アうア' ORDER BY id;
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, 'あい', 'ア') = 'アうア' ORDER BY id;

WITH ft_varchar2_c_text AS (SELECT id, val1 FROM ft_varchar2_c_text)
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, 'ういあ', 'ABC') = 'CBABC' ORDER BY id;
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, 'ういあ', 'ABC') = 'CBABC' ORDER BY id;

WITH ft_varchar2_c_text AS (SELECT id, val1 FROM ft_varchar2_c_text)
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, 'abcde', 'アイウ') = 'アイウイア' ORDER BY id;
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, 'abcde', 'アイウ') = 'アイウイア' ORDER BY id;

WITH ft_varchar2_c_text AS (SELECT id, val1 FROM ft_varchar2_c_text)
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, 'うaい', 'AあB') = 'あBABあ' ORDER BY id;
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, 'うaい', 'AあB') = 'あBABあ' ORDER BY id;

WITH ft_varchar2_c_text AS (SELECT id, val1 FROM ft_varchar2_c_text)
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, 'ああいいうう', 'ABCDEF') = 'ACECA' ORDER BY id;
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, 'ああいいうう', 'ABCDEF') = 'ACECA' ORDER BY id;

-- NG case
WITH ft_varchar2_c_text AS (SELECT id, val1 FROM ft_varchar2_c_text)
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, 'あい', '') = 'う' ORDER BY id;
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, 'あい', '') = 'う' ORDER BY id;

-- NG case
WITH ft_varchar2_c_text AS (SELECT id, val1 FROM ft_varchar2_c_text)
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, 'あい', '') IS NULL ORDER BY id;
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, 'あい', '') IS NULL ORDER BY id;

-- NG case
WITH ft_varchar2_c_text AS (SELECT id, val1 FROM ft_varchar2_c_text)
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, '', 'アイウ') = 'あいういあ' ORDER BY id;
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, '', 'アイウ') = 'あいういあ' ORDER BY id;

-- NG case
WITH ft_varchar2_c_text AS (SELECT id, val1 FROM ft_varchar2_c_text)
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, '', 'アイウ') IS NULL ORDER BY id;
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, '', 'アイウ') IS NULL ORDER BY id;

WITH ft_varchar2_c_text AS (SELECT id, val1 FROM ft_varchar2_c_text)
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, NULL, 'アイウ') IS NULL ORDER BY id;
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, NULL, 'アイウ') IS NULL ORDER BY id;

WITH ft_varchar2_c_text AS (SELECT id, val1 FROM ft_varchar2_c_text)
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, 'あいう', NULL) IS NULL ORDER BY id;
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate(val1, 'あいう', NULL) IS NULL ORDER BY id;

WITH ft_varchar2_c_text AS (SELECT id, val1 FROM ft_varchar2_c_text)
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate('あいういあ', val1, 'アイウ') = 'アイウイア' ORDER BY id;
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate('あいういあ', val1, 'アイウ') = 'アイウイア' ORDER BY id;

WITH ft_varchar2_c_text AS (SELECT id, val1 FROM ft_varchar2_c_text)
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate('あ', val1, 'アイウ') = 'ア' ORDER BY id;
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate('あ', val1, 'アイウ') = 'ア' ORDER BY id;

WITH ft_varchar2_c_text AS (SELECT id, val1 FROM ft_varchar2_c_text)
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate('あ', val1, 'アイウエオカキクケコ') = 'ア' ORDER BY id;
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate('あ', val1, 'アイウエオカキクケコ') = 'ア' ORDER BY id;

-- NG case
WITH ft_varchar2_c_text AS (SELECT id, val1 FROM ft_varchar2_c_text)
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate('', val1, 'アイウエオカキクケコ') = '' ORDER BY id;
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate('', val1, 'アイウエオカキクケコ') = '' ORDER BY id;

-- NG case
WITH ft_varchar2_c_text AS (SELECT id, val1 FROM ft_varchar2_c_text)
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate('', val1, 'アイウエオカキクケコ') IS NULL ORDER BY id;
SELECT id, val1 FROM ft_varchar2_c_text WHERE translate('', val1, 'アイウエオカキクケコ') IS NULL ORDER BY id;

-- translate(text,text,text) nclob
EXPLAIN (COSTS FALSE) 
WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, 'あいう', 'アイウ') = 'アイウイア' ORDER BY id;
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, 'あいう', 'アイウ') = 'アイウイア' ORDER BY id;
WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, 'あいう', 'アイウ') = 'アイウイア' ORDER BY id;
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, 'あいう', 'アイウ') = 'アイウイア' ORDER BY id;

WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, 'あ', 'アイウ') = 'アいういア' ORDER BY id;
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, 'あ', 'アイウ') = 'アいういア' ORDER BY id;

WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, 'あい', 'ア') = 'アうア' ORDER BY id;
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, 'あい', 'ア') = 'アうア' ORDER BY id;

WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, 'ういあ', 'ABC') = 'CBABC' ORDER BY id;
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, 'ういあ', 'ABC') = 'CBABC' ORDER BY id;

WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, 'abcde', 'アイウ') = 'アイウイア' ORDER BY id;
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, 'abcde', 'アイウ') = 'アイウイア' ORDER BY id;

WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, 'うaい', 'AあB') = 'あBABあ' ORDER BY id;
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, 'うaい', 'AあB') = 'あBABあ' ORDER BY id;

WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, 'ああいいうう', 'ABCDEF') = 'ACECA' ORDER BY id;
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, 'ああいいうう', 'ABCDEF') = 'ACECA' ORDER BY id;

-- NG case
WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, 'あい', '') = 'う' ORDER BY id;
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, 'あい', '') = 'う' ORDER BY id;

-- NG case
WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, 'あい', '') IS NULL ORDER BY id;
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, 'あい', '') IS NULL ORDER BY id;

-- NG case
WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, '', 'アイウ') = 'あいういあ' ORDER BY id;
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, '', 'アイウ') = 'あいういあ' ORDER BY id;

-- NG case
WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, '', 'アイウ') IS NULL ORDER BY id;
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, '', 'アイウ') IS NULL ORDER BY id;

WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, NULL, 'アイウ') IS NULL ORDER BY id;
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, NULL, 'アイウ') IS NULL ORDER BY id;

WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, 'あいう', NULL) IS NULL ORDER BY id;
SELECT id, val1 FROM ft_nclob_text WHERE translate(val1, 'あいう', NULL) IS NULL ORDER BY id;

WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE translate('あいういあ', val1, 'アイウ') = 'アイウイア' ORDER BY id;
SELECT id, val1 FROM ft_nclob_text WHERE translate('あいういあ', val1, 'アイウ') = 'アイウイア' ORDER BY id;

WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE translate('あ', val1, 'アイウ') = 'ア' ORDER BY id;
SELECT id, val1 FROM ft_nclob_text WHERE translate('あ', val1, 'アイウ') = 'ア' ORDER BY id;

WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE translate('あ', val1, 'アイウエオカキクケコ') = 'ア' ORDER BY id;
SELECT id, val1 FROM ft_nclob_text WHERE translate('あ', val1, 'アイウエオカキクケコ') = 'ア' ORDER BY id;

-- NG case
WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE translate('', val1, 'アイウエオカキクケコ') = '' ORDER BY id;
SELECT id, val1 FROM ft_nclob_text WHERE translate('', val1, 'アイウエオカキクケコ') = '' ORDER BY id;

-- NG case
WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE translate('', val1, 'アイウエオカキクケコ') IS NULL ORDER BY id;
SELECT id, val1 FROM ft_nclob_text WHERE translate('', val1, 'アイウエオカキクケコ') IS NULL ORDER BY id;

