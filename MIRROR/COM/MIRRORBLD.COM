$ !
$ !	This file builds the Network Mirror Object (MIRROR),
$ !	a component of DECnet-VAX.
$ !
$ !	Assume default directory is [MIRROR] and logical names
$ !	BUG$, COM$, ENH$, EXE$, LIB$, LIS$, MAP$, OBJ$, and SRC$.
$ !
$ GOTO 'PHASE'
$
$INIT:
$ !
$ !	Create the directories.
$ !
$ @SYSBLDCOM$:CREATEDIR
$ EXIT
$
$UPDATE:
$ !
$ !	Update the master source files.
$ !
$ EXIT
$
$SRCLIB:
$ !
$ !	Delete and re-create the macro library.
$ !
$ EXIT
$
$ ASSEM:
$ !
$ !	Delete and re-create the object and listing files.
$ !
$ DELETE OBJ$:*.OBJ;*,LIS$:*.LIS;*,*.LSS;*
$ @SYSBLDCOM$:FASM 'FACNAM "" N 'UPDATES
$ EXIT
$
$ OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB MIRROR
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
$ !	Delete and re-create the image and map files.
$ !
$ DELETE EXE$:MIRROR.EXE;*,MAP$:MIRROR.MAP;*
$ LINK/NOTRACE/EXE=EXE$:MIRROR/MAP=MAP$:MIRROR -
 LIB$:MIRROR/INCLUDE=MIRROR/LIB
$ EXIT
$
$RESULT:
$ !
$ !	Copy the image and map files to a System area.
$ !
$ CPYRESEXE EXE$:MIRROR.EXE
$ CPYRESMAP MAP$:MIRROR.MAP
$ !
$ !	Copy the initialization command procedure to a System area.
$ !
$ CPYRESEXE COM$:MIRROR.COM
$ !
$ !	Concatenate the listing files and copy them to the System area.
$ !
$ CPYRESLIS LIS$:*.LIS MIRROR.LSS
