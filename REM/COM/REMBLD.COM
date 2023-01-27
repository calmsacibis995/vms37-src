$ !
$ !	[REM.COM] R E M B L D . C O M 
$ !
$ !	Assumes [REM] and definitions for 
$ !
$ GOTO 'PHASE'
$
$INIT:
$ !
$ !	Create the Directories
$ !
$ @SYSBLDCOM$:CREATEDIR
$ EXIT
$
$UPDATE:
$ !
$ !	Create updated sources.
$ !
$ SRCUPDATE REMMACROS.MAR
$ EXIT
$
$SRCLIB:
$ !
$ !	Delete and re-create the macro library REM.MLB
$ !
$ DELETE LIB$:REM.MLB;*
$ LIBR/MAC/CREATE=(BLOCKS=2,MODULES=5) LIB$:REM SRC$:REMMACROS
$ CPYSHRLIB LIB$:REM.MLB
$ !
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*,LIS$:*.LIS;*
$ @SYSBLDCOM$:FASM 'FACNAM "" NOLIB 'UPDATES'
$ EXIT
$
$OBJLIB:
$ !
$ ! 	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB REM 40 100 10
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
$ !	Delete REM map and image then re-create REMACP.EXE and STOPREM.EXE
$ !
$ DELETE EXE$:REMACP.EXE;*,MAP$:.MAP;*
$ DELETE EXE$:STOPREM.EXE;*,MAP$:.MAP;*
$ @COM$:REMLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:REMACP.EXE
$ CPYRESEXE EXE$:STOPREM.EXE
$ CPYRESMAP MAP$:REMACP.MAP
$ CPYRESMAP MAP$:STOPREM.MAP
$ CPYRESLIS LIS$:*.LIS REMACP.LSS
