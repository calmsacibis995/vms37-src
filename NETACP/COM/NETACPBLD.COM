$ !
$ !	DECnet ACP and Driver
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
$ !	Create updated sources for macro library
$ !
$ SRCUPDATE NETCTL.MDL			! CNR/CNF definitions
$ SRCUPDATE NETNPAGED.MDL		! Non-paged pool structures
$ SRCUPDATE NETUSR.MDL			! ACP control QIO interface
$ !
$ SRCUPDATE NETMACROS.MAR		! Macros for the ACP and driver
$ SRCUPDATE NETDEFS.MAR			! Symbol definitions
$ !
$ SRCUPDATE LIBHEAD.B32			! Head and tail to build bliss library
$ SRCUPDATE LIBTAIL.B32
$ EXIT
$
$SRCLIB:
$ !
$ !	Delete and re-create the macro library NET.MLB
$ !
$ DELSHRLIB LIB$:NET.L32
$ DELSHRLIB LIB$:NET.MLB
$ DELETE LIB$:NET.MLB;*
$ DELETE LIB$:NETCTL.*;*, LIB$:NETNPAGED.*;*
$ DELETE LIB$:NETUSR.*;*
$ MCR MDL LIB$:NETCTL	 = SRC$:NETCTL
$ MCR MDL LIB$:NETNPAGED = SRC$:NETNPAGED
$ MCR MDL LIB$:NETUSR	 = SRC$:NETUSR
$
$ CPYSHRLIB LIB$:NETUSR.B32			! Share file with VMSLIB
$ CPYSHRLIB LIB$:NETUSR.MAR			! Share file with VMSLIB
$
$ LIB/MACRO/CREATE LIB$:NET SRC$:NETMACROS,NETDEFS,LIB$:NETCTL,NETNPAGED,NETUSR
$
$ BLISS/LIB=LIB$:NET/LIS=LIS$:NET -
  SRC$:LIBHEAD+LIB$:NETCTL+NETNPAGED+NETUSR+SRC$:LIBTAIL
$
$ CPYSHRLIB LIB$:NET.L32
$ CPYSHRLIB LIB$:NET.MLB
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*,LIS$:*.LIS;*
$ @SYSBLDCOM$:FASM 'FACNAM' "" NOLIB 'UPDATES'
$ EXIT
$
$OBJLIB:
$ !
$ ! 	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB NETACP 150 500 30
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
$ !	Delete NETACP map and image then re-create image
$ !
$ @COM$:NETACPLNK
$ EXIT
$
$RESULT:
$ !
$ !	Move listing of DECnet license module from listing area, to
$ !	prevent it from being included in the final fiche kit.
$ !
$ RENAME LIS$:NETGETLIN.LIS;* LIB$:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:NETACP.EXE,EXE$:NETDRIVER.EXE
$ CPYRESMAP MAP$:NETACP.MAP,NETDRIVER.MAP
$ CPYRESLIS LIS$:*.LIS NETACP.LSS
