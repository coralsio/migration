drop temporary table if exists pft;

CREATE
TEMPORARY TABLE pft AS
SELECT DISTINCT NULL                                   AS customer_id,
                serial                                 AS `name`,
                serial                                 AS description,
                COALESCE(
                        (SELECT description FROM pf_new.code_sets WHERE parent_id = 106 AND code = PFrent_rate_code_id),
                        (SELECT description
                         FROM pf_new.code_sets
                         WHERE parent_id = 106
                           AND code = PFcode7_rate_code_id),
                        (SELECT description
                         FROM pf_new.code_sets
                         WHERE parent_id = 106
                           AND code = PFcode8_rate_code_id),
                        (SELECT description
                         FROM pf_new.code_sets
                         WHERE parent_id = 106
                           AND code = PFcode9_rate_code_id),
                        (SELECT description
                         FROM pf_new.code_sets
                         WHERE parent_id = 106
                           AND code = PFcode10_rate_code_id),
                        (SELECT description
                         FROM pf_new.code_sets
                         WHERE parent_id = 106
                           AND code = PFother_rate_code_id),
                        (SELECT description
                         FROM pf_new.code_sets
                         WHERE parent_id = 106
                           AND code = PFdisposal_rate_code_id)
                    )                                  AS Rent_description,
                COALESCE(
                            (SELECT id FROM pf_new.code_sets c WHERE c.code = PFrent_rate_code_id),
                            (SELECT id FROM pf_new.code_sets c WHERE c.code = PFcode7_rate_code_id),
                            (SELECT id FROM pf_new.code_sets c WHERE c.code = PFcode8_rate_code_id),
                            (SELECT id FROM pf_new.code_sets c WHERE c.code = PFcode9_rate_code_id),
                            (SELECT id FROM pf_new.code_sets c WHERE c.code = PFcode10_rate_code_id),
                            (SELECT id FROM pf_new.code_sets c WHERE c.code = PFother_rate_code_id),
                            (SELECT id FROM pf_new.code_sets c WHERE c.code = PFdisposal_rate_code_id)
                    )                                  AS Rent_rate_code_id,
                COALESCE(
                        PFrent_schedule,
                        PFcode7_schedule,
                        PFcode8_schedule,
                        PFcode9_schedule,
                        PFcode10_schedule,
                        PFother_schedule,
                        PFdisposal_schedule,
                        PFcode8_schedule
                    )                                  AS Rent_schedule,
                cast(COALESCE(
                        PFrent_rate,
                        PFcode7_rate,
                        PFcode8_rate,
                        PFcode9_rate,
                        PFcode10_rate,
                        PFother_rate,
                        PFdisposal_rate
                    ) as decimal(8, 2))
                                                       AS Rent_rate,
                COALESCE(
                        (SELECT description
                         FROM pf_new.code_sets
                         WHERE parent_id = 106
                           AND code = PFservice_rate_code_id),
                        ''
                    )                                  AS Service_Description,
                COALESCE(
                        (SELECT id FROM pf_new.code_sets c WHERE c.code = PFservice_rate_code_id),
                        NULL
                    )                                  AS service_rate_code_id,
                COALESCE(PFservice_schedule, NULL)     AS service_schedule, -- defaults to daily..need to check per client.
                cast(PFservice_rate as decimal(8, 2))  AS service_rate,
                COALESCE(
                        (SELECT description
                         FROM pf_new.code_sets
                         WHERE parent_id = 106
                           AND code = PFcode6_rate_code_id),
                        ''
                    )                                  AS custom_1,
                COALESCE(
                            (SELECT id FROM pf_new.code_sets c WHERE c.code = PFcode6_rate_code_id),
                            NULL
                    )                                  AS custom_1_rate_code_id,
                COALESCE(PFcode6_schedule, NULL)       AS custom_1_schedule,
                cast(PFcode6_rate as decimal(8, 2))    AS custom_1_rate,
                COALESCE(
                        (SELECT description
                         FROM pf_new.code_sets
                         WHERE parent_id = 106
                           AND code = PFdamage_rate_code_id),
                        ''
                    )                                  AS custom_2,
                COALESCE(
                        (SELECT id FROM pf_new.code_sets c WHERE c.code = PFdamage_rate_code_id),
                        NULL
                    )                                  AS custom_2_rate_code_id,
                COALESCE(pfdamage_schedule, NULL)      AS custom_2_schedule,
                cast(PFdamage_rate as decimal(8, 2))   AS custom_2_rate,
                COALESCE(
                        (SELECT description
                         FROM pf_new.code_sets
                         WHERE parent_id = 106
                           AND code = PFdisposal_rate_code_id),
                        ''
                    )                                  AS custom_3,
                COALESCE(
                        (SELECT id FROM pf_new.code_sets c WHERE c.code = PFdisposal_rate_code_id),
                        NULL
                    )                                  AS custom_3_rate_code_id,
                COALESCE(PFdisposal_schedule, NULL)    AS custom_3_schedule,
                cast(PFdisposal_rate as decimal(8, 2)) AS custom_3_rate,
                COALESCE(
                        (SELECT description
                         FROM pf_new.code_sets
                         WHERE parent_id = 106
                           AND code = PFcode7_rate_code_id),
                        ''
                    )                                  AS custom_4,
                COALESCE(
                            (SELECT id FROM pf_new.code_sets c WHERE c.code = PFcode7_rate_code_id),
                            NULL
                    )                                  AS custom_4_rate_code_id,
                COALESCE(PFcode7_schedule, NULL)       AS custom_4_schedule,
                cast(PFcode7_rate as decimal(8, 2))    AS custom_4_rate,
                cast(jv.delchrg as decimal(8, 2))      AS one_time_fee,
                0                                      AS prorate,

                'Daily'                                AS prorate_value,
                jv.custnum,
                jv.Serial
FROM jivtf01 jv;



SET
@row_num = 0;

truncate table pf_new.pricing_templates;

INSERT INTO pf_new.pricing_templates (id, customer_id, name, description, Rent_description, Rent_rate_code_id,
                                      Rent_schedule,
                                      Rent_rate, Service_Description, service_rate_code_id, service_schedule,
                                      service_rate,
                                      custom_1, custom_1_rate_code_id, custom_1_schedule, custom_1_rate, custom_2,
                                      custom_2_rate_code_id,
                                      custom_2_schedule, custom_2_rate, custom_3, custom_3_rate_code_id,
                                      custom_3_schedule, custom_3_rate,
                                      custom_4,
                                      custom_4_rate_code_id, custom_4_schedule, custom_4_rate, one_time_fee, prorate,
                                      prorate_value, custnum, serial)
SELECT @row_num := @row_num + 1 AS id,
    customer_id,
    serial AS name,
    serial AS description,
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
    custom_3,
    custom_3_rate_code_id,
    custom_3_schedule,
    custom_3_rate,
    custom_4,
    custom_4_rate_code_id,
    custom_4_schedule,
    custom_4_rate,
    one_time_fee,
    prorate,
    prorate_value,
    custnum,
    serial
FROM pft jv
WHERE description IS NOT NULL
ORDER BY customer_id;
