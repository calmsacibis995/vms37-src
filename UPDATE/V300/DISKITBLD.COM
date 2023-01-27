$ !++
$ ! DISKITBLD.COM - Build a VMS distribution kit
$ !
$ ! AUTHOR:	Greg Robert		14-Aug-1981
$ !		Trudy Matthews		(FT1)
$ !
$ ! ABSTRACT:	This command procedure builds VMS distribution kits
$ !		on tape or disk media
$ !
$ ! INPUT:	P1 - Source device and topsys, assumed mounted
$ !		P2 - Intermediate scratch disk, assumed loaded, not mounted
$ !		P3 - Target device, assumed loaded, not mounted
$ !		P4 - Comma separated list of options
$ !		P5 - Source device and directory for VMSKITBLD.COM, .DAT, and
$ !		     for STABACKIT.COM.
$ !		     Default device = SOURCE, default directory = [SYSUPD]
$ !
$ !		Requires privileges: 
$ !			CMEXEC,CMKRNL,SYSPRV,LOG_IO,OPER and VOLPRO.
$ !
$ ! OPTIONS:	PAUSE	- Pauses at the end of each pass to allow the
$ !			  scratch media to be saved
$ !
$ !		RESTART - Allows the procedure to be restarted at any of the
$ !			  VMSKITBLD invocations (PASS1, PASS2, PASS3, or PASS4)
$ !			  or at any of the BACKUP invocations (PASS1_B, PASS2_B,
$ !			  or PASS3_B, PASS4_B)
$ !		NONE	- No options specified. (this is the default)
$ !
$ ! DESCRIPTION: This is a four pass procedure.  Each pass consists of
$ !		a VMSKITBLD operation from the source device to the inter-
$ !		mediate device, followed by a backup operation from the
$ !		intermediate device to the target device.  Each pass results
$ !		in a saveset on the target media.
$ !
$ ! SAVESETS:	VMSver - Command file set (to drive upgrade procedure)
$ !		REQUIRED - Required file set
$ !		LIBRARY - Library file set
$ !		OPTIONAL - Optional file set
$ !		VMSOPT - Command file set (to drive installation of OPTIONAL)
$ !		EDTCAI - EDTCAI command file set (to drive EDTCAI installation)
$ !		EDTCAI1 - EDTCAI data file set
$ !
$ !		Characters 4-6 of the saveset name (VER in examples)
$ !		is replaced with the version number of the system.

		$ VERSION = "300"

$ ! NOTE:	If the target device is a disk with a capacity of
$ !		fewer than 25,000 blocks, then the optional save
$ !		set is placed on a second volume, with the required
$ !		files (i.e. the optional volume is bootable).
$ !--
$
$ BEGIN:
$	SCRATCH = ""
$	TARGET = ""
$	TOPSYS = "SYS0."
$	ROOT = TOPSYS - "."
$	DEFDIR = F$DIRECTORY ()
$	DEFUIC = F$USER ()
$	DEFDISK = F$LOGICAL ("SYS$DISK")
$	ON ERROR THEN GOTO RUNDOWN
$	ON CONTROL_Y THEN GOTO CONTROLY
$	WRITE SYS$OUTPUT "Build a distribution kit."
$	SET PROCESS /PRIV = (CMEXEC, CMKRNL, VOLPRO, LOG_IO, SYSPRV, OPER)
$	SET UIC  [001,004]
$	SOURCE	 = P1
$	SCRATCH	 = P2
$	TARGET	 = P3
$	ERROR_COUNT = 0
$	START_ERROR_COUNT = 0
$	MOUNT_TARGET = "MOUNT"
$	SUMMARY = " *** FAILURE ***, distribution kit is not complete"
$
$	!
$	! Parse options
$	!
$	OPTIONS	= "," + P4 + ","
$	OPTLEN = F$LENGTH (OPTIONS)
$
$	PAUSE  =  "FALSE"
$	RESTART  =  "FALSE"
$	IF F$LOC (",NONE,", OPTIONS) .NE. OPTLEN THEN GOTO GETSOURCE
$
$	IF F$LOC (",PAUSE,", OPTIONS) .NE. OPTLEN THEN PAUSE := TRUE
$	OPTIONS = OPTIONS - ",PAUSE"
$
$	IF F$LOC(",RESTART,",OPTIONS) .NE. OPTLEN THEN RESTART := TRUE
$	OPTIONS = OPTIONS - ",RESTART"
$
$	IF OPTIONS .EQS. "," .OR. OPTIONS .EQS. ",," THEN GOTO GETSOURCE
$	WRITE SYS$OUTPUT "''OPTIONS' is an unrecognized option"
$	GOTO RUNDOWN
$
$	!
$	! Request any missing parameters, allocate and intialize devices
$	!
$ GETSOURCE:
$	ON WARNING THEN GOTO GETSOURCE
$	IF P1 .NES. "" THEN GOTO 10$
$	INQUIRE SOURCE "Specify source device (DDCU:[topsys])"
$	IF SOURCE .EQS. "" THEN GOTO GETSOURCE
$ 10$:	P1 = ""
$	IF F$LOCATE(":",SOURCE) .EQ. F$LENGTH(SOURCE) THEN -
		SOURCE = SOURCE + ":"
