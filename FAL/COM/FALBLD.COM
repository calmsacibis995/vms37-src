$ !
$ !	[ F A L . C O M ] F A L B L D . C O M
$ !
$ !	This file builds the File Access Listener (FAL) facility,
$ !	a component of DECnet-VAX.
$ !
$ !	Assume default directory is [FAL] and logical names
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
$@COM$:FALUPD
$ EXIT
$
$SRCLIB:
$ !
$ !	Delete and re-create the macro library.
$ !
$ DELETE LIB$:FALDEF.MAR;*,FALDEF.B32;*
$ DELETE LIB$:DAPDEF.MAR;*,DAPDEF.B32;*
$ DELETE LIB$:FAL.MLB;*
$ MCR MDL LIB$:FALDEF=SRC$:FALDEF
$ MCR MDL LIB$:DAPDEF=SRC$:DAPDEF
$ LIBRARY/CREATE=(BLOCKS:75,GLOBALS:0,MODULES:50)/MACRO-
	LIB$:FAL SRC$:FALMACROS+LIB$:FALDEF+DAPDEF
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
$ @SYSBLDCOM$:OBJLIB FAL
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
$ DELETE EXE$:FAL.EXE;*,MAP$:FAL.MAP;*
$ @COM$:FALLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the image and map files to a System area.
$ !
$ CPYRESEXE EXE$:FAL.EXE
$ CPYRESMAP MAP$:FAL.MAP
$ !
$ !	Concatenate the listing files and copy them to the System area.
$ !
$ CPYRESLIS LIS$:*.LIS FAL.LSS
