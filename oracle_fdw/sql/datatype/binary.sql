\c contrib_regression_utf8

\pset null '(null)'
-- data type
SELECT * FROM ft_raw;
SELECT * FROM ft_blob;
SELECT * FROM ft_bfile;

SELECT * FROM ft_raw_text;
SELECT * FROM ft_blob_text;
SELECT * FROM ft_bfile_text;

SELECT * FROM ft_longraw;
SELECT * FROM ft_longraw_text;
ALTER FOREIGN TABLE ft_longraw OPTIONS (ADD max_value_len '1024');
ALTER FOREIGN TABLE ft_longraw_text OPTIONS (ADD max_value_len '1024');
SELECT * FROM ft_longraw;
SELECT * FROM ft_longraw_text;
