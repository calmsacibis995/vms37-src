$ !
$ !	[ C O N V . C O M ] C O N V B L D . C O M
$ !
$ !
$ !	Assumes [CONV] and definitions for  EXE$:,OBJ$:,LIS$:,
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
$ SRCUPDATE CONVDEF.MDL
$ SRCUPDATE CONVERT.REQ
$ SRCUPDATE RECLDEF.MDL
$ EXIT
$
$SRCLIB:
$ !
$ !	Delete and re-create the MDL output.
$ !
$ DELSHRLIB SRC$:CONVDEF.B32
$ DELSHRLIB SRC$:RECLDEF.B32
$ MCR MDL SRC$:CONVDEF=SRC$:CONVDEF
$ MCR MDL SRC$:RECLDEF=SRC$:RECLDEF
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
$ @SYSBLDCOM$:OBJLIB CONVERT
$ EXIT
$
$LNKLIB:
$ !
$ !	Delete CONV and RECL map and image then re-create EXE$:CONVSHR.EXE,
$ !	and MAP$:CONVSHR.MAP
$ !
$ DELETE EXE$:CONVSHR.EXE;*,MAP$:.MAP;*
$ @COM$:CONVSHRLK
$ CPYSYSLIB EXE$:CONVSHR.EXE		! Copy to library area
$ INSHARLIB EXE$:CONVSHR		! Insert into IMAGELIB
$ EXIT
$
$LINK:
$ !
$ !	Delete CONVERT,RECLAIM map and image then re-create EXE$:CONVERT.EXE,
$ !	EXE$:RECLAIM.EXE,MAP$:CONVERT.MAP and MAP$:RECLAIM.MAP
$ !
$ DELETE EXE$:CONVERT.EXE;*,MAP$:CONVERT.MAP;*
$ DELETE EXE$:RECLAIM.EXE;*,MAP$:RECLAIM.MAP;*
$ @COM$:CONVLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXEs and MAPs to a System area
$ !
$ CPYRESEXE EXE$:CONVERT.EXE
$ CPYRESMAP MAP$:CONVERT.MAP
$ CPYRESEXE EXE$:CONVSHR.EXE
$ CPYRESMAP MAP$:CONVSHR.MAP
$ CPYRESEXE EXE$:RECLAIM.EXE
$ CPYRESMAP MAP$:RECLAIM.MAP
$ !
$ !	Build the concatenated listing LIS$:CONV.LSS
$ !
$ CPYRESLIS LIS$:*.LIS CONV.LSS
