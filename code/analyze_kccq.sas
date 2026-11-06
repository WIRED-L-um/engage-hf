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


/** =========================== END ============================== **/
