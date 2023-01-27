$ !
$ !          [ SORT11.COM ] S O R T B L D . C O M
$ !
$ GOTO 'PHASE'
$
$INIT:
$ !
$ ! CREATE THE DIRECTORIES
$ !
$ @SYSBLDCOM$:CREATEDIR
$ EXIT
$
$UPDATE:
$ EXIT
$
$SRCLIB:
$ !
$ !	No source library.
$ !
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*, LIS$:*.LIS;* ,LIS$:*.LST;*
$ SET NOON
$ @SYSBLDCOM$:FASM 'FACNAM' "" NOLIB 'UPDATES'
$ EXIT
$
$OBJLIB:
$ !
$ ! CREATE THE OBJECT LIBRARY
$ !
$ DELETE  LIB$:SRTLIB.OLB;*
$ COPY OBJ$:*.OBJ OBJ$:SORT11.OBS
$ LIBRARY /NOGLOBALS /RSX11 /CREATE LIB$:SORT11 OBJ$:SORT11.OBS
$ DELETE  OBJ$:SORT11.OBS;*,OBJ$:*.OBJ;*
$ EXIT
$
$LNKLIB:
$ !
$ ! Null LNKLIB phase
$ !
$ EXIT
$
$LINK:
$ !
$ ! CREATE THE LINKED IMAGE AND MAP
$ !
$ DELETE EXE$:SRT.EXE;*, MAP$:SRT.MAP;*
$ @COM$:SORT11LNK
$ EXIT
$
$RESULT:
$ !
$ ! COPY THE .EXE AND .MAP TO THE SYSTEM AREA
$ !
$ CPYRESEXE EXE$:SRT.EXE
$ CPYRESMAP MAP$:SRT.MAP
