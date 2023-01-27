$ !
$ !	[ F 1 1 A . C O M ] F 1 1 A B L D . C O M
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
$ !	Create updated require sources
$ @COM$:F11AUPD
$ EXIT
$
$SRCLIB:
$ !
$ !	No source library
$ !
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*, LIS$:*.LIS;*
$  @SYSBLDCOM$:FASM 'FACNAM' "" NOLIB 'UPDATES'
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB F11AACP
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
$ !	Delete F11A map and image then re-create EXE$:F11AACP.EXE
$ !			and LIS$:F11AACP.MAP
$ !
$ DELETE EXE$:F11AACP.EXE;*, MAP$:.MAP;*
$ @COM$:F11ALNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:F11AACP.EXE
$ CPYRESMAP MAP$:F11AACP.MAP
$ !
$ !	Build the concatenated listing LIS$:F11AACP.LSS
$ !
$ CPYRESLIS SRC$:FCPDEF.B32,LIS$:*.LIS F11AACP.LSS
