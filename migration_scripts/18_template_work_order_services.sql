-- Declare variables in MySQL
SET
@firstSunday := CASE
                        WHEN DAYOFWEEK(DATE(CONCAT(YEAR(CURDATE()), '-', MONTH(CURDATE()), '-01'))) = 1
                            THEN DATE(CONCAT(YEAR(CURDATE()), '-', MONTH(CURDATE()), '-01'))
                        WHEN DAYOFWEEK(DATE(CONCAT(YEAR(CURDATE()), '-', MONTH(CURDATE()), '-02'))) = 1
                            THEN DATE(CONCAT(YEAR(CURDATE()), '-', MONTH(CURDATE()), '-02'))
                        WHEN DAYOFWEEK(DATE(CONCAT(YEAR(CURDATE()), '-', MONTH(CURDATE()), '-03'))) = 1
                            THEN DATE(CONCAT(YEAR(CURDATE()), '-', MONTH(CURDATE()), '-03'))
                        WHEN DAYOFWEEK(DATE(CONCAT(YEAR(CURDATE()), '-', MONTH(CURDATE()), '-04'))) = 1
                            THEN DATE(CONCAT(YEAR(CURDATE()), '-', MONTH(CURDATE()), '-04'))
                        WHEN DAYOFWEEK(DATE(CONCAT(YEAR(CURDATE()), '-', MONTH(CURDATE()), '-05'))) = 1
                            THEN DATE(CONCAT(YEAR(CURDATE()), '-', MONTH(CURDATE()), '-05'))
                        WHEN DAYOFWEEK(DATE(CONCAT(YEAR(CURDATE()), '-', MONTH(CURDATE()), '-06'))) = 1
                            THEN DATE(CONCAT(YEAR(CURDATE()), '-', MONTH(CURDATE()), '-06'))
                        WHEN DAYOFWEEK(DATE(CONCAT(YEAR(CURDATE()), '-', MONTH(CURDATE()), '-07'))) = 1
                            THEN DATE(CONCAT(YEAR(CURDATE()), '-', MONTH(CURDATE()), '-07'))
END;

-- Variables to hold offsets for each day of the week
SET
@sunday := NULL;
SET
@monday := NULL;
SET
@tuesday := NULL;
SET
@wednesday := NULL;
SET
@thursday := NULL;
SET
@friday := NULL;
SET
@saturday := NULL;

-- Temporary table for DateOffset
CREATE
TEMPORARY TABLE DateOffset AS
SELECT DAYNAME(DATE_ADD(CURDATE(), INTERVAL o.offset DAY))             AS DayOfWeek,
       DATEDIFF(DATE_ADD(CURDATE(), INTERVAL o.offset DAY), CURDATE()) AS Offset
FROM (SELECT 0 AS offset
      UNION ALL
      SELECT 1
      UNION ALL
      SELECT 2
      UNION ALL
      SELECT 3
      UNION ALL
      SELECT 4
      UNION ALL
      SELECT 5
      UNION ALL
      SELECT 6) o;

-- Set the day offsets based on the temporary table
SELECT Offset
INTO @sunday
FROM DateOffset
WHERE DayOfWeek = 'Sunday';
SELECT Offset
INTO @monday
FROM DateOffset
WHERE DayOfWeek = 'Monday';
SELECT Offset
INTO @tuesday
FROM DateOffset
WHERE DayOfWeek = 'Tuesday';
SELECT Offset
INTO @wednesday
FROM DateOffset
WHERE DayOfWeek = 'Wednesday';
SELECT Offset
INTO @thursday
FROM DateOffset
WHERE DayOfWeek = 'Thursday';
SELECT Offset
INTO @friday
FROM DateOffset
WHERE DayOfWeek = 'Friday';
SELECT Offset
INTO @saturday
FROM DateOffset
WHERE DayOfWeek = 'Saturday';

-- Drop the temporary table
DROP
TEMPORARY TABLE DateOffset;

truncate table pf_new.template_work_order_services;

INSERT INTO pf_new.template_work_order_services (id,
                                                 template_work_order_id,
                                                 service_type_id,
                                                 rate_code_id,
                                                 description,
                                                 quantity,
                                                 rate_code_code,
                                                 rate_code_value,
                                                 rate_code_rate_1,
                                                 rate_code_description,
                                                 rate_code_create_reminder,
                                                 is_recurring,
                                                 scheduling_frequency,
                                                 scheduling_interval,
                                                 scheduling_options,
                                                 scheduling_start_date,
                                                 scheduling_end_date,
                                                 next_service_date,
                                                 route_id,
                                                 stop_number,
                                                 route_note,
                                                 sunday_route_note,
                                                 sunday_stop_number,
                                                 sunday_route_id,
                                                 monday_route_note,
                                                 monday_stop_number,
                                                 monday_route_id,
                                                 tuesday_route_note,
                                                 tuesday_stop_number,
                                                 tuesday_route_id,
                                                 wednesday_route_note,
                                                 wednesday_stop_number,
                                                 wednesday_route_id,
                                                 thursday_route_note,
                                                 thursday_stop_number,
                                                 thursday_route_id,
                                                 friday_route_note,
                                                 friday_stop_number,
                                                 friday_route_id,
                                                 saturday_route_note,
                                                 saturday_stop_number,
                                                 saturday_route_id,
                                                 created_at)
