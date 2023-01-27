1	SUB EDT62
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
1100	call plot("I6200") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2000,2000,9900
2000	call plot("T6200") &
    \	call plot("B6200") &
    \	advice$="+A6200" &
    \	answer$="ED*IT/ED*T NAMES.LIS" &
    \	feedback$="Please edit the file:  NAMES.LIS" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2100,2100,9900
2100	buffer_number%=0% &
    \	buffer_ptr(0%,buffer_number%)=1% &
    \	buffer_ptr(1%,buffer_number%)=1% &
    \	buffer_ptr(2%,buffer_number%)=1% &
    \	buffer_ptr(3%,buffer_number%)=1% &
    \	buffer_ptr(4%,buffer_number%)=1% &
    \	file$(0%,buffer_number%)="MAIN" &
    \	file$(1%,buffer_number%)="[EOB]" &
      !	&
    \	call plot("T6205") &
    \	call plot("B6205")
2105	advice$="+A6205" &
    \	answer$="INC*LUDE A.LIS" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2150,2110,9900
2110	call parsel(response$) &
    \	if error_code%>0% then &
		call feedbk(error_text$) &
    \		goto 2105
2115	error_text$="" &
    \	error_text$="Please use the INCLUDE command." if command$<>"INCLUDE" &
    \	error_text$="Please INCLUDE file A.LIS, not "+file_name$ if file_name$<>"A.LIS" &
    \	if error_text$<>"" then &
		call feedbk(error_text$) &
    \		goto 2105
2150	file$(1%,0%)="1     Allen" &
    \	file$(2%,0%)="2     Anderson" &
    \	file$(3%,0%)="[EOB]" &
    \	buffer_ptr(2%,0%)=3% &
    \	buffer_ptr(4%,0%)=3% &
    \	call plot("T6210") &
    \	call plot("B6210")
2155	advice$="+A6210" &
    \	answer$="T*YPE W*HOLE" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2200,2160,9900
2160	call parsel(response$) &
    \	if error_code%>0% then &
		call feedbk(error_text$) &
    \		goto 2155
2165	error_text$="" &
    \	error_text$="Please use the TYPE command." if command$<>"TYPE" &
    \	error_text$="Please type the entire buffer." &
		if range_list(0%,0%)<2% or range_list(0%,1%)<>1% or range_list(0%,2%)<>2% &
    \	if error_text$<>"" then &
		call feedbk(error_text$) &
    \		goto 2155
2200	call plot("T6215") &
    \	call plot("B6215")
2205	advice$="+A6215" &
    \	answer$="INC*LUDE B.LIS E*ND" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2250,2210,9900
2210	call parsel(response$) &
    \	if error_code%>0% then &
		call feedbk(error_text$) &
    \		goto 2205
2215	error_text$="" &
    \	error_text$="Please use the INCLUDE command." if command$<>"INCLUDE" &
    \	error_text$="Please INCLUDE file B.LIS, not "+file_name$ if file_name$<>"B.LIS" &
    \	error_text$="Please place the file at the end of the buffer." if line_11<3 &
    \	if error_text$<>"" then &
		call feedbk(error_text$) &
    \		goto 2205
2250	file$(3%,0%)="3     Brady" &
    \	file$(4%,0%)="[EOB]" &
    \	buffer_ptr(2%,0%)=4% &
    \	buffer_ptr(4%,0%)=4% &
    \	call plot("T6220") &
    \	call plot("B6220")
2255	advice$="+A6220" &
    \	answer$="T*YPE W*HOLE" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2300,2260,9900
2260	call parsel(response$) &
    \	if error_code%>0% then &
		call feedbk(error_text$) &
    \		goto 2255
2265	error_text$="" &
    \	error_text$="Please use the TYPE command." if command$<>"TYPE" &
    \	error_text$="Please TYPE the MAIN buffer." if buffer_1$<>"" and buffer_1$<>"MAIN" &
    \	error_text$="Please TYPE all of the MAIN buffer." if range_list(0%,0%)<3% &
    \	if error_text$<>"" then &
		call feedbk(error_text$) &
    \		goto 2255
2300	buffer_ptr(0%,1%)=1% &
    \	buffer_ptr(1%,1%)=1% &
    \	buffer_ptr(2%,1%)=1% &
    \	buffer_ptr(3%,1%)=1% &
    \	buffer_ptr(4%,1%)=1% &
    \	file$(0%,1%)="MORE" &
    \	file$(1%,1%)="[EOB]" &
      !	&
    \	call plot("T6225") &
    \	call plot("B6225")
2305	advice$="+A6225" &
    \	answer$="INC*LUDE MORE.LIS =MORE" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2350,2310,9900
2310	call parsel(response$) &
    \	if error_code%>0% then &
		call feedbk(error_text$) &
    \		goto 2305
2315	error_text$="" &
    \	error_text$="Please use the INCLUDE command." if command$<>"INCLUDE" &
    \	error_text$="Please INCLUDE file MORE.LIS, not "+file_name$ if file_name$<>"MORE.LIS" &
    \	error_text$="Please place the file into the buffer MORE." if buffer_1$<>"MORE" &
    \	if error_text$<>"" then &
		call feedbk(error_text$) &
    \		goto 2305
2350	buffer_number%=1% &
    \	file$(1%,1%)="1     Arnold" &
    \	file$(2%,1%)="2     Baker" &
    \	file$(3%,1%)="[EOB]" &
    \	buffer_ptr(2%,1%)=3% &
    \	buffer_ptr(4%,1%)=3% &
      !	&
    \	call plot("T6230") &
    \	call plot("B6230")
