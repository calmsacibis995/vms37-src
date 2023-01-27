$ !
$ ! [BOOTS.COM]SYSBOOLNK.COM - Command file to link SYSBOOT
$ !
$ ! Assumes the following definitions:
$ !
$ !	COM$:	= COMD$:[BOOTS.COM]	command and option files
$ !	EXE$:	= EXED$:[BOOTS.OBJ]	image file, experimental
$ !		= RESOBJD$:		image file, stable
$ !	LIB$:	= LIBD$:[BOOTS.OBJ]	object library, experimental
$ !		= RESOBJ$:		object library, stable
$ !	MAP$:	= MAPD$:[BOOTS.LIS]	map file, experimental
$ !		= RESOBJ$:		map file, stable
$ !	OBJ$:	= OBJD$:[BOOTS.OBJ]	symbol table file, experimental
$ !		= RESOBJ$:		symbol table file, stable
$ !	RESOBJ$:= RESD$:[SYSTEM.OBJ]	other object libraries (old [10,20])
$ !	EXSM:	= RESOBJ$:		exec symbol table, experimental
$ !		= SYS$SYSTEM:		exec symbol table, stable
$ !
$ DELETE EXE$:SYSBOOT.EXE;*, MAP$:SYSBOOT.MAP;*
$ LINK/NOSYSSHR /EXE=EXE$:SYSBOOT/SYSTEM=0/CONTIGUOUS -
		/MAP=MAP$:SYSBOOT/FULL/CROSS-
	LIB$:SYSBOOT/INCLUDE=(-
		SYSBOOT,-
		SYSBOOCMD,-
		BOOTIO,-
		CONIO),-
	RESOBJ$:SYS/INCLUDE:(-
		BOOPARAM,-
		FILEREAD,-
		CVTFILNAM,-
		PARAMETER,-
		SCBVECTOR,-
		SPTSKEL,-
		SYSFAO,-
		SYSPARAM),-
	SYS$LIBRARY:STARLET/INCLUDE:(-
		LIB$CVT_ATB,-
		LIB$TPARSE),-
	RESOBJ$:DELTA/INCLUDE=XDELTA,-
	SYS$INPUT/OPTIONS,-
	EXSM:SYS.STB/SELECTIVE
SYMBOL=LIB$INS_DECODE,0
