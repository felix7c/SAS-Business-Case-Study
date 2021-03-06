*********************************************************************
*																  	*
*  Name: B_Data.sas												  	*
*  Description: Managing new data for the Business Analytics      	*
*				case study - to be run in conjuction with 		    *
*				Run_Me.sas.											*
*																	*
*  Creation Date: 2021-08-18										*
*																	*
*********************************************************************
;


*send logs to a text file rather than SAS log;
proc printto log="&sas_root.\Logs\B_Data_Log.txt";
run;


data staging.households_detail;
  set raw.households;

  *gender/title/greeting code;
  if missing(gender) and upcase(compress(title,'.'))= 'MR' then gender ='M';
  else if missing(gender) and upcase(compress(title,'.')) in ('MRS','MS','MISS') then gender ='F';

  if missing(title) and upcase(gender)='F' then title = 'Mrs';
  else if missing(title) and upcase(gender)='M' then title = 'Mr';
  

  if missing(title)=0 and missing(family_name)=0 then
  		Greeting=propcase(catx(' ','Dear',compress(title,'.'),first(forename),family_name));
  else Greeting= 'Dear Customer';

  *concatenate address1 and postcode so they can be used as unique identifiers;
  addr_poscd=upcase(catx(' ',address_1,postcode));
  
run;



*sort by combination of address_1 and postcode, then other vars used to determine primary householder;
proc sort data=staging.households_detail;
  by addr_poscd gender dob customer_id;
run;


*set unique household identifier;
data staging.households_detail (label="Detailed Households Dataset (Generated by &sysuserid. on &today_f. at &systime.)" drop=addr_poscd) ;
  set staging.households_detail;
  by addr_poscd gender dob customer_id;
  retain Household_ID 0;
  if first.addr_poscd then Household_ID=Household_ID+1;
  

  *Identify primary householder;
  if first.addr_poscd then pri_householder =1;
  else pri_householder=0;
  
  label Household_ID= 'Household Identification'
        pri_householder= 'Primary Householder';
run;



*Contact Preference datasets;
data marts.contact_post (keep= customer_id contact_preference greeting address_1 address_2 address_3 address_4 postcode )
     marts.contact_email (keep= customer_id contact_preference greeting email1)
     excepts.contact_unknown; 
  set staging.households_detail(keep= customer_id contact_preference greeting address_1 address_2 address_3 address_4 postcode email1);
  if upcase(compress(contact_preference,,'ak')) = 'POST' then output marts.contact_post;
  else if upcase(compress(contact_preference,,'ak')) = 'EMAIL' then output marts.contact_email; *'ak' modifier only keeps characters;
  else if upcase(compress(contact_preference,,'ak')) ne 'DNM' then output excepts.contact_unknown; 
  *so if unknown value entered in contact_preference, will be sent to exceptions;
run;




*Saving peoples interests as booleans (file in Detail folder);
data detail.households_detail (label="Detailed Households Dataset with Interests (Generated by &sysuserid. on &today_f. at &systime.)" ) ;
  set staging.households_detail;

  if findw(upcase(interests),'A')>0  or findw(upcase(interests),'K')>0 or findw(upcase(interests),'L')>0 then Mountaineering=1;
  else Mountaineering=0;
  if findw(upcase(interests),'B')>0 then water_sports=1;
  else water_sports=0;
  if findw(upcase(interests),'C')>0 or findw(upcase(interests),'X')>0 then Sightseeing=1;
  else Sightseeing=0;
  if findw(upcase(interests),'D')>0 then Cycling=1;
  else Cycling=0;
  if findw(upcase(interests),'E')>0 then Climbing=1;
  else Climbing=0;
  if findw(upcase(interests),'F')>0 or findw(upcase(interests),'W')>0 then Dancing=1;
  else Dancing=0;
  if findw(upcase(interests),'H')>0 or findw(upcase(interests),'G')>0 then Hiking=1;
  else Hiking=0;
  if findw(upcase(interests),'J')>0 then Skiing=1;
  else Skiing=0;
  if findw(upcase(interests),'M')>0 then Snowboarding=1;
  else Snowboarding=0;
  if findw(upcase(interests),'N')>0 then white_water_rafting=1;
  else white_water_rafting=0;
  if findw(upcase(interests),'P')>0 or findw(upcase(interests),'Q')>0 or findw(upcase(interests),'R')>0 then scuba_diving=1;
  else scuba_diving=0;
  if findw(upcase(interests),'S')>0 then Yoga=1;
  else Yoga=0;
  if findw(upcase(interests),'T')>0 or findw(upcase(interests),'U')>0 then mountain_biking=1;
  else mountain_biking=0;
  if findw(upcase(interests),'V')>0 or findw(upcase(interests),'Y')>0 or findw(upcase(interests),'Z')>0 then trail_walking=1;
  else trail_walking=0;


  label water_sports='Water Sports'
  		white_water_rafting='White Water Rafting'
		scuba_diving='Scuba Diving'
		mountain_biking='Mountain Biking'
		trail_walking='Trail Walking'
        ;

 run;



