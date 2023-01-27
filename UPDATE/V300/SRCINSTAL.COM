$ V='F$VERIFY(0)'
$ !
$ ! SRCINSTAL.COM - the VMS source kit installation procedure
$ !
$ OLD_UIC:='F$USER()'
$ OLD_DIR:='F$DIRECTORY()'
$ OLD_DEV:='F$LOGICAL("SYS$DISK")'
$ TYPE SYS$INPUT:

This command procedure installs the necessary environment in  which  VMS  system
builds  may  be done.  It will prompt you for the device names of (1) the device
on which the source kit will be located (either single components or the  entire
source  kit), (2) the device on which the source kit magtapes are to be mounted,
and (3) then device on which to locate the home  directory  of  the  SYSTEMBUILD
account.   You  may supply either physical or logical device names.  However, if
logical names are given, since the device names are referenced by  this  command
procedure, they must be defined before the installation procedure can continue.

This command procedure will create the SYSTEMBUILD account,  and  move  all  the
necessary command procedures into the default directory.  An indirect pointer to
the system build startup command procedure, SBSTARTUP.COM, will be  appended  to
your SYSTARTUP.COM command procedure.  Therefore, make sure that it does not end
with a $EXIT;  otherwise the system builds will not be restartable.

You should be logged in under the SYSTEM account to  execute  this  installation
procedure.   At  the  very least, you will need the following privileges:  OPER,
SYSPRV, CMKRNL, GRPNAM, and VOLPRO.

If you do not already have  the  .L32  forms  of  the  BLISS  require  files  in
SYS$LIBRARY:,  this  command  procedure  will  compile  thwm.  You should have a
working set quota of at least 500 pages for this to  complete  in  a  reasonable
length of time.

