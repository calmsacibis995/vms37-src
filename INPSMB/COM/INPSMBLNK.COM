$ !
$ !	[ I N P S M B . C O M ] I N P S M B B L D . C O M
$ !
$ !   THIS COMMAND FILE LINKS THE INPUT SYMBIONT
$ !
$ LINK/NOTRACE/EXE=EXE$:INPSMB/MAP=MAP$:INPSMB/FULL/CROSS-
	LIB$:INPSMB/INCLUDE=-
		(GETCARD,-
		HANDLER,-
		MAIN,-
		PARSECMD),-
	RESOBJ$:LOGIN/INCLUDE=(HPWD,VALIDATE_USER),-
	RESOBJ$:CLIUTL/INCLUDE=(CVTTIME,TRANQUEUE),-
	EXSM:SYS.STB/SELECTIVE
