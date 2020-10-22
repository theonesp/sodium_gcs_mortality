-- !preview conn=DBI::dbConnect(RSQLite::SQLite())

-- This query extracts the first MAP or RR on admission (+-12 hrs offset) that is not NULL for every patientid from pivoted_vital
WITH
  respiratoryrate_first AS (
  SELECT
    patientunitstayid,
    chartoffset,
    respiratoryrate,
    ROW_NUMBER() OVER (PARTITION BY patientunitstayid ORDER BY chartoffset ASC) AS rn
  FROM
    `physionet-data.eicu_crd_derived.pivoted_vital`
  WHERE
    respiratoryrate IS NOT NULL 
    AND chartoffset BETWEEN -12*60 AND +12*60 ),
  MAP_first AS (
  SELECT
    patientunitstayid,
    chartoffset,
    COALESCE(ibp_mean, nibp_mean) AS MAP,
    ROW_NUMBER() OVER (PARTITION BY patientunitstayid ORDER BY chartoffset ASC) AS rn
  FROM
    `physionet-data.eicu_crd_derived.pivoted_vital`
  WHERE   
   COALESCE(ibp_mean, nibp_mean) IS NOT NULL
   AND chartoffset BETWEEN -12*60 AND +12*60
)
SELECT
  patientunitstayid,
  respiratoryrate,
  MAP
FROM
`physionet-data.eicu_crd.patient` AS patient
LEFT JOIN
respiratoryrate_first
USING
(patientunitstayid)
LEFT JOIN
MAP_first
USING
(patientunitstayid)
WHERE
respiratoryrate_first.rn =1
AND
MAP_first.rn =1
