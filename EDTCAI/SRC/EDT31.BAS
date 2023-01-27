1	SUB EDT31
2     !****************************************************************************&
      !*									  *&
      !*  COPYRIGHT (c) 1978, 1980, 1982 BY					  *&
      !*  DIGITAL EQUIPMENT CORPORATION, MAYNARD, MASSACHUSETTS.		  *&
      !*  ALL RIGHTS RESERVED.							  *&
      !* 									  *&
      !*  THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED AND COPIED   *&
      !*  ONLY IN  ACCORDANCE WITH  THE  TERMS  OF  SUCH  LICENSE  AND WITH THE   *&
      !*  INCLUSION OF THE ABOVE COPYRIGHT NOTICE. THIS SOFTWARE OR  ANY  OTHER   *&
      !*  COPIES THEREOF MAY NOT BE PROVIDED OR OTHERWISE MADE AVAILABLE TO ANY   *&
      !*  OTHER PERSON.  NO TITLE TO AND OWNERSHIP OF  THE  SOFTWARE IS  HEREBY   *&
      !*  TRANSFERRED.								  *&
      !* 									  *&
      !*  THE INFORMATION IN THIS SOFTWARE IS  SUBJECT TO CHANGE WITHOUT NOTICE   *&
      !*  AND  SHOULD  NOT  BE  CONSTRUED AS  A COMMITMENT BY DIGITAL EQUIPMENT   *&
      !*  CORPORATION.								  *&
      !* 									  *&
      !*  DIGITAL ASSUMES NO RESPONSIBILITY FOR THE USE  OR  RELIABILITY OF ITS   *&
      !*  SOFTWARE ON EQUIPMENT WHICH IS NOT SUPPLIED BY DIGITAL.		  *&
      !* 									  *&
      !*									  *&
      !****************************************************************************&
      !****************************************************************************
800   !	&
      !	****	Dimension, Common, and Map statements &
      !	&
    \	common (pasfil)				! main common for parameters &
		pass_key%,			! pointer to current activity &
						! and to the results of it &
		module_number%,			! the module to study &
		objective_number%,		! the objective to study &
		section_number%			! the section to study.  This &
						! is set to -1% to indicate &
						! completion of this objective &
      !
900   !	&
      !	****	Functions &
      !
910	def fn_getanswer$ &
      !	&
      !	This function calls the GETANS subprogram and passes it values for: &
      !	ANSWER$, FEEDBACK$, ADVICE$, NTRIES%, LIMIT%, and OPTION% (specified &
      ! in the program either explicitly or as a default value).  It returns &
      ! the variables RESPONSE$ and where%.  The latter takes the values: &
      ! 1 - correct, 2 - incorrect, 3 - a keypad movement option was chosen. &
      !	&
    \	advice$="ZA101" if advice$="" &
    \	advice$="-"+advice$ if pos("+-",seg$(advice$,1%,1%),1%)<1% &
    \	where%=option% &
    \	if line_number%>0% and column_number%>0% then &
		call plot("-P2100") &
    \		call setloc("A",line_number%,column_number%,24%,5%) &
    \		where%=DO_FORM% &
      !
911	call getans(answer$,			! Correct answer. &
		    feedback$,			! Feedback if student doesn't &
						! enter the correct answer. &
		    ntries%,			! Number of times to print &
						! feedback before printing &
						! message 'Type ANSWER$'. &
		    response$,			! Student's edited response. &
		    advice$,			! Advice form(s). &
		    limit%,			! Screen width before wrap. &
		    where%)			! Return value (1, 2, or 3) &
    \	sys_where%=where% &
    \	where%=3% if where%>2% &
    \	answer$="" &
    \	feedback$="" &
    \	advice$="" &
    \	option%=0% &
    \	fn_getanswer$=response$ &
    \	fnend
1000  !	&
      !	&
      !	****	Begin Main Routine &
      !	&
    \	on error goto 19000 &
      !	&
    \	answer$="" &
    \	feedback$="" &
    \	advice$="" &
    \	ntries%=32767% &
    \	limit%=-1% &
    \	option%=0% &
    \	NO_ECHO%=-32767% &
    \	SINGLE_CHARACTER%=-32766% &
    \	NO_KEYPAD%=-32765% &
    \	NO_SPACES%=-32764% &
    \	NO_CAPS%=-32763% &
    \	DO_FORM%=-32762% &
      !
1100  !	&
      ! ****	Begin Main Instruction &
      !	&
    \	call keypad("EDT") &
    \	line_number%=0% \ column_number%=0% &
      !	&
    \	call plot("ZK900") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 1150,1150,9900
1150	call plot("I3100") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2000,2000,9900
2000	call keypad("SPECIAL") &
    \	call plot("T3110") &
    \	advice$="+A3110" &
    \	answer$="<GOLD>" &
    \	option%=SINGLE_CHARACTER% &
    \	feedback$="Press the <GOLD> key." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2100,2100,9900
