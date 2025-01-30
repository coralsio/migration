-- Check for more than one entry per custnum in jcusf05
/* IMPORTANT: check billing matrix per client for default bill_type and scheduling_settings!!!!! */
SET SESSION sql_mode = '';

-- Drop sites table if it exists

DROP TABLE IF EXISTS {db_new}.sites;

-- Create the sites table

CREATE TABLE {db_new}.sites
(
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY

) AS
SELECT
                pfc.id                                                                AS customer_id,
                TRIM(a.sitename)                                                      AS name,
                CASE
                    WHEN LOCATE(' ', d.bllcontact) > 0 THEN SUBSTRING_INDEX(d.bllcontact, ' ', 1)
                    ELSE d.bllcontact
                    END                                                               AS contact_1_first_name,
                CASE
                    WHEN LOCATE(' ', d.bllcontact) > 0 THEN SUBSTRING_INDEX(d.bllcontact, ' ', -1)
                    ELSE ''
                    END                                                               AS contact_1_last_name,
                d.bllphone                                                            AS contact_1_phone,
                CASE
                    WHEN LOCATE(' ', super) > 0 THEN SUBSTRING_INDEX(super, ' ', 1)
                    ELSE super
                    END                                                               AS contact_2_first_name,
                CASE
                    WHEN LOCATE(' ', super) > 0 THEN SUBSTRING_INDEX(super, ' ', -1)
                    ELSE ''
                    END                                                               AS contact_2_last_name,
                a.sitephone                                                           AS contact_2_phone,
                a.sitefax                                                             AS contact_3_phone,
                TRIM(a.siteaddr)                                                      AS address_1,
                TRIM(a.siteaddr2)                                                     AS address_2,
                TRIM(a.sitecity)                                                      AS city,
                COALESCE(
                        (SELECT id
                         FROM {db_new}.code_sets c
                   WHERE c.code = a.sitestate
                     AND parent_id = 1), 1)     AS state_id,
                TRIM(a.sitezip)                                                       AS zip,
                'Active'                                                              AS status,
                REPLACE(TRIM(b.email), ';', ',')                                      AS contact_1_email,
                REPLACE(TRIM(b.email2), ';', ',')                                     AS contact_2_email,
                TRIM(b.county)                                                        AS county,
                TRIM(b.township)                                                      AS township,
                COALESCE(
                        (SELECT CASE
                                    WHEN refdesc = '0' THEN 'Earliest'
                                    ELSE 'Latest'
                                    END
                         FROM {db_old}.jref0r2
                WHERE refcode = '1143'
                  AND refcode = a.cocode
               LIMIT 1), 'Earliest')            AS site_bill_through_date_selection,
                COALESCE(
                        (SELECT id
                         FROM {db_new}.code_sets cs
                   WHERE code = b.accttype
                     AND parent_id = 101), 101) AS market_segment_id,
                COALESCE(
                        (SELECT id
                         FROM {db_new}.code_sets
                   WHERE code = b.salecredit
                     AND parent_id = 112), 112) AS billing_term_id,

                (SELECT id
                 FROM {db_new}.divisions
WHERE division_code = a.cocode) AS division_id
    , CASE
    WHEN a.ccardtype = '' THEN NULL
    ELSE a.ccardtype
END
AS card_type,
       a.billfield AS billing_note,
       rtrim(ltrim(CAST(a.dirmemo AS CHAR))) AS job_note,
       CASE
           WHEN a.maplat = '' THEN '0'
           ELSE a.maplat
END
AS latitude,
       CASE
           WHEN a.maplong = '' THEN '0'
           ELSE a.maplong
END
AS longitude, --     TRIM(CAST(b.AuthDotNetProfileID AS CHAR)) AS customer_profile_id,
--     TRIM(CAST(b.AuthDotNetPaymentProfileID AS CHAR)) AS payment_profile_id,
 CASE
     WHEN a.llccbill = 1 THEN 'CC'
     ELSE 'Check'
END
AS payment_method,
 CASE
     WHEN a.stateprnt = 'Y' THEN 1
     ELSE 0
END
AS invoice_method_statement,
 CASE
     WHEN a.LLCCBILL = 1 THEN 0
     ELSE 1
END
AS invoice_method_print,
 CASE
     WHEN a.LLCCBILL = 0 THEN 0
     ELSE a.LLCCBILL
END
AS invoice_method_email,
 CASE
     WHEN b.billperiod IN ('28A',
                           '28R',
                           'EVNT',
                           'MONTH',
                           'MSA') THEN 'Advance'
     WHEN b.billperiod IN ('COVID',
                           'DFW',
                           'FENCETEMP',
                           'MAR',
                           'MS',
                           'ROLLOFF',
                           'SEPTIC') THEN 'Arrears'
     ELSE NULL
