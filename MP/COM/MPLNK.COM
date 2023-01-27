$ !
$ ! This links the multi-processing code for the 11/782.  The psects
$ ! are collected into clusters to force the loadable code to be placed
$ ! together and be based at virtual address 0.  This makes debugging
$ ! much easier as symbols in MP.STB can be used directly off @EXE$GL_MP
$ ! when looking at the MP code in a dump.  The performance measurement
$ ! routines are not mentioned explicitly, but brought in by the linker
$ ! via MP.OLB/LIBRARY so that the same link command works with or
$ ! without the assembly switch MPPFMSWT.
$ !
$LINK/NOTRACE/NOSYSSHR/EXE=EXE$:MP/MAP=MAP$:MP/FULL/CROSS/SYMBOL=EXE$:MP -
	OBJ$:MP.OLB/INCLUDE=(MPDAT,-
	MPINIT,-
	MPINT,-
	MPINTEXC,-
	MPLOAD,-
	MPAST,-
	MPPWRFAIL,-
	MPSCBVEC,-
	MPSCHED,-
	MPTIMER,-
	MPERRLOG,-
	MPMCHECK,-
	XDELTA,-
	MPERRMSG),-
	OBJ$:MP.OLB/LIBRARY,-
	EXSM:SYS.STB/SEL,SYS$INPUT/OPTION
CLUSTER=LOADABLE,0
CLUSTER=OTHER
CLUSTER=LIBRTN
COLLECT=LOADABLE,$$$$$$BEGIN,$$$$MPDATA,$$$00SCB,$$$ERLBUF,$$$INTSTK,-
	$AAEXENONPAGED,$AEXENONPAGED,$AEXNONPAGED,A$EXENONPAGED,A$EXENONPAGED,-
	AEXENONPAGED,MPPFM,WIONONPAGED,Z$DEBUGXDELTA,_END
COLLECT=OTHER,__MPLOAD
COLLECT=LIBRTN,$CODE$,_LIB$DATA,_STR$DATA,_LIB$CODE,_STR$CODE

$ !
$ ! These performance tools can only be linked if MPPFMSWT.MAR is
$ ! assembled with the appropriate modules.  This includes the
$ ! performance measurement code in MP.
$ !
$ ! LINK/NOTRACE/NOSYSSHR/EXE=EXE$:MPCLRPFM/MAP=MAP$:MPCLRPFM/FULL/CROSS -
$ !	OBJ$:MP.OLB/INCLUDE=(MPCLRPFM),-
$ !	EXSM:SYS.STB/SEL,-
$ !	EXE$:MP.STB/SEL
$ !
$ ! LINK/NOTRACE/NOSYSSHR/EXE=EXE$:MPSHWPFM/MAP=MAP$:MPSHWPFM/FULL/CROSS -
$ !	OBJ$:MP.OLB/INCLUDE=(MPSHWPFM),-
$ !	SYS$LIBRARY:STARLET.OLB/INCLUDE=(LIB$PUT_OUTPUT),-
$ !	EXSM:SYS.STB/SEL,-
$ !	EXE$:MP.STB/SEL