SELECT @rownum := @rownum + 1 AS id,
    pft.id AS template_work_order_id,
    COALESCE((SELECT id FROM pf_new.code_sets WHERE description = 'SERVICE TICKET' AND parent_id = 111), NULL) AS service_type_id,
   COALESCE((SELECT id FROM pf_new.code_sets WHERE code = 'S' AND parent_id = 106), 157) AS rate_code_id,
    'Service' AS description,
    CAST(jt.rtquan AS DECIMAL(19,2)) AS quantity,
    'Service' AS rate_code_code,
    'Service' AS rate_code_value,
    CAST(0.00 AS DECIMAL(8,2)) AS rate_code_rate_1,
    'Service' AS rate_code_description,
    0 AS rate_code_create_reminder,
    1 AS is_recurring,
    CASE
        WHEN rtsrvcode = '2W' THEN 1
        WHEN rtsrvcode = '1W' THEN 1
        WHEN rtsrvcode = '3W' THEN 1
        WHEN rtsrvcode = '1M' THEN 1
        ELSE 1
END
AS scheduling_frequency,
    CASE
        WHEN rtsrvcode = '2W' THEN 'Weekly'
        WHEN rtsrvcode = '1W' THEN 'Weekly'
        WHEN rtsrvcode = '3W' THEN 'Weekly'
        WHEN rtsrvcode = '1M' THEN 'Monthly'
        ELSE 'Weekly'
END
AS scheduling_interval,
    CASE
        WHEN routeday = 'M' THEN '{"days":["Monday"]}'
        WHEN routeday = 'T' THEN '{"days":["Tuesday"]}'
        WHEN routeday = 'W' THEN '{"days":["Wednesday"]}'
        WHEN routeday = 'H' THEN '{"days":["Thursday"]}'
        WHEN routeday = 'F' THEN '{"days":["Friday"]}'
        WHEN routeday = 'S' THEN '{"days":["Saturday"]}'
        WHEN routeday = 'U' THEN '{"days":["Sunday"]}'
END
AS scheduling_options,
    CASE
        WHEN rtsrvcode = '1M' THEN '1921-01-01'
        WHEN rtsrvcode = '0' THEN @FirstSunday
        ELSE DATE_SUB(DATE_SUB(NOW(), INTERVAL 4 HOUR), INTERVAL 7 DAY) +
             CASE
                 WHEN routeday = 'M' THEN @monday
                 WHEN routeday = 'T' THEN @tuesday
                 WHEN routeday = 'W' THEN @wednesday
                 WHEN routeday = 'H' THEN @thursday
                 WHEN routeday = 'F' THEN @friday
                 WHEN routeday = 'S' THEN @saturday
                 WHEN routeday = 'U' THEN @sunday
END
END
AS scheduling_start_date,
    NULL AS scheduling_end_date,
    NOW() +
    CASE
        WHEN routeday = 'M' THEN @monday
        WHEN routeday = 'T' THEN @tuesday
        WHEN routeday = 'W' THEN @wednesday
        WHEN routeday = 'H' THEN @thursday
        WHEN routeday = 'F' THEN @friday
        WHEN routeday = 'S' THEN @saturday
        WHEN routeday = 'U' THEN @sunday
END
AS next_service_date,
    COALESCE((SELECT id FROM pf_new.routes p WHERE p.route_number = jt.routenum AND
            (CASE
                 WHEN p.route_day = 'Mo' THEN 'M'
                 WHEN p.route_day = 'Tu' THEN 'T'
                 WHEN p.route_day = 'We' THEN 'W'
                 WHEN p.route_day = 'Th' THEN 'H'
                 WHEN p.route_day = 'Fr' THEN 'F'
                 WHEN p.route_day = 'Sa' THEN 'S'
                 WHEN p.route_day = 'Su' THEN 'U'
                END) = jt.routeday), NULL) AS route_id,
    CASE
        WHEN CAST(jt.stopnum AS SIGNED) = 0 THEN NULL
        ELSE CAST(jt.stopnum AS SIGNED)
END
AS stop_number,
    '' AS route_note,
    CASE
        WHEN routeday = 'U' THEN CAST(jt.rtmemo AS CHAR(8000))
        ELSE ''
END
AS sunday_route_note,
    CASE
        WHEN routeday = 'U' THEN CAST(jt.stopnum AS DECIMAL(10,0))
        ELSE NULL
END
AS sunday_stop_number,
    CASE
        WHEN routeday = 'U' THEN COALESCE((SELECT id FROM pf_new.routes p WHERE p.code = jt.routecode), NULL)
