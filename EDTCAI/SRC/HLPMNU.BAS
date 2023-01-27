1	sub hlpmnu(router_flag%)
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
      ! &
      !		Version V03-000 &
      ! &
      !****************************************************************************
      !
50    !	&
      !	****	Version 1.0		 5-May-80		Original Code &
      !
100   !	&
      !	****	Program Description &
      !	&
      !	This program will display the help menu for this course.  The student &
      !	can move a cursor to the help option desired, and then execute that &
      !	option.  When the student is finished, control is simply returned to &
      !	the calling routine.  The parameter is a flag to tell whether or not &
      !	this routine was called from the ROUTER program.  If ROUTER_FLAG% = 1% &
      !	then this routine was called from one of the menu displays in the &
      !	router, otherwise this routine was called from one of the instruction &
      !	modules, and ROUTER_FLAG% = 0%. &
      !	&
      !	Returns from this program are stored in PASS_KEY% and are as follows: &
      !	&
      !		PASS_KEY% = -2% Return to the ROUTER program &
      !			     2% Return to an instructional program &
      !			     3% Leave the course completely &
      !
300   !	&
      !	****	Files &
      !
400   !	&
      !	****	Variable Directory &
      !
800   !	&
      !	****	Map, Common, and External Statements &
      !	&
    \	dim statpos$(10%) &
    \	dim information$(8%) &
    \	dim movement$(6%) &
      !	&
    \	common (pasfil)				! common to hold passed values &
		pass_key%,			! holds the return value for &
						! use in the ROUTER &
		module_number%,			! the module to be studied &
		objective_number%,		! the objective to be studied &
		subobjective_number%,		! the subobjective to be studied &
		t,				! time (seconds) spent here &
		modlim%(10%),			! count of sections in modules &
		max_student%,			! number of students in the roster &
		map_length%,			! length (bytes) of the map &
		student_key$=3%,		! primary key for the student &
		module_map$(10%)=5%,		! list of module map formnames &
		objective_list$(10%)=5%		! list of objective formnames &
      !	&
    \	common (qiocom)				! common to hold QIO constants &
		fill%(7%), &
		escape$=1%,			! the escape character &
		terminal$=3%			! this persons terminal type &
      !
900   !	&
      !	****	Functions &
      !
910	def fn_setup$ &
      !	&
      !	Set up some constants for this routine &
      !	&
    \	num_information%=8% &
    \		information$(1%)="ZH201" &
    \		information$(2%)="ZH202" &
    \		information$(3%)="ZH203" &
    \		information$(4%)="ZH204" &
    \		information$(5%)="ZH205" &
    \		information$(6%)="ZH206" &
    \		information$(7%)="ZH207" &
    \		information$(8%)="ZH208" &
      !	&
    \	num_movement%=6% &
    \		movement$(1%)="ZH301" &
    \		movement$(2%)="ZH302" &
    \		movement$(3%)="ZH303" &
    \		movement$(4%)="ZH304" &
    \		movement$(5%)="ZH305" &
    \		movement$(6%)="ZH306" &
      !	&
    \	if terminal$="V52" or terminal$="VT1" then &
		statpos$(1%)=fn_at$(3%,35%) &
    \		statpos$(2%)=fn_at$(5%,35%) &
    \		statpos$(3%)=fn_at$(7%,35%) &
    \		statpos$(4%)=fn_at$(9%,35%) &
    \		statpos$(5%)=fn_at$(11%,35%) &
    \		statpos$(6%)=fn_at$(13%,35%) &
    \		statpos$(7%)=fn_at$(15%,35%) &
    \		statpos$(8%)=fn_at$(17%,35%) &
    \		statpos$(9%)=fn_at$(19%,35%) &
    \		cursor_string$=" > " &
    \		erase_cursor_string$="   " &
    \		goto 912
911	if terminal$="VK1" then &
		statpos$(1%)="P[359,125]" &
    \		statpos$(2%)="P[359,155]" &
    \		statpos$(3%)="P[359,185]" &
    \		statpos$(4%)="P[359,215]" &
    \		statpos$(5%)="P[359,245]" &
    \		statpos$(6%)="P[359,275]" &
    \		statpos$(7%)="P[359,305]" &
    \		statpos$(8%)="P[359,335]" &
    \		statpos$(9%)="P[359,365]" &
    \		cursor_string$="@AW(A0)" &
    \		erase_cursor_string$="W(E)@AW(R,A0)"
912	fn_setup$="" &
    \	fnend
920	def fn_at$(x%,y%) &
      !	&
      !	This function will return the escape sequence to place the cursor at &
      !	the screen position X,Y for a VT52 or VT100 terminal. &
      !	&
    \	f_temp$=""				! clear the return value &
    \	f_temp$=escape$+"Y"+chr$(x%+31%)+chr$(y%+31%) if terminal$="V52" &
    \	f_temp$=escape$+"["+num1$(x%)+";"+num1$(y%)+"H" if terminal$="VT1" &
    \	fn_at$=f_temp$ &
    \	fnend
930	def fn_getanswer$ &
      !	&
      !	This function will simplify the calling of the GETANS routine. &
      !	&
    \	call getans("","",3%,response$,"",-1%,option%) &
    \	fn_getanswer$=response$ &
    \	fnend