*Bookings data;
*creating format dataset;
data shared.destinations_format (label="Destinations Format Dataset (Generated by &sysuserid. on &today_f. at &systime.)" );
  retain fmtname 'dest_fmt' type 'C'; *format name, type =char;
  set raw.destinations (rename=(code=start description=label));
run;

*creating the format from the dataset;
proc format library=shared cntlin=shared.destinations_format;
run;


*apply format to destination code in dataset;
data staging.bookings (label="Bookings Dataset (Generated by &sysuserid. on &today_f. at &systime.)" ) ;
  set raw.bookings;
  format destination_code $dest_fmt.;
run;


*sort by booked_date;
proc sort data=staging.bookings out=work.bookings;
  by booked_date;
run;

*create bookings_deposit and bookings_balance datasets;
data marts.bookings_deposit (label="Bookings Dataset - Over 6 Weeks (Generated by &sysuserid. on &today_f. at &systime.)" ) marts.bookings_balance (label="Bookings Dataset - Within 6 Weeks (Generated by &sysuserid. on &today_f. at &systime.)" drop=deposit balance ) ;
  set work.bookings;
  by booked_date;
  if departure_date - booked_date le 42 then output marts.bookings_balance;
  else do;
    Deposit  = 0.2*holiday_cost;
	Balance  = holiday_cost - Deposit;
	format deposit nlmnlgbp12.2 balance nlmnlgbp12.2;
	output marts.bookings_deposit;
  end;
run;



*create shareholders dataset;
proc sql noprint;
  create table marts.shareholders (label= "Shareholders Dataset (Generated by &sysuserid. on &today_f. at &systime.)" ) as
  select h.*, l.account_id, l.invested_date, l.initial_value,l.investor_type, l.current_value
  from raw.households h left join raw.loyalty l
  on h.loyalty_id = l.loyalty_id
  where h.loyalty_id is not missing ;
quit;


*create household_only dataset (customers who havent made a booking);
proc sql noprint;
  create table marts.household_only (label="Household Only Dataset (Generated by &sysuserid. on &today_f. at &systime.)" ) as
  select *
  from detail.households_detail 
  where customer_id not in 
    (select customer_id from staging.bookings);
quit;



*create intermediate table of how many bookings for each household (for bookings_multi dataset);
proc sql noprint;
  create table work.bookings_multi_count as
  select customer_id, count(*) as count_b
  from staging.bookings
  group by family_name, customer_id
  order by customer_id;
quit;



*create bookings_multi dataset (for households whove had more than 1 booking);
proc sql noprint;
  create table work.bookings_multi as
  select h.*, b.brochure_code, b.room_type, b.booking_id, b.booked_date, b.departure_date, b.duration, b.pax, b.insurance_code, b.holiday_cost, b.destination_code 
  from detail.households_detail h inner join staging.bookings b
    on h.customer_id=b.customer_id
  where h.customer_id in 
    (select customer_id from work.bookings_multi_count where count_b >1 )  and pri_householder
  order by h.customer_id;
quit;



*Create the age format;
proc format library=shared;
  value age_fmt 0-17='Under 18'
  				 18-24='18-24'
				 25-34='25-34'
				 35-44='35-44'
				 45-54='45-54'
				 55-64='55-64'
				 65-high='65+'
				 .= 'Missing'
				 other='Not Recognised';
run;


*apply age format and save bookings_multi;
data marts.bookings_multi (label="Multiple Bookings Dataset (Generated by &sysuserid. on &today_f. at &systime.)" );
  set work.bookings_multi;
  if missing(dob)=0 and missing(departure_date)=0 then Age= floor(yrdif(DOB,departure_date,'ACT/ACT')); *sets value for age variable (rounded down using floor, but ACT/ACT  for accurate age);
  format Age age_fmt.;
run;


*Create and save PDF file;

ods pdf file="&sas_root.\Report\B_Report.pdf" style= Pearl; *location to save as pdf;
   
  
  %ODS_PDF_PRINT(staging,Households_Detail,30) *generate proc print;
  %ODS_PDF_PRINT(detail,Households_Detail,30) *generate proc print;
  %ODS_PDF_PRINT(marts,Contact_Post,30) *generate proc print;
  %ODS_PDF_PRINT(marts,Contact_Email,30) *generate proc print;
  %ODS_PDF_PRINT(marts,Bookings_Deposit,30) *generate proc print;
  %ODS_PDF_PRINT(marts,Bookings_Balance,30) *generate proc print;

  
  

ods pdf close;




*resets so logs sent to log from now on;
proc printto;
run;