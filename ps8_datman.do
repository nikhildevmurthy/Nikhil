// Nikkhil Dev Murthy //
// Data Management in STATA // 
// Public Affairs and Community Development //
// Problem Set 7 //
// Spring 2021 //


/* The purpose of this project is to identify the factors most useful for understanding the results of election campaigns in the United States. 

I empiracally test some of the assumptions of the Primary Model conceptualized by Helmut Norpoth in 1996. Norpoth's primary model has correctly predicted the winner of the last six presidenital elections. Retrospectively, the model has predicted the winner for all presidential elections since 1912, except the 1960 presidential election. Among the main assumptions of the primary model is the election cycle. However, the assumption that I aim to address in this part of the project is the economy-related assumption of the model. The model omits the state of the economy as a major factor because of the results of the 2000 election. I aim to empircally test this assumption. In addition, I aim to study other novel aspects of the model as well. I hope to answer the following research questions:   
       
	   1. How does the economy impact presidential elections?  
	   
	   2. How does the economy impact voter turnout? 

In this part of the project, I am focusing on finding evidence on the power of the economy to predict presidential elections */


//// Expected Contribution ///// 

/* This comprehensive dataset and research will make the following theoretical contributions to political science research. First, it will offer evidence supporting one of the most important and controversial assumption of the primary model, which is, the insignificance of the state of the economy in predicting the winner of presidenital elections. Second, it will help political scientists and campaign strategists alike to strategize and manage election campaigns by prioritizing the goals of party leaders. The biggest dataset contains 60 obervations and 47 variables // */ 

// Limitations // 
/* Short of time! Therefore didn't have the time to add more data */ 

********************************************************************************
****************************** References **************************************
********************************************************************************

/*http://www.stata-press.com/data/r8/census.dta - 1980 Census Data 
// New York Times/ Politico – Data on 1980 election results // - Election Results Data  
https://www2.ed.gov/about/overview/budget/history/index.html // 1980 – 1981 - Education Spedning Data 
https://docs.google.com/spreadsheets/d/1or-N33CpOZYQ1UfZo0h8yGPSyz0Db-xjmZOXg3VJi-Q/edit#gid=1670431880
https://www.issuelab.org/resources/7352/7352.pdf // I manually entered the data needed from the pdf // 
https://www.icip.iastate.edu/tables/employment/unemployment-states - Unemployment Data 
https://www.macrotrends.net/1319/dow-jones-100-year-historical-chart - Stock Market Data 
https://www.statista.com/statistics/1184621/presidential-election-voter-turnout-rate-state/ - Ad Spending by State Data and Voter Turnout Data  
https://worldpopulationreview.com/state-rankings/poverty-rate-by-state - Poverty Data 
http://www.electproject.org/ - On the left, there is data on voter turnout for presidential and midterm elections. 
*/ 



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
// Social Explorer did not have all the variables I needed // 
summarize
describe
codebook
replace state = "South Carolina" if state=="S. Carolina"
replace state = "South Dakota" if state=="S. Dakota"
replace state = "West Virginia" if state=="W. Virginia"
replace state = "North Carolina" if state=="N. Carolina"
replace state = "North Dakota" if state=="N. Dakota" 
decode region, generate(region_n)
save formatted_census_data, replace
save 1980_census_data, replace 
clear

////////////////////
insheet using https://raw.githubusercontent.com/nikhildevmurthy/Nikhil/main/1980educationspending.csv 
// This dataset can be found in my github as "educ_spending". 
save educ_1980_spend, replace 
clear


insheet state year educ_spending_1981 using https://raw.githubusercontent.com/nikhildevmurthy/Nikhil/main/1981_education_spending.csv
/* education data for 1981 from the Department of Education 
source: https://www2.ed.gov/about/overview/budget/history/index.html */ //1980 – 1981 dataset // 
save fifth_merge, replace

clear
insheet using https://raw.githubusercontent.com/nikhildevmurthy/Nikhil/main/1980_unemployment%20.csv 
save unemployment_1980, replace 
clear

insheet State Winner using https://raw.githubusercontent.com/nikhildevmurthy/Nikhil/main/carter_v_reagan.csv
/// Source: New York Times/ Politico and https://www.presidency.ucsb.edu/statistics/elections/1980/////
/*(I mannually entered most of the data since the data is not comprehensive.) In other words, I looked at the winners of each state and manually entered them */
replace winner= "1" if winner=="Reagan" // I did this because I wanted to convert the winner variable from string to int // 
replace winner= "0" if winner=="Carter"
destring winner, generate(winner_n) force //destrings the winner variable// 
replace state = strtrim(state) 
drop in 1 // I did this because the first row had observations "State" and "winner" // 
// 1 = if Ronald Reagan won and 0 = if Jimmy Carter // 


