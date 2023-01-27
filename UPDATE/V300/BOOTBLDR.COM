$ !++
$ ! BOOTBLDR.COM  - Command file to create 11/782 console floppies
$ !
$ ! AUTHOR:	Paul DeStefano		29-APR-1982
$ !
$ ! ABSTRACT:	This command procedure creates a new console floppy for a
$ !		multiprocessor system by modifying the command procedures from
$ !		an existing console floppy to use MA780 multi-port memory.
$ !		The original console floppy will not be changed in any way.
$ !		A list of files to be modified will be made by selecting the
$ !		command procedures with the following naming conventions:
$ !
$ !					D%%BOO.CMD
$ !					D%%GEN.;
$ !					D%%XDT.;
$ !					CIBOO.CMD
$ !					CIGEN.;
$ !					CIXDT.;
$ !					RESTAR.CMD
$ !
$ !		Diagnostic Supervisor bootstrap files and Interleaved memory
$ !		bootstrap files will not be reproduced on the new floppy.  This
$ !		includes any files with the following naming conventions:
$ !
$ !					SM%BOO.%%%
$ !					SB%BOO.%%%
$ !					SR%BOO.%%%
$ !					%%%%%%.ILV
$ !
$ !		All other files are copied without modification.
$ !		A new DEFBOO.CMD will be created for the system device.
$ !		RMEM.;1 will be created so that the system can be reset to run
$ !		without the MA780 memory.
$ !
$ ! NOTE:	This procedure will prompt for all inputs and therfore is meant
$ !		to run interactively.  The user should be familiar with the
$ !		memory configuration of the system, and should know the TR
$ !		numbers and the amount of memory on each of the memory
$ !		controllers.  The command files will be written such that the
$ !		starting addresses of the MA780 controllers will be set up
$ !		according to the order in which they are entered.
$ !
$ !		This procedure will created a temporary subdirectory
$ !		[.TEMPBOOT].  It is assumed that this directory does not
$ !		already exist.
$ !
$ !--
$ WRITE SYS$OUTPUT-
 "	VAX 11/782 Multiprocessor Bootstrap Command Procedure Builder"
$ WRITE SYS$OUTPUT ""
$ DIR_CREATED:=FALSE
$ CONSOLE_MOUNTED := FALSE
$ PRIMARY := TRUE
$ ATTACHED := FALSE
$START:
$ DIR_FILE_OPEN := FALSE
$ NOMOD_DIR_OPEN := FALSE
$ MOD_DIR_OPEN := FALSE
$ OLD_FILE_OPEN := FALSE
$ NEW_FILE_OPEN := FALSE
$ IF F$MODE() .EQS. "BATCH" THEN GOTO EXIT
$ SAVED_PRIVS = F$SETPRV("CMKRNL,LOG_IO,VOLPRO")
$ SAVEDEF:= 'F$DIRECTORY()'
$ ON CONTROL_Y THEN GOTO BOTH_DONE
$ ! 
$ ! Get the memory configuration.
$ !
$ MAX_CNTRLRS=6			! Six controllers max.
$ MA_START=1			! Starting address for first MA780
$ INIT_VAR:
$ A=0
$ INIT_VAR1:
$ A=A+1
$ IF A .GT. 6 THEN GOTO ATTACHED_BEGIN
$ MEM_TYPE'A := ""
$ MEM_TR'A=0
$ GOTO INIT_VAR1
$ATTACHED_BEGIN:
$ CNTRLR=1			! Controller we're currently processing
$ END_MA=0			! Starting address for first MS780 controller
$ END_MS=0			! Starting address for first MA780 (for RMEM)
$GET_MEM:
$ IF ATTACHED THEN GOTO ASK_MS780_ONLY
$GET_MEM1:
$ WRITE SYS$OUTPUT ""
$ INQUIRE MEM_TYPE'CNTRLR-
 "Enter memory type (MA780, MS780, or <RETURN> to end)"
$ IF MEM_TYPE'CNTRLR .EQS. "" THEN GOTO GET_MEM_END
$ IF MEM_TYPE'CNTRLR .EQS. "MA780"-
 .OR. MEM_TYPE'CNTRLR .EQS. "MS780" THEN GOTO ASK_TR
$ WRITE SYS$OUTPUT "Illegal memory type - must be MA780 or MS780"
$ GOTO GET_MEM1
$ ASK_TR:
$ INQUIRE MEM_TR'CNTRLR "Enter TR level (1 through 6)"
$ IF MEM_TR'CNTRLR .GT. 0 .AND. MEM_TR'CNTRLR .LT. 7 THEN GOTO ASK_TR2
$ WRITE SYS$OUTPUT "TR number must be in the range or 1 to 6"
$ GOTO ASK_TR
$ ASK_TR2:
$ A=0
$ ASK_TR3:
$ A=A+1
$ IF A .EQ. CNTRLR THEN GOTO ASK_MEM_AMT
$ IF MEM_TR'CNTRLR .NE. MEM_TR'A THEN GOTO ASK_TR3
$ WRITE SYS$OUTPUT "Illegal memory configuration - TR numbers must be unique."
$ GOTO ASK_TR
$ASK_MS780_ONLY:
$ IF MEM_TYPE'CNTRLR .EQS. "MA780" THEN GOTO CONVERT_MEM
$ IF MEM_TR'CNTRLR .NE. 0 THEN GOTO 20$
$ B=0
$FIND_TR:
$ A=0
$ B=B+1
$FIND_TR_LOOP:
$ A=A+1
$ IF A .EQ. 7 THEN GOTO FOUND_TR
$ IF MEM_TR'A .EQ. B THEN GOTO FIND_TR
$ GOTO FIND_TR_LOOP
$FOUND_TR:
$ MEM_TR'CNTRLR=B
$20$:
$ WRITE SYS$OUTPUT ""
$ WRITE SYS$OUTPUT-
 "Is an MS780 (local) memory controller configured at TR level "-
 ,MEM_TR'CNTRLR,"?"
