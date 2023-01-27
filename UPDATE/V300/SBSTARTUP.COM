$ !
$ ! SBSTARTUP.COM -- system startup file to handle system build specific
$ ! startup functions. Mount the master pack and result disks, if they
$ ! are not already mounted, and restart the system build if one was in
$ ! progress.
$ !
$ SET NOON
$ UIC := 'F$USER()'
$ DIR := 'F$DIRECTORY()'
$ SETUSER := $SETUSER
$ SETUSER SYSTEMBUILD
$ SET UIC [11,177]
$ RESTART = 1
$ DEFINE/GROUP WRKD$ XXXX
$ DEFINE/GROUP MASD$ YYYY
$ !
$ ! If the master device in on the UDA, it is necessary to wait about 30
$ ! seconds to all the devices to appear.
$ !
$ MASTER_DEV:='F$LOGICAL("MASD$")'
$ IF "''F$EXTRACT(0,2,MASTER_DEV)'".EQS."DU" THEN $ WAIT 00:00:30
$ !
$ IF .NOT."''F$GETDVI("MASD$:","MNT")'" THEN $ MOUNT /GROUP /ACCESS=12 MASD$: VMSMASTER 
$ IF .NOT. $STATUS THEN RESTART = 0
$ !
$ ! *** Following area is edited by VMSGEN.COM
$ ! *** Mount the current result disk
$ ! *** End of edited area
$ !
$ !
$ ! Start the sysstem build batch queue
$ !
$ START/QUE/JOB=7 SYS$BUILD
$ IF $STATUS THEN GOTO STARTED
$ INIT/QUE/BATCH/JOB=7 SYS$BUILD
$ START/QUE SYS$BUILD
$STARTED:
$ !
$ ! If a restartable build was in progress, restart it.
$ !
$ IF .NOT. RESTART THEN GOTO NORESTART
$ OPEN /ERROR=NORESTART FILE WRKD$:[SYSBLDCOM]VMSACTBLD.COM
$ CLOSE FILE
$ @WRKD$:[SYSBLDCOM]VMSACTBLD
$NORESTART:
$ !
$ SET UIC 'UIC'
$ SET DEFAULT 'DIR'
$ SETUSER SYSTEM
