1	SUB EDT61
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
    \	limit%=39% &
    \	option%=0% &
    \	NO_ECHO%=-32767% &
    \	SINGLE_CHARACTER%=-32766% &
    \	NO_KEYPAD%=-32765% &
    \	NO_SPACES%=-32764% &
    \	NO_CAPS%=-32763% &
    \	DO_FORM%=-32762% &
      !
1100	call plot("I6100") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2000,2000,9900
2000	call plot("T6100") &
    \	call plot("B6100") &
    \	advice$="+A6100" &
    \	answer$="ED*IT/ED*T AD.LIS" &
    \	feedback$="Please enter EDT to edit the file AD.LIS." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2100,2100,9900
2100  !	&
      !	Set up the file with all its buffers &
      !	&
    \	buffer_number%=0% &
    \	buffer_ptr(0%,buffer_number%)=1% &
    \	buffer_ptr(1%,buffer_number%)=1% &
    \	buffer_ptr(2%,buffer_number%)=3% &
    \	buffer_ptr(3%,buffer_number%)=1% &
    \	buffer_ptr(4%,buffer_number%)=3% &
    \	file$(0%,buffer_number%)="MAIN" &
    \	file$(1%,buffer_number%)="1      SALE!  SALE!  SALE!  SALE!" &
    \	file$(2%,buffer_number%)="2                                " &
    \	file$(3%,buffer_number%)="[EOB]" &
      !	&
    \	buffer_ptr(0%,1%)=0% &
    \	buffer_ptr(1%,1%)=0% &
    \	buffer_ptr(2%,1%)=0% &
    \	buffer_ptr(3%,1%)=1% &
    \	buffer_ptr(4%,1%)=1% &
    \	file$(0%,1%)="SECOND" &
    \	file$(1%,1%)="[EOB]" &
      !	&
    \	call plot("T6105") &
    \	call plot("B6105")
2105	advice$="+A6105" &
    \	answer$="T*YPE =SECOND W*HOLE" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2150,2110,9900
2110	call parsel(response$) &
    \	if error_code%>0% then &
		call feedbk(error_text$) &
    \		goto 2105
2115	error_text$="" &
    \	error_text$="Please use the TYPE command." if command$<>"TYPE" &
    \	error_text$="Please display the contents of the buffer SECOND." if buffer_1$<>"SECOND" &
    \	if error_text$<>"" then &
		call feedbk(error_text$) &
    \		goto 2105
2150	buffer_number%=1% &
    \	call plot("T6110") &
    \	call plot("B6110") &
    \	advice$="+A6110" &
    \	answer$="SH*OW BU*FFER" &
    \	feedback$="The SHOW BUFFER command shows the buffers." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2200,2200,9900
2200	call plot("T6115") &
    \	call plot("B6115")
2205	advice$="+A6115" &
    \	answer$="I*NSERT" &
    \	feedback$="Please use the INSERT command (abbreviated as I)." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2250,2210,9900
2210	call parsel(response$) &
    \	if error_code%>0% then &
		call feedbk(error_text$) &
    \		goto 2205
2215	error_text$="" &
    \	error_text$="Please use the INSERT command." if command$<>"INSERT" &
    \	error_text$="Please INSERT text into the SECOND buffer." if buffer_number%<>1% &
    \	if error_text$<>"" then &
		call feedbk(error_text$) &
    \		goto 2205
2220	if error_code%<0% then &
		call feedbk("Since there is nothing in the SECOND buffer, no range is necessary.") &
		else if buffer_1$="SECOND" then &
			call feedbk("It is unnecessary (but ok) to specify the SECOND buffer.")
2250	call plot("T6120") &
    \	call plot("B6120") &
    \	limit% = 28%
2255	advice$="+A6120" &
    \	answer$="" &
    \	feedback$="" &
    \	option%=NO_CAPS% &
    \	response$=fn_getanswer$ &
    \	on where% goto 2255,2260,9900
2260	file$(1%,1%)="1     "+response$ &
    \	file$(2%,1%)="[EOB]" &
    \	buffer_ptr(0%,1%)=1% &
    \	buffer_ptr(1%,1%)=1% &
    \	buffer_ptr(2%,1%)=2% &
    \	buffer_ptr(3%,1%)=1% &
    \	buffer_ptr(4%,1%)=2%
2300	call plot("T6125") &
    \	call plot("B6125") &
    \	advice$="+A6125" &
    \	ntries% = 1000% &
    \	limit% = 1% &
    \	answer$="<EOF>" &
    \	feedback$="Please press CTRL/Z." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2350,2350,9900
2350	call plot("T6130") &
    \	call plot("B6130") &
    \	limit% = 39%
2355	advice$="+A6130" &
    \	ntries% = 3% &
    \	answer$="CO*PY W*HOLE TO =MAIN 3" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2400,2360,9900
2360	call parsel(response$) &
    \	if error_code%>0% then &
		call feedbk(error_text$) &
    \		goto 2355
2365	error_text$="" &
    \	error_text$="Please use the COPY command." if command$<>"COPY" &
    \	error_text$="Please COPY all of the SECOND buffer." &
		if line_11<>1 or (buffer_1$<>"" and buffer_1$<>"SECOND") &
    \	error_text$="Please copy the SECOND buffer to the MAIN buffer." &
		if buffer_2$<>"MAIN" &
    \	error_text$="Please copy the SECOND buffer to line 3, not line "+num1$(line_21) &
		if line_21<3 &
    \	if error_text$<>"" then &
		call feedbk(error_text$) &
    \		goto 2355
2400	file$(3%,0%)="2.1"+right$(file$(1%,1%),2%) &
    \	buffer_number%=0% &
    \	buffer_ptr(0%,buffer_number%)=1% &
    \	buffer_ptr(1%,buffer_number%)=3% &
    \	buffer_ptr(2%,buffer_number%)=4% &
    \	buffer_ptr(3%,buffer_number%)=3% &
    \	buffer_ptr(4%,buffer_number%)=4% &
    \	call plot("T6135") &
    \	call plot("B6135") &
    \	advice$="+A6135" &
    \	answer$="=MAIN" &
    \	feedback$="All you need to type is:  =MAIN" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2450,2450,9900
2450	call plot("T6140") &
    \	call feedbk(right$(file$(3%,0%),4%)) &
    \	call plot("B6140") &
    \	call plot("B6141") &
    \	advice$="+A6140" &
    \	answer$="EX*IT" &
    \	feedback$="Please leave EDT, saving the contents of the file." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2500,2500,9900
2500	call plot("T6145") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 4000,4000,9900
4000	call plot("S6100") &
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
32767	subend &

