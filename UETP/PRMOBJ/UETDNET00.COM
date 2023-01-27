!++
!
! UETDNET00.COM  VAX/VMS UETP DECnet test COMMAND FILE
!	.IDENT	'V03-002'
!
! CREATED BY: Paul Jenq, 28-Aug-1981
!
! MODIFIED BY:
!--
!	V03-002 LDJ0002		Larry D. Jones,		11-Feb-1982
!		Modified to reflect changes to LOGINOUT.
!
!	V03-001	LDJ0001		Larry D. Jones,		05-Nov-1981
!		Added code to support UETININET.DAT file and added
!		more functionallity tests.
!**
$ !
$	LOGFILE = 0			! Default is interactive
$	IF "''F$MODE()'" .EQS. "INTERACTIVE" THEN GOTO SKIPFILE
$	LOGFILE = 1			! We are making a logfile
$	PROC := 'F$GETJPI("","PRCNAM")' ! Get the processname of this procedure
$	UNDER = 'F$LOCATE("_",PROC)'  ! and find the underscore
$	ID = UNDER+1			! Locate the unique ID
$	IF  UNDER .GT. 5 THEN UNDER = 5  ! take the first 5 chars. before underscore
$	FILENAME := 'F$EXTRACT(0,UNDER,PROC)''F$EXTRACT(ID,4,PROC)'.LOG
$ !
$	OPEN/WRITE FILE 'FILENAME'	! Define a place for us . . .
$	DEFINE SYS$ERROR FILE			! Make SYS$ERROR look at it
$	CIR_CNT = 0				! Assume no circuits to test
$	WRITE SYS$ERROR "*** UETDNET00 BEGINNING AT ''F$TI() ***"
$ SKIPFILE:
$	WRITE SYS$OUTPUT "*** UETDNET00 BEGINNING AT ''F$TI() ***"
$	REPORT:='F$LOGICAL("REPORT")
$	RF = 0					! Default to short report
$	IF "''F$EXTRACT(0,1,REPORT)'".NES."S" THEN RF = 1 ! No it's long report
$	ON ERROR THEN GOTO ERROR_EXIT
$	ON CONTROL_Y THEN GOTO CLEAN_UP
$	IF RF.EQ.1 THEN WRITE SYS$ERROR "%UETP-I-BEGIN, Network sizing beginning at ''F$TI()"
$!
$! Identify our currently testable DECnet nodes and circuits.
$! The file UETININET.DAT is created containing a record for every circuit
$! which is active and has a state of "on" but is not in a transitional state.
$! Each record also contains the adjacent node number and name.
$!
$	ASSIGN/USER UETININET.TMP SYS$OUTPUT
$	MC NCP
	SHOW ACTIVE CIRCUITS
	EXIT
