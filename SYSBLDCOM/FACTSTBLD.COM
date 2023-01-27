$ !
$ ! FACTSTBLD - Facility test build command file
$ !
$ !	P1 = facility name, e.g EXEC
$ !	P2 = starting phase, may be any of the following:
$ !		UPDATE - default
$ !		SRCLIB
$ !		ASSEM
$ !		OBJLIB
$ !		LNKLIB
$ !		LINK
$ !	P3 = Device holding source files (default = MASD$:)
$ !	P4 = Device holding SLP update files (default = MASD$:)
$ !	P5 = Device to hold result files (default = WRKD$:)
$ !	P6 = Comma separated list of keywords to indicate which
$ !		types of SLP files should be included: BUG,ENH,EXP.
$ !		The list must be enclosed in double quotes, i.e.,
$ !		"BUG" or "ENH,EXP".  Default is "ENH".
$ !	P7 = working set size, with default being 500
$ !	P8 = Y if log file is to be printed, N if not.  Defaults to N.
$ !
$ SHOW DAYTIME
$ FACNAM :== 'P1'
$ IF P7 .EQS. "" THEN P7 = 500
$ IF P3 .EQS. "" THEN P3 := MASD$:
$ IF P4 .EQS. "" THEN P4 := MASD$:
$ IF 'F$LOC(":",P3)' .EQ. 'F$LEN(P3)' THEN P3 := 'P3':
$ IF 'F$LOC(":",P4)' .EQ. 'F$LEN(P4)' THEN P4 := 'P4':
$ IF P6 .EQS. "" THEN P6 := ENH
$ UPDATES :== 'P6'
$ IF P8 .EQS. "" THEN P8 := "N"
$ IF P8 .EQS. "N" THEN DEFINE SYS$PRINT NOPRINT
$ SET WORKING_SET/LIMIT='P7'
$ IF P5 .EQS. "" THEN P5 := WRKD$:
$ IF 'F$LOC(":",P5)' .EQ. 'F$LEN(P5)' THEN P5 := 'P5':
$ CPYOLB:=="N"		! NOT COPYING OBJECT LIBRARY TO RESOBJ:
$ SET DEFAULT 'P5'['FACNAM']
$ ON ERROR THEN GOTO CLEANUP
$ ON CONTROLY THEN GOTO CLEANUP
$ LINK :== LINK/USERLIB=PROC
$ DEFINE LNK$LIBRARY SYS$LIBRARY:SYSBLDLIB
$ @SYSBLDCOM$:CPYRESDEF		! DEFINE CPYRES FUNCTIONS
$ !
$ !	Alter some resultant copying for facility test builds.
$ !
$ CPYRESOBJ :== "@SYSBLDCOM$:NULL RESOBJ$:"
$ CPYRESEXE :== "@SYSBLDCOM$:NULL RESEXE$:"
$ CPYRESLNK :== "@SYSBLDCOM$:NULL RESLNK$:"
$ CPYSYSLIB :== "@SYSBLDCOM$:NULL RESD$:[SYSLIB]"
$ CPYSHRLIB :== "@SYSBLDCOM$:NULL SHRLIB$:"
$ GETSHRLIB :== "@SYSBLDCOM$:CPYRESENT LIB$: SHRLIB$:'"
$ INSHARLIB :==	"@SYSBLDCOM$:NULL RESD$:[SYSLIB]IMAGELIB"
$ PUTSYSMSG :== "@SYSBLDCOM$:NULL SRCD$:[SYSMSG]SYSMSG"
$ IF 'F$LOCATE("ENH",UPDATES) .NE. 'F$LENGTH(UPDATES) THEN -
	 DEFINE MSRC$ 'P3'[.SRC]
$ IF 'F$LOCATE("BUG",UPDATES) .NE. 'F$LENGTH(UPDATES) THEN -
	 DEFINE MSRC$ 'P3'[.BUGSRC]
$ IF 'F$LOCATE("ENH",UPDATES) .NE. 'F$LENGTH(UPDATES) THEN -
	 DEFINE MCOM$ 'P3'[.COM]
$ IF 'F$LOCATE("BUG",UPDATES) .NE. 'F$LENGTH(UPDATES) THEN -
	 DEFINE MCOM$ 'P3'[.BUGCOM]
$ DEFINE MBUG$ 'P4'[.BUG]
$ DEFINE MENH$ 'P4'[.ENH]
$ DEFINE BUG$ MBUG$:
$ DEFINE ENH$ MENH$:
$ DEFINE RESD$ 'P5
$ DEFINE MAPD$ 'P5
$ DEFINE LISD$ 'P5
$ DEFINE LIBD$ 'P5
$ DEFINE OBJD$ 'P5
$ DEFINE EXED$ 'P5
$ DEFINE SHRLIB$ WRKD$:[SHRLIB]
$ DEFINE RESLNK$ EXE$:
$ DEFINE COM$ MCOM$:
$ DEFINE SRC$ RESD$:[.TMPSRC]
$ DEFINE TMP$ SRC$:
$ SRCUPDATE:==@SYSBLDCOM$:SRCUPDATE
$NOBUG:
$ IF P2 .NES. "" THEN GOTO 'P2'
$UPDATE:
$ PHASE:=="UPDATE"
$ SET PROCESS/NAME='PHASE'_'FACNAM'_T
$ @COM$:'P1'BLD
$SRCLIB:
$ PHASE:=="SRCLIB"
$ SET PROCESS/NAME='PHASE'_'FACNAM'_T
$ @COM$:'P1'BLD
$ASSEM:
$ SH TRANS LIB$
$ SH TRANS LIBD$
$ PHASE:=="ASSEM"
$ SET PROCESS/NAME='PHASE'_'FACNAM'_T
$ @COM$:'P1'BLD
$OBJLIB:
$ PHASE:=="OBJLIB"
$ SET PROCESS/NAME='PHASE'_'FACNAM'_T
$ @COM$:'P1'BLD
$LNKLIB:
$ PHASE:=="LNKLIB"
$ SET PROCESS/NAME='PHASE'_'FACNAM'_T
$ @COM$:'P1'BLD
$LINK:
$ PHASE:=="LINK"
$ SET PROCESS/NAME='PHASE'_'FACNAM'_T
$ DEFINE EXSM SYS$SYSTEM:
$ @COM$:'P1'BLD
$CLEANUP:
$ STATUS = $STATUS
$ DEASSIGN MSRC$
$ DEASSIGN MBUG$
$ DEASSIGN MENH$
$ DEASSIGN RESD$
$ DEASSIGN RESLNK$
$ DEASSIGN COM$
$ DEASSIGN SRC$
$ DEASSIGN BUG$
$ DEASSIGN ENH$
$ DEASSIGN TMP$
$ EXIT 'STATUS'