$ INQUIRE QUES "(YES or NO)"
$ IF QUES .EQS. "" THEN GOTO 20$
$ IF QUES THEN GOTO ASK_MEM_AMT
$ MEM_TYPE'CNTRLR := ""
$ GOTO GET_NEXT_MEM
$ASK_MEM_AMT:
$ MEM_VA'CNTRLR=200000+20*MEM_TR'CNTRLR		! Bits 24-31 of controller VA
$ WRITE SYS$OUTPUT "Enter amount of memory for this controller in .25 megabyte"
$ INQUIRE MEM_AMOUNT'CNTRLR-
 "increments (for example, for 512 kilobytes, enter .5)"
$ !
$ ! Convert Megabytes to hex value
$ !
$CONVERT_MEM:
$ ! Extract integer
$ MEM_INT'CNTRLR=F$EXTRACT(0,F$LOC(".",MEM_AMOUNT'CNTRLR),MEM_AMOUNT'CNTRLR)
$ ! Extract fraction
$ MEM_FRACT'CNTRLR=F$EXTRACT(F$LOCATE(".",MEM_AMOUNT'CNTRLR)+1,-
 F$LENGTH(MEM_AMOUNT'CNTRLR)-F$LOCATE(".",MEM_AMOUNT'CNTRLR)+1,-
 MEM_AMOUNT'CNTRLR)
