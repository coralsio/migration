-- UPDATE jtktf01 SET tktdate = NULL WHERE tktdate ='';
-- UPDATE jtktf01 SET tktdate = STR_TO_DATE(tktdate, '%m/%d/%Y');

truncate table {db_new}.work_order_notes;

INSERT INTO {db_new}.work_order_notes (work_order_id, user_id, notes, created_at)
SELECT wo.id      AS work_order_id,
       1          AS user_id,
       j.notememo AS notes,
       j.tktdate  AS created_at
FROM {db_old}.jtktf01 j
--          INNER JOIN {db_new}.work_orders wo ON j.invno = wo.invno; commented due arrow db
         INNER JOIN {db_new}.work_orders wo ON j.invno = wo.invoice_id;