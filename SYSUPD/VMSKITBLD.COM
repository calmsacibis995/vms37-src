$	VERIFY = 'F$VERIFY(0)
$	IF P3 .NES. "" .AND. P4 .NES. "" THEN GOTO START
$	TYPE SYS$INPUT:

 VMSKITBLD - Build or Copy VAX/VMS binary distribution  kit for Release 3.

$
! This command  file allows the  invoker to create  a system disk or copy a
! system disk.  The transfer can  occur between any  of the disk types sup-
! ported in Release 3.  For small disks (e.g. RL02) the saveset select
! feature allows distribution over several volumes.
!
! This command file will also create a bootblock on the target disk.  This
! This is done by WRITEBOOT, and requires LOG_IO privilege.
!
! There are  eight parameters which  control the kit build procedure.  Some
! or all of these parameters may be specified as input.
!
! The parameters are:
!
! P1 = FILESPEC   The file name of the data file to use for the procedure.
!	Default = SYS$UPDATE:VMSKITBLD.DAT
! 
! P2 = MASK  The mask to use for determining whether to transfer each
!	individual file.
! 
! P3 = SOURCE:[SOURCE_TOPSYS] This specifies the source disk from which the kit
!	will be built, and the associated top level system directory if any.
!	If SOURCE_TOPSYS is defaulted, then the source device is checked
!	to see if it has a SYS0 topsys.  If it does, then SYS0 is the
!	the default, if not then NONE is the default.
!
! P4 = TARGET:LABEL[TARGET_TOPSYS] The target disk, its associated top
!	level system directory, and the target disk label to which the
!	kit will be built.  If TARGET_TOPSYS is defaulted, then it is
!	assumed to be SYS0.  An explicit "NONE" is required to produce
!	a "flat" system.
!
! P5 = SELECT  Savesets to be output.  One of: REQ, LIB, OPT, ALL, or EDTCAI.
!	By default ALL files are transferred to the output device
!
! P6 = MIDNITE	This parameter is set to one of either R,E, or D depending
!		on whether a MidNite system is being built or not.
!	R -	Required file set only.
!	E -	Set for an execution only system.
!	D -	Set for a full development system.
!
! P7 = COPY     This parameter specifies whether to BUILD, ADD, or COPY..
!	BUILD -	Initializes a new volume or volume set and creates all
!		the necessary directories from scratch.
!	ADD   - This is the new feature that puts a new system in a new
!		set of directories on an existing volume which presumably
!		contains other systems on it.  The TARGET_TOPSYS should
!		be a new top level system directory.
!	COPY  -	Copies the kit files to an already existing set of
!		system directories.  It will not create the directories.
!
! P8 = OPTIONS  This parameter is a comma separated list of options.
!	NOPROMPT - Indicates that the user should not be prompted with
!		   "device ready" questions.  Command procedures which
!		   invoke VMSKITBLD with known device status set this switch.
!
! 
! This command procedure uses as input a data file (specified in P1 or
! defaulted to [SYSUPD]VMSKITBLD.DAT on the system disk).  The data file is
! read as input commands to be executed by the procedure.  The format of each
! record in the data file is as follows:
!	1) If the record begins with a "$" (dollar sign), then the record is
!	   submitted directly as a DCL command line.
!	2) The remainder of the records have the following fields defined:
!	   NOTE: The fields can be in any order.
!
!	NAME,OP=op,SET=set,COND=mask,MID=flags,CAT=tailorgroup
!
!			NAME  -  The name of the file to be copied.  Must
!				 include the extension but not the version.
!			OPERATION  =  The action to be performed on the file.
!				 null  -  build/copy the file normally
!				 BUILD  -  transfer the file during build only
!				 SET  -  set the default directory to NAME for
!					 the succeeding transfers.
!				 CREATE  -  create a directory entry called NAME
!					(build only).  The "SYNONYM="  field
!					specifies an alternate directory name
!					to be entered as a synonym to NAME.
!				 ENTER  -  make a directory entry for file NAME
!					(build only)
!				 COPY  -  transfer the file during copy only
!				 CONTIG  -  make the destination file contiguous
!				 RENAME_B - rename a file just copied to the
!					target disk.  In a rename operation, the
!					data record also contains the field
!					DEST=new_file_name.  Only used for
!					BUILD and ADD operations.
!				RENAME_C - same as RENAME_B except used for
!					COPY operations.
!				 SYSGEN  -  create the sysgen files (build
!					only).  If NAME is null, use default
!					sysgen file sizes depending on target
!					disk type.  If 	NAME is not null, create
!					the sysgen file specified in NAME, and
!					use the FILESIZE= field of the record
!					to specify the file size.
!				WRITEBOOT - write a bootblock on the target
!					device
!			SAVESET	- Chooses a subset of files to copy to the
!					target device.  This parameter is used
!					for building Release 3 distribution kits.
!				REQ - required saveset
!				LIB - library saveset
!				OPT - optional saveset
!				EDTCAI - edtcai saveset
!				ALL - all savesets
!			CONDITIONAL  -  The value to be ANDed to determine
!				whether or not to copy/build this file.
!
!				a) 1,2,4  -  UETP
!				b)  8  -  HELP files
!				c) 16  -  F4P, FORTRAN
!				d) 32  -  BASIC +2
!				e) 64  -  DECnet
!				f) 128 -  BLISS32 and .L32 files
!				g) 256 -  coding examples
!				h) 512,1024  -  VMS development only, not
!					for REL 3 kits
!				i) 2048 - files needed to build VMS
!					distribution kits
!				j) all others undefined
!
!			CATEGORY - The tailoring group(s) to which this
!				   file belongs.  This feild is used by
!				   [SYSBLDCOM]TAILORBLD.COM to create the
!				   tailoring group files.
!
!
$START:
$	DEFDIR:='F$DIRECTORY()
$	DEFUIC:='F$USER()
$	SYSGEN:=$SYSGEN
$	ON ERROR THEN GOTO 3020
$	ON CONTROL_Y THEN GOTO 3020
$	SAVED_PRIVS = F$SETPRV("CMKRNL,SYSPRV,LOG_IO,VOLPRO")
$
$ !
$ ! Parse OPTIONS
$ !
$	PROMPT = "TRUE"
$	IF F$LOCATE ("NOPROMPT", P8) .NE. F$LENGTH (P8) -
	  .AND. P8 .NES. "" THEN PROMPT = "FALSE"
