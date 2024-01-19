-- The ROW_NUMBER() function is used to assign a rank to each admitdxpath within each patientunitstayid based on their frequency.
-- The PARTITION BY clause ensures that the ranking is done separately for each patientunitstayid.
-- The WHERE clause filters out null or empty values in the admitdxpath.
-- The COALESCE function is used to replace null or empty values with 'Other'.
-- The final result selects the patientunitstayid and the top 5 ranked admitdxpath values for each patient.
  -- 
WITH TopAdmitSources AS (
  SELECT
    apacheadmissiondx,
    COUNT(*) AS count_per_source
  FROM `physionet-data.eicu_crd.patient`
  WHERE apacheadmissiondx IS NOT NULL AND apacheadmissiondx <> ''
  GROUP BY apacheadmissiondx
  ORDER BY count_per_source DESC
  LIMIT 5
)
SELECT
  `physionet-data.eicu_crd.patient`.patientunitstayid,
  COALESCE(TopAdmitSources.apacheadmissiondx, 'Other/Unknown') AS apacheadmissiondx
FROM `physionet-data.eicu_crd.patient`
LEFT JOIN TopAdmitSources ON `physionet-data.eicu_crd.patient`.apacheadmissiondx = TopAdmitSources.apacheadmissiondx
WHERE `physionet-data.eicu_crd.patient`.apacheadmissiondx IS NOT NULL AND `physionet-data.eicu_crd.patient`.apacheadmissiondx <> '';

