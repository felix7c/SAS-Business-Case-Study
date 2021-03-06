*********************************************************************
*																  	*
*  Name: A_Importing.sas										  	*
*  Description: Importing data for the Business Analytics      		*
*				case study - to be run in conjuction with 		    *
*				Run_Me.sas.											*
*																	*
*  Creation Date: 2021-08-18										*
*																	*
*********************************************************************
;


*send logs to a text file rather than SAS log;
proc printto log="&sas_root.\Logs\A_Importing_Log.txt";
run;



*HOUSEHOLDS;
data raw.households (label="Households Dataset( Generated by &sysuserid. on &today_f. at &systime.)");
  infile "&data_location.\Households.csv"
  delimiter = ","
  missover 
  dsd 
  firstobs=2;
  *continue reading if encounter mv / ignore delimiters enclosed in double quotes/read data from 2nd line onwards;
  
  informat
  Customer_Id 15.
  Family_Name $40.
  Forename  $40.
  Title $15.
  Gender $10.
  DOB ANYDTDTE9. 
  Loyalty_Id $15.
  Address_1 $150.
  Address_2 $60.
  Address_3 $40.
  Address_4 $40.
  Postcode $8.
  Email1 $60.
  Contact_Preference $15.
  Interests $15.
  Customer_StartDate ANYDTDTE9.
  Contact_Date ANYDTDTE9.; *ANYDTDTE9. - should be able to import date regardless of format;

  format
  Customer_Id 15.
  Family_Name $40. 
  Forename  $40.
  Title $15.
  Gender $10.
  DOB date9. 
  Loyalty_Id $15.
  Address_1 $150.
  Address_2 $60.
  Address_3 $40.
  Address_4 $40.
  Postcode $8.
  Email1 $60.
  Contact_Preference $15.
  Interests $15.
  Customer_StartDate date9.
  Contact_Date date9.;


  input
  Customer_Id 
  Family_Name $ 
  Forename  $
  Title $
  Gender $
  DOB 
  Loyalty_Id $ 
  Address_1 $ 
  Address_2 $ 
  Address_3 $ 
  Address_4 $ 
  Postcode $
  Email1 $ 
  Contact_Preference $
  Interests $ 
  Customer_StartDate
  Contact_Date  ;

  label
  Customer_Id ='Customer Identification'
  Family_Name=  'Family Name'
  DOB ='Date of Birth'
  Loyalty_Id = 'Loyalty Identification'
  Address_1 = 'Address1'
  Address_2 = 'Address2'
  Address_3 = 'Address3'
  Address_4 = 'Address4'
  Email1 = 'Email Address'
  Contact_Preference = 'Customers Contact Preference'
  Interests = 'Customer Interests'
  Customer_StartDate= 'Customer Enrolment Date'
  Contact_Date=  'Date Customer Last Contacted';
run;




*BOOKINGS;
data raw.bookings  (label="Bookings Dataset (Generated by &sysuserid. on &today_f. at &systime.)");
  infile "&data_location.\Bookings.csv"
  delimiter = ","
  missover 
  dsd 
  firstobs=2;
  *continue reading if encounter mv / ignore delimiters enclosed in double quotes/read data from 2nd line onwards;
  
  informat
  family_name $60.
  brochure_code $6.
  room_type $20.
  booking_id 12.
  customer_id 12.
  booked_date ANYDTDTE9.
  departure_date ANYDTDTE9.
  duration 5.
  pax 8.
  insurance_code 1.
  holiday_cost NLMNLGBP12.2
  destination_code $6.;

  format
  family_name $60.
  brochure_code $6.
  room_type $20.
  booking_id 12.
  customer_id 12.
  booked_date date9.
  departure_date date9.
  duration 5.
  pax 8.
  insurance_code 1.
  holiday_cost NLMNLGBP12.2
  destination_code $6.;

  input
  family_name $
  brochure_code $
  room_type $
  booking_id
  customer_id
  booked_date
  departure_date
  duration
  pax
  insurance_code
  holiday_cost
  destination_code $;

  label
  family_name = 'Family Name'
  brochure_code = 'Brochure of Destination'
  room_type = 'Room Type'
  booking_id = 'Booking ID'
  customer_id = 'Customer ID'
  booked_date = 'Date Customer Booked Holiday'
  departure_date = 'Holiday Departure Date'
  duration = 'Number of Nights'
  pax = 'Number of Passengers'
  insurance_code = 'Customer Added Insurance'
  holiday_cost = 'Total Cost (?) of Holiday'
  destination_code = 'Destination Code';

run;






*DESTINATIONS;
data raw.destinations (label="Destinations Dataset (Generated by &sysuserid. on &today_f. at &systime.)");
  infile "&data_location.\Destinations.csv"
  delimiter = ","
  missover 
  dsd 
  firstobs=2;
  *continue reading if encounter mv / ignore delimiters enclosed in double quotes/read data from 2nd line onwards;
  
  informat
  CODE $4.
  DESCRIPTION $60.;

  format
  CODE $4.
  DESCRIPTION $60.;

  input
  CODE $
  DESCRIPTION $;

run;





*LOYALTY;
data raw.loyalty (label="Loyalty Dataset (Generated by &sysuserid. on &today_f. at &systime.)");
  infile "&data_location.\loyalty.dat" 
  firstobs=2
  expandtabs;
  
  
  informat
  
  Account_Id 15.
  Loyalty_Id $15.
  Invested_Date ANYDTDTE9.
  Initial_Value NLMNLGBP12.2
  Investor_Type $15.
  Current_Value NLMNLGBP12.2;

  format
  
  Account_Id 15.
  Loyalty_Id $15.
  Invested_Date date9.
  Initial_Value NLMNLGBP12.2
  Investor_Type $15.
  Current_Value NLMNLGBP12.2;
  
  input
  Account_Id 
  Loyalty_Id $
  Invested_Date
  Initial_Value $
  Investor_Type $
  Current_Value$;
  

  label
  Account_Id = 'Loyalty Identification'
  Loyalty_Id = 'Customer Account Number'
  Invested_Date = 'Investment Date'
  Initial_Value = 'Initial Share Value'
  Investor_Type = 'Type of Investor'
  Current_Value = 'Current Share Value';


run;






*Report of assumptions, proc contents etc;

ods pdf file="&sas_root.\Report\A_Report.pdf" style= Pearl; *location to save as pdf, sets as this style for this consistency;
  title2 "Document of Assumptions/Issues:"; 
  ods pdf text="1) I noticed that there are entries labelled as 'Tripple' under room_type in Bookings.csv - these have been left as this spelling as I did not want to alter the data.";
  ods pdf text="2) I have let the user input separate locations for where the data is stored and where the overall file structure is stored, as the project brief states 'The program should be easily executed by another person, even if the initial input data is moved to a new storage location'. However it would be recommended to store data in the Data\1_Input folder within the case study folder structure.";

  title2; 
  
  ods pdf startpage=now;

  %ODS_PDF_Contents(Households) *generate proc contents and save to PDF;
  %ODS_PDF_Contents(Bookings) *generate proc contents and save to PDF;
  %ODS_PDF_Contents(Destinations) *generate proc contents and save to PDF;
  %ODS_PDF_Contents(Loyalty) *generate proc contents and save to PDF;

ods pdf close;





*resets so logs sent to log from now on;
proc printto;
run;