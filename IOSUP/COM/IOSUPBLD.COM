$ !
$ !	[ I O S U P . C O M ] I O S U P B L D . C O M
$ !
$ !	This component builds I/O support subroutines.
$ !
$ !	Assume default directory is [IOSUP] and logical names BUG$,
$ !	COM$, ENH$, EXE$, LIB$, LIS$, MAP$, OBJ$, and SRC$ are defined.
$ !
$ GOTO 'PHASE'
$
$ INIT:
$ !
$ !	Create the directories.
$ !
$ @SYSBLDCOM$:CREATEDIR
$ EXIT
$
$ UPDATE:
$ !
$ !	Update the require file sources.
$ !
$ @COM$:IOSUPUPD
$ EXIT
$
$ SRCLIB:
$ !
$ !	Create macro libraries.
$ !
$ LIB/MACRO/CREATE SRC$:DRDEF SRC$:DRDEF
$ EXIT
$
$ ASSEM:
$ !
$ !	Delete and re-create the object and listing files.
$ !
$ DELETE OBJ$:*.OBJ;*, LIS$:*.LIS;*, *.LSS;*
$ @SYSBLDCOM$:FASM 'FACNAM "" N 'UPDATES
$ EXIT
$ OBJLIB:
$ !
$ !	No object library.
$ !
$ EXIT
$
$LNKLIB:
$ !
$ ! Null LNKLIB phase
$ !
$ EXIT
$
$ LINK:
$ !
$ !	The support routines are linked into STARLET.OLB
$ !
$ EXIT
$
$ RESULT:
$ !
$ !	Copy the LPA-11 command files to [SYSMGR]
$ !
$ CPYSYSMGR COM$:LPA11STRT.COM
$ !
$ !	Include the FORTRAN definition file for DR32 support routines
$ !	in SYS$LIBRARY.
$ !
$ CPYSYSLIB SRC$:XFDEF.FOR
$ EXIT
