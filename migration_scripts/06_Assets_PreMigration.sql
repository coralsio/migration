DROP PROCEDURE IF EXISTS AddColumnsIfNotExists;

DELIMITER //

CREATE PROCEDURE AddColumnsIfNotExists()
BEGIN
    DECLARE column_exists INT;

SELECT COUNT(*) INTO column_exists FROM information_schema.COLUMNS
WHERE TABLE_NAME = 'jivtf01'
  AND COLUMN_NAME = 'PFrent_rate_code_id'
  AND TABLE_SCHEMA = DATABASE();

IF column_exists = 0 THEN
ALTER TABLE jivtf01
    ADD COLUMN PFrent_rate_code_id CHAR(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
            ADD COLUMN PFrent_schedule VARCHAR(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
            ADD COLUMN PFrent_rate DECIMAL(9,2),
            ADD COLUMN PFservice_rate_code_id CHAR(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
            ADD COLUMN PFservice_schedule VARCHAR(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
            ADD COLUMN PFservice_rate DECIMAL(9,2),
            ADD COLUMN PFdamage_rate_code_id CHAR(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
            ADD COLUMN PFdamage_schedule VARCHAR(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
            ADD COLUMN PFdamage_rate DECIMAL(9,2),
            ADD COLUMN PFother_rate_code_id CHAR(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
            ADD COLUMN PFother_schedule VARCHAR(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
            ADD COLUMN PFother_rate DECIMAL(9,2),
            ADD COLUMN PFdisposal_rate_code_id CHAR(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
            ADD COLUMN PFdisposal_schedule VARCHAR(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
            ADD COLUMN PFdisposal_rate DECIMAL(9,2),
            ADD COLUMN PFcode6_rate_code_id CHAR(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
            ADD COLUMN PFcode6_schedule VARCHAR(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
            ADD COLUMN PFcode6_rate DECIMAL(9,2),
            ADD COLUMN PFcode7_rate_code_id CHAR(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
            ADD COLUMN PFcode7_schedule VARCHAR(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
            ADD COLUMN PFcode7_rate DECIMAL(9,2),
            ADD COLUMN PFcode8_rate_code_id CHAR(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
            ADD COLUMN PFcode8_schedule VARCHAR(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
            ADD COLUMN PFcode8_rate DECIMAL(9,2),
            ADD COLUMN PFcode9_rate_code_id CHAR(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
            ADD COLUMN PFcode9_schedule VARCHAR(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
            ADD COLUMN PFcode9_rate DECIMAL(9,2),
            ADD COLUMN PFcode10_rate_code_id CHAR(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
            ADD COLUMN PFcode10_schedule VARCHAR(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
            ADD COLUMN PFcode10_rate DECIMAL(9,2);
END IF;
END
//

DELIMITER ;

CALL AddColumnsIfNotExists();

DROP PROCEDURE IF EXISTS UpdateRates;

DELIMITER $$

CREATE PROCEDURE UpdateRates()
BEGIN
    DECLARE
RentCode VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    DECLARE
DamageCode VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    DECLARE
OtherCode VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    DECLARE
SerialVariable VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    DECLARE
DailyRate DECIMAL(9,2);
    DECLARE
WeeklyRate DECIMAL(9,2);
    DECLARE
MonthlyRate DECIMAL(9,2);
    DECLARE
DailyServiceRate DECIMAL(9,2);
    DECLARE
WeeklyServiceRate DECIMAL(9,2);
    DECLARE
MonthlyServiceRate DECIMAL(9,2);
    DECLARE
DailyDamageRate DECIMAL(9,2);
    DECLARE
WeeklyDamageRate DECIMAL(9,2);
    DECLARE
MonthlyDamageRate DECIMAL(9,2);
    DECLARE
DailyDisposalRate DECIMAL(9,2);
    DECLARE
WeeklyDisposalRate DECIMAL(9,2);
    DECLARE
MonthlyDisposalRate DECIMAL(9,2);
    DECLARE
DailyOtherRate DECIMAL(9,2);
    DECLARE
WeeklyOtherRate DECIMAL(9,2);
    DECLARE
MonthlyOtherRate DECIMAL(9,2);


    -- Declare done variable to detect end of cursor
    DECLARE done INT DEFAULT 0;

    -- Declare cursor for selecting data from jivtf01 table
    DECLARE
RentalUnitRateCursor CURSOR FOR
SELECT Serial,
       CAST(dailyrate AS DECIMAL(9, 2)),
       CAST(wklyrate AS DECIMAL(9, 2)),
       CAST(mthrate AS DECIMAL(9, 2)),
       CAST(srvdrate AS DECIMAL(9, 2)),
       CAST(srvwrate AS DECIMAL(9, 2)),
       CAST(srvmrate AS DECIMAL(9, 2)),
       CAST(damage AS DECIMAL(9, 2)),
       CAST(wdamage AS DECIMAL(9, 2)),
       CAST(mdamage AS DECIMAL(9, 2)),
       CAST(ddisposal AS DECIMAL(9, 2)),
       CAST(disposal AS DECIMAL(9, 2)),
       CAST(mdisposal AS DECIMAL(9, 2)),
       CAST(othdrate AS DECIMAL(9, 2)),
       CAST(othwrate AS DECIMAL(9, 2)),
       CAST(othmrate AS DECIMAL(9, 2))
FROM jivtf01;

-- Continue handler to handle end of data from cursor
DECLARE
CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Fetch the charge codes from jpptf1 table
SELECT LSRENT, LSDAMAGE, LSOTHER
INTO RentCode, DamageCode, OtherCode
FROM jpptf1;

-- Open cursor
OPEN RentalUnitRateCursor;

-- Loop through the cursor rows
read_loop
: LOOP
        -- Fetch next row into variables
        FETCH RentalUnitRateCursor INTO SerialVariable, DailyRate, WeeklyRate, MonthlyRate, DailyServiceRate,
            WeeklyServiceRate, MonthlyServiceRate, DailyDamageRate,
            WeeklyDamageRate, MonthlyDamageRate, DailyDisposalRate,
            WeeklyDisposalRate, MonthlyDisposalRate, DailyOtherRate,
            WeeklyOtherRate, MonthlyOtherRate;

        -- Exit the loop if no more rows
        IF
done THEN
            LEAVE read_loop;
END IF;

        -- Update Rent Rate
        IF
DailyRate > 0 THEN
UPDATE jivtf01
SET PFrent_rate_code_id = CONCAT(RTRIM(RentCode), 'D'),
    PFrent_schedule     = 'Daily',
    PFrent_rate         = DailyRate
WHERE serial = SerialVariable;
END IF;
        IF
WeeklyRate > 0 THEN
UPDATE jivtf01
SET PFrent_rate_code_id = CONCAT(RTRIM(RentCode), 'W'),
    PFrent_schedule     = 'Weekly',
    PFrent_rate         = WeeklyRate
WHERE serial = SerialVariable;
END IF;
        IF
MonthlyRate > 0 THEN
UPDATE jivtf01
SET PFrent_rate_code_id = CONCAT(RTRIM(RentCode), 'M'),
    PFrent_schedule     = 'Monthly',
    PFrent_rate         = MonthlyRate
WHERE serial = SerialVariable;
END IF;

        -- Similarly, update for Service, Damage, Disposal, Other rates (as needed)
END LOOP
read_loop;

    -- Close cursor
CLOSE RentalUnitRateCursor;

END$$

DELIMITER ;

CALL UpdateRates();