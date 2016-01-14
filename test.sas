%include "encode_sein.sas";

/* testing */
data one;
  uiacct="1234567890";
  output;
  uiacct="12345678AZ";
  output;
run;

%let keyval=1A2B3C4D5Z;
%encode_sein(indb=one,outdb=two,invar=uiacct,override=&keyval.);

proc print data=two;
title "Keyval=&keyval.";
run;
