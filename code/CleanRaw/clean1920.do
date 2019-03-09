* CLEAN 1920 FULL COUNT CENSUS DATA ON NBER SERVER
* FOR LINKING CENSUSES
* NEED CODE FROM RAN ABRAMITZKY AND LEAH BOUSTAN GROUP
* emily eisner, emily.eisner@berkeley.edu


* DIRECTORIES
global ados "/disk/homedirs/nber/eisere/censusLinking/code/BorrowedCode/ABE_algorithm_code"
global home "/disk/homedirs/nber/eisere"
global temp "/homes/nber/eisere/bulk/cens1930.work/temp"
global input "/homes/nber/eisere/bulk/cens1930.work/input"
global output "/homes/nber/eisere/bulk/cens1930.work/output"


* LOOP OVER 100 FILES

foreach fi of numlist 1/100 {

* IMPORT DATA
*local fi 1
use bpl namefrst namelast age birthyr year race sex ///
    using /homes/data/cens1930/20160914/100files/us1920c_usa`fi'.dta, clear

* CLEAN NAMES 
*cd $ados
*abeclean namefrst namelast, sex(sex) initial(middleinitial) //fix nickname problem?


* SAVE AS CSV
export delimited using $input/census1920_`fi'.csv, replace delim(tab)

}
