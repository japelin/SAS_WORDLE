options nosource;
%if %sysfunc(exist(words))=0 %then %do;

  /* This code block is created by Chris Hemedinger From https://github.com/sascommunities/wordle-sas */
  /* SAS program that implements Wordle                                 */
  /* Uses "official" Wordle game word list & permitted guess words      */
  /* Implemented by Chris Hemedinger, SAS                               */
  /* Credit to cfreshman on GitHub for the word lists                   */
  /* And of course to Josh Wardle for the fun game concept              */

  /* Get word list */
  filename words temp;
  filename words_ok temp;

  /* "Official" word lists from NYT, via cfreshman GitHub sharing */
  proc http
  	url="https://gist.githubusercontent.com/cfreshman/a7b776506c73284511034e63af1017ee/raw/845966807347a7b857d53294525263408be967ce/wordle-nyt-answers-alphabetical.txt"
  	out=words;
  run;

  proc http
  	url="https://gist.githubusercontent.com/cfreshman/40608e78e83eb4e1d60b285eb7e9732f/raw/2f51b4f2bb96c02e1dee37808b2eed4ef23a3150/wordle-nyt-allowed-guesses.txt"
  	out=words_ok;
  run;

  data words;
  	infile words;
  	length word $ 5;
  	input word;
  run;


  /* valid guesses that aren't necessarily in word list
    via cfreshman GitHub sharing
  */
  data allowed_words;
  	infile words_ok;
  	length word $ 5;
  	input word;
  run;

  /* allowed guesses plus game words => universe of allowed guesses */
  data allowed_words;
  	set allowed_words words;
  run;
  /* Code by Chris is up to this line. */

%end;
/*
Define words and other flag variables.
The word is always a random word.
The number of the answer is always an obs number, not a string.
*/
%global wordcount;    /* obs of work.words dataset */
%global pickobs;      /* specify 1 obs of work.word dataset */
%global correctwrd;   /* correct words count of user type */
%global execcnt;      /* executed count */
%global endf;         /* game end flag */
%Macro ResetWords;
  options nomprint nomlogic nonotes nosource;
  proc sql noprint;
    select count(word) into :wordcount 
    from words
    ;
  quit;
  %let pickobs = %sysfunc(rand(Integer,1,&wordcount.));
  %let correctwrd = 0;
  %let execcnt = 0;
  %let endf = 0;

  data _null_;
    do i=1 to 26;
      call symputx(byte(64+i),byte(64+i),'G');
      call symputx(cats('A',i),byte(64+i),'G');
      call symputx(cats('C',i),'black','G');
    end;
    do i=1 to 6;
      do j=1 to 5;
        call symputx(cats('RES',i,j),'','G');
        call symputx(cats('CLR',i,j),'gray','G');
      end;
    end;
  run;

%Mend;
%ResetWords

/* Create keyboard array alphabet and results into macro variables */

