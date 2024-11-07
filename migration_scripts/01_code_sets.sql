set FOREIGN_key_checks=0;
truncate table pf_new.code_sets;
drop temporary table if exists temp_codesets;
CREATE TEMPORARY TABLE temp_codesets AS
SELECT null          as ID,
       TRIM(refcode) AS code,
       TRIM(refcode) AS `value`,
       CASE
           WHEN CONCAT(CAST(refdesc AS CHAR), CAST(refmemo AS CHAR)) = '' THEN TRIM(refcode)
           WHEN CONCAT(CAST(refdesc AS CHAR), CAST(refmemo AS CHAR)) IS NULL THEN TRIM(refcode)
           ELSE CONCAT(CAST(refdesc AS CHAR), CAST(refmemo AS CHAR))
           END       AS `Description`,
       parent_id,
       0             AS editable,
       0             AS deletable
FROM (
         SELECT refcode, refdesc, refmemo, 100 AS parent_id
         FROM jref004
         UNION ALL
         SELECT refcode, refdesc, refmemo, 101
         FROM jref006
         UNION ALL
         SELECT refcode, refdesc, refmemo, 102
         FROM jref089
         UNION ALL
         SELECT refcode, refdesc, refmemo, 103
         FROM jref007
         UNION ALL
         SELECT refcode, refdesc, refmemo, 104
         FROM jref007
         UNION ALL
         SELECT refcode, refdesc, refmemo, 105
         FROM jref050
         UNION ALL
         SELECT refcode, refdesc, refmemo, 106
         FROM jref015
         UNION ALL
         SELECT refcode, refdesc, refmemo, 107
         FROM jref013
         UNION ALL
         SELECT refcode, refdesc, refmemo, 108
         FROM jref052
         UNION ALL
         SELECT refcode, refdesc, refmemo, 109
         FROM jref054
         UNION ALL
         SELECT refcode, refdesc, refmemo, 110
         FROM jref0n2
         UNION ALL
         SELECT refcode, refdesc, refmemo, 111
         FROM jref001
         UNION ALL
         SELECT refcode, refdesc, refmemo, 112
         FROM jref004
         UNION ALL
         SELECT refcode, refdesc, refmemo, 113
         FROM jref091
         UNION ALL
         SELECT refcode, refdesc, refmemo, 117
         FROM jref030
     ) AS combined_data;

-- Step 1: Set the initial row number
SET @row_num := 5000;

ALTER TABLE temp_codesets
    MODIFY COLUMN ID BIGINT;

DROP TEMPORARY TABLE IF EXISTS temp_codesets_with_ids;

-- Step 2: Create a temporary table to hold the data with ordered row numbers
CREATE TEMPORARY TABLE temp_codesets_with_ids AS
SELECT @row_num := @row_num + 1 AS ID, parent_id, code, value, Description, editable, deletable
FROM temp_codesets
ORDER BY parent_id, code;

truncate table temp_codesets;

-- Step 3: Insert from the temporary table back into `temp_codesets`
INSERT INTO temp_codesets (ID, parent_id, code, value, Description, editable, deletable)
SELECT ID, parent_id, code, value, Description, editable, deletable
FROM temp_codesets_with_ids;

-- Step 4: Drop the temporary table (optional, will be dropped automatically at the end of the session)
DROP TEMPORARY TABLE IF EXISTS temp_codesets_with_ids;

INSERT INTO pf_new.code_sets
(id, code, value, description, parent_id, properties, editable, deletable,
 created_by, updated_by, deleted_at, created_at, updated_at)
