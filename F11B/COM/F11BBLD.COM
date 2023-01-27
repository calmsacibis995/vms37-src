$ !
$ !	[ F 1 1 B . C O M ] F 1 1 B B L D . C O M
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
$ @COM$:F11BUPD
$ EXIT
$
$SRCLIB:
$ !
$ !	No source library
$ !
$ DELSHRLIB SRC$:FCPDEF.B32
$ CPYSHRLIB SRC$:FCPDEF.B32
$ EXIT
$
$ASSEM:
$ DELETE OBJ$:*.OBJ;*, LIS$:*.LIS;*
$ @SYSBLDCOM$:FASM 'FACNAM "" N 'UPDATES
$ EXIT
$
$OBJLIB:
$ !
$ !	Concatenate the objects, delete and re-create the object
$ !		library LIB$:F11BACP.OLB then delete the
$ !		concatenated objects file.
$ !
$ !	Note that we get some individual objects from the F11A build.
$ !
$ @SYSBLDCOM$:OBJLIB F11BACP 200 500 250
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
$ !	Delete F11BACP map and image then re-create EXE$:F11BACP.EXE
$ !			and MAP$:F11BACP.MAP
$ !
$ DELETE EXE$:F11BACP.EXE;*, MAP$:.MAP;*
$ @COM$:F11BLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:F11BACP.EXE
$ CPYRESMAP MAP$:F11BACP.MAP
$ !
$ !	Build the concatenated listing RESLIS$:F11BACP.LSS
$ !
$ CPYRESLIS SRC$:FCPDEF.B32,LIS$:*.LIS F11BACP.LSS
