-- !preview conn=DBI::dbConnect(RSQLite::SQLite())

  --This query extracts the lowest GCS score for the ICU stay
  --The higher the GCS the better.  Ie normal >15.  The lower the score the more severe the lack of consciousness is.
  --We want the worst per day
  --Focus on: gcs and gcs_intub
WITH sq AS(
SELECT
  patientunitstayid,
  gcs AS gcs_baseline,
  gcs_motor AS gcs_motor_baseline,
  gcs_verbal AS gcs_verbal_baseline,
  gcs_eyes AS gcs_eyes_baseline,
  ROW_NUMBER() OVER (PARTITION BY patientunitstayid ORDER BY COALESCE (chartoffset) ASC) AS rn
FROM
  `physionet-data.eicu_crd_derived.pivoted_score`
WHERE
  chartoffset BETWEEN -6*24 AND 24*60
  AND gcs IS NOT NULL
  AND gcs_motor IS NOT NULL
  AND gcs_verbal IS NOT NULL  
  AND gcs_eyes IS NOT NULL )
SELECT
 patientunitstayid,
 gcs_baseline
 --gcs_motor_baseline,
 --gcs_verbal_baseline,
 --gcs_eyes_baseline
FROM
  sq
WHERE
  rn = 1
ORDER BY
  patientunitstayid


