$ !++
$ ! CONSOLBLD.COM	- Build a VMS console medium.
$ !
$ ! AUTHOR:	Steve Jeffreys		20-FEB-1980
$ !
$ ! ABSTRACT:	This command procedure will build a VAX family console
$ !		medium on the target device.  This command procedure is
$ !		driven from a data file which specifies which files are
$ !		to be copied to the console medium.
$ !
$ !
$ ! INPUTS:	P1	- Kit type.  Legal types are: 780, 750, 730.
$ !		P2	- Target device. (assumed on line w/ no medium mounted)
$ !		P3	- Source device and directory where console boot
$ !			  command files, microcode files, and diagnostic files
$ !			  (if any) can be found. (DDCU:[DIRECTORY])
$ !			  ** NOTE ** do not use a logical name for P3 ***
$ !		P4	- Source device and directory where VMB.EXE can be
$ !			  found.  (DDCU:[DIRECTORY])  Optional.  Defaults to
$ !			  SYS$SYSROOT:[SYSEXE].
$ !			  ** NOTE ** Do not use a logical name for P4 ***
$ !		P5	- Data file spec.  Optional.  Defaults to
$ !			  SYS$UPDATE:'P1'CNSL.DAT
$ !
$ !		SETPRV privilege required.
$ !
$ !
$ ! DATA FILE FORMAT:
$ !
$ !		- Records beginning with "!" are treated as comments.
$ !
$ !		- Records beginning with "$" are executed as DCL commands.
$ !
$ !		- All other records are file names.
$ !
$ !		The files are copied by FLX, and certain FLX switches
$ !		must be associated with each file name.  This command
$ !		procedure expects the switches in the local symbols
$ !		SRC_FLX_SWITCH$ and DST_FLX_SWITCH$.  The data file is
$ !		responsible for setting	the switches AND the default
$ !		directory from which the files are to be copied.  This
$ !		is done by having the appropriate DCL commands in the
$ !		data file.
$ !
$ !
$ ! NOTE:	The console medium for the 11/780, 11/750 and 11/730 must
$ !		have a valid boot block.  This command procedure uses
$ !		WRITEBOOT to write a boot block to the 11/750 medium, and
$ !		RTB to write a boot block to the 11/780 and 11/730 media.
$ !
$ !--

$ !
$ ! If this is running as a batch job, make sure all the parameters are
$ ! specified.
$ !
$ IF F$MODE() .NES. "BATCH" THEN GOTO START
$ IF P1 .NES. "" .AND. P2 .NES. "" .AND. P3 .NES. "" THEN GOTO START
$ WRITE SYS$OUTPUT "*** error *** P1 through P3 must be specified"
$ EXIT

$START:
$ TYPE SYS$INPUT

Create a VMS console medium.

$ SAVED_PRIVS = F$SETPRV("CMKRNL,CMEXEC,LOG_IO,SYSNAM,VOLPRO")
$ SAVED_UIC = F$USER()
$ SAVED_DIR := 'F$LOG("SYS$DISK")''F$DIR()'
$ DATA_FILE_OPEN := FALSE
$ DEVICE_MOUNTED := FALSE
$ KIT_DONE := FALSE
$ ON ERROR THEN GOTO CLEAN_UP
$ SET UIC [1,4]
$ KIT := 'P1
$ DST := 'P2
$ CMDSRC := 'P3
$ VMBSRC := 'P4
$
$ KIT:
$ !
$ ! If P1 was not specified, then prompt for a kit type.
$ !
$ IF KIT .EQS. "" THEN -
  INQUIRE KIT "Which kit do you wish to build (780!750!730)"
$ IF (KIT .EQS. "780") .OR. (KIT .EQS. "750") .OR. (KIT .EQS. "730") THEN -
	GOTO DST
