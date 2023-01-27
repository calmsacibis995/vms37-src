$ oldvfy='f$verify(0)'
$ !
$ ! CPYRESENT -  Enter directory pointer or copy file to result directory
$ !
$ !	If the input device does not equal the output device, then
$ !	the file must be copied instead of merely making an additional
$ !	directory entry that points to it.  The destination file(s)
$ !	will be purged.
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
$ OUT_FILE:='P1''P3'
$ IF 'F$LOCATE(";",OUT_FILE).EQ.'F$LENGTH(OUT_FILE) THEN OUT_FILE:='OUT_FILE';
$ !
$ !	Find the output device.
$ !
$10:
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
$ IF INDEV .NES. OUTDEV THEN GOTO COPY_IT
$ SET FILE/ENTER='OUT_FILE' 'P2'
$ GOTO DONE
$COPY_IT:
$ COPY 'P2' 'OUT_FILE'
$DONE:
$ IF OLDVFY THEN SET VERIFY
