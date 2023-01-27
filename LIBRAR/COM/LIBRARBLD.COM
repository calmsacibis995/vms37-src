$ !
$ !	[ L I B R A R . C O M ] L I B R A R B L D . C O M
$ !
$ !	Assume default directory is [LIBRAR] and logical names
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
$ SRCUPDATE LIB.MDL
$ SRCUPDATE PREFIX.REQ
$ EXIT
$
$SRCLIB:
$ !
$ !	Create the REQUIRE files LIB.B32 and LIBRARMSG.B32 from updated sources
$ !
$ MCR MDL LIB$:LIB=SRC$:LIB
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ REMSHRLIB LBR.B32
$ REMSHRLIB OLDLIBFMT.B32
$ REMSHRLIB CRFMDL.B32
$ DELETE OBJ$:*.OBJ;*,	LIS$:*.LIS;*
$ SET NOON				! In case of errors
$ GETSHRLIB LBR.B32			! Share file with LBR
$ GETSHRLIB OLDLIBFMT.B32		! Share file with LBR
$ GETSHRLIB CRFMDL.B32			! Share file with CRF
$ @COM$:LIBASNREQ
$ @SYSBLDCOM$:FASM LIBRAR "" N 'UPDATES'
$ @COM$:LIBDEAREQ
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB LIBRAR
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
$ !	Delete librarian map and image then re-create EXE$:LIBRARIAN.EXE
$ !			and MAP$:LIBRARIAN.MAP
$ !
$ DELETE EXE$:LIBRARIAN.EXE;*,	MAP$:LIBRARIAN.MAP;*
$ @COM$:LIBRARLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:LIBRARIAN.EXE
$ CPYRESMAP COM$:LIBRARLNK.COM,MAP$:LIBRARIAN.MAP	LIBRARIAN.MAP
$ !
$ !	Build the concatenated listing LIBRAR.LSS
$ !
$ CPYRESLIS LIS$:*.LIS LIBRAR.LSS
