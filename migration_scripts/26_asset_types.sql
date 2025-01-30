DROP
TEMPORARY TABLE IF EXISTS latestworkorderForSite;

CREATE
TEMPORARY TABLE latestworkorderForSite AS
SELECT a.site_id, MAX(id) AS work_order_id
FROM (
         SELECT pfw.site_id, id
         FROM (
                  SELECT MAX(scheduled_date) AS dd, site_id
                  FROM {db_new}.work_orders
                  GROUP BY site_id
              ) pfw
                  INNER JOIN {db_new}.work_orders pfw1
                             ON pfw.site_id = pfw1.site_id
                                 AND pfw.dd = pfw1.scheduled_date
     ) a
GROUP BY a.site_id;

truncate table {db_new}.asset_services;

INSERT INTO {db_new}.asset_services (asset_id, work_order_service_id, work_order_id, template_work_order_service_id,
                                   template_work_order_id, service_ended, created_at)
SELECT pfa.id  AS asset_id,
       pwos.id AS work_order_service_id,
       LS.work_order_id,
       pfats.template_work_order_service_id,
       ptwo.template_work_order_id,
       0       AS service_ended,
       NOW()   AS created_at
FROM {db_new}.assets pfa
         INNER JOIN latestworkorderForSite LS
                    ON pfa.site_id = LS.site_id
         INNER JOIN {db_new}.work_order_services pwos
                    ON LS.work_order_id = pwos.work_order_id
         INNER JOIN {db_new}.asset_template_services pfats
                    ON pfa.id = pfats.asset_id
         INNER JOIN {db_new}.template_work_order_services ptwo
                    ON ptwo.id = pfats.template_work_order_service_id
group by pfa.id