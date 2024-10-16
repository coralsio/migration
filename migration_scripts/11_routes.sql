truncate table pf_new.routes;

INSERT INTO pf_new.routes (ID, code, description, route_number, route_day, route_color, driver_id, truck_id,
                           division_id, max_stops)
SELECT ROW_NUMBER()  OVER(ORDER BY a.refcode ASC) AS ID, a.refcode AS code,
       a.refdesc  AS description,
       a.refroute AS route_number,
       CASE
           WHEN a.refrtday = 'M' THEN 'Mo'
           WHEN a.refrtday = 'T' THEN 'Tu'
           WHEN a.refrtday = 'W' THEN 'We'
           WHEN a.refrtday = 'H' THEN 'Th'
           WHEN a.refrtday = 'F' THEN 'Fr'
           WHEN a.refrtday = 'S' THEN 'Sa'
           WHEN a.refrtday = 'U' OR a.refrtday = 'SU' THEN 'Su'
           END    AS route_day,
       ''         AS route_color,
       0          AS driver_id,
       110        AS truck_id,
       (SELECT id FROM pf_new.divisions LIMIT 1) AS division_id,
    0 AS max_stops
FROM jref032 a;