// Nikkhil Dev Murthy //
// Data Management in STATA // 
// Public Affairs and Community Development //
// Problem Set 3 //
// Spring 2021 //


/* The purpose of this project is to identify the factors most useful for understanding the results of election campaigns in the United States. 

I empiracally test some of the assumptions of the Primary Model conceptualized by Helmut Norpoth in 1996. Norpoth's primary model has correctly predicted the winner of the last six presidenital elections. Retrospectively, the model has predicted the winner for all presidential elections since 1912, except the 1960 presidential election. Among the main assumptions of the primary model is the election cycle. However, the assumption that I aim to address in this part of the project is the economy-related assumption of the model. The model omits the state of the economy as a major factor because of the results of the 2000 election. I aim to empircally test this assumption. In addition, I aim to study other novel aspects of the model as well. I hope to answer the following research questions:   
       1. Does the assumptions of the primary model hold for non-presidential elections as well?  
       2.  How does the economy impact presidential election?  

In this part of the project, I am focusing on the 1980 United States 
Presidential Election. I aim to find new empirical evidence to explain the 
results of the 1980 election by studying and testing a variety of factors from 
education spending to the state of the economy */ 





********************************************************************************
****************************** References **************************************
********************************************************************************

/*http://www.stata-press.com/data/r8/census.dta
// New York Times/ Politico – Data on 1980 election results // 
https://www2.ed.gov/about/overview/budget/history/index.html // 1980 – 1981
https://docs.google.com/spreadsheets/d/1or-N33CpOZYQ1UfZo0h8yGPSyz0Db-xjmZOXg3VJi-Q/edit#gid=1670431880
https://www.issuelab.org/resources/7352/7352.pdf // I manually entered the data needed from the pdf // 
https://www.icip.iastate.edu/tables/employment/unemployment-states */



*************************** Introduction ***************************************
 
cd /Users/nikhildev/Desktop/Data_Management        

set matsize 800 
version 16
set more off
clear

********************************************************************************
****************** Editing and formatting the data for use later ****************
********************************************************************************

***** Code for formating "formatted_census_data" *******************************

use http://www.stata-press.com/data/r8/census.dta 
// I was unable to find 1980 Census data, which is why I am still using the above dataset // 
summarize
describe
codebook
replace state = "South Carolina" if state=="S. Carolina"
replace state = "South Dakota" if state=="S. Dakota"
replace state = "West Virginia" if state=="W. Virginia"
replace state = "North Carolina" if state=="N. Carolina"
replace state = "North Dakota" if state=="N. Dakota" 
save formatted_census_data, replace
clear



*** Code for formatting "edu_1980_spend" ***************************************
insheet using https://raw.githubusercontent.com/nikhildevmurthy/Nikhil/main/1980educationspending.csv 
// This dataset can be found in my github as "educ_spending". The reason I use import is because, for some reason, I am unable to merge this dataset with another if i use the insheet command // 
save educ_1980_spend, replace 
clear




****** Formatting for fourth Merge *********************************************
clear
use formatted_census_data.dta
decode region, generate(region_n)
save 1980_census_data, replace 
clear



****** Formatting for Fifth Merge **********************************************
insheet state year educ_spending_1981 using https://raw.githubusercontent.com/nikhildevmurthy/Nikhil/main/1981_education_spending.csv
/* education data for 1981 from the Department of Education 
source: https://www2.ed.gov/about/overview/budget/history/index.html */ //1980 – 1981 dataset // 
save fifth_merge, replace



********* Formatting for Sixth Merge *******************************************
clear
insheet using https://raw.githubusercontent.com/nikhildevmurthy/Nikhil/main/1980_unemployment%20.csv
// Source // 
save unemployment_1980, replace 
clear





**** Code for formatting using dataset *****************************************
clear
insheet State Winner using https://raw.githubusercontent.com/nikhildevmurthy/Nikhil/main/carter_v_reagan.csv
/// Source: New York Times/ Politico and https://www.presidency.ucsb.edu/statistics/elections/1980/////
/*(I mannually entered most of the data since the data is not comprehensive.) In other words, I looked at the winners of each state and manually entered them */
replace winner= "1" if winner=="Reagan" // I did this because I wanted to convert the winner variable from string to int // 
replace winner= "0" if winner=="Carter"
destring winner, generate(winner_n) force //destrings the winner variable// 
replace state = strtrim(state) 
drop in 1 // I did this because the first row had observations "State" and "winner" // 



