1	SUB EDT53
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
    \	common (hlpcom)	library_index%, &
			current_row%, &
			current_column%, &
			header_flag% &
      !	&
    \	external integer function print_help &
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
920	def fn_find_line%(f_temp0) &
      !	&
      !	This function will return the address of the line number F_TEMP0. &
      !	&
    \	for f_temp%=1% to buffer_ptr(4%,0%) &
    \		f_temp1=999% &
    \		f_temp1=val(left$(file$(f_temp%,0%),pos(file$(f_temp%,0%)," ",1%))) &
			if file$(f_temp%,0%)<>"[EOB]" &
    \		f_temp2=999% &
    \		f_temp2=val(left$(file$(f_temp%+1%,0%),pos(file$(f_temp%+1%,0%)," ",1%))) &
			if file$(f_temp%+1%,0%)<>"[EOB]" &
    \		if f_temp0<=f_temp1 then &
			fn_find_line%=f_temp% &
    \			fnexit &
			else &
			if f_temp0>f_temp1 and f_temp0<f_temp2 then &
				fn_find_line%=f_temp%+1% &
    \				fnexit
921	next f_temp% &
    \	fn_find_line%=0% &
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
    \	call plot("I5300") &
    \   answer$="" &
    \   feedback$="" &
    \   response$=fn_getanswer$ &
    \   on where% goto 2000,2000,9900
2000	call plot("T5300") &
    \   advice$="+A5300" &
    \   answer$="CO*PY 3 TO 1" &
    \   feedback$="Please copy line 3 to be positioned in front of line 1." &
    \   response$=fn_getanswer$ &
    \   on where% goto 2100,2100,9900
2100	call plot("T5305") &
    \   advice$="+A5305" &
    \   answer$="T*YPE W*HOLE" &
    \   feedback$="Please display the whole file." &
    \   response$=fn_getanswer$ &
    \   on where% goto 2150,2150,9900
2150	call plot("T5310") &
    \   answer$="" &
    \   feedback$="" &
    \   response$=fn_getanswer$ &
    \   on where% goto 2200,2200,9900
2200	call plot("T5315")
2205    advice$="+A5315" &
    \   answer$="" &
    \   feedback$="" &
    \   response$=fn_getanswer$ &
    \   on where% goto 3000,2210,9900
2210	if left$(response$,1%)="M" then &
		goto 2250 &
		else &
		call feedbk("Please type MORE or press RETURN.") &
    \		goto 2205
2250    call plot("T5320") &
    \   answer$="" &
    \   feedback$="" &
    \   response$=fn_getanswer$ &
    \   on where% goto 2300,2300,9900
2300  !	&
      !	Here set up the file &
      !	&
    \	file$(0%,0%)="MAIN" &
    \	file$(1%,0%)="1       Practice using the COPY command on this file." &
    \	file$(2%,0%)="2       For example:  COPY 1:3 to 5  - copies lines 1 through 3" &
    \	file$(3%,0%)="3                     in front of line 5." &
    \	file$(4%,0%)="4       After you copy lines of text display the file with the" &
    \	file$(5%,0%)="5       TYPE WHOLE command." &
    \	file$(i%,0%)="[EOB]" for i%=6% to 12% &
    \	buffer_number%=0% &
    \	buffer_ptr(0%,0%)=1% &
    \	buffer_ptr(1%,0%)=1% &
    \	buffer_ptr(2%,0%)=6% &
    \	buffer_ptr(3%,0%)=1% &
    \	buffer_ptr(4%,0%)=6% &
      !
2302	call plot("T5325") &
    \	current_row%=0% &
    \	current_column%=2% &
    \	response$="TYPE WHOLE" &
    \	goto 2320
2305	current_column%=1% &
    \	x%=print_help("*",0%,0%,0%) &
    \	current_column%=2% &
    \	call setloc("R",0%,+1%,+1%,+1%)
2310	advice$="+A5315" &
    \   answer$="[A*DVICE" &
    \   feedback$="" &
    \   response$=fn_getanswer$ &
    \   on where% goto 2315,2320,9900
2315	call plot("A5315") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2302,2302,9900
2320	goto 3000 if left$(response$,1%)="Q" &
    \	goto 2300 if left$(response$,1%)="R" &
    \	gosub 10000 &
    \	goto 2310 if error_code%<>0% &
    \	goto 2305
3000    call plot("S5300") &
    \   advice$="" &
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
10000 !	&
      !	****	Subroutine to parse line ranges and COPY them &
      !	&
    \	call parsel(response$) &
    \	error_text$="Please use the TYPE or COPY commands, or QUIT to quit." &
		if command$<>"TYPE" and command$<>"COPY" &
    \	if error_code%<>0% or (command$<>"TYPE" and command$<>"COPY") then &
		call feedbk(error_text$) &
    \		error_code%=1% &
    \		return
