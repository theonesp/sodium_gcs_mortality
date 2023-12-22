-- !preview conn=DBI::dbConnect(RSQLite::SQLite())

  -- This query extracts (first available centered 12 hours on admit)
  -- Admission 1x :
  -- Admission sodium
  -- 
SELECT patientunitstayid,admitdxpath FROM `physionet-data.eicu_crd.admissiondx`