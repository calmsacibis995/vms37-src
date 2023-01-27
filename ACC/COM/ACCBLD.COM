$ !
$ !	[ACC.COM] A C C B L D . C O M
$ !
$ !	Assumes [ACC] and definitions for  EXE$:,OBJ$:,LIS$:,
$ !		MAP$:,COM$:
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
$ !	Null update phase
$ !
$ EXIT
$
$SRCLIB:
$ !
$ !	Null source lib phase
$ !
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*,LIS$:*.LSS;*,*.LIS;*
$ @SYSBLDCOM$:FASM 'FACNAM "" N 'UPDATES
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB ACC
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
$ !	Delete ACC map and image then re-create
$ !	EXE$:CNVACC.EXE and MAP$:CNVACC.MAP
$ !
$ DELETE EXE$:CNVACC.EXE;*,MAP$:.MAP;*
$ DELETE EXE$:ACC.EXE;*,MAP$:.MAP;*
$ @COM$:ACCLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:CNVACC.EXE
$ CPYRESMAP MAP$:CNVACC.MAP
$ CPYRESEXE EXE$:ACC.EXE
$ CPYRESMAP MAP$:ACC.MAP
$ !
$ !	Build the concatenated listing
$ !
$ CPYRESLIS LIS$:*.LIS ACC.LSS
