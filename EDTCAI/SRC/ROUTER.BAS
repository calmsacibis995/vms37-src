1	sub router
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
50    !	&
      !	****	Version	1.0	12-Jan-81	original code &
      !
100   !	&
      !	****	Program Description &
      !	&
      !	This is the router program which tracks all students in the course, &
      !	and sends them to the correct place in the curriculum. &
      !	&
      !	All of the communication to the calling program is done via PASS_KEY%, &
      !	which is a common variable.  Its entry values are as follows: &
      !	&
      !		PASS_KEY% = -5% Just registered, go to introduction &
      !			    -4% Returning from testing &
      !			    -3% Returning from the Introduction &
      !			    -2% Returning from the Help Menu &
      !			    -1% *** Not used *** &
      !			     0% Entering for the first time &
      !			     1% Instructional section incomplete, go to a menu &
      !			     2% Instructional section complete, go to the next section &
      !			     3% Leave course immediately ([QUIT) &
      !			     4% Go to previous instructional section ([BACK) &
      !			     5% Execute command line, exit this image &
      !	&
      !	The exit values of PASS_KEY% are as follows: &
      !	&
      !		PASS_KEY% = -5% Go to registration procedure &
      !			    -4% Go to the testing procedure &
      !			    -3% Go to the Introduction &
      !			    -2% Go to the Help Menu &
      !			    -1% *** Not used *** &
      !			     0% Leave the course. &
      !			     1% Go to instruction &
      !
300   !	&
      !	****	Files &
      !	&
      !		  1	??????.ROS	Roster of all students &
      !		  2	??????.DIC	File containing [GLOSSARY words &
      !		  3	??????.CMT	Permanent file to hold all comments &
      !		 12	???V52.DLB &
      !		     or ???VT1.DLB &
      !		     or ???VK1.DLB	The DRAW library file &
      !
400   !	&
      !	****	Variable Directory &
      !
800   !	&
      !	****	Dimension the arrays &
      !	&
    \	dim modmenu$(10%)			! module menu form array &
    \	dim statpos$(20%)			! status position array &
    \	dim summary$(10%,10%)			! summary form name array &
    \	dim objective$(10%,10%)			! objective form name array &
    \	dim module_time%(10%) &
    \	dim module_status%(10%) &
    \	dim test_status%(10%) &
      !	&
    \	common (comnt)				! common for [COMMENT program &
		comment_name$=64%,		! students name &
		course_name$=64%		! name of this course &
      !	&
    \	common (glosry)				! common for [GLOSSARY program &
		glossary_acc$=32%		! file name of dictionary file &
      !	&
    \	common (testr)				! common for TESTER program &
		test_key%,			! main communication with TESTER &
		test_acc$=32%			! name of question bank file &
      !	&
    \	common (pasfil)				! main common for parameters &
		pass_key%,			! pointer to current activity &
						! and to the results of it &
		module_number%,			! module number to take &
		objective_number%,		! objective number to take &
		section_number%,		! section number to take &
		t,				! time (seconds) spent in this activity &
		modlim%(10%),			! # of objectives in each module &
		max_student%,			! number of students in the roster &
		map_length%,			! length (bytes) of the roster map &
		student_key$=3%,		! student primary key in roster file &
		module_map$(10%)=5%,		! list of module map formnames &
		master_objective$(10%)=5%	! the master objective forms &
      !	&
    \	common (qiocom)				! common to hold QIO values &
		fill%(7%), &
		escape$=1%,			! the escape character &
		terminal$=3%			! the terminal type &
      !	&
    \	map (studnt)				! map for ROSTER file &
		roster_key$=16%, &
		roster_data$=496% &
      !	&
    \	external integer function lib$do_command
900   !	&
      !	****	Functions &
      !
910	def fn_setup$ &
      !	&
      !	****	Set up the constants necessary for this program &
      !	&
    \	c_library_name$    = "EDT" &
      !	&
    \	c_testing_enable%  = 0%			! =1% to enable testing &
						! =0% to disable testing &
      !	&
    \	one_moment$        = "ZR104" &
      !	&
      !	****	Set up arrays &
      !	&
    \	modmenu$(0%)="ZM10" &
    \		modmenu$(1%)="ZM100" &
    \		modmenu$(2%)="ZM200" &
    \		modmenu$(3%)="ZM300" &
    \		modmenu$(4%)="ZM400" &
    \		modmenu$(5%)="ZM500" &
    \		modmenu$(6%)="ZM600" &
      !	&
    \	module_map$(0%)="ZM11" &
    \		module_map$(1%)="ZM101" &
    \		module_map$(2%)="ZM201" &
    \		module_map$(3%)="ZM301" &
    \		module_map$(4%)="ZM401" &
    \		module_map$(5%)="ZM501" &
    \		module_map$(6%)="ZM601" &
      !	&
    \	summary$(0%,0%)="S1100" &
    \		summary$(0%,1%)="S1200" &
    \		summary$(0%,2%)="S1300" &
    \	summary$(1%,0%)="S2100" &
    \		summary$(1%,1%)="S2200" &
    \		summary$(1%,2%)="S2300" &
    \		summary$(1%,3%)="S2400" &
    \	summary$(2%,0%)="S3100" &
    \		summary$(2%,1%)="S3200" &
    \		summary$(2%,2%)="S3300" &
    \		summary$(2%,3%)="S3400" &
    \		summary$(2%,4%)="S3500" &
    \	summary$(3%,0%)="S4100" &
    \		summary$(3%,1%)="S4200" &
    \		summary$(3%,2%)="S4300" &
    \		summary$(3%,3%)="S4400" &
    \		summary$(3%,4%)="S4500" &
    \		summary$(3%,5%)="-S4600" &
    \	summary$(4%,0%)="S5100" &
    \		summary$(4%,1%)="S5200" &
    \		summary$(4%,2%)="S5300" &
    \		summary$(4%,3%)="S5400" &
    \		summary$(4%,4%)="S5500" &
    \		summary$(4%,5%)="-S5600" &
    \	summary$(5%,0%)="S6100" &
    \		summary$(5%,1%)="S6200" &
    \		summary$(5%,2%)="S6300" &
      !	&
    \	master_objective$(1%)="ZO100" &
    \		master_objective$(2%)="ZO200" &
    \		master_objective$(3%)="ZO300" &
    \		master_objective$(4%)="ZO400" &
    \		master_objective$(5%)="ZO500" &
    \		master_objective$(6%)="ZO600" &
     !	&
    \	objective$(0%,0%)="O1100" &
    \		objective$(0%,1%)="O1200" &
    \		objective$(0%,2%)="O1300" &
    \	objective$(1%,0%)="O2100" &
    \		objective$(1%,1%)="O2200" &
    \		objective$(1%,2%)="O2300" &
    \		objective$(1%,3%)="O2400" &
    \	objective$(2%,0%)="O3100" &
    \		objective$(2%,1%)="O3200" &
    \		objective$(2%,2%)="O3300" &
    \		objective$(2%,3%)="O3400" &
    \		objective$(2%,4%)="O3500" &
    \	objective$(3%,0%)="O4100" &
    \		objective$(3%,1%)="O4200" &
    \		objective$(3%,2%)="O4300" &
    \		objective$(3%,3%)="O4400" &
    \		objective$(3%,4%)="O4500" &
    \		objective$(3%,5%)="ZO998" &
    \	objective$(4%,0%)="O5100" &
    \		objective$(4%,1%)="O5200" &
    \		objective$(4%,2%)="O5300" &
    \		objective$(4%,3%)="O5400" &
    \		objective$(4%,4%)="O5500" &
    \		objective$(4%,5%)="ZO998" &
    \	objective$(5%,0%)="O6100" &
    \		objective$(5%,1%)="O6200" &
    \		objective$(5%,2%)="O6300" &
      !	&
    \	if terminal$="V52" or terminal$="VT1" then &
		c_cursor$=">" &
    \		c_erase_cursor$=" " &
    \		c_star$="   *" &
    \		statpos$(0%)=fn_at$(3%,33%) &
    \		statpos$(1%)=fn_at$(5%,33%) &
    \		statpos$(2%)=fn_at$(7%,33%) &
    \		statpos$(3%)=fn_at$(9%,33%) &
    \		statpos$(4%)=fn_at$(11%,33%) &
    \		statpos$(5%)=fn_at$(13%,33%) &
    \		statpos$(6%)=fn_at$(15%,33%) &
    \		statpos$(7%)=fn_at$(17%,33%) &
    \		statpos$(8%)=fn_at$(19%,33%) &
    \		statpos$(9%)=fn_at$(21%,33%) &
    \		goto 912
911	if terminal$="VK1" then &
		c_cursor$="@A" &
    \		c_erase_cursor$="W(E)@AW(R)" &
    \		c_star$="T(I(Y))'   *'" &
    \		statpos$(0%)="P[359,125]" &
    \		statpos$(1%)="P[359,150]" &
    \		statpos$(2%)="P[359,175]" &
    \		statpos$(3%)="P[359,200]" &
    \		statpos$(4%)="P[359,225]" &
    \		statpos$(5%)="P[359,250]" &
    \		statpos$(6%)="P[359,275]" &
    \		statpos$(7%)="P[359,300]" &
    \		statpos$(8%)="P[359,325]" &
    \		statpos$(9%)="P[359,350]"
912	fnend
920	def fn_at$(x%,y%) &
      !	&
      !	This function will supply the correct escape code to place the cursor &
      !	at the screen location specified. &
      !	&
    \	f_temp$=""				! clear the escape sequence &
    \	f_temp$=chr$(27%)+"Y"+chr$(31%+x%)+chr$(31%+y%) if terminal$="V52" &
    \	f_temp$=chr$(27%)+"["+num1$(x%)+";"+num1$(y%)+"H" if terminal$="VT1" &
    \	f_temp$="P["+num1$(x%)+","+num1$(y%)+"]" if terminal$="VK1" &
    \	fn_at$=f_temp$ &
    \	fnend
930	def fn_print_error$ &
      !	&
      !	****	Function to return escape sequence to print an error message &
      !	&
    \	f_temp$=""				! initialize to null &
    \	f_temp$=escape$+"Y"+chr$(31%+24%)+chr$(31%+1%) if terminal$="V52" &
    \	f_temp$=escape$+"[24;1H" if terminal$="VT1" &
    \	f_temp$=escape$+"\"+escape$+"PrSM2VC3"+escape$+"\"+escape$+"[24;1H" if terminal$="VK1" &
    \	fn_print_error$=f_temp$			! return the correct value &
    \	fnend
940	def fn_getanswer$ &
      !	&
      !	This function will simplify the calling of the GETANS routine. &
      !	&
    \	call getans("","",3%,response$,"",limit%,result%) &
    \	limit%=-1% &
    \	fn_getanswer$=response$ &
    \	fnend
950	def fn_get_map_var%(f_temp%) &
      !	&
      !	This routine will copy a numeric value from the ROSTER_DATA$ at the &
      !	position specified, and return that value. &
      !	&
    \	f_temp1%=f_temp%*2%+1% &
    \	fn_get_map_var%=ascii(seg$(roster_data$,f_temp1%,f_temp1%))*256%+ &
			ascii(seg$(roster_data$,f_temp1%+1%,f_temp1%+1%)) &
    \	fnend
960	def fn_put_map_var$(f_temp%) &
      !	&
      !	This routine will take the number passed and return it as a two byte &
      !	string.  This can then be used to build the ROSTER_DATA$. &
      !	&
    \	fn_put_map_var$=chr$(int(f_temp%/256%))+chr$(f_temp%-(int(f_temp%/256%)*256%)) &
    \	fnend
1000  !	&
      !	****	Begin Main Routine &
      !	&
    \	on error goto 19000 &
    \	limit%=-1% &
    \	temp$=fn_setup$				! set up program constants &
      !	&
    \	restart%=0%				! set no restart &
    \	goto 31000 if pass_key%<>0%		! if PASS_KEY% = 0%, then the &
						! person is entering for the &
						! first time, otherwise they &
						! are returning from something &
    \	gosub 14700				! go set up program constants &
    \	goto 32760 if error%<>1%		! if the setup failed, quit &
    \	goto 1030 if restart%=1%		! if restarting, goto 1030
1010	comment_name$="CURRENTLY REGISTERING"	! set up a dummy name &
    \	call plot("ZR100")			! plot the opening title page &
    \	response$=fn_getanswer$ &
    \	goto 32000 if result% > 2%		! quit if [EXIT or [QUIT &
    \	if student_key$="NOR" then &
		comment_name$="UNREGISTERED STUDENT" &
    \		module_number%=1% &
    \		objective_number%=1% &
    \		goto 1200
1015	call plot("ZR101")			! plot "Enter codename" page &
    \	limit%=20% &
    \	result%=-32767%				! turn echo off &
    \	response$=fn_getanswer$ &
    \	goto 32000 if result%>2%		! quit if [EXIT or [QUIT &
    \	goto 1020 if response$=""		! go register if null codename &
    \	s1$=response$ &
    \	s1%=1% &
    \	gosub 14800				! go check the codename &
    \	goto 1030 if s1% = 1%			! found it, go to menu &
    \	call plot("ZR102")			! plot "Try again" page &
    \	result%=-32767%				! keep echo off &
    \	limit%=20% &
    \	response$=fn_getanswer$ &
    \	goto 32000 if result%>2%		! quit if [EXIT or [QUIT &
    \	goto 1020 if response$=""		! go register if null codename &
    \	s1$=response$ &
    \	s1%=1% &
    \	gosub 14800				! go check the codename &
    \	goto 1030 if s1% = 1%			! found it, go to menu &
    \	call plot("ZR103")			! plot "Too bad" page &
    \	response$=fn_getanswer$ &
    \	goto 32000				! leave the course
1020  !	&
      !	****	Set up to register the student &
      !	&
    \	t=time(0%) &
    \	pass_key%=-5% &
    \	subexit
1030  !	&
      !	****	Code name found, read this courses records. &
      !	&
    \	s1%=0% &
    \	gosub 14800 &
    \	log_on%=log_on%+1% &
    \	gosub 14900				! update the record &
    \	if s1%<>1% then				! update failed, quit &
		goto 19999
1040  !	&
      !	The update worked, send the student to the correct menu &
      !	&
    \	comment_name$=cs_name$ &
    \	goto 9000 if restart%=1% &
    \	module_number%=module_status%(0%) &
    \	if module_number%=0% then		! if they just got here &
		goto 3000			! go do the introduction &
		else 1990			! or go to the correct menu
1200  !	&
      !	****	Main Menu &
      !	&
    \	print ""; &
    \	call plot(modmenu$(0%)) &
    \	for i%=1% to modlim%(0%) &
    \		print statpos$(i%+1%)+c_star$; if int(module_status%(i%)/16%)=>(2%**modlim%(i%))-1% &
    \	next i% &
    \	arrow_loc%=module_number%+1%		! pointer to arrow &
    \	print statpos$(arrow_loc%)+c_cursor$; &
    \	module_number%=0%
1205	gosub 14600				! get some input &
    \	on result% goto				! depending on the option &
		3000,				! go to the intro &
		1205,				! *** NOT USED *** &
		1210,				! go to a module menu &
		1205,				! *** NOT USED *** &
		1205,				! *** NOT USED *** &
		1200,				! replot this menu &
		2000,				! go to the help menu &
		32000,				! exit this program &
		1205				! or go back for more
1210  !	&
      !	One of the modules has been chosen, so go to that module menu &
      !	&
    \	module_number%=arrow_loc% - 1% &
    \	goto 1990
1300  !	&
      !	****	Module Menu &
      !	&
    \	print ""; &
      !	&
    \	call plot(modmenu$(module_number%)) &
      !	&
      !	Print the gold stars for objective completion &
      !	&
    \	for s1%=1% to modlim%(module_number%) &
    \		s2%=int(module_status%(module_number%)/(2%**(s1%+3%))) &
    \		print statpos$(s1%+1%+c_testing_enable%)+c_star$; if (s2% and 1%)=1% &
    \	next s1% &
      !	&
      !	Put the cursor at the correct line &
      !	&
    \	arrow_loc%=1% &
    \	arrow_loc%=objective_number%+1%+c_testing_enable% if student_key$="NOR" &
    \	s1%=module_status%(module_number%) and 15% &
    \	arrow_loc%=s1%+1%+c_testing_enable% if s1%>0% and s1%<=modlim%(module_number%) &
    \	print statpos$(arrow_loc%)+c_cursor$; &
      !	&
      !	Print the message if the student blew a piece of the test &
      !	&
    \	goto 1305 if (test_status%(module_number%) and 1%) = 0% &
						! skip if no test taken &
    \	goto 1305 if test_status%(module_number%)>=(2%**modlim%(module_number%))-1% &
						! skip if all tests passed &
    \	temp$="" &
    \	for i%=1% to modlim%(module_number%) &
    \		temp$=temp$+num1$(i%)+", " if (test_status%(module_number%) and (2%**i%))=0% &
    \	next i% &
    \	temp$=seg$(temp$,1%,len(temp$)-2%)+"."	! add a period at the end &
    \	temp$="s "+seg$(temp$,1%,len(temp$)-3%) &
		+" and "+seg$(temp$,len(temp$)-1%,len(temp$)) &
			if pos(temp$,",",1%)>0%	! add "and" to multiple tests &
    \	print fn_at$(22%,20%)+"The last time you took the test you missed" &
    \	print fn_at$(23%,20%)+"items on objective";temp$
1305	gosub 14600 &
    \	on result% goto				! depending on the option &
		1200,				! go to the Main menu &
		5000,				! or view the Objectives &
		4000,				! or take a test &
		1320,				! or take some instruction &
		6000,				! or view the summaries &
		1300,				! or replot this page &
		2000,				! or go to the Help Menu &
		32000,				! or quit &
		1310				! or re-ask the question
1310  !	&
      !	One of the un-documented features of these menus is the ability to &
      !	go right to a module menu by typing its number (0 for the Main menu). &
      !	Here is where it is done. &
      !	&
    \	s1%=ascii(response$)-ascii("0")		! get the numeric form &
    \	goto 1305 if s1%<0% or s1%>modlim%(0%)	! forget it if out of range &
    \	module_number%=s1% &
    \	goto 1990
1320	objective_number%=arrow_loc%-1%-c_testing_enable% &
    \	section_number%=0% &
    \	goto 9000
1990  !	&
      !	****	Routine to place student at correct location &
      !	&
    \	module_number%=0% if module_number%<1% &
    \	module_number%=modlim%(0%) if module_number%>modlim%(0%) &
    \	objective_number%=1% &
    \	if module_number% = 0% then &
		goto 1200 &
		else goto 1300
2000  !	&
      !	****	Set up for the HELP MENU &
      !	&
    \	t=time(0%) &
    \	pass_key%=-2% &
    \	subexit
3000  !	&
      !	****	Set up for the INTRODUCTION &
      !	&
    \	t=time(0%) &
    \	pass_key%=-3% &
    \	subexit
3010  !	&
      !	Return from the INTRODUCTION &
      !	&
    \	module_number%=module_status%(0%) &
    \	goto 1200 if module_status%(0%)>0%	! if they were reviewing the &
						! intro, just go back &
    \	module_status%(0%)=1%			! otherwise flag the intro as &
    \	module_number%=1%			! as completed &
    \	gosub 14900				! update their records &
    \	if s1%=1% then 1200			! good, it worked &
		  else 19999			! phooey, it didn't
4000  !	&
      ! ****	Take the pre/post test &
      !	&
    \	test_key%=0%				! assume pre-test &
    \	test_key%=1% if module_status%(module_number%)<>0% &
		     or test_status%(module_number%)<>0% &
						! if they have done anything &
						! at all, give them a posttest &
    \	t=time(0%) &
    \	pass_key%=-4% &
    \	subexit
4010  !	&
      !	Return from the pre/post test &
      !	&
      !	The common variable TEST_KEY% signifies how they did on the test at &
      !	this point.  If TEST_KEY% = 0% the student QUIT out of the test before &
      !	a mastery determination could be made so treat the test as if it never &
      !	happened.  If TEST_KEY% = 1%, the student passed the test.  Otherwise, &
      !	if TEST_KEY% > 1% the student failed the test, and TEST_KEY% has bit &
      !	(N+1) on if they passed that section.  Notice that by dividing the &
      !	TEST_KEY% by 2% (ie right-shifting the word down one bit) it is in the &
      !	form required by TEST_STATUS%. &
      !	&
    \	goto 1990 if test_key%=0%		! they QUIT, forget it &
    \	test_status%(module_number%)=test_key%/2% &
    \	gosub 14900				! update their records &
    \	if s1%=1% then 1990			! good, it worked &
		  else 19999			! phooey, it didn't
5000  !	&
      !	****	Print objectives of each section &
      !	&
    \	goto 1990 if module_number%<1% or module_number%>modlim%(0%) &
    \	call plot(master_objective$(module_number%)) &
    \	response$=fn_getanswer$ &
    \	goto 32000 if result%=3% &
    \	goto 1990
6000  !	&
      !	****	Print summary of each section &
      !	&
    \	for i%=1% to modlim%(module_number%) &
    \		temp$=left$(summary$(module_number%-1%,i%-1%),1%) &
    \		if temp$<>"-" then &
			call plot(summary$(module_number%-1%,i%-1%)) &
    \			response$=fn_getanswer$ &
    \			goto 32000 if result%=3% &
    \			if result% > 2% then 1990
6010	next i% &
    \	goto 1990
9000  !	&
      !	****	Module Setup &
      !	&
    \	temp%=int(module_status%(module_number%)/(2%**(objective_number%+3%))) &
    \	temp%=temp% and 1%			! get this sections status bit &
    \	s1$=objective$(module_number%-1%,objective_number%-1%) &
    \	s2$=summary$(module_number%-1%,objective_number%-1%) &
    \	s2$=right$(s2$,2%) if left$(s2$,1%)="-" &
    \	s3$=module_map$(module_number%) &
    \	call setmod(s1$,s2$,s3$,temp%) &
    \	t=time(0%)				! set the beginning time &
    \	pass_key%=1% &
    \	subexit
10000 !	&
      !	****	Begin Sub Routines &
      !
14600 !	&
      !	****	Subroutine to handle and format input &
      !	&
      !	This routine will call the GETANS routine, and reformat the student &
      !	response into the variable result%, as follows: &
      !	&
      !	If in the Main Menu: &
      !	&
      !		result% = 1% Go to the Introduction &
      !			  2% *** NOT USED *** &
      !			  3% Go to a Module Menu &
      !			  4% *** NOT USED *** &
      !			  5% *** NOT USED *** &
      !			  6% [REVIEW or [BACKUP (replot the menu) &
      !			  7% Go to the HELP Menu &
      !			  8% Exit the course &
      !			  9% Cursor movement, or invalid answer &
      !	&
      !	If in the one of the Module Menus: &
      !	&
      !		result% = 1% Go to the Main Menu &
      !			  2% View the objectives &
      !			  3% Go take a test of some type &
      !			  4% Go take some instruction &
      !			  5% View the summary &
      !			  6% [REVIEW or [BACKUP (replot the menu) &
      !			  7% Go to the HELP Menu &
      !			  8% Exit the course &
      !			  9% Cursor movement, or invalid answer &
      !	&
    \	response$=fn_getanswer$ &
    \	on result% goto 14610,14610,14620,14620,14630,14630,14610,14640
14610 !	&
      !	Normal response, so evaluate it &
      !	&
    \	temp%=2% &
    \	temp%=temp%+c_testing_enable% if module_number%>0% &
    \	print statpos$(arrow_loc%)+c_erase_cursor$; ! erase the old pointer &
    \	arrow_loc%=arrow_loc%-1% if response$="<UP>" &
    \	arrow_loc%=arrow_loc%+1% if response$="<DOWN>" &
    \	arrow_loc%=0% if arrow_loc%>modlim%(module_number%)+temp% &
    \	arrow_loc%=modlim%(module_number%)+temp% if arrow_loc%<0% &
    \	print statpos$(arrow_loc%)+c_cursor$;	! write out the new pointer &
    \	result%=9%				! assume simple replot &
    \	return if response$<>""			! return if arrow key &
    \	goto 14615 if module_number%>0% &
      !	&
      !	Evaluate the cursor position in the Main Menu &
      !	&
    \	result%=1% if arrow_loc%=0% &
    \	result%=7% if arrow_loc%=1% &
    \	result%=3% if arrow_loc%>1% and arrow_loc%<modlim%(module_number%)+temp% &
    \	result%=8% if arrow_loc%=modlim%(module_number%)+temp% &
    \	return
14615 !	&
      !	Now evaluate the cursor position in one of the Module Menus &
      !	&
    \	result%=1% if arrow_loc%=0% &
    \	result%=2% if arrow_loc%=1% &
    \	result%=3% if arrow_loc%=2% &
    \	result%=4% if arrow_loc%>1%+c_testing_enable% and arrow_loc%<modlim%(module_number%)+temp% &
    \	result%=5% if arrow_loc%=modlim%(module_number%)+temp% &
    \	return
14620 !	&
      !	[EXIT or [QUIT &
      !	&
    \	if result%=3% and module_number%>0% then ! Exit goes to the Main Menu &
		result%=1% &
		else result%=8%			! Otherwise leave the course
14625	return
14630 !	&
      !	[REVIEW &
      !	&
    \	result%=6% &
    \	return
14640 !	&
      !	[HELP Menu &
      !	&
    \	result%=7% &
    \	return
14700 !	&
      !	****	subroutine to set everything up the first time through &
      !	&
      !	This routine gets the terminal type being run on, opens the correct &
      !	.DLB file, and opens the database roster file. &
      !	&
    \	print "One moment, please..."; &
    \	error%=0%				! assume failure &
    \	open "SYS$INSTRUCTION:ROSTER.DAT" for input as file 1%, &
		organization indexed variable, &
		access modify, &
		allow modify, &
		map studnt, &
		primary key roster_key$ noduplicates &
    \	get #1%, key #0 eq "|COURSE_"+c_library_name$ &
    \	unlock #1% &
      !	&
    \	modlim%(0%)=ascii(seg$(roster_data$,1%,1%)) &
    \	modlim%(i%)=ascii(seg$(roster_data$,i%+1%,i%+1%)) &
		for i%=1% to modlim%(0%) &
    \	roster_flags%=ascii(seg$(roster_data$,modlim%(0%)+2%,modlim%(0%)+2%)) &
      !	&
    \	student_key$="NOR" if (roster_flags% and 1%)=0% &
    \	map_length%=16%+2%+2%*3%*(modlim%(0%)+1%) &
      !	&
    \	temp%=pos(roster_data$,"\",1%) &
    \	temp1%=pos(roster_data$,"\",temp%+1%) &
    \	temp2%=pos(roster_data$,"\",temp1%+1%) &
    \	course_name$=edit$(seg$(roster_data$,temp%+1%,temp1%-1%),1%+4%+128%) &
    \	f$=edit$(seg$(roster_data$,temp1%+1%,temp2%-1%),1%+4%+128%)+c_library_name$ &
      !	&
    \	glossary_acc$=f$+"CAI" &
    \	test_acc$=f$ &
    \	call setup("SETUP",f$,error%) &
    \	return if error%<>1%			! if it failed, bomb out &
    \	s1$=fn_setup$				! set up program constants &
    \	call setmod("ZO998","ZS998","ZM11",0%) &
      !	&
      !	Now check to see if the person is re-starting the course &
      !	&
    \	restart%=0%				! set no restart &
    \	call startr("",-1%,temp%)		! get the restart parameters &
    \	return if temp%<>1%			! return if not restarting &
    \	s1%=0% &
    \	gosub 14800 &
    \	return if s1%<>1%			! quit if no records &
    \	restart%=1%				! set as restarting &
    \	error%=1%				! it all worked, set the flag &
    \	return
14800 !	&
      !	****	Subroutine to read student s1$'s records &
      !	&
      !	There are two possibilities, which decides which type of record is to &
      !	be searched for:  either the students records for this course (which &
      !	contain module times and status and the test status), or the header
      !	information (the code name and first and last name of the student). &
      !	S1%=0% indicates the first, and S1%<>0% indicates the second. &
      !	&
    \	if student_key$="NOR" then &
		s1%=1% &
    \		return
14805	goto 14850 if s1%<>0% &
    \	get #1%, key #0 eq c_library_name$+"_"+student_key$ &
      !	&
      !	Now that the student data has been read in successfully, copy it to &
      !	the proper arrays. &
      !	&
    \	f_temp2%=0% &
    \	log_on%=fn_get_map_var%(f_temp2%) &
    \	for f_temp3%=0% to modlim%(0%) &
    \		f_temp2%=f_temp2%+1% &
    \		module_time%(f_temp3%)=fn_get_map_var%(f_temp2%) &
    \		f_temp2%=f_temp2%+1% &
    \		module_status%(f_temp3%)=fn_get_map_var%(f_temp2%) &
    \		f_temp2%=f_temp2%+1% &
    \		test_status%(f_temp3%)=fn_get_map_var%(f_temp2%) &
    \	next f_temp3% &
      !	&
    \	s1%=1% &
    \	goto 14890
14810 !	&
      !	Here the GET in the previous line failed, due to a record not found. &
      !	Therefore, the student has registered for CBI, but not for this &
      !	course.  So create the record. &
      !	&
    \	roster_key$=c_library_name$+"_"+student_key$ &
    \	log_on%=1% &
    \	for s1%=0% to modlim%(0%) &
    \		module_time%(s1%)=0% &
    \		module_status%(s1%)=0% &
    \		test_status%(s1%)=0% &
    \	next s1% &
    \	roster_data$=string$(map_length%,0%) &
      !	&
    \	put #1%, count map_length% &
    \	s1%=1% &
    \	goto 14890
14850 !	&
      !	Otherwise search for the student with the code name = S1$ &
      !	&
    \	s1%=0%
14855	s1%=s1%+1% &
    \	get #1%, key #0 eq "|STUDENT_"+num1$(s1%) &
    \	goto 14855 if left$(roster_data$,10%)<>s1$ ! not found, try next one &
    \	student_key$=num1$(s1%)			! set which one found &
    \	s1%=1%					! signal success &
    \	cs_code_name$=seg$(roster_data$,1%,10%) &
    \	cs_start_date$=seg$(roster_data$,11%,25%) &
    \	cs_name$=edit$(seg$(roster_data$,26%,74%),1%+4%+128%)
14890	unlock #1% &
    \	return
14900 !	&
      !	****	Subroutine to write student student_number$'s records &
      !	&
    \	if student_key$="NOR" then &
		s1%=1% &
    \		return
14905	find #1%, key #0 eq c_library_name$+"_"+student_key$ &
      !	&
      !	Now that the data has been found, copy the data from the arrays to &
      !	the map for this file. &
      !	&
    \	f_temp$="" &
    \	f_temp$=f_temp$+fn_put_map_var$(log_on%) &
    \	for f_temp2%=0% to modlim%(0%) &
    \		f_temp$=f_temp$ +fn_put_map_var$(module_time%(f_temp2%)) &
				+fn_put_map_var$(module_status%(f_temp2%)) &
				+fn_put_map_var$(test_status%(f_temp2%)) &
    \	next f_temp2% &
      !	&
    \	roster_key$=c_library_name$+"_"+student_key$ &
    \	roster_data$=f_temp$ &
    \	update #1%, count map_length% &
    \	s1%=1%
14910	unlock #1% &
    \	return
19000 !	&
      !	****	Error Routines &
      !	&
    \	IF ERR=154 THEN				! Code name locked &
		S1%=2%				! Set the flag &
    \		IF ERL=14805 OR ERL=14855 THEN RESUME 14890 &
			ELSE IF ERL=14905 THEN RESUME 14910
19010	IF ERR=155 THEN				! Code name not found. &
		S1%=3%				! Set the flag &
    \		IF ERL=14805 THEN RESUME 14810 &
			ELSE IF ERL=14855 THEN RESUME 14890 &
				ELSE IF ERL=14905 THEN RESUME 14910
19020	IF ERL=14810 THEN			! Error in creating a new data &
						! record for this student. &
		print fn_print_error$ &
    \		print "An error has occurred in creating your records.  The error is ";ert$(err) &
    \		print "Please contact your System Manager to solve this problem." &
    \		resume 32760
19030	IF ERL=14700 THEN			! The ROSTER file is not there &
	  print fn_print_error$ &
    \	  f$="SYS$INSTRUCTION:ROSTER.DAT" &
    \	  temp$="The "+F$+" file has not been initialized properly." &
    \	  temp$="The "+F$+" file has the wrong protection code." if err=10 &
    \	  temp$="The logical name SYS$INSTRUCTION: is not assigned correctly." if err=162 &
    \	  print temp$ &
    \	  print "Please contact your System Manager to solve this problem." &
    \	  resume 32760
19999 !	&
      !	****	Subroutine to handle all other errors &
      !	&
    \	print fn_print_error$ &
    \	print "There is a problem with this course.  Please contact your System Manager." &
    \	print "The problem is at line";erl;" and is ";ert$(err) &
    \	resume 32760
31000 !	&
      !	****	Call entry point for tutorial programs &
      !	&
    \	t=time(0%)-t				! get the elapsed time &
    \	call plot(one_moment$) if pass_key%<>3% and pass_key%<>5% &
    \	s1$=student_key$ &
    \	s1%=0% &
    \	gosub 14800				! read students records &
    \	goto 19999 if s1%<>1%			! quit if the read failed &
    \	goto 1040 if pass_key%=-5%		! if just registered &
    \	goto 4010 if pass_key%=-4%		! if just finished testing &
    \	goto 3010 if pass_key%=-3%		! if just finished intro &
    \	if pass_key%=-2% then			! returning from Help Menu &
		goto 1990 if module_number%>0%	! go to a Module Menu &
    \		module_number%=module_status%(0%) &
    \		goto 1200			! or to the Main Menu
31010	goto 31020 if student_key$="NOR" &
    \	goto 31020 if module_number%<1% &
    \	goto 31020 if objective_number%<1% &
    \	module_time%(0%)=module_time%(0%)+t	! add to total time &
    \	module_time%(module_number%)=module_time%(module_number%)+t &
						! add to this modules' time &
    \	module_status%(0%)=module_number%	! update the module pointer &
      !	&
      !	If the SECTION_NUMBER% common variable is set to < 0% then give the &
      !	student credit for completing this section. &
      !	&
    \	module_status%(module_number%)=module_status%(module_number%) or (2%**(objective_number%+3%)) &
		if section_number%<0% &
      !	&
      !	If the SECTION_NUMBER% common variable is => 0%, and the PASS_KEY% &
      !	common variable is set to not go on (ie, <> 2%) then the student is &
      !	still in the middle of this section, so set the cursor to point to &
      !	this section. &
      !	&
    \	module_status%(module_number%)=(module_status%(module_number%) and 32752%) + objective_number% &
		if section_number%=>0% and pass_key%<>2% &
      !	&
    \	gosub 14900				! write the students record &
    \	goto 19999 if s1%<>1%			! if the write failed, quit
31020	goto 31030 if pass_key%=1% &
    \	goto 31040 if pass_key%=2% &
    \	goto 32000 if pass_key%=3% &
    \	goto 31050 if pass_key%=4% &
    \	goto 31060 if pass_key%=5%
31030 !	&
      !	This section of the course completed, go to options &
      !	&
    \	call keypad("CAI") &
    \	call setmod("ZO998","ZS998","ZM11",0%) &
    \	goto 1990
31040 !	&
      !	This section of the course completed, go to the next section &
      !	&
    \	objective_number%=objective_number%+1% &
    \	section_number%=0% &
    \	if module_number%<1% or module_number%>modlim%(0%) then 31030 &
		else if objective_number%>modlim%(module_number%) then 31030 &
			else 9000
31050 !	&
      !	****	[BACK, backup one section &
      !	&
    \	objective_number%=objective_number%-2% &
    \	if objective_number%>=0% then 31040 &
		else module_number%=module_number%-1% &
    \		objective_number%=modlim%(module_number%)-1% &
    \		goto 31040
31060 !	&
      !	****	Execute the DCL command line &
      !	&
    \	close #1, #2, #3, #12 &
    \	temp$=edit$(glossary_acc$,128%) &
    \	x%=lib$do_command(temp$) &
      !	&
      !	Oops.  Since we are here at all, something must have gone wrong with &
      !	the LIB$DO_COMMAND.  Tell the student, and abort. &
      !	&
    \	print fn_print_error$ &
    \	print "There is a problem with this course.  Please contact your System Manager." &
    \	print "The command '";temp$;"' could not be executed." &
    \	goto 32760
32000 !	&
      !	****	Program Completion & Exit Routines &
      !	&
    \	print escape$+"H"+escape$+"J"; if terminal$="V52" &
    \	print escape$+"[H"+escape$+"[2J"; if terminal$="VT1" &
    \	print "S(E)"; if terminal$="VK1"
32760	pass_key%=0%
32767	subend
