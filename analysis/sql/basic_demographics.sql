  -- basic demographics
WITH
  sq AS(
  SELECT
    basic_demographics.patientunitstayid,
    CASE -- fixing age >89 to 93
      WHEN basic_demographics.age = '> 89' THEN 93 -- age avg of eicu patients >89
      WHEN basic_demographics.age IS NOT NULL
    AND basic_demographics.age !='' THEN CAST (basic_demographics.age AS INT64)
  END
    AS age,
    basic_demographics.gender,
    basic_demographics.hosp_mortality,
    icustay_detail.unittype,
    icustay_detail.apache_iv,
    icustay_detail.ethnicity
  FROM
    `physionet-data.eicu_crd_derived.basic_demographics` basic_demographics
  INNER JOIN
    `physionet-data.eicu_crd_derived.icustay_detail` icustay_detail
  USING
    (patientunitstayid) )
SELECT
  patientunitstayid,
  age,
  gender,
  hosp_mortality,
  unittype,
  apache_iv,
  ethnicity
FROM
  sq
WHERE
  age >=16