END
AS sunday_route_id,
    CASE
        WHEN routeday = 'M' THEN CAST(jt.rtmemo AS CHAR(8000))
        ELSE ''
END
AS monday_route_note,
    CASE
        WHEN routeday = 'M' THEN CAST(jt.stopnum AS DECIMAL(10,0))
        ELSE NULL
END
AS monday_stop_number,
    CASE
        WHEN routeday = 'M' THEN COALESCE((SELECT id FROM pf_new.routes p WHERE p.code = jt.routecode), NULL)
END
AS monday_route_id,
    CASE
        WHEN routeday = 'T' THEN CAST(jt.rtmemo AS CHAR(8000))
        ELSE ''
END
AS tuesday_route_note,
    CASE
        WHEN routeday = 'T' THEN CAST(jt.stopnum AS DECIMAL(10,0))
        ELSE NULL
END
AS tuesday_stop_number,
    CASE
        WHEN routeday = 'T' THEN COALESCE((SELECT id FROM pf_new.routes p WHERE p.code = jt.routecode), NULL)
END
AS tuesday_route_id,
    CASE
        WHEN routeday = 'W' THEN CAST(jt.rtmemo AS CHAR(8000))
        ELSE ''
END
AS wednesday_route_note,
    CASE
        WHEN routeday = 'W' THEN CAST(jt.stopnum AS DECIMAL(10,0))
        ELSE NULL
END
AS wednesday_stop_number,
    CASE
        WHEN routeday = 'W' THEN COALESCE((SELECT id FROM pf_new.routes p WHERE p.code = jt.routecode), NULL)
END
AS wednesday_route_id,
    CASE
        WHEN routeday = 'H' THEN CAST(jt.rtmemo AS CHAR(8000))
        ELSE ''
END
AS thursday_route_note,
    CASE
        WHEN routeday = 'H' THEN CAST(jt.stopnum AS DECIMAL(10,0))
        ELSE NULL
END
AS thursday_stop_number,
    CASE
        WHEN routeday = 'H' THEN COALESCE((SELECT id FROM pf_new.routes p WHERE p.code = jt.routecode), NULL)
END
AS thursday_route_id,
    CASE
        WHEN routeday = 'F' THEN CAST(jt.rtmemo AS CHAR(8000))
        ELSE ''
END
AS friday_route_note,
    CASE
        WHEN routeday = 'F' THEN CAST(jt.stopnum AS DECIMAL(10,0))
        ELSE NULL
END
AS friday_stop_number,
    CASE
        WHEN routeday = 'F' THEN COALESCE((SELECT id FROM pf_new.routes p WHERE p.code = jt.routecode), NULL)
END
AS friday_route_id,
    CASE
        WHEN routeday = 'S' THEN CAST(jt.rtmemo AS CHAR(8000))
        ELSE ''
END
AS saturday_route_note,
    CASE
        WHEN routeday = 'S' THEN CAST(jt.stopnum AS DECIMAL(10,0))
        ELSE NULL
END
AS saturday_stop_number,
    CASE
        WHEN routeday = 'S' THEN COALESCE((SELECT id FROM pf_new.routes p WHERE p.code = jt.routecode), NULL)
END
AS saturday_route_id,
    '1990-01-01' AS created_at
from jrtf01 jt left outer join pf_new.sites pf on jt.custnum = pf.id
                join pf_new.template_work_orders pft on jt.custnum = pft.site_id
where rtsrvcode <> 'OC';

--  UPDATE jrtf05 SET rtentdate =null WHERE rtentdate  = '';
--  UPDATE jrtf05 SET rtentdate = STR_TO_DATE(rtentdate ,'%m/%d/%Y');

--  UPDATE jrtf05 SET rtsrvdate =null WHERE rtsrvdate  = '';
--  UPDATE jrtf05 SET rtsrvdate = STR_TO_DATE(rtsrvdate ,'%m/%d/%Y');

--  UPDATE jrtf05 SET rtnxtdate =null WHERE rtnxtdate  = '';
--  UPDATE jrtf05 SET rtnxtdate = STR_TO_DATE(rtnxtdate ,'%m/%d/%Y');

INSERT INTO pf_new.template_work_order_services (id,
                                                 template_work_order_id,
                                                 service_type_id,
                                                 rate_code_id,
                                                 description,
                                                 quantity,
                                                 rate_code_code,
                                                 rate_code_value,
                                                 rate_code_rate_1,
                                                 rate_code_description,
                                                 rate_code_create_reminder,
                                                 is_recurring,
                                                 scheduling_frequency,
                                                 scheduling_interval,
                                                 scheduling_options,
                                                 scheduling_start_date,
                                                 scheduling_end_date,
                                                 next_service_date,
                                                 Route_Id,
                                                 stop_number,
                                                 route_note,
                                                 sunday_route_note,
                                                 sunday_stop_number,
                                                 sunday_route_id,
                                                 monday_route_note,
                                                 monday_stop_number,
                                                 monday_route_id,
                                                 tuesday_route_note,
                                                 tuesday_stop_number,
                                                 tuesday_route_id,
                                                 wednesday_route_note,
                                                 wednesday_stop_number,
                                                 wednesday_route_id,
                                                 thursday_route_note,
                                                 thursday_stop_number,
                                                 thursday_route_id,
                                                 friday_route_note,
                                                 friday_stop_number,
                                                 friday_route_id,
                                                 saturday_route_note,
                                                 saturday_stop_number,
                                                 saturday_route_id,
                                                 created_at)