1000  !	&
      !	****	Main Routine &
      !	&
    \	on error goto 19000 &
    \	temp$=fn_setup$
1100  !	&
      !	****	Main display &
      !	&
    \	call plot("ZH100") &
    \	cursor%=1% &
    \	max_cursor%=9% &
    \	print statpos$(cursor%)+cursor_string$;
1110  !	&
      !	****	Main loop &
      !	&
    \	gosub 10000				! go get some input &
    \	on option%+3% goto 2100,2000,1110,2000,2100,2200,2300,2400,2500,2600,2700,2800,1110
2000  !	&
      !	****	Go back to where you were &
      !	&
    \	pass_key%=2%				! go back to some instruction &
    \	pass_key%=-2% if router_flag%=1%	! but not if from the ROUTER &
    \	router_flag%=pass_key% &
    \	subexit
2100  !	&
      !	****	Leave the course completely ([QUIT) &
      !	&
    \	pass_key%=3% &
    \	router_flag%=pass_key% &
    \	subexit
2200  !	&
      !	****	Go back to the Main Module Menu in ROUTER &
      !	&
    \	pass_key%=-2% &
    \	module_number%=0% &
    \	router_flag%=pass_key% &
    \	subexit
2300  !	&
      !	****	Go back to the specific menu in ROUTER &
      !	&
    \	pass_key%=-2% &
    \	router_flag%=pass_key% &
    \	subexit
2400  !	&
      !	****	Show the Maps of the course &
      !	&
    \	call plot(module_map$(0%)) &
    \	response$=fn_getanswer$ &
    \	goto 2100 if option% = 4% &
    \	goto 1100
2500  !	&
      !	****	Show the Objectives of the course &
      !	&
    \	for i%=1% to modlim%(0%) &
    \		call plot(objective_list$(i%)) &
    \		response$=fn_getanswer$ &
    \		goto 2100 if option% = 4% &
    \		goto 1100 if option% > 2% &
    \	next i% &
    \	goto 1100
2600  !	&
      !	****	Show the Keypad Diagram &
      !	&
    \	call plot("ZK1") &
    \	response$=fn_getanswer$ &
    \	goto 2100 if option% = 4% &
    \	goto 1100
2700  !	&
      !	****	Show the Informational Features of the course &
      !	&
    \	call plot("ZH101") &
    \	cursor%=1% &
    \	max_cursor%=9% &
    \	print statpos$(cursor%)+cursor_string$;
2710  !	&
      !	Main loop of the informational features &
      !	&
    \	gosub 10000 &
    \	goto 2100 if option% = -2% &
    \	if option%<0% or option%=max_cursor% then 1100 &
		else if option%=0% then 2710 &
			else temp$=information$(option%) &
    \				call plot(temp$) &
    \				response$=fn_getanswer$ &
    \				goto 1100 if option% = 3% &
    \				goto 2100 if option% = 4% &
    \				goto 2700
2800  !	&
      !	****	Show the Movement Features of the course &
      !	&
    \	call plot("ZH102") &
    \	cursor%=1% &
    \	max_cursor%=6% &
    \	print statpos$(cursor%)+cursor_string$;
2810  !	&
      !	Main loop of the movement features &
      !	&
    \	gosub 10000 &
    \	goto 2100 if option% = -2% &
    \	if option%<0% or option%=max_cursor% then 1100 &
		else if option%=0% then 2810 &
			else temp$=movement$(option%) &
    \				call plot(temp$) &
    \				response$=fn_getanswer$ &
    \				goto 1100 if option% = 3% &
    \				goto 2100 if option% = 4% &
    \				goto 2800
10000 !	&
      !	****	Main input routine &
      !	&
      !	This routine will handle the input for the main Help Menu. &
      !	&
      !	Return values are stored in OPTION%, and are as follows: &
      !	&
      !		-2% = [QUIT pressed &
      !		-1% = [EXIT pressed &
      !		 0% = An arrow key pressed, cursor moved, try again &
      !		 1% through MAX_CURSOR% = that option was chosen from the menu &
      !	&
    \	response$=fn_getanswer$ &
    \	on option% goto 10010,10010,10020,10020,10010,10010,10010,10010
10010 !	&
      !	Move the cursor, or set OPTION as necessary &
      !	&
    \	print statpos$(cursor%)+erase_cursor_string$;	! first erase the old cursor &
    \	cursor%=cursor%+1% if response$="<DOWN>" &
    \	cursor%=cursor%-1% if response$="<UP>" &
    \	cursor%=1% if cursor% > max_cursor% &
    \	cursor%=max_cursor% if cursor% < 1% &
    \	print statpos$(cursor%)+cursor_string$;	! and print the new one &
    \	option%=0%				! set the default case &
    \	option%=cursor%	if response$=""		! if they pressed return, set &
						! the value accordingly &
    \	return
10020 !	&
      !	Exit the help menu as specified &
      !	&
    \	if option%=3% then option%=-1% &
		      else option%=-2%
10025	return
19000 !	&
      !	****	Error recovery routine &
      !	&
    \	if err=28 then				!  CTRL/C trap &
		resume 32000
19099 !	&
      !	No error recovery has worked to here, so just abort. &
      !	&
    \	resume 32767
32000 !	&
      !	****	Exit routine &
      !	&
    \	pass_key%=-2%
32767	subend
