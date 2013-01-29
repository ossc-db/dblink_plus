\c contrib_regression_utf8

-- substr(text,int,int)
EXPLAIN (COSTS FALSE) 
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 2, 2) = 'bc' ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 2, 2) = 'bc' ORDER BY id;
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 2, 2) = 'bc' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 2, 2) = 'bc' ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 2, 2) = 'ab' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 2, 2) = 'ab' ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 1, 2) = 'ab' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 1, 2) = 'ab' ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 3, 3) = 'いうい' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 3, 3) = 'いうい' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 0, 2) = 'ab' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 0, 2) = 'ab' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 0, 2) = ' ' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 0, 2) = ' ' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, -1, 4) = 'a' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, -1, 4) = 'a' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, -1, 4) = ' a' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, -1, 4) = ' a' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, -2, 5) = 'ba' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, -2, 5) = 'ba' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, -2, 5) = ' a' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, -2, 5) = ' a' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, -2, 7) = ' あいう' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, -2, 7) = ' あいう' ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 2, 1) = 'a' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 2, 1) = 'a' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 2, 0) = '' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 2, 0) = '' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 2, 0) IS NULL ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 2, 0) IS NULL ORDER BY id;

-- NG case
-- length is positive
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 2, -1) = 'ab' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 2, -1) = 'ab' ORDER BY id;

-- error case
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 1.4, 2) = 'ab' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 1.4::real, 2) = 'ab' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 1, 2.4) = 'ab' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 1, 2.4::real) = 'ab' ORDER BY id;

EXPLAIN (COSTS FALSE) 
WITH ft_number_int AS (SELECT * FROM ft_number_int)
SELECT * FROM ft_number_int WHERE substr('あいうえお', val1, val2) = 'いう' ORDER BY id;
EXPLAIN (COSTS FALSE) 
SELECT * FROM ft_number_int WHERE substr('あいうえお', val1, val2) = 'いう' ORDER BY id;
WITH ft_number_int AS (SELECT * FROM ft_number_int)
SELECT * FROM ft_number_int WHERE substr('あいうえお', val1, val2) = 'いう' ORDER BY id;
SELECT * FROM ft_number_int WHERE substr('あいうえお', val1, val2) = 'いう' ORDER BY id;

WITH ft_number_int AS (SELECT * FROM ft_number_int)
SELECT * FROM ft_number_int WHERE substr('あいうえお', val1, val2) IS NULL ORDER BY id;
SELECT * FROM ft_number_int WHERE substr('あいうえお', val1, val2) IS NULL ORDER BY id;

EXPLAIN (COSTS FALSE) 
SELECT * FROM ft_number_sma WHERE substr('あいうえお', val1, val2) IS NULL ORDER BY id;

-- substr(text,int) char
EXPLAIN (COSTS FALSE) 
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 2) = 'bcba' ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 2) = 'bcba' ORDER BY id;
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 2) = 'bcba' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 2) = 'bcba' ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 2) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 2) = 'abcba' ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 1) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 1) = 'abcba' ORDER BY id;

WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 3) = 'いういあ' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 3) = 'いういあ' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 0) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 0) = 'abcba' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, -1) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, -1) = 'abcba' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, -2) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, -2) = 'abcba' ORDER BY id;

-- NG case
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE substr(val1, -2) = ' あいういあ' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, -2) = ' あいういあ' ORDER BY id;

-- error case
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 1.4) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE substr(val1, 1.4::real) = 'abcba' ORDER BY id;

EXPLAIN (COSTS FALSE) 
WITH ft_number_int AS (SELECT * FROM ft_number_int)
SELECT * FROM ft_number_int WHERE substr('あいうえお', val1) = 'いうえお' ORDER BY id;
EXPLAIN (COSTS FALSE) 
SELECT * FROM ft_number_int WHERE substr('あいうえお', val1) = 'いうえお' ORDER BY id;
WITH ft_number_int AS (SELECT * FROM ft_number_int)
SELECT * FROM ft_number_int WHERE substr('あいうえお', val1) = 'いうえお' ORDER BY id;
SELECT * FROM ft_number_int WHERE substr('あいうえお', val1) = 'いうえお' ORDER BY id;

WITH ft_number_int AS (SELECT * FROM ft_number_int)
SELECT * FROM ft_number_int WHERE substr('あいうえお', val1) IS NULL ORDER BY id;
SELECT * FROM ft_number_int WHERE substr('あいうえお', val1) IS NULL ORDER BY id;

EXPLAIN (COSTS FALSE) 
SELECT * FROM ft_number_sma WHERE substr('あいうえお', val1) IS NULL ORDER BY id;

-- substr(text,int) nvarchar2
EXPLAIN (COSTS FALSE) 
WITH ft_nvarchar2_text AS (SELECT id, val1 FROM ft_nvarchar2_text)
SELECT id, val1 FROM ft_nvarchar2_text WHERE substr(val1, 2) = 'bcba' ORDER BY id;
WITH ft_nvarchar2_text AS (SELECT id, val1 FROM ft_nvarchar2_text)
SELECT id, val1 FROM ft_nvarchar2_text WHERE substr(val1, 2) = 'bcba' ORDER BY id;
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_nvarchar2_text WHERE substr(val1, 2) = 'bcba' ORDER BY id;
SELECT id, val1 FROM ft_nvarchar2_text WHERE substr(val1, 2) = 'bcba' ORDER BY id;

WITH ft_nvarchar2_text AS (SELECT id, val1 FROM ft_nvarchar2_text)
SELECT id, val1 FROM ft_nvarchar2_text WHERE substr(val1, 2) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_nvarchar2_text WHERE substr(val1, 2) = 'abcba' ORDER BY id;

