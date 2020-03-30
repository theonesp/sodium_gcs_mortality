-- !preview conn=DBI::dbConnect(RSQLite::SQLite())

  -- This query extracts (first available centered 12 hours on admit)
  -- Admission 1x :
  -- Admission sodium
  -- 
WITH
  tempo AS (
  SELECT
    patientunitstayid,
    labname,
    labresultoffset,
    labresult,
    ROW_NUMBER() OVER (PARTITION BY patientunitstayid, labname ORDER BY labresultoffset ASC) AS position
  FROM
    `physionet-data.eicu_crd.lab`
  WHERE
    (  LOWER (labname) = 'sodium'
      )
    AND labresultoffset BETWEEN -12*60 AND 12*60
  ORDER BY
    patientunitstayid,
    labresultoffset )
SELECT
  patientunitstayid,
  MAX(CASE
    WHEN LOWER(labname) = 'sodium' AND position =1 THEN labresult
  ELSE
  NULL
END)
  AS sodium1
FROM
  tempo
GROUP BY patientunitstayid
