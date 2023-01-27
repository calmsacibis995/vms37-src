1	SUB EDT55
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
      !	****	Dimension the arrays &
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
    \	common (parsl)	buffer_number%, &
			buffer_ptr(4%,2%), &
			range_list(1%,15%), &
			command%, &
			line_11, &
			line_12, &
			line_21, &
			line_22, &
			option_n%, &
			option_m%, &
			error_code%, &
			file$(12%,2%)=80%, &
			command$, &
			buffer_1$, &
			buffer_2$, &
			line_11$, &
			line_12$, &
			line_21$, &
			line_22$, &
			sub_string_1$, &
			sub_string_2$, &
			file_name$, &
			option$, &
			error_text$=80%, &
			command_list$(20%)=11% &
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
1100	call plot("I5500") &
    \   advice$="" &
    \   answer$="" &
    \   feedback$="" &
    \   response$=fn_getanswer$ &
    \   on where% goto 2000,2000,9900
2000	call plot("T5500") &
    \   advice$="+A5500" &
    \   answer$="RES*EQUENCE" &
    \   feedback$="Please resequence the whole file." &
    \   response$=fn_getanswer$ &
    \   on where% goto 2150,2150,9900
2150	call plot("T5505") &
    \	advice$="+A5505" &
    \   answer$="T*YPE W*HOLE" &
    \   feedback$="Please display the whole file." &
    \   response$=fn_getanswer$ &
    \   on where% goto 2200,2200,9900
2200	call plot("T5510")
2205    answer$="" &
    \   feedback$="" &
    \   response$=fn_getanswer$ &
    \   on where% goto 2210,2210,9900
2210  !	&
      !	Now set up the file &
      !	&
    \	file$(0%,0%)="MAIN" &
    \	file$(1%,0%)="1     There will be a staff meeting" &
    \	file$(2%,0%)="1.1   on Tuesday in room 35." &
    \	file$(3%,0%)="2     Hope to see you then." &
    \	file$(4%,0%)="3     Call if you can't make it." &
    \	file$(5%,0%)="[EOB]" &
    \	buffer_number%=0% &
    \	buffer_ptr(0%,0%)=1% &
    \	buffer_ptr(1%,0%)=1% &
    \	buffer_ptr(2%,0%)=4% &
    \	buffer_ptr(3%,0%)=1% &
    \	buffer_ptr(4%,0%)=5% &
      !	&
    \	call plot("T5515")
2215	advice$="+A5515" &
    \   answer$="RES*EQUENCE 1:2" &
    \   feedback$="" &
    \   response$=fn_getanswer$ &
    \   on where% goto 2300,2220,9900
2220	call parsel(response$) &
    \	if error_code%<>0% then &
		call feedbk(error_text$) &
    \		goto 2215
2225	error_text$="" &
    \	error_text$="Please use the RESEQUENCE command." if command$<>"RESEQUENCE" &
    \	error_text$="Please do not use any options." if option$<>"" &
    \	error_text$="Please RESEQUENCE all lines from 1 to 2." &
		if range_list(0%,0%)<>3% or range_list(0%,1%)<>1% or range_list(0%,2%)<>1.1 or range_list(0%,3%)<>2% &
    \	error_text$="Please RESEQUENCE only lines 1 and 2." if range_list(0%,0%)>3% &
    \	if error_text$<>"" then &
		call feedbk(error_text$) &
    \		goto 2215
2300	call plot("T5520") &
    \	advice$="" &
    \   answer$="" &
    \   feedback$="" &
    \   response$=fn_getanswer$ &
    \   on where% goto 2350,2350,9900
2350	call plot("T5525") &
    \	advice$="+A5525" &
    \   answer$="T*YPE W*HOLE" &
    \   feedback$="Please display the whole file." &
    \   response$=fn_getanswer$ &
    \   on where% goto 2400,2400,9900
2400	call plot("T5530") &
    \	advice$="" &
    \   answer$="" &
    \   feedback$="" &
    \   response$=fn_getanswer$ &
    \   on where% goto 2450,2450,9900
2450	call plot("T5535") &
    \	advice$="" &
    \   answer$="" &
    \   feedback$="" &
    \   response$=fn_getanswer$ &
    \   on where% goto 2500,2500,9900
2500	call plot("S5500") &
    \	advice$="" &
    \   answer$="" &
    \   feedback$="" &
    \   response$=fn_getanswer$ &
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