SELECT (SELECT MAX(id) FROM pf_new.template_work_order_services) +
       ROW_NUMBER()                                                                                       OVER(ORDER BY jr.custnum ASC) AS id, pft.id AS template_work_order_id,
       COALESCE((SELECT id FROM pf_new.code_sets WHERE code = jr.rttypetkt AND parent_id = 111),
                NULL)                                                                                  AS service_type_id,
       COALESCE((SELECT id FROM pf_new.code_sets WHERE code = jr.rtratecode AND parent_id = 106), 157) AS rate_code_id,
       COALESCE((SELECT description FROM pf_new.code_sets WHERE code = jr.rtratecode AND parent_id = 106),
                jr.rtratecode)                                                                         AS description,
       COALESCE(jr.rtqty, 0)                                                                           AS quantity,
       jr.rtratecode                                                                                   AS rate_code_code,
       jr.rtratecode                                                                                   AS rate_code_value,
       COALESCE((SELECT refrate FROM jref015 WHERE refcode = jr.rtratecode),
                0)                                                                                     AS rate_code_rate_1,
       CAST(jr.rtmemo AS CHAR(250))                                                                    AS rate_code_description,
       0                                                                                               AS rate_code_create_reminder,
       1                                                                                               AS is_recurring,
       CASE
           WHEN rtinttype = 'D' THEN
               CASE
                   WHEN rtintwk % 30 = 0 THEN rtintwk / 30
                   WHEN rtintwk % 7 = 0 THEN rtintwk / 7
                   ELSE ROUND(rtintwk / 7, 0)
                   END
           ELSE rtintwk
           END                                                                                         AS scheduling_frequency,
       CASE
           WHEN rtinttype = 'D' OR rtinttype = 'Daily' THEN
               CASE
                   WHEN rtintwk % 30 = 0 THEN 'Monthly'
                   WHEN rtintwk % 7 = 0 THEN 'Weekly'
                   ELSE 'Weekly'
                   END
           WHEN rtinttype = 'W' THEN 'Weekly'
           WHEN rtinttype = 'M' THEN 'Monthly'
           WHEN rtinttype = 'Y' THEN 'Yearly'
           ELSE rtinttype
           END                                                                                         AS scheduling_interval,
       CONCAT('{"days":["', DAYNAME(rtnxtdate), '"]}')                                                 AS scheduling_options,
       rtsrvdate                                                                                       AS scheduling_start_date,
       NULL                                                                                            AS scheduling_end_date,
       jr.rtnxtdate                                                                                    AS next_service_date,
       COALESCE((SELECT id FROM pf_new.routes WHERE code = jr.rtnum), NULL)                            AS Route_Id,
       CASE
           WHEN CAST(jr.rtstop AS UNSIGNED) = 0 THEN NULL
           ELSE CAST(jr.rtstop AS UNSIGNED)
           END                                                                                         AS stop_number,
       TRIM(CONCAT(CAST(rttime AS CHAR(20)), CAST(jr.rtdesc AS CHAR(6000))))                           AS route_note,
       CASE
           WHEN (rtday = 'U' OR WEEKDAY(rtnxtdate) = 0)
               THEN CONCAT(CAST(rttime AS CHAR(20)), CAST(jr.rtdesc AS CHAR(6000)))
           ELSE ''
           END                                                                                         AS sunday_route_note,
       CASE
           WHEN (rtday = 'U' OR WEEKDAY(rtnxtdate) = 0) THEN jr.rtstop
           ELSE NULL
           END                                                                                         AS sunday_stop_number,
       CASE
           WHEN (rtday = 'U' OR WEEKDAY(rtnxtdate) = 0) THEN COALESCE(
                       (SELECT id FROM pf_new.routes p WHERE p.code = jr.rtnum), NULL)
           END                                                                                         AS sunday_route_id,
       CASE
           WHEN (rtday = 'M' OR WEEKDAY(rtnxtdate) = 1)
               THEN CONCAT(CAST(rttime AS CHAR(20)), CAST(jr.rtdesc AS CHAR(6000)))
           ELSE ''
           END                                                                                         AS monday_route_note,
       CASE
           WHEN (rtday = 'M' OR WEEKDAY(rtnxtdate) = 1) THEN jr.rtstop
           ELSE NULL
           END                                                                                         AS monday_stop_number,
       CASE
           WHEN (rtday = 'M' OR WEEKDAY(rtnxtdate) = 1) THEN COALESCE(
                       (SELECT id FROM pf_new.routes p WHERE p.code = jr.rtnum), NULL)
           END                                                                                         AS monday_route_id,
       CASE
           WHEN (rtday = 'T' OR WEEKDAY(rtnxtdate) = 2)
               THEN CONCAT(CAST(rttime AS CHAR(20)), CAST(jr.rtdesc AS CHAR(6000)))
           ELSE ''
           END                                                                                         AS tuesday_route_note,
       CASE
           WHEN (rtday = 'T' OR WEEKDAY(rtnxtdate) = 2) THEN jr.rtstop
           ELSE NULL
           END                                                                                         AS tuesday_stop_number,
       CASE
           WHEN (rtday = 'T' OR WEEKDAY(rtnxtdate) = 2) THEN COALESCE(
                       (SELECT id FROM pf_new.routes p WHERE p.code = jr.rtnum), NULL)
           END                                                                                         AS tuesday_route_id,
       CASE
           WHEN (rtday = 'W' OR WEEKDAY(rtnxtdate) = 3)
               THEN CONCAT(CAST(rttime AS CHAR(20)), CAST(jr.rtdesc AS CHAR(6000)))
           ELSE ''
           END                                                                                         AS wednesday_route_note,
       CASE
           WHEN (rtday = 'W' OR WEEKDAY(rtnxtdate) = 3) THEN jr.rtstop
           ELSE NULL
           END                                                                                         AS wednesday_stop_number,
       CASE
           WHEN (rtday = 'W' OR WEEKDAY(rtnxtdate) = 3) THEN COALESCE(
                       (SELECT id FROM pf_new.routes p WHERE p.code = jr.rtnum), NULL)
           END                                                                                         AS wednesday_route_id,
       CASE
           WHEN (rtday = 'H' OR WEEKDAY(rtnxtdate) = 4)
               THEN CONCAT(CAST(rttime AS CHAR(20)), CAST(jr.rtdesc AS CHAR(6000)))
           ELSE ''
           END                                                                                         AS thursday_route_note,
       CASE
           WHEN (rtday = 'H' OR WEEKDAY(rtnxtdate) = 4) THEN jr.rtstop
           ELSE NULL
           END                                                                                         AS thursday_stop_number,
       CASE
           WHEN (rtday = 'H' OR WEEKDAY(rtnxtdate) = 4) THEN COALESCE(
                       (SELECT id FROM pf_new.routes p WHERE p.code = jr.rtnum), NULL)
           END                                                                                         AS thursday_route_id,
       CASE
           WHEN (rtday = 'F' OR WEEKDAY(rtnxtdate) = 5)
               THEN CONCAT(CAST(rttime AS CHAR(20)), CAST(jr.rtdesc AS CHAR(6000)))
           ELSE ''
           END                                                                                         AS friday_route_note,
       CASE
           WHEN (rtday = 'F' OR WEEKDAY(rtnxtdate) = 5) THEN jr.rtstop
           ELSE NULL
           END                                                                                         AS friday_stop_number,
       CASE
           WHEN (rtday = 'F' OR WEEKDAY(rtnxtdate) = 5) THEN COALESCE(
                       (SELECT id FROM pf_new.routes p WHERE p.code = jr.rtnum), NULL)
           END                                                                                         AS friday_route_id,
       CASE
           WHEN (rtday = 'S' OR WEEKDAY(rtnxtdate) = 6)
               THEN CONCAT(CAST(rttime AS CHAR(20)), CAST(jr.rtdesc AS CHAR(6000)))
           ELSE ''
           END                                                                                         AS saturday_route_note,
       CASE
           WHEN (rtday = 'S' OR WEEKDAY(rtnxtdate) = 6) THEN jr.rtstop
           ELSE NULL
           END                                                                                         AS saturday_stop_number,
       CASE
           WHEN (rtday = 'S' OR WEEKDAY(rtnxtdate) = 6) THEN COALESCE(
                       (SELECT id FROM pf_new.routes p WHERE p.code = jr.rtnum), NULL)
           END                                                                                         AS saturday_route_id,
       jr.rtentdate                                                                                    AS created_at
