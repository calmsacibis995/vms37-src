1	sub glsry
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
      !	****	Version 1.0			18-Apr-79 &
      !	&
      !
100   !	&
      !	****	Program Description &
      !	&
      !	This program processes GLOSSARY requests.  The word to be defined is &
      !	requested from the student, after which the word is searched for in &
      !	the array G$, which contains the list of all GLOSSARY defined words. &
      !	If found, the file GLSRY.ACC$+".DIC" is opened and the definition is &
      !	printed out from the database onto the bottom 3 lines of the screen. &
      !
300   !	&
      !	****	Files &
      !	&
      !		# 2	GLSRY.ACC$ + ".DIC"	Glossary words and definitions &
      !
400   !	&
      !	****	Variable Directory &
      !
800   !	&
      !	****	Dimension the arrays &
      !	&
    \	common (glosry) 			! common to hold GLOSSARY &
		glsry.acc$=32%,			! directory specification &
		g%,				! number of words in list &
		g$(200%)=16%			! list of key words &
      !	&
    \	common (qiocom) &
		fill%(7%), &
		escape$=1%, &
		terminal$=3% &
      !	&
    \	external integer function sys$qiow
900   !	&
      !	****	Functions &
      !
1000  !	&
      !	First set up some constants. &
      !	&
    \	on error goto 19000 &
      !	&
    \	x0%=1%+4%+32%+128% &
    \	x%=ctrlc% &
      !	&
    \	if terminal$="V52" then &
		erase.line$=escape$+"K" &
    \		erase.screen$=escape$+"J" &
    \		line22$=escape$+"Y5 " &
    \		line23$=escape$+"Y6 " &
    \		line24$=escape$+"Y7 " &
    \		goto 1100
1010	if terminal$="VT1" or terminal$="VK1" then &
		erase.line$=escape$+"[0K" &
    \		erase.screen$=escape$+"[0J" &
    \		line22$=escape$+"[22;1H" &
    \		line23$=escape$+"[23;1H" &
    \		line24$=escape$+"[24;1H" &
    \		goto 1100
1020  !	&
      !	At this point, it is not a legal type of terminal, so abort &
      !	&
    \	subexit
1100  !	&
      !	****	Check to see whether or not the GLOSSARY file exists. &
      !	&
    \	close 2% &
    \	open edit$(glsry.acc$,128%)+".DIC" for input as file 2%, &
		access read, &
		allow read
1110  !	&
      !	At this point the GLOSSARY file may not exist.  If so, complain. &
      !	&
    \	if g% < 1% then &
		print line23$+erase.screen$; &
    \		print "The file ";edit$(glsry.acc$,128%); &
		      ".DIC which contains the GLOSSARY words cannot be accessed."; &
    \		print "Please contact your System Manager about this problem."; &
    \		subexit
1120  !	&
      !	Inquire what word the student wants defined. &
      !	&
    \	print line22$;erase.screen$;
2000	print line23$;erase.line$;" What word "; &
    \	linput x$ &
    \	x$=edit$(x$,x0%)
2010	if len(x$)<1% then &
		print line22$;erase.screen$ &
    \		subexit
2020	restore #2 &
    \	for s2%=0% to g% &
    \		goto 2040 if x$=seg$(g$(s2%),1%,len(x$)) &
    \	next s2%
2030	print line24$;erase.screen$+" '"+x$+"' is not in the GLOSSARY."; &
    \	goto 2000
2040	linput #2, s2$ &
    \	goto 2040 if "<W> "+x$<>edit$(seg$(s2$,1%,len(x$)+4%),x0%) &
    \	linput #2, s2$ &
    \	s2$=seg$(s2$,3%,len(s2$)) &
    \	s3$="<>" &
    \	linput #2, s3$ if s2$<>"<>" &
    \	s4$="<>" &
    \	linput #2, s4$ if s3$<>"<>" &
    \	s5$=line22$ &
    \	if s3$="<>" then &
		s5$=line24$ &
		else if s4$="<>" then &
			s5$=line23$
2050	goto 2060 if left$(s2$,3%)="> @" and s3$="<>" &
      ! &
      !	Here there is text to print, so print it. &
      ! &
    \	print line22$+erase.screen$+s5$+" "+s2$; &
    \	print s5$+chr$(10%)+" "+s3$; if seg$(s3$,1%,1%)<>"<" &
    \	print s5$+chr$(10%)+chr$(10%)+" "+s4$; if seg$(s4$,1%,1%)<>"<" &
    \	subexit
2060  ! &
      !	Here there is a form to plot, so plot it. &
      ! &
    \	call plot(seg$(edit$(s2$,32%),4%,8%)) &
    \	subexit
19000 !	&
      !	****	Error Handling &
      !	&
    \	if erl=1100 then			! error opening the file &
		g%=-1%				! set the flag &
    \		close #2% &
    \		resume 1110
19010	if erl=2000 then			! error on student input &
		x$="" &
    \		resume 2010
19020	if erl=2040 then			! error reading the file &
		resume 2030
19999 !	&
      !	****	All other error handling &
      !	&
    \	print line22$;erase.screen$; &
    \	print "Error in sub-program GLSRY at line";erl;"which is ";ert$(err) &
    \	print "Please contact your System Manager and report this problem." &
    \	resume 32000
32000 !	&
      !	****	Exit routines &
      !
32767	subend