$ INQUIRE ANS "Are you ready to proceed (Y/N)"
$ IF .NOT.ANS THEN $ GOTO CLEAN_UP1
$ ON ERROR THEN $ GOTO CLEAN_UP
$ SET UIC [11,177]
$ !
$ ! Get the device names for the source disk, the source kit tape drive, and
$ ! the home directory device.
$ !
$GET_SOURCE:
$ INQUIRE DST_MASTER "On what device in the master pack located (Dxcu:)"
$ IF DST_MASTER.EQS."" THEN $ GOTO GET_SOURCE
$ IF 'F$LOCATE(":",DST_MASTER)'.GE.'F$LENGTH(DST_MASTER)' THEN $ DST_MASTER:='DST_MASTER':
$ IF .NOT."''F$GETDVI(DST_MASTER,"MNT")'" THEN $ MOUNT/OVERRIDE=IDENTIFICATION 'DST_MASTER'
$ !
$GET_TAPE:
$ INQUIRE TAPE_DRIVE "On what device are the source kit tapes to be mounted (Mxcu:)"
$ IF TAPE_DRIVE.EQS."" THEN $ GOTO GET_TAPE
$ IF 'F$LOCATE(":",TAPE_DRIVE)'.GE.'F$LENGTH(TAPE_DRIVE)' THEN $ TAPE_DRIVE:='TAPE_DRIVE':
$ ALLOCATE 'TAPE_DRIVE'
$ IF .NOT."''F$GETDVI(TAPE_DRIVE,"MNT")'" THEN $ MOUNT/FOREIGN 'TAPE_DRIVE' VMSRC1
$ !
$GET_HOME:
$ INQUIRE BUILD_HOME "On what device will the SYSTEMBUILD account be located (Dxcu:)"
$ IF BUILD_HOME.EQS."" THEN $ GOTO GET_HOME
$ IF 'F$LOCATE(":",BUILD_HOME)'.GE.'F$LENGTH(BUILD_HOME)' THEN $ BUILD_HOME:='BUILD_HOME':
$ !
$ WRITE SYS$OUTPUT "Creating the SYSTEMBUILD account..."
$ !
$ ! See if the SYSTEMBUILD account exists.  If not, create it.
$ !
$ SEARCH/OUTPUT=NL: SYS$SYSTEM:SYSUAF.DAT SYSTEMBUILD
$ IF $STATUS.EQ.1 THEN $ GOTO NO_CREATE
$ !
$ OPEN/WRITE FILE SYS$MANAGER:CREATACNT.COM
$ WRITE FILE "$ SET DEFAULT SYS$SYSTEM:"
$ WRITE FILE "$ RUN AUTHORIZE"
$ WRITE FILE "ADD SYSTEMBUILD /ASTLM=10 /BIOLM=6 /BYTLM=8192 /CLI=DCL-"
$ WRITE FILE "/CPUTIME=0 /DEVICE=",BUILD_HOME,"/DIOLM=6 /DIRECTORY=[SYSBLDCOM]-"
$ WRITE FILE "/ENQLM=10 /FILLM=20 /FLAGS=(NODISCTLY,NOLOCKPWD,NODEFCLI,-"
$ WRITE FILE "NOCAPTIVE,NODISNEWMAIL,NODISWELCOME,NODISUSER) /MAXJOBS=0-"
$ WRITE FILE "/OWNER=""Source Kit"" /PASSWORD=CAVEAT_EMPTOR /PBYTLM=0-"
$ WRITE FILE "/PGFLQUOTA=10000 /P_RESTRICT /PRCLM=2 /PRIMEDAYS=(MON,TUE,WED,-"
$ WRITE FILE "THU,FRI,SAT,SUN) /PRIORITY=4 /PRIVILEGES=(GRPNAM,GROUP,VOLPRO,-"
$ WRITE FILE "OPER,TMPMBX) /SHRFILLM=4 /TQELM=10 /UIC=[11,177] /WSDEFAULT=150-"
$ WRITE FILE "/WSQUOTA=1000 /ACCOUNT=SYSBUILD"
$ CLOSE FILE
$ @SYS$MANAGER:CREATACNT.COM
$ DELETE SYS$MANAGER:CREATACNT.COM;
$ !
$NO_CREATE:
$ WRITE SYS$OUTPUT "Creating the SYSTEMBUILD directory..."
$ !
$ SET DEFAULT 'BUILD_HOME'[SYSBLDCOM]
$ !
$ WRITE SYS$OUTPUT "Ignore the following errors if you are not using disk quotas..."
$ !
$ RUN SYS$SYSTEM:DISKQUOTA
ADD [11,177] /PERMQUOTA=20000 /OVERDRAFT=1000
$ !
$ IF "''F$SEARCH("[0,0]SYSBLDCOM.DIR")'".NES."" THEN $ GOTO GOT_SYSBLDCOM
$ CREATE/DIRECTORY/OWNER=[11,177]/PROTECTION=(S:R,O:RW,G:R,W) [SYSBLDCOM]
$GOT_SYSBLDCOM:
$ IF "''F$SEARCH("[0,0]SYS.DIR")'".EQS."" THEN $ GOTO CREATE_SRC
$ IF "''F$SEARCH("[SYS]SRC.DIR")'".NES."" THEN $ GOTO GOT_SRC
$CREATE_SRC:
$ CREATE/DIRECTORY/OWNER=[11,177]/PROTECTION=(S:R,O:RW,G:R,W) [SYS.SRC]
$GOT_SRC:
$ IF "''F$SEARCH("[SYS]OBJ.DIR")'".NES."" THEN $ GOTO GOT_OBJ
$ CREATE/DIRECTORY/OWNER=[11,177]/PROTECTION=(S:R,O:RW,G:R,W) [SYS.OBJ]
$GOT_OBJ:
$ IF "''F$SEARCH("[SYS]LIS.DIR")'".NES."" THEN $ GOTO GOT_LIS
$ CREATE/DIRECTORY/OWNER=[11,177]/PROTECTION=(S:R,O:RW,G:R,W) [SYS.LIS]
$GOT_LIS:
$ IF "''F$SEARCH("[0,0]SYSOBJ.DIR")'".NES."" THEN $ GOTO GOT_SYSOBJ
$ CREATE/DIRECTORY/OWNER=[11,177]/PROTECTION=(S:R,O:RW,G:R,W) [SYSOBJ]
$GOT_SYSOBJ:
$ !
$ WRITE SYS$OUTPUT "Restoring SYSTEMBUILD command procedures and compilers..."
$ !
$ BACKUP 'TAPE_DRIVE'SYSBLDCOM/EXCLUDE=(SRCINSTAL.COM) 'DST_MASTER'[*...]/OWNER=ORIGINAL/NEW_VERSION
$ IF BUILD_HOME.EQS.DST_MASTER THEN $ GOTO COPY_DONE
$ COPY 'DST_MASTER'[SYSBLDCOM]SBSTARTUP.COM,LOGIN.COM,SCANALL.COM,SDL.CLD,-
	SETUSER.B32 'BUILD_HOME'[SYSBLDCOM]
