1     !	********************************************************************** &
      !	&
      !	&
      !		C B I   A D M I N I S T R A T I O N   P R O G R A M &
      !	&
      !	&
    \	ON ERROR GOTO 19000 &
      !	&
      !	&
      !		VERSION:	2.0 &
      !	&
      !		EDIT LEVEL:	1.0 &
      !	&
      !		AUTHOR(S):	Ken Moreau &
      !	&
      !	&
      !	**********************************************************************
11    !	********************************************************************** &
      !	&
      !	&
      !				C O P Y R I G H T &
      !	&
      !	&
      !		(C) Copyright 1981 &
      !		Digital Equipment Corporation, Maynard, Massachusetts &
      !	&
      !		This software is furnished under a license for use only &
      !		on a single computer system and may be copied only with &
      !		the  inclusion  of  the  above  copyright notice.  This &
      !		software, or  any  other copies therof, may not be pro- &
      !		vided or  otherwise  made available to any other person &
      !		except for use on such  system and to one who agrees to &
      !		these license terms.  Title  to  and  ownership  of the &
      !		software shall at all times remain in DIGITAL. &
      !	&
      !		The information  in  this software is subject to change &
      !		without notice and should not be construed as a commit- &
      !		ment by Digital Equipment Corporation. &
      !	&
      !		DIGITAL assumes no responsibility for the use or relia- &
      !		bility of its software on equipment that is not sup- &
      !		plied by DIGITAL. &
      !	&
      !	**********************************************************************
20    !	********************************************************************** &
      !	&
      !	&
      !		M O D I F I C A T I O N   H I S T O R Y   L O G &
      !	&
      !	&
      !		VER/ED	DATE	INITIAL	 REASON &
      !		-------	-----	---------------------------------------------- &
      !		1.0	17-Nov-81 KNM	First version of combined roster file &
      !	&
      !	&
      !	**********************************************************************
100   !	********************************************************************** &
      !	&
      !	&
      !		P R O G R A M   D E S C R I P T I O N &
      !	&
      !	This program is the general administration program for all of the &
      !	Computer Based Instructional (CBI) courses on a system.  It allows the &
      !	system manager to administer the data base for the students. &
      !	&
      !	Functions allowed are: &
      !	&
      !		Display the comments file - which displays all of the comments &
      !				entered by the students in a course &
      !		Display a courses data    - which displays all of the courses &
      !				data, which includes number of modules and &
      !				number of lessons in each module &
      !		Display a students status - which displays on the screen the &
      !				status of a particular student in a course &
      !		Edit a courses data	  - which allows the entry, removal, &
      !				or editing of a courses record &
      !		Edit a students data	  - which allows the entry, removal, &
      !				or editing of a students record &
      !	&
      !	**********************************************************************
300   !	********************************************************************** &
      !	&
      !	&
      !		C H A N N E L   A S S I G N M E N T S &
      !	&
      !	&
      !		CHANNEL		ASSIGNMENT &
      !		--------	---------------------------------------------- &
      !		2		Main data base file &
      !		3		Comment file &
      !		4		Data file for course information &
      !		5		Output file for all listings &
      !	&
      !	&
      !	**********************************************************************
400   !	********************************************************************** &
      !	&
      !	&
      !		L O C A L   V A R I A B L E S   A N D   A R R A Y S   U S E D &
      !	&
      !	&
      !		NAME		DESCRIPTION &
      !		-----		---------------------------------------------- &
      !		COURSE_NAME$	List of the names of the courses in the data &
      !				base, both the short (cf. CC_KEY$) and long &
      !				(cf. CC_NAME$) forms. &
      !		COURSE_DATA%	The number of modules and lessons in each of &
      !				the courses in the data base. &
      !		STUDENT_NAME$	The list of the first and last names of all of &
      !				the students in the data base. &
      !		CC_KEY$		Current Course Key, used for accessing the &
      !				data base.  1-8 bytes.  Ex: VMS &
      !		CC_NAME$	Current Course Name, used for titles. &
      !				1-40 bytes.  Ex: The VMS Primer &
      !		CC_DATA%	Current Course Data, which holds the number of &
      !				modules and lessons in the course. &
      !		CS_NAME$	Current Student Name.  1-50 bytes.  In the &
      !				form: Last_name, First_name &
      !		CS_NUMBER$	Current Student Number, used for accessing the &
      !				data base.  1-5 bytes.  Ex: 123 &
      !		CS_CODE_NAME$	Current Student Codename.  1-10 bytes. &
      !		CS_OBJ_TIME%	Current Student Objective Time.  The amount of &
      !				time (seconds) spent in each objective by the &
      !				student.  Dimensioned to 50. &
      !		CS_MODULE_STATUS%	Current Student Module Status.  The &
      !				flags for completion of each lesson in an &
      !				objective.  Dimensioned to 50. &
      !		CS_TEST_STATUS%	Current Student Test Status.  The flags for &
      !				status of the tests for each objective. &
      !				Dimensioned to 50. &
      !		RETURN_VALUE%	Returned value from functions. &
      !	&
      !
450   !	&
      !	&
      !		E X T E R N A L   V A R I A B L E S   A N D   A R R A Y S &
      !	&
      !	&
      !		NAME		DESCRIPTION &
      !		-----		---------------------------------------------- &
      !	&
    \	external integer function lib$get_input &
      !	&
      !	**********************************************************************
500   !	********************************************************************** &
      !	&
      !	&
      !		E X T E R N A L   S U B S   A N D   F U N C T I O N S &
      !	&
      !	&
      !		NAME		DESCRIPTION &
      !		-----		---------------------------------------------- &
      !	&
      !	&
      !	**********************************************************************
700   !	********************************************************************** &
      !	&
      !	&
      !			S U B R O U T I N E S   U S E D &
      !	&
      !	&
      !		NAME/LINE	DESCRIPTION &
      !		----------	---------------------------------------------- &
      !	&
      !	&
      !	**********************************************************************
750   !	********************************************************************** &
      !	&
      !	&
      !			F U N C T I O N S   U S E D &
      !	&
      !	&
      !		NAME/LINE	DESCRIPTION &
      !		----------	---------------------------------------------- &
      !	&
      !	&
      !	**********************************************************************
800   !	********************************************************************** &
      !	&
      !	&
      !		L O C A L   C O M M O N   D E C L A R A T I O N S &
      !	&
      !	&
      !		NAME		DESCRIPTION &
      !		-----		---------------------------------------------- &
      !		STUDNT		Map for the data base. &
      !	&
      !	&
    \	map (studnt) &
		roster_key$=16%, &
		roster_data$=496% &
      !	&
      !	The structure of this MAP is variable, since there are three different &
      !	types of records, all of which are differentiated by software.  They &
      !	are as follows: &
      !	&
      !		1. Course records. &
      !			ROSTER_KEY$  =	"|COURSE_"+course_name$. &
      !			ROSTER_DATA$ =	Byte 1 - Various flag bits.  See &
      !						 CC_ROUTER_FLAGS% for details. &
      !					Byte 2 - Number of modules. &
      !					Byte 3 thru ?? - Number of lessons in &
      !							 each module. &
      !					The rest of the record contains the &
      !					course name and directory for the data &
      !					files, separated by "\". &
      !		2. Student main records. &
      !			ROSTER_KEY$  =	"|STUDENT_"+student_number%. &
      !			ROSTER_DATA$ =	Byte 1 thru 10 - Code name. &
      !					Byte 11 thru 25 - Start date. &
      !					Byte 26 thru 74 - Last, First name. &
      !		3. Student course records.  This record contains numeric data &
      !		   in alpha format, which the functions FN_GET_MAP_VAR and &
      !		   FN_PUT_MAP_VAR convert in both directions. &
      !			ROSTER_KEY$  =	course_name$+"_"+student_number%. &
      !			CS_LOG_ON%   =  Number of times entering this course. &
      !			CS_OBJ_TIME% =  Time spent in each objective. &
      !			CS_MODULE_STATUS% = Status in each lesson for each &
      !					module.  This is a 1-bit array. &
      !			CS_TEST_STATUS% = Status for the tests in each module. &
      !
850   !	&
      !	&
      !		L I B R A R Y   C O M M O N   D E C L A R A T I O N S &
      !	&
      !	&
      !		NAME		DESCRIPTION &
      !		-----		---------------------------------------------- &
      !	&
      !	&
      !	**********************************************************************
