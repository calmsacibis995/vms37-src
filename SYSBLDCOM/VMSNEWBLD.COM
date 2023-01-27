$ !
$ !	[ SYSBLDCOM ] V M S N E W B L D . C O M
$ !
$ !	This is the batch command file to build VMS.
$ !	It is submitted with the following parameters:
$ !
$ !	PHASES = P1 (Required)	The phases of a system build
$ !				that this run will execute.
$ !				The format is "startphase:endphase".
$ !				END is the phase beyond RESULT.
$ !
$ !	START = P2 (Required)	The name of the component with
$ !				which this build run will begin.
$ !				"BEGIN" is the start everything
$ !				label, "END" is the label beyond
$ !				the last component.
$ !
$ !	END = P3 (Required)	The name of the last component in
$ !				this build run. See above note on
$ !				START parameter.
$ !
$ !	TARGET = P4 (Required)	The device names of the target
$ !				 for this build.
$ !
$ !	INDEV = P5 (Required)	The device name of the source and
$ !				command files.
$ !
$ !	OPTIONS = P6 (Optional)	List of options:
$ !			R -	Restart specifies that the build should
$ !				insulate itself from crashes.  Only one
$ !				copy of this procedure may use this
$ !				option at a time.
$ !			S -	Set when the current invocation was
$ !				invoked by this procedure.
$ !
$ !			I -	Set if build is in place; i.e., if the
$ !				target disk is the same as the source.
$ !
$ !			B - 	Set if this is a BUG build; i.e., if
$ !				BUG update packets, etc., are to be used.
$ !
$ !			Pn -	Sets the process priority of the build.
$ !				The digit following P specifies the priority.
$ !				If not specified, the default job priority of
$ !				the batch job queue is used (INIT/PRIO).
$ !
$ !	BLDFIL	= P7 (Optional)	Name of file containing list of
$ !				facilities to rebuild.  The default
$ !				file is SYSBLDCOM$:VMSNEWBLD.DAT.
$ !
$ !
$ !	The phases of a system build are:
$ !
$ !	INIT	Set up directories and or copy files
$ !
$ !	UPDATE	Update the master source with SLP changes
$ !
$ !	SRCLIB	Construct source libraries using MDL and create
$ !		macro libraries etc.
$ !
$ !	ASSEM	Assemble all sources.
$ !
$ !	OBJLIB	Create all object libraries.
$ !
$ !	LNKLIB	Create shareable images and insert into IMAGELIB
$ !
$ !	LINK	Link all images.
$ !
$ !	RESULT	Put the results of the build in consolidated
$ !		accounts for the distribution kit building
$ !		process.
$ !
$ !	If this build is doing all components (i.e. START="BEGIN"
$ !	and END="END"), then the assembly and link phases are done
$ !	by recursively calling this procedure with the appropriate
$ !	parameters several times to create multiple batch streams.
$ !
$ !
$ DEFINE SYS$PRINT NOWHERE	! DO NOT PRINT OR DELETE THE LOG
$ SHOW DAYTIME
$ !
$ !	SET JOB CONDITIONS FOR SYSTEM BUILD
$ !
$ SET PROT=(S:RW,O:RWED,G:R,W:R)/DEFAULT ! For all newly created files
$ COPY :== COPY/PROTECTION=(O:RWED)	! When copying from master disk files
$					! without delete access.
$ !
$ !	ACCEPT INPUT PARAMETERS AND APPLY DEFAULTS
$ !
$ L1='F$LOCATE(":",P1)
$ PHASE:='F$EXTRACT(0,L1,P1)
$ IF PHASE .NES. "LNKLIB" -
	.AND. PHASE .NES. "LINK" THEN GOTO GETENDPHASE
