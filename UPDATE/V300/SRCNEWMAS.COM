$ V='F$VERIFY(0)'
$ !
$ ! This command procedure creates a copy of the specified master source pack
$ ! on the desired disk device.  It accepts the following parameters to control
$ ! the various operations:
$ !
$ !	P1 -	the device on which the source master pack resides
$ !		(required)
$ !
$ !	P2 -	the device on which the target master pack is to be built
$ !		(required)
$ !
$ !	P3 -	the label of the target master pack (default is VMSMASTER)
$ !
$ !	P4 -	the name of the file to control the structure of the target
$ !		master pack (the default is [SYSBLDCOM]VMSNEWBLD.DAT.
$ !
$ !	P5 -	the source of the update packets (ENH or BUG)
$ !		(required)
$ !
$ !	P6 -	the name of the facility to start copying (this is for a partial
$ !		copy operation).
$ !
$ !	P7 -	misc. options to control various internal choices.  Currently
$ !		the only option is LOG to control the logging of various
$ !		operations (directory creations, file copies, etc.).
$ !
$ ! In addition to the above parameters, this command procedure also looks for
$ ! the logical name STOP_MERGE in the group logical name table.  If this
$ ! logical name is defined (it is not null) then the merge is aborted cleanly.
$ !
$ SET NOVERIFY
$ OLD_DEV:='F$LOGICAL("SYS$DISK")'
$ OLD_DIR:='F$DIRECTORY()'
$ OLD_UIC:='F$USER()'
$ CLEANUP=0
$ ON ERROR THEN $ GOTO CLEAN_UP
$ ON SEVERE_ERROR THEN $ GOTO CLEAN_UP
$ ON CONTROL_Y THEN $ GOTO CLEAN_UP
$ ON CONTROL_C THEN $ GOTO CLEAN_UP
$ BATCH:="FALSE"
$ IF "''F$MODE()".EQS."BATCH" THEN BATCH:="TRUE"
$ !
$ ! See if this is a restart of a copy.  If not, create the checkpoint file.
$ ! If it is, read the needed information from the checkpoint file and continue
$ ! from where the job stopped.
$ !
$ RESTART:="FALSE"
$ OPEN/READ/ERROR=NO_CHECK_FILE CHKPNT SYS$LOGIN:NEWMASTER.MKR
$ CLEANUP=CLEANUP.OR.512
$ READ CHKPNT FACILITY
$ READ CHKPNT OPERATION
$ READ CHKPNT RESTART_FIL
$ READ CHKPNT RESTART_DIR
$ READ CHKPNT CLEANUP
$ CLOSE CHKPNT
$ CLEANUP=(CLEANUP.OR.128.OR.256).AND.(.NOT.512)
$ IF OPERATION.NES."" THEN $ RESTART:="TRUE"
$ GOTO GET_SRC
$NO_CHECK_FILE:
$ OPEN/WRITE CHKPNT SYS$LOGIN:NEWMASTER.MKR
$ CLEANUP=CLEANUP.OR.256.OR.512
$ WRITE CHKPNT ""
$ WRITE CHKPNT ""
$ WRITE CHKPNT ""
$ WRITE CHKPNT ""
$ WRITE CHKPNT ""
$ CLOSE CHKPNT
$ CLEANUP=CLEANUP.AND.(.NOT.512)
$ RESTART_DIR:=""
$ RESTART_FIL:=""
$ OPEN/WRITE CHKPNT SYS$LOGIN:UPDATEMKR.COM
$ CLEANUP=CLEANUP.OR.128.OR.512
$ WRITE CHKPNT "$ VERIFY='F$VERIFY(0)'"
$ WRITE CHKPNT "$ OPEN/WRITE CHECK SYS$LOGIN:NEWMASTER.MKR
$ WRITE CHKPNT "$ WRITE CHECK P1"
$ WRITE CHKPNT "$ WRITE CHECK P2"
$ WRITE CHKPNT "$ WRITE CHECK P3"
$ WRITE CHKPNT "$ WRITE CHECK P4"
$ WRITE CHKPNT "$ CLOSE CHECK"
$ WRITE CHKPNT "$ PURGE SYS$LOGIN:NEWMASTER.MKR"
$ WRITE CHKPNT "$ IF VERIFY THEN $ SET VERIFY"
$ CLOSE CHKPNT
$ CLEANUP=CLEANUP.AND.(.NOT.512)
$ !
$ ! Get the source master pack device name if not given.
$ !
$GET_SRC:
$ IF P1.NES."" THEN $ GOTO GOT_SRC
$ IF BATCH THEN $ EXIT
$ INQUIRE P1 "What device has the source master pack (ddcn:)"
$ GOTO GET_SRC
$GOT_SRC:
$ IF 'F$LOCATE(":",P1)'.GE.'F$LENGTH(P1)' THEN $ P1:='P1':
$ SRC_MASTER:='P1'
$ !
$ ! Get the target master pack device name if not given.
$ !
$GET_DST:
$ IF P2.NES."" THEN $ GOTO GOT_DST
$ IF BATCH THEN $ EXIT
$ INQUIRE P2 "What device is the target master pack on (ddcn:)"
$ GOTO GET_DST
$GOT_DST:
$ IF 'F$LOCATE(":",P2)'.GE.'F$LENGTH(P2)' THEN $ P2:='P2':
$ DST_MASTER:='P2'
$ P2:=""
$ IF "''F$GETDVI(DST_MASTER,"MNT")'" THEN $ GOTO GET_LABEL
$ ON WARNING THEN $ GOTO GET_DST
$ ALLOCATE 'DST_MASTER'
$ ON WARNING THEN $ CONTINUE
$ !
$ ! Determine the label of the target master pack.
$ !
$GET_LABEL:
$ DST_LABEL:='P3'
$ IF P3.NES."" THEN $ GOTO GOT_LABEL
$ IF .NOT.BATCH THEN $ INQUIRE P3 "Targer master pack label (VMSMASTER)"
$ DST_LABEL:='P3'
$ IF P3.EQS."" THEN $ DST_LABEL:="VMSMASTER"
$GOT_LABEL:
$ !
$ ! Determine the build data file to use.
$ !
$GET_FILE:
$ BUILD_FILE:='P4'
$ IF P4.NES."" THEN $ GOTO CHECK_FILE
$ IF .NOT.BATCH THEN $ INQUIRE P4 "Control data file ([SYSBLDCOM]VMSNEWBLD.DAT)"
$ BUILD_FILE:='P4'
$ IF P4.EQS."" THEN $ BUILD_FILE:='SRC_MASTER'"[SYSBLDCOM]VMSNEWBLD.DAT"
$CHECK_FILE:
$ ON WARNING THEN $ GOTO NO_FILE
$ FIL:='F$SEARCH(BUILD_FILE)'
$ IF FIL.NES."" THEN $ GOTO GOT_FILE
$ WRITE SYS$OUTPUT "%SRCMRG-E-FNF, file not found '",BUILD_FILE,"'"
$NO_FILE:
$ IF BATCH THEN $ EXIT
$ P4:=""
$ GOTO GET_FILE
$GOT_FILE:
$ ON WARNING THEN $ CONTINUE
$ BUILD_FILE:='FIL'
$ !
$ ! Determine the type of master pack copy to do.
$ !
$GET_TYPE:
$ IF P5.EQS."BUG".OR.P5.EQS."ENH" THEN $ GOTO GOT_TYPE
$ IF BATCH THEN $ EXIT
$ INQUIRE P5 "What type of copy operation (BUG or ENH)"
$ GOTO GET_TYPE
$GOT_TYPE:
$ PACKET_DIR:=[.'P5']
$ IGNORE_TYPE:="BUG"
$ IF P5.EQS."BUG" THEN $ IGNORE_TYPE:="ENH"
$ !
$ ! See if this is a partial copy operation
$ !
$ FIRST_FACILITY:=""
$ IF P6.NES."" THEN $ FIRST_FACILITY:='P6'
$ !
$ ! Check for any options.
$ !
$ LOGGING:=""
$ IF 'F$LOCATE("LOG",P7)'.LT.'F$LENGTH(P7)' THEN $ LOGGING:="/LOG"
$ !
$ SET UIC [11,177]
$ !
$ ! See if this is a restarted operation.
$ !
$ IF RESTART THEN $ FIRST_FACILITY:='FACILITY'
$ !
$ ! Initialize the target master pack.
$ !
$ IF FIRST_FACILITY.NES."" THEN $ GOTO JUST_MOUNT
$ IF BATCH THEN $ GOTO INIT_NOCHECK
$ WRITE SYS$OUTPUT "It is necessary to initialize the target disk ",DST_MASTER
$INIT_CHECK:
$ INQUIRE ANSWER "Continue (Y/N)"
$ IF ANSWER.EQS."" THEN $ GOTO INIT_CHECK
$ IF .NOT.ANSWER THEN $ EXIT
$INIT_NOCHECK:
$ IF "''F$GETDVI(DST_MASTER,"MNT")'" THEN $ DISMOUNT/NOUNLOAD 'DST_MASTER'
$ INITIALIZE/GROUP 'DST_MASTER' 'DST_LABEL'
$JUST_MOUNT:
$ IF "''F$GETDVI(DST_MASTER,"MNT")'" THEN $ GOTO DST_MOUNTED
$ MOUNT/GROUP 'DST_MASTER' 'DST_LABEL'
$DST_MOUNTED:
$ !
$ ! Create a few miscellaneous directories.
$ !
$ ! Because these directories are wired in. It is essential that the following
$ ! directories created parallel those on the source master pack.
$ !
$ IF FIRST_FACILITY.NES."" THEN $ GOTO START_COPY
$ OPEN/WRITE CREFIL CREATCOPY.COM
$ CLEANUP=CLEANUP.OR.32.OR.64
$ WRITE CREFIL "$ VERIFY='F$VERIFY(0)'"
$ WRITE CREFIL "$ SET NOON"
$ WRITE CREFIL "$ CREATE/DIRECTORY",LOGGING,"/OWNER=[11,177] ",DST_MASTER,"'P1'"
$ WRITE CREFIL "$ COPY",LOGGING,"/PROTECTION=(S:R,O:RW,G:R,W) ",SRC_MASTER,"'P1'*.*; ",DST_MASTER,"'P1'*.*;1"
$ WRITE CREFIL "$ SET ON"
$ WRITE CREFIL "$ IF VERIFY THEN $ SET VERIFY"
$ CLOSE CREFIL
$ CLEANUP=CLEANUP.AND.(.NOT.64)
$ @CREATCOPY [CONSOLE.730]
$ @CREATCOPY [CONSOLE.750]
$ @CREATCOPY [CONSOLE.780]
$ @CREATCOPY [SYSBLDCOM]
$ CREATE/DIRECTORY'LOGGING'/OWNER=[11,177] 'DST_MASTER'[SYSERR]
$ @CREATCOPY [SYSEXE]
$ @CREATCOPY [SYSHLP]
$ @CREATCOPY [SYSHLP.EXAMPLES]
$ @CREATCOPY [SYSLIB]
$ SET FILE/ENTER='DST_MASTER'[0,0]001001.DIR 'DST_MASTER'[0,0]SYSLIB.DIR
$ @CREATCOPY [SYSMGR]
$ @CREATCOPY [SYSMSG]
$ SET FILE/ENTER='DST_MASTER'[0,0]001002.DIR 'DST_MASTER'[0,0]SYSMSG.DIR
$ @CREATCOPY [SYSOBJ]
$ @CREATCOPY [SYSUPD]
$ DELETE CREATCOPY.COM;
$ CLEANUP=CLEANUP.AND.(.NOT.32)
$ !
$ ! Copy the current versions of the language compilers necessary to do
$ ! the system build.
$ !
$ COPY'LOGGING'/PROTECTION=(S:R,O:RW,G:R,W) SYS$SYSTEM:BLISS16.EXE 'DST_MASTER'[SYSEXE]BLISS16.EXE;1
$ COPY'LOGGING'/PROTECTION=(S:R,O:RW,G:R,W) SYS$SYSTEM:BLISS32.EXE 'DST_MASTER'[SYSEXE]BLISS32.EXE;1
$ COPY'LOGGING'/PROTECTION=(S:R,O:RW,G:R,W) SYS$SYSTEM:FORTRAN.EXE 'DST_MASTER'[SYSEXE]FORTRAN.EXE;1
$ COPY'LOGGING'/PROTECTION=(S:R,O:RW,G:R,W) SYS$SYSTEM:MARBLI.EXE 'DST_MASTER'[SYSEXE]MARBLI.EXE;1
$ COPY'LOGGING'/PROTECTION=(S:R,O:RW,G:R,W) SYS$SYSTEM:MDL.EXE 'DST_MASTER'[SYSEXE]MDL.EXE;1
$ COPY'LOGGING'/PROTECTION=(S:R,O:RW,G:R,W) SYS$SYSTEM:PASCAL.EXE 'DST_MASTER'[SYSEXE]PASCAL.EXE;1
$ COPY'LOGGING'/PROTECTION=(S:R,O:RW,G:R,W) SYS$SYSTEM:PLIG.EXE 'DST_MASTER'[SYSEXE]PLIG.EXE;1
$ COPY'LOGGING'/PROTECTION=(S:R,O:RW,G:R,W) SYS$SYSTEM:SDL.EXE 'DST_MASTER'[SYSEXE]SDL.EXE;1
$ COPY'LOGGING'/PROTECTION=(S:R,O:RW,G:R,W) SYS$SYSTEM:CVTMSG.EXE 'DST_MASTER'[SYSEXE]CVTMSG.EXE;1
$ COPY'LOGGING'/PROTECTION=(S:R,O:RW,G:R,W) SYS$SYSTEM:CVTMSG.COM 'DST_MASTER'[SYSEXE]CVTMSG.COM;1
$ !
$ ! Create the main directory and all needed sub-directories for all the
$ ! facilities specified in the control data file.
$ !
$START_COPY:
$ SET DEFAULT 'DST_MASTER'
$ OPEN/READ BLDFIL 'BUILD_FILE'
$ CLEANUP=CLEANUP.OR.1
$NEXT_RECORD:
$ IF "''F$LOGICAL("STOP_MERGE")'".NES."" THEN $ GOTO CLEAN_UP
$ READ/END_OF_FILE=FACILITY_DONE BLDFIL RECORD
$ IF "''F$EXTRACT(0,1,RECORD)'".EQS."!" THEN $ GOTO NEXT_RECORD
$ T1='F$LOCATE("	",RECORD)'
$ FACILITY:='F$EXTRACT(0,T1,RECORD)'
$ IF FIRST_FACILITY.NES."".AND.FIRST_FACILITY.NES.FACILITY THEN $ GOTO NEXT_RECORD
$ FIRST_FACILITY:=""
$ SET DEFAULT ['FACILITY']
$ IF RESTART THEN $ GOTO 'OPERATION'
$CREATE_DIR:
$ @SYS$LOGIN:UPDATEMKR 'FACILITY' CREATE_DIR "" ""
$ @'SRC_MASTER'[SYSBLDCOM]CREATEDIR MASTER
$ !
$ ! At this point all the necessary directories and sub-directories have
$ ! have been created for a specific facility.  It is now necessary to copy
$ ! all the files for the facility from the original master pack to the new
$ ! master pack applying any update packets found in the desired packet
$ ! sub-directory.
$ !
$ DIRECTORY/NOHEADING/OUTPUT=DIRFILE.DAT [...]*.DIR;
$ CLEANUP=CLEANUP.OR.2
$COPY_MASTER:
$ @SYS$LOGIN:UPDATEMKR 'FACILITY' COPY_MASTER "" ""
$ OPEN/READ DIRFIL DIRFILE.DAT
$ CLEANUP=CLEANUP.OR.4
$NEXT_DIR_COPY:
$ IF "''F$LOGICAL("STOP_MERGE")'".NES."" THEN $ GOTO CLEAN_UP
$ READ/END_OF_FILE=COPY_DONE DIRFIL RECORD
$ T1='F$LOCATE("[",RECORD)'
$ IF T1.GE.'F$LENGTH(RECORD)' THEN $ GOTO NEXT_DIR_COPY
$ T2='F$LOCATE("]",RECORD)'
$ DIR:='F$EXTRACT(T1,T2-T1,RECORD)'
$ T4='F$LENGTH(RECORD)-T2+2
$ RECORD:='F$EXTRACT(T2+1,T4,RECORD)'
$ T1=F$LOCATE(".",RECORD)'
$ FIL:='F$EXTRACT(0,T1,RECORD)'
$ !
$ ! Check to see if this directory should not be copied.
$ !
$ IF IGNORE_TYPE.NES."BUG" THEN $ GOTO CHECK_ENH
$ IF FIL.EQS."BUG".OR.-
     FIL.EQS."BUGCOM".OR.-
     FIL.EQS."BUGSRC" THEN $ GOTO NEXT_DIR_COPY
$ GOTO CHECK_DONE
$CHECK_ENH:
$ IF IGNORE_TYPE.NES."ENH" THEN $ GOTO CHECK_DONE
$ IF FIL.EQS."ENH".OR.-
     FIL.EQS."COM".OR.-
     FIL.EQS."SRC" THEN $ GOTO NEXT_DIR_COPY
$CHECK_DONE:
$ DIR:='DIR'.'FIL']
$ IF RESTART.AND.DIR.NES.RESTART_DIR THEN $ GOTO NEXT_DIR_COPY
$ RESTART:="FALSE"
$ @SYS$LOGIN:UPDATEMKR 'FACILITY' COPY_MASTER "" 'DIR'
$ ON ERROR THEN $ GOTO NEXT_DIR_COPY
$ COPY'LOGGING' 'SRC_MASTER''DIR'*.*; 'DST_MASTER''DIR'*.*;1
$ PURGE 'DST_MASTER''DIR'
$ GOTO NEXT_DIR_COPY
$COPY_DONE:
$ ON ERROR THEN $ GOTO CLEAN_UP
$ CLOSE DIRFIL
$ CLEANUP=CLEANUP.AND.(.NOT.4)
$ DELETE DIRFILE.DAT;
$ CLEANUP=CLEANUP.AND.(.NOT.2)
$ !
$ ! Copy any directories on the source master pack which are not on the
$ ! destination master pack.
$ !
$ DIRECTORY/NOHEAD/OUTPUT=DIRFILE.DAT 'SRC_MASTER'[...]*.DIR;
$ CLEANUP=CLEANUP.OR.2
$COPY_MISC:
$ @SYS$LOGIN:UPDATEMKR 'FACILITY' COPY_MISC "" ""
$ OPEN/READ DIRFIL DIRFILE.DAT
$ CLEANUP=CLEANUP.OR.4
$MISC_DIR_COPY:
$ READ/END=MISC_DONE DIRFIL RECORD
$ T1='F$LOCATE("[",RECORD)'
$ IF T1.GE.'F$LENGTH(RECORD)' THEN $ GOTO MISC_DIR_COPY
$ T2='F$LOCATE("]",RECORD)'
$ DIR:='F$EXTRACT(T1,T2-T1,RECORD)'
$ T3='F$LOCATE(":",RECORD)'
$ CDIRFIL:='F$EXTRACT(T3+1,999,RECORD)'
$ T4='F$LENGTH(RECORD)-T2+2
$ RECORD:='F$EXTRACT(T2+1,T4,RECORD)'
$ T1=F$LOCATE(".",RECORD)'
$ FIL:='F$EXTRACT(0,T1,RECORD)'
$ DIR:='DIR'.'FIL']
$ IF RESTART.AND.DIR.NES.RESTART_DIR THEN $ GOTO MISC_DIR_COPY
$ RESTART:="FALSE"
$ @SYS$LOGIN:UPDATEMKR 'FACILITY' COPY_MISC "" 'DIR'
$ ON ERROR THEN $ GOTO MISC_DIR_COPY
$ IF "''F$SEARCH(CDIRFIL)'".NES."" THEN $ GOTO MISC_DIR_COPY
$ CREATE/DIRECTORY'LOGGING'/OWNER=[11,177] 'DST_MASTER''DIR'
$ COPY'LOGGING' 'SRC_MASTER''DIR'*.*; 'DST_MASTER''DIR'*.*;1
$ PURGE 'DST_MASTER''DIR'
$ GOTO MISC_DIR_COPY
$MISC_DONE:
$ ON ERROR THEN $ GOTO CLEAN_UP
$ CLOSE DIRFIL
$ CLEANUP=CLEANUP.AND.(.NOT.4)
$ DELETE DIRFILE.DAT;
$ CLEANUP=CLEANUP.AND.(.NOT.2)
$ !
$ ! Apply any update packets found in the specified packet directory.
$ !
$ DIRECTORY/NOHEADING/OUTPUT=UPDFILE.DAT 'PACKET_DIR'*.UPD;
$ CLEANUP=CLEANUP.OR.8
$FIND_UPDATES:
$ @SYS$LOGIN:UPDATEMKR 'FACILITY' FIND_UPDATES "" ""
$ OPEN/READ UPDFIL UPDFILE.DAT
$ CLEANUP=CLEANUP.OR.16
$NEXT_UPD_FILE:
$ IF "''F$LOGICAL("STOP_MERGE")'".NES."" THEN $ GOTO CLEAN_UP
$ READ/END_OF_FILE=UPDATE_DONE UPDFIL RECORD
$ T1='F$LOCATE("]",RECORD)'
$ IF T1.GE.'F$LENGTH(RECORD)' THEN $ GOTO NEXT_UPD_FILE
$ T2='F$LENGTH(RECORD)'-T1
$ T1=T1+1
$ FIL:='F$EXTRACT(T1,T2,RECORD)'
$ T1='F$LOCATE(".",FIL)'
$ IF IGNORE_TYPE.EQS."BUG" THEN $ FIL:=[.SRC]'F$EXTRACT(0,T1,FIL)'.*
$ IF IGNORE_TYPE.EQS."ENH" THEN $ FIL:=[.BUGSRC]'F$EXTRACT(0,T1,FIL)'.*
$ IF RESTART.AND.FIL.NES.RESTART_FIL THEN $ GOTO NEXT_UPD_FILE
$ RESTART:="FALSE"
$ @SYS$LOGIN:UPDATEMKR 'FACILITY' FIND_UPDATES 'FIL' ""
$ !
$ ! Search for a source file corresponding to the update packet.
$ !
$ T1=0
$FILE_LOOP:
$ TFILE:='F$SEARCH(FIL)'
$ IF TFILE.EQS."" THEN $ GOTO SEARCH_DONE
$ IF T1.EQ.0 THEN $ FILE:='TFILE'
$ T1=T1+1
$ IF T1.LE.1 THEN $ GOTO FILE_LOOP
$ IF T1.NE.2 THEN $ GOTO FILE_LOOP1
$ WRITE SYS$OUTPUT "%SRCMRG-E-MULTIPLESRC, multiple source files for update file '",RECORD,"'"
$ WRITE SYS$OUTPUT "-SRCMRG-I-MULTIPLEFIL, source file '",FILE,"'"
$FILE_LOOP1:
$ WRITE SYS$OUTPUT "-SRCMRG-I-MULTIPLEFIL, source file '",TFILE,"'"
$ GOTO FILE_LOOP
$ !
$ ! File specification successfully searched.  Now check to see if any source
$ ! file was found or whether more than one source file was found.
$ !
$SEARCH_DONE:
$ IF T1.EQ.1 THEN $ GOTO GOT_SRC_FILE
$ IF T1.NE.0 THEN $ GOTO MUL_SRC_FILE
$ WRITE SYS$OUTPUT "%SRCMRG-E-NOSOURCE, no source file for update file '",RECORD,"'"
$ GOTO NEXT_UPD_FILE
$MUL_SRC_FILE:
$ IF BATCH THEN $ GOTO NEXT_UPD_FILE
$ INQUIRE ANSWER "Which file is to be updated"
$ IF ANSWER.EQS."".OR.ANSWER.EQS."IGNORE" THEN $ GOTO NEXT_UPD_FILE
$ FILE:='ANSWER'
$ !
$ ! Now it is known which file in the source directory corresponds to the update
$ ! file.  Update it.
$ !
$GOT_SRC_FILE:
$ T1='F$LOCATE(";",FILE)'
$ FILE:='F$EXTRACT(0,T1,FILE)'
$ EDIT/SUM/OUTPUT='FILE' 'FILE'/UPDATE='RECORD'
$ IF LOGGING.EQS."" THEN $ GOTO NEXT_UPD_FILE
$ WRITE SYS$OUTPUT "%SUMSLP-S-UPDATED, ",FILE," updated with ",RECORD
$ GOTO NEXT_UPD_FILE
$ !
$ ! At this point all the updates have been applied.
$ !
$UPDATE_DONE:
$ CLOSE UPDFIL
$ CLEANUP=CLEANUP.AND.(.NOT.16)
$ DELETE UPDFILE.DAT;
$ CLEANUP=CLEANUP.AND.(.NOT.8)
$ !
$ ! Now purge all extraneous versions and rename all files to version 1.
$ !
$ UPDATED_SRC:="[.SRC]"
$ UPDATED_COM:="[.COM]"
$ ENTER_SRC:="[.BUGSRC]"
$ ENTER_COM:="[.BUGCOM]"
$ IF IGNORE_TYPE.EQS."BUG" THEN $ GOTO PURGE_UPDATES
$ UPDATED_SRC:="[.BUGSRC]"
$ UPDATED_COM:="[.BUGCOM]"
$ ENTER_SRC:="[.SRC]"
$ ENTER_COM:="[.COM]"
$PURGE_UPDATES:
$ ON ERROR THEN $ GOTO PURGE_DONE
$ SET PROCESS/PRIVILEGE=BYPASS
$ PURGE 'UPDATED_SRC'*.*
$ RENAME 'UPDATED_SRC'*.*;* 'UPDATED_SRC'*.*;1
$ RENAME 'UPDATED_COM'*.*;* 'UPDATED_COM'*.*;1
$ DELETE 'PACKET_DIR'*.*;*
$PURGE_DONE:
$ ON ERROR THEN $ GOTO CLEAN_UP
$ SET PROCESS/PRIVILEGE=NOBYPASS
$ !
$ ! Now get a list of the files in the [.COM] and [.SRC] directories (or the
$ ! [.BUGCOM] and [.BUGSRC] directories) and enter the files in the associated
$ ! [.BUGCOM] and [.BUGSRC] directories (or the [.COM] and [.SRC] directories).
$ !
$ DIRECTORY/NOHEADING/OUTPUT=DIRFILE.DAT 'UPDATED_SRC','UPDATED_COM'
$ CLEANUP=CLEANUP.OR.2
$ENTER_FILES:
$ @SYS$LOGIN:UPDATEMKR 'FACILITY' ENTER_FILES "" ""
$ OPEN/READ DIRFIL DIRFILE.DAT
$ CLEANUP=CLEANUP.OR.4
$NEXT_ENT_FILE:
$ IF "''F$LOGICAL("STOP_MERGE")'".NES."" THEN $ GOTO CLEAN_UP
$ READ/END=ENTER_DONE DIRFIL RECORD
$ T1='F$LOCATE("]",RECORD)'
$ IF T1.GE.'F$LENGTH(RECORD) THEN $ GOTO NEXT_ENT_FILE
$ T2='F$LENGTH(RECORD)'-T1
$ T1=T1+1
$ FILE:='F$EXTRACT(T1,T2,RECORD)'
$ IF RESTART.AND.FILE.NES.RESTART_FIL THEN $ GOTO NEXT_ENT_FILE
$ RESTART:="FALSE"
$ @SYS$LOGIN:UPDATEMKR 'FACILITY' ENTER_FILES 'FILE' ""
$ IF 'F$LOCATE("COM]",RECORD)'.LT.'F$LENGTH(RECORD)' -
	THEN $ SET FILE/ENTER='ENTER_COM''FILE' 'UPDATED_COM''FILE'