$ !
$ ! Parse SELECT parameter.
$ !
$	SELECT = P5
$	VALID_SAVESETS := REQ,LIB,OPT,EDTCAI,ALL
$	IF SELECT .EQS. "" THEN SELECT = "ALL"
$	IF F$LOCATE(SELECT,VALID_SAVESETS) .NE. F$LENGTH(VALID_SAVESETS) -
	THEN GOTO GET_OPERATION
$	WRITE SYS$OUTPUT -
"P5 must be one of: REQ, LIB, OPT, EDTCAI, ALL, or null"
$	EXIT
$ !
$ ! Determine which operation was requested.
$ !
$GET_OPERATION:
$	BUILD = P7
$60:	IF BUILD .EQS. "BUILD" .OR. BUILD .EQS. "ADD" .OR. BUILD .EQS. "COPY"-
	THEN GOTO 61
$	INQUIRE BUILD "Is this a BUILD, ADD, or COPY operation?"
$	GOTO 60
$61:
$ !
$ ! Get source device and TOPSYS directory.
$ !
$GET_SOURCE:
$	DEFAULT_SOURCE_TOPSYS = "NONE"
$	SOURCE = P3
$	IF SOURCE .EQS. "" THEN GOTO SRC_PROMPT
$	COLON_POS = 'F$LOCATE(":",SOURCE)+1
$	SOURCE_TOPSYS = F$EXTRACT(COLON_POS,132,SOURCE)
$	SOURCE = F$EXTRACT(0,COLON_POS,SOURCE)
$	GOTO FORM_SRC_SYMBOLS
$
$SRC_PROMPT:
$	INQUIRE SOURCE "Enter mounted source disk name (DDCU:)"
$	IF SOURCE .EQS. "" THEN GOTO SRC_PROMPT
$	SOURCE = SOURCE - ":" + ":"		! Make sure : is at the end.
$	TEMP = F$SEARCH("''SOURCE'[0,0]SYS0.DIR;1")
$	IF TEMP .NES. "" THEN DEFAULT_SOURCE_TOPSYS = "SYS0"
$	INQUIRE SOURCE_TOPSYS -
"Enter SOURCE disk top level system directory [default = ''DEFAULT_SOURCE_TOPSYS']"
$
$FORM_SRC_SYMBOLS:
$	SOURCE_TOPSYS = SOURCE_TOPSYS - ":" - "[" - "<" - "]" - ">"
$	IF SOURCE_TOPSYS .EQS. "" THEN SOURCE_TOPSYS = DEFAULT_SOURCE_TOPSYS
$	IF SOURCE_TOPSYS .EQS. "NONE" THEN SOURCE_TOPSYS = ""
$	SOURCE_TOPSYS_DOT := ""
$	IF SOURCE_TOPSYS .NES. "" THEN SOURCE_TOPSYS_DOT := 'SOURCE_TOPSYS'.
$ !
$ ! Get target device, label, and TOPSYS directory.
$ !
$GET_TARGET:
$	TARGET = P4
$	IF TARGET .EQS. "" THEN GOTO TARGET_PROMPT
$	COLON_POS = F$LOCATE(":",TARGET)+1
$	LB_POS = F$LOCATE("[",TARGET)
$	LABEL = F$EXTRACT(COLON_POS,LB_POS-COLON_POS,TARGET)
$	IF LABEL .EQS. "" THEN INQUIRE LABEL -
"Enter the target disk's label [default = VAXVMSRL3]"
$	TARGET_TOPSYS = F$EXTRACT(LB_POS,132,TARGET) - "[" - "<" - "]" - ">"
$	TARGET = F$EXTRACT(0,COLON_POS,TARGET)
$	GOTO FORM_TARGET_SYMBOLS
$
$TARGET_PROMPT:
$	INQUIRE TARGET "Enter target disk name (DDCU:)"
$	IF TARGET .EQS. "" THEN GOTO TARGET_PROMPT
$	TARGET = TARGET - ":" + ":"
$	INQUIRE LABEL -
"Enter the target disk's label [default = VAXVMSRL3]"
$GET_TARGET_TOPSYS:
$	INQUIRE TARGET_TOPSYS -
"Enter TARGET disk top level system directory [default = SYS0]"
$
$FORM_TARGET_SYMBOLS:
$	IF LABEL .EQS. "" THEN LABEL := VAXVMSRL3
$	IF TARGET_TOPSYS .EQS. "" THEN TARGET_TOPSYS = "SYS0"
$	IF TARGET_TOPSYS .NES. "NONE" THEN GOTO NOT_FLAT
$	TARGET_TOPSYS = ""
$	TYPE SYS$INPUT

