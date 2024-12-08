INSERT INTO pf_new.code_sets (code, description, value, parent_id)
SELECT DISTINCT
salecredit AS code,
    salecredit AS description,
    salecredit AS value,
    117 AS parent_id
FROM jcusf09
WHERE NOT EXISTS (
    SELECT 1
FROM pf_new.code_sets
WHERE parent_id = 117 AND code = salecredit
)
and salecredit IS NOT NULL;


INSERT INTO pf_new.code_sets (code, description, value, parent_id)
SELECT DISTINCT
PFrent_rate_code_id AS code,
    PFrent_rate_code_id AS description,
    PFrent_rate_code_id AS value,
    106 AS parent_id
FROM jivtf01
WHERE NOT EXISTS (
    SELECT 1
FROM pf_new.code_sets
WHERE parent_id = 106 AND code = PFrent_rate_code_id
)
and PFrent_rate_code_id IS NOT NULL and PFrent_rate_code_id <> '';


INSERT INTO pf_new.code_sets (code, description, value, parent_id)
SELECT DISTINCT
j1.desc AS code,
    j1.desc AS description,
    j1.desc AS value,
    103 AS parent_id
FROM jivtf01 j1
WHERE NOT EXISTS (
    SELECT 1
FROM pf_new.code_sets
WHERE parent_id = 103 AND code = j1.desc
) AND j1.desc IS NOT NULL AND j1.desc <> '';


INSERT INTO pf_new.code_sets (code, description, value, parent_id)
SELECT DISTINCT
    PFrent_rate_code_id AS code,
    PFrent_rate_code_id AS description,
    NULL AS value,
    106 AS parent_id
FROM jivtf01
WHERE PFrent_rate_code_id IS NOT NULL and PFrent_rate_code_id <> ''
  AND NOT EXISTS (
    SELECT 1
    FROM pf_new.code_sets
    WHERE parent_id = 106 AND code = PFrent_rate_code_id
    );


INSERT INTO pf_new.code_sets (code, description, value, parent_id)
SELECT DISTINCT jk.tktsale AS code, jk.tktsale AS description, jk.tktsale AS value, 117 AS parent_id
FROM jtktf01 jk
WHERE jk.tktsale IS NOT NULL and jk.tktsale <> ''
  AND NOT EXISTS (
    SELECT 1
    FROM pf_new.code_sets cs
    WHERE cs.parent_id = 117
  AND cs.code = jk.tktsale
    );

INSERT INTO pf_new.code_sets (code, description, value, parent_id)
SELECT DISTINCT jk.prodtext AS code, jk.prodtext AS description, jk.prodtext AS value, 107 AS parent_id
FROM jtktf01 jk
WHERE jk.prodtext IS NOT NULL and jk.prodtext <> ''
  AND NOT EXISTS (
    SELECT 1
    FROM pf_new.code_sets cs
    WHERE cs.parent_id = 107
  AND cs.code = jk.prodtext
    );


INSERT INTO pf_new.code_sets (code, description, value, parent_id)
SELECT DISTINCT jk.typesrv AS code,
                jk.typesrv  AS description,
                jk.typesrv  AS value,
                111 AS parent_id
FROM jtktf01 jk
WHERE jk.typesrv IS NOT NULL and jk.typesrv <> ''
  AND NOT EXISTS (
    SELECT 1
    FROM pf_new.code_sets cs
    WHERE cs.parent_id = 111
  AND cs.code = jk.typesrv
    );

INSERT INTO pf_new.code_sets (code, description, value, parent_id)
SELECT DISTINCT jk.driver AS code, jk.driver AS description,  jk.driver AS value, 115 AS parent_id
FROM jtktf01 jk
WHERE jk.driver IS NOT NULL and jk.driver <> ''
  AND NOT EXISTS (
    SELECT 1
    FROM pf_new.code_sets cs
    WHERE cs.parent_id = 115
  AND cs.code = jk.driver
    );

INSERT INTO pf_new.code_sets (code, description, value, parent_id)
SELECT DISTINCT jx.chrgclerk AS code, jx.chrgclerk AS description, jx.chrgclerk AS value, 100 AS parent_id
FROM jxchrgf1 jx
WHERE jx.chrgclerk IS NOT NULL and jx.chrgclerk <> ''
  AND NOT EXISTS (
    SELECT 1
    FROM pf_new.code_sets cs
    WHERE cs.parent_id = 100
  AND cs.code = jx.chrgclerk
    );


INSERT INTO pf_new.code_sets (code, description, value, parent_id)
SELECT DISTINCT j.centclerk AS code, j.centclerk AS description, j.centclerk AS value, 100 AS parent_id
FROM jcusf01_sites_dbf j
WHERE j.centclerk IS NOT NULL and j.centclerk <> ''
  AND NOT EXISTS (
    SELECT 1
    FROM pf_new.code_sets cs
    WHERE cs.parent_id = 100
  AND cs.code = j.centclerk
    );


