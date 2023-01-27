$ !
$ ! This command cleans up dangling directory entries on a Release 2/3 system.
$ ! It will not run on a Release 1 system, but merely terminate.
$ !
$ !	P1 = the device that is to be cleaned up.  If this parameter is not
$ !	     specified, then the user is prompted for the information.
$ !
$ !	P2 = the version of the system that is running, e.g. V2.5 or Y1AS.
$ !	     (used to determine whether a SET FILE/REMOVE or PIP /RM is done)
$ !
$ SET NOVERIFY
$ ON CONTROL_Y THEN GOTO 200
$ ON ERROR THEN GOTO 200
$ DEVICE:='P1
$ SYSVER:='P2
$10:
$ IF DEVICE .NES. "" THEN GOTO 20
$ INQUIRE TEMP "What is the target disk? (DDCU:)"
$ DEVICE:='TEMP
$ GOTO 10
$20:
$ IF 'F$LOCATE(":",DEVICE) .EQ. 'F$LENGTH(DEVICE) THEN DEVICE:='DEVICE':
$ SET PROC/PRIV=(BYPASS)
$ WRITE SYS$OUTPUT "Start directory clean up."
$ WRITE SYS$OUTPUT "This section takes a variable amount of time"
$ WRITE SYS$OUTPUT "depending on the number of files on the disk."
$ WRITE SYS$OUTPUT "(Please ignore possible undefined symbol messages.)"
$ DIRECTORY :== DIRECTORY
$ DELETE /SYMBOL/GLOBAL DIRECTORY
$ DIRECTORY := DIRECTORY
$ DELETE /SYMBOL/LOCAL DIRECTORY
$ DIRECTORY/SIZE/OUTPUT=DIRCLENUP.LIS 'DEVICE'[000000...]
$ OPEN/READ DIRFILE DIRCLENUP.LIS
$30:
$ READ/END_OF_FILE=100 DIRFILE RECORD
$ IF 'F$LOCATE("Directory",RECORD) .NE. 'F$LENGTH(RECORD) THEN GOTO 40
$ IF 'F$LOCATE("file identification sequence number check",RECORD) .NE. -
	'F$LENGTH(RECORD) THEN GOTO 50
$ IF 'F$LOCATE("no such file",RECORD) .NE. 'F$LENGTH(RECORD) THEN GOTO 50
$ GOTO 30
$ !
$ ! Extract the new directory name.
$ !
$40:
$ L='F$LOCATE("[",RECORD)
$ M = 'F$LOCATE("]",RECORD)
$ M = M - L + 1
$ CURDIR:='F$EXT(L,M,RECORD)
$ GOTO 30
$ !
$ ! Delete this dangling directory entry.
$ !
$50:
$ L = 0
$ M = 'F$LOCATE(" ",RECORD)
$ FILENAM:='F$EXT(L,M,RECORD)
$ ON ERROR THEN CONTINUE
$ IF (SYSVER .EQS. "V2.5") THEN GOTO 60
$ SET VER
$ SET FILE /REMOVE 'DEVICE''CURDIR''FILENAM'
$ SET NOVER
$ GOTO 30
$60:
$ SET VER
$ MCR PIP 'DEVICE''CURDIR''FILENAM'/RM
$ SET NOVER
$ GOTO 30
$100:
$ CLOSE DIRFILE
$ DELETE DIRCLENUP.LIS;0
$ SET PROC/PRIV=NOBYPASS
$ WRITE SYS$OUTPUT "Directory cleanup complete."
$ EXIT
$200:
$ SET NOVER
$ CLOSE DIRFILE
$ SET PROC/PRIV=NOBYPASS
$ EXIT
