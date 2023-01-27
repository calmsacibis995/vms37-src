$ !
$ !	[ R M S . C O M ] R M S L N K . C O M
$ !
$ !	This command file links RMS as part of the System.
$ !
$ !	Assume default directory is [RMS] and logical names
$ !	COM$, EXE$, EXSM, LIB$, MAP$, OBJ$, RESD$, RESOBJ$, and SYSBLDCOM$
$ !	are defined.
$ !
$ SET NOON
$ !
$ !	Link RMS.
$ !
$ DELETE EXE$:RMS.EXE;*, MAP$:RMS.MAP;*, EXE$:RMS.STB;*
$ LINK /EXE=EXE$:RMS /SYSTEM=0 /HEADER -
	/MAP=MAP$:RMS/FULL/CROSS -
	/SYMBOLS=EXE$:RMS -
	COM$:RMSLNK.OPT/OPTIONS
$ !
$ !	Link RMSSHARE.
$ !
$ DELETE EXE$:RMSSHARE.EXE;*, MAP$:RMSSHARE.MAP;*
$ LINK /MAP=MAP$:RMSSHARE/CROSS/FULL/NOTRACE/EXECUTABLE=EXE$:RMSSHARE-
	LIB$:RMS/INCLUDE=RMSSHARE, -
	EXSM:SYS.STB/SELECTIVE_SEARCH
