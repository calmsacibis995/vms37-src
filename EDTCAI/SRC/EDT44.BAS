1	SUB EDT44
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
      !	****	Begin Main Routine &
      !	&
    \	call plot("I4400") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2000,2000,9900
2000  !	&
      !	First set up the file &
      !	&
    \	file$(0%,0%)="MAIN" &
    \	file$(1%,0%)="1     This is line 1." &
    \	file$(2%,0%)="2     This is line 2." &
    \	file$(3%,0%)="[EOB]" &
    \	buffer_number%=0% &
    \	buffer_ptr(0%,0%)=1% &
    \	buffer_ptr(1%,0%)=1% &
    \	buffer_ptr(2%,0%)=3% &
    \	buffer_ptr(3%,0%)=1% &
    \	buffer_ptr(4%,0%)=3% &
      !	&
    \	call plot("T4400") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2050,2050,9900
2050	call plot("T4403")
2055	answer$="S*UBSTITUTE/IS/WAS" &
    \	feedback$="" &
    \	advice$="+A4403" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2100,2060,9900
2060	call parsel(response$) &
    \	if error_code%<>0% then &
		call feedbk(error_text$) &
    \		goto 2055
2065	temp$="" &
    \	temp$="Please use the SUBSTITUTE command." if command$<>"SUBSTITUTE" &
    \	temp$="Please substitute 'was' for 'is'." if sub_string_1$<>"/IS/" or sub_string_2$<>"/WAS/" &
    \	temp$="Please substitute 'was' for 'is' in line 1 only." &
		if range_list(0%,0%)<1% or range_list(0%,1%)<>1% &
    \	if temp$<>"" then &
		call feedbk(temp$) &
    \		goto 2055
2100	call plot("T4406") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2150,2150,9900
2150	call plot("T4409") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2180,2180,9900
2180	call plot("T4412")
2181	answer$="S*UBSTITUTE/ IS/ WAS" &
    \	feedback$="" &
    \	advice$="+A4412" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2190,2182,9900
2182	call parsel(response$) &
    \	if error_code%<>0% then &
		call feedbk(error_text$) &
    \		goto 2181
2183	temp$="" &
    \	temp$="Please use the SUBSTITUTE command." if command$<>"SUBSTITUTE" &
    \	temp$="Please substitute ' was' for ' is'." if sub_string_1$<>"/ IS/" or sub_string_2$<>"/ WAS/" &
    \	temp$="Please substitute ' was' for ' is' in line 1 only." &
		if range_list(0%,0%)<1% or range_list(0%,1%)<>1% &
    \	if temp$<>"" then &
		call feedbk(temp$) &
    \		goto 2181
2190	call plot("T4415") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2200,2200,9900
2200	call plot("T4418")
2205	advice$="+A4418" &
    \	answer$="S*UBSTITUTE/LINE/NUMBER/2" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3000,2210,9900
2210	call parsel(response$) &
    \	if error_code%<>0% then &
		call feedbk(error_text$) &
    \		goto 2205
2215	temp$="" &
    \	temp$="Please use the SUBSTITUTE command." if command$<>"SUBSTITUTE" &
    \	temp$="Please substitute 'number' for 'line'." if sub_string_1$<>"/LINE/" or sub_string_2$<>"/NUMBER/" &
    \	temp$="Please substitute 'number' for 'line' in line 2 only." &
		if range_list(0%,0%)<>1% or range_list(0%,1%)<>2% &
    \	if temp$<>"" then &
		call feedbk(temp$) &
    \		goto 2205
3000	call plot("T4421") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3050,3050,9900
3050	call plot("T4424")
3055	advice$="+A4424" &
    \	answer$="S*UBSTITUTE/THIS IS/COPY/W*HOLE" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3100,3060,9900
3060	call parsel(response$) &
    \	if error_code%<>0% then &
		call feedbk(error_text$) &
    \		goto 3055
3065	temp$="" &
    \	temp$="Please use the SUBSTITUTE command." if command$<>"SUBSTITUTE" &
    \	temp$="Please substitute 'Copy' for 'This is'." if sub_string_1$<>"/THIS IS/" or sub_string_2$<>"/COPY/" &
    \	temp$="Please substitute 'Copy' for 'This is' in the whole file." &
		if range_list(0%,0%)<2% &
    \	if temp$<>"" then &
		call feedbk(temp$) &
    \		goto 3055
3100	call plot("T4427") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3150,3150,9900
3150	call plot("T4430")
3155	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 4260,3160,9900
3160	if left$(response$,1%)="M" then 3200 &
		else call feedbk("Please type MORE or press RETURN.") &
    \		goto 3155
3200	call plot("T4433")
3205	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3300,3210,9900
3210	if left$(response$,1%)="M" then 3250 &
		else call feedbk("Please type MORE or press RETURN.") &
    \		goto 3205
