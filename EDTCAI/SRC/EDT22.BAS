1	SUB EDT22
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
    \	call keypad("EDT") &
    \	line_number%=0% \ column_number%=0% &
      !	&
    \	call plot("I2200") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2000,2000,9900
2000	call plot("T2200")
2005	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2100,2010,9900
2010	if left$(response$,1%)="M" then &
		goto 2050 &
		else &
		call feedbk("Please type MORE, or press RETURN") &
    \		goto 2005
2050	call plot("T2205")
2055	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2100,2060,9900
2060	if left$(response$,1%)="M" then &
		goto 2075 &
		else &
		call feedbk("Please type MORE, or press RETURN") &
    \		goto 2055
2075	call plot("T2206") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2100,2100,9900
2100	call plot("T2210")
2105	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2200,2110,9900
2110	if left$(response$,1%)="M" then &
		goto 2150 &
		else &
		call feedbk("Please type MORE, or press RETURN") &
    \		goto 2105
2150	call plot("T2211") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2200,2200,9900
2200	call plot("T2220")
2205	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2210,2206,9900
2206	if left$(response$,1%)="M" then &
		goto 2207 &
		else &
		call feedbk("Please type MORE, or press RETURN") &
    \		goto 2005
2207	call plot("M2220") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2210,2210,9900
2210	call plot("T2221") &
    \	advice$="+A2221" &
    \	answer$="7" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2300,2211,9900
2211	if response$="SEVEN" then &
		goto 2300
2215	call plot("M2221") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2221,2221,9900
2221	call plot("M2222") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2231,2231,9900
2231	call plot("M2223") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2241,2241,9900
2241	call plot("M2224") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2251,2251,9900
2251	call plot("M2225") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2261,2261,9900
2261	call plot("M2226") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2271,2271,9900
2271	call plot("M2227") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2281,2281,9900
2281	call plot("M2228") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2291,2291,9900
2291	call plot("M2229") &
    \	answer$="14" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2300,2292,9900
2292	if response$="FOURTEEN" then &
		goto 2300 &
		else &
		call setloc("A",0%,0%,22%,5%) &
    \		call feedbk("Sorry, that's not right.  Press RETURN to review.") &
    \		call plot("ZZ101") &
    \		answer$="" &
    \		feedback$="" &
    \		response$=fn_getanswer$ &
    \		on where% goto 2210,2210,9900
2300	call plot("T2230")
2305	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2332,2310,9900
2310	if left$(response$,1%)="M" then &
		goto 2331 &
		else &
		call feedbk("Please type MORE, or press RETURN") &
    \		goto 2305
2331	call plot("T2231") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2332,2332,9900
2332	call plot("T2232") &
    \	answer$="4" &
    \	advice$="+A2232" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2400,2340,9900
2340	if response$="FOUR" then &
		goto 2400
2350	call plot("T2233") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2400,2400,9900
2400	line_number%=14% \ column_number%=37% &
    \	call plot("T2240") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2450,2450,9900
2450	line_number%=0% &
    \	call plot("T2245") &
    \	advice$="+A2245" &
    \	answer$="<CHAR>" &
    \	answer$="<RIGHT>" if terminal$="V52" &
    \	feedback$="<CHAR> is the keypad key #3" &
    \	feedback$="<RIGHT> is the middle key on the right of the keypad." if terminal$="V52" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2460,2460,9900
2460	call plot("T2246") &
    \	advice$="+A2246" &
    \	answer$="<WORD>" &
    \	feedback$="<WORD> is the keypad key #1" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2470,2470,9900
2470	call plot("T2247") &
    \	advice$="+A2247" &
    \	answer$="<LINE>" &
    \	feedback$="<LINE> is the keypad key #0" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2480,2480,9900
2480	call plot("T2248") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2500,2500,9900
2500  !	&
      !	First set up the file &
      !	&
    \	f$(1%)="This is text from your" &
    \	f$(2%)="input file, which will" &
    \	f$(3%)="be edited in keypad mode." &
    \	f$(4%)="" &
    \	f$(5%)="The flashing cursor can" &
    \	f$(6%)="be positioned anywhere " &
    \	f$(7%)="within this text buffer." &
    \	f$(8%)="" &
    \	last_line%=8% &
    \	x_offset%=9% \ y_offset%=32% &
    \	ntries%=32767% &
      !	&
    \	call plot("T2250") &
    \	x%=1% \ y%=1% &
    \	target_x%=5% \ target_y%=16% &
    \	m_advice$="+A2250" &
    \	message$='Please move to the first "r" in "cursor".' &
    \	gosub 10000 &
    \	on where% goto 2510,2510,9900
2510	call plot("T2251") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2550,2550,9900
2550	call plot("T2255") &
    \	target_x%=7% \ target_y%=21% &
    \	m_advice$="+A2255" &
    \	message$='Please move to the second "f" in "buffer".' &
    \	gosub 10000 &
    \	on where% goto 2600,2600,9900
2600	line_number%=0% &
    \	call plot("T2260") &
    \	advice$="+A2260" &
    \	answer$=chr$(8%) &
    \	feedback$="Please press the BACKSPACE key." &
    \	option%=SINGLE_CHARACTER% &
    \	response$=fn_getanswer$ &
    \	on where% goto 2610,2610,9900
2610	call plot("T2261") &
    \	advice$="+A2261" &
    \	answer$="<EOL>" &
    \	feedback$="<EOL> is keypad key #2" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2620,2620,9900
2620	call plot("T2262") &
    \	advice$="+A2262" &
    \	answer$="<BACKUP>" &
    \	feedback$="<BACKUP> is keypad key #5" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2630,2630,9900
2630	call plot("T2263") &
    \	advice$="+A2260" &
    \	answer$="<ADVANCE>" &
    \	feedback$="<ADVANCE> is keypad key #4" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2640,2640,9900
2640	call plot("T2264") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3000,3000,9900
3000	call plot("T2270") &
    \	advice$="+A2270" &
    \	answer$="ED*IT/ED*T EXERCISE.DAT" &
    \	feedback$="Please edit the file:  EXERCISE.DAT" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3050,3050,9900
3050	call plot("T2271") &
    \	advice$="+A2271" &
    \	answer$="C*HANGE" &
    \	feedback$="Please enter change mode." &
    \	response$=fn_getanswer$ &
    \	on where% goto 3100,3100,9900
3100  !	&
      !	First set up the file &
      !	&
    \	f$(1%)="This is text from your input file, which" &
    \	f$(2%)="will be edited in keypad mode." &
    \	f$(3%)="" &
    \	f$(4%)="The flashing cursor can be positioned" &
    \	f$(5%)="anywhere within this text buffer." &
    \	f$(6%)="" &
    \	last_line%=6% &
    \	call plot("T2272") &
    \	x_offset%=12% \ y_offset%=26% &
    \	x%=1% \ y%=1% &
    \	target_x%=0% \ target_y%=0% &
    \	m_advice$="+A2272" &
    \	alternate_answer$="" &
    \	gosub 10000 &
    \	on where% goto 3150,3150,9900
3150	call plot("T2280") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 3200,3200,9900
3200	line_number%=0% \ column_number%=0% &
    \	call plot("S2200") &
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
10095	call feedbk("Please press one of the keypad movement keys, or press RETURN") &
    \	goto 10005
10098	if target_x%<>0% and target_y%<>0% then &
		if x%<>target_x% or y%<>target_y% then &
			call feedbk(message$) &
    \			goto 10005
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
