
DROP
TEMPORARY TABLE IF EXISTS pfpre;
    DROP
TEMPORARY TABLE IF EXISTS pftwoa;

    CREATE
TEMPORARY TABLE pftwoa AS
SELECT DISTINCT pf.id AS                                                                                      template_work_order_id,
                pf.site_id,
                pfa.asset_type_id,
                11111 AS                                                                                      service_type_id,
                IFNULL(
                            (SELECT id FROM pf_new.pricing_templates WHERE name = jv.serial LIMIT 1), 777) AS pricing_template_id,
                1 AS                                                                                          quantity,
                1 AS                                                                                          is_assigned,
                jv.inputdate AS                                                                               delivery_date,
                pfa.scheduling_settings AS                                                                    scheduling_settings,
                pfa.bill_type AS                                                                              bill_type,
                1 AS                                                                                          prorate,
                'Daily' AS                                                                                    prorate_value,
                jv.custnum,
                pfa.serial_no,
                'assigned' AS                                                                                 `Status`,

                -- Add rate info from pfassets
                COALESCE(
                        (SELECT description FROM pf_new.code_sets WHERE parent_id = 106 AND code = PFrent_rate_code_id),
                        (SELECT description
                         FROM pf_new.code_sets
                         WHERE parent_id = 106 AND code = PFcode7_rate_code_id),
                        (SELECT description
                         FROM pf_new.code_sets
                         WHERE parent_id = 106 AND code = PFcode8_rate_code_id),
                        (SELECT description
                         FROM pf_new.code_sets
                         WHERE parent_id = 106 AND code = PFcode9_rate_code_id),
                        (SELECT description
                         FROM pf_new.code_sets
                         WHERE parent_id = 106 AND code = PFcode10_rate_code_id),
                        (SELECT description
                         FROM pf_new.code_sets
                         WHERE parent_id = 106 AND code = PFother_rate_code_id),
                        (SELECT description
                         FROM pf_new.code_sets
                         WHERE parent_id = 106 AND code = PFdisposal_rate_code_id)
                    ) AS                                                                                      Rent_description,

                COALESCE(
                            (SELECT id FROM pf_new.code_sets c WHERE c.code = PFrent_rate_code_id),
                            (SELECT id FROM pf_new.code_sets c WHERE c.code = PFcode7_rate_code_id),
                            (SELECT id FROM pf_new.code_sets c WHERE c.code = PFcode8_rate_code_id),
                            (SELECT id FROM pf_new.code_sets c WHERE c.code = PFcode9_rate_code_id),
                            (SELECT id FROM pf_new.code_sets c WHERE c.code = PFcode10_rate_code_id),
                            (SELECT id FROM pf_new.code_sets c WHERE c.code = PFother_rate_code_id),
                            (SELECT id FROM pf_new.code_sets c WHERE c.code = PFdisposal_rate_code_id)
                    ) AS                                                                                      Rent_rate_code_id,

                COALESCE(
                        PFrent_schedule,
                        PFcode7_schedule,
                        PFcode8_schedule,
                        PFcode9_schedule,
                        PFcode10_schedule,
                        PFother_schedule,
                        PFdisposal_schedule,
                        PFcode8_schedule
                    ) AS                                                                                      Rent_schedule,

                COALESCE(
                        PFrent_rate,
                        PFcode7_rate,
                        PFcode8_rate,
                        PFcode9_rate,
                        PFcode10_rate,
                        PFother_rate,
                        PFdisposal_rate
                    ) AS                                                                                      Rent_rate,

                COALESCE(
                        (SELECT description
                         FROM pf_new.code_sets
                         WHERE parent_id = 106 AND code = PFservice_rate_code_id),
                        ''
                    ) AS                                                                                      Service_Description,

                COALESCE(
                        (SELECT id FROM pf_new.code_sets c WHERE c.code = PFservice_rate_code_id),
                        NULL
                    ) AS                                                                                      service_rate_code_id,

                COALESCE(PFservice_schedule, NULL) AS                                                         service_schedule,
                PFservice_rate AS                                                                             service_rate,

                COALESCE(
                        (SELECT description
                         FROM pf_new.code_sets
                         WHERE parent_id = 106 AND code = PFcode6_rate_code_id),
                        ''
                    ) AS                                                                                      custom_1,

                COALESCE(
                            (SELECT id FROM pf_new.code_sets c WHERE c.code = PFcode6_rate_code_id),
                            NULL
                    ) AS                                                                                      custom_1_rate_code_id,

                COALESCE(PFcode6_schedule, NULL) AS                                                           custom_1_schedule,
                PFcode6_rate AS                                                                               custom_1_rate,

                COALESCE(
                        (SELECT description
                         FROM pf_new.code_sets
                         WHERE parent_id = 106 AND code = PFdamage_rate_code_id),
                        ''
                    ) AS                                                                                      custom_2,

                COALESCE(
                        (SELECT id FROM pf_new.code_sets c WHERE c.code = PFdamage_rate_code_id),
                        NULL
                    ) AS                                                                                      custom_2_rate_code_id,

                COALESCE(PFdamage_schedule, NULL) AS                                                          custom_2_schedule,
                PFdamage_rate AS                                                                              custom_2_rate
