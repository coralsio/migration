-- UPDATE jivof01 SET invdate = STR_TO_DATE(invdate, '%m/%d/%Y');
-- UPDATE jxchrgf1 SET chrgdate = STR_TO_DATE(chrgdate, '%m/%d/%Y') WHERE chrgdate IS NOT NULL AND chrgdate <> '';




-- Drop the procedure if it already exists
DROP PROCEDURE IF EXISTS AddMissingColumns;

DELIMITER $$

CREATE PROCEDURE AddMissingColumns()
BEGIN
    DECLARE column_exists INT DEFAULT 0;

SELECT COUNT(*) INTO column_exists
FROM information_schema.COLUMNS
WHERE TABLE_NAME = 'jivof01'
  AND COLUMN_NAME = 'PFTaxAmount'
  AND TABLE_SCHEMA = DATABASE(); -- Use the current database

IF column_exists = 0 THEN
ALTER TABLE jivof01
    ADD COLUMN PFTaxAmount DECIMAL(10, 3);
END IF;

    -- Reset column_exists for the next check
    SET column_exists = 0;

    -- Check if the column PFPreTaxTotal exists
SELECT COUNT(*) INTO column_exists
FROM information_schema.COLUMNS
WHERE TABLE_NAME = 'jivof01'
  AND COLUMN_NAME = 'PFPreTaxTotal'
  AND TABLE_SCHEMA = DATABASE();

-- If PFPreTaxTotal does not exist, add the column
IF column_exists = 0 THEN
ALTER TABLE jivof01
    ADD COLUMN PFPreTaxTotal DECIMAL(10, 3);
END IF;
END $$

-- Reset the delimiter back to the default
DELIMITER ;

-- Call the procedure to execute it
CALL AddMissingColumns();


-- for better performance
-- CREATE INDEX idx_chrgdate ON jxchrgf1 (chrgdate);
-- CREATE INDEX idx_chrginv ON jxchrgf1 (chrginv);
-- CREATE INDEX idx_prev_inv ON jivof01 (prev_inv);
-- CREATE INDEX idx_invdate ON jivof01 (invdate);


UPDATE jivof01 j
    JOIN (
    SELECT chrginv AS InvoiceNumber,
    SUM(chrgamt) AS PreTaxTotal,
    SUM(chrgtax) AS TaxTotal
    FROM jxchrgf1
    WHERE chrgdate > '2015-12-01'
    GROUP BY chrginv
    ) c ON j.prev_inv = c.InvoiceNumber
    SET j.PFTaxAmount = c.TaxTotal,
        j.PFPreTaxTotal = c.PreTaxTotal
WHERE j.invdate > '2016-01-01';