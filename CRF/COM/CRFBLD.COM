$ !
$ !	[ C R F . C O M ] C R F B L D . C O M
$ !
$ !	This command file builds the multi-way tree cross reference.
$ !	Assumes [CRF.COM] and definitions for LIB$:, LIS$:, SRC$:,
$ !	OBJ$: and RESLIS$:
$ !
$ !	The only known users of CRF at the present time are the LINKER
$ !	MACRO32, and the LIBRARIAN.
$ !
$ GOTO 'PHASE'
$
$INIT:
$ !
$ !	Create the directories
$ !
$ @SYSBLDCOM$:CREATEDIR
$ EXIT
$
$UPDATE:
$ !
$ !	Create updated sources.
$ !
$ DELSHRLIB SRC$:CRFMAC.REQ
$ DELSHRLIB SRC$:CRFMACROS.MAR
$ SRCUPDATE CRF.MDL
$ SRCUPDATE CRFERRMSG.MSG
$ PUTSYSMSG SRC$:CRFERRMSG.MSG		! Insert in SYSMSG.TLB
$ SRCUPDATE CRFMAC.REQ
$ CPYSHRLIB SRC$:CRFMAC.REQ		! Share file with VMSLIB
$ SRCUPDATE CRFMACROS.MAR
$ CPYSHRLIB SRC$:CRFMACROS.MAR		! Share file with VMSLIB
$ SRCUPDATE CRFMDL.MDL
$ !
$ !	The following MDL output must be created during the UPDATE phase
$ !	instead of the SRCLIB phase because VMSLIB uses it during the
$ !	SRCLIB phase.
$ !
$ DELSHRLIB LIB$:CRF.MAR
$ DELSHRLIB LIB$:CRF.B32
$ DELETE LIB$:CRF.MAR;*,LIB$:CRF.B32;*
$ MCR MDL LIB$:CRF=SRC$:CRF
$ CPYSHRLIB LIB$:CRF.MAR		! Share file with VMSLIB
$ CPYSHRLIB LIB$:CRF.B32		! Share file with VMSLIB
$ EXIT
$
$SRCLIB:
$ !
$ !	Delete and re-create macro libraries
$ !
$ DELSHRLIB LIB$:CRFMDL.B32
$ DELETE LIB$:CRF.MLB;*
$ DELETE LIB$:CRFERRMSG.MAR;*,.B32;*
$ DELETE LIB$:CRFMDL.MAR;*,.B32;*
$ MESSAGE/MDL=SRC$:CRFERRMSG/NOOBJ SRC$:CRFERRMSG
$ MCR MDL LIB$:CRFERRMSG=SRC$:CRFERRMSG
$ MCR MDL LIB$:CRFMDL=SRC$:CRFMDL
$ CPYSHRLIB LIB$:CRFMDL.B32		! Share file with LIBRAR and LINKER
$ LIBRARY /MACRO /CREATE LIB$:CRF LIB$:CRF, CRFERRMSG, CRFMDL
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the CRF objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*, LIS$:*.LIS;*, *.LSS;*
$ @COM$:ASSIGNREQ
$ @SYSBLDCOM$:FASM CRF "" N 'UPDATES'
$ @COM$:DEASREQ
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB CRF
$ EXIT
$
$LNKLIB:
$ !
$ !	Delete and recreate map and image files.  Then copy the 
$ !	sharable image to SYS$LIBRARY for the LINKER.
$ !
$ @COM$:CRFSHRLNK
$ CPYSYSLIB EXE$:CRFSHR.EXE
$ INSHARLIB EXE$:CRFSHR			!Insert into IMAGELIB
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
$ !	Copy the image and map files to a system area
$ !
$ !	Build the concatenated listing RESLIS$:CRF.LSS
$ !
$ CPYRESLIS LIS$:*.LIS CRF.LSS
$ CPYRESEXE EXE$:CRFSHR.EXE
$ CPYRESMAP COM$:CRFSHRLNK.COM,MAP$:CRFSHR.MAP CRF.MAP
