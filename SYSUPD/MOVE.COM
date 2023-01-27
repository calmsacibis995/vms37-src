$ !
$ ! This command moves files from one directory to another maintaining
$ ! the order of the version numbers.
$ !
$ ! NOTE:  There may be only ONE version of the target file already
$ !	   in the target directory!!!
$ !
$ !	P1 = the file specifications to be moved (DDCU:[DIR]file)
$ !		(any file spec that DIRECTORY understands)
$ !
$ !	P2 = the destination disk and directory
$ !		(no other pieces of file specs allowed)
$ !
$ !	P3 = the desired operation:  MOVE or ENTER or COPY
$ !		MOVE - does a RENAME
$ !		ENTER - does a PIP/EN
$ !		COPY - does a COPY
$ !
$ !	P4 = the desired version number change:  OVER or UNDER or NULL
$ !		UNDER - places moved files as lower version numbers
$ !		OVER - places moved files as higher version numbers
$ !		NULL - just RENAME files, don't worry about version numbers
$ !
$ FILEOPEN := "NO"
$ ON CONTROL_Y THEN GOTO 200
$ ON ERROR THEN GOTO 200
$ SOURCE:='P1
$10:
$ IF SOURCE .NES. "" THEN GOTO 20
$ INQUIRE SOURCE "What is the disk and directory to be moved? (DDCU:[DIR])"
$ GOTO 10
$20:
$ SOURCE_D := 'SOURCE
$ IF 'F$LOCATE("]",SOURCE) .EQ. 'F$LENGTH(SOURCE) THEN GOTO 21
$ L = 'F$LOCATE("]",SOURCE) + 1
$ SOURCE_D := 'F$EXTRACT(0,L,SOURCE)
$ K = 'F$LENGTH(SOURCE)
$ FILENAME := 'F$EXTRACT(L,K,SOURCE)
$ L = 'F$LOCATE(";",FILENAME)
$ IF (L .NE. 'F$LENGTH(FILENAME)) THEN FILENAME := 'F$EXTRACT(0,L,FILENAME)
$21:
$ TARGET:='P2
$22:
$ IF TARGET .NES. "" THEN GOTO 23
$ INQUIRE TARGET "What is the destination disk and directory? (DDCU:[DIR])"
$ GOTO 22
$23:
$ OPERATION:='P3
$24:
$ IF OPERATION .NES. "" THEN GOTO 25
$ INQUIRE OPERATION "What is the operation? (MOVE or ENTER or COPY)"
$ GOTO 24
$25:
$ LOCATION:='P4
$26:
$ IF LOCATION .NES. "" THEN GOTO 27
$ INQUIRE LOCATION "What is the location? (OVER or UNDER or NULL)"
$ GOTO 26
$27:
$ DIRECTORY :== DIRECTORY
$ DELETE /SYMBOL/GLOBAL DIRECTORY
$ DIRECTORY := DIRECTORY
$ DELETE /SYMBOL/LOCAL DIRECTORY
$ IF (OPERATION .EQS. "ENTER") THEN GOTO INIT_ENTER
$ IF (OPERATION .EQS. "COPY") THEN GOTO INIT_COPY
$INIT_MOVE:
$ IF (LOCATION .EQS. "NULL") THEN GOT GET_DIR
$ IF (LOCATION .EQS. "OVER") THEN -
	RENAME 'SOURCE_D''FILENAME';* 'SOURCE_D''FILENAME';0
$ RENAME 'TARGET''FILENAME';1 'SOURCE_D';0
$ IF (LOCATION .EQS. "OVER") THEN -
	RENAME 'SOURCE_D''FILENAME';* 'SOURCE_D''FILENAME';0
$ GOTO GET_DIR
$INIT_ENTER:
$INIT_COPY:
$GET_DIR:
$ DIRECTORY/COLUMN=1/OUTPUT=MOVE.LIS 'SOURCE'
$ FILEOPEN := "YES"
$ OPEN/READ DIRFILE MOVE.LIS
$30:
$ READ/END_OF_FILE=100 DIRFILE RECORD
$ IF ('F$LOCATE(".DIR;1",RECORD) .NE. 'F$LENGTH(RECORD)) .AND. -
	(OPERATION .NES. "MOVE") THEN GOTO 30
$ IF 'F$LOCATE(";",RECORD) .NE. 'F$LENGTH(RECORD) THEN GOTO 40
$ GOTO 30
$40:
$ ON ERROR THEN CONTINUE
$ IF (OPERATION .EQS. "MOVE") THEN RENAME 'SOURCE_D''RECORD' 'TARGET';*
$ IF (OPERATION .EQS. "ENTER") THEN MCR PIP 'TARGET''RECORD'/EN='SOURCE_D''RECORD'
$ IF (OPERATION .EQS. "COPY") THEN COPY 'SOURCE_D''RECORD' 'TARGET'
$ ON ERROR THEN GOTO 200
$ GOTO 30
$100:
$ CLOSE DIRFILE
$ DELETE MOVE.LIS;*
$ EXIT
$200:
$ IF FILEOPEN THEN CLOSE DIRFILE
$ EXIT
