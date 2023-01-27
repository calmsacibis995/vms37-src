$ !
$ !	[ S O S . C O M ] S O S B L D . C O M
$ !
$ GOTO 'PHASE'
$
$INIT:
$ @SYSBLDCOM$:CREATEDIR		! Create the Directories
$ EXIT
$
$UPDATE:
$ @COM$:SOSUPD			! Create updated require file sources.
$ EXIT
$
$SRCLIB:
$ !	SOS has no macro library
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*, LIS$:*.LST;*, *.LSS;*
$ @SYSBLDCOM$:FASM 'FACNAM "" N 'UPDATES
$ EXIT
$
$OBJLIB:
$ !
$ !	Concatenate the objects, delete and re-create the object
$ !		library LIB$:SOS.OLB then delete the
$ !		concatenated objects file.
$ !
$ COPY OBJ$:*.OBJ OBJ$:SOS.OBS
$ DELETE LIB$:SOS.OLB;*
$ LIBRARIAN /RSX /CREATE:(MODULES:128, GLOBALS:448, BLOCKS:225)-
  LIB$:SOS OBJ$:SOS.OBS
$ DELETE OBJ$:SOS.OBS;*,OBJ$:*.OBJ;*
$ EXIT
$
$LNKLIB:
$ !
$ ! Null LNKLIB phase
$ !
$ EXIT
$
$LINK:
$ SET NOON
$ !
$ !	Delete image, lines-per-page patch data, and map.
$ !	Then recreate  EXE$:SOS.EXE, EXE$:SOSLPG.DAT, and MAP$:SOS.MAP.
$ !
$ DELETE EXE$:SOS.EXE;*, SOSLPG.DAT;*, MAP$:SOS.MAP;*
$ !
$ ! Many diagnostics regarding multiply defined PSECT's will result 
$ ! from the following link and they are unavoidable given the
$ ! current state of SYSLIB.  No other errors are expected.
$ !
$ WRITE SYS$OUTPUT "%BLD-W-FYI, The following error messages are normal.  Ignore them."
$ @SYSBLDCOM$:TKBLPG SOS SOSLNK LINPPG 2
$ SEV=$SEVERITY
$ IF SEV .LT. 3 THEN SEV=1
$ EXIT SEV
$
$RESULT:
$ !
$ !	Copy the EXE, lines-per-page patch data, and MAP to a System area
$ !
$ CPYRESEXE  EXE$:SOS.EXE
$ CPYRESEXE  EXE$:SOSLPG.DAT
$ CPYRESMAP  MAP$:SOS.MAP
$ !
$ !	Build the concatenated listing RESLIS$:SOS.LSS
$ !		Include the prefix file for the MACRO assemblies
$ !		and the BLISS16 include file.
$ !
$ CPYRESLIS  SRC$:PREFIX.MAC,LIS$:*.LST,SRC$:SOSREQ.B16,LIS$:*.LIS SOS.LSS
$ CPYSYSMSG  SRC$:SOS.HLP
