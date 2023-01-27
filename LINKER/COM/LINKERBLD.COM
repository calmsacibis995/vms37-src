$ !
$ !	[ L I N K E R . C O M ] L I N K E R B L D . C O M
$ !
$ !	Assume default directory is [LINKER] and logical names
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
$ SRCUPDATE DATBAS.MDL
$ SRCUPDATE ISGENC.REQ
$ SRCUPDATE PREFIX.REQ
$ SRCUPDATE TIRAUX.REQ
$ EXIT
$
$SRCLIB:
$ !
$ !	Delete and re-create the macro library LIB$:LNK.MLB
$ !
$ !
$ MCR MDL LIB$:DATBAS=SRC$:DATBAS
$ DELETE LIB$:LNK.MLB;*
$ LIB/MAC/CREATE LIB$:LNK LIB$:DATBAS
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ REMSHRLIB CRFMDL.B32
$ DELETE OBJ$:*.OBJ;*,	LIS$:*.LIS;*
$ SET NOON				! In case of errors
$ GETSHRLIB CRFMDL.B32			! Share file with CRF
$ !
$ ! Create the bliss library file
$ !
$ DELETE LIB$:DATBAS.L32;*
$ BLISS /LIST=LIS$:DATBAS /LIBRARY=LIB$:DATBAS SYS$INPUT+LIB$:DATBAS.B32
!
! Get definitions for $EQULST and friends
!
LIBRARY
	'SYS$LIBRARY:STARLET.L32';
$ @COM$:ASSIGNREQ			! Define REQUIRE logical names
$ @SYSBLDCOM$:FASM LINKER "" N 'UPDATES'
$ @COM$:DEASREQ				! Dispose of logical names
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB LINKER 250 750 50
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
$ !	Delete linker map and image then re-create EXE$:LINK.EXE
$ !			and MAP$:LINK.MAP
$ !
$ DELETE EXE$:LINK.EXE;*,	MAP$:LINK.MAP;*
$ @COM$:LINKERLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:LINK.EXE
$ CPYRESMAP COM$:LINKERLNK.COM,MAP$:LINK.MAP	LINKER.MAP
$ !
$ !	Build the concatenated listing LINKER.LSS
$ !
$ CPYRESLIS SRC$:*.REQ,*.MSG,LIS$:*.LIS LINKER.LSS
