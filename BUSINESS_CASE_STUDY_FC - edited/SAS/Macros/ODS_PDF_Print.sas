*********************************************************************
*																  	*
*  Name: ODS_PDF_Print.sas									 	 	*
*  Description: A macro to generate a proc print for a dataset		*
*        		(for use in a PDF).									*
*																	*
*  Creation Date: 2021-08-23										*
*																	*
*********************************************************************

;




%macro ODS_PDF_Print(lib, dataset, n_obs);
%if %sysfunc(verify(strip(&n_obs.), '0123456789')) %then %do; *check if positive numeric integer;
  %if %sysfunc(exist(&lib..&dataset.,data)) %then %do;
    title3 "&dataset. Dataset (First &n_obs. Obs.)";
    ods results=off; *supress pdf from being opened;
    proc print data=&lib..&dataset. (obs=&n_obs.) label; *runs proc print;
    run;
    title3;
  %end;
  %else put ERROR: specified dataset or library name does not exist;
%end;
%else %put ERROR: n_obs must be a number;
%mend;
