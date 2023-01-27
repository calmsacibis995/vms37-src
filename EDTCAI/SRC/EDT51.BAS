1	SUB EDT51
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
      !	&
    \	common (qiocom)	fill%(5%), &
			response_length%, &
			feedbk_length%, &
			escape$=1%, &
			terminal$=3% &
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
920	def fn_at$(x%,y%) &
      !	&
    \	f_temp$="" &
    \	f_temp$=escape$+"Y"+chr$(x%+31%)+chr$(y%+31%) if terminal$="V52" &
    \	f_temp$=escape$+"["+num1$(x%)+";"+num1$(y%)+"H" if terminal$="VT1" &
    \	fn_at$=f_temp$ &
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
    \	call plot("I5100") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \   on where% goto 2000,2000,9900
2000	call plot("T5100") &
    \	answer$="T*YPE 1" &
    \	feedback$="Please display line 1 of the file." &
    \   advice$="+A5100" &
    \   limit%=41% &
    \	response$=fn_getanswer$ &
    \   on where% goto 2050,2050,9900
2050	call plot("T5105") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \   on where% goto 2100,2100,9900
2100	call plot("T5110")
2105    answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \   on where% goto 4000,2110,9900
2110	if left$(response$,1%)="M" then 3000 &
                 else call feedbk("Please type MORE or press RETURN.") &
    \            goto 2105
3000    call plot("T5115") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \   on where% goto 3050,3050,9900
3050  !	&
      !	Set up the file for parsing &
      !	&
    \	file$(1%,0%)="1       Practice using the TYPE command with single line ranges." &
    \	file$(2%,0%)="2       For example:   TYPE BEGIN - displays the first line in the file." &
    \	file$(3%,0%)="3       The current cursor position is marked by >." &
    \	file$(4%,0%)="4" &
    \	file$(5%,0%)="5       For more examples of single line ranges, press <ADVICE>." &
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
    \	call plot("T5120") &
    \	print fn_at$(buffer_ptr(3%,0%),1%)+">";
3055	call plot("-T5120") &
    \	advice$="+A5120" &
    \	answer$="Q*UIT" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \   on where% goto 4000,3100,9900
3100	gosub 10000 &
    \	goto 3055 if error_code%<>0% &
    \	call feedbk("In this section, please use only single line ranges.") &
		if range_list(0%,0%)>1% &
    \	goto 3055
4000	call plot("T5125")
4005    advice$="+A5125" &
    \	answer$="T*YPE 2:4" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \   on where% goto 4050,4010,9900
4010	if response$="TYPE 2 THRU 4" then &
		goto 4050 &
		else &
		call feedbk("Please display lines 2 through 4.") &
    \		goto 4005
4050	call plot("T5130") &
    \   advice$="" &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \   on where% goto 4100,4100,9900
4100	call plot("T5135")
4105    answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \   on where% goto 5000,4150,9900
4150	call plot("T5140") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \   on where% goto 4200,4200,9900
4200  !	&
      !	Here set up the file &
      !	&
    \	file$(1%,0%)="1       Practice using the TYPE command with contiguous line ranges." &
    \	file$(2%,0%)="2       For example:  TYPE REST  - displays the lines from the current" &
    \	file$(3%,0%)="3                     line to the end of the file." &
    \	file$(4%,0%)="4       The current cursor position is marked by >." &
    \	file$(5%,0%)="5" &
    \	file$(6%,0%)="6       For more examples of contiguous line ranges, press <ADVICE>." &
    \	file$(7%,0%)="7" &
    \	file$(8%,0%)="8       When you are ready to continue, type: QUIT." &
    \	file$(9%,0%)="[EOB]" &
    \	buffer_number%=0% &
    \	buffer_ptr(0%,0%)=1% &
    \	buffer_ptr(1%,0%)=1% &
    \	buffer_ptr(2%,0%)=9% &
    \	buffer_ptr(3%,0%)=1% &
    \	buffer_ptr(4%,0%)=9% &
      !	&
    \	call plot("T5145") &
    \	print fn_at$(buffer_ptr(3%,0%),1%)+">";
4205	call plot("-T5145") &
    \	advice$="+A5145" &
    \	answer$="Q*UIT" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \   on where% goto 5000,4250,9900
4250	gosub 10000 &
    \	goto 4205 if error_code%<>0% &
      !	&
      !	Here check for single or non-contiguous ranges &
      !	&
    \	if range_list(0%,0%)<2% then &
		call feedbk("Please use contiguous line ranges in this section.") &
    \		goto 4205
