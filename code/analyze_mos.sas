/** ==================================================================================== **/
/** ================================== ENGAGE-HF Study ================================= 
    ========== There are two study arms : variable name is randomization
    ========== 1. Intervention & 2. Control ============================================
    ========== It is a multi center study : 3 centers
               1='Johns Hopkins University' 
               2='Stanford University' 
		       3='University of Michigan'
/** ==================================================================================== **/
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

/** ==================================================================================== **/
/** ================================== Primary Analysis ================================ **/
/** ====================== Outcome: Medication Optimization Score ====================== **/
/** ==================================================================================== **/


%let today_macro = %sysfunc(today(), date9.);

/** By Study Arms **/
proc sort data=out.mos_analysis;
by randomization;
run;

/* Insert your path */

%Include '<path>\macro_table.sas';
%Table(dsn=out.mos_analysis,
var =
MOS1_pct
MOS2_pct,
by=randomization,
type= c c,
ptype= te te,
labelwrap=y,
outdoc=<pathy>\MOS_Summary_&today_macro,
meandec=2,
ttitle1=MOS ENGAGE-HF study); 

/** Examining by study sites **/
proc sort data=out.mos_analysis;
by study_site;
run;

/* Insert your path */


%Include '<path>\macro_table.sas';
%Table(dsn=out.mos_analysis,
var =
MOS1_pct
MOS2_pct,
by=study_site,
type= c c,
ptype= te te,
labelwrap=y,
outdoc=<pathy>\MOS_sites_&today_macro,
meandec=2,
ttitle1=MOS ENGAGE-HF study); 

/** ================================================ **/
/** ================= Analysis ===================== **/
/** == Restricted Cube Spline with 3 and 4 knots === **/
/** ================================================ **/


/* Insert your path */

ods pdf file="<path>\MOS_Analysis_July.pdf";

proc sort data=out.mos_analysis;
by MOS1_pct;
run;
proc glmselect data=out.mos_analysis;
    effect spl = spline(MOS1_pct  / naturalcubic basis=tpf(noint) 
                           knotmethod=percentiles(3)); 
    model MOS2_pct  = spl / selection=none;
    output out=SplineOut predicted=Fit; /* Output predicted values for plot */
quit;

/* 3. Plot the Spline with 95% Confidence Intervals */
proc sgplot data=SplineOut;
    title "Restricted Cubic Spline: Predictor vs Score (0-100)";
    scatter x=MOS1_pct  y=MOS2_pct  / transparency=0.5; /* Raw data */
    series x=MOS1_pct  y=Fit / lineattrs=(thickness=3 color=red); /* Predicted curve */
    yaxis label="Score (0-100)" min=0 max=120;
    xaxis label="Predictor Variable (MOS Baseline)";
run;

ods select ANOVA ParameterEstimates SplineKnots;
proc glmselect data=out.mos_analysis
outdesign(addinputvars fullmodel)=SplineBasis;
    effect spl = spline(MOS1_pct / naturalcubic basis=tpf(noint) knotmethod=percentiles(3));
    model MOS2_pct = spl / selection=none;

quit;


/** primary analysis with 3 knots */
proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model MOS2_pct  =randomization spl_:   study_site /solution;	lsmeans randomization/cl;

run;

/** sensitivity analysis 1*/

proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model MOS2_pct  = randomization spl_: age sex   /solution;	lsmeans randomization/cl;

run;

/** sensitivity analysis 2*/


proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model MOS2_pct  =randomization spl_: age sex study_site /solution;	lsmeans randomization/cl;

run;

/** sensitivity analysis 3*/

proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model MOS2_pct  =randomization spl_:  age
sex study_site resting_sbp ckd_stage_value/solution;	lsmeans randomization/cl;
run;


/** ================== with  4 knots ======================= **/

proc glmselect data=out.mos_analysis;
    effect spl = spline(MOS1_pct  / naturalcubic basis=tpf(noint) 
                           knotmethod=percentiles(4)); 
    model MOS2_pct  = spl / selection=none;
    output out=SplineOut predicted=Fit; /* Output predicted values for plot */
quit;

/* 3. Plot the Spline with 95% Confidence Intervals */
proc sgplot data=SplineOut;
    title "Restricted Cubic Spline: Predictor vs Score (0-100)";
    scatter x=MOS1_pct  y=MOS2_pct  / transparency=0.5; /* Raw data */ 
    series x=MOS1_pct  y=Fit / lineattrs=(thickness=3 color=red); /* Predicted curve */
    yaxis label="Score (0-100)" min=0 max=120;
    xaxis label="Predictor Variable (MOS Baseline)"  min=0 max=120;
run;



ods select ANOVA ParameterEstimates SplineKnots;
proc glmselect data=out.mos_analysis
outdesign(addinputvars fullmodel)=SplineBasis;
    effect spl = spline(MOS1_pct / naturalcubic basis=tpf(noint) knotmethod=percentiles(4));
    model MOS2_pct = spl / selection=none;
quit;


proc sort data=out.mos_analysis;
by MOS1_pct;
run;

/** primary analysis */
proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model MOS2_pct  = randomization spl_: study_site /solution;	lsmeans randomization/cl;

run;
/** sensitivity analysis 1*/

proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model MOS2_pct  =randomization spl_:  age sex/solution;	lsmeans randomization/cl;

run;
/** sensitivity analysis 2*/


proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model MOS2_pct  =randomization spl_: age sex study_site /solution;	lsmeans randomization/cl;

run;
/** sensitivity analysis 3*/

proc glm data=SplineBasis;
class randomization(ref="Control") study_site sex;
    model MOS2_pct  =randomization spl_: age sex study_site resting_sbp ckd_stage_value/solution;	lsmeans randomization/cl;

run;

ods pdf close;
