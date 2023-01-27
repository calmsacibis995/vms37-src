$ !
$ !	MEDIACOPY.COM -- General-purpose files-11 media copy procedure.
$ !
$ !		For Version 3.0 of VAX/VMS, this procedure can
$ !		be used to copy installation/upgrade disk/magtape kits and
$ !		stand-alone BACKUP floppies and cassettes.
$ !
$ ON CONTROL_Y THEN GOTO FINISH
$ ON ERROR THEN GOTO FINISH
$ WRITE SYS$OUTPUT ""
$ WRITE SYS$OUTPUT "	Copy distribution kits  (VOLPRO privilege required)."
$ WRITE SYS$OUTPUT ""
$ SET PROC/PRIV=VOLPRO
$GET_SOURCE:
$ INQUIRE SOURCE "Enter drive holding the write-locked master kit (DDCU)"
$ IF SOURCE .EQS. "" THEN GOTO GET_SOURCE
$ IF F$LOCATE(":",SOURCE) .EQ. F$LENGTH(SOURCE) THEN SOURCE := 'SOURCE':
$
$GET_TARGET:
$ INQUIRE TARGET "Enter drive holding the write-enabled target kit (DDCU)"
$ IF TARGET .EQS. "" THEN GOTO GET_TARGET
$ IF F$LOCATE(":",TARGET) .EQ. F$LENGTH(TARGET) THEN TARGET := 'TARGET':
$
$ KIT_TYPE := 'F$EXTRACT(0,1,SOURCE)
$
$COPY_KIT:
$ MOUNT /OVER=ID 'SOURCE'
$AGAIN:
$ INQUIRE ANSWER "Is the target, ''TARGET', ready to be initialized? (Y/N)"
$ IF (ANSWER .EQS. "") THEN GOTO AGAIN
$ IF .NOT. ANSWER THEN GOTO AGAIN
$ INIT 'TARGET' VMS300
$ IF (KIT_TYPE .EQS. "M") THEN GOTO TAPE_COPY
$ MOUNT/FOREIGN 'TARGET'
$ BACKUP/IMAGE 'SOURCE' 'TARGET'
$ GOTO COPY_DONE
$TAPE_COPY:
$ MOUNT/OVER=ID 'TARGET'
$ COPY 'SOURCE'*.* 'TARGET'*/LOG
$
$COPY_DONE:
$ DISMOUNT 'TARGET'
$
$ WRITE SYS$OUTPUT "Kit copy is complete."
$ INQUIRE ANSWER "Do you want to make another copy of the master kit?"
$ IF .NOT. ANSWER THEN GOTO FINISH
$ WRITE SYS$OUTPUT "Please place a new kit in the target drive, ''TARGET'."
$ DISMOUNT/NOUNLOAD 'SOURCE'
$ GOTO COPY_KIT
$
$FINISH:
$ DISMOUNT 'SOURCE'
$ SET PROC/PRIV=NOVOLPRO