FROM jrtf05 jr
         LEFT OUTER JOIN pf_new.sites pf ON jr.custnum = pf.id
         JOIN pf_new.template_work_orders pft ON jr.custnum = pft.site_id;



#
UPDATE pf_new.template_work_order_services
    #
SET next_service_date = DATE_ADD(next_service_date, INTERVAL 1 WEEK) #
WHERE rtsrvcode = 'EVEN';
#
rtsrvcode missing
DROP
TEMPORARY TABLE IF EXISTS tempA;

CREATE
TEMPORARY TABLE tempA AS
SELECT ROW_NUMBER() OVER (PARTITION BY pf_new.template_work_orders.site_id ORDER BY scheduling_options ASC) AS grpid, pf_new.template_work_orders.site_id,
       pf_new.template_work_order_services.id,
       pf_new.template_work_order_services.template_work_order_id,
       pf_new.template_work_order_services.service_type_id,
       pf_new.template_work_order_services.rate_code_id,
       pf_new.template_work_order_services.description,
       pf_new.template_work_order_services.quantity,
       pf_new.template_work_order_services.rate_code_code,
       pf_new.template_work_order_services.rate_code_value,
       pf_new.template_work_order_services.rate_code_rate_1,
       pf_new.template_work_order_services.rate_code_description,
       pf_new.template_work_order_services.rate_code_create_reminder,
       pf_new.template_work_order_services.is_recurring,
       pf_new.template_work_order_services.scheduling_frequency,
       pf_new.template_work_order_services.scheduling_interval,
       pf_new.template_work_order_services.scheduling_options,
       pf_new.template_work_order_services.scheduling_start_date,
       pf_new.template_work_order_services.scheduling_end_date,
       pf_new.template_work_order_services.next_service_date,
       pf_new.template_work_order_services.route_id,
       pf_new.template_work_order_services.stop_number,
       pf_new.template_work_order_services.route_note,
       pf_new.template_work_order_services.sunday_route_note,
       pf_new.template_work_order_services.sunday_stop_number,
       pf_new.template_work_order_services.sunday_route_id,
       pf_new.template_work_order_services.monday_route_note,
       pf_new.template_work_order_services.monday_stop_number,
       pf_new.template_work_order_services.monday_route_id,
       pf_new.template_work_order_services.tuesday_route_note,
       pf_new.template_work_order_services.tuesday_stop_number,
       pf_new.template_work_order_services.tuesday_route_id,
       pf_new.template_work_order_services.wednesday_route_note,
       pf_new.template_work_order_services.wednesday_stop_number,
       pf_new.template_work_order_services.wednesday_route_id,
       pf_new.template_work_order_services.thursday_route_note,
       pf_new.template_work_order_services.thursday_stop_number,
       pf_new.template_work_order_services.thursday_route_id,
       pf_new.template_work_order_services.friday_route_note,
       pf_new.template_work_order_services.friday_stop_number,
       pf_new.template_work_order_services.friday_route_id,
       pf_new.template_work_order_services.saturday_route_note,
       pf_new.template_work_order_services.saturday_stop_number,
       pf_new.template_work_order_services.saturday_route_id,
       pf_new.template_work_order_services.created_at
