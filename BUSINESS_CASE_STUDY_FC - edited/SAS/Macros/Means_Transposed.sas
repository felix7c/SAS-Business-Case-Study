*********************************************************************
*																  	*
*  Name: Means_Transposed.sas								 	 	*
*  Description: A macro to generate a proc means for a dataset		*
*        		and transpose it, for each holiday interest in 		*
*				the Business Case Study.							*
*																	*
*  Creation Date: 2021-08-24										*
*																	*
*********************************************************************

;




%macro Means_Transposed(dataset_in,class_var);
%if %sysfunc(exist(&dataset_in.,data)) %then %do;
  *Frequency count for each interest;
  proc means data=&dataset_in.  noprint nway missing;
    class &class_var.;
    var Mountaineering water_sports Sightseeing Cycling Climbing Dancing Hiking Skiing Snowboarding white_water_rafting scuba_diving Yoga mountain_biking trail_walking;
     output out= work.interests_freq_&class_var. (drop=_type_ _freq_) sum=;
  run;

  *Transpose this so easier to read;
  proc transpose data=work.interests_freq_&class_var. out=work.interests_freq_&class_var._t;
  run;
%end;
%else put ERROR: specified dataset name does not exist;

%mend;
