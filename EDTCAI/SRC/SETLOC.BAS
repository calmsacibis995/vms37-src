1	sub setloc(option$,lx1%,cx1%,lx2%,cx2%)
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
      !	****	Version 1.0		5-May-80		Original Code &
      !
100   !	&
      !	****	Program Description &
      !	&
      !	This program will enable the calling routine to edit the values of the &
      !	the two escape sequences which set the screen locations for all terminal &
      !	I/O performed in the routine GETANS.  The parameters are as follows: &
      !	&
      !		OPTION$	- "R" to Relocate the current cursor positions by incrementing &
      !			  them by the amounts in the other parameters. &
      !			  "A" to set the cursor positions to the Absolute positions &
      !			  defined in the other parameters. &
      !		LX1%,CX1% - either the increments or the values of the cursor position &
      !			  to accept input from the student, depending on the value &
      !			  of OPTION$. &
      !		LX2%,CX2% - either the increments or the values of the cursor position &
      !			  to print feedback to the student, depending on the value &
      !			  of OPTION$. &
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
      !
1000  !	&
      !	Main routine &
      !	&
    \	on error goto 19000			! set up the error routine &
    \	l1%=lx1%				! copy the passed values &
    \	c1%=cx1% &
    \	l2%=lx2% &
    \	c2%=cx2% &
    \	goto 2000 if edit$(option$,32%)="R"	! relocate the current sequence by &
						! incrementing the current value &
						! with the parameters &
    \	goto 3000 if edit$(option$,32%)="A"	! take the parameters as absolute &
						! values, and set the current &
						! sequence to them &
    \	subexit					! if its not one of those, quit
2000  !	&
      !	Relocate the current sequence by the parameters &
      !	&
    \	goto 2100 if terminal$="V52" &
    \	goto 2200 if terminal$="VT1" &
    \	goto 2300 if terminal$="VK1" &
    \	subexit					! if its not one of the above, quit
2100  !	&
      !	Disassemble the escape sequences for a VT52 &
      !	&
    \	temp%=ascii(seg$(loc1$,3%,3%))-31%	! the row number &
    \	temp1%=ascii(seg$(loc1$,4%,4%))-31%	! the column number &
    \	l1%=l1%+temp%				! increment them &
    \	c1%=c1%+temp1% &
    \	temp%=ascii(seg$(loc2$,3%,3%))-31%	! the row number &
    \	temp1%=ascii(seg$(loc2$,4%,4%))-31%	! the column number &
    \	l2%=l2%+temp%				! increment them &
    \	c2%=c2%+temp1% &
    \	goto 3000				! and reset the escape sequences
2200  !	&
      !	Disassemble the escape sequences for a VT100 &
      !	&
    \	x%=pos(loc1$,";",1%)			! find the first delimiter &
    \	goto 2250 if x%<1%			! if not there, try the other one &
    \	y%=pos(loc1$,"H",x%+1)			! find the second delimiter &
    \	goto 2250 if y%<1%			! if not there, try the other one &
    \	temp%=val(seg$(loc1$,3%,x%-1%))		! pick up the line value &
    \	temp1%=val(seg$(loc1$,x%+1%,y%-1%))	! pick up the column value &
    \	l1%=l1%+temp%				! increment them &
    \	c1%=c1%+temp1%
2250  !	&
      !	Try the second escape sequence &
      !	&
    \	x%=pos(loc2$,";",1%)			! find the first delimiter &
    \	goto 3000 if x%<1%			! if not there, quit &
    \	y%=pos(loc2$,"H",x%+1%)			! find the second delimiter &
    \	goto 3000 if y%<1%			! if not there, try the other one &
    \	temp%=val(seg$(loc2$,3%,x%-1%))		! pick up the line value &
    \	temp1%=val(seg$(loc2$,x%+1%,y%-1%))	! pick up the column value &
    \	l2%=l2%+temp%				! increment them &
    \	c2%=c2%+temp1% &
    \	goto 3000
2300  !	&
      !	Disassemble the escape sequence for the VK100 &
      !	&
    \	x%=pos(loc1$,",",1%)			! find the first delimiter &
    \	goto 2350 if x%<1%			! if not there, try the other one &
    \	y%=pos(loc1$,"]",x%+1%)			! find the second delimiter &
    \	goto 2350 if y%<1%			! if not there, try the other one &
    \	temp%=val(seg$(loc1$,3%,x%-1%))		! pick up the line value &
    \	temp1%=val(seg$(loc1$,x%+1%,y%-1%))	! pick up the column value &
    \	l1%=l1%+temp%				! increment them &
    \	c1%=c1%+temp1%
2350  !	&
      !	Try the second escape sequence &
      !	&
    \	x%=pos(loc2$,",",1%)			! find the first delimiter &
    \	goto 3000 if x%<1%			! if not there, try the other one &
    \	y%=pos(loc2$,"]",x%+1%)			! find the second delimiter &
    \	goto 3000 if y%<1%			! if not there, try the other one &
    \	temp%=val(seg$(loc2$,3%,x%-1%))		! pick up the line value &
    \	temp1%=val(seg$(loc2$,x%+1%,y%-1%))	! pick up the column value &
    \	l2%=l2%+temp%				! increment them &
    \	c2%=c2%+temp1% &
    \	goto 3000
3000  !	&
      !	Set the escape sequence to the values specified (or computed) &
      !	&
    \	goto 3100 if terminal$="V52" &
    \	goto 3200 if terminal$="VT1" &
    \	goto 3300 if terminal$="VK1" &
    \	subexit
3100  !	&
      !	Assemble the escape sequence for a VT52 &
      !	&
    \	l1%=1% if l1%<0%			! make sure the values are in range &
    \	l1%=24% if l1%>24% &
    \	c1%=1% if c1%<0% &
    \	c1%=80% if c1%>80% &
    \	loc1$=escape$+"Y"+chr$(l1%+31%)+chr$(c1%+31%) if l1%>0% and c1%>0% &
    \	l2%=1% if l2%<0%			! make sure the values are in range &
    \	l2%=24% if l2%>24% &
    \	c2%=1% if c2%<0% &
    \	c2%=80% if c2%>80% &
    \	loc2$=escape$+"Y"+chr$(l2%+31%)+chr$(c2%+31%) if l2%>0% and c2%>0% &
    \	subexit
3200  !	&
      !	Assemble the escape sequence for a VT100 &
      !	&
    \	l1%=1% if l1%<0%			! make sure the values are in range &
    \	l1%=24% if l1%>24% &
    \	c1%=1% if c1%<0% &
    \	c1%=80% if c1%>80% &
    \	loc1$=escape$+"["+num1$(l1%)+";"+num1$(c1%)+"H" if l1%>0% and c1%>0% &
    \	l2%=1% if l2%<0%			! make sure the values are in range &
    \	l2%=24% if l2%>24% &
    \	c2%=1% if c2%<0% &
    \	c2%=80% if c2%>80% &
    \	loc2$=escape$+"["+num1$(l2%)+";"+num1$(c2%)+"H" if l2%>0% and c2%>0% &
    \	subexit
3300  !	&
      !	Assemble the escape sequence for a VK100 &
      !	&
    \	l1%=1% if l1%<0%			! make sure the values are in range &
    \	l1%=767% if l1%>767% &
    \	c1%=1% if c1%<0% &
    \	c1%=479% if c1%>479% &
    \	loc1$="P["+num1$(l1%)+","+num1$(c1%)+"]" if l1%>0% and c1%>0% &
    \	l2%=1% if l2%<0%			! make sure the values are in range &
    \	l2%=767% if l2%>767% &
    \	c2%=1% if c2%<0% &
    \	c2%=479% if c2%>479% &
    \	loc2$="P["+num1$(l2%)+","+num1$(c2%)+"]" if l2%>0% and c2%>0% &
    \	subexit
19000 !	&
      !	Error recovery routine &
      !	&
      !	The only error that this routine can generate is a VAL function error. &
      !	If this happens, simply return without resetting anything. &
      !	&
    \	resume 32767
32767	subend
