/** ================================== ENGAGE-HF Study ================================= 
    ========== There are two study arms : variable name is randomization
    ========== 1. Intervention & 2. Control ============================================
    ========== It is a multi center study : 3 centers
               1='Johns Hopkins University' 
               2='Stanford University' 
		       3='University of Michigan'
/** =========== Other Scores like MOS modified kcmo,hfc,QTO etc. ====================== **/
/** ==================================================================================== **/
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

run;

/* Summary statistics */

proc means data=out.additional_scores_long n nmiss mean std min max maxdec=1;
var hfc_2022_full_0_12	modified_hfc_0_10	qto_0_8	qto_percent	ops_0_10	
kresoja_2024_0_12	modified_kcmo_0_100;
run;
/* Insert your path */
ods pdf file="<path>\Score_Summary.pdf";

proc corr data=out.additional_scores_long;
var hfc_2022_full_0_12	modified_hfc_0_10	qto_0_8	qto_percent	ops_0_10	kresoja_2024_0_12	modified_kcmo_0_100;
run;
ods pdf close;

proc corr data=out.additional_scores_long;
var 	qto_0_8	qto_percent;
run;
proc corr data=out.additional_scores_long;
var hfc_2022_full_0_12	modified_hfc_0_10	;
run;

data score1;
set out.additional_scores_long;
modified_kcmo_0_100_1=modified_kcmo_0_100;
qto_percent_1=qto_percent;
hfc_2022_full_0_12_1=hfc_2022_full_0_12;
modified_hfc_0_10_1=modified_hfc_0_10;
qto_0_8_1	=qto_0_8;
ops_0_10_1=	ops_0_10;
kresoja_2024_0_12_1=kresoja_2024_0_12;



where redcap_event_name="consent__enrollmen_arm_1";
keep ID hfc_2022_full_0_12_1	modified_hfc_0_10_1	qto_0_8_1		ops_0_10_1	
kresoja_2024_0_12_1	 modified_kcmo_0_100_1 qto_percent_1;
run;

proc means data=score1 n nmiss mean std min max maxdec=1;
var hfc_2022_full_0_12_1;
run;


data score2;
set out.additional_scores_long;
where redcap_event_name ne "consent__enrollmen_arm_1";
run;

proc sort data=score1;
by ID;
run;
proc sort data=score2;
by ID;
run;
/*Wide dataset created  for performing cubic splines  (KCMO, HFC, modified ones etc. */
data out.additional_scores_wide;
merge score1 score2;
by ID;
run;

data out.additional_scores_wide;
set out.additional_scores_wide;
drop redcap_event_name ;
run;

/* Insert your path */

ods pdf file="<path>\Score_Analysis.pdf";

/**========================== kresoja =========== **/

proc sort data=out.additional_scores_wide;
by kresoja_2024_0_12_1;
run;
proc glmselect data=out.additional_scores_wide;
    effect spl = spline(kresoja_2024_0_12_1  / naturalcubic basis=tpf(noint) 
                           knotmethod=percentiles(3)); 
    model kresoja_2024_0_12  = spl / selection=none;
    output out=SplineOut predicted=Fit; /* Output predicted values for plot */
quit;

/* 3. Plot the Spline with 95% Confidence Intervals */
proc sgplot data=SplineOut;
    title "Restricted Cubic Spline: Predictor vs Score (0-100)";
    scatter x=kresoja_2024_0_12_1  y=kresoja_2024_0_12  / transparency=0.5; /* Raw data */
    series x=kresoja_2024_0_12_1  y=Fit / lineattrs=(thickness=3 color=red); /* Predicted curve */
    yaxis label="Score (0-100)" min=0 max=120;
    xaxis label="Predictor Variable (MOS Baseline)";
run;

ods select ANOVA ParameterEstimates SplineKnots;
proc glmselect data=out.additional_scores_wide
outdesign(addinputvars fullmodel)=SplineBasis;
    effect spl = spline(kresoja_2024_0_12_1 / naturalcubic basis=tpf(noint) knotmethod=percentiles(3));
    model kresoja_2024_0_12 = spl / selection=none;

quit;


/** primary analysis */
proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model kresoja_2024_0_12  =randomization spl_:   study_site /solution;	lsmeans randomization/cl;

run;
/** sensitivity analysis */

proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model kresoja_2024_0_12  = randomization spl_: age
sex   /solution;	lsmeans randomization/cl;

run;
/** sensitivity analysis */


proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model kresoja_2024_0_12  =randomization spl_: age
sex study_site /solution;	lsmeans randomization/cl;

run;
/** sensitivity analysis */

proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model kresoja_2024_0_12  =randomization spl_:  age
sex study_site resting_sbp ckd_stage_value/solution;	lsmeans randomization/cl;
run;


