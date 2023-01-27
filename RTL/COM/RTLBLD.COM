$ ! [RTL.COM] R T L B L D . C O M
$ !
$ ! 2-042 - Specify .REQ explicitly for SDL command.  SBL 5-Feb-1982
$ ! 2-041 - Use SET FILE.  SBL 21-Dec-1981
$ ! 2-040 - Build RTL.OLB instead of .OBS files.  SBL 7-Dec-1981
$ ! 2-039 - Add copy of RTLVECTOR to [SYSLIB].  SBL 1-Dec-1981
$ ! 2-038 - Add LIBCLIDEF.  SBL 14-Sep-1981
$ ! 2-037 - Inhibit checkpoint restart unless this is a restarted build.  SBL 10-Sep-1981
$ ! 2-036 - Have ASSEM phase use checkpointing.  SBL 9-Sept-1981
$ ! 2-035 - Copy LIBDCFDEF to shared area for VMSLIB.  SBL 29-Aug-1981
$ ! 2-034 - Install VMSRTL in SHARELIB.  SBL 25-Aug-1981
$ ! 2-033 - Add RTLSRCLIB.COM.  Remove RTLPATCH.  SBL 16-July-1981
$ ! 2-032 - Reenable VECTORTST.  SBL 10-July-1981
$ ! 2-031 - Add RTLXPORT logical name for XPORT.L32.  Reflect change of
$ !	    MDL message definition files (except BASMSG) to .MSG.  SBL 23-Apr-1981
$ ! 2-030 - Disable VECTORTST pending a rewrite of ANALYZE/IMAGE.  SBL 10-Mar-1981
$ ! 2-029 - Take ERRORS.HLP from OBJ$ instead of SRC$.  SBL 30-Jan-1981
$ ! 2-028 - Add LNKLIB phase. BLS 18-Jan-1981
$ ! 2-027 - Remove all references to "test" builds, which are no
$ !	    longer done. SBL 18-June-1980
$ ! 2-026 - Add VECTORTST to the RESULT phase.  SBL 11-March-1980
$ ! 2-025 - Remove redefinition of global sections, no longer needed.
$ !	    Remove copying of LIBENUENA, which no longer exists.  SBL 25-Feb-1980
$ ! 2-024 - Only delete O.OLB.* not *.OLB.* DGP 19-Feb-80
$ ! 2-023 - Do CRF only if RTL$TEST is true.  SBL 21-Jan-1980
$ ! 2-022 - Temporarily remove the CRF phase due to DB0ACP bug.  DGP 18-Jan-80
$ ! 2-021 - Delete old files in more places, so as not to fill up
$ !	    disk when restarting system build.  SBL 17-Jan-1980
$ ! 2-020 - Take test objects from old STARLET.OLB.  JBS 02-DEC-1979
$ ! 2-019 - Remove F4PCOMPAT.OBS.  JBS 18-OCT-1979
$ ! 2-018 - Remove some of the image name definitions to try to
$ !	     avoid running out of storage.  JBS 17-OCT-1979
$ ! 2-017 - Add global image name definitions so that reassignment
$ !	    of SYS$LIBRARY: will work on VMS 2.0.  SBL 17-Oct-1979
$ ! 2-016 - Add FORIOSDEF.FOR.  SBL 28-Sept-1979
$ ! 2-015 - Add logical name RTLLIB.  JBS 18-SEP-1979
$ ! 2-014 - Build two sharable libraries, so we can be sure
$ !	     it is position independent.  JBS 13-SEP-1979
$ ! 2-013 - Add logical name RTLTPAMAC, and defend logical name
$ !	     definition code so that only real builds use it.
$ !	     JBS 12-SEP-1979
$ ! 2-012 - Correct an error in edit 011.  JBS 02-AUG-1979
$ ! 2-011 - Correct a typo in the deletion of unnecessary OBJ files.
$ !	     JBS 01-AUG-1979
$ ! 2-010 - Dont delete .OBS files.  SBL 24-July-1979
$ ! 2-009 - Restore .OBJ deletions, put in RESULT phase.  SBL 12-July-1979
$ ! 2-008 - Stop deleting the .OBJ files, since SYSTEMBUILD has
$ ! 	    privilege to override protection.  SBL 11-JUL-1979
$ ! 2-007 - Delete the test version of STARLET.OLB when we are
$ !	     through with it.  JBS 09-JUL-1979
$ ! 2-006 - Take copies of the latest TPARSE and CVT_ATB object files
$ !	     from [RTL.TST].  JBS 09-JUL-1979
$ ! 2-005 - Delete OBJ files after OBS files created.  SBL 6-Jul-1979
$ ! 2-004 - Change CVT_ATB to LIB$CVT_ATB.  SBL 20-Jun-1979
$ ! 2-003 - Take LIB$TPARSE and CVT_ATB from STARLET when building
$ !	     a test library.  JBS 19-JUN-1979
$ ! 2-002 - Remove concatentated listing files from result phase.  SBL 4-Jun-79
$ ! 2-001 - Release 2 version.  SBL 16-May-1979
$ !
$ !	ASSUMES [RTL] AND DEFINITIONS FOR LIB$:, LIS$:, SRC$:,
$ !			EXE$:, MAP$: AND OBJ$:
$ !
$ !	Uses the following command files:
$ !
$ !	  COM$:RTLLOGNAM.COM		define RTL-specific logical names
$ !	  COM$:RTLUPD.COM		update all source modules
$ !	  COM$:RTLSRCLIB.COM		create source libraries
$ !	  COM$:MDLRTL.COM		run all MDL conversions
$ ! SYSBLDCOM$:FASM.COM			assemble/compile all modules
$ !	  COM$:VMSRTLLNK.COM,.OPT	Link sharable VMSRTL.EXE
$ !	  COM$:VECTORTST.COM		Compare vector addresses
$ !
$ !	Define logical names which occur in BLISS REQUIRE declarations:
$ !	Make sure control Y DEASSIGNs logical names at EXIT
$ !	(Unless this is a test build).
$ !
$ ON CONTROL_Y THEN GOTO EXIT
$ @COM$:RTLLOGNAM ASSIGN
$ STATUS = 1
$ GOTO 'PHASE'
$ !
$ !
$INIT:
$ !
$ !	CREATE THE DIRECTORIES
$ !
$ @SYSBLDCOM$:CREATEDIR
$ GOTO EXIT
$
$UPDATE:
$ !
$ ! 	DELETE FILES FROM PREVIOUS BUILDS
$ !
$ ON ERROR THEN CONTINUE
$ DELSHRLIB SRC$:BASMSG.MDL
$ DELSHRLIB SRC$:RTLMACMAR.MAR
$ DELSHRLIB SRC$:RTLMACB32.REQ
$ DELSHRLIB LIB$:BASMSG.MAR
$ DELSHRLIB LIB$:COBMSG.MAR
$ DELSHRLIB LIB$:FORMSG.MAR
$ DELSHRLIB LIB$:LIBMSG.MAR
$ DELSHRLIB LIB$:MTHMSG.MAR
$ DELSHRLIB LIB$:OTSMSG.MAR
$ DELSHRLIB LIB$:STRMSG.MAR
$ DELSHRLIB LIB$:LIBCLIDEF.MAR
$ DELSHRLIB LIB$:LIBCLIDEF.REQ
$ DELSHRLIB LIB$:LIBDCFDEF.MAR
$ DELSHRLIB LIB$:LIBDCFDEF.REQ
$ IF F$SEARCH("LIS$:LIBCLICAL.LIS") .NES. "" THEN -
  SET FILE LIS$:LIBCLICAL.LIS;* /REMOVE
