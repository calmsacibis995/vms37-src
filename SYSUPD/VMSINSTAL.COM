$	ON CONTROL_Y THEN GOTO DTR$CONTROL_Y
$	ON ERROR THEN GOTO CLEANUP
$	STS$M_INHIB_MSG		= %X10000000
$ !
$ !	VMSINSTAL.COM -- Install new software on VAX/VMS Version 3.0
$ !
$ ! Author:	Trudy C. Matthews
$ !
$ ! FUNCTIONAL DESCRIPTION:
$ !	This command procedure installs software onto a VAX/VMS system.
$ !
$ ! INPUTS:
$ !	P1	- The name of the product being installed (which
$ !		  is used by this procedure as the name of the saveset to
$ !		  restore).  If this parameter is defaulted, the volume label
$ !		  on the installation kit is used as the name of the saveset.
$ !
$ !		  defaulted, VMSINSTAL will prompt for it.
$ !
$ !	P3	- Keyword DETAILOR or RETAILOR.  DETAILOR should be specified
$ !		  before an update or installation is performed on an RL02
$ !		  system disk.  RETAILOR should be specified after an update
$ !		  or installation has completed on an RL02 system disk.
$ !
$ !	The distribution kit is expected to contain a saveset, which will be
$ !	restored onto the system disk in the directory [SYSUPD.saveset_name].
$ !	Once the files are restored, a command procedure (saveset_name.COM)
$ !	will be invoked to perform the product-specific installation.
$ !
$ !
$ ! PRIVILEGES REQUIRED:
$ !	SETPRV
$ !
$
$GET_P3:
$	IF P3 .EQS. "" THEN GOTO START
$	IF P3 .NES. "DETAILOR" .AND. P3 .NES. "RETAILOR" -
	   THEN GOTO INVALID_P3
$	DTR$STATUS = 2
$	ON ERROR THEN GOTO DTR$CLEANUP
$	VMS$TAILOR := @SYS$UPDATE:VMSTAILOR
$	GOTO VMS$'P3'
$
$INVALID_P3:
$	WRITE SYS$OUTPUT -
	"If specified, P3 must be DETAILOR or RETAILOR"
$	WRITE SYS$OUTPUT """''P3'"" is not recognized"
$	EXIT (2 .OR. STS$M_INHIB_MSG)
$START:
$	SAVED_PRIVS = F$SETPRV("VOLPRO,CMKRNL,SYSPRV")
$	SAVED_DIR = F$DIRECTORY()
$	SAVED_UIC = F$USER()
$	SET PROTECTION=(S:RWED,G:RWED,O:RWED,W:RE) /DEFAULT
$	VERSION := 300
$	SUMMARY := "   Installation procedure incomplete."
$
$CHK_KIT:
$ !
$ ! Get distribution kit drive.
$ !
$	KIT := 'P2
$	IF KIT .NES. "" THEN GOTO 10$
$GET_KIT:
$	ON ERROR THEN GOTO GET_KIT
$	INQUIRE KIT "Enter drive holding distribution kit"
$10$:	IF F$LOC(":",KIT) .EQ. F$LEN(KIT) THEN KIT := 'KIT':
$	IF F$GETDVI(KIT,"EXISTS") THEN GOTO MNT_KIT
$	WRITE SYS$OUTPUT "Cannot access device ""''KIT'"""
$	GOTO GET_KIT
$
$MNT_KIT:
$	ON WARNING THEN GOTO GET_KIT
$	KIT_TYPE = F$GETDVI(KIT,"DEVCLASS")
$	IF KIT_TYPE .EQ. 2 THEN XMOUNT = "MOUNT /NOWRITE /NOASSIST /FOREIGN" ! Magtape.
$	IF KIT_TYPE .EQ. 1 THEN XMOUNT = "MOUNT /NOWRITE /NOASSIST /OVER=ID" ! Disk.
$	ON ERROR THEN GOTO GET_KIT
$	XMOUNT 'KIT'
$
$	ON ERROR THEN GOTO CLEANUP
$	ON CONTROL_Y THEN GOTO CLEANUP
$	SET UIC [1,4]
$	SET DEFAULT SYS$DISK:[SYSEXE]
$
$ !
$ ! Get the name of the product being installed.
$ !
$	SAVESET := 'P1
$	IF SAVESET .NES. "" THEN GOTO DETAILOR_RL02
$	SAVESET = F$GETDVI(KIT,"VOLNAM")
$
$DETAILOR_RL02:
$	IF F$GETDVI("SYS$DISK","MAXBLOCK") .GE. 25000 THEN GOTO CREATE_DIR
$	IF F$GETDVI("SYS$DISK","DEVNAM") -
	  .NES. F$GETDVI("SYS$SYSDEVICE","DEVNAM") THEN GOTO CREATE_DIR
