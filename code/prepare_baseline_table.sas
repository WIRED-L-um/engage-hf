/** ==================================================================================== 
/** ================================== ENGAGE-HF Study ================================= 
    ========== There are two study arms : variable name is randomization
    ========== 1. Intervention & 2. Control ============================================
    ========== It is a multi center study : 3 centers
               1='Johns Hopkins University' 
               2='Stanford University' 
		       3='University of Michigan'
/** ==================================================================================== **/

proc format;
value study_site_ 
1='Johns Hopkins University' 
2='Stanford University' 
3='University of Michigan'; 

value 	race 1="White"
	2="African American or Black"
	3="Asian"
	4="American Indian or Alaska Indian"
	5="Native Hawaiian"
	6="Unknown";
run;




data out.demographics_baseline;
set out.demographics_baseline;

length etiology_class $20. ;

/** missing or unknown etiology category **/
if etiology in ("Non-ischemic", "Ischemic") then etiology_class=etiology;
else etiology_class="Missing/unknown";

/** 2 or more HF hospitalization **/

if hf_hospitalization ge 2 then hf_hosp=2;
else hf_hosp=hf_hospitalization;

if ace_name in ("Valsartan/sacubitril (Entresto)") then ARNA=1;
else ARNA=0; 

/* ACEi/ARB Target dose */
 if ace_name in ("Lisinopril (Zestril or Prinivil)","enalapril","Olmesartan (Benicar)") 
then ace_Target_dose=100*ace_dose/20;
else if ace_name in ('Trandolapril (Mavik)') then ace_Target_dose=100*ace_dose/4;
else if ace_name in ('Captopril (Capoten)') then ace_Target_dose=100*ace_dose/150;
else if ace_name in ('Benazepril (Lotensin)','Quinapril (Accupril)',
'Telmisartan (Micardis)','Fosinopril (Monopril)') then ace_Target_dose=100*ace_dose/40;
else if ace_name in ('Ramipril (Altace)') then ace_Target_dose=100*ace_dose/10;
else if ace_name in ("Losartan (Cozaar)") then ace_Target_dose=100*ace_dose/150;
else if ace_name in ('Candasartan (Atacand)') then ace_Target_dose=100*ace_dose/32;
else if ace_name in ("Valsartan (Diovan)") then ace_Target_dose=100*ace_dose/320;
else if ace_name in ('Irbesartan (Avapro)') then ace_Target_dose=100*ace_dose/300;
else ace_Target_dose=.;


/* ACEi/ARB/ARNA Target dose */

if ace_name in ("Valsartan/sacubitril (Entresto)") then mace_Target_dose=100*ace_dose/400; 
 else if ace_name in ("Lisinopril (Zestril or Prinivil)","enalapril","Olmesartan (Benicar)") 
then mace_Target_dose=100*ace_dose/20;
else if ace_name in ('Trandolapril (Mavik)') then mace_Target_dose=100*ace_dose/4;
else if ace_name in ('Captopril (Capoten)') then mace_Target_dose=100*ace_dose/150;
else if ace_name in ('Benazepril (Lotensin)','Quinapril (Accupril)',
'Telmisartan (Micardis)','Fosinopril (Monopril)') then mace_Target_dose=100*ace_dose/40;
else if ace_name in ('Ramipril (Altace)') then mace_Target_dose=100*ace_dose/10;
else if ace_name in ("Losartan (Cozaar)") then mace_Target_dose=100*ace_dose/150;
else if ace_name in ('Candasartan (Atacand)') then mace_Target_dose=100*ace_dose/32;
else if ace_name in ("Valsartan (Diovan)") then mace_Target_dose=100*ace_dose/320;
else if ace_name in ('Irbesartan (Avapro)') then mace_Target_dose=100*ace_dose/300;
else mace_Target_dose=.;

/* Beta Target dose */

if beta_name in ('Bisoprolol') then beta_Target_dose=100*beta_dose/10;
else if beta_name in ('Carvedilol','Carvedilol phosphate') then beta_Target_dose=100*beta_dose/50;
else if beta_name in ('Metoprolol succinate','Metoprolol tartrate') then beta_Target_dose=100*beta_dose/200;
else beta_Target_dose=.;

/* ARNA Target dose */

if ace_name in ("Valsartan/sacubitril (Entresto)") then ARNA_Target_dose=100*ace_dose/400;
else ARNA_Target_dose=.; 

