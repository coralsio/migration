-- UPDATE jcusf01_sites_dbf SET startdate =null WHERE startdate  = '';
-- UPDATE jcusf01_sites_dbf SET startdate = STR_TO_DATE(startdate,'%d/%m/%Y');
truncate table pf_new.notifications;

INSERT INTO pf_new.notifications (ID,
                                  customer_id,
                                  site_id,
                                  user_id,
                                  notification_preference_email,
                                  notification_preference_sms,
                                  notification_preference_mailing_label,
                                  subject,
                                  message,
                                  is_recurring,
                                  scheduling_interval,
                                  scheduling_frequency,
                                  scheduling_start_date,
                                  scheduling_end_date,
                                  next_notification_date,
                                  sms_message)
SELECT (@rownum := @rownum + 1)                                                                                                            AS ID,
       pfs.customer_id                                                                                                                     AS customer_id,
       pfs.id                                                                                                                              AS site_id,
       COALESCE(
               (SELECT id
                FROM pf_new.code_sets cs
                WHERE cs.code = j.centclerk
                  AND cs.parent_id IN (100, 112)
               LIMIT
               1), 100)                                                                                                                    AS user_id,
       1                                                                                                                                   AS notification_preference_email,
       1                                                                                                                                   AS notification_preference_sms,
       1                                                                                                                                   AS notification_preference_mailing_label,
       'Service Reminder'                                                                                                                  AS subject,
       'A friendly reminder that your System is Due for Service. Please email or call us so we can get you scheduled at your convenience.' AS message,
       1                                                                                                                                   AS is_recurring,
       'Yearly'                                                                                                                            AS scheduling_interval,
       j.remindint                                                                                                                         AS scheduling_frequency,
       j.startdate                                                                                                                         AS scheduling_start_date,
       j.startdate                                                                                                                         AS scheduling_end_date,
       CASE
           WHEN j.remindint > 0 THEN j.startdate
           ELSE NULL
           END                                                                                                                             AS next_notification_date,
       ''                                                                                                                                  AS sms_message
FROM jcusf01_sites_dbf j
         JOIN pf_new.sites pfs ON j.custnum = pfs.id
   , (SELECT @rownum := 0) r
WHERE j.startdate > '2019-12-31';


-- Update scheduling_start_date to '1990-01-01' where it's earlier than '1970-01-01'
UPDATE pf_new.notifications
SET scheduling_start_date = '1990-01-01'
WHERE scheduling_start_date < '1970-01-01';

-- Add 50 years to scheduling_end_date
UPDATE pf_new.notifications
SET scheduling_end_date = DATE_ADD(scheduling_end_date, INTERVAL 50 YEAR);

-- Delete rows where scheduling_frequency is 0
DELETE
FROM pf_new.notifications
WHERE scheduling_frequency = 0;
