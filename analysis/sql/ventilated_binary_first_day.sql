  --It tells whether the patient was mechanically ventilated each day for the first 10 days of ICU admission.
  --this query gets the data from respiratorycare (any invasive airway),
  --respiratorycharting and treatment (either ETT/NiV) to tell whether
  --a patient was mechanically ventilated during the first 10 days of ICU admission
WITH
  t1 AS (
  SELECT
    DISTINCT patientunitstayid,
    respcarestatusoffset
  FROM
    `physionet-data.eicu_crd.respiratorycare`
  WHERE
    respcarestatusoffset BETWEEN -6*60
    AND 24*10*60 --FROM minus 6 hours to 10 days
    AND airwaytype IN ('Oral ETT','Nasal ETT','Tracheostomy') -- either invasive airway or NULL
    ),
  t2 AS (
  SELECT
    DISTINCT patientunitstayid,
    respchartoffset
  FROM
    `physionet-data.eicu_crd.respiratorycharting` rc
  WHERE
    LOWER(respchartvalue) LIKE '%ventilator%'
    OR LOWER(respchartvalue) LIKE '%vent%'
    OR LOWER(respchartvalue) LIKE '%bipap%'
    OR LOWER(respchartvalue) LIKE '%840%'
    OR LOWER(respchartvalue) LIKE '%cpap%'
    OR LOWER(respchartvalue) LIKE '%drager%'
    OR LOWER(respchartvalue) LIKE 'mv%'
    OR LOWER(respchartvalue) LIKE '%servo%'
    OR LOWER(respchartvalue) LIKE '%peep%'
    AND respchartoffset BETWEEN -6*60
    AND 24*10*60 --FROM minus 6 hours to 10 days
    ),
  t3 AS (
  SELECT
    DISTINCT patientunitstayid,
    treatmentoffset
  FROM
    `physionet-data.eicu_crd.treatment`
  WHERE
    treatmentoffset BETWEEN -6*60
    AND 24*10*60 --FROM minus 6 hours to 10 days
    AND treatmentstring IN ('pulmonary|ventilation and oxygenation|mechanical ventilation',
      'pulmonary|ventilation and oxygenation|tracheal suctioning',
      'pulmonary|ventilation and oxygenation|ventilator weaning',
      'pulmonary|ventilation and oxygenation|mechanical ventilation|assist controlled',
      'pulmonary|radiologic procedures / bronchoscopy|endotracheal tube',
      'pulmonary|ventilation and oxygenation|oxygen therapy (> 60%)',
      'pulmonary|ventilation and oxygenation|mechanical ventilation|tidal volume 6-10 ml/kg',
      'pulmonary|ventilation and oxygenation|mechanical ventilation|volume controlled',
      'surgery|pulmonary therapies|mechanical ventilation',
      'pulmonary|surgery / incision and drainage of thorax|tracheostomy',
      'pulmonary|ventilation and oxygenation|mechanical ventilation|synchronized intermittent',
      'pulmonary|surgery / incision and drainage of thorax|tracheostomy|performed during current admission for ventilatory support',
      'pulmonary|ventilation and oxygenation|ventilator weaning|active',
      'pulmonary|ventilation and oxygenation|mechanical ventilation|pressure controlled',
      'pulmonary|ventilation and oxygenation|mechanical ventilation|pressure support',
      'pulmonary|ventilation and oxygenation|ventilator weaning|slow',
      'surgery|pulmonary therapies|ventilator weaning',
      'surgery|pulmonary therapies|tracheal suctioning',
      'pulmonary|radiologic procedures / bronchoscopy|reintubation',
      'pulmonary|ventilation and oxygenation|lung recruitment maneuver',
      'pulmonary|surgery / incision and drainage of thorax|tracheostomy|planned',
      'surgery|pulmonary therapies|ventilator weaning|rapid',
      'pulmonary|ventilation and oxygenation|prone position',
      'pulmonary|surgery / incision and drainage of thorax|tracheostomy|conventional',
      'pulmonary|ventilation and oxygenation|mechanical ventilation|permissive hypercapnea',
      'surgery|pulmonary therapies|mechanical ventilation|synchronized intermittent',
      'pulmonary|medications|neuromuscular blocking agent',
      'surgery|pulmonary therapies|mechanical ventilation|assist controlled',
      'pulmonary|ventilation and oxygenation|mechanical ventilation|volume assured',
      'surgery|pulmonary therapies|mechanical ventilation|tidal volume 6-10 ml/kg',
      'surgery|pulmonary therapies|mechanical ventilation|pressure support') ),
  sq AS(
  SELECT
    pt.patientunitstayid,
    CASE
      WHEN respcarestatusoffset BETWEEN -6*60 AND 24*60 OR respchartoffset BETWEEN -6*60 AND 24*60 OR treatmentoffset BETWEEN -6*60 AND 24*60 THEN 1
      ELSE 0
    END AS mechvent_day01
  FROM
    `physionet-data.eicu_crd.patient` pt
  LEFT JOIN
    t1
  ON
    t1.patientunitstayid=pt.patientunitstayid
  LEFT JOIN
    t2
  ON
    t2.patientunitstayid=pt.patientunitstayid
  LEFT JOIN
    t3
  ON
    t3.patientunitstayid=pt.patientunitstayid )
SELECT
  patientunitstayid,
  MAX(mechvent_day01) AS mechvent_day01
FROM
  sq
GROUP BY
  patientunitstayid
ORDER BY
  patientunitstayid
