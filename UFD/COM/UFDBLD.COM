$ !
$ !	[ U F D . C O M ] U F D B L D . C O M
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
$ !	Create updated require file sources.  (NONE)
$ !
$ EXIT
$
$SRCLIB:
$ !
$ !	No macro library.
$ !
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*, LIS$:*.LST;*
$ @SYSBLDCOM$:FASM 'FACNAM "" N 'UPDATES
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ COPY OBJ$:*.OBJ OBJ$:UFD.OBS
$ DELETE LIB$:UFD.OLB;*
$ LIB/RSX/CREATE LIB$:UFD OBJ$:UFD.OBS
$ DELETE OBJ$:UFD.OBS;*,OBJ$:*.OBJ;*
$ IF CPYOLB THEN CPYRESOBJ LIB$:UFD.OLB
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
$ !	Delete map and image then re-create EXE$:UFD.EXE
$ !			and LIS$:UFD.MAP
$ !
$ DELETE EXE$:UFD.EXE;*, MAP$:.MAP;*
$ MCR TKB @COM$:UFDLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:UFD.EXE
$ CPYRESMAP MAP$:UFD.MAP
$ !
$ !	Build the concatenated listing RESLIS$:UFD.LSS
$ !
$ CPYRESLIS LIS$:*.LST UFD.LSS
