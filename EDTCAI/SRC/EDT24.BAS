1	sub edt24
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
		header_flag%			! =0% if heading not finished &
      !	&
    \	common (qiocom)				! common for main parameters &
		fill%(7%), &
		escape$=1%, &
		terminal$=3% &
      !	&
    \	external integer function lbr$ini_control &
    \	external integer function lbr$open &
    \	external integer function lbr$close &
    \	external integer function lbr$get_help &
    \	external integer plot_help &
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
    \	advice$="ZA101" if advice$="" &
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
    \	call keypad("EDT") &
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
      !	****	Begin Main instruction &
      !	&
    \	call keypad("EDT") &
      !	&
    \	call plot("I2400") &
    \	advice$="+ZA101" &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2000,2000,9900
2000	call plot("T2400") &
    \	advice$="+A2400" &
    \	answer$="<HELP>" &
    \	feedback$="<HELP> is the PF2 key." &
    \	feedback$="<HELP> is the center blank key." if terminal$="V52" &
    \	response$=fn_getanswer$ &
    \	on where% goto 2050,2050,9900
2050	call plot("T2405") &
    \	advice$="+A2405" &
    \	answer$="<ADVANCE>" &
    \	feedback$="<ADVANCE> is the keypad key #4." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2100,2100,9900
2100	call keypad("SPECIAL") &
    \	call plot("T2410") &
    \	advice$="+A2410" &
    \	answer$="<GOLD>" &
    \	feedback$="<GOLD> is the PF1 key." &
    \	feedback$="<GOLD> is the right blank key." if terminal$="V52" &
    \	option%=SINGLE_CHARACTER% &
    \	response$=fn_getanswer$ &
    \	on where% goto 2150,2150,9900
2150	call keypad("EDT") &
    \	call plot("T2415") &
    \	advice$="+A2415" &
    \	answer$="" &
    \	feedback$="Please press the RETURN key." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2200,2200,9900
2200	call plot("T2420") &
    \	advice$="+A2420" &
    \	answer$="<EOF>" &
    \	feedback$="Please press CTRL/Z." &
    \	response$=fn_getanswer$ &
    \	on where% goto 2250,2250,9900
2250	call plot("T2425")
2255	advice$="+A2425" &
    \	answer$="" &
    \	feedback$="" &
    \	option%=SINGLE_CHARACTER% &
    \	response$=fn_getanswer$ &
    \	on where% goto 2260,2260,9900
2260	goto 2300 if response$==" " &
    \	call feedbk("Please press the SPACE bar.") &
    \	goto 2255
2300	call plot("T2430")
2305	answer$="" &
    \	advice$="+A2430" &
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
    \	term_type$="VT52" &
    \	term_type$="VT100" if terminal$="VT1" &
      !	&
    \	call keypad("SPECIAL") &
      !	&
    \	if term_type$="VT52" then &
		key_pointer$="<LINE>00<WORD>01<EOL>02<CUT>03<ADVANCE>04<BACKUP>05" &
			    +"<DEL C>06<PAGE>07<FNDNXT>08<DEL W>09<HELP>10<DEL L>11" &
			    +"<UP>12<DOWN>13<RIGHT>14<LEFT>15<SELECT>16<GOLD>20<ENTER>21" &
			    +"<CTRL/A>45<CTRL/D>48<CTRL/E>49<CTRL/H>52<CTRL/J>54" &
			    +"<CTRL/K>55<CTRL/T>64<CTRL/U>65<EOF>70" &
	   else key_pointer$="<LINE>00<WORD>01<EOL>02<CHAR>03<ADVANCE>04<BACKUP>05" &
			    +"<CUT>06<PAGE>07<SECT>08<APPEND>09<HELP>10<FNDNXT>11" &
			    +"<UP>12<DOWN>13<LEFT>14<RIGHT>15<SELECT>16<DEL L>17" &
			    +"<DEL W>18<DEL C>19<GOLD>20<ENTER>21" &
			    +"<CTRL/A>45<CTRL/D>48<CTRL/E>49<CTRL/H>52<CTRL/J>54" &
			    +"<CTRL/K>55<CTRL/T>64<CTRL/U>65<EOF>70"
3102	call plot("T2440")
3105	call setloc("A",24%,1%,24%,1%) &
    \	advice$="+ZA101" &
    \	answer$="" &
    \	feedback$="" &
    \	option%=SINGLE_CHARACTER% &
    \	response$=fn_getanswer$ &
    \	on where% goto 3110,3110,9900
3110	goto 3102 if response$=="" &
    \	goto 3900 if response$==" " &
    \	response$="<CTRL/A>" if ascii(response$)=1% &
    \	response$="<CTRL/D>" if ascii(response$)=4% &
    \	response$="<CTRL/E>" if ascii(response$)=5% &
    \	response$="<CTRL/H>" if ascii(response$)=8% &
    \	response$="<CTRL/J>" if ascii(response$)=10% &
    \	response$="<CTRL/K>" if ascii(response$)=11% &
    \	response$="<CTRL/T>" if ascii(response$)=20% &
    \	response$="<CTRL/U>" if ascii(response$)=21% &
      !	&
    \	temp%=0% &
    \	temp%=pos(key_pointer$,response$,1%) if left$(response$,1%)="<" &
					    and right$(response$,len(response$))=">" &
    \	goto 3120 if temp%<1% &
    \	key_key$=seg$(key_pointer$,temp%+len(response$),temp%+len(response$)+1%) &
    \	print escape$+"H"+escape$+"J" if terminal$="V52" &
    \	print escape$+"[H"+escape$+"[0J" if terminal$="VT1" &
    \	header_flag%=0% &
    \	x%=lbr$get_help(library_index%,,plot_help by ref,,"KEYPAD",term_type$,key_key$) &
    \	print "" &
    \	print "To return to the keypad diagram, press the return key" &
    \	print "For help on another keypad key, press the key" &
    \	print "To exit from HELP, type a space" &
    \	goto 3105
3120	call feedbk("Press a keypad key, or type a space to quit.") &
    \	goto 3105
3900	x%=lbr$close(library_index%) &
    \	call keypad("EDT")
4000	call plot("S2400") &
    \	advice$="+ZA101" &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	goto 9899
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
