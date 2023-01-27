$ !
$ !	[ S O R T 3 2 . C O M ] S O R T 3 2 B L D . C O M
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
$ !	Create updated sources
$ !
$ SRCUPDATE MAPDDB.REQ
$ EXIT
$
$SRCLIB:
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*, LIS$:*.LIS;*
$ SET NOON
$ @SYSBLDCOM$:FASM 'FACNAM' "" NOLIB 'UPDATES'
$ EXIT
$
$OBJLIB:
$ !
$ !	Create the object library from the object modules.
$ !
$ DELETE OBJ$:*.OLB;*
$ LIBRARY/CREATE LIB$:SORT32 OBJ$:SORT,SCRIO,KEYSUB,MERGE,GENKEY,GHSIM,-
				RMSIO,SORTSR,SORMSG
$ EXIT
$
$LNKLIB:
$ EXIT
$ !
$LINK:
$ !
$ !	Delete SORT32 map and image then re-create EXE$:SORT32.EXE
$ !			and MAP$:SORT32.MAP
$ !
$ DELETE EXE$:SORT32.EXE;* , MERGE.EXE;*, MAP$:*.MAP;*
$ @COM$:SORT32LNK
$ @COM$:MERGELNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:SORT32.EXE
$ CPYRESEXE EXE$:MERGE.EXE
$ CPYRESMAP MAP$:SORT32.MAP
$ CPYRESMAP MAP$:MERGE.MAP
$ !
$ !	Build the concatenated listing RESLIS$:SORT32.LSS
$ !
$ CPYRESLIS LIS$:*.LIS SORT32.LSS
