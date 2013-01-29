\c contrib_regression_utf8

-- length
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_char_b WHERE length(val1) = 5 ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE length(val1) = 5 ORDER BY id;
EXPLAIN (COSTS FALSE) 
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE length(val1) = 5 ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE length(val1) = 5 ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE length(val1) = 6 ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE length(val1) = 6 ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE length(val1) = 0 ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE length(val1) = 0 ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE length(val1) IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE length(val1) IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE char_length(val1) = 5 ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE char_length(val1) = 5 ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE character_length(val1) = 5 ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE character_length(val1) = 5 ORDER BY id;
--
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE length(val1) = 5 ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE length(val1) = 5 ORDER BY id;

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE length(val1) = 6 ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE length(val1) = 6 ORDER BY id;

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE length(val1) = 0 ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE length(val1) = 0 ORDER BY id;

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE length(val1) IS NULL ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE length(val1) IS NULL ORDER BY id;

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE char_length(val1) = 5 ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE char_length(val1) = 5 ORDER BY id;

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE character_length(val1) = 5 ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE character_length(val1) = 5 ORDER BY id;
--
SELECT id, val1 FROM ft_clob_varchar WHERE length(val1) = 5 ORDER BY id;
WITH ft_clob_varchar AS (SELECT id, val1 FROM ft_clob_varchar)
SELECT id, val1 FROM ft_clob_varchar WHERE length(val1) = 5 ORDER BY id;

SELECT id, val1 FROM ft_clob_varchar WHERE length(val1) = 6 ORDER BY id;
WITH ft_clob_varchar AS (SELECT id, val1 FROM ft_clob_varchar)
SELECT id, val1 FROM ft_clob_varchar WHERE length(val1) = 6 ORDER BY id;

SELECT id, val1 FROM ft_clob_varchar WHERE length(val1) = 0 ORDER BY id;
WITH ft_clob_varchar AS (SELECT id, val1 FROM ft_clob_varchar)
SELECT id, val1 FROM ft_clob_varchar WHERE length(val1) = 0 ORDER BY id;

SELECT id, val1 FROM ft_clob_varchar WHERE length(val1) IS NULL ORDER BY id;
WITH ft_clob_varchar AS (SELECT id, val1 FROM ft_clob_varchar)
SELECT id, val1 FROM ft_clob_varchar WHERE length(val1) IS NULL ORDER BY id;

SELECT id, val1 FROM ft_clob_varchar WHERE char_length(val1) = 5 ORDER BY id;
WITH ft_clob_varchar AS (SELECT id, val1 FROM ft_clob_varchar)
SELECT id, val1 FROM ft_clob_varchar WHERE char_length(val1) = 5 ORDER BY id;

SELECT id, val1 FROM ft_clob_varchar WHERE character_length(val1) = 5 ORDER BY id;
WITH ft_clob_varchar AS (SELECT id, val1 FROM ft_clob_varchar)
SELECT id, val1 FROM ft_clob_varchar WHERE character_length(val1) = 5 ORDER BY id;
--
SELECT id, val1 FROM ft_nclob_varchar WHERE length(val1) = 5 ORDER BY id;
WITH ft_nclob_varchar AS (SELECT id, val1 FROM ft_nclob_varchar)
SELECT id, val1 FROM ft_nclob_varchar WHERE length(val1) = 5 ORDER BY id;

SELECT id, val1 FROM ft_nclob_varchar WHERE length(val1) = 6 ORDER BY id;
WITH ft_nclob_varchar AS (SELECT id, val1 FROM ft_nclob_varchar)
SELECT id, val1 FROM ft_nclob_varchar WHERE length(val1) = 6 ORDER BY id;

SELECT id, val1 FROM ft_nclob_varchar WHERE length(val1) = 0 ORDER BY id;
WITH ft_nclob_varchar AS (SELECT id, val1 FROM ft_nclob_varchar)
SELECT id, val1 FROM ft_nclob_varchar WHERE length(val1) = 0 ORDER BY id;