FROM pf_new.template_work_order_services
         LEFT JOIN
     pf_new.template_work_orders
     ON pf_new.template_work_orders.id = pf_new.template_work_order_services.template_work_order_id;

-- Drop temporary table if it exists
DROP
TEMPORARY TABLE IF EXISTS iter;
-- Step 4: Drop the temporary tables after use
DROP
TEMPORARY TABLE IF EXISTS tempA_a;
DROP
TEMPORARY TABLE IF EXISTS tempA_b;
DROP
TEMPORARY TABLE IF EXISTS temp_data;

-- Create temporary table
CREATE
TEMPORARY TABLE iter (a INT);

-- Insert values into the temporary table
INSERT INTO iter
VALUES (0);
INSERT INTO iter
VALUES (1);
INSERT INTO iter
VALUES (2);
INSERT INTO iter
VALUES (3);
INSERT INTO iter
VALUES (4);
INSERT INTO iter
VALUES (5);
INSERT INTO iter
VALUES (6);
INSERT INTO iter
VALUES (7);

SET
foreign_key_checks=0;
-- Drop the permanent table if it exists
truncate table pf_new.template_work_order_services;

SET
foreign_key_checks=1;


-- Step 1: Create temporary tables for both instances of tempA
CREATE
TEMPORARY TABLE tempA_a AS
SELECT *
FROM tempA;
CREATE
TEMPORARY TABLE tempA_b AS
SELECT *
FROM tempA;

