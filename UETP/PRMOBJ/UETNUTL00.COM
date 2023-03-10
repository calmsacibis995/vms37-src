$ SET NOVERIFY
$ !
$ !NATIVE MODE UTILITY TEST
$ ! AUTHOR: Richard N. Holstein,	CREATION DATE: September, 1981
$ !
$ ! MODIFIED BY:
$ !
$ !  02-11-82  LDJ001	Modified to reflect changes to LOGINOUT
$ !
$ !  10-23-81  FWM001	Deleted * from TEST%.DAT;* to resolve file buildup
$ !			Fixed CTRL Y to clean up test data files
$ !			Fixed copy to SYS$ERROR problem (undefined if no
$ !			  LOGFILE)
$ !			Changed copy to logfile on error to info type-out
$ !**
$ !
$ STS$K_SUCCESS = 1				! Severity for no DIFFERENCEs
$ !
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
$   DEFINE SYS$ERROR FILE			! Make SYS$ERROR look at it
$   WRITE SYS$ERROR "*** UETNUTL00 BEGINNING AT ''F$TI() ***"
$ !
$SKIPFILE:
$   WRITE SYS$OUTPUT "*** UETNUTL00 BEGINNING AT ''F$TI() ***"
$ !
$   ON ERROR THEN GOTO FINI
$   ON CONTROL_Y THEN GOTO FINI
$ PNAME:='P1
$ !
$PARAMETER:
$   IF PNAME .EQS. "SORT" THEN GOTO UETSORT00
$   IF PNAME .EQS. "" .OR. PNAME .EQS. "ALL" THEN GOTO UTILITIES
$   INQUIRE PAR "ENTER THE NAME OF A UTILITY OR CARRIAGE RETURN"
$ PNAME:='PAR
$   GOTO PARAMETER
$ !
$UTILITIES:
$ !
$ !
$UETSORT00:
$   ON CONTROL_Y THEN GOTO SORT_CLEAN_UP
$ !
$ !
$ !			VAX-11 SORT TEST
$ !
$ !
$   SET VERIFY
$   SORT/KEY:(POS:1,SIZE:3) SORT.DAT TEST1
$   SORT/KEY:(POS:1,SIZE:3,CHARACTER,ASCENDING) SORT.DAT TEST2
$   SORT/KEY:(POS:1,SIZE:3,CHARACTER,DESCENDING) SORT.DAT TEST3
$   SORT/KEY:(POS:1,SIZE:3,NUMBER:1,ASCENDING) SORT.DAT TEST4
$   SORT/KEY:(POS:1,SIZE:4,BINARY, ASCENDING) SORT.DAT TEST5
$   SORT/KEY:(POS:1,SIZE:3)/PROCESS:RECORD SORT.DAT TEST6
$   SORT/KEY:(POS:1,SIZE:3)/PROCESS:TAG SORT.DAT TEST7
$   SORT/KEY:(POS:1,SIZE:3)/WORK_FILES:4 SORT.DAT TEST10
$   SORT/KEY:(POS:1,SIZE:3)/WORK_FILES:12 SORT.DAT TEST11
$   SORT/KEY:(POS:1,SIZE:3) SORT.DAT/FORMAT:(RECORD_SIZE:132) TEST12
$   SORT/KEY:(POS:1,SIZE:3) SORT.DAT/FORMAT:(FILE_SIZE:50) TEST13
$   SORT/KEY:(POS:1,SIZE:3) SORT.DAT TEST14/FORMAT:(VARIABLE:132)
$   SORT/KEY:(POS:1,SIZE:3) SORT.DAT TEST15/FORMAT:(CONT:80,SIZE:2)
$   SORT/KEY:(POS:1,SIZE:3) SORT.DAT TEST16/SEQUENTIAL
$   SORT/KEY:(POS:1,SIZE:3) SORT.DAT TEST17/RELATIVE/FORMAT:VAR:81
$   SORT/KEY:(POS:1,SIZE:3) SORT.DAT-
      TEST18/RELATIVE/BUCKET_SIZE:2/FORMAT:VAR:81
$   SORT/KEY:(POS:1,SIZE:3) SORT.DAT TEST19/SEQ/ALLOCATE:50
$   SORT/KEY:(POS:1,SIZE:3) SORT.DAT TEST20/ALLOCATE:50/CONT
$   SORT/KEY:(POS:1,SIZE:3) SORT.DAT TEST21/ALLOCATE:40
$ !
$   APPEND TEST2.DAT,TEST3.DAT,TEST4.DAT,TEST5.DAT,-
      TEST6.DAT,TEST7.DAT,TEST10.DAT,TEST11.DAT,TEST12.DAT,-
      TEST13.DAT,TEST15.DAT,TEST16.DAT,TEST19.DAT,TEST20.DAT,-
      TEST21.DAT   TEST1.DAT
$   ERR_FILE := SMFILE1			! used if difference found
$   DIFFERENCE /OUTPUT=TMP0.DAT SMFILE1.DAT TEST1.DAT
$   IF $SEVERITY .NE. STS$K_SUCCESS THEN GOTO SORTDIFFERS
$   ERR_FILE := SMFILE2			! used if difference found
$   DIFFERENCE /OUTPUT=TMP0.DAT SMFILE2.DAT TEST14.DAT
$   IF $SEVERITY .NE. STS$K_SUCCESS THEN GOTO SORTDIFFERS
$   CONVERT TEST17.DAT TMP1.DAT
$   ERR_FILE := SMFILE3			! used if difference found
$   DIFFERENCE /OUTPUT=TMP0.DAT SMFILE3.DAT TMP1.DAT
$   IF $SEVERITY .NE. STS$K_SUCCESS THEN GOTO SORTDIFFERS
$   CONVERT TEST18.DAT TMP2.DAT
$   ERR_FILE := SMFILE4			! used if difference found
$   DIFFERENCE /OUTPUT=TMP0.DAT SMFILE4.DAT TMP2.DAT
$   IF $SEVERITY .NE. STS$K_SUCCESS THEN GOTO SORTDIFFERS
$ !
$ !
$SORT_CLEAN_UP:
$   DELETE TMP%.DAT;*,TEST%.DAT;*,TEST%%.DAT;*
$   GOTO SORT_COMPLETE
$ !
$SORTDIFFERS:
$   WRITE SYS$ERROR "VAX-11 SORT TEST (''ERR_FILE') HAD ERRORS"
$ !
$SORT_COMPLETE:
$ !
$ !			SORT Testing Complete
$   SET NOVERIFY
$   ON CONTROL_Y THEN GOTO FINI
$   IF PNAME .EQS. "SORT" THEN GOTO FINI
$ !
$FINI:
$   SET NOVERIFY
$ 
$   WRITE SYS$OUTPUT "*** UETNUTL00 ENDED AT ''F$TIME() ***"
$   IF .NOT. 'LOGFILE' THEN EXIT
$   WRITE SYS$ERROR "*** UETNUTL00 ENDED AT ''F$TIME() ***"
$   CLOSE FILE
$   DEASSIGN SYS$ERROR
$                ! END OF NATIVE MODE UTILITY TEST
