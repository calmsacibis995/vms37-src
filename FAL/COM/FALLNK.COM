$ !
$ !	[ F A L . C O M ] F A L L N K . C O M
$ !
$ !	This command file links FAL.
$ !
$ !	Assume default directory is [FAL] and logical names
$ !	COM$, EXE$, LIB$, and MAP$ are defined.
$ !
$ LINK/EXE=EXE$:FAL/MAP=MAP$:FAL/NOTRACE/FULL/CROSS-
	LIB$:FAL/INCLUDE=(FALACTINI,FALACTION,FALACTMSG,-
		FALBLDATT,FALBLDSTS,FALBLDXAB,-
		FALDAPCRC,FALDAPIO,FALDECODE,FALENCODE,-
		FALLOGGER,FALMAIN,FALRMSDAP,FALSTATE)
