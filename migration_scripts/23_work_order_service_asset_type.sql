truncate table {db_new}.work_order_service_asset_types;
INSERT INTO {db_new}.work_order_service_asset_types (work_order_service_id, asset_type_id)
SELECT DISTINCT wos.id          AS work_order_service_id,
                a.asset_type_id AS asset_type_id
-- FROM {db_new}.work_order_services wos
--          INNER JOIN {db_new}.assets a ON wos.custnum = a.site_id; commented due arrow db

-- added due arrow db

FROM {db_new}.work_order_services wos
INNER JOIN {db_new}.work_orders pf ON pf.id = wos.work_order_id
    LEFT OUTER JOIN {db_new}.assets a ON pf.site_id = a.site_id;