proc sort data=out.additional_scores_wide;
by ops_0_10_1;
run;
proc glmselect data=out.additional_scores_wide;
    effect spl = spline(ops_0_10_1  / naturalcubic basis=tpf(noint) 
                           knotmethod=percentiles(3)); 
    model ops_0_10  = spl / selection=none;
    output out=SplineOut predicted=Fit; /* Output predicted values for plot */
quit;

/* 3. Plot the Spline with 95% Confidence Intervals */
proc sgplot data=SplineOut;
    title "Restricted Cubic Spline: Predictor vs Score (0-100)";
    scatter x=ops_0_10_1  y=ops_0_10  / transparency=0.5; /* Raw data */
    series x=ops_0_10_1  y=Fit / lineattrs=(thickness=3 color=red); /* Predicted curve */
    yaxis label="Score (0-100)" min=0 max=120;
    xaxis label="Predictor Variable (MOS Baseline)";
run;

ods select ANOVA ParameterEstimates SplineKnots;
proc glmselect data=out.additional_scores_wide
outdesign(addinputvars fullmodel)=SplineBasis;
    effect spl = spline(ops_0_10_1 / naturalcubic basis=tpf(noint) knotmethod=percentiles(3));
    model ops_0_10 = spl / selection=none;

quit;


/** primary analysis */
proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model ops_0_10  =randomization spl_:   study_site /solution;	lsmeans randomization/cl;

run;
/** sensitivity analysis */

proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model ops_0_10  = randomization spl_: age
sex   /solution;	lsmeans randomization/cl;

run;
/** sensitivity analysis */


proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model ops_0_10  =randomization spl_: age
sex study_site /solution;	lsmeans randomization/cl;

run;
/** sensitivity analysis */

proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model ops_0_10  =randomization spl_:  age
sex study_site resting_sbp ckd_stage_value/solution;	lsmeans randomization/cl;
run;

proc sort data=out.additional_scores_wide;
by modified_hfc_0_10_1;
run;
proc glmselect data=out.additional_scores_wide;
    effect spl = spline(modified_hfc_0_10_1  / naturalcubic basis=tpf(noint) 
                           knotmethod=percentiles(3)); 
    model modified_hfc_0_10  = spl / selection=none;
    output out=SplineOut predicted=Fit; /* Output predicted values for plot */
quit;

/* 3. Plot the Spline with 95% Confidence Intervals */
proc sgplot data=SplineOut;
    title "Restricted Cubic Spline: Predictor vs Score (0-100)";
    scatter x=modified_hfc_0_10_1  y=modified_hfc_0_10  / transparency=0.5; /* Raw data */
    series x=modified_hfc_0_10_1  y=Fit / lineattrs=(thickness=3 color=red); /* Predicted curve */
    yaxis label="Score (0-100)" min=0 max=120;
    xaxis label="Predictor Variable (MOS Baseline)";
run;

ods select ANOVA ParameterEstimates SplineKnots;
proc glmselect data=out.additional_scores_wide
outdesign(addinputvars fullmodel)=SplineBasis;
    effect spl = spline(modified_hfc_0_10_1 / naturalcubic basis=tpf(noint) knotmethod=percentiles(3));
    model modified_hfc_0_10 = spl / selection=none;

quit;


/** primary analysis */
proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model modified_hfc_0_10  =randomization spl_:   study_site /solution;	lsmeans randomization/cl;

run;
/** sensitivity analysis */

proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model modified_hfc_0_10  = randomization spl_: age
sex   /solution;	lsmeans randomization/cl;

run;
/** sensitivity analysis */


proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model modified_hfc_0_10  =randomization spl_: age
sex study_site /solution;	lsmeans randomization/cl;

run;
/** sensitivity analysis */

proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model modified_hfc_0_10  =randomization spl_:  age
sex study_site resting_sbp ckd_stage_value/solution;	lsmeans randomization/cl;
run;



/** ============================== **/
proc sort data=out.additional_scores_wide;
by qto_percent_1;
run;
proc glmselect data=out.additional_scores_wide;
    effect spl = spline(qto_percent_1  / naturalcubic basis=tpf(noint) 
                           knotmethod=percentiles(3)); 
    model qto_percent  = spl / selection=none;
    output out=SplineOut predicted=Fit; /* Output predicted values for plot */
quit;

/* 3. Plot the Spline with 95% Confidence Intervals */
proc sgplot data=SplineOut;
    title "Restricted Cubic Spline: Predictor vs Score (0-100)";
    scatter x=qto_percent_1  y=qto_percent  / transparency=0.5; /* Raw data */
    series x=qto_percent_1  y=Fit / lineattrs=(thickness=3 color=red); /* Predicted curve */
    yaxis label="Score (0-100)" min=0 max=120;
    xaxis label="Predictor Variable (MOS Baseline)";
