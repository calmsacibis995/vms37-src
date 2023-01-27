$ V='F$VERIFY(0)'
$ !
$ ! This command procedure creates the master source kit tapes.  It accepts the
$ ! following parameters:
$ !
$ !	P1 -	the device on which the source master pack resides
$ !
$ !	P2 -	the device on which the tape are to be mounted
$ !
$ !	P3 -	the name of the file to drive the create (the default
$ !		is [SYSBLDCOM]VMWNEWBLD.DAT)
$ !
$ !	P4 -	create options:
$ !				blank - nothing special
$ !				CONFIRM - confirm after each save set
$ !
$ !	P5 -	the name of the first facility to backup along with the label
$ !		to use when the tape is mounted
$ !
$ ! In addition this command procedure looks for the group logical name
$ ! STOP_SRCKIT.  If this logical name is found (it is not null) the source
$ ! kit build is aborted.
$ !
$ SET NOON
$ BATCH:="FALSE"
$ IF "''F$MODE()'".EQS."BATCH" THEN $ BATCH:="TRUE"
$ TAPE_NAME:="VMSRC1"
$ FIRST_FACILITY:=""
$ !
$ ! Get the source master device.
$ !
$GET_MASTER:
$ IF P1.NES."" THEN $ GOTO GOT_MASTER
$ IF BATCH THEN $ EXIT
$ INQUIRE P1 "On what device is the source master pack"
$ GOTO GET_MASTER
$GOT_MASTER:
$ IF 'F$LOCATE(":",P1)'.GE.'F$LENGTH(P1)' THEN $ P1:='P1':
$ SRC_MASTER:='P1'
$ !
$ ! Get the name of the output magtape device.
$ !
$GET_TAPE:
$ IF P2.NES."" THEN $ GOTO GOT_TAPE
$ IF BATCH THEN $ EXIT
$ INQUIRE P2 "On what device are the output tapes to be mounted"
$ GOTO GET_TAPE
$GOT_TAPE:
$ IF 'F$LOCATE(":",P2)'.GE.'F$LENGTH(P2)' THEN $ P2:='P2':
$ TAPE_DRIVE:='P2'
$ !
$ ! Get the name of the controlling data file.
$ !
$ BUILD_FILE:='SRC_MASTER'"[SYSBLDCOM]VMSNEWBLD.DAT"
$ IF P3.NES."" THEN $ BUILD_FILE:='P3'
$ !
$ ! Get any additional create options.
$ !
$ CONFIRM:="FALSE"
$ IF P4.EQS."" THEN $ GOTO NO_OPTIONS
$ IF 'F$LOCATE("CONFIRM",P4)'.LT.'F$LENGTH(P4)' THEN $ CONFIRM:="TRUE"
$ IF .NOT.BATCH.AND.CONFIRM THEN $ GOTO NO_OPTIONS
$ WRITE SYS$OUTPUT "%CREATEKIT-E-NOTINBATCH, CONFIRM option illegal in batch"
$ EXIT
$NO_OPTIONS:
$ !
$ ! See if there is an initial facility specified.
$ !
$ IF P5.EQS."" THEN $ GOTO MOUNT_TAPE
$ LOCOMA='F$LOCATE(",",P5)'
$ IF LOCOMA.LT.'F$LENGTH(P5)' THEN $ GOTO GET_FIRST
$ WRITE SYS$OUTPUT "%CREATEKIT-E-BADFIRST, bad parameter format for first facility"
$ EXIT
$GET_FIRST:
$ FIRST_FACILITY:='F$EXTRACT(0,LOCOMA,P5)'
$ TAPE_NAME:='F$EXTRACT(LOCOMA+1,999,P5)'
$MOUNT_TAPE:
$ !
$ ! Mount the tape and create the initial save set.
$ !
$ ALLOCATE 'TAPE_DRIVE'
$ MOUNT/FOREIGN/DENSITY=1600 'TAPE_DRIVE' 'TAPE_NAME'
$ SRC_MOUNTED:="TRUE"
$ IF "''F$GETDVI(SRC_MASTER,"MNT")'" THEN $ GOTO SRC_MOUNTED
$ SRC_MOUNTED:="FALSE"
$ ALLOCATE 'SRC_MASTER'
$ MOUNT 'SRC_MASTER' V3AMASTER
$SRC_MOUNTED:
$ IF FIRST_FACILITY.EQS."" THEN $ GOTO SAVE_INITIAL
$ OPEN/READ BLDFIL 'BUILD_FILE'
$ REW_IND:="REWIND"
$ GOTO NEXT_FACILITY
$SAVE_INITIAL:
$ !
$ ! Initial save set consists of the [SYSBLDCOM] command files necessary for
$ ! the VMS build and the necessary files (assemblers, compilers, etc.) from
$ ! [SYSEXE].  As well as a few miscellaneous files.
$ !
$ FACILITY:="SYSBLDCOM,SYSEXE"
$ COPY/PROTECTION=O:RWED 'SRC_MASTER'[UTIL32.SRC]SETUSER.B32 'SRC_MASTER'[SYSBLDCOM]
$ COPY/PROTECTION=O:RWED WRKD$:[FOLKLORE]SDL.CLD 'SRC_MASTER'[SYSBLDCOM]
$ BACKUP/DENSITY=1600/LABEL='TAPE_NAME'/INTERCHANGE -
	'SRC_MASTER'[SYS.SRC]VERSION.MAR;,-
	'SRC_MASTER'[SYSBLDCOM]*.*;,-
	'SRC_MASTER'[SYSEXE]*.*; 'TAPE_DRIVE'SYSBLDCOM
