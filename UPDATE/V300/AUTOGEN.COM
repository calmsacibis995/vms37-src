$ ! AUTOGEN procedure - This procedure is a collection of 4 subprocedures
$ !			that attempt to configure a VMS system for a sites
$ !			hardware environment and typical user needs.
$ !	Authors:
$ !		Herb Jacobs
$ !		Steve Beckhardt
$ !
$ ! The 4 subprocedures are:
$ !
$ !	GETCONFIG - Used to determine the current hardware configuration
$ !	SAVPARAMS - Used in an upgrade to propogate a previously running
$ !		    systems requirements into the new system.
$ !	GENPAR	  - Used to normalize values coming from an upgrade and
$ !		    a new installation and produce a user editable
$ !		    requirements file.
$ !	AUTOGEN	  - Used to process a user requirements file into sysgen
$ !		    parameters, installed image list, and paging, swapping
$ !		    and dump files.
$
$ IF P1.eqs."" then goto AUTOGEN
$ IF P1.eqs."CONFIG" then goto GETCONFIG
$ IF P1.eqs."SAVE" then goto SAVPARAMS
$ IF P1.eqs."GENPAR" then goto GENPAR
$ IF P1.eqs."REBOOT" then goto AUTOGEN
$ IF P1.eqs."SHUTDOWN" then goto AUTOGEN
$ WRITE SYS$OUTPUT "%AUTOGEN-E-Unrecognized command request"
$ EXIT
$
$ !
$ !	GETCONFIG -	Command file to get configuration data on 
$ !			running system.  Creates file CONFIG.DAT.
$ !
$
$GETCONFIG:
$ ON CONTROL_Y THEN GOTO INTERRUPTED
$ SET NOON
$ DEFINE/USER SYS$OUTPUT NL:
$ DEFINE/USER SYS$ERROR NL:
$ DELETE SYS$SYSTEM:CONFIG.DAT;*,SHOWMEM.TMP;*,DEV.TMP;* ! Delete old versions
$ OPEN/WRITE/ERROR=CREATERR CONFIG SYS$SYSTEM:CONFIG.DAT ! Open output file
$
$ !	Get system version number (by using F$GETSYI)
$
$ VERS = F$GETSYI("VERSION")
$ WRITE CONFIG "VERSION:=",VERS
$
$ !	Get cpu type (by using F$GETSYI)
$
$ CPU = F$GETSYI("CPU")
$ WRITE CONFIG "CPUTYPE=",CPU
$
$ !	Get SID (by using F$GETSYI)
$
$ SID = F$GETSYI("SID")
$ WRITE CONFIG "SID=",SID
$
$ !	Get memory size (by parsing output from SHOW MEMORY command)
$
$ DEFINE/USER SYS$OUTPUT SYS$SYSTEM:SHOWMEM.TMP
$ SHOW MEMORY					! Write SHOW MEM info to a file
$ OPEN/READ/ERROR=OPENERR TEMPFILE SYS$SYSTEM:SHOWMEM.TMP
$ 10:
$     READ TEMPFILE LINE			! Read next line in file
$     LINELEN = F$LENGTH(LINE)			! Get length of line and look
$     IF F$LOCATE("Main Memory",LINE) .EQ. LINELEN THEN GOTO 10	! for right one
$ TMP1 = F$LOCATE(")",LINE)
$ GG = LINELEN-TMP1-1
$ GGG = TMP1 + 1
$ MEM := 'F$EXTRACT(GGG,GG,LINE)	! Extract line after ")"
$ TMP1 = F$LOCATE(" ",MEM)
$ MEM := 'F$EXTRACT(0,TMP1,MEM)			! Extract memory size
$ WRITE CONFIG "MEMSIZE=",MEM
$ CLOSE TEMPFILE
$ DELETE SYS$SYSTEM:SHOWMEM.TMP;*
$
$ !	Get system disk speed indicator and free blocks (by using F$GETDVI)
$
$ DISK = -1					! Assume unknown disk
$ DEVNAM = F$GETDVI("SYS$SYSDEVICE","DEVNAM")	! Get device name of system disk
$ DEVNAM = F$EXTRACT(1,2,DEVNAM)		! Extract type of disk
$ IF DEVNAM .EQS. "DL" .OR. DEVNAM .EQS. "DQ" THEN DISK = 1 ! Low speed disks
$ IF DEVNAM .EQS. "DM" THEN DISK = 2  		! Medium speed disks
$ IF DEVNAM .EQS. "DB" .OR. DEVNAM .EQS. "DR" .OR. -
     DEVNAM .EQS. "DU" THEN DISK = 4  		! High speed disks
$ WRITE CONFIG "SYSDISK=",DISK
$
$ !	Get # of various devices (by doing a SHOW DEVICE)
$
$ DEFINE/USER SYS$OUTPUT SYS$SYSTEM:DEV.TMP
$ SHOW DEVICE					! Write SHOW DEV info to a file
$ OPEN/READ/ERROR=OPENERR TEMPFILE SYS$SYSTEM:DEV.TMP
$ READ TEMPFILE LINE				! Read header lines
$ READ TEMPFILE LINE
$ READ TEMPFILE LINE
$ NUMTERMS = 0					! Initialize # of devices
$ NUMTAPES = 0
$ NUMDISKS = 0
$ NUMCOMMS = 0
$ NUMPRINTERS = 0
$ NUMDEVICES = 0
$ 20:
$     READ/END_OF_FILE=30 TEMPFILE LINE 	! Read next line in file
$     DEVTYPE = F$EXTRACT(2,1,LINE)		! Get first char. of dev. name
$     IF DEVTYPE .EQS. "T" THEN NUMTERMS = NUMTERMS + 1
$     IF DEVTYPE .EQS. "M" THEN NUMTAPES = NUMTAPES + 1
$     IF DEVTYPE .EQS. "D" THEN NUMDISKS = NUMDISKS + 1
$     IF DEVTYPE .EQS. "X" THEN NUMCOMMS = NUMCOMMS + 1
$     IF DEVTYPE .EQS. "P" THEN NUMCOMMS = NUMCOMMS + 4
$     IF DEVTYPE .EQS. "L" THEN NUMPRINTERS = NUMPRINTERS + 1
$     NUMDEVICES = NUMDEVICES + 1
$     GOTO 20
$ 30:
$ CLOSE TEMPFILE 
$ DELETE SYS$SYSTEM:DEV.TMP;*
$ WRITE CONFIG "NUMTERMS=",NUMTERMS
$ WRITE CONFIG "NUMTAPES=",NUMTAPES
$ WRITE CONFIG "NUMDISKS=",NUMDISKS
$ WRITE CONFIG "NUMCOMMS=",NUMCOMMS
$ WRITE CONFIG "NUMPRINTERS=",NUMPRINTERS
$ WRITE CONFIG "NUMDEVICES=",NUMDEVICES
$
$ CLOSE CONFIG
$ EXIT
$
$ !
$ !	Error handling routines
$ !
$
$ CREATERR:
$ WRITE SYS$OUTPUT "%AUTOGEN-E-Unable to create CONFIG.DAT file"
$ EXIT
$
$ OPENERR:
$ WRITE SYS$OUTPUT "%AUTOGEN-E-Error opening TEMP file"
$ CLOSE CONFIG
$ EXIT
$
$ INTERRUPTED:
$ CLOSE TEMPFILE
$ CLOSE CONFIG
$ EXIT
$
$ ! SAVPARAMS - This command procedure saves the old site parameters and
$ !		    the old defaults.  It writes the following files:  
$ !		OLDSITE1.LIS 	contains those parameters that 
$ !				should be preserved as is.
$ !		OLDSITE2.LIS	contains those parameters that should be
$ !				maximized with the new defaults.
$ !		OLDSITE3.LIS	contains those parameters that need to
$ !				examined for informational purposes.
$ !		OLDSITE4.LIS	contains those parameters that need to be
$ !				examined for other special purposes
$
$SAVPARAMS:
$ DEFINE/USER SYS$OUTPUT NL:
$ DEFINE/USER SYS$ERROR NL:
$ DELETE SYS$SYSTEM:OLDSITE1.LIS;*,OLDSITE2.LIS;*,-	! Delete old copies
		    OLDSITE3.LIS;*,OLDSITE4.LIS;*