VALUES (1, 'address-states-list', 'Address States', 'Address States', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, NULL),
       (2, 'AK', 'Alaska', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (3, 'AL', 'Alabama', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (4, 'AR', 'Arkansas', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (5, 'AZ', 'Arizona', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (6, 'CA', 'California', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (7, 'CO', 'Colorado', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (8, 'CT', 'Connecticut', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (9, 'DE', 'Delaware', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (10, 'DC', 'District of Columbia', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (11, 'FL', 'Florida', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (12, 'GA', 'Georgia', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (13, 'HI', 'Hawaii', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (14, 'IA', 'Iowa', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (15, 'ID', 'Idaho', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (16, 'IL', 'Illinois', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (17, 'IN', 'Indiana', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (18, 'KS', 'Kansas', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (19, 'KY', 'Kentucky', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (20, 'LA', 'Louisiana', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (21, 'MA', 'Massachusetts', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (22, 'MD', 'Maryland', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (23, 'ME', 'Maine', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (24, 'MI', 'Michigan', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (25, 'MN', 'Minnesota', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (26, 'MO', 'Missouri', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (27, 'MS', 'Mississippi', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (28, 'MT', 'Montana', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (29, 'NC', 'North Carolina', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (30, 'ND', 'North Dakota', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (31, 'NE', 'Nebraska', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (32, 'NH', 'New Hampshire', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (33, 'NJ', 'New Jersey', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (34, 'NM', 'New Mexico', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (35, 'NV', 'Nevada', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (36, 'NY', 'New York', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (37, 'OH', 'Ohio', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (38, 'OK', 'Oklahoma', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (39, 'OR', 'Oregon', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (40, 'PA', 'Pennsylvania', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (41, 'RI', 'Rhode Island', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (42, 'SC', 'South Carolina', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (43, 'SD', 'South Dakota', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (44, 'TN', 'Tennessee', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (45, 'TX', 'Texas', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (46, 'UT', 'Utah', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (47, 'VA', 'Virginia', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (48, 'VT', 'Vermont', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (49, 'WA', 'Washington', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (50, 'WI', 'Wisconsin', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (51, 'WV', 'West Virginia', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (52, 'WY', 'Wyoming', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (54, 'AB', 'Alberta', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (55, 'BC', 'British Columbia', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (56, 'NB', 'New Brunswick', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (57, 'NL', 'Newfoundland', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (58, 'NT', 'Northwest Territories', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (59, 'NS', 'Nova Scotia', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (60, 'NU', 'Nunavut', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (61, 'ON', 'Ontario', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (62, 'PE', 'Prince Edward Island', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (63, 'QC', 'Quebec', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (64, 'SK', 'Saskatchewan', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (65, 'YT', 'Yukon', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL),
       (66, 'NA', 'NA', NULL, 1, NULL, 1, 1, NULL, NULL, NULL, NULL, NULL)
;


insert into pf_new.code_sets(id, code, value, description, editable)
values (100, 'sales_sources', 'Sales Sources', 'Sales Sources', 1);
insert into pf_new.code_sets(id, code, value, description, editable)
values (101, 'market_segments', 'Market Segments', 'Market Segments', 1);
insert into pf_new.code_sets(id, code, value, description, editable)
values (102, 'note_titles', 'Note Titles', 'Note Titles', 1);
insert into pf_new.code_sets(id, code, value, description, editable)
values (103, 'asset_types', 'Asset Types', 'Asset Types', 1);
insert into pf_new.code_sets(id, code, value, description, editable)
values (104, 'equipment_types', 'Equipment Types', 'Equipment Types', 1);
insert into pf_new.code_sets(id, code, value, description, editable)
values (105, 'disposal_locations', 'Disposal Locations', 'Disposal locations', 1);
insert into pf_new.code_sets(id, code, value, description, editable)
values (106, 'rate_codes', 'Rate Codes', 'Rate Codes', 1);
insert into pf_new.code_sets(id, code, value, description)
values (107, 'work_order_statuses ', 'Work Order Statuses', 'Work Order Statuses');

insert into pf_new.code_sets(id, code, value, description, editable)
values (108, 'waste_sources', 'Waste Sources', 'Waste Sources', 1);

insert into pf_new.code_sets(id, code, value, description, editable)
values (109, 'waste_types ', 'Waste Types ', 'Waste Types', 1);

insert into pf_new.code_sets(id, code, value, description, editable)
values (110, 'trucks', 'Trucks', 'Trucks', 1);

insert into pf_new.code_sets(id, code, value, description, editable)
values (111, 'service_types', 'Service Types', 'Service Types', 1);

insert into pf_new.code_sets(id, code, value, description, editable)
values (112, 'sales_credits ', 'Sales Credits ', 'Sales Credits ', 1);

insert into pf_new.code_sets(id, code, value, description, editable)
values (113, 'surcharges', 'Surcharges', 'Surcharges', 1);

insert into pf_new.code_sets(id, code, value, description, editable)
values (114, 'email_templates', 'Email Templates', 'Email Templates', 1);

insert into pf_new.code_sets(id, code, value, description, editable)
values (115, 'taxes', 'Taxes', 'Taxes', 1);

insert into pf_new.code_sets(id, code, value, description, editable)
values (116, 'text_templates', 'Text Templates', 'Text Templates', 1);

insert into pf_new.code_sets(id, code, value, description, editable)
values (118, 'note_categories', 'Note Categories', 'Note Categories', 1);

insert into pf_new.code_sets(id, code, value, description, editable)
values (119, 'scheduling_settings', 'Scheduling Settings', 'Scheduling Settings', 1);

insert into pf_new.code_sets(id, code, value, description, editable)
values (117, 'sales_reps', 'Sales Reps', 'Sales Reps', 1);

--
insert into pf_new.code_sets(id, code, value, description)
values (10001, 'division_market_segment_id', 'division market segment id', 'division market segment id');

insert into pf_new.code_sets(id, code, value, description, parent_id, properties, editable)
values (10000, '7118', '', 'Site Default Surcharge #1 Code', 113, '{"Percentage": 0}', 1);

insert into pf_new.code_sets(id, code, value, description, parent_id, editable)
values (4999, 'advanced', 'Advanced', 'Advanced', 119, 1);

insert into pf_new.code_sets(id, code, value, description, parent_id, editable)
values (5000, 'arrears', 'Arrears', 'Arrears', 119, 1);

insert into pf_new.code_sets(id, code, value, description, parent_id, editable)
values (99999, '', '', 'Blank', 1, 1);

insert into pf_new.code_sets(id, code, value, description, parent_id, editable)
values (99998, '', '', 'Blank', NULL, 1);

insert into pf_new.code_sets(id, code, value, description, parent_id, editable)
values (99997, '', '', 'Bad Data', NULL, 1);


insert into pf_new.code_sets( code, value, description, parent_id, editable)
values ( 'na', 'na', 'na', NULL, 1);

INSERT INTO pf_new.code_sets (id, code, value, description, parent_id, properties)
SELECT id, code, value, CAST(description AS CHAR(1024)), parent_id, null
    FROM temp_codesets where code is not null;


insert into pf_new.code_sets(code, value, description,parent_id, editable)
values ( 'PTW', 'PTW', 'PTW',103, 1),
 ( 'SPT', 'SPT', 'SPT',103, 1),
 ( 'SPTS', 'SPTS', 'SPTS',103, 1),
 ( 'SHCA', 'SHCA', 'SHCA',103, 1),
 ( 'SHCWC', 'SHCWC', 'SHCWC',103, 1),
 ( 'BC', 'BC', 'BC',103, 1),
 ( 'PTN', 'PTN', 'PTN',103, 1),
 ( 'PTS', 'PTS', 'PTS',103, 1),
 ( 'HCN', 'HCN', 'HCN',103, 1),
 ( 'PTSW', 'PTSW', 'PTSW',103, 1),
 ( 'WS', 'WS', 'WS',103, 1),
 ( 'RPT', 'RPT', 'RPT',103, 1),
 ( 'HS', 'HS', 'HS',103, 1),
 ( 'CT', 'CT', 'CT',103, 1),
 ( 'EXEC', 'EXEC', 'EXEC',103, 1);
