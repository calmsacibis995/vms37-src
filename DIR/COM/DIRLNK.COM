$ !
$ !	Link DIRECTORY
$ !
$ DELETE EXE$:DIRECTORY.EXE;*, MAP$:DIRECTORY.MAP;*
$ QUAL := NOTRACE
$ IF P1 .NES. "" THEN QUAL := DEBUG
$ LINK /NOSYSSHR /EXE=EXE$:DIRECTORY /MAP=MAP$:DIRECTORY/FULL/CROSS -
	/'QUAL' -
	LIB$:DIRECTORY/LIBRARY/INCLUDE=DIR,-
	RESOBJ$:CLIUTL/INCLUDE=CVTTIME,SYS$INPUT/OPTION
!
! Options input
!
PSECT=$PLIT$,EXE
