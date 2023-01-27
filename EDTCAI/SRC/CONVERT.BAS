1     !	********************************************************************** &
      !	&
      !	&
      !			C O N V E R S I O N   P R O G R A M &
      !	&
      !	&
    \	ON ERROR GOTO 19000 &
      !	&
      !	&
      !		VERSION:	1.0 &
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
      !		(C) Copyright 1982 &
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
      !		1.0	2/8/82	KNM	 Original Version &
      !	&
      !	&
      !	**********************************************************************
100   !	********************************************************************** &
      !	&
      !	&
      !		P R O G R A M   D E S C R I P T I O N &
      !	&
      !	This program will take the roster file from the original EDTCAI course, &
      !	and convert it to the format used in EDTCAI V2.0, which will be released &
      !	on VMS V3.0. &
      !	&
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
      !	&
      !		1		EDT$CAI:ROSTER.DAT	Original Roster File &
      !		2		SYS$INSTRUCTION:ROSTER.DAT	New Roster File &
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
      !
450   !	&
      !	&
      !		E X T E R N A L   V A R I A B L E S   A N D   A R R A Y S &
      !	&
      !	&
      !		NAME		DESCRIPTION &
      !		-----		---------------------------------------------- &
      !	&
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
      !	&
      !		STUDNT		Map for Original Roster File &
      !		NEWROS		Map for New Roster File &
      !	&
    \	map (studnt) &
		student.number$=3%, &
		code.name$=10%, &
		first.name$=20%, &
		last.name$=30%, &
		course$=30%, &
		instructor$=30%, &
		start.date$=15%, &
		prior.exp$=2%, &
		dec.emp$=6%, &
		company.addres$=128%, &
		log.on%, &
		objective.time%(7%), &
		activity.code$=4%, &
		module.status%(7%) &
      !	&
    \	map (newros) &
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
    \	dim course_name$(200%,2%) &
    \	dim course_data%(200%,50%) &
    \	dim cc_data%(50%) &
    \	dim cs_obj_time%(50%) &
    \	dim cs_module_status%(50%) &
    \	dim cs_test_status%(50%) &
    \	dim student_number%(200%) &
    \	dim student_name$(200%) &
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
      !	********************************************************************** &
      !	&
    \	temp%=ctrlc				! Enable CTRL/C trapping &
    \	STS$K_FAILURE% = 0% &
    \	STS$K_SUCCESS% = 1% &
    \	MAX_OBJECTIVES%= 50% &
      ! &
    \	lesson_1_credit%=2%**4% &
    \	lesson_2_credit%=2%**5% &
    \	lesson_3_credit%=2%**6% &
    \	lesson_4_credit%=2%**7% &
    \	lesson_5_credit%=2%**8% &
      ! &
      ! Open the CONTROL file, which tells where the ROSTER file is. &
      !
    \	open "EDT$CAI:CONTROL.DAT" as file 1% &
    \		linput #1, code.word$ &
    \		linput #1, lib.account$ &
    \		linput #1, roster.account$ &
    \	close #1%
      !	&
      !	Open the old roster file. &
      !	&
    \	open roster.account$+"ROSTER.DAT" for input as file 1%, &
		organization relative fixed, &
		access read, &
		map studnt
1005  !	&
      !	Open the data base file, and build the local records for this session &
      !	&
    \	open "SYS$INSTRUCTION:ROSTER.DAT" as file 2%, &
		organization indexed variable, &
		map newros, &
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
2000  !	&
      !	Copy an course from the old roster file to here. &
      !	&
      !	Check to see if the main record is already there. &
      !	&
    \	course%=fn_find_course%("EDT") &
    \	if course%=0% then &
		print "Please update the roster file, using the ADMIN program." &
    \		goto 32000