$	SOURCE_DEV = SOURCE
$	IF F$LOCATE("[",SOURCE) .NE. F$LENGTH(SOURCE) THEN -
		SOURCE_DEV = SOURCE_DEV - "]" + ".]"
$	IF F$GETDVI (SOURCE_DEV, "MNT") THEN GOTO GETSCRATCH
$	WRITE SYS$OUTPUT "Source device must be mounted"
$	GOTO GETSOURCE
$
$ GETSCRATCH:
$	ON WARNING THEN GOTO GETSCRATCH
$	IF P2 .NES. "" THEN GOTO 20$
$	INQUIRE SCRATCH "Specify scratch device (DDCU:)"
$	IF SCRATCH .EQS. "" THEN GOTO GETSCRATCH
$ 20$:	P2 = ""
$	SCRATCH = SCRATCH - ":"
$	IF .NOT. F$GETDVI (SCRATCH, "MNT") THEN GOTO 25$
$	WRITE SYS$OUTPUT "Scratch disk ''SCRATCH' already mounted"
$	GOTO GETSCRATCH
$ 25$:	ALLOCATE 'SCRATCH
$
$ GETTARGET:
$	ON WARNING THEN GOTO GETTARGET
$	IF P3 .NES. "" THEN GOTO 30$
$	INQUIRE TARGET "Specify target device (DDCU:)"
$	IF TARGET .EQS. "" THEN GOTO GETTARGET
$ 30$:	P3 = ""
$	TARGET = TARGET - ":"
$	IF .NOT. F$GETDVI (TARGET, "MNT") THEN GOTO PREPARE_MEDIA
$	WRITE SYS$OUTPUT "Target disk ''TARGET' already mounted"
$	GOTO GETTARGET
$
$ PREPARE_MEDIA:
$	IF RESTART THEN GOTO MNT_TARGET
$	IF F$MODE () .NES. "INTERACTIVE" THEN GOTO INIT_TARGET
$	WRITE SYS$OUTPUT -
"Please place the PRIMARY kit medium in the target drive, ''TARGET':."
$DO_OVER:
$	INQUIRE OK "Is ''TARGET': ready to be initialized? (Y/N)"
$	IF .NOT. OK THEN GOTO DO_OVER
$	WRITE SYS$OUTPUT -
"Please place the scratch RL02 in the scratch drive, ''SCRATCH':."
$DO_AGAIN:
$	INQUIRE ANSWER "Is ''SCRATCH': ready to be initialized? (Y/N)"
$	IF .NOT. ANSWER THEN GOTO DO_AGAIN
$
$ INIT_TARGET:
$	INIT_TARGET = "INIT"
$	IF F$GETDVI (TARGET, "DEVCLASS") .EQ. 1 THEN INIT_TARGET = "INIT /MAXIMUM_FILES=300"
$	INIT_TARGET 'TARGET VMS'VERSION
$
$ MNT_TARGET:
$	START_ERROR_COUNT = F$GETDVI (TARGET, "ERRCNT")
$	IF F$GETDVI (TARGET, "DEVCLASS") .EQ. 2 THEN MOUNT_TARGET= "MOUNT /FOREIGN"
$	MOUNT_TARGET 'TARGET /OV=ID
$
$ START:
$	COMMAND	:= 'P5
$	IF COMMAND .EQS. "" THEN COMMAND = SOURCE_DEV + "[SYSUPD]"
$	BLOCKSIZE := ""		! Assume target device is a disk.
$	IF F$GETDVI (TARGET, "DEVCLASS") .EQ. 2 THEN -	! If its a magtape...
	BLOCKSIZE = "/BLOCK_SIZE=7952"
