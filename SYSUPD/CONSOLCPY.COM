$ !
$ !	CONSOLCOPY.COM -- Copy floppy or tu58 console media.
$ !
$ WRITE SYS$OUTPUT "	Copy floppy or tu58 console media."
$ WRITE SYS$OUTPUT ""
$
$GET_SOURCE:
$ INQUIRE SOURCE "Enter drive holding the master console (DDCU)"
$ IF SOURCE .EQS. "" THEN GOTO GET_SOURCE
$ IF F$LOCATE(":",SOURCE) .EQ. F$LENGTH(SOURCE) THEN SOURCE := 'SOURCE':
$ MOUNT/FOREIGN 'SOURCE'
$
$GET_TARGET:
$ INQUIRE TARGET "Enter drive holding the target console media (DDCU)"
$ IF TARGET .EQS. "" THEN GOTO GET_TARGET
$ IF F$LOCATE(":",TARGET) .EQ. F$LENGTH(TARGET) THEN TARGET := 'TARGET':
$
$COPY_CONSOLE:
$ INIT 'TARGET' CONSOLE
$ MOUNT/FOREIGN 'TARGET'
$ BACKUP/PHYSICAL 'SOURCE' 'TARGET'
$ DISMOUNT 'TARGET'
$
$ WRITE SYS$OUTPUT "Console copy is complete."
$ INQUIRE ANSWER "Do you want to make another copy of the master console?"
$ IF .NOT. ANSWER THEN GOTO FINISH
$ WRITE SYS$OUTPUT -
"Please place a new console media in the target drive, ''TARGET',"
$ INQUIRE ANSWER "and press <RETURN> when ready"
$ GOTO COPY_CONSOLE
$
$FINISH:
$ DISMOUNT 'SOURCE'