900   !	********************************************************************** &
      !	&
      !	&
      !		L O C A L   D I M E N S I O N   D E C L A R A T I O N S &
      !	&
      !	&
      !		NAME		DESCRIPTION &
      !		-----		---------------------------------------------- &
      !	&
      !	&
    \	dim course_name$(200%,2%) &
    \	dim course_data%(200%,50%) &
    \	dim student_name$(500%) &
    \	dim student_number%(500%) &
    \	dim cc_data%(50%) &
    \	dim cs_obj_time%(50%) &
    \	dim cs_module_status%(50%) &
    \	dim cs_test_status%(50%) &
    \	dim name_list%(25%) &
      !
950   !	&
      !	&
      !		L I B R A R Y   D I M E N S I O N   D E C L A R A T I O N S &
      !	&
      !	&
      !		NAME		DESCRIPTION &
      !		-----		---------------------------------------------- &
      !	&
      !	&
      !	********************************************************************** &

1000  !	********************************************************************** &
      !	&
      !	&
      !			M A I N   P R O G R A M   L O G I C &
      !	&
      !	&
    \	temp%=ctrlc				! Enable CTRL/C trapping &
    \	STS$K_FAILURE% = 0% &
    \	STS$K_SUCCESS% = 1% &
    \	MAX_OBJECTIVES%= 50% &
    \	KEYWORD_LIST$ = CHR$(1%) +"|ADD"+ &
			CHR$(3%) +"|MODIFY"+ &
			CHR$(5%) +"|REMOVE"+ &
			CHR$(7%) +"|SHOW"+ &
			CHR$(10%)+"|LIST"+ &
			CHR$(13%)+"|HELP"+ &
			CHR$(14%)+"|EXIT"+ &
			CHR$(14%)+"|QUIT" &
      !	&
      !	********************************************************************** &
      !	&
      !	Open the data base file, and build the local records for this session &
      !	&
    \	open "SYS$INSTRUCTION:ROSTER.DAT" as file 2%, &
		organization indexed variable, &
		map studnt, &
		primary key roster_key$, &
		access modify, &
		allow modify
1010  !	&
      !	Now build the local records for this session.  These local records &
      !	are built once at the beginning of the session, which saves a great &
      !	deal of access time later on. &
      !	&
      !	First build the records of the courses. &
      !	&
    \	number_of_courses%=0% &
    \	get #2, key #0 ge "|COURSE_"
1015	return_value%=fn_read_course% &
    \	goto 1020 if return_value%<>STS$K_SUCCESS% &
    \	number_of_courses%=number_of_courses%+1% &
    \	course_name$(number_of_courses%,0%)=cc_key$ &
    \	course_name$(number_of_courses%,1%)=cc_name$ &
    \	course_name$(number_of_courses%,2%)=cc_directory$ &
    \	course_data%(number_of_courses%,i%)=cc_data%(i%) &
		for i%=0% to max_objectives% &
    \	course_data%(number_of_courses%,cc_data%(0%)+1%)=cc_router_flags% &
    \	get #2 &
    \	goto 1015 if seg$(roster_key$,1%,8%)="|COURSE_"
1020  !	&
      !	Now build the records for the students in the courses. &
      !	&
    \	number_of_students%=0%
1025	student_number%(number_of_students%+1%)=number_of_students%+1% &
    \	return_value%=fn_read_student_hdr%(number_of_students%+1%) &
    \	goto 1030 if return_value%<>STS$K_SUCCESS% &
    \	number_of_students%=number_of_students%+1% &
    \	student_name$(number_of_students%)=cs_name$ &
    \	student_name$(number_of_students%)="ZZZEMPTY_RECORD" &
		   if cs_name$="EMPTY_RECORD" &
		   or edit$(cs_name$,128%)="" &
		   or cs_code_name$="REGISTERXX" &
    \	goto 1025
1030  !	&
      !	Now that all of the students are read in, lets sort them. &
      !	&
    \	for temp%=1% to number_of_students%-1% &
    \		for temp1%=temp%+1% to number_of_students% &
    \			if student_name$(temp%)>student_name$(temp1%) then &
				temp$=student_name$(temp%) &
    \				student_name$(temp%)=student_name$(temp1%) &
    \				student_name$(temp1%)=temp$ &
    \				temp2%=student_number%(temp%) &
    \				student_number%(temp%)=student_number%(temp1%) &
    \				student_number%(temp1%)=temp2%
1035		next temp1% &
    \	next temp%
1100  !	&
      !	Begin the main loop of the program. &
      !	&
    \	response$=fn_get_input$("ADMIN>") &
    \	on fn_parse_command%(response$)+1% goto &
		1110,				! Syntax error, report error &
		2000,				! Add a new course &
		2500,				! Add a new student &
		3000,				! Modify an existing course &
		3500,				! Modify an existing student &
		4000,				! Remove an existing course &
		4500,				! Remove an existing student &
		5000,				! List comments to the screen &
		6000,				! List course information to &
						! the screen &
		7000,				! List student status to the &
						! screen &
		5500,				! Print comments to a file &
		6500,				! Print course information to &
						! a file for printing &
		7500,				! Print student status to a &
						! file for printing &
		9000,				! Display help text &
		32000,				! Exit the program &
		1100				! Repeat query
1110  !	&
      !	Report syntax error &
      !	&
    \	print "Syntax error, type HELP for help." &
    \	goto 1100 &

2000  !	&
      !	Add a new course to the data base. &
      !	&
    \	if next_word$="" then &
		next_word$=fn_get_input$("Course information file >") &
    \		goto 1100 if next_word$="EXIT" &
    \		goto 2000
2010	file_name$=next_word$ &
    \	close #5% &
    \	open file_name$ for input as file 5%, &
		organization sequential variable, &
		access read, &
		defaultname ".DAT"
2020	linput #5, cc_key$ &
    \	cc_key$=edit$(cc_key$,32%)		! Make sure its uppercase &
    \	linput #5, cc_name$ &
    \	linput #5, cc_directory$ &
    \	cc_directory$=edit$(cc_directory$,32%)	! Make sure its uppercase &
    \	temp$=seg$(cc_directory$,len(cc_directory$),len(cc_directory$)) &
    \	cc_directory$=cc_directory$+":" if temp$<>"]" and temp$<>":" &
    \	linput #5, temp$ &
    \	cc_router_flags%=1% &
    \	cc_router_flags%=0% if edit$(temp$,1%+4%+8%+16%+32%+128%)="REGISTRATION OFF" &
    \	 input #5, cc_data%(0%) &
    \	cc_data%(i%)=0% for i%=1% to max_objectives% &
    \	 input #5, cc_data%(i%) for i%=1% to cc_data%(0%) &
    \	temp$="Updated" &
    \	temp%=fn_find_course%(cc_key$) &
    \	if temp%=0% then &
		number_of_courses%=number_of_courses%+1% &
    \		temp%=number_of_courses% &
    \		temp$="Added"
2030	course_name$(temp%,0%)=cc_key$ &
    \	course_name$(temp%,1%)=cc_name$ &
    \	course_name$(temp%,2%)=cc_directory$ &
    \	course_data%(temp%,i%)=cc_data%(i%) &
		for i%=0% to max_objectives% &
    \	course_data%(temp%,cc_data%(0%)+1%)=cc_router_flags% &
    \	return_value%=fn_write_course% &
    \	if return_value%=STS$K_SUCCESS% then &
		print temp$;" course ";cc_key$;", ";cc_name$ &
    \		goto 2020
2040	close #5 &
    \	goto 1100
2500  !	&
      !	Add a new student to the data base. &
      !	&
    \	first_name$=fn_get_input$("Students first name >") &
    \	goto 1100 if first_name$="EXIT" &
    \	if first_name$="" then &
		goto 2500
2510	last_name$=fn_get_input$("Students last name  >") &
    \	goto 1100 if last_name$="EXIT" &
    \	if last_name$="" then &
		goto 2510
2520	code_name$=fn_get_input$("Students code name  >") &
    \	goto 1100 if code_name$="EXIT" &
    \	if code_name$="" then &
		goto 2520
2530	full_name$=edit$(last_name$,128%)+", "+edit$(first_name$,128%) &
    \	for i%=1% to number_of_students% &
    \		return_value%=fn_read_student_hdr%(i%) &
    \		goto 2540 if return_value%<>STS$K_SUCCESS% &
    \		if cs_name$=full_name$ then &
			temp$="name" &
			else if cs_code_name$=code_name$ then &
				temp$="code name" &
				else goto 2540
2535		print "There is already someone in the data base with that ";temp$;"." &
    \		goto 1100