$ IF 'F$LOCATE("SRC]",RECORD)'.LT.'F$LENGTH(RECORD)' -
	THEN $ SET FILE/ENTER='ENTER_SRC''FILE' 'UPDATED_SRC''FILE'
$ GOTO NEXT_ENT_FILE
$ !
$ ! At this point all extraneous versions have been deleted, all the files
$ ! renamed to version 1, and the corresponding source and command directory
$ ! entries have been made.  Do some final cleanup and move on to the next
$ ! facility.
$ !
$ENTER_DONE:
$ CLOSE DIRFIL
$ CLEANUP=CLEANUP.AND.(.NOT.4)
$ DELETE DIRFILE.DAT;
$ CLEANUP=CLEANUP.AND.(.NOT.2)
$ !
$ ! Now set the protection of all the files needed by the facility.
$ !
$ SET PROTECTION=(S:RW,O:RW,G:R,W) [...]*.*;*
$ !
$ GOTO NEXT_RECORD
$ !
$ ! Either some fatal error has occurred or the master pack has been
$ ! successfully copied.  In either case some cleanup is required before
$ ! control may be returned to DCL.
$ !
$FACILITY_DONE:
$ @SYS$LOGIN:UPDATEMKR "" CLEAN_UP "" ""
$CLEAN_UP:
$ SET NOON
$ IF (CLEANUP.AND.512).NE.0 THEN $ CLOSE CHKPNT
$ IF (CLEANUP.AND.256).NE.0 THEN $ DELETE SYS$LOGIN:NEWMASTER.MKR;
$ IF (CLEANUP.AND.128).NE.0 THEN $ DELETE SYS$LOGIN:UPDATEMKR.COM;
$ IF (CLEANUP.AND.64).NE.0 THEN $ CLOSE CREFIL
$ IF (CLEANUP.AND.32).NE.0 THEN $ DELETE CREATCOPY.COM;
$ IF (CLEANUP.AND.16).NE.0 THEN $ CLOSE UPDFIL
$ IF (CLEANUP.AND.8).NE.0 THEN $ DELETE UPDFILE.DAT;
$ IF (CLEANUP.AND.4).NE.0 THEN $ CLOSE DIRFIL
$ IF (CLEANUP.AND.2).NE.0 THEN $ DELETE DIRFILE.DAT;
$ IF (CLEANUP.AND.1).NE.0 THEN $ CLOSE BLDFIL
$CLEAN_UP1:
$ IF "''F$LOGICAL("STOP_MERGE")'".NES."" THEN $ DEASSIGN/GROUP STOP_MERGE
$ SET DEFAULT 'OLD_DEV''OLD_DIR'
$ SET UIC 'OLD_UIC'
$ SET ON
$ IF V THEN $ SET VERIFY