$ LINK :== LINK /USERLIB=PROC		!Only use process library
$ DEFINE LNK$LIBRARY SYS$LIBRARY:SYSBLDLIB
$GETENDPHASE:
$ L1=L1+1
$ L2='F$LENGTH(P1)-L1
$ IF L2 .GT. 0 THEN ENDPHASE:='F$EXTRACT(L1,L2,P1)
$ IF L2 .LE. 0 THEN ENDPHASE:='PHASE'
$ START:='P2'
$ END:='P3'
$ TARGDEV:='P4'
$ INDEV:='P5'
$ OPTIONS:='P6'
$ BLDFIL:='P7'
$ IF BLDFIL .EQS. "" THEN BLDFIL := SYSBLDCOM$:VMSNEWBLD.DAT
$ RESTART := N
$ IF 'F$LOCATE("R",OPTIONS) .NE. 'F$LENGTH(OPTIONS) THEN RESTART := Y
$ SUB := N
$ IF 'F$LOCATE("S",OPTIONS) .NE. 'F$LENGTH(OPTIONS) THEN SUB := Y
$ INPLACE := N
$ IF 'F$LOCATE("I",OPTIONS) .NE. 'F$LENGTH(OPTIONS) THEN INPLACE := Y
$ BUGBUILD := N
$ IF 'F$LOCATE("B",OPTIONS) .NE. 'F$LENGTH(OPTIONS) THEN BUGBUILD := Y
$ IF F$LOCATE("P",OPTIONS) .NE. F$LENGTH(OPTIONS) THEN -
	SET PROCESS/PRIORITY='F$EXTRACT(F$LOCATE("P",OPTIONS)+1,1,OPTIONS)'
$ DELETE/SYMBOL P1
$ DELETE/SYMBOL P2
$ DELETE/SYMBOL P3
$ DELETE/SYMBOL P4
$ DELETE/SYMBOL P5
$ DELETE/SYMBOL P6
$ DELETE/SYMBOL P7
$ DELETE/SYMBOL P8
$ !
$ !	DEFINE SOURCE UPDATE FUNCTIONS
$ !
$ UPDATES:=(ENH)			! assume ENH build
$ IF BUGBUILD THEN UPDATES:=(BUG)	! If BUG build, use bug updates only
$ SRCUPDATE:=@SYSBLDCOM$:SRCUPDATE	! Merge SLP files into sources
$ !
$ !	DEFINE LOGICAL NAMES USED BY THE COMPONENT BUILD PROCEDURES
$ !
$ @SYSBLDCOM$:BLDLOGNAM 'TARGDEV' 'INDEV' 'INPLACE'
$ !
$ !	DEFINE RESULT PHASE COPY FUNCTIONS
$ !
$ @SYSBLDCOM$:CPYRESDEF		! DEFINE THE RESULT PHASE COPY FUNCTIONS
$ !
$ ! WHEN CPYOLB HAS THE VALUE "Y" SOME FACILITIES WILL COPY THEIR OBJECT
$ ! LIBRARIES TO RESOBJ$:.  ALL FACILITIES WHICH SHARE OBJECT MODULES
$ ! WITH OTHER FACILITIES AND ALL THAT LINK WITH THE EXEC SYMBOL TABLE
$ ! SHOULD COPY THEIR OBJECT LIBRARIES IF THIS GLOBAL FLAG IS SET.
$ !
$ CPYOLB:="N"
$ IF PHASE .EQS. "OBJLIB" THEN CPYOLB:="Y"
$ !
$ !	COPY LIBRARY FILES NEEDED FOR BUILD COMPILES
$ !
$ IF PHASE .NES. "INIT" .OR. START .NES. "BEGIN" .OR. END .NES. "END" -
	 THEN GOTO LIB_OK
$ SET NOON
$ CPYRES SYS$LIBRARY: 'INDEV'[SYSLIB]XPORT.OLB		! For RUNOFF
$ BLISS/LIBRARY=SYS$LIBRARY:XPORT.L32 -			! For RUNOFF
	/NOLISTING -
	'INDEV'[SYSLIB]XPORT.REQ
