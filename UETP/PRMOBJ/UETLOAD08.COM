$ !	BAA 02/11/82	Modified to reflect changes in LOGINOUT.
$ !
$ !	RNH 08/13/81	Modified to work with UETPHAS00.
$ !
$ !--
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
$ DEFINE SYS$ERROR FILE		! ...to put all error messages
$ WRITE SYS$ERROR "*** UETLOAD08 BEGINNING AT ''F$TIME() ***"
$ !
$SKIPFILE:
$ WRITE SYS$OUTPUT "*** UETLOAD08 BEGINNING AT ''F$TIME() ***"
$ !
$ SET VERIFY
$ ! 			***   UETLOAD08.COM   ***
$ ! THE TOTAL NUMBER OF LOAD TEST USERS IS 'F$LOG("UETP$USERS")
$ ! YOU ARE USER NUMBER (LOOK AT THE LAST 2 DIGITS):
$ !  'F$PROC()
$ SH DEF
$ SH DA
$ DEF ABC UETP
$ DEF UETP SQM
$ DEF SQM RAB
$ DEF RAB PJT
$ DEF PJT WIZ
$ SH TR ABC
$ SH LOG ABC
$ ABC:=UETP
$ SH SYMB ABC
$ SH LOG/ALL
$ SH STAT
$ SET NOVERIFY
$ COUNT = 0
$ MSG := "  COUNT IS NOW EQUAL TO "
$LOOP:
$ WAIT 0:0:15		! 15 SECONDS
$ SHOW DAY
$ COUNT = COUNT + 1
$ WRITE SYS$OUTPUT MSG,COUNT
$ IF COUNT .LE. 14 THEN GOTO LOOP
$ SET VERIFY
$ DIR [*]*.DMP/FULL
$ SHOW PROC
$ !
$ WRITE SYS$OUTPUT "*** UETLOAD08 ENDED AT ''F$TIME() ***"
$ IF .NOT. 'LOGFILE' THEN EXIT		! Exit if nothing to clean up
$ WRITE SYS$ERROR "*** UETLOAD08 ENDED AT ''F$TIME() ***"
$ CLOSE FILE
$ DEASSIGN SYS$ERROR
$ EXIT
