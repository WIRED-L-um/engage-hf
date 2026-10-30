
/** ================================== ENGAGE-HF Study ================================= 
    ========== There are two study arms : variable name is randomization
    ========== 1. Intervention & 2. Control ============================================
    ========== It is a multi center study : 3 centers
               1='Johns Hopkins University' 
               2='Stanford University' 
		       3='University of Michigan'
/** ==================================================================================== **/
/** ==================================================================================== **/
/** ==================================  90-day all-cause mortality, hospitalization, 
      ED visits, & outpatient intravenous diuresis====================================== **/
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




data out.AE_final;
set out.AE_final;
/** Brad provided and included in the RedCap **/
date=mdy(12,22,2025);
if  ae_yes_no not in ('',"No","UNK") and ae_start_date ne . then
newtime_ae=ae_start_date-enrollment_date+1;
else if ae_yes_no not in ('',"No","UNK") and ae_start_date = . then
newtime_ae=date-enrollment_date+1;
else newtime_ae=90;



if  ae_yes_no not in ('',"No","UNK") or sae_hf = 'Ye' or sae_category ne ''
then composite=1;
else composite=0;
if ae_yes_no not in ('',"No","UNK") then ae_event=1;
else ae_event=0;
if sae_hf = 'Ye' then sae_HF_event=1;
else sae_HF_event=0;
if sae_category="Death" then death=1;
else death=0;
if sae_category = 'Inpatient hospitalization or prolongation of existing hospitalization' then INP=1;
else inp=0;
if ae_yes_no not in ('',"No","UNK") then
time=sae_mm_date-enrollment_date+1;
else time=90;

time_diff=sae_mm_date-ae_start_date;

run;



/** =============================== **/
/** aggregated at the patient level **/
/** =============================== **/

proc sql;
create table AE_event as select record_id,randomization,study_site, sum(INP) as INP,
sum(death) as death, sum(ae_event) as ae_event, sum(sae_HF_event) as sae_HF_event ,
sum(composite) as composite 
from out.AE_final
group by record_id;
quit;

proc sort data=AE_event nodupkey;
by _all_;
run;

data demo;
set out.demographic_June;
keep record_id randomization study_site;
run;

proc sort data=demo;
by record_id;
run;
proc sort data=AE_event;
by record_id;
run;

data event;
merge demo ae_event;
by record_id;
run;

data event;
set event;
if inp  in (.,0) then INP=0;
else INP=1;

if  sae_HF_event in (.,0) then  sae_HF_event=0;
else  sae_HF_event= 1;

if composite in (.,0) then composite=0;
else composite=1;



if death in (.,0) then death=0;
else death=1;

run;

/* Insert your path */

%Include '<path>\Table.sas';
%Table(dsn=event,
var =death sae_HF_event INP composite,
by=randomization,
type= d d d d d,
ptype=ch ch ch ch ch,
labelwrap=y,
outdoc=<path>\AE_EngageHF,
meandec=2,
ttitle1=AE of the participants in the ENGAGE-HF study); 

/* Insert your path */

%Include '<path>\Table.sas';
%Table(dsn=event,
var =death sae_HF_event INP composite,
by=study_site,
type= d d d d d,
ptype=ch ch ch ch ch,
labelwrap=y,
outdoc=<path>\AE_sites,
meandec=2,
ttitle1=AE of the participants in the ENGAGE-HF study); 


/** time to event analysis **/
/* Insert your path */

ods pdf file="<path>\AE_Analysis_final.pdf";
proc phreg data=out.AE_final;
    class randomization(ref="Control") sex study_site;
    model newtime_ae * composite(0) = randomization;
run;


proc phreg data=out.AE_final;
    class randomization(ref="Control") sex study_site;
    model newtime_ae * composite(0) = randomization study_site age sex;
run;



proc phreg data=out.AE_final;
    class randomization(ref="Control") sex study_site;
    model newtime_ae * INP(0) = randomization study_site age sex;
run;



proc phreg data=out.AE_final;
    class randomization(ref="Control") sex study_site;
    model newtime_ae * sae_HF_event(0) = randomization study_site age sex;
run;


proc phreg data=out.AE_final;
    class randomization(ref="Control") sex study_site;
    model newtime_ae* death(0) = randomization ;
run;

ods pdf close;
