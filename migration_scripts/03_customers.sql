-- IMPORTANT: check billing matrix per client for default bill_type and scheduling_settings!!!!!

SET SESSION sql_mode = '';

-- Dropping temporary table if exists
DROP
TEMPORARY TABLE IF EXISTS LowestSite;

-- Creating temporary table
CREATE
TEMPORARY TABLE LowestSite AS
SELECT DISTINCT j1.custmast, MIN(j9.custnum) AS LSCustnum
FROM {db_old}.jcusf01 j1
         INNER JOIN {db_old}.jcusf09 j9 ON j1.custnum = j9.custnum
GROUP BY j1.custmast;



DROP TABLE IF EXISTS {db_new}.customers;

CREATE TABLE {db_new}.customers (
 id INT UNSIGNED NOT NULL PRIMARY KEY
) AS
SELECT
    ROW_NUMBER() OVER (ORDER BY j7.bllmast ASC) AS id,
    j7.bllmast AS number,
    j7.BLLMAST                            AS customer_number,
    TRIM(j7.blladdr)                      AS address_1,
    TRIM(j7.blladdr2)                     AS address_2,
    j7.bllcity                            AS city,
    REPLACE(TRIM(j7.bllemail1), ';', ',') AS contact_1_email,
    REPLACE(TRIM(j7.bllemail2), ';', ',') AS contact_2_email,
    j7.bllfax                             AS contact_2_phone,
    j7.bllname                            AS company_name,
    j7.bllphone                           AS contact_1_phone,
    j7.bllstate                           AS bllstate, -- Update this to {db_new}.code_sets ID below
    (SELECT id FROM {db_new}.code_sets
WHERE parent_id = 1
  AND code = j7.bllstate) AS state_id
    , j7.bllzip AS zip
    , (
SELECT id
FROM {db_new}.divisions pfd
WHERE pfd.division_code = j7.bllcocode) AS division_id
    , COALESCE ((SELECT id FROM {db_new}.code_sets cs WHERE cs.code = j9.accttype
  AND parent_id = 101)
    , 101) AS customer_market_segment_id
    , (
SELECT LLCCBILL
FROM {db_old}.jcusf01 j1
WHERE j1.custnum = ls.LSCustnum) AS communication_method
    , j7.bllcrlmt AS credit_limit
    , j7.blledate
    , j7.blletime
    , CASE
    WHEN LOCATE(' '
    , j7.bllcontact)
    > 0 THEN SUBSTRING_INDEX(j7.bllcontact
    , ' '
    , 1)
    ELSE j7.bllcontact
END
AS contact_1_first_name,
    CASE
        WHEN LOCATE(' ', j7.bllcontact) > 0 THEN SUBSTRING_INDEX(j7.bllcontact, ' ', -1)
        ELSE ''
END
AS contact_1_last_name,
    j7.bllrating,
    j7.bllcountry,
    CASE
        WHEN j7.BLLCODE1  = '' THEN NULL
        ELSE (SELECT id FROM {db_new}.code_sets WHERE code = j7.BLLCODE1  AND parent_id = 67)
END
AS sales_rep_id,
    j7.BLLCONTACT AS billing_note,
    (SELECT ntcode FROM {db_old}.jcusf08 WHERE custmast = j7.bllmast LIMIT 1) AS customer_note_type,
--     j7.blltier, commented due arrow db
--     j7.bllsalesteam, commented due arrow db
--     j7.webpass, commented due arrow db
    CASE
        WHEN j1.stateprnt = 'Y' THEN 1
        ELSE 0
END
AS invoice_method_statement,
    CASE
        WHEN j1.LLCCBILL = 1 THEN 0
        ELSE 1
END
AS invoice_method_print,
    CASE
        WHEN j1.LLCCBILL = 0 THEN 0
        ELSE j1.LLCCBILL
END
AS invoice_method_email,
--     j7.CollectionMessage AS collection_note_type,
    null AS collection_note_type,
    CASE
        WHEN j1.ccardtype <> '' THEN j1.ccardtype
        ELSE NULL
END
AS card_type,
    99999 AS default_surcharge_id,
    0 AS default_surcharge_rate,
    j7.bllcrlmt AS credit_amount,
--     TRIM(j9.AuthDotNetProfileID) AS customer_profile_id,
--     TRIM(j9.AuthDotNetPaymentProfileID) AS payment_profile_id,
     null AS customer_profile_id,
    null AS payment_profile_id,
    CASE
        WHEN j9.terms LIKE 'NET%' THEN j9.terms
        ELSE 'DOR'
END
AS billing_terms,
    CASE
        WHEN j7.bllcode1 IN ('28A', '28R', 'EVNT', 'MONTH', 'MSA') THEN 'Advance'
        WHEN j7.bllcode1 IN ('COVID', 'DFW', 'FENCETEMP', 'MAR', 'MS', 'ROLLOFF', 'SEPTIC') THEN 'Arrears'
        ELSE NULL
END
AS scheduling_settings,
    'Standard' AS invoice_settings,
    CASE
        WHEN j1.billperiod IN ('28A', '28R', 'MSA') THEN '28 Day Fixed'
        WHEN j1.billperiod IN ('7', 'FENCETEMP', 'MAR', 'MONTH', 'MS') THEN 'Monthly'
        WHEN j1.billperiod IN ('COVID', 'DFW', 'EVNT', 'ROLLOFF', 'SEPTIC') THEN 'On Demand'
        ELSE NULL
