$ !
$ !	Define build logical names - See BLDEASLOG.COM for reverse of this.
$ !
$ !	TARGDEV = P1 (Required)	The device name of the target
$ !				volume for this build.
$ !
$ !	INDEV = P2 (Required)	The device name of the source and
$ !				command files.
$ !
$ !	INPLACE = P3 (Optional)	TRUE to indicate that the build
$ !				is in place and that the [.TMPSRC]
$ !				directory is to be used instead of [.SRC].
$ !
$ TARGDEV:='P1'
$ INDEV:='P2'
$ INPLACE:='P3'
$ !
$ !	DEFINE LOGICAL NAMES USED BY THE COMPONENT BUILD PROCEDURES
$ !
$ DEFINE MASD$	'INDEV'		! USED ONLY DURING SOURCE UPDATES
$ DEFINE COMD$	'INDEV'
$ DEFINE PRMOBJ$ 'INDEV'[.PRMOBJ]
$ DEFINE PRMLIS$ 'INDEV'[.PRMLIS]
$
$ DEFINE SRCD$	'TARGDEV'	! UPDATED SOURCES ARE ON TARGET DEVICE
$ DEFINE RESD$	'TARGDEV' 
$ DEFINE LIBD$	'TARGDEV'
$ DEFINE OBJD$	'TARGDEV' 
$ DEFINE LISD$	'TARGDEV' 
$ DEFINE MAPD$	'TARGDEV'
$ DEFINE EXED$	'TARGDEV' 
$ DEFINE LB0	'TARGDEV' 
$ DEFINE LB	'TARGDEV' 
$ DEFINE SYS$LIBRARY 'TARGDEV'[SYSLIB] 
$
$ DEFINE SHRLIB$	LIBD$:[SHRLIB]
$ DEFINE RESEXE$	EXED$:[SYSEXE]
$ DEFINE RESOBJ$	OBJD$:[SYSOBJ]
$ DEFINE RESLNK$	OBJD$:[SYSOBJ]
$ DEFINE RESLIS$	LISD$:[SYSLISTS]
$ DEFINE RESMAP$	MAPD$:[SYSLISTS]
$
$ DEFINE EXECML$ 'TARGDEV'[SYS.OBJ]LIB.MLB
$ DEFINE EXSM	'TARGDEV'[SYSOBJ] 
$
$ IF 'F$LOCATE("ENH",UPDATES) .NE. 'F$LENGTH(UPDATES) THEN -
	DEFINE MSRC$ MASD$:[.SRC]	! USED ONLY DURING UPDATE PHASE
$ IF 'F$LOCATE("BUG",UPDATES) .NE. 'F$LENGTH(UPDATES) THEN -
	DEFINE MSRC$ MASD$:[.BUGSRC]	!	"
$ DEFINE MENH$	MASD$:[.ENH]		!	"
$ DEFINE MBUG$	MASD$:[.BUG]		!	"
$ DEFINE BUG$	MASD$:[.BUG]		!	"
$ DEFINE ENH$	MASD$:[.ENH]		!	"
$ IF 'F$LOCATE("ENH",UPDATES) .NE. 'F$LENGTH(UPDATES) THEN -
	DEFINE COM$ COMD$:[.COM]
$ IF 'F$LOCATE("BUG",UPDATES) .NE. 'F$LENGTH(UPDATES) THEN -
	DEFINE COM$ COMD$:[.BUGCOM]
$ DEFINE OBJ$	OBJD$:[.OBJ] 
$ DEFINE LIB$	LIBD$:[.OBJ] 
$ DEFINE EXE$	EXED$:[.OBJ] 
$ DEFINE LIS$	LISD$:[.LIS] 
$ DEFINE MAP$	MAPD$:[.LIS] 
$ IF INPLACE THEN GOTO INPL
$ IF 'F$LOCATE("ENH",UPDATES) .NE. 'F$LENGTH(UPDATES) THEN -
	DEFINE TMP$ SRCD$:[.SRC]	!	"
$ IF 'F$LOCATE("BUG",UPDATES) .NE. 'F$LENGTH(UPDATES) THEN -
	DEFINE TMP$ SRCD$:[.BUGSRC]	!	"
$ IF 'F$LOCATE("ENH",UPDATES) .NE. 'F$LENGTH(UPDATES) THEN -
	DEFINE SRC$ SRCD$:[.SRC]
$ IF 'F$LOCATE("BUG",UPDATES) .NE. 'F$LENGTH(UPDATES) THEN -
	DEFINE SRC$ SRCD$:[.BUGSRC]
$ GOTO END
$INPL:
$ DEFINE TMP$	SRCD$:[.TMPSRC]		!	"
$ DEFINE SRC$	SRCD$:[.TMPSRC]
$ !
$END:
$!SHOW LOGICAL/ALL
