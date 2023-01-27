1	sub edt45
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
    \	dim help_key$(5%) &
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
    \	common (hlpcom)				! common for PRINT_HELP &
		library_index%,			! pointer to library index &
		current_row%,			! current line number to write to &
		current_column%,		! current column number &
		header_flag% &
      !	&
    \	external integer function lbr$ini_control &
    \	external integer function lbr$open &
    \	external integer function lbr$close &
    \	external integer function lbr$get_help &
    \	external integer print_help &
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
920	def fn_scroll_line% &
    \	if current_row%<20% then &
		current_row%=current_row%+1% &
		else &
		call plot("U4500") &
    \		current_row%=20%
921	call setloc("A",current_row%,current_column%,current_row%,current_column%) &
    \	fn_scroll_line%=0% &
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
    \	call plot("I4500") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2000,2000,9900
2000	call plot("T4500") &
    \	call plot("B4500") &
    \	advice$="+A4500" &
    \	answer$="H*ELP" &
    \	feedback$="Please use the HELP command." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2050,2050,9900
2050	call plot("T4505") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2100,2100,9900
2100	call plot("T4510") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2150,2150,9900
2150	call plot("T4515") &
    \	call plot("B4515") &
    \	advice$="+A4515" &
    \	answer$="H*ELP SH*OW" &
    \	feedback$="Find out about the SHOW command." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2200,2200,9900
2200	call plot("T4520") &
    \	call plot("B4520") &
    \	advice$="+A4520" &
    \	answer$="H*ELP SH*OW TE*RMINAL" &
    \	feedback$="Find out how to SHOW the TERMINAL type you are using." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2250,2250,9900
2250	call plot("T4525") &
    \	call plot("B4525") &
    \	advice$="+A4525" &
    \	answer$="SH*OW TE*RMINAL" &
    \	feedback$="Use the command that shows your terminal type." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2300,2300,9900
2300	call plot("T4530")
2305	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 4000,2310,9900
2310	if left$(response$,1%)="M" then &
		goto 3000 &
		else &
		call feedbk("Please type MORE or press RETURN.") &
    \		goto 2305
3000  !	&
      !	****	Practice section with the EDT Help text &
      !	&
    \	i%=1% &
    \	x%=lbr$ini_control(library_index%,i%) &
    \	temp$="SYS$HELP:EDTHELP.HLB" &
    \	x%=lbr$open(library_index%,temp$) &
      !	&
    \	call plot("T4535") &
    \	current_row%=0% &
    \	current_column%=2%
3100	current_row%=current_row%+1% &
    \	call setloc("A",current_row%,1%,current_row%,1%) &
    \	call feedbk("*") &
    \	call setloc("A",current_row%,current_column%,current_row%+1%,current_column%)
3105	advice$="+A4535" &
    \	answer$="Q*UIT" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3900,3110,9900
3110	goto 3100 if response$="" &
    \	pointer%=0% &
    \	help_key$(i%)="" for i%=1% to 5% &
    \	temp%=pos(response$," ",1%) &
    \	temp%=len(response$)+1% if temp%<1% &
    \	temp$=left$(response$,temp%-1%) &
    \	cur_char%=temp% &
    \	if temp$<>"H" and temp$<>"HE" and temp$<>"HEL" and temp$<>"HELP" then &
		call feedbk("Please use the HELP command, or QUIT to leave.") &
    \		goto 3105
3120	temp1%=pos(response$," ",cur_char%+1%) &
    \	temp1%=len(response$)+1% if temp1%<1% &
    \	pointer%=pointer%+1% &
    \	pointer%=5% if pointer%>5% &
    \	help_key$(pointer%)=seg$(response$,cur_char%+1%,temp1%-1%) &
    \	cur_char%=temp1% &
    \	if cur_char%<=len(response$) then 3120
3130	x%=fn_scroll_line% &
    \	x%=lbr$get_help(library_index%,,print_help by ref,,help_key$(1%),help_key$(2%),help_key$(3%),help_key$(4%),help_key$(5%)) &
    \	goto 3100
3900	x%=lbr$close(library_index%)
4000	call plot("S4500") &
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
