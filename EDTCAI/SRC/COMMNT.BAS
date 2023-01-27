1	sub commnt
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
      !	****	Version 1.0			5-Apr-79
100   !	&
      !	&
      !	&
      !	****	Program Description &
      !	&
      !	This program accepts comments on the bottom 3 lines of the screen, and &
      !	writes them to the array "COMMENT.BUF$".  After the student finishes &
      !	writing the comment, it is appended to the master comment file. &
      !
300   !	&
      !	****	Files &
      !	&
      !		# 3	COMMENT_ACCOUNT$+.CMT  Permanent file for all comments &
      !
400   !	&
      !	****	Variable Directory &
      !	&
      !		comment_account$  file specification of permanent comment file &
      !		erase.line$	escape sequence to erase to the end of a line &
      !		erase.screen$	escape sequence to erase to the end of the screen &
      !		line22$, line23$, line24$	escape sequences to position the &
      !				cursor at (22,1), (23,1), and (24,1) &
      !		n0$		student number (primary key for database) &
      !		n1$		student first name &
      !		n2$		student last name &
      !		terminal$	terminal type (V52, VT1, VK1) &
      !		x$, x0$-x1$	variables to accept and convert student input &
      !		x0%		value for edit$ function &
      !
800   !	&
      !	****	Dimension the arrays &
      !	&
    \	dim comment.buf$(100%)			! place to hold comment &
      !	&
    \	common (comnt)				! common for [COMMENT &
		name$=64%,			! students name &
		course$=64%			! course name &
      !	&
    \	common (pasfil) &
		pass_key%, &
		module_number%, &
		objective_number%, &
		section_number% &
      !	&
    \	common (qiocom) &
		fill%(7%), &
		escape$=1%, &
		terminal$=3% &
      !	&
    \	map (dsply) &
		rec.num$=5%, &
		rec.val$=4091% &
      !
900   !	&
      !	****	Functions &
      !
1000  !	&
      !	First set up some constants. &
      !	&
    \	on error goto 19000 &
      !	&
    \	x0%=1%+4%+8%+32%+128%			! set up the editing constant &
      !	&
    \	if terminal$="V52" then &
		erase.line$=escape$+"K" &
    \		erase.screen$=escape$+"J" &
    \		line22$=escape$+"Y5 " &
    \		line23$=escape$+"Y6 " &
    \		line24$=escape$+"Y7 " &
    \		goto 1090
1010	if terminal$="VT1" or terminal$="VK1" then &
		erase.line$=escape$+"[0K" &
    \		erase.screen$=escape$+"[0J" &
    \		line22$=escape$+"[22;1H" &
    \		line23$=escape$+"[23;1H" &
    \		line24$=escape$+"[24;1H" &
    \		goto 1090
1020  !	&
      !	At this point, it is not a legal type of terminal, so abort &
      !	&
    \	subexit
1090	s2$=""					! the line they just entered &
    \	comment.ptr%=0%				! pointer to the line of the &
						! array to store the comment
2000  !	&
      !	****	Accept the input and store it one line at a time &
      !	&
    \	print line22$+erase.screen$+line24$+"Enter your comment.  Type HELP for assistance, CTRL/Z to end.";
2010	s1$=s2$ &
    \	print line22$+erase.line$+s1$+line23$+erase.line$; &
    \	gosub 15000 &
    \	s2$=x$ &
    \	s3$=edit$(s2$,x0%) &
    \	goto 2020 if seg$(s3$,1%,2%)="[E" &
    \	goto 3000 if s3$="HELP" &
    \	comment.ptr%=comment.ptr% + 1% &
    \	comment.buf$(comment.ptr%)=s2$ &
    \	goto 2010
2020	close 3% &
    \	open "SYS$INSTRUCTION:COMMENT.DAT" as file 3%, &
		sequential, &
		recordsize 80%, &
		access append &
      !	&
    \	print #3, "<N> ";edit$(name$,128%) &
    \	print #3, "<F> ";rec.num$; &
		  " <C> ";edit$(course$,128%); &
		  " <L>";module_number%;objective_number%;section_number%; &
		  " <D> ";date$(0%);" ";time$(0%) &
    \	print #3, "<TX>"; &
    \	for i%=1% to comment.ptr% &
    \		print #3, comment.buf$(i%) &
    \	next i% &
    \	print #3, "<>"
2030	close 3% &
    \	print line22$;erase.screen$; &
		line24$;space$(19%);"Thank you, your comment has been stored."; &
		space$(7%);"Press <RETURN>"; &
    \	subexit
3000  !	&
      !	[HELP for [COMMENT section &
      !	&
    \	print line22$+erase.screen$+"    Enter your comment one line at a time.  Each time you press <RETURN>" &
    \	print line23$+"the last line you typed will move up, allowing you to enter the next line." &
    \	print line24$+"Hold down the <CTRL> key and press Z to end your comment."+line22$; &
    \	gosub 15000 &
    \	s2$=s1$ &
    \	goto 2000
15000 !	&
      !	****	Subroutine to handle all keyboard input &
      !	&
    \	x$="" &
    \	linput x$
15005	return
19000 !	&
      !	****	Error Routine &
      !	&
    \	if erl=15000 then &
		x$="[END" if err=11 or err=28 &
    \		resume 15005
19010	if erl=2020 then &
		resume 2030
19999 !	&
      !	****	All other error handling &
      !	&
    \	print line22$;erase.screen$; &
    \	print "Error in sub-program COMMNT at line";erl;"which is ";ert$(err) &
    \	print "Please contact your System Manager and report this problem." &
    \	resume 32000
32000 !	&
      !	****	Exit routine &
      !
32767	subend
