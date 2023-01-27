1	SUB EDT52
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
1100  !	&
      !	****	Begin Main Instruction &
      !	&
    \	call plot("I5200") &
    \   advice$="" &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \   on where% goto 2000,2000,9900
2000	call plot("T5205") &
    \   advice$="+A5205" &
    \	answer$="F*IND 2" &
    \	feedback$="Please position in pointer in front of line 2." &
    \	response$=fn_getanswer$ &
    \   on where% goto 2050,2050,9900
2050   	call plot("T5210") &
    \   advice$="+A5210" &
    \	answer$="I*NSERT" &
    \	feedback$="Please enter INSERT mode." &
    \	response$=fn_getanswer$ &
    \   on where% goto 2100,2100,9900
2100  	call plot("T5215")
2105    advice$="+A5215" &
    \	answer$="" &
    \	feedback$="" &
    \   limit%=30% &
    \   option%=NO_CAPS% &
    \	response$=fn_getanswer$ &
    \   on where% goto 2110,2110,9900
2110    if response$<>"" then &
                line1$="1.1   "+response$ &
                else &
                call feedbk ("Please enter a line of text into the file.") &
    \           goto 2105
2200	call plot("T5220") &
    \   advice$="+A5220" &
    \	answer$="<EOF>" &
    \   ntries%=100% &
    \	feedback$="Please press CTRL/Z to return to line mode." &
    \	response$=fn_getanswer$ &
    \   on where% goto 2250,2250,9900
2250	call plot("T5225") &
    \   ntries%=3% &
    \   advice$="+A5225" &
    \	answer$="T*YPE W*HOLE" &
    \	feedback$="Please display the whole file to see the change." &
    \	response$=fn_getanswer$ &
    \   on where% goto 2300,2300,9900
2300	call plot("B5225") &
    \   call feedbk(line1$) &
    \	call plot("T5230") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \   on where% goto 2350,2350,9900
2350	call plot("T5235")
2355	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \   on where% goto 3000,2360,9900
2360	if left$(response$,1%)="M" then &
		goto 2400 &
		else &
		call feedbk("Please type MORE or press RETURN.") &
    \		goto 2355
2400	call plot("T5240") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \   on where% goto 2450,2450,9900
2450  !	&
      !	Now set up the file &
      !	&
    \	file$(1%,0%)="1       Practice using the FIND command with single line ranges." &
    \	file$(2%,0%)="2       For example:   FIND BEGIN - finds the first line in the file." &
    \	file$(3%,0%)="3       The current cursor position is marked by >." &
    \	file$(4%,0%)="4" &
    \	file$(5%,0%)="5       For more examples of the FIND command, press <ADVICE>." &
    \	file$(6%,0%)="6" &
    \	file$(7%,0%)="7       When you are ready to continue, type: QUIT." &
    \	file$(8%,0%)="[EOB]" &
    \	buffer_number%=0% &
    \	buffer_ptr(0%,0%)=1% &
    \	buffer_ptr(1%,0%)=1% &
    \	buffer_ptr(2%,0%)=8% &
    \	buffer_ptr(3%,0%)=1% &
    \	buffer_ptr(4%,0%)=8% &
      !	&
    \	call plot("T5245") &
    \	temp%=buffer_ptr(3%,0%) &
    \	call setloc("A",0%,0%,temp%,1%) &
    \	call feedbk(">") &
    \	call setloc("A",0%,0%,11%,3%)
2455	call plot("-T5245") &
    \	advice$="+A5245" &
    \	answer$="Q*UIT" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \   on where% goto 3000,2460,9900
2460	gosub 10000 &
    \	goto 2455
3000	call plot("S5200") &
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
10000 !	&
      !	****	Subroutine to parse line ranges and display them &
      !	&
    \	call parsel(response$) &
    \	error_text$="Please use the FIND command, or QUIT to quit." if command$<>"FIND" &
    \	if error_code%<>0% or command$<>"FIND" then &
		call feedbk(error_text$) &
    \		return
10010	temp%=buffer_ptr(3%,0%) &
    \	call setloc("A",0%,0%,temp%,1%) &
    \	call feedbk(" "+chr$(8%)) &
    \	buffer_ptr(1%,0%)=range_list(0%,1%) &
    \	buffer_ptr(1%,0%)=buffer_ptr(2%,0%) if buffer_ptr(1%,0%)>buffer_ptr(2%,0%) &
    \	buffer_ptr(3%,0%)=buffer_ptr(1%,0) &
    \	temp%=buffer_ptr(3%,0%) &
    \	call setloc("A",0%,0%,temp%,1%) &
    \	call feedbk(">") &
    \	call setloc("A",9%,3%,11%,3%) &
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