2540	next i% &
      !	&
      !	Ok.  It is not a duplicate, so add the student. &
      !	&
    \	for i%=1% to number_of_students% &
    \		if student_name$(i%)="ZZZEMPTY_RECORD" then &
			student%=i% &
    \			goto 2550
2545	next i% &
      !	&
      !	Oops.  There is no hole to place this student in, so create a new &
      !	record. &
      !	&
    \	number_of_students%=number_of_students%+1% &
    \	student_number%(number_of_students%)=number_of_students% &
    \	student%=number_of_students%
2550  !	&
      !	Add the student to the data base. &
      !	&
    \	cs_code_name$=code_name$ &
    \	cs_name$=full_name$ &
    \	cs_start_date$=seg$(date$(0%)+" "+time$(0%),1%,15%) &
    \	return_value%=fn_write_student_hdr%(student%) &
    \	if return_value%=STS$K_SUCCESS% then &
		student_name$(student%)=full_name$ &
    \		print full_name$;" added successfully." &
		else &
		print full_name$;" was not added, because ";ert$(err)
2590	goto 1030
3000  !	&
      !	Modify an existing courses records. &
      !	&
    \	course$=next_word$ &
    \	if course$="" then &
		next_word$=fn_get_input$("Modify course >") &
    \		goto 1100 if next_word$="EXIT" &
    \		goto 3000
3010	course%=fn_find_course%(course$) &
    \	if course%=0% then &
		print "Course ";course$;" not found." &
    \		next_word$="" &
    \		goto 3000
3020	cc_key$=course_name$(course%,0%) &
    \	cc_name$=course_name$(course%,1%) &
    \	cc_directory$=course_name$(course%,2%) &
    \	cc_data%(i%)=course_data%(course%,i%) &
		for i%=0% to max_objectives% &
    \	cc_router_flags%=course_data%(course%,cc_data%(0%)+1%) &
    \	register_flag$="ON" &
    \	register_flag$="OFF" if (cc_router_flags% and 1%)=0%
3030	temp$=fn_get_input$("What is the location of the course files? ("+cc_directory$+") >") &
    \	goto 1100 if temp$="EXIT" &
    \	temp$=cc_directory$ if temp$="" &
    \	temp$=temp$+":" if right$(temp$,len(temp$))<>":" and &
			   right$(temp$,len(temp$))<>"]"
3040	temp1$=fn_get_input$("Should registration be ON or OFF ("+register_flag$+") >") &
    \	goto 1100 if temp1$="EXIT" &
    \	temp1$=register_flag$ if temp1$="" &
    \	if temp1$<>"ON" and temp1$<>"OFF" then &
		print "Please enter either ON or OFF." &
    \		goto 3040
3050	cc_directory$=temp$ &
    \	course_name$(course%,2%)=cc_directory$ &
    \	cc_router_flags%=0% &
    \	cc_router_flags%=1% if temp1$="ON" &
    \	course_data%(course%,course_data%(course%,0%)+1%)=cc_router_flags% &
    \	return_value%=fn_write_course% &
    \	if return_value%=STS$K_SUCCESS% then &
		print "Course ";course_name$(course%,0%);" updated successfully." &
		else &
		print "Course ";course_name$(course%,0%);" not updated because ";ert$(err)
3060	goto 1100
3500  !	&
      !	Modify an existing students records. &
      !	&
    \	if next_word$<>"" then &
		temp%=pos(next_word$," ",1%) &
    \		temp%=len(next_word$)+1% if temp%<1% &
    \		student$=seg$(next_word$,1%,temp%-1%) &
    \		next_word$=seg$(next_word$,temp%+1%,len(next_word$)) &
		else &
		next_word$=fn_get_input$("Modify student >") &
    \		goto 1100 if next_word$="EXIT" &
    \		goto 3500
3505	student%=fn_find_student%(student$) &
    \	if student%=0% then &
		print "Student ";student$;" not found." &
    \		next_word$="" &
    \		goto 3500
3510	course$=next_word$ &
    \	if course$="" then &
		course$=fn_get_input$("What course (or press <RETURN> to modify name information) >") &
    \		goto 1100 if course$="EXIT" &
    \		goto 3550 if course$=""
3515	course%=fn_find_course%(course$) &
    \	if course%=0% then &
		print "Course ";course$;" not found." &
    \		next_word$="" &
    \		goto 3510
3520  !	&
      !	Here get the persons course records into local memory. &
      !	&
    \	return_value%=fn_read_student_data%(course%,student%) &
    \	if return_value%<>STS$K_SUCCESS% then &
		for i%=0% to max_objectives% &
    \			cs_module_status%(i%)=0% &
    \			cs_test_status%(i%)=0% &
    \			cs_obj_time%(i%)=0% &
    \		next i%
3530  !	&
      !	This is the main loop for editing the persons course records. &
      !	&
    \	val_limit%=course_data%(course%,0%) &
    \	response$=fn_get_input$("What module (1 to "+num1$(val_limit%)+") >") &
    \	goto 1100 if response$="EXIT" &
    \	module%=val(response$) &
    \	if module%<1% or module%>val_limit% then &
		print "Enter a number from 1 to";val_limit%;"or EXIT." &
    \		goto 3530
3535    val_limit%=course_data%(course%,module%) &
    \	response$=fn_get_input$("What lesson (1 to "+num1$(val_limit%)+") >") &
    \	goto 1100 if response$="EXIT" &
    \	if response$="ALL" then &
		lesson%=val_limit%+1% &
		else &
		lesson%=val(response$) &
    \		if lesson%<1% or lesson%>val_limit% then &
			print "Enter a number from 1 to";val_limit%;", ALL or EXIT." &
    \			goto 3535
3540	if lesson%>course_data%(course%,module%) then &
		cs_module_status%(module%)=32753% &
		else &
		cs_module_status%(module%)=cs_module_status%(module%) or (2%**(lesson%+3%))
3545	return_value%=fn_write_student_data%(course%,student%) &
    \	if return_value%=STS$K_SUCCESS% then &
		print student_name$(student%);" updated." &
    \		goto 3530 &
		else &
		print student_name$(student%);" not updated because ";ert$(err) &
    \		goto 1100
3550  !	&
      !	This is the section to edit the students header record. &
      !	&
    \	return_value%=fn_read_student_hdr%(student%) &
    \	temp%=pos(cs_name$,",",1%) &
    \	o_first_name$=edit$(seg$(cs_name$,temp%+2%,len(cs_name$)),128%) &
    \	o_last_name$=edit$(seg$(cs_name$,1%,temp%-1%),128%) &
    \	o_code_name$=cs_code_name$
3560	first_name$=fn_get_input$("Students first name ("+o_first_name$+") >") &
    \	goto 1100 if first_name$="EXIT" &
    \	first_name$=o_first_name$ if first_name$="" &
      !	&
    \	last_name$=fn_get_input$("Students last name ("+o_last_name$+") >") &
    \	goto 1100 if last_name$="EXIT" &
    \	last_name$=o_last_name$ if last_name$="" &
      !	&
    \	code_name$=fn_get_input$("Students code name >") &
    \	goto 1100 if code_name$="EXIT" &
    \	code_name$=o_code_name$ if code_name$="" &
      !	&
    \	full_name$=edit$(last_name$,128%)+", "+edit$(first_name$,128%) &
    \	for i%=1% to number_of_students% &
    \		goto 3570 if i%=student%		! Skip yourself &
    \		return_value%=fn_read_student_hdr%(i%) &
    \		goto 3570 if return_value%<>STS$K_SUCCESS% &
    \		if cs_name$=full_name$ then &
			temp$="name" &
			else if cs_code_name$=code_name$ then &
				temp$="code name" &
				else goto 3570
3565		print "There is already someone in the data base with that ";temp$;"." &
    \		goto 1100
3570	next i% &
      !	&
    \	cs_code_name$=code_name$ &
    \	cs_name$=full_name$ &
    \	return_value%=fn_write_student_hdr%(student%) &
    \	if return_value%=STS$K_SUCCESS% then &
		student_name$(student%)=full_name$ &
    \		print full_name$;" modified successfully." &
		else &
		print full_name$;" was not modified, because ";ert$(err)
3590	goto 1030
4000  !	&
      !	Delete an existing courses records. &
      !	&
    \	if next_word$="" then &
		next_word$=fn_get_input$("Remove course >") &
    \		goto 1100 if next_word$="EXIT" &
    \		goto 4000
