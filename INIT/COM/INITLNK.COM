$ !
$ ! [INIT.COM]INITLNK.COM - COMMAND FILE TO LINK INITVOL
$ !
$ ! NOTE: RESOBJ$:F11AACP.OLB, VMOUNT.OLB & MTAACP.OLB ARE PREREQUISITE
$ !
$ LINK/NOSYSSHR/EXE=EXE$:INIT/MAP=MAP$:INIT/FULL/CROSS/NOTRACE -
	LIB$:INIT/INCLUDE:(INIVOL,INIPAR,INIDSK,-
	INIBAD,INITIO,INIALL,INIBIT,ININDX,ININD1,INIMFD,INITAP,RDHOME)-
	+SYS$LIBRARY:STARLET/LIB-
	+RESOBJ$:F11AACP/LIB-
	+RESOBJ$:VMOUNT/LIB-
	+RESOBJ$:MTAACP/LIB-
	+EXSM:SYS.STB/SEL