$ DELETE 'SRC_MASTER'[SYSBLDCOM]SETUSER.B32;,SDL.CLD;
$ WRITE SYS$OUTPUT "%CREATEKIT-S-SAVEDONE, ",FACILITY," save set complete"
$ !
$ ! The second save set consists of all the object libraries from [SYSOBJ] to
$ ! aid the user is doing a build of a single facility without having to first
$ ! build the entire system (it also includes [SHRLIB]).
$ !
$ RESD:="RESD$:"
$ IF "''F$LOGICAL("RESD$")'".NES."" THEN $ GOTO SAVE_SYSOBJ
$ IF .NOT.BATCH THEN $ GOTO GET_RESD
$ WRITE SYS$OUTPUT "%CREATEKIT-E-NORESD, result device name RESD$ not available"
$ EXIT
$GET_RESD:
$ INQUIRE ANS "On which device is the result desk mounted"
$ IF ANS.EQS."" THEN $ GOTO GET_RESD
$ IF 'F$LOCATE(":",ANS)'.GE.'F$LENGTH(ANS)' THEN $ ANS:='ANS':
$ RESD:='ANS'
$SAVE_SYSOBJ:
$ FACILITY:="SYSOBJ"
$ COPY/PROTECTION=O:RWED RESD$:[SYSLIB]SYSBLDLIB.OLB 'SRC_MASTER'[SYSBLDCOM]
$ BACKUP/DENSITY=1600/NOREWIND/LABEL='TAPE_NAME'/INTERCHANGE -
	'RESD'[SHRLIB]*.*;,-
	'SRC_MASTER'[SYSBLDCOM]SYSBLDLIB.OLB;,-
	'RESD'[SYSOBJ]*.*; 'TAPE_DRIVE'SYSOBJ
$ DELETE 'SRC_MASTER'[SYSBLDCOM]SYSBLDLIB.OLB;
$ WRITE SYS$OUTPUT "%CREATEKIT-S-SAVEDONE, ",FACILITY," save set complete"
$ !
$ ! Save other miscellaneous directories.
$ !
$ FACILITY:="SYSTEM"
$ BACKUP/DENSITY=1600/NOREWIND/LABEL='TAPE_NAME'/INTERCHANGE -
	'SRC_MASTER'[SYSHLP...]*.*;,-
	'SRC_MASTER'[SYSLIB]*.*;,-
	'SRC_MASTER'[SYSMGR]*.*;,-
	'SRC_MASTER'[SYSMSG]*.*;,-
	'SRC_MASTER'[SYSOBJ]*.*;,-
	'SRC_MASTER'[SYSUPD]*.*; 'TAPE_DRIVE'SYSTEM
$ WRITE SYS$OUTPUT "%CREATEKIT-S-SAVEDONE, ",FACILITY," save set complete"
$ !
$ ! Save the updates made after code freeze.
$ !
$ FACILITY:="UPDATES"
$ BACKUP/DENSITY=1600/NOREWIND/LABEL='TAPE_NAME'/INTERCHANGE -
	'SRC_MASTER'[UPDATE.V300]*.*; 'TAPE_DRIVE'UPDATES
$ WRITE SYS$OUTPUT "%CREATEKIT-S-SAVEDONE, ",FACILITY," save set complete"
$ !
$ ! Save the console files.
$ !
$ FACILITY:="CONSOLE"
$ BACKUP/DENSITY=1600/NOREWIND/LABEL='TAPE_NAME'/INTERCHANGE -
	'SRC_MASTER'[CONSOLE...]*.*; 'TAPE_DRIVE'CONSOLE
$ !
$ ! Open the control file for use.
$ !
$ OPEN/READ BLDFIL 'BUILD_FILE'
$ GOTO END_OF_SAVESET
$NEXT_FACILITY:
$ IF "''F$LOGICAL("STOP_SRCKIT")'".NES."" THEN $ GOTO ABORT
$ READ/END_OF_FILE=ALL_DONE BLDFIL RECORD
$ IF "''F$EXTRACT(0,1,RECORD)'".EQS."!" THEN $ GOTO NEXT_FACILITY
$ T1='F$LOCATE("	",RECORD)'
$ FACILITY:='F$EXTRACT(0,T1,RECORD)'
$ IF FIRST_FACILITY.NES."".AND.FACILITY.NES.FIRST_FACILITY THEN $ GOTO NEXT_FACILITY
$ FIRST_FACILITY:=""
$ T1='F$LOCATE("/TAPE=",RECORD)'+6
$ IF T1.LT.'F$LENGTH(RECORD)' THEN $ GOTO FILE_OK
$ WRITE SYS$OUTPUT "%CREATEKIT-E-BADVERSION, incorrect version of ",BUILD_FILE
$ WRITE SYS$OUTPUT "-CREATEKIT-I-NOTAPENUM, /TAPE option not given"
$ GOTO ALL_DONE
$FILE_OK:
$ TAPE:="VMSRC"'F$EXTRACT(T1,1,RECORD)'
$ IF CONFIRM.OR.TAPE.EQS.TAPE_NAME THEN $ GOTO SAVE_FACILITY
$ DISMOUNT 'TAPE_DRIVE'
$ IF BATCH THEN $ GOTO MOUNT_NEXT
$ WRITE SYS$OUTPUT "%CREATEKIT-I-MNTNEXT, please mount ''TAPE' on ''TAPE_DRIVE'"
$CHECK_REPLY:
$ INQUIRE ANS "Continue (Y/N)"
$ IF .NOT.ANS THEN $ GOTO CHECK_REPLY
$MOUNT_NEXT:
$ TAPE_NAME:='TAPE'
$ MOUNT/FOREIGN/DENSITY=1600 'TAPE_DRIVE' 'TAPE_NAME'
$ REW_IND:="REWIND"
$SAVE_FACILITY:
$ BACKUP/DENSITY=1600/'REW_IND'/LABEL='TAPE_NAME'/INTERCHANGE -
	/EXCLUDE=([*.BUGSRC],[*.BUGCOM],[*.BUGCLD]) -
	'SRC_MASTER'['FACILITY'...]*.*; 'TAPE_DRIVE''FACILITY'
$END_OF_SAVESET:
$ REW_IND:="NOREWIND"
$ WRITE SYS$OUTPUT "%CREATEKIT-S-SAVEDONE, ",FACILITY," save set complete"
$ IF .NOT.CONFIRM THEN $ GOTO NEXT_FACILITY
$GET_ANSWER:
$ INQUIRE ANS "Continue (Y/N/L)"
$ IF ANS.EQS."" THEN $ GOTO GET_ANSWER
$ IF "''F$EXTRACT(0,1,ANS)'".NES."L" THEN $ GOTO CHECK_ANSWER
$ DISMOUNT 'TAPE_DRIVE'
$GET_LABEL:
$ INQUIRE TAPE_NAME "What is the label to use on the new tape"
$ IF TAPE_NAME.EQS."" THEN $ GOTO GET_LABEL
$GOT_LABEL:
$ MOUNT/FOREIGN/DENSITY=1600 'TAPE_DRIVE' 'TAPE_NAME'
$ REW_IND:="REWIND"
$ GOTO NEXT_FACILITY
$CHECK_ANSWER:
$ IF ANS THEN $ GOTO NEXT_FACILITY
$ GOTO GET_ANSWER
$ !
$ ! Control is transferred here if the source kit build is aborted.
$ !
$ABORT:
$ WRITE SYS$OUTPUT "%CREATEKIT-W-ABORT, magtape source kit build aborted."
$ GOTO CLEAN_UP
$ !
$ ! Here when the source master tapes are complete.
$ !
$ALL_DONE:
$ CLOSE BLDFIL
$ WRITE SYS$OUTPUT "%CREATEKIT-S-COMPLETE, magtape source kit build complete."
$CLEAN_UP:
$ IF "''F$LOGICAL("STOP_SRCKIT")'".NES."" THEN $ DEASSIGN/GROUP STOP_SRCKIT
$ IF .NOT.SRC_MOUNTED THEN $ DISMOUNT/NOUNLOAD 'SRC_MASTER'
$ DISMOUNT/NOUNLOAD 'TAPE_DRIVE'
$ IF V THEN $ SET VERIFY