$ IF F$LEN(MEM_FRACT'CNTRLR) .EQ. 1 THEN MEM_FRACT'CNTRLR=MEM_FRACT'CNTRLR*10
$ ! Make sure fraction is valid
$ IF MEM_FRACT'CNTRLR .EQS. ""-
 .OR. MEM_FRACT'CNTRLR .EQS. "00" .OR. MEM_FRACT'CNTRLR .EQS. "25"-
 .OR. MEM_FRACT'CNTRLR .EQS. "50" .OR. MEM_FRACT'CNTRLR .EQS. "75"-
 THEN GOTO CONVERT_MEM2
$ WRITE SYS$OUTPUT "Memory amount must be in .25 megabyte increments."
$ GOTO ASK_MEM_AMT
$CONVERT_MEM2:
$ IF MEM_TYPE'CNTRLR .EQS. "MA780" THEN GOTO CONVERT_MEM3
$ IF MEM_INT'CNTRLR .LT. 4 .OR.-
 MEM_INT'CNTRLR .EQS. "4" .AND. MEM_FRACT'CNTRLR .EQS. "" .OR.-
 MEM_INT'CNTRLR .EQS. "4" .AND. MEM_FRACT'CNTRLR .EQS. "0" .OR.-
 MEM_INT'CNTRLR .EQS. "4" .AND. MEM_FRACT'CNTRLR .EQS. "00"-
 THEN GOTO CONVERT_MEM4
$ WRITE SYS$OUTPUT "Memory amount must not exceed 4 megabytes per MS780"
$ GOTO ASK_MEM_AMT
$CONVERT_MEM3:
$ IF MEM_INT'CNTRLR .LT. 2 .OR.-
 MEM_INT'CNTRLR .EQS. "2" .AND. MEM_FRACT'CNTRLR .EQS. "" .OR.-
 MEM_INT'CNTRLR .EQS. "2" .AND. MEM_FRACT'CNTRLR .EQS. "0" .OR.-
 MEM_INT'CNTRLR .EQS. "2" .AND. MEM_FRACT'CNTRLR .EQS. "00"-
 THEN GOTO CONVERT_MEM4
$ WRITE SYS$OUTPUT "Memory amount must not exceed 2 megabytes per MA780"
$ GOTO ASK_MEM_AMT
$CONVERT_MEM4:
$ MEM'CNTRLR=MEM_INT'CNTRLR*%X400000+MEM_FRACT'CNTRLR/25*%X100000 ! Convert
$ !
$ ! Calculate the address following all of the MA780 (and MS780 for RMEM) 
$ !
$ IF MEM_TYPE'CNTRLR .EQS. "MA780" THEN END_MA=END_MA+MEM'CNTRLR
$ IF MEM_TYPE'CNTRLR .EQS. "MS780" THEN END_MS=END_MS+MEM'CNTRLR
$GET_NEXT_MEM:
$ IF CNTRLR .EQ. MAX_CNTRLRS THEN GOTO GET_MEM_END
$ CNTRLR=CNTRLR+1
$ GOTO GET_MEM
$GET_MEM_END:
$ WRITE SYS$OUTPUT ""
$ IF ATTACHED THEN GOTO GET_NOMOD2
$ !
$ ! Determine the TR level of the UBA
$ !
$ A=0
$ UBA_TR=3
$GET_UBA_TR:
$ A=A+1
$ IF A .EQ. CNTRLR THEN GOTO GET_UBA_TR1
$ IF MEM_TR'A .GT. UBA_TR .OR. MEM_TR'A .EQ. UBA_TR THEN UBA_TR=MEM_TR'A+1
$ GOTO GET_UBA_TR
$GET_UBA_TR1:
$ WRITE SYS$OUTPUT-
 "The Unibus Adapter (UBA) is assumed to be at TR level ",UBA_TR
$ INQUIRE UBATR "Enter the TR level of the UBA  (Enter <RETURN> to default)"
$ IF UBATR .NES. "" THEN UBA_TR=UBATR
$ WRITE SYS$OUTPUT ""
$ !
$ ! Get the name of the default boot file for SET DEFBOO.CMD
$ !
$ INQUIRE NAME "Enter the name of the default boot command procedure"
$ IF NAME .EQS. "" THEN GOTO GET_MEM_END
$GET_DEV:
$ WRITE SYS$OUTPUT ""
$ WRITE SYS$OUTPUT "Enter the name of the floppy disk drive you want to use"
$ INQUIRE DEV "(format is ddu:)"
$ IF F$LOC(":",DEV) .EQ. F$LENGTH(DEV) THEN DEV:='DEV':
$ IF F$LENGTH(DEV) .EQ. 4 THEN GOTO OK_DEV
$ WRITE SYS$OUTPUT "Please enter drive in the format ddu: ."
$ GOTO GET_DEV
$OK_DEV:
$ IF F$LOC("CS",DEV) .EQ. F$LENGTH(DEV) THEN GOTO 10$
$CONNECT:
$ RUN SYS$SYSTEM:SYSGEN
CONNECT CONSOLE
$10$:
$ WRITE SYS$OUTPUT ""
$ WRITE SYS$OUTPUT "Insert original console floppy in ",DEV,"."
$ INQUIRE Q  "Ready to continue? (YES or NO)"
$ IF F$EXTRACT(0,1,Q) .NES. "Y" THEN GOTO 10$
$ WRITE SYS$OUTPUT ""
$ ON ERROR THEN CONTINUE
$ MOUNT 'DEV'/FOR/NOWRITE
$ CONSOLE_MOUNTED:=TRUE
$ !
$ ! Create a temporary subdirectory and copy all files to the directory.
$ !
$CRE_DIR:
$ CREATE/DIRECTORY [.TEMPBOOT]
$ STAT=$STATUS .AND. 7
$ SET DEFAULT [.TEMPBOOT]
$ DIR_CREATED:=TRUE
$ PRES_DIR=F$DIRECTORY()
$ IF STAT .EQ. 1 THEN GOTO CRE_DIR1
$ WRITE SYS$OUTPUT "All files in ",PRES_DIR," will be deleted."
$ INQUIRE CRE_QUES "Ready to continue? (YES or NO)"
$ IF F$EXTRACT(0,1,CRE_QUES) .NES. "Y" THEN GOTO EXIT1
$ DELETE *.*;*/LOG
$ CRE_DIR1:
$ MCR FLX CONDIR.TMP='DEV'/RT/LI
$ WRITE SYS$OUTPUT ""
$ WRITE SYS$OUTPUT "Copying console floppy to temporary directory."
$ OPEN/READ DIR_FILE CONDIR.TMP
$ DIR_FILE_OPEN:=TRUE
$NEXT_DIR:
$ READ/END_OF_FILE=DIR_END DIR_FILE DIR_RECORD
$ !
$ ! Ignore all records other than file names.
$ !
$ IF F$LOC(".",DIR_RECORD) .EQ. F$LEN(DIR_RECORD) .OR.-
 F$LOC("-",DIR_RECORD) .EQ. F$LEN(DIR_RECORD) THEN GOTO NEXT_DIR
$ FILE_NAME:='F$EXTRACT(0,10,DIR_RECORD)
$ !
$ ! Ignore diagnostic supervisor boot files and interleave mode files.
$ !
$ IF F$EXTRACT(0,3,DIR_RECORD) .EQS. "WCS"-
 .AND. F$EXTRACT(7,3,DIR_RECORD) .NES. "PAT" THEN GOTO NEXT_DIR
$ IF F$EXTRACT(7,3,DIR_RECORD) .EQS. "PAT"-
 .AND. F$EXTRACT(0,3,DIR_RECORD) .NES. "WCS" THEN GOTO NEXT_DIR
$ IF F$EXTRACT(7,3,DIR_RECORD) .EQS. "ILV" THEN GOTO NEXT_DIR
$ IF F$EXTRACT(3,3,DIR_RECORD) .NES. "BOO" THEN GOTO NEXT_DIR1
$ IF F$EXTRACT(0,2,DIR_RECORD) .EQS. "SM"-
	.OR. F$EXTRACT(0,2,DIR_RECORD) .EQS. "SR"-
	.OR. F$EXTRACT(0,2,DIR_RECORD) .EQS. "SB" THEN GOTO NEXT_DIR
$ !
$ ! Determine if this file should be copied image mode.
$ !
$NEXT_DIR1:
$ RT_SWITCH:="/RT"
$ IF F$EXTRACT(7,3,DIR_RECORD) .EQS. "PAT"-
	.OR. F$EXTRACT(7,3,DIR_RECORD) .EQS. "BIN"-
	.OR. F$EXTRACT(7,3,DIR_RECORD) .EQS. "EXE"-
	.OR. F$EXTRACT(7,3,DIR_RECORD) .EQS. "VN0"-
	.OR. F$EXTRACT(7,3,DIR_RECORD) .EQS. "SYS" THEN RT_SWITCH:="/RT/IM"
$ ON ERROR THEN CONTINUE
$ MCR FLX /RS='DEV''FILE_NAME''RT_SWITCH
$ GOTO NEXT_DIR
$ !
$DIR_END:
$ CLOSE DIR_FILE
$ DIR_FILE_OPEN:=FALSE
$ DELETE CONDIR.TMP;*
$DIR_END1:
$ IF F$SEARCH(NAME) .EQS. "" THEN GOTO NO_DEF
$ GOTO DIR_END2
$NO_DEF:
$ WRITE SYS$OUTPUT "Unable to locate ",NAME
$ INQUIRE NAME "What is the name of the default bootstrap command procedure"
$ GOTO DIR_END1
$DIR_END2:
$ !
$ ! Copy a V3.0 VMB.EXE (since this command procedure will only
$ ! work on a V3.0 system, SYS$SYSTEM:VMB.EXE should be V3.0 version).
$ !
$ WRITE SYS$OUTPUT "Copying VMS V3 VMB.EXE from SYS$SYSTEM."
$ WRITE SYS$OUTPUT " (11/782 requires a V3 VMB in order to use MA780 memory.)"
$ COPY SYS$SYSTEM:VMB.EXE *
$ PURGE VMB.EXE
$ DISMOUNT 'DEV'
$ WRITE SYS$OUTPUT ""
$ WRITE SYS$OUTPUT "Please remove original floppy from ",DEV,"."
$ CONSOLE_MOUNTED:=FALSE
$ IF ATTACHED THEN GOTO GET_NOMOD2
$ !
$ ! Make a DEFBOO command file for the primary processor.
$ !
$ COPY 'NAME' DEFBOO.CMD
$ PURGE DEFBOO.CMD
$ !
$ ! Get a directory of the files to be copied without modification.
$ !
$GET_NOMOD:
$ DIRECTORY/OUTPUT=NOMODIR.TMP/NOHEAD/NOTRAIL -
 /EXCLUDE=(D*GEN.*,D*XDT.*,D*BOO.CMD,CIBOO.CMD,CIGEN.,CIXDT,-
 RESTAR.CMD,DEFBOO.CMD,NOMODIR.TMP)
$ GOTO MOUNT_NEW
$GET_NOMOD2:
$ !
$ ! Duplicate all files for attached.
$ !
$ DIRECTORY/OUTPUT=NOMODIR.TMP/NOHEAD/NOTRAIL/EXCLUDE=NOMODIR.TMP
$ !
$ ! Now mount the new floppy and run BAD.
$ !
$MOUNT_NEW:
$ WRITE SYS$OUTPUT ""
$ WRITE SYS$OUTPUT ""
$ IF PRIMARY THEN WRITE SYS$OUTPUT "Creating floppy for primary processor."
$ IF ATTACHED THEN WRITE SYS$OUTPUT "Creating floppy for attached processor."
$ WRITE SYS$OUTPUT ""
$ WRITE SYS$OUTPUT "Place a scratch floppy in ",DEV,"."
$ASK_READY:
$ WRITE SYS$OUTPUT "WARNING - ",DEV," will be initialized."
$ INQUIRE QUES "Ready to continue? (YES or NO)"
$ IF F$EXTRACT(0,1,QUES) .NES. "Y" THEN GOTO ASK_READY
$ WRITE SYS$OUTPUT ""
$ INIT 'DEV' CONSOLE
$ MOUNT/FOR 'DEV' CONSOLE
$ CONSOLE_MOUNTED:=TRUE
$ WRITE SYS$OUTPUT ""
$ WRITE SYS$OUTPUT "Running BAD on ",DEV,"."
$ MCR BAD 'DEV'
$ MCR FLX 'DEV'/RT/ZE
$ !
$ ! Copy the files that will not be modified to the new console floppy
$ ! Delete them from the temporary directory as they are copied.
$ !
$ WRITE SYS$OUTPUT ""
$ WRITE SYS$OUTPUT "Copying unmodified files to ",DEV,"."
$ WRITE SYS$OUTPUT ""
$ OPEN/READ NOMOD_DIR NOMODIR.TMP
$ NOMOD_DIR_OPEN:=TRUE
$ NEXT_NOMOD_FILE:
$ READ/END_OF_FILE=NOMOD_DONE NOMOD_DIR NOMOD_FILE
$ FILE:='F$EXTRACT(F$LOCATE("]",NOMOD_FILE)+1,-
 F$LENGTH(NOMOD_FILE)-F$LOCATE("]",NOMOD_FILE)+1,NOMOD_FILE)
