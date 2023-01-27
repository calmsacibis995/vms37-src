$ !
$ !	[ D I S K Q . C O M ] D I S K Q B L D . C O M
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
$ !	Create updated require file sources (NONE)
$ !
$ ! 	Copy help file source onto result disk
$ !
$ SRCUPDATE DISKQHLP.HLP
$ EXIT
$
$SRCLIB:
$ !
$ !	No source library
$ !
$ EXIT
$
$ASSEM:
$ DELETE OBJ$:*.OBJ;*, LIS$:*.LIS;*
$ SET NOON
$ @SYSBLDCOM$:FASM 'FACNAM "" N 'UPDATES
$ EXIT
$
$OBJLIB:
$ !
$ !	Concatenate the objects, delete and re-create the object
$ !		library LIB$:DISKQACP.OLB then delete the
$ !		concatenated objects file.
$ !
$ @SYSBLDCOM$:OBJLIB DISKQUOTA 70 50 12
$ !
$ !	Create the facility HELP library.
$ !
$ LIBRARY/CREATE=(MODULES=5,GLOBALS=0)/HELP OBJ$:DISKQUOTA SRC$:DISKQHLP
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
$ !	Delete DISKQUOTA map and image then re-create EXE$:DISKQUOTA.EXE
$ !			and MAP$:DISKQUOTA.MAP
$ !
$ DELETE EXE$:DISKQUOTA.EXE;*, MAP$:.MAP;*
$ @COM$:DISKQLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:DISKQUOTA.EXE
$ CPYRESMAP MAP$:DISKQUOTA.MAP
$ !
$ !	Build the concatenated listing RESLIS$:DISKQUOTA.LSS
$ !
$ CPYRESLIS LIS$:*.LIS DISKQUOTA.LSS
$ !
$ !	Copy the facility HELP library.
$ !
$ CPYSYSHLP OBJ$:DISKQUOTA.HLB
