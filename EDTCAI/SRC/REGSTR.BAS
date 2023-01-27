1	sub regstr
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
      !	****	Version	1.0	13-Jan-81	original code &
      !
100   !	&
      !	****	Program Description &
      !	&
      !	This program handles all of the collection of data necessary to &
      !	register a student into the data base.  It also ensures that there &
      !	is no duplication of the data in the data base, by prohibiting the &
      !	student from entering duplicate data. &
      !	&
      !	The program expects one value to be placed in common by the calling &
      !	routine, which is the number of students in the roster (MAX_STUDENT%). &
      !	It is to be stored in the common variable MODULE_NUMBER%, which is &
      !	simply a convenient common location. &
      !	&
      !	There are two exit conditions, flagged by values in PASS_KEY%, as &
      !	follows: &
      !	&
      !		PASS_KEY% = -5% success, student registered in the roster file &
      !			  =  0% failure, either there is no room in the roster &
      !				file to register the student, or the student &
      !				quit and did not complete registration. &
      !
300   !	&
      !	****	Files &
      !	&
      !		  1	??????.ROS	Roster of all students &
      !
400   !	&
      !	****	Variable Directory &
      !
800   !	&
      !	****	Dimension the arrays &
      !	&
    \	common (pasfil)				! common to hold passed values &
		pass_key%,			! pointer to a students activity &
						! or the results of that activity &
		module_number%,			! the module to be studied, &
		objective_number%,		! the objective to be studied &
		section_number%,		! the section to be studied &
		t,				! time (seconds) spent here &
		modlim%(10%),			! count of sections in modules &
		max_student%,			! number of students in roster &
		map_length%,			! length (bytes) of the map &
		student_key$=3%			! primary key for a student &
      !	&
    \	common (qiocom)				! common for QIO values &
		fill%(7%),			! don't really need these &
		escape$=1%,			! the ESCAPE character &
		terminal$=3%			! = "V52", "VT1", or "VK1" &
      !	&
    \	map (studnt) &
		roster_key$=16%, &
		roster_data$=496% &
      !
900   !	&
      !	****	Begin Functions &
      !
910	def fn_setup$ &
      !	&
      !	****	Function to set up constants for this program &
      !	&
    \	fn_setup$="" &
    \	fnend