$ !
$ ! Ignore null records.
$ !
$ IF F$LOCATE(".",FILE) .EQ. F$LENGTH(FILE) THEN GOTO NEXT_NOMOD_FILE
$ !
$ ! Determine if file should be copied image mode.
$ !
$ RT_SWITCH:="/RS"
$ IF F$LOCATE(".PAT",FILE) .NE. F$LENGTH(FILE)-
	.OR. F$LOCATE(".BIN",FILE) .NE. F$LENGTH(FILE)-
	.OR. F$LOCATE(".EXE",FILE) .NE. F$LENGTH(FILE)-
	.OR. F$LOCATE(".VN0",FILE) .NE. F$LENGTH(FILE)-
	.OR. F$LOCATE(".SYS",FILE) .NE. F$LENGTH(FILE) THEN RT_SWITCH:="/RS/IM"
$RESTOR_NOMOD:
$ MCR FLX 'DEV'/RT='FILE''RT_SWITCH
$ WRITE SYS$OUTPUT "Copied		",FILE
$ GOTO NEXT_NOMOD_FILE
$ !
$NOMOD_DONE:
$ CLOSE NOMOD_DIR
$ NOMOD_DIR_OPEN:=FALSE
$ DELETE NOMODIR.TMP;*
$ !
$ ! Get a directory of the remaining files which will be
$ ! modified for multiprocessor use.
$ !
$ WRITTEN:=FALSE
$ IF ATTACHED THEN GOTO CREAT
$ DIRECTORY/OUTPUT=MODIR.TMP/NOHEAD/NOTRAIL -
 D*GEN.*,D*XDT.*,D*BOO.CMD,CIBOO.CMD,CIGEN.,CIXDT.,RESTAR.CMD