$ CPYRES SYS$LIBRARY: 'INDEV'[SYSLIB]PLISYSDEF.TLB
$ CPYRES SYS$LIBRARY: 'INDEV'[SYSLIB]PL1RTLIB.OLB
$ CPYRES SYS$LIBRARY: 'INDEV'[SYSLIB]LIBDEF.PAS
$ CPYRES SYS$LIBRARY: 'INDEV'[SYSLIB]MTHDEF.PAS
$ CPYRES SYS$LIBRARY: 'INDEV'[SYSLIB]PASDEF.PAS
$ CPYRES SYS$LIBRARY: 'INDEV'[SYSLIB]SIGDEF.PAS
$ CPYRES SYS$LIBRARY: 'INDEV'[SYSLIB]RMSMAC.MLB
$ CPYRES SYS$LIBRARY: 'INDEV'[SYSLIB]RMSLIB.OLB
$ SET ON
$LIB_OK:
$ !
$ !	Begin the first phase
$ !
$START_PHASE:
$ IF SUB .OR. .NOT.RESTART THEN GOTO DONTAUTO
$ OPEN/WRITE AUTO$ SYS$LOGIN:VMSACTBLD.TMP
$ RECORD:="$ ASSIGN/GROUP I STOP_BUILD		! Initialize logical name"
$ WRITE AUTO$ RECORD
$ RECORD:="$ DEASSIGN/GROUP STOP_BUILD"
$ WRITE AUTO$ RECORD
$ RECORD:="$ DEFINE/USER SYS$LOGIN ''F$LOGICAL("SYS$LOGIN")'"
$ WRITE AUTO$ RECORD
$ RECORD:="$ SUBMIT MASD$:[SYSBLDCOM]VMSNEWBLD/NAME=ACTBUILD -"
$ WRITE AUTO$ RECORD
$ RECORD:="	/QUEUE=SYS$BUILD -"
$ WRITE AUTO$ RECORD
$ RECORD:="	/PARAM=("'PHASE':'ENDPHASE'","'START'","'END'","'TARGDEV'", -"
$ WRITE AUTO$ RECORD
$ RECORD:="		"'INDEV'","'OPTIONS'","'BLDFIL'")"
$ WRITE AUTO$ RECORD
$ CLOSE AUTO$
$ RENAME SYS$LOGIN:VMSACTBLD.TMP SYS$LOGIN:VMSACTBLD.COM
$ PURGE SYS$LOGIN:VMSACTBLD.COM
$DONTAUTO:
$ IF PHASE .EQS. "END" THEN GOTO RESULT
$ !
$ !	SPAWN EXTRA JOBS IF NECESSARY
$ !
$ IF START .NES. "BEGIN" .OR. END .NES. "END" THEN GOTO BEGIN
$ OPEN DATA$ 'BLDFIL'
$ JOBS = 0
$RESET_FIRST:
$ FIRST := ""
$ SET NOVERIFY
$FIND_SPLIT:
$ READ DATA$ RECORD /END=NO_SPLIT
$ L = 'F$LOCATE("	",RECORD)
$ IF L .GT. 'F$LOCATE(" ",RECORD) THEN L = 'F$LOCATE(" ",RECORD)
$ IF "''F$EXTRACT(0,6,RECORD)" .EQS. "!SPLIT" .AND -
	'F$LOC(PHASE,RECORD) .NE. 'F$LEN(RECORD) THEN GOTO SPLIT
$ IF "''F$EXTRACT(0,1,RECORD)" .EQS. "!" THEN GOTO FIND_SPLIT
$ LAST := 'F$EXTRACT(0,L,RECORD)
$ IF FIRST .EQS. "" THEN FIRST := 'LAST
$ GOTO FIND_SPLIT
$SPLIT:
$ SET VERIFY
$ JOBS = JOBS + 1
$ SUBMIT SYSBLDCOM$:VMSNEWBLD -
	/NAME='PHASE''JOBS' -
	/QUEUE=SYS$BUILD -
	/PARAM=('PHASE','FIRST','LAST','TARGDEV','INDEV',S'OPTIONS','BLDFIL')