$	!
$	! Determine if this is a small disk.
$	!
$	SMALLDISK := FALSE
$	IF F$GETDVI (TARGET, "DEVCLASS") .NE. 1 THEN GOTO 100	! Disk device?
$	IF F$GETDVI (TARGET, "MAXBLOCK") .GT. 25000 THEN GOTO 100
$	SMALLDISK := TRUE
$
$ 100:
$	DESTINATION := PASS1	! Assume a fresh build.
$	IF RESTART THEN INQUIRE DESTINATION -
"Enter PASS1, PASS1_B, PASS2, PASS2_B, PASS3, PASS3_B, PASS4, or PASS4_B"
$	GOTO 'DESTINATION
$
$ PASS1:
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "		* * * * *   PASS1   * * * * *"
$	WRITE SYS$OUTPUT ""
$	ON ERROR THEN GOTO RUNDOWN
$	!
$	! Do a VMSKITBLD of the required file set.
$	!
$	@'COMMAND'VMSKITBLD.COM -	! Kitbuild command procedure
		'COMMAND'VMSKITBLD.DAT -! Kitbuild data file
		"" -			! Default mask -- standard kit
		'SOURCE' -		! Source disk -- no topsys
		'SCRATCH':VAXVMSRL3 -	! Target disk
		REQ -			! Required fileset
		"" -			! n/a
		BUILD -			! Fresh build operation
		NOPROMPT		! Device already confirmed
$	!
$	! BACKUP the scratch disk to the target media
$	!
$
$ PASS1_B:
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "		* * * * *   PASS1_B   * * * * *"
$	WRITE SYS$OUTPUT ""
$	MOUNT 'SCRATCH' VAXVMSRL3
$	SET DEFAULT 'SCRATCH':['TOPSYS'SYSEXE]
$ 150:
$	!
$	! Set the default system generation parameters for the upgrade.
$	! Make STARTUP.INS be used the first time the new system
$	! is booted, as it will restore the LIB and OPT savesets.
$	!
$	SET DEFAULT 'SCRATCH':['TOPSYS'SYSEXE]
$	DEFINE/USER VMSRTL 'SCRATCH':['TOPSYS'SYSLIB]VMSRTL
$	DEFINE/USER SCRSHR 'SCRATCH':['TOPSYS'SYSLIB]SCRSHR
$	DEFINE/USER LBRSHR 'SCRATCH':['TOPSYS'SYSLIB]LBRSHR
$	DEFINE/USER SYS$SYSTEM 'SCRATCH':['TOPSYS'SYSEXE]
$	RUN SYSGEN
		USE DEFAULT
		SET /STARTUP SYS$SYSTEM:STARTUP.INS	! Installation command proc
		WRITE CURRENT
$	SET DEFAULT 'DEFDISK''DEFDIR'
$	IF F$GETDVI(TARGET,"DEVCLASS") .EQ. 1 THEN BLOCKSIZE := /BLOCKSIZE=2048
$if f$extract (0, 3, f$getdvi (target, "devnam")) .nes. "_DL" then -
	BACKUP 'SOURCE_DEV'[SYSUPD]VMS300.COM;0,VMSKITBLD.V25;0, -
		MOVE.COM;0,DIRCLENUP.COM;0,SHUTDOWN.V25;0,EDITSOS.CLD;0, -
		'SOURCE'[SYSEXE]STARTUP.UP*;0, -
		'SOURCE'[SYSEXE]BOOT58.EXE;0, -
		'SOURCE'[SYSUPD]SETDEFBOO.COM;0, -
		'SOURCE'[SYSUPD]AUTOGEN.COM;0, -
		'SOURCE'[CONSOLE.780]CS1BOO.CMD;0,CS1GEN.;0, -
		'SOURCE'[CONSOLE.750]CSABOO.CMD;0,CSAGEN.;0 -
		'TARGET':[000000]VMS300 /SAVESET -
		/INTERCHANGE -
		'BLOCKSIZE' -
		/NOINIT -
		/LABEL = VMS'VERSION'
