$ !
$ !	D E L E T E L N K. C O M
$ !
$ ! THIS FILE LINKS THE NATIVE DELETE UTILITY, "DELETE.EXE".
$ !
$ QUAL := NOTRACE
$ IF P1 .NES. "" THEN QUAL := DEBUG
$ DELETE EXE$:DELETE.EXE;*, MAP$:DELETE.MAP;*
$ LINK /EXE:EXE$:DELETE/MAP:MAP$:DELETE/CROSS/FULL/'QUAL'  -
	LIB$:DELETE/LIB/INCLUDE=(DELECLI,DELEGBL,-
	DELEMAIN,DELEMSG,PURGEDIR,DELESPECS,DELRMSDEF),-
	RESOBJ$:CLIUTL/LIB/INCLUDE=(CVTTIME),-
	SYS$INPUT/OPTION
PSECT=$PLIT$,EXE
