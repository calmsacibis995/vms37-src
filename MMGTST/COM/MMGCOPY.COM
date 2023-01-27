$ !	THIS PROGRAM COPIES ALL FILES NECESSARY TO USE THE MMG TEST PACKAGE
$ !	 	TO A DEVICE AND DIRECTORY OF THE INVOKERS CHOICE
$ !	*******************************************************************
$ !
$ !   This program copies all memory management programs from a SOURCE
$ ! device you specify.  The specific directory it looks for on the device is
$ ! [MMGTST.OBJ]. It copies the programs to a TARGET device of your choice.
$ ! If no directory on the target device is specified the default is the
$ ! users CURRENT directory.
$ !
$ !   This command procedure also copies the command file, which runs these
$ ! tests, from the master disk. This is NOT ALTERABLE as the command file is
$ ! only stored in that location.  Therefore, the MASTER disk must be 
$ ! accessible for the copying to take place.  The directory on the MASTER
$ ! disk where the testing command file is stored is [MMGTST.COM].
$ !
$ASK_SOURCE:
$ INQUIRE SRCDEV "Enter the mounted SOURCE device name [RESD$] "
$ IF SRCDEV .EQS. "" THEN GOTO ASK_SOURCE
$ LEN='F$LEN(SRCDEV)-1
$ IF 'F$LOC(":",SRCDEV)' .NE. 'F$LEN(SRCDEV) THEN SRCDEV:='F$EXT(0,LEN,SRCDEV)'
$ IF "''F$LOG(SRCDEV)" .NES. "" THEN SRCDEV := 'F$LOG(SRCDEV)'
$ IF 'F$LOC(":",SRCDEV)' .EQ. 'F$LEN(SRCDEV)' THEN SRCDEV:='SRCDEV':
$ IF "''F$EXT(0,1,SRCDEV)'" .NES. "_" THEN SRCDEV := _'SRCDEV'
$
$ASK_TARGET:
$ INQUIRE TARGDEV "Enter the mounted TARGET device name "
$ IF TARGDEV .EQS. "" THEN GOTO ASK_TARGET
$ LEN='F$LEN(TARGDEV)-1
$ IF 'F$LOC(":",TARGDEV)' .NE. 'F$LEN(TARGDEV) THEN -
	TARGDEV:='F$EXT(0,LEN,TARGDEV)'
$ IF "''F$LOG(TARGDEV)" .NES. "" THEN TARGDEV := 'F$LOG(TARGDEV)'
$ IF 'F$LOC(":",TARGDEV)' .EQ. 'F$LEN(TARGDEV)' THEN TARGDEV:='TARGDEV':
$ IF "''F$EXT(0,1,TARGDEV)'" .NES. "_" THEN TARGDEV := _'TARGDEV'
$
$ASK_DIRECTORY:
$ WRITE SYS$OUTPUT "Enter the TARGET device DIRECTORY where tests are" 
$ INQUIRE TARGDIR "to be copied (defaults to CURRENT directory) [xxxxx] "
$ IF TARGDIR .EQS. "" THEN TARGDIR:= 'F$DIRECTORY()
$
$COPY_FILES:
$ COPY 'SRCDEV'[MMGTST.OBJ]*.EXE; 'TARGDEV''TARGDIR'*
$ COPY MASD$:[MMGTST.COM]MMGTESTER.COM; 'TARGDEV''TARGDIR'*
$
$COMPLETION_MESSAGE:
$ WRITE SYS$OUTPUT " "
$ WRITE SYS$OUTPUT "Files were successfully copied to "'TARGDEV''TARGDIR'
