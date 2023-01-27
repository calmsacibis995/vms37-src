$ ! MODIFIED BY:
$ !
$ !	V02-004	RNH0003		Richard N. Holstein,	09-Apr-1982
$ !		Use 3-character file types so we can have more 
$ !		than 100 processes without file conflicts in TEMP.%%.
$ !
$ !	V02-003	BAA0002		Brian A. Axtell,	11-Feb-1982
$ !		Modified to reflect changes in LOGINOUT.
$ !
$ !	V02-002	BAA0001		Brian A. Axtell,	21-Sep-1981
$ !		Fixed to take last two characters of process name
$ !		as file extension for temporary files.
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
$ DEFINE SYS$ERROR FILE		! ...to put all error messages
$ WRITE SYS$ERROR "*** UETLOAD09 BEGINNING AT ''F$TIME() ***"
$ !
$SKIPFILE:
$ WRITE SYS$OUTPUT "*** UETLOAD09 BEGINNING AT ''F$TIME() ***"
$ !
$ SET VERIFY
$ ! 			***   UETLOAD09.COM   ***
$ !
$ PRN := 'F$PROC()
$ LEN = 'F$LENGTH(PRN)'
$ OFFST = 'LEN'-3
$ PRN := 'F$EXTR(OFFST,3,PRN)
$ !
$ WRITE SYS$OUTPUT "YOU ARE USER ''PRN' OUT OF ''F$LOG("LOADS")'."
$ SHOW DAY
$ SHOW DEVICES
$ SHOW DEVICES/FULL DB
$ SHOW DEVICES/MOU
$ SHOW PROCESS/ALL
$ SHOW SYSTEM
$ SHOW STATUS
$ SHOW LOGICAL SYS$SYSTEM
$ SHOW LOGICAL
$ SHOW WORKING_SET
$ SHOW TRANS XXX
$ SHOW TRANS SYS$SYSTEM
$ SHOW QUEUE SYS$PRINT
$ SHOW SYMBOLS/LOCAL/ALL
$ SHOW SYMBOLS/GLOBAL/ALL
$ SHOW PROTECTION
$ SHOW DEFAULT
$ SHOW DAYTIME
$ SET WORKING_SET/QUOTA=100
$ SET WORKING_SET/LIMIT=0
$ SET WORKING_SET/QUOTA=0
$ SET WORKING_SET/LIMIT=9999
$ !SET QUEUE/JOB_COUNT=1/ENTRY=100
$ COPY UETFORT01.DAT TEMP.'PRN
$ ASSI TEMP.'PRN FOR005
$ RUN UETFORT97
$ WAIT 0:1:30
$ RUN UETFORT98
$ DELE TEMP.'PRN';*
$ !
$ WRITE SYS$OUTPUT "*** UETLOAD09 ENDED AT ''F$TIME() ***"
$ IF .NOT. 'LOGFILE' THEN EXIT		! Exit if nothing to clean up
$ WRITE SYS$ERROR "*** UETLOAD09 ENDED AT ''F$TIME() ***"
$ CLOSE FILE
$ DEASSIGN SYS$ERROR
$ EXIT