$ COPY 'DST_MASTER'[SYS.SRC]VERSION.MAR 'BUILD_HOME'[SYS.SRC]
$COPY_DONE:
$ COPY 'DST_MASTER'[SYSEXE]CVTMSG.* SYS$SYSTEM:
$ PURGE [SYS.SRC]VERSION.MAR
$ !
$ ! Modify SBSTARTUP.COM to reflect the devices specified
$ !
$ MUNG:=$TECO MUNG
$ MUNG 'DST_MASTER'EDITSTART,'BUILD_HOME','DST_MASTER'
$ PURGE [SYSBLDCOM]*.*
$ !
$ ! Now modify the site SYSTARTUP.COM file to invoke SBSTARTUP.COM
$ !
$ SET DEFAULT SYS$MANAGER:
$ MUNG 'DST_MASTER'[SYSBLDCOM]EDITSYST,'BUILD_HOME'
$ !
$ WRITE SYS$OUTPUT "Compiling the BLISS libraries..."
$ !
$ SET UIC 'OLD_UIC'
$ SET DEFAULT SYS$LIBRARY:
$ DEFINE BLISS32 'DST_MASTER'[SYSEXE]BLISS32
$ SET WORKING_SET/LIMIT=1000
$ IF "''F$SEARCH("CLIMAC.L32")'".NES."" THEN $ GOTO GOT_CLIMAC
$ BLISS/LIBRARY CLIMAC
$GOT_CLIMAC:
$ IF "''F$SEARCH("TPAMAC.L32")'".NES."" THEN $ GOTO GOT_TPAMAC
$ BLISS/LIBRARY TPAMAC
$GOT_TPAMAC:
$ IF "''F$SEARCH("STARLET.L32")'".NES."" THEN $ GOTO GOT_STARLET
$ WRITE SYS$OUTPUT "Compiling STARLET.L32...take a short break..."
$ BLISS/LIBRARY STARLET
$GOT_STARLET:
$ IF "''F$SEARCH("LIB.L32")'".NES."" THEN $ GOTO GOT_LIB
$ WRITE SYS$OUTPUT "Compiling LIB.L32...take a longer break..."
$ BLISS/LIBRARY=LIB STARLET+LIB
$GOT_LIB:
$ !
$ ! Now build SETUSER.EXE
$ !
$ SET DEFAULT 'BUILD_HOME'[SYSBLDCOM]
$ BLISS SETUSER
$ LINK SETUSER,SYS$SYSTEM:SYS.STB/SEL
$ COPY SETUSER.EXE SYS$SYSTEM:
$ !
$ DEASSIGN BLISS32
$ SET WORKING_SET/LIMIT=150
$ TYPE SYS$INPUT:

To complete installation of the VMS source kit, now  dismount  the  source  disk
/NOUNLOAD,  and  execute  the  system  build  startup command file by typing the
command:

$ WRITE SYS$OUTPUT "	@",BUILD_HOME,"[SYSBLDCOM]SBSTARTUP"
$ TYPE SYS$INPUT:

This will mount the source disk /GROUP, and it  will  create  the  system  build
batch queues.  Once you have done this, log out and log in under the SYSTEMBUILD
account just created.  The password is CAVEAT_EMPTOR;  remember to change it  to
one    of    your    own    choosing.     For    further    information,    read
[SYSBLDCOM]SOURCEKIT.DOC.

$CLEAN_UP:
$ IF "''F$GETDVI(TAPE_DRIVE,"MNT")'" THEN $ DISMOUNT 'TAPE_DRIVE'
$CLEAN_UP1:
$ SET UIC 'OLD_UIC'
$ SET DEFAULT 'OLD_DEV''OLD_DIR'
$ IF V THEN $ SET VERIFY
