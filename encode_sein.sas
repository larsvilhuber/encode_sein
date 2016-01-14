/* The following macro will encode a arbitrary length string, in a variable,
   with a one-time pad. The key will be read from either a database, or
   can be provided as an argument (override=). */
/* ASCII table: http://www.asciitable.com/ */

%macro encode_sein(indb=,invar=,
                   outdb=,outvar=sein,
                   keylib=CONTROL,keydb=parms_us_seins,
                   keyvar=seinkey,
                   override=);

%local errorcode;
%let errorcode=0;

/* validation */
%if ( "&indb." = "" ) %then %do;
  %put DIAGNOSTICS: %upcase(error): Please specify INDB= for database to encode;
  %let errorcode=%eval(&errorcode.+1);
  %end;
%if ( "&invar." = "" ) %then %do;
  %put DIAGNOSTICS: %upcase(error): Please specify INVAR= for database to encode;
  %let errorcode=%eval(&errorcode.+2);
%end;



/* check length of invar */
proc contents data=&indb.(keep=&invar.) out=tmp noprint;
run;

data _null_;
  set tmp;
  call symput('inlength',trim(left(length)));
  call symput('intype',trim(left(type)));
run;

%put DIAGNOSTICS: Variable &invar. has length &inlength. and is of type &intype.;
%if ( "&intype" ne "2" ) %then %do;
  %put DIAGNOSTICS: %upcase(error): &invar. should be character.;
  %let errorcode=%eval(&errorcode.+4);
%end;


/* check length of key */
%if ( "&override" ne "" ) %then %do;
  %put DIAGNOSTICS: Override specified, creating temporary keydb;
  %let keylib=WORK;
  %let keydb=keydb;

  data keydb;
    &keyvar.="&override.";
    output;
  run;
%end; /* end override condition */

/* TODO: test for presence of KEYDB */
proc contents data=&keylib..&keydb.(keep=&keyvar.) out=tmp noprint;
run;

data _null_;
  set tmp;
  call symput('keylength',trim(left(length)));
  call symput('keytype',trim(left(type)));
run;


%put DIAGNOSTICS: Variable &keyvar. has length &keylength. and is of type &keytype.;
%if ( "&keytype" ne "2" ) %then %do;
  %put DIAGNOSTICS: %upcase(error): &keyvar. should be character.;
  %let errorcode=%eval(&errorcode.+8);
%end;

%if ( "&keylength" ne "&inlength" ) %then %do;
  %put DIAGNOSTICS: %upcase(error): Key length &keylength. should be equal to length(&invar). = &inlength.;
  %let errorcode=%eval(&errorcode.+16);
%end;
%else %do;
%put DIAGNOSTICS: OK: Key length &keylength. is equal to length(&invar.)=&inlength.;
%end;


/*============= end error checking, now act on it =============*/
%if ( &errorcode > 0 ) %then %do;
%put ERROR: &errorcode;
data _null_;
  call execute("endsas;");
  run;
%end;

/*=============== end error check =======================*/
data _null_;
  set &keylib..&keydb.(keep=&keyvar.);
  call symput('keyval',trim(left(&keyvar.)));
run;

data &outdb.;
  set &indb.;
  length &outvar. tmpkey $ &inlength.;
  array inchar (&inlength) _TEMPORARY_;
  array outchar (&inlength) _TEMPORARY_;
  array keychar (&inlength) _TEMPORARY_;
  drop i tmpchar tmpkey;
  do i = 1 to &inlength.;
    tmpchar=upcase(substr(&invar.,i,1));
    tmpkey=upcase(substr("&keyval.",i,1));
    inchar(i)=(rank(tmpchar)-48)*(48<=rank(tmpchar)<58)
              +(rank(tmpchar)-65+10)*(65<=rank(tmpchar)<91);
    keychar(i)=(rank(tmpkey)-48)*(48<=rank(tmpkey)<58)
              +(rank(tmpkey)-65+10)*(65<=rank(tmpkey)<91)
              +inchar(i);
    if keychar(i)>=36 then keychar(i)=keychar(i)-36;
    outchar(i)=(keychar(i)+48)*(0<=keychar(i)<10)
                + (keychar(i)+65-10)*(10<=keychar(i)<36);
    put inchar(i)= outchar(i)= ;
    /* construct the output variable */
    substr(&outvar.,i,1)=byte(outchar(i));
  end;


%mend;
