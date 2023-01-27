$ !
$ !	[ D U M P . C O M ] D U M P B L D . C O M
$ !
$ !	Assume default directory is [DUMP] and logical names
$ !	BUG$, COM$, ENH$, EXE$, LIB$, LIS$, MAP$, OBJ$, and SRC$
$ !	are defined.
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
$ SRCUPDATE DUMPRE.REQ
$ EXIT
$
$SRCLIB:
$ !
$ !	Null SRCLIB phase.
$ !
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*, LIS$:*.LIS;*
$ @SYSBLDCOM$:FASM DUMP "" N 'UPDATES'
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB DUMP
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
$ !	Delete map and image then re-create EXE$:DUMP.EXE
$ !			and MAP$:DUMP.MAP
$ !
$ DELETE EXE$:DUMP.EXE;*, MAP$:DUMP.MAP;*
$ @COM$:DUMPLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:DUMP.EXE
$ CPYRESMAP MAP$:DUMP.MAP
$ !
$ !	Build the concatenated listing DUMP.LSS
$ !
$ CPYRESLIS SRC$:DUMPRE.REQ,LIS$:*.LIS DUMP.LSS
