-- !preview conn=DBI::dbConnect(RSQLite::SQLite())

  -- This query extracts (first available centered 12 hours on admit)
  -- Admission 1x :
  -- Admission sodium
  -- 
select patientunitstayid,hospitaladmitsource FROM `physionet-data.eicu_crd.patient`