$ SET NOVERIFY
$ !COMPATIBILITY MODE UTILITY TEST
$ ! AUTHOR: PAULA TIRAK,		CREATION DATE: NOVEMBER, 1977
$ !
$ ! MODIFIED BY:
$ !
$ !		VERSION 3.07 : 15-AUG-81
$ !--
$ ! 07  LDJ  02/11/82	Modified to reflect changes to LOGINOUT.
$ !
$ ! 06  LDJ  01/11/82	Modified SOS test to conform to new editor default
$ !			of EDT.
$ !
$ ! 05  RNP  12/07/81	Added commands to check results of utility commands
$ !			not previously checked and output error message to 
$ !			SYS$OUTPUT if found.
$ !
$ ! 04  FWM  10/23/81   Modified how result of DIFF was tested
$ !                     Added BYOC.DMP test which was typed as ASRC.DMP
$ !			Removed 'VFY' testing
$ !			Changed destination of GOTO to DONE for all but FLX test
$ !
$ ! 03  LDJ  10/02/81	Modified magtape FLX code to init the tape to UETP after
$ !			testing.
$ !
$ ! 02  BAA  08/28/81   Modified to use VMS's DIFF and no longer
$ !			 need UETCOMP01.COM
$ !
$ ! 01  BAA  08/15/81	Modified to work under UETPHAS00
$ !
$ !**
$ !
$ STS$K_SUCCESS =   1				! define success code
$ !
$ ! SYS$SCRATCH is not defined in detached process
$ !
$ IF F$LOGICAL("SYS$SCRATCH") .EQS. "" THEN DEFINE SYS$SCRATCH SYS$TEST:
$ LOGFILE = 0			! Default is interactive
$ IF "''F$MODE()'" .EQS. "INTERACTIVE" THEN GOTO SKIPFILE
$ LOGFILE = 1			! We are making a logfile
$ PROC := 'F$GETJPI("","PRCNAM")' ! Get the processname of this procedure
$ UNDER = 'F$LOCATE("_",PROC)'  ! and find the underscore
$ ID = UNDER+1			! Locate the unique ID
$ IF  UNDER .GT. 5 THEN UNDER = 5  ! take the first 5 chars. before underscore
$ FILENAME := 'F$EXTRACT(0,UNDER,PROC)''F$EXTRACT(ID,4,PROC)'.LOG
$ !
$ OPEN/WRITE FILE 'FILENAME'	! Define a place for us . . .
$   DEFINE SYS$ERROR FILE			! make SYS$ERROR look at it
$   WRITE SYS$ERROR "*** UETCOMP00 BEGINNING AT ''F$TIME() ***"
$
$SKIPFILE:
$   WRITE SYS$OUTPUT "*** UETCOMP00 BEGINNING AT ''F$TIME() ***"
$
$   ON ERROR THEN GOTO FINI
$   ON CONTROL_Y THEN GOTO FINI
$   UET:='F$LOGICAL("UET$MAGTAP")		! Get a magtape for testing
$   PNAME:='P1
$
$PARAMETER:
$   IF PNAME .EQS. "DMP" THEN GOTO UETCDMP00
$   IF PNAME .EQS. "FLX" THEN GOTO UETCFLX00
$   IF PNAME .EQS. "LBR" THEN GOTO UETCLBR00
$   IF PNAME .EQS. "PAT" THEN GOTO UETCPAT00
$   IF PNAME .EQS. "PIP" THEN GOTO UETCPIP00
$   IF PNAME .EQS. "SLP" THEN GOTO UETCSLP00
$   IF PNAME .EQS. "SOS" THEN GOTO UETCSOS00
$   IF PNAME .EQS. "SRT" THEN GOTO UETCSRT00
$   IF PNAME .EQS. "" .OR. PNAME .EQS. "ALL" THEN GOTO UTILITIES
$   INQUIRE PAR "ENTER THE NAME OF A UTILITY OR CARRIAGE RETURN"
$   PNAME:='PAR
$   GOTO PARAMETER
$
$UTILITIES:
$   SET VERIFY
$		! COMPATIBILITY MODE UTILITY TEST
$   SET NOVERIFY
$   SHOW TIME
$
$UETCDMP00:
$   SET VERIFY
$
$			! DMP Test
$ 
$		! Dump DMPDATA.DMP a record at a time in ASCII mode
$   MCR DMP ASRC.DMP/-SP=DMPDATA.DMP/AS/RC
$		! Compare against a master file for differences
$
$   DIFF /OUT=TEMP.DAT /IGNORE=(COMMENT) /COMMENT=(FORM)  DMPASRC.DMP ASRC.DMP
$   IF $SEVERITY .NE. STS$K_SUCCESS THEN-
      WRITE SYS$ERROR "DMP (quals=/AS/RC) TEST DATA ERROR"
