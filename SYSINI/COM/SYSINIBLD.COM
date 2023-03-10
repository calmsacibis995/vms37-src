$ !
$ !	[SYSINI.COM] S Y S I N I B L D . C O M
$ !
$ !	COMMAND FILE TO BUILD THE VAX/VMS SYSTEM INITIALIZATION PROGRAM
$ !
$ GOTO 'PHASE'
$
$INIT:
$ !
$ !	CREATE THE DIRECTORIES
$ !
$ @SYSBLDCOM$:CREATEDIR
$ EXIT
$
$UPDATE:
$ !
$ !	Create updated sources.
$ !
$ EXIT
$
$SRCLIB:
$ !
$ ! SYSINIT HAS NO SOURCE LIBRARIES
$ !
$ EXIT
$
$ASSEM:
$ !
$ !	DELETE AND RE-CREATE THE SYSINIT OBJECTS AND LISTINGS
$ !
$ REMSHRLIB MOUDEF.B32
$ DELETE OBJ$:*.OBJ;*,LIS$:*.LIS;*
$ GETSHRLIB MOUDEF.B32
$ @SYSBLDCOM$:FASM 'FACNAM "" N 'UPDATES
$ EXIT
$
$OBJLIB:
$ !
$ ! 	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB SYSINIT
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
$ !	DELETE, THEN RE-CREATE SYSINIT.EXE AND SYSINIT.MAP
$ !
$ DELETE EXE$:SYSINIT.EXE;*,MAP$:.MAP;*
$ @COM$:SYSINILNK
$ EXIT
$
$RESULT:
$ !
$ !	COPY THE IMAGE AND MAP FILES TO A SYSTEM AREA
$ !
$ CPYRESEXE EXE$:SYSINIT.EXE
$ CPYRESMAP MAP$:SYSINIT.MAP
$ CPYRESLIS LIS$:*.LIS SYSINIT.LSS
