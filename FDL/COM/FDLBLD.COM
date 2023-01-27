$ !
$ !	[ FDL.COM ] F D L B L D . C O M
$ !
$ !
$ !	Assumes [FDL] and definitions for  EXE$:,OBJ$:,LIS$:,
$ !		MAP$:,COM$:
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
$ !	Create updated sources
$ !
$ DELETE SRC$:*.*;*
$ SRCUPDATE FDLPARDEF.MDL
$ DELSHRLIB SRC$:FDLUTIL.REQ
$ SRCUPDATE FDLUTIL.REQ
$ CPYSHRLIB SRC$:FDLUTIL.REQ		! Share file with EDF, CONV components
$ EXIT
$
$SRCLIB:
$ !
$ !	Delete and re-create the MDL output.
$ !
$ DELSHRLIB SRC$:FDLPARDEF.B32
$ MCR MDL SRC$:FDLPARDEF=SRC$:FDLPARDEF
$ CPYSHRLIB SRC$:FDLPARDEF.B32		! Share file with EDF, CONV components
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly and bliss objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*,LIS$:*.LSS;*,*.LIS;*
$ @SYSBLDCOM$:FASM 'FACNAM "" N 'UPDATES
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB FDL
$ EXIT
$
$LNKLIB:
$ !
$ !	Delete FDL map and image then re-create EXE$:FDLSHR.EXE
$ !			and MAP$:FDLSHR.MAP
$ !
$ DELETE EXE$:FDLSHR.EXE;*,MAP$:.MAP;*
$ @COM$:FDLSHRLNK
$ CPYSYSLIB EXE$:FDLSHR.EXE		! Copy to library area
$ INSHARLIB EXE$:FDLSHR			! Insert into IMAGELIB
$ EXIT
$
$LINK:
$ !
$ !	Delete CREATEFDL map and image then re-create EXE$:CREATEFDL.EXE
$ !			and MAP$:CREATEFDL.MAP
$ !
$ DELETE EXE$:CREATEFDL.EXE;*,MAP$:CREATEFDL.MAP;*
$ @COM$:CREALNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXEs and MAPs to a System area
$ !
$ CPYRESEXE EXE$:CREATEFDL.EXE
$ CPYRESMAP MAP$:CREATEFDL.MAP
$ CPYRESEXE EXE$:FDLSHR.EXE
$ CPYRESMAP MAP$:FDLSHR.MAP
$ !
$ !	Build the concatenated listing LIS$:FDL.LSS
$ !
$ CPYRESLIS LIS$:*.LIS FDL.LSS