********************************************************************************
************************** First Merge *****************************************
********************************************************************************

merge 1:1 state using formated_census_data 
tab _merge 
/* One obeservations in the master did not match because using does not have data on "District of Columbia" */
drop if _merge==1
drop _merge
/////////////////////////////// Analyzing the Data ////////////////////////////
//drop if region==2|region==3|region==4// //This is the code i used to get the below statistic // 
// summarize // Reagan won 8 out of the 9 states in the northeast //
////////////////////////////////////////////////////////////////////////////////
summarize
describe
codebook
save firstmerge, replace



********************************************************************************
************************** Second Merge *****************************************
********************************************************************************

merge 1:1 state using educ_1980_spend 
/*edu_spend_1980 is a dataset with a collection of spending by the Department of 
Education by state. Source: https://www2.ed.gov/about/overview/budget/history/index.html */
tab _merge 
/* There are 11 unmatched from using. This is because the data from the Department 
of Education has data on United States territories and a few options like "others", which
is absent from the data in the master */ 
summarize, detail
describe
codebook
/////////////// Code for analysis //////////////////////////////////////////////
/* keep in 1/51
destring ed, gen(es)ignore(",")
format es %10.2f
sum es
di %12.0f `r(mean)'
sum es
di %12.2f `r(mean)'
sum es
di %12.0f `r(mean)'
In 1980 the federal government spend an average of 59788635 on education */
drop if _merge==2
drop _merge
save second_merge, replace
clear


********************************************************************************
************************** Third Merge *****************************************
********************************************************************************

