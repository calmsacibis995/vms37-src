$ !
$ ! CONSCOPY -- Save or Restore a console medium
$ !
$ ! Inputs:
$ !	P1 - Kit type: 780 or 750 or 730
$ !	P2 - Function: SAVE or RESTORE
$ !	P3 - Files-11 device and directory
$ !	P4 - Console device drive
$ !	P5 - File to be written on the bootblock of the console medium.
$ !	     Optional.  The defaults are:
$ !		780 - CONSOL.SYS
$ !		750 - BOOT58.EXE
$ !		730 - BOOT.EXE
$ !
$ ! This program saves or restores a console medium.  It uses the compatibility
$ ! mode utility FLX to copy and re-format files between a user medium
$ ! (Files-11 format) and a console medium (RT-11 format).
$ !
$
$ !**********************************************************************
$ !*	If this is running as a batch job, make sure all		*
$ !*	parameters are specified.					*
$ !**********************************************************************
$
$ IF F$MODE() .NES. "BATCH" THEN GOTO START
$ IF P1 .NES. "" .AND. P2 .NES. "" .AND. P3 .NES. "" .AND. P4 .NES. "" -
	THEN GOTO START
$ WRITE SYS$OUTPUT "*** error ***  P1 through P4 must be specified."
$ EXIT
$
$ !**********************************************************************
$ !*	Write a greeting mssage, then initialize symbols used by this	*
$ !*	command procedure.						*
$ !**********************************************************************
$
$START:
$ TYPE SYS$INPUT

Save or restore a VMS console medium.

$ SAVED_PRIVS = F$SETPRV("CMEXEC,CMKRNL,LOG_IO,SYSNAM,VOLPRO")
$ SAVED_DIR := 'F$LOG("SYS$DISK")''F$DIR()'
$ KIT_DONE := FALSE
$
$ KIT := 'P1
$ FUNCTION := 'P2
$ FILES11_DEVICE := 'P3
$ CONSOLE_DEVICE := 'P4
$ BOOTFILE := 'P5
$
$ !**********************************************************************
$ !*	Get CPU type, and derive information about the console		*
$ !*	device from it.							*
$ !**********************************************************************
$
$KIT:
$ !
$ ! If P1 not specified, prompt for kit type.
$ !
$ IF KIT .NES. "" THEN GOTO CHECK_KIT
$
$GET_KIT:
$ INQUIRE KIT "Which kit do you want to build (780!750!730)"
$
$CHECK_KIT:
$ IF KIT .EQS. "780" THEN GOTO SET_780_PARMS
$ IF KIT .EQS. "750" THEN GOTO SET_750_PARMS
$ IF KIT .EQS. "730" THEN GOTO SET_730_PARMS
$ GOTO GET_KIT
$
$SET_780_PARMS:
$ MEDIUM := "floppy"
$ FILES11_FLX_SWITCH := /RS/IM
$ RT_FLX_SWITCH := /RT
$ IF BOOTFILE .EQS. "" THEN BOOTFILE := CONSOL.SYS
$ GOTO END_SET_PARMS
$
$SET_750_PARMS:
$ MEDIUM := "TU58"
$ FILES11_FLX_SWITCH := /RS/IM
$ RT_FLX_SWITCH := /RT
$ IF BOOTFILE .EQS. "" THEN BOOTFILE := BOOT58.EXE
$ GOTO END_SET_PARMS
$
$SET_730_PARMS:
$ MEDIUM := "TU58"
$ FILES11_FLX_SWITCH := /RS/IM
$ RT_FLX_SWITCH := /RT/IM
$ IF BOOTFILE .EQS. "" THEN BOOTFILE := BOOT.EXE
$
$END_SET_PARMS:
$
$ !**********************************************************************
$ ! 	Get the remainder of the input parameters.			*
$ !**********************************************************************
$
$FUNCTION:
$ !
$ ! If P2 not specified, prompt for function.
$ !
$ IF FUNCTION .NES. "" THEN GOTO CHECK_FUNCTION
$ TYPE SYS$INPUT:

	A SAVE operation involves copying the console medium
	to a Files-11 directory.

	A RESTORE operation involves copying the entire contents
	of a Files-11 directory to a console medium.

$GET_FUNCTION:
$ INQUIRE FUNCTION "Do you want to SAVE or RESTORE your console ''MEDIUM'?"
$
$CHECK_FUNCTION:
$ IF (FUNCTION .NES. "SAVE") .AND. (FUNCTION .NES. "RESTORE") -
	THEN GOTO GET_FUNCTION
$
$FILES11_DEVICE:
$ !
$ ! If P3 not specified, prompt for Files-11 device and directory.
$ !
$ IF FILES11_DEVICE .EQS. "" THEN -
  INQUIRE FILES11_DEVICE "Enter Files-11 device and directory (DDCU:[DIR])"
$
$ !
$ ! Check that the directory exists and is writable, by creating a temporary
$ ! file.  This is done to provide better error messages for the user than
$ ! FLX gives if it fails later on.
$ CREATE 'FILES11_DEVICE'TEMP.TMP
This is temporary test file to check the directory is writable.
$ DELETE 'FILES11_DEVICE'TEMP.TMP;*
$
$CONSOLE_DEVICE:
$ !
$ ! If P4 not specified, prompt for console device drive.
$ !
$ IF CONSOLE_DEVICE .EQS. "" THEN -
	INQUIRE CONSOLE_DEVICE "Enter console device drive (DDCU:)"