$
$ IF "''F$LOGICAL("SYS$SYSROOT")'".NES."" then goto v3old
$
$ !	First create OLDSITE1.LIS for V2
$
$ DEFINE/USER SYS$OUTPUT SYS$SYSTEM:OLDSITE1.LIS
$ SAVEVER = 'F$VERIFY(0)			! Turn off verify
$ RUN SYS$SYSTEM:SYSGEN
USE CURRENT
SHOW EXTRACPU
SHOW MAXSYSGROUP
SHOW XFMAXRATE
SHOW LAMAPREGS
SHOW REALTIME_SPTS
SHOW BUGREBOOT
SHOW CRDENABLE
SHOW DUMPBUG
SHOW UAFALTERNATE
SHOW TTYSCANDELTA
SHOW DIALTYPE
SHOW TTY_BUF
SHOW TTY_TYPAHDSZ
SHOW TTY_PROT
SHOW TTY_OWNER
SHOW PQL_DCPULM
SHOW PQL_MCPULM
SHOW PQL_DPRCLM
SHOW PQL_MPRCLM
SHOW PQL_DTQELM
SHOW PQL_MTQELM
SHOW MAXPRINTSYMB
SHOW DEFPRI
SHOW ACP_WRITEBACK
SHOW ACP_DATACHECK
SHOW ACP_BASEPRIO
SHOW ACP_SWAPFLGS
$ SAVEVER = 'F$VERIFY(SAVEVER)			! Restore verify mode
$ GOTO OLD2
$V3OLD:
$
$ !	First create OLDSITE1.LIS for V3
$
$ DEFINE/USER SYS$OUTPUT SYS$SYSTEM:OLDSITE1.LIS
$ SAVEVER = 'F$VERIFY(0)			! Turn off verify
$ RUN SYS$SYSTEM:SYSGEN
USE CURRENT
SHOW EXTRACPU
SHOW MAXSYSGROUP
SHOW XFMAXRATE
SHOW LAMAPREGS
SHOW REALTIME_SPTS
SHOW BUGREBOOT
SHOW CRDENABLE
SHOW DUMPBUG
SHOW BUGCHECKFATAL
SHOW UAFALTERNATE
SHOW SCSSYSTEMID
SHOW TTY_SCANDELTA
SHOW TTY_DIALTYPE
SHOW TTY_BUF
SHOW TTY_TYPAHDSZ
SHOW TTY_PROT
SHOW TTY_OWNER
SHOW PQL_DCPULM
SHOW PQL_MCPULM
SHOW PQL_DPRCLM
SHOW PQL_MPRCLM
SHOW PQL_DTQELM
SHOW PQL_MTQELM
SHOW MAXPRINTSYMB
SHOW DEFPRI
SHOW ACP_WRITEBACK
SHOW ACP_DATACHECK
SHOW ACP_BASEPRIO
SHOW ACP_SWAPFLGS
$ SAVEVER = 'F$VERIFY(SAVEVER)			! Restore verify mode
$OLD2:
$ !	Now do OLDSITE2.LIS
$
$ DEFINE/USER SYS$OUTPUT SYS$SYSTEM:OLDSITE2.LIS
$ SAVEVER = 'F$VERIFY(0)			! Turn off verify
$ RUN SYS$SYSTEM:SYSGEN
USE CURRENT
SHOW INTSTKPAGES
SHOW LRPSIZE
SHOW MAXBUF
SHOW DEFMBXBUFQUO
SHOW DEFMBXMXMSG
SHOW DEFMBXNUMMSG
SHOW CLISYMTBL
SHOW PQL_DASTLM
SHOW PQL_MASTLM
SHOW PQL_DBIOLM
SHOW PQL_MBIOLM
SHOW PQL_DBYTLM
SHOW PQL_MBYTLM
SHOW PQL_DDIOLM
SHOW PQL_MDIOLM
SHOW PQL_DFILLM
SHOW PQL_MFILLM
SHOW PQL_DWSDEFAULT
SHOW PQL_MWSDEFAULT
SHOW PQL_DWSQUOTA
SHOW PQL_MWSQUOTA
SHOW ACP_FIDCACHE
SHOW ACP_EXTCACHE
SHOW ACP_EXTLIMIT
$ SAVEVER = 'F$VERIFY(SAVEVER)			! Restore verify mode
$
$ !	Now do OLDSITE3.LIS
$
$ DEFINE/USER SYS$OUTPUT SYS$SYSTEM:OLDSITE3.LIS
$ SAVEVER = 'F$VERIFY(0)			! Turn off verify
$ RUN SYS$SYSTEM:SYSGEN
USE CURRENT
SHOW GBLSECTIONS
SHOW GBLPAGES
SHOW WSMAX
$ SAVEVER = 'F$VERIFY(SAVEVER)			! Restore verify mode
$
$ !	Now do OLDSITE4.LIS
$
$ DEFINE/USER SYS$OUTPUT SYS$SYSTEM:OLDSITE4.LIS
$ SAVEVER = 'F$VERIFY(0)			! Turn off verify
$ RUN SYS$SYSTEM:SYSGEN
USE CURRENT
SHOW MAXPROCESSCNT
SHOW VIRTUALPAGECNT
$ SAVEVER = 'F$VERIFY(SAVEVER)			! Restore verify mode
$ EXIT
$
$ !
$ ! GENPAR	Command procedure to make first pass at generating
$ !		site specific parameter file.
$ !	Input is:
$ !		CONFIG.DAT	which contains hardware configuration 
$ !				information.
$ !		Files OLDSITE*.LIS which contain former parameter settings
$ !				and their defaults.
$ !	Output is:
$ !		PARAMS.DAT	which contains first cut at certain 
$ !				parameter settings.
$
$GENPAR:
$ ON CONTROL_Y THEN GOTO INTERRUPTED1
$ SET NOON
$ DEFINE/USER SYS$OUTPUT NL:
$ DEFINE/USER SYS$ERROR NL:
$ DELETE SYS$SYSTEM:PARAMS.DAT;*,NEWDEF.LIS;*		! Delete old copies
$ OPEN/WRITE/ERROR=CREATERR PAR1 SYS$SYSTEM:PARAMS.DAT
$
$ !	Write out raw configuration data
$
$ FILENAME = "CONFIG.DAT"
$ OPEN/READ/ERROR=OPENERR1 CONFIG SYS$SYSTEM:'FILENAME
$ 50:
$ READ/END_OF_FILE=60 CONFIG LINE
$ WRITE PAR1 LINE
$ 'LINE						! Execute the line too
$ GOTO 50
$ 60:
$ CLOSE CONFIG
$
$ !	Define symbol UPGRADE to be null or non-null depending
$ !	on whether this is an upgrade or not.
$ !	If the file OLDSITE1.LIS is not present in system directory
$ !	then assume that this is a new installation, not an upgrade
$
$ UPGRADE = F$SEARCH("SYS$SYSTEM:OLDSITE1.LIS",)
$
$ !	Calculate values for MAXPROCESSCNT and VIRTUALPAGECNT
$
$ DECNET = 0
$ IF NUMCOMMS .NE. 0 THEN DECNET = 4 + (NUMTERMS/20)
$ ACPS = 1 + (NUMDISKS / 8)
$ ACPS = ACPS + ((NUMTAPES + 3) / 4)
$ TERMFACTOR = NUMTERMS + (NUMTERMS / 10)
$ MAXPCNT = TERMFACTOR + DECNET + NUMPRINTERS + ACPS + 5
$ MAXPCNT = ((MAXPCNT+4)/5)*5		! Round up to nearest mult. of 5
$ IF MAXPCNT.GT.50 THEN MAXPCNT = ((MAXPCNT + 5) / 10) * 10
$
$ VPAGECNT = MEMSIZE + 2048
$ IF VPAGECNT .LT. 8192 THEN VPAGECNT = 8192
$
$ !	If this is an upgrade, maximize the calculated MAXPROCESSCNT 
$ !	and VIRTUALPAGECNT with their old values.
$	
$ IF UPGRADE .EQS. "" THEN GOTO 90
$ FILENAME = "OLDSITE4.LIS"
$ OPEN/READ/ERROR=OPENERR1 OLDSITE SYS$SYSTEM:'FILENAME
$ 70:
$ READ/END_OF_FILE=80 OLDSITE LINE
$ SYM = F$EXTRACT(2,15,LINE)
$ OLDVAL = 'F$EXTRACT(17,10,LINE)
$ OLD_'SYM = OLDVAL
$ GOTO 70
$ 80:
$ CLOSE OLDSITE
$ IF OLD_MAXPROCESSCNT .GT. MAXPCNT THEN MAXPCNT = OLD_MAXPROCESSCNT
$ IF OLD_VIRTUALPAGECNT .GT. VPAGECNT THEN VPAGECNT = OLD_VIRTUALPAGECNT
$
$ !	Write out values for MAXPROCESSCNT and VIRTUALPAGECNT
$
$ 90:
$ WRITE PAR1 "MAXPROCESSCNT=",MAXPCNT
$ WRITE PAR1 "VIRTUALPAGECNT=",VPAGECNT
$
$ !	Skip remaining stuff if this is a new installation
$
$ IF UPGRADE .EQS. "" THEN GOTO DONE
$
$ !	Output the values for the parameters in OLDSITE3.LIS.
$ !	The parameter name is preceded by "OLD_" to indicate
$ !	that this is an informational parameter setting, not a required
$ !	parameter setting.
$
$ FILENAME = "OLDSITE3.LIS"
$ OPEN/READ/ERROR=OPENERR1 OLDSITE SYS$SYSTEM:'FILENAME
$ 100:
$ READ/END_OF_FILE=110 OLDSITE LINE
$ SYM = F$EXTRACT(2,15,LINE)
$ OLDVAL = 'F$EXTRACT(17,10,LINE)
$ SYM := 'SYM					! Remove trailing blanks
$ WRITE PAR1 "OLD_",SYM,"=",OLDVAL
$ GOTO 100
$ 110:
$ CLOSE OLDSITE
$
$ !	Output the parameters in OLDSITE1.LIS only if their old value
$ !	is not equal to the old default value (i.e. they were explicitly
$ !	set and this setting should be preserved).
$
$ FILENAME = "OLDSITE1.LIS"
$ OPEN/READ/ERROR=OPENERR1 OLDSITE SYS$SYSTEM:'FILENAME
$ 120:
$ READ/END_OF_FILE=130 OLDSITE LINE
$ SYM = F$EXTRACT(2,15,LINE)
$ OLDVAL = 'F$EXTRACT(17,10,LINE)
$ OLDDEF = 'F$EXTRACT(27,10,LINE)
$ IF OLDVAL .EQ. OLDDEF THEN GOTO 120
$ SYM := 'SYM					! Remove trailing blanks
$ WRITE PAR1 SYM,"=",OLDVAL
$ GOTO 120
$ 130:
$ CLOSE OLDSITE
$
$ !	Output the parameters in OLDSITE2.LIS only if their old value
$ !	is not equal to the old default value (i.e. they were explicitly
$ !	set and this setting should be preserved) and the old value is
$ !	greater than the version 3 default.
$
$ !	First run through the parameters in OLDSITE2.LIS and create DCL 
$ !	symbols for them if their value is not equal to the old default value.
$
$ FILENAME = "OLDSITE2.LIS"
$ OPEN/READ/ERROR=OPENERR1 OLDSITE SYS$SYSTEM:'FILENAME
$ 140:
$ READ/END_OF_FILE=150 OLDSITE LINE
$ SYM = F$EXTRACT(2,15,LINE)
$ OLDVAL = 'F$EXTRACT(17,10,LINE)
$ OLDDEF = 'F$EXTRACT(27,10,LINE)
$ IF OLDVAL .EQ. OLDDEF THEN GOTO 140
$ 'SYM = OLDVAL
$ GOTO 140
$ 150:
$ CLOSE OLDSITE
$
$ !	Now create a file containing the new defaults and compare
$ !	with the DCL symbols just created.
$
$ DEFINE/USER SYS$OUTPUT SYS$SYSTEM:NEWDEF.LIS
$ SAVEVER = F$VERIFY(0)				! Turn off verify
$ RUN SYS$SYSTEM:SYSGEN
USE DEFAULT
SHOW INTSTKPAGES
SHOW MAXBUF
SHOW DEFMBXBUFQUO
SHOW DEFMBXMXMSG
SHOW DEFMBXNUMMSG
SHOW CLISYMTBL
$ SAVEVER = F$VERIFY(SAVEVER)			! Restore verify mode
$ FILENAME = "NEWDEF.LIS"
$ OPEN/READ/ERROR=OPENERR1 NEWDEF SYS$SYSTEM:'FILENAME
$ 160:
$ READ/END_OF_FILE=170 NEWDEF LINE
$ SYM = F$EXTRACT(2,15,LINE)
$ TEMP = "'" + SYM				! See if this parameter
$ TEMP := 'TEMP'				! is defined
$ IF TEMP .EQS. "" THEN GOTO 160
$ DEFVAL = 'F$EXTRACT(27,10,LINE)
$ IF 'SYM .LE. DEFVAL THEN GOTO 160
$ SYM := 'SYM					! Remove trailing blanks
$ WRITE PAR1 SYM,"=",'SYM
$ GOTO 160
$ 170:
$ CLOSE NEWDEF
$ DELETE SYS$SYSTEM:NEWDEF.LIS;*
$
$ !	Write sizes of old PAGEFILE, SWAPFILE, AND SYSDUMP
$
$ !ON ERROR THEN GOTO 180
$ !SIZE = F$FILE_ATTRIBUTES("SYS$SYSTEM:PAGEFILE.SYS","ALQ")
$ !WRITE PAR1 "OLD_PAGEFILE=",SIZE
$ !SIZE = F$FILE_ATTRIBUTES("SYS$SYSTEM:SWAPFILE.SYS","ALQ")
$ !WRITE PAR1 "OLD_SWAPFILE=",SIZE
$ !SIZE = F$FILE_ATTRIBUTES("SYS$SYSTEM:SYSDUMP.DMP","ALQ")
$ !WRITE PAR1 "OLD_DUMPFILE=",SIZE
$ 180:
$ ON ERROR THEN GOTO INTERRUPTED1
$ DONE:
$ CLOSE PAR1
$ DEFINE/USER SYS$OUTPUT NL:
$ DEFINE/USER SYS$ERROR NL:
$ DELETE SYS$SYSTEM:OLDSITE%.LIS;*
$ EXIT
$
$ !
$ !	Error handling routines
$ !
$
$ CREATERR:
$ WRITE SYS$OUTPUT "%AUTOGEN-E-Unable to create PARAMS.DAT file"
$ EXIT
$
$ OPENERR1:
$ WRITE SYS$OUTPUT "%AUTOGEN-E-Unable to open input file ''FILENAME'"
$ CLOSE PAR1
$ IF FILENAME.eqs."CONFIG.DAT" then WRITE SYS$OUTPUT -
"%AUTOGEN-E-Start from the beginning with @SYS$UPDATE:AUTOGEN CONFIG"
$ EXIT
$
$ INTERRUPTED1:
$ CLOSE PAR1
$ CLOSE NEWDEF
$ CLOSE OLDSITE
$ CLOSE CONFIG
$ EXIT
$
$ !
$ ! AUTOGEN.COM	Command procedure to merge default sysgen parameters with
$ !		system manager edited inputs and previous sysgen values in
$ !		the case of an upgrade.
$ !
$ !   inputs:
$ !		PARAMS.DAT
$ !		which contains hardware configuration information,
$ !		hand edited system manager inputs, and in the case of an
$ !		upgrade former parameter values that are site specific.
$ !
$ !   outputs:
$ !		AUTOGEN.PAR - the new sysgen parameters for this release.
$ !		VMSIMAGES.DAT - images to be installed
$ !		SWAPFILE.SYS
$ !		PAGEFILE.SYS
$ !		SYSDUMP.DMP
$
$AUTOGEN:
$ SET NOON
$ ON CONTROL_Y THEN GOTO INTERRUPTED2
$
$ ! Delete old versions of files
$
$ DEFINE/USER SYS$OUTPUT NL:
$ DEFINE/USER SYS$ERROR NL:
$ DELETE SYS$MANAGER:VMSIMAGES.DAT;2,VMSIMAGES.DAT;3,VMSIMAGES.TMP;*, -
	 SYS$SYSTEM:PARMS.TMP;*,SETPARMS.COM;*