$	IF F$GETDVI(TARGET,"DEVCLASS") .EQ. 1 THEN BLOCKSIZE := ""
$	COPY 'SOURCE'[SYSEXE]STARTUP.INS 'SCRATCH':['TOPSYS'SYSEXE]
$	DELETE 'SCRATCH':['TOPSYS'SYSEXE]SYSUAF.DAT;*	! Rely on .RL2 copy
$	BACKUP 'SCRATCH': 'TARGET':[000000]REQUIRED /SAVESET -
		'BLOCKSIZE' -
		/IMAGE -
		/INTERCHANGE -
		/NOINIT -
		/NOREWIND -
		/LABEL = VMS'VERSION'
$	DISMOUNT /NOUNLOAD 'SCRATCH'
$
$ PASS2:
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "		* * * * *   PASS2   * * * * *"
$	WRITE SYS$OUTPUT ""
$	IF F$MODE () .NES. "INTERACTIVE" THEN GOTO 200$
$	IF PAUSE THEN INQUIRE ANSWER "Press RETURN to begin pass 2"
$200$:	ON ERROR THEN GOTO RUNDOWN
$	!
$	! Do a VMSKITBLD of the library file set
$	!
$	@'COMMAND'VMSKITBLD.COM -		! Kitbuild command procedure
		'COMMAND'VMSKITBLD.DAT -	! Kitbuild data file
		"" -				! Default mask -- standard kit
		'SOURCE' -			! Source disk -- no topsys
		'SCRATCH':VAXVMSLB3	-	! Target disk
		LIB -				! Library fileset
		"" -				! n/a
		BUILD -				! Fresh build operation
		NOPROMPT			! Device already confirmed
$PASS2_B:
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "		* * * * *   PASS2_B   * * * * *"
$	WRITE SYS$OUTPUT ""
$	!
$	! BACKUP the scratch disk to the target media
$	!
$	MOUNT 'SCRATCH' VAXVMSLB3
$	!
$	! Remove the compatibility mode synonyms so that the
$	! files are recorded by alphabetic directory name in the saveset.
$	!
$	SET FILE /REMOVE 'SCRATCH':['ROOT']001001.DIR;1
$	SET FILE /REMOVE 'SCRATCH':['ROOT']001002.DIR;1
$	BACKUP 'SCRATCH': 'TARGET':[000000]LIBRARY /SAVESET -
		'BLOCKSIZE' -
		/IMAGE -
		/INTERCHANGE -
		/NOINIT -
		/NOREWIND			! If tape, then append
$	DISMOUNT /NOUNLOAD 'SCRATCH'
$	!
$	! Copy the standalone backup kit to the Required disk.
$	!
$	IF F$GETDVI (TARGET, "DEVCLASS") .NE. 1 THEN GOTO PASS3
$set noon
$	@'COMMAND'STABACKIT 'TARGET [SYSEXE] 'SOURCE_DEV'[SYSEXE]
$set on
$
$ PASS3:
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "		* * * * *   PASS3   * * * * *"
$	WRITE SYS$OUTPUT ""
$	IF F$MODE () .NES. "INTERACTIVE" THEN GOTO PASS3_A
$	IF PAUSE THEN INQUIRE ANSWER "Press RETURN to begin pass 3"
$	IF .NOT. SMALLDISK THEN GOTO PASS3_A
$	DISMOUNT /UNLOAD 'TARGET
$	WRITE SYS$OUTPUT -
"Please place the OPTIONAL disk volume in the target drive, ''TARGET'"
$DO_OVER2:
$	INQUIRE OK "Is ''TARGET': ready to be initialized? (Y/N)"
$	IF .NOT. OK THEN GOTO DO_OVER2
$	!
$	! For dual RL02 kits ONLY:  build the required file set onto the
$	! optional disk, making it a bootable device.  Then write STARTUP.OPT
$	! as the system startup command procedure, ensuring that this captive
$	! command procedure is the only thing the booted system will run.
$	! Also, put VMSOPT.COM on the optional disk as a command saveset
$	! suitable to be invoked by VMSINSTAL.COM.  And, put a smaller pagefile
$	! on the disk.
$	!
$	@'COMMAND'VMSKITBLD.COM -		! Kitbuild command procedure
		'COMMAND'VMSKITBLD.DAT -	! Kit build data file
		"" -				! Default mask -- standard kit
		'SOURCE' -			! Source disk -- no topsys
		'TARGET':VMSOPT -		! Build onto optional kit disk
		REQ -				! Required file set
		"" -				! n/a
		BUILD -				! Initialize the disk
		NOPROMPT			! Device already confirmed
