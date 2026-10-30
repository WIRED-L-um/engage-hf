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

The SAS programs are in [`code/`](./code/). The supplied data sets are in [`data/`](./data/). The table shows how each program relates to its data sets. Before running the programs, configure the `OUT` library to point to the study data and replace the `<path>` placeholders with valid locations for included macros and output files.

The following required input data sets are **not supplied**:

- `MED_FOLLOWUP`: follow-up medication data required by [`analyze_medications.sas`](./code/analyze_medications.sas). The program expects this data set to exist before execution; it does not create it.
- `out.score_long`: additional medication-score data required by [`analyze_additional_scores.sas`](./code/analyze_additional_scores.sas). The program uses this input to create `out.score_wide`, which is a derived output rather than a separate required input.

These programs cannot run from start to finish using only the supplied data sets.

| SAS program                                                                   | Associated data sets                                               | Analysis or role                                                                                                                                      |
| ----------------------------------------------------------------------------- | ------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`prepare_baseline_table.sas`](./code/prepare_baseline_table.sas) | Reads and updates `demographics_baseline` | Prepares baseline demographic and clinical variables, including medication target-dose measures, and generates the manuscript's baseline Table 1. |
| [`analyze_medications.sas`](./code/analyze_medications.sas) | `demographics_baseline` + `MED_FOLLOWUP` → `medications_analysis` | Combines baseline and follow-up medication data, calculates C4P scores, and analyzes score changes using restricted cubic splines. |
| [`analyze_mos.sas`](./code/analyze_mos.sas) | `mos_analysis` | Performs the primary Medication Optimization Score (MOS) analysis, including summaries and spline-based primary and sensitivity analyses. |
| [`analyze_kccq.sas`](./code/analyze_kccq.sas) | `kccq_followup` (90-day follow-up) + `demographics_baseline` → `kccq_analysis` | Analyzes the KCCQ-23 clinical summary score and quality-of-life subscores with spline-based models. |
| [`analyze_additional_scores.sas`](./code/analyze_additional_scores.sas) | `score_long` → `score_wide` | Summarizes and examines correlations and spline-based analyses for additional scores, including HFC, KCMO, QTO, OPS, and Kresoja measures. |
| [`analyze_adverse_events.sas`](./code/analyze_adverse_events.sas) | Reads and updates `adverse_events`; also uses `demographics_baseline` | Analyzes 90-day all-cause mortality, hospitalization, ED visits, and outpatient intravenous diuresis, including time-to-event and composite outcomes. |
| [`macro_table.sas`](./code/macro_table.sas) | Used by the demographic, medication, MOS, and AE programs | Shared `%Table` macro for producing demographic and bivariate summary tables; it does not create a study data set. |
