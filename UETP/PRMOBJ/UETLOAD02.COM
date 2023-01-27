$ !
$ ! MODIFIED BY:
$ !
$ !		VERSION 3.0
$ !	02	RNP 02/11/82	Modified to reflect changes to loginout.
$ !
$ !	01	RNH 08/13/81	Modified to work with UETPHAS00.
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
$ DEFINE SYS$ERROR FILE			! ...to put all error messages
$ WRITE SYS$ERROR "*** UETLOAD02 BEGINNING AT ''F$TIME() ***"
$ !
$SKIPFILE:
$ WRITE SYS$OUTPUT "*** UETLOAD02 BEGINNING AT ''F$TIME() ***"
$ !
$ SET VERIFY
$ !			***    UETLOAD02.COM   ***
$ ! THE TOTAL NUMBER OF LOAD TEST USERS IS 'F$LOG("UETP$USERS")
$ ! YOU ARE USER NUMBER (LOOK AT THE LAST 2 DIGITS 00-NN):
$ !  'F$PROC()
$ SH DA
$ SH DEF
$ RUN UETFORT99
$ !
$ WRITE SYS$OUTPUT "*** UETLOAD02 ENDED AT ''F$TIME() ***"
$ IF .NOT. 'LOGFILE' THEN EXIT		! Exit if nothing to clean up
$ WRITE SYS$ERROR "*** UETLOAD02 ENDED AT ''F$TIME() ***"
$ CLOSE FILE
$ DEASSIGN SYS$ERROR
$ EXIT
