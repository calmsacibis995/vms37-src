$ !
$ !	[ TMDRVR.COM ] T M D R V R B L D . C O M
$ !
$ !	Assumes [TMDRVR] and definitions for  EXE$:,OBJ$:,LIS$:,
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
$ !		library LIB$:TMDRVR.OLB then delete the
$ !		concatenated objects file.
$ !
$ DELETE LIB$:TMDRVR.OLB;*
$ LIB/CREATE=(BLOCKS=50,MODULES=10)/NOGLOBALS -
	LIB$:TMDRVR OBJ$:*.OBJ
$ DELETE OBJ$:*.OBJ;*
$ !
$ !	Conditionally copy TMDRVR.OLB for other's use.
$ !
$ IF CPYOLB .EQS. "Y" THEN CPYRESOBJ LIB$:TMDRVR.OLB
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
$ !	Delete then re-create EXE$:*.EXE, OBJ$:*.STB, and LIS$:*.MAP.
$ !
$ DELETE EXE$:TMDRIVER.EXE;*,MAP$:.MAP;*,OBJ$:.STB;*
$ @COM$:TMDRVRLNK
$ !
$ !	Copy TMDRIVER.STB to common place for MTAACP.EXE to link against.
$ !
$ CPYRESLNK OBJ$:TMDRIVER.STB
$ EXIT
$
$RESULT:
$ !
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:TMDRIVER.EXE
$ !
$ !	Build the concatenated listing LIS$:TMDRVR.LSS
$ !
$ CPYRESLIS LIS$:*.LIS TMDRVR.LSS
