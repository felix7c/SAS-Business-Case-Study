*********************************************************************
*																  	*
*  Name: Run_Me.sas												  	*
*  Description: Run this to run all sections of the Business		*
*				Analytics case study.								*
*																	*
*  Creation Date: 2021-08-18										*
*																	*
*********************************************************************
;

*MAKE SURE THAT YOU HAVE RUN AUTOEXEC.SAS BEFORE ATTEMPTING TO RUN THIS CODE;



*DO NOT EDIT;
%let sas_root= &root.\BUSINESS_CASE_STUDY_FC\SAS;

%inc "&sas_root.\Programs\A_Importing.sas" ; *run part A code;
%inc "&sas_root.\Programs\B_Data.sas" ; *run part B code;
%inc "&sas_root.\Programs\C_Analytics.sas" ; *run part C code;


*Revert certain options back to default;
title;
footnote;