$
$ !	If the file PARAMS.DAT is not present in this directory
$ !	then issue error and exit.
$
$ OPEN/READ/ERROR=NOPAR1 INPUTS SYS$SYSTEM:PARAMS.DAT
$ 
$ !	Read all the requested input values and make DCL symbols for them
$ !	for easy access.
$
$ 200:
$ READ/END_OF_FILE=210 INPUTS LINE
$ 'LINE
$ GOTO 200
$ 210:
$ CLOSE INPUTS
$
$ IF F$GETSYI("SID").eq.SID then goto 220
$ WRITE SYS$OUTPUT -
"%AUTOGEN-W-SID register indicates @SYS$UPDATE:AUTOGEN CONFIG performed"
$ WRITE SYS$OUTPUT -
"           on a different hardware configuration.  PROCEEDING."
$
$220:
$ ! NPAGEDYN
$
$ if "''NPAGEDYN'".eqs."" then NPAGEDYN = 50000 + -
	NUMCOMMS * 2000 + -
	MAXPROCESSCNT * 600
$
$ ! NPAGEVIR
$
$ if "''NPAGEVIR'".eqs."" then NPAGEVIR = NPAGEDYN * 3
$
$ ! SRPCOUNT
$
$ if "''SRPCOUNT'".eqs."" then SRPCOUNT = 100 + -
	MAXPROCESSCNT * 4
