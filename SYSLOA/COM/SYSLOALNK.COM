$ !
$ !	LINK LOADABLE CPU-[IN]DEPENDENT IMAGES, SYSLOAxxx.EXE, SCSLOA.EXE
$ !
$ SET NOON
$ !
$ !	SCSLOA - FOR ALL PROCESSORS
$ !
$ DELETE EXE$:SCSLOA.EXE;*, MAP$:SCSLOA.MAP;*
$ LINK /NOSYSSHR/NOTRACEBACK -
	/EXE=EXE$:SCSLOA /SYSTEM=0 /HEADER /CONTIGUOUS -
	/MAP=MAP$:SCSLOA /FULL /CROSS -
	SYS$INPUT/OPTION
LIB$:SYSLOA/INCLUDE:(-
	SCSLOA),-
EXSM:SYS.STB/SELECTIVE
$ !
$ !	VAX 11/780:
$ !
$ DELETE EXE$:SYSLOA780.EXE;*, MAP$:SYSLOA780.MAP;*
$ LINK /NOSYSSHR/NOTRACEBACK -
	/EXE=EXE$:SYSLOA780 /SYSTEM=0 /HEADER /CONTIGUOUS -
	/MAP=MAP$:SYSLOA780 /FULL /CROSS -
	SYS$INPUT/OPTION
RESOBJ$:SYS/INCLUDE:LOAVEC, -
LIB$:SYSLOA/INCLUDE:(-
	ERRSUB780, -
	LIOSUB780, -
	MCHECK780, -
	ADAPTERR),-
EXSM:SYS.STB/SELECTIVE
$ !
$ !	VAX 11/750:
$ !
$ DELETE EXE$:SYSLOA750.EXE;*, MAP$:SYSLOA750.MAP;*
$ LINK /NOSYSSHR/NOTRACEBACK -
	/EXE=EXE$:SYSLOA750 /SYSTEM=0 /HEADER /CONTIGUOUS -
	/MAP=MAP$:SYSLOA750 /FULL /CROSS -
	SYS$INPUT/OPTION
RESOBJ$:SYS/INCLUDE:LOAVEC, -
LIB$:SYSLOA/INCLUDE:(-
	ERRSUB750, -
	LIOSUB750, -
	MCHECK750),-
EXSM:SYS.STB/SELECTIVE
$ !
$ !	VAX 11/730:
$ !
$ DELETE EXE$:SYSLOA730.EXE;*, MAP$:SYSLOA730.MAP;*
$ LINK /NOSYSSHR/NOTRACEBACK -
	/EXE=EXE$:SYSLOA730 /SYSTEM=0 /HEADER /CONTIGUOUS -
	/MAP=MAP$:SYSLOA730 /FULL /CROSS -
	SYS$INPUT/OPTION
RESOBJ$:SYS/INCLUDE:LOAVEC, -
LIB$:SYSLOA/INCLUDE:(-
	LIOSUB730, -
	ERRSUB730, -
	MCHECK730), -
EXSM:SYS.STB/SELECTIVE