$ GOTO MOD_FILES
$ !
$ ! If building for the attached, create dummy files to be modified.
$ !
$CREAT:
$ CREATE MODIR.TMP
[*]DEFBOO.CMD
[*]RESTAR.CMD
$ CREATE DEFBOO.CMD
			!
HALT			! HALT PROCESSOR
UNJAM			! UNJAM PROCESSOR
INIT			! INIT PROCESSOR
EXAMINE 100		! GET STARTING ADDRESS
START 100		! AND GO THERE
$ COPY DEFBOO.CMD RESTAR.CMD			! RESTAR is same as DEFBOO
$ !
$ ! Now modify the remaining files for multiprocessor use and
$ ! copy them to the floppy.  Delete the files from the
$ ! temporary directory as they are copied.
$ !
$MOD_FILES:
$ WRITE SYS$OUTPUT ""
$ WRITE SYS$OUTPUT "Creating multiprocessor bootstrap command procedures."
$ WRITE SYS$OUTPUT ""
$ OPEN/READ MOD_DIR MODIR.TMP
$ MOD_DIR_OPEN:=TRUE
$NEXT_MOD_FILE:
$ READ/END_OF_FILE=MOD_DIR_DONE MOD_DIR MOD_FILE
$ FILE:='F$EXTRACT(F$LOCATE("]",MOD_FILE)+1,-
 F$LENGTH(MOD_FILE)-F$LOCATE("]",MOD_FILE)+1,MOD_FILE)
$ OPEN/READ OLD_FILE 'FILE
$ OLD_FILE_OPEN:=TRUE
$ OPEN/WRITE NEW_FILE NEWCMD.TMP
$ NEW_FILE_OPEN:=TRUE
$ !
$ ! Add comments describing floppy and memory configuration.
$ !
$ WRITE NEW_FILE "!"
$ IF PRIMARY THEN GOTO PRIM_COM
$ WRITE NEW_FILE "!	11/782 ATTACHED PROCESSOR BOOT COMMAND FILE - ",FILE
$ WRITE NEW_FILE "!"
$ WRITE NEW_FILE-
 "!	COMMAND FILES RESTAR.CMD AND DEFBOO.CMD ARE ESSENTIALY "
$ WRITE NEW_FILE-
 "!	THE SAME.  THIS FILE CAN BE INVOKED MANUALLY WITH THE COMMAND:"
$ WRITE NEW_FILE "!			@",FILE
$ WRITE NEW_FILE "!"
$ WRITE NEW_FILE-
 "!	THIS COMMAND FILE CAN ONLY BE USED FOR THE ATTACHED PROCESSOR"
$ WRITE NEW_FILE "!	ON A TIGHTLY-COUPLED MULTI-PROCESSING SYSTEM"
$ GOTO COMMON_COM
$PRIM_COM:
$ WRITE NEW_FILE "!	11/782 PRIMARY PROCESSOR BOOT COMMAND FILE - ",FILE
$ WRITE NEW_FILE "!"
$ WRITE NEW_FILE "!	MULTI-PROCESSING BOOT, USING ONLY MULTI-PORT MEMORY."
$COMMON_COM:
$ WRITE NEW_FILE "!"
$ WRITE NEW_FILE "!	THIS ASSUMES THAT THERE IS:"
$ WRITE NEW_FILE "!"
$ A=0
$10$:
$ A=A+1
$ IF A .GT. MAX_CNTRLRS THEN GOTO END_MEM
$ IF MEM_TYPE'A .EQS. "" THEN GOTO 10$
$ IF MEM_TYPE'A .NES. "MS780" THEN GOTO NOT_MS
$ WRITE NEW_FILE-
 "!		LOCAL MEMORY AT TR #",MEM_TR'A," (",MEM_AMOUNT'A,"MB)"
$ GOTO 10$
$NOT_MS:
$ WRITE NEW_FILE -
   "!		MULTI-PORT MEMORY AT TR #",MEM_TR'A," (",MEM_AMOUNT'A,"MB)"