Warning -- system disks built without a top level system directory are
           not supported by Digital and cannot be upgraded nor updated.

$
$NOT_FLAT:
$	TARGET_TOPSYS_DOT := ""
$	ROOT = "[0,0]"
$	IF TARGET_TOPSYS .NES. "" THEN GOTO 10$
$	IF BUILD .NES. "ADD" THEN GOTO GET_DATAFILE
$	WRITE SYS$OUTPUT -
"The ADD function requires a top level system directory for the TARGET disk."
$	GOTO GET_TARGET_TOPSYS
$10$:
$	TARGET_TOPSYS = TARGET_TOPSYS - "[" - "<" - "]" - ">"
$	IF 'F$LENGTH(TARGET_TOPSYS) .EQ. 0 THEN GOTO 20$
$	IF 'F$LENGTH(TARGET_TOPSYS) .EQ. 4 -
	.AND. ((TARGET_TOPSYS .GES. "SYS0" .AND. TARGET_TOPSYS .LES. "SYS9") -
	.OR. (TARGET_TOPSYS .GES. "SYSA" .AND. TARGET_TOPSYS .LES. "SYSF")) -
	THEN GOTO 20$
$	WRITE SYS$OUTPUT -
"The TARGET top level system directory must be SYS0 - SYSF, or NONE."
$	GOTO GET_TARGET_TOPSYS
$20$:
$	TARGET_TOPSYS_DOT := 'TARGET_TOPSYS'.
$	ROOT := ['TARGET_TOPSYS']
$ !
$ ! Get data file name.
$ !
$GET_DATAFILE:
$	FILENAME = P1
$	IF FILENAME .EQS. "" THEN FILENAME = "SYS$UPDATE:VMSKITBLD.DAT"
$	ON ERROR THEN GOTO 3010
$	ON CONTROL_Y THEN GOTO 3010
$	OPEN/READ DATAF 'FILENAME
$	IF $STATUS THEN GOTO GET_MIDNITE
$	WRITE SYS$OUTPUT " Unable to open data parameter file."
$	EXIT
$
$GET_MIDNITE:
$	MIDNITE = P6
$	IF MIDNITE .EQS. "" THEN GOTO GET_CONDIT
$	MIDNITE = F$EXTRACT(0,1,MIDNITE)
$	IF F$LOCATE(MIDNITE,"RED").NE.3 THEN GOTO GET_CONDIT
$	WRITE SYS$OUTPUT " Invalid P6 parameter."
$	EXIT
$
$GET_CONDIT:
$	MASK = P2
$	CONDIT = 1+2+4+8+64+256
$	IF MASK .NES. "" THEN CONDIT = 'MASK'
$	IF BUILD .EQS. "COPY" THEN GOTO ALLOC_TARGET
$ !
$ ! Set up for BUILD and ADD operation.
$ !
$	NOPRIV = 0
$	SET NOON
$	SET UIC [1,4]
$	IF .NOT. $STATUS THEN NOPRIV = 1
$	SET ON
$	DELETE:="!"
$	SYS_QUAL = ""
$	IF NOPRIV THEN SYS_QUAL = "/SYS"
$	MAXFILES_QUAL = "/MAXIMUM_FILES=2500"
$	IF SELECT .EQS. "ALL" THEN MAXFILES_QUAL = ""
$	HEADERS_QUAL = ""
$	IF SELECT .EQS. "REQ" THEN HEADERS_QUAL = "/HEADERS=300"
$	INIT_VOLUME := INIT/CLUSTER=1'SYS_QUAL''MAXFILES_QUAL''HEADERS_QUAL'
$	CREATE_DIRECTORY = "CREATE/DIRECTORY/OWNER=[1,4]/PROTECTION=(SY:RWE,OW:RWE,GR:RE,WO:RE)"
$	IF NOPRIV THEN CREATE_DIRECTORY = "CREATE/DIRECTORY/PROTECTION=(SY:RWE,OW:RWE,GR:RE,WO:RE)"
$	IF BUILD .EQS. "ADD" THEN GOTO MOUNT_TARGET
$ !
$ ! This next block is only executed during a BUILD operation.
$ !
$INIT_TARGET:
$	IF F$MODE() .NES. "INTERACTIVE" THEN GOTO 63
$	WRITE SYS$OUTPUT "  It will be necessary to initialize the target disk(s)."
$62:	IF .NOT. PROMPT THEN GOTO 63
$	INQUIRE READY -
"Is the target disk, ''TARGET, ready to be initialized? (Y/N)"
$	IF .NOT. READY THEN GOTO 62
$63:	ALLOCATE 'TARGET
$	'INIT_VOLUME' 'TARGET' 'LABEL'
$	GOTO MOUNT_TARGET
$ !
$ ! Executed during an ADD or COPY operation.
$ !
$ALLOC_TARGET:
$	WRITE SYS$OUTPUT "  Allocate and mount the target disk(s).
$	SET DEFAULT ['TARGET_TOPSYS_DOT'SYSEXE]
$	SOURCE_DEFAULT := 'SOURCE'['SOURCE_TOPSYS_DOT'SYSEXE]
$	ALLOCATE 'TARGET
$ !
$ ! All operations converge at this point.
$ !
$MOUNT_TARGET:
$	ON CONTROL_Y THEN GOTO 3000
$	ON ERROR THEN GOTO 3000
$	MOUNT/DATA_CHECK=(READ,WRITE) 'TARGET' 'LABEL'
$	IF BUILD .EQS. "COPY" .OR. TARGET_TOPSYS .EQS. "" THEN GOTO START_BUILD
$	'CREATE_DIRECTORY'  'TARGET'['TARGET_TOPSYS']
$
$START_BUILD:
$	SET NOON
$	SET UIC [1,4]
$ !
$ ! This is the main loop that is executed for each record in the data file.
$ !
$RECORD_LOOP:
$	READ/END_OF_FILE=2000 DATAF RECORD
$	IF F$EXTRACT(0,1,RECORD) .EQS. "$" THEN GOTO EXECUTE_DCL
$	IF F$EXTRACT(0,1,RECORD) .EQS. "!" THEN GOTO COMMENT
$	IF F$EXTRACT(0,1,RECORD) .NES. "*" THEN GOTO GET_SAVESET
$	IF MIDNITE .EQS. "" THEN GOTO COMMENT
$	RECORD = F$EXTRACT(1,200,RECORD)
$	GOTO GET_SAVESET
$
$COMMENT:
$ !
$ ! If this is the comment that announces the UETP files, see if UETP is
$ ! requested.  If not, we're through looking at the data file (UETP is
$ ! always the last component copied).
$ !
$	IF F$LOCATE("UETP",RECORD) .EQ. F$LENGTH(RECORD) THEN GOTO RECORD_LOOP
$	IF (7 .AND. CONDIT) .EQ. 0 THEN GOTO 2000
$	IF SELECT .NES. "LIB" .AND. SELECT .NES. "ALL" THEN GOTO 2000
$	GOTO RECORD_LOOP
$ !
$ ! Get the saveset field from the current record.
$ !
$GET_SAVESET:
$	IF SELECT .EQS. "ALL" THEN GOTO GET_CONDITIONAL
$	SAVESET = F$EXTRACT(F$LOCATE("SET=",RECORD)+4,132,RECORD)
$	SAVESET = F$EXTRACT(0,F$LOCATE(",",SAVESET),SAVESET)
$	IF SAVESET .EQS. "" THEN SAVESET := LIB
$	IF F$LOCATE(SAVESET,VALID_SAVESETS) .NE. F$LENGTH(VALID_SAVESETS) -
	THEN GOTO 250
