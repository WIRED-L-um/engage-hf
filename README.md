# ENGAGE-HF Study

The ENGAGE-HF study was a two-armed, multicenter randomized clinical trial. The trial evaluated the efficacy of a technology-based platform for heart failure disease management following a recent hospitalization. The ENGAGE-HF study was a two-armed, multicenter randomized clinical trial. The study was conducted across three academic medical centers: Johns Hopkins Health, University of Michigan Health, and Stanford Medicine. The trial evaluated the efficacy of a technology-based platform for HF disease management following a recent hospitalization.

## Outcome Measures

### Primary Outcome

The primary outcome was the difference in the Medication Optimization Score (MOS) at 90 days between the intervention and control groups.

### Secondary Outcome

The secondary outcome was the difference in heart failure-related quality of life, assessed by the 23-item Kansas City Cardiomyopathy Questionnaire (KCCQ-23) clinical summary score (CSS) at 90 days.

### Exploratory Outcomes

Exploratory outcomes include all-cause mortality, HF hospitalizations, Emergency Department visits, and other published measures of GDMT medication use.

## SAS Analysis Files and Data Sets

The SAS programs are in [`code/`](./code/). The data sets are in [`data/`](./data/). The table shows how each program relates to its data sets. Before running the programs, configure the `OUT` library to point to the study data and replace the `<path>` placeholders with valid locations for included macros and output files.

| SAS program                                                                   | Associated data sets                                               | Analysis or role                                                                                                                                      |
| ----------------------------------------------------------------------------- | ------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`Demographic_Engage_HF.sas`](./code/Demographic_Engage_HF.sas)               | Reads and updates `demographic_june`                               | Prepares baseline demographic and clinical variables, including medication target-dose measures, and generates the manuscript's baseline Table 1.     |
| [`Medication_Engage_HF.sas`](./code/Medication_Engage_HF.sas)                 | `demographic_june` + `MED_FOLLOWUP` → `med_Engagehf`               | Combines baseline and follow-up medication data, calculates C4P scores, and analyzes score changes using restricted cubic splines.                    |
| [`Engage-HF_Analysis.sas`](./code/Engage-HF_Analysis.sas)                     | `MOS_July_Final`                                                   | Performs the primary Medication Optimization Score (MOS) analysis, including summaries and spline-based primary and sensitivity analyses.             |
| [`Engage-HF_Secondary-Analysis.sas`](./code/Engage-HF_Secondary-Analysis.sas) | `KCCQ2` (90-day follow-up) + `demographic_june` → `kccq_base_june` | Analyzes the KCCQ-23 clinical summary score and quality-of-life subscores with spline-based models.                                                   |
| [`Other_Scores_Engage_HF.sas`](./code/Other_Scores_Engage_HF.sas)             | `score_long` → `score_wide`                                        | Summarizes and examines correlations and spline-based analyses for additional scores, including HFC, KCMO, QTO, OPS, and Kresoja measures.            |
| [`AE_Engage_HF.sas`](./code/AE_Engage_HF.sas)                                 | Reads and updates `AE_final`; also uses `demographic_june`         | Analyzes 90-day all-cause mortality, hospitalization, ED visits, and outpatient intravenous diuresis, including time-to-event and composite outcomes. |
| [`table.sas`](./code/table.sas)                                               | Used by the demographic, medication, MOS, and AE programs          | Shared `%Table` macro for producing demographic and bivariate summary tables; it does not create a study data set.                                    |