$ KIT :=
$ GOTO KIT
$
$ DST:
$ !
$ ! If P2 was not specified, then prompt for a target device.
$ !
$ IF DST .EQS. "" THEN -
  INQUIRE DST "Specify target device (DDCU:)"
$ TARGET := "''F$EXTRACT(0,2,DST)'''F$EXTRACT(3,1,DST)':"
$
$ CMDSRC:
$ !
$ ! If P3 was not specified, then prompt for a source device and directory
$ ! for boot command files, microcode and diagnostic console files.
$ !
$ IF CMDSRC .NES. "" THEN GOTO VMBSRC
$ WRITE SYS$OUTPUT -
"	All boot command files, microcode files, and diagnostic files listed"
$ WRITE SYS$OUTPUT -
"	in data file ''KIT'CNSL.DAT are expected to be in the directory you
$ WRITE SYS$OUTPUT -
"	specify next.  ** NOTE ** Do not use a logical name **.
$ WRITE SYS$OUTPUT -
"Specify device and directory containing boot command files (DDCU:[DIRECTORY])"
$ INQUIRE CMDSRC ""
$
$ VMBSRC:
$ !
$ ! If P4 was not specified, use SYS$SYSROOT:[SYSEXE] as the device and
$ ! directory where VMB.EXE, the primary bootstrap file, can be found.
$ !
$ IF VMBSRC .NES. "" THEN GOTO OPEN
$ TOPSYS = F$LOGICAL("SYS$TOPSYS")
$ IF TOPSYS .NES. "" THEN TOPSYS = TOPSYS + "."
$ VMBTEMP = F$LOGICAL("SYS$SYSDEVICE") - "__" + "[" + TOPSYS + "SYSEXE" + "]"
$ IF F$MODE() .NES. "INTERACTIVE" THEN GOTO VMBSRC_DEFAULT
$ WRITE SYS$OUTPUT -
"	VMB.EXE, the primary bootstrap image, is expected to be in the"
$ WRITE SYS$OUTPUT -
"	directory you specify next.  The default is ''VMBTEMP'."
$ WRITE SYS$OUTPUT -
"	Just type <RETURN> to select default device and directory."
$ WRITE SYS$OUTPUT -
"	** NOTE ** Do not use a logical name **."
$ INQUIRE VMBSRC -
"Specify device and directory containing VMB.EXE"
$VMBSRC_DEFAULT:
$ IF VMBSRC .EQS. "" THEN VMBSRC = VMBTEMP
$
$ OPEN:
$ !
$ ! Open the data file.
$ !
$ ON CONTROL_Y THEN GOTO CLEAN_UP
$ SET DEFAULT 'CMDSRC
$ IF P5 .EQS. "" THEN P5 := SYS$UPDATE:'KIT'CNSL.DAT
$ OPEN DATA_FILE 'P5
$ DATA_FILE_OPEN := TRUE

$ MOUNT:
$ !
$ ! Mount the TARGET device.  The device is assumed to be on line
$ ! with no medium currently mounted.  The medium is first INITed
$ ! to give it the volume name of "CONSOLE".
$ !
$ ! If the target device is the system console, some
$ ! extra steps must be taken to be sure the console
$ ! is on line and unmounted.  (This is not necessary for
$ ! 11/730 kits, though, since the console TU58 is in a
$ ! different drive than the "user" tu58).
$ !
$ IF F$EXTRACT(0,2,TARGET) .NES. "CS" THEN GOTO CHK_CNSL_DEV
$ RUN SYS$SYSTEM:SYSGEN
CONNECT CONSOLE

$CHK_CNSL_DEV:
$ IF .NOT. F$GETDVI(TARGET,"MNT") THEN GOTO FINISH_MOUNT
$ DISMOUNT 'TARGET

