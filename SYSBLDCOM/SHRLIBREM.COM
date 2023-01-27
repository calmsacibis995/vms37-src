$ oldvfy='f$verify(0)'
$ !
$ ! SHRLIBREM - Delete a file that has a directory pointer or copy of a
$ !		file placed in [SHRLIB].  The copy in [SHRLIB] is not changed.
$ !		(REMSHRLIB is the complement of GETSHRLIB.)
$ !
$ !	If the input device does not equal the output device, then
$ !	the file must have been copied instead of merely making an additional
$ !	directory entry that points to it.
$ !
$ ! INPUTS:
$ !
$ !	P1 - Output device and directory string
$ !	P2 - Input file list as if input to PIP
$ !	P3 - Output file name if concatenating (no device or directory)
$ !	     (May be a * IF no concatenation is desired.)
$ !
$ !
$ !	Build the output file spec.
$ !
$ ON ERROR THEN CONTINUE
$ INP_FILE:='P2
$ IF 'F$LOCATE(";",INP_FILE).EQ.'F$LENGTH(INP_FILE) THEN INP_FILE:='INP_FILE';
$ FILE_NAME:='P3
$ IF FILE_NAME .NES. "" THEN GOTO GOT_NAME
$ FILE_NAME:='P2
$ L:='F$LOCATE(":",FILE_NAME)
$ L=L+1
$ L2:='F$LENGTH(FILE_NAME)
$ FILE_NAME:='F$EXT(L,L2,FILE_NAME)
$GOT_NAME:
$ OUT_FILE:='P1''FILE_NAME'
$ IF 'F$LOCATE(";",OUT_FILE).EQ.'F$LENGTH(OUT_FILE) THEN OUT_FILE:='OUT_FILE';
$ !
$ !	Find the output device.
$ !
$ DEV:='P1
$ L:='F$LOCATE(":",DEV)
$ DEV:='F$EXT(0,L,DEV)
$ OUTDEV = F$GETDVI(DEV,"DEVNAM")
$ !
$ !	Now find the input device.
$ !
$ DEV:='P2
$ L:='F$LOCATE(":",DEV)
$ DEV:='F$EXT(0,L,DEV)
$ INDEV = F$GETDVI(DEV,"DEVNAM")
$ !
$ !	Now decide whether to copy the file or create a directory entry
$ !	that points to the file.
$ !
$ IF F$SEARCH(OUT_FILE) .EQS. "" THEN GOTO DONE
$ SET PROT=(S:RWED,G:RWED,W:RWED,O:RWED) 'OUT_FILE'
$ IF INDEV .NES. OUTDEV THEN GOTO COPY_IT
$ SET FILE/REMOVE 'OUT_FILE'
$ GOTO DONE
$COPY_IT:
$ DELETE 'OUT_FILE'
$DONE:
$ IF OLDVFY THEN SET VERIFY
