/** ================================== ENGAGE-HF Study ================================= 
    ========== There are two study arms : variable name is randomization
    ========== 1. Intervention & 2. Control ============================================
    ========== It is a multi center study : 3 centers
               1='Johns Hopkins University' 
               2='Stanford University' 
		       3='University of Michigan'
/** ==================================================================================== **/
/** ============== Medication at the Baseline & Followup ============================== **/
/** ============== C4P_score calculation =============================================== **/

/** =================================================================================== **/
OPTIONS nofmterr;

proc format;
value study_site_ 1='Johns Hopkins University' 2='Stanford University' 
		3='University of Michigan'; 
value 	race 1="White"
	2="African American or Black"
	3="Asian"
	4="American Indian or Alaska Indian"
	5="Native Hawaiian"
	6="Unknown";

	value grp 0="Unprescribed"
	1="<50%"
	2="50 to <100%"
	3="100%";

	value mgrp 0="Unprescribed"
	1="<50%"
	2="50 to 100%";
	value med 1="Beta Blocker"
  2="ARNA"
 3="ACEi/ARB";
run;

/** =============== Data Mining Steps ============================= **/
/*NOTE: WORK.MED_FOLLOWUP data set was successfully created.
NOTE: The data set WORK.MED_FOLLOWUP has 170 observations and 27 variables.
*/

proc sort data=out.demographics_baseline ;
by record_ID;
run;

proc sort data=MED_FOLLOWUP ;
by record_ID;
run;


data demo;
set out.demographics_baseline;
hydralazine1=hydralazine;
ace1=ace;
beta1=beta;
loop1=loop;
sglt21=sglt2;
thiazide1= thiazide;
ARNA1=ARNA;
aldo1=aldo;
hydralazine1=hydralazine ;
aldo_dose1=aldo_dose;
ace_dose1=ace_dose;
beta_dose1=beta_dose;
loop_dose1=loop_dose;
sglt2_dose1=sglt2_dose;
thiazide_dose1=thiazide_dose;
if arna=1 then arna_dose1=ace_dose;

/** Baseline target dose **/

Ace_Target_dose_PCT1=Ace_Target_dose_PCT;
beta_Target_dose_PCT1= beta_Target_dose_PCT;
 ARNA_Target_dose_PCT1=ARNA_Target_dose;

keep record_ID randomization hydralazine1
study_site aldo1 ace1 beta1  loop1
sglt21 thiazide1 ARNA1 hydralazine1 
ace beta  loop aldo
sglt2 thiazide  aldo
mace_Target_dose /** mace_Target_dose=baseline ACEi/ARB/ARNI */
Ace_Target_dose_PCT1 /** Ace_Target_dose_PCT1=baseline ACEi/ARB */
beta_Target_dose_PCT1 
ARNA_Target_dose_PCT1
Ace_Target_dose_PCT
beta_Target_dose_PCT 
aldo_dose1
Ace_dose1
beta_dose1 
ARNA_dose1
sglt2_dose1
thiazide_dose1 study_site  age sex study_site resting_sbp ckd_stage_value;
run;


data demo;
set  demo;
drop ace beta  loop aldo
sglt2 ARNA thiazide Ace_Target_dose_PCT
beta_Target_dose_PCT ARNA_Target_dose hydralazine
aldo_dose
Ace_dose
beta_dose 
ARNA_dose
sglt2_dose
thiazide_dose ;
run;


data Med_June;
merge DEMO(in=a) MED_FOLLOWUP(in=b);
by record_ID;
if a=1 then output;
run;

/*NOTE: MERGE statement has more than one data set with repeats of BY values.
NOTE: There were 134 observations read from the data set DEMO.
NOTE: There were 170 observations read from the data set WORK.MED_FOLLOWUP.
NOTE: The data set WORK.MED_JUNE has 134 observations and 99 variables.
NOTE: DATA statement used (Total process time):
      real time           0.85 seconds
      cpu time            0.00 seconds
*/


data med_June;
set med_June;

if ARNA=1 then ARNA_dose=ace_dose;
else ARNA_dose=0;
if hydralazine1='' then mhydralazine1="False";
else mhydralazine1="True";
mhydralazine=hydralazine;

/** the target dose acei/ARB/ARNA Target_dose follow up*/

 if ace_name in ("Valsartan/sacubitril (Entresto)") then ace_Target_dose=100*ace_dose/400; 
else if ace_name in ("Lisinopril (Zestril or Prinivil)","enalapril","Olmesartan (Benicar)") 
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

/** the target dose acei/ARB Target_dose follow up*/

