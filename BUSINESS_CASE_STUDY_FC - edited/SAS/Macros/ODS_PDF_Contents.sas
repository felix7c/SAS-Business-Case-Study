*********************************************************************
*																  	*
*  Name: ODS_PDF_Contents.sas									  	*
*  Description: A macro to generate a proc contents for a dataset	*
*        		(for use in a PDF).									*
*																	*
*  Creation Date: 2021-08-20										*
*																	*
*********************************************************************

;




%macro ODS_PDF_Contents(dataset);
%if %sysfunc(exist(raw.&dataset.,data)) %then %do;
  title3 "&dataset. Dataset";
  ods results=off; *supress pdf from being opened;
  proc contents data=raw.&dataset.; *runs proc contents;
  run;
  title3;
%end;
%else put ERROR: specified dataset name does not exist;
%mend;