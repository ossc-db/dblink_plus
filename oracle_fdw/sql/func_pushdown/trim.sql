\c contrib_regression_utf8

-- trim
EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_char_b WHERE trim('a' from val1) = 'bcb';
SELECT id, val1 FROM ft_char_b WHERE trim('a' from val1) = 'bcb';
EXPLAIN (COSTS FALSE) 
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE trim('a' from val1) = 'bcb';
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE trim('a' from val1) = 'bcb';

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE trim('a' from val1) = 'bcb';
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE trim('a' from val1) = 'bcb';

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE trim(leading 'a' from val1) = 'bcba';
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE trim(leading 'a' from val1) = 'bcba';

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE trim(trailing 'a' from val1) = 'abcb';
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE trim(trailing 'a' from val1) = 'abcb';

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE trim(both 'a' from val1) = 'bcb';
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE trim(both 'a' from val1) = 'bcb';

SELECT id, val1 FROM ft_char_b WHERE trim('ab' from val1) = 'c';
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE trim('ab' from val1) = 'c';

SELECT id, val1 FROM ft_char_b WHERE trim('ba' from val1) = 'c';
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE trim('ba' from val1) = 'c';

SELECT id, val1 FROM ft_char_b WHERE trim('あ' from val1) = 'いうい';
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE trim('あ' from val1) = 'いうい';

SELECT id, val1 FROM ft_char_b WHERE trim('あい' from val1) = 'う';
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE trim('あい' from val1) = 'う';

SELECT id, val1 FROM ft_char_b WHERE trim('いああああああああ' from val1) = 'う';
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE trim('いああああああああ' from val1) = 'う';

SELECT id, val1 FROM ft_char_b WHERE trim(val1) = 'abcba' ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE trim(val1) = 'abcba' ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE trim(val1) = 'あいういあ' ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE trim(val1) = 'あいういあ' ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE trim(val1) IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE trim(val1) IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE trim(NULL from val1) IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE trim(NULL from val1) IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE trim(val1 from NULL) IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE trim(val1 from NULL) IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE trim('' from val1) IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE trim('' from val1) IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE trim(val1 from '') IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE trim(val1 from '') IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE trim(' ' from val1) IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE trim(' ' from val1) IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE trim(val1 from ' ') IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE trim(val1 from ' ') IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE trim(val1 from 'abc') IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE trim(val1 from 'abc') IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE btrim(val1, 'ab') = 'c';
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE btrim(val1, 'ab') = 'c';

SELECT id, val1 FROM ft_char_c WHERE btrim(val1, 'ab') = 'c';
WITH ft_char_c AS (SELECT id, val1 FROM ft_char_c)
SELECT id, val1 FROM ft_char_c WHERE btrim(val1, 'ab') = 'c';

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE btrim(val1, 'ab') = 'c';
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE btrim(val1, 'ab') = 'c';

EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_clob_varchar WHERE btrim(val1, 'ab') = 'c';
SELECT id, val1 FROM ft_clob_varchar WHERE btrim(val1, 'ab') = 'c';
WITH ft_clob_varchar AS (SELECT id, val1 FROM ft_clob_varchar)
SELECT id, val1 FROM ft_clob_varchar WHERE btrim(val1, 'ab') = 'c';

SELECT id, val1 FROM ft_nclob_varchar WHERE btrim(val1, 'ab') = 'c';
WITH ft_nclob_varchar AS (SELECT id, val1 FROM ft_nclob_varchar)
SELECT id, val1 FROM ft_nclob_varchar WHERE btrim(val1, 'ab') = 'c';

EXPLAIN (COSTS FALSE) 
SELECT id, val1 FROM ft_nclob_varchar WHERE btrim(val1, val2) = 'c';
SELECT id, val1 FROM ft_nclob_varchar WHERE btrim(val1, val2) = 'c';
WITH ft_nclob_varchar AS (SELECT id, val1 FROM ft_nclob_varchar)
SELECT id, val1 FROM ft_nclob_varchar WHERE btrim(val1, val2) = 'c';

-- rtrim
SELECT id, val1 FROM ft_char_b WHERE rtrim(val1, 'a') = 'abcb';
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE rtrim(val1, 'a') = 'abcb';

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE rtrim(val1, 'a') = 'abcb';
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE rtrim(val1, 'a') = 'abcb';