4255	for i%=1% to range_list(0%,0%)-1% &
    \		goto 4260 if range_list(0%,i%)>buffer_ptr(2%,0%) &
			  or range_list(0%,i%+1%)>buffer_ptr(2%,0%) &
    \		goto 4260 if range_list(0%,i%)-1%=range_list(0%,i%+1%) &
			  or range_list(0%,i%)+1%=range_list(0%,i%+1%) &
    \		call feedbk("Please use contiguous line ranges in this section.") &
    \		goto 4205
4260	next i% &
    \	goto 4205
5000	call plot("T5150")
5005    advice$="+A5150" &
    \	answer$="T*YPE 1,3" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \   on where% goto 5050,5010,9900
5010	if response$="TYPE 1 AND 3" then &
		goto 5050 &
		else &
		call feedbk("Please display lines 1 and 3 of the file.") &
    \		goto 5005
5050	call plot("T5155") &
    \   advice$="" &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \   on where% goto 5100,5100,9900
5100	call plot("T5160")
5105    answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \   on where% goto 6000,5110,9900
5110	if left$(response$,1%)="M" then &
		goto 5150 &
		else &
		call feedbk("Please type MORE or press RETURN.") &
    \		goto 5105
5150	call plot("T5165") &
    \   advice$="" &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \   on where% goto 5200,5200,9900
5200  !	&
      !	Here set up the file &
      !	&
    \	file$(1%,0%)="1       Practice using the TYPE command with noncontiguous line ranges." &
    \	file$(2%,0%)="2       For example:  TYPE 1,3,7  - displays lines 1, 3" &
    \	file$(3%,0%)="3                     and 7." &
    \	file$(4%,0%)="4       The current cursor position is marked by >." &
    \	file$(5%,0%)="5" &
    \	file$(6%,0%)="6       For more examples of noncontiguous line ranges, press <ADVICE>." &
    \	file$(7%,0%)="7" &
    \	file$(8%,0%)="8       When you are ready to continue, type: QUIT." &
    \	file$(9%,0%)="[EOB]" &
    \	buffer_number%=0% &
    \	buffer_ptr(0%,0%)=1% &
    \	buffer_ptr(1%,0%)=1% &
    \	buffer_ptr(2%,0%)=9% &
    \	buffer_ptr(3%,0%)=1% &
    \	buffer_ptr(4%,0%)=9% &
      !	&
    \	call plot("T5170") &
    \	print fn_at$(buffer_ptr(3%,0%),1%)+">";
5205	call plot("-T5170") &
    \	advice$="+A5170" &
    \	answer$="Q*UIT" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \   on where% goto 6000,5250,9900
5250	gosub 10000 &
    \	goto 5205 if error_code%<>0% &
      !	&
      !	Here check for single or contiguous ranges &
      !	&
    \	if range_list(0%,0%)<2% then &
		call feedbk("Please use noncontiguous line ranges in this section.") &
    \		goto 5205
5255	for i%=1% to range_list(0%,0%)-1% &
    \		goto 5260 if range_list(0%,i%)>buffer_ptr(2%,0%) &
			  or range_list(0%,i%+1%)>buffer_ptr(2%,0%) &
    \		goto 5205 if range_list(0%,i%)-1%<>range_list(0%,i%+1%) &
			 and range_list(0%,i%)+1%<>range_list(0%,i%+1%)
5260	next i% &
    \	call feedbk("Please use noncontiguous line ranges in this section.") &
    \	goto 5205
6000	call plot("S5100") &
    \   advice$="" &
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
    \	error_text$="Please use the TYPE command, or QUIT to quit." if command$<>"TYPE" &
    \	if error_code%<>0% or command$<>"TYPE" then &
		call feedbk(error_text$) &
    \		return
10010	current_line%=13% &
    \	current_column%=5% &
    \	print fn_at$(buffer_ptr(3%,0%),1%)+" "; &
    \	call plot("U5100") &
    \	for i%=1% to range_list(0%,0%) &
    \		temp%=range_list(0%,i%) &
    \		temp%=buffer_ptr(2%,0%) if temp%>buffer_ptr(2%,0%) &
    \		print fn_at$(current_line%,current_column%)+file$(temp%,0%) &
    \		current_line%=current_line%+1% &
    \		current_line%=21% if current_line%>21% &
    \	next i% &
    \	buffer_ptr(1%,0%)=range_list(0%,1%) &
    \	buffer_ptr(1%,0%)=buffer_ptr(2%,0%) if buffer_ptr(1%,0%)>buffer_ptr(2%,0%) &
    \	buffer_ptr(3%,0%)=buffer_ptr(1%,0) &
    \	print fn_at$(buffer_ptr(3%,0%),1%)+">" &
    \	call setloc("A",10%,3%,11%,3%) &
    \	response_length%=len(response$)+5% &
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