$ IF F$SEARCH("LIS$:LIBCVTATB.LIS") .NES. "" THEN -
  SET FILE LIS$:LIBCVTATB.LIS;* /REMOVE
$ IF F$SEARCH("LIS$:LIBSCRPKG.LIS") .NES. "" THEN -
  SET FILE LIS$:LIBSCRPKG.LIS;* /REMOVE
$ IF F$SEARCH("LIS$:LIBTPARSE.LIS") .NES. "" THEN -
  SET FILE LIS$:LIBTPARSE.LIS;* /REMOVE
$ DELETE OBJ$:*.OBJ;*
$ DELETE OBJ$:*.OLB;*
$ DELETE OBJ$:*.L32;*
$ DELETE OBJ$:*.MAR;*
$ DELETE OBJ$:*.B32;*
$ DELETE OBJ$:*.REQ;*
$ DELETE LIS$:*.LIS;*
$ DELETE EXE$:*.EXE;*
$ DELETE MAP$:*.MAP;*
$ ON ERROR THEN GOTO FAIL
$ !
$ !	CREATE UPDATED REQUIRE FILES
$ !
$ @COM$:RTLUPD
$ CPYSHRLIB SRC$:BASMSG.MDL		! Share file with MSGFIL component
$ CPYSHRLIB SRC$:RTLMACMAR.MAR		! Share file with VMSLIB component
$ CPYSHRLIB SRC$:RTLMACB32.REQ		! Share file with VMSLIB component
$ !
$ !	NOW CREATE MDL OUTPUT THAT MUST BE SHARED WITH VMSLIB COMPONENT.
$ !	IT MUST BE CREATED IN THIS PHASE BECAUSE VMSLIB NEEDS IT IN THE
$ !	SRCLIB PHASE.
$ !
$ DELETE SRC$:COBMSG.MDL;*
$ DELETE SRC$:FORMSG.MDL;*
$ DELETE SRC$:LIBMSG.MDL;*
$ DELETE SRC$:MTHMSG.MDL;*
$ DELETE SRC$:OTSMSG.MDL;*
$ DELETE SRC$:STRMSG.MDL;*
$ MESSAGE/MDL=SRC$:COBMSG/NOOBJECT SRC$:COBMSG
$ MESSAGE/MDL=SRC$:FORMSG/NOOBJECT SRC$:FORMSG
$ MESSAGE/MDL=SRC$:LIBMSG/NOOBJECT SRC$:LIBMSG
$ MESSAGE/MDL=SRC$:MTHMSG/NOOBJECT SRC$:MTHMSG
$ MESSAGE/MDL=SRC$:OTSMSG/NOOBJECT SRC$:OTSMSG
$ MESSAGE/MDL=SRC$:STRMSG/NOOBJECT SRC$:STRMSG
$ DELETE LIB$:BASMSG.B32.*,BASMSG.MAR.*
$ DELETE LIB$:COBMSG.B32.*,COBMSG.MAR.*
$ DELETE LIB$:FORMSG.B32.*,FORMSG.MAR.*
$ DELETE LIB$:LIBMSG.B32.*,LIBMSG.MAR.*
$ DELETE LIB$:MTHMSG.B32.*,MTHMSG.MAR.*
$ DELETE LIB$:OTSMSG.B32.*,OTSMSG.MAR.*
$ DELETE LIB$:STRMSG.B32.*,STRMSG.MAR.*
$ DELETE LIB$:LIBDCFDEF.REQ;*,LIBDCFDEF.MAR;*
$ MCR MDL LIB$:BASMSG=SRC$:BASMSG
$ MCR MDL LIB$:COBMSG=SRC$:COBMSG
$ MCR MDL LIB$:FORMSG=SRC$:FORMSG
$ MCR MDL LIB$:LIBMSG=SRC$:LIBMSG
$ MCR MDL LIB$:MTHMSG=SRC$:MTHMSG
$ MCR MDL LIB$:OTSMSG=SRC$:OTSMSG
$ MCR MDL LIB$:STRMSG=SRC$:STRMSG
$ SDL/LANG=(MACRO=LIB$:,BLISS=LIB$:.REQ) SRC$:LIBCLIDEF
$ SDL/LANG=(MACRO=LIB$:,BLISS=LIB$:.REQ) SRC$:LIBDCFDEF
$ CPYSHRLIB LIB$:BASMSG.MAR		! Share file with VMSLIB component
$ CPYSHRLIB LIB$:COBMSG.MAR		! Share file with VMSLIB component
$ CPYSHRLIB LIB$:FORMSG.MAR		! Share file with VMSLIB component
$ CPYSHRLIB LIB$:LIBMSG.MAR		! Share file with VMSLIB component
$ CPYSHRLIB LIB$:MTHMSG.MAR		! Share file with VMSLIB component
$ CPYSHRLIB LIB$:OTSMSG.MAR		! Share file with VMSLIB component
$ CPYSHRLIB LIB$:STRMSG.MAR		! Share file with VMSLIB component
$ CPYSHRLIB LIB$:LIBCLIDEF.MAR		! Share file with VMSLIB component
$ CPYSHRLIB LIB$:LIBCLIDEF.REQ		! Share file with VMSLIB component
$ CPYSHRLIB LIB$:LIBDCFDEF.MAR		! Share file with VMSLIB component
$ CPYSHRLIB LIB$:LIBDCFDEF.REQ		! Share file with VMSLIB component
$ GOTO EXIT
$
$SRCLIB:
$ !
$ !	DELETE AND RECREATE REQUIRE FILES USING MDL
$ !	COPY FORTRAN INCLUDE FILES TO SYS$LIBRARY
$ !	DELETE AND RECREATE MACRO LIBRARY S.MLB
$ !
$ ON ERROR THEN CONTINUE
$ DELSHRLIB OBJ$:ERRORS.HLP
$ !
$ !
$ ON ERROR THEN GOTO FAIL
$ @COM$:MDLRTL
$ !
$ ! Copy FORTRAN INCLUDE files to SYS$LIBRARY
$ !
$ ! ON ERROR THEN CONTINUE
$ CPYSYSLIB SRC$:FORDEF.FOR
$ CPYSYSLIB SRC$:FORIOSDEF.FOR
$ CPYSYSLIB SRC$:LIBDEF.FOR
$ CPYSYSLIB SRC$:MTHDEF.FOR
$ CPYSYSLIB SRC$:SIGDEF.FOR
$ CPYSHRLIB OBJ$:ERRORS.HLP		! Share file with HELP component
$ !
$ ON ERROR THEN GOTO FAIL
$ !
$ ! Create source libraries
$ @COM$:RTLSRCLIB
$ !
$ ON ERROR THEN CONTINUE
$ DELETE FASMCHECK.CHK;*
$
$ GOTO EXIT
$
$ASSEM:
$ !
$ !	PURGE AND RECREATE THE ASSEMBLY LANGUAGE OBJECTS AND LISTINGS
$ !
$ PURGE LIS$:		! Dont delete listings since we may be
$ PURGE OBJ$:		! restarting an assembly
$ !
$ IF F$SEARCH("LIB$:RTL.OLB") .EQS. "" THEN -
   LIBRARY/CREATE=(BLOCKS:1500,MODULES:700,GLOBALS:7000)/OBJECT LIB$:RTL
