-- basic demographics

SELECT
  basic_demographics.patientunitstayid,
  basic_demographics.age,
  basic_demographics.gender,
  basic_demographics.hosp_mortality,
  icustay_detail.unittype,
  icustay_detail.apache_iv,
  icustay_detail.ethnicity
FROM
  `physionet-data.eicu_crd_derived.basic_demographics` basic_demographics
INNER JOIN
  `physionet-data.eicu_crd_derived.icustay_detail` icustay_detail
USING (patientunitstayid)