$	MOUNT_TARGET 'TARGET' VMSOPT
$	COPY 'SOURCE'[SYSEXE]STARTUP.INS 'TARGET':['TOPSYS'SYSEXE]
$ !
$ ! If VMSHELP, VMSTLRHLP, and SEARCH aren't already on TARGET then copy them
$ !
$	IF F$SEARCH ("''TARGET':[''TOPSYS'SYSEXE]VMSHELP.EXE") .EQS. "" -
	   THEN COPY 'SOURCE'[SYSEXE]VMSHELP.EXE 'TARGET':['TOPSYS'SYSEXE]
$	IF F$SEARCH ("''TARGET':[''TOPSYS'SYSEXE]SEARCH.EXE") .EQS. "" -
	   THEN COPY 'SOURCE'[SYSEXE]SEARCH.EXE 'TARGET':['TOPSYS'SYSEXE]
$	IF F$SEARCH ("''TARGET':[''TOPSYS'SYSHLP]VMSTLRHLP.HLB") .EQS. "" -
	   THEN COPY 'SOURCE'[SYSHLP]VMSTLRHLP.HLB 'TARGET':['TOPSYS'SYSHLP]
$	IF F$GETDVI(TARGET,"DEVCLASS") .EQ. 1 THEN BLOCKSIZE := /BLOCKSIZE=2048
$	BACKUP	'SOURCE_DEV'[SYSUPD]VMSOPT.COM;0 -
		'TARGET':[000000]VMSOPT.SAV /SAVESET -
		/NOINIT -
		/INTERCHANGE -
		'BLOCKSIZE'
$	IF F$GETDVI(TARGET,"DEVCLASS") .EQ. 1 THEN BLOCKSIZE := ""
$	SET DEFAULT 'TARGET':['TOPSYS'SYSEXE]
$	DELETE 'TARGET':['TOPSYS'SYSEXE]PAGEFILE.SYS;*
$	DEFINE/USER SYS$SYSTEM 'TARGET':['TOPSYS'SYSEXE]
$	RUN SYSGEN
		USE DEFAULT
		SET /STARTUP SYS$SYSTEM:STARTUP.INS	! Installation procedure
		CREATE PAGEFILE.SYS/SIZE=4000		! Create smaller pagefile
		WRITE CURRENT
$	SET DEFAULT 'DEFDISK''DEFDIR'
$	
$	!
$	! Do a VMSKITBLD of the optional file set
$	!
$PASS3_A:
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "		* * * * *   PASS3_A   * * * * *"
$	WRITE SYS$OUTPUT ""
$	ON ERROR THEN GOTO RUNDOWN
$	@'COMMAND'VMSKITBLD.COM -		! Kitbuild command procedure
		'COMMAND'VMSKITBLD.DAT -	! Kitbuild data file
		"" -				! Default mask -- standard kit
		'SOURCE' -			! Source disk -- no topsys
		'SCRATCH':VAXVMSOP3	-	! Target disk
		OPT -				! Optional fileset
		"" -				! n/a
		BUILD -				! Fresh build operation
		NOPROMPT			! Device already confirmed
$PASS3_B:
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "		* * * * *   PASS3_B   * * * * *"
$	WRITE SYS$OUTPUT ""
$	!
$	! BACKUP the scratch disk to the target media
$	!
$	MOUNT 'SCRATCH' VAXVMSOP3
$	!
$	! Remove the compatibility mode synonyms so that the
$	! files are recorded by alphabetic directory name in the saveset.
$	!
$	SET FILE /REMOVE 'SCRATCH':['ROOT']001001.DIR;1
$	SET FILE /REMOVE 'SCRATCH':['ROOT']001002.DIR;1
$	BACKUP 'SCRATCH': 'TARGET':[000000]OPTIONAL /SAVESET -
		'BLOCKSIZE' -
		/INTERCHANGE -
		/IMAGE -
		/NOINIT -
		/NOREWIND			! If tape, then append
