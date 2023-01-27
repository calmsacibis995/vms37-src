!
! [ H E L P . C O M ] H E L P L N K . C O M
!
! Create the executable image VMSHELP.EXE
!
$ T := /NOTRACE
$ IF P1 .NES. "" THEN T := /DEBUG
$ DELETE EXE$:VMSHELP.EXE;*,MAP$:VMSHELP.MAP;*
$ LINK 'T' /EXE=EXE$:VMSHELP /MAP=MAP$:VMSHELP-
	 /FULL/CROSS  OBJ$:HELP, SYS$INPUT:/OPTIONS
!
! Options input
!
PSECT=$PLIT$,EXE