$
$ ! SRPCOUNTV
$
$ if "''SRPCOUNTV'".eqs."" then SRPCOUNTV = SRPCOUNT * 3
$ if SRPCOUNTV.lt.350 then SRPCOUNTV = 350
$
$ ! IRPCOUNT
$
$ if "''IRPCOUNT'".eqs."" then IRPCOUNT = 50 + -
	MAXPROCESSCNT * 3
$
$ ! IRPCOUNTV
$
$ if "''IRPCOUNTV'".eqs."" then IRPCOUNTV = IRPCOUNT * 3
$ if IRPCOUNTV.lt.200 then IRPCOUNTV = 200
$
$ ! LRPCOUNT
$
$ temp = 2 + NUMCOMMS * 6
$ if MEMSIZE.lt.2048 .and. temp.gt.24 then temp = 24
$ if "''LRPCOUNT'".eqs."" then LRPCOUNT = temp
$
$ ! LRPCOUNTV
$
$ if "''LRPCOUNTV'".eqs."" then LRPCOUNTV = LRPCOUNT * 3
$ if LRPCOUNTV.lt.60 then LRPCOUNTV=60
$
$ ! VIRTUALPAGECNT
$
$ if "''VIRTUALPAGECNT'".eqs."" then VIRTUALPAGECNT = 8192
$ if VIRTUALPAGECNT.lt.8192 then VIRTUALPAGECNT = 8192
$ if VIRTUALPAGECNT.lt.MEMSIZE+2048 then VIRTUALPAGECNT = MEMSIZE + 2048
$
$ ! BALSETCNT
$
$ temp = ((VIRTUALPAGECNT*10)/MEMSIZE)
$ if MEMSIZE .lt. 4096 then temp = temp / 2
$ temp = MAXPROCESSCNT - ( (MAXPROCESSCNT * temp) / 100 )
$ if MEMSIZE .lt. 4096 then temp = temp / 2
$ if "''BALSETCNT'".eqs."" then BALSETCNT = temp
$ if BALSETCNT .gt. MAXPROCESSCNT - 2  then BALSETCNT = MAXPROCESSCNT - 2
$ if BALSETCNT .lt. 2 then BALSETCNT = 2
$
$ ! WSMAX
$
$ temp = MEMSIZE - 1024
$ if temp.gt.3072 then temp = 3072
$ if temp.lt.512 then temp = 300
$ if "''WSMAX'".eqs."" then WSMAX = temp
$ 
$ ! LOCKIDTBL
$
$ temp = MAXPROCESSCNT * 2
$ if temp .lt. 64 then temp = 64
$ if "''LOCKIDTBL'".eqs."" then LOCKIDTBL = temp
$
$ ! RESHASHTBL
$
$ if "''RESHASHTBL'".eqs."" then RESHASHTBL = LOCKIDTBL / 4
$ oldtemp = 2
$reshash1:
$ temp = oldtemp * 2
$ if RESHASHTBL .le. temp then goto reshash2
$ oldtemp = temp
$ goto reshash1
$reshash2:
$ if oldtemp+temp .ge. RESHASHTBL * 2 then temp = oldtemp
$ RESHASHTBL = temp
$
$ ! PFCDEFAULT
$
$ if "''PFCDEFAULT'".eqs."" then PFCDEFAULT = SYSDISK * 16
$
$ ! FREELIM
$
$ temp = BALSETCNT
$ if temp.gt.64 then temp = 64
$ if temp.lt.16 then temp = 16
$ if "''FREELIM'".eqs."" .and. temp.ne.64 then FREELIM = temp
$
$ ! FREEGOAL
$
$ if "''FREELIM'".eqs."" then goto MPW
$ if "''FREEGOAL'".eqs."" then FREEGOAL = FREELIM * 3
$ if FREEGOAL .lt. FREELIM then FREEGOAL = FREELIM
$
$ ! GROWLIM
$
$ if "''GROWLIM'".nes."" then goto MPW
$ if "''FREELIM'".nes."" then GROWLIM = FREELIM - 1
$
$MPW:
$ ! Modified page writer parameters
$
$ ! MPW_LOLIMIT
$
$ temp = BALSETCNT * 3
$ if temp .gt. 120 then temp = 120
$ if "''MPW_LOLIMIT'".eqs."" then MPW_LOLIMIT = temp
$
$ ! MPW_WAITLIMIT
$
$ if "''MPW_HILIMIT'".eqs."" then goto ACP
$ if "''MPW_WAITLIMIT'".eqs."" then MPW_WAITLIMIT = MPW_HILIMIT
$ if MPW_WAITLIMIT .lt. MPW_HILIMIT then MPW_WAITLIMIT = MPW_HILIMIT
$
$ACP:
$ ! Setting of the ACP parameters
$
$ ! ACP_MULTIPLE
$
$ temp = 0
$ if MEMSIZE.ge.2048 then temp = 1
$ if "''ACP_MULTIPLE'".eqs."" then ACP_MULTIPLE = temp
$
$ ! ACP_MAPCACHE
$
$ temp = NUMDISKS * 2
$ if temp.lt.8 then temp = 8
$ if "''ACP_MAPCACHE'".eqs."" then ACP_MAPCACHE = temp
$
$ ! ACP_HDRCACHE
$
$ temp = BALSETCNT * 2
$ if temp.lt.20 then temp = 20
$ if "''ACP_HDRCACHE'".eqs."" then ACP_HDRCACHE = temp
$
$ ! ACP_DIRCACHE
$
$ temp = BALSETCNT * 2
$ if temp.lt.20 then temp = 20
$ if "''ACP_DIRCACHE'".eqs."" then ACP_DIRCACHE = temp
$
$ ! ACP_QUOCACHE
$
$ if "''ACP_QUOCACHE'".eqs."" then ACP_QUOCACHE = MAXPROCESSCNT
$
$ ! ACP_SYSACC
$
$ temp = BALSETCNT / NUMDISKS
$ if temp.lt.4 then temp = 4
$ if "''ACP_SYSACC'".eqs."" then ACP_SYSACC = temp
$
$ ! ACP_SWAPFLGS
$
$ temp = 15
$ if MEMSIZE.gt.2048 then temp = 14
$ if MEMSIZE.eq.2048 .and. BALSETCNT.gt.24 then temp = 14
$ if "''ACP_SWAPFLGS'".eqs."" then ACP_SWAPFLGS = temp
$
$ ! Set up for single line sysgen invocations
$
$ SYSGEN := $SYSGEN
$
$ SYSDISKSIZE = F$GETDVI("SYS$SYSDEVICE","MAXBLOCK")
$ SMALLDISK = 0
$ IF SYSDISKSIZE.lt.25000 then SMALLDISK = 1
$
$ ! Calculate PAGEFILE.SYS size
$
$pagefile:
$ temp = 2000 + (400 * MAXPROCESSCNT)
$ if temp.lt.(VIRTUALPAGECNT * 2) then temp = VIRTUALPAGECNT * 2
$ if SMALLDISK then temp = 4604
$ if SMALLDISK .and. MEMSIZE.gt.2048 then temp = temp + 496
$ if "''PAGEFILE'".eqs."" then PAGEFILE = temp
$ temp = F$FILE_ATTRIBUTES("SYS$SYSTEM:PAGEFILE.SYS","ALQ")
$ if temp-(temp/5).le.PAGEFILE .and. temp.ge.PAGEFILE then goto SWAPFILE
$ freeblocks = F$GETDVI("SYS$SYSDEVICE","FREEBLOCKS")
$ if pagefile-temp.gt.freeblocks-1000 then goto perr
$ SYSGEN create SYS$SYSTEM:PAGEFILE.SYS /size='pagefile
$perr:
$ temp = F$FILE_ATTRIBUTES("SYS$SYSTEM:PAGEFILE.SYS","ALQ")
$ IF temp.ge.PAGEFILE then goto SWAPFILE
$ IF PAGEFILE-(PAGEFILE/5).ge.temp then goto SWAPFILE
$ WRITE SYS$OUTPUT -
"%AUTOGEN-E-Error creating PAGEFILE.SYS"
$ WRITE SYS$OUTPUT -
"-          PAGEFILE.SYS needs to be created manually at ''PAGEFILE' blocks"
$
$ ! Calculate SWAPFILE.SYS size
$
$swapfile:
$ temp = 300
$ if WSMAX.lt.temp then temp = WSMAX
$ temp = 2000 + (temp * MAXPROCESSCNT)
$ if SMALLDISK then temp = 1000
$ oneflag=""
$ if SMALLDISK then oneflag="1"
$ if "''SWAPFILE'".eqs."" then SWAPFILE = temp
$ if SWAPFILE.lt.100 then goto dumpfile
$ temp=0
$ if F$SEARCH("SYS$SYSTEM:SWAPFILE''oneflag'.SYS",).eqs."" then goto swapcre
$ temp = F$FILE_ATTRIBUTES("SYS$SYSTEM:SWAPFILE''oneflag'.SYS","ALQ")
$ if temp-(temp/5).le.SWAPFILE .and. temp.ge.SWAPFILE then goto dumpfile
$swapcre:
$ freeblocks = F$GETDVI("SYS$SYSDEVICE","FREEBLOCKS")
$ if swapfile-temp.gt.freeblocks-1000 then goto serr
$ SYSGEN create sys$system:swapfile'oneflag'.sys /size='swapfile
$serr:
$ if F$SEARCH("SYS$SYSTEM:SWAPFILE''oneflag'.SYS",).eqs."" then goto swaperr
$ temp = F$FILE_ATTRIBUTES("SYS$SYSTEM:SWAPFILE''oneflag'.SYS","ALQ")
$ if temp.ge.SWAPFILE then goto dumpfile
$ if SWAPFILE-(SWAPFILE/5).ge.temp then goto dumpfile
$swaperr:
$ WRITE SYS$OUTPUT -
"%AUTOGEN-E-Error creating SWAPFILE''ONEFLAG'.SYS"
$ WRITE SYS$OUTPUT -
"-          SWAPFILE''ONEFLAG'.SYS needs to be created manually at ''SWAPFILE' blocks"
$
$ ! Calculate SYSDUMP.DMP size
$
$dumpfile:
$ temp = MEMSIZE + 4
$ if SMALLDISK .and. "''DUMPFILE'".eqs."" then goto FIXPROT
$ if "''DUMPFILE'".eqs."" then DUMPFILE = temp
$ if DUMPFILE.lt.3 then goto FIXPROT
$ temp=0
$ if F$SEARCH("SYS$SYSTEM:SYSDUMP.DMP",).eqs."" then goto dumpcre
$ temp = F$FILE_ATTRIBUTES("SYS$SYSTEM:SYSDUMP.DMP","ALQ")
$ if temp.ge.DUMPFILE then goto FIXPROT
$dumpcre:
$ freeblocks = F$GETDVI("SYS$SYSDEVICE","FREEBLOCKS")
$ if dumpfile-temp.gt.freeblocks-1000 then goto derr
$ SYSGEN create SYS$SYSTEM:SYSDUMP.DMP /size='dumpfile
$derr:
$ if F$SEARCH("SYS$SYSTEM:SYSDUMP.DMP",).eqs."" then goto dumperr
$ temp = F$FILE_ATTRIBUTES("SYS$SYSTEM:SYSDUMP.DMP","ALQ")
$ if temp.ge.DUMPFILE then goto FIXPROT
$dumperr:
$ WRITE SYS$OUTPUT -
"%AUTOGEN-E-Error creating SYS$SYSTEM:SYSDUMP.DMP"
$ WRITE SYS$OUTPUT -
"-          SYSDUMP.DMP needs to be created manually at ''DUMPFILE' blocks"
$
$FIXPROT:
$ SET PROT=(S:RWED,O:RWED,G,W) SYS$SYSTEM:PAGEFILE.SYS;*
$ SET FILE /NOBACKUP SYS$SYSTEM:PAGEFILE.SYS
$ if F$SEARCH("SYS$SYSTEM:SWAPFILE.SYS",).eqs."" then goto fixprot1
$ SET PROT=(S:RWED,O:RWED,G,W) SYS$SYSTEM:SWAPFILE.SYS;*
$ SET FILE /NOBACKUP SYS$SYSTEM:SWAPFILE.SYS
$fixprot1:
$ if F$SEARCH("SYS$SYSTEM:SWAPFILE1.SYS",).eqs."" then goto fixprot2
$ SET PROT=(S:RWED,O:RWED,G,W) SYS$SYSTEM:SWAPFILE1.SYS;*
$ SET FILE /NOBACKUP SYS$SYSTEM:SWAPFILE1.SYS
$fixprot2:
$ if F$SEARCH("SYS$SYSTEM:SYSDUMP.DMP",).eqs."" then goto vmsimages
$ SET PROT=(S:RWED,O:RWED,G,W) SYS$SYSTEM:SYSDUMP.DMP;*
$ SET FILE /NOBACKUP SYS$SYSTEM:SYSDUMP.DMP
$
$vmsimages:
$
$ C8192S=""
$ C4096S=""
$ C4096O=""
$ CP8192S=""
$ CP4096S=""
$ CP4096O=""
$
$ if MEMSIZE .ge. 8192 then C8192S=" /SHARED"
$ if MEMSIZE .ge. 4096 then C4096S=" /SHARED"
$ if MEMSIZE .ge. 4096 then C4096O=" /OPEN /HEADER"
$ if MEMSIZE .ge. 8192 .and.MAXPROCESSCNT .ge. 48 then CP8192S=" /SHARED"
$ if MEMSIZE .ge. 4096 .and.MAXPROCESSCNT .ge. 48 then CP4096S=" /SHARED"
$ if MEMSIZE .ge. 4096 .and.MAXPROCESSCNT .ge. 48 then CP4096O=" /OPEN /HEADER"
$
$ TGBLPAGES = 103 + 68 + 60 + 67 + 77 + 12 + 51 + 86 + 253 + 252 + 70 + 400
$ TGBLSECTIONS = 1 + 3 + 2  + 5  + 6  + 3  + 3  + 9  + 3   + 1   + 1  + 20
$ if C8192S.nes."" then TGBLPAGES = TGBLPAGES + 12 + 6 + 591 + 11 + 5
$ if C8192S.nes."" then TGBLSECTIONS = TGBLSECTIONS + 3 + 2 + 7 + 3
$ if C4096S.nes."" then TGBLPAGES = TGBLPAGES + 3 + 1
$ if C4096S.nes."" then TGBLSECTIONS = TGBLSECTIONS + 2
$ if C4096S.nes."" .and. NUMCOMMS .ge. 2 then TGBLPAGES = TGBLPAGES + 249 + 2
$ if C4096S.nes."" .and. NUMCOMMS .ge. 2 then TGBLSECTIONS = TGBLSECTIONS + 7
$ if CP8192S.nes."" then TGBLPAGES = TGBLPAGES + 15 + 40 + 2
$ if CP8192S.nes."" then TGBLSECTIONS = TGBLSECTIONS + 1 + 2
$ if CP4096S.nes."" then TGBLPAGES = TGBLPAGES + 40 + 10 + 25 + 23 + 24 + 33 +5
$ if CP4096S.nes."" then TGBLSECTIONS = TGBLSECTIONS + 2 + 1 + 1 + 1 + 2 + 2
$
$ OPEN/WRITE/ERROR=NOVMSIMAGES IMAGES SYS$MANAGER:VMSIMAGES.TMP
$ WRITE IMAGES "SYS$SYSTEM:MCR"
$ WRITE IMAGES "SYS$SHARE:MCRTABLES"
$ WRITE IMAGES "SYS$SYSTEM:REQUEST	/PRIV=(TMPMBX)"
$ WRITE IMAGES "SYS$SYSTEM:INIT		/PRIV=(CMKRNL,PHY_IO,SYSPRV)"
$ WRITE IMAGES "SYS$SYSTEM:INSTALL	/PRIV=(CMKRNL,SYSGBL,PRMGBL)"
$ if SMALLDISK.eq.0 .and. CP4096O .nes. "" then -
  WRITE IMAGES "SYS$SYSTEM:MESSAGE	/OPEN /HEADER"
