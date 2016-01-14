options nocenter;

*** define function to encrypt and decrypt account number **;

proc fcmp outlib=here.funcs.encrypt;
	function padendcrypt(in $,key $,direction) $ &encryptlen;
		allvals=catt(collate(rank('0'),rank('9')),collate(rank('A'),rank('Z')));
		key2=inputc(key,catt("$hex",&encryptlen.));
		do i=1 to length(in);
			cindx=find(allvals,char(in,i));
			if cindx>0 then do;
				c2indx=mod(cindx-1+length(allvals)+rank(char(key2,i))*direction,length(allvals))+1;
				substr(in,i,1)=char(allvals,c2indx) ;
			end;
		end;
		return ( in  );
	endsub;
run;
options cmplib=here.funcs;
