-- TProvides predictions made by the APACHE score (versions IV and IVa).

SELECT 
patientunitstayid, 
apachescore 
FROM `physionet-data.eicu_crd.apachepatientresult`