$ if SMALLDISK.eq.0 .and. C8192S .nes. "" then -
  WRITE IMAGES "SYS$SYSTEM:LIBRARIAN	/OPEN /HEADER"
$ WRITE IMAGES "SYS$SYSTEM:SETP0	/PRIV=(CMKRNL)",C4096O,C4096S
$ if C8192S .nes. "" then -
  WRITE IMAGES "SYS$SHARE:SUMSHR 	/OPEN /SHARED /HEADER"
$ if SMALLDISK.eq.0 .and. C4096S .nes. "" .and. NUMCOMMS .ge. 2 then -
  WRITE IMAGES "SYS$SYSTEM:FAL		/OPEN /SHARED /HEADER"
$ if SMALLDISK.eq.0 then -
  WRITE IMAGES "SYS$SYSTEM:MONITOR	/PRIV=(CMKRNL)",CP4096O
$ if SMALLDISK.eq.1 then -
  WRITE IMAGES "SYS$SYSTEM:MONITOR	/PRIV=(CMKRNL)"
$ if SMALLDISK.eq.0 then -
  WRITE IMAGES "SYS$SYSTEM:CLEDITOR	/PRIV=(CMEXEC)",CP4096O
$ if SMALLDISK.eq.1 then -
  WRITE IMAGES "SYS$SYSTEM:CLEDITOR	/PRIV=(CMEXEC)"