$ FINISH_MOUNT:
$ IF KIT .EQS. "780" THEN CNSL_MEDIUM := "floppy"
$ IF KIT .EQS. "750" .OR. KIT .EQS."730" THEN CNSL_MEDIUM := "TU58 cartridge"
$ WRITE SYS$OUTPUT "Put the ''CNSL_MEDIUM' in the target device, ''DST'."
$ INQUIRE NULL "Type <cr> when you are ready to continue"
$ INIT 'TARGET CONSOLE
$ MOUNT/F 'TARGET
$ MCR FLX 'TARGET'/RT/ZE
$

$ ! While the data file is not empty:
$ !	- read a record.
$ !	- if the record is a comment, ignore it.
$ !	- if the record is a DCL command, execute it.
$ !	- if the record is a file name, copy it to the target device.
$ !
$ NEXT_RECORD:
$ READ/END_OF_FILE=WRITE_BOOTBLK DATA_FILE DATA_RECORD
$ IF "''F$EXTRACT(0,1,DATA_RECORD)'" .EQS. "!" THEN GOTO NEXT_RECORD
$ IF "''F$EXTRACT(0,1,DATA_RECORD)'" .EQS. "$" THEN GOTO EXECUTE_COMMAND
$ MCR FLX 'TARGET''DST_FLX_SWITCH$'='DATA_RECORD''SRC_FLX_SWITCH$'
$ WRITE SYS$OUTPUT "Copied ''DATA_RECORD'"
$ GOTO NEXT_RECORD

$ EXECUTE_COMMAND:
$ !
$ ! Execute a DCL command record and return to the read loop.
$ !
'DATA_RECORD
$ GOTO NEXT_RECORD

$ WRITE_BOOTBLK:
$ !
$ ! If this is a 750 kit, write a bootblock on the medium.
$ !
$ IF KIT .NES. "750" THEN KIT_DONE := TRUE
$ IF KIT .NES. "750" THEN GOTO CLEAN_UP
$ ASSIGN/USER 'TARGET' TARGET_DEVICE
$ MCR WRITEBOOT
TARGET_DEVICE:BOOT58.EXE
1
C000
$ WRITE SYS$OUTPUT "Boot block written."
$ KIT_DONE := TRUE

$ CLEAN_UP:
$ !
$ ! Do any clean up necessary before exiting.
$ ! If the target device was the system console,
$ ! the origional console medium must be mounted
$ ! to protect it from DERFS.
$ !
$ ON ERROR THEN CONTINUE
$ ON CONTROL_Y THEN CONTINUE
$ IF F$GETDVI(TARGET,"MNT") THEN DISMOUNT 'TARGET
$ IF F$EXTRACT(0,2,TARGET) .NES. "CS" THEN GOTO FINISH_CLEAN_UP
$ IF F$GETSYI("CPU") .EQ. 3 THEN GOTO 730_CONSOLE
$ CONSOLE_DRIVE := CSA1
$ WRITE SYS$OUTPUT -
"Please replace the original console medium in the console drive."
$ GOTO REMOUNT_CONSOLE
$
$730_CONSOLE:
$ IF F$GETDVI("CSA2:","MNT") THEN GOTO FINISH_CLEAN_UP
$ CONSOLE_DRIVE := CSA2
$
$REMOUNT_CONSOLE:
$ WRITE SYS$OUTPUT -
"The console medium will be mounted /NOWRITE for protection."
$ INQUIRE NULL "Type <cr> when you are ready to continue."
$ MOUNT/FOR/SYS/NOWRITE 'CONSOLE_DRIVE' CONSOLE
$
$FINISH_CLEAN_UP:
$ IF DATA_FILE_OPEN THEN CLOSE DATA_FILE
$ SET UIC 'SAVED_UIC
$ SET PROCESS/PRIV=('SAVED_PRIVS')
$ SET DEFAULT 'SAVED_DIR
$ IF KIT_DONE THEN WRITE SYS$OUTPUT "Done."
$ IF .NOT. KIT_DONE THEN -
	WRITE SYS$OUTPUT "Procedure aborted - kit is incomplete."
