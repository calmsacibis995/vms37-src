$ V='F$VERIFY(0)'
$ !
$ ! This command procedure restores one or more facilities from the source
$ ! tapes.  It accepts the following parameters:
$ !
$ !	P1 -	the tape drive to use for the restore operation
$ !
$ !	P2 -	the device on which the facilities should be placed
$ !
$ !	P3 -	the facility or facilities to restore (multiple facility
$ !		name must be separated by a comma; the keyword ALL restores
$ !		all the facilities for a complete copy of the source master
$ !		pack).
$ !
$ !	P4 -	the name of the file to drive the restore of the components
$ !		(the default is [SYSBLDCOM]VMSNEWBLD.DAT)
$ !
$ !	P5 -	the name of the first facility to restore if this is finishing
$ !		a partial restore
$ !
$ BATCH:="FALSE"
$ IF "''F$MODE()'".EQS."BATCH" THEN $ BATCH:="TRUE"
$ CLEANUP=0
$ FIRST_FACILITY:=""
$ !
$ ! Get the device name to use for the restore operation.
$ !
$GET_DRIVE:
$ IF P1.NES."" THEN $ GOTO GOT_DRIVE
$ IF BATCH THEN $ EXIT
$ INQUIRE P1 "What tape drive is to be used for the restore operation"
$ GOTO GET_DRIVE
$GOT_DRIVE:
$ IF 'F$LOCATE(":",P1)'.GE.'F$LENGTH(P1)' THEN $ P1:='P1':
$ TAPE_DRIVE:='P1'
$ P1:=""
$ ON WARNING THEN $ GOTO GET_DRIVE
$ ALLOCATE 'TAPE_DRIVE'
$ ON WARNING THEN $ CONTINUE
$ !
$ ! Get the output device.
$ !
$GET_DST:
$ IF P2.NES."" THEN $ GOTO GOT_DST
$ IF BATCH THEN $ EXIT
$ INQUIRE P2 "On what disk device should the facilities be placed"
$ GOTO GET_DST
$GOT_DST:
$ IF 'F$LOCATE(":",P2)'.GE.'F$LENGTH(P2)' THEN $ P2:='P2':
$ DST_MASTER:='P2'
$ IF "''F$GETDVI(DST_MASTER,"MNT")'" THEN $ GOTO GET_FACILITY
$ WRITE SYS$OUTPUT "The target disk must be mounted before the restore can continue"
$ EXIT
$ !
$ ! Get the facility or facilities to restore.
$ !
$GET_FACILITY:
$ IF P3.NES."" THEN $ GOTO GOT_FACILITY
$ IF BATCH THEN $ EXIT
$ INQUIRE P3 "What facility or facilities do you want to restore"
$ GOTO GET_FACILITY
$GOT_FACILITY:
$ FACILITY_LIST:='P3',
$ ALL:="FALSE"
$ IF 'F$LOCATE("ALL",P3)'.LT.'F$LENGTH(P3)' THEN $ ALL:="TRUE"
$ !
$ ! Now get the name of the controlling data file.
$ !
$ IF P4.EQS."" THEN $ P4:='DST_MASTER'"[SYSBLDCOM]VMSNEWBLD.DAT"
$ !
$ ! See if this is only a partial restore of the entire list
$ !
$ IF P5.EQS."" THEN $ GOTO NO_PARTIAL
$ FIRST_FACILITY:='P5'
$ BUILD_FILE:='P4'
$ SPECIAL_CASE:="FALSE"
$ TAPE_MOUNTED:=""
$ GOTO START_RESTORE
$ !
$ ! Special case the first four save sets on the source kit tapes by creating
$ ! a temporary control file with the necessary "component" names.
$ !
$NO_PARTIAL:
$ SPECIAL_CASE:="TRUE"
$ OPEN/WRITE SPCASE SYS$LOGIN:SPECASE.DAT
$ WRITE SPCASE "SYSOBJ		/TAPE=1"
$ WRITE SPCASE "SYSTEM		/TAPE=1"
$ WRITE SPCASE "UPDATES		/TAPE=1"
$ WRITE SPCASE "CONSOLE		/TAPE=1"
$ CLOSE SPCASE
$ BUILD_FILE:="SYS$LOGIN:SPECASE.DAT"
$ TAPE_MOUNTED:=""
$ !
$ ! Find the tape which contains the first facility listed and mount it.
$ !
$START_RESTORE:
$ SET DEFAULT 'DST_MASTER'
$ OPEN/READ/ERROR=NO_BUILD_FILE BLDFIL 'BUILD_FILE'
$ CLEANUP=CLEANUP.OR.1
$NEXT_FACILITY:
$ READ/END_OF_FILE=FACILITY_DONE BLDFIL RECORD
$ IF "''F$EXTRACT(0,1,RECORD)'".EQS."!" THEN $ GOTO NEXT_FACILITY
$ T1='F$LOCATE("	",RECORD)'
$ FACILITY:='F$EXTRACT(0,T1,RECORD)'
$ IF FIRST_FACILITY.NES."".AND.FIRST_FACILITY.NES.FACILITY THEN $ GOTO NEXT_FACILITY
$ FIRST_FACILITY:=""
$ IF ALL THEN $ GOTO DO_ALL
$ T2='F$LOCATE(FACILITY,FACILITY_LIST)'
$ IF T2.GE.'F$LENGTH(FACILITY_LIST)' THEN $ GOTO NEXT_FACILITY
$ !
$ ! The correct facility record has been found.  Now get the tape number.
$ !
$DO_ALL:
$ T1='F$LOCATE("/TAPE=",RECORD)'+6
$ TAPE_NAME:="VMSRC"'F$EXTRACT(T1,1,RECORD)'
$ IF TAPE_NAME.EQS.TAPE_MOUNTED THEN $ GOTO MOUNTED
$ IF TAPE_MOUNTED.NES."" THEN $ DISMOUNT 'TAPE_DRIVE'
$ MOUNT/FOREIGN 'TAPE_DRIVE' 'TAPE_NAME'
$ TAPE_MOUNTED:='TAPE_NAME'
$MOUNTED:
$ IF SPECIAL_CASE THEN $ GOTO DO_RESTORE
$ SET DEFAULT ['FACILITY']
$ @'DST_MASTER'[SYSBLDCOM]CREATEDIR MASTER
$DO_RESTORE:
$ BACKUP/NOREWIND 'TAPE_DRIVE''FACILITY' [*...]/OWNER=ORIGINAL/NEW_VERSION
$ WRITE SYS$OUTPUT "%RESTORE-S-COMPLETE, facility ",FACILITY," restored"
$ IF ALL THEN $ GOTO NEXT_FACILITY
$REMOVE_FACILITY:
$ T3=T2+'F$LENGTH(FACILITY)'+1
$ T4='F$LENGTH(FACILITY_LIST)'-T3
$ FIRST:=""
$ IF T2.GT.0 THEN $ FIRST:='F$EXTRACT(0,T2,FACILITY_LIST)'
$ LAST:=""
$ IF T4.GT.0 THEN $ LAST:='F$EXTRACT(T3,T4,FACILITY_LIST)'
$ FACILITY_LIST:='FIRST''LAST'
$ IF FACILITY_LIST.NES."" THEN $ GOTO NEXT_FACILITY
$ !
$ ! At this point all the entries in the control file have been processed.
$ ! If this is the initial special case and there is more to do, do it.
$ ! Otherwise I'm done.
$ !
$FACILITY_DONE:
$ IF .NOT.SPECIAL_CASE.OR.FACILITY_LIST.EQS."" THEN $ GOTO CLEAN_UP
$ SPECIAL_CASE:="FALSE"
$ CLOSE BLDFIL
$ BUILD_FILE:='P4'
$ GOTO START_RESTORE
$CLEAN_UP:
$ IF TAPE_MOUNTED.NES."" THEN $ DISMOUNT 'TAPE_DRIVE'
$ DELETE SYS$LOGIN:SPECASE.DAT;
$ IF (CLEANUP.AND.1).NE.0 THEN $ CLOSE BLDFIL
$ IF FACILITY_LIST.EQS."".OR.ALL THEN $ EXIT
$ WRITE SYS$OUTPUT "%RESTORE-E-REMAIN, facilities remaining to be restored: ",FACILITY_LIST
$ IF V THEN $ SET VERIFY
