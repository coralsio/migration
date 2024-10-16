-- UPDATE jtktf01 SET tktdate = NULL WHERE tktdate ='';
-- UPDATE jtktf01 SET tktdate = STR_TO_DATE(tktdate, '%m/%d/%Y');

truncate table pf_new.work_order_notes;

INSERT INTO pf_new.work_order_notes (work_order_id, user_id, notes, created_at)
SELECT wo.id      AS work_order_id,
       1          AS user_id,
       j.notememo AS notes,
       j.tktdate  AS created_at
FROM jtktf01 j
         INNER JOIN pf_new.work_orders wo ON j.invno = wo.invno;