/** ============ more than 100 was imputed to 100 ========= **/
if ace_Target_dose ge 100 then ace_Target_dose_PCT=100;
else ace_Target_dose_PCT=ace_Target_dose;

/** ============ more than 100 was imputed to 100 ========= **/
if beta_Target_dose ge 100 then beta_Target_dose_PCT=100;
else beta_Target_dose_PCT=beta_Target_dose;


/** ============ more than 100 was imputed to 100 ========= **/
if mace_Target_dose ge 100 then mace_Target_dose=100;
else mace_Target_dose=mace_Target_dose;
run;


/** ======================================================= **/
/** ======== Generating Table 1 for the manuscript ======== **/
/** ================= Stratified by Study Arms ============ **/

data mcom;
    length level $150
           pvalue $17
           ci c1 c2 ctotal $40;

    nvar=1;  _line=0.5; level="Age (years)";                                   pvalue=" "; output;
    nvar=2;  _line=0.5; level="Gender";                                pvalue=" "; output;
    nvar=3;  _line=0.5; level="Hispanic or Latino";                    pvalue=" "; output;
    nvar=4;  _line=0.5; level="Education";                             pvalue=" "; output;
    nvar=5;  _line=0.5; level="NYHA class";                            pvalue=" "; output;
    nvar=6;  _line=0.5; level="eGFR";                                  pvalue=" "; output;
    nvar=7;  _line=0.5; level="Creatinine";                            pvalue=" "; output;
    nvar=8;  _line=0.5; level="Potassium";                             pvalue=" "; output;
    nvar=9;  _line=0.5; level="Sodium";                                pvalue=" "; output;
    nvar=10; _line=0.5; level="Blood urea nitrogen";                   pvalue=" "; output;
    nvar=11; _line=0.5; level="Ejection fraction";                     pvalue=" "; output;
    nvar=12; _line=0.5; level="Predominant etiology of heart failure"; pvalue=" "; output;
    nvar=13; _line=0.5; level="Heart rate";                             pvalue=" "; output;
    nvar=14; line=0.5;  level="Resting DBP";                            pvalue=" "; output;
    nvar=15; line=0.5;  level="Resting SBP";                            pvalue=" "; output;
    nvar=16; _line=0.5; level="ACEi/ARB";                              pvalue=" "; output;
    nvar=17; _line=0.5; level="Beta";                                  pvalue=" "; output;
    nvar=18; line=0.5;  level="Loop";                                  pvalue=" "; output;
    nvar=19; line=0.5;  level="sglt2";                                 pvalue=" "; output;
    nvar=20; line=0.5;  level="Thiazide";                              pvalue=" "; output;
    nvar=21; line=0.5;  level="ACEi/ARB Target dose (PCT)";            pvalue=" "; output;
    nvar=22; line=0.5;  level="Beta Blocker Target dose (PCT)";        pvalue=" "; output;
    nvar=23; _line=0.5; level="HF hospitalization";                    pvalue=" "; output;
    nvar=24; line=0.5;  level="Depression";                            pvalue=" "; output;
    nvar=25; line=0.5;  level="Diabetes";                              pvalue=" "; output;
    nvar=26; line=0.5;  level="Hypertension";                          pvalue=" "; output;
    nvar=27; line=0.5;  level="Stroke";                                pvalue=" "; output;
    nvar=28; _line=0.5; level="Sleep Apnea";                           pvalue=" "; output;
    nvar=29; line=0.5;  level="Peripheral edema";                      pvalue=" "; output;
    nvar=30; _line=0.5; level="Lipid";                                 pvalue=" "; output;
    nvar=31; _line=0.5; level="Cancer";                                pvalue=" "; output;
    nvar=32; _line=0.5; level="AF";                                    pvalue=" "; output;
    nvar=33; _line=0.5; level="VTACH";                                 pvalue=" "; output;
    nvar=34; line=0.5;  level="k23 Clinical Summary Score";            pvalue=" "; output;
    nvar=35; line=0.5;  level="k23 Overall summary score";             pvalue=" "; output;
    nvar=36; line=0.5;  level="k23 Physical Limitation Score";         pvalue=" "; output;
    nvar=37; line=0.5;  level="k23 Quality of Life Score";             pvalue=" "; output;
    nvar=38; line=0.5;  level="k23 Self-efficacy Score";               pvalue=" "; output;
    nvar=39; line=0.5;  level="k23 Social Limitation Score";           pvalue=" "; output;
    nvar=40; line=0.5;  level="k23 Symptom Burden Score";              pvalue=" "; output;
    nvar=41; line=0.5;  level="k23 Symptom Frequency Score";           pvalue=" "; output;
    nvar=42; line=0.5;  level="k23 Symptom Stability Score";           pvalue=" "; output;
    nvar=43; line=0.5;  level="k23 Total Symptom Score";               pvalue=" "; output;
    nvar=44; line=0.5;  level="Study Site";                             pvalue=" "; output;
    nvar=45; line=0.5;  level="Weight (lb)";                            pvalue=" "; output;
    nvar=46; line=0.5;  level="Height (inches)";                        pvalue=" "; output;
    nvar=47; line=0.5;  level="CKD stage";                              pvalue=" "; output;
    nvar=48; line=0.5;  level="Index los";                              pvalue=" "; output;
    nvar=49; line=0.5;  level="Race";                                   pvalue=" "; output;
    nvar=50; line=0.5;  level="nyha k23";                               pvalue=" "; output;
    nvar=51; line=0.5;  level="MRA";                                    pvalue=" "; output;
    nvar=52; line=0.5;  level="ARNA";                                   pvalue=" "; output;
    nvar=53; line=0.5;  level="ARNA Target Score";                      pvalue=" "; output;
    nvar=54; line=0.5;  level="ACEi/ARB/ARNA Target Score";             pvalue=" "; output;
