\c contrib_regression_utf8

-- lower
EXPLAIN (COSTS FALSE) 
SELECT id, val2 FROM ft_char_b WHERE lower(val2) = 'abcba' ORDER BY id;
SELECT id, val2 FROM ft_char_b WHERE lower(val2) = 'abcba' ORDER BY id;
EXPLAIN (COSTS FALSE) 
WITH ft_char_b AS (SELECT id, val2 FROM ft_char_b)
SELECT id, val2 FROM ft_char_b WHERE lower(val2) = 'abcba' ORDER BY id;
WITH ft_char_b AS (SELECT id, val2 FROM ft_char_b)
SELECT id, val2 FROM ft_char_b WHERE lower(val2) = 'abcba' ORDER BY id;

SELECT id, val2 FROM ft_char_b WHERE lower(val2) = 'あぁアァ' ORDER BY id;
WITH ft_char_b AS (SELECT id, val2 FROM ft_char_b)
SELECT id, val2 FROM ft_char_b WHERE lower(val2) = 'あぁアァ' ORDER BY id;

SELECT id, val2 FROM ft_char_b WHERE lower(val2) = ' ａａｂｂｃｃ' ORDER BY id;
WITH ft_char_b AS (SELECT id, val2 FROM ft_char_b)
SELECT id, val2 FROM ft_char_b WHERE lower(val2) = ' ａａｂｂｃｃ' ORDER BY id;

SELECT id, val2 FROM ft_char_b WHERE lower(val2) = '' ORDER BY id;
WITH ft_char_b AS (SELECT id, val2 FROM ft_char_b)
SELECT id, val2 FROM ft_char_b WHERE lower(val2) = '' ORDER BY id;

SELECT id, val2 FROM ft_char_b WHERE lower(val2) IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val2 FROM ft_char_b)
SELECT id, val2 FROM ft_char_b WHERE lower(val2) IS NULL ORDER BY id;

--
EXPLAIN (COSTS FALSE) 
SELECT id, val2 FROM ft_char_c WHERE lower(val2) = 'abcba' ORDER BY id;
SELECT id, val2 FROM ft_char_c WHERE lower(val2) = 'abcba' ORDER BY id;
EXPLAIN (COSTS FALSE) 
WITH ft_char_c AS (SELECT id, val2 FROM ft_char_c)
SELECT id, val2 FROM ft_char_c WHERE lower(val2) = 'abcba' ORDER BY id;
WITH ft_char_c AS (SELECT id, val2 FROM ft_char_c)
SELECT id, val2 FROM ft_char_c WHERE lower(val2) = 'abcba' ORDER BY id;

SELECT id, val2 FROM ft_char_c WHERE lower(val2) = 'あぁアァ' ORDER BY id;
WITH ft_char_c AS (SELECT id, val2 FROM ft_char_c)
SELECT id, val2 FROM ft_char_c WHERE lower(val2) = 'あぁアァ' ORDER BY id;

SELECT id, val2 FROM ft_char_c WHERE lower(val2) = ' ａａｂｂｃｃ' ORDER BY id;
WITH ft_char_c AS (SELECT id, val2 FROM ft_char_c)
SELECT id, val2 FROM ft_char_c WHERE lower(val2) = ' ａａｂｂｃｃ' ORDER BY id;

SELECT id, val2 FROM ft_char_c WHERE lower(val2) = '' ORDER BY id;
WITH ft_char_c AS (SELECT id, val2 FROM ft_char_c)
SELECT id, val2 FROM ft_char_c WHERE lower(val2) = '' ORDER BY id;

SELECT id, val2 FROM ft_char_c WHERE lower(val2) IS NULL ORDER BY id;
WITH ft_char_c AS (SELECT id, val2 FROM ft_char_c)
SELECT id, val2 FROM ft_char_c WHERE lower(val2) IS NULL ORDER BY id;

