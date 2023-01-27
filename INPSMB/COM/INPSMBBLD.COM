$ !
$ !	[ I N P S M B . C O M ] I N P S M B B L D . C O M
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
$ SRCUPDATE PREFIX.MAR
$ EXIT
$
$SRCLIB:
$ !
$ ! There is no macro library for INPSMB
$ !
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*, LIS$:*.LIS;*
$ @SYSBLDCOM$:FASM INPSMB "" N 'UPDATES
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB INPSMB
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
$ !	Delete INPSMB map and image then re-create EXE$:INPSMB.EXE
$ !			and MAP$:INPSMB.MAP
$ !
$ DELETE EXE$:INPSMB.EXE;*, MAP$:.MAP;*
$ @COM$:INPSMBLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE  EXE$:INPSMB.EXE
$ CPYRESMAP  MAP$:INPSMB.MAP
$ !
$ !	Build the concatenated listing RESLIS$:INPSMB.LSS
$ !
$ CPYRESLIS  LIS$:*.LIS  INPSMB.LSS