2100	call keypad("EDT") &
    \	call plot("T3115") &
    \	advice$="+A3115" &
    \	answer$="<RESET>" &
    \	feedback$="<RESET> is <GOLD>, then the keypad period key." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2150,2150,9900
2150	line_number%=16% \ column_number%=48% &
    \	call plot("T3120") &
    \	advice$="+A3120" &
    \	answer$="<TOP>" &
    \	feedback$="<TOP> is <GOLD>, then the keypad key #5." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2200,2200,9900
2200	line_number%=13% \ column_number%=37% &
    \	call plot("T3125") &
    \	advice$="+A3125" &
    \	answer$="<BOTTOM>" &
    \	feedback$="<BOTTOM> is <GOLD>, then the keypad key #4." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2250,2250,9900
2250	line_number%=19% &
    \	call plot("T3130") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2300,2300,9900
2300	line_number%=0% &
    \	call plot("T3135") &
    \	advice$="+A3135" &
    \	answer$="<GOLD>" &
    \	feedback$="<GOLD> is the PF1 key on the keypad." &
    \	feedback$="<GOLD> is the left blank key on the keypad." if terminal$="V52" &
    \	option%=SINGLE_CHARACTER% &
    \	call keypad("SPECIAL") &
    \	response$=fn_getanswer$ &
    \	call keypad("EDT") &
    \	on where% goto 2310,2310,9900
2310	call plot("T3140") &
    \	answer$="5" &
    \	feedback$="Move forward 5 lines." &
    \	option%=SINGLE_CHARACTER% &
    \	advice$="+A3135" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2315,2315,9900
2315	call setloc("R",0%,1%,0%,0%) &
    \	answer$="<LINE>" &
    \	feedback$="<LINE> is keypad key #0." &
    \	option%=SINGLE_CHARACTER% &
    \	advice$="+A3135" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2350,2350,9900
2350	call plot("T3145") &
    \	advice$="+A3145" &
    \	line_number%=18% &
    \	answer$="<BACKUP>" &
    \	feedback$="<BACKUP> is keypad key #5." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2360,2360,9900
2360	call plot("T3150") &
    \	line_number%=0% &
    \	answer$="<GOLD>" &
    \	feedback$="<GOLD> is the PF1 key on the keypad." &
    \	feedback$="<GOLD> is the left blank key on the keypad." if terminal$="V52" &
    \	option%=SINGLE_CHARACTER% &
    \	call keypad("SPECIAL") &
    \	response$=fn_getanswer$ &
    \	call keypad("EDT") &
    \	on where% goto 2370,2370,9900
2370	call plot("T3140") &
    \	answer$="7" &
    \	feedback$="Move back by 7 words." &
    \	advice$="+A3145" &
    \	option%=SINGLE_CHARACTER% &
    \	response$=fn_getanswer$ &
    \	on where% goto 2380,2380,9900
2380	call setloc("R",0%,1%,0%,0%) &
    \	answer$="<WORD>" &
    \	feedback$="<WORD> is keypad key #1." &
    \	advice$="+A3145" &
    \	option%=SINGLE_CHARACTER% &
    \	response$=fn_getanswer$ &
    \	on where% goto 2400,2400,9900
2400	line_number%=16% \ column_number%=63% &
    \	call plot("T3155") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2450,2450,9900
2450    line_number%=0% &
    \	call plot("S3100") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 9899,9899,9900
9899  !	&
      !	****	Fall through after last piece of instruction &
      !	&
      !	At this point they are finished with this section so set the flag to &
      !	have the router mark it as finished, and exit. &
      !	&
    \	pass_key%=2% &
    \	section_number%=-1% &
    \	goto 32000
9900  !	&
      !	****	Routine to handle [EXIT, [QUIT, [BACK, [REVIEW, and [NEXT &
      !	&
    \	if sys_where%=3% then			! [EXIT &
		pass_key%=1% &
    \		goto 32000
9910	if sys_where%=4% then			! [QUIT &
		pass_key%=3% &
    \		goto 32000
9920	if sys_where%=5% then			! [BACKUP &
		if first_flag%=0% then 2000 &
			else pass_key%=4% &
    \			     goto 32000
9930	if sys_where%=6% then			! [REVIEW &
		goto 2000			! review this section
9940	if sys_where%=7% then			! [NEXT &
		pass_key%=2% &
    \		goto 32000
9950	if sys_where%=8% then			! [HELP Menu &
		pass_key%=-2% &
    \		goto 32000
9960  !	&
      !	What can it be?  Treat it as [REVIEW &
      !	&
    \	goto 2000
19000 !	&
      !	****	Error Routine &
      !	&
    \	if err=28% then				! CTRL/C trap &
		resume 32000
19999 !	&
      !	No error handling has worked to here, so abort &
      !	&
    \	pass_key%=1%				! set the abort &
    \	resume 32000
32000 !	&
      !	****	Exit routines &
      !
32767	subend
