$ !
$ !	VMSOPT.COM - Install the OPTIONAL file set to a target VAX/VMS system.
$ !
$ !	Author:  Trudy Matthews			Date: October 6, 1981
$ !
$ ! FUNCTIONAL DESCRIPTION:
$ !	This command procedure is invoked by VMSINSTAL.COM to install the
$ !	OPTIONAL VAX/VMS Release 3 file set to a target VAX/VMS system or
$ !	library disk.
$ !
$ ! INPUTS:
$ !	P1 -	Kit.  The device which contains the saveset VMS300OPT.
$ !		The kit device is assumed on line and mounted.
$ !
$ !	TARGET -
$ !		This command procedure will prompt for the target device to
$ !		which the optional file set should be restored.
$ !		If this device is not already mounted, the command procedure
$ !		will mount it.
$ !
$ ! OUTPUTS:
$ !	The VMS300OPT saveset is restored to the specified target disk.
$ !
$ !	VOLPRO privilege is assumed.
$ !
$
$	P1 = P1 - ":"
$	STATUS = -
"   OPTIONAL file set installation aborted. Please restart installation."
$100:
$	INQUIRE TARGET -
"Enter device to which optional saveset should be restored (DDCU)"
$	IF TARGET .EQS. "" THEN GOTO 100
$	TARGET = TARGET - ":"
$	ON WARNING THEN CONTINUE
$	IF F$GETDVI(TARGET,"MNT") THEN GOTO TARGET_MOUNTED
$	ON ERROR THEN GOTO 100
$	MOUNT/OV=ID 'TARGET'
$
$TARGET_MOUNTED:
$	ON ERROR THEN GOTO EXIT
$ !
$ ! Restore the optional files.  Use /REPLACE for restartability.
$ !
$	WRITE SYS$OUTPUT "Restoring optional files."
$	BACKUP /REPLACE /VERIFY -
		'P1':[000000]OPTIONAL /SAVESET  -
		'TARGET':[*...]
$	STATUS = "OPTIONAL file set restoration complete."
$
$EXIT:
$	WRITE SYS$OUTPUT STATUS
$	EXIT
