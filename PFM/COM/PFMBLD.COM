$ !
$ !	[ P F M . C O M ] P F M B L D . C O M
$ !
$ !	Assume default directory is [PFM] and logical names
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
$ !	Create updated sources.
$ !
$ SRCUPDATE PFM.MDL
$ SRCUPDATE PFMON.HLP
$ EXIT
$
$SRCLIB:
$ !
$ !	Delete and re-create the macro library LIB$:PFM.MLB
$ !
$ DELETE LIB$:PFM.MLB;*
$ MCR MDL LIB$:PFM=SRC$:PFM
$ LIBRARY/MACRO/CREATE LIB$:PFM LIB$:PFM
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*,	LIS$:*.LIS;*
$ SET NOON				! In case of errors
$ @SYSBLDCOM$:FASM PFM "" N 'UPDATES'
$ EXIT
$
$OBJLIB:
$ !
$ !	Copy the module PGFALTMON.OBJ to SYS$LIBRARY
$ !
$ CPYSYSLIB OBJ$:PGFALTMON.OBJ
$ !
$ !	Create object library from object modules.
$ !
$ DELETE LIB$:PFM.OLB;*
$ LIB/CREATE=(BLOCKS=50,MODULES=10,GLOBALS=50) LIB$:PFM OBJ$:*.OBJ
$ RENAME OBJ$:PGFALTMON.OBJ;* OBJ$:PGFALTMON.OBI;*
$ DELETE OBJ$:*.OBJ;*
$ RENAME OBJ$:PGFALTMON.OBI;* OBJ$:PGFALTMON.OBJ;*
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
$ !	Delete and recreate the images PFMFILWRT.EXE and
$ !	PFMANALYZ.EXE
$ !
$ DELETE EXE$:PFMFILWRT.EXE;*, PFMANALYZ.EXE;*
$ DELETE MAP$:PFMFILWRT.MAP;*, PFMANALYZ.MAP;*
$ @COM$:PFMANLLNK
$ @COM$:PFMWRTLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:PFMFILWRT.EXE
$ CPYRESEXE EXE$:PFMANALYZ.EXE
$ CPYRESMAP COM$:PFMWRTLNK.COM,MAP$:PFMFILWRT.MAP	PFMFILWRT.MAP
$ CPYRESMAP COM$:PFMANLLNK.COM,MAP$:PFMANALYZ.MAP	PFMANALYZ.MAP
$ CPYSYSHLP SRC$:PFMON.HLP
$ !
$ !	Build the concatenated listing PFM.LSS
$ !
$ CPYRESLIS LIS$:*.LIS PFM.LSS
