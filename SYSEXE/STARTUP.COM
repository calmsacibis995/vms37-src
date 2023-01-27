$ VERIFY = 'F$VERIFY(0)
$ ! 
$ ! VAX/VMS system startup - Release 3
$ !
$ SET NOON
$ P1:="''P1'"	! Make sure P1 is defined
$ IF P1 .NES. "" .AND. P1 .NES. "MINIMUM" THEN GOTO 'P1
$UPGRADE:
$ DISK = F$GETDVI("SYS$SYSDEVICE","DEVNAM")
$ TOPSYS = F$LOGICAL("SYS$TOPSYS")
$ ROOT = "_''DISK'"
$ IF TOPSYS .NES. "" THEN ROOT = "''ROOT'[''TOPSYS'.]"
$ DEFINE /SYSTEM SYS$SYSROOT 'ROOT'
$ DEFINE /SYSTEM SYS$SYSDISK SYS$SYSROOT:
$ SET DEFAULT SYS$SYSTEM
$ !
$ ! Assign debugger systemwide logical names
$ !
$ ASSIGN /SYSTEM SYS$INPUT: DBG$INPUT:
$ ASSIGN /SYSTEM SYS$OUTPUT: DBG$OUTPUT:
$ !
$ ! Assign systemwide logical names for RSX-11M support
$ !
$ IF TOPSYS .EQS. "" THEN ROOT = DISK
$ ASSIGN /SYSTEM 'ROOT' LB:
$ ASSIGN /SYSTEM 'ROOT' LB0:
$ ASSIGN /SYSTEM SYS$SCRATCH: WK:
$ ASSIGN /SYSTEM SYS$SCRATCH: WK0:
$ ASSIGN /SYSTEM 'DISK' SP:
$ ASSIGN /SYSTEM 'DISK' SP0:
$ !
$ ! Assign systemwide logical names for libraries and help files
$ !
$ DEASSIGN /SYSTEM SYS$SYSTEM
$ ASSIGN /SYSTEM SYS$SYSROOT:[SYSEXE] SYS$SYSTEM:
$ DEASSIGN /SYSTEM SYS$MESSAGE
$ ASSIGN /SYSTEM SYS$SYSROOT:[SYSMSG] SYS$MESSAGE:
$ DEASSIGN /SYSTEM SYS$SHARE
$ ASSIGN /SYSTEM SYS$SYSROOT:[SYSLIB] SYS$SHARE:
$ ASSIGN /SYSTEM SYS$SYSROOT:[SYSLIB] SYS$LIBRARY:
$ ASSIGN /SYSTEM SYS$SYSROOT:[SYSHLP] SYS$HELP:
$ ASSIGN /SYSTEM SYS$SYSROOT:[SYSHLP.EXAMPLES] SYS$EXAMPLES:
$ ASSIGN /SYSTEM SYS$SYSROOT:[SYSMGR] SYS$MANAGER:
$ ASSIGN /SYSTEM SYS$SYSROOT:[SYSUPD] SYS$UPDATE:
$ ASSIGN /SYSTEM SYS$SYSROOT:[SYSTEST] SYS$TEST:
$ ASSIGN /SYSTEM SYS$SYSROOT:[SYSMAINT] SYS$MAINTENANCE:
$ ASSIGN /SYSTEM SYS$SYSROOT:[SYSERR] SYS$ERRORLOG:
$ ASSIGN /SYSTEM SYS$SYSROOT:[SYSCBI] SYS$INSTRUCTION:
$ !
$ !	Start up ERRFMT
$ !
$ERRFMT:
$ DEFINE /USER SYS$OUTPUT NL:
$ RUN SYS$SYSTEM:ERRFMT.EXE -
	/PROCESS_NAME		= "ERRFMT" -
	/UIC			= [1,6] -
	/PRIORITY		= 7 -
	/INPUT			= "OPA0:" -
	/OUTPUT			= "OPA0:" -
	/ERROR			= "OPA0:" -
	/AST_LIMIT		= 64 -
	/BUFFER_LIMIT		= 40960 -
	/IO_BUFFERED		= 12 -
	/IO_DIRECT		= 12 -
	/FILE_LIMIT		= 64 -
	/WORKING_SET		= 100 -
	/MAXIMUM_WORKING_SET	= 512 -
	/PAGE_FILE		= 20480 -
	/QUEUE_LIMIT		= 64 -
	/SUBPROCESS_LIMIT	= 64 -
	/PRIVILEGES		=( -
		ACNT, -
		ALLSPOOL, -
		ALTPRI, -
		BUGCHK, -
		BYPASS, -
		CMEXEC, -
		CMKRNL, -
		DETACH, -
		DIAGNOSE, -
		EXQUOTA, -
		GROUP, -
		GRPNAM, -
		LOG_IO, -
		MOUNT, -
		NETMBX, -
		OPER, -
		NOPFNMAP, -
		PHY_IO, -
		PRMCEB, -
		PRMGBL, -
		PRMMBX, -
		PSWAPM, -
		SETPRV, -
		NOSHMEM, -
		SYSGBL, -
		SYSNAM, -
		SYSPRV, -
		TMPMBX, -
		VOLPRO, -
		WORLD)