4010	course%=fn_find_course%(next_word$) &
    \	goto 4020 if course%=0% &
      !	&
      !	First delete it in the data base. &
      !	&
    \	find #2, key #0 eq "|COURSE_"+course_name$(course%,0%) &
    \	delete #2 &
      !	&
      !	Now delete all of the student records for this course. &
      !	&
    \	for i%=1% to number_of_students% &
    \		delete #2 if fn_read_student_data%(course%,i%)=STS$K_SUCCESS% &
    \	next i% &
      !	&
      !	Now delete it from the local records.  This is done by copying the &
      !	last record in the local records to the one to be deleted, then &
      !	decrementing the number of courses.  This is simpler than packing &
      !	all of the courses down. &
      !	&
    \	course_name$(course%,0%)=course_name$(number_of_courses%,0%) &
    \	course_name$(course%,1%)=course_name$(number_of_courses%,1%) &
    \	course_name$(course%,2%)=course_name$(number_of_courses%,2%) &
    \	course_data%(course%,i%)=course_data%(number_of_courses%,i%) &
		for i%=0% to max_objectives% &
    \	number_of_courses%=number_of_courses%-1% &
    \	number_of_courses%=0% if number_of_courses%<1% &
      !	&
    \	print "Course ";next_word$;" deleted." &
    \	goto 1100
4020  !	&
      !	Either the course could not be found in the local records, or the FIND &
      !	failed, which indicates the course could not be found in the database. &
      !	In either case, report failure. &
      !	&
    \	print "Course ";next_word$;" is not in the data base." &
    \	goto 1100
4500  !	&
      !	Delete an existing students records. &
      !	&
    \	if next_word$="" then &
		next_word$=fn_get_input$("Remove student >") &
    \		goto 1100 if next_word$="EXIT" &
    \		goto 4500
4510	student%=fn_find_student%(next_word$) &
    \	if student%=0% then &
		print "Student ";next_word$;" is not in the data base." &
    \		next_word$="" &
    \		goto 4500
4520  !	&
      !	Fill in the header record with dummy (empty) data. &
      !	&
    \	cs_code_name$="EMPTY_RECD" &
    \	cs_start_date$="EMPTY_RECORD" &
    \	cs_name$="EMPTY_RECORD" &
    \	return_value%=fn_write_student_hdr%(student%) &
    \	temp$=student_name$(student%) &
    \	if return_value%=STS$K_SUCCESS% then &
		student_name$(student%)="ZZZEMPTY_RECORD" &
		else &
		print "Student ";temp$;" was not deleted because ";ert$(err) &
    \		goto 1100
4530  !	&
      !	Now that the header record is empty, delete all of the data records. &
      !	&
    \	for i%=1% to number_of_courses% &
    \		delete #2 if fn_read_student_data%(i%,student%)=STS$K_SUCCESS% &
    \	next i% &
      !	&
      !	All done. &
      !	&
    \	print "Student ";temp$;" deleted." &
    \	goto 1100 &

5000  !	&
      !	Display comments to the screen. &
      !	&
    \	if next_word$="" then &
		next_word$=fn_get_input$("Display comments for course >") &
    \		goto 1100 if next_word$="EXIT"
5010	course$="/ALL" &
    \	if next_word$<>"" and next_word$<>"*" then &
		temp%=fn_find_course%(next_word$) &
    \		if temp%>0% then &
			course$=edit$(course_name$(temp%,1%),32%) &
			else &
			print "Course ";next_word$;" could not be found." &
    \			next_word$="" &
    \			goto 5000
5020  !	&
      !	Now open the comment file, and search through it for comments from &
      !	the course specified. &
      !	&
    \	close #3 &
    \	open "SYS$INSTRUCTION:COMMENT.DAT" for input as file #3, &
		organization sequential variable, &
		access read &
    \	print ""
5030  !	&
      !	Now print out comments for the course specified. &
      !	&
    \	return_value%=fn_find_comment%(course$) &
    \	goto 5090 if return_value%<>STS$K_SUCCESS% &
    \	print "" &
    \	print "Name   : ";c_name$;  tab(50%);"Module : ";c_module$ &
    \	print "Course : ";c_course$;tab(50%);"Lesson : ";c_lesson$ &
    \	print "Date   : ";c_date$;  tab(50%);"Form   : ";c_frame$ &
    \	print "" &
    \	return_value%=fn_print_comment%(0%) &
    \	print string$(78%,ascii("_")) &
    \	goto 5030 if return_value%=STS$K_SUCCESS%
5090	close #3 &
    \	print "End of comments." &
    \	goto 1100
5500  !	&
      !	Display comments to a file. &
      !	&
    \	if next_word$="" then &
		next_word$=fn_get_input$("Print comments for course >") &
    \		goto 1100 if next_word$="EXIT"
5510	course$="/ALL" &
    \	first_course%=1% &
    \	last_course%=number_of_courses% &
    \	if next_word$<>"" and next_word$<>"*" then &
		first_course%=fn_find_course%(next_word$) &
    \		last_course%=first_course% &
    \		if first_course%=0% then &
			print "Course ";next_word$;" could not be found." &
    \			next_word$="" &
    \			goto 5500
5520  !	&
      !	Now open the comment file, and search through it for comments from &
      !	the course specified. &
      !	&
    \	close #3 &
    \	open "SYS$INSTRUCTION:COMMENT.DAT" for input as file #3, &
		organization sequential variable, &
		access read &
      !	&
    \	close #5 &
    \	open "ROSTER.LIS" for output as file 5%, &
		organization sequential variable, &
		recordsize 135%
5530  !	&
      !	Now print out comments for the course specified. &
      !	&
    \	for i%=first_course% to last_course% &
    \		restore #3 &
    \		print #5, chr$(12%) &
    \		print #5, "Comments as of ";date$(0%);" from ";course_name$(i%,1%) &
    \		print #5, ""
5535		return_value%=fn_find_comment%(edit$(course_name$(i%,1%),32%)) &
    \		goto 5540 if return_value%<>STS$K_SUCCESS% &
    \		print #5, "" &
    \		print #5, "Name   : ";c_name$;  tab(50%);"Module : ";c_module$ &
    \		print #5, "Course : ";c_course$;tab(50%);"Lesson : ";c_lesson$ &
    \		print #5, "Date   : ";c_date$;  tab(50%);"Form   : ";c_frame$ &
    \		print #5, "" &
    \		return_value%=fn_print_comment%(5%) &
    \		print #5, string$(78%,ascii("_")) &
    \		goto 5535 if return_value%=STS$K_SUCCESS%
5540	next i%
5590	close #3, #5 &
    \	print "Output written to ROSTER.LIS." &
    \	goto 1100
6000  !	&
      !	Display course information to the screen. &
      !	&
    \	first_course%=1% &
    \	last_course%=number_of_courses% &
    \	if next_word$<>"" and next_word$<>"*" then &
		first_course%=fn_find_course%(next_word$) &
    \		last_course%=first_course% &
    \		if first_course%=0% then &
			print "Course ";next_word$;" is not in the data base." &
    \			next_word$=fn_get_input$("Display course >") &
    \			goto 1100 if next_word$="EXIT" &
    \			goto 6000
6010	max_obj%=0% &
    \	max_obj%=course_data%(i%,j%) if course_data%(i%,j%)>max_obj% &
		for j%=1% to course_data%(i%,0%) &
			for i%=first_course% to last_course% &
    \	print "" &
    \	print "KEY";tab(5);"TITLE/LOCATION";tab(40);"Module"; &
    \	print tab(44%+i%*3%);num1$(i%); for i%=1% to max_obj% &
    \	print tab(46%+max_obj%*3%);"Registration" &
    \	print "" &
    \	for i%=first_course% to last_course% &
    \		print course_name$(i%,0%);tab(5);course_name$(i%,1%);" / ";course_name$(i%,2%); &
    \		print tab(43%+j%*3%);course_data%(i%,j%); for j%=1% to course_data%(i%,0%) &
    \		temp$="ON" &
    \		temp$="OFF" if (course_data%(i%,course_data%(i%,0%)+1%) and 1%)=0% &
    \		print tab(50%+max_obj%*3%);temp$ &
    \	next i% &
    \	print "" &
    \	goto 1100
6500  !	&
      !	Write course information to a file. &
      !	&
    \	first_course%=1% &
    \	last_course%=number_of_courses% &
    \	if next_word$<>"" and next_word$<>"*" then &
		first_course%=fn_find_course%(next_word$) &
    \		last_course%=first_course% &
    \		if first_course%=0% then &
			print "Course ";next_word$;" is not in the data base." &
    \			next_word$="" &
    \			goto 6500
