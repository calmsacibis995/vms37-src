$ !
$ !	[ EDF.COM ] E D F B L D . C O M
$ !
$ !
$ !	Assumes [EDF] and definitions for  EXE$:,OBJ$:,LIS$:,
$ !		MAP$:,COM$:
$ !
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
$ !	Create updated sources
$ !
$ DELETE SRC$:*.*;*
$ SRCUPDATE EDFHLP.HLP
$ SRCUPDATE EDFMSG.MSG
$ SRCUPDATE EDFCONST.PAS
$ SRCUPDATE EDFTYPE.PAS
$ SRCUPDATE EDFVAR.PAS
$ SRCUPDATE EDFVALUE.PAS
$ SRCUPDATE EDFEXTERN.PAS
$ SRCUPDATE EDFCHF.PAS
$ SRCUPDATE EDFUTIL.PAS
$ SRCUPDATE EDFASK.PAS
$ SRCUPDATE EDFSHOW.PAS
$ SRCUPDATE EDFDESIGN.PAS
$ SRCUPDATE EDFFUNCS.PAS
$ EXIT
$
$SRCLIB:
$ !
$ !	Re-create the Help library
$ !
$ LIBRARY/CREATE=(BLOCKS=35,MODULES=20,GLOBALS=0)/HELP OBJ$:EDFHLP SRC$:EDFHLP
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly and bliss objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*,LIS$:*.LSS;*,*.LIS;*
$ @SYSBLDCOM$:FASM 'FACNAM "" N 'UPDATES
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB EDF
$ EXIT
$
$LNKLIB:
$ !
$ !	Null lnklib phase
$ !
$ EXIT
$
$LINK:
$ !
$ !	Delete EDF map and image then re-create EXE$:EDF.EXE
$ !			and MAP$:EDF.MAP
$ !
$ DELETE EXE$:EDF.EXE;*,MAP$:EDF.MAP;*
$ @COM$:EDFLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXEs and MAPs to a System area
$ !
$ CPYRESEXE EXE$:EDF.EXE
$ CPYRESMAP MAP$:EDF.MAP
$ CPYSYSHLP OBJ$:EDFHLP.HLB
$ !
$ !	Build the concatenated listing LIS$:EDF.LSS
$ !
$ CPYRESLIS LIS$:*.LIS EDF.LSS
