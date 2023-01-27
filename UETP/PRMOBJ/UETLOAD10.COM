$ ! MODIFIED BY:
$ !
$ !	V02-004	RNH0003		Richard N. Holstein,	09-Apr-1982
$ !		Use 3-character file types so we can have more 
$ !		than 100 processes without file conflicts in TEMP.%%.
$ !
$ ! 	V02-003	BAA0002		Brian A. Axtell,	11-Feb-1982
$ !		Modified to relfect changes in LOGINOUT.
$ !
$ !     V02-002	BAA0001		Brian A. Axtell,	21-Sep-1981
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
$ WRITE SYS$ERROR "*** UETLOAD10 BEGINNING AT ''F$TIME() ***"
$ !
$SKIPFILE:
$ WRITE SYS$OUTPUT "*** UETLOAD10 BEGINNING AT ''F$TIME() ***"
$ !
$ SET VERIFY
$ ! 			***   UETLOAD10.COM   ***
$ !
$ PRN := 'F$PROC()
$ LEN = 'F$LENGTH(PRN)'
$ OFFST = 'LEN'-3
$ PRN := 'F$EXT(OFFST,3,PRN)
$ !
$ WRITE SYS$OUTPUT "YOU ARE USER ''PRN' OUT OF ''F$LOG("LOADS")'."
$ SH DEF
$ SH DAY
$ SH SYS
$ SHOW TRAN SYS$SYSTEM
$ ! NOW LOOP RUNNING UETFORT98 20 TIMES.
$ ASSI TEMP.'PRN SYS$OUTPUT
$ SET NOVERIFY
$ COUNT = 0
$LOOP:
$ RUN UETFORT98
$ COUNT = COUNT + 1
$ IF COUNT .LE. 12 THEN GOTO LOOP
$ SET VERIFY
$ DEAS SYS$OUTPUT
$ DELE TEMP.'PRN';*
$ RUN UETFORT98
$ !
$ WRITE SYS$OUTPUT "*** UETLOAD10 ENDED AT ''F$TIME() ***"
$ IF .NOT. 'LOGFILE' THEN EXIT		! Exit if nothing to clean up
$ WRITE SYS$ERROR "*** UETLOAD10 ENDED AT ''F$TIME() ***"
$ CLOSE FILE
$ DEASSIGN SYS$ERROR
$ EXIT
