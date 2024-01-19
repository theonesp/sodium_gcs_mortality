WITH TopAdmitSources AS (
  SELECT
    hospitaladmitsource,
    COUNT(*) AS count_per_source
  FROM `physionet-data.eicu_crd.patient`
  WHERE hospitaladmitsource IS NOT NULL AND hospitaladmitsource <> ''
  GROUP BY hospitaladmitsource
  ORDER BY count_per_source DESC
  LIMIT 5
)
SELECT
  p.patientunitstayid,
  COALESCE(tas.hospitaladmitsource, 'Other/Unknown') AS adm_source
FROM `physionet-data.eicu_crd.patient` p
LEFT JOIN TopAdmitSources tas ON p.hospitaladmitsource = tas.hospitaladmitsource
WHERE p.hospitaladmitsource IS NOT NULL AND p.hospitaladmitsource <> '';
