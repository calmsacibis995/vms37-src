1	SUB EDT32
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
    \		call setloc("A",line_number%,column_number%,22%,5%) &
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
1100	call plot("I3200") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2000,2000,9900
2000  !	&
      ! ****	Begin Main Instruction &
      !	&
    \	call keypad("EDT") &
    \	line_number%=0% \ column_number%=0% &
      !	&
    \	call plot("T3200") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2050,2050,9900
2050	line_number%=12% \ column_number%=38% &
    \	call plot("T3205") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2100,2100,9900
2100	call plot("T3210") &
    \	m_advice$="+A3210" &
    \	ntries%=100% &
    \	x_offset%=11% \ y_offset%=37% &
    \	x%=1% \ y%=1% &
    \	target_x%=1% \ target_y%=7% &
    \	message$='Please move the cursor to the "s" in "Sir".' &
    \	alternate_answer$=chr$(127%) &
    \	f$(1%)="Dear  Sir:" &
    \	f$(2%)="" &
    \	f$(3%)="Please return these" &
    \	f$(4%)="documents by the 10th," &
    \	f$(5%)="with your snagture." &
    \	f$(6%)="" &
    \	f$(7%)="     Sincerely," &
    \	f$(8%)="" &
    \	last_line%=8% &
    \	gosub 10000 &
    \	on where% goto 2200,2150,9900
2150	line_number%=0% &
    \	call setloc("A",12%,44%,0%,0%) &
    \	answer$=chr$(127%) &
    \	feedback$="Press the keyboard DELETE key." &
    \	option%=SINGLE_CHARACTER%			! single character input &
    \	advice$="+A3210" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2200,2200,9900
2200    line_number%=12% \ column_number%=43% &
    \	y%=y%-1% &
    \	f$(1%)="Dear Sir:" &
    \	call plot("T3215") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2250,2250,9900
2250	call plot("T3220") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2300,2300,9900
2300	call plot("T3225") &
    \	m_advice$="+A3225" &
    \	target_x%=5% \ target_y%=15% &
    \	message$='Please move the cursor to the "t" in "snagture".' &
    \	alternate_answer$=chr$(10%) &
    \	gosub 10000 &
    \	on where% goto 2400,2350,9900
2350	call plot("T3230") &
    \ 	advice$="+A3230" &
    \	call setloc("A",line_number%,column_number%,0%,0%) &
    \	line_number%=0% &
    \	answer$=chr$(10%) &
    \	feedback$="<DEL BW> is the LINEFEED key." &
    \	option%=SINGLE_CHARACTER% &
    \	response$=fn_getanswer$ &
    \	on where% goto 2400,2400,9900
2400	line_number%=16% \ column_number%=48% &
    \	call plot("T3235") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2450,2450,9900
2450	call plot("T3240") &
    \	advice$="+A3240" &
    \	answer$="SIGNA" &
    \	gosub 10100 &
    \	on where% goto 2500,2500,9900
2500	line_number%=16% \ column_number%=53% &
    \	f$(5%)="with your signature." &
    \	y%=y%+5% &
    \	call plot("T3245") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2550,2550,9900
2550	call plot("T3250") &
    \	m_advice$="+A3250" &
    \	target_x%=8% \ target_y%=1% &
    \	message$="Please move the cursor to the bottom of the file." &
    \	alternate_answer$=chr$(21%) &
    \	gosub 10000 &
    \	on where% goto 2650,2600,9900
2600	call setloc("A",19%,38%,0%,0%) &
    \	line_number%=0% &
    \	answer$=chr$(21%) &
    \	feedback$="<DEL B> is CTRL/U." &
    \	option%=SINGLE_CHARACTER% &
    \	advice$="+A3250" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2650,2650,9900
2650    line_number%=18% \ column_number%=38% &
    \	call plot("T3255") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2700,2700,9900
2700	line_number%=18% \ column_number%=38% &
    \	call plot("T3260") &
    \	advice$="+A3260" &
    \	answer$="<UND L>" &
    \	feedback$="<UND L> is <GOLD> then PF4." &
    \	feedback$="<UND L> is <GOLD> then the right blank key." if terminal$="V52" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2750,2750,9900
2750    line_number%=19% \ column_number%=38% &
    \	call plot("T3265") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2800,2800,9900
2800	call plot("T3270") &
    \	m_advice$="+A3270" &
    \	target_x%=5% \ target_y%=1% &
    \	message$='Please move the cursor to the beginning of the word "with".' &
    \	alternate_answer$="<DEL W>" &
    \	gosub 10000 &
    \	on where% goto 2950,2900,9900
2900	answer$="<DEL W>" &
    \	feedback$="<DEL W> is the minus key on the keypad." &
    \	feedback$="<DEL W> is keypad key #9." if terminal$="V52" &
    \	advice$="+A3270" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2950,2950,9900
2950    call plot("T3275") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3000,3000,9900
3000	call plot("T3280") &
    \	m_advice$="+A3280" &
    \	target_x%=3% \ target_y%=1% &
    \	message$='Please move the cursor to before the word "please".' &
    \	alternate_answer$="<UND C>" &
    \	gosub 10000 &
    \	on where% goto 3150,3100,9900
3100	line_number%=14% &
    \	answer$="<UND C>" &
    \	feedback$="<UND C> is <GOLD>, then the comma key on the keypad." &
    \	feedback$="<UND C> is <GOLD>, then keypad key #6." if terminal$="V52" &
    \	advice$="+A3280" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3150,3150,9900
3150	line_number%=14% \ column_number%=39% &
    \	call plot("T3285") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3200,3200,9900
3200    line_number%=0% \ column_number%=0% &
    \	call plot("S3200") &
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
10100 !	&
      !	Subroutine to handle moving text over during input &
      !	&
    \	line_number%=0% &
    \	response$="" &
    \	line$="ture." &
    \	call setloc("A",16%,48%,22%,5%)
10110	option%=SINGLE_CHARACTER% &
    \	call getans("","",limit%,r$,"",1%,option%) &
    \	if option%>2% then &
		sys_where%=option% &
    \		where%=option% &
    \		where%=3% if where%>2% &
    \		return
10120	if r$="" then &
		where%=1% &
    \		print edit$(loc1$,128%)+line$+"  "; &
    \		return if response$="SIGNA" &
    \		call feedbk("Please type:  SIGNA") &
    \		goto 10100
10130	if r$=chr$(21%) then &
		response$="" &
    \		call setloc("A",16%,48%,0%,0%) &
    \		print edit$(loc1$,128%)+line$+space$(20%) &
    \		goto 10110
10140	if r$=chr$(127%) then &
		if len(response$)<1% then &
			call setloc("A",16%,48%,0%,0%) &
    \			goto 10110 &
			else &
			response$=left$(response$,len(response$)-1%) &
    \			call setloc("R",0%,-1%,0%,0%) &
    \			print edit$(loc1$,128%)+line$+"  " &
    \			goto 10110
10150	if ascii(r$)>31% and ascii(r$)<127% then &
		call setloc("R",0%,1%,0%,0%) &
    \		print edit$(loc1$,128%)+line$ &
    \		response$=response$+r$ &
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