if ace_name in ("Lisinopril (Zestril or Prinivil)","enalapril","Olmesartan (Benicar)") 
then pace_Target_dose=100*ace_dose/20;
else if ace_name in ('Trandolapril (Mavik)') then pace_Target_dose=100*ace_dose/4;
else if ace_name in ('Captopril (Capoten)') then pace_Target_dose=100*ace_dose/150;
else if ace_name in ('Benazepril (Lotensin)','Quinapril (Accupril)',
'Telmisartan (Micardis)','Fosinopril (Monopril)') then pace_Target_dose=100*ace_dose/40;
else if ace_name in ('Ramipril (Altace)') then pace_Target_dose=100*ace_dose/10;
else if ace_name in ("Losartan (Cozaar)") then pace_Target_dose=100*ace_dose/150;
else if ace_name in ('Candasartan (Atacand)') then pace_Target_dose=100*ace_dose/32;
else if ace_name in ("Valsartan (Diovan)") then pace_Target_dose=100*ace_dose/320;
else if ace_name in ('Irbesartan (Avapro)') then pace_Target_dose=100*ace_dose/300;
else pace_Target_dose=.;



if beta_name in ('Bisoprolol') then beta_Target_dose=100*beta_dose/10;
else if beta_name in ('Carvedilol','Carvedilol phosphate') then beta_Target_dose=100*beta_dose/50;
else if beta_name in ('Metoprolol succinate','Metoprolol tartrate') then beta_Target_dose=100*beta_dose/200;
else beta_Target_dose=.;

if ace_name in ("Valsartan/sacubitril (Entresto)") then ARNA=1;
else ARNA=0; 

/** ARNA only target dose **/
if ace_name in ("Valsartan/sacubitril (Entresto)") then ARNA_Target_dose=100*ace_dose/400;
else ARNA_Target_dose=.; 

/** imputing extreme target dose to 100 Percent ACEi/ARB/ARNI all **/
if ace_Target_dose ge 100 then ace_Target_dose_PCT=100;
else ace_Target_dose_PCT=ace_Target_dose;
/** imputing extreme target dose to 100 Percent ACEi/ARB Target Dose **/

if pace_Target_dose ge 100 then pace_Target_dose_PCT=100;
else pace_Target_dose_PCT=pace_Target_dose;


/** imputing extreme target dose to 100 **/

if beta_Target_dose ge 100 then beta_Target_dose_PCT=100;
else beta_Target_dose_PCT=beta_Target_dose;
/** imputing extreme target dose to 100 **/

if ARNA_Target_dose ge 100 then ARNA_Target_dose_PCT=100;
else ARNA_Target_dose_PCT=ARNA_Target_dose;

run;

/** =============== Data saved for the Analysis =================== **/
data out.medications_analysis;
set med_june;

/** C4P_score calculation **/
/** start **/
if ACE1="True" then ACEscore1=2+2*Ace_Target_dose_PCT1/100;
else  ACEscore1=0;


if beta1="True" then BBscore1=2+(2*beta_Target_dose_PCT1/100);
else BBscore1=0;



if sglt21="True" then SGscore1=2+2*(sglt2_dose1/100);
else  SGscore1=0;


if ARNA1=1 then ARscore1=4+2*(ARNA_Target_dose_PCT1/100);
else  ARscore1=0;

/** end **/
if ACE="True" then ACEscore=2+2*pace_Target_dose/100;
else  ACEscore=0;
if beta="True" then BBscore=2+2*beta_Target_dose_PCT/100;
else  BBscore=0;
if sglt2="True" then SGscore=2+2*sglt2_dose/100;
else  SGscore=0;
if ARNA=1 then ARscore=4+2*ARNA_Target_dose_PCT/100;
else ARscore=0;


if ARNA_Target_dose_PCT=. then ARNA_GRP=0;
else if 0<=ARNA_Target_dose_PCT<50 then ARNA_GRP=1;
else if 50<=ARNA_Target_dose_PCT<100 then ARNA_GRP=2;
else if ARNA_Target_dose_PCT=100 then ARNA_GRP=3;

if Beta_Target_dose_PCT=. then Beta_GRP=0;
else if 0<=Beta_Target_dose_PCT<50 then Beta_GRP=1;
else if 50<=Beta_Target_dose_PCT<100 then Beta_GRP=2;
else if Beta_Target_dose_PCT=100 then Beta_GRP=3;

if ACE_Target_dose_PCT=. then ACE_GRP=0;
else if 0<=ACE_Target_dose_PCT<50 then ACE_GRP=1;
else if 50<=ACE_Target_dose_PCT<100 then ACE_GRP=2;
else if ACE_Target_dose_PCT=100 then ACE_GRP=3;

if ARNA_Target_dose_PCT1=. then ARNA_GRP1=0;
else if 0<=ARNA_Target_dose_PCT1<50 then ARNA_GRP1=1;
else if 50<=ARNA_Target_dose_PCT1<100 then ARNA_GRP1=2;
else if ARNA_Target_dose_PCT1=100 then ARNA_GRP1=3;

