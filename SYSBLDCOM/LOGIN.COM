$ IF F$MODE() .EQS. "BATCH" THEN SET NOVERIFY
$ !
$ ! LOGIN.COM -- This command file defines the basic logical names and
$ ! foreign commands needed to run system builds. Feel free to add your
$ ! own favorite command procedures, etc.
$ !
$ SQB		:==	SHOW QUEUE/BATCH
$ SB		:==	SHOW/SYSTEM/BATCH
$ VMSGEN	:==	@SYSBLDCOM$:VMSGEN
$ RESTORE	:==	@SYSBLDCOM$:SRCRESTOR
$ SETUSER	:==	$SETUSER
$ STOP_BUILD	:==	"ASSIGN/GROUP F STOP_BUILD"
$ SCAN		:== 	$SYSBLDCOM$:SCAN
$ TECO		:==	$TECO TECO
$ MAKE		:==	$TECO MAKE
$ MUNG		:==	$TECO MUNG
$ !
$ ! Define logical names for language processors used in the system build.
$ ! If you have a language processor as part of your standard system and
$ ! wish to use it instead, remove the corresponding logical name.
$ !
$ DEFINE BLISS16	MASD$:[SYSEXE]BLISS16
$ DEFINE BLISS32	MASD$:[SYSEXE]BLISS32
$ DEFINE FORTRAN	MASD$:[SYSEXE]FORTRAN
$ DEFINE MARBLI		MASD$:[SYSEXE]MARBLI
$ DEFINE MDL		MASD$:[SYSEXE]MDL
$ DEFINE PASCAL		MASD$:[SYSEXE]PASCAL
$ DEFINE PLIG		MASD$:[SYSEXE]PLIG
$ DEFINE SDL		MASD$:[SYSEXE]SDL
$ !
$ ! Define logical names used in system build procedures
$ !
$ DEFINE EXSM		SYS$SYSTEM:	! SYS.STB directory
$ DEFINE EXECML$	SYS$LIBRARY:LIB.MLB
$ DEFINE LNK$LIBRARY	SYSBLDCOM$:SYSBLDLIB.OLB
$ !
$ ! Define logical names for the devices on which the various output files will
$ ! reside
$ !
$ DEFINE LIBD$		WRKD$:
$ DEFINE OBJD$		WRKD$:
$ DEFINE LISD$		WRKD$:
$ DEFINE EXED$		WRKD$:
$ DEFINE MAPD$		WRKD$:
$ DEFINE COMD$		WRKD$:
$ DEFINE SRCD$		WRKD$:
$ !
$ ! Define logical names for some needed directories on the source master pack
$ !
$ DEFINE MSRC$		MASD$:[.SRC]
$ DEFINE MBUG$		MASD$:[.BUG]
$ DEFINE MENH$		MASD$:[.ENH]
$ DEFINE MCOM$		MASD$:[.COM]
$ DEFINE SYSBLDCOM$	MASD$:[SYSBLDCOM]
$ !
$ ! Define logical names for the directories used in the component builds
$ !
$ DEFINE SRC$		SRCD$:[.SRC]
$ DEFINE BUG$		SRCD$:[.BUG]
$ DEFINE ENH$		SRCD$:[.ENH]
$ DEFINE OBJ$		OBJD$:[.OBJ]
$ DEFINE LIS$		LISD$:[.LIS]
$ DEFINE PRMOBJ$	MASD$:[.PRMOBJ]
$ DEFINE PRMLIS$	MASD$:[.PRMLIS]
$ DEFINE COM$		COMD$:[.COM]
$ DEFINE MAP$		MAPD$:[.LIS]
$ DEFINE EXE$		EXED$:[.OBJ]
$ DEFINE LIB$		LIBD$:[.OBJ]
$ !
$ ! Define logical names for the various result directories, these contain
$ ! the results of the component builds
$ !
$ DEFINE SHRLIB$	LIBD$:[SHRLIB]
$ DEFINE RESEXE$	EXED$:[SYSEXE]
$ DEFINE RESOBJ$	OBJD$:[SYSOBJ]
$ DEFINE RESLNK$	OBJD$:[SYSOBJ]
$ DEFINE RESLIS$	LISD$:[SYSLISTS]
$ DEFINE RESMAP$	MAPD$:[SYSLISTS]
$
$ SET PROTECTION=(SY:RWED,OW:RWED,GR:R,WO) /DEFAULT
$
$ SET COMMAND SYS$LOGIN:SDL
$
$ IF F$MODE() .EQS. "BATCH" THEN GOTO 10
$ TYPE SYS$SYSTEM:NOTICE.TXT
$ GOTO END
$10:
$ SET VERIFY
$END:
