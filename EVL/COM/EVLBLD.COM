$ !
$ !	[EVL.COM] E V L B L D . C O M 
$ !
$ !	Assumes [EVL] and definitions for system build
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
$ SRCUPDATE EVLDEF.MDL
$ SRCUPDATE EVCDEF.MDL
$ SRCUPDATE WQDEF.MDL
$ SRCUPDATE LIBHEAD.B32
$ SRCUPDATE LIBTAIL.B32
$ SRCUPDATE EVLIBRARY.B32
$ SRCUPDATE UTILDEF.REQ
$ EXIT
$
$SRCLIB:
$ !
$ !	Create libraries
$ !
$ DELETE LIB$:*.L32;*, *.MLB;*, *.B32;*, *.MAR;*
$ DELSHRLIB LIB$:EVCDEF.L32
$ DELSHRLIB LIB$:EVCDEF.MLB
$ MCR MDL LIB$:WQDEF=SRC$:WQDEF		! Not inserted into EVLIBRARY
$ MCR MDL LIB$:EVLDEF=SRC$:EVLDEF
$ MCR MDL LIB$:EVCDEF=SRC$:EVCDEF
$ BLISS /LIB=LIB$:EVLIBRARY/LIS=LIS$:EVLIBRARY -
	SRC$:EVLIBRARY+SRC$:LIBHEAD+LIB$:EVLDEF+SRC$:LIBTAIL
$ LIBRARY/MACRO/CREATE LIB$:EVCDEF LIB$:EVCDEF
$ BLISS /LIB=LIB$:EVCDEF -
	SRC$:LIBHEAD+LIB$:EVCDEF+SRC$:LIBTAIL
$
$ CPYSHRLIB LIB$:EVCDEF.MLB
$ CPYSHRLIB LIB$:EVCDEF.L32
$
$ CPYSYSLIB SRC$:UTILDEF.REQ
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ @SYSBLDCOM$:FASM 'FACNAM "" NOLIB 'UPDATES'
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB 'FACNAM'
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
$ !	Delete map and image then re-create
$ !
$ @COM$:EVLLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:EVL.EXE
$ CPYRESMAP MAP$:EVL.MAP
$ CPYRESLIS LIS$:*.LIS EVL.LSS
