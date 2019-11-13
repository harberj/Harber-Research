/*
Jack Harber
5 October 2019

This do-file is called cleaning.do

First, we are cleaning the 2013-2017 American Community Survey 5-Year Estimates for 
Selected Economic Characteristics. This dataset has the economic characteristic
estimates for each county in the United States. We only want the percapita 
income for each county.

There are hundreds of variables in this dataset, but we will delete all but two

*/

clear all
version 16.0
cd "C:\Users\harberj\Desktop\ECON 56200\Harber Research\Cleaning Do-File"

/*
Using our zip code dataset
*/

use "C:\Users\harberj\Desktop\ECON 56200\Harber Research\Import Do-File\county.dta"

/*
Only keeping the County, FIPs, and per capita variable
*/

keep id2 geography v352 

// We can now rename our percapita variable and fips variable
rename id2 stcountyfp
rename v352 percapita

// Next we merge the zipstofips dataset with this dataset
merge 1:m stcountyfp using "C:\Users\harberj\Desktop\ECON 56200\Harber Research\Import Do-File\zipsfips.dta"

keep if _merge == 3
drop _merge countyname state classfp

save fips, replace

/*
This gives us multiple zipcodes for each county. We then have to merge with the
zip codes given in the schoolinfo dataset so that we only keep the correct zipcodes
*/

/*
Second, we are cleaning the schoolregion.dta file. We only need to keep the school
name, region, and starting median salary
*/

clear all

use "C:\Users\harberj\Desktop\ECON 56200\Harber Research\Import Do-File\schoolregion.dta"

/*
Only keeping three variables and renaming them appropriately
*/

keep SchoolName Region StartingMedianSalary
rename SchoolName school
rename Region region
rename StartingMedianSalary startsalary

/*
This is for the manually matching
*/
sort school
gen match = 0
replace match = _n
order match school

save region, replace
clear all

/*
Third, we are cleaning the schoolinfo.dta file. This dataset has much more info
that will be useful. We still only keep certain variables
*/

use "C:\Users\harberj\Desktop\ECON 56200\Harber Research\Import Do-File\schoolinfo.dta"

/*
Dropping irrelevant variables
*/

drop Column1rankingNoteText Column1nonResponderText Column1nonResponder ///
Column1primaryPhoto Column1primaryPhotoThumb Column1rankingNoteCharacter ///
Column1hsgpaavg Column1urlName Column1rankingDisplayName Column1sortName ///
Column1rankingDisplayRank Column1ranking Column1xwalkId Column1rankingIsTied ///
Column1isPublic Column1businessRepScore Column1engineeringRepScore ///
Column1schoolType Column1region Column1aliasNames Column1rankingType ///
Column1rankingMaxPossibleScore Column1rankingRankStatus Column1primaryKey ///
Column1overallRank

rename Column1actavg actavg
rename Column1satavg satavg
rename Column1enrollment enrollment
rename Column1city city
rename Column1zip zip
rename Column1acceptancerate acceptance
rename Column1rankingDisplayScore score
rename Column1percentreceivingaid percentaid
rename Column1costafteraid costafteraid
rename Column1state state
rename Column1rankingSortRank rank
rename Column1tuition tuition 
rename Column1displayName school
rename Column1institutionalControl public

/*
Changing the public variable into a dummy
*/
replace public = "1" if public == "public"
replace public = "0" if public == "private"
replace public = "" if public == "proprietary"

destring(public), replace
destring(zip), replace

save info, replace

/*
We have cleaned all four of our important data sets. Now it is time to merge
the datasets together so that we can run regression analysis.
*/

/*
We merge "info" and our "county" datasets together and only keep the matches.
*/

joinby zip using "C:\Users\harberj\Desktop\ECON 56200\Harber Research\Cleaning Do-File\fips.dta"

