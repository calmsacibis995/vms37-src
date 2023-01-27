$ !
$ !	[ DELTA.COM ] D E L T A B L D . C O M
$ !
$ !	Assumes [DELTA] and definitions for  EXE$:,OBJ$:,LIS$:,
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
$ !	No macros to update
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
$ !		library LIB$:DELTA.OLB then delete the
$ !		concatenated objects file.
$ !
$ DELETE LIB$:DELTA.OLB;*
$ LIB/CREATE=(BLOCKS=100,MODULES=10)/NOGLOBALS -
	LIB$:DELTA OBJ$:*.OBJ
$ RENAME OBJ$:DELTA.OBJ;* OBJ$:DELTA.OBI;*
$ DELETE OBJ$:*.OBJ;*
$ RENAME OBJ$:DELTA.OBI;* OBJ$:DELTA.OBJ;*
$ !
$ !	Conditionally Copy DELTA.OLB for other's use.
$ !
$ IF CPYOLB .EQS. "Y" THEN CPYRESOBJ LIB$:DELTA.OLB
$ EXIT
$
$LNKLIB:
$ !
$ ! Construct SYS$LIBRARY:DELTA.OBJ for those who need DELTA
$ ! linked into the image rather than mapped at image activation
$ !
$ LIB RESOBJ$:SDA/EXTRACT=(LIB$INS_DECODE,LIB$VAX_INST) /OUT=OBJ$:DECODE
$ LIB LIB$:DELTA/EXTRACT=DELTA /OUT=OBJ$:DELTA
$ APPEND OBJ$:DECODE.OBJ OBJ$:DELTA.OBJ
$ DELETE OBJ$:DECODE.OBJ;*
$ CPYSYSLIB OBJ$:DELTA.OBJ
$ EXIT
$
$LINK:
$ !
$ !	Delete then re-create EXE$:DELTA.EXE, S0DELTA.EXE and
$ !		LIS$:DELTA.MAP, S0DELTA.MAP
$ !
$ DELETE EXE$:DELTA.EXE;*,MAP$:.MAP;*, EXE$:S0DELTA.EXE;*,MAP$:.MAP;*
$ @COM$:DELTALNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy delta for distribution
$ !
$ CPYSYSLIB OBJ$:DELTA.EXE
$ CPYSYSLIB OBJ$:S0DELTA.EXE
$ !
$ !	Build the concatenated listing LIS$:DELTA.LSS
$ !
$ CPYRESLIS LIS$:*.LIS DELTA.LSS
