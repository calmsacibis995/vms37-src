1	sub plot(form.spec.pass$)
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
      !	****	Version 1.0		10-May80		Original Code &
      !
100   !	&
      !	****	Program Description &
      !	&
      !	This program is the subroutine which will actually plot the forms &
      !	created using the DRAW program.  It will be called from any user &
      !	program with the form number to plot in the CALL statement.  It &
      !	will then set up the pointers to plot that form.  See the documentation &
      !	below for details of the actual plotting algorithm. &
      !	&
      !	The parameters in the call are as follows: &
      !	&
      !		form.spec$ - the form specification to plot. &
      !	&
      !	There are no error returns from this routine, since the only &
      !	type of error could be a "RECORD NOT FOUND" from the GET's at &
      !	lines 1010 and 1040, and this type of error is simply ignored. &
      !
300   !	&
      !	****	Files &
      !	&
      !		# 12	??????XXX.LIB	RMS Indexed Variable file which contains &
      !					the escape sequences to display, with the &
      !					form number as primary key (REC.VAL%). &
      !					The name is constructed as follows: &
      !						?????? - course name (EDTCAI, &
      !							 REGIS, DCLCAI, etc.) &
      !						XXX - terminal type (V52, VT1, VK1) &
      !
400   !	&
      !	****	Variable Directory &
      !
800   !	&
      !	****	Map, Common, and External Statements &
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
    \	dim plot%(5%), plot$(5%)		! array to hold push-down stack &
						! for the PLOT section (see the &
						! documentation at line 1040) &
      !	&
    \	external integer function sys$qiow
1000  !	&
      !	****	Setup values and pointers &
      !	&
    \	on error goto 19000			! standard error recovery &
      !	&
    \	form.spec$=edit$(form.spec.pass$,128%)	! pick up the parameter &
    \	form.spec$=form.spec$+space$(5%-len(form.spec$)) if len(form.spec$)<5% &
      !	&
      !	There is a special case of the form calling routine, based on whether &
      !	the initial character in the form specification is a plus or a minus &
      !	sign.  (If the first character is neither, then assume a plus sign.) &
      !	If the first character is not a minus, then plot the form.  If the &
      !	first character is a minus, then act as if the form has been plotted, &
      !	but do not place anything on the screen. &
      !	&
    \	form.spec$=right$(form.spec$,2%) if left$(form.spec$,1%)="+" &
    \	if left$(form.spec$,1%)="-" then &
		rec.num$=right$(form.spec$,2%) &
    \		subexit
1005  !	&
      !	Now set up to plot the form &
      !	&
    \	original.form.spec$=form.spec$ &
    \	print escape$+"Pp"; if terminal$="VK1"	! if this is a VK100, &
						! print the prefix to turn REGIS on &
    \	for p.temp%=0% to 5%			! zero out the stack pointer &
    \		plot%(p.temp%)=0% &
    \		plot$(p.temp%)="" &
    \	next p.temp% &
    \	response.length%=0%			! since a new form is being &
    \	feedbk.length%=0%			! presented, it is assumed that &
						! the old response and feedback &
						! are being erased, so zero the &
						! flags for their lengths &
    \	loc1$=""				! clear the two .AT commands &
    \	loc2$="" &
						! of a form
