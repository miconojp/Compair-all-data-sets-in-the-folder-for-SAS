proc  datasets lib=work kill nolist ; run; quit;
dm log 'clear'; dm output 'clear';

/*現在時刻と実行ユーザー名取得*/
data _NULL_;
	length DAY $10.;
	DAY = put(today(),yymmddn8.);
	USER = "%SYSGET(USERNAME)";
	call symputx("today",catx("_",DAY,USER));
	call symputx("today2",DAY);
run;
/*ルートフォルダ設定*/
%let path =%SYSGET(SAS_EXECFILEPATH);
%let len = %length("comapare");
%let drct = %substr(&path,1,%length(&path.)-%length(%scan(&path,-1,"\")));
%let pg_path = %str(&drct.);
%put &pg_path.;

libname = inDs "&pg_path.inDs";
libname = outDs "&pg_path.outDS";

/*フォルダ内のファイル名取得*/
ods output member = OUT1;
	proc datasets lib=inds memtype=data;
	quit;
ods output close;

/*マクロ変数に格納*/
data _NULL_;
	set OUT1 end = _EOF;
		if _EOF then call symputx("OBS",_N_);
		call symputx(catx("DS",_N_),Name);
run;

%macro proc_compare();
	
	proc printto print="&pg_path.\&today._compare.lst";
	run;
	
	%do i=1 %to &OBS.;
		proc compare base=inds.&&ds&i compare=outds.&&ds.&i;
		run;
	%end;

	proc printto;
	run;
%mend;

%proc_compare;

/*ログを出力*/
dm 'log;file "&pg_path.\&today..log" replace';