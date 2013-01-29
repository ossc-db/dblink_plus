\c contrib_regression_utf8

SET datestyle TO ISO;
SET timezone TO 'Asia/Tokyo';

SELECT to_timestamp(999999999999223372036854.77442);
SELECT to_timestamp(9223372036854.77442);
SELECT to_timestamp(9223372036854.77441999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999);
SELECT to_timestamp(9223372036854.7744);

SELECT id, to_date(val1, val2) FROM ft_varchar2_b_varchar ORDER BY id;

--  to_timestamp(text,text) char_b
EXPLAIN (COSTS FALSE) 
WITH ft_varchar2_b_varchar AS (SELECT * FROM ft_varchar2_b_varchar)
SELECT * FROM ft_varchar2_b_varchar WHERE to_timestamp(val1, val2) = '2011-01-02'::timestamptz ORDER BY id;
EXPLAIN (COSTS FALSE) 
SELECT * FROM ft_varchar2_b_varchar WHERE to_timestamp(val1, val2) = '2011-01-02'::timestamptz ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT * FROM ft_varchar2_b_varchar)
SELECT * FROM ft_varchar2_b_varchar WHERE to_timestamp(val1, val2) = '2011-01-02'::timestamptz ORDER BY id;
SELECT * FROM ft_varchar2_b_varchar WHERE to_timestamp(val1, val2) = '2011-01-02'::timestamptz ORDER BY id;

WITH ft_varchar2_b_varchar AS (SELECT * FROM ft_varchar2_b_varchar)
SELECT * FROM ft_varchar2_b_varchar WHERE to_timestamp(val1, val2) = '2011-01-01'::timestamptz ORDER BY id;
SELECT * FROM ft_varchar2_b_varchar WHERE to_timestamp(val1, val2) = '2011-01-01'::timestamptz ORDER BY id;

WITH ft_varchar2_b_varchar AS (SELECT * FROM ft_varchar2_b_varchar)
SELECT * FROM ft_varchar2_b_varchar WHERE to_timestamp(val1, val2) = '0001-11-01 BC'::timestamptz ORDER BY id;
SELECT * FROM ft_varchar2_b_varchar WHERE to_timestamp(val1, val2) = '0001-11-01 BC'::timestamptz ORDER BY id;

WITH ft_varchar2_b_varchar AS (SELECT * FROM ft_varchar2_b_varchar)
SELECT * FROM ft_varchar2_b_varchar WHERE to_timestamp(val1, val2) = '0001-01-11 BC'::timestamptz ORDER BY id;
SELECT * FROM ft_varchar2_b_varchar WHERE to_timestamp(val1, val2) = '0001-01-11 BC'::timestamptz ORDER BY id;