FROM pf_new.template_work_orders pf
         INNER JOIN jivtf01 jv ON pf.custnum = jv.custnum
         LEFT OUTER JOIN pf_new.assets pfa ON pfa.serial_no = jv.serial
WHERE jv.custnum > 0;

CREATE
TEMPORARY TABLE pfpre AS
SELECT ROW_NUMBER() OVER (ORDER BY template_work_order_id ASC) AS id, pftwoa.*
FROM pftwoa;

UPDATE pfpre pft
    JOIN pf_new.code_sets cs
ON cs.id = pft.asset_type_id
    JOIN pf_new.pricing_templates pfp ON cs.code = pfp.name
    SET pft.pricing_template_id = pfp.id;

UPDATE pfpre pft
    JOIN pf_new.code_sets cs
ON cs.id = pft.asset_type_id
    JOIN pf_new.pricing_templates pfp ON cs.code = LEFT (pfp.serial, 2) AND CHAR_LENGTH (pfp.serial) = 2
    SET pft.pricing_template_id = pfp.id;

UPDATE pfpre pft
    JOIN pf_new.code_sets cs
ON cs.id = pft.asset_type_id
    JOIN pf_new.pricing_templates pfp ON cs.code = LEFT (pfp.name, 3) AND CHAR_LENGTH (pfp.name) = 3
    SET pft.pricing_template_id = pfp.id;


UPDATE pfpre pft
    JOIN pf_new.code_sets cs
ON cs.id = pft.asset_type_id
    JOIN pf_new.pricing_templates pfp ON cs.code = LEFT (pfp.name, 4) AND CHAR_LENGTH (pfp.name) = 4
    SET pft.pricing_template_id = pfp.id;


UPDATE pfpre pft
    JOIN pf_new.code_sets cs
ON cs.id = pft.asset_type_id
    JOIN pf_new.pricing_templates pfp ON cs.code = LEFT (pfp.name, 2)
    AND SUBSTRING(pfp.name, 3, 1) REGEXP '^[0-9]$'
    SET pft.pricing_template_id = pfp.id
WHERE pft.pricing_template_id = 777;

truncate table pf_new.template_work_order_assets;

INSERT INTO pf_new.template_work_order_assets (id,
                                               template_work_order_id,
                                               site_id,
                                               quantity,
                                               asset_type_id,
                                               service_type_id,
                                               pricing_template_id,
                                               is_assigned,
                                               delivery_date,
                                               bill_type,
                                               prorate,
                                               prorate_value,
                                               rent_description,
                                               scheduling_settings,
                                               `Status`,
                                               rent_rate_code_id,
                                               rent_schedule,
                                               rent_rate,
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
                                               custom_2_schedule)
SELECT MIN(id)                    AS id,
       template_work_order_id,
       site_id,
       SUM(quantity)              AS quantity,
       asset_type_id,
       service_type_id,
       MIN(pricing_template_id)   AS pricing_template_id,
       is_assigned,
       MIN(delivery_date)         AS delivery_date,
       MIN(bill_type)             AS bill_type,
       prorate,
       prorate_value,
       MIN(rent_description)      AS rent_description,
       MIN(scheduling_settings)   AS scheduling_settings,
       MIN(`Status`)              AS `Status`,
       MIN(rent_rate_code_id)     AS rent_rate_code_id,
       MIN(rent_schedule)         AS rent_schedule,
       MIN(rent_rate)             AS rent_rate,
       MIN(service_rate_code_id)  AS Service_Description,
       MIN(service_rate_code_id)  AS service_rate_code_id,
       MIN(service_schedule)      AS service_schedule, -- defaults to daily..need to check per client.
       MIN(service_rate)          AS service_rate,
       MIN(custom_1)              AS custom_1,
       MIN(custom_1_rate_code_id) AS custom_1_rate_code_id,
       MIN(custom_1_schedule)     AS custom_1_schedule,
       MIN(custom_1_rate)         AS custom_1_rate,
       MIN(custom_2)              AS custom_2,
       MIN(custom_2_rate_code_id) AS custom_2_rate_code_id,
       MIN(custom_2_schedule)     AS custom_2_schedule
FROM pfpre
GROUP BY template_work_order_id,
         site_id,
         asset_type_id,
         service_type_id,
         is_assigned,
         prorate,
         prorate_value;
