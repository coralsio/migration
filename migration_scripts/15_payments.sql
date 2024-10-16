-- UPDATE jpayf01 SET pentdate = null WHERE pentdate  = '';
-- UPDATE jpayf01 SET pentdate = STR_TO_DATE(pentdate, '%m/%d/%Y');

-- UPDATE jpayf01 SET checkdate =null WHERE checkdate  = '';
-- UPDATE jpayf01 SET checkdate = STR_TO_DATE(checkdate, '%m/%d/%Y');

-- UPDATE jpayf01 SET postdate =null WHERE postdate  = '';
-- UPDATE jpayf01 SET postdate = STR_TO_DATE(postdate, '%m/%d/%Y');


DROP
TEMPORARY TABLE IF EXISTS cardtypes;

CREATE
TEMPORARY TABLE cardtypes AS
SELECT DISTINCT checknum,
                CASE
                    WHEN LEFT(checknum, 1) = 'A' THEN 'AMEX'
    WHEN LEFT (checknum, 1) = 'D' THEN 'DISC'
    WHEN LEFT (checknum, 1) = 'V' THEN 'VISA'
    WHEN LEFT (checknum, 1) = 'M' THEN 'MC'
END
AS cardtype
FROM jpayf01
WHERE LEFT(checknum, 1) IN ('A', 'M', 'D', 'V')
  AND checknum NOT LIKE 'AD%';

truncate table pf_new.payments;

INSERT INTO pf_new.payments (ID, invoice_id, payment_date, check_date, post_date, card_type, batch_id, check_amount,
                             amount, tax_paid, tax_1_amount, method, eft_check, note, customer_id, site_id, created_at)
SELECT ROW_NUMBER()                     OVER(ORDER BY jp.invoice ASC) AS ID, jp.invoice AS invoice_id,
       jp.pentdate                   AS payment_date,
       jp.checkdate                  AS check_date,
       jp.postdate                   AS post_date,
       ct.cardtype                   AS card_type,
       jp.control                    AS batch_id,
       jp.checkamt                   AS check_amount,
       jp.payment                    AS amount,
       jp.paytax                     AS tax_paid,
       jp.paytax                     AS tax_1_amount,
       jp.checknum                   AS method,
       jp.checknum                   AS eft_check,
       CAST(jp.paydesc AS CHAR(200)) AS note,
       ps.customer_id,
       ps.id                         AS site_id,
       jp.pentdate                   AS created_at
FROM jpayf01 jp
         LEFT OUTER JOIN pf_new.sites ps ON jp.custnum = ps.id
         LEFT OUTER JOIN cardtypes ct ON jp.checknum = ct.checknum;


-- Update method to 'CC' for specific values
UPDATE pf_new.payments
SET method = 'CC'
WHERE method IN ('AMEX', 'MC', 'V', 'VISA', 'AME', 'DIS', 'DISC', 'VI', 'VS', 'VIS');

-- Update method to 'Check' where eft_check is numeric
UPDATE pf_new.payments
SET method = 'Check'
WHERE eft_check REGEXP '^[0-9]+$';

-- Update method to 'Other' where method contains 'CASH'
UPDATE pf_new.payments
SET method = 'Other'
WHERE method LIKE '%CASH%';

-- Update method to 'Other' where method contains 'ADJ'
UPDATE pf_new.payments
SET method = 'Other'
WHERE method LIKE '%ADJ%';

-- Update method to 'Other' for all remaining non-matching methods
UPDATE pf_new.payments
SET method = 'Other'
WHERE method NOT IN ('CC', 'Check', 'Other');