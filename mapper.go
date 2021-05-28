package main

var tableXML = `<?xml version="1.0" encoding="UTF-8"?>
<batis-mapper binding="table">
    <select id="SelectTableList">
		SELECT 
		  t.TABLE_NAME,
		  IFNULL(t.TABLE_COMMENT, '') as TABLE_COMMENT
		FROM
		  information_schema.TABLES AS t 
		WHERE t.TABLE_SCHEMA = '{{.DBName}}'
		{{.Where}}
    </select>
    <select id="SelectTableColumnList">
		SELECT 
		  t.TABLE_NAME,
		  t.COLUMN_KEY,
		  t.COLUMN_NAME,
		  IFNULL(t.COLUMN_DEFAULT, '__NULL__') AS COLUMN_DEFAULT,
		  IF(
			LOCATE('(', t.COLUMN_TYPE) = 0,
			t.COLUMN_TYPE,
			SUBSTRING(
			  t.COLUMN_TYPE,
			  1,
			  LOCATE('(', t.COLUMN_TYPE) - 1
			)
		  ) AS COLUMN_TYPE,
		  IFNULL(t.COLUMN_COMMENT, '') AS COLUMN_COMMENT,
		  t.EXTRA = 'auto_increment' as AUTO_INCREMENT
		FROM
		  information_schema.COLUMNS AS t 
		WHERE t.TABLE_SCHEMA = '{{.}}' 
		ORDER BY t.TABLE_NAME ASC,
		  t.ORDINAL_POSITION ASC 
    </select>
</batis-mapper>`
