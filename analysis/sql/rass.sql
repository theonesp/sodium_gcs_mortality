-- !preview conn=DBI::dbConnect(RSQLite::SQLite())

  -- This query extracts (first available centered 12 hours on admit)
  -- Admission 1x :
  -- Admission sodium
  -- 
SELECT * FROM `physionet-data.eicu_crd.nursecharting`
where nursingchartcelltypevallabel = 'RASS'
and nursingchartoffset < 1440
and nursingchartoffset > -1440