/*
Jack Harber
5 October 2019

This do-file is called importing.do-file

We are importing mainly Excel and CSV files and converting these into DTA files
for Stata. The converted files will be save in the folder Importable Data Files.
*/

clear all
version 16.0
cd "C:\Users\harberj\Desktop\ECON 56200\Harber Research\Import Do-File"

/*
First, importing our US Census Bureau Data Source
*/

import delimited "C:\Users\harberj\Desktop\ECON 56200\Harber Research\Importable Data Files\county.csv"

save county, replace
clear all

/*
Next, importing our School Info data
*/

import excel "C:\Users\harberj\Desktop\ECON 56200\Harber Research\Importable Data Files\schoolInfo.xlsx", ///
sheet("Sheet1") firstrow

save schoolinfo, replace
clear all

/*
Next, importing our ZipCode and County identifiers dataset
*/
import delimited "C:\Users\harberj\Desktop\ECON 56200\Harber Research\Importable Data Files\zipstofips.csv"

save zipsfips, replace
clear all

/*
Lastly, importing our School Region data
*/

import excel "C:\Users\harberj\Desktop\ECON 56200\Harber Research\Importable Data Files\schoolregion.xlsx", ///
sheet("salaries-by-region") firstrow

save schoolregion, replace