$ 
$		! Dump DMPDATA.DMP in byte octal format
$   MCR DMP BYOC.DMP/-SP=DMPDATA.DMP/BY
$		! Compare the new file against a master for differences
$
$   DIFF /OUT=TEMP.DAT /IGNORE=(COMMENT) /COMMENT=FORM DMPBYOC.DMP BYOC.DMP
$   IF $SEVERITY .NE. STS$K_SUCCESS THEN -
      WRITE SYS$ERROR "DMP (quals=/BY {octal}) TEST DATA ERROR"
$
$		! Dump DMPDATA.DMP in decimal word format
$   MCR DMP DCWD.DMP/-SP=DMPDATA.DMP/DC
$		! Compare the new file against a master for differences
$
$   DIFF /OUT=TEMP.DAT /IGNORE=(COMMENT) /COMMENT=FORM DMPDCWD.DMP DCWD.DMP
$   IF $SEVERITY .NE. STS$K_SUCCESS THEN -
      WRITE SYS$ERROR "DMP (quals=/DC) TEST DATA ERROR"
$                ! Verification of dump test starts here
$   SET NOVERIFY
$   DELE ASRC.*;*,BYOC.*;*,DCWD.*;*
$   DELE TEMP.DAT;*
$ 
$ 			! DMP Testing Complete
$   SET NOVERIFY
$   IF PNAME .EQS. "DMP" THEN GOTO DONE
$   IF UET .EQS. "" THEN GOTO UETCLBR00
$
$UETCFLX00:
$   MAGTAP:='F$EXT(0,2,UET)''F$EXT(3,1,UET)':
$   SET VERIFY
$
$ 			! FLX Test
$
$   ON ERROR THEN GOTO ENDFLX		! Skip this test if mount fails
$   MOUNT 'MAGTAP/FOREIGN/NOASSIST	! Mount the magtape
$   ON ERROR THEN GOTO DISMNT		! Quit test and dismount tape on error
$
$   COPY RANDOM.FLX RNDFLX.FLX		! Create the FILES-11 test files
$   COPY SORTED.FLX SRTFLX.FLX		! on sys to be copied
$
$   MCR FLX 'MAGTAP/DO/ZE		! Initialize a DOS-11 magtape
$   MCR FLX 'MAGTAP/DO=RNDFLX.FLX,SRTFLX.FLX/RS   ! Copy  the test files
$   DELETE RNDFLX.FLX;*,SRTFLX.FLX;*	! Delete test files from sys
$   MCR FLX SY:/RS='MAGTAP*.*/DO	! Copy test files from magtape
$
$
$   DIFF /OUT=TEMP.DAT RANDOM.FLX RNDFLX.FLX
$   IF $SEVERITY .NE. STS$K_SUCCESS THEN -
      WRITE SYS$ERROR "FLX (random) TEST DATA ERROR"
$
$   DIFF /OUT=TEMP.DAT SORTED.FLX SRTFLX.FLX
$   IF $SEVERITY .NE. STS$K_SUCCESS THEN -
      WRITE SYS$ERROR "FLX (sorted) TEST DATA ERROR"