$ GOTO 10$
$END_MEM:
$ !
$ ! Read each record of the original file and delete or add
$ ! records to make the necessary modifications.
$ !
$NEXT_RECORD:
$ READ/END_OF_FILE=EN_MOD OLD_FILE RECORD
$ CHAR= F$EXTRACT(0,1,RECORD)
$ !
$ ! Records that contain only comments are copied as is.
$ !
$ IF CHAR .EQS. "!" THEN GOTO WRITE_RECORD
$ !
$ ! All other comments are shifted right one tab for neatness.
$ !
$ RECORD=F$EXTRACT(0,F$LOCATE("!",RECORD),RECORD)-
 +"	"-
 +F$EXTRACT(F$LOCATE("!",RECORD),F$LENGTH(RECORD)-F$LOCATE("!",RECORD),-RECORD)
$ IF CHAR .EQS. "D" THEN GOTO CHECK_D				! Deposit
$ IF CHAR .EQS. "S" THEN GOTO CHECK_S				! Start
$ IF CHAR .EQS. "I" .AND. ATTACHED THEN GOTO CHECK_INIT		! Init
$WRITE_RECORD:
$ WRITE NEW_FILE RECORD
$ GOTO NEXT_RECORD
$ !
$ ! Check for DEPOSIT R5 or DEPOSIT SP.
$ !
$CHECK_D:
$ IF F$LEN(RECORD) .EQ. F$LOC(" R5 ",RECORD) THEN GOTO CHECK_D2
$ !
$ ! "OR IN" the multiport software flag with the flags that are selected in the
$ ! original file.  If multiport flag is already set then abort.
$ !
$ STRING=F$EXTRACT(F$LOC("!",RECORD)+4,F$LEN(RECORD)-F$LOC("!",RECORD)+4,-
 RECORD)
$ SFLAGS=F$EXTRACT(0,F$LOC("	",STRING),STRING)
$ NEW_SFLAGS=%X'SFLAGS
$ NEW_SFLAGS=NEW_SFLAGS .OR. %X800
$ NEW_SFLAGS=NEW_SFLAGS .AND. %XFFFFBFFF
$ NEW_SFLAGS=F$FAO("!XL",NEW_SFLAGS)
$ IF NEW_SFLAGS .NE. SFLAGS THEN GOTO CHECK_D1
$ WRITE SYS$OUTPUT "BOOTBLDR has detected multiprocessor bootfile ",FILE
 on the original floppy - Procedure aborted..."
$ CLOSE OLD_FILE
$ CLOSE NEW_FILE
$ DEL 'FILE
$ DEL NEWCMD.TMP;
$ GOTO BOTH_DONE
$CHECK_D1:
$ WRITE NEW_FILE-
 "DEPOSIT R5 ",NEW_SFLAGS,"		! SOFTWARE BOOT FLAGS
$ GOTO NEXT_RECORD
$ !
$ ! Replace DEPOSIT R1 3 with DEPOSIT R1 'UBA_TR
$ !
$CHECK_D2:
$ IF F$LOCATE("R1 3",RECORD) .EQ. F$LEN(RECORD) THEN GOTO CHECK_D3
$ WRITE NEW_FILE-
 "DEPOSIT R1 ",UBA_TR
$ GOTO NEXT_RECORD
$ !
$ ! Remove SP DEPOSITS to be replaced with DEPOSIT SP 200
$ !
$CHECK_D3:
$ IF F$LOCATE("SP",RECORD) .EQ. F$LEN(RECORD) THEN GOTO CHECK_FP
$ GOTO NEXT_RECORD
$ !
$ ! Add memory setup instructions after INIT for attached.
$ !
$CHECK_INIT:
$ WRITE NEW_FILE RECORD
$ GOTO WRITE_MP
$ !
$ ! Add memory setup instructions after DEPOSIT FP for primary.
$ !
$CHECK_FP:

$ IF F$LOCATE(" FP ",RECORD) .EQ. F$LEN(RECORD) THEN GOTO DEP_MEM
$ WRITE NEW_FILE RECORD
$ IF WRITTEN THEN GOTO NEXT_RECORD
$WRITE_MP:
$ WRITTEN:=TRUE
$ A=0
$ TOTAL_MS=0			! Running total of MS780 memory in hex
$ TOTAL_MA=0			! Running total of MA780 memory in hex
$ MA_INT=0			! MA780 starting address in Megs (INTEGER)
$ MA_FRAC=0			! MA780 starting address in Megs (FRACTION)
$10$:
$ A=A+1
$ IF A .GT. MAX_CNTRLRS THEN GOTO END_FP
$ IF MEM_TYPE'A .EQS. "" THEN GOTO 10$
$ MSTART=END_MA+TOTAL_MS
$ !
$ ! MS_START = starting address for MS780 in formated hex longword
$ ! shifted right three places, plus enable write starting address bit.
$ !
$ MS_START=F$FAO("!XL",MSTART/%X4+%X4000)
$ IF MEM_TYPE'A .NES. "MS780" THEN GOTO SET_MA
$ WRITE NEW_FILE "DEPOSIT ",MEM_VA'A,"00 00400100",-
 "	! CLEAR POWER UP AND INTRLV BITS IN MS780 (TR #",MEM_TR'A,")"
$ WRITE NEW_FILE "DEPOSIT ",MEM_VA'A,"04 ",MS_START,-
 "	! SET LOCAL MEMORY OUT OF THE WAY (TR #",MEM_TR'A,")"
$ TOTAL_MS=TOTAL_MS+MEM'A	! Add this controller's memory to running total
$ GOTO 10$
$SET_MA:
$ !
$ ! MA_START = starting address for MA780 in formated hex longword,
$ ! plus ID 0 bit.
$ !
$ MA_START=F$FAO("!XL",TOTAL_MA+1)
$ WRITE NEW_FILE "DEPOSIT ",MEM_VA'A,"00 00400000",-
 "	! CLEAR POWER UP BIT IN MA780 (TR #",MEM_TR'A,")"
$ WRITE NEW_FILE "DEPOSIT ",MEM_VA'A,"04 FF000000",-
 "	! CLEAR ERROR BITS IN MA780 (TR #",MEM_TR'A,")"
$ WRITE NEW_FILE "DEPOSIT ",MEM_VA'A,"08 D000C000",-
 "	! CLEAR ERROR BITS IN MA780 (TR #",MEM_TR'A,")"
$ WRITE NEW_FILE "DEPOSIT ",MEM_VA'A,"10 80000000",-
 "	! CLEAR ERROR BITS IN MA780 (TR #",MEM_TR'A,")"
$ WRITE NEW_FILE "DEPOSIT ",MEM_VA'A,"0C ",MA_START,-
 "	! SET MA780 TO START AT ",MA_INT,".",MA_FRAC,"MG (TR #",MEM_TR'A,")"