2355	advice$="+A6230" &
    \	answer$="T*YPE =MORE W*HOLE" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2400,2360,9900
2360	buffer_number%=1% &
    \	call parsel(response$) &
    \	if error_code%>0% then &
		call feedbk(error_text$) &
    \		goto 2355
2365	error_text$="" &
    \	error_text$="Please use the TYPE command." if command$<>"TYPE" &
    \	error_text$="Please display the contents of the buffer MORE." &
		if buffer_1$<>"" and buffer_1$<>"MORE" &
    \	error_text$="Please display all of the buffer MORE." &
		if range_list(0%,0%)<2% &
    \	if error_text$<>"" then &
		call feedbk(error_text$) &
    \		goto 2355
2400	call plot("T6235") &
    \	call plot("B6235")
2405	advice$="+A6235" &
    \	answer$="MO*VE 2 TO =MAIN 3" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2450,2410,9900
2410	call parsel(response$) &
    \	if error_code%>0% then &
		call feedbk(error_text$) &
    \		goto 2405
2415	error_text$="" &
    \	error_text$="Please use the MOVE command." if command$<>"MOVE" &
    \	error_text$="Please MOVE line 2 from the buffer MORE." &
		if buffer_1$<>"" and buffer_1$<>"MORE" &
    \	error_text$="Please MOVE line 2 from the buffer MORE." &
		if range_list(0%,0%)<>1% and range_list(0%,1%)<>2% &
    \	error_text$="Please MOVE line 2 to before line 3 in the MAIN buffer." &
		if buffer_2$<>"MAIN" &
    \	error_text$="Please MOVE line 2 to before line 3 in the MAIN buffer." &
		if range_list(1%,0%)<>1% and range_list(1%,1%)<>3% &
    \	if error_text$<>"" then &
		call feedbk(error_text$) &
    \		goto 2405
2450	file$(5%,0%)=file$(4%,0%) &
    \	file$(4%,0%)=file$(3%,0%) &
    \	file$(3%,0%)="2.1   Arnold" &
    \	buffer_ptr(4%,0%)=5% &
    \	file$(2%,1%)="[EOB]" &
      !	&
    \	call plot("T6240") &
    \	call plot("B6240")
2455	advice$="+A6240" &
    \	answer$="=MAIN" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2500,2460,9900
2460	call parsel(response$) &
    \	if error_code%>0% then &
		call feedbk(error_text$) &
    \		goto 2455
2465	error_text$="" &
    \	error_text$="Please use the TYPE command." if command$<>"TYPE" &
    \	error_text$="Please TYPE the MAIN buffer." if buffer_1$<>"MAIN" &
    \	error_text$="Please TYPE all of the MAIN buffer." if range_list(0%,0%)<4% &
    \	if error_text$<>"" then &
		call feedbk(error_text$) &
    \		goto 2455
2500	buffer_number%=0% &
    \	call plot("T6245") &
    \	call plot("B6245")
2505	advice$="+A6245" &
    \	answer$="MO*VE =MORE 1 TO 3" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2550,2510,9900
2510	call parsel(response$) &
    \	if error_code%>0% then &
		call feedbk(error_text$) &
    \		goto 2505
2515	error_text$="" &
    \	error_text$="Please use the MOVE command." if command$<>"MOVE" &
    \	error_text$="Please MOVE line 1 from the buffer MORE." &
		if buffer_1$<>"MORE" &
    \	error_text$="Please MOVE line 1 from the buffer MORE." &
		if range_list(0%,0%)<>1% and range_list(0%,1%)<>1% &
    \	error_text$="Please MOVE line 1 to before line 3 in the MAIN buffer." &
		if buffer_2$<>"" and buffer_2$<>"MAIN" &
    \	error_text$="Please MOVE line 1 to before line 3 in the MAIN buffer." &
		if range_list(1%,0%)<>1% and range_list(1%,1%)<>3% &
    \	if error_text$<>"" then &
		call feedbk(error_text$) &
    \		goto 2505
2550	file$(6%,0%)=file$(5%,0%) &
    \	file$(5%,0%)=file$(4%,0%)
    \	file$(4%,0%)="2.2   Baker" &
    \	buffer_ptr(4%,0%)=6% &
    \	file$(2%,1%)="[EOB]" &
    \	call plot("T6250") &
    \	call plot("B6250")
2555	advice$="+A6250" &
    \	answer$="=MAIN" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2600,2560,9900
2560	call parsel(response$) &
    \	if error_code%>0% then &
		call feedbk(error_text$) &
    \		goto 2555
2565	error_text$="" &
    \	error_text$="Please use the TYPE command." if command$<>"TYPE" &
    \	error_text$="Please TYPE the MAIN buffer." &
		if buffer_1$<>"" and buffer_1$<>"MAIN" &
    \	error_text$="Please TYPE all of the MAIN buffer." if range_list(0%,0%)<5% &
    \	if error_text$<>"" then &
		call feedbk(error_text$) &
    \		goto 2555
2600	call plot("T6255") &
    \	call plot("B6255") &
    \	advice$="+A6255" &
    \	answer$="EX*IT" &
    \	feedback$="Please leave EDT, saving the contents of the file." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2650,2650,9900
2650	call plot("T6260") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 4000,4000,9900
4000	call plot("S6200") &
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
