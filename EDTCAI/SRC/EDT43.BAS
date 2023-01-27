1	SUB EDT43
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
    \	advice$="-"+advice$ if pos("+-",seg$(advice$,1%,1%),1%)<1% &
    \	where%=option% &
      !	&
    \	call getans(answer$,			! Correct answer. &
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
    \	ntries%=3% &
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
      !	****	Begin Main Instruction &
      !	&
    \	call plot("I4300") &
    \	answer$="" &
    \	feedback$="" &
    \	advice$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2000,2000,9900
2000	call plot("T4300") &
    \	call plot("B4300") &
    \	answer$="D*ELETE" &
    \	feedback$="Please type:  DELETE (abbreviated as D)." &
    \	advice$="+A4300" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2050,2050,9900
2050	call plot("T4305") &
    \	call plot("B4305") &
    \	answer$="T*YPE W*HOLE" &
    \	feedback$="Please type:  TYPE WHOLE" &
    \	advice$="+A4305" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2100,2100,9900
2100	call plot("T4310") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2150,2150,9900
2150	call plot("T4315") &
    \	call plot("B4315") &
    \	answer$="D*ELETE 2" &
    \	feedback$="Please delete line 2." &
    \	advice$="+A4315" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2200,2200,9900
2200	call plot("T4320") &
    \	call plot("B4320") &
    \	answer$="T*YPE W*HOLE" &
    \	feedback$="Remember, TYPE WHOLE displays an entire file." &
    \	advice$="+A4320" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2250,2250,9900
2250	call plot("T4325") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2300,2300,9900
2300	call plot("T4330") &
    \	call plot("B4330") &
    \	answer$="R*EPLACE 3" &
    \	feedback$="The REPLACE command is specified the same way as DELETE." &
    \	advice$="+A4330" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2350,2350,9900
2350	call plot("T4335") &
    \	call plot("B4335")
2355	answer$="ON MAY 4." &
    \	feedback$="" &
    \	advice$="+A4335" &
    \	option%=NO_CAPS% &
    \	response$=fn_getanswer$ &
    \	on where% goto 2360,2360,9900
2360	if edit$(response$,8%+16%+32%+128%)="ON MAY 4" or &
	   edit$(response$,8%+16%+32%+128%)="ON MAY 4." then &
		line1$="2     "+response$ &
		else &
		call feedbk("Please type:  on May 4.") &
    \		goto 2355
2400	call plot("T4340") &
    \	answer$="<EOF>" &
    \	feedback$="Please press CTRL/Z" &
    \	ntries%=100% &
    \	advice$="+A1225" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2450,2450,9900
2450	call plot("T4345") &
    \	answer$="T*YPE W*HOLE" &
    \	feedback$="Please type:  TYPE WHOLE" &
    \	advice$="+A4345" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2500,2500,9900
2500	call plot("T4350") &
    \	call feedbk(line1$) &
    \	call plot("B4350") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2550,2550,9900
2550	call plot("S4300") &
    \	answer$="" &
    \	feedback$="" &
    \	advice$="" &
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