$	WRITE SYS$OUTPUT "BAD SAVESET SPECIFIED IN RECORD *''RECORD'*"
$	SAVESET = "LIB"
$250:	IF SAVESET .NES. "ALL" .AND. SELECT .NES. SAVESET -
	THEN GOTO RECORD_LOOP
$ !
$ ! Get the CONDTIONAL field from the current record.
$ !
$GET_CONDITIONAL:
$	IF CONDIT .EQ. -1 THEN GOTO GET_MIDNITE
$	CONDITIONAL = F$EXTRACT(F$LOCATE("COND=",RECORD)+5,132,RECORD)
$	IF CONDITIONAL .EQS. "" THEN GOTO GET_MIDNITE
$	CONDITIONAL = F$EXTRACT(0,F$LOCATE(",",CONDITIONAL),CONDITIONAL)
$	IF (CONDITIONAL .AND. CONDIT) .EQ. 0 THEN GOTO RECORD_LOOP
$ !
$ ! Get the flagging for MidNite if this is a MidNite build.
$ !
$GET_MIDNITE:
$	IF MIDNITE .EQS. "" THEN GOTO GET_NAME
$	MIDFLAGS = F$EXTRACT(F$LOCATE("MID=",RECORD)+4,132,RECORD)
$	IF MIDFLAGS .EQS. "" THEN GOTO RECORD_LOOP
$	IF F$LOCATE(MIDNITE,MIDFLAGS) .EQ. F$LENGTH(MIDFLAGS) -
	  THEN GOTO RECORD_LOOP
