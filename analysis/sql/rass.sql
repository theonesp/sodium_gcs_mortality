-- !preview conn=DBI::dbConnect(RSQLite::SQLite())

  -- This query extracts (first available centered 12 hours on admit)
  -- Admission 1x :
  -- Admission sodium
  -- 
SELECT
DISTINCT
  patientunitstayid,
  nursingchartvalue
FROM
  `physionet-data.eicu_crd.nursecharting`
WHERE
  nursingchartcelltypevallabel = 'RASS'
  AND nursingchartoffset < 1440
  AND nursingchartoffset > -1440