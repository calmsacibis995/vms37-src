$ !
$ !	[ U E T P . C O M ] U E T P B L D . C O M
$ !
$ !	Assumes [UETP] and definitions for LIB$:, LIS$:, SRC$:,
$ !			EXE$:, MAP$:, OBJ$:
$ !		PRMOBJ$: for data files, etc., not rebuilt
$ !		or dependent on VMS versions.
$ !		LIBD$:[SYSTST.OBJ] for SYSTST.MLB
$ !
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
$ !	Create updated data file sources.
$ !
$ SRCUPDATE UETPMSG.MSG
$ PUTSYSMSG SRC$:UETPMSG.MSG			! Insert in SYSMSG.TLB
$ SRCUPDATE SYSTSTMAC.MAR
$ SRCUPDATE UETUNT.MDL
$ EXIT
$
$SRCLIB:
$ !
$ !	Delete and re-create the macro library
$ !
$ DELSHRLIB LIB$:UETP.MLB
$ DELETE LIB$:UETPMSG.MAR;*, UETPMSG.B32;*, UETUNT.MAR;*, UETUNT.B32;*
$ MESSAGE/MDL=SRC$:UETPMSG/NOOBJ SRC$:UETPMSG
$ MCR MDL LIB$:UETPMSG=SRC$:UETPMSG
$ MCR MDL LIB$:UETUNT=SRC$:UETUNT
$ LIB/MAC/CREATE LIB$:UETP SRC$:SYSTSTMAC,LIB$:UETPMSG,LIB$:UETUNT
$ CPYSHRLIB LIB$:UETP.MLB
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and recreate the OBJ's and LIS's
$ !
$ DELETE OBJ$:*.OBJ;*, LIS$:*.LIS;*
$ @SYSBLDCOM$:FASM 'FACNAM "" N 'UPDATES
$ EXIT
$
$OBJLIB:
$ !
$ ! 	Create object library from object modules.
$ !
$ DELETE LIB$:UETP.OLB;*
$ DELETE LIB$:RSXTST.OLB;*
$ COPY OBJ$:TST*.OBJ OBJ$:RSXTST.OBS
$ LIB/RSX/CREATE LIB$:RSXTST OBJ$:RSXTST.OBS
$ DELETE OBJ$:RSXTST.OBS;*,OBJ$:TST*.OBJ;*
$ LIB/CREATE=(BLOCKS=350,GLOBALS=500) LIB$:UETP OBJ$:*.OBJ
$ DELETE OBJ$:*.OBJ;*
$ IF CPYOLB THEN CPYRESOBJ LIB$:UETP.OLB
$ IF CPYOLB THEN CPYRESOBJ LIB$:RSXTST.OLB
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
$ !	Delete map and image files, then re-create EXE$:*.EXE
$ !			and MAP$:*.MAP files.
$ !
$ @COM$:UETPLNK
$ MCR TKB @COM$:RSXTSTLNK
$ EXIT
$
$RESULT:
$ !
$ ! Copy the .EXE and data files to the SYSTEST area
$ !
$ CPYRES LIBD$:[SYSTEST] EXE$:*.EXE
$ CPYRES LIBD$:[SYSTEST] PRMOBJ$:*.*
$ !
$ !	Build the concatenated listing RESLIS$:UETP.LSS
$ !
$ CPYRESLIS LIS$:*.LIS UETP.LSS
$ !
$ !	Copy MAP files to a UETP system area
$ !
$ CPYRESMAP MAP$:*.MAP
