$ !
$ ! LINK COMMAND FILE FOR RTPAD
$ !
$ QUAL := DEBUG
$ IF P1 .EQS. "" THEN QUAL := NOTRACE
$ DELETE EXE$:RTPAD.EXE;*, MAP$:RTPAD.MAP;*
$ LINK/NOSYSSHR /EXE=EXE$:RTPAD /MAP=MAP$:RTPAD/FULL/CROSS /'QUAL' -
	LIB$:CLIUTL/INCLUDE=(RTPAD,RSXRT,RSTSRT)/LIBRARY,-
	SYS$INPUT/OPTION
PSECT=$PLIT$,EXE
PSECT=$RMSNAM,NOEXE
PSECT=_RSTSRT,NOEXE
PSECT=_RTPAD,NOEXE