$ !
$ ! Get files from other facilities that we need
$ !
$ REMSHRLIB CLIMSG.B32
$ GETSHRLIB CLIMSG.B32	! Share with DCL facility
$ !
$ @SYSBLDCOM$:FASM RTL "" Y 'UPDATES N Y
$ PURGE LIS$:
$ PURGE OBJ$:
$ !
$ GOTO EXIT
$
$OBJLIB:
$ !
$ ! Delete all unnecessary .OBJ files.
$ !
$ RENAME OBJ$:ALLGBL.OBJ OBJ$:ALLGBL.OXX
$ RENAME OBJ$:RTLVECTOR.OBJ OBJ$:RTLVECTOR.OXX
$ DELETE OBJ$:*.OBJ;*
$ RENAME OBJ$:*.OXX;* OBJ$:*.OBJ
$ !
$ GOTO EXIT
$
$LNKLIB:
$ !
$ !
$ !	LINK ALLGBL AGAINST THE DEFAULT OBJECT LIBRARY TO REFERENCE
$ !	ALL RTL GLOBALS.
$ !	ALL SYMBOLS SHOULD BE DEFINED!
$ !
$ ON ERROR THEN CONTINUE
$ ! ALLGBL.OBJ was assembled in the ASSEM phase
$ DELETE MAP$:ALLGBL.MAP.*
$ ON ERROR THEN GOTO FAIL
$ LINK/NOSYSSHR/NOTRACE/FULL/CROSS/MAP=MAP$:ALLGBL/EXE=EXE$:ALLGBL -
	OBJ$:ALLGBL
