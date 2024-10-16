truncate table pf_new.equipments;

INSERT INTO pf_new.equipments (ID,
                               site_id,
                               template_work_order_id,
                               work_order_id,
                               type_id,
                               description,
                               hose_feet,
                               size,
                               depth,
                               interval_of_service,
                               cover,
                               `condition`,
                               notes,
                               latitude,
                               longitude
                               -- mediajoinkey
                               )
SELECT ROW_NUMBER()                             OVER(ORDER BY a.custnum ASC)             AS ID,
pf.id AS site_id,
       0                                     AS template_work_order_id,
       0                                     AS work_order_id,
       COALESCE(
               (SELECT id
                FROM pf_new.code_sets
                WHERE code = a.tktype
                  AND parent_id = 104), 104) AS type_id,
       a.tkloc                               AS description,
       a.tkdrain                             AS hose_feet,
       a.tksize AS size,
    a.tkdepth AS depth,
    a.tkyears AS interval_of_service,
    a.tkcover AS cover,
    a.tkout AS `condition`,
    a.tkmemo AS notes,
    CASE 
        WHEN UPPER(a.tkmaplat) = '' THEN '0' 
        ELSE a.tkmaplat
END
AS latitude,
    CASE 
        WHEN UPPER(a.tkmaplong) = '' THEN '0' 
        ELSE a.tkmaplong
END
AS longitude
-- ,a.ID as mediajoinkey
FROM jtnkf01 a
INNER JOIN pf_new.sites pf ON a.custnum = pf.id