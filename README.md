# SAS_WORDLE


Submit below code on your Base SAS9.4.

```
options dlcreatedir;
%let repopath=%sysfunc(pathname(WORK))/SAS_WORDLE;
libname repo "&repopath.";
data _null_;
    rc = gitfn_clone( 
      "https://github.com/japelin/SAS_WORDLE", 
      "&repoPath." 
    			); 
    put 'Git repo cloned ' rc=; 
run;
%include "&repopath./wordle_full.sas";

/* start a game and guess */
%Wordle
```