6510	close #5 &
    \	open "ROSTER.LIS" for output as file 5%, &
		organization sequential variable, &
		recordsize 135% &
    \	max_obj%=0% &
    \	max_obj%=course_data%(i%,j%) if course_data%(i%,j%)>max_obj% &
		for j%=1% to course_data%(i%,0%) &
			for i%=first_course% to last_course% &
    \	print #5, "" &
    \	print #5, "Computer Based Instructional courses as of ";date$(0%) &
    \	print #5, "" &
    \	print #5, "KEY";tab(5);"TITLE/LOCATION";tab(45);"Module #"; &
    \	print #5, tab(50%+i%*3%);num1$(i%); for i%=1% to max_obj% &
    \	print #5, tab(55%+max_obj%*3%);"Registration" &
    \	print #5, "" &
    \	for i%=first_course% to last_course% &
    \		print #5, course_name$(i%,0%);tab(5);course_name$(i%,1%);" / ";course_name$(i%,2%); &
    \		print #5, tab(49%+j%*3%);course_data%(i%,j%); for j%=1% to course_data%(i%,0%) &
    \		temp$="ON" &
    \		temp$="OFF" if (course_data%(i%,course_data%(i%,0%)+1%) and 1%)=0% &
    \		print #5, tab(59%+max_obj%*3%);temp$ &
    \		print #5, "" &
    \	next i% &
    \	close #5 &
    \	print "Output written to ROSTER.LIS." &
    \	goto 1100
7000  !	&
      !	Display student status to the screen. &
      !	&
    \	if next_word$<>"" then &
		temp%=pos(next_word$," ",1%) &
    \		temp%=len(next_word$)+1% if temp%<1% &
    \		student$=seg$(next_word$,1%,temp%-1%) &
    \		next_word$=seg$(next_word$,temp%+1%,len(next_word$)) &
		else &
		next_word$=fn_get_input$("Show student >") &
    \		goto 1100 if next_word$="EXIT" &
    \		goto 7000
7005	first_student%=1% &
    \	last_student%=number_of_students% &
    \	goto 7050 if pos("/BRIEF",student$,1%)=1% &
    \	if student$<>"*" then &
		first_student%=fn_find_student%(student$) &
    \		last_student%=first_student% &
    \		if first_student%=0% then &
			print "Student ";student$;" not found." &
    \			next_word$="" &
    \			goto 7000
7010	course$=next_word$ &
    \	if course$="" then &
		next_word$=fn_get_input$("What course >") &
    \		goto 1100 if next_word$="EXIT" &
    \		goto 7010
7015	first_course%=1% &
    \	last_course%=number_of_courses% &
    \	goto 7050 if pos("/BRIEF",course$,1%)=1% &
    \	if course$<>"*" then &
		first_course%=fn_find_course%(course$) &
    \		last_course%=first_course% &
    \		if first_course%=0% then &
			print "Course ";course$;" not found." &
    \			next_word$="" &
    \			goto 7010
7020	max_obj%=0% &
    \	max_obj%=course_data%(i%,j%) if course_data%(i%,j%)>max_obj% &
		for j%=1% to course_data%(i%,0%) &
			for i%=first_course% to last_course% &
      !	&
    \	for student%=first_student% to last_student% &
    \		goto 7040 if student_name$(student%)="ZZZEMPTY_RECORD" &
    \		print "" &
    \		print "Student status for ";student_name$(student%) &
    \		temp%=STS$K_FAILURE% &
    \		for course%=first_course% to last_course% &
    \			if fn_read_student_data%(course%,student%)=STS$K_SUCCESS% then &
				temp%=STS$K_SUCCESS% &
    \				print "" &
    \				print course_name$(course%,0%); &
    \				print tab(10%+j%*5%);j%; for j%=1% to max_obj% &
    \				print tab(17%+max_obj%*5%);"Time" &
    \				print tab(10%);j%; &
					tab(14%);fn_student_status$(j%,course_data%(course%,j%)); &
					tab(15%+max_obj%*5%);fn_student_time$(j%) &
						for j%=1% to course_data%(course%,0%)
7030		next course% &
      !	&
    \		goto 7040 if temp%=STS$K_SUCCESS% &
      !	&
      !	Oops, this student was not registered for any of the courses that were &
      !	specified.  Give the user a message to that effect. &
      !	&
    \		print student_name$(student%);" is not registered for "; &
    \		print "any courses." if first_course%<last_course% &
    \		print "course ";course_name$(first_course%,0%) if first_course%=last_course%
7040	next student% &
    \	goto 1100
7050  !	&
      !	Here display a brief list of all the students, and which courses they &
      !	are registered in. &
      !	&
    \	print "" &
    \	print "Student name";tab(30%);"Registered in course" &
    \	print "" &
    \	for student%=first_student% to last_student% &
    \		goto 7060 if student_name$(student%)="ZZZEMPTY_RECORD" &
    \		temp%=STS$K_FAILURE% &
    \		temp$="" &
    \		print student_name$(student%);tab(30%); &
    \		for course%=1% to number_of_courses% &
    \			goto 7055 if fn_read_student_data%(course%,student%)<>STS$K_SUCCESS% &
    \			temp%=STS$K_SUCCESS% &
    \			if len(temp$)<=45% then &
				temp$=temp$+course_name$(course%,0%)+", " &
				else &
				print temp$ &
    \				print tab(30%); &
    \				temp$=course_name$(course%,0%)+", "
7055		next course% &
    \		temp$=seg$(temp$,1%,len(temp$)-2%) &
    \		temp$="Not registered for any courses." if temp%<>STS$K_SUCCESS% &
    \		print temp$
7060	next student% &
    \	goto 1100
7500  !	&
      !	Display student status to a file. &
      !	&
    \	if next_word$<>"" then &
		temp%=pos(next_word$," ",1%) &
    \		temp%=len(next_word$)+1% if temp%<1% &
    \		student$=seg$(next_word$,1%,temp%-1%) &
    \		next_word$=seg$(next_word$,temp%+1%,len(next_word$)) &
		else &
		next_word$=fn_get_input$("List student >") &
    \		goto 1100 if next_word$="EXIT" &
    \		goto 7500
7505	first_student%=1% &
    \	last_student%=number_of_students% &
    \	if student$<>"*" then &
		first_student%=fn_find_student%(student$) &
    \		last_student%=first_student% &
    \		if first_student%=0% then &
			print "Student ";student$;" not found." &
    \			next_word$="" &
    \			goto 7500
7510	course$=next_word$ &
    \	if course$="" then &
		next_word$=fn_get_input$("What course >") &
    \		goto 1100 if next_word$="EXIT" &
    \		goto 7510
7515	first_course%=1% &
    \	last_course%=number_of_courses% &
    \	if course$<>"*" then &
		first_course%=fn_find_course%(course$) &
    \		last_course%=first_course% &
    \		if first_course%=0% then &
			print "Course ";course$;" not found." &
    \			next_word$="" &
    \			goto 7510
7520	close #5 &
    \	open "ROSTER.LIS" for output as file 5%, &
		organization sequential variable, &
		recordsize 135% &
      !	&
    \	max_obj%=0% &
    \	max_obj%=course_data%(i%,j%) if course_data%(i%,j%)>max_obj% &
		for j%=1% to course_data%(i%,0%) &
			for i%=first_course% to last_course% &
      !	&
    \	for student%=first_student% to last_student% &
    \		goto 7540 if student_name$(student%)="ZZZEMPTY_RECORD" &
    \		print #5, "" &
    \		print #5, "Student status for ";student_name$(student%) &
    \		temp%=STS$K_FAILURE% &
    \		for course%=first_course% to last_course% &
    \			if fn_read_student_data%(course%,student%)=STS$K_SUCCESS% then &
				temp%=STS$K_SUCCESS% &
    \				print #5, "" &
    \				print #5, course_name$(course%,0%); &
    \				print #5, tab(10%+j%*5%);j%; for j%=1% to max_obj% &
    \				print #5, tab(15%+max_obj%*5%);"Time" &
    \				print #5, tab(10%);j%; &
					tab(14%);fn_student_status$(j%,course_data%(course%,j%)); &
					tab(14%+max_obj%*5%);fn_student_time$(j%) &
						for j%=1% to course_data%(course%,0%)