$ if CP4096O .nes. "" then -
  WRITE IMAGES "SYS$SYSTEM:VMSHELP	/OPEN /HEADER"
$ if CP4096O .nes. "" then -
  WRITE IMAGES "SYS$SYSTEM:TYPE		/OPEN /HEADER"
$ if SMALLDISK.eq.0 .and. C4096S .nes. "" .and. NUMCOMMS .ge. 2 then -
  WRITE IMAGES "SYS$SHARE:NMLSHR	/OPEN /HEADER /SHARED"
$ if C4096O .nes. "" then -
  WRITE IMAGES "SYS$SHARE:TRACE		/OPEN /HEADER",C8192S
$ if SMALLDISK.eq.0 .and. C8192S .nes. "" then -
  WRITE IMAGES "SYS$SYSTEM:LINK		/OPEN /HEADER"
$ if C4096O .nes. "" then -
  WRITE IMAGES "SYS$SHARE:CRFSHR	/OPEN /HEADER",C8192S
$ if SMALLDISK.eq.0 then -
  WRITE IMAGES "SYS$SYSTEM:SUBMIT	/PRIV=(TMPMBX)",CP4096O,CP8192S
$ if SMALLDISK.eq.1 then -
  WRITE IMAGES "SYS$SYSTEM:SUBMIT	/PRIV=(TMPMBX)"
