-- TProvides predictions made by the APACHE score (versions IV and IVa).

-- Select patientunitstayid and apachescore based on the specified conditions,
-- ensuring only one apache score is printed for each patientunitstayid.
-- Select patientunitstayid and prioritize apachescore based on apacheversion.
SELECT 
  patientunitstayid, 
  COALESCE(MAX(CASE WHEN apacheversion = 'IVa' THEN apachescore END), 
           MAX(CASE WHEN apacheversion = 'IV' THEN apachescore END)) AS apachescore
FROM `physionet-data.eicu_crd.apachepatientresult`
-- Ensure only one row per patientunitstayid is selected.
GROUP BY patientunitstayid;