$	IF SAVESET .EQS. "EDTCAI" THEN GOTO CREATE_DIR
$	@SYS$UPDATE:VMSINSTAL "" "" DETAILOR
$	IF .NOT. $STATUS THEN GOTO CLEANUP
$
$CREATE_DIR:
$	CREATE/DIRECTORY [SYSUPD.'SAVESET']
$	IF $STATUS .NE. %X10911293 THEN GOTO RESTORE_FILES
$	DELETE [SYSUPD.'SAVESET']*.*;*
$
$RESTORE_FILES:
$	SS_TYPE = ""
$	IF SAVESET .NES. "VMS300" THEN SS_TYPE = ".SAV"
$	BACKUP 'KIT'[0,0]'SAVESET''SS_TYPE'/SAVE_SET [SYSUPD.'SAVESET']
$	@[SYSUPD.'SAVESET']'SAVESET'.COM  'KIT'
$	DELETE [SYSUPD.'SAVESET']*.*;*
$	SET FILE /NODIR [SYSUPD]'SAVESET'.DIR
$	SET /PROTECTION = (S:D,O:D,G:D,W:D) [SYSUPD]'SAVESET'.DIR
$	DELETE [SYSUPD]'SAVESET'.DIR;
$
$RETAILOR_RL02:
$	IF F$GETDVI("SYS$DISK","MAXBLOCK") .GE. 25000 THEN GOTO DONE
$	IF F$GETDVI("SYS$DISK","DEVNAM") -
	  .NES. F$GETDVI("SYS$SYSDEVICE","DEVNAM") THEN GOTO DONE
$	IF SAVESET .EQS. "EDTCAI" THEN GOTO DONE
$	ON ERROR THEN GOTO DONE
$	@SYS$UPDATE:VMSINSTAL "" "" RETAILOR
$
$DONE:
$	ON ERROR THEN GOTO CLEANUP
$	SUMMARY := -
"Kit installation complete."
$
$CLEANUP:
$	SET NOON
$	IF F$GETDVI(KIT,"MNT") THEN DISMOUNT /NOUNLOAD 'KIT'
$	SET UIC 'SAVED_UIC'
$	SET DEFAULT 'SAVED_DIR'
$	SET PROCESS/PRIVILEGE = ('SAVED_PRIVS')
$	WRITE SYS$OUTPUT SUMMARY
$	EXIT
$
$
$ !
$ ! The detailor function records the user software configuration.
$ ! If any revised files are found the user is given the choice of
$ ! deleting them, copying them to the library disk, or exiting.
$ !
$ ! Logical names are assigned for various library files.
$ ! 
$ VMS$DETAILOR:
$	ON ERROR THEN GOTO DTR$GETLIB
$	ON CONTROLY THEN GOTO DTR$CLEANUP
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT " The library disk must be mounted and writeable."
$	WRITE SYS$OUTPUT " Check that ""WRITE PROTECT"" is disabled."
$
$ !
$ ! Locate the library disk and mount it.
$ !
$ DTR$GETLIB:
$	ON ERROR THEN GOTO DTR$GETLIB
$	WRITE SYS$OUTPUT ""
$	READ SYS$COMMAND DTR$LIBDISK /END=DTR$GETLIB -
	/PROMPT="Enter drive holding the library disk (DDCU:) or ""EXIT"": "