$	DISM /NOUNLOAD 'SCRATCH'
$ PASS4:
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "		* * * * *   PASS4   * * * * *"
$	WRITE SYS$OUTPUT ""
$	IF F$MODE () .NES. "INTERACTIVE" THEN GOTO 450$
$	IF PAUSE THEN INQUIRE ANSWER "Press return to begin pass 4"
$	!
$	! Build an EDTCAI distribution kit onto the OPTIONAL disk/tape.
$	!
$ 450$:	ON ERROR THEN CONTINUE
$	@'COMMAND'VMSKITBLD.COM -		! Kitbuild command procedure
		'COMMAND'VMSKITBLD.DAT - 	! Kitbuild data file
		%X400 -				! Mask for EDTCAI
		'SOURCE' -			! Source disk -- no topsys
		'SCRATCH':EDTCAI-		! Target disk
		EDTCAI -			! EDTCAI fileset
		"" -				! n/a
		BUILD -				! Fresh build operation
		NOPROMPT			! Device already confirmed
$PASS4_B:
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "		* * * * *   PASS4_B   * * * * *"
$	WRITE SYS$OUTPUT ""
$	!
$	! BACKUP the scratch disk to the target media
$	!
$	MOUNT 'SCRATCH' EDTCAI
$	IF F$GETDVI(TARGET,"DEVCLASS") .EQ. 1 THEN BLOCKSIZE := /BLOCKSIZE=2048
$	BACKUP 'SOURCE_DEV'[SYSUPD]EDTCAI.COM;0 -
		'TARGET':[000000]EDTCAI.SAV /SAVESET-
		'BLOCKSIZE' -
		/INTERCHANGE -
		/NOINIT -
		/NOREWIND			! If tape, then append
$	IF F$GETDVI(TARGET,"DEVCLASS") .EQ. 1 THEN BLOCKSIZE := ""
$	BACKUP 'SCRATCH':['TOPSYS'SYSEXE]*.*;0,['TOPSYS'SYSCBI]*.*;0 -
		'TARGET':[000000]EDTCAI1.SAV /SAVESET -
		/INTERCHANGE -
		'BLOCKSIZE' -
		/NOINIT -
		/NOREWIND			! If tape, then append
$	DISM /NOUNLOAD 'SCRATCH'
$
$ COMPLETION:
$	SUMMARY = " Completed distribution kit is on device ''TARGET'"
$	GOTO RUNDOWN
$
$ CONTROLY:
$	SUMMARY = "Distribution kit build aborted by CTRL/Y"
$
$ RUNDOWN:
$	!
$	! Do any cleanup necessary before exiting.
$	!
$	ON ERROR THEN GOTO 920$
$	IF SCRATCH .EQS. "" THEN GOTO 920$
$	IF F$GETDEV (SCRATCH, "MNT") THEN DISMOUNT /NOUNLOAD 'SCRATCH
$ 920$:	ON ERROR THEN GOTO 930$
$	IF TARGET .EQS. "" THEN GOTO 930$
$	IF .NOT. F$GETDEV (TARGET, "MNT") THEN GOTO 930$
$	DISMOUNT /NOUNLOAD 'TARGET
$	ERROR_COUNT = F$GETDEV (TARGET, "ERRCNT") - START_ERROR_COUNT
$	IF ERROR_COUNT .NE. 0 THEN WRITE SYS$OUTPUT -
		" There were ''ERROR_COUNT' errors on device ''TARGET'"
$ 930$:	SET UIC 'DEFUIC'
$	SET DEFAULT 'DEFDISK'
$	SET DEFAULT 'DEFDIR'
$	SET PROCESS/PRIV=(NOCMEXEC,NOCMKRNL,NOVOLPRO,NOLOG_IO,NOSYSPRV,NOOPER)
$	WRITE SYS$OUTPUT SUMMARY
