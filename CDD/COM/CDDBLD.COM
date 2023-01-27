$ !
$ !	[ C D D . C O M ] C D D B L D . C O M
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
$ SRCUPDATE CDDLIB.B32
$ EXIT
$
$SRCLIB:
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ !
$ ! Create CDDLIB.L32
$ !
$ BLISS /LIST=LIS$:CDDLIB/LIBRARY=OBJ$:CDDLIB SRC$:CDDLIB
$ DELETE OBJ$:*.OBJ;*,	LIS$:*.LIS;*
$ @SYSBLDCOM$:FASM CDD "" N 'UPDATES'
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ RENAME OBJ$:CDDEXC2.OBJ .OBB
$ @SYSBLDCOM$:OBJLIB CDD 250 750 50
$ LIBRARY LIB$:CDD OBJ$:CDDEXC2.OBB/SELECT/NOGLOBAL
$ EXIT
$
$LNKLIB:
$ @COM$:CDDSHRLNK
$ CPYSYSLIB EXE$:CDDSHR.EXE
$ INSHARLIB EXE$:CDDSHR
$ EXIT
$
$LINK:
$ EXIT
$
$RESULT:
$ !
$ !	Copy the MAP to a System area
$ !
$ CPYRESMAP MAP$:CDDSHR.MAP	CDDSHR.MAP