$ !
$ ! Calc next controller's starting adr in Megs.
$ !
$ MA_INT=MA_INT+MEM_INT'A
$ MA_FRAC=MA_FRAC+MEM_FRACT'A
$ IF MA_FRAC .GT. 100 THEN MA_INT=MA_INT+1
$ IF MA_FRAC .GT. 100 THEN MA_FRAC=MA_FRAC-100
$ !
$ ! Calc next controller's starting adr in hex.
$ !
$ TOTAL_MA=TOTAL_MA+MEM'A
$ GOTO 10$
$ !
$ ! Add deposit to SP instruction.
$ !
$END_FP:
$ WRITE NEW_FILE "DEPOSIT SP 200			! SET BASE ADDRESS"
$ GOTO NEXT_RECORD
$ !
$ ! Check for Deposit to local memory VA or /I 11.
$ ! If found, do not include in output file.
$ !
$DEP_MEM:
$ A=0
$10$:
$ A=A+1
$ IF A .GT. MAX_CNTRLRS THEN GOTO CHECK_I
$ IF MEM_TYPE'A .EQS. "" THEN GOTO 10$
$ IF MEM_TYPE'A .NES. "MS780" THEN GOTO 10$
$ IF F$LOCATE(MEM_VA'A,RECORD) .EQ. F$LEN(RECORD) THEN GOTO 10$
$ GOTO NEXT_RECORD
$CHECK_I:
$ IF F$LOCATE("/I 11",RECORD) .EQ. F$LEN(RECORD) THEN GOTO WRITE_RECORD
$ GOTO NEXT_RECORD
$ !
$ ! Check for START 20003000 followed by WAIT DONE
$ !
$CHECK_S:
$ IF F$LOCATE("20003000",RECORD) .EQ. F$LENGTH(RECORD) THEN GOTO CHECK_S2
$ OLD_RECORD:=RECORD
$ READ/END_OF_FILE=EN_MOD OLD_FILE RECORD
$ IF F$LOCATE("DONE",RECORD) .NE. F$LENGTH(RECORD) THEN GOTO NEXT_RECORD
$ WRITE NEW_FILE OLD_RECORD
$ GOTO WRITE_RECORD
$ !
$ ! Check for START 20003004
$ !
$CHECK_S2:
$ IF F$LOCATE("20003004",RECORD) .EQ. F$LEN(RECORD) THEN GOTO WRITE_RECORD
$ WRITE NEW_FILE "EXAMINE 4			! GET RESTART ADDRESS FROM RPB"
$ WRITE NEW_FILE "START @				! AND START IT"
$ GOTO NEXT_RECORD
$ !
$ ! Write the modified file out to the floppy.
$ !
$EN_MOD:
$ CLOSE OLD_FILE
$ OLD_FILE_OPEN:=FALSE
$ CLOSE NEW_FILE
$ NEW_FILE_OPEN:=FALSE
$ IF F$LOCATE(";",FILE) .EQ. F$LENGTH(FILE) THEN FILE:='FILE'";"
$ DELETE 'FILE
$ RENAME NEWCMD.TMP 'FILE
$ MCR FLX 'DEV'/RT='FILE/RS
$ WRITE SYS$OUTPUT "Created		",FILE
$ DELETE 'FILE
$ WRITTEN:=FALSE
$ GOTO NEXT_MOD_FILE
$ !
$ ! All files modified.
$ !
$MOD_DIR_DONE:
$ CLOSE MOD_DIR
$ DELETE MODIR.TMP;*
$ MOD_DIR_OPEN:=FALSE
$ !
$ ! Now build RMEM.
$ !
$ OPEN/WRITE NEW_FILE RMEM.
$ NEW_FILE_OPEN:=TRUE
$ WRITE NEW_FILE "!"
$ WRITE NEW_FILE "! COMMAND FILE TO RESET MEMORY CONTROLLER RESTART ADDRESSES."
$ WRITE NEW_FILE "!"
$ A=0
$ TOTAL_MS=0		! Running total of MS780 memory in hex.
$ TOTAL_MA=0		! Running total of MA780 memory in hex.
$ MS_START=0
$ MS_INT=0		! Starting adr of MS780 memory in Megs. (INTEGER)
$ MS_FRAC=0		! Starting adr of MS780 memory in Megs. (FRACTION)
$RMEM_LOOP:
$ A=A+1
$ IF A .GT. MAX_CNTRLRS THEN GOTO END
$ IF MEM_TYPE'A .EQS. "" THEN GOTO RMEM_LOOP
$ IF MEM_TYPE'A .EQS. "MA780" THEN GOTO RMEM2
$ !
$ ! MS_START = starting address for MS780 in formated hex longword
$ ! shifted right three places, plus enable write starting address bit.
$ !
$ MS_START=F$FAO("!XL",TOTAL_MS/%X4+%X4000)
$ WRITE NEW_FILE "DEPOSIT ",MEM_VA'A,"04 ",MS_START,-
 "	! SET LOCAL MEMORY TO START AT ",MS_INT,".",MS_FRAC,-
 "MG (TR #",MEM_TR'A,")"
$ !
$ ! Calc starting adr for next controller in Megs
$ !
$ MS_INT=MS_INT+MEM_INT'A	
$ MS_FRAC=MS_FRAC+MEM_FRACT'A
$ IF MS_FRAC .GT. 100 THEN MS_INT=MS_INT+1
$ IF MS_FRAC .GT. 100 THEN MS_FRAC=MS_FRAC-100
$ !
$ ! Calc starting adr for next controller in hex.
$ !
$ TOTAL_MS=TOTAL_MS+MEM'A
$ GOTO RMEM_LOOP
$RMEM2:
$ MASTART=END_MS+TOTAL_MA		! Starting address of MA780 in hex.
$ !
$ ! MA_START = Starting address of MA780 in formated hex longword,
$ ! plus ID bit 0.
$ !
$ MA_START=F$FAO("!XL",MASTART+1)
$ WRITE NEW_FILE "DEPOSIT ",MEM_VA'A,"0C ",MA_START, -
  "	! SET MA780 OUT OF THE WAY (TR #",MEM_TR'A,")"
$ ! Add memory on this controller to running total.
$ TOTAL_MA=TOTAL_MA+MEM'A
$ GOTO RMEM_LOOP
$END:
$ CLOSE NEW_FILE
$ NEW_FILE_OPEN:=FALSE
$ MCR FLX 'DEV'/RT=RMEM.;1/RS
$ WRITE SYS$OUTPUT "Created		RMEM.;1"
$ DELETE RMEM.;1
$ !
$ ! Write RT-11 bootblock on floppy.
$ !
$ DEFINE/USER RTB$INPUT CONSOL.SYS
$ DEFINE/USER RTB$OUTPUT 'DEV'
$ RUN SYS$SYSTEM:RTB
$ WRITE SYS$OUTPUT ""
$ WRITE SYS$OUTPUT "11/782 bootblock written."
$ WRITE SYS$OUTPUT ""
$ DISMOUNT 'DEV'
$ CONSOLE_MOUNTED:=FALSE
$ IF PRIMARY THEN WRITE SYS$OUTPUT-
 "Primary processor console floppy completed."
$ IF ATTACHED THEN WRITE SYS$OUTPUT-
 "Attached processor console floppy completed."
$ WRITE SYS$OUTPUT ""
$ WRITE SYS$OUTPUT ""
$ WRITE SYS$OUTPUT ""
$CLEANUP:
$ IF ATTACHED THEN GOTO BOTH_DONE
$ PRIMARY := FALSE
$ ATTACHED := TRUE
$ WRITE SYS$OUTPUT "Enter memory configuration for attached processor."
$ WRITE SYS$OUTPUT ""
$ WRITE SYS$OUTPUT "MA780 memory must be identical on both processors."
$ WRITE SYS$OUTPUT "MS780 (local) memory may be different."
$ WRITE SYS$OUTPUT ""
$ GOTO ATTACHED_BEGIN
$BOTH_DONE:
$ ON ERROR THEN CONTINUE
$ ON CONTROL_Y THEN CONTINUE
$ IF DIR_FILE_OPEN THEN CLOSE DIR_FILE
$ IF NOMOD_DIR_OPEN THEN CLOSE NOMOD_DIR
$ IF MOD_DIR_OPEN THEN CLOSE MOD_DIR
$ IF OLD_FILE_OPEN THEN CLOSE OLD_FILE
$ IF NEW_FILE_OPEN THEN CLOSE NEW_FILE
$ IF CONSOLE_MOUNTED THEN DISMOUNT 'DEV'
$ SET DEFAULT 'SAVEDEF
$ IF .NOT. DIR_CREATED THEN GOTO RESTORE_PRIVS
$ DELETE [.TEMPBOOT]*.*;*
$ SET PROT=(OWNER:RWED) TEMPBOOT.DIR
$ DELETE TEMPBOOT.DIR;*
$RESTORE_PRIVS:
$ SET PROC/PRIV=('SAVED_PRIVS')
$EXIT:
$ EXIT
$EXIT1:
$ SET DEFAULT 'SAVEDEF
$ EXIT
