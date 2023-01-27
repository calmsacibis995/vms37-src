$ !
$ !	[ D I F . C O M ] D I F B L D . C O M
$ !
$ !	Assume default directory is [DIF] and logical names
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
$ SRCUPDATE DIFDEF.MDL
$ SRCUPDATE DIFPRE.REQ
$ EXIT
$
$SRCLIB:
$ !
$ ! Re-create source libraries
$ !
$ MCR MDL LIB$:DIFDEF=SRC$:DIFDEF
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*,	LIS$:*.LIS;*
$ SET NOON				! In case of errors
$ @COM$:DIFASNREQ
$ @SYSBLDCOM$:FASM DIF "" N 'UPDATES'
$ @COM$:DIFDEAREQ
$ EXIT
$
$OBJLIB:
$ !
$ !	Create the DIFF library
$ !
$ @SYSBLDCOM$:OBJLIB DIFF
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
$ !	Delete differences map and image then re-create EXE$:DIFF.EXE
$ !			and MAP$:DIFF.MAP
$ !
$ DELETE EXE$:DIFF.EXE;*,	MAP$:DIFF.MAP;*
$ @COM$:DIFLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:DIFF.EXE
$ CPYRESMAP COM$:DIFLNK.COM,MAP$:DIFF.MAP	DIFF.MAP
$ !
$ !	Build the concatenated listing DIF.LSS
$ !
$ CPYRESLIS LIS$:*.LIS	DIFF.LSS
