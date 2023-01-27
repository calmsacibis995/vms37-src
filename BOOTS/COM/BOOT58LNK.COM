$ !
$ ! [BOOTS.COM]BOOT58LNK.COM - Command file to link BOOT58 Utility
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
$ LINK/EXE=EXE$:BOOT58/MAP=MAP$:BOOT58/FULL/CROSS/NOTRACE -
	/SYSTEM=0/CONTIGUOUS -
	LIB$:SYSBOOT.OLB/INCLUDE:(-
		BOOT58,-
		CONIO,-
		RTFILREAD,-
		T58BOOTIO),-
	RESOBJ$:SYS.OLB/INCLUDE:(-
		CVTFILNAM, -
		SYSFAO), -
	RESOBJ$:DELTA/INCLUDE=XDELTA, -
	SYS$LIBRARY:STARLET.OLB/INCLUDE:(-
		LIB$CVT_ATB,-
		LIB$TPARSE), -
	EXSM:SYS.STB/SELECTIVE