3250	call plot("T4436") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3300,3300,9900
3300	call plot("T4439") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3350,3350,9900
3350  !	&
      !	Set up the file &
      !	&
    \	file$(0%,0%)="MAIN" &
    \	file$(1%,0%)="10 100  REM: A sample set of lines to illustrate" &
    \	file$(2%,0%)="20 110  REM: the use of the QUERY option with" &
    \	file$(3%,0%)="30 120  REM: the SUBSTITUTE command." &
    \	file$(4%,0%)='40 130  PRINT "This is the example."' &
    \	file$(5%,0%)="50 140  END" &
    \	file$(6%,0%)="[EOB]" &
    \	buffer_number%=0% &
    \	buffer_ptr(0%,0%)=10% &
    \	buffer_ptr(1%,0%)=10% &
    \	buffer_ptr(2%,0%)=50% &
    \	buffer_ptr(3%,0%)=1% &
    \	buffer_ptr(4%,0%)=6% &
      !	&
    \	call plot ("T4442")
3355	advice$="+A4442" &
    \	answer$="S*UBSTITUTE/REM:/!/W*HOLE/Q*UERY" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3450,3360,9900
3360	call parsel(response$) &
    \	if error_code%<>0% then &
		call feedbk(error_text$) &
    \		goto 3355
3365	temp$="" &
    \	temp$="Please use the SUBSTITUTE command." if command$<>"SUBSTITUTE" &
    \	temp$="Please substitute '!' for 'REM:'." if sub_string_1$<>"/REM:/" or sub_string_2$<>"/!/" &
    \	temp$="Please substitute '!' for 'REM:' in the whole file." &
		if range_list(0%,0%)<5% &
    \	temp$="Please include the /QUERY option." if option$<>"/QUERY" &
    \	if temp$<>"" then &
		call feedbk(temp$) &
    \		goto 3355
3450	call plot("T4445") &
    \	advice$="+A4445" &
    \	answer$="Y*ES" &
    \	feedback$="Please make this substitution." &
    \	response$=fn_getanswer$ &
    \	on where% goto 3500,3500,9900
3500	call plot("T4448") &
    \	advice$="+A4448" &
    \	answer$="N*O" &
    \	feedback$="Please do not make this substitution." &
    \	response$=fn_getanswer$ &
    \	on where% goto 3550,3550,9900
3550	call plot("T4451") &
    \	advice$="+A4445" &
    \	answer$="Y*ES" &
    \	feedback$="Please make this substitution." &
    \	response$=fn_getanswer$ &
    \	on where% goto 3600,3600,9900
3600	call plot("T4454") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3650,3650,9900
3650	call plot("T4457") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 4000,4000,9900
4000	call plot("T4460") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 4050,4050,9900
4050  !	&
      !	Set up the file &
      !	&
    \	file$(0%,0%)="MAIN" &
    \	file$(1%,0%)="10 A computer is determined by many factors including architecture," &
    \	file$(2%,0%)="20 structural properties, the technological environment, and the human" &
    \	file$(3%,0%)="30 aspects of the environment in which it was designed and built." &
    \	file$(4%,0%)="40 (Bell et al., Computer Engineering, Digital Press, 1978)" &
    \	file$(5%,0%)="[EOB]" &
    \	buffer_number%=0% &
    \	buffer_ptr(0%,0%)=10% &
    \	buffer_ptr(1%,0%)=10% &
    \	buffer_ptr(2%,0%)=40% &
    \	buffer_ptr(3%,0%)=1% &
    \	buffer_ptr(4%,0%)=5% &
      !	&
    \	call plot("T4463")
4055	advice$="+A4463" &
    \	answer$="S*UBSTITUTE/ENVIRONMENT/SETTING/W*HOLE/BR*IEF:7" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 4100,4060,9900
4060	call parsel(response$) &
    \	if error_code%<>0% then &
		call feedbk(error_text$) &
    \		goto 4055
4065	temp$="" &
    \	temp$="Please use the SUBSTITUTE command." if command$<>"SUBSTITUTE" &
    \	temp$="Please substitute 'setting' for 'environment'." &
		 if sub_string_1$<>"/ENVIRONMENT/" or sub_string_2$<>"/SETTING/" &
    \	temp$="Please substitute 'setting' for 'environment' in the whole file." &
		if range_list(0%,0%)<4% &
    \	temp$="Please include the /BRIEF option." if option$<>"/BRIEF" &
    \	temp$="Please display only 7 characters with the /BRIEF option." &
		if option_n%<>7% &
    \	if temp$<>"" then &
		call feedbk(temp$) &
    \		goto 4055
4100	call plot("T4466") &
    \	advice$="+A4466" &
    \	answer$="T*YPE W*HOLE" &
    \	feedback$="Please type:  TYPE WHOLE" &
    \	response$=fn_getanswer$ &
    \	on where% goto 4150,4150,9900
4150	call plot("T4469") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 4200,4200,9900
4200	call plot("T4472") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 4250,4250,9900
4250	call plot("T4475") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 4260,4260,9900
4260	call plot("S4400") &
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