7530		next course% &
      !	&
    \		goto 7540 if temp%=STS$K_SUCCESS% &
      !	&
      !	Oops, this student was not registered for any of the courses that were &
      !	specified.  Give the user a message to that effect. &
      !	&
    \		print #5, student_name$(student%);" is not registered for "; &
    \		print #5, "any courses." if first_course%<last_course% &
    \		print #5, "course ";course_name$(first_course%,0%) if first_course%=last_course%
7540	next student% &
      !	&
    \	close #5 &
    \	print "Output written to ROSTER.LIS." &
    \	goto 1100
9000  !	&
      !	Display help to the screen. &
      !	&
    \	print "" &
    \	print "The commands are as follows:" &
    \	print "	ADD COURSE	to add a new course to the data base." &
    \	print "	ADD STUDENT	to add a new student to the data base." &
    \	print "	EXIT		to exit." &
    \	print "	HELP		to see this information." &
    \	print "	LIST COMMENTS	to file student comments in ROSTER.LIS." &
    \	print "	LIST COURSE	to file course information in ROSTER.LIS." &
    \	print "	LIST STUDENT	to file student information in ROSTER.LIS." &
    \	print "	MODIFY COURSE	to modify course specific information." &
    \	print "	MODIFY STUDENT	to modify data on a student." &
    \	print "	REMOVE COURSE	to remove a course from the data base." &
    \	print "	REMOVE STUDENT	to remove a student from the data base." &
    \	print "	SHOW COMMENTS	to see the course specific comments." &
    \	print "	SHOW COURSE	to see course specific information." &
    \	print "	SHOW STUDENT	to see student progress in a course." &
    \	print "" &
    \	print "You may specify a particular student or course you wish to work with" &
    \	print "in the LIST, MODIFY, REMOVE and SHOW commands.  Also, the '*' wildcard" &
    \	print "may be used in the LIST and SHOW commands.  For example:" &
    \	print "" &
    \	print "	LIST COURSE VMS		or	SHOW STUDENT SMITH *" &
    \	print "	MODIFY STUDENT SMITH	or	LIST STUDENT * /BRIEF" &
    \	print "" &
    \	goto 1100 &

10000 !	********************************************************************** &
      !	&
      !	&
      !	   S U B R O U T I N E S   L O C A L   T O   T H I S   P R O G R A M &
      !	&
      !	&
      !	**********************************************************************
15000 !	********************************************************************** &
      !	&
      !	&
      !	     F U N C T I O N S   L O C A L   T O   T H I S   P R O G R A M &
      !	&
      !	&
      !	**********************************************************************
