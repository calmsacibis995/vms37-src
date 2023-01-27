$ !
$ ! VMS300 - Apply VAX/VMS upgrade distribution kit for Release 3.
$ ! 
$ ! This procedure requires privileges: CMKRNL, BYPASS, and VOLPRO.
$ !
$ ! This command file allows the invoker to upgrade a running V2.5 system disk
$ ! to a release 3 system disk.  The transfer can occur from magtape, RL02,
$ ! or RK07 to any of the disk types supported in Release 3.
$ !
$ ! There is one parameter to this procedure:  the device on which the
$ ! kit is mounted.
$ !
$ ! The parameters are:
$ !
$ ! P1 = KIT	- The device on which the distribution kit is mounted foreign.
$ !
$ ! 
$ ! 
$ ! This command procedure uses as input a data file (VMSKITBLD.V25)
$ ! which has been copied off the distribution media as part of the command
$ ! saveset.
$ !
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "	VAX/VMS V3.0 Upgrade Procedure"
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "This procedure will convert a VAX/VMS V2.5 system disk"
$	WRITE SYS$OUTPUT "into a VAX/VMS V3.0 system disk.  To accomplish this,"
$	WRITE SYS$OUTPUT "the system must be rebooted several times.  The upgrade"
$	WRITE SYS$OUTPUT "will continue automatically after each reboot via a"
$	WRITE SYS$OUTPUT "specially created system startup command procedure."
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "	       IMPORTANT NOTE"
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "The pagefile, swapfile, dump file, and user"
$	WRITE SYS$OUTPUT "authorization file will all be purged to one"
$	WRITE SYS$OUTPUT "copy.  All accounting and operator logs will"
$	WRITE SYS$OUTPUT "be deleted.  Everything in [SYSERR] will also"
$	WRITE SYS$OUTPUT "be deleted.  If you wish to preserve any of"
$	WRITE SYS$OUTPUT "these files, please exit from the upgrade and"
$	WRITE SYS$OUTPUT "move them to a user directory."
$	WRITE SYS$OUTPUT ""
$5:
$	INQUIRE OK "Do you want to continue? (Y/N)"
$	IF (OK .EQS. "") THEN GOTO 5
$	IF .NOT. OK THEN EXIT
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "	Upgrade Phase 1"
$	WRITE SYS$OUTPUT ""
$	DEFDIR:="SYSUPD.VMS300"
$	FILEOPEN:=""
$	FILE2OPEN:=""
$	FILE3OPEN:=""
$	SET ON
$	SET MESSAGE /FACILITY/SEVERITY/TEXT/IDENTIFICATION
$	ON ERROR THEN GOTO 7000
$	ON CONTROL_Y THEN GOTO 7000
$	ON CONTROL_C THEN GOTO 7000
$	SET PROCESS /PRIV=(CMK,SYSP,LOG,VOLPRO)
$	SET PROTECTION=(S:RWED,G:RWED,O:RWED,W:RE)/DEFAULT
$	COPY :== COPY
$!	DELETE /SYMBOL /GLOBAL COPY
$	MOUNT := MOUNT
$!	DELETE /SYMBOL /LOCAL MOUNT
$	MOUNT :== MOUNT
$!	DELETE /SYMBOL /GLOBAL MOUNT
$	KIT:='P1
$	VALID_SAVESETS := REQ,LIB,OPT,ALL,EDTCAI
$	VALID_UPGRADES:=IGNORE,KEEP,UNDER,OVER
$	IF KIT .NES. "" THEN GOTO 20
$	WRITE SYS$OUTPUT "No device specified for distribution kit."
$	GOTO 7000
$20:
$	IF 'F$LOC(":",KIT) .EQ. 'F$LEN(KIT) THEN KIT := 'KIT':
$	IF ('F$LENGTH(KIT) .NE. 5) THEN GOTO 21
$	CONTROLER := 'F$EXTRACT(2,2,KIT)
$	IF (CONTROLER .LTS. "A0") THEN GOTO 21
$	IF (CONTROLER .GTS. "Z9") THEN GOTO 21
$	GOTO 24
$21:
$	WRITE SYS$OUTPUT "Distribution kit must be specified in the format DDCU:"
$	GOTO 7000
$
$24:
$	SYSDEV := 'F$LOGICAL("SYS$SYSTEM")
$	N = 'F$LOCATE("SYS$SYSROOT:",SYSDEV)
$	L = 'F$LENGTH(SYSDEV)
$	IF (L .EQ. N) THEN GOTO 25
$	SYSDEV := 'F$LOGICAL("SYS$SYSROOT")
$25:
$	L = 'F$LENGTH(SYSDEV)
$	N = 'F$LOCATE("_",SYSDEV)
$	IF (L .EQ. N) THEN GOTO 26
$	N = N + 1
$ 	L = L - 1
$	SYSDEV := 'F$EXTRACT(N,L,SYSDEV)
$26:
$	L = 'F$LOCATE(":",SYSDEV) + 1
$	TARGET := 'F$EXT(0,L,SYSDEV)
$	L = 'F$LOCATE("[",SYSDEV)
$	M = 'F$LOCATE(".",SYSDEV)
$	IF M .EQ. 'F$LENGTH(SYSDEV) THEN GOTO NO_TOPSYS
$	N = M - L
$	L = L + 1
$	OLD_ROOT_DOT := 'F$EXT(L,N,SYSDEV)
$	GOTO AGAIN2
$NO_TOPSYS:
$	OLD_ROOT_DOT := ""
$ !
$ ! Default EDITOR for V3 is EDT instead of SOS as it was
$ ! in VMS V2.  Ask if system manager desires SOS to still
$ ! be the default editor.
$ !
$AGAIN2:
$ WRITE SYS$OUTPUT "With VMS V3.0 the default editor invoked"
$ WRITE SYS$OUTPUT "by the EDIT command is EDT.  Would you like"
$ WRITE SYS$OUTPUT "SOS to be the default editor for the EDIT
$ INQUIRE QUES "command, as it was in VMS V2? (Y/N)"
$ WRITE SYS$OUTPUT ""
$ IF QUES .EQS. "" THEN GOTO AGAIN2
$ IF .NOT. QUES THEN DELETE 'TARGET'['OLD_ROOT_DOT''DEFDIR']EDITSOS.CLD;*
$ !
$ ! Determine type of cpu
$ !
$30:
$	SET DEFAULT 'TARGET'['OLD_ROOT_DOT''DEFDIR']
$	CPUTYPE = 0
$	SYSVER := ""
$	DEFINE/USER SYS$OUTPUT NL:
$	RUN SYS$SYSTEM:SDA
*
SET OUTPUT CPUTYPE.DAT
EXAM EXE$GB_CPUTYPE
E SYS$GQ_VERSION
EXIT
$	OPEN/READ DATAF CPUTYPE.DAT
$	FILEOPEN:="YES"
$35:
$	READ/END_OF_FILE=40 DATAF RECORD
$	N = 'F$LENGTH(RECORD)
$	M = 'F$LOCATE("SYS$GQ_VERSION",RECORD)
$	IF (M .NE. N) THEN GOTO GOT_SYSVER
$	L = 'F$LOCATE("EXE$GB_CPUTYPE:",RECORD)
$	IF (L .EQ.N) THEN GOTO 35
$	L = L + 23
$	CPUTYPE := 'F$EXTRACT(L,2,RECORD)
$	CPUTYPE = 'CPUTYPE
$	IF (CPUTYPE .EQ. 1).OR. (CPUTYPE .EQ. 2) THEN GOTO GOT_CPUTYPE
$	IF (CPUTYPE .EQ. 3) THEN -
	WRITE SYS$OUTPUT "Upgrade procedure not supported for cpu type "'cputype'"."
$	GOTO 7000
$GOT_CPUTYPE:
$	IF (SYSVER .NES. "") THEN GOTO GOT_BOTH
$	GOTO 35
$GOT_SYSVER:
$	N = 'F$LOCATE("""",RECORD) + 1
$	SYSVER := 'F$EXTRACT(N,4,RECORD)
$	IF (CPUTYPE .NE. 0) THEN GOTO GOT_BOTH
$	GOTO 35
$GOT_BOTH:
$	CLOSE DATAF
$	FILEOPEN:=""
$	DELETE CPUTYPE.DAT;*
$	GOTO 45
$40:
$	CLOSE DATAF
$	FILEOPEN:=""
$	DELETE CPUTYPE.DAT;*
$	WRITE SYS$OUTPUT "EOF encountered in trying to determine cpu type."
$	GOTO 7000
$45:
$	SET DEF SYS$SYSTEM:
$	DEFINE/USER SYS$OUTPUT NL:
$	RUN AUTHORIZE
M SYSTEM/ENQLM=10/WSQUOTA=350/WSEXTENT=1024
M SYSTEST/WSQUOTA=350/WSEXTENT=1024
EXIT
$	WRITE SYS$OUTPUT "Turning off disk quotas on system disk."
$	ON ERROR THEN GOTO 50
$	RUN SYS$SYSTEM:DISKQUOTA
USE SYS$SYSTEM
DISABLE
$50:
$	ON ERROR THEN GOTO 7000
$	SET DEFAULT 'TARGET'['OLD_ROOT_DOT''DEFDIR']
$	FILENAME:='TARGET'['OLD_ROOT_DOT''DEFDIR']VMSKITBLD.V25
$60:
$	OPEN/READ DATAF 'FILENAME
$	IF $STATUS THEN GOTO 65
$	WRITE SYS$OUTPUT "Unable to open data parameter file."
$	GOTO 7000
$65:
$	FILEOPEN:="YES"
$	CONDIT = 1+2+4+8+64+256	! Use UETP, HELP, DECnet, and Coding Examples
$	ON ERROR THEN GOTO 7000
$	WRITE SYS$OUTPUT ""
$	SET PROC/PRIV=(CMKRNL,VOLPRO,BYPASS)
$	@['OLD_ROOT_DOT''DEFDIR']DIRCLENUP.COM 'TARGET' 'SYSVER'
$	SET PROC/PRIV=(CMKRNL,VOLPRO,BYPASS)
$	STOP JOB_CONTROL
$	STOP OPCOM
$	SET UIC [1,6]
$	STOP ERRFMT
$	SET UIC [1,4]
$	SET DEFAULT 'TARGET'['OLD_ROOT_DOT''DEFDIR']
$ !
$ ! Delete known files and associated global sections.
$ !
$ create zzz000zzz.tmp
$ deck
$ run sys$system:install 
/LIST
$ exit
$ eod
$ @zzz000zzz.tmp/output=zzz000zzz
$ !
$ ! Open the necessary files
$ !
$ open/error=open_err_0 file zzz000zzz.lis
$ open/write/error=open_err_1 file1 zzz001zzz.tmp
$ write/error=wrt_err file1 "$ run sys$system:install
$ on error then goto cleanup
$ !
$ ! Begin reading the output file
$ !
$	8010:
$ 	output := ""
$ 	read/end_of_file=the_eof file record
$ 	position = 'f$locate(";", record)'
$ 	length = 'f$length(record)'
$ 	if position .eq. length then goto 8010
$ 	!
$ 	! Set up for the writing of the new command file
$ 	!
$ 		output[0, position]:= 'f$extract(0, position, record)'
$ 		output[position, 7]:= /delete
$		tmp = 'f$locate("VMSRTL.EXE", output)'
$		len = 'f$length(output)
$		if tmp .ne. len then goto 8010
$		tmp = 'f$locate("RSXSHR.EXE", output)'
$		len = 'f$length(output)
$		if tmp .ne. len then goto 8010
$		tmp = 'f$locate("DISMNTSHR.EXE", output)'
$		len = 'f$length(output)
$		if tmp .ne. len then goto 8010
$		tmp = 'f$locate("MOUNTSHR.EXE", output)'
$		len = 'f$length(output)
$		if tmp .ne. len then goto 8010
$ 		write/error=wrt_err file1 output
$ 		goto 8010
$ !
$ ! Get here only if entire file has been processed
$ !
$the_eof:
$ write file1 "$ exit
$ close file
$ close file1
$ @ZZZ001ZZZ.TMP
$ goto cleanup1
$open_err_0:
$ write sys$output "Error opening output file for reading
$ goto cleanup
$open_err_1:
$ write sys$output "Error opening temporary command file for writing
$ goto cleanup
$wrt_err:
$ write sys$output "Error writing temporary command file
$cleanup:
$ close file
$ close file1
$ goto 7000
$cleanup1:
$ delete zzz000zzz.lis.*
$ delete zzz000zzz.tmp.*
$ delete zzz001zzz.tmp.*
$ on error then goto 7000
$ GOTO 3005
$ !
$ ! Restart the console media write here.
$ !
$RESTART_CONSOLE:
$	ON ERROR THEN CONTINUE
$	DISMOUNT 'FLX_DEVICE'
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "Error.  Restarting the part of the upgrade procedure"
$	WRITE SYS$OUTPUT "that copies the old console ''MEDIUM'."
$	WRITE SYS$OUTPUT ""
$3005:
$	BOOT_CS := "YES"
$	ON ERROR THEN GOTO RESTART_CONSOLE
$	SET PROC/PRIV=(CMEXEC,CMKRNL,LOG_IO,SYSNAM,VOLPRO)
$	CREATE/DIR/PROT=(S:RWE,O:RWE,G:RE,W:RE) -
		'TARGET'['OLD_ROOT_DOT'SYSUPD.VMS300.CONSOLE]
$	SET DEFAULT 'TARGET'['OLD_ROOT_DOT'SYSUPD.VMS300.CONSOLE]
$	FLX_DEVICE := "CS1:"
$	DELETE 'TARGET'['OLD_ROOT_DOT'SYSUPD.VMS300.CONSOLE]*.*;*
$	IF (CPUTYPE .EQ. 1) THEN GOTO SET_780_PARMS
$	IF (CPUTYPE .EQ. 2) THEN GOTO SET_750_PARMS
$	IF (CPUTYPE .EQ. 3) THEN GOTO SET_730_PARMS
$	WRITE SYS$OUTPUT "Unrecognized cpu type "'cputype'"."
$	GOTO 7000
$SET_780_PARMS:
$	MEDIUM := "floppy"
$	FILES11_FLX_SWITCH := /RS/IM
$	RT_FLX_SWITCH := /RT
$	BOOTFILE := CONSOL.SYS
$	GOTO END_SET_PARMS
$
$SET_750_PARMS:
$	MEDIUM := "TU58"
$	FILES11_FLX_SWITCH := /RS/IM
$	RT_FLX_SWITCH := /RT
$	BOOTFILE := BOOT58.EXE
$AGAIN5:
$	INQUIRE BOOT_CS "Do you want to boot from the TU58? (Y/N)"
$	IF BOOT_CS .EQS. "" THEN GOTO AGAIN5
$	IF .NOT. BOOT_CS THEN GOTO 230
$	GOTO END_SET_PARMS
$
$SET_730_PARMS:
$	MEDIUM := "TU58"
$	FLX_DEVICE := "CS2:"
$	FILES11_FLX_SWITCH := /RS/IM
$	RT_FLX_SWITCH := /RT/IM
$	BOOTFILE := BOOT.EXE
$
$END_SET_PARMS:
$	WRITE SYS$OUTPUT ""
$ 	WRITE SYS$OUTPUT "Now a new site-specific ''MEDIUM' must be created"
$	WRITE SYS$OUTPUT "to allow reboot of a kernel VAX/VMS V3.0 system."
$AGAIN4:
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "Put your old console ''MEDIUM' into drive ''FLX_DEVICE'."
$	WRITE SYS$OUTPUT "DEFBOO.CMD must be set to boot from your current"
$	WRITE SYS$OUTPUT "system disk.  You must set this up if it has not"
$	INQUIRE TEMP "been done previously.  Do you want to do this now? (Y/N)"
$	IF TEMP .EQS. "" THEN GOTO AGAIN4
$	IF .NOT. TEMP THEN GOTO DEFBOO_SET
$	WRITE SYS$OUTPUT ""
$	@['OLD_ROOT_DOT''DEFDIR']SETDEFBOO.COM 'CPUTYPE'
$DEFBOO_SET:
$	RUN SYS$SYSTEM:SYSGEN
CONNECT CONSOLE
$	IF (CPUTYPE .EQ. 3) THEN GOTO MOUNT_CONSOLE
$	ON ERROR THEN CONTINUE
$	DISMOUNT 'FLX_DEVICE'
$
$	ON ERROR THEN GOTO RESTART_CONSOLE
$MOUNT_CONSOLE:
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "Your old console ''MEDIUM' should be in drive ''FLX_DEVICE'."
$AGAIN1:
$	INQUIRE READY -
	"Is the old console ''MEDIUM, ''FLX_DEVICE', ready to be mounted? (Y/N)"
$	IF .NOT. READY THEN GOTO AGAIN1
$	MOUNT/FOREIGN 'FLX_DEVICE'
$	DEVICE_MOUNTED := TRUE
$
$	WRITE SYS$OUTPUT "The old console ''MEDIUM' will be copied to a"
$	WRITE SYS$OUTPUT "scratch directory now.  Afterwards you will"
$	WRITE SYS$OUTPUT "be asked to insert a scratch ''MEDIUM'.  This"
$	WRITE SYS$OUTPUT "copy takes about 5 minutes."
$	MCR FLX 'FILES11_FLX_SWITCH'='FLX_DEVICE'*.*'RT_FLX_SWITCH'
$	SET DEFAULT 'TARGET'['OLD_ROOT_DOT'SYSUPD.VMS300]
$	MCR FLX /RS='FLX_DEVICE'DEFBOO.CMD/RT
$	IF (CPUTYPE .NE. 1) THEN GOTO ENOUGH_ROOM
$	OPEN/READ/ERROR=ENOUGH_ROOM DATA4 PCS.PAT
$	CLOSE DATA4
$	DELETE PCS.PAT;*
$ENOUGH_ROOM:
$	RENAME DEFBOO.CMD DEFBOO.SIT
$	SET DEFAULT 'TARGET'['OLD_ROOT_DOT'SYSUPD.VMS300.CONSOLE]
$	DISMOUNT 'FLX_DEVICE'
$	GOTO 3006
$RESTART_CONSOLE_2:
$	ON ERROR THEN CONTINUE
$	DISMOUNT 'FLX_DEVICE'
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "Error initializing the console ''MEDIUM'."
$	WRITE SYS$OUTPUT "If the console ''MEDIUM' had bad blocks,"
$	WRITE SYS$OUTPUT "please replace it with a different ''MEDIUM'."
$	WRITE SYS$OUTPUT "Restarting the part of the upgrade procedure"
$	WRITE SYS$OUTPUT "that initializes the scratch console ''MEDIUM'."
$3006:
$	ON ERROR THEN GOTO RESTART_CONSOLE_2
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "Put a scratch console ''MEDIUM' into drive ''FLX_DEVICE'."
$	WRITE SYS$OUTPUT "This will be initialized now to verify that the"
$	WRITE SYS$OUTPUT "media is usable and written just before the system"
$	WRITE SYS$OUTPUT "is rebooted, in order to boot from the V3.0 kernel."
$	WRITE SYS$OUTPUT "DO NOT put your normal console media back in the "
$	WRITE SYS$OUTPUT "console drive during the remainder of the upgrade procedure."
$AGAIN3:
$	INQUIRE READY -
"Is a scratch console ''MEDIUM, now in ''FLX_DEVICE'? (Y/N)"
$	IF .NOT. READY THEN GOTO AGAIN3
$	ON ERROR THEN GOTO RESTART_CONSOLE_2
$	MOUNT/FOREIGN 'FLX_DEVICE'
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "Running BAD on new console ''MEDIUM'."
$	MCR BAD 'FLX_DEVICE'
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "Initializing the scratch console ''MEDIUM."
$	MCR FLX 'FLX_DEVICE'/RT/ZE		! Initialize the console medium.
$
$230:
$	ON ERROR THEN GOTO 7000
$
$ !
$ ! Now clean off all the VAX/VMS V2 files, so that the maximum free space
$ ! is available on the system disk.  All files required to reboot and execute
$ ! this procedure will not be deleted, so that the upgrade can recover from
$ ! any error and the procedure restarted.
$ !
$ ! This is the main cleanup loop that is executed for each record
$ ! in the data file.
$ !
$	WRITE SYS$OUTPUT ""
$	IF (CPUTYPE .EQ. 1) THEN -
	WRITE SYS$OUTPUT "The upgrade procedure will continue automatically"
$	IF (CPUTYPE .EQ. 1) THEN -
	WRITE SYS$OUTPUT "for the next two hours.  It reboots automatically"
$	IF (CPUTYPE .EQ. 1) THEN -
	WRITE SYS$OUTPUT "with no operator intervention needed from here on."
$	IF (CPUTYPE .EQ. 2) THEN -
	WRITE SYS$OUTPUT "The upgrade procedure will continue for the next"
$	IF (CPUTYPE .EQ. 2) THEN -
	WRITE SYS$OUTPUT "20 minutes.  After that it will reboot.  If you"
$	IF (CPUTYPE .EQ. 2) THEN -
	WRITE SYS$OUTPUT "are rebooting from the TU58, enter B to the BOOT58>"
$	IF (CPUTYPE .EQ. 2) THEN -
	WRITE SYS$OUTPUT "prompt.  If you are rebooting from the disk, enter"
$	IF (CPUTYPE .EQ. 2) THEN -
	WRITE SYS$OUTPUT "CNTRL/P when the shutdown is complete and then enter"
$	IF (CPUTYPE .EQ. 2) THEN -
	WRITE SYS$OUTPUT "B/F0000000 ddcu to reboot.  The upgrade procedure"
$	IF (CPUTYPE .EQ. 2) THEN -
	WRITE SYS$OUTPUT "will continue automatically after the reboot."
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "Now removing all VAX/VMS V2.5 files not needed to"
$	WRITE SYS$OUTPUT "complete the upgrade."
$	WRITE SYS$OUTPUT ""
$	NEW_ROOT := SYSF
$	CREATE/DIRECTORY/OWNER=[1,4]/PROT=(S:RWE,O:RWE,G:RE,W:RE) -
		 'TARGET'['NEW_ROOT']
$RECORD_LOOP:
$	READ/END_OF_FILE=3000 DATAF RECORD
$	IF "''F$EXTRACT(0,1,RECORD)'" .EQS. "$" THEN GOTO RECORD_LOOP
$	IF "''F$EXTRACT(0,1,RECORD)'" .EQS. "!" THEN GOTO RECORD_LOOP
$ !
$ ! Get the upgrade field from the current record.
$ !
$GET_UPGRADE:
$	L = 'F$LOCATE("UPG=",RECORD) + 4
$	UPGRADE := 'F$EXTRACT(L,132,RECORD)
$	L = 'F$LOCATE(",",UPGRADE)
$	UPGRADE := 'F$EXTRACT(0,L,UPGRADE)
$	IF UPGRADE .EQS. "" THEN GOTO GET_SAVESET
$	IF 'F$LOCATE(UPGRADE,VALID_UPGRADES) .NE. 'F$LENGTH(VALID_UPGRADES) -
	THEN GOTO 240
$	WRITE SYS$OUTPUT "Bad upgrade field specified in record *''RECORD'*"
$	GOTO 7000
$240:
$	IF (UPGRADE .EQS. "IGNORE") .OR. (UPGRADE .EQS. "KEEP") -
	.OR. (UPGRADE .EQS. "OVER") .OR. (UPGRADE .EQS. "UNDER") -
	 THEN GOTO RECORD_LOOP
$ !
$ ! Get the saveset field from the current record.
$ !
$GET_SAVESET:
$	L = 'F$LOCATE("SET=",RECORD) + 4
$	SAVESET := 'F$EXTRACT(L,132,RECORD)
$	L = 'F$LOCATE(",",SAVESET)
$	SAVESET := 'F$EXTRACT(0,L,SAVESET)
$	IF SAVESET .EQS. "" THEN SAVESET := LIB
$	IF 'F$LOCATE(SAVESET,VALID_SAVESETS) .NE. 'F$LENGTH(VALID_SAVESETS) -
	THEN GOTO 250
$	WRITE SYS$OUTPUT "Bad saveset field specified in record *''RECORD'*"
$	GOTO 7000
$250:
$ !
$ ! Get the CONDITIONAL field from the current record.
$ !
$GET_CONDITIONAL:
$	CONDITIONAL := ""
$	L = 'F$LOCATE("COND=",RECORD) + 5
$	IF L .GE. 'F$LENGTH(RECORD) THEN GOTO GET_NAME
$	CONDITIONAL := 'F$EXTRACT(L,132,RECORD)
$	IF CONDITIONAL .EQS. "" THEN GOTO GET_NAME
$	L = 'F$LOCATE(",",CONDITIONAL)
$	CONDITIONAL := 'F$EXTRACT(0,L,CONDITIONAL)
$	IF (CONDITIONAL .AND. CONDIT) .EQ. 0 THEN GOTO RECORD_LOOP
$ !
$ ! Get the name from the current record.  (The name is always the first field
$ ! in the record, and doesn't have a keyword associated with it.)
$ !
$GET_NAME:
$	L = 'F$LOCATE(",",RECORD)
$	NAME := 'F$EXTRACT(0,L,RECORD)
$ !
$ ! Get the operation specified by the current record.
$ !
$GET_OPERATION:
$	L = 'F$LOCATE("OP=",RECORD) + 3
$	OPERATION := 'F$EXTRACT(L,132,RECORD)
$	IF OPERATION .EQS. "" THEN GOTO NORMAL
$	L = 'F$LOCATE(",",OPERATION)
$	OPERATION := 'F$EXTRACT(0,L,OPERATION)
$	IF (OPERATION .EQS. "BUILD") .OR. (OPERATION .EQS. "COPY") .OR. -
	(OPERATION .EQS. "CONTIG") -
	THEN GOTO NORMAL
$	IF (OPERATION .EQS. "CREATE") THEN GOTO CREATE
$	IF (OPERATION .EQS. "SET") THEN GOTO SET
$	IF (OPERATION .EQS. "CREATE") THEN GOTO CREATE_DIR
$	GOTO RECORD_LOOP
$
$NORMAL:
$	OPEN/READ/ERROR=FNF DATA4 'NAME'
$	CLOSE DATA4
$	DELETE 'TARGET''NAME';*
$	IF 'F$LOCATE(".EXE",NAME) .EQ. 'F$LENGTH(NAME) THEN GOTO FNF
$	L = 'F$LOCATE(".EXE",NAME)
$	JOURNAL := 'F$EXTRACT(0,L,NAME)
$	OPEN/READ/ERROR=FNF DATA4 'JOURNAL'
$	CLOSE DATA4
$	DELETE 'TARGET''JOURNAL'.JNL;*
$FNF:
$	ON ERROR THEN GOTO 7000
$	GOTO RECORD_LOOP
$	
$SET:
$	SET DEFAULT ['OLD_ROOT_DOT''NAME']
$	SETDIR := 'NAME'
$	WRITE SYS$OUTPUT "Now working on files in ["'OLD_ROOT_DOT''NAME'"]."
$	GOTO RECORD_LOOP
$
$CREATE:
$	CREATE/DIRECTORY/OWNER=[1,4]/PROT=(S:RWE,O:RWE,G:RE,W:RE) -
		'TARGET'['NEW_ROOT'.'NAME']
$	L = 'F$LOCATE("SYNONYM=",RECORD) + 8
$	SYNONYM := 'F$EXTRACT(L,132,RECORD)
$	L = 'F$LOCATE(",",SYNONYM)
$	SYNONYM := 'F$EXTRACT(0,L,SYNONYM)
$	IF SYNONYM .EQS. "" THEN GOTO RECORD_LOOP
$	MCR PIP -
	'TARGET'['NEW_ROOT']'SYNONYM'.DIR;1/EN='TARGET'['NEW_ROOT']'NAME'.DIR;1
$	GOTO RECORD_LOOP
$
$3000:
$	SET DEFAULT 'TARGET'['OLD_ROOT_DOT''DEFDIR']
$	CLOSE DATAF
$	WRITE SYS$OUTPUT ""
$ 	WRITE SYS$OUTPUT "Now copying over the V3.0 required saveset"
$	WRITE SYS$OUTPUT ""
$	BACKUP/VERIFY/REPLACE -
		'KIT'[0,0]REQUIRED/SAVE_SET -
		'TARGET'['NEW_ROOT'...] -
		/SELECT=[SYS0...] -
		/EXCLUDE=([SYS0.SYSEXE]PAGEFILE.SYS,SYSDUMP.DMP, -
			SWAPFILE.SYS,NOTICE.TXT,SYSTARTUP.COM,-
			SYSHUTDWN.COM,SYSUAF.DAT,STARTUP.INS,[SYSEXE]*.*;*)
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "Purging pagefile, swapfile, dump file, and"
$	WRITE SYS$OUTPUT "authorization file back to one version."
$	WRITE SYS$OUTPUT "(Please ignore possible file not found messages.)"
$	WRITE SYS$OUTPUT ""
$	PURGE 'TARGET'['OLD_ROOT_DOT'SYSEXE]PAGEFILE.SYS,SYSDUMP.DMP, -
		SWAPFILE.SYS,SYSUAF.DAT
$	MCR PIP 'TARGET'['NEW_ROOT'.SYSEXE]PAGEFILE.SYS;*/RM
$	MCR PIP 'TARGET'['NEW_ROOT'.SYSEXE]SYSDUMP.DMP;*/RM
$	MCR PIP 'TARGET'['NEW_ROOT'.SYSEXE]SWAPFILE.SYS;*/RM
$	MCR PIP 'TARGET'['NEW_ROOT'.SYSEXE]SYSUAF.DAT;*/RM
$	MCR PIP -
	'TARGET'['NEW_ROOT'.SYSEXE]PAGEFILE.SYS/EN=-
	'TARGET'['OLD_ROOT_DOT'SYSEXE]PAGEFILE.SYS
$	MCR PIP -
	'TARGET'['NEW_ROOT'.SYSEXE]SYSDUMP.DMP/EN=-
	'TARGET'['OLD_ROOT_DOT'SYSEXE]SYSDUMP.DMP
$	MCR PIP -
	'TARGET'['NEW_ROOT'.SYSEXE]SWAPFILE.SYS/EN=-
	'TARGET'['OLD_ROOT_DOT'SYSEXE]SWAPFILE.SYS
$	MCR PIP -
	'TARGET'['NEW_ROOT'.SYSEXE]SYSUAF.DAT/EN=-
	'TARGET'['OLD_ROOT_DOT'SYSEXE]SYSUAF.DAT
$ !
$ ! Create a data file that will be used to find the distribution
$ ! kit after reboot.
$ !
$	SET DEFAULT 'TARGET'['NEW_ROOT'.SYSEXE]
$	OPEN/WRITE DATAF UPGRADE.KIT;0
$	FILEOPEN:="YES"
$	WRITE DATAF KIT
$	TEMP := 'F$TIME()
$	WRITE DATAF TEMP
$	CLOSE DATAF
$	FILEOPEN:=""
$ !
$ ! Create data files that will be used to create a new site-specific
$ ! sysgen parameter file.
$ !
$	@['OLD_ROOT_DOT''DEFDIR']AUTOGEN SAVE
$ !
$ ! Set up the default startup command file for the next phase
$ ! of the upgrade procedure, after reboot.
$ !
$	DELETE 'TARGET'['OLD_ROOT_DOT'SYSEXE]STARTUP.INS;*,.UP*;*
$	COPY 'TARGET'['OLD_ROOT_DOT''DEFDIR']STARTUP.UP* -
		'TARGET'['NEW_ROOT'.SYSEXE]*
$	COPY 'TARGET'['NEW_ROOT'.SYSEXE]STARTUP.UP2 -
		'TARGET'['NEW_ROOT'.SYSEXE]STARTUP.INS
$ !
$ ! Now edit the default boot command file, to come up under [SYSF].
$ !
$	IF .NOT. BOOT_CS THEN GOTO DISK_BOOT_BLOCK
$	SET DEFAULT ['OLD_ROOT_DOT''DEFDIR'.CONSOLE]
$	GOTO 490
$RESTART_CONS_WRT:
$	ON ERROR THEN CONTINUE
$	DISMOUNT 'FLX_DEVICE'
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "Error initializing the console ''MEDIUM'."
$	WRITE SYS$OUTPUT "If the console ''MEDIUM' was unwritable,"
$	WRITE SYS$OUTPUT "please replace it with a different ''MEDIUM'."
$	WRITE SYS$OUTPUT "Restarting the part of the upgrade procedure"
$	WRITE SYS$OUTPUT "that writes a new console ''MEDIUM'."
$AGAIN7:
$	INQUIRE READY -
"Is a scratch console ''MEDIUM, now in ''FLX_DEVICE'? (Y/N)"
$	IF .NOT. READY THEN GOTO AGAIN7
$	MOUNT/FOREIGN 'FLX_DEVICE'
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "Running BAD on new console ''MEDIUM'."
$	MCR BAD 'FLX_DEVICE'
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "Initializing the scratch console ''MEDIUM."
$	MCR FLX 'FLX_DEVICE'/RT/ZE		! Initialize the console medium.
$490:
$	ON ERROR THEN GOTO RESTART_CONS_WRT
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "Copying unmodified files to new console ''MEDIUM'."
$	COPY 'TARGET'['NEW_ROOT'.SYSEXE]VMB.EXE *
$	IF (CPUTYPE .EQ. 2) THEN -
		COPY 'TARGET'['OLD_ROOT_DOT''DEFDIR']BOOT58.EXE *
$	IF (CPUTYPE .EQ. 2) THEN -
		COPY 'TARGET'['OLD_ROOT_DOT''DEFDIR']CSABOO.CMD *
$	IF (CPUTYPE .EQ. 2) THEN -
		COPY 'TARGET'['OLD_ROOT_DOT''DEFDIR']CSAGEN. CS1GEN.
$	IF (CPUTYPE .EQ. 1) THEN -
		COPY 'TARGET'['OLD_ROOT_DOT''DEFDIR']CS1BOO.CMD,CS1GEN. *
$	PURGE *.*
$	MCR FLX 'FLX_DEVICE''RT_FLX_SWITCH'=*.*'FILES11_FLX_SWITCH'	! Copy.
$	IF (CPUTYPE .EQ. 2) THEN -
		MCR FLX 'FLX_DEVICE'CSABOO.CMD/RT/DE
$	IF (CPUTYPE .EQ. 2) THEN -
		MCR FLX 'FLX_DEVICE'/RT=CSABOO.CMD/RS
$	IF (CPUTYPE .EQ. 2) THEN -
		MCR FLX 'FLX_DEVICE'CS1GEN./RT/DE
$	IF (CPUTYPE .EQ. 2) THEN -
		MCR FLX 'FLX_DEVICE'/RT=CS1GEN./RS
$	IF (CPUTYPE .EQ. 1) THEN -
		MCR FLX 'FLX_DEVICE'CS1BOO.CMD/RT/DE
$	IF (CPUTYPE .EQ. 1) THEN -
		MCR FLX 'FLX_DEVICE'/RT=CS1BOO.CMD/RS
$	IF (CPUTYPE .EQ. 1) THEN -
		MCR FLX 'FLX_DEVICE'CS1GEN./RT/DE
$	IF (CPUTYPE .EQ. 1) THEN -
		MCR FLX 'FLX_DEVICE'/RT=CS1GEN./RS
$	WRITE SYS$OUTPUT "Modifying DEFBOO.CMD to boot V3 from [SYSF.SYSEXE]."
$	OPEN/WRITE DATA2 DEFBOO.CMD
$	OPEN/WRITE DATA3 UPGGEN.CMD
$	OPEN/READ DATAF 'TARGET'['OLD_ROOT_DOT''DEFDIR']DEFBOO.SIT
$	R5_CHANGED:="NO"
$	FILEOPEN:="YES"
$	FILE2OPEN:="YES"
$	FILE3OPEN:="YES"
$500:
$	READ/END_OF_FILE=550 DATAF RECORD
$	L = 'F$LOCATE("D/G 5",RECORD)
$	IF (CPUTYPE .EQ. 1) THEN L = 'F$LOCATE("R5",RECORD)
$	IF (L .EQ. 'F$LENGTH(RECORD)) THEN GOTO 530
$	IF .NOT. R5_CHANGED THEN GOTO 510
$	WRITE SYS$OUTPUT "Edit of DEFBOO.CMD found two R5 lines."
$	GOTO 7000
$510:
$	IF (CPUTYPE .NE. 1) THEN -
		RECORD := "D/G 5 F0000000        ! Boot from SYSF"
$	IF (CPUTYPE .NE. 1) THEN GOTO 520
$	L = 'F$LOCATE("8",RECORD)
$	K = 'F$LENGTH(RECORD)
$	IF (L .EQ. K) THEN RECORD := "DEPOSIT R5 F0000000    ! Boot from SYSF"
$	IF (L .NE. K) THEN RECORD := "DEPOSIT R5 F0000800    ! Boot MP from SYSF"
$520:
$	R5_CHANGED := "YES"
$530:
$	WRITE DATA2 RECORD
$	IF 'F$LOCATE("DEPOSIT R5 F0000",RECORD) .NE. 'F$LENGTH(RECORD) -
	THEN RECORD:='F$EXTRACT(0,18,RECORD)"1	!Interactive boot from SYSF"
$	WRITE DATA3 RECORD
$	GOTO 500
$550:
$	IF R5_CHANGED THEN GOTO EDIT_DONE
$	WRITE SYS$OUTPUT "Edit of DEFBOO.CMD failed to find R5."
$	GOTO 7000
$EDIT_DONE:
$	CLOSE DATAF
$	CLOSE DATA2
$	CLOSE DATA3
$	FILEOPEN:=""
$	FILE2OPEN:=""
$	FILE3OPEN:=""
$	PURGE DEFBOO.CMD
$	MCR FLX 'FLX_DEVICE'/RT=DEFBOO.CMD/RS
$	MCR FLX 'FLX_DEVICE'/RT=UPGGEN.CMD/RS
$
$WRITEBOOT:
$	IF (CPUTYPE .EQ. 2) THEN GOTO WRITEBOOT_750
$	!
$	! Use RTB utility to write a bootblock on 780 and 730 media.
$	!
$	ON ERROR THEN CONTINUE
$	IF (SYSVER .NES. "V2.5") THEN GOTO RTB_V3
$	ASSIGN/USER SYS$DISK: TR0:
$	MCR RTB 'FLX_DEVICE'='BOOTFILE'
$	GOTO 3099
$RTB_V3:
$	DEFINE/USER RTB$INPUT 'BOOTFILE'
$	DEFINE/USER RTB$OUTPUT 'FLX_DEVICE'
$	RUN SYS$SYSTEM:RTB
$	GOTO 3099
$
$WRITEBOOT_750:
$	ASSIGN/USER 'FLX_DEVICE''BOOTFILE' BOOT 
$	RUN SYS$SYSTEM:WRITEBOOT
BOOT
1
C000
$ !
$ ! Clean up from writing console media.
$ !
$3099:
$	DELETE 'TARGET'['OLD_ROOT_DOT''DEFDIR'.CONSOLE]*.*;*
$	DISMOUNT 'FLX_DEVICE'
$ !
$ ! Write boot block onto disk so that it can be booted on an 11/750,
$ ! even if it is being upgraded on another type of cpu.
$ !
$DISK_BOOT_BLOCK:
$	ASSIGN/USER 'TARGET'['NEW_ROOT'.SYSEXE]VMB.EXE BOOT 
$	RUN SYS$SYSTEM:WRITEBOOT
BOOT
1
200
$	ON ERROR THEN GOTO 7000
$	DELETE 'TARGET'['OLD_ROOT_DOT''DEFDIR']CONSOLE.DIR;1
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "System shutting down to boot a kernel V3.0 system."
$	WRITE SYS$OUTPUT ""
$	IF BOOT_CS THEN -
	WRITE SYS$OUTPUT "Leave the newly created site-specific console"
$	IF BOOT_CS THEN -
	WRITE SYS$OUTPUT "''MEDIUM' in the console drive for the remainder"
$	IF BOOT_CS THEN -
$	WRITE SYS$OUTPUT "of the upgrade procedure."
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "The upgrade procedure will continue automatically"
$	WRITE SYS$OUTPUT "after the reboot.  If for any reason you should"
$ 	WRITE SYS$OUTPUT "have to restart the upgrade procedure by"
$	WRITE SYS$OUTPUT "rebooting by hand, from now on type only:"
$	WRITE SYS$OUTPUT ""
$	IF (CPUTYPE .EQ. 1) THEN -
	WRITE SYS$OUTPUT "		B"
$	IF (CPUTYPE .EQ. 2) THEN -
	WRITE SYS$OUTPUT "		B/F0000000 ddcu"
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "The distribution kit must remain on ''KIT' and"
$	WRITE SYS$OUTPUT "system disk must remain on ''TARGET' in order"
$	WRITE SYS$OUTPUT "to procede to the next phase of the upgrade."
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "The sysgen parameters are set to boot any system."
$	WRITE SYS$OUTPUT "Do not change them during the reboot or the upgrade"
$	WRITE SYS$OUTPUT "may fail to execute properly!"
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "On occasion, this shutdown fails to complete."
$	WRITE SYS$OUTPUT "If the system fails to shut down within 5 minutes,"
$	WRITE SYS$OUTPUT "enter CNTRL/P, H, and reboot as described above"
$	WRITE SYS$OUTPUT "to continue the upgrade procedure."
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT ""
$	!
$	! Now shut down the system.
$	!
$	IF .NOT. BOOT_CS THEN GOTO 6000
$	IF (SYSVER .NES. "V2.5") THEN GOTO REBOOT_FT2
$	SET DEFAULT SYS$SYSTEM:
$	PATCH SYS$SYSTEM:OPCCRASH/OUTPUT=SYS$SYSTEM:OPCCRASH
REPL /I 2E9
'BICL2	#2000,@#800024A4'
EXI
'BISL2	#2000,@#800024A4'
EXI
U
$REBOOT_FT2:
$	DEFINE OPC$REBOOT Y
$6000:
$	SET DEFAULT 'TARGET'['OLD_ROOT_DOT''DEFDIR']
$	@'TARGET'['OLD_ROOT_DOT''DEFDIR']SHUTDOWN.V25 -
		"0" "Reboot during upgrade procedure" "N"
$
$	!
$	! On error, exit from the upgrade procedure here.
$	!
$7000:
$	ON ERROR THEN CONTINUE
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "Upgrade to VAX/VMS Version 3.0 incomplete."
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "Error exit from upgrade procedure."
$	WRITE SYS$OUTPUT "Restart upgrade from last boot of system."
$	WRITE SYS$OUTPUT ""
$	SET UIC 'DEFUIC'
$	SET DEFAULT 'DEFDISK'
$	SET DEFAULT 'DEFDIR'
$	IF (FILEOPEN .NES. "") THEN CLOSE DATAF
$	IF (FILE2OPEN .NES. "") THEN CLOSE DATA2
$	IF (FILE3OPEN .NES. "") THEN CLOSE DATA3
$	EXIT
