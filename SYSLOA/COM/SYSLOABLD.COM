$ !
$ !	[ SYSLOA.COM ] S Y S L O A B L D . C O M
$ !
$ !	Assumes [SYSLOA] and definitions for  EXE$:,OBJ$:,LIS$:,
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
$ SRCUPDATE MCDEF.MDL
$ EXIT
$
$SRCLIB:
$ !
$ !	Create macro library used by MCHECK730.EXE
$ !
$ MCR MDL LIB$:MCDEF=SRC$:MCDEF
$ LIB/MACRO/CREATE=(MODULES:10) LIB$:MC LIB$:MCDEF
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
$ !		library LIB$:SYSLOA.OLB then delete the
$ !		concatenated objects file.
$ !
$ DELETE LIB$:SYSLOA.OLB;*
$ LIB/CREATE=(BLOCKS=500,MODULES=250)/NOGLOBALS -
	LIB$:SYSLOA OBJ$:*.OBJ
$ DELETE OBJ$:*.OBJ;*
$ !
$ !	Conditionally copy SYSLOA.OLB for other's use.
$ !
$ IF CPYOLB .EQS. "Y" THEN CPYRESOBJ LIB$:SYSLOA.OLB
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
$ !	Delete then re-create EXE$:SYSLOA*.EXE, OBJ$:SYSLOA*.STB,
$ !	and  LIS$:SYSLOA*.MAP.
$ !
$ @COM$:SYSLOALNK
$ EXIT
$
$RESULT:
$ !
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:SCSLOA.EXE
$ CPYRESEXE EXE$:SYSLOA780.EXE
$ CPYRESEXE EXE$:SYSLOA750.EXE
$ CPYRESEXE EXE$:SYSLOA730.EXE
$ CPYRESEXE MAP$:SCSLOA.MAP
$ CPYRESEXE MAP$:SYSLOA780.MAP
$ CPYRESEXE MAP$:SYSLOA750.MAP
$ CPYRESEXE MAP$:SYSLOA730.MAP
$ !
$ !	Build the concatenated listing LIS$:SYSLOA.LSS
$ !
$ CPYRESLIS LIS$:*.LIS SYSLOA.LSS
