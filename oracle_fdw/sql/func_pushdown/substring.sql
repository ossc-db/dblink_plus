\c contrib_regression_utf8

-- substring(text,int,int)
EXPLAIN (COSTS FALSE) 
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 2, 2) = 'bc' ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 2, 2) = 'bc' ORDER BY id;
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 2, 2) = 'bc' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 2, 2) = 'bc' ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 2, 2) = 'ab' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 2, 2) = 'ab' ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 1, 2) = 'ab' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 1, 2) = 'ab' ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 3, 3) = 'いうい' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 3, 3) = 'いうい' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 0, 2) = 'ab' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 0, 2) = 'ab' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 0, 2) = ' ' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 0, 2) = ' ' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, -1, 4) = 'a' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, -1, 4) = 'a' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, -1, 4) = ' a' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, -1, 4) = ' a' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, -2, 5) = 'ba' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, -2, 5) = 'ba' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, -2, 5) = ' a' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, -2, 5) = ' a' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, -2, 7) = ' あいう' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, -2, 7) = ' あいう' ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 2, 1) = 'a' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 2, 1) = 'a' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 2, 0) = '' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 2, 0) = '' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 2, 0) IS NULL ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 2, 0) IS NULL ORDER BY id;

-- NG case
-- length is positive
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 2, -1) = 'ab' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 2, -1) = 'ab' ORDER BY id;

-- error case
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 1.4, 2) = 'ab' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 1.4::real, 2) = 'ab' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 1, 2.4) = 'ab' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 1, 2.4::real) = 'ab' ORDER BY id;

EXPLAIN (COSTS FALSE) 
WITH ft_number_int AS (SELECT * FROM ft_number_int)
SELECT * FROM ft_number_int WHERE substring('あいうえお', val1, val2) = 'いう' ORDER BY id;
EXPLAIN (COSTS FALSE) 
SELECT * FROM ft_number_int WHERE substring('あいうえお', val1, val2) = 'いう' ORDER BY id;
WITH ft_number_int AS (SELECT * FROM ft_number_int)
SELECT * FROM ft_number_int WHERE substring('あいうえお', val1, val2) = 'いう' ORDER BY id;
SELECT * FROM ft_number_int WHERE substring('あいうえお', val1, val2) = 'いう' ORDER BY id;

WITH ft_number_int AS (SELECT * FROM ft_number_int)
SELECT * FROM ft_number_int WHERE substring('あいうえお', val1, val2) IS NULL ORDER BY id;
SELECT * FROM ft_number_int WHERE substring('あいうえお', val1, val2) IS NULL ORDER BY id;

EXPLAIN (COSTS FALSE) 
SELECT * FROM ft_number_sma WHERE substring('あいうえお', val1, val2) IS NULL ORDER BY id;

-- substring(text,int)
EXPLAIN (COSTS FALSE) 
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 2) = 'bcba' ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 2) = 'bcba' ORDER BY id;
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 2) = 'bcba' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 2) = 'bcba' ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 2) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 2) = 'abcba' ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 1) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 1) = 'abcba' ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 3) = 'いういあ' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 3) = 'いういあ' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 0) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 0) = 'abcba' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, -1) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, -1) = 'abcba' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, -2) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, -2) = 'abcba' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1, -2) = ' あいういあ' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, -2) = ' あいういあ' ORDER BY id;

-- error case
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 1.4) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1, 1.4::real) = 'abcba' ORDER BY id;

EXPLAIN (COSTS FALSE) 
WITH ft_number_int AS (SELECT * FROM ft_number_int)
SELECT * FROM ft_number_int WHERE substring('あいうえお', val1) = 'いうえお' ORDER BY id;
EXPLAIN (COSTS FALSE) 
SELECT * FROM ft_number_int WHERE substring('あいうえお', val1) = 'いうえお' ORDER BY id;
WITH ft_number_int AS (SELECT * FROM ft_number_int)
SELECT * FROM ft_number_int WHERE substring('あいうえお', val1) = 'いうえお' ORDER BY id;
SELECT * FROM ft_number_int WHERE substring('あいうえお', val1) = 'いうえお' ORDER BY id;

WITH ft_number_int AS (SELECT * FROM ft_number_int)
SELECT * FROM ft_number_int WHERE substring('あいうえお', val1) IS NULL ORDER BY id;
SELECT * FROM ft_number_int WHERE substring('あいうえお', val1) IS NULL ORDER BY id;

EXPLAIN (COSTS FALSE) 
SELECT * FROM ft_number_sma WHERE substring('あいうえお', val1) IS NULL ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1 from 3 for 3) = 'いうい' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1 from 3 for 3) = 'いうい' ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1 from 3) = 'いういあ' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1 from 3) = 'いういあ' ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substring(val1 for 3) = ' あい' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substring(val1 for 3) = ' あい' ORDER BY id;

WITH ft_number_int AS (SELECT * FROM ft_number_int)
SELECT * FROM ft_number_int WHERE substring('あ い うえお' from val1 for val2) = ' い' ORDER BY id;
SELECT * FROM ft_number_int WHERE substring('あ い うえお' from val1 for val2) = ' い' ORDER BY id;