--
EXPLAIN (COSTS FALSE) 
SELECT id, val2 FROM ft_varchar2_b_varchar WHERE lower(val2) = 'abcba' ORDER BY id;
SELECT id, val2 FROM ft_varchar2_b_varchar WHERE lower(val2) = 'abcba' ORDER BY id;
EXPLAIN (COSTS FALSE) 
WITH ft_varchar2_b_varchar AS (SELECT id, val2 FROM ft_varchar2_b_varchar)
SELECT id, val2 FROM ft_varchar2_b_varchar WHERE lower(val2) = 'abcba' ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val2 FROM ft_varchar2_b_varchar)
SELECT id, val2 FROM ft_varchar2_b_varchar WHERE lower(val2) = 'abcba' ORDER BY id;

SELECT id, val2 FROM ft_varchar2_b_varchar WHERE lower(val2) = 'あぁアァ' ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val2 FROM ft_varchar2_b_varchar)
SELECT id, val2 FROM ft_varchar2_b_varchar WHERE lower(val2) = 'あぁアァ' ORDER BY id;

SELECT id, val2 FROM ft_varchar2_b_varchar WHERE lower(val2) = ' ａａｂｂｃｃ' ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val2 FROM ft_varchar2_b_varchar)
SELECT id, val2 FROM ft_varchar2_b_varchar WHERE lower(val2) = ' ａａｂｂｃｃ' ORDER BY id;

SELECT id, val2 FROM ft_varchar2_b_varchar WHERE lower(val2) = '' ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val2 FROM ft_varchar2_b_varchar)
SELECT id, val2 FROM ft_varchar2_b_varchar WHERE lower(val2) = '' ORDER BY id;

SELECT id, val2 FROM ft_varchar2_b_varchar WHERE lower(val2) IS NULL ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val2 FROM ft_varchar2_b_varchar)
SELECT id, val2 FROM ft_varchar2_b_varchar WHERE lower(val2) IS NULL ORDER BY id;

--
EXPLAIN (COSTS FALSE) 
SELECT id, val2 FROM ft_nchar WHERE lower(val2) = 'abcba' ORDER BY id;
SELECT id, val2 FROM ft_nchar WHERE lower(val2) = 'abcba' ORDER BY id;
EXPLAIN (COSTS FALSE) 
WITH ft_nchar AS (SELECT id, val2 FROM ft_nchar)
SELECT id, val2 FROM ft_nchar WHERE lower(val2) = 'abcba' ORDER BY id;
WITH ft_nchar AS (SELECT id, val2 FROM ft_nchar)
SELECT id, val2 FROM ft_nchar WHERE lower(val2) = 'abcba' ORDER BY id;

SELECT id, val2 FROM ft_nchar WHERE lower(val2) = 'あぁアァ' ORDER BY id;
WITH ft_nchar AS (SELECT id, val2 FROM ft_nchar)
SELECT id, val2 FROM ft_nchar WHERE lower(val2) = 'あぁアァ' ORDER BY id;

SELECT id, val2 FROM ft_nchar WHERE lower(val2) = ' ａａｂｂｃｃ' ORDER BY id;
WITH ft_nchar AS (SELECT id, val2 FROM ft_nchar)
SELECT id, val2 FROM ft_nchar WHERE lower(val2) = ' ａａｂｂｃｃ' ORDER BY id;

SELECT id, val2 FROM ft_nchar WHERE lower(val2) = '' ORDER BY id;
WITH ft_nchar AS (SELECT id, val2 FROM ft_nchar)
SELECT id, val2 FROM ft_nchar WHERE lower(val2) = '' ORDER BY id;

SELECT id, val2 FROM ft_nchar WHERE lower(val2) IS NULL ORDER BY id;
WITH ft_nchar AS (SELECT id, val2 FROM ft_nchar)
SELECT id, val2 FROM ft_nchar WHERE lower(val2) IS NULL ORDER BY id;