-- Step 2: Create a temporary table to hold the aggregated data
CREATE
TEMPORARY TABLE temp_data AS
SELECT a.site_id,
       MIN(a.id)                                                                                                     AS id,
       MIN(a.template_work_order_id)                                                                                 AS template_work_order_id,
       MIN(a.service_type_id)                                                                                        AS service_type_id,
       MIN(a.rate_code_id)                                                                                           AS rate_code_id,
       MIN(a.description)                                                                                            AS description,
       MIN(a.quantity)                                                                                               AS quantity,
       MIN(a.rate_code_code)                                                                                         AS rate_code_code,
       MIN(a.rate_code_value)                                                                                        AS rate_code_value,
       MIN(a.rate_code_rate_1)                                                                                       AS rate_code_rate_1,
       MIN(a.rate_code_description)                                                                                  AS rate_code_description,
       MIN(a.rate_code_create_reminder)                                                                              AS rate_code_create_reminder,
       MIN(a.is_recurring)                                                                                           AS is_recurring,
       MIN(a.scheduling_frequency)                                                                                   AS scheduling_frequency,
       MIN(a.scheduling_interval)                                                                                    AS scheduling_interval,
       MIN(a.scheduling_start_date)                                                                                  AS scheduling_start_date,
       MIN(a.scheduling_end_date)                                                                                    AS scheduling_end_date,
       MIN(a.next_service_date)                                                                                      AS next_service_date,
       MIN(a.route_id)                                                                                               AS route_id,
       MIN(a.stop_number)                                                                                            AS stop_number,
       MIN(a.route_note)                                                                                             AS route_note,
       MAX(CASE
               WHEN a.scheduling_options LIKE '%Monday%' OR b.scheduling_options LIKE '%Monday%'
                   THEN a.monday_stop_number
               ELSE 0 END)                                                                                           AS monday_stop_number,
       MAX(CASE
               WHEN a.scheduling_options LIKE '%Tuesday%' OR b.scheduling_options LIKE '%Tuesday%'
                   THEN a.tuesday_stop_number
               ELSE 0 END)                                                                                           AS tuesday_stop_number,
       MAX(CASE
               WHEN a.scheduling_options LIKE '%Wednesday%' OR b.scheduling_options LIKE '%Wednesday%'
                   THEN a.wednesday_stop_number
               ELSE 0 END)                                                                                           AS wednesday_stop_number,
       MAX(CASE
               WHEN a.scheduling_options LIKE '%Thursday%' OR b.scheduling_options LIKE '%Thursday%'
                   THEN a.thursday_stop_number
               ELSE 0 END)                                                                                           AS thursday_stop_number,
       MAX(CASE
               WHEN a.scheduling_options LIKE '%Friday%' OR b.scheduling_options LIKE '%Friday%'
                   THEN a.friday_stop_number
               ELSE 0 END)                                                                                           AS friday_stop_number,
       MAX(CASE
               WHEN a.scheduling_options LIKE '%Saturday%' OR b.scheduling_options LIKE '%Saturday%'
                   THEN a.saturday_stop_number
               ELSE 0 END)                                                                                           AS saturday_stop_number,
       MAX(CASE
               WHEN a.scheduling_options LIKE '%Sunday%' OR b.scheduling_options LIKE '%Sunday%'
                   THEN a.sunday_stop_number
               ELSE 0 END)                                                                                           AS sunday_stop_number,
       MIN(a.created_at)                                                                                             AS created_at,
       MAX(CASE
               WHEN a.scheduling_options LIKE '%Monday%' OR b.scheduling_options LIKE '%Monday%' THEN 1
               ELSE 0 END)                                                                                           AS Monday_stop_numb,
       MAX(CASE
               WHEN a.scheduling_options LIKE '%Tuesday%' OR b.scheduling_options LIKE '%Tuesday%' THEN 1
               ELSE 0 END)                                                                                           AS Tuesday_stop_numb,
       MAX(CASE
               WHEN a.scheduling_options LIKE '%Wednesday%' OR b.scheduling_options LIKE '%Wednesday%' THEN 1
               ELSE 0 END)                                                                                           AS Wednesday_stop_numb,
       MAX(CASE
               WHEN a.scheduling_options LIKE '%Thursday%' OR b.scheduling_options LIKE '%Thursday%' THEN 1
               ELSE 0 END)                                                                                           AS Thursday_stop_numb,
       MAX(CASE
               WHEN a.scheduling_options LIKE '%Friday%' OR b.scheduling_options LIKE '%Friday%' THEN 1
               ELSE 0 END)                                                                                           AS Friday_stop_numb,
       MAX(CASE
               WHEN a.scheduling_options LIKE '%Saturday%' OR b.scheduling_options LIKE '%Saturday%' THEN 1
               ELSE 0 END)                                                                                           AS Saturday_stop_numb,
       MAX(CASE
               WHEN a.scheduling_options LIKE '%Sunday%' OR b.scheduling_options LIKE '%Sunday%' THEN 1
               ELSE 0 END)                                                                                           AS Sunday_stop_numb
FROM tempA_a AS a
         INNER JOIN tempA_b AS b ON a.site_id = b.site_id
GROUP BY a.site_id;

-- Step 3: Create the final table using the temporary table
INSERT INTO pf_new.template_work_order_services (scheduling_options, id, template_work_order_id, service_type_id,
                                                 rate_code_id, description, quantity, rate_code_code, rate_code_value,
                                                 rate_code_rate_1, rate_code_description, rate_code_create_reminder,
                                                 is_recurring, scheduling_frequency, scheduling_interval,
                                                 scheduling_start_date, scheduling_end_date, next_service_date,
                                                 route_id, stop_number, route_note)
