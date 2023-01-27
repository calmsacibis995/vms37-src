$ !
$ !	[ D M P . C O M ] D M P B L D . C O M
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
$ !	THERE IS CURRENTLY NO MACRO LIBRARIES TO BUILD
$ !
$ EXIT
$
$ASSEM:
$ DELETE OBJ$:*.OBJ;*, LIS$:*.LST;*
$ @SYSBLDCOM$:FASM 'FACNAM "" N 'UPDATES
$ EXIT
$
$OBJLIB:
$ COPY OBJ$:*.OBJ OBJ$:DMP.OBS
$ DELETE LIB$:DMP.OLB;*
$ LIB/RSX/CREATE LIB$:DMP OBJ$:DMP.OBS
$ DELETE OBJ$:*.OBS;*,OBJ$:*.OBJ;*
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
$ !	Delete linker map and image then re-create DMP
$ !
$ DELETE EXE$:*.EXE;*, MAP$:*.MAP;*
$ MCR TKB @COM$:DMPTKB
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:DMP.EXE
$ CPYRESMAP MAP$:DMP.MAP
$ CPYRESLIS LIS$:*.LST DMP.LSS
