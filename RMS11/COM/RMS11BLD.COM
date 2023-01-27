$ !
$ !	[ R M S 1 1 . C O M ] R M S 1 1 B L D . C O M
$ !
$ !  *****     Updated for RMS-11 V1.8 on 02-Nov-1979 (S. Davis and R. Abramson)
$ !
$ !
$ !	Assumes [RMS11] and definitions for LIB$:, LIS$:, SRC$:,
$ !			EXE$:, MAP$: and OBJ$:
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
$ !	No sources.
$ !
$ EXIT
$
$SRCLIB:
$ !
$ !	THERE ARE CURRENTLY NO MACRO LIBRARIES TO BUILD
$ !
$ EXIT
$
$ASSEM:
$ !
$ !	THERE ARE CURRENTLY NO ASSEMBLIES NEEDED
$ !
$ EXIT
$
$OBJLIB:
$ !
$ !	Copy the RMS11 library to SYS$LIBRARY for task builds and result phase
$ !
$ CPYRES SYS$LIBRARY: PRMOBJ$:RMSLIB.OLB
$ !
$ !	Get the other object libraries for the build
$ !
$ DELETE LIB$:RMSUTL.OLB;*,LIB$:RMSIFL.OLB;*
$ COPY PRMOBJ$:RMSUTL.OLB,RMSIFL LIB$
$ !
$ ! Replace RMS11 modules in SYS$LIBRARY:SYSLIB.OLB
$ !
$ LIBR/RSX SYS$LIBRARY:SYSLIB PRMOBJ$:RMSFUN
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
$ !	Delete linker map and image then re-create
$ !		THE RMS11 UTILITIES AND MAPS
$ !
$ !	CNV.EXE,CNV.MAP  DEF.EXE,DEF.MAP  DSP.EXE,DSP.MAP
$ !	BCK.EXE,BCK.MAP  RST.EXE,RST.MAP  DFN.EXE,DFN.MAP
$ !	IFL.EXE,IFL.MAP
$ !
$ DELETE EXE$:*.EXE;*,MAP$:*.MAP;*
$ MCR TKB @COM$:RMS11TKB
$ EXIT
$
$RESULT:
$ !
$ !	COPY THE RMS11 COMPONENTS TO SYS$LIBRARY
$ !
$ CPYRES SYS$LIBRARY: PRMOBJ$:RMSMAC.MLB
$ CPYRES SYS$LIBRARY: PRMOBJ$:RMS11.ODL
$ CPYRES SYS$LIBRARY: PRMOBJ$:RMS11S.ODL
$ CPYRES SYS$LIBRARY: PRMOBJ$:RMS11X.ODL
$ CPYRES SYS$LIBRARY: PRMOBJ$:RMS12X.ODL
$ CPYRES SYS$LIBRARY: PRMOBJ$:MAKRMSODL.CMD
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:*.EXE
$ CPYRESMAP MAP$:*.MAP
