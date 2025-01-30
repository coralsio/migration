
truncate table {db_new}.notes;

INSERT INTO {db_new}.notes (id, site_id, customer_id, note_type, note_title_id, note_text, note_category_id)
SELECT ROW_NUMBER() OVER (ORDER BY j3.custnum ASC) AS id, ps.id AS site_id,
       NULL    AS   customer_id,
       CASE
           WHEN ntcode LIKE 'POP%' THEN 'Display'
           ELSE 'Standard'
           END AS   note_type,
       COALESCE(
               (SELECT id FROM {db_new}.code_sets cs WHERE j3.ntcode = cs.code AND parent_id = 102),
               102
           )   AS   note_title_id,
       ntmemo  AS   note_text,
       COALESCE(
               (SELECT id FROM {db_new}.code_sets cs WHERE j3.ntcode = cs.code AND parent_id = 118),
               NULL
           )   AS   note_category_id
FROM {db_old}.jcusf03 j3
         LEFT OUTER JOIN {db_new}.sites ps
                         ON j3.custnum = ps.id;


INSERT INTO {db_new}.notes (id, site_id, customer_id, note_type, note_title_id, note_text, note_category_id)
SELECT (SELECT MAX(id) FROM {db_new}.notes) + ROW_NUMBER()                            OVER (ORDER BY j.custnum ASC) AS id, ps.id AS site_id,
       NULL                                                                      AS customer_id,
       'Standard'                                                                AS note_type,
       (SELECT id FROM {db_new}.code_sets WHERE code = 'NOTE' AND parent_id = 102) AS note_title_id,
       j.text0                                                                   AS note_text,
       NULL                                                                      AS note_category_id
FROM {db_old}.jcusf01 j
         LEFT JOIN {db_new}.sites ps ON j.custnum = ps.id
WHERE TRIM(j.text0) <> '';


INSERT INTO {db_new}.notes (id, site_id, customer_id, note_type, note_title_id, note_text, note_category_id)
SELECT (SELECT MAX(id) FROM {db_new}.notes) + ROW_NUMBER()                                           OVER (ORDER BY j.custnum ASC)          AS id, ps.id AS site_id,
       NULL                                                                                     AS customer_id,
       'Invoice'                                                                                AS note_type,
       COALESCE((SELECT id FROM {db_new}.code_sets WHERE code = 'NOTE' AND parent_id = 102), 102) AS note_title_id,
       j.custmemo                                                                               AS note_text,
       NULL                                                                                     AS note_category_id
FROM {db_old}.jcusf01 j
         LEFT JOIN {db_new}.sites ps ON j.custnum = ps.id
WHERE TRIM(j.custmemo) <> '';

INSERT INTO {db_new}.notes (id, site_id, customer_id, note_type, note_title_id, note_text, note_category_id)
SELECT (SELECT MAX(id) FROM {db_new}.notes) + ROW_NUMBER() OVER (ORDER BY j8.custmast ASC) AS id, NULL AS site_id,
       c.id           AS                                 customer_id,
       CASE
           WHEN j8.ntcode LIKE 'POP%' THEN 'Display'
           ELSE 'Standard'
           END        AS                                 note_type,
       COALESCE((SELECT id FROM {db_new}.code_sets cs WHERE j8.ntcode = cs.code AND parent_id = 102),
                102)  AS                                 note_title_id,
       j8.ntmemo      AS                                 note_text,
       COALESCE((SELECT id FROM {db_new}.code_sets cs WHERE j8.ntcode = cs.code AND parent_id = 118),
                NULL) AS                                 note_category_id
FROM {db_old}.jcusf08 j8
         LEFT JOIN {db_new}.customers c ON j8.custmast = c.number;


INSERT INTO {db_new}.notes (id, site_id, customer_id, note_type, note_title_id,
    -- note_text,
                          note_category_id, created_at)
SELECT (SELECT MAX(id) FROM {db_new}.notes) + ROW_NUMBER() OVER (ORDER BY j.bllmast ASC) AS id, NULL AS site_id,
       c.id         AS                                   customer_id,
       'Invoice'    AS                                   note_type,
       0            AS                                   note_title_id,
       --  j.bllinvmsg                                                                     AS note_text,
       0            AS                                   note_category_id,
       '1990-01-01' AS                                   created_at
FROM {db_old}.jcusf07 j -- changed from {db_old}.jcusf07 to {db_old}.jcusf07 due db arrow
         LEFT JOIN {db_new}.customers c ON j.bllmast = c.number
-- WHERE TRIM(j.bllinvmsg) <> ''
;


-- since the CollectionMessage & bllinvmsg are missing so the queires are duplicated

INSERT INTO {db_new}.notes (id, site_id, customer_id, note_type, note_title_id,
                          -- note_text,
                          note_category_id, created_at)
SELECT (SELECT MAX(id) FROM {db_new}.notes) + ROW_NUMBER() OVER (ORDER BY j.bllmast ASC) AS id, NULL AS site_id,
       c.id         AS                                   customer_id,
       'Collection' AS                                   note_type,
       0            AS                                   note_title_id,
       --  CAST(j.CollectionMessage AS CHAR) AS note_text,
       0            AS                                   note_category_id,
       '1990-01-01' AS                                   created_at
FROM {db_old}.jcusf07 j
         LEFT JOIN {db_new}.customers c ON j.bllmast = c.number
-- WHERE TRIM(j.CollectionMessage) <> ''
;


update {db_new}.notes
set note_text = REGEXP_REPLACE(note_text, '<[^>]*>', '');
update {db_new}.notes
set created_at = null
where created_at < '1990-01-01'
   or created_at > '2030-01-01'
