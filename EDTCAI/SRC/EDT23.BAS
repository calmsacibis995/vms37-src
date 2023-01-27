1	sub edt23
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
      !	****	Begin Introduction &
      !	&
    \	call keypad("EDT") &
      !	&
    \	call plot("I2300") &
    \   advice$="+ZA101" &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2000,2000,9900
2000  !	&
      !	****	Begin Main Instruction &
      !	&
    \	line_number%=13% \ column_number%=36% &
    \	x_offset%=13% \ y_offset%=35% &
      !	&
    \	call plot("T2300") &
    \   m_advice$="+A2300" &
    \	x%=1% \ y%=1% &
    \	target_x%=3% \ target_y%=1% &
    \	message$="Please move the cursor to the beginning of the third line." &
    \	alternate_answer$="" &
    \	f$(1%)="" &
    \	f$(2%)="" &
    \	f$(3%)=" is typing." &
    \	f$(4%)="" &
    \	f$(5%)="******************************" &
    \	f$(6%)="" &
    \	last_line%=6% &
    \	gosub 10000 &
    \	on where% goto 2100,2100,9900
2100	call plot("T2305") &
    \   advice$="+A2305" &
    \	gosub 10100 &
    \	on where% goto 2150,2150,9900
2150	line_number%=16% \ column_number%=column_number%+len(response$) &
    \	y%=y%+len(response$) &
    \	f$(3%)=response$+f$(3%) &
      !	&
    \	call plot("T2310") &
    \   advice$="+ZA101" &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2200,2200,9900
2200	line_number%=0% \ column_number%=0% &
    \	call plot("T2335") &
    \   advice$="+A2335" &
    \	answer$="<DEL C>" &
    \	feedback$="The <DEL C> key is the keypad comma key." &
    \	feedback$="The <DEL C> key is keypad key #6." if terminal$="V52" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2420,2420,9900
2420	call plot("T2340") &
    \   advice$="+ZA101" &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2450,2450,9900
2450	line_number%=10% \ column_number%=32% &
    \	x_offset%=10% \ y_offset%=31% &
      !	&
    \	call plot("T2345") &
    \   m_advice$="+A2345" &
    \	message$='Please move the cursor to the "8" in "87".' &
    \	x%=1% \ y%=1% &
    \	target_x%=6% \ target_y%=11% &
    \	alternate_answer$="<DEL C>" &
    \	f$(1%)="Student:  Jane Doe" &
    \	f$(2%)="Grade:    A" &
    \	f$(3%)="" &
    \	f$(4%)="QUIZ      SCORE" &
    \	f$(5%)="" &
    \	f$(6%)="#1        87%" &
    \	f$(7%)="#2        91%" &
    \	f$(8%)="Final     93%" &
    \	f$(9%)="" &
    \	f$(10%)="" &
    \	last_line%=10% &
    \	gosub 10000 &
    \	on where% goto 2600,2550,9900
2550	line_number%=16% \ column_number%=42% &
    \	call plot("T2350") &
    \   advice$="+A2335" &
    \	answer$="<DEL C>" &
    \	feedback$="<DEL C> is the keypad comma key." &
    \	feedback$="<DEL C> is keypad key #6." if terminal$="V52" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2600,2600,9900
2600	line_number%=16% \ column_number%=42% &
    \	f$(6%)="#1        7%" &
    \	call plot("T2355") &
    \   advice$="+ZA101" &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2650,2650,9900
2650	call plot("T2360") &
    \   m_advice$="+A2320" &
    \	target_x%=1% \ target_y%=1% &
    \	message$="Please move to the top of the file." &
    \	alternate_answer$="<DEL W>" &
    \	gosub 10000 &
    \	on where% goto 2750,2700,9900
2700	line_number%=11% \ column_number%=32% &
    \	answer$="<DEL W>" &
    \	feedback$="<DEL W> is the minus key on the keypad." &
    \	feedback$="<DEL W> is keypad key #9." if terminal$="V52" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2750,2750,9900
2750	line_number%=11% \ column_number%=32% &
    \	f$(1%)="Jane Doe" &
    \	call plot("T2365") &
    \   advice$="+ZA101" &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2800,2800,9900
2800	call plot("T2370") &
    \   m_advice$="+A2370" &
    \	x%=1% \ y%=1% &
    \	target_x%=1% \ target_y%=3% &
    \	message$='Please move to the "n" in "Jane Doe".' &
    \	alternate_answer$="<DEL W>" &
    \	gosub 10000 &
    \	on where% goto 2950,2900,9900
2900	line_number%=11% \ column_number%=34% &
    \	answer$="<DEL W>" &
    \	feedback$="<DEL W> is the keypad minus key." &
    \	feedback$="<DEL W> is keypad key #9." if terminal$="V52" &
    \	m_advice$="+A2371" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2950,2950,9900
2950	line_number%=11% \ column_number%=34% &
    \	call plot("T2375") &
    \   advice$="+A2375" &
    \	answer$="<DEL L>" &
    \	feedback$="<DEL L> is the PF4 key on the keypad." &
    \	feedback$="<DEL L> is the right blank key on the keypad." if terminal$="V52" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3000,3000,9900
3000	call plot("T2380") &
    \   advice$="+ZA101" &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3200,3200,9900
3200    line_number%=0% &
    \	call plot("S2300") &
    \   advice$="+ZA101" &
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
10095	goto 10098 if ascii(response$)>31% and ascii(response$)<127% &
    \	call feedbk("Please press one of the keypad movement keys, or press RETURN") &
    \	goto 10005
10098	if x%<>target_x% or y%<>target_y% then &
		call feedbk(message$) &
    \		goto 10005
10099	line_number%=x%+x_offset% &
    \	column_number%=y%+y_offset% &
    \	return
10100 !	&
      !	Subroutine to handle moving text over during input &
      !	&
    \	line_number%=0% &
    \	response$="" &
    \	line$=" is typing." &
    \	call setloc("A",16%,36%,22%,5%)
10110	option%=SINGLE_CHARACTER% &
    \	call getans("","",-1%,r$,"",1%,option%) &
    \	if option%>2% then &
		sys_where%=option% &
    \		where%=option% &
    \		where%=3% if where%>2% &
    \		return
10120	if r$=="" then &
		where%=1% &
    \		print edit$(loc1$,128%)+line$+"   "; &
    \		return if len(response$)>0% &
    \		call feedbk("Please enter your name.") &
    \		goto 10100
10130	if r$=chr$(21%) then &
		response$="" &
    \		call setloc("A",16%,36%,0%,0%) &
    \		print edit$(loc1$,128%)+line$+space$(21%) &
    \		goto 10110
10140	if r$=chr$(127%) then &
		if len(response$)<1% then &
			call setloc("A",16%,36%,0%,0%) &
    \			response$="" &
    \			goto 10110 &
			else &
			response$=left$(response$,len(response$)-1%) &
    \			call setloc("R",0%,-1%,0%,0%) &
    \			print edit$(loc1$,128%)+line$+"  " &
    \			goto 10110
10150	if ascii(r$)>31% and ascii(r$)<127% then &
		call setloc("R",0%,1%,0%,0%) if len(response$)<=20% &
    \		call feedbk("In this exercise, please do not enter more than 20 characters.") &
			if len(response$)>20% &
    \		print edit$(loc1$,128%)+line$ &
    \		response$=response$+seg$(r$,1%,1%) if len(response$)<=20% &
    \		goto 10110
10199	r$="" &
    \	goto 10120
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
