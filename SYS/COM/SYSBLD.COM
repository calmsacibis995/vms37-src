$ !
$ !	[ SYS.COM ] S Y S B L D . C O M
$ !
$ !	Assumes [SYS] and definitions for  EXE$:,OBJ$:,LIS$:,
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
$ DELSHRLIB SRC$:SYSMAR.MAR
$ DELSHRLIB SRC$:SYSDEF.MDL
$ SRCUPDATE SYSMAR.MAR			! Used by VMSLIB (LIB.MLB)
$ CPYSHRLIB SRC$:SYSMAR.MAR		! Share file with VMSLIB
$ SRCUPDATE SYSDEFAE.MDL		! Part of SYSDEF.MDL
$ SRCUPDATE SYSDEFFL.MDL		! Part of SYSDEF.MDL
$ SRCUPDATE SYSDEFMP.MDL		! Part of SYSDEF.MDL
$ SRCUPDATE SYSDEFQZ.MDL		! Part of SYSDEF.MDL
$ COPY SRC$:SYSDEF%%.MDL SRC$:SYSDEF.MDL ! Used by VMSLIB SRCLIB phase
$ CPYSHRLIB SRC$:SYSDEF.MDL		! Share file with VMSLIB
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
$ !
$ !	Save copies of some object modules for inclusion into STARLET.OLB
$ !	by the VMSLIB facility
$ !
$ DELETE OBJ$:SYSVECTOR.OBB;*
$ RENAME OBJ$:SYSVECTOR.OBJ OBJ$:SYSVECTOR.OBB/NEW_VERSION
$ DELETE OBJ$:P1SYSVECT.OBB;*
$ COPY OBJ$:P1SYSVECT.OBJ OBJ$:P1SYSVECT.OBB
$ DELETE OBJ$:IODEF.OBB;*,MISCDEF;*,PRDEF;*,SSDEF;*
$ COPY OBJ$:IODEF.OBJ OBJ$:IODEF.OBB
$ COPY OBJ$:MISCDEF.OBJ OBJ$:MISCDEF.OBB
$ COPY OBJ$:PRDEF.OBJ OBJ$:PRDEF.OBB
$ COPY OBJ$:SSDEF.OBJ OBJ$:SSDEF.OBB
$ DELETE OBJ$:USRVECTOR.OBB;*
$ COPY OBJ$:USRVECTOR.OBJ OBJ$:USRVECTOR.OBB
$ EXIT
$
$OBJLIB:
$ !
$ !	Concatenate the objects, delete and re-create the object
$ !		library LIB$:SYS.OLB then delete the
$ !		concatenated objects file.
$ !
$ DELETE LIB$:SYS.OLB;*
$ LIB/CREATE=(BLOCKS=500,MODULES=250)/NOGLOBALS -
	LIB$:SYS OBJ$:*.OBJ
$ DELETE OBJ$:*.OBJ;*
$ !
$ !	Conditionally Copy SYS.OLB for other's use.
$ !
$ IF CPYOLB .EQS. "Y" THEN CPYRESOBJ LIB$:SYS.OLB
$ EXIT
$
$LNKLIB:
$ !
$ !	Delete then re-create EXE$:SYS.EXE, EXE$:SYS.STB, LIS$:SYS.MAP,
$ !	and move SYS.STB to RESOBJ$ for other privileged code to link with.
$ !
$ @COM$:SYSLNK
$ CPYRESOBJ EXE$:SYS.STB
$ EXIT
$
$LINK:
$ !
$ ! System is built during link lib phase now so that privileged libraries
$ ! can be linked during the lnklib phase and obtain the system symbol table.
$ !
$ ! Null LINK phase
$ !
$ EXIT
$
$RESULT:
$ !
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:SYS.EXE
$ CPYRESMAP MAP$:SYS.MAP
$ CPYRESEXE MAP$:SYS.MAP
$ CPYRESEXE OBJ$:SYS.STB
$ !
$ !	Build the concatenated listing LIS$:SYS.LSS
$ !
$ CPYRESLIS LIS$:*.LIS SYS.LSS
