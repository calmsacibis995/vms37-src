$!
$!	[SYSINI.COM] S Y S I N I L N K . C O M
$!
$!	NATIVE MODE LINK COMMAND FILE FOR "SYSINIT.EXE"
$!
$ LINK /NOSYSSHR/EXE=EXE$:SYSINIT/MAP=MAP$:SYSINIT/FULL/CROSS/NOTRACE -
	SYS$INPUT:/OPTIONS
	LIB$:SYSINIT/INCLUDE=SYSINIT/LIBR,-
	RESOBJ$:INSTALL/INCLUDE=(INS_CREDEL,INS_MESSAGE), -
	RESOBJ$:RMS/INCLUDE=KF0SCAN,-
	RESOBJ$:SYSBOOT/INCLUDE=INITPGFIL,-
	RESOBJ$:VMOUNT/LIBRARY,-
	RESOBJ$:F11AACP/LIBRARY,-
	RESOBJ$:F11BACP/LIBRARY,-
	EXSM:SYS.STB/SELECTIVE
CLUSTER=RBLD,,,RESOBJ$:VMOUNT/INCLUDE:(REBUILD)