INSERT INTO pf_new.code_sets (code, description, value, parent_id)
SELECT DISTINCT a.tktype AS code, a.tktype AS description,  a.tktype  AS value, 104 AS parent_id
FROM jtnkf01 a
WHERE a.tktype IS NOT NULL and a.tktype <> ''
  AND NOT EXISTS (
    SELECT 1
    FROM pf_new.code_sets cs
    WHERE cs.parent_id = 104
  AND cs.code = a.tktype
    );

INSERT INTO pf_new.code_sets (code, description, value, parent_id)
SELECT distinct     jr.rttypetkt as code, jr.rttypetkt as description,jr.rttypetkt as value,  111
FROM jrtf05 jr WHERE jr.rttypetkt IS NOT NULL and jr.rttypetkt <> ''
                 AND NOT EXISTS (
            SELECT 1
            FROM pf_new.code_sets cs
            WHERE cs.parent_id = 111
              AND cs.code = jr.rttypetkt
        );


INSERT INTO pf_new.code_sets (code, description, value, parent_id)
SELECT distinct jr.rtratecode as code, jr.rtratecode as description,jr.rtratecode as value,  106
FROM jrtf05 jr WHERE jr.rtratecode IS NOT NULL and jr.rtratecode <> ''
                 AND NOT EXISTS (
    SELECT 1
    FROM pf_new.code_sets cs
    WHERE cs.parent_id = 106
                 AND cs.code = jr.rtratecode
    );

INSERT INTO pf_new.code_sets (code, description, value, parent_id)
SELECT distinct jt.ratecode1 as code, jt.ratecode1 as description,jt.ratecode1 as value,  106
FROM jtktf01 jt WHERE jt.ratecode1 IS NOT NULL and jt.ratecode1 <> ''
                  AND NOT EXISTS (
    SELECT 1
    FROM pf_new.code_sets cs
    WHERE cs.parent_id = 106
                 AND cs.code = jt.ratecode1
    );

INSERT INTO pf_new.code_sets (code, description, value, parent_id)
SELECT distinct typesrv as code, typesrv as description,typesrv as value,  111
FROM jtktf01 jt WHERE typesrv IS NOT NULL and typesrv <> ''
                  AND NOT EXISTS (
    SELECT 1
    FROM pf_new.code_sets cs
    WHERE cs.parent_id = 111
                  AND cs.code = typesrv
    );

INSERT INTO pf_new.code_sets (code, description, value, parent_id)
SELECT distinct j3.ntcode as code, j3.ntcode as description,j3.ntcode as value,  102
FROM jcusf03 j3 WHERE j3.ntcode IS NOT NULL and j3.ntcode <> ''
                  AND NOT EXISTS (
    SELECT 1
    FROM pf_new.code_sets cs
    WHERE cs.parent_id = 102
                  AND cs.code = j3.ntcode
    );


INSERT INTO pf_new.code_sets (code, description, value, parent_id)
SELECT distinct j3.ntcode as code, j3.ntcode as description,j3.ntcode as value,  118
FROM jcusf03 j3 WHERE j3.ntcode IS NOT NULL and j3.ntcode <> ''
                  AND NOT EXISTS (
    SELECT 1
    FROM pf_new.code_sets cs
    WHERE cs.parent_id = 118
                  AND cs.code = j3.ntcode
    );


INSERT INTO pf_new.code_sets (code, description, value, parent_id)
SELECT 'NOTE', 'NOTE', 'NOTE', 102
    WHERE NOT EXISTS (
    SELECT 1 FROM pf_new.code_sets cs WHERE cs.code = 'NOTE' AND cs.parent_id = 102
);

INSERT INTO pf_new.code_sets (code, description, value, parent_id)
SELECT distinct j8.ntcode as code, j8.ntcode as description,j8.ntcode as value,  118
FROM jcusf08 j8 WHERE j8.ntcode IS NOT NULL and j8.ntcode <> ''
                  AND NOT EXISTS (
    SELECT 1
    FROM pf_new.code_sets cs
    WHERE cs.parent_id = 118
                  AND cs.code = j8.ntcode
    );

INSERT INTO pf_new.code_sets (code, description, value, parent_id)
SELECT distinct j8.ntcode as code, j8.ntcode as description,j8.ntcode as value,  102
FROM jcusf08 j8 WHERE j8.ntcode IS NOT NULL and j8.ntcode <> ''
                  AND NOT EXISTS (
    SELECT 1
    FROM pf_new.code_sets cs
    WHERE cs.parent_id = 102
                  AND cs.code = j8.ntcode
    );