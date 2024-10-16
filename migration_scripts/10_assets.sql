    UPDATE jivtf01
    set billthru = NULL
    WHERE billthru = '';
    UPDATE jivtf01
    set inputdate = NULL
    WHERE inputdate = '';
    UPDATE jivtf01
    set uentdate = NULL
    WHERE uentdate = '';

    --      UPDATE jivtf01 SET inputdate = null WHERE inputdate  = '';
    --      UPDATE jivtf01 SET inputdate = STR_TO_DATE(inputdate,'%m/%d/%Y');

    truncate table pf_new.assets;

    INSERT INTO pf_new.assets (ID,
        --  asset_type_id,
                               serial_no,
                               work_order_id,
                               template_work_order_id,
                               site_id,
        --  pricing_template_id,
                               scheduling_settings,
                               bill_type,
                               start_date,
                               bill_through_date,
                               brand,
                               description,
                               parts_replaced,
        -- latitude,
        --  longitude,
        --   active_status,
                               one_time_fee,
                               created_at,
                               Rent_description,
                               Rent_rate_code_id,
                               Rent_schedule,
                               Rent_rate,
                               Service_Description,
                               service_rate_code_id,
                               service_schedule,
                               service_rate,
                               custom_1,
                               custom_1_rate_code_id,
                               custom_1_schedule,
                               custom_1_rate,
                               custom_2,
                               custom_2_rate_code_id,
                               custom_2_schedule,
                               custom_2_rate,
                               is_assigned,
                               prorate,
                               prorate_value,
                               delivery_date,
                               sales_rep_id)
    SELECT ROW_NUMBER()                                                                                                      OVER(ORDER BY j1.serial ASC) AS ID,
           -- COALESCE((SELECT id FROM pf_new.code_sets WHERE parent_id = 103 AND code = descrip LIMIT 1), NULL) AS asset_type_id,
           j1.serial AS serial_no,
           CAST(NULL AS SIGNED)                                                                                           AS work_order_id,
           COALESCE((SELECT id FROM pf_new.template_work_orders pft WHERE j1.custnum = pft.site_id LIMIT
                    1), NULL)                                                                                             AS template_work_order_id,
           COALESCE(pfs.id, NULL)                                                                                         AS site_id,
    --    COALESCE((SELECT id FROM pf_new.pricing_templates pr WHERE j1.CombinedPriceBookCode = pr.Serial LIMIT 1), NULL) AS pricing_template_id,

           CASE
               WHEN billperiod IN ('28A', '28A_A', 'MULTI SITE') OR RTRIM(billperiod) = 'MONTH ADV' THEN 'Advance'
               WHEN billperiod IN ('28ARREAR', 'MONTH') THEN 'Arrears'
               ELSE NULL
               END                                                                                                        AS scheduling_settings,

           CASE
               WHEN billperiod IN ('28A', 'MULTI SITE', '28 A A') OR RTRIM(billperiod) IN ('28ARREAR', 'ANNUAL')
                   THEN '28 Day Fixed'
               WHEN RTRIM(billperiod) = 'MONTH ADV' OR billperiod = 'MONTH' THEN 'Monthly'
               WHEN billperiod = 'SE' THEN 'On Demand'
               ELSE NULL
               END                                                                                                        AS bill_type,

           DATE_ADD(STR_TO_DATE(billthru, '%m/%d/%Y'), INTERVAL 1 DAY)                                                    AS start_date,
           STR_TO_DATE(billthru, '%m/%d/%Y')                                                                              AS bill_through_date,
           delordnum                                                                                                      AS brand,
           CONCAT(COALESCE((SELECT description FROM pf_new.code_sets WHERE parent_id = 106 AND code = PFrent_rate_code_id),
                           ''), ' Service = ',
                  j1.ivtserv)                                                                                             AS description,
           `condition`                                                                                                    AS parts_replaced,
           -- j1.latitude AS latitude,
           -- j1.longitude AS longitude,
           -- active AS active_status,
           cast(j1.delchrg as decimal(8, 2))                                                                              AS one_time_fee,
           STR_TO_DATE(j1.uentdate, '%m/%d/%Y')                                                                           AS created_at,

           COALESCE(
                   (SELECT description FROM pf_new.code_sets WHERE parent_id = 106 AND code = PFrent_rate_code_id),
                   (SELECT description FROM pf_new.code_sets WHERE parent_id = 106 AND code = PFcode7_rate_code_id),
                   (SELECT description FROM pf_new.code_sets WHERE parent_id = 106 AND code = PFcode8_rate_code_id),
                   (SELECT description FROM pf_new.code_sets WHERE parent_id = 106 AND code = PFcode9_rate_code_id),
                   (SELECT description FROM pf_new.code_sets WHERE parent_id = 106 AND code = PFcode10_rate_code_id),
                   (SELECT description FROM pf_new.code_sets WHERE parent_id = 106 AND code = PFother_rate_code_id),
                   (SELECT description FROM pf_new.code_sets WHERE parent_id = 106 AND code = PFdisposal_rate_code_id)
               )                                                                                                          AS Rent_description,

           COALESCE(
                       (SELECT id FROM pf_new.code_sets c WHERE c.code = PFrent_rate_code_id),
                       (SELECT id FROM pf_new.code_sets c WHERE c.code = PFcode7_rate_code_id),
                       (SELECT id FROM pf_new.code_sets c WHERE c.code = PFcode8_rate_code_id),
                       (SELECT id FROM pf_new.code_sets c WHERE c.code = PFcode9_rate_code_id),
                       (SELECT id FROM pf_new.code_sets c WHERE c.code = PFcode10_rate_code_id),
                       (SELECT id FROM pf_new.code_sets c WHERE c.code = PFother_rate_code_id),
                       (SELECT id FROM pf_new.code_sets c WHERE c.code = PFdisposal_rate_code_id)
               )                                                                                                          AS Rent_rate_code_id,

           COALESCE(PFrent_schedule, PFcode7_schedule, PFcode8_schedule, PFcode9_schedule, PFcode10_schedule,
                    PFother_schedule, PFdisposal_schedule,
                    PFcode8_schedule)                                                                                     AS Rent_schedule,
           cast(COALESCE(PFrent_rate, PFcode7_rate, PFcode8_rate, PFcode9_rate, PFcode10_rate, PFother_rate,
                         PFdisposal_rate) as decimal(10, 2))                                                              AS Rent_rate,

           COALESCE((SELECT description FROM pf_new.code_sets WHERE parent_id = 106 AND code = PFservice_rate_code_id),
                    '')                                                                                                   AS Service_Description,
           COALESCE((SELECT id FROM pf_new.code_sets c WHERE c.code = PFservice_rate_code_id),
                    NULL)                                                                                                 AS service_rate_code_id,
           COALESCE(PFservice_schedule, NULL)                                                                             AS service_schedule,
           cast(PFservice_rate as decimal(10, 2))                                                                         AS service_rate,

           COALESCE((SELECT description FROM pf_new.code_sets WHERE parent_id = 106 AND code = PFcode6_rate_code_id),
                    '')                                                                                                   AS custom_1,
           COALESCE((SELECT id FROM pf_new.code_sets c WHERE c.code = PFcode6_rate_code_id),
                    NULL)                                                                                                 AS custom_1_rate_code_id,
           COALESCE(PFcode6_schedule, NULL)                                                                               AS custom_1_schedule,
           cast(PFcode6_rate as decimal(10, 2))                                                                           AS custom_1_rate,

           COALESCE((SELECT description FROM pf_new.code_sets WHERE parent_id = 106 AND code = PFdamage_rate_code_id),
                    '')                                                                                                   AS custom_2,
           COALESCE((SELECT id FROM pf_new.code_sets c WHERE c.code = PFdamage_rate_code_id),
                    NULL)                                                                                                 AS custom_2_rate_code_id,
           COALESCE(pfdamage_schedule, NULL)                                                                              AS custom_2_schedule,
           cast(PFdamage_rate as decimal(10, 2))                                                                          AS custom_2_rate,

           CASE
               WHEN pfs.id IS NOT NULL THEN 1
               ELSE 0
               END                                                                                                        AS is_assigned,

           -- CASE
           --   WHEN pfs.cocode = 'S' THEN 0
           -- ELSE 0
           -- END AS prorate,

           0                                                                                                              as prorate,
           'Daily'                                                                                                        AS prorate_value,
           j1.inputdate                                                                          AS delivery_date,
           salesrep.id                                                                                                    AS sales_rep_id
    FROM jivtf01 j1
             LEFT OUTER JOIN pf_new.sites pfs ON j1.custnum = pfs.ID
             LEFT OUTER JOIN jcusf09 j9 ON j1.custnum = j9.custnum
             LEFT JOIN pf_new.code_sets salesrep ON salesrep.code = j9.salecredit AND salesrep.parent_id = 117;
