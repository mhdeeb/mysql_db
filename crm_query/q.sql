
CREATE DATABASE
IF NOT EXISTS db;

DELIMITER $$
CREATE FUNCTION db_exists (db_name VARCHAR(10)) RETURNS BOOL
	READS SQL DATA
BEGIN
	IF (
		SELECT SCHEMA_NAME
			FROM INFORMATION_SCHEMA.SCHEMATA
			WHERE SCHEMA_NAME = db_name
	) THEN
		RETURN TRUE;
	ELSE
		RETURN FALSE;
    END IF;
END$$
DELIMITER ;

SET @bef = IF(db_exists('db'), 'yes', 'no');

DROP DATABASE db;

SET @aft = IF(db_exists('db'), 'yes', 'no');

SELECT @bef as log; SELECT @aft;