$   SET NOVERIFY
$   DELE TEMP.DAT;*
$DISMNT:
$   DISMOUNT/NOUNLOAD 'MAGTAP		! Dismount the magtape
$   INIT 'MAGTAP UETP			! Reset the tape label
$   UET:=""				! Undefine the magtape symbol
$   DELE RNDFLX.*;*,SRTFLX.*;*		! Delete unnecessary files
$
$ 			!FLX Testing Complete
$ENDFLX:
$   ON ERROR THEN GOTO FINI
$   SET NOVERIFY
$   IF PNAME .EQS. "FLX" THEN GOTO FINI
$
$
$UETCLBR00:
$   SET VERIFY
$
$ 			!LBR Test			
$
$   MCR LBR OBJLIB/CR:50:::OBJ	! Create an object module library
$   MCR LBR OBJLIB/IN=OBJLBR1,OBJLBR2,OBJLBR3  ! Insert 3 object modules
$   MCR LBR OBJLIB/DE:OBJ3		! Delete a module
$   MCR LBR OBJLIB/IN=OBJLBR3		! Insert the module back
$   MCR LBR OBJLIB/RP=OBJLBR1,OBJLBR2	! Replace two existing modules
$   MCR LBR OBJLIB/DG:ENT$A1:ENT$B2:ENT$A3  ! Delete several entry points
$   MCR LBR EXTOBJ2=OBJLIB/EX:OBJ2	! Extract an object module
$
$   DIFF /OUT=TEMP.DAT EXTOBJ2.OBJ OBJLBR2.OBJ
$   IF $SEVERITY .NE. STS$K_SUCCESS THEN -
      WRITE SYS$ERROR "LBR (extobj) TEST DATA ERROR"
$
$   MCR LBR MACLIB/CR:50:::MAC		! Create a macro library
$   MCR LBR MACLIB.MLB/IN=MCLBR1,MCLBR2,MCLBR3	! Insert three macros
$   MCR LBR MACLIB.MLB/DE:MCLBR3	! Delete a module
$   MCR LBR MACLIB.MLB/IN=MCLBR3	! Insert the module back
$   MCR LBR MACLIB.MLB/RP=MCLBR1,MCLBR2	! Replace two existing modules
$
$   MCR LBR EXTMAC2=MACLIB.MLB/EX:MCLBR2  ! Extract a macro
$
$   DIFF /OUT=TEMP.DAT /MATCH=2 EXTMAC2.MAC MCLBR2.MAC
$   IF $SEVERITY .NE. STS$K_SUCCESS THEN - 
      WRITE SYS$ERROR "LBR (extmac) TEST DATA ERROR"
$
$   SET NOVERIFY
$   DELE TEMP.DAT;*
$   DELE OBJLIB.*;*,EXTOBJ2.*;*,MACLIB.*;*,EXTMAC2.*;*
$
$ 			! LBR Testing Complete
$   SET NOVERIFY
$   IF PNAME .EQS. "LBR" THEN GOTO DONE
$
$
$UETCPAT00:
$   SET VERIFY
$
$ 			! PAT Test
$
$				! Create an updated object file
$   MCR PAT PATPATCH.PAT=OBJLBR1.OBJ,PATCHPAT.OBJ
$				! Compare file with one of known quality
$
$   DIFF /OUT=TEMP.DAT PATPATCH.PAT PATCHED.PAT
$   IF $SEVERITY .NE. STS$K_SUCCESS THEN -
      WRITE SYS$ERROR "PAT TEST DATA ERROR"
$   SET NOVERIFY
$   DELE TEMP.DAT;*
$   DELE PATPATCH.PAT;*		! Delete unnecessary files
$
$ 			! PAT Testing Complete
$   SET NOVERIFY
$   IF PNAME .EQS. "PAT" THEN GOTO DONE
$
$
$UETCPIP00:
$   SET VERIFY
$
$ 			! PIP Test
$
$   MCR PIP /ID				! Version of PIP
$
$			! Clean up any files that might be left around
$   SET MESSAGE/NOFAC/NOID/NOSEV/NOTEXT ! Disable error messages
$   DELETE COPY.PIP;*,VERSIONS.PIP;*,RENAME.PIP;*,UPDATE.PIP;* 
$   SET MESSAGE/FAC/ID/SEV/TEXT		! Enable error messages
$
$ 			! Test "Copy" Function
$   MCR PIP COPY.PIP;1=PIPDATA.PIP	! Create a copy of a file
$
$   DIFF /OUT=TEMP.DAT COPY.PIP PIPDATA.PIP
$   IF $SEVERITY .NE. STS$K_SUCCESS THEN -
      WRITE SYS$ERROR "PIP (copy) TEST DATA ERROR"
$
$ 			! Test "Version Override" Function (/SU)
$   MCR PIP COPY.PIP;1=PIPDATA.PIP/SU	! Replace an existing file
$   IF F$SEARCH("COPY.PIP;1") .EQS. "" THEN- ! Make sure file exists
	GOTO OVERERR 
