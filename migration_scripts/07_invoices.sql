drop temporary table if exists tax;
CREATE
TEMPORARY TABLE tax AS
SELECT chrginv,
       SUM(chrgamt) AS pretaxtotal,
       SUM(chrgtax) AS taxtotal
FROM jxchrgf1
WHERE chrgdate > '2018-12-01'
GROUP BY chrginv;

-- CREATE INDEX idx_chrginv ON tax(chrginv);


DROP PROCEDURE IF EXISTS UpdateTaxAmounts;
DELIMITER
//

CREATE PROCEDURE UpdateTaxAmounts()
BEGIN
    DECLARE
batch_size INT DEFAULT 1000;
    DECLARE
row_count INT DEFAULT 1; -- Initialize row count to enter the loop

    WHILE
row_count > 0 DO
            -- Update statement with limit for batch processing
UPDATE jivof01 jv
    LEFT JOIN tax jx
ON jv.prev_inv = jx.chrginv
    SET
        jv.PFTaxAmount = COALESCE (jx.taxtotal, 0),
        jv.PFPreTaxTotal = COALESCE (jx.pretaxtotal, 0)
WHERE
    jv.invdate
    > '2019-01-01'
    LIMIT batch_size;

-- Get the count of rows updated in this batch
SET
row_count = ROW_COUNT();
END WHILE;
END
//

DELIMITER ;

CALL UpdateTaxAmounts();
truncate table pf_new.invoices;

UPDATE jcusf09 SET terms = 'NET15' WHERE terms IN ('NET 15', 'MET15');
UPDATE jcusf09 SET terms = 'NET30' WHERE terms IN ('NET90');

INSERT INTO pf_new.invoices (id,
                             is_billable,
                             customer_id,
                             site_id,
                             settings,
                             user_id,
                             amount,
                             tax_amount,
                             tax_1_amount,
                             tax_2_amount,
                             total_amount,
                             paid,
                             invoice_date,
                             billing_terms,
                             due_date)
SELECT jv.prev_inv                     AS id,
       1                               as is_billable,
       pfc.id                          AS customer_id,
       pfs.id                          AS site_id,
       'Standard'                      AS settings,
       COALESCE((SELECT id FROM pf_new.code_sets cs WHERE code = jc.centclerk AND parent_id IN (100, 112) LIMIT
                1), 100)               AS user_id,
       COALESCE(jv.PFPreTaxTotal, 0)   AS amount,
       COALESCE(jv.PFTaxAmount, 0)     AS tax_amount,
       CAST(0.00 AS DECIMAL(10, 3))    AS tax_1_amount,
       CAST(0.00 AS DECIMAL(10, 3))    AS tax_2_amount,
       jv.currentamt                   AS total_amount,
       CASE
           WHEN COALESCE(jv.paidamt, 0) > COALESCE(jv.currentamt, 0) THEN -1
           WHEN COALESCE(jv.paidamt, 0) = COALESCE(jv.currentamt, 0) THEN 1
           ELSE 0
           END                         AS paid,
       jv.invdate                      AS invoice_date,
       trim(CASE
                WHEN j9.terms LIKE 'NET%' THEN j9.terms
                ELSE 'DOR'
           END)                        AS billing_terms,
       DATE_ADD(jv.invdate, INTERVAL CASE
        WHEN RIGHT(TRIM(pfs.billing_terms), 2) REGEXP '^[0-9]+$' THEN CAST(RIGHT(TRIM(pfs.billing_terms), 2) AS UNSIGNED)
        ELSE 0
    END DAY
) AS due_date
FROM jivof01 jv
         INNER JOIN
     jcusf01_sites_dbf jc ON jv.custnum = jc.custnum
         INNER JOIN
     pf_new.customers pfc ON jc.custmast = pfc.number
         INNER JOIN
     pf_new.sites pfs ON jv.custnum = pfs.id
         INNER JOIN
     jcusf09 j9 ON jv.custnum = j9.custnum
group by prev_inv;


-- UPDATE pf_new.invoices i
--     LEFT JOIN (
--     SELECT chrginv, SUM(chrgamttax1) AS tax1, SUM(chrgamttax2) AS tax2
--     FROM jxchrgf1
--     GROUP BY chrginv
--     ) a
-- ON i.id = a.chrginv
--     SET
--         i.tax_1_amount = COALESCE (a.tax1, 0),
--         i.tax_2_amount = COALESCE (a.tax2, 0);

update pf_new.invoices
set tax_amount = 0
where tax_amount is NULL;

update pf_new.invoices
set amount = 0
where amount is NULL;
update pf_new.invoices
set total_amount = 0
where total_amount is NULL;
delete
from pf_new.invoices
where invoice_date < '2019-01-01';
update pf_new.invoices
set billing_Terms = 'DOR'
where billing_terms = ''
   or billing_terms = 'COD';


update pf_new.invoices
set billing_terms = 'NET10'
where billing_terms = '2';
update pf_new.invoices
set billing_terms = 'NET10'
where billing_terms = 'NET 10';
update pf_new.invoices
set billing_terms = 'NET15'
where billing_terms IN ('NET 15', 'NET 5');
update pf_new.invoices
set billing_terms = 'NET30'
where billing_terms = 'CC';
update pf_new.invoices
set billing_terms = 'NET30'
where billing_terms = 'CHARGE';
update pf_new.invoices
set billing_terms = 'DOR'
where billing_terms = 'CCMONTHLY';
update pf_new.invoices
set billing_terms = 'NET30'
where billing_terms = 'NET';
update pf_new.invoices
set billing_terms = 'NET30'
where billing_terms = 'NETT';
update pf_new.invoices
set billing_terms = 'NET15'
where billing_terms = 'NET20';