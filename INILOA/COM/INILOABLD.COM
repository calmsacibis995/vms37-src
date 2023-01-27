$ !
$ !	[ INILOA.COM ] I N I L O A B L D . C O M
$ !
$ !	Assumes [INILOA] and definitions for  EXE$:,OBJ$:,LIS$:,
$ !		MAP$:,COM$:
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
$ !	Create updated sources shared by other components
$ !
$ EXIT
$
$SRCLIB:
$ !
$ !	No macro library
$ !
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*,LIS$:*.LSS;*,*.LIS;*
$ @SYSBLDCOM$:FASM 'FACNAM "" N 'UPDATES
$ EXIT
$
$OBJLIB:
$ !
$ !	Concatenate the objects, delete and re-create the object
$ !		library LIB$:INILOA.OLB then delete the
$ !		concatenated objects file.
$ !
$ DELETE LIB$:INILOA.OLB;*
$ LIB/CREATE=(BLOCKS=500,MODULES=250)/NOGLOBALS -
	LIB$:INILOA OBJ$:*.OBJ
$ DELETE OBJ$:*.OBJ;*
$ !
$ !	Conditionally copy INILOA.OLB for other's use.
$ !
$ IF CPYOLB .EQS. "Y" THEN CPYRESOBJ LIB$:INILOA.OLB
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
$ !	Delete then re-create EXE$:INILOA.EXE, OBJ$:INILOA.STB,
$ !	and  LIS$:INILOA.MAP.
$ !
$ DELETE EXE$:INILOA.EXE;*,MAP$:INILOA.MAP;*,OBJ$:INILOA.STB;*
$ @COM$:INILOALNK
$ EXIT
$
$RESULT:
$ !
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:INILOA.EXE
$ CPYRESEXE MAP$:INILOA.MAP
$ !
$ !	Build the concatenated listing LIS$:INILOA.LSS
$ !
$ CPYRESLIS LIS$:*.LIS INILOA.LSS
