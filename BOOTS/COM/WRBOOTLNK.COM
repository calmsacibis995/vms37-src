$ !
$ ! [BOOTS.COM]WRBOOTLNK.COM - Command file to link WRITEBOOT Utility
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
$ LINK/EXE=EXE$:WRITEBOOT/MAP=MAP$:WRITEBOOT/FULL/CROSS/NOTRACE -
	LIB$:SYSBOOT.OLB/INCLUDE:(-
		WRITEBOOT,-
		READLBN, -
		RTFILREAD),-
	RESOBJ$:SYS.OLB/INCLUDE:(-
		CVTFILNAM)
