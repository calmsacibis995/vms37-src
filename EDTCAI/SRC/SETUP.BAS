1	sub setup(function$,file$,error%)
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
      !	****	Version 1.0		10-May-80		Original Code &
      !
100   !	&
      !	****	Program Description &
      !	&
      !	This is the subprogram which will perform all of the operations &
      !	necessary to allow PLOT and GETANS to do their work.  These &
      !	operations include: &
      !	&
      !		1. Determining the terminal type &
      !		2. Setting up the SYS$QIOW buffers and channels for all &
      !		   terminal I/O. &
      !		3. Opening the correct RMS Indexed Variable file for this &
      !		   terminal type, which contains all of the compiled &
      !		   forms which the calling program might which to print. &
      !		4. Setting up the constants for the auxiliary keypad keys. &
      !		5. Reading the [GLOSSARY words into the common block. &
      !	&
      !	Also, this program acts as the exit routine for any programs using &
      !	PLOT.  These operations include: &
      !	&
      !		1. Closing the RMS file. &
      !		2. Resetting the terminal characteristics to the way they &
      !		   were at the beginning of the session. &
      !		3. Closing the SYS$QIOW buffers and channels. &
      !	&
      !	Which of these actions (setup or exit) is performed is dependent on the &
      !	parameters passed, as follows: &
      !	&
      !			FUNCTION$ - if = "SETUP" then setup all files and buffers &
      !				if = "EXIT" then shutdown all files and buffers &
      !			FILE$ -	The account and course name of the RMS file to be &
      !				opened.  The terminal type (also part of the file &
      !				name) is determined inside this program. &
      !			ERROR% - if = 1% then everything went fine &
      !				if <> 1% then something went wrong (file name was &
      !				bad, terminal type was off, something).  An error &
      !				message will be printed by this program, so all &
      !				the calling routine has to do is abort. &
      !
300   !	&
      !	****	Files &
      !	&
      !		#  2	MAIN.ACC$ + .DIC	List of the [GLOSSARY words &
      !		# 12	FILE$ + terminal + .DLB		RMS Indexed Variable &
      !					file containing all of the forms to be &
      !					displayed.  The file name is built using &
      !					the FILE$ parameter, plus the 3 letter &
      !					terminal type determined in this program. &
      !
400   !	&
      !	****	Variable Directory &
      !	&
      !
800   !	&
      !	****	Map, Common, and External Statements &
      !	&
    \	dim chn_buf%(2%) &
      ! &
    \	map (dsply)				! map statement for file 14, &
						! which holds the forms to display &
		rec.num$=5%,			! primary key, which is the form &
						! name to be displayed &
		rec.val$=4091%			! the actual escape sequence to &
						! display.  The reason that it &
						! 4091 characters in length is &
						! so that the total map is 4096 &
						! characters, or 8 disk blocks. &
      !	&
    \	common (glosry) main.acc$=32%,g%,g$(200%)=16% &
      !	&
    \	common (qiocom)				! common to hold QIO constants &
						! and values &
		channel%,			! channel number of the terminal &
						! file for QIO use &
		io_readvblk%,			! constant to hold value of &
						! pointer to io$_readvblk function &
						! of SYS$QIOW &
		io_writevblk%,			! pointer to IO$_WRITEVBLK% function &
						! of SYS$QIOW &
		chn_chr%(1%),			! array to hold original values &
						! of terminal characteristics, &
						! to be reset at the end of the &
						! session. &
		response.length%,		! the length of the last response &
						! entered by the student.  This &
						! is used to erase the response &
						! when the student enters a new one &
		feedbk.length%,			! the length of the last feedback &
						! message printed.  This is used &
						! to erase the feedback when the &
						! student enters a new response &
		escape$=1%,			! the escape character &
		terminal$=3%,			! this persons terminal type &
		loc1$=10%,			! the escape code of the next &
						! to the last .AT command.  This &
						! is where on the screen to accept &
						! input from the student &
		loc2$=10%,			! the escape code of the last &
						! .AT command.  This is where on &
						! the screen to print feedback &
		review$=1%,			! = "Y" if the student is reviewing &
						! = "N" if the student is not reviewing &
		objective$=5%,			! the objective form number &
		summary$=5%,			! the summary form number &
		modmap$=5%,			! the module map form number &
		keypad$(22%,1%)=10%		! translated names of the keypad keys &
      !	&
    \	external integer function sys$assign &
    \	external integer function sys$dassgn &
    \	external integer function sys$getmsg &
    \	external integer function sys$qiow &
    \	external integer function sys$trnlog &
    \	external integer dt$_vt52 &
    \	external integer dt$_vt100 &
    \	tt2$m_ansi% = 2%**24% &
    \	tt2$m_regis% = 2%**25% &
    \	external integer tt$m_wrap &
    \	external integer io$_readvblk &
    \	external integer io$_sensemode &
    \	external integer io$_setmode &
    \	external integer io$_writevblk &
    \	external integer io$m_escape &
    \	external integer io$m_noecho &
    \	external integer io$m_nofiltr &
    \	external integer io$m_noformat &
    \	external integer ss$_notran &
      !
1000  !	&
      !	****	Set up some constants and pointers &
      !	&
    \	on error goto 19000			! universal error routine &
    \	error%=0%				! assume failure &
      !	&
      !	****	Decide which operation was asked for &
      !	&
    \	goto 2000 if edit$(function$,32%)="EXIT"	! goto the exit routine &
						! if that was the operation requested &
    \	goto 32767 if edit$(function$,32%)<>"SETUP"	! if the parameter was not &
						! correct, exit this routine &
      !	&
      !	****	Subroutine to set up the terminal &
      !	&
      !	This program uses the SYS$QIOW function for most of its I/O.  To do &
      !	this, the device name must be gotten (using the SYS$TRNLOG function), &
      !	the channel must be assigned (using the SYS$ASSIGN function), and the &
      !	constants must be given values (using the external integer statements &
      !	at line 800).  Then the terminal type is determined. &
      !	&
      !	First set the constant for the escape character &
      !	&
    \	escape$=chr$(27%) &
      !	&
    \	temp$="SYS$COMMAND"			! start translating the device name
1010	x%=sys$trnlog(temp$,temp%,rec.val$,,,0% by value)	! get the device name &
    \	goto 19000 if (x% and 1%)=0%		! if the translate failed, quit &
    \	temp$=left$(rec.val$,temp%)		! pick up the device name &
    \	temp$=seg$(rec.val$,5%,temp%) if ascii(rec.val$)=27%	! if the first character &
						! of the device name is an escape &
						! character, the real device name &
						! starts in the 5th character &
    \	goto 1010 if x%<>loc(ss$_notran)	! if there is more to translate, go do it &
      ! &
    \	x%=sys$assign(temp$,channel%,,0% by value)	! assign the channel &
    \	goto 19000 if (x% and 1%)=0%		! if the assign failed, quit &
      !	&
      !	Now assign some values to the constants &
      !	&
    \	io_writevblk%=loc(io$_writevblk) or loc(io$m_noformat) or loc(io$m_escape) &
    \	io_readvblk%=loc(io$_readvblk) or loc(io$m_noecho) or loc(io$m_nofiltr) &
      !	&
      !	Now set the terminal characteristics.  The only one that really needs &
      !	setting is the wrap feature, which must be turned off, so that when &
      !	the cursor hits the end of the screen, it will not wrap to a new line. &
      !	The terminal characteristics will be saved in another array, so they &
      !	can be reset to their original values at the end of the session. &
      !	&
    \	temp%=loc(io$_sensemode) &
    \	x%=sys$qiow(, channel% by value, temp% by value,,,, &
		chn_buf%() by ref, 12% by value,,,, 0% by value) &
    \	goto 19000 if (x% and 1%)=0%		! if there was an error, abort &
      !	&
      !	Now save the values away, to reset them at the end of the session. &
      !	&
    \	chn_chr%(0%)=chn_buf%(0%) &
    \	chn_chr%(1%)=chn_buf%(1%) &
      !	&
      !	Find the terminal type from the channel characteristics buffer &
      !	&
    \	temp%=(chn_buf%(0%)/256%) and 255%	! pick up the terminal type &
						! parameter from the buffer &
    \	temp1%=chn_buf%(2%)			! pick up the extended attributes &
						! from the buffer &
    \	if temp%=loc(dt$_vt52) then terminal$="V52" &
	  else if temp%=loc(dt$_vt100) then terminal$="VT1" &
	    else if (temp1% and tt2$m_regis%)<>0% then terminal$="VK1" &
	      else if (temp1% and tt2$m_ansi%)<>0% then terminal$="VT1" &
		else terminal$="BAD" &
    \		     goto 19000
1015  !	&
      !	Now set the characteristics, using SETMODE. &
      !	&
    \	chn_buf%(1%)=chn_buf%(1%) and not(loc(tt$m_wrap)) &
    \	temp%=loc(io$_setmode) &
    \	x%=sys$qiow(, channel% by value, temp% by value,,,, &
		chn_buf%() by ref, 8% by value,,,, 0% by value) &
    \	goto 19000 if (x% and 1%)=0%		! if there was an error, abort
1020  !	&
      !	Now that the terminal type has been determined, and it is a type of &
      !	terminal that there is an associated library file for, open that file. &
      !	&
    \	temp$=edit$(file$,128%)+terminal$+".DLB" ! assemble the file name &
      !	&
    \	open temp$ for input as file 12%, &
		organization indexed variable, &
		recordsize 4096%, &
		map dsply, &
		primary key rec.num$, &
		access read, &
		allow modify
1030  !	&
      !	Now setup the names of the keypad keys for translation by GETANS. &
      !	&
    \	call keypad("CAI") &
      !	&
      !	And setup the initial terminal parameters &
      !	&
    \	if terminal$="V52" then			! setup the VT52 keypad &
		print escape$+"\"		! turn off hold screen mode &
			+escape$+">";		! exit alternate keypad mode &
    \		goto 1040			! all done, go to cleanup
1031	if terminal$="VT1" then			! setup the VT100 keypad &
		print escape$+"<"		! enter ANSI mode &
			+escape$+"[?7l"		! stop wraparound &
			+escape$+">";		! exit alternate keypad mode &
    \		goto 1040			! all done, go to clean up
1032	if terminal$="VK1" then			! setup the VK100 keypad &
		print escape$+"Pr"		! start affecting SETUPS &
			+"BA0XO1SM0RV0EM0OS0VC1SC0LE0AW0KR0KC1MB0TM1KP0CK0PK0UK0" &
			+escape$+"\" &
    \		goto 1040			! all done, go to clean up
1040  !	&
      !	Read in the [GLOSSARY words &
      !	&
    \	g%=-1%					! initialize the number of words in the file &
    \	f$=edit$(main.acc$,128%)+".DIC"		! file name for [GLOSSARY word &
    \	open f$ as file 2%, access read, allow read	! open the file
1042	linput #2, s1$				! read in a line of text &
    \	s1$=edit$(s1$,1%+4%+8%+16%+32%+128%)	! edit it &
    \	goto 1042 if seg$(s1$,1%,3%)<>"<W>"	! if this is not a keyword &
						! line, read another &
    \	g%=g%+1%				! increment the counter &
    \	goto 1045 if g%>200%			! don't go off the edge &
    \	g$(g%)=edit$(seg$(s1$,4%,len(s1$)),8%)	! store the keyword &
    \	goto 1042				! and go back for more
1045	close #2				! end-of-file, so close it
1050	loc1$=""				! clear all the pointers &
    \	loc2$=""				! and such &
    \	response.length%=0% &
    \	feedbk.length%=0% &
    \	error%=1%				! everything worked, so set no error &
    \	subexit					! and leave
2000  !	&
      !	****	Routine to clean up all buffers and files. &
      !	&
      !	This routine will reset the terminal characteristics to the way that &
      !	they were at the beginning of this session.  These characteristics were &
      !	saved in the common array CHN_CHR%, and changed using SYS$QIOW SETMODE, &
      !	so reset them that way. &
      !	&
    \	io_setmode%=loc(io$_setmode) &
    \	x%=sys$qiow(, channel% by value, io_setmode% by value,,,, &
		chn_chr%() by ref, 8% by value,,,, 0% by value) &
      !	&
      !	Now DEASSIGN the channel &
      !	&
    \	x%=sys$dassgn(channel% by value) &
      !	&
      !	and close the RMS file &
      !	&
    \	close # 12% &
      !	&
      !	If this is a VK100, it is necessary to turn REGIS off. &
      !	&
    \	print escape$+"\"+escape$+"PrSM2VC3KR1"+escape$+"\"; if terminal$="VK1" &
      !	&
      !	All done, so exit &
      !	&
    \	error%=1%				! everything worked, so set no error &
    \	subexit
19000 !	&
      !	****	Universal error recovery routine &
      !	&
    \	if erl=1040 or erl=1042 then		! error in opening or reading &
						! the [GLOSSARY file &
		resume 1045
19010 ! &
      !	There are several terminals which can handle both ReGIS graphics and &
      ! ANSI escape sequences.  In this case, make the check to see if the &
      !	library file exists for the graphics version first, figuring that it &
      !	looks better in graphics.  However, if this file does not exist, then &
      !	check to see if the display library for a VT100 exists. &
      ! &
    \	if erl=1020 and terminal$="VK1" then &
	  if (chn_buf%(2%) and tt2$m_ansi%)<>0% then &
	    terminal$="VT1" &
    \	    resume 1020
19100 !	&
      !	From here down, all errors are fatal, so make sure the screen can &
      !	scroll to display the error message, if this is a VK100 terminal. &
      !	&
    \	print escape$+"\"+escape$+"PrSM2VC3KR1"+escape$+"\"; if terminal$="VK1" &
      !	&
      !	And get the cursor to the bottom of the screen. &
      !	&
    \	print escape$+"[24;1H" if terminal$="VT1" or terminal$="VK1" &
    \	print escape$+"Y7 " if terminal$="V52" &
      !	&
    \	if (x% and 1%)=0% then			! some type of SYS$???? error &
		print				! so print the SYS$???? message &
    \		x%=sys$getmsg(x% by value, temp%, rec.val$,,0% by value) &
						! get the system message &
    \		print left$(rec.val$,temp%)	! and print it &
    \		resume 32767
19110	if terminal$="BAD" then			! illegal terminal type &
		print &
    \		print "This terminal cannot use this course.  Please check with your course" &
    \		print "administrator concerning which type of terminal you should use." &
    \		resume 32767
19120	if erl=1020 then			! some type of file access error. &
						! Either they didn't install the &
						! software right, or there is no &
						! file associated with this terminal &
						! type.  So complain. &
		print &
    \		print "The library for a "; &
    \		print "VT52"; if terminal$="V52" &
    \		print "VT100"; if terminal$="VT1" &
    \		print "VK100"; if terminal$="VK1" &
    \		print " terminal cannot be found which means that" &
    \		print "this terminal cannot use this course.  Please check with your course" &
    \		print "administrator concerning which type of terminal you should use." &
    \		resume 32767
19999 !	&
      !	I can't figure it out, so print the system message. &
      !	&
    \	print &
    \	print "Error number";err;"which is '";ert$(err);"'" &
    \	resume 32767
32767	subend