$ !
$ ! Get the name from the current record.  (The name is always the first field
$ ! in the record, and doesn't have a keyword associated with it.)
$ !
$GET_NAME:
$	NAME = F$EXTRACT(0,F$LOCATE(",",RECORD),RECORD)
$ !
$ ! Get the operation specified by the current record.
$ !
$GET_OPERATION:
$	OPERATION = F$EXTRACT(F$LOCATE("OP=",RECORD)+3,132,RECORD)
$	IF OPERATION .EQS. "" THEN GOTO NORMAL
$	OPERATION = F$EXTRACT(0,F$LOCATE(",",OPERATION),OPERATION)
$	GOTO 'OPERATION
$
$BUILD:
$	IF BUILD .NES. "BUILD" .AND. BUILD .NES. "ADD" THEN GOTO RECORD_LOOP
$	GOTO NORMAL
$
$COPY:
$	IF BUILD .NES. "COPY" THEN GOTO RECORD_LOOP
$	GOTO NORMAL
$
$SET:
$	SET DEFAULT ['TARGET_TOPSYS_DOT''NAME']
$	SOURCE_DEFAULT = SOURCE + "[" + SOURCE_TOPSYS_DOT + NAME + "]"
$	GOTO RECORD_LOOP
$
$CREATE:
$	IF BUILD .EQS. "COPY" THEN GOTO RECORD_LOOP
$	'CREATE_DIRECTORY' 'TARGET'['TARGET_TOPSYS_DOT''NAME']
$	SYNONYM = F$EXTRACT(F$LOCATE("SYNONYM=",RECORD)+8,132,RECORD)
$	SYNONYM = F$EXTRACT(0,F$LOCATE(",",SYNONYM),SYNONYM)
$	IF SYNONYM .EQS. "" THEN GOTO RECORD_LOOP
$	MCR PIP 'TARGET''ROOT''SYNONYM'.DIR;1/EN='TARGET''ROOT''NAME'.DIR;1
$	MCR PIP 'ROOT''NAME'/RE='TARGET''ROOT''NAME'.DIR;1
$	GOTO RECORD_LOOP
$
$ENTER:
$	IF BUILD .EQS. "COPY" THEN GOTO RECORD_LOOP
$	CREATE 'TARGET''NAME'
$	GOTO RECORD_LOOP
$
$NORMAL:
$	IF BUILD .NES. "BUILD" THEN DELETE 'TARGET''NAME';*
$	COPY /PROTECTION=(S=RWED,O=RWED,G=RWED,W=RE) -
		'SOURCE_DEFAULT''NAME' 'TARGET''NAME'
$	GOTO RECORD_LOOP
$
$CONTIG:
$	DELETE 'TARGET''NAME';*
$	COPY /PROTECTION=(S=RWED,O=RWED,G=RWED,W=RE) /CONTIG  -
		/TRUNC 'SOURCE_DEFAULT''NAME' 'TARGET''NAME'
$	GOTO RECORD_LOOP
$	
$RENAME_C:
$	IF BUILD .NES. "COPY" THEN GOTO RECORD_LOOP
$	GOTO RENAME
$RENAME_B:
$	IF BUILD .NES. "BUILD" THEN GOTO RECORD_LOOP
$RENAME:
$	DESTINATION = F$EXTRACT(F$LOCATE("DEST=",RECORD)+5,132,RECORD)
$	IF DESTINATION .EQS. "" THEN GOTO RECORD_LOOP
$	DESTINATION = F$EXTRACT(0,F$LOCATE(",",DESTINATION),DESTINATION)
$	RENAME 'TARGET''NAME' 'TARGET''DESTINATION'
$	GOTO RECORD_LOOP
$
$EXECUTE_DCL:
	'RECORD
$	GOTO RECORD_LOOP
$
$SYSGEN:
$	IF BUILD .NES. "BUILD" THEN GOTO RECORD_LOOP
$	SET DEF ['TARGET_TOPSYS_DOT'SYSEXE]
$	IF MIDNITE .NES. "" THEN GOTO MIDGEN
$	IF SELECT .NES. "REQ" THEN GOTO SIZE_SYSGEN_FILES
$MIDGEN:
$	WRITE SYS$OUTPUT -
	"For distribution kits, the following system file sizes are used:"
$	WRITE SYS$OUTPUT -
	"PAGEFILE.SYS=4604, SWAPFILE.SYS=none, SYSDUMP.DMP=none"
$	NAME = "PAGEFILE.SYS"
$	FILESIZE := 4604
$	GOTO 590
$
$SIZE_SYSGEN_FILES:
$	DISKSIZE = F$GETDEV(TARGET,"MAXBLOCK")
$	IF DISKSIZE .GT. 100000 THEN GOTO 500$
$	DUMP := 1028
$	PAGE := 8192
$	SWAP := 3080
$	GOTO CREATE_SYSGEN_FILES
$500$:
$	IF DISKSIZE .GT. 300000 THEN GOTO 510$
$	DUMP := 2054
$	PAGE := 24000
$	SWAP := 26600
$	GOTO CREATE_SYSGEN_FILES
$510$:
$	DUMP := 4104
$	PAGE := 48000
$	SWAP := 36000
$
$CREATE_SYSGEN_FILES:
$	IF NAME .NES. "" THEN GOTO CREATE_SINGLE
$	SYSGEN CREATE 'TARGET'SWAPFILE/SIZE='SWAP
$	SET PROT=(S:RWED,O:RWED,G,W) 'TARGET'SWAPFILE.SYS
$	SET FILE /NOBACKUP 'TARGET'SWAPFILE.SYS
$	SYSGEN CREATE 'TARGET'PAGEFILE/SIZE='PAGE
$	SET PROT=(S:RWED,O:RWED,G,W) 'TARGET'PAGEFILE.SYS
$	SET FILE /NOBACKUP 'TARGET'PAGEFILE.SYS
$	SYSGEN CREATE 'TARGET'SYSDUMP.DMP/SIZE='DUMP
$	SET PROT=(S:RWED,O:RWED,G,W) 'TARGET'SYSDUMP.DMP
$	SET FILE /NOBACKUP 'TARGET'SYSDUMP.DMP
$	GOTO RECORD_LOOP
$
$CREATE_SINGLE:
$	FILESIZE = F$EXTRACT(F$LOCATE("FILESIZE=",RECORD)+9,132,RECORD)
$	FILESIZE = F$EXTRACT(0,F$LOCATE(",",FILESIZE),FILESIZE)
$	IF FILESIZE .NES. "" THEN GOTO 590
$	IF NAME .EQS. "SWAPFILE" THEN GOTO SWAPFILE
$	IF NAME .EQS. "PAGEFILE" THEN GOTO PAGEFILE
$	IF NAME .EQS. "SYSDUMP.DMP" THEN GOTO SYSDUMP
$	WRITE SYS$OUTPUT "Invalid parameter for SYSGEN, files not created."
$	WRITE SYS$OUTPUT "Invalid record = *''RECORD'*""
$	GOTO RECORD_LOOP
$SWAPFILE:
$	FILESIZE := 'SWAP
$	GOTO 590
$PAGEFILE:
$	FILESIZE := 'PAGE
$	GOTO 590
$SYSDUMP:
$	FILESIZE := 'DUMP
$590:
$	SYSGEN CREATE 'TARGET''NAME'/SIZE='FILESIZE
$	SET PROT=(S:RWED,O:RWED,G,W) 'TARGET''NAME'
$	SET FILE /NOBACKUP 'TARGET''NAME'
$	GOTO RECORD_LOOP
$
$WRITEBOOT:
$	IF SELECT .NES. "REQ" .AND. SELECT .NES. "ALL" THEN GOTO RECORD_LOOP
$	DEFINE /USER TARGET_DISK 'TARGET'['TARGET_TOPSYS_DOT'SYSEXE]
$	MCR WRITEBOOT
TARGET_DISK:VMB.EXE
1
200
$	GOTO RECORD_LOOP
$
$LIBENTER:
$	LIB_NAME := ""
$	IF BUILD .EQS. "BUILD" THEN GOTO RECORD_LOOP
$	IF LIB_SCRATCH .EQS. "" THEN GOTO 870
$ 	CREATE 'LIB_SCRATCH''NAME'
$	LIB_NAME := 'NAME'
$	GOTO RECORD_LOOP
$LIBEXTRACT:
$	IF BUILD .EQS. "BUILD" THEN GOTO RECORD_LOOP
$	IF LIB_SCRATCH .EQS. "" THEN GOTO 870
$	TS := 'F$PROCESS()
$	SFX := 'F$EXTRACT(1,1,TS)''F$EXTRACT(3,2,TS)
$	DESTINATION = F$EXTRACT(F$LOCATE("DEST=",RECORD)+5,132,RECORD)
$	DESTINATION = F$EXTRACT(0,F$LOCATE(",",DESTINATION),DESTINATION)
$	IF DESTINATION .EQS. "" THEN DESTINATION := 'NAME
$	LIBRARY/EXTRACT='DESTINATION' /OUTPUT='LIB_SCRATCH'TEMP'SFX'.TMP -
		'SOURCE_DEFAULT''NAME'
$	APPEND 'LIB_SCRATCH'TEMP'SFX'.TMP 'LIB_SCRATCH''LIB_NAME'
$	DELETE 'LIB_SCRATCH'TEMP'SFX'.TMP;*
$	GOTO RECORD_LOOP
$LIBREPLACE:
$	IF BUILD .EQS. "BUILD" THEN GOTO RECORD_LOOP
$	IF LIB_SCRATCH .EQS. "" THEN GOTO 870
$	DESTINATION = F$EXTRACT(F$LOCATE("DEST=",RECORD)+5,132,RECORD)
$	DESTINATION = F$EXTRACT(0,F$LOCATE(",",DESTINATION),DESTINATION)
$	IF DESTINATION .EQS. "" THEN DESTINATION := 'NAME
$	LIBRARY 'TARGET''DESTINATION' 'LIB_SCRATCH''NAME'
$	DELETE 'LIB_SCRATCH''NAME';*
$	GOTO RECORD_LOOP
$LIBSELECTIVE:
$	IF BUILD .EQS. "BUILD" THEN GOTO RECORD_LOOP
$	IF LIB_SCRATCH .EQS. "" THEN GOTO 870
$	DESTINATION = F$EXTRACT(F$LOCATE("DEST=",RECORD)+5,132,RECORD)
$	DESTINATION = F$EXTRACT(0,F$LOCATE(",",DESTINATION),DESTINATION)
$	IF DESTINATION .EQS. "" THEN DESTINATION := 'NAME
$	LIBRARY 'TARGET''DESTINATION' 'LIB_SCRATCH''NAME'/SELECTIVE_SEARCH
$	DELETE 'LIB_SCRATCH''NAME';*
$	GOTO RECORD_LOOP
$LIBDELETE:
$	IF BUILD .EQS. "BUILD" THEN GOTO RECORD_LOOP
$	IF LIB_SCRATCH .EQS. "" THEN GOTO 870
$	DESTINATION = F$EXTRACT(F$LOCATE("DEST=",RECORD)+5,132,RECORD)
$	DESTINATION = F$EXTRACT(0,F$LOCATE(",",DESTINATION),DESTINATION)
$	IF DESTINATION .EQS. "" THEN DESTINATION := 'NAME
$	LIBRARY/DELETE='DESTINATION' 'TARGET''NAME'
$	GOTO RECORD_LOOP
$LIBCOPY:
$	IF BUILD .EQS. "COPY" THEN GOTO RECORD_LOOP
$	DESTINATION = F$EXTRACT(F$LOCATE("DEST=",RECORD)+5,132,RECORD)
$	DESTINATION = F$EXTRACT(0,F$LOCATE(",",DESTINATION),DESTINATION)
$	IF DESTINATION .EQS. "" THEN DESTINATION := 'NAME
$	DELETE 'TARGET''DESTINATION';*
$	COPY/PROTECTION=(S:RWED,O:RWED,G:RWED,W:RE) -
		'SOURCE_DEFAULT''NAME' 'TARGET''DESTINATION'
$	GOTO RECORD_LOOP
$LIBSCRATCH:
$	IF BUILD .EQS. "BUILD" THEN GOTO RECORD_LOOP
$	LIB_SCRATCH = NAME
$	GOTO RECORD_LOOP
$870:	TYPE SYS$INPUT:

The LIBSCRATCH operation must preceed any other LIB operation.
It defines a scratch area (DEV:[DIR]) provided in the NAME field.

$	GOTO RECORD_LOOP
$
$2000:
$	IF SELECT .NES. "ALL" .AND. SELECT .NES. "REQ" THEN GOTO 2100		! System disks only
$	IF TARGET_TOPSYS .EQS. "" THEN GOTO 2100				! Non-flat systems only
$	IF BUILD .EQS. "ADD" THEN GOTO 2100					! Don't change old flat sysexe
$	IF BUILD .EQS. "COPY" THEN GOTO 2020					! Directory entries not needed
$	CREATE_DIRECTORY 'TARGET'[SYSEXEMIN]
$	SET FILE /ENTER='TARGET'[0,0]SYSEXE.DIR;1 'TARGET'[0,0]SYSEXEMIN.DIR;1
$	GOTO 2030
$2020:
$	SET PROTECTION=(W:RWE) 'TARGET'[0,0]SYSEXEMIN.DIR;1			! Make directory writeable
$	SET FILE /REMOVE 'TARGET'[SYSEXEMIN]SYSBOOT.EXE;			! Remove old sysboot synomyn
$2030:
$	SET FILE /ENTER='TARGET'[SYSEXEMIN]SYSBOOT.EXE 'TARGET'['TARGET_TOPSYS'.SYSEXE]SYSBOOT.EXE
$	SET PROTECTION=(S:R,O:R,G,W) 'TARGET'[0,0]SYSEXEMIN.DIR;1
$	SET FILE /REMOVE 'TARGET'['TARGET_TOPSYS'.SYSEXE]SYSBOOT.EXE;
$	SET FILE /ENTER ='TARGET'['TARGET_TOPSYS'.SYSEXE]SYSBOOT.EXE -
		'TARGET'[SYSEXEMIN]SYSBOOT.EXE
$2100:
$3000:	ON CONTROL_Y THEN CONTINUE
$	DISMOUNT/NOUNLOAD 'TARGET'
$3010:	ON CONTROL_Y THEN CONTINUE
$	CLOSE DATAF
$3020:	ON CONTROL_Y THEN CONTINUE
$	SET UIC 'DEFUIC'
$	SET DEFAULT 'DEFDIR'
$	SET PROCESS/PRIV=('SAVED_PRIVS')
$	IF VERIFY THEN SET VERIFY		!Reset verify
