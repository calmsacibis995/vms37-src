1	sub feedbk(feedback$)
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
      !	This program will print the string specified as feedback to the student. &
      !	This string will be placed on the screen at the screen location specified &
      !	by the LOC2$ value, the escape sequence for the screen location to print &
      !	feedback. &
      !
300   !	&
      !	****	Files &
      !	&
      !
400   !	&
      !	****	Variable Directory &
      !
800   !	&
      !	****	Map, Common, and External Statements &
      !	&
    \	common (qiocom)				! common to hold QIO constants &
						! and values &
		channel%,			! channel number of the terminal &
						! file for QIO use &
		io_readvblk%,			! constant to hold value of &
						! pointer to IO$_READVBLK function &
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
    \	external integer function sys$qiow
1000  !	&
      !	Main routine &
      !	&
    \	x$=edit$(loc2$,128%)			! get the escape sequence to print &
						! the feedback at without trailing &
						! blanks &
    \	x$=x$+" " if len(x$)<4% and terminal$="V52" &
    \	x$=x$+" " if len(x$)<4% and terminal$="V52"	! on some of the VT52 &
						! escape sequences, a trailing &
						! blank is required &
    \	x1$=edit$(feedback$,128%)		! strip off the trailing blanks &
						! from the feedback, too &
    \	feedbk.length%=len(x1$)			! store the length of the feedback &
						! into the common variable, for later &
    \	x1$="T(W(R))'"+x1$+"'" if terminal$="VK1" ! VK100 terminals have a &
						! special format for printing &
    \	x$=x$+x1$				! append the feedback to the escape &
						! sequence &
    \	x%=len(x$)				! find the length of the string to print &
    \	x%=sys$qiow(, channel% by value, io_writevblk% by value,,,, &
		x$ by ref, x% by value,,,, 0% by value)		! write it out
32767	subend
