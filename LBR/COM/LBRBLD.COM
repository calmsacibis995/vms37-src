$ !
$ !	[ L B R . C O M ] L B R B L D . C O M
$ !
$ !	Assume default directory is [LBR] and logical names
$ !	BUG$, COM$, ENH$, EXE$, LIB$, LIS$, MAP$, OBJ$, and SRC$
$ !	are defined.
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
$ !	Create updated sources.
$ !
$ DELSHRLIB SRC$:LBRUSR.MDL
$ SRCUPDATE LBR.MDL
$ SRCUPDATE LBRUSR.MDL
$ CPYSHRLIB SRC$:LBRUSR.MDL		! Share file with VMSLIB component
$ SRCUPDATE LBRMSG.MSG
$ PUTSYSMSG SRC$:LBRMSG.MSG		! Insert in SYSMSG.TLB
$ SRCUPDATE PREFIX.REQ
$ SRCUPDATE OLDLIBFMT.MDL
$ EXIT
$
$SRCLIB:
$ !
$ !	Delete and re-create the macro library LIB$:LBR.MLB
$ !
$ DELSHRLIB LIB$:LBR.B32
$ DELSHRLIB LIB$:OLDLIBFMT.B32
$ DELETE LIB$:LBR.MLB;*
$ MCR MDL LIB$:LBR=SRC$:LBR
$ CPYSHRLIB LIB$:LBR.B32		! Share file with LIBRAR component
$ MCR MDL LIB$:OLDLIBFMT=SRC$:OLDLIBFMT
$ CPYSHRLIB LIB$:OLDLIBFMT.B32		! Share file with LIBRAR component
$ !
$ ! No need for OLDLIBFMT in the macro library
$ !
$ LIBRARY/MACRO/CREATE LIB$:LBR LIB$:LBR
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*,	LIS$:*.LIS;*
$ SET NOON				! In case of errors
$ @COM$:ASSIGNREQ
$ @SYSBLDCOM$:FASM LBR "" N 'UPDATES'
$ @COM$:DEASREQ
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB LBR
$ EXIT
$
$LNKLIB:
$ !
$ !	Delete librarian map and image then re-create EXE$:LBRSHR.EXE
$ !			and MAP$:LBRSHR.MAP
$ !
$ DELETE EXE$:LBRSHR.EXE;*,	MAP$:LBRSHR.MAP;*
$ @COM$:LBRSHRLNK
$ CPYSYSLIB EXE$:LBRSHR.EXE	! Copy to library area for MACRO/LINK
$ INSHARLIB EXE$:LBRSHR		! Insert into IMAGELIB
$ EXIT
$
$LINK:
$ !
$ ! LINK done in LNKLIB phase
$ !
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:LBRSHR.EXE
$ CPYRESMAP COM$:LBRSHRLNK.COM,MAP$:LBRSHR.MAP	LBR.MAP
$ !
$ !	Build the concatenated listing LBR.LSS
$ !
$ CPYRESLIS LIS$:*.LIS LBR.LSS
