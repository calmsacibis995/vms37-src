$ !
$ ! 	[ D I F . C O M ] D I F L N K . C O M
$ !
$ !	Command procedure to link the native DIFFERENCES command 
$ !	processor.
$ !
$ !	Assume default directory is [MACRO] and logical names
$ !	COM$, EXE$, LIB$ and MAP$ are defined.
$ !
$ QUAL := NOTRACE
$ IF P1 .NES. "" THEN QUAL := DEBUG
$ DELETE EXE$:DIFF.EXE;*, MAP$:DIFF.MAP;*
$ LINK /'QUAL'  /EXE=EXE$:DIFF /MAP=MAP$:DIFF /FULL /CROSS -
	SYS$INPUT/OPTIONS
!
! Options input
!
LIB$:DIFF/INCLUDE=(DIF_DATA, DIF_GETCMD, DIF_MAIN, DIF_OUTPUT, DIFMSG, -
		   DIF$FORMAT_HEX_OCTAL)
PSECT=$PLIT$,EXE