$ WRITE IMAGES "SYS$SHARE:DISMNTSHR	/PROTECT /OPEN /HEADER /SHARE !/NOREMOVE"
$ WRITE IMAGES "SYS$SHARE:MOUNTSHR	/PROTECT /OPEN /HEADER /SHARE"
$ if SMALLDISK.eq.0 then -
  WRITE IMAGES "SYS$SYSTEM:RTPAD	/PRIV=(TMPMBX)",CP4096O,CP8192S
$ if SMALLDISK.eq.1 then -
  WRITE IMAGES "SYS$SYSTEM:RTPAD	/PRIV=(TMPMBX)"
$ if SMALLDISK.eq.0 .and. C4096O .nes. "" then -
  WRITE IMAGES "SYS$LIBRARY:DEBUG	/OPEN /HEADER",C8192S
$ if SMALLDISK.eq.0 then WRITE IMAGES "SYS$SYSTEM:PHONE",-
"	/PRIV=(NETMBX,OPER,PRMMBX,WORLD)",CP4096O,CP4096S
$ if SMALLDISK.eq.1 then WRITE IMAGES "SYS$SYSTEM:PHONE",-
"	/PRIV=(NETMBX,OPER,PRMMBX,WORLD)"
$ WRITE IMAGES "SYS$SYSTEM:LOGINOUT",-
"	/PRIV=(CMKRNL,TMPMBX,EXQUO,SYSPRV) /OPEN /HEADER",CP4096S
$ WRITE IMAGES "SYS$SHARE:DCLTABLES	/OPEN /SHARED /HEADER"
$ WRITE IMAGES "SYS$SYSTEM:DCL		/OPEN /SHARED /HEADER"
$ WRITE IMAGES "SYS$SYSTEM:DELETE	/OPEN /HEADER",CP4096S
$ WRITE IMAGES "SYS$SYSTEM:DIRECTORY	/OPEN /HEADER",CP4096S
$ WRITE IMAGES "SYS$SYSTEM:COPY		/OPEN /HEADER",CP4096S
$ WRITE IMAGES "SYS$SYSTEM:SET",-
"		/PRIV=(CMKRNL,SYSPRV,TMPMBX) /OPEN /HEADER /SHARED"
$ WRITE IMAGES "SYS$SYSTEM:SHOW",-
"		/PRIV=(CMKRNL,NETMBX,SETPRV) /OPEN /HEADER /SHARED"
$ if SMALLDISK.eq.0 then WRITE IMAGES "SYS$SYSTEM:MAIL",-
"		/PRIV=(SYSPRV,OPER,WORLD,NETMBX) /OPEN /HEADER",CP4096S
$ if SMALLDISK.eq.1 then WRITE IMAGES "SYS$SYSTEM:MAIL",-
"		/PRIV=(SYSPRV,OPER,WORLD,NETMBX)"
$ if SMALLDISK.eq.0 then -
  WRITE IMAGES "SYS$SYSTEM:EDT		/OPEN /SHARED /HEADER"