920	def fn_print_error$ &
      !	&
      !	****	Function to return escape sequence to print an error message &
      !	&
    \	f_temp$=""				! initialize to null &
    \	f_temp$=escape$+"Y"+chr$(31%+24%)+chr$(31%+1%) if terminal$="V52" &
    \	f_temp$=escape$+"[24;1H" if terminal$="VT1" &
    \	f_temp$=escape$+"\"+escape$+"PrSM2VC3"+escape$+"\"+escape$+"[24;1H" if terminal$="VK1" &
    \	fn_print_error$=f_temp$			! return the correct value &
    \	fnend
930	def fn_getanswer$ &
      !	&
      !	This function will simplify the calling of the GETANS routine. &
      !	&
    \	call getans("","",3%,response$,"",-1%,result%) &
    \	fn_getanswer$=response$ &
    \	fnend
1000  !	&
      !	****	Get all information to register a student &
      !	&
    \	on error goto 19000 &
      !	&
      !	Set up some constants &
      !	&
    \	s1$=fn_setup$ &
      !	&
      !	First find if there is a slot for them &
      !	&
    \	rec_num%=0%				! initialize the counter
1002	rec_num%=rec_num%+1% &
    \	get #1, key #0 eq "|STUDENT_"+num1$(rec_num%) ! pick up that record &
    \	unlock #1%				! and unlock it &
    \	goto 1002 if seg$(roster_data$,1%,10%)<>"EMPTY_RECD"	! the record is not &
						! empty, go back for another &
    \	student_key$=num1$(rec_num%)		! save the record number &
    \	roster_data$="REGISTERXX"		! lock this one down &
    \	find #1, key #0 eq "|STUDENT_"+student_key$ &
    \	update #1, count 26% &
    \	goto 1010
1004	student_key$=num1$(rec_num%)		! there are no empty spots, so &
    \	student_number$=student_key$		! create a new one &
    \	roster_key$="|STUDENT_"+student_key$ &
    \	roster_data$="REGISTERXX"		! set the code name to a dummy &
    \	put #1, count 90%			! create the record &
    \	goto 1010
1006  !	&
      !	Something went wrong with the PUT in the last section.  This must mean &
      !	that there is no room to register them.  Tell them so. &
      !	&
    \	call plot("ZR110") &
    \	goto 1095				! abort
1010  !	&
      !	Get the students first name &
      !	&
    \	call plot("ZR111")
1015	response$=fn_getanswer$ &
    \	goto 1090 if result%=3% or result%=4%	! [EXIT or [QUIT &
    \	first$=left$(response$,20%)		! save the first name &
    \	if result%>2% or response$="" then	! if they entered nothing &
		call feedbk("Please enter your first name.") &
    \		goto 1015
1020  !	&
      !	Get the students last name &
      !	&
    \	call plot("ZR112")
1025	response$=fn_getanswer$ &
    \	goto 1090 if result%=3% or result%=4%	! [EXIT or [QUIT &
    \	last$=left$(response$,20%)		! save the last name &
    \	if result%>2% or response$="" then	! if they entered nothing &
		call feedbk("Please enter your last name.") &
    \		goto 1025
1030  !	&
      !	Find if the name has been used before &
      !	&
    \	full_name$=edit$(last$,128%)+", "+edit$(first$,128%) &
    \	s2%=0%
1032	s2%=s2%+1% &
    \	s1%=0%				! flag to get record number &
    \	s1$=num1$(s2%) &
    \	gosub 14800			! get this record &
    \	goto 1040 if s1%=3%		! quit looking if no records &
    \	if s1%=1% then			! if the name is there &
		if full_name$=cs_name$ then &
			call plot("ZR113") &
    \			response$=fn_getanswer$ &
    \			goto 1010
1035	goto 1032
1040  !	&
      !	Check to see if they got it right &
      !	&
    \	call plot("ZR114") &
    \	call feedbk("Your name has been recorded as "+edit$(first$,128%)+" "+edit$(last$,128%)) &
    \	call setloc("A",19%,28%,20%,28%) if terminal$="V52" or terminal$="VT1" &
    \	call setloc("A",343%,190%,343%,210%) if terminal$="VK1"
1045	response$=fn_getanswer$ &
    \	goto 1050 if left$(response$,1%)="Y"	! if they got it right &
    \	goto 1090 if result%=3% or result%=4%	! [EXIT or [QUIT &
    \	goto 1010 if left$(response$,1%)="N"	! ask again if they got it wrong &
    \	call feedbk("Please type Y or N.") &
    \	goto 1045
1050  !	&
      !	Get the students code name &
      !	&
    \	call plot("ZR115")
1055	call plot("ZR116") &
    \	result%=-32767%				! set flag for noecho &
    \	response$=fn_getanswer$ &
    \	goto 1090 if result%=3% or result%=4%	! [EXIT or [QUIT &
    \	code$=left$(response$,10%)		! save the code name &
    \	if result%>2% or response$="" then	! if they entered nothing &
		call feedbk("Please enter a code name.") &
    \		goto 1055
1060  !	&
      !	Check to see if the code has already been used &
      !	&
    \	s1$=code$ &
    \	s1%=1% &
    \	gosub 14800				! get the record with this code name &
    \	if s1%<>3% then				! if the code name was there &
		call plot("ZR117") &
    \		response$=fn_getanswer$ &
    \		goto 1055
1070  !	&
      !	Confirm the students code name &
      !	&
    \	call plot("ZR118")
1075	result%=-32767% &
    \	response$=fn_getanswer$ &
    \	goto 1090 if result%=3% or result%=4%	! [EXIT or [QUIT &
    \	if response$<>code$ then		! oops, they blew it &
		call plot("ZR119") &
    \		response$=fn_getanswer$ &
    \		goto 1055
1080  !	&
      !	Finally, all the information has been collected. &
      !	&
      !	Now place it in the MAP &
      !	&
    \	roster_key$="|STUDENT_"+student_key$ &
    \	temp$=code$+space$(10%-len(code$)) &
		   +seg$(date$(0%)+" "+time$(0%),1%,15%) &
		   +full_name$ &
    \	roster_data$=temp$ &
    \	find #1, key #0 eq roster_key$ &
    \	update #1, count 16%+len(temp$) &
      !	&
    \	call plot("ZR120") &
    \	response$=fn_getanswer$ &
    \	goto 1090 if result% > 2% &
    \	pass_key%=-5%				! signal success &
    \	subexit					! and leave
1090  !	&
      !	Here something went wrong, so print an error message &
      !	&
    \	print fn_print_error$ &
    \	print " Your registration is incomplete, and you will have to start over." &
    \	print " You may register again at a later time." &
    \	find #1, key #0 eq "|STUDENT_"+student_key$ &
    \	roster_data$="EMPTY_RECDEMPTY_RECORD   EMPTY_RECORD" &
    \	update #1, count 53%
1095  !	&
      !	Set the flag for an error &
      !	&
    \	pass_key%=0% &
    \	subexit
14800 !	&
      !	****	Subroutine to read student s1$'s records &
      !	&
      !	There are two possibilities:  Either a specific record is to be read, &
      !	or all of the records are to be searched for specific information. &
      !	S1%=0% indicates the first, and S1%<>0% indicates the second. &
      !	&
    \	if s1%=0% then &
		get #1%, key #0 eq "|STUDENT_"+s1$ &
    \		s1%=1%				! found it, set the flag &
    \		goto 14810
14802 !	&
      !	Otherwise search for the student with the code name = S1$ &
      !	&
    \	s1%=0%
14805	s1%=s1%+1% &
    \	get #1%, key #0 eq "|STUDENT_"+num1$(s1%) &
    \	goto 14805 if left$(roster_data$,10%)<>s1$ ! not found, try next one &
    \	s1%=1%					! signal success
14810	cs_code_name$=edit$(seg$(roster_data$,1%,10%),1%+4%+128%) &
    \	cs_start_date$=seg$(roster_data$,11%,25%) &
    \	cs_name$=edit$(seg$(roster_data$,26%,74%),1%+4%+128%) &
    \	unlock #1% &
    \	return
19000 !	&
      !	****	Error Routines &
      !	&
    \	IF ERL=14800 OR ERL=14805 THEN		! A problem getting a record &
		S1%=2% IF ERR=154%		! Code name locked &
    \		S1%=3% IF ERR=155%		! Code name not found &
    \		RESUME 14810
19010	IF ERL=1002 THEN			! Can't find an unused record &
		RESUME 1004 &
		ELSE IF ERL=1004 THEN		! Can't create new record &
			RESUME 1006 &
			ELSE IF ERL=1080 THEN	! Can't update the created record &
				RESUME 1090
19020	IF ERL=1090 THEN			! Error in restoring the file &
		RESUME 1095
19999 !	&
      !	****	Subroutine to handle all other errors &
      !	&
    \	print fn_print_error$ &
    \	print "There is a problem with this course.  Please contact your System Manager." &
    \	print "The problem is at line";erl;" and is ";ert$(err) &
    \	pass_key%=0% &
    \	resume 32000
32000 !	&
      !	****	Program Completion  &  Exit Routines &
      !
32767	subend
