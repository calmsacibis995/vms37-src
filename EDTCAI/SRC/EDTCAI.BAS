1     !	Driver program for the CAI course
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
      !	****	Version	1.0	13-Jan-1981	original code &
      !	&
      !
100   !	&
      !	****	Program Description &
      !	&
      !	&
      !	All of the communication to the sub-programs is done via PASS_KEY%, &
      !	which is a common variable. &
      !	&
      !	The values on entry to the ROUTER program are as follows: &
      !	&
      !		PASS_KEY% = -5% Returning from registration &
      !			    -4% Returning from testing &
      !			    -3% Returning from the Introduction &
      !			    -2% Returning from the Help Menu &
      !			    -1% *** Not used *** &
      !			     0% Entering for the first time &
      !			     1% Instructional section incomplete &
      !			     2% Instructional section complete &
      !			     3% Leave course immediately ([QUIT) &
      !			     4% Go to previous instructional section ([BACK) &
      !			     5% Execute DCL command line, exit this image &
      !	&
      !	The values on exit from the ROUTER program are as follows: &
      !	&
      !		PASS_KEY% = -5% Go to registration procedure &
      !			    -4% Go to the testing procedure &
      !			    -3% Go to the Help Menu &
      !			    -2% Go to the Introduction &
      !			    -1% *** Not used *** &
      !			     0% Leave the course.  This is the normal exit. &
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
    \	common (comnt)				! common for [COMMENT program &
		name1$=20%,			! students first name &
		name2$=30%,			! students last name &
		course_name$=20%,		! name of this course &
		comment_acc$=32%		! file name of the master comment file &
      !	&
    \	common (glosry)				! common for [GLOSSARY program &
		main_acc$=32%			! file name of dictionary file &
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
		master_objective$(10%)=5%	! list of objective formnames &
      !	&
    \	common (qiocom)				! common to hold QIO values &
		fill%(7%), &
		escape$=1%,			! the escape character &
		terminal$=3%			! the terminal type &
      !	&
    \	map (studnt) STUDENT_NUMBER$=3%,CODE_NAME$=10%,FIRST_NAME$=20%, &
		LAST_NAME$=30%,START_DATE$=15%,LOG_ON%, &
		OBJECTIVE_TIME%(10%),MODULE_STATUS%(10%),TEST_STATUS%(10%)
900   !	&
      !	****	Functions &
      !
1000  !	&
      !	****	Main Routine, come here from everywhere &
      !	&
    \	on error goto 19000 &
      !	&
    \	call router &
    \	router_flag%=1%				! flag as from the ROUTER &
    \	goto 5000 if pass_key%=-5%		! Go register &
    \	goto 4000 if pass_key%=-4%		! Go take a test &
    \	goto 3000 if pass_key%=-3%		! Go to the Introduction &
    \	goto 2000 if pass_key%=-2%		! Go to the Help Menu &
    \	router_flag%=0%				! not from the ROUTER anymore &
    \	goto 32000 if pass_key%<>1%		! if not = 1%, then exit
1010	on module_number% goto 1100,1200,1300,1400,1500,1600,1700
1100  !	&
      !	****	Module 1 &
      !	&
    \	if objective_number%<1% or objective_number%>modlim%(1%) then 32000 &
		else on objective_number% goto 1110,1112,1114,1116,1118,1120
1110	call EDT11 \ goto 2000
1112	call EDT12 \ goto 2000
1114	call EDT13 \ goto 2000
1116	rem call EDT14 \ goto 2000
1118	rem call EDT15 \ goto 2000
1120	rem call EDT16 \ goto 2000
1199    goto 1000
1200  !	&
      !	****	Module 2 &
      !	&
    \	if objective_number%<1% or objective_number%>modlim%(2%) then 32000 &
		else on objective_number% goto 1210,1212,1214,1216,1218,1220
1210	call EDT21 \ goto 2000
1212	call EDT22 \ goto 2000
1214	call EDT23 \ goto 2000
1216	call EDT24 \ goto 2000
1218	rem call EDT25 \ goto 2000
1220	rem call EDT26 \ goto 2000
1299    goto 1000
1300  !	&
      !	****	Module 3 &
      !	&
    \	if objective_number%<1% or objective_number%>modlim%(3%) then 32000 &
		else on objective_number% goto 1310,1312,1314,1316,1318,1320
1310	call EDT31 \ goto 2000
1312	call EDT32 \ goto 2000
1314	call EDT33 \ goto 2000
1316	call EDT34 \ goto 2000
1318	call EDT35 \ goto 2000
1320	rem call EDT36 \ goto 2000
1399    goto 1000
1400  !	&
      !	****	Module 4 &
      !	&
    \	if objective_number%<1% or objective_number%>modlim%(4%) then 32000 &
		else on objective_number% goto 1410,1412,1414,1416,1418,1420
1410	call EDT41 \ goto 2000
1412	call EDT42 \ goto 2000
1414	call EDT43 \ goto 2000
1416	call EDT44 \ goto 2000
1418	call EDT45 \ goto 2000
1420	call EDT46 \ goto 2000
1499    goto 1000
1500  !	&
      !	****	Module 5 &
      !	&
    \	if objective_number%<1% or objective_number%>modlim%(5%) then 32000 &
		else on objective_number% goto 1510,1512,1514,1516,1518,1520
1510	call EDT51 \ goto 2000
1512	call EDT52 \ goto 2000
1514	call EDT53 \ goto 2000
1516	call EDT54 \ goto 2000
1518	call EDT55 \ goto 2000
1520	call EDT56 \ goto 2000
1599    goto 1000
1600  !	&
      !	****	Module 6 &
      !	&
    \	if objective_number%<1% or objective_number%>modlim%(6%) then 32000 &
		else on objective_number% goto 1610,1612,1614,1616,1618,1620
1610	call EDT61 \ goto 2000
1612	call EDT62 \ goto 2000
1614	call EDT63 \ goto 2000
1616	rem call EDT64 \ goto 2000
1618	rem call EDT65 \ goto 2000
1620	rem call EDT66 \ goto 2000
1699    goto 1000
1700  !	&
      !	****	Module 7 &
      !	&
    \	if objective_number%<1% or objective_number%>modlim%(7%) then 32000 &
		else on objective_number% goto 1710,1712,1714,1716,1718,1720
1710	rem call EDT71 \ goto 2000
1712	rem call EDT72 \ goto 2000
1714	rem call EDT73 \ goto 2000
1716	rem call EDT74 \ goto 2000
1718	rem call EDT75 \ goto 2000
1720	rem call EDT76 \ goto 2000
1799    goto 1000
2000  !	&
      !	****	Handle the [HELP MENU &
      !	&
    \	goto 1000 if pass_key%<>-2%		! if they didn't choose the &
						! [HELP Menu, go to the router &
    \	call hlpmnu(router_flag%) &
    \	goto 1010 if pass_key%=2%		! go back to the current instruction &
    \	goto 32000 if pass_key%=3%		! leave the course &
    \	goto 1000				! anything else treat as -2% &
						! and go back to the router
3000  !	&
      !	****	Introduction &
      !	&
    \	call intro &
    \	goto 1000
4000  !	&
      !	****	Take a Pre or Post Test &
      !	&
    !	call tester &
    \	goto 1000
5000  !	&
      !	****	Get Registered into the course &
      !	&
    \	call regstr &
    \	if pass_key%=0% then 32000 &
		else 1000
19000 !	&
      ! ****	Error recovery routine &
      !	&
    \	resume 32000
32000 !	&
      !	****	Program completion and exit routines &
      !	&
    \	call setup("EXIT","",error%)
32767	end