$!	DEASSIGN SYS$OUTPUT
$	OPEN/ERROR=FILE_ERROR/READ NCPFILE UETININET.TMP
$	X=7
$LOOP1:
$	READ/ERROR=FILE_ERROR NCPFILE RECORD
$	X=X-1
$	IF X.NE.0 THEN GOTO LOOP1
$	OPEN/ERROR=FILE_ERROR/WRITE NCPFIN UETININET.DAT
$	IF RF.EQ.1 THEN WRITE SYS$ERROR "%UETP-I-TEXT, The following circuits will be tested:"
$!
$! Loop to create the final data file
$!
$ININET_LOOP:
$	READ/ERROR=DONE NCPFILE RECORD
$	RECLEN='F$LENGTH(RECORD)
$	STATE='F$LOCATE("on",RECORD)		! See if line is on
$	IF STATE.EQ.RECLEN THEN GOTO ININET_LOOP ! If not then forget this circuit
$	SUBRECORD:='F$EXTRACT(STATE,RECLEN-STATE,RECORD)
$	SRECLEN='F$LENGTH(SUBRECORD)
$	ODDON='F$LOCATE("-",SUBRECORD)	! See if state is on but not totally
$	IF ODDON.NE.SRECLEN THEN GOTO ININET_LOOP ! If not on totally then forget this one
$!
$! Any circuit that reaches here should be testable so write it to the final
$! file in the form:
$!
$!	CIRCUIT NAME<sp>NODE ID<sp>(NODE NAME)
$!
$	SUBRECORD:='F$EXTRACT(2,RECLEN-2,RECORD)
$	CIREND='F$LOCATE(" ",SUBRECORD)	! Find the end of the circuit name
$	CIRNAM:='F$EXTRACT(0,CIREND,SUBRECORD) ! Extract the circuit name
$	SRECLEN = 'F$LENGTH(SUBRECORD)-CIREND
$	SUBRECORD:='F$EXTRACT(CIREND+1,SRECLEN,SUBRECORD)
$	ADR_STR='F$LOCATE(" ",SUBRECORD)+1
$	SUBRECORD:='F$EXTRACT(ADR_STR,SRECLEN-ADR_STR,SUBRECORD)
$	WRITE NCPFIN CIRNAM," ",SUBRECORD
$	IF RF.EQ.1 THEN WRITE SYS$ERROR "               Circuit ",CIRNAM," to node ",SUBRECORD
$	GOTO ININET_LOOP
$FILE_ERROR:
$	WRITE SYS$OUTPUT "File error"
$	GOTO ERROR_EXIT
$DONE:
$	WRITE NCPFIN "END OF UETININET.DAT"
$	IF RF.EQ.1 THEN WRITE SYS$ERROR "%UETP-I-ENDED, Network sizing ended at ''F$TI()"
$EXIT:
$	CLOSE NCPFILE
$	CLOSE NCPFIN
$	DEL UETININET.TMP;*
$LOCAL_TEST:
$	MODE := 'F$LOGICAL("MODE")
$	MODE := 'F$EXTRACT(0,1,MODE)
$	MD = 0
$	IF MODE.EQS."D" THEN MD = 1
$ 	OPEN/READ/ERROR=ERROR_EXIT NETFILE UETININET.DAT ! Look at the other nodes
$	OPEN/WRITE/ERROR=ERROR_EXIT NET01 UETDNET01.DAT  ! Open the PHAS00 DATA file
$	WRITE NET01 "NAME = UETDNET01"			 ! Set the process name
$	WRITE NET01 "LOG = UETDNET01.LOG"		 ! Set the log file name
$READ_LOOP:						 ! Create a command file
$ 	READ/ERROR=FILE_ERROR NETFILE RECORD		 ! for each circuit.
$	IF "''F$EXTRACT(0,3,RECORD)".EQS."END" THEN GOTO DO_TEST
$	RECL = 'F$LENGTH(RECORD)
$	COM_LEN = 'F$LOCATE(" ",RECORD)
$  	COMM_LINE := 'F$EXTRACT(0,COM_LEN,RECORD)'	 ! Parse circuit name
$	SUBRECORD := 'F$EXTRACT(COM_LEN,RECL-COM_LEN,RECORD)
$	COM_LEN = 'F$LOCATE(" ",SUBRECORD)
$ 	NODE_ADDR := 'F$EXTRACT(0,COM_LEN,SUBRECORD)'	 ! Parse node address
$ 	NODE_NAME := 'F$EXTRACT(COM_LEN,RECL-COM_LEN,SUBRECORD)' ! Parse node name
$	CIR_CNT = CIR_CNT + 1
$	FPS = F$LOCATE("-",COMM_LINE)			 ! Make the command procedure name
$	FPC := 'F$EXTRACT(0,FPS,COMM_LINE)'
$	FPC := 'FPC''F$EXTRACT(FPS + 1, F$LENGTH(COMM_LINE) - FPS + 1, COMM_LINE)
$	FPP = F$LOCATE(".",FPC)				 ! Locate possible tributary number
$	FPC := 'F$EXTRACT(0,FPP,FPC)			 ! Strip tributary if present
$	FFN := 'FPC''NODE_ADDR'
$	FPC := 'FPC''NODE_ADDR'.COM
$	OPEN/WRITE/ERROR=ERROR_EXIT ZERO ZERO.COM	 ! Create a counter zeroing command file
$	WRITE ZERO "$ SET PROC/PRIV=OPER"		 ! Add OPER priv to ZERO counters
$	WRITE ZERO "$ MC NCP"
$	WRITE ZERO "ZERO NODE ",NODE_ADDR," COUNTERS"	 ! Zero node counters
$	WRITE ZERO "ZERO CIRCUIT ",COMM_LINE," COUNTERS" ! Zero circuit counters
$	WRITE ZERO "$ SET PROC/PRIV=NOOPER"
$	CLOSE ZERO
$	@ZERO						 ! Do it
$	DEL ZERO.COM;*					 ! Clean up the mess
$	WRITE NET01 "Y Y "'FPC'				 ! Write PHAS00 record
$ 	OPEN/WRITE NCPCOM 'FPC'				 ! Create the .COM file
$	IF MD .EQ. 1 THEN WRITE NCPCOM "$ ! BEGIN ",FFN
$ 	WRITE NCPCOM "$ MCR NCP"
$	WRITE NCPCOM "SHOW NODE ",NODE_ADDR," STATUS"
$ 	WRITE NCPCOM "LOOP NODE ",NODE_ADDR," COUNT 100 LENGTH 576 WITH ONES"
$ 	WRITE NCPCOM "LOOP NODE ",NODE_ADDR," COUNT 100 LENGTH 10 WITH ZERO"
$	WRITE NCPCOM "LOOP NODE ",NODE_ADDR," COUNT 100 LENGTH 128 WITH MIXED"
$	WRITE NCPCOM "SHOW COUNTERS NODE ",NODE_ADDR
$	WRITE NCPCOM "SHOW COUNTERS CIRCUIT ",COMM_LINE
$ 	WRITE NCPCOM "EXIT"
$	IF MD .EQ. 1 THEN WRITE NCPCOM "$ ! END ",FFN
$ 	CLOSE NCPCOM
$	IF MD .EQ. 1 THEN TYPE 'FPC'
$	GOTO READ_LOOP					 ! Do all circuits
$ DO_TEST:
$	CLOSE NET01					 ! Close the PHAS00 file
$!							   the test files.
$! Test the EXECUTOR node
$!
$	IF RF.EQ.1 THEN WRITE SYS$ERROR "%UETP-I-BEGIN, EXECUTOR node testing beginning at ''F$TI()"
$	MCR NCP
	SHOW EXECUTOR STATUS
	LOOP EXECUTOR COUNT 100 LENGTH 576 WITH MIXED
	LOOP EXECUTOR COUNT 128 LENGTH 10 WITH ONES
	LOOP EXECUTOR COUNT 100 LENGTH 128 WITH ZERO
	EXIT
