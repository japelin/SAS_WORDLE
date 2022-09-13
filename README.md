# SAS_WORDLE


## Submit below code on your Base SAS9.4 M6 or later.

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

## If you use SAS9.4 M5 or before, submit below code.

```
filename wordle temp;
proc http 
  url="https://raw.githubusercontent.com/japelin/SAS_WORDLE/main/wordle_full.sas"
  out=wordle;
run;
%inc wordle;

/* start a game and guess */
%Wordle
```
