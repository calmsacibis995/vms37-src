1	SUB EDT21
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
1100	call keypad("EDT") &
      !	&
    \	call plot("ZK900") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 1150,1150,9900
1150	call plot("I2100") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2000,2000,9900
2000  !	&
      !	****	Begin Main Instruction &
      !	&
    \	call plot("T2100") &
    \	advice$="+A2100" &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2050,2050,9900
2050	call plot("T2105") &
    \	advice$="+ZA101" &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2100,2100,9900
2100	call plot("T2110") &
    \	call plot("B2110") &
    \	advice$="+A2110" &
    \	answer$="ED*IT/ED*T JONES.MEM" &
    \	feedback$="Please edit the file:  JONES.MEM" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2150,2150,9900
2150	call plot("T2115") &
    \	call plot("B2115") &
    \	advice$="+A2115" &
    \	answer$="C*HANGE" &
    \	feedback$="Please enter the CHANGE mode of EDT." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2200,2200,9900
2200	call plot("T2120") &
    \	call plot("B2120") &
    \	advice$="+A2120" &
    \	x%=1% \ y%=1% &
    \	x_offset%=12% \ y_offset%=26% &
    \	target_x%=5% \ target_y%=10% &
    \	f$(1%)="To:                      J.R. Jones" &
    \	f$(2%)="From:                    T.M. Smith" &
    \	f$(3%)="" &
    \	f$(4%)="Please meet me for lunch next Thursday," &
    \	f$(5%)="at 11:45." &
    \	f$(6%)="                       - Terry" &
    \	f$(7%)="" &
    \	last_line%=7% &
    \	message$="Please move the cursor past the period in 11:45." &
    \	alternate_answer$="" &
    \	gosub 10000 &
    \	on where% goto 2250,2250,9900
2250	call plot("T2125") &
    \	call plot("B2125") &
    \	for i%=1% to 5% &
    \		advice$="+A2125" &
    \		answer$=chr$(127%) &
    \		feedback$="Please press the DELETE key "+num1$(6%-i%) &
    \		feedback$=feedback$+" times." if i%=1% &
    \		feedback$=feedback$+" more times." if i%>1% and i%<5% &
    \		feedback$=feedback$+" more time." if i%=5% &
    \		option%=SINGLE_CHARACTER% &
    \		response$=fn_getanswer$ &
    \		on where% goto 2260,2260,9900
2260		call setloc("A",17%,36%-i%,17%,36%-i%) &
    \		call feedbk("     "+chr$(8%)) &
    \		call setloc("A",0%,0%,23%,5%) &
    \	next i%
2300	call plot("T2130") &
    \	call plot("B2130") &
    \	advice$="+A2130" &
    \	answer$="2:30." &
    \	feedback$="Please change the time to read 12:30." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2350,2350,9900
2350	call plot("T2135") &
    \	call plot("B2135") &
    \	advice$="+A2135" &
    \	answer$="<EOF>" &
    \	feedback$="Please exit change mode by pressing CTRL/Z." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2400,2400,9900
2400	call plot("T2140") &
    \	call plot("B2140") &
    \	advice$="+A2140" &
    \	answer$="EX*IT" &
    \	feedback$="Please exit EDT and save the file." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2450,2450,9900
2450	call plot("T2145") &
    \	advice$="+ZA101" &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 9000,9000,9900
9000	call plot("S2100") &
    \	advice$="+ZA101" &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% GOTO 9899,9899,9900
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
      !	to practice with the arrow keys.  It is assumed that the text has &
      !	been placed on the screen by the form to be plotted. &
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
10010	goto 10060 if 0%=0%		! disable all except arrow keys &
    \	goto 10015 if response$<>"<ADVANCE>" &
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