$	DTR$LIBDISK := 'DTR$LIBDISK
$	IF DTR$LIBDISK .EQS. "" THEN GOTO DTR$GETLIB
$	WRITE SYS$OUTPUT ""
$	IF DTR$LIBDISK .EQS. "EXIT" THEN EXIT (STS$M_INHIB_MSG .OR. 2)
$	IF F$GETDVI (DTR$LIBDISK, "EXISTS") THEN GOTO DTR$CHKMNT
$	WRITE SYS$OUTPUT "No such device as ''DTR$LIBDISK'"
$	GOTO DTR$GETLIB
$
$ DTR$CHKMNT:
$	IF F$GETDVI ("LIB$SYSDEVICE", "EXISTS") THEN VMS$TAILOR DISMOUNT
$	IF F$GETDVI (DTR$LIBDISK, "MNT") THEN DISMOUNT /NOUNLOAD 'DTR$LIBDISK'
$
$ DTR$MNTLIB:
$	VMS$TAILOR MOUNT /WRITE 'DTR$LIBDISK'
$	IF .NOT. $STATUS THEN GOTO DTR$GETLIB
$
$ !
$ ! Record the user's software tailored software configuration and
$ ! detect any revised files.
$ !
$ DTR$RECORD:
$	ON ERROR THEN GOTO DTR$CLEANUP
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "    Recording tailored software configuration"
$	WRITE SYS$OUTPUT ""
$	VMS$TAILOR RECORD SITE SITEREVD
$	IF F$FILE ("SYS$UPDATE:SITEREVD.TLR", "EOF") .EQ. 0 -
	   THEN GOTO DTR$DELETE
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "*** WARNING -- REVISED FILES ***"
$	WRITE SYS$OUTPUT "--------------------------------"
$	WRITE SYS$OUTPUT ""
$	TYPE SYS$UPDATE:SITEREVD.TLR
$	TYPE SYS$INPUT
$DECK

    The preceding  list of files on your system  disk have revision dates
    different from their copies on the library disk.  These files will be
    deleted from your system disk if you continue this installation.  You
    may  choose to COPY them to the library  disk before deleting them or
    you  may  stop  this  installation by  typing EXIT.  See your "VAX-11
    Software Installation Guide" for more information.

$EOD
$
$ !
$ ! Here if there are revised files.  Find out how the user wants to
$ ! handle them.
$ !
$ DTR$GETACT:
$	ON ERROR THEN GOTO DTR$GETACT
$	READ SYS$COMMAND DTR$REPLY /END=DTR$CLEANUP -
		/PROMPT="Do you wish to COPY [Y]? "
$	DTR$REPLY := 'DTR$REPLY
$	IF DTR$REPLY .EQS. "EXIT" THEN GOTO DTR$CLEANUP
$	DTR$REPLY = F$EXTRACT (0, 1, DTR$REPLY)
$	IF DTR$REPLY .EQS. "N" THEN GOTO DTR$DELETE
$	IF DTR$REPLY .NES. "Y" THEN GOTO DTR$GETACT
$	VMS$TAILOR COPY /LIBRARY SITEREVD
$
$
$ !
$ ! The user's configuration has been recorded and any revised files
$ ! have been copied if desired.  Now delete the user's tailored files
$ ! to make room for the layered product installation.
$ !
$ DTR$DELETE:
$	ON ERROR THEN GOTO DTR$CLEANUP
$	TYPE SYS$INPUT
$DECK

    Deleting tailored software configuration.

    The tailored software will be restored at the end of this procedure.
    If an error  occurs the  configuration can be manually  restored  by
    issuing this command:

                   $ @SYS$UPDATE:VMSTAILOR COPY SITE"