END
AS scheduling_settings,
--  CASE
--      WHEN DefaultInvoiceFormat = 1 THEN 'Multi-Site'
--      ELSE 'Standard'
-- END AS invoice_settings,
 CASE
     WHEN b.billperiod IN ('28A',
                           '28R',
                           'MSA') THEN '28 Day Fixed'
     WHEN b.billperiod IN ('7',
                           'FENCETEMP',
                           'MAR',
                           'MONTH',
                           'MS') THEN 'Monthly'
     WHEN b.billperiod IN ('COVID',
                           'DFW',
                           'EVNT',
                           'ROLLOFF',
                           'SEPTIC') THEN 'On Demand'
     ELSE NULL
END
AS default_bill_type,
 CASE
     WHEN b.terms LIKE 'NET%' THEN b.terms
     ELSE b.terms
END
AS billing_terms,
 COALESCE(
            (SELECT id
             FROM {db_new}.code_sets
             WHERE code = c.sccode
               AND parent_id = 113), 113) AS default_surcharge_id,
 scpamt AS default_surcharge_rate,
 a.po_num AS po_number,
 1 AS tax_manual_override,
 a.taxpcnt AS tax_rate_1,
 a.taxpcnt2 AS tax_rate_2,
 a.centdate AS created_at,
 a.cocode AS cocode,
 cs.id AS grouping_code_salescredit_id
FROM {db_old}.jcusf01 a
INNER JOIN {db_new}.customers PFC ON a.custmast = PFC.customer_number
LEFT OUTER JOIN {db_old}.jcusf09 b ON a.custnum = b.custnum
LEFT OUTER JOIN {db_old}.jcusf05 c ON a.custnum = c.custnum
LEFT OUTER JOIN {db_old}.jcusf07 d ON a.custmast = d.bllmast
LEFT JOIN {db_new}.code_sets cs ON b.billperiod = cs.code
AND cs.parent_id = 112;

-- Additional updates for data normalization

UPDATE {db_new}.sites
SET invoice_method_print = 1
WHERE invoice_method_print = 0
  AND invoice_method_email = 0;


UPDATE {db_new}.sites
SET default_surcharge_rate = 0
WHERE default_surcharge_rate IS NULL;

-- Normalize card_type values

UPDATE {db_new}.sites
SET card_type = 'amex'
WHERE card_type IN ('AMEX'
    , 'AMERICAN'
    , 'A/E'
    , 'AM'
    , 'AE'
    , 'AMERICAN EXPRESS');


UPDATE {db_new}.sites
SET card_type = 'mastercard'
WHERE card_type IN ('MC'
    , 'MASTER'
    , 'M C'
    , 'Mastercard');


UPDATE {db_new}.sites
SET card_type = 'discover'
WHERE card_type IN ('DISC'
    , 'discovery'
    , 'Discover');


UPDATE {db_new}.sites
SET card_type = 'visa'
WHERE card_type IN ('VISA'
    , 'FALSE'
    , '');


UPDATE {db_new}.sites
SET card_type = NULL
WHERE card_type = '';


UPDATE {db_new}.sites
SET card_type = LOWER (card_type);


UPDATE {db_new}.sites
SET billing_terms = 'NET10'
WHERE billing_terms IN ('NET 10'
    , '2');


UPDATE {db_new}.sites
SET billing_terms = 'NET15'
WHERE billing_terms IN ('NET 15'
    , 'NET 5');


UPDATE {db_new}.sites
SET billing_terms = 'NET30'
WHERE billing_terms IN ('NET'
    , ''
    , 'CC'
    , 'NETT');


UPDATE {db_new}.sites
SET billing_terms = 'DOR'
WHERE billing_terms = 'CCMONTHLY';

-- Update coordinates

UPDATE {db_new}.sites
SET longitude = 0
WHERE longitude = '-'
   OR longitude LIKE '%--%';


UPDATE {db_new}.sites
SET longitude = REPLACE(longitude, ', ', '');


UPDATE {db_new}.sites
SET latitude = REPLACE(latitude, ', ', '');


UPDATE {db_new}.sites
SET latitude = REPLACE(latitude, '+', '');


UPDATE {db_new}.sites
SET billing_note = rtrim(ltrim(billing_note)), job_note = rtrim(ltrim (job_note));


UPDATE {db_new}.sites
SET contact_1_first_name = rtrim(ltrim( contact_1_first_name)), contact_1_last_name = rtrim(ltrim(contact_1_last_name));


UPDATE {db_new}.sites
SET contact_1_phone = rtrim(ltrim(contact_1_phone));


UPDATE {db_new}.sites
SET contact_1_first_name = 'NA'
WHERE contact_1_first_name = ''
   OR contact_1_first_name IS NULL;


UPDATE {db_new}.sites
SET contact_1_last_name = 'NA'
WHERE contact_1_last_name = ''
   OR contact_1_last_name IS NULL;


UPDATE {db_new}.sites
SET contact_1_email = 'noemail@email.com'
WHERE contact_1_email = ''
   OR contact_1_email IS NULL;


SELECT *
FROM {db_new}.sites;