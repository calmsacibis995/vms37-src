$ !++
$ ! STABACKIT.COM - Build a standalone BACKUP kit.
$ !
$ ! ABSTRACT:	This command procedure builds a standalone BACKUP kit on
$ !		floppies, TU58 cartridges, or a disk.
$ !
$ ! INPUT:	P1 - Target device, assumed online with no media mounted.
$ !		P2 - Target directory (optional, defaults to [SYSEXE]).
$ !		P3 - Source device and directory (optional, defaults to
$ !		SYS$SYSTEM)
$ !
$ !		Privileges required:  SETPRV
$ !		Write access to SYS$UPDATE is also required.
$ !--
$ ON ERROR THEN GOTO CLEAN_UP
$ ON CONTROL_Y THEN GOTO CLEAN_UP
$ WRITE SYS$OUTPUT "Build a standalone BACKUP kit."
$ SAVED_PRIVS = F$SETPRV("CMKRNL,CMEXEC,LOG_IO,SYSNAM,VOLPRO,OPER")
$ VOL_NAME := A
$ KIT_DONE := FALSE
$ SAVED_UIC = F$USER()
$ COPYCT = "COPY/CONTIG/TRUNC/LOG"
$ SET UIC [1,4]
$P1:
$ !
$ ! If P1 was not specified, prompt the user for a target device.
$ !
$ IF P1 .NES. "" THEN GOTO MOUNT
$ INQUIRE P1 "Specify target device (DDCU:)"
$ GOTO P1
$MOUNT:
$ !
$ ! If the target device is the system console make sure it is online with no
$ ! media mounted.
$ !
$ IF F$EXTRACT(0,2,P1) .NES. "CS" THEN GOTO NOT_CONSOLE
$ MCR SYSGEN
CONNECT CONSOLE
$ ON WARNING THEN CONTINUE
$ IF F$GETDVI(P1,"MNT") THEN DISMOUNT 'P1'
$ ON WARNING THEN GOTO CLEAN_UP
$
$NOT_CONSOLE:
$ IF F$LOCATE(":", P1) .EQ. F$LENGTH(P1) THEN P1 := 'P1':
$ ON WARNING THEN GOTO CLEAN_UP
$ DEV_TYPE = 'F$GETDVI(P1, "DEVTYPE")
$ ON ERROR THEN GOTO CLEAN_UP
$ KIT_TYPE = "disk"
$ IF DEV_TYPE .EQ. 11 .OR. DEV_TYPE .EQ. 16 THEN KIT_TYPE = "floppy"
$ IF DEV_TYPE .EQ. 14 THEN KIT_TYPE = "TU58"
$ IF KIT_TYPE .NES. "disk" THEN P2 = ""
$ IF KIT_TYPE .NES. "disk" THEN VOLUME = "first "
$ IF P2 .EQS. "" THEN P2 = "[SYSEXE]"
$ DEFINE KIT$ 'P1''P2'
$ IF P3 .EQS. "" THEN P3 = "SYS$SYSROOT:[SYSEXE]"
$ DEFINE SYS$ 'P3'
$ !
$ ! Initialize and mount the target device.  The volume label depends on which
$ !
$FINISH_MOUNT:
$ ON WARNING THEN CONTINUE
$ IF KIT_TYPE .EQS. "disk" .AND. F$GETDVI(P1, "MNT") THEN GOTO MOUNTED
$ WRITE SYS$OUTPUT "Please place the ''VOLUME'''KIT_TYPE' in drive ''P1'."
$ INQUIRE TEMP "Press return when ready to continue"
$ IF KIT_TYPE .EQS. "disk" THEN GOTO M1
$ IF .NOT. F$GETDVI(P1, "MNT") THEN GOTO 20
$ WRITE SYS$OUTPUT "Error - target ''KIT_TYPE' is already mounted."
$ WRITE SYS$OUTPUT "Please dismount it and re-invoke this procedure."
$ GOTO CLEAN_UP
$20:
$ HEADERS = 18
$ IF KIT_TYPE .EQS. "TU58" .AND. VOL_NAME .EQS. "A" THEN HEADERS = 20
$ IF VOL_NAME .EQS. "B" THEN HEADERS = 22
$ IF KIT_TYPE .EQS. "TU58" .AND. VOL_NAME .EQS. "B" THEN HEADERS = 23
$ ON WARNING THEN GOTO FINISH_MOUNT
$ DENS = ""
$ IF DEV_TYPE .EQ. 11 THEN DENS = "/DENSITY=SINGLE"
$ INITIALIZE'DENS/HEADERS='HEADERS/INDEX=BEGINNING 'P1 STABACKUP'VOL_NAME
$ ON ERROR THEN GOTO CLEAN_UP
$M1:
$ ON ERROR THEN GOTO CLEAN_UP
$ MOUNT/OVER=ID 'P1
$MOUNTED:
$ ON ERROR THEN GOTO CLEAN_UP
$ DEVICE_MOUNTED := TRUE
$ CREATE/DIRECTORY/LOG 'P1''P2'
$ IF VOL_NAME .EQS. "B" THEN GOTO VOLUME2
$VOLUME1:
$ !
$ ! Get a local copy of SYS.EXE and apply the parameter file to it.
$ !
$ COPY SYS$:SYS.EXE SYS$UPDATE:
$ DEFINE/USER SYS$SYSTEM 'F$LOGICAL("SYS$UPDATE")'
$ RUN SYS$:SYSGEN
USE DEFAULT
SET PFCDEFAULT 1
SET GBLSECTIONS 20
SET GBLPAGES 512
SET MAXPROCESSCNT 12
SET BALSETCNT 4
SET IRPCOUNT 100
SET WSMAX 1000
SET NPAGEDYN 80000
SET VIRTUALPAGECNT 2048
SET SPTREQ 512
SET SYSPAGING 0
SET MPW_HILIM 2000
SET PQL_DASTLM 12
SET PQL_DDIOLM 12
SET PQL_DWSDEFAULT 1000
SET PQL_DWSQUOTA 1000
SET PQL_DWSEXTENT 1000
WRITE CURRENT
$ !
$ ! Copy the BACKUP system to the medium.  The files must all be contiguous.
$ ! In order to conserve space, the files are copied with the /TRUNC option.
$ ! Some files are unique to a certain CPU.  These files are copied or not
$ ! copied as special cases.
$ !
$ IF KIT_TYPE .EQS. "disk" THEN -
   COPY/CONTIGUOUS/ALLOC=4 NL: KIT$:SYSDUMP.DMP	! Create minimum dump file.
