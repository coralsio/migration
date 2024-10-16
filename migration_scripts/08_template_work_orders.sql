-- UPDATE jrtf01 SET rentdate =null WHERE rentdate  = '';
-- UPDATE jrtf01 SET rentdate = STR_TO_DATE(rentdate ,'%m/%d/%Y');

truncate table pf_new.template_work_orders;

INSERT INTO pf_new.template_work_orders (id,
                                         site_id,
                                         po_number,
                                         billing_note,
                                         job_note,
                                         cod,
                                         is_draft,
                                         asset_route_id,
                                         created_at,
    --   autoid,
                                         custnum,
                                         sales_rep_id)
SELECT ROW_NUMBER()                   OVER (ORDER BY jrt.custnum) AS id, pf.id AS site_id,
       CAST(jc.po_num AS CHAR(24)) AS po_number,
       jc.billfield                AS billing_note,
       RTRIM(jc.dirmemo)           AS job_note,
       NULL                        AS cod,
       0                           AS is_draft,
       NULL                        AS asset_route_id,
       jrt.rentdate                AS created_at,
       -- jrt.autoid,
       jrt.custnum,
       salesrep.id                 AS sales_rep_id
FROM jrtf01 jrt
         JOIN
     pf_new.sites pf ON jrt.custnum = pf.id
         LEFT JOIN
     jcusf01_sites_dbf jc ON jrt.custnum = jc.custnum
         LEFT JOIN
     jcusf09 j9 ON jc.custnum = j9.custnum
         LEFT JOIN
     pf_new.code_sets salesrep ON salesrep.code = j9.salecredit AND salesrep.parent_id = 117
ORDER BY jrt.custnum;

INSERT INTO pf_new.template_work_orders (id, site_id, po_number, billing_note, job_note, cod, is_draft, asset_route_id,
                                         created_at, custnum, sales_rep_id)
SELECT COALESCE((SELECT MAX(id) FROM pf_new.template_work_orders), 0) + (@rownum := @rownum + 1) AS id,
       pf.id                                                                                     AS site_id,
       CAST(jc.po_num AS CHAR(24))                                                               AS po_number,
       jc.billfield                                                                              AS billing_note,
       jc.dirmemo                                                                                AS job_note,
       NULL                                                                                      AS cod,
       0                                                                                         AS is_draft,
       NULL                                                                                      AS asset_route_id,
       jr.rtentdate                                                                              AS created_at,
       jr.custnum                                                                                as custnum,
       salesrep.id                                                                               AS sales_rep_id
FROM jrtf05 jr
         inner JOIN pf_new.sites pf ON jr.custnum = pf.id
         LEFT JOIN jcusf01_sites_dbf jc ON jr.custnum = jc.custnum
         LEFT JOIN jcusf09 j9 ON jc.custnum = j9.custnum
         LEFT JOIN pf_new.code_sets salesrep ON salesrep.code = j9.salecredit AND salesrep.parent_id = 117
         CROSS JOIN (SELECT @rownum := 0) r;


update pf_new.template_work_orders
set created_at ='1990-01-01'
where created_at < '1990-01-01'
   or created_at > '2030-01-01';



update pf_new.template_work_orders
set billing_note = REGEXP_REPLACE(billing_note, '<[^>]*>', '');
update pf_new.template_work_orders
set job_note = REGEXP_REPLACE(job_note, '<[^>]*>', '');

DROP
TEMPORARY TABLE IF EXISTS pftwo;

CREATE
TEMPORARY TABLE pftwo AS
SELECT MIN(id)             AS id,
       site_id,
       MIN(po_number)      AS po_number,
       MIN(billing_note)   AS billing_note,
       MIN(job_note)       AS job_note,
       MIN(cod)            AS cod,
       MIN(is_draft)       AS is_draft,
       MIN(asset_route_id) AS asset_route_id,
       MIN(created_at)     AS created_at,
       MIN(custnum)        AS custnum,
       MIN(sales_rep_id)   AS sales_rep_id
FROM pf_new.template_work_orders
GROUP BY site_id;

SET
foreign_key_checks=0;
truncate table pf_new.template_work_orders;
SET
foreign_key_checks=1;

INSERT INTO pf_new.template_work_orders (id, site_id, po_number, billing_note, job_note, cod, is_draft, asset_route_id,
                                         created_at, custnum, sales_rep_id)
SELECT id,
       site_id,
       po_number,
       billing_note,
       job_note,
       cod,
       is_draft,
       asset_route_id,
       created_at,
       custnum,
       sales_rep_id
FROM pftwo;
