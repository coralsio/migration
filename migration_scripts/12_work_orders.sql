-- UPDATE jtktf01 SET reqdate = NULL WHERE reqdate ='';
-- UPDATE jtktf01 SET reqdate = STR_TO_DATE(reqdate, '%m/%d/%Y');

-- UPDATE jtktf01 SET schdate = NULL WHERE schdate ='';
-- UPDATE jtktf01 SET schdate = STR_TO_DATE(schdate, '%m/%d/%Y');

truncate table pf_new.work_orders;

INSERT INTO pf_new.work_orders (id, dispatched, site_id, sales_rep_id, Invoice_ID, status_id, is_recurring, type,
                                po_number, processed, route_id, route_schedule_id, scheduled_time, scheduled_date,
                                requested_time, invoice_note, route_note, cod, driver_id, truck_id, stop_number,
                                created_at,
                                -- autoid,
                                custnum,
                                invno
                                -- mediajoinkey
                                )
SELECT ROW_NUMBER()                                                                                                OVER(ORDER BY jk.custnum ASC) AS id, 1 AS dispatched,
       pf.id                                                                                                    AS site_id,
       COALESCE((SELECT id FROM pf_new.code_sets cs WHERE code = jk.tktsale AND parent_id = 117 LIMIT
                1), NULL)                                                                                       AS sales_rep_id,      -- need to look at for other clients
       NULL                                                                                                     AS Invoice_ID,        -- this is technically the chrgwono which is why we include invno at bottom to join when we build linecharges
       COALESCE((SELECT id FROM pf_new.code_sets WHERE code = jk.prodtext AND parent_id = 107 LIMIT
                1), 107)                                                                                        AS status_id,
       1                                                                                                        AS is_recurring,
       COALESCE(
               (SELECT DISTINCT CASE
                                    WHEN description LIKE '%SERVICE%' THEN 'Service'
                                    WHEN description LIKE '%DELIVER%' THEN 'Delivery'
                                    WHEN description LIKE '%PICK%UP%' THEN 'Pickup'
                                    END
                FROM pf_new.code_sets
                WHERE code = jk.typesrv
                  AND parent_id = 111), NULL
           )                                                                                                    AS type,              -- defaulting to service, but should be changed in PF DB
       jk.ponum                                                                                                 AS po_number,
       1                                                                                                        AS processed,
       COALESCE((SELECT id FROM pf_new.routes WHERE code = jk.grpcode LIMIT 1), NULL)                           AS route_id,
       NULL                                                                                                     AS route_schedule_id, -- loopback
       '00:00:00'                                                                                               AS scheduled_time,
       jk.schdate                                                                                               AS scheduled_date,
       RTRIM(jk.reqtime)                                                                                        AS requested_time,
       jk.ratememo                                                                                              AS invoice_note,
       jk.notememo                                                                                              AS route_note,
       jk.tktcash                                                                                               AS cod,
       COALESCE((SELECT id FROM pf_new.code_sets WHERE code = jk.driver AND parent_id = 115 LIMIT
                1), NULL)                                                                                       AS driver_id,         -- driver blank in code_sets mapping
       COALESCE((SELECT id FROM pf_new.code_sets WHERE code = jk.truck AND parent_id = 110 LIMIT
                1), NULL)                                                                                       AS truck_id,
       jk.stopnum                                                                                               AS stop_number,
       jk.reqdate                                                                                               AS created_at,
       -- autoid,
       jk.custnum,
       jk.invno
    --   jk.AutoID                                                                                                as mediajoinkey
FROM jtktf01 jk
         LEFT OUTER JOIN pf_new.sites pf ON jk.custnum = pf.id;


UPDATE pf_new.work_orders
SET stop_number = 999
WHERE stop_number REGEXP '[^0-9]';

UPDATE pf_new.work_orders
SET route_note = REGEXP_REPLACE(route_note, '<[^>]+>', '');

delete
from pf_new.work_orders
where scheduled_date < '2019-01-01';
delete
from pf_new.work_orders
where site_id is null;

UPDATE pf_new.assets
    JOIN (
    SELECT site_id, MIN(id) AS min_id
    FROM pf_new.work_orders
    WHERE `type` = 'Delivery'
    GROUP BY site_id
    ) AS min_work_order
ON pf_new.assets.site_id = min_work_order.site_id
    SET pf_new.assets.work_order_id = min_work_order.min_id;