SELECT id, val1 FROM ft_nclob_varchar WHERE length(val1) IS NULL ORDER BY id;
WITH ft_nclob_varchar AS (SELECT id, val1 FROM ft_nclob_varchar)
SELECT id, val1 FROM ft_nclob_varchar WHERE length(val1) IS NULL ORDER BY id;

SELECT id, val1 FROM ft_nclob_varchar WHERE char_length(val1) = 5 ORDER BY id;
WITH ft_nclob_varchar AS (SELECT id, val1 FROM ft_nclob_varchar)
SELECT id, val1 FROM ft_nclob_varchar WHERE char_length(val1) = 5 ORDER BY id;

SELECT id, val1 FROM ft_nclob_varchar WHERE character_length(val1) = 5 ORDER BY id;
WITH ft_nclob_varchar AS (SELECT id, val1 FROM ft_nclob_varchar)
SELECT id, val1 FROM ft_nclob_varchar WHERE character_length(val1) = 5 ORDER BY id;

-- octet_length
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_char_b WHERE octet_length(val1) = 2000 ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE octet_length(val1) = 2000 ORDER BY id;
EXPLAIN (COSTS FALSE) 
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE octet_length(val1) = 2000 ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE octet_length(val1) = 2000 ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE octet_length(val1) > 2000 ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE octet_length(val1) > 2000 ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE octet_length(val1) = 0 ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE octet_length(val1) = 0 ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE octet_length(val1) IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE octet_length(val1) IS NULL ORDER BY id;
--
SELECT id, val1 FROM ft_char_c WHERE octet_length(val1) = 2000 ORDER BY id;
WITH ft_char_c AS (SELECT id, val1 FROM ft_char_c)
SELECT id, val1 FROM ft_char_c WHERE octet_length(val1) = 2000 ORDER BY id;

SELECT id, val1 FROM ft_char_c WHERE octet_length(val1) > 2000 ORDER BY id;
WITH ft_char_c AS (SELECT id, val1 FROM ft_char_c)
SELECT id, val1 FROM ft_char_c WHERE octet_length(val1) > 2000 ORDER BY id;

SELECT id, val1 FROM ft_char_c WHERE octet_length(val1) = 0 ORDER BY id;
WITH ft_char_c AS (SELECT id, val1 FROM ft_char_c)
SELECT id, val1 FROM ft_char_c WHERE octet_length(val1) = 0 ORDER BY id;

SELECT id, val1 FROM ft_char_c WHERE octet_length(val1) IS NULL ORDER BY id;
WITH ft_char_c AS (SELECT id, val1 FROM ft_char_c)
SELECT id, val1 FROM ft_char_c WHERE octet_length(val1) IS NULL ORDER BY id;
--
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE octet_length(val1) = 5 ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE octet_length(val1) = 5 ORDER BY id;

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE octet_length(val1) = 6 ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE octet_length(val1) = 6 ORDER BY id;

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE octet_length(val1) = 15 ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE octet_length(val1) = 15 ORDER BY id;

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE octet_length(val1) = 16 ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE octet_length(val1) = 16 ORDER BY id;

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE octet_length(val1) = 0 ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE octet_length(val1) = 0 ORDER BY id;

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE octet_length(val1) IS NULL ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE octet_length(val1) IS NULL ORDER BY id;
--
SELECT id, val1 FROM ft_clob_varchar WHERE octet_length(val1) = 5 ORDER BY id;
WITH ft_clob_varchar AS (SELECT id, val1 FROM ft_clob_varchar)
SELECT id, val1 FROM ft_clob_varchar WHERE octet_length(val1) = 5 ORDER BY id;
--
SELECT id, val1 FROM ft_nclob_varchar WHERE octet_length(val1) = 5 ORDER BY id;
WITH ft_nclob_varchar AS (SELECT id, val1 FROM ft_nclob_varchar)
SELECT id, val1 FROM ft_nclob_varchar WHERE octet_length(val1) = 5 ORDER BY id;

