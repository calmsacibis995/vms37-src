$ IF P1 .EQS. "" THEN P1 := NOTRACE
$ !
$ ! SYELNK.COM - COMMAND FILE TO LINK SYE - ERROR LOG REPORT GENERATOR
$ !
$ ! ASSUME DEFAULT = [SYE.COM] AND
$ ! LOGICAL NAMES LIB$:,  MAP$:, AND EXE$: ARE DEFINED
$ !
$ LINK  /'P1'/EXE=EXE$:SYE/MAP=MAP$:SYE/FULL/CROSS-
	LIB$:SYE/LIB/INCLUDE=ERRPRT, -
	RESOBJ$:SYS/INCLUDE=BUGCHKMSG
