truncate table pf_new.template_work_order_service_asset_types;

INSERT INTO pf_new.template_work_order_service_asset_types (template_work_order_service_id, asset_type_id)
SELECT DISTINCT ptwos.id AS template_work_order_service_id,
                pfa.asset_type_id
FROM pf_new.assets pfa
         INNER JOIN
     pf_new.template_work_order_services ptwos ON pfa.template_work_order_id = ptwos.template_work_order_id;