-- bit_length
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_char_b WHERE bit_length(val1) = 5 * 8 ORDER BY id;
SELECT id, val1 FROM ft_char_b WHERE bit_length(val1) = 5 * 8 ORDER BY id;
EXPLAIN (COSTS FALSE) 
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE bit_length(val1) = 5 * 8 ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE bit_length(val1) = 5 * 8 ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE bit_length(val1) = 6 * 8 ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE bit_length(val1) = 6 * 8 ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE bit_length(val1) = 15 * 8 ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE bit_length(val1) = 15 * 8 ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE bit_length(val1) = 16 * 8 ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE bit_length(val1) = 16 * 8 ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE bit_length(val1) = 0 ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE bit_length(val1) = 0 ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE bit_length(val1) IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE bit_length(val1) IS NULL ORDER BY id;
--
SELECT id, val1 FROM ft_char_c WHERE bit_length(val1) = 5 * 8 ORDER BY id;
WITH ft_char_c AS (SELECT id, val1 FROM ft_char_c)
SELECT id, val1 FROM ft_char_c WHERE bit_length(val1) = 5 * 8 ORDER BY id;

SELECT id, val1 FROM ft_char_c WHERE bit_length(val1) = 6 * 8 ORDER BY id;
WITH ft_char_c AS (SELECT id, val1 FROM ft_char_c)
SELECT id, val1 FROM ft_char_c WHERE bit_length(val1) = 6 * 8 ORDER BY id;

SELECT id, val1 FROM ft_char_c WHERE bit_length(val1) = 15 * 8 ORDER BY id;
WITH ft_char_c AS (SELECT id, val1 FROM ft_char_c)
SELECT id, val1 FROM ft_char_c WHERE bit_length(val1) = 15 * 8 ORDER BY id;

SELECT id, val1 FROM ft_char_c WHERE bit_length(val1) = 16 * 8 ORDER BY id;
WITH ft_char_c AS (SELECT id, val1 FROM ft_char_c)
SELECT id, val1 FROM ft_char_c WHERE bit_length(val1) = 16 * 8 ORDER BY id;

SELECT id, val1 FROM ft_char_c WHERE bit_length(val1) = 0 ORDER BY id;
WITH ft_char_c AS (SELECT id, val1 FROM ft_char_c)
SELECT id, val1 FROM ft_char_c WHERE bit_length(val1) = 0 ORDER BY id;

SELECT id, val1 FROM ft_char_c WHERE bit_length(val1) IS NULL ORDER BY id;
WITH ft_char_c AS (SELECT id, val1 FROM ft_char_c)
SELECT id, val1 FROM ft_char_c WHERE bit_length(val1) IS NULL ORDER BY id;
--
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE bit_length(val1) = 5 * 8 ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE bit_length(val1) = 5 * 8 ORDER BY id;

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE bit_length(val1) = 6 * 8 ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE bit_length(val1) = 6 * 8 ORDER BY id;

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE bit_length(val1) = 15 * 8 ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE bit_length(val1) = 15 * 8 ORDER BY id;

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE bit_length(val1) = 16 * 8 ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE bit_length(val1) = 16 * 8 ORDER BY id;

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE bit_length(val1) = 0 ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE bit_length(val1) = 0 ORDER BY id;

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE bit_length(val1) IS NULL ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE bit_length(val1) IS NULL ORDER BY id;
--
SELECT id, val1 FROM ft_clob_varchar WHERE bit_length(val1) = 5 * 8 ORDER BY id;
WITH ft_clob_varchar AS (SELECT id, val1 FROM ft_clob_varchar)
SELECT id, val1 FROM ft_clob_varchar WHERE bit_length(val1) = 5 * 8 ORDER BY id;
--
SELECT id, val1 FROM ft_nclob_varchar WHERE bit_length(val1) = 5 * 8 ORDER BY id;
WITH ft_nclob_varchar AS (SELECT id, val1 FROM ft_nclob_varchar)
SELECT id, val1 FROM ft_nclob_varchar WHERE bit_length(val1) = 5 * 8 ORDER BY id;

