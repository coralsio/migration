set FOREIGN_key_checks=0;
    set sql_mode ='';
truncate table {db_new}.routes;

INSERT INTO {db_new}.routes (ID, code, description, route_number, route_day, route_color, driver_id, truck_id,
                           division_id, max_stops)
SELECT ROW_NUMBER()  OVER(ORDER BY a.ROUTECODE ASC) AS ID, a.ROUTECODE AS code,
       ROUTECODE  AS description,
       a.routenum AS route_number,
       CASE
           WHEN a.routeday = 'M' THEN 'Mo'
           WHEN a.routeday = 'T' THEN 'Tu'
           WHEN a.routeday = 'W' THEN 'We'
           WHEN a.routeday = 'H' THEN 'Th'
           WHEN a.routeday = 'F' THEN 'Fr'
           WHEN a.routeday = 'S' THEN 'Sa'
           WHEN a.routeday = 'U' OR a.routeday = 'SU' THEN 'Su'
           END    AS route_day,
       ''         AS route_color,
       0          AS driver_id,
       110        AS truck_id,
       (SELECT id FROM {db_new}.divisions LIMIT 1) AS division_id,
    0 AS max_stops
FROM {db_old}.JRTF01 a group by routecode;
