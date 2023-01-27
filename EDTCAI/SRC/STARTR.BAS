1	sub startr(pass_file_spec$,unit_number%,error%)
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
      !	This program deals with the problem of leaving the instruction in this &
      !	course to execute a DCL command file and then to re-start at the exact &
      !	point where the student left.  This could be used (for example) to &
      !	call the EDT editor directly, instead of trying to simulate it, or to &
      !	allow a controlled execution of DCL commands, instead of trying to &
      !	simluate the actions/error messages/parsing/etc. of DCL. &
      !	&
      !	This program has two functions, as follows: &
      !	&
      !	If UNIT_NUMBER% < 0% then read the contents of the restart data file &
      !	and place these values into the common variables MODULE_NUMBER%, &
      !	OBJECTIVE_NUMBER%, and SECTION_NUMBER%.  The calling program then will &
      !	use these values to start the student at the point in the instruction &
      !	where they left off. &
      !	&
      !	If UNIT_NUMBER% >= 0% then write the restart data file with the values &
      !	in MODULE_NUMBER%, OBJECTIVE_NUMBER% and UNIT_NUMBER%, which sets the &
      !	location where the student will restart when they get back. &
      !	&
      !	The parameters are as follows: &
      !	&
      !		PASS_FILE_SPEC$ =   the DCL command (generally "@??????.COM") &
      !				    to execute upon exit from the router. &
      !		UNIT_NUMBER%  < 0%  read the data file.  This sets the values &
      !				    read into the common variables. &
      !			     >= 0%  the number to write as the SECTION_NUMBER% &
      !				    in the data file.  This is the place in &
      !				    the instructional program to restart later &
      !		ERROR%    = 0%      failure.  The file could not be found or &
      !				    written or read correctly. &
      !			    1%      success.  The file operation was carried &
      !				    out successfully. &
      !	&
      !	The restart file name is made up of some job parameter which is unique &
      !	across the operating system in which it runs.  On VAX/VMS, this is the &
      !	name of the terminal on which the process is running.  The restart &
      !	file contains the following information: &
      !	&
      !		STUDENT_KEY$ 	  = the student number (primary key) of the &
      !				    roster data base file. &
      !		MODULE_NUMBER%    = the module number in which to restart. &
      !		OBJECTIVE_NUMBER% = the objective number in which to restart. &
      !		UNIT_NUMBER%	  = the section number in which to restart. &
      !
300   !	&
      !	****	Files &
      !
400   !	&
      !	****	Variable Directory &
      !
800   !	&
      !	****	External, Map, and Common Statements &
      !	&
    \	common (pasfil)				! main common for parameters &
		pass_key%,			! pointer to current activity &
						! and to the results of it &
		module_number%,			! module number to take &
		objective_number%,		! objective number to take &
		section_number%,		! section number to take &
		t,				! time (seconds) spent in this activity &
		modlim%(10%),			! # of objectives in each module &
		max_student%,			! number of students in roster &
		map_length%,			! length (bytes) of the roster map &
		student_key$=3%			! student primary key in roster file &
      !	&
    \	common (glosry)				! the [GLOSSARY common block &
		glsry_acc$=32% &
      !	&
    \	external integer function sys$trnlog &
    \	external integer ss$_notran
1000  !	&
      !	****	Set up some constants and pointers &
      !	&
    \	on error goto 19000			! universal error routine &
    \	error%=0%				! assume failure &
      !	&
      !	****	Decide which operation was asked for &
      !	&
    \	goto 3000 if unit_number%>=0%
2000  !	&
      !	Here open and read the data file, so the student can re-start where &
      !	they were the last time they were on. &
      !	&
    \	gosub 10000				! get the file name &
    \	open file_name$ for input as file 2%	! open it &
    \	linput #2%, code_name$			! read the students code name &
    \	 input #2%, mod_number%			! and the module number &
    \	 input #2%, obj_number%			! and the objective number &
    \	 input #2%, sect_number%		! and the section number &
    \	close #2% &
    \	gosub 10100				! go delete the file &
      !	&
      !	Done.  It worked &
      !	&
    \	student_key$=code_name$			! stick the values into the &
    \	module_number%=mod_number%		! return locations which are &
    \	objective_number%=obj_number%		! common variables &
    \	section_number%=sect_number% &
    \	error%=1%				! signal success &
    \	subexit
3000  !	&
      !	****	Write the data file &
      !	&
    \	gosub 10000				! get the file name &
    \	gosub 10100				! kill all copies of the file &
    \	open file_name$ for output as file 2%	! open and &
    \	print #2%, student_key$			! write the file &
    \	print #2%, module_number% &
    \	print #2%, objective_number% &
    \	print #2%, unit_number% &
    \	close #2% &
      !	&
      !	Here the PASS_FILE_SPEC$ is placed into common.  The common variable &
      !	GLSRY_ACC$ was chosen because it was convenient and of the proper size &
      !	to take the full command line.  The current value if GLSRY_ACC$ (which &
      !	is the directory specification for the list of [GLOSSARY words) is &
      !	destroyed, but this is not considered a problem, since the image will &
      !	be destroyed upon execution of the DCL command, and the current value &
      !	of GLSRY_ACC$ will not be used for the rest of this run. &
      !	&
    \	glsry_acc$=pass_file_spec$ &
    \	pass_key%=5% &
      !	&
      !	Done. It worked &
      !	&
    \	error%=1%				! signal success &
    \	subexit
10000 !	&
      !	****	Subroutine to translate the logical name to get the physical &
      !		terminal name.  The terminal name can be counted on to be &
      !		completely unique across the entire system. &
      !	&
    \	temp$="SYS$INPUT" &
    \	temp1$=space$(128%)
10010	x%=sys$trnlog(temp$,temp%,temp1$,,,0% by value) &
						! get the device name &
    \	goto 19000 if (x% and 1%)=0%		! the translate failed, quit &
    \	temp$=left$(temp1$,temp%)		! pick up the device name &
    \	temp$=seg$(temp1$,5%,temp%) if ascii(temp1$)=27% &
						! if the first character of &
						! the device name is an escape &
						! character, the device name &
						! starts in the 5th character &
    \	goto 10010 if x%<>loc(ss$_notran)	! there is more to translate &
    \	temp$=right$(temp$,2%) while left$(temp$,1%)="_" &
    \	temp$=seg$(temp$,1%,4%)			! get rid of the funny chars &
						! in the terminal name &
    \	file_name$=temp$+".TMP"			! complete the file name &
    \	return
10100 !	&
      !	****	Subroutine to kill all versions of the file &
      !	&
    \	kill file_name$ &
    \	goto 10100
10110	return
19000 !	&
      !	****	Error routines &
      !	&
    \	if erl=2000 then			! error in opening / reading &
						! the restart file.  either &
		resume 32000			! way, just quit
19010	if erl=3000 then			! error in writing the file. &
		resume 32000			! again, just quit
19020	if erl=10100 then			! error in deleting the file. &
		resume 10110			! this is expected, so resume &
						! and return normally
19999 !	&
      !	Must be some other type of error.  In any case, just quit &
      !	&
    \	resume 32000
32000 !	&
      !	****	Exit routine &
      !	&
    \	error%=0%				! signal failure
32767	subend