//// Merges //// 
merge 1:1 state using formatted_census_data 
tab _merge 
/* One obeservations in the master did not match because using does not have data on "District of Columbia" */
drop _merge
/////////////////////////////// Analyzing the Data ////////////////////////////
//drop if region==2|region==3|region==4// //This is the code i used to get the below statistic // 
// summarize // Reagan won 8 out of the 9 states in the northeast //
////////////////////////////////////////////////////////////////////////////////
summarize
describe
codebook
save firstmerge, replace
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
drop if _merge==2
drop _merge
save second_merge, replace
clear
insheet using https://raw.githubusercontent.com/nikhildevmurthy/Nikhil/main/Book3.csv
// Voter turnout data from the University of Florida. Source https://docs.google.com/spreadsheets/d/1or-N33CpOZYQ1UfZo0h8yGPSyz0Db-xjmZOXg3VJi-Q/edit#gid=1670431880 //
 

destring veptotalballotscounted, generate(total_ballots) ignore(`"%"')
label variable total_ballots "percent of total ballots cast" 
drop veptotalballotscounted

destring vephighestoffice, generate(presvotes) ignore(`"%"')
label variable presvotes "percent number of people who voted for presidential elections"
drop vephighestoffice

destring vaphighestoffice, generate(rawturnout) ignore(`"%"')
label variable rawturnout "percent of voting age population who voted in the presidential election"
drop vaphighestoffice

destring totalballotscounted, generate(rawtotalballots) ignore(`","')
label variable rawtotalballots "total number of ballots presidential and nonpresidential"
drop totalballotscounted

destring highestoffice, generate(nuofballots) ignore(`","', illegal)
label variable nuofballots "total number of ballots for presidential election"
drop highestoffice

destring votingeligiblepopulation_vep, generate(total_vep) ignore(`","', illegal)
label variable total_vep "total voting eligible population"
drop votingeligiblepopulation_vep

destring votingagepopulation_vap, generate(vap_total) ignore(`","', illegal)
label variable vap_total "total number of voting age population who voted"
drop votingagepopulation_vap 

destring percent_noncitizen, generate(noncitizenvot) ignore(`"%"', illegal)
label variable noncitizenvot "total number of non-citizen"
drop percent_noncitizen

destring prison, generate(prisonvote) ignore(`","', illegal)
label variable prisonvote "total prison population"
drop prison

destring probation, generate(probationvote) ignore(`","', illegal)
label variable probationvote "total number of people in probation"
drop probation

destring parole, generate(parolevote) ignore(`","', illegal)
label variable parolevote "total number of people on parole"
drop parole

destring totalineligiblefelon, generate(ineligible) ignore(`","', illegal)
label variable ineligible "total number of ineligible felons"
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

foreach n in year region winner_n total_ball popular_vote_~l ronald_reagan jimmy_carter pop educ_spending _unemployment~e marriage popurban medage {
	inspect `n'
}
drop ocis
drop _merge


********************************************************************************
********************************************************************************
***************************** Graphs *******************************************
********************************************************************************
********************************************************************************


// Nested Loop // 
levelsof winner, loc(winner)
levelsof region, loc(region)
foreach r in `region' {
       foreach w in `winner' {
              di "************************************"
             di "this is region `r'  and winner `w'" 
			  sum popular_vote_~l if region == `r' & winner == "`w'"
       }
}



/// Understanding my variables ////


foreach xvar in total_ball presvotes _unemployment~e educ_spending popular_vote_~l {
	hist `xvar', percent normal 
gr export `xvar'.pdf, replace 
}

foreach nvar in total_ball presvotes _unemployment~e educ_spending popular_vote_~l {
	symplot `nvar'
gr export `nvar'.pdf, replace 
}

foreach avar in total_ball presvotes _unemployment~e educ_spending popular_vote_~l {
	quantile `avar'
gr export `avar'.pdf, replace 
}

foreach bvar in total_ball presvotes _unemployment~e educ_spending popular_vote_~l {
	hist `bvar', percent by(winner_n)  
gr export `bvar'.pdf, replace 
}






//******* Understanding all the other variables using **********//


foreach cvar in jimmy_carter ronald_reagan {
	des `cvar' 
	sum `cvar'
	hist `cvar', percent 
	gr export `cvar'.pdf, replace  
	total `cvar'
}


// constrasting other variables // 
graph bar jimmy_carter ronald_reagan // Even though the popular vote between carter and reagan was close reagan won 44 states while carter only 6 // 
graph export graph23.pdf, replace
graph box popular_vote_~l, over(winner_n)
graph export graph24.pdf, replace
histogram region, discrete percent by(winner_n) // The states that carter won were mostly in south. // 
graph export graph25.pdf, replace
graph box total_ball presvotes /* This is to compare the percent of people who voted downballot versus those who only voted for the presidential election. */ 
graph export graph26.pdf, replace
graph dot presvotes, over(winner_n) // The mean turnout in the states Reagan won was only slightly larger then the states Carter won //
graph export graph27.pdf, replace 
twoway (kdensity total_ball if winner_n == 0) (kdensity total_ball if winner_n == 1), legend(label(1 "Carter") label(2 "Reagan")) /* states that Reagan won had a much higher voter turnout rate than the states Carter won */ 
graph export graph28.pdf, replace
graph box total_ball, by(region, note("")) over(winner_n) // This is compare boxplots by region // 
graph export graph29.pdf, replace


//****** Scatter plots ************//
scatter ronald_reagan _unemployment~e // Does not seem to be related //
graph export graph30.pdf, replace
scatter jimmy_carter _unemployment~e // Seems to be somewhat correlated //
graph export graph31.pdf, replace 
scatter presvotes educ_spending, mlabel(state) // states with low education spending have a higher voter turnout rate // 
graph export graph32.pdf, replace
scatter total_ball educ_spending, mlabel(state) // Same this as above// 
graph export graph33.pdf, replace
scatter popular_vote_~l divorce // The relationship is linear // 
graph export graph34.pdf, replace 


//// Scatter Plots using Loops //// 
foreach var in ronald_reagan jimmy_carter {
scatter _unemployment~e `var'
graph export _unemployment~e`var'.pdf, replace 

}

foreach var in presvotes popular_vote_~l percent_of_re~n percent_of_ca~r {
scatter _unemployment~e `var'
graph export _unemployment~e`var'.pdf, replace 

}


scatter presvotes _unemployment~e
graph export graph35.pdf, replace
graph bar educ_spending educ_spend~1981 // Education spending did go down in 1981 when compared with education spending in 1980 // 
graph export graph36.pdf, replace



// Bivariate Regression // 
reg rawtotalballots educ_spending // A dollar increase in educational spending corresponds to a .02 increase in the popular vote. 90% r square // 
reg ronald_reagan _unemployment~e // A 1 percent increase in unemployment corresponed to a 110,940 voted for ronald reagan, however the r square is only 4 percent // 
reg jimmy_carter _unemployment~e // A 1 percent increase in unemployment corresponed to a 113,492 voted for jimmy carter, however the r square is only 7 percent


loc x _unemployment~e pop educ_spending
reg jimmy_carter `x' //While controlling for everything else, a unit increase in the unemployment rate corresponded to an increase of 31,773 votes for Carter // //r square - 97 // 
reg ronald_reagan `x' // While controlling for everything else, a unit increase in the unemployment rate corresponded to an increase of only 5267 votes for Reagan // //r square - 98//
// Multiple Regression // 
//reg jimmy_carter _unemployment~e pop educ_spending //
// reg ronald_reagan _unemployment~e pop educ_spending /
save compre_dataset, replace


/********************************** Voter ***************************************
********************************* Turnout **************************************
******************************* Time Series ************************************/
clear
insheet using https://raw.githubusercontent.com/nikhildevmurthy/Nikhil/main/voter_turnout_data.csv
// This data is from the United States Election Project //
line unitedstatesv~t unitedstatesp~o year
// Midterm and presidenital election turnout from 1800 to 2010 //
drop year  
drop unitedstatesv~t
save timeline, replace 
clear


/************************ /////////////////////////// ***************************/
clear 
insheet using https://raw.githubusercontent.com/nikhildevmurthy/Nikhil/main/1984_election_data.csv
describe

//////// LOOP ////////////
foreach var in using {
	drop v10 v11 v12 v13 v14 v15 v16 v17 v18
}



///// END OF LOOP //////

destring total_votes, generate(total_votes_1984) ignore(`","')
destring reagan_1984, generate(reagan_votes) ignore(`","')
destring mondale_1984, generate(modale_votes) ignore(`","')
destring percent_of_votes_mondale, generate(percent_mondale) force
sum 
describe
drop total_votes
drop reagan_1984
drop mondale_1984
drop percent_of_vo~e
des 
label variable winner "winner of the 1984 presidential election"
label variable total_vote~1984 "popular vote by state"
label variable reagan_votes "total number of votes reagan received"
label variable percent_of_vo~n "percent of votes reagan received"
label variable ev_reagan "total electoral votes reagan received"
label variable modale_votes "total number of votes mondale received" 
label variable percent_mondale "percent of votes mondale received"
label variable ev_mondale "total electoral votes mondale received"
des
merge 1:1 state using comp_dataset
drop in 1
drop _merge 
save comp_dataset, replace // This dataset contains 60 obervations and 47 variables // 



/// Comparing Stock Market Trends and Voter Turnout /// 
clear 
insheet using https://raw.githubusercontent.com/nikhildevmurthy/Nikhil/main/stock_market_timeline.csv
destring date, generate(date_n) ignore(`"/"')
generate newvar = date_n-12110
drop in 85/106
generate Year = newvar+1910
line value Year // Historical graph of the Dow Jones Industrial Average // 
merge 1:m Year using timeline // 21 Matched because presidenital elections take place every four years // 
line value Year  
drop date 
drop date_n
drop newvar
drop _merge 
drop in 85/121
line value Year 
line unitedstatesp~o Year // Voter turnout for presidenital elections // 
line value unitedstatesp~o Year
correlate unitedstatesp~o value // There is no corrrelation // // This provides evidence to support the assumption that the economy does NOT play an important role in which party wins the white house // 
save stock_market_presidenital, replace 
twoway dropline value Year
graph export dow.pdf, replace


//// New Dataset /// This Dataset containes the information on the party that won each presidential election //  
clear 
insheet using https://raw.githubusercontent.com/nikhildevmurthy/Nikhil/main/timeline_party.csv
describe
rename yearofelection Year 
merge 1:1 Year using stock_market_presidenital // 21 merged //
drop _merge 
encode party, gen(party_n) // "party" is a variable that consists of the party of each individual who won the white house // 
rename unitedstatesp~o vep_turnout
reg vep_turnout party_n value // The year in which a republican won the white house saw a voter turnout rate lower than when a democrat won the white house when controlling for the dow jones // 


// 2020 Election Ad spending aginst voter turnout // 
clear 
insheet using https://raw.githubusercontent.com/nikhildevmurthy/Nikhil/main/ad_spending.csv
rename v1 state 
rename v2 money
drop in 1
destring money, generate(money_n) ignore(`","')
drop money
save ad_spending, replace
clear 
insheet using https://raw.githubusercontent.com/nikhildevmurthy/Nikhil/main/2020_turnout.csv
merge 1:1 state using ad_spending 
keep if money_n <50000
describe
scatter money_n percent_turnout_2020, mlabel(state)
cor money_n percent_turnout_2020
graph box money_n 
graph box percent_turnout_2020


// Unemployment and Voter Turnout // 
clear 
insheet using https://raw.githubusercontent.com/nikhildevmurthy/Nikhil/main/2020_turnout.csv //Dataset of the top ten states that received the largest amount of money for ads // 
rename percent_tu~2020 turnout
save 2020_turnout, replace 
des 
clear
insheet using https://raw.githubusercontent.com/nikhildevmurthy/Nikhil/main/unem_2020.csv
rename v1 state 
drop in 1
destring v8, generate(unem) ignore(`"%"')
merge 1:1 state using 2020_turnout 
scatter unem turnout
cor unem turnout // Further evidence that the economy has little impact in voter turnout 
save 2020economy, replace 



// Comparing Poverty Rate and Voter Turnout // 
clear 
insheet using https://raw.githubusercontent.com/nikhildevmurthy/Nikhil/main/csvData.csv
describe 
gen pov_n = povertyrate*100
drop povertyrate
encode state, gen(state_n)
scatter pov_n state_n, mlabel(state)
merge 1:1 state using 2020_turnout // 50 Matched // 
drop _merge 
scatter pov_n turnout
cor pov_n turnout // Voter turnout and poverty is somewhat negatively coorelated to each other but still is inconclusive. Further research, adding more variables, and running regressions can strenghten these findings // 

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
/////////////////////////////END OF DO-FILE/////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
