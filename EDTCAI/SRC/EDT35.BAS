1	SUB EDT35
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
      !	&
    \	common (qiocom) &
		fill%(7%), &
		fill$=1%, &
		terminal$=3%, &
		loc1$=10%, &
		loc2$=10%
900   !	&
      !	****	Functions &
      !
910	def fn_getanswer$ &
      !	&
      !	This function calls the GETANS subprogram and passes it values for: &
      !	answer$, FEEDBACK$, ADVICE$, NTRIES%, LIMIT%, and OPTION% (specified &
      ! in the program either explicitly or as a default value).  It returns &
      ! the variables RESPONSE$ and where%.  The latter takes the values: &
      ! 1 - correct, 2 - incorrect, 3 - a keypad movement option was chosen. &
      !	&
    \	advice$="ZA101" if advice$="" &
    \	advice$="-"+advice$ if pos("+-",seg$(advice$,1%,1%),1%)<1% &
    \	where%=option% &
    \	if line_number%>0% and column_number%>0% then &
		call plot("-P2100") &
    \	call setloc("A",line_number%,column_number%,24%,5%) &
    \	where%=DO_FORM% &
      !
911	call getans(answer$,			! Correct answer. &
		    feedback$,			! Feedback if student doesn't &
						! enter the correct answer. &
		    ntries%,			! Number of times to print &
						! feedback before printing &
						! message 'Type answer$'. &
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
      !	&
    \	call plot("I3500") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2000,2000,9900
2000	line_number%=0%  \ column_number%=0% &
    \	call plot("T3500") &
    \   advice$="+A3500" &
    \	answer$="<FIND>" &
    \	feedback$="The <FIND> key is the <GOLD> key, then PF3." &
    \	feedback$="The <FIND> key is the <GOLD> key, then keypad key #8." if terminal$="V52" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2100,2100,9900
2100	call plot("T3503") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2150,2150,9900
2150	call plot ("T3506") &
    \	advice$="+A3506" &
    \	answer$="<FNDNXT>" &
    \	feedback$="<FNDNXT> is the PF3 key on the keypad." &
    \	feedback$="<FNDNXT> is keypad key #8." if terminal$="V52" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2200,2200,9900
2200	call plot("T3509") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2250,2250,9900
2250 	line_number%=12% \ column_number%=28% &
    \	call plot("T3512") &
    \	answer$="<FIND>" &
    \	feedback$="Press <FIND> which is the <GOLD> key, then PF3." &
    \   feedback$="Press <FIND> which is the <GOLD> key, then keypad key #8." if terminal$="v52" &
    \   advice$="+A3500" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2300,2300,9900
2300	line_number%=20% \ column_number%=40% &
    \	call plot("T3515") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2350,2350,9900
2350	call plot("T3518") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2400,2400,9900
2400	call plot("T3521")
2405	sub_advice$="+A3521" &
    \	sub_answer$="TEST<ADVANCE>" &
    \	gosub 10000 &
    \	on where% goto 2450,2410,9900
2410	goto 2450 IF Response$="TEST<ENTER>" &
    \	temp$="Type TEST, then press <ADVANCE> (keypad key #4.)" &
    \	temp$="Please type TEST, then <ADVANCE>, not <BACKUP>." if response$="TEST<BACKUP>" &
    \	call feedbk(temp$) &
    \	goto 2405
2450	line_number%=17% \ column_number%=28% &
    \	call plot("T3524") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3000,3000,9900
3000	line_number%=17% \ column_number%=28% &
    \	call plot("T3527") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3050,3050,9900
3050	call plot("T3530") &
    \   advice$="+A3530" &
    \	answer$="<FNDNXT>" &
    \	feedback$="<FNDNXT> is the PF3 key on the keypad." &
    \	feedback$="<FNDNXT> is keypad key #8." if terminal$="V52" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3100,3100,9900
3100	line_number%=18% \ column_number%=30% &
    \	call plot("T3533") &
    \   advice$="+A3530" &
    \	answer$="<FNDNXT>" &
    \	feedback$="<FNDNXT> is the PF3 key on the keypad." &
    \	feedback$="<FNDNXT> is keypad key #8." if terminal$="V52" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3150,3150,9900
3150	call plot("T3536") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3200,3200,9900
3200	call plot("T3539") &
    \	answer$="<FIND>" &
    \   advice$="+A3539" &
    \	feedback$="The <FIND> key is the <GOLD> key, then PF3." &
    \	feedback$="The <FIND> key is the <GOLD> key, then keypad key #8." if terminal$="V52" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3250,3250,9900
3250	line_number%=0% \ column_number%=0% &
    \	call plot("T3542")
3255	sub_advice$="+A3542" &
    \	sub_answer$=".BAS<BACKUP>" &
    \	gosub 10000 &
    \	on where% goto 3300,3260,9900
3260	temp$="Type .BAS, then press <BACKUP>." &
    \	temp$="Search from here to the beginning of the file, use <BACKUP>." &
		if response$=".BAS<BACKUP>" or response$=".BAS<ENTER>" &
    \	call feedbk(temp$) &
    \	goto 3255
3300	line_number%=16% \ column_number%=34% &
    \	call plot("T3545") &
    \   advice$="+A3545" &
    \	answer$="<BACKUP>" &
    \	feedback$="<BACKUP> is keypad key #5." &
    \	response$=fn_getanswer$ &
    \	on where% goto 3350,3350,9900
3350	answer$="<FNDNXT>" &
    \	feedback$="The <FNDNXT> key is PF3." &
    \	feedback$="The <FNDNXT> key is keypad key #8." if terminal$="V52" &
    \	advice$="+A3506" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3400,3400,9900
3400	call plot("T3548") &
    \   advice$="+A3548" &
    \	line_number%=15% \ column_number%=34% &
    \	answer$="<FIND>" &
    \	feedback$="The <FIND> key is the <GOLD> key, then PF3." &
    \	feedback$="The <FIND> key is the <GOLD> key, then keypad key #8." if terminal$="V52" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3450,3450,9900
3450	line_number%=0% \ column_number%=0% &
    \	call plot("T3542")
3455	sub_answer$="79<BACKUP>" &
    \   m_advice$="+A3548" &
    \	gosub 10000 &
    \	on where% goto 3470,3460,9900
3460	goto 3470 if response$="79<ENTER>" &
    \	call feedbk("Please type 79, then press the keypad <BACKUP> key.") &
    \	goto 3455
3470	line_number%=14% \ column_number%=49% &
    \	call plot("T3551") &
    \   advice$="" &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3600,3600,9900
3600	line_number%=0% \ column_number%=0% &
    \   call plot("T3554") &
    \   advice$="+A3554" &
    \	answer$="<SUBS>" &
    \	feedback$="Please press <GOLD> and then <ENTER> to access <SUBS>." &
    \	response$=fn_getanswer$ &
    \	on where% goto 3605,3605,9900
3605	call plot("T3557") &
    \   advice$="" &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3615,3615,9900
3615	call plot("T3560") &
    \   advice$="" &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3650,3650,9900
3650	line_number%=14% \ column_number%=28% &
    \	call plot("T3563") &
    \   advice$="+A3563" &
    \	answer$="<FIND>" &
    \	feedback$="<FIND> is <GOLD>, then the PF3 key on the keypad." &
    \	feedback$="<FIND> is <GOLD>, then keypad key #8." if terminal$="V52" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3700,3700,9900
3700	call plot("T3542") &
    \	sub_answer$="79<ADVANCE>" &
    \	sub_advice$="+A3563" &
    \	gosub 10000 &
    \	on where% goto 3750,3710,9900
3710	goto 3750 if response$="79<ENTER>" &
    \	call feedbk("Please type 79, then press the keypad <ADVANCE> key.") &
    \	goto 3700
3750    line_number%=14% \ column_number%=49% &
    \	call plot("T3566") &
    \   advice$="+A3566" &
    \	answer$="<SUBS>" &
    \	feedback$="<SUBS> is <GOLD>, then the keypad <ENTER> key." &
    \	response$=fn_getanswer$ &
    \	on where% goto 3800,3800,9900
3800    line_number%=15% \ column_number%=49% &
    \	call plot("T3569") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3850,3850,9900
3850	call plot("T3572") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3900,3900,9900
3900 	line_number%=0% &
    \	call plot ("T3575") &
    \   advice$="+A3575" &
    \   answer$="<COMMAND>" &
    \	feedback$="Press <GOLD> then <ENTER> to access <COMMAND>." &
    \	response$=fn_getanswer$ &
    \	on where% goto 4000,4000,9900
4000 	call plot ("T3578") &
    \   advice$="" &
    \   answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 4050,4050,9900
4050 	call plot ("T3581") &
    \   advice$="" &
    \   answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 4100,4100,9900
4100	call plot("S3500") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 4150,4150,9900
4150	call plot("S3501") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	goto 9899
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
    \	goto 32000
9910	if sys_where%=4% then			! [QUIT &
		pass_key%=3% &
    \	goto 32000
9920	if sys_where%=5% then			! [BACKUP &
		if first_flag%=0% then 2000 &
			else pass_key%=4% &
    \		     goto 32000
9930	if sys_where%=6% then			! [REVIEW &
		goto 2000			! review this section
9940	if sys_where%=7% then			! [NEXT &
		pass_key%=2% &
    \	goto 32000
9950	if sys_where%=8% then			! [HELP Menu &
		pass_key%=-2% &
    \	goto 32000
9960  !	&
      !	What can it be?  Treat it as [REVIEW &
      !	&
    \	goto 2000
10000 !	&
      !	****	Subroutine to collect single character answers &
      !	&
    \	line_number%=0% &
    \	temp$=""				! variable to collect answer &
    \	call setloc("A",20%,40%,0%,0%) &
    \	print edit$(loc1$,128%)+space$(5%)
10010	answer$="" &
    \	feedback$="" &
    \	advice$=sub_advice$ &
    \	option%=SINGLE_CHARACTER%				! single character input &
    \	response$=fn_getanswer$ &
    \	return if where%>2% &
    \	if len(response$)=1% and ascii(response$)>31% and ascii(response$)<127% then &
		temp$=temp$+response$ &
    \		call setloc("R",0%,1%,0%,0%) &
    \		goto 10010
10020	if ascii(response$)=127% then &
		if len(temp$)<2% then &
			goto 10000 &
			else &
			call setloc("R",0%,-1%,0%,0%) &
    \			print edit$(loc1$,128%)+" " &
    \			temp$=left$(temp$,len(temp$)-1%) &
    \			goto 10010
10030	response$=edit$(temp$+response$,32%) &
    \	where%=2% &
    \	where%=1% if response$=sub_answer$ &
    \	return
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
