$ !
$ !	[ C O P Y . C O M ] C O P Y . C O M
$ !
$ !	THIS COMMAND FILE BUILDS THE NATIVE COPY UTILITY, COPY.EXE.
$ !	ASSUMES [COPY] AND DEFINITIONS FOR LIB$:, LIS$:, SRC$:,
$ !	OBJ$:, MAP$:, AND EXE$:.
$ !
$ GOTO 'PHASE'
$
$INIT:
$ !
$ !	CREATE THE DIRECTORIES
$ !
$ @SYSBLDCOM$:CREATEDIR
$ EXIT
$
$UPDATE:
$ !
$ !	Create updated sources.
$ !
$ DELETE SRC$:*.*;*
$ SRCUPDATE COPY.REQ
$ SRCUPDATE COPYMSG.REQ
$ SRCUPDATE VMSMAC.REQ
$ EXIT
$
$SRCLIB:
$ EXIT
$
$ASSEM:
$ !
$ !	DELETE AND RE-CREATE THE COPY OBJECTS AND LISTINGS
$ !
$ DELETE OBJ$:*.OBJ;*,LIS$:*.LIS;*
$ @SYSBLDCOM$:FASM 'FACNAM' "" NOLIB 'UPDATES'
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB 'FACNAM'
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
$ !	DELETE MAP AND IMAGE FILES, THEN RE-CREATE EXE$::COPY.EXE AND MAP$:COPY.MAP
$ !
$ @COM$:COPYLNK
$ EXIT
$
$RESULT:
$ !
$ !	COPY THE IMAGE AND MAP FILES TO A SYSTEM AREA
$ !
$ CPYRESEXE EXE$:COPY.EXE
$ CPYRESMAP MAP$:COPY.MAP
$ !
$ !	BUILD THE CONCATENATED LISTING LIS$:COPY.LSS
$ !
$ CPYRESLIS LIS$:*.LIS COPY.LSS
