Select all records where categories have total frequencies greater than 10

Same result in WPS and SAS

Nice solutions by Paul Dorphman

github
https://tinyurl.com/ybxj74wa
https://github.com/rogerjdeangelis/utl_select_all_records_where_categories_have_total_frequencies_greater_than_10

see
https://tinyurl.com/y9hmly76
https://stackoverflow.com/questions/50778942/bucketing-data-and-selecting-only-some-of-the-bucketed-values

Pauls profile
https://stackoverflow.com/users/9926681/sashole

INPUT
=====

 CATEGORY    VALUE    FREQUENCY

    A         RED          6  keep
    A         RED          7  keep 6+7>10

    A         GREEN        4  remove because sum freq<=10

    A         BLUE        12  keep

    B         RED          9  remove

    B         BROWN        6  keep
    B         BROWN        5  keep 5+6=11

    B         ORANGE      14  keep

 EXAMPLE OUTPUT

 CATEGORY    VALUE     FREQUENCY

    A        BLUE          12

    A        RED            7
    A        RED            6

    B        BROWN          5
    B        BROWN          6

    B        ORANGE        14


PROCESS   ( I commented Paus Code)
===================================

data want (drop = _:) ;

  * load keys in order;
  dcl hash h (ordered:"a") ;
  h.definekey ("category", "value") ;

  * variable for sum;
  h.definedata ("_fsum") ;
  h.definedone () ;

  * sum by key look;
  do until (last) ;

    set have end = last ;

    * if new key then inialize frequency else cumulate frequency;;
    if h.find() ne 0 then _fsum = frequency ;
    else _fsum + frequency ;
    h.replace() ;

  end ;

  * cycle until no keys left;
  do until (0) ;
    set have ;
    h.find() ;
    if _fsum > 10 then output ;
  end ;

run;quit;


OUTPUT
======
 Up to 40 obs WORK.WANT total obs=6

 Obs    CATEGORY    VALUE     FREQUENCY

  1        A        RED            6
  2        A        RED            7
  3        A        BLUE          12
  4        B        BROWN          6
  5        B        BROWN          5
  6        B        ORANGE        14

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

data have;
input Category $ Value $ Frequency;
cards4;
 A RED 6
 A RED 7
 A GREEN 4
 A BLUE 12
 B RED 9
 B BROWN 6
 B BROWN 5
 B ORANGE 14
;;;;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;
* WPS;
%utl_submit_wps64('
libname wrk sas7bdat "%sysfunc(pathname(work))";
data want (drop = _:) ;
  dcl hash h (ordered:"a") ;
  h.definekey ("category", "value") ;
  h.definedata ("_fsum") ;
  h.definedone () ;
  do until (last) ;
    set wrk.have end = last ;
    if h.find() ne 0 then _fsum = frequency ;
    else _fsum + frequency ;
    h.replace() ;
  end ;
  do until (0) ;
    set wrk.have ;
    h.find() ;
    if _fsum > 10 then output ;
  end ;
run;quit;
proc print;
run;quit;
');