$	IF RF.EQ.1 THEN WRITE SYS$ERROR "%UETP-I-ENDED, EXECUTOR node testing ended at ''F$TI()"
$!
$!
$! Do sequential circuit testing
$!
$	IF RF.EQ.1 THEN WRITE SYS$ERROR "%UETP-I-BEGIN, Sequential circuit testing beginning at ''F$TI()"
$	DEFINE PARCNT 1					 ! Run one at a time
$	DEFINE FILNAM UETDNET01.DAT			 ! All circuits
$	RUN UETPHAS00
$	IF RF.EQ.1 THEN WRITE SYS$ERROR "%UETP-I-ENDED, Sequential circuit testing ended at ''F$TI()"
$	DEL UETDNET01.LOG;*
$!
$! Do parallel circuit testing
$!
$	IF RF.EQ.1 THEN WRITE SYS$ERROR "%UETP-I-BEGIN, Parallel circuit testing beginning at ''F$TI()"
$	X = (2 * CIR_CNT)				 ! Don't run more than 2
$	Y := 'F$LOGICAL("LOADS")
$	IF X.GT.Y THEN X = Y				 ! copys per circuit
$	DEFINE PARCNT 'X				 ! and don't exceed the
$	RUN UETPHAS00					 ! system resources
$	IF RF.EQ.1 THEN WRITE SYS$ERROR "%UETP-I-ENDED, Parallel circuit testing ended at ''F$TI()"
$	DEL UETDNET01.LOG;*
$!
$! Do a counter check
$!
$	RUN/NODEB UETNETS00
$ 	GOTO TEST_END					 ! Bail out
$ ERROR_EXIT:
$	WRITE SYS$OUTPUT "%UETP-I-TEXT, DCL command error "
$ 	SET NOON
$ 	CLOSE NETFILE
$ 	SET ON
$ 	GOTO TEST_END
$ CLEAN_UP:
$	WRITE SYS$OUTPUT "%UETP-I-TEXT, DECnet UETP test aborted by CONTROL-Y"
$ 	GOTO TEST_END
$ NO_NET:
$	WRITE SYS$ERROR "%UETP-I-TEXT, DECnet unavailable "
$ 	GOTO TEST_END
$ TEST_END:
$	SET NOVERIFY
$	CLOSE NETFILE
$ 	OPEN/READ/ERROR=TEST_END1 NETFILE UETDNET01.DAT ! Find out what to clean up
$ 	READ/ERROR=TEST_END1 NETFILE RECORD		! Skip the header data
$ 	READ/ERROR=TEST_END1 NETFILE RECORD
$A10:
$ 	READ/ERROR=TEST_END1 NETFILE RECORD
$	FILE_NAME_LEN = F$LENGTH(RECORD)-4
$	FILE_NAME:='F$EXTRACT(4,FILE_NAME_LEN,RECORD)
$	DELETE 'FILE_NAME';*
$	GOTO A10
$TEST_END1:
$	WRITE SYS$OUTPUT "*** UETDNET00 ENDED AT ''F$TIME() ***"
$	IF .NOT. 'LOGFILE' THEN EXIT
$	WRITE SYS$ERROR "*** UETDNET00 ENDED AT ''F$TIME() ***"
$	CLOSE FILE
$	DEASSIGN SYS$ERROR
$	EXIT
$                ! END OF DECnet TEST