if Beta_Target_dose_PCT1=. then Beta_GRP1=0;
else if 0<=Beta_Target_dose_PCT1<50 then Beta_GRP1=1;
else if 50<=Beta_Target_dose_PCT1<100 then Beta_GRP1=2;
else if Beta_Target_dose_PCT1=100 then Beta_GRP1=3;

if ACE_Target_dose_PCT1=. then ACE_GRP1=0;
else if 0<=ACE_Target_dose_PCT1<50 then ACE_GRP1=1;
else if 50<=ACE_Target_dose_PCT<100 then ACE_GRP1=2;
else if ACE_Target_dose_PCT=100 then ACE_GRP1=3;

format ACE_GRP Beta_GRP ARNA_GRP ACE_GRP1 Beta_GRP1 ARNA_GRP1 grp.;
run;



data out.medications_analysis;
set  out.medications_analysis;

if ACEscore=. then ACEscore=0;
if  BBscore=. then  BBscore=0;
if SGscore=. then SGscore=0;
if ARscore=. then ARscore=0;
if ACEscore1=. then ACEscore1=0;
if  BBscore1=. then BBscore1=0;
if SGscore1=. then SGscore1=0;
if ARscore1=. then ARscore1=0;

C4P_score= ACEscore+ BBscore+SGscore+ARscore;
C4P_score1= ACEscore1+ BBscore1+SGscore1+ARscore1;

run;


/** ================================================================== **/
/** ====================== Table by study Arms ======================= **/
/** ================================================================== **/

%let today_macro = %sysfunc(today(), date9.);

data pcom;
 length level $ 150
 pvalue $ 17
 ci c1 c2 ctotal $ 40;
 nvar=1; line=0.5; level='ACEi/ARB Baseline'; pvalue=''; output;
 nvar=2; line=0.5; level='Beta Blocker Baseline'; pvalue=''; output;
 nvar=3;   line=0.5; level='Loop Baseline'; pvalue=''; output;
 nvar=4;   line=0.5; level='sglt2 Baseline'; pvalue=''; output;
 nvar=5;   line=0.5; level='Thiazide Baseline'; pvalue=''; output;
 nvar=6;   line=0.5; level='ARNI Baseline'; pvalue=''; output;
 nvar=7;   line=0.5; level='MRA Baseline'; pvalue=''; output;
 nvar=8; line=0.5; level='ACEi/ARB'; pvalue=''; output;
 nvar=9; line=0.5; level='Beta Blocker'; pvalue=''; output;
 nvar=10;   line=0.5; level='Loop'; pvalue=''; output;
 nvar=11;   line=0.5; level='sglt2'; pvalue=''; output;
 nvar=12;   line=0.5; level='Thiazide'; pvalue=''; output;
 nvar=13;   line=0.5; level='ARNI'; pvalue=''; output;
 nvar=14;   line=0.5; level='MRA'; pvalue=''; output;
 nvar=15;   line=0.5; level='ACEi/ARB/ARNA Target dose (PCT) Baseline'; pvalue=''; output;
 nvar=16;   line=0.5; level='ACEi/ARB Target dose (PCT) Baseline'; pvalue=''; output;
 nvar=17;   line=0.5; level='Beta Blocker Target dose (PCT) Baseline'; pvalue=''; output;
 nvar=18;   line=0.5; level='ARNI Target dose (PCT) Baseline'; pvalue=''; output;
 nvar=19;   line=0.5; level='ACEi/ARB/ARNA Target dose (PCT) '; pvalue=''; output;
 nvar=20;   line=0.5; level='ACEi/ARB Target dose (PCT) '; pvalue=''; output;
 nvar=21;   line=0.5; level='Beta Blocker Target dose (PCT)'; pvalue=''; output;
 nvar=22;   line=0.5; level='ARNI Target dose (PCT) '; pvalue=''; output;

run;

/* Insert your path */
%Include '<path>\macro_table.sas';
%Table(dsn=out.medications_analysis,
var =
ace1 beta1  loop1
sglt21 thiazide1 arna1 aldo1
ace beta  loop
sglt2 thiazide arna aldo
mace_Target_dose
Ace_Target_dose_PCT1
beta_Target_dose_PCT1 
ARNA_Target_dose_PCT1
ace_Target_dose_PCT
pace_Target_dose_PCT
beta_Target_dose_PCT 
ARNA_Target_dose_PCT,
by=randomization,
type= d d d d d d d d d d d d d d c c c c c c c c,
ptype=ch ch ch ch ch ch ch ch ch ch ch ch ch ch te te te te te te te te,
comments=pcom,
dvar= 1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 10 10	11 11 12 12 13 13 14 14 15 15 16 16 17 17 18 18 19 19 20 20 21 21 22 22,
dline=1 2 1 2 1 2 1 2 1	2 1	2 1 2 1 2 1 2 1	2 1	2 1	2 1 2 1 2 1 2 1 2 1 2 1	2 1	2 1	2 1	2 1	2,
labelwrap=y,
outdoc=<path>\Medication_&today_macro.rtf,
meandec=2,
ttitle1=Medications participants in the ENGAGE-HF study); 


