$ !
$ ! [SYSUPD]SWAPFILES.COM - Modify sizes of page, swap, and dump files.
$ !
$ DIR:='F$DIRECTORY()
$ DISK:='F$LOG("SYS$DISK")
$ MODIFIED := FALSE
$ ON CONTROLY THEN GOTO EXIT
$ SET DEFAULT SYS$SYSTEM
$ SYSGEN:=$SYS$SYSTEM:SYSGEN
$ WRITE SYS$OUTPUT "To leave a file size at its current value type a"
$ WRITE SYS$OUTPUT "carriage return in response to its size prompt."
$ WRITE SYS$OUTPUT "Current file sizes are:"
$ DIRECTORY PAGEFILE.SYS,SYSDUMP.DMP,SWAPFILE*.SYS/SIZE
$ WRITE SYS$OUTPUT ""
$ FREEBLOCKS = F$GETDVI ("SYS$SYSDEVICE", "FREEBLOCKS")
$ WRITE SYS$OUTPUT "There are ''FREEBLOCKS' available blocks on SYS$SYSDEVICE."
$ WRITE SYS$OUTPUT ""
$GET_PAGE:
$ INQUIRE PAGEFILE "Enter new size for paging file"
$ IF PAGEFILE .EQS. "" THEN GOTO GET_DUMP
$ PAGEFILE = F$INTEGER (PAGEFILE)
$ IF PAGEFILE .EQ. 0 THEN GOTO GET_PAGE
$CREATE_PAGE:
$ SYSGEN CREATE PAGEFILE.SYS /SIZE='PAGEFILE' /NOCONTIG 
$ SET PROT=(S:RWED,O:RWED,G,W) SYS$SYSTEM:PAGEFILE.SYS
$ SET FILE /NOBACKUP SYS$SYSTEM:PAGEFILE.SYS
$ MODIFIED := TRUE
$GET_DUMP:
$ INQUIRE SYSDUMP "Enter new size for system dump file"
$ IF SYSDUMP .EQS. "" THEN GOTO CHECK_SWAP
$ IF SYSDUMP .LT. 3 THEN SYSDUMP=3
$ SYSGEN CREATE SYSDUMP.DMP /SIZE='SYSDUMP' /NOCONTIG 
$ SET PROT=(S:RWED,O:RWED,G,W) SYS$SYSTEM:SYSDUMP.DMP
$ SET FILE /NOBACKUP SYS$SYSTEM:SYSDUMP.DMP
$ MODIFIED := TRUE
$
$CHECK_SWAP:
$ NEW = "new "
$ FILE = F$SEARCH("SWAPFILE*.SYS")
$ IF FILE .NES. "" THEN GOTO GET_SWAP
$ INQUIRE/NOPUNCTUATION CREATE "Do you wish to create a swapping file [NO]? "
$ IF CREATE .EQS. "" THEN CREATE = "NO"
$ IF .NOT. CREATE THEN GOTO EXIT
$ NEW = ""
$ FILE = "SWAPFILE.SYS"
$ IF F$GETDVI("SYS$SYSDEVICE","MAXBLOCK") .LT. 25000 THEN FILE = "SWAPFILE1.SYS"
$GET_SWAP:
$ INQUIRE/NOPUNCTUATION SWAPSIZE "Enter ''NEW'size for swapping file: "
$ IF SWAPSIZE .EQS. "" THEN GOTO EXIT
$ IF F$STRING(F$INTEGER(SWAPSIZE)) .NES. SWAPSIZE THEN GOTO GET_SWAP
$ FILE = "SYS$SYSTEM:''F$PARSE(FILE,,,"NAME").SYS"
$ SYSGEN CREATE 'FILE/SIZE='SWAPSIZE/NOCONTIGUOUS
$ SET PROTECTION=(S:RWED,O:RWED,G,W) 'FILE
$ SET FILE/NOBACKUP 'FILE
$ MODIFIED := TRUE
$
$EXIT:
$ SET DEFAULT 'DISK''DIR'
$ IF .NOT. MODIFIED THEN EXIT
$ TYPE SYS$INPUT

************************************************************************
*  Please reboot in order for the new files to be used by the system.  *
*  After rebooting, purge obsolete copies of the files.                *
*  DO NOT delete the old files until after the reboot.                 *
************************************************************************

$
$ EXIT
