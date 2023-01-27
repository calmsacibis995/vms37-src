$ ! MODIFIED BY:
$ !
$ !	V02-004	RNH0002		Richard N. Holstein,	09-Apr-1982
$ !		Use 3-character file types so we can have more 
$ !		than 100 processes without file conflicts in TEMP.%%.
$ !
$ !	V02-003	RNP0001		Robert N. Perron,	11-Feb-1982
$ !		Modified to reflect changes to loginout.
$ !
$ !	V02-002	BAA0001		Brian A. Axtell,	21-Sep-1981
$ !		Fixed so that last two characters of process 
$ !		name is file extension for temporary files.
$ !
$ !	V02-001	RNH0001		Richard N. Holstein,	13-Aug-1981
$ !		Modified to work with UETPHAS00.
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
$ WRITE SYS$ERROR "*** UETLOAD03 BEGINNING AT ''F$TIME() ***"
$ !
$SKIPFILE:
$ WRITE SYS$OUTPUT "*** UETLOAD03 BEGINNING AT ''F$TIME() ***"
$ !
$ SET VERIFY
$ ! 			***   UETLOAD03.COM   ***
$ !
$ PRN := 'F$PROC()
$ LEN = 'F$LENGTH(PRN)'
$ OFFST = 'LEN'-3
$ PRN := 'F$EXT(OFFST,3,PRN)
$ !
$ WRITE SYS$OUTPUT "YOU ARE USER ''PRN' OUT OF ''F$LOG("LOADS")'."
$ !
$ SH DA
$ SH DEF
$ ! NOW LOOP RUNNING UETFORT98 20 TIMES.
$ ASSI TEMP.'PRN SYS$OUTPUT
$ SET NOVERIFY
$ COUNT = 0
$LOOP:
$ RUN UETFORT98
$ COUNT = COUNT + 1
$ IF COUNT .LE. 20 THEN GOTO LOOP
$ SET VERIFY
$ DEAS SYS$OUTPUT
$ DELE TEMP.'PRN';*
$ SH LOG/ALL
$ SH STAT
$ DIR [*]*.CMD/FULL
$ !
$ WRITE SYS$OUTPUT "*** UETLOAD03 ENDED AT ''F$TIME() ***"
$ IF .NOT. 'LOGFILE' THEN EXIT		! Exit if nothing to clean up
$ WRITE SYS$ERROR "*** UETLOAD03 ENDED AT ''F$TIME() ***"
$ CLOSE FILE
$ DEASSIGN SYS$ERROR
$ EXIT