$   IF F$SEARCH("COPY.PIP;2") .EQS. "" THEN- ! Make sure new version wasn't created
	GOTO ENDOVERRIDE
$OVERERR:
$   WRITE SYS$ERROR "PIP version override test failed"
$ENDOVERRIDE:
$
$ 			! Test "Append" Function (/AP)
$   COPY PIPDATA.PIP APPENDED.PIP	! Create a file
$   MCR PIP APPENDED.PIP=PIPDATA.PIP/AP	! Append another copy to the end
$				! Compare file with one of known quality
$   DIFF /OUT=TEMP.DAT APPENDED.PIP APPEND.PIP
$   IF $SEVERITY .NE. STS$K_SUCCESS THEN -
      WRITE SYS$ERROR "PIP (append) TEST DATA ERROR"
$
$ 			! Test "Delete" Function (/DE)
$   COPY PIPDATA.PIP DELETE.PIP		!Create a file
$   MCR PIP DELETE.PIP;*/DE		! Delete the file
$   IF F$SEARCH("DELETE.PIP") .EQS. "" THEN- ! Make sure it was deleted
	GOTO DELOK
$   WRITE SYS$ERROR " PIP delete test failed"
$DELOK:
$
$ 			! Test "Merge" Function (/ME)
$   MCR PIP MERGED.PIP=PIPDATA.PIP,PIPDATA.PIP/ME  ! Merge two files
$
$   DIFF /OUT=TEMP.DAT MERGED.PIP APPEND.PIP
$   IF $SEVERITY .NE. STS$K_SUCCESS THEN -
      WRITE SYS$ERROR "PIP (merge) TEST DATA ERROR"
$
$ 			! Test "Purge" Function (/PU)
$   COPY PIPDATA.PIP VERSIONS.PIP	! Create several versions
$   COPY PIPDATA.PIP VERSIONS.PIP	! of the same file
$   COPY PIPDATA.PIP VERSIONS.PIP	
$   COPY PIPDATA.PIP VERSIONS.PIP	
$   COPY PIPDATA.PIP VERSIONS.PIP	
$   MCR PIP VERSIONS.PIP/PU:3	     ! Retain the 3 most current versions (3-5)
$   IF F$SEARCH("VERSIONS.PIP;2") .NES. "" THEN- ! Make sure ver. #2 is gone
	GOTO PURGERR
$   IF F$SEARCH("VERSIONS.PIP;3") .EQS. "" THEN- ! Make sure ver. #3 still exists
	GOTO PURGERR
$   MCR PIP VERSIONS.PIP/PU		! Purge all but the highest version
$   IF F$SEARCH("VERSIONS.PIP;4") .NES. "" THEN- ! Make sure ver. #4 is gone
	GOTO PURGERR
$   IF F$SEARCH("VERSIONS.PIP;5") .NES. "" THEN- ! Make sure ver. #5 still exists
	GOTO ENDPURGE
$PURGERR:
$   WRITE SYS$ERROR "PIP purge function failed"
$ENDPURGE:
$
$ 			! Test "Rename" Function (/RE)
$   MCR PIP RENAME.PIP=COPY.PIP/RE		! Rename the file
$   IF F$SEARCH("COPY.PIP") .NES. "" THEN- 	! Make sure it is gone
	GOTO RENAMERR
$   IF F$SEARCH("RENAME.PIP") .NES. "" THEN-	! Make sure it got renamed
	GOTO ENDRENAME
$RENAMERR:
$   WRITE SYS$ERROR "PIP rename function error"
$ENDRENAME:
$
$			! Test "Update" Function (/Up)
$   COPY PIPDATA.PIP UPDATE.PIP		! Create a file
$   MCR PIP UPDATE.PIP=APPEND.PIP/UP	! Update file to larger file
$
$   DIFF /OUT=TEMP.DAT UPDATE.PIP APPEND.PIP
$   IF $SEVERITY .NE. STS$K_SUCCESS THEN -
      WRITE SYS$ERROR "PIP (update) TEST DATA ERROR"
