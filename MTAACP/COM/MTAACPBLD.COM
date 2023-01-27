$ !
$ !	[ MTAACP.COM ] M T A A C P B L D . C O M
$ !
$ !
$ !	Assumes [MTAACP] and definitions for  EXE$:,OBJ$:,LIS$:,
$ !		MAP$:,COM$:
$ !
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
$ !	Create updated sources
$ !
$ @COM$:MTAACPUPD
$ EXIT
$
$SRCLIB:
$ !
$ !	No source library
$ !
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly and bliss objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*,LIS$:*.LSS;*,*.LIS;*
$ @SYSBLDCOM$:FASM 'FACNAM "" N 'UPDATES
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB MTAACP
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
$ !	Delete MTAACP map and image then re-create EXE$:MTAAACP.EXE
$ !			and MAP$:MTAAACP.MAP
$ !
$ DELETE EXE$:MTAAACP.EXE;*,MAP$:.MAP;*
$ @COM$:MTAACPLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:MTAAACP.EXE
$ CPYRESMAP MAP$:MTAAACP.MAP
$ !
$ !	Build the concatenated listing LS:[10,50]MTAACP.LSS
$ !
$ CPYRESLIS LIS$:*.LIS MTAACP.LSS
