$ !
$ !	[ V E R I F Y . C O M ] V E R I F Y B L D . C O M
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
$ !	Null UPDATE phase
$ !
$ EXIT
$
$SRCLIB:
$ !
$ !	Null SRCLIB phase
$ !
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*, LIS$:*.LIS;*
$ @SYSBLDCOM$:FASM 'FACNAM' "" NOLIB 'UPDATES'
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB VERIFY
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
$ !	Delete VERIFY map and image then re-create EXE$:VERIFY.EXE
$ !			and LIS$:VERIFY.MAP
$ !
$ DELETE EXE$:VERIFY.EXE;*, MAP$:.MAP;*
$ @COM$:VERIFYLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:VERIFY.EXE
$ CPYRESMAP MAP$:VERIFY.MAP
$ !
$ !	Build the concatenated listing LIS$:VERIFY.LSS
$ !
$ CPYRESLIS LIS$:*.LIS VERIFY.LSS
