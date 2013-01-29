\c contrib_regression_utf8

SET datestyle TO ISO;
SET timezone TO 'Asia/Tokyo';

SELECT id, to_date(val1, val2) FROM ft_varchar2_b_varchar ORDER BY id;

--  to_date(text,text) char_b
EXPLAIN (COSTS FALSE) 
WITH ft_varchar2_b_varchar AS (SELECT * FROM ft_varchar2_b_varchar)
SELECT * FROM ft_varchar2_b_varchar WHERE to_date(val1, val2) = '2011-01-02'::date ORDER BY id;
EXPLAIN (COSTS FALSE) 
SELECT * FROM ft_varchar2_b_varchar WHERE to_date(val1, val2) = '2011-01-02'::date ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT * FROM ft_varchar2_b_varchar)
SELECT * FROM ft_varchar2_b_varchar WHERE to_date(val1, val2) = '2011-01-02'::date ORDER BY id;
SELECT * FROM ft_varchar2_b_varchar WHERE to_date(val1, val2) = '2011-01-02'::date ORDER BY id;

EXPLAIN (COSTS FALSE) 
WITH ft_varchar2_b_varchar AS (SELECT * FROM ft_varchar2_b_varchar)
SELECT * FROM ft_varchar2_b_varchar WHERE to_date(val1, val2) = '2011-01-01'::date ORDER BY id;
EXPLAIN (COSTS FALSE) 
SELECT * FROM ft_varchar2_b_varchar WHERE to_date(val1, val2) = '2011-01-01'::date ORDER BY id;
WITH ft_varchar2_b_varchar AS (SELECT * FROM ft_varchar2_b_varchar)
SELECT * FROM ft_varchar2_b_varchar WHERE to_date(val1, val2) = '2011-01-01'::date ORDER BY id;
SELECT * FROM ft_varchar2_b_varchar WHERE to_date(val1, val2) = '2011-01-01'::date ORDER BY id;