run;

ods select ANOVA ParameterEstimates SplineKnots;
proc glmselect data=out.additional_scores_wide
outdesign(addinputvars fullmodel)=SplineBasis;
    effect spl = spline(qto_percent_1 / naturalcubic basis=tpf(noint) knotmethod=percentiles(3));
    model qto_percent = spl / selection=none;

quit;


/** primary analysis */
proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model qto_percent  =randomization spl_:   study_site /solution;	lsmeans randomization/cl;

run;
/** sensitivity analysis */

proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model qto_percent  = randomization spl_: age
sex   /solution;	lsmeans randomization/cl;

run;
/** sensitivity analysis */


proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model qto_percent  =randomization spl_: age
sex study_site /solution;	lsmeans randomization/cl;

run;
/** sensitivity analysis */

proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model qto_percent  =randomization spl_:  age
sex study_site resting_sbp ckd_stage_value/solution;	lsmeans randomization/cl;
run;

/** =================== **/
proc sort data=out.additional_scores_wide;
by modified_kcmo_0_100_1;
run;

/** modified_kcmo **/
proc glmselect data=out.additional_scores_wide;
    effect spl = spline(modified_kcmo_0_100_1  / naturalcubic basis=tpf(noint) 
                           knotmethod=percentiles(3)); 
    model modified_kcmo_0_100  = spl / selection=none;
    output out=SplineOut predicted=Fit; /* Output predicted values for plot */
quit;

/* 3. Plot the Spline with 95% Confidence Intervals */
proc sgplot data=SplineOut;
    title "Restricted Cubic Spline: Predictor vs Score (0-100)";
    scatter x=modified_kcmo_0_100_1  y=modified_kcmo_0_100  / transparency=0.5; /* Raw data */
    series x=modified_kcmo_0_100_1  y=Fit / lineattrs=(thickness=3 color=red); /* Predicted curve */
    yaxis label="Score (0-100)" min=0 max=120;
    xaxis label="Predictor Variable (MOS Baseline)";
run;

ods select ANOVA ParameterEstimates SplineKnots;
proc glmselect data=out.additional_scores_wide
outdesign(addinputvars fullmodel)=SplineBasis;
    effect spl = spline(modified_kcmo_0_100_1 / naturalcubic basis=tpf(noint) knotmethod=percentiles(3));
    model modified_kcmo_0_100 = spl / selection=none;

quit;


/** primary analysis */
proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model modified_kcmo_0_100  =randomization spl_:   study_site /solution;	lsmeans randomization/cl;

run;
/** sensitivity analysis */

proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model modified_kcmo_0_100  = randomization spl_: age
sex   /solution;	lsmeans randomization/cl;

run;
/** sensitivity analysis */


proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model modified_kcmo_0_100  =randomization spl_: age
sex study_site /solution;	lsmeans randomization/cl;

run;
/** sensitivity analysis */

proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model modified_kcmo_0_100  =randomization spl_:  age
sex study_site resting_sbp ckd_stage_value/solution;
run;

ods pdf close;












/*hfc_2022_full_0_12		qto_0_8		ops_0_10 

proc sort data=out.additional_scores_wide;
by hfc_2022_full_0_12;
run;
proc glmselect data=out.additional_scores_wide;
    effect spl = spline(hfc_2022_full_0_12_1  / naturalcubic basis=tpf(noint) 
                           knotmethod=percentiles(3)); 
    model hfc_2022_full_0_12  = spl / selection=none;
    output out=SplineOut predicted=Fit; * Output predicted values for plot;
quit;

* 3. Plot the Spline with 95% Confidence Intervals;
proc sgplot data=SplineOut;
    title "Restricted Cubic Spline: Predictor vs Score (0-100)";
    scatter x=hfc_2022_full_0_12_1  y=hfc_2022_full_0_12  / transparency=0.5; * Raw data;
    series x=hfc_2022_full_0_12_1  y=Fit / lineattrs=(thickness=3 color=red); * Predicted curve;
    yaxis label="Score (0-100)" min=0 max=120;
    xaxis label="Predictor Variable (MOS Baseline)";
run;

ods select ANOVA ParameterEstimates SplineKnots;
proc glmselect data=out.additional_scores_wide
outdesign(addinputvars fullmodel)=SplineBasis;
    effect spl = spline(hfc_2022_full_0_12_1 / naturalcubic basis=tpf(noint) knotmethod=percentiles(3));
    model hfc_2022_full_0_12 = spl / selection=none;

quit;


* primary analysis;
proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model hfc_2022_full_0_12  =randomization spl_:   study_site /solution;	lsmeans randomization/cl;

run;
*/