$EOD
$	APPEND SYS$UPDATE:SITEREVD.TLR SYS$UPDATE:SITE.TLR
$	DTR$SITE_BLOCKS == F$GETDVI ("SYS$DISK", "FREEBLOCKS")
$	VMS$TAILOR DELETE SITE
$	DTR$SITE_BLOCKS==F$GETDVI("SYS$DISK","FREEBLOCKS")-DTR$SITE_BLOCKS + 50
$
$ !
$ ! Now define the logical names necessary to access library images
$ !
$	SET NOON
$	IF F$LOGICAL ("STARLET") .NES. "" THEN DEASSIGN STARLET
$	IF F$SEARCH ("SYS$LIBRARY:STARLET.OLB;") .EQS. "" -
	   THEN DEFINE STARLET LIB$LIBRARY:STARLET
$
$	IF F$LOGICAL ("IMAGELIB") .NES. "" THEN DEASSIGN IMAGELIB
$	IF F$SEARCH ("SYS$LIBRARY:IMAGELIB.OLB;") .EQS. "" -
	   THEN DEFINE IMAGELIB LIB$LIBRARY:IMAGELIB
$
$ DTR$DEFINE_EXE:
$	FILE = F$SEARCH ("LIB$SYSTEM:*.EXE;")
$	IF FILE .EQS. "" THEN GOTO DTR$ASSIGN_FINISH
$	FILE = F$PARSE (FILE,,,"NAME")
$	IF F$LOGICAL (FILE) .NES. "" THEN DEASSIGN 'FILE'
$	DEFINE 'FILE' LIB$SYSTEM:'FILE'
$	GOTO DTR$DEFINE_EXE
$
$ DTR$ASSIGN_FINISH:
$	SET ON
$	DTR$STATUS = 1
$	GOTO DTR$CLEANUP
$
$ !
$ ! The RETAILOR function deletes the files used for software installation
$ ! and restores the user's orginal tailored configuration.
$ !
$ VMS$RETAILOR:
$	SET NOON
$	IF F$LOGICAL ("STARLET") .NES. "" THEN DEASSIGN STARLET
$	IF F$LOGICAL ("IMAGELIB") .NES. "" THEN DEASSIGN IMAGELIB
$
$ DTR$DEASSIGN:
$	FILE = F$SEARCH ("LIB$SYSTEM:*.EXE;")
$	IF FILE .EQS. "" THEN GOTO DTR$DEASSIGN_FINISH
$	FILE = F$PARSE (FILE,,,"NAME")
$	IF F$LOGICAL (FILE) .NES. "" THEN DEASSIGN 'FILE'
$	GOTO VMS$RETAILOR
$
$ DTR$DEASSIGN_FINISH:
$	ON ERROR THEN GOTO DTR$CLEANUP
$	SET ON
$	SITE_BLOCKS = DTR$SITE_BLOCKS
$	DELETE /SYMBOL /GLOBAL DTR$SITE_BLOCKS
$	IF SITE_BLOCKS .LE. F$GETDVI ("SYS$DISK", "FREEBLOCKS") THEN GOTO DTR$RESTORE
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "Only ''F$GETDVI("SYS$DISK","FREEBLOCKS")' of the ''SITE_BLOCKS' blocks necessary to restore the original"
$	WRITE SYS$OUTPUT "tailored software configuration are available on ''F$LOGICAL("SYS$SYSDEVICE")'.  The"
$	WRITE SYS$OUTPUT "saved configuration has been recorded in the group ""SITE"" and may"
$	WRITE SYS$OUTPUT "be manually restored after sufficient disk space has been freed."
$	WRITE SYS$OUTPUT ""
$	GOTO DTR$RETAILOR_FINISH
$
$ DTR$RESTORE:
$	WRITE SYS$OUTPUT ""
$	WRITE SYS$OUTPUT "Restoring tailored software configuration"
$	VMS$TAILOR COPY SITE
$
$ DTR$RETAILOR_FINISH:
$	DTR$STATUS = 1
$	$X = F$LOGICAL ("LIB$SYSDEVICE")
$	VMS$TAILOR DISMOUNT
$	VMS$TAILOR MOUNT '$X
$	GOTO DTR$CLEANUP
$
$ DTR$CLEANUP:
$	SET NOON
$	EXIT (DTR$STATUS .OR. STS$M_INHIB_MSG)
$
$ DTR$CONTROL_Y:
$	EXIT (2 .OR. STS$M_INHIB_MSG)
