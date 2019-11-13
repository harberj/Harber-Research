/*
Jack Harber
10 October 2019

This do-file is called results.do
*/

clear all
version 16.0
cd "C:\Users\harberj\Desktop\ECON 56200\Harber Research\Results Do-File"
use "C:\Users\harberj\Desktop\ECON 56200\Harber Research\Cleaning Do-File\final.dta"

/*
First, I run summary statistics of my variables. This will be Table 1 in my
paper and will be on page 2 under the section Data.
*/
estpost summarize acceptance tuition public percapita startsalary
eststo: esttab, cells("count mean sd min max") noobs

esttab using summarystatistics.tex, modelwidth(10 20) cell((count(label(Count)) mean(label(Mean)) sd(par label(Standard Deviation)) min(label(Minimum)) max(label(Maximum)))) label title(Summary Statistics) nonumber replace

/*
Next, I check for correlation between my variables of interest to (1) see if
there is perfect collinearity and (2) verify that they are correlated with 
each other. For (2), this is the reason why I included acceptance rate, public,
and startsalary in the primary regression equation.
*/

eststo: estpost correlate percapita acceptance public startsalary, matrix listwise

esttab using correlation.tex, replace unstack not noobs compress label title(Correlation of Key Variables) nonumber

/*
We will be running regression analysis on our dataset. The first step will
be to run the regression. The second step will be to verify that there is
not heteroskedasticity. The third step will be to verify that it is in the
correct functional form. The fourth step will be to verify that both public
and private universities follow the same regression model.
*/

/*
Step 1: Multiple Regression
Our regression equation is:

logtuition = B_0 + B_1 * logpercapita +  B_2 * startsalary 
			+ B_3 * acceptance + B_4 * public + B_5 * salary2
*/

/*
Using our cleaned final dataset, we run our regression  
*/
gen salary2 = startsalary^2
label variable salary2 "Salary^2"

reg logtuition logpercapita startsalary acceptance public salary2

/*
Step 2: Homoskedasticity?
We try Breusch-Pagan Test and the Special Case for White
*/

/*
First up, Breusch-Pagan Test. This will be Table 2 in my
paper and will be on page 3 under the section Methodology.
*/

predict uhat, resid
gen uhat2 = uhat^2
eststo: reg uhat2 logpercapita startsalary acceptance public salary2

esttab est3 using "bp_test.tex", label title(Breusch-Pagan Test) nonumbers mtitles("Model 1" "Model 2" ) scalars(F p) replace 

/*
Using Breusch-Pagan, we find that the F-Statistic is .94 with a p-value 
of .4595. Thus, we fail to reject the null hypothesis of homoskedasticity
*/

/*
Second up, Special White Test. This will be Table 3 in my
paper and will be on page 3 under the section Methodology.
*/

drop uhat uhat2
reg logtuition logpercapita startsalary acceptance public salary2
predict yhat, xb
gen yhat2 = yhat^2
predict uhat, resid
gen uhat2 = uhat^2

eststo: reg uhat2 yhat yhat2

esttab est4 using "white_test.tex", label title(Special White Test) nonumbers mtitles("Model 1" "Model 2" ) scalars(F p) replace 


/*
Using the Special Case for White, we find that F-Statistic is .49 with 
a p-value of .6142. Thus, we fail to reject the null hypothesis of homoskedasticity
*/

/*
Step 3: Functional Form Misspecification?
We apply Ramsey RESET
*/

/*
This will be Table 4 in my paper and will be on page 3 under the section Methodology.
*/


drop uhat uhat2 yhat yhat2
reg logtuition logpercapita startsalary acceptance public salary2
predict yhat, xb
gen yhat2 = yhat^2
gen yhat3 = yhat^3
reg logtuition logpercapita startsalary acceptance public salary2 yhat2 yhat3

test yhat2 yhat3

eststo, add(p_diff r(p))
esttab est5 using "reset.tex", replace stat(p_diff) label title(Ramsey RESET)
drop yhat yhat2 yhat3

/*
We obtain an F-Statistic of .38 with a p-value of .6812, thus, our functional
form is okay
*/

/*
Step 4: Chow Test? 
We allow for an intercept difference
*/

/*
This will be Table 5 in my paper and will be on page 3 under the section Methodology.
*/

gen public_logpercapita = public * logpercapita
gen public_startsalary = public * startsalary
gen public_acceptance = public * acceptance
gen public_salary2 = public * salary2

reg logtuition logpercapita startsalary acceptance public salary2 public_logpercapita public_startsalary public_acceptance public_salary2

test public_logpercapita public_startsalary public_acceptance public_salary2

eststo, add(p_diff r(p))
esttab est6 using "chow_test.tex", replace stat(p_diff) label title(Chow Test)
drop public_logpercapita public_startsalary public_acceptance public_salary2

/*
We obtain an F-Statistic of .40 with a p-value of .8073, thus, we fail to reject then null hypothesis that both public and private universities follow 
the same regression model
*/

/*
Now, it is time to run the regression
*/

eststo: reg logtuition logpercapita startsalary acceptance public salary2

esttab est7 using "regression.tex", label title(Regression Results) nonumbers mtitles("Model 5") addnote("Standard errors in parentheses" "* p<0.1, ** p<0.05, *** p<0.01") r2 c(b(star fmt(4)) se(par fmt(4))) starl(* .1 ** .05 *** .01) replace 
