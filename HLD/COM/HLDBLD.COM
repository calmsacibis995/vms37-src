$ !
$ !	[HLD.COM] H L D B L D . C O M 
$ !
$ !	Assumes [HLD] and definitions for 
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
$ !	Create updated require file sources.
$ !
$ @COM$:HLDUPD
$ EXIT
$
$SRCLIB:
$ !
$ !	Delete and re-create the macro library HLD.MLB
$ !
$ DELETE LIB$:HLD.MLB;*
$ @COM$:HLDLIB
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*,LIS$:*.LIS;*
$ @SYSBLDCOM$:FASM 'FACNAM "" N 'UPDATES
$ EXIT
$
$OBJLIB:
$ !
$ ! 	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB HLD 50 100 12
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
$ !	Delete HLD map and image then re-create HLD.EXE and HLD.EXE
$ !
$ DELETE EXE$:HLD.EXE;*,MAP$:.MAP;*
$ @COM$:HLDLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:HLD.EXE
$ CPYRESMAP MAP$:HLD.MAP
$ CPYRESLIS LIS$:*.LIS HLD.LSS
