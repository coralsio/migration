truncate table {db_new}.asset_template_services;

INSERT INTO {db_new}.asset_template_services (asset_id, template_work_order_service_id, created_at)
SELECT pfa.id AS asset_id,
       pfs.id AS template_work_order_service_id,
       NOW()  AS created_at
FROM {db_new}.assets pfa
         INNER JOIN {db_new}.template_work_order_services pfs
                    ON pfa.template_work_order_id = pfs.template_work_order_id
WHERE pfa.template_work_order_id IS NOT NULL;