10010	goto 10020 if command$<>"COPY" &
      !	&
    \	extract_ptr%=0% &
    \	for i%=1% to range_list(0%,0%) &
    \		temp%=fn_find_line%(range_list(0%,i%)) &
    \		if temp%>0% and file$(temp%,0%)<>"[EOB]" then &
			extract_ptr%=extract_ptr%+1% &
    \			file$(extract_ptr%,1%)=file$(temp%,0%)
10012	next i% &
    \	return if extract_ptr%<1% &
      !	&
    \	if buffer_ptr(4%,0%)+extract_ptr%>11% then &
		call feedbk("This exercise has a maximum of eleven lines.  Type: R to restart, or Q to quit.") &
    \		error_code%=1% &
    \		return
10015 !	&
      !	Now find what line numbers are available for use &
      !	&
    \	temp%=fn_find_line%(range_list(1%,1%))-1% &
    \	temp%=0% if temp%<1% &
    \	temp1%=pos(file$(temp%,0%)," ",1%) &
    \	temp$=left$(file$(temp%,0%),temp1%) &
    \	temp$="0" if temp$="MAIN" or temp$="[EOB]" &
    \	first_line=val(temp$) &
      !	&
    \	temp$=file$(fn_find_line%(range_list(1%,1%)),0%) &
    \	second_line=range_list(1%,1%) &
    \	second_line=999 if temp$="MAIN" or temp$="[EOB]" &
    \	start=int(first_line) &
    \	increment=1 &
    \	temp=extract_ptr% &
    \	goto 10018 if first_line>=second_line
10017	if start+(temp*increment) >= second_line then &
		increment=increment/10 &
    \		start=int(first_line)+1 &
    \		start=first_line if start>=second_line &
    \		if increment>0.00001 then &
			goto 10017 &
			else &
			call feedbk("In this exercise, please do not COPY lines into that range.") &
    \			error_code%=1% &
    \			return
10018 !	&
      !	Now make a hole to put the lines back &
      !	&
    \	insert_ptr%=fn_find_line%(range_list(1%,1%)) &
    \	insert_ptr%=1% if insert_ptr%<1% &
    \	for i%=buffer_ptr(4%,0%) to insert_ptr% step -1% &
    \		file$(i%+extract_ptr%,0%)=file$(i%,0%) &
    \	next i% &
      !	&
      !	Now put the lines back &
      !	&
    \	for i%=1% to extract_ptr% &
    \		start=start+increment &
    \		temp$=num1$(start) &
    \		temp$="0"+temp$ if start<1 &
    \		file$(insert_ptr%,0%)=temp$+space$(8%-len(temp$))+right$(file$(i%,1%),9%) &
    \		insert_ptr%=insert_ptr%+1% &
    \	next i% &
      !	&
      !	Now recalculate the buffer pointers &
      !	&
    \	temp%=pos(file$(1%,0%)," ",1%) &
    \	buffer_ptr(0%,0%)=val(left$(file$(1%,0%),temp%)) &
    \	buffer_ptr(1%,0%)=range_list(1%,1%) &
    \	buffer_ptr(4%,0%)=buffer_ptr(4%,0%)+extract_ptr% &
    \	temp%=pos(file$(buffer_ptr(4%,0%)-1%,0%)," ",1%) &
    \	buffer_ptr(2%,0%)=val(left$(file$(buffer_ptr(4%,0%)-1%,0%),temp%))+1% &
    \	buffer_ptr(3%,0%)=fn_find_line%(range_list(1%,1%)) &
      !	&
    \	temp$=num1$(extract_ptr%)+" lines copied" &
    \	temp$=num1$(extract_ptr%)+" line copied" if extract_ptr%<2% &
    \	x%=print_help(temp$,0%,0%,0%) &
    \	return
10020 !	&
      !	Handle the TYPE command &
      !	&
    \	for i%=1% to range_list(0%,0%) &
    \		temp%=fn_find_line%(range_list(0%,i%)) &
    \		x%=print_help(file$(temp%,0%),0%,0%,0%) &
    \	next i% &
    \	buffer_ptr(1%,0%)=range_list(0%,1%) &
    \	buffer_ptr(1%,0%)=buffer_ptr(2%,0%) if buffer_ptr(1%,0%)>buffer_ptr(2%,0%) &
    \	buffer_ptr(3%,0%)=buffer_ptr(1%,0) &
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
