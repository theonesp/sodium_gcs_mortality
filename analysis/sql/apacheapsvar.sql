-- This query extracts part of the required apache variables.

SELECT
  patientunitstayid,
  intubated,
  vent,
  dialysis,
  eyes,
  motor,
  verbal,
  meds,
  urine,
  wbc,
  temperature,
  heartrate,
  meanbp,
  ph,
  hematocrit,
  creatinine,
  albumin,
  pao2,
  pco2,
  bun,
  glucose,
  bilirubin,
  fio2
FROM
  `physionet-data.eicu_crd.apacheapsvar`