/*
We had to use joinby because some of the zipcodes correspond to more than one 
county. Thus, if the zipcode corresponds to mulitple counties, we take an average
of income of the counties with that zipcode to give us a more accurate income 
measure
*/

sort zip school
egen totalpercapita = sum(percapita), by(zip)
egen numberzip = count(percapita), by(zip)
gen averagepercapita = totalpercapita / numberzip
drop if zip == zip[_n-1] & school == school[_n - 1]

/*
Unfortunately,
the only identifier for the "region" dataset is the university name. Because this
will not match well, we will need to manually match these universities. However,
this should not take too long since there are only about 150-200 universities.
*/



/*
First, we try to match on name, but some will not match.
*/
merge 1:1 school using "C:\Users\harberj\Desktop\ECON 56200\Harber Research\Cleaning Do-File\region.dta"
drop if _merge == 2
drop _merge

/*
Next, we sort our dataset so that we can manually match our universities.
*/

/*
match will be the variable that we will merge on, and we need to manually edit
it for all universities that match in the manual phase
*/

gsort -startsalary school city state 
order school city state match

replace match = 2 if school == "American University"
replace match = 9 if school == "Ball State University"
replace match = 12 if school == "Binghamton University--SUNY"
replace match = 29 if school == "California State University--Fullerton"
replace match = 34 if school == "Carnegie Mellon University"
replace match = 58 if school == "East Carolina University"
replace match = 66 if school == "Florida Atlantic University"
replace match = 74 if school == "George Washington University"
replace match = 89 if school == "Illinois Institute of Technology"
replace match = 91 if school == "Indiana University--Bloomington"
replace match = 97 if school == "Kansas State University"
replace match = 107 if school == "Louisiana State University--Baton Rouge"
replace match = 109 if school == "Massachusetts Institute of Technology"
replace match = 115 if school == "Mississippi State University"
replace match = 124 if school == "New York University"
replace match = 129 if school == "Northern Illinois University"
replace match = 133 if school == "Ohio State University--Columbus"
replace match = 137 if school == "Oregon State University"
replace match = 141 if school == "Pennsylvania State University--University Park"
replace match = 150 if school == "Purdue University--West Lafayette"
replace match = 155 if school == "Rensselaer Polytechnic Institute"
replace match = 159 if school == "Rochester Institute of Technology"
replace match = 161 if school == "Rutgers University--New Brunswick"
replace match = 165 if school == "San Francisco State University"
replace match = 174 if school == "Southern Illinois University--Carbondale"
replace match = 190 if school == "Stony Brook University--SUNY"
replace match = 197 if school == "Texas Christian University"
replace match = 180 if school == "University at Albany--SUNY"
replace match = 181 if school == "University at Buffalo--SUNY"
replace match = 213 if school == "University of California--Berkeley"
replace match = 214 if school == "University of California--Davis"
replace match = 212 if school == "University of California--Los Angeles"
replace match = 219 if school == "University of California--Santa Cruz"
replace match = 223 if school == "University of Connecticut"
replace match = 226 if school == "University of Georgia"
replace match = 227 if school == "University of Hawaii--Manoa"
replace match = 230 if school == "University of Illinois--Chicago"
replace match = 231 if school == "University of Illinois--Urbana-Champaign"
replace match = 232 if school == "University of Iowa"
replace match = 234 if school == "University of Kentucky"
replace match = 236 if school == "University of Maryland--Baltimore County"
replace match = 237 if school == "University of Maryland--College Park"
replace match = 238 if school == "University of Massachusetts--Amherst"
replace match = 239 if school == "University of Massachusetts--Boston"
replace match = 240 if school == "University of Massachusetts--Dartmouth"
replace match = 241 if school == "University of Massachusetts--Lowell"
replace match = 242 if school == "University of Memphis"
replace match = 243 if school == "University of Michigan--Ann Arbor"
replace match = 244 if school == "University of Minnesota--Twin Cities"
replace match = 247 if school == "University of Missouri--Kansas City"
replace match = 249 if school == "University of Missouri--St. Louis"
replace match = 255 if school == "University of New Hampshire"
replace match = 267 if school == "University of Rhode Island"
replace match = 270 if school == "University of South Florida"
replace match = 271 if school == "University of Southern California"
replace match = 274 if school == "University of Texas--Austin"
replace match = 277 if school == "University of Texas--San Antonio"
replace match = 281 if school == "University of Vermont"
replace match = 282 if school == "University of Virginia"
replace match = 283 if school == "University of Washington"
replace match = 287 if school == "University of Wisconsin--Madison"
replace match = 305 if school == "Washington State University"
replace match = 314 if school == "Western Michigan University"
replace match = 319 if school == "Worcester Polytechnic Institute"
replace match = 5 if school == "Arizona State University--Tempe"
replace match = 14 if school == "Boise State University"
replace match = 20 if school == "Brigham Young University--Provo"
replace match = 24 if school == "California Institute of Technology"
replace match = 43 if school == "Colorado State University"
replace match = 67 if school == "Florida International University"
replace match = 69 if school == "Florida State University"
replace match = 111 if school == "Michigan State University"
replace match = 118 if school == "Montana State University"
replace match = 127 if school == "North Dakota State University"
replace match = 146 if school == "Portland State University"
replace match = 164 if school == "San Diego State University"
replace match = 173 if school == "South Dakota State University"
replace match = 177 if school == "St. John's University"
replace match = 196 if school == "Texas A&M University--College Station"
replace match = 215 if school == "University of California--Irvine"
replace match = 216 if school == "University of California--Riverside"
replace match = 217 if school == "University of California--San Diego"
replace match = 218 if school == "University of California--Santa Barbara"
replace match = 220 if school == "University of Central Florida"
replace match = 221 if school == "University of Colorado--Boulder"
replace match = 222 if school == "University of Colorado--Denver"
replace match = 225 if school == "University of Florida"
replace match = 228 if school == "University of Houston"
replace match = 235 if school == "University of Louisiana--Lafayette"
replace match = 246 if school == "University of Missouri"
replace match = 251 if school == "University of Nebraska--Lincoln"
replace match = 252 if school == "University of Nebraska--Omaha"
replace match = 253 if school == "University of Nevada--Las Vegas"
replace match = 254 if school == "University of Nevada--Reno"
replace match = 257 if school == "University of New Mexico"
replace match = 258 if school == "University of North Carolina--Chapel Hill"
replace match = 259 if school == "University of North Carolina--Charlotte"
replace match = 275 if school == "University of Texas--Arlington"
replace match = 276 if school == "University of Texas--El Paso"
replace match = 288 if school == "University of Wisconsin--Milwaukee"
replace match = 295 if school == "University of Wyoming"
replace match = 302 if school == "Virginia Commonwealth University"
replace match = 311 if school == "West Virginia University"

/*
After manually matching, I went back through again to verify I had the correct
values. I found no errors.
*/
drop if match == .
drop region startsalary

merge 1:1 match using "C:\Users\harberj\Desktop\ECON 56200\Harber Research\Cleaning Do-File\region.dta"

keep if _merge == 3
drop _merge match city state actavg satavg zip score percentaid costafteraid ///
rank stcountyfp geography percapita totalpercapita numberzip region enrollment
rename averagepercapita percapita

label variable school "School"
label variable acceptance "Acceptance Rate"
label variable tuition "Tuition"
label variable public "Public"
label variable percapita "Per Capita Income"
/*
Lastly, we want to create log forms for our variables in dollars for they 
may be useful in the regression.
*/
gen logtuition = log(tuition)
gen logpercapita = log(percapita)
gen logsalary = log(startsalary)

label variable logpercapita "log(Per Capita Income)"

/*
We have finished cleaning our dataset. This will be the only dataset used in
our regression analysis, as it is the merged dataset of four datasets
*/

save final, replace


