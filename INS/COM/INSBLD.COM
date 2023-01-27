$ !
$ !	[ I N S . C O M ] I N S B L D . C O M
$ !
$ !	THIS COMMAND FILE BUILDS THE INSTALL UTILITY.
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
$ SRCUPDATE INSMSG.MSG
$ SRCUPDATE INSDEF.MDL
$ SRCUPDATE INSPREFIX.REQ
$ SRCUPDATE INSTALCMD.CLD
$ SRCUPDATE INSTALHLP.HLP
$ EXIT
$
$SRCLIB:
$ !
$ ! Build library containing error message codes and severity levels.
$ !
$ ON ERROR THEN CONTINUE
$ MCR MDL LIB$:INSDEF=SRC$:INSDEF
$ LIBRAR/HELP/CREATE=(BLOCKS:8,MODULE:16,GLOBALS:0) OBJ$:INSTALHLP SRC$:INSTALHLP
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the INSTALL objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*,*.LIS;*
$ @SYSBLDCOM$:FASM 'FACNAM "" N 'UPDATES
$ SET COMMAND SRC$:INSTALCMD /OBJECT=OBJ$:INSTALCMD /LISTING=LIS$:INSTALCMD
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB INSTALL
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
$ !	Delete INSTALL map and image then re-create EXE$:INSTALL.EXE
$ !			and MAP$:INSTALL.MAP
$ !
$ DELETE EXE$:INSTALL.EXE;*, MAP$:.MAP;*
$ @COM$:INSLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE  EXE$:INSTALL.EXE
$ CPYRESMAP  MAP$:INSTALL.MAP
$ CPYSYSHLP  OBJ$:INSTALHLP.HLB
$ !
$ !	Build the concatenated listing RESLIS$:INSTALL.LSS
$ !
$ CPYRESLIS  LIS$:*.LIS  INSTALL.LSS
$ EXIT
