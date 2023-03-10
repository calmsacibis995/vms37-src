$ !
$ !	[ M A C R O . C O M ] M A C R O L N K . C O M
$ !
$ !	This command file links MACRO-32.
$ !
$ !	Assume default directory is [MACRO] and logical names
$ !	COM$, EXE$, LIB$ and MAP$ are defined.
$ !
$ P1_LENGTH='f$length(P1)
$ if 'f$locate("/",P1).ge.P1_LENGTH then P1:=/'P1'
$ if P1_LENGTH.eq.0 then P1:="/NOTRACE"
$ LINK'P1' /NOSYSSHR /EXE=EXE$:MACRO32 /MAP=MAP$:MACRO32 /FULL /CROSS -
	SYS$INPUT/OPTIONS		! Obtain options in-line
!
!	[ M A C R O . C O M ] M A C R O L N K . O P T
!
LIB$:MACRO/INCLUDE=(MAC$DATA,MAC$DATA1,MAC$IODAT),-
LIB$:MACRO/INCLUDE=(MAC$LRPTAB,MAC$SYMTAB,MAC$ERRMSG,MAC$ACTCHR),-
LIB$:MACRO/INCLUDE=(MAC$ACTIF,MAC$ACTONE,MAC$ACTOPC,MAC$ACTPRI),-
LIB$:MACRO/INCLUDE=(MAC$ACTREF,MAC$ACTSTA,MAC$APSECT,MAC$ARGSCN),-
LIB$:MACRO/INCLUDE=(MAC$BDYSCN,MAC$COMPUT,MAC$CRFDAT,MAC$CRFSUB),-
LIB$:MACRO/INCLUDE=(MAC$ERROR,MAC$FINISH,MAC$FLOAT,MAC$GETARG),-
LIB$:MACRO/INCLUDE=(MAC$GETCMD,MAC$INPUT,MAC$INTOUT,MAC$MACDEF),-
LIB$:MACRO/INCLUDE=(MAC$MACLIB,MAC$MACLIN,MAC$MACSUB,MAC$MAIN),-
LIB$:MACRO/INCLUDE=(MAC$OHDOUT,MAC$P2ACT1,MAC$P2ACT2,MAC$P2DRVR),-
LIB$:MACRO/INCLUDE=(MAC$PARSER,MAC$RPTIRP,MAC$SCANER,MAC$TIMER,MACMSG),-
!
!	Specify Source Update Merge object modules to be linked
!	with MACRO-32.
!
SYS$LIBRARY:SUMSHR/SHARE,-
!
!	Specify Cross-reference sharable image to be linked with
!	MACRO-32.
!
SYS$LIBRARY:CRFSHR/SHARE,-
!
!	Specify Librarian shareable image to be linked with MACRO-32.
!
SYS$LIBRARY:LBRSHR/SHARE