insheet using https://raw.githubusercontent.com/nikhildevmurthy/Nikhil/main/Book3.csv
/* Voter turnout data from the University of Florida. Source https://docs.google.com/spreadsheets/d/1or-N33CpOZYQ1UfZo0h8yGPSyz0Db-xjmZOXg3VJi-Q/edit#gid=1670431880
*/  
destring veptotalballotscounted, generate(total_ballots_counted) ignore(`"%"')
label variable total_ballots_counted "percent of total ballots cast" 
drop veptotalballotscounted

destring vephighestoffice, generate(highest_office_votes) ignore(`"%"')
label variable highest_office_votes "percent number of people who voted for presidential elections"
drop vephighestoffice

destring vaphighestoffice, generate(Voting_age_pop_highest_office) ignore(`"%"')
label variable Voting_age_pop_highest_office "percent of voting age population who voted in the presidential election"
drop vaphighestoffice

destring totalballotscounted, generate(raw_total_ballots_counted) ignore(`","')
label variable raw_total_ballots_counted "total number of ballots presidential and nonpresidential"
drop totalballotscounted


destring highestoffice, generate(highest_office_total) ignore(`","', illegal)
label variable highest_office_total "total number of ballots for presidential election"
drop highestoffice


destring votingeligiblepopulation_vep, generate(total_vep) ignore(`","', illegal)
label variable total_vep "total voting eligible population"
drop votingeligiblepopulation_vep


destring votingagepopulation_vap, generate(vap_total) ignore(`","', illegal)
label variable vap_total "total number of voting age population who voted"
drop votingagepopulation_vap 

destring percent_noncitizen, generate(noncitizen_vote_total) ignore(`"%"', illegal)
label variable noncitizen_vote_total "total number of non-citizen"
drop percent_noncitizen

destring prison, generate(prison_vote_total) ignore(`","', illegal)
label variable prison_vote_total "total prison population"
drop prison


destring probation, generate(probation_vote_total) ignore(`","', illegal)
label variable probation_vote_total "total number of people in probation"
drop probation


destring parole, generate(parole_vote_total) ignore(`","', illegal)
label variable parole_vote_total "total number of people on parole"
drop parole

destring totalineligiblefelon, generate(ineligible_felon) ignore(`","', illegal)
label variable ineligible_felon "total number of ineligible felons"
drop totalineligiblefelon

destring overseaseligible, generate(ocis) ignore(`","', illegal)
label variable ocis "total number of over seas citizens"
drop overseaseligible

merge 1:1 state using second_merge
tab _merge
/* From master 2 are missing because the United States is an observation and District of Columbia */
summarize, detail
describe
codebook
drop if _merge==1
save third_merge, replace






********************************************************************************
************************** Fourth Merge ****************************************
********************************************************************************
clear
insheet using https://raw.githubusercontent.com/nikhildevmurthy/Nikhil/main/Book6.csv
/* The above dataset consists of immigration data in major metro areas and regions
source: https://www.issuelab.org/resources/7352/7352.pdf */ 
rename region region_n
merge 1:m region_n using 1980_census_data
drop _merge
/* From master 2 unmatched because regions like "midwest" is not avialabe is using. 
And for using 21 unmathched because regions like N Central are not available in master */
save fourth_merge, replace 




********************************************************************************
************************** Fifth Merge / Sixth Merge ***************************
********************************************************************************
clear
use third_merge
drop _merge
merge 1:1 state using fifth_merge
/* 10 unmatched from Using because using has data on US Territories */ 
drop _merge
merge 1:1 state using unemployment_1980
drop _merge /* 9 obervations did not match from masters because the using dataset does not have US Territories. */ 
label variable educ_spending "education spending by state in 1980"
label variable educ_spend~1981 "education spending by state in 1981"
save sixth_merge, replace 
clear
insheet using https://raw.githubusercontent.com/nikhildevmurthy/Nikhil/main/pop_vote_total_1980.csv
summarize
describe
drop v10
destring total_pop_votes, generate(popular_vote_total) ignore(`","', illegal)
drop total_pop_votes
destring reagan, generate(ronald_reagan) ignore(`","', illegal)
drop reagan
destring carter, generate(jimmy_carter) ignore(`","', illegal)
drop carter
destring ja, generate(third_party) ignore(`","', illegal)
drop ja
describe
codebook 
label variable popular_vote_~l "the total popular vote by state"
label variable ev "electoral votes"
label variable third_party "third party candidate"
label variable percent_of_ja "percent of vote for third party candidate"
merge 1:1 state using sixth_merge // 9 unmatched because of US Territories // 
describe
assert year ==1980 | year ==1981
inspect year // This confirms that there is no negative numbers and everything with this variable seems to be in order // 
inspect region // There are 10 missing and 4 regions // 
inspect winner_n // There are 10 missing because of US Territories // // Carter won 6 states // 
inspect total_ball // There are no negative observations which is a good sign // 
inspect popular_vote_~l // 9 are missing because of US Territories //
inspect ronald_reagan // 9 are missing because of US Territories //
inspect jimmy_carter // Everything seems to be in order //
inspect pop // Everything seems to be in order //
inspect educ_spending  // Everything seems to be in order // 
inspect _unemployment~e // 4 integers //
inspect marriage // Everything seems to be in order // 
inspect divorce // Everything seems to be in order // 
inspect popurban // Everything seems to be in order // 
inspect medage // Normal // 

drop ocis
drop _merge
********************************************************************************
********************************************************************************
***************************** Graphs *******************************************
********************************************************************************
********************************************************************************


///// Histograms /////// I use histograms because it helps me understand my data 


*** Understanding the "total_ballot_cast" variable *****
histogram total_ball, percent normal /* Around 30 percent of American states had a 60 percent turnout rate in the 1980 election. In addition, the variable "total_ball" does
seem to fit the normal distribution curve. */
symplot total_ballots // I used this command to confirm that the data was symmetrical. //
graph export graph2.pdf 
quantile total_ballots // The data is normally distributed // 
graph export graph3.pdf
sum total_ballots, detail 
histogram total_ball, percent by(winner_n) /* 60 percent of the states that Carter won had voter turnout rates of 50% */ 
histogram highest_offic~l, percent by(winner_n) 

**** Understanding the unemployment variable ********
histogram _unemployment~e, percent normal /* 30 percent of states had an unemployment rate
of 7 percent in 1980. Plus, the data is normally distributed. */ 
symplot _unemployment~e, mlabel(state) // The data is somewhat normally distributed however there are a few outliers //  
graph box _unemployment~e, marker (1, mlabel (state)) // This box plot reaffirms that the unemployment rate for Michigan is an outlier // 
sum _unemployment~e, detail 
quantile _unemployment~e // The data is slightly negatively skewed // 
histogram _unemployment~e, percent by(winner_n) /* 50 percent of the states that Carter won had an unemployment rate of 7% */ 


***** Understanding the education_spending variables *******
histogram educ_spending, percent normal // Around 80% of the states spent between $50 million to $100 million on educational programs. // 
symplot educ_spending, mlabel (state) // The data is somewhat normally distributed although there are outliers // 
graph box educ_spending, marker (1, mlabel (state)) // This reaffirms that California, New York and Texas are outliers // 
quantile educ_spending // Data is negatively skewed // 
histogram educ_spending, percent by(winner_n) // States that Carter won spent vastly more of educational program than the states Reagan won // 


***** Understanding the popular vote variable ********
histogram popular_vote_~l, percent normal // nearly 60% of the states casted an estimate of 1 million votes //. 
symplot popular_vote_~l, mlabel (state) // The data is somewhat normally distriibuted with a few outliers
graph box popular_vote_~l, marker (1, mlabel (state)) // California, New York, and Illinois are outliers // 
quantile popular_vote_~l // Data is negatively skewed // 
hist popular_vote_~l, percent by(winner_n)


******* Understanding all the other variables **********

// Jimmy_Carter Variable // 
describe jimmy_carter
sum jimmy_carter
total jimmy_carter
hist percent_of_ca~r, percent 


// Ronald Reagan Variable // 
describe ronald_reagan
sum ronald_reagan
total ronald_reagan
hist ronald_reagan


// constrasting other variables // 
graph bar jimmy_carter ronald_reagan // Even though the popular vote between carter and reagan was close reagan won 44 states while carter only 6 // 
graph box popular_vote_~l, over(winner_n)
histogram region, discrete percent by(winner_n) // The states that carter won were mostly in south. // 
graph box total_ball highest_office_votes /* This is to compare the percent of people who voted downballot versus those who only voted for the presidential election. */ 
graph dot highest_offic~s, over(winner_n) // The mean turnout in the states Reagan won was only slightly larger then the states Carter won // 
twoway (kdensity total_ball if winner_n == 0) (kdensity total_ball if winner_n == 1), legend(label(1 "Carter") label(2 "Reagan")) /* states that Reagan won had a much higher voter turnout rate than the states Carter won */ 
graph box total_ball, by(region, note("")) over(winner_n) // This is compare boxplots by region // 


****** Scatter plots ************
scatter ronald_reagan _unemployment~e // Does not seem to be related //
scatter jimmy_carter _unemployment~e // Seems to be somewhat correlated // 
scatter highest_offic~s educ_spending, mlabel(state) // states with low education spending have a higher voter turnout rate // 
scatter total_ball educ_spending, mlabel(state) // Same this as above// 
scatter popular_vote_~l divorce // The relationship is linear // 


// Regressions // 

reg total_ball marriage 
reg highest_offic~l marriage pop // For every marriage that takes place, voter turnout decreases by -4.44 individuals, when controlling for population. 

reg highest_offic~l _unemployment~e pop winner_n 
reg highest_offic~l winner_n
scatter highest_offic~l _unemployment~e
graph bar educ_spending educ_spend~1981 // Education spending did go down in 1981 when compared with education spending in 1980 // 


 // Bivariate Regression // 
reg raw_total_bal~d educ_spending // A dollar increase in educational spending corresponds to a .02 increase in the popular vote. 90% r square // 
reg ronald_reagan _unemployment~e // A 1 percent increase in unemployment corresponed to a 110,940 voted for ronald reagan, however the r square is only 4 percent // 
reg jimmy_carter _unemployment~e // A 1 percent increase in unemployment corresponed to a 113,492 voted for jimmy carter, however the r square is only 7 percent


// Multiple Regression // 
reg jimmy_carter _unemployment~e pop educ_spending // While controlling for everything else, a unit increase in the unemployment rate corresponded to an increase of 31,773 votes for Carter // //r square - 97 // 

reg ronald_reagan _unemployment~e pop educ_spending
// While controlling for everything else, a unit increase in the unemployment rate corresponded to an increase of only 5267 votes for Reagan // //r square - 98 // 




********************************** Voter ***************************************
********************************* Turnout **************************************
******************************* Time Series ************************************
clear
insheet using https://raw.githubusercontent.com/nikhildevmurthy/Nikhil/main/voter_turnout_data.csv
// This data is from the United States Election Project //
line unitedstatesv~t unitedstatesp~o year
// Midterm and presidenital election turnout from 1800 to 2010 //










////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
/////////////////////////////END OF DO-FILE/////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
