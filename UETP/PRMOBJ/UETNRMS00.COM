$ SET NOVERIFY
$ ! VAX-11 RMS TEST FOR UETP
$ ! AUTHOR: PAULA TIRAK,		CREATION DATE: FEBRUARY, 1978
$ !
$ ! MODIFIED BY:
$ !
$ !--
$ ! LDJ0002	11-FEB-1982 Larry D. Jones
$ !		Modified to reflect changes to LOGINOUT
$ !
$ ! FWM0001	23-OCT-1981 Fred W. Matthes
$ !		Changed how result of DIFF was tested
$ !
$ ! LDJ0001	13-AUG-1981 Larry D. Jones
$ !		Modified to work with the test controller.
$ !
$ ! BAA0002	11-SEP-1981 Brian A. Axtell
$ !		Modified to use native mode DIFFERENCE utility.
$ !**
$ !
$ STS$K_SUCCESS =  1				! define success code
$ LOGFILE = 0			! Default is interactive
$ IF "''F$MODE()'" .EQS. "INTERACTIVE" THEN GOTO SKIPFILE
$ LOGFILE = 1			! We are making a logfile
$ PROC := 'F$GETJPI("","PRCNAM")' ! Get the processname of this procedure
$ UNDER = 'F$LOCATE("_",PROC)'  ! and find the underscore
$ ID = UNDER+1			! Locate the unique ID
$ IF  UNDER .GT. 5 THEN UNDER = 5  ! take the first 5 chars. before underscore
$ FILENAME := 'F$EXTRACT(0,UNDER,PROC)''F$EXTRACT(ID,4,PROC)'.LOG
$ !
$ OPEN/WRITE FILE 'FILENAME'	! Define a place for us . . .
$   DEFINE SYS$ERROR FILE			! and define SYS$ERROR to be that
$   WRITE SYS$ERROR "*** UETNRMS00 beginning at ''F$TI() ***"
$ !
$SKIPFILE:
$   WRITE SYS$OUTPUT "*** UETNRMS00 beginning at ''F$TI() ***"
$ !
$
$			! Indicate continuous mode of operation
$   ASSIGN RMS RMS$TST_VERBOSITY_FLAG
$			! Define TST$DISK to be the default disk
$   ASSIGN SYS$DISK:  TST$DISK
$			! Continue after finding an error
$   ON ERROR THEN GOTO FINI
$   ON CONTROL_Y THEN GOTO CTRLY
$   MAGTAP:='F$LOG("UET$MAGTAP"):
$
$			! Execute all the tests sequentially
$ ! B -- Block input/output tests
$ ! F -- XAB and $FLUSH tests
$ ! G -- Sequential tests
$ ! K -- Directory and related filename tests
$ ! L -- Relative tests, including locking
$ ! X -- Indexed sequential tests
$ ! C -- Copy the input file to the output file
$ ! A -- Append the input file to the output files
$ ! M -- Magtape tests
$
$   SET VERIFY
$   RUN UETNRMS01
B
F
G
K
L
X
C
PIPDATA.PIP
APPENDIT.PIP
A
PIPDATA.PIP
APPENDIT.PIP
$		! See if the append succeeded with the DIF program
$   DIFF APPEND.PIP APPENDIT.PIP
$   IF $SEVERITY .NE. STS$K_SUCCESS THEN -
      WRITE SYS$ERROR "NATIVE MODE RMS TEST -- APPEND ERROR"
$   SET NOVERIFY
$   IF MAGTAP .EQS. ":" THEN GOTO FINI
$   ALLOCATE 'MAGTAP
$   MOUNT/NOASSIST 'MAGTAP UETP
$		! Define TST$MTA to be the default magtape
$   ASSIGN 'MAGTAP TST$MTA
$   SET VERIFY
$   RUN UETNRMS01
M
$CTRLY:
$   SET NOVERIFY
$   IF MAGTAP .EQS. ":" THEN GOTO FINI
$   DISMOUNT/NOUNLOAD 'MAGTAP
$   INITIALIZE 'MAGTAP UETP
$   DEALLOCATE 'MAGTAP
$   DEASSIGN TST$MTA
$FINI:
$   SET NOVERIFY
$   DEASSIGN RMS$TST_VERBOSITY_FLAG
$   DEASSIGN TST$DISK
$   IF 'LOGFILE' .EQ. 0 THEN GOTO EXIT	! wasn't any file
$   WRITE SYS$ERROR "*** UETNRMS00 ended at ''F$TI() ***"
$   CLOSE FILE
$   ASSIGN NL: SYS$ERROR		! nothing else to log file
$EXIT:
$   WRITE SYS$OUTPUT "*******************************"
$   WRITE SYS$OUTPUT "Please ignore any delete errors"
$   WRITE SYS$OUTPUT "*******************************"
$   DELETE *.FIL;*,T4FILE.DAT;*,APPENDIT.*;*
$   WRITE SYS$OUTPUT "*** UETNRMS00 ended at ''F$TI() ***"
$ ! END RMS TESTS
