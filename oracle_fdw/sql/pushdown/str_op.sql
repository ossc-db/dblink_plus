\c contrib_regression_utf8

SET DateStyle = 'ISO,YMD';
SET IntervalStyle = 'sql_standard';
SET TIMEZONE = 'Asia/Tokyo';

-- '||' operator
-- 1258	: textcat
EXPLAIN (COSTS FALSE) SELECT id FROM char_char WHERE 'a '::char(2) || val = 'aaAあア亜阿';
EXPLAIN (COSTS FALSE) SELECT id FROM vc2_vc WHERE 'a '::char(2) || val = 'aaAあア亜阿';
EXPLAIN (COSTS FALSE) SELECT id FROM clob_text WHERE 'a '::char(2) || val = 'aaAあア亜阿';
EXPLAIN (COSTS FALSE) SELECT id FROM char_char WHERE 'a '::varchar(2) || val = 'a aAあア亜阿';
EXPLAIN (COSTS FALSE) SELECT id FROM vc2_vc WHERE 'a '::varchar(2) || val = 'a aAあア亜阿';
EXPLAIN (COSTS FALSE) SELECT id FROM clob_text WHERE 'a '::varchar(2) || val = 'a aAあア亜阿';
EXPLAIN (COSTS FALSE) SELECT id FROM char_char WHERE 'a '::text || val = 'a aAあア亜阿';
EXPLAIN (COSTS FALSE) SELECT id FROM vc2_vc WHERE 'a '::text || val = 'a aAあア亜阿';
EXPLAIN (COSTS FALSE) SELECT id FROM clob_text WHERE 'a '::text || val = 'a aAあア亜阿';

SELECT id FROM char_char WHERE 'a '::char(2) || val = 'aaAあア亜阿';
SELECT id FROM vc2_vc WHERE 'a '::char(2) || val = 'aaAあア亜阿';
SELECT id FROM clob_text WHERE 'a '::char(2) || val = 'aaAあア亜阿';
SELECT id FROM char_char WHERE 'a '::varchar(2) || val = 'a aAあア亜阿';
SELECT id FROM vc2_vc WHERE 'a '::varchar(2) || val = 'a aAあア亜阿';
SELECT id FROM clob_text WHERE 'a '::varchar(2) || val = 'a aAあア亜阿';
SELECT id FROM char_char WHERE 'a '::text || val = 'a aAあア亜阿';
SELECT id FROM vc2_vc WHERE 'a '::text || val = 'a aAあア亜阿';
SELECT id FROM clob_text WHERE 'a '::text || val = 'a aAあア亜阿';

EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE char_char_1 || char_char_1 = 'a';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE char_char_1 || varchar2_varchar_1 = 'a';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE char_char_1 || clob_text_1 = 'a';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE varchar2_varchar_1 || char_char_1 = 'a';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE varchar2_varchar_1 || varchar2_varchar_1 = 'a';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE varchar2_varchar_1 || clob_text_1 = 'a';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE clob_text_1 || char_char_1 = 'a';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE clob_text_1 || varchar2_varchar_1 = 'a';
EXPLAIN (COSTS FALSE) SELECT id FROM all_type WHERE clob_text_1 || clob_text_1 = 'a';

-- リテラル長超過
SELECT id FROM char_varchar_ WHERE val = lpad('a', 4000, 'a');
SELECT id FROM char_varchar_ WHERE val = lpad('a', 4001, 'a');
SELECT id FROM char_varchar_ WHERE val = lpad('あ', 1333, 'あ');
SELECT id FROM char_varchar_ WHERE val = lpad('あ', 1334, 'あ');

-- Oracle CHAR BYTE column
SELECT id FROM char_varchar_ WHERE val || lpad('a', 2000, 'a') = 'a';
SELECT id FROM char_varchar_ WHERE val || lpad('a', 2001, 'a') = 'a';
-- Oracle CHAR CHAR column
SELECT id FROM char_text WHERE val || lpad('a', 2000, 'a') = 'a';
SELECT id FROM char_text WHERE val || lpad('a', 2001, 'a') = 'a';
-- Oracle VARCHAR2 BYTE column
SELECT id FROM vc2_vc_b WHERE val || lpad('a', 3986, 'a') = 'a';
SELECT id FROM vc2_vc_b WHERE val || lpad('a', 3987, 'a') = 'a';
-- Oracle VARCHAR2 CHAR column
SELECT id FROM vc2_vc WHERE val || lpad('a', 3986, 'a') = 'a';
SELECT id FROM vc2_vc WHERE val || lpad('a', 3987, 'a') = 'a';