END
AS default_bill_type,
    'Earliest' AS customer_bill_through_date_selection,
    (SELECT latedol FROM {db_old}.jreff03 WHERE cocode = j7.bllcocode LIMIT 1) AS late_charge,
    CASE
        WHEN j1.ccardtype <> '' AND j1.llccbill = 1 THEN 'CC'
        ELSE 'Check'
END
AS payment_method,
    cs.id AS grouping_code_salescredit_id
FROM {db_old}.jcusf07 j7
INNER JOIN LowestSite ls ON j7.bllmast = ls.custmast
INNER JOIN {db_old}.jcusf09 j9 ON j9.custnum = ls.LSCustnum
INNER JOIN {db_old}.jcusf01 j1 ON j9.custnum = j1.custnum
LEFT JOIN {db_new}.code_sets cs ON j9.billperiod = cs.code AND cs.parent_id = 112;

-- Update the state_id in {db_new}.customers
UPDATE {db_new}.customers p
    INNER JOIN {db_new}.code_sets s
ON p.bllstate = s.code
    SET p.state_id = s.id;

-- Set state_id to NULL for unmatched bllstate
UPDATE {db_new}.customers
SET state_id = NULL
WHERE bllstate NOT IN (SELECT code FROM {db_new}.code_sets);

-- Normalize card_type values
UPDATE {db_new}.customers
SET card_type = 'amex'
WHERE card_type IN ('AMEX', 'AMERICAN', 'A/E', 'AM', 'AE', 'AMERICAN EXPRESS');
UPDATE {db_new}.customers
SET card_type = 'mastercard'
WHERE card_type IN ('MC', 'MASTER', 'M C', 'Mastercard');
UPDATE {db_new}.customers
SET card_type = 'discover'
WHERE card_type IN ('DISC', 'discovery', 'Discover');
UPDATE {db_new}.customers
SET card_type = 'visa'
WHERE card_type IN ('VISA', 'FALSE', '');

-- Normalize billing_terms
UPDATE {db_new}.customers
SET billing_terms = 'NET10'
WHERE billing_terms = 'NET 10';
UPDATE {db_new}.customers
SET billing_terms = 'NET15'
WHERE billing_terms IN ('NET 15', 'NET 5');
UPDATE {db_new}.customers
SET billing_terms = 'NET30'
WHERE billing_terms IN ('NET', 'NETT', 'CHARGE');
UPDATE {db_new}.customers
SET billing_terms = 'DOR'
WHERE billing_terms = 'CCMONTHLY';
UPDATE {db_new}.customers
SET billing_note = REGEXP_REPLACE(billing_note, '<[^>]*>', '');
UPDATE {db_new}.customers
SET collection_note_type = REGEXP_REPLACE(collection_note_type, '<[^>]*>', '');

UPDATE {db_new}.customers
SET collection_note_type = LEFT(collection_note_type, 20)
WHERE LENGTH (collection_note_type) > 20;
UPDATE {db_new}.customers
SET contact_2_email = LEFT(contact_2_email, 50)
WHERE LENGTH (contact_2_email) > 50;

UPDATE {db_new}.customers
SET customer_note_type = 'Popup'
WHERE customer_note_type LIKE '%POP%';
UPDATE {db_new}.customers
SET customer_note_type = 'Standard'
WHERE customer_note_type <> 'Popup';

UPDATE {db_new}.customers
SET contact_1_first_name = rtrim(ltrim(contact_1_first_name));
UPDATE {db_new}.customers
SET contact_1_last_name = rtrim(ltrim(contact_1_last_name));
UPDATE {db_new}.customers
SET contact_1_phone = rtrim(ltrim(contact_1_phone));
UPDATE {db_new}.customers
SET contact_1_first_name = 'NA'
WHERE contact_1_first_name = ''
   OR contact_1_first_name IS NULL;
UPDATE {db_new}.customers
SET contact_1_last_name = 'NA'
WHERE contact_1_last_name = ''
   OR contact_1_last_name IS NULL;
UPDATE {db_new}.customers
SET contact_1_phone = '000-000-0000'
WHERE contact_1_phone = ''
   OR contact_1_phone IS NULL;
UPDATE {db_new}.customers
SET contact_1_email = 'noemail@email.com'
WHERE contact_1_email = ''
   OR contact_1_email IS NULL;

ALTER TABLE {db_new}.customers DROP COLUMN bllstate;
ALTER TABLE {db_new}.customers DROP COLUMN blledate;
ALTER TABLE {db_new}.customers DROP COLUMN blletime;
ALTER TABLE {db_new}.customers DROP COLUMN bllrating;
ALTER TABLE {db_new}.customers DROP COLUMN bllcountry;
-- ALTER TABLE {db_new}.customers DROP COLUMN blltier;commented due arrow db
-- ALTER TABLE {db_new}.customers DROP COLUMN bllsalesteam;  commented due arrow db
-- ALTER TABLE {db_new}.customers DROP COLUMN webpass;commented due arrow db

-- Final output for verification
SELECT *
FROM {db_new}.customers;