$ COPYCT SYS$UPDATE:SYS.EXE KIT$:
$ COPYCT SYS$:INILOA.EXE KIT$:
$ COPYCT SYS$:SCSLOA.EXE KIT$:
$ COPYCT SYS$:STASYSGEN.EXE KIT$:SYSINIT.EXE
$ COPYCT SYS$:SYSBOOT.EXE KIT$:
$ IF KIT_TYPE .NES. "TU58" THEN COPYCT SYS$:SYSLOA780.EXE KIT$:
$ IF KIT_TYPE .NES. "floppy" THEN COPYCT SYS$:SYSLOA730.EXE KIT$:
$ IF KIT_TYPE .NES. "floppy" THEN COPYCT SYS$:SYSLOA750.EXE KIT$:
$ IF KIT_TYPE .NES. "floppy" THEN COPYCT SYS$:VMB.EXE KIT$:
$ !
$ ! Copy the drivers.
$ !
$ IF KIT_TYPE .EQS. "TU58" THEN COPYCT SYS$:DDDRIVER.EXE KIT$:
$ IF KIT_TYPE .EQS. "floppy" THEN COPYCT SYS$:DXDRIVER.EXE KIT$:
$ COPYCT SYS$:TTDRIVER.EXE KIT$:
$ !
$ ! Write a boot block on a disk or TU58 kit.
$ !
$ IF KIT_TYPE .EQS. "floppy" THEN GOTO FINISH_VOLUME1
$ MCR WRITEBOOT
KIT$:VMB.EXE
1
200
$FINISH_VOLUME1:
$ !
$ ! Set up for building volume 2.
$ !
$ IF KIT_TYPE .EQS. "disk" THEN GOTO C4
$ DISMOUNT 'P1
$ DEVICE_MOUNTED := FALSE
$ VOLUME = "second "
$ VOL_NAME = "B"
$ GOTO FINISH_MOUNT
$
$VOLUME2:
$ !
$ ! Build the second volume of the set.
$ !
$C4:
$ COPYCT SYS$:STABACKUP.EXE KIT$:
$ !
$ ! Copy remaining drivers.
$ !
$ IF KIT_TYPE .NES. "disk" THEN COPYCT SYS$:SCSLOA.EXE KIT$:
$ COPYCT SYS$:DBDRIVER.EXE KIT$:
$ IF KIT_TYPE .EQS. "disk" THEN COPYCT SYS$:DDDRIVER.EXE KIT$:
$ COPYCT SYS$:DLDRIVER.EXE KIT$:
$ COPYCT SYS$:DMDRIVER.EXE KIT$:
$ IF KIT_TYPE .NES. "floppy" THEN COPYCT SYS$:DQDRIVER.EXE KIT$:
$ COPYCT SYS$:DRDRIVER.EXE KIT$:
$ COPYCT SYS$:DUDRIVER.EXE KIT$:
$ COPYCT SYS$:PUDRIVER.EXE KIT$:
$ IF KIT_TYPE .EQS. "disk" THEN COPYCT SYS$:DXDRIVER.EXE KIT$:
$ IF KIT_TYPE .EQS. "disk" THEN COPYCT SYS$:DYDRIVER.EXE KIT$:
$ COPYCT SYS$:TFDRIVER.EXE KIT$:
$ COPYCT SYS$:TMDRIVER.EXE KIT$:
$ COPYCT SYS$:TSDRIVER.EXE KIT$:
$ COPYCT SYS$:LCDRIVER.EXE KIT$:
$ COPYCT SYS$:LPDRIVER.EXE KIT$:
$ KIT_DONE := TRUE
$ WRITE SYS$OUTPUT "Kit is complete."
$CLEAN_UP:
$ !
$ ! Do any cleanup necessary before exiting.
$ ! If the target device was the system console,
$ ! the original console medium must be remounted.
$ !
$ ON ERROR THEN CONTINUE
$ ON CONTROL_Y THEN CONTINUE
$ IF P1 .EQS. "" THEN GOTO FINISH_CLEAN_UP
$ IF F$GETDVI(P1, "MNT") .AND. KIT_TYPE .NES. "disk" THEN DISMOUNT/NOUNLOAD 'P1'
$ IF F$EXTRACT(0,2,P1) .NES. "CS" THEN GOTO FINISH_CLEAN_UP
$ IF F$GETSYI("CPU") .EQ. 3 THEN GOTO 730_CONSOLE
$ CONSOLE_DRIVE := CSA1
$ WRITE SYS$OUTPUT "Please replace the console ''KIT_TYPE."
$ GOTO REMOUNT_CONSOLE
$
$730_CONSOLE:
$ IF F$GETDVI("CSA2:","MNT") THEN GOTO FINISH_CLEAN_UP
$ CONSOLE_DRIVE := CSA2
$
$REMOUNT_CONSOLE:
$ WRITE SYS$OUTPUT -
"The console ''KIT_TYPE' will be mounted /NOWRITE for protection."
$ INQUIRE NULL "Press return when ready to continue"
$ MOUNT/FOREIGN/SYSTEM/NOWRITE 'CONSOLE_DRIVE' CONSOLE
$
$FINISH_CLEAN_UP:
$ IF F$LOGICAL("SYS$") .NES. "" THEN DEASSIGN SYS$
$ IF F$LOGICAL("KIT$") .NES. "" THEN DEASSIGN KIT$
$ IF F$SEARCH("SYS$UPDATE:SYS.EXE") .NES. "" THEN DELETE SYS$UPDATE:SYS.EXE;*
$ SET UIC 'SAVED_UIC
$ SET PROCESS/PRIV=('SAVED_PRIVS')
$ IF .NOT. KIT_DONE THEN WRITE SYS$OUTPUT "Kit is incomplete."
