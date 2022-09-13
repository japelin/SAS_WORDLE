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

/* Create line in %Window */
data _null_;
  length line $800;
  do i=1 to 6;
    line='';
    do j=1 to 5;
      /* Create line in %Window -> #6 @16 RES11 1 attr=REV_VIDEO color=&CLR11 PROTECT=yes */
      line=cat(trim(line),' #',i+5,' @',14+j*2,' RES',i,j,' 1 ','attr=REV_VIDEO color=&CLR',i,j,' PROTECT=YES');
    end;
    call symputx(cats('def_result',i),line);
  end;
  line='';
  j=1;
  do i=17,23,5 ,18,20,25,21,9 ,15,16;
    /* create line in %Window -> #15 @12 &A17 attr=REV_VIDEO color=&C17 PROTECT=YES*/
    line=cat(trim(line),'#15 @',10+j*2,' &A',i,' attr=REV_VIDEO color=&C',i,' PROTECT=YES');
    j+1;
  end;
  call symputx('def_keyboard1',line);
  line='';
  j=1;
  do i=1 ,19,4 ,6 ,7 ,8 ,10,11,12;
    line=cat(trim(line),'#17 @',10+j*2,' &A',i,' attr=REV_VIDEO color=&C',i,' PROTECT=YES');
    j+1;
  end;
  call symputx('def_keyboard2',line);
  line='';
  j=1;
  do i=26,24,3 ,22,2 ,14,13;
    line=cat(trim(line),'#19 @',12+j*2,' &A',i,' attr=REV_VIDEO color=&C',i,' PROTECT=YES');
    j+1;
  end;
  call symputx('def_keyboard3',line);
run;

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
    &def_result1
    &def_result2
    &def_result3
    &def_result4
    &def_result5
    &def_result6
    
    #13 @12 message 30 color=black PROTECT=YES

    &def_keyboard1
    &def_keyboard2
    &def_keyboard3
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
    data _null_;
      set words(firstobs=&pickobs obs=&pickobs);
      length res $1 color $8;
      correctwrd=0;
      %do _i=1 %to 5;
        res=char(upcase("&input"),&_i);
        idx=index(upcase(word),res);
        cnt=count(upcase(word),res);
        fnd=find(upcase(word),res,&_i);
        if idx=0 then do;
          color='white';
        end; else
        if idx=&_i then do;
          color='green';
          correctwrd+1;
        end; else
        if cnt>1 then do;
          if fnd=&_i then do;
            color='green';
            correctwrd+1;
          end; else 
          do;
            color='yellow';
          end;
        end; else
        if color='' then do;
          color='yellow';
        end;
        call symputx(cats('C',rank(res)-64),color,'G');
        call symputx(cats('RES',%eval(&execcnt+1),&_i),res,'G');
        call symputx(cats('CLR',%eval(&execcnt+1),&_i),color,'G');
        color='';
      %end;
      call symputx('correctwrd',correctwrd,'G');
      %let execcnt=%eval(&execcnt+1);
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