%Macro WordleCheck;
  options nomprint nomlogic nonotes nosource;
  %local answer;

  %if &correctwrd=5 %then %do;
    %if &endf=1 %then %abort;

    %let protect=YES;
    %if &execcnt = 1 %then %let message = GENIUS!;
    %if &execcnt = 2 %then %let message = MAGNIFICENT!;
    %if &execcnt = 3 %then %let message = IMPRESSIVE!;
    %if &execcnt = 4 %then %let message = SPLENDID!;
    %if &execcnt = 5 %then %let message = GREAT!;
    %if &execcnt = 6 %then %let message = PHEW!;
    
    /* replace word datasets */
    
    data words;
      set words(firstobs=&pickobs obs=&pickobs);
      if not (_n_=&pickobs);
    run;
    data words;
      set words;
      if not (_n_=&pickobs);
    run;
    
    
    
  %end; %else
  %if &execcnt=6 %then %do;
    %let protect=YES;
    data _null_;
      set words(firstobs=&pickobs obs=&pickobs);
      call symputx('answer',upcase(word),'L');
    run;
    %let message=Missed it! Answer is &answer;
  %end; %else
  %do;
    %let protect=NO;
  %end;

  %window wordleWindow
    color=gray
    icolumn=1
    irow=1
    rows=30
    columns=60

    #1 @8 "Welcome to WORDLE in SAS"
    #2 @8 "Enter 5 charactors and press Enter"
    #4 @16 input 5 attr=underline REQUIRED=yes PROTECT=&PROTECT color=red
    
    #6  @16 RES11 1 attr=REV_VIDEO color=&CLR11 PROTECT=YES
    #6  @18 RES12 1 attr=REV_VIDEO color=&CLR12 PROTECT=YES
    #6  @20 RES13 1 attr=REV_VIDEO color=&CLR13 PROTECT=YES
    #6  @22 RES14 1 attr=REV_VIDEO color=&CLR14 PROTECT=YES
    #6  @24 RES15 1 attr=REV_VIDEO color=&CLR15 PROTECT=YES
    
    #7  @16 RES21 1 attr=REV_VIDEO color=&CLR21 PROTECT=YES
    #7  @18 RES22 1 attr=REV_VIDEO color=&CLR22 PROTECT=YES
    #7  @20 RES23 1 attr=REV_VIDEO color=&CLR23 PROTECT=YES
    #7  @22 RES24 1 attr=REV_VIDEO color=&CLR24 PROTECT=YES
    #7  @24 RES25 1 attr=REV_VIDEO color=&CLR25 PROTECT=YES
    
    #8  @16 RES31 1 attr=REV_VIDEO color=&CLR31 PROTECT=YES
    #8  @18 RES32 1 attr=REV_VIDEO color=&CLR32 PROTECT=YES
    #8  @20 RES33 1 attr=REV_VIDEO color=&CLR33 PROTECT=YES
    #8  @22 RES34 1 attr=REV_VIDEO color=&CLR34 PROTECT=YES
    #8  @24 RES35 1 attr=REV_VIDEO color=&CLR35 PROTECT=YES
    
    #9  @16 RES41 1 attr=REV_VIDEO color=&CLR41 PROTECT=YES
    #9  @18 RES42 1 attr=REV_VIDEO color=&CLR42 PROTECT=YES
    #9  @20 RES43 1 attr=REV_VIDEO color=&CLR43 PROTECT=YES
    #9  @22 RES44 1 attr=REV_VIDEO color=&CLR44 PROTECT=YES
    #9  @24 RES45 1 attr=REV_VIDEO color=&CLR45 PROTECT=YES
    
    #10 @16 RES51 1 attr=REV_VIDEO color=&CLR51 PROTECT=YES
    #10 @18 RES52 1 attr=REV_VIDEO color=&CLR52 PROTECT=YES
    #10 @20 RES53 1 attr=REV_VIDEO color=&CLR53 PROTECT=YES
    #10 @22 RES54 1 attr=REV_VIDEO color=&CLR54 PROTECT=YES
    #10 @24 RES55 1 attr=REV_VIDEO color=&CLR55 PROTECT=YES
    
    #11 @16 RES61 1 attr=REV_VIDEO color=&CLR61 PROTECT=YES
    #11 @18 RES62 1 attr=REV_VIDEO color=&CLR62 PROTECT=YES
    #11 @20 RES63 1 attr=REV_VIDEO color=&CLR63 PROTECT=YES
    #11 @22 RES64 1 attr=REV_VIDEO color=&CLR64 PROTECT=YES
    #11 @24 RES65 1 attr=REV_VIDEO color=&CLR65 PROTECT=YES
    
    #13 @12 message 30 color=black PROTECT=YES
    
    #15 @12 &A17 attr=REV_VIDEO color=&C17 PROTECT=YES
    #15 @14 &A23 attr=REV_VIDEO color=&C23 PROTECT=YES
    #15 @16 &A5  attr=REV_VIDEO color=&C5  PROTECT=YES
    #15 @18 &A18 attr=REV_VIDEO color=&C18 PROTECT=YES
    #15 @20 &A20 attr=REV_VIDEO color=&C20 PROTECT=YES
    #15 @22 &A25 attr=REV_VIDEO color=&C25 PROTECT=YES
    #15 @24 &A21 attr=REV_VIDEO color=&C21 PROTECT=YES
    #15 @26 &A9  attr=REV_VIDEO color=&C9  PROTECT=YES
    #15 @28 &A15 attr=REV_VIDEO color=&C15 PROTECT=YES
    #15 @30 &A16 attr=REV_VIDEO color=&C16 PROTECT=YES
    
    #17 @12 &A1  attr=REV_VIDEO color=&C1  PROTECT=YES
    #17 @14 &A19 attr=REV_VIDEO color=&C19 PROTECT=YES
    #17 @16 &A4  attr=REV_VIDEO color=&C4  PROTECT=YES
    #17 @18 &A6  attr=REV_VIDEO color=&C6  PROTECT=YES
    #17 @20 &A7  attr=REV_VIDEO color=&C7  PROTECT=YES
    #17 @22 &A8  attr=REV_VIDEO color=&C8  PROTECT=YES
    #17 @24 &A10 attr=REV_VIDEO color=&C10 PROTECT=YES
    #17 @26 &A11 attr=REV_VIDEO color=&C11 PROTECT=YES
    #17 @28 &A12 attr=REV_VIDEO color=&C12 PROTECT=YES
    
    #19 @14 &A26 attr=REV_VIDEO color=&C26 PROTECT=YES
    #19 @16 &A24 attr=REV_VIDEO color=&C24 PROTECT=YES
    #19 @18 &A3  attr=REV_VIDEO color=&C3  PROTECT=YES
    #19 @20 &A22 attr=REV_VIDEO color=&C22 PROTECT=YES
    #19 @22 &A2  attr=REV_VIDEO color=&C2  PROTECT=YES
    #19 @24 &A14 attr=REV_VIDEO color=&C14 PROTECT=YES
    #19 @26 &A13 attr=REV_VIDEO color=&C13 PROTECT=YES
  ;

  %display wordleWindow;

  %if &correctwrd=5 %then %do;
    %let endf=1;
    %abort;
  %end;

  data dummy;
    set allowed_words;
    where upcase(word)=upcase("&input");
  run;

  %if %length(&input)=0 %then %do;
    %let _j=8;
  %end;%else
  %if %length(&input)^=5 %then %do;
    %if &endf=0 %then %do;
      data _null_;
        putlog 'not 5 charactors!';
      run;
      %let _j=%eval(&_j-1);
    %end;
  %end;%else
  %if &sysnobs=0 %then %do;
    data _null_;
      putlog "&input. is not allowed words!";
    run;
    %let _j=%eval(&_j-1);
  %end; %else
  %do;
    data res;
      set words(firstobs=&pickobs obs=&pickobs);
      length res1-res5 $1 color $8;
      correctwrd=0;
      %do _i=1 %to 5;
        res&_i=char(upcase("&input"),&_i);
        idx=index(upcase(word),res&_i);
        if idx=0 then do;
          color='white';
        end; else
        if idx=&_i then do;
          color='green';
          correctwrd+1;
        end; else
        do;
          color='yellow';
        end;
        call symputx(cats('C',rank(res&_i)-64),color,'G');
        call symputx(cats('RES',%eval(&execcnt+1),&_i),res&_i,'G');
        call symputx(cats('CLR',%eval(&execcnt+1),&_i),color,'G');
      %end;
      call symputx('correctwrd',correctwrd,'G');
      %let execcnt=%eval(&execcnt+1);
      keep res:;
    run;
  %end;
  %let input=;

%Mend;

%Macro Wordle;
  %ResetWords
  %do _j=1 %to 7;
    %WordleCheck
  %end;
%Mend;
/*%Wordle;*/