SELECT id, val1 FROM ft_char_b WHERE rtrim(val1, 'ab') = 'abc';
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE rtrim(val1, 'ab') = 'abc';

SELECT id, val1 FROM ft_char_b WHERE rtrim(val1, 'ba') = 'abc';
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE rtrim(val1, 'ba') = 'abc';

SELECT id, val1 FROM ft_char_b WHERE rtrim(val1, 'あ') = 'あいうい';
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE rtrim(val1, 'あ') = 'あいうい';

SELECT id, val1 FROM ft_char_b WHERE rtrim(val1, 'あい') = 'あいう';
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE rtrim(val1, 'あい') = 'あいう';

SELECT id, val1 FROM ft_char_b WHERE rtrim(val1, 'いああああああああ') = 'あいう';
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE rtrim(val1, 'いああああああああ') = 'あいう';

SELECT id, val1 FROM ft_char_b WHERE rtrim(val1) = 'abcba' ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE rtrim(val1) = 'abcba' ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE rtrim(val1) = 'あいういあ' ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE rtrim(val1) = 'あいういあ' ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE rtrim(val1) IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE rtrim(val1) IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE rtrim(val1, NULL) IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE rtrim(val1, NULL) IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE rtrim(NULL, val1) IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE rtrim(NULL, val1) IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE rtrim(val1, '') IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE rtrim(val1, '') IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE rtrim('', val1) IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE rtrim('', val1) IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE rtrim(val1, ' ') IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE rtrim(val1, ' ') IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE rtrim('', val1) IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE rtrim('', val1) IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE rtrim('abc', val1) IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE rtrim('abc', val1) IS NULL ORDER BY id;

-- ltrim
SELECT id, val1 FROM ft_char_b WHERE ltrim(val1, 'a') = 'bcba';
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE ltrim(val1, 'a') = 'bcba';

SELECT id, val1 FROM ft_varchar2_b_varchar WHERE ltrim(val1, 'a') = 'bcba';
WITH ft_varchar2_b_varchar AS (SELECT id, val1 FROM ft_varchar2_b_varchar)
SELECT id, val1 FROM ft_varchar2_b_varchar WHERE ltrim(val1, 'a') = 'bcba';

SELECT id, val1 FROM ft_char_b WHERE ltrim(val1, 'ab') = 'cba';
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE ltrim(val1, 'ab') = 'cba';

SELECT id, val1 FROM ft_char_b WHERE ltrim(val1, 'ba') = 'cba';
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE ltrim(val1, 'ba') = 'cba';

SELECT id, val1 FROM ft_char_b WHERE ltrim(val1, 'あ') = 'いういあ';
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE ltrim(val1, 'あ') = 'いういあ';

SELECT id, val1 FROM ft_char_b WHERE ltrim(val1, 'あい') = 'ういあ';
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE ltrim(val1, 'あい') = 'ういあ';

SELECT id, val1 FROM ft_char_b WHERE ltrim(val1, 'いああああああああ') = 'ういあ';
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE ltrim(val1, 'いああああああああ') = 'ういあ';

SELECT id, val1 FROM ft_char_b WHERE ltrim(val1) = 'abcba' ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE ltrim(val1) = 'abcba' ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE ltrim(val1) = 'あいういあ' ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE ltrim(val1) = 'あいういあ' ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE ltrim(val1) IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE ltrim(val1) IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE ltrim(val1, NULL) IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE ltrim(val1, NULL) IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE ltrim(NULL, val1) IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE ltrim(NULL, val1) IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE ltrim(val1, '') IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE ltrim(val1, '') IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE ltrim('', val1) IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE ltrim('', val1) IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE ltrim(val1, ' ') IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE ltrim(val1, ' ') IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE ltrim('', val1) IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE ltrim('', val1) IS NULL ORDER BY id;

SELECT id, val1 FROM ft_char_b WHERE ltrim('abc', val1) IS NULL ORDER BY id;
WITH ft_char_b AS (SELECT id, val1 FROM ft_char_b)
SELECT id, val1 FROM ft_char_b WHERE ltrim('abc', val1) IS NULL ORDER BY id;