run;


%let today_macro = %sysfunc(today(), date9.);


proc sort data=out.demographics_baseline;
by randomization;
run;
/** Please include your path to the data forlder */

%Include '<path>\macro_table.sas';
%Table(dsn=out.demographics_baseline,
var =
age
sex
is_race_hispanic_or_latino
education
nyha
ckd_stage_value
creatinine 
potassium 
sodium  
blood_urea_nitrogen
ejection_fraction
etiology_class
heart_rate
resting_dbp
resting_sbp
ace beta  loop
sglt2 thiazide 
Ace_Target_dose_PCT
beta_Target_dose_PCT 
hf_hosp
depression
diabetes
htn
stroke
sleep_apnea 
peripheral_edema
lipid
cancer
afib_flutt
vtach
k23_clinsummary
 k23_overallsummary
 k23_physlimit
 k23_qol
k23_selfefficacy
k23_soclimit
 k23_sympburden
 k23_sympfreq
k23_sympstability
 k23_totalsymp
study_site 
weight_pounds
height_inches
ckd_stage_code
index_los
race_ethnicity
nyha_k23
aldo
ARNA
ARNA_Target_dose
mace_Target_dose,
by=randomization,
type= c d d d d c c c c c c d c c c d d d d d 
      c c d d d d d d d d d d d c c c c c c c
      c c c d c c d c d d d d c c,
ptype= te ch ch ch ch te te te te te te ch te te te ch ch ch ch ch
       te te ch ch ch ch ch ch ch  ch ch ch te te te te te te te te  
	   te te te ch te te ch te ch ch ch ch te te,
labelwrap=y,
outdoc=<path>\Table1_&today_macro.rtf,
meandec=2,
comments=mcom,
dvar= 1 1 2 3 4 5 6 6 7 7 8 8 9 9 10 10	11 11 12 13 13	14 14 15 15	16 16 17 17 18 18 19 19 20 20 21 21 22 22
23	24 24 25 25	26 26 27 27 28 28 29 29 30 30 31 31 32 32 33 33 34 34 35 35 36 36 37 37 38 38 39 39 40 40
41 41 42 42 43 43 44 45 45 46 46 47 47 48 48 49 49 50 50 51 51 52 53 53 54 54 ,
dline=1 2 1 1 1 1 1 2 1 2 1	2 1	2 1	2 
1 2 1 2	1 2	1	2 1	2 1	2 1 2  1 2	1 2	1
1 2 1	2 1 1	2 1	2 1	2 1	2 1	2 1	2 1 2
1 2	1 2	1 2 1 2	1 2	1 2	1 2	1 2	1 2	1 2
1 2	1 2	1 2	1 2	1 2	1 2	1 2	1 2	
1	2 1 2 1 1 2	1	1 1 2 1 2 1 2,
ttitle1=Demographics of the participants in the ENGAGE-HF study); 


