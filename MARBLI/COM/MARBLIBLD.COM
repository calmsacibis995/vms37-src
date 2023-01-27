$ !
$ !	[ M A R B L I . C O M ] M A R B L I B L D . C O M
$ !
$ !	Assume default directory is [MARBLI] and logical names
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
$ EXIT
$
$SRCLIB:
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*,	LIS$:*.LIS;*
$ SET NOON				! In case of errors
$ @SYSBLDCOM$:FASM MARBLI "" N 'UPDATES'
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
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
$ !	Delete MARBLI map and image then re-create EXE$:MARBLI.EXE
$ !			and MAP$:MARBLI.MAP
$ !
$ DELETE EXE$:MARBLI.EXE;*,	MAP$:MARBLI.MAP;*
$ @COM$:MARBLILNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:MARBLI.EXE
$ CPYRESMAP COM$:MARBLILNK.COM,MAP$:MARBLI.MAP	MARBLI.MAP
$ !
$ !	Build the concatenated listing LIBRAR.LSS
$ !
$ CPYRESLIS LIS$:*.LIS MARBLI.LSS