$ GOTO RESET_FIRST
$NO_SPLIT:
$ SET VERIFY
$ CLOSE DATA$
$ IF JOBS .EQ. 0 THEN GOTO BEGIN
$ IF FIRST .EQS. "" THEN GOTO WAIT_FOR_JOBS
$ JOBS = JOBS + 1
$ SUBMIT SYSBLDCOM$:VMSNEWBLD -
	/NAME='PHASE''JOBS' -
	/QUEUE=SYS$BUILD -
	/PARAM=('PHASE','FIRST',END,'TARGDEV','INDEV',S'OPTIONS','BLDFIL')
$ !
$ !	WAIT FOR SPAWNED JOBS TO COMPLETE
$ !
$WAIT_FOR_JOBS:
$ SET PROCESS/NAME=BUILD_MASTER
$ N = 0
$ IF SUB .OR. (PHASE .NES. "ASSEM") THEN GOTO WAIT_LOOP
$ SET NOON
$ @SYSBLDCOM$:TAILORBLD 'INDEV'[SYSUPD] 'TARGDEV'[SYSUPD] ! Build tailoring files
$ SET ON
$WAIT_LOOP:
$ N = N + 1
$ SET NOON
$ SYNCHRONIZE/QUEUE=SYS$BUILD 'PHASE''N'
$ SET ON
$!COPY SYS$LOGIN:'PHASE''N'.LOG 'TARGDEV'[SYSBLDCOM]
$ IF N .LT. JOBS THEN GOTO WAIT_LOOP
$ GOTO NXTPHASE	! SETUP FOR NEXT PHASE IN SEQUENCE
$ !
$ !	BUILD THE NEXT COMPONENT IN THE LIST
$ !
$BEGIN:
$ OPEN DATA$ 'BLDFIL'
$ IF START .EQS. "BEGIN" THEN GOTO NXTCMD
$ !
$ !	IF START IS A SPECIFIC COMPONENT, THEN FIND IT IN THE LIST.
$ !
$ SET NOVERIFY
$FINDSTART:
$ READ DATA$ CMD /END=NOTFOUND
$ IF "''F$EXTRACT(0,1,CMD)" .EQS. "!" THEN GOTO FINDSTART
$ L = 'F$LOCATE("	",CMD)		! SEARCH FOR END OF NAME
$ IF L .GT. 'F$LOCATE(" ",CMD)' THEN L = 'F$LOCATE(" ",CMD)'
$ IF START .NES. "''F$EXTRACT(0,L,CMD)" THEN GOTO FINDSTART
$ GOTO FOUND
$NOTFOUND:
$ CLOSE DATA$
$ WRITE SYS$OUTPUT "Component not found in component list."
$ GOTO EXIT
$ !
$ !	READ NEXT COMMAND FROM DATA FILE
$ !
$ ! THE DATA LINES START AT THE LEFT MARGIN, NO $, NO SPACES OR TABS
$ !
$NXTCMD:
$ SET NOVERIFY
$ IF "''F$LOGICAL("STOP_BUILD")'" .NES. "" THEN GOTO EXIT
$ READ DATA$ CMD /END=ENDPHASE
$ IF "''F$EXTRACT(0,1,CMD)'" .EQS. "!" THEN GOTO NXTCMD
$FOUND:
$ IF END .EQS. "EXEC_STB" .AND. -
	'F$LOCATE("/EX",CMD)' .EQ. 'F$LENGTH(CMD) THEN GOTO NXTCMD
