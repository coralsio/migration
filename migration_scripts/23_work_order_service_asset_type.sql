truncate table pf_new.work_order_service_asset_types;
INSERT INTO pf_new.work_order_service_asset_types (work_order_service_id, asset_type_id)
SELECT DISTINCT wos.id          AS work_order_service_id,
                a.asset_type_id AS asset_type_id
FROM pf_new.work_order_services wos
         INNER JOIN pf_new.assets a ON wos.custnum = a.site_id;