15100	def fn_read_course% &
      !	&
      !	Copy information from the MAP to the standard variables.  This routine &
      !	assumes that a GET has just been done to place course information in &
      !	the MAP variables ROSTER_KEY$ and ROSTER_DATA$. &
      !	&
    \	cc_key$=edit$(seg$(roster_key$,9%,16%),1%+4%+128%) &
    \	cc_data%(0%)=ascii(seg$(roster_data$,1%,1%)) &
    \	cc_data%(f_temp%)=ascii(seg$(roster_data$,f_temp%+1%,f_temp%+1%)) &
		for f_temp%=1% to cc_data%(0%) &
    \	cc_router_flags%=ascii(seg$(roster_data$,cc_data%(0%)+2%,cc_data%(0%)+2%)) &
    \	f_temp%=pos(roster_data$,"\",1%) &
    \	f_temp1%=pos(roster_data$,"\",f_temp%+1%) &
    \	f_temp2%=pos(roster_data$,"\",f_temp1%+1%) &
    \	cc_name$=edit$(seg$(roster_data$,f_temp%+1%,f_temp1%-1%),1%+4%+128%) &
    \	cc_directory$=edit$(seg$(roster_data$,f_temp1%+1%,f_temp2%-1%),1%+4%+128%) &
    \	fn_read_course%=STS$K_SUCCESS% &
    \	fnend
15200	def fn_write_course% &
      !	&
      !	Copy information from the standard variables to the MAP, then update &
      !	the data base. &
      !	&
    \	roster_key$="|COURSE_"+cc_key$ &
    \	f_temp$="" &
    \	f_temp$=f_temp$+chr$(cc_data%(f_temp%)) &
		for f_temp%=0% to cc_data%(0%) &
    \	f_temp$=f_temp$+chr$(cc_router_flags%) &
    \	f_temp$=f_temp$+"\"+edit$(cc_name$,128%)+"\"+edit$(cc_directory$,128%)+"\" &
    \	roster_data$=f_temp$ &
    \	return_value%=fn_write_record%(roster_key$,len(edit$(f_temp$,128%))+16%) &
    \	fn_write_course%=return_value% &
    \	fnend
15300	def fn_read_student_hdr%(f_temp%) &
      !	&
      !	Get the record which contains the header information for a student. &
      !	The student number is passed as the parameter. &
      !	&
    \	return_value%=fn_read_record%("|STUDENT_"+num1$(student_number%(f_temp%))) &
    \	if return_value%=STS$K_SUCCESS% then &
		cs_number%=f_temp% &
    \		cs_code_name$=edit$(seg$(roster_data$,1%,10%),1%+4%+128%) &
    \		cs_start_date$=edit$(seg$(roster_data$,11%,25%),1%+4%+128%) &
    \		cs_name$=edit$(seg$(roster_data$,26%,74%),1%+4%+128%) &
		else &
		cs_number%=0% &
    \		cs_code_name$="" &
    \		cs_name$=""
15390	fn_read_student_hdr%=return_value% &
    \	fnend
15400	def fn_write_student_hdr%(f_temp%) &
      !	&
      !	This routine will copy all of the variables to the MAP variables and &
      !	update the data base. &
      !	&
    \	roster_key$="|STUDENT_"+num1$(student_number%(f_temp%)) &
    \	roster_data$=cs_code_name$+space$(10%-len(cs_code_name$))+ &
		     cs_start_date$+space$(15%-len(cs_start_date$))+ &
		     cs_name$ &
    \	return_value%=fn_write_record%(roster_key$,len(edit$(roster_data$,1%+4%+128%))+16%) &
    \	fn_write_student_hdr%=return_value% &
    \	fnend
15500	def fn_read_student_data%(f_temp%,f_temp1%) &
      !	&
      !	This routine will read the data for a particular student in a &
      !	particular course. &
      !	&
    \	f_temp2%=fn_read_record%(course_name$(f_temp%,0%)+"_"+num1$(student_number%(f_temp1%))) &
    \	goto 15590 if f_temp2%<>STS$K_SUCCESS% &
      !	&
      !	Now transfer the data from the map to the proper arrays. &
      !	&
    \	f_temp2%=0% &
    \	cs_log_on%=fn_get_map_var%(f_temp2%) &
    \	for f_temp3%=0% to course_data%(f_temp%,0%) &
    \		f_temp2%=f_temp2%+1% &
    \		cs_obj_time%(f_temp3%)=fn_get_map_var%(f_temp2%) &
    \		f_temp2%=f_temp2%+1% &
    \		cs_module_status%(f_temp3%)=fn_get_map_var%(f_temp2%) &
    \		f_temp2%=f_temp2%+1% &
    \		cs_test_status%(f_temp3%)=fn_get_map_var%(f_temp2%) &
    \	next f_temp3% &
      !	&
    \	f_temp2%=STS$K_SUCCESS%
15590	fn_read_student_data%=f_temp2% &
    \	fnend
15600	def fn_write_student_data%(f_temp%,f_temp1%) &
      !	&
      !	This routine will write the data for a particular student in a &
      !	particular course. &
      !	&
    \	f_temp$="" &
    \	f_temp$=fn_put_map_var$(cs_log_on%) &
    \	for f_temp2%=0% to course_data%(f_temp%,0%) &
    \		f_temp$=f_temp$ +fn_put_map_var$(cs_obj_time%(f_temp2%)) &
				+fn_put_map_var$(cs_module_status%(f_temp2%)) &
				+fn_put_map_var$(cs_test_status%(f_temp2%)) &
    \	next f_temp2% &
    \	roster_key$=course_name$(f_temp%,0%)+"_"+num1$(student_number%(f_temp1%)) &
    \	roster_data$=f_temp$ &
      !	&
    \	f_temp2%=fn_write_record%(roster_key$,16%+len(f_temp$)) &
    \	fn_write_student_data%=f_temp2% &
    \	fnend
15700	def fn_get_input$(f_temp01$) &
      !	&
      !	This routine will get one line of input from the user. &
      !	&
    \	f_temp0$=space$(128%)			! pre-extend the input string &
    \	f_temp0%=lib$get_input(f_temp0$,f_temp01$) &
      !	&
    \	f_temp0$="EXIT" if (f_temp0% and 1%)=0% &
    \	f_temp0$="EXIT" if f_temp0$<>"" and pos("|EXIT|QUIT","|"+f_temp0$,1%)>0% &
      !	&
    \	fn_get_input$=edit$(f_temp0$,1%+4%+8%+16%+32%+128%) &
    \	fnend
15800	def fn_parse_command%(command_line$) &
      !	&
      !	This routine will parse the command line.  It will return a numeric &
      !	value which points to a routine to execute.  As a side effect, it will &
      !	place the next word (past the parsed portion of the command line) into &
      !	the variable NEXT_WORD$. &
      !	&
    \	next_word$="" &
    \	if command_line$="" then &
		f_command%=15% &
    \		goto 15890
15810	f_temp%=pos(command_line$," ",1%)	! Find a space which separates &
						! the keywords in the line. &
    \	f_temp%=len(command_line$)+1% if f_temp%<1%	! If there is no space &
						! pick up the whole line &
    \	f_temp1%=pos(command_line$,"/",1%)	! Find a slash which separates &
						! the keywords in the line. &
    \	f_temp1%=len(command_line$)+1% if f_temp1%<1%	! If there is no slash &
						! pick up the whole line &
    \	f_temp%=f_temp1% if f_temp%>f_temp1%	! find the first one. &
    \	f_temp$="|"+seg$(command_line$,1%,f_temp%-1%) &
    \	f_command%=pos(keyword_list$,f_temp$,1%) &
    \	goto 15890 if f_command%<1% &
    \	f_command%=ascii(seg$(keyword_list$,f_command%-1%,f_command%-1%)) &
    \	if f_temp%>len(command_line$) and f_command%<13% then &
		f_temp%=0% &
    \		command_line$=fn_get_input$("What:") &
    \		if command_line$="" then &
			f_command%=13%		! Null entry, get HELP &
    \			goto 15890 &
			else if command_line$="EXIT" then &
				f_command%=14%	! Repeat question &
    \				goto 15890
15820	f_temp1$="|COURSES |STUDENTS" &
    \	f_temp1$="|COMMENTS"+f_temp1$ if f_command%=7% or f_command%=10% &
    \	f_temp1%=pos(command_line$," ",f_temp%+1%) &
    \	f_temp1%=len(command_line$)+1% if f_temp1%<1% &
    \	f_temp2%=pos(command_line$,"/",f_temp%+1%) &
    \	f_temp2%=len(command_line$)+1% if f_temp2%<1% &
    \	f_temp1%=f_temp2% if f_temp1%>f_temp2%	! find the first one. &
    \	f_temp$="|"+seg$(command_line$,f_temp%+1%,f_temp1%-1%) &
    \	f_temp%=pos(f_temp1$,f_temp$,1%) &
    \	if f_temp%<1% then &
		f_command%=0% &
    \		goto 15890
15830	f_command%=f_command%+int(f_temp%/9%) &
    \	next_word$=seg$(command_line$,f_temp1%+1%,len(command_line$))
15890	fn_parse_command%=f_command% &
    \	fnend
15900	def fn_read_record%(f_temp$) &
      !	&
      !	This routine will read a record, with the primary key eq the parameter &
      !	passed.  The return value is either STS$K_SUCCESS%, or STS$K_FAILURE%. &
      !	&
    \	on error goto 15910 &
      !	&
    \	get #2, key #0 eq f_temp$ &
    \	f_temp%=STS$K_SUCCESS% &
    \	goto 15990
15910	f_temp%=STS$K_FAILURE% &
    \	resume 15990
15990	fn_read_record%=f_temp% &
    \	fnend
16000	def fn_write_record%(f_temp$,f_temp%) &
      !	&
      !	This routine will write a record to the data base, with the primary &
      !	key eq the first parameter, and the length eq the second parameter. &
      !	The return value is either STS$K_SUCCESS%, or STS$K_FAILURE%. &
      !	&
    \	on error goto 16020 &
      !	&
    \	find #2, key #0 eq f_temp$ &
      !	&
      !	The record has been found, so UPDATE it. &
      !	&
    \	update #2, count f_temp% &
    \	f_temp%=STS$K_SUCCESS% &
    \	goto 16090
16010 !	&
      !	The record has not been found, or the UPDATE failed.  Try to PUT the &
      !	record.  If this fails, report failure. &
      !	&
    \	put #2, count f_temp% &
    \	f_temp%=STS$K_SUCCESS% &
    \	goto 16090
16020 !	&
      !	This is the error section for this function.  There are two cases: &
      !	Either there was an error at line 16000 (for either the FIND or the &
      !	UPDATE failing), or there was an error at line 16010 (which indicates &
      !	the PUT failed after the FIND failed).  In the first case, try to &
      !	create the record by RESUMEing at line 16010.  In the second case, &
      !	simply report failure. &
      !	&
    \	if erl=16000 then &
		resume 16010 &
		else &
		f_temp%=STS$K_FAILURE% &
    \		resume 16090
16090	fn_write_record%=f_temp% &
    \	fnend
16100	def fn_find_course%(f_temp$) &
      !	&
      !	Return the array address of the course passed as the parameter. &
      !	&
    \	f_temp%=0% &
    \	f_temp%=f_temp1% if course_name$(f_temp1%,0%)=f_temp$ &
		for f_temp1%=1% to number_of_courses% &
    \	fn_find_course%=f_temp% &
    \	fnend
16200	def fn_find_comment%(f_temp$) &
      !	&
      !	This routine will find the next comment which matches the course &
      !	specification passed as the parameter.  It returns STS$K_SUCCESS% if &
      !	a comment for this course was found, or STS$K_FAILURE% if no more &
      !	comments could be found for this course.  As a side effect, the &
      !	variables C_NAME$, C_MODULE$, C_COURSE$, C_LESSON$, C_DATE$, and &
      !	C_FRAME$ will be set for the calling routine to print. &
      !	&
    \	on error goto 16220 &
      !
16210	linput #3, f_temp1$ &
      !	&
      !	Skip lines until a NAME line is found (started with <N>) &
      !	&
    \	goto 16210 if seg$(f_temp1$,1%,3%)<>"<N>" &
    \	c_name$=seg$(f_temp1$,5%,len(f_temp1$)) &
      !	&
      !	The next line will have the form: &
      !	&
      !		<F> XXNNN <C> The ???? Primer <L> N N N <D> DD-MM-YY HH:MM:SS &
      !	&
      !	Check whether this is a comment from a course requested by the calling &
      !	routine, (which could be "/ALL" courses), and if it is, then break it &
      !	into the variables listed above. &
      !	&
    \	linput #3, f_temp1$ &
    \	goto 16210 if f_temp$<>"/ALL" and pos(edit$(f_temp1$,32%),f_temp$,1%)<1% &
      !	&
      !	It is a course requested by the calling routine.  Set the variables. &
      !	&
    \	f_temp1%=pos(f_temp1$,"<F>",1%) &
    \	f_temp2%=pos(f_temp1$,"<C>",1%) &
    \	f_temp3%=pos(f_temp1$,"<L>",1%) &
    \	f_temp4%=pos(f_temp1$,"<D>",1%) &
    \	c_frame$=edit$(seg$(f_temp1$,f_temp1%+3%,f_temp2%-1%),8%+128%) &
    \	c_course$=edit$(seg$(f_temp1$,f_temp2%+3%,f_temp3%-1%),8%+128%) &
    \	c_date$=edit$(seg$(f_temp1$,f_temp4%+3%,len(f_temp1$)),8%+128%) &
    \	f_temp1$=edit$(seg$(f_temp1$,f_temp3%+3%,f_temp4%-1%),8%+128%) &
    \	f_temp1%=pos(f_temp1$," ",1%) &
    \	f_temp2%=pos(f_temp1$," ",f_temp1%+3%) &
    \	c_module$=edit$(seg$(f_temp1$,1%,f_temp1%-1%),2%) &
    \	c_lesson$=edit$(seg$(f_temp1$,f_temp1%+1%,f_temp2%-1%),2%) &
    \	f_temp%=STS$K_SUCCESS% &
    \	goto 16290
16220 !	&
      !	An error has occurred.  Probably it is End-Of-File on the comment &
      !	file.  If this occurs, then no more comments can be found for this &
      !	course, so return failure. &
      !	&
    \	f_temp%=STS$K_FAILURE% &
    \	resume 16290
16290	fn_find_comment%=f_temp% &
    \	fnend
16300	def fn_print_comment%(f_temp%) &
      !	&
      !	This routine will print the next comment in the comment file.  The &
      !	data will be printed to the channel passed as the parameter. &
      !	&
    \	on error goto 16320 &
    \	f_temp1%=STS$K_SUCCESS% &
      !
16310	linput #3, f_temp$ &
    \	f_temp$=seg$(f_temp$,5%,len(f_temp$)) if seg$(f_temp$,1%,4%)="<TX>" &
    \	goto 16390 if f_temp$="<>" &
    \	print # f_temp%, f_temp$ &
    \	goto 16310
16320 !	&
      !	An error has occurred.  Probably this is an End-Of-File, which tends &
      !	to indicate the end of the comment. &
      !	&
    \	f_temp1%=STS$K_FAILURE% &
    \	resume 16390
16390	fn_print_comment%=f_temp1% &
    \	fnend
16400	def fn_find_student%(f_temp$) &
      !	&
      !	This routine will return the number of the student in the local data &
      !	base.  This is then used to get the students information from the &
      !	permanent data base. &
      !	&
    \	on error goto 16480 &
      !	&
    \	f_temp2%=0% &
    \	for f_temp%=1% to number_of_students% &
    \		goto 16420 if student_name$(f_temp%)="ZZZEMPTY_RECORD" &
    \		if pos(student_name$(f_temp%),f_temp$,1%)=1% then &
			f_temp1$=fn_get_input$("Do you mean "+student_name$(f_temp%)+" >") &
    \			goto 16490 if left$(f_temp1$,1%)="Y" &
    \			goto 16420
16410		if left$(f_temp$,2%)=left$(student_name$(f_temp%),2%) then &
			f_temp2%=f_temp2%+1% &
    \			name_list%(f_temp2%)=f_temp%
16420	next f_temp% &
    \	print "There is no student named ";f_temp$;".  "; &
    \	if f_temp2%<1% then &
		f_temp%=0% &
    \		goto 16490 &
		else &
		if f_temp2%=1% then &
			f_temp1$=fn_get_input$("Do you mean "+student_name$(name_list%(1%))+" >") &
    \			f_temp%=0% &
    \			f_temp%=name_list%(1%) if left$(f_temp1$,1%)="Y" &
    \			goto 16490 &
			else &
			print "People with similar names are:" &
    \			for f_temp1%=1% to f_temp2% &
    \				print "(";num1$(f_temp1%);")";tab(6%);student_name$(name_list%(f_temp1%)) &
    \			next f_temp1%
16430	f_temp1$=fn_get_input$("Which student (1 to "+num1$(f_temp2%)+") >") &
    \	f_temp1%=val(f_temp1$) &
    \	if f_temp1%>0% and f_temp1%<=f_temp2% then &
		f_temp%=name_list%(f_temp1%) &
    \		goto 16490 &
		else &
		print "Please enter a number from 1 to ";num1$(f_temp2%) &
    \		goto 16430
16480 !	&
      !	Error recovery.  Generally, the only type of error is entering an &
      !	illegal number.  In this case, simply return with failure. &
      !	&
    \	f_temp%=0% &
    \	resume 16490
16490	fn_find_student%=f_temp% &
    \	fnend
16500	def fn_student_status$(f_temp%,f_temp1%) &
      !	&
      !	This routine will return a string which is the students status in a &
      !	particular module.  The first parameter is which module to return the &
      !	status for, and the second parameter is how many lessons (objectives) &
      !	there are in this module. &
      !	&
    \	f_temp$="" &
      !	&
      !	First construct the module and test status. &
      !	&
    \	for f_temp2%=1% to f_temp1% &
    \		f_temp$=f_temp$+" " &
    \		f_temp3%=int(cs_module_status%(f_temp%)/(2%**(f_temp2%+3%))) &
    \		if (f_temp3% and 1%)=1% then f_temp$=f_temp$+"C" &
					else f_temp$=f_temp$+"-"
16510		f_temp$=f_temp$+"/" &
    \		if cs_test_status%(f_temp%)=0% then &
			f_temp$=f_temp$+"-" &
			else &
			f_temp3%=cs_test_status%(f_temp%) and (2%**f_temp2%) &
    \			if f_temp3%=0%  then f_temp$=f_temp$+"F" &
					else f_temp$=f_temp$+"P"
16520		f_temp$=f_temp$+" " &
    \	next f_temp2% &
    \	fn_student_status$=f_temp$ &
    \	fnend
16600	def fn_student_time$(f_temp%) &
      !	&
      !	Function to return the time spent in a module in alpha format. &
      !	&
    \	f_temp$="" &
      !	&
    \	f_temp2%=int(cs_obj_time%(f_temp%)/3600%) &
    \	f_temp1$=num1$(f_temp2%) &
    \	f_temp1$=" "+f_temp1$ if len(f_temp1$)<2% &
    \	f_temp$=f_temp$+f_temp1$+":" &
    \	f_temp3%=int((cs_obj_time%(f_temp%)-(f_temp2%*3600%))/60%) &
    \	f_temp1$=num1$(f_temp3%) &
    \	f_temp1$="0"+f_temp1$ if len(f_temp1$)<2% &
    \	f_temp$=f_temp$+f_temp1$+":" &
    \	f_temp4%=cs_obj_time%(f_temp%)-(f_temp3%*60%+f_temp2%*3600%) &
    \	f_temp1$=num1$(f_temp4%) &
    \	f_temp1$="0"+f_temp1$ if len(f_temp1$)<2% &
    \	f_temp$=f_temp$+f_temp1$ &
      !	&
    \	fn_student_time$=f_temp$ &
    \	fnend
16700	def fn_get_map_var%(f_temp%) &
      !	&
      !	This routine will copy a numeric value from the ROSTER_DATA$ at the &
      !	position specified, and return that value. &
      !	&
    \	f_temp1%=f_temp%*2%+1% &
    \	fn_get_map_var%=ascii(seg$(roster_data$,f_temp1%,f_temp1%))*256%+ &
			ascii(seg$(roster_data$,f_temp1%+1%,f_temp1%+1%)) &
    \	fnend
16800	def fn_put_map_var$(f_temp%) &
      !	&
      !	This routine will take the number passed and return it as a two byte &
      !	string.  This can then be used to build the ROSTER_DATA$. &
      !	&
    \	fn_put_map_var$=chr$(int(f_temp%/256%))+chr$(f_temp%-(int(f_temp%/256%)*256%)) &
    \	fnend
19000 !	********************************************************************** &
      !	&
      !	&
      !		S T A N D A R D   E R R O R   H A N D L I N G &
      !	&
      !	&
      !	********************************************************************** &
      !	&
    \	if err=28 then				! ^C trap.  Resume at prompt &
		temp%=ctrlc			! Re-enable ^C trapping. &
    \		print ""			! Clear out the I/O buffer &
    \		resume 1100
19010	if erl=1000 then			! Error opening main data base &
		print "" &
    \		print "The file SYS$INSTRUCTION:ROSTER.DAT cannot be opened because "; &
    \		print ert$(err) &
    \		print "Please correct this error and try again." &
    \		resume 32767
19020	if erl=1010 or erl=1015 then		! Error finding course records &
		resume 1020
19030	if erl=2010 then			! Error in opening the file &
						! which contains course info &
		print "The file ";file_name$;" could not be opened because "; &
    \		print ert$(err) &
    \		print "Please correct this error and try again." &
    \		resume 1100
19040	if erl=2020 then			! Error in reading the file &
						! which contains course info &
		resume 2040
19050	if err=52 then				! Bad number entered by the user &
		print "Enter a number from 1 to";val_limit%;"or EXIT." &
    \		resume
19060	if erl=4010 then			! Error in finding the course &
						! records to delete &
		resume 4020
19900 !	********************************************************************** &
      !	&
    \	print "Unknown error";err;"at line";erl;"which is ";ert$(err) &
    \	RESUME 32767 &
      !	&
      !	**********************************************************************
32000 !	********************************************************************** &
      !	&
      !	&
      !			E N D   O F   P R O C E S S I N G &
      !	&
      !	&
      !	********************************************************************** &
      !	&
    \	close #1, #2, #3, #4, #5
32767 !	********************************************************************** &
      !	&
      !	&
      !			E N D   O F   P R O G R A M &
      !	&
      !	&
      !	********************************************************************** &
      !	&
    \	END