$ FLX_DEVICE:= 'F$EXTRACT(0,2,CONSOLE_DEVICE)''F$EXTRACT(3,1,CONSOLE_DEVICE)':
$
$ !**********************************************************************
$ !*	If using the console device (CSA1:), make sure the console	*
$ !*	is connected.  Mount the console medium on the specified drive.	*
$ !**********************************************************************
$
$ ON ERROR THEN GOTO CLEAN_UP
$ ON CONTROL_Y THEN GOTO CLEAN_UP
$ IF F$EXTRACT(0,2,CONSOLE_DEVICE) .NES. "CS" THEN GOTO CHK_CNSL_DEV
$ RUN SYS$SYSTEM:SYSGEN
CONNECT CONSOLE
$
$CHK_CNSL_DEV:
$ IF .NOT. F$GETDVI(CONSOLE_DEVICE,"MNT") THEN GOTO MOUNT_CONSOLE
$ DISMOUNT 'CONSOLE_DEVICE'
$
$MOUNT_CONSOLE:
$ WRITE SYS$OUTPUT "Put your console ''MEDIUM' into drive ''CONSOLE_DEVICE',"
$ INQUIRE TEMP "and type <RETURN> when ready"
$ MOUNT/NOASSIST/FOREIGN 'CONSOLE_DEVICE'
$
$ !**********************************************************************
$ !*	Save or restore the console medium.				*
$ !**********************************************************************
$
$ SET DEFAULT 'FILES11_DEVICE'
$ IF FUNCTION .EQS. "RESTORE" THEN GOTO RESTORE
$
$SAVE:
$ !
$ ! Copy the constents of the console medium to a files-11 directory,
$ ! using the FLX utility.
$ !
$ MCR FLX 'FILES11_FLX_SWITCH'='FLX_DEVICE'*.*'RT_FLX_SWITCH'
$ KIT_DONE := TRUE
$ GOTO CLEAN_UP
$
$RESTORE:
$ !
$ ! Rebuild the console medium.  FLX will be used to copy all the files to the
$ ! console medium in RT-11 format.  Also, write a bootblock on the medium.
$ !
$ MCR FLX 'FLX_DEVICE'/RT/ZE		! Initialize the console medium.
$ MCR FLX 'FLX_DEVICE''RT_FLX_SWITCH'=*.*'FILES11_FLX_SWITCH'	! Copy.
$ MCR FLX 'FLX_DEVICE'/RT/LI		! List all files on console.
$
$
$WRITEBOOT:
$ IF KIT .EQS. "750" THEN GOTO WRITEBOOT_750
$ !
$ ! Use RTB utility to write a bootblock on 780 and 730 media.
$ !
$ DEFINE/USER RTB$INPUT 'BOOTFILE'
$ DEFINE/USER RTB$OUTPUT 'FLX_DEVICE'
$ RUN SYS$SYSTEM:RTB
$ KIT_DONE := TRUE
$ GOTO CLEAN_UP
$
$WRITEBOOT_750:
$ ASSIGN/USER 'CONSOLE_DEVICE''BOOTFILE' BOOT 
$ RUN SYS$SYSTEM:WRITEBOOT
BOOT
1
C000
$ KIT_DONE := TRUE
$
$ !**********************
$ !*	Clean up.	*
$ !**********************
$
$CLEAN_UP:
$ ON ERROR THEN CONTINUE
$ ON CONTROL_Y THEN CONTINUE
$ SET DEFAULT 'SAVED_DIR'
$ IF KIT_DONE THEN WRITE SYS$OUTPUT -
	"''FUNCTION' of your console ''MEDIUM' is complete."
$ IF .NOT. KIT_DONE THEN WRITE SYS$OUTPUT -
	"Error in command file execution -- kit is incomplete."
$ IF F$GETDVI(CONSOLE_DEVICE,"MNT") THEN DISMOUNT 'CONSOLE_DEVICE'
$ !
$ ! If this procedure used the console drive, it is now accessible.  Mount
$ ! it /NOWRITE to protect it.
$ !
$ IF F$EXTRACT(0,2,CONSOLE_DEVICE) .NES. "CS" THEN GOTO DONE
$ IF F$GETSYI("CPU") .EQ. 3 THEN GOTO 730_CONSOLE
$ CONSOLE_DRIVE := CSA1
$ GOTO REMOUNT_CONSOLE
$
$730_CONSOLE:
$ IF F$GETDVI("CSA2:","MNT") THEN GOTO DONE
$ CONSOLE_DRIVE := CSA2
$
$REMOUNT_CONSOLE:
$ WRITE SYS$OUTPUT ""
$ WRITE SYS$OUTPUT "Since the console device is now accessible to users,"
$ WRITE SYS$OUTPUT "the console ''MEDIUM' will be remounted /NOWRITE for"
$ WRITE SYS$OUTPUT "protection.  Please place your console ''MEDIUM' in"
$ INQUIRE TEMP "the console device drive and type <RETURN> when ready"
$ MOUNT/NOASSIST/FOREIGN/SYSTEM/NOWRITE 'CONSOLE_DRIVE' CONSOLE
$
$DONE:
$ SET PROCESS/PRIV=('SAVED_PRIVS')