$ WRITE IMAGES "SYS$SHARE:SCRSHR	/OPEN /SHARED /HEADER"
$ WRITE IMAGES "SYS$SHARE:LBRSHR	/OPEN /SHARED /HEADER"
$ WRITE IMAGES "SYS$SHARE:VMSRTL	/OPEN /SHARED /HEADER"
$ WRITE IMAGES -
"! Data file used to install VMS known images. This file MUST NOT be modified."
$ WRITE IMAGES -
"!"
$ WRITE IMAGES -
"! Users wishing to alter the list of installed images should remove"
$ WRITE IMAGES -
"! and reinstall the image via the SYSTARTUP.COM mechanism."
$ WRITE IMAGES -
"!"
$ WRITE IMAGES -
"! The presence of a /NOREMOVE qualifier on the line (in a comment) indicates"
$ WRITE IMAGES -
"! the file should not be removed during the SHUTDOWN process."
$
$ CLOSE IMAGES
$
$ ! GBLPAGES
$
$ TGBLPAGES = TGBLPAGES * 2
$ if "''OLD_GBLPAGES'".eqs."" then OLD_GBLPAGES = 0
$ if "''GBLPAGES'".nes."" then OLD_GBLPAGES = 0
$ if "''GBLPAGES'".eqs."" then GBLPAGES = TGBLPAGES
$ if GBLPAGES.lt.TGBLPAGES then GBLPAGES = TGBLPAGES
$ if GBLPAGES.lt.OLD_GBLPAGES then GBLPAGES = OLD_GBLPAGES
$
$ ! GBLSECTIONS
$
$ TGBLSECTIONS = TGBLSECTIONS + (TGBLSECTIONS / 3)
$ if "''OLD_GBLSECTIONS'".eqs."" then OLD_GBLSECTIONS = 0
$ if "''GBLSECTIONS'".nes."" then OLD_GBLSECTIONS = 0
$ if "''GBLSECTIONS'".eqs."" then GBLSECTIONS = TGBLSECTIONS
$ if GBLSECTIONS.lt.TGBLSECTIONS then GBLSECTIONS = TGBLSECTIONS
$ if GBLSECTIONS.lt.OLD_GBLSECTIONS then GBLSECTIONS = OLD_GBLSECTIONS
$
$ ! SYSMWCNT
$
$ temp = BALSETCNT
$ if temp .gt. 100 then temp = 100
$ temp = 170 + temp + (GBLPAGES / 128)
$ if "''SYSMWCNT'".eqs."" then SYSMWCNT = temp
$ if SYSMWCNT.lt.temp then SYSMWCNT = temp
$ 
$ ! JOBQUEUES
$
$ temp = 1
$ if SMALLDISK then temp = 0
$ if "''JOBQUEUES'".eqs."" then JOBQUEUES = temp
$
$ ! MAXPRINTSYMB
$
$ if "''MAXPRINTSYMB'".eqs."" then MAXPRINTSYMB = 32
$
$ ! Write out the new .PAR file and update the CURRENT parameters
$
$ DEFINE/USER SYS$OUTPUT SYS$SYSTEM:PARMS.TMP
$ SAVEVER = 'F$VERIFY(0)			! Turn off verify
$ RUN SYS$SYSTEM:SYSGEN
SHOW/ALL
SHOW/SPECIAL
SHOW USERD1
SHOW USERD2
SHOW USER3
SHOW USER4
$ SAVEVER = 'F$VERIFY(SAVEVER)			! Restore verify mode
$ OPEN/WRITE/ERROR=NOSETPARMS SETPARMS SYS$SYSTEM:SETPARMS.COM
$
$ ! Setup command procedure to invoke to set new sysgen parameters
$
$ WRITE SETPARMS "$ RUN SYS$SYSTEM:SYSGEN"
$ WRITE SETPARMS "USE DEFAULT"
$ OPEN/READ/ERROR=NOPARMS PARMS SYS$SYSTEM:PARMS.TMP
$
$ ! Discard all records that do not have parameter names
$
$parmloop:
$ READ/END=ENDPARMS PARMS RECORD
$ sym=f$extract(3,1,record)
$ if sym .lts. "A" .or. sym .gts "Z" then goto parmloop
$ record=f$extract(2,f$locate("   ",record)-2,record)
$ sym="'"+record
$ sym:='sym'
$ IF sym.eqs."" then goto parmloop
$ write setparms "set ",record," ",'record
$ GOTO PARMLOOP
$endparms:
$ WRITE SETPARMS "WRITE CURRENT"
$ WRITE SETPARMS "WRITE SYS$SYSTEM:AUTOGEN.PAR"
$ WRITE SETPARMS "EXIT"
$ CLOSE PARMS
$ DELETE SYS$SYSTEM:PARMS.TMP;*
$ CLOSE SETPARMS
$ @SYS$SYSTEM:SETPARMS
$ DELETE SYS$SYSTEM:SETPARMS.COM;*
$
$ RENAME SYS$MANAGER:VMSIMAGES.TMP SYS$MANAGER:VMSIMAGES.DAT
$ SET PROT=(SYS:RWED,OWN:RWED,GRO,WOR) SYS$MANAGER:VMSIMAGES.DAT;*
$
$ IF P1.nes."REBOOT".and.P1.nes."SHUTDOWN" then goto DONE1
$
$ WRITE SYS$OUTPUT ""
$ WRITE SYS$OUTPUT "System shutting down to allow boot of complete V3.0 system,"
$ WRITE SYS$OUTPUT "with generated site-specific parameters and installed images."
$ !
$ ! Now shut down the system.
$ !
$ IF P1.eqs."REBOOT" then goto REBOOT
$ REBOOTFLAG="N"
$ WRITE SYS$OUTPUT "You must manually reboot the system after it halts."
$ goto DOWN
$
$REBOOT:
$ REBOOTFLAG="Y"
$ WRITE SYS$OUTPUT "The system will automatically reboot after the shutdown."
$ WRITE SYS$OUTPUT ""
$ WRITE SYS$OUTPUT "Upgrade to VAX/VMS Version 3.0 complete after reboot."
$ WRITE SYS$OUTPUT ""
$DOWN:
$ @SYS$SYSTEM:SHUTDOWN "0" "Reboot system with generated parameters" "N" -
	 "N" "soon" 'REBOOTFLAG
$
$ GOTO DONE1
$
$noparms:
$ WRITE SYS$OUTPUT -
"%AUTOGEN-E-PARMS.TMP could not be created, please correct the problem."
$ WRITE SYS$OUTPUT -
"-          Then reinvoke @SYS$UPDATE:AUTOGEN"
$ GOTO DONE1
$
$nosetparms:
$ WRITE SYS$OUTPUT -
"%AUTOGEN-E-SETPARAMS.COM could not be created, please correct the problem."
$ WRITE SYS$OUTPUT -
"-          Then reinvoke @SYS$UPDATE:AUTOGEN"
$ GOTO DONE1
$
$novmsimages:
$ WRITE SYS$OUTPUT -
"%AUTOGEN-E-VMSIMAGES.DAT could not be created, please correct the problem."
$ WRITE SYS$OUTPUT -
"-          Then reinvoke @SYS$UPDATE:AUTOGEN"
$ GOTO DONE1
$
$nopar1:
$ WRITE SYS$OUTPUT -
"%AUTOGEN-E-PARAMS.DAT not found"
$ WRITE SYS$OUTPUT -
"-          start from the beginning with @SYS$UPDATE:AUTOGEN CONFIG"
$ WRITE SYS$OUTPUT -
"-          then @SYS$UPDATE:AUTOGEN GENPAR
$ WRITE SYS$OUTPUT -
"-          then @SYS$UPDATE:AUTOGEN"
$ GOTO DONE1
$
$interrupted2:
$ CLOSE INPUTS
$ CLOSE SETPARMS
$ CLOSE PARMS
$ CLOSE IMAGES
$done1:
