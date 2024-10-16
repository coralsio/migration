-- UPDATE jxchrgf1 SET chrgdate =null WHERE chrgdate  = '';


-- UPDATE jxchrgf1 SET chrgedate =null WHERE chrgedate  = '';
-- UPDATE jxchrgf1 SET chrgedate = STR_TO_DATE(chrgedate, '%m/%d/%Y');


-- UPDATE jxchrgf1 SET chrgsdate =null WHERE chrgsdate  = '';
-- UPDATE jxchrgf1 SET chrgsdate = STR_TO_DATE(chrgsdate, '%m/%d/%Y');
--
-- UPDATE jxchrgf1 SET xentdate =null WHERE xentdate  = '';
-- UPDATE jxchrgf1 SET xentdate = STR_TO_DATE(xentdate, '%m/%d/%Y');


truncate table pf_new.line_charges;

INSERT INTO pf_new.line_charges (ID,
                                 work_order_service_id,
                                 user_id,
                                 unique_id,
                                 work_order_asset_id,
                                 work_order_id,
                                 site_id,
                                 Invoice_id,
                                 customer_id,
                                 asset_id,
                                 type,
                                 start_date,
                                 bill_service_date,
                                 bill_through_date,
                                 description,
                                 bill_type,
                                 rate_code_code,
                                 rate_1,
                                 rate_2,
                                 quantity,
                                 amount,
                                 taxable_amount,
                                 is_taxable,
                                 tax_amount,
                                 tax_1_amount,
                                 created_at,
                                 total_amount,
                                 sales_rep_id)
SELECT ROW_NUMBER()                                                                                              OVER(ORDER BY jx.custnum ASC) AS ID, NULL AS work_order_service_id,
       COALESCE((SELECT id FROM pf_new.code_sets WHERE code = jx.chrgclerk AND parent_id = 100 LIMIT
                1), 100)                                                     AS                                  user_id,
       jx.chrgid                                                             AS                                  unique_id,
       NULL                                                                  AS                                  work_order_asset_id,
       COALESCE(pw.id, NULL)                                                 AS                                  work_order_id,
       jx.custnum                                                            AS                                  site_id,
       CASE WHEN chrginv = 0 THEN NULL ELSE chrginv END                      AS                                  Invoice_id,
       pfs.customer_id                                                       AS                                  customer_id,
       COALESCE(pfa.id, NULL)                                                AS                                  asset_id,
       CASE WHEN COALESCE(chrgutype, '') <> '' THEN 'Asset' ELSE 'Other' END AS                                  type,
       jx.chrgsdate                                                          AS                                  start_date,
       jx.chrgdate                                                           AS                                  bill_service_date,
       jx.chrgedate                                                          AS                                  bill_through_date,
       jx.chrgmemo                                                           AS                                  description,
       NULL                                                                  AS                                  bill_type,
       jx.chrgcode                                                           AS                                  rate_code_code,
       jx.chrgrate                                                           AS                                  rate_1,
       jx.chrgtrate                                                          AS                                  rate_2,
       CAST(jx.chrgqty AS DECIMAL(12, 2))                                    AS                                  quantity,
       jx.chrgamt                                                            AS                                  amount,
       jx.chrgamttax                                                         AS                                  taxable_amount,
       CASE WHEN chrgtax > 0 THEN 1 ELSE 0 END                               AS                                  is_taxable,
       jx.chrgtax                                                            AS                                  tax_amount,
       jx.chrgtax                                                            AS                                  tax_1_amount,
       jx.xentdate                                                           AS                                  created_at,
       jx.chrgamt + jx.chrgtax                                               AS                                  total_amount,
       salesrep.id                                                           AS                                  sales_rep_id
FROM jxchrgf1 jx
         LEFT JOIN pf_new.sites pfs ON jx.custnum = pfs.id
         LEFT JOIN pf_new.assets pfa ON pfa.site_id = jx.custnum AND jx.chrgserial = pfa.serial_no
         LEFT JOIN pf_new.work_orders pw ON jx.chrgwono = pw.invno
         LEFT JOIN jcusf09 jc ON jx.custnum = jc.custnum
         LEFT JOIN pf_new.code_sets salesrep ON salesrep.code = jc.salecredit AND salesrep.parent_id = 117
WHERE jx.chrginv = 0;

UPDATE pf_new.line_charges
SET quantity = CAST(quantity AS DECIMAL(10, 0))
WHERE quantity > 999999;

-- Update the work_order_id where it is 0
UPDATE pf_new.line_charges
SET work_order_id = 9999999
WHERE work_order_id = 0;

-- Update bill_service_date where it is earlier than '1930-01-01'
UPDATE pf_new.line_charges
SET bill_service_date = '1990-01-01'
WHERE bill_service_date < '1930-01-01';

-- Update bill_through_date where it is earlier than '1930-01-01'
UPDATE pf_new.line_charges
SET bill_through_date = '1990-01-01'
WHERE bill_through_date < '1930-01-01';

-- Update start_date where it is earlier than '1930-01-01'
UPDATE pf_new.line_charges
SET start_date = '1990-01-01'
WHERE start_date < '1930-01-01';

-- Update created_at where it is earlier than '1930-01-01'
UPDATE pf_new.line_charges
SET created_at = '1990-01-01'
WHERE created_at < '1930-01-01';

-- Delete records where invoice_id does not exist in pfinvoices
DELETE
FROM pf_new.line_charges
WHERE invoice_id NOT IN (SELECT id FROM pf_new.invoices);

-- Update escape character :)
UPDATE pf_new.line_charges
SET description = REPLACE(description, '\\', '-')
WHERE description LIKE '%\\\\%';