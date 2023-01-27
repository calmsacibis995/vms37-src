1	SUB EDT42
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
    \	limit%=32% &
    \	option%=0% &
    \	NO_ECHO%=-32767% &
    \	SINGLE_CHARACTER%=-32766% &
    \	NO_KEYPAD%=-32765% &
    \	NO_SPACES%=-32764% &
    \	NO_CAPS%=-32763% &
    \	DO_FORM%=-32762% &
      !
1100	call plot("I4200") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2000,2000,9900
2000	call plot("T4200") &
    \	call plot("B4200") &
    \	advice$="+A4200" &
    \   answer$="ED*IT/ED*T" &
    \   limit=35% &
    \   feedback$="Enter EDIT/EDT (abbreviated as ED/ED)." &
    \	response$=fn_getanswer$ &
    \   on where% goto 2050,2050,9900
2050	call plot ("T4205") &
    \	advice$="+A4205" &
    \	answer$="MEMO.LIS" &
    \   feedback$="Please edit the file:  MEMO.LIS" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2100,2100,9900
2100	call plot ("T4210") &
    \	answer$="" &
    \   feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2300,2300,9900
2300	call plot("T4215") &
    \	call plot("B4215") &
    \   advice$="+A4215" &
    \	answer$="I*NSERT" &
    \	feedback$="To enter insert mode, type:  INSERT" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2400,2400,9900
2400	call plot("T4220") &
    \	call plot("B4220")
2405	advice$="+A4220" &
    \   answer$="" &
    \   feedback$="" &
    \	option%=NO_CAPS% &
    \   response$=fn_getanswer$ &
    \	on where% goto 2406,2406,9900
2406	if response$<>"" and response$<>"<EOF>" then &
		line1$="    1     "+response$ &
		else &
		call feedbk("Please enter something into the buffer.") &
    \		goto 2405
2407    call setloc("R",+1%,+0%,0%,0%)
2408	advice$="+A4220" &
    \	answer$="" &
    \   feedback$="" &
    \	option%=NO_CAPS% &
    \   response$=fn_getanswer$ &
    \   on where% goto 2409,2409,9900
2409	if response$<>"" and response$<>"<EOF>" then &
		line2$="    2     "+response$ &
		else &
		call feedbk("Please enter a second line into the buffer.") &
    \		goto 2408
2450	call plot("T4225") &
    \	answer$="<EOF>" &
    \   ntries%=100% &
    \	feedback$="Please press CTRL/Z." &
    \	advice$="+A1225" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2455,2455,9900
2455	call plot ("T4230") &
    \	call plot("B4230") &
    \	answer$="T*YPE W*HOLE" &
    \	feedback$="Please type:  TYPE WHOLE (abbreviated as T W)." &
    \   ntries%=3% &
    \	advice$="+A4230" &
    \   response$=fn_getanswer$ &
    \   on where% goto 2500,2500,9900
2500	call plot("T4235") &
    \	call plot("B4235") &
    \	call setloc("A",0%,0%,13%,26%) &
    \   call feedbk (line1$) &
    \	call setloc ("R",0%,0%,+1%,0%) &
    \   call feedbk (line2$) &
    \	call setloc("R",0%,0%,+1%,0%) &
    \	call feedbk("[EOB]") &
    \	call setloc("R",0%,0%,+1%,0%) &
    \	call feedbk("*") &
    \	call setloc("A",16%,27%,22%,5%) &
    \	advice$="+A4235" &
    \	answer$="T*YPE 1" &
    \   feedback$="Please type:  TYPE 1 (abbreviated as T 1)." &
    \   response$=fn_getanswer$ &
    \	on where% goto 2550,2550,9900
2550	call setloc ("A",0%,0%,17%,26%) &
    \   call feedbk (line1$) &
    \	call plot("T4240") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \   on where% goto 2555,2555,9900
2555	call plot("T4245") &
    \	call plot("B4245")
2556	advice$="+A4245" &
    \	answer$="I*NSERT 2" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2560,2557,9900
2557	if response$="INSERT 1" then &
		call feedbk ("No, INSERT 1 would place the insert pointer in front of line 1. Try again.") &
    \		goto 2556 &
		else &
		call feedbk("Please insert a line between lines 1 and 2.") &
    \		goto 2556
2560	call plot("T4250") &
    \	call plot("B4250")
2561	answer$="" &
    \   advice$="+A4250" &
    \   feedback$="" &
    \	option%=NO_CAPS% &
    \   response$=fn_getanswer$ &
    \   on where% goto 2562,2562,9900
2562	if response$<>"" then &
		line3$="    1.1   "+response$ &
		else &
		call feedbk("Please enter something to be placed between lines 1 and 2.") &
    \		goto 2561
2565	call plot("T4255") &
    \	call plot("B4255")
2566	advice$="+A1225" &
    \	answer$="<EOF>" &
    \   feedback$="Please press CTRL/Z." &
    \	ntries%=100% &
    \   response$=fn_getanswer$ &
    \   on where% goto 2570,2570,9900
2570    call plot("T4260") &
    \   advice$="+A4260" &
    \	answer$="T*YPE W*HOLE" &
    \	feedback$="Please type:  TYPE WHOLE (abbreviated as T W)." &
    \	ntries%=3% &
    \	response$=fn_getanswer$ &
    \   on where% goto 2580,2580,9900
2580    call plot("T4265") &
    \   call setloc("A",+0%,+0%,13%,26%) &
    \   call feedbk(line1$) &
    \   call setloc ("R",0%,0%,+1%,0%) &
    \   call feedbk(line3$) &
    \   call setloc ("R",0%,0%,+1%,0%) &
    \	call feedbk(line2$) &
    \   call plot ("B4265") &
    \   answer$="" &
    \   feedback$="" &
    \   response$=fn_getanswer$ &
    \   on where% goto 2590,2590,9900
2590    call plot ("S4200") &
    \   advice$="+ZA100" &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \   on where% goto 9899,9899,9900
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