1010  !	&
      !	This routine will plot the form specified by form.spec$. &
      !	&
      !	This routine works as follows:  A form is picked up from the library file &
      !	which has been previously opened on channel 12.  It then checks this form &
      !	for the two special cases of forms: ANIMATE and PLOT, flagged by CHR$(23%) &
      !	and CHR$(20%) respectively.  If neither is present the entire record (form) &
      !	is displayed using SYS$QIOW and control is returned to the calling routine. &
      !	If ANIMATE is signalled then everything up to the ANIMATE is displayed &
      !	and control is handed to the ANIMATE sequence.  See line 1030 for more &
      !	details.  If PLOT is signalled then everything up to the PLOT is displayed &
      !	and control is handed to the PLOT sequence which recursively calls this &
      !	routine to display that form.  The pushdown parameter stack is kept in &
      !	the PLOT% array, with PLOT%(0%) being the stack pointer. &
      !	&
      !	So lets do it.  First check to make sure the nesting isn't too deep. &
      !	(Most of the checks in this routine are just for safety sake, since the &
      !	DRAW program should always produce error-free code, but just in case... &
      !	&
    \	return if plot%(0%)>4%			! don't allow too deep nesting &
    \	plot%(0%)=plot%(0%)+1%			! increment the stack pointer &
    \	plot.level%=plot%(0%)			! save it in a more distinctive &
						! name, which also saves array &
						! look-up time &
    \	get #12%, key #0 eq form.spec$		! get the form into memory &
    \	unlock #12%				! unlock the record &
    \	re.count%=pos(rec.val$,chr$(26%),1%)-1%	! get the length of the string &
    \	plot$(plot.level%)=left$(rec.val$,re.count%)	! save the form &
    \	plot%(plot.level%)=1%			! save the character position &
						! in the form being displayed
1020  !	&
      !	This is the main loop of this routine.  If either ANIMATE or PLOT are &
      !	flagged, this is where the routine comes back to to finish the display. &
      !	&
    \	p.temp%=pos(rec.val$,chr$(23%),plot%(plot.level%))	! find the ANIMATE flag &
    \	p.temp%=re.count%+1% if p.temp%<1%	! if there isn't one, pick up &
						! the entire line &
    \	p.temp1%=pos(rec.val$,chr$(20%),plot%(plot.level%))	! or the PLOT flag &
    \	p.temp1%=re.count%+1% if p.temp1%<1%	! if there isn't one, &
						! pick up the entire line &
    \	p.temp%=p.temp1% if p.temp1%<p.temp%	! get the first one found &
    \	p.temp1%=pos(rec.val$,chr$(19%),plot%(plot.level%))	! or the IVIS flag &
    \	p.temp1%=re.count%+1% if p.temp1%<1%	! if there isn't one, &
						! pick up the entire line &
    \	p.temp%=p.temp1% if p.temp1%<p.temp%	! get the first one found &
    \	p.temp$=seg$(rec.val$,plot%(plot.level%),p.temp%-1%) &
    \	for temp%=1% to 4096%/128%		! length of the buffer / size of each section &
    \		temp1%=128% &
    \		temp1%=len(p.temp$) if temp1%>len(p.temp$) &
    \		p.temp1%=sys$qiow(, channel% by value, io_writevblk% by value,,,, &
			p.temp$ by ref, temp1% by value,,,, 0% by value) &
    \		goto 19000 if (p.temp1% and 1%)=0% &
    \		p.temp$=seg$(p.temp$,129%,len(p.temp$)) &
    \	next temp% &
    \	plot%(plot.level%)=p.temp%+1%		! update the character pointer &
    \	goto 1050 if p.temp%>re.count%		! if no more to display, quit &
    \	p.temp$=seg$(rec.val$,p.temp%,p.temp%)	! pick up the flag character &
    \	goto 1030 if p.temp$=chr$(23%)		! go execute ANIMATE commands &
    \	goto 1040 if p.temp$=chr$(20%)		! go execute PLOT commands &
    \	goto 1045 if p.temp$=chr$(19%)		! go execute IVIS commands &
    \	goto 1020				! this should never happen.  If &
						! there is more to display then &
						! one of the flags MUST be present &
						! but just in case...
1030  !	&
      !	Routine to execute ANIMATE commands &
      !	&
      !	When the ANIMATE command is flagged (by the presence of CHR$(23%)), then &
      !	the following characters are expected: &
      !	&
      !		CHR$(23%)	- flag for ANIMATE &
      !		string		- string to print as first part of ANIMATE &
      !		CHR$(22%)	- delimiter flag for first string &
      !		string		- trace string to overwrite first string &
      !		CHR$(22%)	- delimiter flag for second string &
      !		CHR$(n%)	- repeat count for ANIMATE, ie, the number of &
      !				  times to ANIMATE the strings &
      !		string		- cursor position to print strings at &
      !		CHR$(22%)	- delimiter flag for cursor position &
      !		string		- next cursor position to print strings at &
      !		CHR$(22%)	- delimiter flag for cursor position &
      !		  . &
      !		  . &
      !		  . &
      !		string		- nth cursor position to print strings at &
      !		CHR$(22%)	- delimiter flag for cursor position &
      !	&
    \	p.temp%=pos(rec.val$,chr$(22%),plot%(plot.level%))	! find the first delimiter &
    \	goto 1020 if p.temp%<1%			! syntax error, so abort ANIMATE &
    \	plot.string1$=seg$(rec.val$,plot%(plot.level%),p.temp%-1%) &
						! get the first string to print &
    \	plot%(plot.level%)=p.temp%+1%		! update the character pointer &
    \	p.temp%=pos(rec.val$,chr$(22%),plot%(plot.level%))	! find the second delimiter &
    \	goto 1020 if p.temp%<1%			! syntax error, so abort ANIMATE &
    \	plot.string2$=seg$(rec.val$,plot%(plot.level%),p.temp%-1%) &
						! get the second string to print &
    \	plot%(plot.level%)=p.temp%+1%		! update the character pointer &
    \	p.temp2%=ascii(seg$(rec.val$,plot%(plot.level%),plot%(plot.level%))) &
						! get the repeat count &
    \	plot%(plot.level%)=plot%(plot.level%)+1%	! and set the character pointer &
						! past the repeat count &
    \	for p.temp%=1% to p.temp2%-1%		! do it the number of times specified &
    \		p.temp1%=pos(rec.val$,chr$(22%),plot%(plot.level%)) &
    \		goto 1020 if p.temp1%<1%	! if the delimiter was not found &
						! syntax error, so abort ANIMATE &
    \		p.temp1$=seg$(rec.val$,plot%(plot.level%),p.temp1%-1%) &
						! get the cursor position &
    \		p.temp$=p.temp1$+plot.string1$+p.temp1$+plot.string2$ &
						! assemble the string to print &
    \		plot%(plot.level%)=p.temp1%+1% ! update the character pointer &
    \		p.temp1%=len(p.temp$) &
    \		p.temp1%=sys$qiow(, channel% by value, io_writevblk% by value,,,, &
			p.temp$ by ref, p.temp1% by value,,,, 0% by value) &
						! write it (finally) &
    \		goto 19000 if (p.temp1% and 1%)=0% &
    \	next p.temp% &
    \	p.temp1%=pos(rec.val$,chr$(22%),plot%(plot.level%)) &
    \	goto 1020 if p.temp1%<1%		! if the delimiter was not found &
						! syntax error, so abort ANIMATE &
    \	p.temp1$=seg$(rec.val$,plot%(plot.level%),p.temp1%-1%) &
						! get the cursor position &
    \	plot%(plot.level%)=p.temp1%+1%		! update the character pointer &
    \	p.temp$=p.temp1$+plot.string1$		! place the string at the final position &
    \	p.temp1%=len(p.temp$) &
    \	p.temp1%=sys$qiow(, channel% by value, io_writevblk% by value,,,, &
		p.temp$ by ref, p.temp1% by value,,,, 0% by value) &
    \	goto 19000 if (p.temp1% and 1%)=0% &
    \	goto 1020				! ANIMATE finished, go back for more
1040  !	&
      !	Routine to execute PLOT &
      !	&
      !	This routine will execute the .PLOT command, which is effectively a &
      !	subroutine call to display another form.  This is done by recursively &
      !	calling this subroutine, and keeping the pushdown stack in the PLOT &
      !	array.  PLOT%(0%) (also known as PLOT.LEVEL%) is the stack pointer. &
      !	The form number to display is in the five characters following the &
      !	CHR$(20%) flag. &
      !	&
    \	form.spec$=seg$(rec.val$,plot%(plot.level%),plot%(plot.level%)+4%) &
    \	plot%(plot.level%)=plot%(plot.level%)+5%	! update the character &
						! pointer past the form number &
						! to be displayed &
    \	gosub 1010				! go display the form &
      !	&
      !	Now that the other form has been displayed, set all the pointers back to &
      !	the way they were before the call.  This includes getting the original &
      !	display back into the buffer. &
      !	&
    \	plot.level%=plot%(0%)			! reset the stack pointer &
    \	goto 1050 if plot.level%<1%		! this should never happen &
    \	rec.val$=plot$(plot.level%)		! reset the form &
    \	re.count%=len(plot$(plot.level%)) &
    \	goto 1020
1045  !	&
      !	Routine to execute IVIS commands &
      !	&
      !	IVIS commands are bracketed by CHR$(19%).  Pick up the text between &
      !	the CHR$(19%) at the current pointer location and the next one, and &
      !	then pass it to IVIS.  When the routine is finished, turn graphics &
      !	mode back on if this is a GIGI terminal, and go back for more. &
      !	&
    \	p.temp%=pos(rec.val$,chr$(19%),plot%(plot.level%)) &
						! find the ending character &
    \	p.temp%=plot%(plot.level%) if p.temp%<1% ! set for a null string if &
						! no delimiter is found.  This &
						! should never happen, but... &
    \	p.temp$=seg$(rec.val$,plot%(plot.level%),p.temp%-1%) &
						! pick up the text &
    !	call ivis(p.temp$) &
    \	plot%(plot.level%)=p.temp%+1%		! update the character pointer &
    \	print escape$+"Pp"; if terminal$="VK1"	! turn ReGIS back on &
    \	goto 1020
1050  !	&
      !	Exit routine &
      !	&
      !	This section goes back one level in the recursive calling of this routine. &
      !	&
    \	plot%(0%)=plot%(0%)-1%			! decrement the stack pointer &
    \	plot%(0%)=0% if plot%(0%)<1%		! don't allow it to drop below zero &
      !	&
      !	In any given form to plot, there should be two .AT commands at the very &
      !	end of the form.  These last two .AT commands are the location on the &
      !	screen to accept input from the student, and to print feedback to the &
      !	student.  These escape sequences are stored into the variables LOC1$ and &
      !	LOC2$.  So search for them and store them into the correct places.  First &
      !	set the values for the search.  TEMP% is the number of characters that &
      !	two .AT commands take, for each terminal type.  TEMP$ is the beginning &
      !	of the escape sequence for the .AT command, for each terminal type. &
      !	&
    \	temp%=8% &
    \	temp$=escape$+"Y" &
    \	goto 1055 if terminal$="V52"		! values for a VT52 &
    \	temp%=15% &
    \	temp$=escape$+"[" &
    \	goto 1055 if terminal$="VT1"		! values for a VT100 &
    \	temp%=19% &
    \	temp$="P["				! must be a VK100
1055  !	&
      !	Now pick up the last piece of the form, which may hold the last two .AT &
      !	commands.  The length of this piece is stored in TEMP%. &
      !	&
    \	temp1$=seg$(rec.val$,re.count%-temp%,re.count%) &
      !	&
      !	If there is a .PLOT command contained in the last piece of the form, &
      !	(where the two .AT commands are being searched for), then there is no room &
      !	for both .AT commands.  This almost certainly means that the two .ATs are &
      !	contained in the .PLOTted form.  In this case, do not search for the two &
      !	.AT commands in this form. &
      !	&
    \	goto 1060 if pos(temp1$,chr$(20%),1%)>0% &
      !	&
      !	So look for the two .AT commands. &
      !	&
    \	temp1%=pos(temp1$,temp$,1%)		! find the first one &
    \	temp2%=pos(temp1$,temp$,temp1%+1%)	! and the second one &
    \	goto 1060 if temp1%<1%			! if there aren't any escape &
						! sequences, just exit one level &
    \	loc1$=seg$(temp1$,temp1%,len(temp1$))	! pick up the first one &
    \	loc2$=loc1$				! if there is only one, default the &
						! second to the same as the first &
    \	goto 1060 if temp2%<1%			! if there is only one, then &
						! exit one level &
    \	loc1$=seg$(temp1$,temp1%,temp2%-1%)	! there is two of them, so pick &
    \	loc2$=seg$(temp1$,temp2%,len(temp1$))	! up both of them
1060  !	&
      !	Here it is time to exit from plotting this form.  There are two possibilities: &
      !	&
      !		1. This routine has been called by itself.  In this case, execute &
      !		   a RETURN to back up one level. &
      !		2. This routine is at the top of the stack.  In this case, execute &
      !		   a SUBEXIT to return to the calling routine. &
      !	&
    \	return if plot%(0%)>0% &
    \	rec.num$=original.form.spec$ &
    \	subexit
19000 !	&
      !	****	Universal error recovery routine &
      !	&
      !	The only type of error recovery is to back up one level of the call. &
      !	This is a resume to the exit routine at 1050. &
      !	&
    \	print escape$+"Y5 "+escape$+"J" if terminal$="V52" &
    \	print escape$+"[22;1H"+escape$+"[J" if terminal$="VT1" or terminal$="VK1" &
    \	print "The form '";form.spec$;"' is not in the display library, and therefore cannot be" &
    \	print "displayed.  Please contact your System Manager and report this problem."; &
    \	print escape$+"Pp"; if terminal$="VK1" &
    \	resume 1050
32000 !	&
      !	****	Exit routine &
      !
32767	subend