WITH ft_nvarchar2_text AS (SELECT id, val1 FROM ft_nvarchar2_text)
SELECT id, val1 FROM ft_nvarchar2_text WHERE substr(val1, 1) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_nvarchar2_text WHERE substr(val1, 1) = 'abcba' ORDER BY id;

WITH ft_nvarchar2_text AS (SELECT id, val1 FROM ft_nvarchar2_text)
SELECT id, val1 FROM ft_nvarchar2_text WHERE substr(val1, 3) = 'いういあ' ORDER BY id;
SELECT id, val1 FROM ft_nvarchar2_text WHERE substr(val1, 3) = 'いういあ' ORDER BY id;

-- NG case
WITH ft_nvarchar2_text AS (SELECT id, val1 FROM ft_nvarchar2_text)
SELECT id, val1 FROM ft_nvarchar2_text WHERE substr(val1, 0) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_nvarchar2_text WHERE substr(val1, 0) = 'abcba' ORDER BY id;

-- NG case
WITH ft_nvarchar2_text AS (SELECT id, val1 FROM ft_nvarchar2_text)
SELECT id, val1 FROM ft_nvarchar2_text WHERE substr(val1, -1) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_nvarchar2_text WHERE substr(val1, -1) = 'abcba' ORDER BY id;

-- NG case
WITH ft_nvarchar2_text AS (SELECT id, val1 FROM ft_nvarchar2_text)
SELECT id, val1 FROM ft_nvarchar2_text WHERE substr(val1, -2) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_nvarchar2_text WHERE substr(val1, -2) = 'abcba' ORDER BY id;

-- NG case
WITH ft_nvarchar2_text AS (SELECT id, val1 FROM ft_nvarchar2_text)
SELECT id, val1 FROM ft_nvarchar2_text WHERE substr(val1, -2) = ' あいういあ' ORDER BY id;
SELECT id, val1 FROM ft_nvarchar2_text WHERE substr(val1, -2) = ' あいういあ' ORDER BY id;

-- error case
SELECT id, val1 FROM ft_nvarchar2_text WHERE substr(val1, 1.4) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_nvarchar2_text WHERE substr(val1, 1.4::real) = 'abcba' ORDER BY id;

-- substr(text,int) nclob
EXPLAIN (COSTS FALSE) 
WITH ft_nclob_varchar AS (SELECT id, val1 FROM ft_nclob_varchar)
SELECT id, val1 FROM ft_nclob_varchar WHERE substr(val1, 2) = 'bcba' ORDER BY id;
WITH ft_nclob_varchar AS (SELECT id, val1 FROM ft_nclob_varchar)
SELECT id, val1 FROM ft_nclob_varchar WHERE substr(val1, 2) = 'bcba' ORDER BY id;
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_nclob_varchar WHERE substr(val1, 2) = 'bcba' ORDER BY id;
SELECT id, val1 FROM ft_nclob_varchar WHERE substr(val1, 2) = 'bcba' ORDER BY id;

WITH ft_nclob_varchar AS (SELECT id, val1 FROM ft_nclob_varchar)
SELECT id, val1 FROM ft_nclob_varchar WHERE substr(val1, 2) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_nclob_varchar WHERE substr(val1, 2) = 'abcba' ORDER BY id;

WITH ft_nclob_varchar AS (SELECT id, val1 FROM ft_nclob_varchar)
SELECT id, val1 FROM ft_nclob_varchar WHERE substr(val1, 1) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_nclob_varchar WHERE substr(val1, 1) = 'abcba' ORDER BY id;

WITH ft_nclob_varchar AS (SELECT id, val1 FROM ft_nclob_varchar)
SELECT id, val1 FROM ft_nclob_varchar WHERE substr(val1, 3) = 'いういあ' ORDER BY id;
SELECT id, val1 FROM ft_nclob_varchar WHERE substr(val1, 3) = 'いういあ' ORDER BY id;

-- NG case
WITH ft_nclob_varchar AS (SELECT id, val1 FROM ft_nclob_varchar)
SELECT id, val1 FROM ft_nclob_varchar WHERE substr(val1, 0) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_nclob_varchar WHERE substr(val1, 0) = 'abcba' ORDER BY id;

-- NG case
WITH ft_nclob_varchar AS (SELECT id, val1 FROM ft_nclob_varchar)
SELECT id, val1 FROM ft_nclob_varchar WHERE substr(val1, -1) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_nclob_varchar WHERE substr(val1, -1) = 'abcba' ORDER BY id;

-- NG case
WITH ft_nclob_varchar AS (SELECT id, val1 FROM ft_nclob_varchar)
SELECT id, val1 FROM ft_nclob_varchar WHERE substr(val1, -2) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_nclob_varchar WHERE substr(val1, -2) = 'abcba' ORDER BY id;

-- NG case
WITH ft_nclob_varchar AS (SELECT id, val1 FROM ft_nclob_varchar)
SELECT id, val1 FROM ft_nclob_varchar WHERE substr(val1, -2) = ' あいういあ' ORDER BY id;
SELECT id, val1 FROM ft_nclob_varchar WHERE substr(val1, -2) = ' あいういあ' ORDER BY id;

-- error case
SELECT id, val1 FROM ft_nclob_varchar WHERE substr(val1, 1.4) = 'abcba' ORDER BY id;
SELECT id, val1 FROM ft_nclob_varchar WHERE substr(val1, 1.4::real) = 'abcba' ORDER BY id;

