$ !
$ !	SHOWLNK.COM	- LINK COMMAND FILE FOR SHOW
$ !
$ QUAL := NOTRACE
$ IF P1 .NES. "" THEN QUAL := DEBUG
$ DELETE EXE$:SHOW.EXE;*, MAP$:SHOW.MAP;*
$ LINK /NOSYSSHR /EXE=EXE$:SHOW/MAP=MAP$:SHOW/FULL/CROSS/'QUAL' -
	SYS$INPUT/OPTIONS
CLUSTER=SHOW_1,,,LIB$:CLIUTL/INCLUDE=(SHOW$OPT_DISP,SHOW$MSG_TEXT,-
	SHOW$DEVI_CLI,SHOW$DEVI_UTL,SHOW$ERROR,SHOW$FILES,SHOW$LOGICAL,-
	SHOWMAGTAPE,SHOW$MEMORY,SHOW$NETWORK,SHOWPRINT,SHOW$MSG_UTIL,-
	SHOW$PROCESS,SHOWQUE,TRANQUEUE,SHOWRMS,SHOW$SYSTEM,SHOWTERM,SHOW$USERS,-
	SHOW$WORKING_S)
CLUSTER=SHOW_2,,,LIB$:CLIUTL/INCLUDE=SHOW$PROCESS_CONT
CLUSTER=SHOW_3,,,RESOBJ$:F11BACP/INCLUDE=MATCHNAME,-
	EXSM:SYS.STB/SELECT
SYS$LIBRARY:SCRSHR/SHARE
PSECT=INFO_PLIT,EXE
PSECT=$PLIT$,EXE
PSECT=SHOW$MSG_TABLE,EXE
PSECT=SHOW$MSG_TEXT,EXE
PSECT=SHOW$MSG_TXT,EXE
PSECT=SHOW$RDDATA,EXE
PSECT=SHOW$STATE_TBL1,EXE
PSECT=SHOW$STATE_TBL2,EXE
