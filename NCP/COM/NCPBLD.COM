$ !
$ !	[NCP.COM] N C P B L D . C O M 
$ !
$ !	Assumes [NCP] and definitions for system build
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
$ !	Create updated library file sources.
$ !
$ DELETE SRC$:*.*;*
$ SRCUPDATE NCPDEF.MDL
$ SRCUPDATE NMADEF.MDL			! 2.2 definitions
$ SRCUPDATE NCPLIBRY.B32
$ SRCUPDATE NCPERRMSG.MSG
$ SRCUPDATE NCPHLP.HLP
$ SRCUPDATE NMAHEAD.B32
$ SRCUPDATE NMATAIL.B32
$ EXIT
$
$SRCLIB:
$ !
$ !	NCPLIBRY
$ !
$ DELETE LIB$:NCPDEF.B32;*, .MAR;*
$ MCR MDL LIB$:NCPDEF=SRC$:NCPDEF
$ BLISS /LIB=LIB$:NCPLIBRY /LIS=LIS$:NCPLIBRY -
	SRC$:NCPLIBRY+NMAHEAD+LIB$:NCPDEF+SRC$:NMATAIL
$ !
$ !	NMALIBRY
$ !
$ DELSHRLIB LIB$:NMALIBRY.MLB
$ DELSHRLIB LIB$:NMALIBRY.L32
$
$ DELETE LIB$:NMALIBRY.MLB;*, NMADEF.B32;*, .MAR;*
$ MCR MDL LIB$:NMADEF=SRC$:NMADEF
$ BLISS /LIB=LIB$:NMALIBRY /LIS=LIS$:NMALIBRY -
	SRC$:NMAHEAD+LIB$:NMADEF+SRC$:NMATAIL
$ LIB/MACRO/CREATE LIB$:NMALIBRY LIB$:NMADEF
$
$ CPYSHRLIB LIB$:NMADEF.MAR			! For VMSLIB, LIB.MLB
$ CPYSHRLIB LIB$:NMALIBRY.MLB
$ CPYSHRLIB LIB$:NMALIBRY.L32
$ !
$ !	NCPHELP
$ !
$ LIB/CREATE=(KEYSIZE:31,MODULE:21)/HELP LIB$:NCPHELP SRC$:NCPHLP
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*,LIS$:*.LIS;*
$ @SYSBLDCOM$:FASM 'FACNAM "" NOLIB 'UPDATES'
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB NCP
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
$ !	Delete NCP map and image then re-create NCP.EXE and NCP.MAP
$ !
$ @COM$:NCPLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:NCP.EXE
$ CPYRESMAP MAP$:NCP.MAP
$ CPYSYSHLP LIB$:NCPHELP.HLB
$ CPYRESLIS LIS$:*.LIS NCP.LSS
