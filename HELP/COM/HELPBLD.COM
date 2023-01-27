$ !
$ !	[ H E L P . C O M ] H E L P B L D . C O M
$ !
$ !	Assume default directory is [HELP] and logical names
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
$ @COM$:HELPUPD
$ EXIT
$
$SRCLIB:
$ !
$ ! Re-create source libraries
$ !
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ REMSHRLIB LBR.B32
$ DELETE OBJ$:*.OBJ;*,	LIS$:*.LIS;*
$ SET NOON				! In case of errors
$ GETSHRLIB LBR.B32
$ @COM$:HLPASNREQ
$ @SYSBLDCOM$:FASM HELP "" N 'UPDATES'
$ @COM$:HLPDEAREQ
$ EXIT
$
$OBJLIB:
$ !
$ !	Create the HELP library
$ !
$ LIBRARY /CREATE=(MODULES=200) /HELP LIB$:HELPLIB SRC$:*.HLP
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
$ !	Delete librarian map and image then re-create EXE$:VMSHELP.EXE
$ !			and MAP$:VMSHELP.MAP
$ !
$ DELETE EXE$:VMSHELP.EXE;*,	MAP$:VMSHELP.MAP;*
$ @COM$:HELPLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:VMSHELP.EXE
$ CPYRESMAP MAP$:VMSHELP.MAP
$ CPYSYSHLP LIB$:HELPLIB.HLB
$ !
$ !	Build the concatenated listing VMSHELP.LSS
$ !
$ CPYRESLIS LIS$:*.LIS VMSHELP.LSS