2010	print "Now copying students." &
    \	for i%=2% to 1000% &
    \		get #1%, record i% &
    \		goto 2030 if code_name$="EMPTY RECD" or code_name$="REGISTERXX" &
    \		full_name$=edit$(last.name$,128%)+", "+edit$(first.name$,128%) &
    \		for j%=1% to number_of_students% &
    \			return_value%=fn_read_student_hdr%(j%) &
    \			goto 2015 if return_value%<>STS$K_SUCCESS% &
    \			if cs_name$=full_name$ then &
				temp%=j% &
    \				goto 2020 &
				else &
				if cs_code_name$=code.name$ then &
					print "There is a duplicate code name for ";cs_name$ &
    \					goto 2030
2015		next j% &
    \		number_of_students%=number_of_students%+1% &
    \		student_number%(number_of_students%)=number_of_students% &
    \		temp%=number_of_students% &
    \		cs_code_name$=edit$(code.name$,128%) &
    \		cs_name$=full_name$ &
    \		cs_start_date$=start.date$ &
    \		return_value%=fn_write_student_hdr%(number_of_students%) &
    \		if return_value%=STS$K_SUCCESS% then &
			print full_name$;" added to the roster." &
    \			student_name$(temp%)=full_name$ &
    \			goto 2020 &
			else &
			print full_name$;" was not added to the roster." &
    \			goto 2030
2020		for j%=0% to course_data%(course%,0%) &
    \			cs_obj_time%(j%)=objective.time%(j%) &
    \			cs_test_status%(j%)=0% &
    \		next j% &
    \		gosub 10100				! Translate completion records &
    \		return_value%=fn_write_student_data%(course%,temp%) &
    \		if return_value%=STS$K_SUCCESS% then &
			print full_name$;" was added to ";course_name$(course%,0%) &
			else print full_name$;" was not added to ";course_name$(course%,0%);" because ";ert$(err)
2030	next i% &
    \	print "Finished converting the students." &
    \	goto 32000

10000 !	********************************************************************** &
      !	&
      !	&
      !	   S U B R O U T I N E S   L O C A L   T O   T H I S   P R O G R A M &
      !	&
      !	&
      !	**********************************************************************