WITH ft_number_int AS (SELECT * FROM ft_number_int)
SELECT * FROM ft_number_int WHERE substring('あ い うえお' from val1) = ' い うえお' ORDER BY id;
SELECT * FROM ft_number_int WHERE substring('あ い うえお' from val1) = ' い うえお' ORDER BY id;

WITH ft_number_int AS (SELECT * FROM ft_number_int)
SELECT * FROM ft_number_int WHERE substring('あ い うえお' for val2) = 'あ ' ORDER BY id;
SELECT * FROM ft_number_int WHERE substring('あ い うえお' for val2) = 'あ ' ORDER BY id;

-- substring(text,int) varchar
EXPLAIN (COSTS FALSE) 
WITH ft_nvarchar2_varchar AS (SELECT id, val1 FROM ft_nvarchar2_varchar)
SELECT id, val1 FROM ft_nvarchar2_varchar WHERE substring(val1, 2) = 'bcba' ORDER BY id;
WITH ft_nvarchar2_varchar AS (SELECT id, val1 FROM ft_nvarchar2_varchar)
SELECT id, val1 FROM ft_nvarchar2_varchar WHERE substring(val1, 2) = 'bcba' ORDER BY id;
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_nvarchar2_varchar WHERE substring(val1, 2) = 'bcba' ORDER BY id;
SELECT id, val1 FROM ft_nvarchar2_varchar WHERE substring(val1, 2) = 'bcba' ORDER BY id;

WITH ft_nvarchar2_varchar AS (SELECT id, val1 FROM ft_nvarchar2_varchar)
SELECT id, val1 FROM ft_nvarchar2_varchar WHERE substring(val1, 2) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_nvarchar2_varchar WHERE substring(val1, 2) = 'abcba' ORDER BY id;

WITH ft_nvarchar2_varchar AS (SELECT id, val1 FROM ft_nvarchar2_varchar)
SELECT id, val1 FROM ft_nvarchar2_varchar WHERE substring(val1, 1) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_nvarchar2_varchar WHERE substring(val1, 1) = 'abcba' ORDER BY id;

WITH ft_nvarchar2_varchar AS (SELECT id, val1 FROM ft_nvarchar2_varchar)
SELECT id, val1 FROM ft_nvarchar2_varchar WHERE substring(val1, 3) = 'いういあ' ORDER BY id;
SELECT id, val1 FROM ft_nvarchar2_varchar WHERE substring(val1, 3) = 'いういあ' ORDER BY id;

-- NG case
WITH ft_nvarchar2_varchar AS (SELECT id, val1 FROM ft_nvarchar2_varchar)
SELECT id, val1 FROM ft_nvarchar2_varchar WHERE substring(val1, 0) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_nvarchar2_varchar WHERE substring(val1, 0) = 'abcba' ORDER BY id;

-- NG case
WITH ft_nvarchar2_varchar AS (SELECT id, val1 FROM ft_nvarchar2_varchar)
SELECT id, val1 FROM ft_nvarchar2_varchar WHERE substring(val1, -1) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_nvarchar2_varchar WHERE substring(val1, -1) = 'abcba' ORDER BY id;

-- NG case
WITH ft_nvarchar2_varchar AS (SELECT id, val1 FROM ft_nvarchar2_varchar)
SELECT id, val1 FROM ft_nvarchar2_varchar WHERE substring(val1, -2) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_nvarchar2_varchar WHERE substring(val1, -2) = 'abcba' ORDER BY id;

-- NG case
WITH ft_nvarchar2_varchar AS (SELECT id, val1 FROM ft_nvarchar2_varchar)
SELECT id, val1 FROM ft_nvarchar2_varchar WHERE substring(val1, -2) = ' あいういあ' ORDER BY id;
SELECT id, val1 FROM ft_nvarchar2_varchar WHERE substring(val1, -2) = ' あいういあ' ORDER BY id;

-- error case
SELECT id, val1 FROM ft_nvarchar2_varchar WHERE substring(val1, 1.4) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_nvarchar2_varchar WHERE substring(val1, 1.4::real) = 'abcba' ORDER BY id;

-- substring(text,int) clob
EXPLAIN (COSTS FALSE) 
WITH ft_clob_varchar AS (SELECT id, val1 FROM ft_clob_varchar)
SELECT id, val1 FROM ft_clob_varchar WHERE substring(val1, 2) = 'bcba' ORDER BY id;
WITH ft_clob_varchar AS (SELECT id, val1 FROM ft_clob_varchar)
SELECT id, val1 FROM ft_clob_varchar WHERE substring(val1, 2) = 'bcba' ORDER BY id;
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_clob_varchar WHERE substring(val1, 2) = 'bcba' ORDER BY id;
SELECT id, val1 FROM ft_clob_varchar WHERE substring(val1, 2) = 'bcba' ORDER BY id;

-- substring(text,int) nclob
EXPLAIN (COSTS FALSE) 
WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE substring(val1, 2) = 'bcba' ORDER BY id;
WITH ft_nclob_text AS (SELECT id, val1 FROM ft_nclob_text)
SELECT id, val1 FROM ft_nclob_text WHERE substring(val1, 2) = 'bcba' ORDER BY id;
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_nclob_text WHERE substring(val1, 2) = 'bcba' ORDER BY id;
SELECT id, val1 FROM ft_nclob_text WHERE substring(val1, 2) = 'bcba' ORDER BY id;

