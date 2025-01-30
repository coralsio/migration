set FOREIGN_key_checks=0;
truncate table {db_new}.work_order_services;

INSERT INTO {db_new}.work_order_services (id, work_order_id, rate_code_code, rate_code_id, template_work_order_service_id,
                                        service_type_id, rate_code_value, rate_code_description
--                                           custnum commented due row db
)
SELECT @rownum := @rownum + 1 AS id,
    pf.id AS work_order_id,
    jt.ratecode1 AS rate_code_code,
    COALESCE((SELECT id FROM {db_new}.code_sets cs WHERE cs.code = jt.ratecode1 AND parent_id = 106), 5092) AS rate_code_id,
    NULL AS template_work_order_service_id,
    COALESCE((SELECT id FROM {db_new}.code_sets WHERE code = typesrv AND parent_id = 111 LIMIT 1), NULL) AS service_type_id,
    jt.ratecode1 AS rate_code_value,
    CAST(jt.ratememo AS CHAR(255)) AS rate_code_description
--     jt.custnum commented due arrow db
FROM {db_old}.jtktf01 jt
    LEFT OUTER JOIN {db_new}.work_orders pf
    ON pf.site_id = jt.custnum
--    AND jt.invno = pf.invno commented due arrow db
    CROSS JOIN (SELECT @rownum := 0) AS r;