10100 ! &
      !	Subroutine to translate the completion records from the old course &
      !	format to the new course format. &
      ! &
      !	The old records which stored the information on which lessons were &
      !	completed are in a completely different format than the new records. &
      !	In addition, there is not a one-to-one correspondence between completing &
      !	a particular lesson under the old course, and getting credit for having &
      !	completed that lesson under the new course.  For both reasons, translate &
      !	the MODULE.STATUS% array into CS_MODULE_STATUS%. &
      ! &
      !	Now clear out the array. &
      ! &
    \	cs_module_status%(k%)=0% for k%=0% to 7% &
      ! &
      !	Copy the pointer to which module they are in. &
      ! &
    \	cs_module_status%(0%)=module.status%(0%) &
      ! &
      !	Copy Module 1, Objective 1 to Module 1. &
      ! &
    \	cs_module_status%(1%)=1% &
    \	cs_module_status%(1%)=module.status%(1%) &
		if module.status%(1%)>0% and module.status%(1%)<7% &
    \	cs_module_status%(1%)=cs_module_status%(1%) or lesson_1_credit% &
		if module.status%(1%)>1% &
    \	cs_module_status%(1%)=cs_module_status%(1%) or lesson_1_credit% &
		if module.status%(1%)>2% &
    \	cs_module_status%(1%)=cs_module_status%(1%) or lesson_3_credit% &
		if module.status%(1%)>3% &
      ! &
      !	Copy Module 2, Objective 1 to Module 2. &
      ! &
    \	cs_module_status%(2%)=1% &
    \	cs_module_status%(2%)=module.status%(2%) &
		if module.status%(2%)>0% and module.status%(2%)<7% &
    \	cs_module_status%(2%)=cs_module_status%(2%) or lesson_2_credit% &
		if module.status%(2%)>1% &
    \	cs_module_status%(2%)=cs_module_status%(2%) or lesson_3_credit% &
		if module.status%(2%)>2% &
      ! &
      !	Copy Module 2, Objective 2 to Module 3. &
      ! &
    \	cs_module_status%(3%)=1% &
    \	cs_module_status%(3%)=module.status%(3%) &
		if module.status%(3%)>0% and module.status%(3%)<7% &
    \	cs_module_status%(3%)=cs_module_status%(3%) or lesson_2_credit% &
		if module.status%(3%)>1% &
    \	cs_module_status%(3%)=cs_module_status%(3%) or lesson_3_credit% &
		if module.status%(3%)>2% &
    \	cs_module_status%(3%)=cs_module_status%(3%) or lesson_5_credit% &
		if module.status%(3%)>3% &
      ! &
      !	Copy Module 3, Objective 1 to Module 4. &
      ! &
    \	cs_module_status%(4%)=1% &
    \	cs_module_status%(4%)=module.status%(4%) &
		if module.status%(4%)>0% and module.status%(4%)<7% &
    \	cs_module_status%(4%)=cs_module_status%(4%) or lesson_2_credit% &
		if module.status%(4%)>1% &
    \	cs_module_status%(5%)=cs_module_status%(5%) or lesson_1_credit% &
		if module.status%(4%)>2% &
    \	cs_module_status%(4%)=cs_module_status%(4%) or lesson_2_credit% &
		if module.status%(4%)>3% &
    \	cs_module_status%(4%)=cs_module_status%(4%) or lesson_3_credit% &
		if module.status%(4%)>4% &
      ! &
      !	Copy Module 3, Objective 2 to Module 5. &
      ! &
    \	cs_module_status%(5%)=1% &
    \	cs_module_status%(5%)=module.status%(5%) &
		if module.status%(5%)>0% and module.status%(5%)<7% &
    \	cs_module_status%(4%)=cs_module_status%(4%) or lesson_4_credit% &
		if module.status%(5%)>1% &
    \	cs_module_status%(4%)=cs_module_status%(4%) or lesson_3_credit% &
		if module.status%(5%)>2% &
    \	cs_module_status%(5%)=cs_module_status%(5%) or lesson_3_credit% &
		if module.status%(5%)>3% &
    \	cs_module_status%(5%)=cs_module_status%(5%) or lesson_4_credit% &
		if module.status%(5%)>4% &
    \	cs_module_status%(5%)=cs_module_status%(5%) or lesson_5_credit% &
		if module.status%(5%)>5% &
      ! &
      !	There is nothing comparable in the new course to what was Module 3, &
      ! Objective 3.  The information is spread around the lesson. &
      ! &
      ! &
      !	Copy Module 4, Objective 1 to Module 6. &
      ! &
    \	cs_module_status%(6%)=1% &
    \	cs_module_status%(6%)=module.status%(6%) &
		if module.status%(6%)>0% and module.status%(6%)<7% &
    \	cs_module_status%(6%)=cs_module_status%(6%) or lesson_1_credit% &
		if module.status%(7%)>1% &
    \	cs_module_status%(6%)=cs_module_status%(6%) or lesson_2_credit% &
		if module.status%(7%)>2% &
    \	cs_module_status%(6%)=cs_module_status%(6%) or lesson_3_credit% &
		if module.status%(7%)>3%
10199	return
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
    \	if err=28 then				! ^C trap.  Resume at prompt &
		temp%=ctrlc			! Re-enable ^C trapping. &
    \		print ""			! Clear out the I/O buffer &
    \		resume 32000
19010	if erl=1000 then			! Error opening main data base &
		print "" &
    \		print "The file EDT$CAI:ROSTER.DAT cannot be opened because "; &
    \		print ert$(err) &
    \		print "Please correct this error and try again." &
    \		resume 32767
19020	if erl=1005 then			! Error opening main data base &
		print "" &
    \		print "The file SYS$INSTRUCTION:ROSTER.DAT cannot be opened because "; &
    \		print ert$(err) &
    \		print "Please correct this error and try again." &
    \		resume 32767
19030	if erl=1010 or erl=1015 then		! Error finding course records &
		resume 1020
19040	if erl=2010 then			! Error reading old course &
		resume 2030
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
    \	close #1, #2
32767 !	********************************************************************** &
      !	&
      !	&
      !			E N D   O F   P R O G R A M &
      !	&
      !	&
      !	********************************************************************** &
      !	&
    \	END
