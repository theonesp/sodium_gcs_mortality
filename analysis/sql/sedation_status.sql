-- The script utilizes various subqueries to calculate the sedation status of patients in an ICU.
-- This SQL query analyzes ICU patient sedation status by combining laboratory, 
-- medication, and nursing chart data from the eICU Collaborative Research Database. 
-- It first determines baseline sodium levels to establish a temporal context. 
-- Then, it identifies sedative medication and infusion administrations relative to the sodium baseline. 
-- Ordered medications and infusions are constrained BETWEEN 0 AND 24 hours of the sodium_baseline_offset
-- It also evaluates nursing chart sedation scores near the time of the earliest Glasgow Coma Scale (GCS) measurement. 
-- Finally, it categorizes patients into 'Sedated by Med', 'Not sedated by Med', or 'Suspected error', 
-- based on a comparison between administered sedatives and observed sedation scores.
-- Final categories are:
-- "Sedated by Med": Score = sedated AND meds = sedated.
-- "Not sedated by Med": meds = not sedated.
-- "Suspected error": meds = sedated AND score = not sedated.

WITH
  tempo AS (
  SELECT
    patientunitstayid,
    labname,
    labresultoffset,
    labresult,
    ROW_NUMBER() OVER (PARTITION BY patientunitstayid, labname ORDER BY labresultoffset ASC) AS position
  FROM
    `physionet-data.eicu_crd.lab`
  WHERE
    LOWER(labname) = 'sodium'
    AND labresultoffset BETWEEN -12*60 AND 12*60 ),
  sodium_baseline AS(
  SELECT
    patientunitstayid,
    MAX(CASE
        WHEN LOWER(labname) = 'sodium' AND position = 1 THEN labresult
      ELSE
      NULL
    END
      ) AS sodium_baseline,
    MAX(CASE
        WHEN LOWER(labname) = 'sodium' AND position = 1 THEN labresultoffset
      ELSE
      NULL
    END
      ) AS sodium_baseline_offset
  FROM
    tempo
  GROUP BY
    patientunitstayid ),
  medications AS (
  SELECT
    m.patientunitstayid,
    CASE
      WHEN LOWER(m.drugname) LIKE '%propo%' THEN 'Propofol'
      WHEN LOWER(m.drugname) LIKE '%mida%' THEN 'Midazolam'
      WHEN LOWER(m.drugname) LIKE '%lora%' THEN 'Lorazepam'
    ELSE
    'Other'
  END
    AS drug_group
  FROM
    `physionet-data.eicu_crd.medication` m
  WHERE
    (LOWER(m.drugname) LIKE '%propo%'
      OR LOWER(m.drugname) LIKE '%mida%'
      OR LOWER(m.drugname) LIKE '%lora%')
    AND EXISTS (
    SELECT
      1
    FROM
      sodium_baseline
    WHERE
      sodium_baseline.patientunitstayid = m.patientunitstayid
      AND ABS(sodium_baseline_offset - m.drugstartoffset) BETWEEN -12*60 AND 24*60 ) ), --we relaxed the time window to include neg offset in the order
  infusions AS (
  SELECT
    i.patientunitstayid,
    CASE
      WHEN LOWER(i.drugname) LIKE '%propo%' THEN 'Propofol'
      WHEN LOWER(i.drugname) LIKE '%mida%' THEN 'Midazolam'
      WHEN LOWER(i.drugname) LIKE '%lora%' THEN 'Lorazepam'
    ELSE
    'Other'
  END
    AS drug_group
  FROM
    `physionet-data.eicu_crd.infusiondrug` i
  WHERE
    (LOWER(i.drugname) LIKE '%propo%'
      OR LOWER(i.drugname) LIKE '%mida%'
      OR LOWER(i.drugname) LIKE '%lora%')
    AND EXISTS (
    SELECT
      1
    FROM
      sodium_baseline
    WHERE
      sodium_baseline.patientunitstayid = i.patientunitstayid
      AND ABS(sodium_baseline_offset - i.infusionoffset) BETWEEN -12*60 AND 24*60 ) ), --we relaxed the time window to include neg offset in the order
  sq1 AS(
  SELECT
    patientunitstayid,
    gcs AS gcs_baseline,
    gcs_motor AS gcs_motor_baseline,
    gcs_verbal AS gcs_verbal_baseline,
    gcs_eyes AS gcs_eyes_baseline,
    chartoffset,
    ROW_NUMBER() OVER (PARTITION BY patientunitstayid ORDER BY COALESCE (chartoffset) ASC) AS rn
  FROM
    `physionet-data.eicu_crd_derived.pivoted_score`
  WHERE
    chartoffset BETWEEN -6*24 AND 24*60
    AND gcs IS NOT NULL
    AND gcs_motor IS NOT NULL
    AND gcs_verbal IS NOT NULL
    AND gcs_eyes IS NOT NULL ),
  sq2 AS(
  SELECT
    patientunitstayid,
    chartoffset AS gcs_offset
  FROM
    sq1
  WHERE
    rn = 1
  ORDER BY
    patientunitstayid ),
  sq3 AS(
  SELECT
    sq2.patientunitstayid,
    nursingchartoffset,
    gcs_offset,
    CASE
      WHEN nursingchartvalue IN ('-1', '-2', '-3', '-4', '-5') THEN 'Sedated'
      WHEN nursingchartvalue IN ('0', '00','01', '1') THEN 'Not Sedated'
      WHEN nursingchartvalue IN ('2', '3', '4', '5', '6', '7') THEN 'Exclude'
    ELSE
    NULL
  END
    AS sedation_status,
    ROW_NUMBER() OVER (PARTITION BY sq2.patientunitstayid ORDER BY ABS(nursingchartoffset - gcs_offset) ASC) AS rn
  FROM
    sq2
  JOIN
    physionet-data.eicu_crd.nursecharting
  USING
    (patientunitstayid)
  WHERE
    nursingchartcelltypevalname = 'Sedation Score'
  ORDER BY
    sq2.patientunitstayid, rn ),
    med_sedation_status AS (
  SELECT 
    patientunitstayid,
    'Sedated by Med' AS sedation_category
  FROM
    medications
  UNION DISTINCT
  SELECT 
    patientunitstayid,
    'Sedated by Med' AS sedation_category
  FROM
    infusions
),
nursing_sedation AS (
  SELECT
    sq3.patientunitstayid,
    CASE
      WHEN sedation_status = 'Sedated' THEN 'Sedated'
      WHEN sedation_status = 'Not Sedated' THEN 'Not Sedated'
    END AS nursing_sedation_status
  FROM
    sq3
  WHERE
    rn = 1
),
combined_sedation AS (
  SELECT 
    n.patientunitstayid,
    m.sedation_category,
    n.nursing_sedation_status
  FROM
    nursing_sedation n
    LEFT JOIN med_sedation_status m ON n.patientunitstayid = m.patientunitstayid
),
final_sedation_status AS (
  SELECT
    patientunitstayid,
    CASE
      WHEN sedation_category IS NOT NULL AND nursing_sedation_status = 'Sedated' THEN 'Sedated by Med'
      WHEN sedation_category IS NULL THEN 'Not sedated by Med'
      WHEN sedation_category IS NOT NULL AND nursing_sedation_status = 'Not Sedated' THEN 'Suspected error'
    ELSE 'Uncategorized'
    END AS final_sedation_category
  FROM
    combined_sedation
),

-- This final SELECT combines everything together and utilizes the final_sedation_status for categorization <----!!!!
final_output AS (
  SELECT 
    p.patientunitstayid,
    COALESCE(f.final_sedation_category, 'Not sedated by Med') AS sedation_status
  FROM
    `physionet-data.eicu_crd.patient` p
    LEFT JOIN final_sedation_status f ON p.patientunitstayid = f.patientunitstayid
)
SELECT * FROM final_output;
