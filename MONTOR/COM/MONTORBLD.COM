$ !
$ !	[MONTOR.COM] M O N T O R B L D . C O M
$ !
$ !	Assumes [MONTOR] and definitions for  EXE$:,OBJ$:,LIS$:,
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
$ !	Create updated require file sources
$ !
$ DELETE SRC$:*.*;*
$ SRCUPDATE DSPDEF.MDL
$ SRCUPDATE MONDEF.SDL
$ EXIT
$
$SRCLIB:
$ !
$ !	Create data structure definition modules using MDL and SDL
$ !
$ MCR MDL LIB$:DSPDEF=SRC$:DSPDEF
$ SDL SRC$:MONDEF /LANGUAGE=(MACRO=LIB$:MONDEF, -
			     BLISS=LIB$:MONDEF.REQ, -
			     PLI=LIB$:MONDEF)
$ !
$ !	Delete and re-create the MACRO-32 macro library LIB$:MONLIB.MLB
$ !
$ DELETE LIB$:MONLIB.MLB;*
$ LIB/MACRO/CREATE LIB$:MONLIB LIB$:DSPDEF,LIB$:MONDEF
$ !
$ !	Delete and re-create the PL/I macro library LIB$:MONLIB.TLB
$ !
$ DELETE LIB$:MONLIB.TLB;*
$ LIB/TEXT/CREATE LIB$:MONLIB LIB$:MONDEF.PLI
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ !	Assign and de-assign logical names for BLISS require files
$ !
$ DELETE OBJ$:*.OBJ;*,LIS$:*.LSS;*,*.LIS;*
$ DEFINE   /PROCESS MONDEFREQ  LIB$:MONDEF.REQ
$ DEFINE   /PROCESS DSPDEFREQ  LIB$:DSPDEF.B32
$ @SYSBLDCOM$:FASM 'FACNAM "" N 'UPDATES
$ DEASSIGN /PROCESS MONDEFREQ
$ DEASSIGN /PROCESS DSPDEFREQ
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB MONTOR
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
$ !	Delete Monitor map and image then re-create
$ !	EXE$:MONITOR.EXE and MAP$:MONITOR.MAP
$ !
$ DELETE EXE$:MONITOR.EXE;*,MAP$:.MAP;*
$ @COM$:MONTORLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:MONITOR.EXE
$ CPYRESMAP MAP$:MONITOR.MAP
$ !
$ !	Build the concatenated listing
$ !
$ CPYRESLIS LIS$:*.LIS MONTOR.LSS
