-- This query retrieves the closest sedation score in time to gcs_baseline taking into account gcs_baseline offset.

WITH
sq1 AS(
  SELECT
  patientunitstayid,
  gcs AS gcs_baseline,
  gcs_motor AS gcs_motor_baseline,
  gcs_verbal AS gcs_verbal_baseline,
  gcs_eyes AS gcs_eyes_baseline,
  chartoffset,
  ROW_NUMBER() OVER (PARTITION BY patientunitstayid ORDER BY COALESCE (chartoffset) ASC) AS rn
  FROM
  `physionet-data.eicu_crd_derived.pivoted_score`
  WHERE
  chartoffset BETWEEN -6*24
  AND 24*60
  AND gcs IS NOT NULL
  AND gcs_motor IS NOT NULL
  AND gcs_verbal IS NOT NULL
  AND gcs_eyes IS NOT NULL ),
sq2 AS(
  SELECT
  patientunitstayid,
  chartoffset AS gcs_offset
  FROM
  sq1
  WHERE
  rn = 1
  ORDER BY
  patientunitstayid ),sq3 AS(
    SELECT
    sq2.patientunitstayid,
    nursingchartoffset,
    gcs_offset,
    CASE
    WHEN nursingchartvalue IN ('-1', '-2', '-3', '-4', '-5') THEN 'Sedated'
    WHEN nursingchartvalue IN ('0', '00', '01', '1') THEN 'Not Sedated'
    WHEN nursingchartvalue IN ('2', '3', '4', '5', '6', '7') THEN 'Exclude'
    ELSE  NULL
    END
    AS sedation_score,
    ROW_NUMBER() OVER (PARTITION BY sq2.patientunitstayid ORDER BY ABS(nursingchartoffset - gcs_offset) ASC) AS rn
    FROM
    sq2
    JOIN
    physionet-data.eicu_crd.nursecharting
    USING
    (patientunitstayid)
    WHERE nursingchartcelltypevalname = 'Sedation Score'
    ORDER BY
    sq2.patientunitstayid,
    rn
  )
SELECT
patientunitstayid,
sedation_score,   
nursingchartoffset
FROM
sq3
WHERE rn=1