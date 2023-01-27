$ !
$ !	[ SYSBLDCOM ] T R I A L S Y S . C O M
$ !
$ !	This is a batch command file to build a new executive and relink
$ !	all the components that link with the executive symbol table.
$ !
$ !	Both the LNKLIB and LINK phases are executed in order to properly
$ !	link the exec, privileged libraries and other privileged images.
$ !
$ !	It is submitted with the following parameters:
$ !
$ !		TARGDIR = P1 (Required)	The name of the main device/directory
$ !					that contains a [.OBJ] directory
$ !					with the .OLB's and will get the
$ !					.EXE's and a [.LIS] directory
$ !					that will get the .MAP's.
$ !					Directory bracket delimiters are
$ !					optional.  If device not specified,
$ !					OBJD$ is used.
$ !
$ !		 P2 - P8 (Optional)	The name(s) of the facilities
$ !					that have their .OLB's in the
$ !					TARGDIR directory.
$ !					If none are specified, SYS is
$ !					the default.
$ !
$ !	For each facility listed in P2 - P8, TRIALSYS will look in
$ !	['TARGDIR'.COM] for 'FACILITY'BLD.COM, and use it (and all the
$ !	files it calls) from there if it is present. If it is not there,
$ !	the build files from [SYSOBJ.'FACILITY'.COM] are used.  If the
$ !	command files still cannot be found there, the master disk command
$ !	files are used instead.
$ !
$ !
$ SYSDEV = F$GETDVI("SYS$SYSDEVICE","DEVNAM")
$ PERMOBJ := 'SYSDEV'[SYSOBJ		! Where to find permanent objects
$ PROCDIR := 'SYSDEV'[SYSOBJ		! Where to find permanent procedures
$ TARGDEV := 'F$LOG("WRKD$")'		! Default result disk = WRKD$
$ TARGDIR := 'P1'			! Assume only directory name given
$ IF P2 .EQS. "" THEN P2 := SYS		! Default component = SYS only
$ POS = 'F$LOCATE(":",P1)'		! Device and directory given?
$ IF POS .EQ. 'F$LEN(P1) THEN GOTO NODEV
$ POS = POS+1
$ TARGDEV:='F$EXT(0,POS,P1)'		! If so, extract out device
$ TARGDIR:='F$EXT(POS,999,P1)'		! and directory portions
$NODEV:
$ TARGDEV = F$GETDVI(TARGDEV,"DEVNAM")
$
$ IF "''F$EXT(0,1,TARGDIR)" .NES. "[" THEN GOTO NOBRACKETS
$ LEN = 'F$LEN(TARGDIR)'-2
$ TARGDIR:='F$EXT(1,LEN,TARGDIR)'	! Strip any gratituous brackets
$NOBRACKETS:
$ SET NOON
$ SET WORKING_SET/LIMIT=400
$ SHOW DAYTIME
$ ASSIGN MASD$: SRCD$:
$ ASSIGN 'TARGDEV' COMD$:
$ ASSIGN 'TARGDEV' LB0:
$ ASSIGN 'TARGDEV' LB
$ ASSIGN 'TARGDEV' OBJD$:
$ ASSIGN 'TARGDEV' LISD$:
$ ASSIGN 'TARGDEV' MAPD$:
$ ASSIGN 'TARGDEV' EXED$:
$ ASSIGN 'TARGDEV' LIBD$:
$ ASSIGN 'TARGDEV' RESD$:
$ ASSIGN EXED$:['TARGDIR'.OBJ] EXE$:
$ ASSIGN MAPD$:['TARGDIR'.LIS] MAP$:
$ ASSIGN OBJD$:['TARGDIR'.OBJ] OBJ$:
$ ASSIGN LIBD$:['TARGDIR'.OBJ] LIB$:
$ ASSIGN LISD$:['TARGDIR'.LIS] LIS$:
$ ASSIGN 'TARGDEV'['TARGDIR'.OBJ] EXSM:
$ ASSIGN 'TARGDEV'['TARGDIR'.OBJ] RESLNK$:
$ ASSIGN 'PERMOBJ'] RESOBJ$:
$ ASSIGN 'PERMOBJ'] RESEXE$:
$ LINK :== LINK /USERLIB=PROC		! Use process defaults
$ DEFINE LNK$LIBRARY SYS$LIBRARY:SYSBLDLIB
$ @SYSBLDCOM$:CPYRESDEF			! Define result copy functions
$ CPYOLB := "N"				! Do not copy results to RESOBJ$
$ ON ERROR THEN CONTINUE
$ PHASE:== LNKLIB
$PHASE_LOOP:
$ OPEN DATA SYSBLDCOM$:VMSNEWBLD.DAT	! Open facility data file
$ !
$ ! GET NEXT FACILITY NAME FROM DATA FILE AND DETERMINE IF IT
$ ! NEEDS TO BE RE-BUILT WITH THE EXECUTIVE SYMBOL TABLE (/EX QUALIFIER).
$ !
$NXTCMD:
$ SET NOVERIFY
$ READ DATA CMD /END = ELOOP
$ IF F$EXTRACT(0,1,CMD) .EQS. "!" THEN GOTO NXTCMD
$ IF F$LOCATE("/EX",CMD) .EQ. F$LENGTH(CMD) THEN GOTO NXTCMD
$ L = 'F$LOCATE("	",CMD)		! SEARCH FOR END OF NAME
$ IF L .GT. 'F$LOCATE(" ",CMD)' THEN L = 'F$LOCATE(" ",CMD)'
$ FACNAM:='F$EXTRACT(0,L,CMD)
$ !
$ ! DETERMINE IF FACILITY'S .OLB IS IN [TARGDIR.OBJ] OR [SYSOBJ]
$ !
$ N = 2
$OLB_LOOP:
$ IF FACNAM .EQS. P'N' THEN GOTO TARGDIR_FAC
$ N = N + 1
$ IF N .LE. 8 THEN GOTO OLB_LOOP
$ !
$ ! FACILITY'S .OLB IS NOT IN [TARGDIR.OBJ]
$ !
$ SET VERIFY
$ ASSIGN 'PERMOBJ'] OBJ$:
$ ASSIGN 'PERMOBJ'] LIB$:
$ GOTO SYSOBJ_COM
$ !
$ ! FACILITY'S .OLB IS IN [TARGDIR.OBJ]
$ !
$TARGDIR_FAC:
$ SET VERIFY
$ ASSIGN OBJD$:['TARGDIR'.OBJ] OBJ$:
$ ASSIGN LIBD$:['TARGDIR'.OBJ] LIB$:
$ SET NOVERIFY
$ !
$ ! SEE IF USER COMMAND FILES ARE ALSO PRESENT
$ !
$ OPEN/READ/ERROR=SYSOBJ_COM FILE COMD$:['TARGDIR'.COM]'FACNAM'BLD.COM
$ CLOSE FILE
$ SET VERIFY
$ ASSIGN COMD$:['TARGDIR'.COM] COM$:
$ GOTO BUILD_IT
$ !
$ ! SEE IF PERMANENT COMMAND FILES ARE PRESENT IN [SYSOBJ...]
$ !
$SYSOBJ_COM:
$ OPEN/READ/ERROR=MASTER_COM FILE 'PERMOBJ'.'FACNAM'.COM]'FACNAM'BLD.COM
$ CLOSE FILE
$ SET VERIFY
$ ASSIGN 'PERMOBJ'.'FACNAM'.COM] COM$:
$ GOTO BUILD_IT
$ !
$ ! IF COMMAND FILES NOT FOUND IN EITHER USER DIRECTORY OR [SYSOBJ...]
$ ! THEN USE THE ONES ON THE MASTER DISK.
$ !
$MASTER_COM:
$ SET VERIFY
$ ASSIGN MASD$:['FACNAM'.COM] COM$:
$ !
$ !	RE-LINK THE COMPONENT WITH THE NEW EXECUTIVE
$ !
$BUILD_IT:
$
$ !***************************************************************************
$ !*									     *
$ !*			BUILD	'FACNAM'   ('PHASE' PHASE)			     *
$ !*									     *
$ !***************************************************************************
$
$ SET DEFAULT ['FACNAM']
$ IF PHASE .NES.  "LNKLIB" THEN GOTO BLD
$ IF FACNAM .EQS. "SYS" THEN @SYSBLDCOM$:NEXTVERS 'TARGDIR'  ! INCREMENT VERSION
$BLD:
$ @COM$:'FACNAM'BLD
$ ON ERROR THEN CONTINUE
$ GOTO NXTCMD
$
$ELOOP:
$ IF PHASE .EQS. "LINK" THEN GOTO EXIT
$ CLOSE DATA
$ PHASE :== LINK
$ GOTO PHASE_LOOP
$
$EXIT:
$ PURGE EXE$:*.EXE,MAP$:*.MAP