$
$   SET NOVERIFY
$   DELE TEMP.DAT;*
$   DELE APPENDED.*;*,MERGED.*;*	! Delete unnecessary files
$   DELE VERSIONS.*;*,RENAME.*;*,UPDATE.*;*
$
$ 			! PIP Testing Complete
$   SET NOVERIFY
$   IF PNAME .EQS. "PIP" THEN GOTO DONE
$
$
$UETCSLP00:
$   SET VERIFY
$
$ 			! SLP Test
$
$   MCR SLP		! Invoke the SLP Editor to edit a data file
OUTPUT.SLP,LIST.SLP/-SP=SLPDATA.SLP
-2
INSERTED LINE 200A
INSERTED LINE 200B
INSERTED LINE 200C
INSERTED LINE 200D
-/5/,/9/,/AUDIT#1/
INSERTED LINE 900A
INSERTED LINE 900B
-.,,/AUDIT#2/
INSERTED LINE 1000A
INSERTED LINE 1000B
-.,,/AUDIT#3/
INSERTED LINE 1100A
\
-.
INSERTED LINE 1200A
INSERTED LINE 1200B
%
INSERTED LINE 1200C
INSERTED LINE 1200D
-/15/+2,.+1
/
$		! Verify that the editing was properly performed
$		! Compare new files with files of known quality
$
$   DIFF /OUT=TEMP.DAT OUTPUT.SLP SLPOUT.SLP
$   IF $SEVERITY .NE. STS$K_SUCCESS THEN -
      WRITE SYS$ERROR "SLP (output) TEST DATA ERROR"
$
$   DIFF /OUT=TEMP.DAT LIST.SLP SLPLIST.SLP
$   IF $SEVERITY .NE. STS$K_SUCCESS THEN -
      WRITE SYS$ERROR "SLP (list) TEST DATA ERROR"
$   SET NOVERIFY
$   DELE TEMP.DAT;*
$   DELE OUTPUT.*;*,LIST.*;*		! Delete unnecessary files
$
$ 			! SLP Testing Complete
$   SET NOVERIFY
$   IF PNAME .EQS. "SLP" THEN GOTO DONE
$
$
$UETCSOS00:
$   SET VERIFY
$			! SOS (EDIT) Test
$
$   EDIT/SOS UETCSOS01.DAT/OUTPUT=UETCSOS04.DAT	! SOS commands in file 2
@UETCSOS02
$
$
$   DIFF /OUT=TEMP.DAT UETCSOS03.DAT UETCSOS04.DAT
$   IF $SEVERITY .NE. STS$K_SUCCESS THEN -
      WRITE SYS$ERROR "SOS TEST DATA ERROR"
$   SET NOVERIFY
$   DELE TEMP.DAT;*
$			! SOS testing complete
$   SET NOVERIFY
$   DELE UETCSOS04.DAT;*			! Clean up
$   IF PNAME .EQS. "SOS" THEN GOTO DONE
$
$
$UETCSRT00:
$   SET VERIFY
$
$			! SRT (SORT-11) TEST
$
$			! Sort RANDOM.FLX using bytes 2-10 as the key
$   MCR SRT SORT.SRT=RANDOM.FLX/FO:U:80/KE:2.10
$
$
$   DIFF /OUT=TEMP.DAT  SORT.SRT SORTED.FLX
$   IF $SEVERITY .NE. STS$K_SUCCESS THEN -
      WRITE SYS$ERROR "SRT TEST DATA ERROR"
$   SET NOVERIFY
$   DELE TEMP.DAT;*
$   DELE SORT.SRT;*	! Delete unnecessary files
$
$			! SRT Testing Complete
$   SET NOVERIFY
$   IF PNAME .EQS. "SRT" THEN GOTO DONE
$
$FINI:
$   SET NOVERIFY
$   SET NOON
$   IF UET .EQS. "" THEN GOTO DONE
$   DISMOUNT/NOUNLOAD 'MAGTAP		! Dismount the magtape
$   INIT 'MAGTAP UETP			! Reset the tape label
$DONE:
$   SET NOVERIFY
$ 
$   WRITE SYS$OUTPUT "*** UETCOMP00 ENDED AT ''F$TIME() ***"
$   IF .NOT. 'LOGFILE' THEN EXIT
$   WRITE SYS$ERROR "*** UETCOMP00 ENDED AT ''F$TIME() ***"
$   CLOSE FILE
$   DEASSIGN SYS$ERROR
$                ! END OF COMPATIBILITY MODE UTILITY TEST
