$ T := /NOTRACE
$ IF P1 .NES. "" THEN T := /DEBUG
$ LINK 'T' /EXE=EXE$:MERGE /MAP=MAP$:MERGE /FULL /CROSS -
			OBJ$:MAINMERG,OBJ$:MRGCMD,OBJ$:SPECPR,-
			OBJ$:STATS,LIB$:SORT32/LIBRARY,-
			SYS$INPUT/OPTION
PSECT=SOR$CLIDATA,EXE
PSECT=SOR$MERGEDATA,EXE
PSECT=SOR$RMSSTOR,EXE
PSECT=SOR$SORTDATA,EXE
PSECT=SOR$SPECDATA,EXE
PSECT=SOR$STATDATA,EXE
$ EXIT
