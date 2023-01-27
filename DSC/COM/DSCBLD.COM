$ !
$ !	[ DSC.COM ] D S C B L D . C O M
$ !
$ ! This command procedure builds DSC1 and DSC2
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
$ @COM$:DSCUPD
$ EXIT
$
$SRCLIB:
$ !
$ !	***  DSC has no source library phase  ***
$ !
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*,*.OB1;*,	LIS$:*.LST;*,*.LS1;*,*.LSS;*
$ @COM$:DSCASM
$ EXIT
$
$OBJLIB:
$ !
$ !	Concatenate the objects, delete and re-create the object
$ !		library LIB$:DSC1.OLB and DSC2.OLB, delete the
$ !		concatenated objects file.
$ !
$ COPY OBJ$:*.OBJ OBJ$:DSC2.OBS
$ COPY OBJ$:*.OB1,TPRDY.OBJ OBJ$:DSC1.OBS
$ DELETE LIB$:DSC1.OLB;*,DSC2.OLB;*
$ LIBRARIAN /RSX /CREATE:(MODULES:200, GLOBALS:1100, BLOCKS:50)-
  LIB$:DSC2 OBJ$:DSC2.OBS
$ COPY PRMOBJ$:DSC.OLB LIB$:DSC1.OLB
$ LIBR/RSX LIB$:DSC1 OBJ$:DSC1.OBS
$ DELETE OBJ$:DSC1.OBS;*,OBJ$:DSC2.OBS;*
$ DELETE OBJ$:*.OBJ;*,OBJ$:*.OB1;*
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
$ !	Delete map and image then re-create EXE$:DSC2.EXE
$ !			and MAP$:DSC2.MAP
$ !
$ DELETE EXE$:DSC1.EXE;*,DSC2.EXE;*
$ DELETE MAP$:DSC1.MAP;*,DSC2.MAP;*
$ @COM$:DSC1LNK
$ @COM$:DSC2LNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:DSC1.EXE
$ CPYRESEXE EXE$:DSC2.EXE
$ CPYRESMAP COM$:DSC1LNK.COM,MAP$:DSC1.MAP DSC1.MAP
$ CPYRESMAP COM$:DSC2LNK.COM,MAP$:DSC2.MAP DSC2.MAP
$ !
$ !	Build the concatenated listing LIS$:DSC.LSS
$ !
$ CPYRESLIS LIS$:*.LS1,*.LST DSC.LSS