$ IF P1 .EQS. "ERRFMT" THEN EXIT
$ !
$ ! 	Start up the Job Controller
$ !
$JOBCTL:
$ DEFINE /USER SYS$OUTPUT NL:
$ RUN SYS$SYSTEM:JOBCTL.EXE -
	/PROCESS_NAME		= "JOB_CONTROL" -
	/UIC			= [1,4] -
	/PRIORITY		= 8 -
	/INPUT			= "OPA0:" -
	/OUTPUT			= "OPA0:" -
	/ERROR			= "OPA0:" -
	/AST_LIMIT		= 64 -
	/BUFFER_LIMIT		= 40960 -
	/IO_BUFFERED		= 12 -
	/IO_DIRECT		= 12 -
	/FILE_LIMIT		= 64 -
	/WORKING_SET		= 100 -
	/MAXIMUM_WORKING_SET	= 512 -
	/PAGE_FILE		= 20480 -
	/QUEUE_LIMIT		= 64 -
	/SUBPROCESS_LIMIT	= 64 -
	/PRIVILEGES		=( -
		ACNT, -
		ALLSPOOL, -
		ALTPRI, -
		BUGCHK, -
		BYPASS, -
		CMEXEC, -
		CMKRNL, -
		DETACH, -
		DIAGNOSE, -
		EXQUOTA, -
		GROUP, -
		GRPNAM, -
		LOG_IO, -
		MOUNT, -
		NETMBX, -
		OPER, -
		NOPFNMAP, -
		PHY_IO, -
		PRMCEB, -
		PRMGBL, -
		PRMMBX, -
		PSWAPM, -
		SETPRV, -
		NOSHMEM, -
		SYSGBL, -
		SYSNAM, -
		SYSPRV, -
		TMPMBX, -
		VOLPRO, -
		WORLD)
$ IF P1 .EQS. "JOBCTL" THEN EXIT
$ !
$ !	Start up OPCOM
$ !
$OPCOM:
$ DEFINE /USER SYS$OUTPUT NL:
$ RUN SYS$SYSTEM:OPCOM.EXE -
	/PROCESS_NAME		= "OPCOM" -
	/UIC			= [1,4] -
	/PRIORITY		= 6 -
	/INPUT			= "OPA0:" -
	/OUTPUT			= "OPA0:" -
	/ERROR			= "OPA0:" -
	/AST_LIMIT		= 64 -
	/BUFFER_LIMIT		= 40960 -
	/IO_BUFFERED		= 12 -
	/IO_DIRECT		= 12 -
	/FILE_LIMIT		= 64 -
	/WORKING_SET		= 100 -
	/MAXIMUM_WORKING_SET	= 512 -
	/PAGE_FILE		= 20480 -
	/QUEUE_LIMIT		= 64 -
	/SUBPROCESS_LIMIT	= 64 -
	/PRIVILEGES		=( -
		ACNT, -
		ALLSPOOL, -
		ALTPRI, -
		BUGCHK, -
		BYPASS, -
		CMEXEC, -
		CMKRNL, -
		DETACH, -
		DIAGNOSE, -
		EXQUOTA, -
		GROUP, -
		GRPNAM, -
		LOG_IO, -
		MOUNT, -
		NETMBX, -
		OPER, -
		NOPFNMAP, -
		PHY_IO, -
		PRMCEB, -
		PRMGBL, -
		PRMMBX, -
		PSWAPM, -
		SETPRV, -
		NOSHMEM, -
		SYSGBL, -
		SYSNAM, -
		SYSPRV, -
		TMPMBX, -
		VOLPRO, -
		WORLD)
$ IF P1 .EQS. "OPCOM" THEN EXIT
$ IF P1 .EQS. "UPGRADE" THEN GOTO MINIMUM_1
$ !
$ !	Install images requiring privilege and those which should be shared.
$ !
$ @SYS$MANAGER:VMSIMAGES INSTALL VMSIMAGES 'P1'
$ IF P1 .EQS. "MINIMUM" THEN GOTO MINIMUM_1
$ !
$ !	Automatically configure I/O data base to include all
$ !	standard devices and their required drivers.
$ !
$ RUN SYS$SYSTEM:SYSGEN
AUTOCONFIGURE ALL
$ !
$ ! Enable RMS file sharing.
$ !
$ RUN SYS$SYSTEM:RMSSHARE
20
$ !
$ ! Install deferred swapfile if present
$ !
$ IF F$SEARCH ("SYS$SYSTEM:SWAPFILE1.SYS") .EQS. "" THEN GOTO SITE_SPECIFIC
$ RUN SYS$SYSTEM:SYSGEN
INSTALL SYS$SYSTEM:SWAPFILE1.SYS /SWAPFILE
$ !
$ ! Invoke system manager's installation-specific startup file.
$ !
$SITE_SPECIFIC:
$ MOUNT == "MOUNT /NOASSIST"
$ DEFINE SYS$LOGIN SYS$SYSTEM:
$ @SYS$MANAGER:SYSTARTUP
$ !
$ ! System initialization complete
$ !
$ SET LOGIN /INTERACTIVE=64
$ LOGOUT/BRIEF
$ !
$ ! For minimum system:
$ !	Skip the SYSGEN AUTOCONFIGURE ALL
$ !	Do not invoke the system dependent startup file
$ !
$MINIMUM_1:
$ RUN SYS$SYSTEM:RMSSHARE
10
$ !
$ ! System initialization complete
$ !
$ IF P1 .EQS. "UPGRADE" THEN EXIT
$ SET LOGIN /INTERACTIVE=8
$ LOGOUT /BRIEF
