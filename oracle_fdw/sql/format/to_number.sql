\c contrib_regression_utf8

SELECT id, to_number(val1, val2) FROM ft_varchar2_c_varchar ORDER BY id;

--  to_number(text,text)
EXPLAIN (COSTS FALSE) 
WITH ft_varchar2_c_varchar AS (SELECT * FROM ft_varchar2_c_varchar)
SELECT * FROM ft_varchar2_c_varchar WHERE to_number(val1, val2) = 123456 ORDER BY id;
EXPLAIN (COSTS FALSE) 
SELECT * FROM ft_varchar2_c_varchar WHERE to_number(val1, val2) = 123456 ORDER BY id;
WITH ft_varchar2_c_varchar AS (SELECT * FROM ft_varchar2_c_varchar)
SELECT * FROM ft_varchar2_c_varchar WHERE to_number(val1, val2) = 123456 ORDER BY id;
SELECT * FROM ft_varchar2_c_varchar WHERE to_number(val1, val2) = 123456 ORDER BY id;

WITH ft_varchar2_c_varchar AS (SELECT * FROM ft_varchar2_c_varchar)
SELECT * FROM ft_varchar2_c_varchar WHERE to_number(val1, val2) = 123.456 ORDER BY id;
SELECT * FROM ft_varchar2_c_varchar WHERE to_number(val1, val2) = 123.456 ORDER BY id;

WITH ft_varchar2_c_varchar AS (SELECT * FROM ft_varchar2_c_varchar)
SELECT * FROM ft_varchar2_c_varchar WHERE to_number(val1, val2) = -123.456 ORDER BY id;
SELECT * FROM ft_varchar2_c_varchar WHERE to_number(val1, val2) = -123.456 ORDER BY id;

