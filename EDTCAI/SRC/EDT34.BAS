1	SUB EDT34
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
    \	dim f$(20%) &
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
		fill%(5%), &
		response.length%, &
		feedbk.length%, &
		fill$=1%, &
		terminal$=3%, &
		loc1$=10%, &
		loc2$=10%, &
		review$=1%
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
    \	advice$="ZA101" if advice$="" &
    \	advice$="-"+advice$ if pos("+-",seg$(advice$,1%,1%),1%)<1% &
    \	where%=option% &
    \	if line_number%>0% and column_number%>0% then &
		call plot("-P2100") &
    \		call setloc("A",line_number%,column_number%,24%,5%) &
    \		where%=DO_FORM% &
      !
911	call getans(answer$,			! Correct answer. &
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
    \	ntries%=32767% &
    \	limit%=39% &
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
    \	call keypad("EDT") &
    \	line_number%=0% \ column_number%=0% &
      !	&
    \	call plot("I3400") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2000,2000,9900
2000	line_number%=0% \ column_number%=0% &
    \	call plot("T3400") &
    \	call plot("B3400") &
    \	advice$="+A3400" &
    \	answer$="<APPEND>" &
    \	feedback$="<APPEND> is keypad key #9." &
    \	feedback$="<APPEND> is <GOLD>, then the <LEFT> arrow key." if terminal$="V52" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2500,2500,9900
2500	call plot("T3405") &
    \	call plot("B3405") &
    \	advice$="+A3405" &
    \	answer$="<REPLACE>" &
    \	feedback$="<REPLACE> is <GOLD>, then keypad key #9." &
    \	feedback$="<REPLACE> is <GOLD>, then the <UP> arrow key." if terminal$="V52" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2550,2550,9900
2550	call plot("T3410") &
    \	call plot("B3410") &
    \	advice$="+A3410" &
    \	answer$="<CHNGCASE>" &
    \	feedback$="<CHNGCASE> is <GOLD>, the keypad key #1." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2600,2600,9900
2600	line_number%=13% \ column_number%=27% &
    \	call plot("T3415") &
    \	call plot("B3415") &
    \	advice$="+A3415" &
    \	answer$="<SELECT>" &
    \	feedback$="<SELECT> is the keypad period key." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2650,2650,9900
2650	call plot("T3420") &
    \	m_advice$="+A3420" &
    \	x%=5% \ y%=1% &
    \	x_offset%=8% \ y_offset%=26% &
    \	target_x%=7% \ target_y%=23% &
    \	message$="Move the cursor past the period in the second sentence." &
    \	alternate_answer$="<APPEND>" &
    \	f$(1%)="  The cost of computer" &
    \	f$(2%)="hardware has decreased" &
    \	f$(3%)="exponentially for the" &
    \	f$(4%)="past ten years.  " &
    \	f$(5%)="We must begin to use" &
    \	f$(6%)="this valuable resource" &
    \	f$(7%)="without further delay." &
    \	f$(8%)="Yet," &
    \	f$(9%)="software development" &
    \	f$(10%)="has not kept pace with" &
    \	f$(11%)="this startling trend." &
    \	last_line%=12% &
    \	gosub 10000 &
    \	on where% goto 2750,2700,9900
2700	line_number%=15% \ column_number%=49% &
    \	call plot("T3425") &
    \	call plot("B3425") &
    \	advice$="+A3425" &
    \	answer$="<APPEND>" &
    \	feedback$="<APPEND> is keypad key # 9" &
    \	feedback$="<APPEND> is <GOLD>, then the <LEFT> arrow key." if terminal$="V52" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2750,2750,9900
2750	line_number%=13% \ column_number%=27% &
    \	call plot("T3430") &
    \	call plot("B3430") &
    \	advice$="+A3430" &
    \	answer$="<SELECT>" &
    \	feedback$="<SELECT> is the keypad period key." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2800,2800,9900
2800	call plot("T3435") &
    \	m_advice$="+A3435" &
    \	x%=5% \ y%=1% &
    \	target_x%=9% \ target_y%=1% &
    \	message$="Move the cursor to the end of the buffer." &
    \	alternate_answer$="<REPLACE>" &
    \	f$(1%)="  The cost of computer" &
    \	f$(2%)="hardware has decreased" &
    \	f$(3%)="exponentially for the" &
    \	f$(4%)="past ten years.  " &
    \	f$(5%)="Yet," &
    \	f$(6%)="software development" &
    \	f$(7%)="has not kept pace with" &
    \	f$(8%)="this startling trend." &
    \	f$(9%)="" &
    \	last_line%=9% &
    \	gosub 10000 &
    \	on where% goto 2900,2850,9900
2850	line_number%=17% \ column_number%=27% &
    \	call plot("T3440") &
    \	call plot("B3440") &
    \	advice$="+A3440" &
    \	answer$="<REPLACE>" &
    \	feedback$="<REPLACE> is <GOLD>, then keypad key #9." &
    \	feedback$="<REPLACE> is <GOLD>, then the <UP> arrow key." if terminal$="V52" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2900,2900,9900
2900	line_number%=13% \ column_number%=27% &
    \	call plot("T3445") &
    \	call plot("B3445") &
    \	advice$="+A3445" &
    \	answer$="<DEL L>" &
    \	feedback$="<DEL L> is the keypad PF4 key." &
    \	feedback$="<DEL L> is the right blank key." if terminal$="V52" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2950,2950,9900
2950	call plot("T3450") &
    \	call plot("B3450") &
    \	advice$="+A3450" &
    \	answer$="<CHNGCASE>" &
    \	feedback$="<CHNGCASE> is <GOLD>, then keypad key #1." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2970,2970,9900
2970	line_number%=0% &
    \	call plot("T3455") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 4000,4000,9900
4000	call plot("S3400") &
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
10000 !	&
      !	Section to have the student move the cursor around a sample file &
      !	to practice with the <ADVANCE>, <BACKUP>, <LINE>, <WORD>, <CHAR> &
      !	and arrow keys.  It is assumed that the text will be placed on the &
      !	screen by the form to be plotted. &
      !	&
    \	far_y%=y% &
    \	direction%=+1%			! start off in <ADVANCE> mode &
    \	line_number%=0% &
    \	column_number%=0%
10005	answer$="" &
    \	feedback$="" &
    \	advice$=m_advice$ &
    \	call setloc("A",x%+x_offset%,y%+y_offset%,22%,5%) &
    \	response.length%=0% &
    \	option%=SINGLE_CHARACTER%			! single character input &
    \	temp$=review$ &
    \	review$="N" &
    \	response$=fn_getanswer$ &
    \	review$=temp$ &
    \	goto 9900 if where%>2% &
    \	if response$="" then &
		where%=2% &
    \		goto 10098 &
		else &
		if response$=chr$(10%) and review$="Y" then &
			x%=target_x% &
    \			y%=target_y% &
    \			response$=alternate_answer$ &
    \			where%=1% &
    \			goto 10098 &
			else &
			if response$=alternate_answer$ then &
				where%=1% &
    \				goto 10098
10010	goto 10015 if response$<>"<ADVANCE>" &
    \	direction%=+1% &
    \	goto 10005
10015	goto 10020 if response$<>"<BACKUP>" &
    \	direction%=-1% &
    \	goto 10005
10020	goto 10025 if response$<>"<TOP>" &
    \	x%=1% &
    \	y%=1% &
    \	goto 10005
10025	goto 10030 if response$<>"<BOTTOM>" &
    \	x%=last_line% &
    \	y%=1% &
    \	goto 10005
10030	goto 10033 if response$<>"<EOL>" &
    \	x%=x%+direction% if direction%<0% or y%=len(f$(x%))+1% &
    \	x%=1% if x%<1% &
    \	x%=last_line% if x%>last_line% &
    \	y%=len(f$(x%))+1% &
    \	far_y%=y% &
    \	goto 10005
10033	goto 10035 if response$<>chr$(8%) &
    \	x%=x%-1% if y%=1% and x%>1% &
    \	y%=1% &
    \	far_y%=y% &
    \	goto 10005
10035	goto 10040 if response$<>"<LINE>" &
    \	x%=x%+direction% &
    \	y%=1% &
    \	far_y%=y% &
    \	x%=1% if x%<1% &
    \	x%=last_line% if x%>last_line% &
    \	goto 10005
10040	goto 10050 if response$<>"<WORD>" &
    \	goto 10045 if direction%<0% &
    \	if y%>=len(f$(x%))+1% then &
		x%=x%+1% &
    \		x%=last_line% if x%>last_line% &
    \		y%=1% &
    \		far_y%=y% &
    \		goto 10005
10041	for y%=y% to len(f$(x%)) &
    \		goto 10042 if seg$(f$(x%),y%,y%)=" " &
    \	next y% &
    \	y%=len(f$(x%))+1% &
    \	far_y%=y% &
    \	goto 10005
10042	for y%=y% to len(f$(x%)) &
    \		goto 10043 if seg$(f$(x%),y%,y%)<>" " &
    \	next y% &
    \	y%=len(f$(x%))+1%
10043	far_y%=y% &
    \	goto 10005
10045	if y%<=1% then &
		x%=x%-1% &
    \		if x%<1% then &
			x%=1% &
    \			y%=1% &
    \			far_y%=y% &
    \			goto 10005 &
			else &
			y%=len(f$(x%))+1% &
    \			far_y%=y% &
    \			goto 10005
10046	y%=y%-1% &
    \	for y%=y% to 1% step -1% &
    \		goto 10047 if seg$(f$(x%),y%,y%)<>" " &
    \	next y% &
    \	y%=1% &
    \	far_y%=y% &
    \	goto 10005
10047	for y%=y% to 1% step -1% &
    \		goto 10048 if seg$(f$(x%),y%,y%)=" " &
    \	next y% &
    \	y%=0%
10048	y%=y%+1% &
    \	far_y%=y% &
    \	goto 10005
10050	goto 10060 if response$<>"<CHAR>" &
    \	if direction%>0% then response$="<RIGHT>" &
			 else response$="<LEFT>"
10060	goto 10070 if response$<>"<UP>" &
    \	x%=x%-1% &
    \	x%=1% if x%<1% &
    \	goto 10075
10070	goto 10080 if response$<>"<DOWN>" &
    \	x%=x%+1% &
    \	x%=last_line% if x%>last_line%
10075	y%=far_y% if y%<=far_y% &
    \	y%=len(f$(x%))+1% if y%>len(f$(x%)) &
    \	goto 10005
10080	goto 10090 if response$<>"<LEFT>" &
    \	y%=y%-1% &
    \	far_y%=y% &
    \	goto 10005 if y%>0% &
    \	x%=x%-1% &
    \	if x%>0% then &
		y%=len(f$(x%))+1% &
    \		far_y%=y% &
    \		goto 10005 &
		else &
		x%=1% &
    \		y%=1% &
    \		far_y%=y% &
    \		goto 10005
10090	goto 10095 if response$<>"<RIGHT>" &
    \	y%=y%+1% &
    \	far_y%=y% &
    \	goto 10005 if y%<=len(f$(x%))+1% &
    \	x%=x%+1% &
    \	x%=last_line% if x%>last_line% &
    \	y%=1% &
    \	far_y%=y% &
    \	goto 10005
10095	call feedbk("Please press one of the keypad movement keys, or press RETURN.") &
    \	goto 10005
10098	if x%<>target_x% or y%<>target_y% then &
		call feedbk(message$) &
    \		goto 10005
10099	line_number%=x%+x_offset% &
    \	column_number%=y%+y_offset% &
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