SELECT CONCAT(
               '{"days":[',
               TRIM(TRAILING ',' FROM CONCAT(
                       (CASE WHEN Monday_stop_numb = 1 THEN '"Monday",' ELSE '' END),
                       (CASE WHEN Tuesday_stop_numb = 1 THEN '"Tuesday",' ELSE '' END),
                       (CASE WHEN Wednesday_stop_numb = 1 THEN '"Wednesday",' ELSE '' END),
                       (CASE WHEN Thursday_stop_numb = 1 THEN '"Thursday",' ELSE '' END),
                       (CASE WHEN Friday_stop_numb = 1 THEN '"Friday",' ELSE '' END),
                       (CASE WHEN Saturday_stop_numb = 1 THEN '"Saturday",' ELSE '' END),
                       (CASE WHEN Sunday_stop_numb = 1 THEN '"Sunday",' ELSE '' END)
                   )),
               ']}'
           ) AS scheduling_options,
       temp_data.id,
       temp_data.template_work_order_id,
       temp_data.service_type_id,
       temp_data.rate_code_id,
       temp_data.description,
       temp_data.quantity,
       temp_data.rate_code_code,
       temp_data.rate_code_value,
       temp_data.rate_code_rate_1,
       temp_data.rate_code_description,
       temp_data.rate_code_create_reminder,
       temp_data.is_recurring,
       temp_data.scheduling_frequency,
       temp_data.scheduling_interval,
       temp_data.scheduling_start_date,
       temp_data.scheduling_end_date,
       temp_data.next_service_date,
       temp_data.route_id,
       temp_data.stop_number,
       temp_data.route_note
FROM temp_data;


UPDATE pf_new.template_work_order_services
SET sunday_route_note = REGEXP_REPLACE(sunday_route_note, '<[^>]*>', '');

UPDATE pf_new.template_work_order_services
SET monday_route_note =REGEXP_REPLACE(monday_route_note, '<[^>]*>', '');

UPDATE pf_new.template_work_order_services
SET tuesday_route_note = REGEXP_REPLACE(tuesday_route_note, '<[^>]*>', '');

UPDATE pf_new.template_work_order_services
SET wednesday_route_note = REGEXP_REPLACE(wednesday_route_note, '<[^>]*>', '');

UPDATE pf_new.template_work_order_services
SET thursday_route_note = REGEXP_REPLACE(thursday_route_note, '<[^>]*>', '');

UPDATE pf_new.template_work_order_services
SET friday_route_note = REGEXP_REPLACE(friday_route_note, '<[^>]*>', '');

UPDATE pf_new.template_work_order_services
SET saturday_route_note = REGEXP_REPLACE(saturday_route_note, '<[^>]*>', '');

UPDATE pf_new.template_work_order_services
SET route_note = REGEXP_REPLACE(route_note, '<[^>]*>', '');

UPDATE pf_new.template_work_order_services
SET description = REGEXP_REPLACE(description, '<[^>]*>', '');

UPDATE pf_new.template_work_order_services
SET route_note = LTRIM(RTRIM(route_note));


UPDATE pf_new.template_work_order_services
SET scheduling_options = CONCAT(
    LEFT(RTRIM(scheduling_options), CHAR_LENGTH(RTRIM(scheduling_options)) - 1), ']}'
    )
WHERE scheduling_options LIKE '%,]}';


UPDATE pf_new.template_work_order_services
SET sunday_stop_number    = NULL,
    monday_stop_number    = NULL,
    tuesday_stop_number   = NULL,
    wednesday_stop_number = NULL,
    thursday_stop_number  = NULL,
    friday_stop_number    = NULL,
    saturday_stop_number  = NULL,
    sunday_route_id       = NULL,
    monday_route_id       = NULL,
    tuesday_route_id      = NULL,
    wednesday_route_id    = NULL,
    thursday_route_id     = NULL,
    friday_route_id       = NULL,
    saturday_route_id     = NULL,
    scheduling_options    = '"{object Object}"'
WHERE scheduling_interval IN ('Monthly', 'Yearly');

UPDATE pf_new.template_work_order_services
SET route_id    = NULL,
    stop_number = NULL
WHERE scheduling_interval = 'Weekly';


UPDATE pf_new.template_work_order_services pf
    INNER JOIN pf_new.code_sets cs
ON pf.rate_code_code = cs.code
    SET
        pf.rate_code_description = cs.description
WHERE
    pf.rate_code_description IS NULL
   OR pf.rate_code_description = '';

UPDATE pf_new.template_work_order_services
SET scheduling_options = '{}'
WHERE scheduling_interval = 'Yearly';

UPDATE pf_new.template_work_order_services
SET created_at = '1990-01-01'
WHERE created_at < '1940-01-01';

DELETE
FROM pf_new.template_work_order_services
WHERE template_work_order_id IS NULL;

UPDATE pf_new.template_work_order_services
SET next_service_date = DATE_ADD(next_service_date, INTERVAL IF(CURDATE() = CAST(next_service_date AS DATE), 1, 0) WEEK);
