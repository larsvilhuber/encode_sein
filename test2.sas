%let encryptlen=10;
%include "sein-encrypt-function.sas";

/* testing */
data one;
  uiacct="1234567890";
  output;
  uiacct="12345678AZ";
  output;
run;

/* %let keyval=1A2B3C4D5Z;*/
%let keyval=1A2B3C4D5E;

%let encryptlen=10;

** test: encrypt and decrypt sample strings;
data two;
    set one;
	sein=padendcrypt(uiacct,"&keyval",1);
	c=padendcrypt(sein,"&keyval",-1);
;
run;

proc print data=two;
title "Keyval=&keyval.";
run;