$ !
$ !	Build the shared Run-Time Library and copy it to SYS$LIBRARY:
$ !
$ !	THIS MUST PRECEDE THE LINKING OF ANY FACILITY THAT
$ !		USES SHARED RTL PROCEDURES.
$ !
$ @COM$:VMSRTLLNK
$ CPYSYSLIB EXE$:VMSRTL.EXE
$ INSHARLIB EXE$:VMSRTL	
$ !
$ GOTO EXIT
$
$LINK:
$ !
$ ! Null LINK phase, all done in LNKLIB phase
$ !
$ GOTO EXIT
$
$RESULT:
$ !
$ !	Move RTLVECTOR.OBJ to SYS$LIBRARY:
$ !
$ CPYSYSLIB OBJ$:RTLVECTOR.OBJ
$ !
$ !	Enter synonyms in our LIS$ for modules built by VMSLIB so
$ !	that they can be found easier.  Also insert those objects into
$ !	RTL.OLB.
$ !
$ ON ERROR THEN CONTINUE
$ IF F$SEARCH("LIS$:LIBCLICAL.LIS") .NES. "" THEN -
  SET FILE LIS$:LIBCLICAL.LIS;* /REMOVE
$ IF F$SEARCH("LIS$:LIBCVTATB.LIS") .NES. "" THEN -
  SET FILE LIS$:LIBCVTATB.LIS;* /REMOVE
$ IF F$SEARCH("LIS$:LIBSCRPKG.LIS") .NES. "" THEN -
  SET FILE LIS$:LIBSCRPKG.LIS;* /REMOVE
$ IF F$SEARCH("LIS$:LIBTPARSE.LIS") .NES. "" THEN -
  SET FILE LIS$:LIBTPARSE.LIS;* /REMOVE
$ SET FILE /ENTER=LIS$:LIBCLICAL.LIS LISD$:[VMSLIB.LIS]LIBCLICAL.LIS
$ SET FILE /ENTER=LIS$:LIBCVTATB.LIS LISD$:[VMSLIB.LIS]CVTATB.LIS
$ SET FILE /ENTER=LIS$:LIBSCRPKG.LIS LISD$:[VMSLIB.LIS]SCRPKG.LIS
$ SET FILE /ENTER=LIS$:LIBTPARSE.LIS LISD$:[VMSLIB.LIS]TPARSE.LIS
$ LIB LIB$:RTL OBJD$:[VMSLIB.OBJ]LIBCLICAL,CVTATB,TPARSE
$ ON ERROR THEN GOTO FAIL
$ !
$ ! Test the vector to make sure no undesired changes have occurred
$ !
$ @COM$:VECTORTST
$ GOTO EXIT
$FAIL:
$ STATUS = $STATUS
$ WRITE SYS$OUTPUT "%RTL-F-FAIL, >>>>>>>>>> RTL FAILURE <<<<<<<<<<"
$EXIT:
$ ! DEASSIGN any logical names assigned in this batch file
$ ! so reduce chances of affecting other builds.
$ @COM$:RTLLOGNAM DEASSIGN
$ !
$ EXIT STATUS