$ L = 'F$LOCATE("	",CMD)		! SEARCH FOR END OF NAME
$ IF L .GT. 'F$LOCATE(" ",CMD)' THEN L = 'F$LOCATE(" ",CMD)'
$ FACNAM:='F$EXTRACT(0,L,CMD)
$ IF .NOT.RESTART THEN GOTO NOMARKER
$ OPEN MARK$ 'TARGDEV'['FACNAM']PHASE.MKR /ERROR=NOMARKER
$ READ MARK$ RECORD /END=NOTMARKED
$ IF 'F$LOCATE(PHASE,RECORD) .EQ. 'F$LENGTH(RECORD) THEN GOTO NOTMARKED
$ CLOSE MARK$
$ IF FACNAM .EQS. END THEN GOTO ENDPHASE
$ GOTO NXTCMD
$NOTMARKED:
$ CLOSE MARK$
$NOMARKER:
$ WRITE SYS$OUTPUT "***************************************************************************"
$ WRITE SYS$OUTPUT "*									     *"
$ WRITE SYS$OUTPUT "*			BUILD	''FACNAM'   (''PHASE' PHASE)			     *"
$ WRITE SYS$OUTPUT "*									     *"
$ WRITE SYS$OUTPUT "***************************************************************************"
$ SET VERIFY
$ ON ERROR THEN GOTO FACFAIL
$ SET PROCESS/NAME='PHASE'_'FACNAM'
$ SET DEFAULT 'TARGDEV'['FACNAM']
$ SET WORKING_SET /LIMIT=500
$ IF PHASE .EQS. "ASSEM" THEN SHOW PROCESS/ACCOUNTING	! these two lines
$ IF PHASE .NES. "ASSEM" THEN SHOW DAYTIME		! here for timing
$! SHOW DAYTIME
$ ON ERROR THEN CONTINUE
$ @COM$:'FACNAM'BLD
$ IF $SEVERITY THEN GOTO DONE
$ !
$FACFAIL:
$ WRITE SYS$OUTPUT "%BUILD-F-FAIL, >>>>>>> ''FACNAM' FAILURE <<<<<<"
$ ON ERROR THEN CONTINUE
$ !
$DONE:
$ IF .NOT.RESTART THEN GOTO DONTMARK
$ OPEN/WRITE MARK$ 'TARGDEV'['FACNAM']PHASE.MKR
$ WRITE MARK$ PHASE
$ CLOSE MARK$
$ IF PHASE .NES. "INIT" THEN PURGE 'TARGDEV'['FACNAM']PHASE.MKR
$DONTMARK:
$ IF FACNAM .NES. END THEN GOTO NXTCMD
$ !
$ !	SET UP TO DO THE NEXT PHASE OF THE BUILD
$ !
$ENDPHASE:
$ SET VERIFY
$ CLOSE DATA$
$!SHOW PROCESS/ACCOUNTING
$NXTPHASE:
$ IF SUB THEN GOTO DSPPHASE
$ IF PHASE .NES. "OBJLIB" THEN GOTO DSPPHASE
$ CPYOLB:="N"
$DSPPHASE:
$ IF PHASE .EQS. ENDPHASE THEN GOTO NORMALEXIT
$ IF "''F$LOGICAL("STOP_BUILD")'" .NES. "" THEN GOTO NORMALEXIT
$ GOTO 'PHASE'
$INIT:
$ PHASE:="UPDATE"
$ GOTO START_PHASE
$UPDATE:
$ PHASE:="SRCLIB"
$ GOTO START_PHASE
$SRCLIB:
$ PHASE:="ASSEM"
$ GOTO START_PHASE
$ASSEM:
$ PHASE:="OBJLIB"
$ CPYOLB:="Y"
$ GOTO START_PHASE
$OBJLIB:
$ PHASE:="LNKLIB"
$ GOTO START_PHASE
$LNKLIB:
$ PHASE:="LINK"
$ GOTO START_PHASE
$LINK:
$ PHASE:="RESULT"
$ GOTO START_PHASE
$RESULT:
$ IF END .NES. "END" THEN GOTO NORMALEXIT
$ @SYSBLDCOM$:BLDRESULT 'TARGDEV' 'INDEV'
$NORMALEXIT:
$ IF .NOT.SUB .AND. RESTART THEN DELETE SYS$LOGIN:VMSACTBLD.COM;*
$EXIT:
