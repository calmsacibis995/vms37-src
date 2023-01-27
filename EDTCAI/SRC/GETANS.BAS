1	sub getans(answer.pass$,feedback.pass$,ntries.pass%,response.pass$,help.pass$,length.pass%,option%)
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
      !	This program is called to get a student response from the keyboard.  It &
      !	places the cursor at the correct screen position, gets the student response &
      !	one character at a time using SYS$QIOW, and assembles it into the variable &
      !	to be passed back to the calling routine.  It then compares the answer &
      !	given by the student to the desired answer supplied by the calling routine &
      !	and sets the flag variable according to whether or not the answer was matched, &
      !	or whether one of the special options was chosen.  Most of the special &
      !	options are handled internally to this routine, and the question is repeated &
      !	without bothering the calling routine about it.  Parameters are as follows &
      !	&
      !		ANSWER.PASS$	- the answer desired by the calling routine &
      !		FEEDBACK.PASS$	- the feedback presented to the student if the &
      !				  correct answer was not given.  If this is null &
      !				  (of length = 0) then the incorrect answer is simply &
      !				  passed back to the calling routine. &
      !		LENGTH.PASS%	- the maximum length of a students input.  This &
      !				  is used for wrapping of text before the edge &
      !				  of the screen.  This = -1% if there is no maximum. &
      !		HELP.PASS$	- the form number(s) of the help displays &
      !		RESPONSE.PASS$	- the edited form of the students input &
      !		OPTION%		- a number indicating a special option chosen by &
      !				  the student. &
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
    \	dim exercise_form$(20%,1%) &
      !	&
    \	map (dsply)				! map statement for file 12, &
						! which holds the forms to display &
		rec.num$=5%,			! primary key, which is the form &
						! number to be displayed &
		rec.val$=4091%			! the actual escape sequence to &
						! display.  The reason that it &
						! 4091 characters in length is &
						! so that the total map is 4096 &
						! characters, or 8 disk blocks. &
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
		objective$=5%,			! the objective form spec &
		summary$=5%,			! the summary form number &
		modmap$=5%,			! the module map form number &
		keypad$(22%,1%)=10%		! translated names of the keypad keys &
      !	&
    \	common (pasfil) a0%,m0%,o0%,o1% &
      !	&
    \	external integer function sys$qiow
900   !	&
      !	****	Begin Functions &
      !
905	def fn.getchar$ &
      !	&
      !	This routine will pick up one character from the keyboard using QIO. &
      !	&
    \	f.temp$="     "				! since the QIO function does &
						! not change the length of the &
						! string being read, make sure &
						! that the length of the buffer &
						! is greater than 0 &
    \	x%=sys$qiow(, channel% by value, io_readvblk% by value,,,, &
		f.temp$ by ref, 1% by value,,,, 0% by value) &
    \	fn.getchar$=edit$(seg$(f.temp$,1%,1%),1%) &
    \	fnend
910	def fn.write%(at%,f.string$) &
      !	&
      !	Type out the string on the screen at the location specified.  The first &
      !	parameter is a pointer to the escape sequence of the cursor location to &
      !	print the string at. &
      !	&
    \	f.temp$=""				! clear the escape sequence &
    \	f.temp$=at1$ if at%=1%			! if the pointer is 1, set the &
						! string to print at the first &
						! location. &
    \	f.temp$=at2$ if at%=2%			! if the pointer is 2, set the &
						! string to print at the second &
						! location. &
    \	f.string$="''" if f.string$="'"	and terminal$="VK1" &
    \	f.string$="T(W(R))'"+f.string$+"'" if terminal$="VK1"	! if the terminal is a &
						! VK100, the string needs to be &
						! in single quotes in replace mode &
    \	f.temp$=f.temp$+f.string$		! assemble the entire string to &
						! be printed &
    \	f.temp%=len(f.temp$)			! QIO needs to know the length &
    \	x%=sys$qiow(, channel% by value, io_writevblk% by value,,,, &
		f.temp$ by ref, f.temp% by value,,,, 0% by value) &
    \	fn.write%=0%				! there is no return value &
    \	fnend
915	def fn.analyze% &
      !	&
      !	This routine searches for legal abbreviations in each part of the &
      !	correct answer supplied by the calling program, within the response &
      !	entered by the student.  The two values used by this routine are &
      !	ANSWER$ and RESPONSE$.  The value returned by this routine is either &
      !	MATCH% (indicating a legal abbreviation of the answer was entered), or &
      !	NOMATCH% (indicating no legal abbreviation of the answer was entered). &
      !	Each word (defined by a space or slash or equal sign) is checked is a &
      !	separate entity. &
      !	&
      !	Example: &
      !	&
      !		ANSWER$ = "H*ELP DIR*ECTORY/TOTAL" &
      !	&
      !		Legal answers would be	H DIR/TOTAL &
      !					HELP DIRECT/TOTAL &
      !					HE DIRECTORY/TOTAL &
      !	&
      !	If a word has no * in it, an * is appended to the end before checking. &
      !	&
    \	a.next.char%=1%				! pointer to next character to &
						! analyze in ANSWER$ &
    \	r.next.char%=1%				! pointer to next character to &
						! analyze in RESPONSE$ &
    \	if len(answer$)<1% or len(response$)<1% then &
		fn.analyze%=nomatch%		! can't match what isn't there &
    \		fnexit
916   !	&
      !	First find the next word in ANSWER$ to check. &
      !	&
    \	f.temp%=pos(answer$," ",a.next.char%)	! find a space &
    \	f.temp%=len(answer$)+1% if f.temp%<1%	! set to the length of the string &
						! if no space was found &
    \	f.temp1%=pos(answer$,"/",a.next.char%)	! also find a slash &
    \	f.temp1%=len(answer$)+1% if f.temp1%<1%	! set to the length of the string &
						! if no slash was found &
    \	f.temp%=f.temp1% if f.temp1%<f.temp%	! use the first one encountered &
    \	f.temp1%=pos(answer$,"=",a.next.char%)	! also find an equal sign &
    \	f.temp1%=len(answer$)+1% if f.temp1%<1%	! set to the length of the string &
						! if no equal sign was found &
    \	f.temp%=f.temp1% if f.temp1%<f.temp%	! use the first one encountered &
    \	w.answer$=seg$(answer$,a.next.char%,f.temp%-1%)	! pick up this word &
    \	w.answer$=w.answer$+"*" if pos(w.answer$,"*",1%)<1%	! add an * if none is there &
    \	i%=pos(w.answer$,"*",1%)-1%		! find number of characters to match &
    \	a.next.char%=f.temp%+1%			! and update the word pointer &
    \	if pos(w.answer$,"_*",1%)>0% then	! handle literal * (_*) &
		f.temp%=pos(w.answer$,"_*",1%) &
    \		w.answer$=left$(w.answer$,f.temp%-1%)+right$(w.answer$,f.temp%+1%) &
						! first delete the literal character &
    \		w.answer$=w.answer$+"*" if pos(w.answer$,"*",f.temp%+1%)<1% &
    \		i%=pos(w.answer$,"*",f.temp%+1%)-1%
917   !	&
      !	Find the next word in RESPONSE$ to check. &
      !	&
    \	f.temp%=pos(response$," ",r.next.char%)	! find a space &
    \	f.temp%=len(response$)+1% if f.temp%<1%	! set to the length of the string &
						! if no space was found &
    \	f.temp1%=pos(response$,"/",r.next.char%)	! also find a slash &
    \	f.temp1%=len(response$)+1% if f.temp1%<1%	! set to the length of the string &
						! if no slash was found &
    \	f.temp%=f.temp1% if f.temp1%<f.temp%	! use the first one encountered &
    \	f.temp1%=pos(response$,"=",r.next.char%)  ! also find a equal sign &
    \	f.temp1%=len(response$)+1% if f.temp1%<1% ! set to the length of the string &
						! if no equal sign was found &
    \	f.temp%=f.temp1% if f.temp1%<f.temp%	! use the first one encountered &
    \	w.response$=seg$(response$,r.next.char%,f.temp%-1%)	! pick up this word &
    \	r.next.char%=f.temp%+1%			! and update the word pointer &
      !	&
      !	Now check to see if the words match &
      !	&
    \	if pos("["+w.answer$,"["+left$(w.response$,i%)+"*",1%)<>1% then &
		fn.analyze%=nomatch%		! phooey. no match &
    \		fnexit				! so quit
918   !	&
      !	Now that a match has been found, check the rest of the word. &
      !	&
    \	for j%=i%+2% to len(w.answer$)+1% &
    \		f.temp$=seg$(w.response$,j%-1%,j%-1%) &
    \		goto 920 if f.temp$="" &
    \		f.temp1$=seg$(w.answer$,j%,j%) &
    \		if f.temp1$<>f.temp$ then &
			fn.analyze%=nomatch% &
    \			fnexit
919	next j% &
    \	goto 921
920   !	&
      !	At last.  The keyword is good.  Fill out the rest of the keyword, and &
      !	go search for the next one. &
      !	&
    \	response$=left$(response$,r.next.char%-2%) &
		+right$(w.answer$,j%) &
		+right$(response$,r.next.char%-1%) &
    \	r.next.char%=r.next.char%+len(w.answer$)-len(w.response$)-1%	! find the new length
921	goto 916 if a.next.char%<=len(answer$) and r.next.char%<=len(response$) &
    \	fn.analyze%=match% &
    \	fn.analyze%=nomatch% if a.next.char%<=len(answer$) or r.next.char%<=len(response$) &
						! if either there is more to &
						! parse in the response, or &
						! more to check in the answer, &
						! they did not get it right, &
						! so mark it wrong &
    \	fnend
1000  !	&
      !	****	Main routine &
      !	&
      !	Set up the constants, and initialize the passed and common parameters &
      !	&
    \	on error goto 19000 &
    \	x%=ctrlc				! turn off ^C &
      !	&
    \	at1$=edit$(loc1$,128%)			! strip off trailing blanks from &
						! the escape sequence &
    \	at1$=at1$+" " if len(at1$)<4% and terminal$="V52"	! add a blank on &
						! the end of the VT52 escape sequence &
						! if necessary &
    \	at2$=edit$(loc2$,128%)			! do it again from the other &
						! escape sequence &
    \	at2$=at2$+" " if len(at2$)<4% and terminal$="V52" &
      !	&
    \	answer$=edit$(answer.pass$,1%+32%+128%+256%)	! edit the desired answer &
    \	feedback$=edit$(feedback.pass$,1%+4%+128%)	! and the feedback &
    \	ntries%=ntries.pass%			! get the number of tries allowed &
    \	help$=edit$(help.pass$,1%+4%+32%+128%)	! and the list of helps &
    \	help$="+ZA100" if help$=""		! supply the default if no HELP specified &
    \	char.limit%=length.pass%		! get the character length limit &
    \	char.limit%=32767% if char.limit%<1% &
      !	&
    \	show.key$="ON"				! turn echoing of the characters on &
    \	show.key$="OFF" if option%=-32767%	! the calling program can request &
						! that the characters not be echoed &
						! to the screen by passing the value &
						! -32767 to this program &
    \	single.char$="OFF"			! assume no single character input &
    \	practicing.keypad$="OFF" &
    \	single.char$="ON" if option%=-32766%	! the calling program can also request &
						! that only a single character be &
						! returned by passing the value &
						! -32766 to this program &
    \	keypad$="="				! character to turn on the keypad &
    \	keypad$=">" if option%=-32765%		! but if NOKEYPAD is specified... &
    \	edit.spec%=1%+4%+16%+32%+256%		! constant for EDIT$ function &
    \	edit.spec%=edit.spec%-4% if option%=-32766% &
    \	edit.spec%=edit.spec%+2% if option%=-32764%	! or if NOSPACES is specified... &
    \	edit.spec%=edit.spec%-32% if option%=-32763% or option%=-32762% &
						! or if NOCAPS is specified... &
    \	do.form$="" &
    \	do.form$=rec.num$ if option%=-32762%	! if DO_FORM is specified... &
      !	&
      !	Set up the OPTION% constants &
      !	&
    \	match%=1%				! answer matched &
    \	nomatch%=2%				! answer not matched &
    \	exit%=3%				! [EXIT chosen &
    \	quit%=4%				! [QUIT chosen &
    \	back%=5%				! [BACK chosen &
    \	review%=6%				! [REVIEW chosen &
    \	next%=7%				! [NEXT chosen &
    \	help%=8%				! [HELP Menu chosen &
      !	&
      !	Set up the array necessary for the [KEYPAD routine &
      !	&
    \	exercise_form$(0%,0%)="ZK00" &
    \	exercise_form$(1%,0%)="ZK01" \ exercise_form$(1%,1%)="ZK21" &
    \	exercise_form$(2%,0%)="ZK02" \ exercise_form$(2%,1%)="ZK22" &
    \	exercise_form$(3%,0%)="ZK03" \ exercise_form$(3%,1%)="ZK23" &
    \	exercise_form$(4%,0%)="ZK04" \ exercise_form$(4%,1%)="ZK24" &
    \	exercise_form$(5%,0%)="ZK05" \ exercise_form$(5%,1%)="ZK25" &
    \	exercise_form$(6%,0%)="ZK06" \ exercise_form$(6%,1%)="ZK26" &
    \	exercise_form$(7%,0%)="ZK07" \ exercise_form$(7%,1%)="ZK27" &
    \	exercise_form$(8%,0%)="ZK08" \ exercise_form$(8%,1%)="ZK28" &
    \	exercise_form$(9%,0%)="ZK09" \ exercise_form$(9%,1%)="ZK29" &
    \	exercise_form$(10%,0%)="ZK10" \ exercise_form$(10%,1%)="ZK30" &
    \	exercise_form$(11%,0%)="ZK11" \ exercise_form$(11%,1%)="ZK31" &
    \	exercise_form$(12%,0%)="ZK12" \ exercise_form$(12%,1%)="ZK32" &
    \	exercise_form$(13%,0%)="ZK13" \ exercise_form$(13%,1%)="ZK33" &
    \	exercise_form$(14%,0%)="ZK14" \ exercise_form$(14%,1%)="ZK34" &
    \	exercise_form$(15%,0%)="ZK15" \ exercise_form$(15%,1%)="ZK35" &
    \	exercise_form$(16%,0%)="ZK16" \ exercise_form$(16%,1%)="ZK36" &
    \	exercise_form$(17%,0%)="ZK17" \ exercise_form$(17%,1%)="ZK37" &
    \	exercise_form$(18%,0%)="ZK18" \ exercise_form$(18%,1%)="ZK38" &
    \	exercise_form$(19%,0%)="ZK19" \ exercise_form$(19%,1%)="ZK39" &
    \	exercise_form$(20%,0%)="ZK20" \ exercise_form$(20%,1%)="ZK40" &
      !	&
      !	Set up the erase-to-end-of-screen string for [GLSRY and [COMMNT &
      !	&
    \	ees$="" &
    \	ees$=escape$+"Y"+chr$(31%+22%)+chr$(31%+1%)+escape$+"J" if terminal$="V52" &
    \	ees$=escape$+"[22;1H"+escape$+"[0J" if terminal$="VT1" &
    \	ees$="P[0,420]W(S' ')V[0,511][767,511]W(S0)" if terminal$="VK1" &
      !	&
      !	Build the displayable answer for [WHAT and the LF key &
      !	Since the ANSWER$ is full of parsing characters (such as * and _*) it &
      !	is really not in a form to be displayed to the student, so build an &
      !	answer that can be shown to them. &
      !	&
    \	display.answer$="" &
    \	temp1$="" &
    \	for i%=1% to len(answer$) &
    \		temp$=seg$(answer$,i%,i%) &
    \		display.answer$=display.answer$+temp$ if &
			not (temp$="_" or (temp$="*" and temp1$<>"_")) &
    \		temp1$=temp$ &
    \	next i% &
      !	&
    \	num.tries%=0%				! set the current number of &
						! tries at this question to 0
1100  !	&
      !	Get the first character typed by the student &
      !	&
    \	print escape$+keypad$;			! turn on/off the keypad &
    \	print escape$+"H"; if terminal$="V52"	! print the necessary escape &
    \	print escape$+"[H"; if terminal$="VT1"	! sequence to place the cursor &
    \	print escape$+"\"+escape$+"[H"; if terminal$="VK1"	! at the home &
    \	print					! position and then print a &
						! CR/LF to reset the *%@# pointer &
						! which automatically prints a &
						! hard return after the 80th &
						! character. &
    \	print escape$+"Pp"; if terminal$="VK1"	! turn REGIS back on &
    \	response$=""				! clear the string to accept the response &
    \	print at1$;				! then get the cursor at &
						! the correct position to &
						! accept student input &
    \	r$=fn.getchar$				! get a single character &
    \	if do.form$<>"" then &
		temp$=rec.num$ &
    \		call plot(temp$) &
    \		at1$=edit$(loc1$,128%) &
    \		at1$=at1$+" " if len(at1$)<4% and terminal$="V52" &
    \		at2$=edit$(loc2$,128%) &
    \		at2$=at2$+" " if len(at2$)<4% and terminal$="V52" &
		else &
		s1%=response.length%		! find the minimum of the &
    \		s1%=char.limit% if response.length%>char.limit%	! response.length% &
						! and char.limit% &
    \		x%=fn.write%(1%,space$(s1%))	! erase previous response &
    \		x%=fn.write%(2%,space$(feedbk.length%))	! & previous feedback
1110	print at1$;				! and reset the cursor &
    \	response.length%=0%			! once the erase is taken care &
    \	feedbk.length%=0%			! of, zero the length of the &
						! response and feedback string &
    \	gosub 11010				! go analyze the character
2000  !	&
      !	****	Analyze the answer typed by the student &
      !	&
    \	response$=edit$(response$,edit.spec%) &
    \	response.length%=len(response$) if show.key$="ON" &
						! save length of response &
    \	if response$=answer$ then		! this is to save having to parse &
						! it, if they entered it perfectly &
		option%=match% &
    \		goto 32000
2005  !	&
      !	Oops, no exact match, so analyze their answer. &
      !	&
    \	option%=fn.analyze%			! check the response for the correct answer &
    \	goto 32000 if option%=match%		! if the answer matched, leave &
    \	goto 3000 if len(response$)<1%		! if they entered nothing, &
						! print the feedback message &
    \	up.shift$=edit$(response$,32%)		! just in case
2010	if pos("[WHAT",up.shift$,1%)=1% then	! [WHAT, display answer &
		x%=fn.write%(2%,"The answer is : "+display.answer$) &
    \		feedbk.length%=16%+len(display.answer$)	! save the length of &
						! the string just printed &
    \		goto 1100			! and go back for more
2020	if pos("[BACK",up.shift$,1%)=1% then	! [BACK, back up one level &
		option%=back%			! set the flag &
    \		goto 32000			! and leave
2030	if pos("[COMMENT",up.shift$,1%)=1% then	! [COMMENT, write a comment &
		gosub 10000			! go to the proper routine &
    \		goto 4000			! and go back for more
2040	if pos("[EXIT",up.shift$,1%)=1% then	! [EXIT, leave the course &
		option%=exit%			! set the flag &
    \		goto 32000			! and leave
2050	if pos("[ID",up.shift$,1%)=1% then	! [ID, display the form number &
		temp$="The form is "+rec.num$+" in Module "+num1$(m0%)+", Objective " &
    \		temp%=o0% &
    \		temp%=-16% if o0%<1% &
    \		temp$=temp$+chr$(temp%+64%)+"."+num1$(o1%) &
    \		x%=fn.write%(2%,temp$)		! write the string &
    \		feedbk.length%=len(temp$)	! save the length of the string &
						! just printed &
    \		goto 1100			! and go back for more
2060	if pos("[GLOSSARY",up.shift$,1%)=1% then ! [GLOSSARY, look up a word &
		gosub 10100			! go to the proper routine &
    \		goto 4000			! and go back for more
2070	if pos("[ADVICE",up.shift$,1%)=1% then	! [ADVICE, get some help &
		gosub 10200			! go to the proper routine &
    \		if f.temp%>0% then 4000		! and go back for more &
			      else 4005
2080	if pos("[KEYPAD",up.shift$,1%)=1% then	! [KEYPAD key diagram &
		gosub 10300			! go to the proper routine &
    \		goto 32000			! and leave
2090	if pos("[HELP",up.shift$,1%)=1% then	! [HELP &
		option%=help%			! set the flag &
    \		goto 32000			! and leave
2100	if pos("[FORWARD",up.shift$,1%)=1% then	! [FORWARD a subobjective &
		option%=next%			! set the flag &
    \		goto 32000			! and leave
2110	if pos("[OBJECTIVE",up.shift$,1%)=1% then ! [OBJECTIVE, display the objectives &
		gosub 10500			! go to the proper routine &
    \		goto 4000			! and go back for more
2120	if pos("[PLOT",up.shift$,1%)=1% then	! [PLOT, replot the current form &
		gosub 10600			! go to the proper routine &
    \		goto 1100
2130	if pos("[QUIT",up.shift$,1%)=1% then	! [QUIT, get out RIGHT NOW! &
		option%=quit%			! set the flag &
    \		goto 32000			! and leave
2140	if pos("[REVIEW",up.shift$,1%)=1% then	! [REVIEW, review material &
		option%=review%			! set the flag &
    \		goto 32000			! and leave
2150	if pos("[SUMMARY",up.shift$,1%)=1% then	! [SUMMARY form &
		gosub 10700			! go to the proper routine &
    \		goto 32000			! and leave
2160	if pos("[VIEW",up.shift$,1%)=1% then	! [VIEW, display debugging values &
		gosub 10800			! go to the proper routine &
    \		goto 1100			! and go back for more
2170	if pos("[MAP",up.shift$,1%)=1% then	! Objective Map &
		gosub 10400			! go to the proper routine &
    \		goto 32000			! and leave
2180	rem Turn off the keyword checks for now &
      !	&
      !	Here start checking for some of the words which can take some special &
      !	meanings, such as HELP, EXIT, QUIT, BYE, GOODBYE, etc. &
      !	&
    \	if up.shift$<>"" and &
	   pos("|QUIT|HELP|EXIT|BYE|GOODBYE|LO|LOGOUT|LOGOFF","|"+up.shift$,1%)>0% then &
		gosub 10900 &
    \		call plot("ZA100") &
    \		gosub 10950 &
    \		goto 1100
2190  !	&
      !	Many of the keys on the keypad are not used.  These are marked with &
      !	the special flag <NO KEY>.  Check for this, and ignore those keys if &
      !	they are pressed. &
      !	&
    \	if up.shift$="<NO KEY>" then &
		goto 1100
3000  !	&
      !	Here the correct answer was not matched, and it was not any special &
      !	option.  Therefore, either print the feedback and try again (if feedback &
      !	was specified), or set the flag to NOMATCH and quit. &
      !	&
    \	num.tries%=num.tries%+1%		! increment the incorrect tries counter &
    \	if len(feedback$)>0% then		! if feedback was specified, &
		temp$=feedback$			! set the default feedback &
    \		temp$="No.  Please try again." if num.tries% = 1% &
    \		temp$="Please type "+display.answer$ if num.tries% > ntries% &
    \		x%=fn.write%(2%,temp$)		! print it &
    \		feedbk.length%=len(temp$)	! save the length for later &
    \		goto 1100			! and go back for more
3010  !	&
      !	Here there was no feedback specified.  Check one more thing: whether the &
      !	student just pressed RETURN when an answer was requested. &
      !	&
    \	if len(answer$)>0% and len(up.shift$)<1% then	! oops, thats what happened &
		x%=fn.write%(2%,"Please enter an answer.") &
    \		feedbk.length%=23%		! print an error message and save &
						! its length &
    \		goto 1100			! and go back for more
3020  !	&
      !	Here they entered an incorrect answer.  Set the flag and exit. &
      !	&
    \	option%=nomatch% &
    \	goto 32000
4000  !	&
      !	****	Section to decide on replotting the screen &
      !	&
      !	This section is called after any function which erases the bottom 3 &
      !	lines of the screen.  Based on the value of the character preceding &
      !	the ADVICE frame specification, (either - or +) either the last form &
      !	is replotted and the bottom three lines are erased (for +) or the &
      !	Press <RETURN> to Continue form (ZZ100) is plotted.  In either case &
      !	if the student presses <RETURN> then more input is requested (ie, goto &
      !	1100), otherwise the input which they entered is treated as their &
      !	response to the original question (ie, goto 2000). &
      !	&
    \	response$="" &
    \	print escape$+keypad$; &
    \	print at1$; &
    \	gosub 11000
4005	temp$=seg$(help$,len(help$)-5%,len(help$)) &
    \	goto 4010 if pos(temp$,"+",1%)>0% &
    \	goto 2000 if left$(response$,1%)="[" &
    \	gosub 10900 &
    \	call plot("ZZ100") &
    \	gosub 10950 &
    \	goto 4020
4010	goto 2000 if len(response$)>0% &
    \	print ees$; &
    \	gosub 10600 &
    \	goto 4020
4020	response.length%=0%			! don't erase the original response &
						! since it was probably erased already &
    \	goto 1100 &

10000 !	&
      !	****	Subroutine to handle [COMMENT &
      !	&
    \	print ees$+escape$+">";			! turn off the keypad &
    \	call commnt &
    \	return
10100 !	&
      !	****	Subroutine for [GLOSSARY &
      !	&
    \	print ees$+escape$+">";			! turn off the keypad &
    \	call glsry &
    \	return
10200 !	&
      !	****	Subroutine for [ADVICE &
      !	&
    \	gosub 10900				! save the old information &
    \	f.temp%=1%				! set flag to start at beginning
10210	temp1$=seg$(help$,f.temp%,f.temp%)	! pick up the replot flag &
    \	temp$=seg$(help$,f.temp%+1%,f.temp%+5%)	! pick up the form number &
    \	f.temp%=f.temp%+6%			! update the pointer &
    \	call plot(temp$)			! display the form &
    \	if f.temp%<len(help$) then		! if there is more advice &
		response$="" &
    \		print at1$; &
    \		gosub 11000			! wait for a response &
    \		goto 10210 if response$<>"" and &
			      pos("[ADVICE",edit$(response$,32%),1%)<>1% &
    \		f.temp%=-1%
10220	gosub 10950 &
    \	return
10300 !	&
      !	****	Subroutine for [KEYPAD &
      !	&
    \	key_ptr$=edit$(keypad$(0%,0%),128%) &
    \	save.key%=0% &
    \	option%=review% &
    \	goto 10335
10310	if response$="<NO KEY>" then &
		temp$="That key has no function here." &
    \		x%=fn.write%(2%,temp$) &
    \		feedbk.length%=len(temp$) &
    \		goto 10340
10320	for temp%=1% to 22% &
    \		goto 10330 if response$=keypad$(temp%,0%) &
    \	next temp% &
    \	temp$="Please press a keypad key, or <RETURN> to continue. " &
    \	x%=fn.write%(2%,temp$) &
    \	feedbk.length%=len(temp$) &
    \	goto 10340
10330	save.key%=temp%-4%			! skip the arrow keys &
    \	save.key%=19% if save.key%<1%
10335	temp$=exercise_form$(save.key%,0%) &
    \	temp$=left$(temp$,2%)+key_ptr$+right$(temp$,3%) &
    \	call plot(temp$) &
    \	at1$=edit$(loc1$,128%) &
    \	at1$=at1$+" " if len(at1$)<4% and terminal$="V52" &
    \	at2$=edit$(loc2$,128%) &
    \	at2$=at2$+" " if len(at2$)<4% and terminal$="V52"
10340	practicing.keypad$="ON" &
    \	single.char$="ON" &
    \	response$="" &
    \	print at1$; &
    \	gosub 11000 &
    \	print at2$+space$(feedbk.length%)+at1$; &
    \	practicing.keypad$="OFF" &
    \	single.char$="OFF" &
    \	return if response$="" &
    \	temp$=exercise_form$(save.key%,1%) &
    \	temp$=left$(temp$,2%)+key_ptr$+right$(temp$,3%) &
    \	call plot(temp$) if temp$<>key_ptr$ &
    \	goto 10310
10400 !	&
      !	****	Subroutine for [MAP (Objective Map) &
      !	&
    \	temp$=edit$(modmap$,128%)		! get the form number to plot &
    \	call plot(temp$) &
    \	gosub 11000 &
    \	option%=review% &
    \	return
10500 !	&
      !	****	Subroutine for [OBJECTIVE &
      !	&
    \	gosub 10900				! save the old information &
    \	temp$=edit$(objective$,128%)		! get the form number to plot &
    \	call plot(temp$) &
    \	gosub 10950				! restore the old information &
    \	return
10600 !	&
      !	****	Subroutine for [PLOT &
      !	&
    \	temp$=rec.num$				! get the form number to plot &
    \	call plot(temp$)			! and plot the form &
    \	return
10700 !	&
      !	****	Subroutine for [SUMMARY &
      !	&
    \	temp$=edit$(summary$,128%)		! get the form number to plot &
    \	call plot(temp$) &
    \	gosub 11000 &
    \	option%=next% &
    \	return
10800 !	&
      !	****	Subroutine for [VIEW (show debugging information) &
      !	&
    \	temp$="Loc1$=!"+right$(at1$,2%)+"!, Loc2$=!"+right$(at2$,2%) &
		+"!, Advice="+help$+", Answer="+answer$ &
    \	x%=fn.write%(2%,temp$) &
    \	feedbk.length%=len(temp$) &
    \	return
10900 !	&
      !	****	Subroutine to save old form name, and the two .AT locations &
      !	&
    \	old.form$=rec.num$ &
    \	old.at1$=at1$ &
    \	old.at2$=at2$ &
    \	return
10950 !	&
      !	****	Subroutine to restore the old form name, and the two .AT locations &
      !	&
    \	rec.num$=old.form$ &
    \	at1$=old.at1$ &
    \	at2$=old.at2$ &
    \	loc1$=old.at1$ &
    \	loc2$=old.at2$ &
    \	return
11000 !	&
      !	****	Subroutine to get a single line of input from the keyboard &
      !	&
    \	r$=fn.getchar$				! get a single character
11010 !	&
      !	Analyze the character just entered &
      !	&
    \	if ascii(r$)>31% and ascii(r$)<127% then ! if its a printable character &
		response$=response$+r$		! append it to the response &
      !	&
      !	There is a special case of the printable characters, which consists of &
      !	the PF1 key (translated to "*GOLD") followed by an alphabetic key.  This &
      !	is to be treated as [ + key, and is to be executed immediately, without &
      !	the student having to press RETURN.  Also, if single character input has &
      !	been requested (SINGLE.CHAR$="ON"), then also execute it immediately. &
      !	&
    \		temp%=0%			! set the flag to assume it is &
						! not a *GOLD alphabetic key &
    \		r1$=edit$(r$,32%)		! get the upshifted form &
    \		temp%=1% if response$="*GOLD"+r$ and r1$>="A" and r1$<="Z" &
						! set the flag if it is *GOLD alphabetic key &
    \		r$=r$+chr$(8%) if len(response$)>=char.limit% &
    \		x%=fn.write%(0%,r$) if show.key$="ON" and temp%=0% &
						! display the character if echo &
						! is on and if it is not *GOLD alphabetic &
    \		goto 11080 if temp%=0%		! continue if it is not *GOLD alphabetic &
    \		response$="["+r$		! convert *GOLD alphabetic key &
						! into [ alphabetic key &
    \		return				! and go process it
11015 !	&
      !	Handle TAB key &
      !	&
    \	if ascii(r$)=9% then			! its a TAB &
		r$=space$(8%-(len(response$)-int(len(response$)/8%)*8%)) &
						! replace a tab with spaces &
    \		temp$=r$ &
    \		temp%=char.limit%-len(response$) &
    \		temp%=1% if temp% < 1% &
    \		temp$=seg$(r$,1%,temp%)+chr$(8%) if len(response$+r$)>char.limit% &
    \		response$=response$+r$		! add it into the response &
    \		x%=fn.write%(0%,temp$) if show.key$="ON" ! write it out &
    \		goto 11080
11020 !	&
      !	If the student is reviewing material which they have already gone through, &
      !	it is not necessary for them to answer all the questions.  In this case, &
      !	allow the student to press the LF key, and have that treated as the correct &
      !	answer.  The answer will then be printed to the screen as if they entered &
      !	it, and all flags will be set correctly. &
      !	&
    \	if ascii(r$)=10% and review$="Y" then &
		response$=display.answer$	! consider it matched &
    \		option%=match%			! set the flag &
    \		x%=fn.write%(1%,display.answer$) if show.key$="ON" ! print the &
						! answer if echo is on &
    \		return				! and leave
11025 !	&
      !	Check to see if is a CONTROL-C or CONTROL-Y &
      !	&
    \	if ascii(r$)=3% or ascii(r$)=25% then	! it is &
		response$="[EXIT"		! turn these into [EXITs &
    \		return				! all done
11030 !	&
      !	Check to see if its a CR/LF &
      !	&
    \	if ascii(r$)=13% then &
		return				! all done
11040 !	&
      !	Check to see if its a CONTROL-U &
      !	&
    \	if ascii(r$)=21% then			! it is, simulate the function &
		temp%=len(response$) &
    \		temp%=char.limit% if temp%>char.limit% &
    \		x%=fn.write%(1%,space$(temp%))	! clear the line &
    \		x%=fn.write%(1%,"")		! and reset the cursor &
    \		response$=""			! clear the response &
    \		goto 11080
11045 !	&
      !	Check to see if its a CONTROL-W &
      !	&
    \	if ascii(r$)=23% then			! it is, set up for replotting &
		response$="[PLOT"		! the screen (like all screen &
    \		return				! editors do)
11050 !	&
      !	Check to see if its a CONTROL-Z &
      !	&
     \	if ascii(r$)=26% then			! it is, append the end of file flag &
		response$="<EOF>" &
    \		return				! all done
11060 !	&
      !	Check to see if its an ESCAPE sequence (from the keypad) &
      !	&
    \	if ascii(r$)=27% then			! it is, pick up the first character &
		r$=fn.getchar$			! of the rest of the sequence &
    \		r$=fn.getchar$ if pos("?[O",r$,1%)>0%	! if one of the leading &
						! characters was present, skip it &
    \		which.key%=pos("ABCDpqrstuvwxymlnMPQRS",r$,1%)	! find the key &
    \		goto 11080 if which.key%<1%	! if an illegal escape sequence &
						! ignore it &
    \		temp%=0%			! decide which table to look at &
    \		temp%=1% if response$="*GOLD"	! if they pressed *GOLD, look at &
						! the GOLD function table &
    \		response$=edit$(keypad$(which.key%,temp%),128%) &
						! place the translated name of &
						! the key into the response &
    \		goto 11080 if which.key%=19%	! if the GOLD (PF1) key was pressed &
						! go back for more &
    \		return				! otherwise go process it
11070 !	&
      !	Check to see if its a DELETE &
      !	&
    \	if ascii(r$)=127% then			! it is, so simulate it &
		if response$="*GOLD" then response$=""	! but not if its a *GOLD key &
		else &
		temp$=chr$(8%)+" "+chr$(8%) &
    \		temp$=" "+chr$(8%) if len(response$)=char.limit% &
    \		temp$=seg$(response$,len(response$)-1%,len(response$)-1%)+chr$(8%) if len(response$)>char.limit% &
    \		x%=fn.write%(0%,temp$) if len(response$)>0% and show.key$="ON" &
						! if theres anything typed so &
						! far, erase it on the screen &
						! but only if ECHO is turned on &
    \		if len(response$)<2% then response$=""	! if there is only one &
						! character in the response, clear it &
			else response$=seg$(response$,1%,len(response$)-1%) &
						! otherwise, just remove the &
						! last character in the response
11080 !	&
      !	At this point, either it fell through from the previous line, or a &
      !	character was entered which fit none of the above checks.  In either &
      !	case, just go back and try again. &
      !	&
    \	if single.char$="ON" then		! handle single character mode &
		response$=r$ if response$=""	! if it was a funny character, &
						! save it anyway (single char &
						! mode returns anything) &
    \		return if response$<>"*GOLD" or practicing.keypad$="ON"
11085	goto 11000
19000 !	&
      !	*****	Error recovery routine &
      !	&
    \	if err=28 then				! its a ^C &
		response$="[EXIT"		! translate the ^C &
    \		resume 2000			! and resume at the main routine
19090	resume 32767
32000 !	&
      !	****	Exit routine &
      !	&
    \	response.pass$=response$
32767	subend
