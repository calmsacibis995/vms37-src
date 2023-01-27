$ !
$ !	[ R U N O F F . C O M ] R U N O F F B L D . C O M
$ !
$ !	Assume default directory is [RUNOFF] and logical names
$ !	BUG$, COM$, ENH$, EXE$, LIB$, LIS$, MAP$, OBJ$, and SRC$
$ !	are defined.
$ !
$ GOTO 'PHASE'
$ 
$INIT:
$ !
$ !	Create the Directories
$ !
$ @SYSBLDCOM$:CREATEDIR
$ EXIT
$
$UPDATE:
$ !
$ !	Update all 48 require files to get them copied to SRC$!!!
$ !
$ SRCUPDATE ARECCC.REQ
$ SRCUPDATE ATCODE.REQ
$ SRCUPDATE BIGNUM.REQ
$ SRCUPDATE BOOL.REQ
$ SRCUPDATE BPOSIT.REQ
$ SRCUPDATE CLHCC.REQ
$ SRCUPDATE CLHOPS.REQ
$ SRCUPDATE CLIST.REQ
$ SRCUPDATE CONVRT.REQ
$ SRCUPDATE DIGIT.REQ
$ SRCUPDATE FLGT.REQ
$ SRCUPDATE FOOFIL.REQ
$ SRCUPDATE FNCT.REQ
$ SRCUPDATE FRMSTK.REQ
$ SRCUPDATE FSPACK.REQ
$ SRCUPDATE GCA.REQ
$ SRCUPDATE GETQSC.REQ
$ SRCUPDATE GNCC.REQ
$ SRCUPDATE GSLUCC.REQ
$ SRCUPDATE HCT.REQ
$ SRCUPDATE HLC.REQ
$ SRCUPDATE IFSTK.REQ
$ SRCUPDATE INDEX.REQ
$ SRCUPDATE IRAC.REQ
$ SRCUPDATE KC.REQ
$ SRCUPDATE KWITEM.REQ
$ SRCUPDATE LETTER.REQ
$ SRCUPDATE LSTBTS.REQ
$ SRCUPDATE LSTOPS.REQ
$ SRCUPDATE MSGTXT.REQ
$ SRCUPDATE NBITS.REQ
$ SRCUPDATE NMLST.REQ
$ SRCUPDATE NUMPRM.REQ
$ SRCUPDATE OUTOPT.REQ
$ SRCUPDATE PAGEN.REQ
$ SRCUPDATE PDT.REQ
$ SRCUPDATE PHDEF.REQ
$ SRCUPDATE POOL.REQ
$ SRCUPDATE RNODEF.REQ
$ SRCUPDATE RNOMAC.REQ
$ SRCUPDATE RUNHAN.REQ
$ SRCUPDATE RUNTAB.REQ
$ SRCUPDATE SCA.REQ
$ SRCUPDATE SETCAS.REQ
$ SRCUPDATE TOCRTY.REQ
$ SRCUPDATE TPROB.REQ
$ SRCUPDATE TSF.REQ
$ SRCUPDATE VR.REQ
$ SRCUPDATE XTNTAB.REQ
$ EXIT
$
$SRCLIB:
$ !
$ !	Not necesary to delete and re-create macro librarys.
$ !
$ EXIT
$
$ASSEM:
!
!	Do BLISS compiles of RUNOFF modules
!
$ @COM$:ASSIGNREQ			  ! Define REQUIRE logical names
$ @SYSBLDCOM$:FASM RUNOFF "" N 'UPDATES'
$ @COM$:DEASREQ				  ! Dispose of special logical names
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @com$:dsrutlsr SAVE			  ! Save modules specific to utilities
$ @SYSBLDCOM$:OBJLIB RUNOFF  590 500 110  ! Generate RUNOFF.OLB
$ @com$:dsrutlsr RESTORE		  ! Restore utility specific modules
$ @SYSBLDCOM$:OBJLIB DSRUTL   95  40   6  ! Generate DSRUTL.OLB
$ EXIT
$
$LNKLIB:
$ !
$ ! Null LNKLIB phase
$ !
$ EXIT
$
$LINK:
$ !
$ !	Delete linker map and image then re-create EXE$:RUNOFF.EXE
$ !			and MAP$:RUNOFF.MAP
$ !
$ DELETE EXE$:RUNOFF.EXE;*, MAP$:RUNOFF.MAP;*	! Dump old map and image
$ DELETE EXE$:TOC.EXE;*, MAP$:TOC.MAP;*
$ DELETE EXE$:TCX.EXE;*, MAP$:TCX.MAP;*
$ @COM$:RUNOFFLNK				! generate new map and image
$ @COM$:DSRUTLLNK				! generate TOC and TCX
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:RUNOFF.EXE,EXE$:TOC.EXE,EXE$:TCX.EXE
$ CPYRESMAP MAP$:RUNOFF.MAP	RUNOFF.MAP
$ CPYRESMAP MAP$:TOC.MAP	TOC.MAP
$ CPYRESMAP MAP$:TCX.MAP	TCX.MAP
$ !
$ !	Build the concatenated listing RUNOFF.LSS
$ !
$ CPYRESLIS SRC$:*.REQ,*.MSG,LIS$:*.LIS RUNOFF.LSS
