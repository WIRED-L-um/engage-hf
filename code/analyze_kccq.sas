/** ================================== ENGAGE-HF Study ================================= 
    ========== There are two study arms : variable name is randomization
    ========== 1. Intervention & 2. Control ============================================
    ========== It is a multi center study : 3 centers
               1='Johns Hopkins University' 
               2='Stanford University' 
		       3='University of Michigan'
/** ==================================================================================== **/

/** ========================================================================================================================= **/
/** ========================================= Secondsary Analysis =========================================================== **/
/** ========================================= Outcome:kccq 23 clinical summary =============================================== **/
/** ========================================================================================================================= **/


/** =================== KCCQ Followup Data ==================== **/
/*

NOTE: OUT.kccq_followup data set was successfully created.
NOTE: The data set OUT.kccq_followup has 129 observations and 11 variables.

*/

/** Getting Baseline KCCQ from demographics_baseline File **/

data mdemographic_june;
set out.demographics_baseline;
pnew_k23_clinsummary=k23_clinsummary+0;
pnew_k23_soclimit=k23_soclimit+0;
pnew_k23_sympstability=k23_sympstability+0;
pnew_k23_selfefficacy=k23_selfefficacy+0;
pnew_k23_overallsummary=k23_overallsummary+0;
pnew_k23_physlimit= k23_physlimit+0;
pnew_k23_qol=k23_qol+0;
pnew_k23_sympburden= k23_sympburden+0;
pnew_k23_sympfreq=k23_sympfreq+0;
pnew_k23_totalsymp=k23_totalsymp+0;
run;


data mdemographic_june;
set mdemographic_june;
drop k23_sympstability
k23_selfefficacy
k23_clinsummary
 k23_overallsummary
 k23_physlimit
 k23_qol
 k23_sympburden
 k23_sympfreq
k23_totalsymp
k23_sympburden
;
 run;



proc sql;
create table kccq_analysis
as select * 
from OUT.kccq_followup as a, mdemographic_june as b
where a.record_id=b.record_id;
quit;

/** Data set was saved for the analysis **/
data out.kccq_analysis;
set kccq_analysis;
run;


/** ============================ Analysis ============================= **/
/* Insert your path */

ods select ANOVA ParameterEstimates SplineKnots;
ods pdf file="<path>\kccq_Analysis_3_4knots.pdf";

proc glmselect data=out.kccq_analysis
outdesign(addinputvars fullmodel)=SplineBasis;
    effect spl = spline(pnew_k23_clinsummary / naturalcubic basis=tpf(noint) knotmethod=percentiles(3));
    model k23_clinsummary = spl / selection=none;
quit;

/** primary analysis */
proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model k23_clinsummary  = randomization spl_:  study_site /solution;
	lsmeans randomization/cl;

run;
/** sensitivity analysis */

proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model k23_clinsummary  = randomization  spl_:  age sex /solution;
	lsmeans randomization/cl;

run;
/** sensitivity analysis */
proc glm data=SplineBasis;

class randomization(ref="Control") study_site sex;
    model k23_clinsummary  = randomization spl_: study_site age sex  /solution;
	lsmeans randomization/cl;

run;
/** sensitivity analysis */

proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model k23_clinsummary  =randomization spl_:    study_site age
sex  resting_sbp ckd_stage_value/solution;
lsmeans randomization/cl;

run;
/** 4 knots */

ods select ANOVA ParameterEstimates SplineKnots;
proc glmselect data=out.kccq_analysis
outdesign(addinputvars fullmodel)=SplineBasis;
    effect spl = spline(pnew_k23_clinsummary / naturalcubic basis=tpf(noint) knotmethod=percentiles(4));
    model k23_clinsummary = spl / selection=none;

quit;

/** primary analysis */
proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model k23_clinsummary  = randomization spl_:  study_site /solution;
	lsmeans randomization/cl;

run;
/** sensitivity analysis */

proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model k23_clinsummary  = randomization   spl_:  age sex/solution;
	lsmeans randomization/cl;

run;


/** sensitivity analysis */


proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model k23_clinsummary  = randomization spl_:   study_site age
sex/solution;
lsmeans randomization/cl;

run;
/** sensitivity analysis */

proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model k23_clinsummary  = randomization spl_:   study_site age
sex resting_sbp ckd_stage_value/solution;
lsmeans randomization/cl;
run;

ods pdf close;



/** ======================================================== **/
/** ================= subscore analysis ==================== **/
/** ======================================================== **/

/** ================== Restricted 3 knots analysis ========= **/
/** ======================================================== **/
/* Insert your path */

%macro mod(X);
ods select ANOVA ParameterEstimates SplineKnots;
ods pdf file="<path>\Analysis_&x.pdf";

proc glmselect data=out.kccq_analysis
outdesign(addinputvars fullmodel)=SplineBasis;
    effect spl = spline(pnew_&x / naturalcubic basis=tpf(noint) knotmethod=percentiles(3));
    model &x  = spl / selection=none;
quit;

/** primary analysis */
proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model &x   = randomization spl_:  study_site /solution;
	lsmeans randomization/cl;

run;
ods pdf close;

%mend;
%mod(k23_sympstability);
%mod(k23_selfefficacy);
%mod(k23_overallsummary);
%mod(k23_physlimit);
%mod(k23_qol);
%mod(k23_sympburden);
%mod(k23_sympfreq);
%mod(k23_totalsymp);
%mod(k23_sympburden);

/** ================ END ===================== **/