/** Cubcal spline analysis C4P score **/

ods pdf file="<path>\C4P_Analysis_Final.pdf";


proc means data=out.medications_analysis median q1 q3 maxdec=2;
var  C4P_score1 C4P_score ;
run;

proc means data=out.medications_analysis maxdec=2 median q1 q3;
class randomization;
var  C4P_score1 C4P_score ;
run;

proc sort data=out.medications_analysis;
by C4P_score1;
run;

proc glmselect data=out.medications_analysis;
    effect spl = spline(C4P_score1  / naturalcubic basis=tpf(noint) 
                           knotmethod=percentiles(3)); 
    model C4P_score  = spl / selection=none;
    output out=SplineOut predicted=Fit; /* Output predicted values for plot */
quit;

/* 3. Plot the Spline with 95% Confidence Intervals */
proc sgplot data=SplineOut;
    title "Restricted Cubic Spline: Predictor vs C4P Score";
    scatter x=C4P_score1  y=C4P_score  / transparency=0.5; /* Raw data */
    series x=C4P_score1  y=Fit / lineattrs=(thickness=3 color=red); /* Predicted curve */
    yaxis label="C4P Score" min=0 max=25;
    xaxis label="Predictor Variable (C4P Baseline)";
run;

ods select ANOVA ParameterEstimates SplineKnots;
proc glmselect data=out.medications_analysis
outdesign(addinputvars fullmodel)=SplineBasis;
    effect spl = spline(C4P_score1 / naturalcubic basis=tpf(noint) knotmethod=percentiles(3));
    model C4P_score = spl / selection=none;

quit;

/*
proc glm data=SplineBasis;
class randomization(ref="Control") ;
    model C4P_score  = spl_:  randomization/solution;
run; */
/** primary analysis */
proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model C4P_score  =randomization spl_:   study_site /solution;	lsmeans randomization/cl;

run;


/** sensitivity analysis */

proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model C4P_score  = randomization spl_: age
sex   /solution;	lsmeans randomization/cl;

run;
/** sensitivity analysis */


proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model C4P_score  =randomization spl_: age
sex study_site /solution;	lsmeans randomization/cl;

run;
/** sensitivity analysis */

proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model C4P_score  =randomization spl_:  age
sex study_site resting_sbp ckd_stage_value/solution;	lsmeans randomization/cl;
run;


/** ================== 4 knots ======================= **/

proc glmselect data=out.medications_analysis;
    effect spl = spline(C4P_score1  / naturalcubic basis=tpf(noint) 
                           knotmethod=percentiles(4)); 
    model C4P_score  = spl / selection=none;
    output out=SplineOut predicted=Fit; /* Output predicted values for plot */
quit;

/* 3. Plot the Spline with 95% Confidence Intervals */
proc sgplot data=SplineOut;
    title "Restricted Cubic Spline: Predictor vs C4P Score";
    scatter x=C4P_score1  y=C4P_score  / transparency=0.5; /* Raw data */ 
    series x=C4P_score1  y=Fit / lineattrs=(thickness=3 color=red); /* Predicted curve */
    yaxis label="Score C4P" min=0 max=25;
    xaxis label="Predictor Variable (C4P Baseline)"  min=0 max=120;
run;



ods select ANOVA ParameterEstimates SplineKnots;
proc glmselect data=out.medications_analysis
outdesign(addinputvars fullmodel)=SplineBasis;
    effect spl = spline(C4P_score1 / naturalcubic basis=tpf(noint) knotmethod=percentiles(4));
    model C4P_score = spl / selection=none;
quit;


proc sort data=out.medications_analysis;
by C4P_score1;
run;
/*
proc glm data=SplineBasis;
class randomization(ref="Control") ;
    model C4P_score  = spl_:  randomization/solution;
run; */
/** primary analysis */
proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model C4P_score  = randomization spl_: study_site /solution;	lsmeans randomization/cl;

run;
/** sensitivity analysis */

proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model C4P_score  =randomization spl_:  age sex/solution;	lsmeans randomization/cl;

run;

/** sensitivity analysis */

proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model C4P_score  =randomization spl_: age sex study_site /solution;	lsmeans randomization/cl;
run;


/** sensitivity analysis */

proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model C4P_score  =randomization spl_: age sex study_site resting_sbp ckd_stage_value/solution;	lsmeans randomization/cl;

run;

ods pdf close;
