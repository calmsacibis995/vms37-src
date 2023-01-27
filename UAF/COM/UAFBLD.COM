$ !
$ !	[UAF.COM] U A F B L D . C O M
$ !
$ !	Command file to build AUTHORIZE program
$ !
$ ! 	Assumes [UAF] and definitions for EXE$: , OBJ$: , LIS$: ,
$ !		MAP$: , COM$:
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
$ !	Update cld file, help file
$ !
$ SRCUPDATE AUTHORIZE.CLD
$ SRCUPDATE UAFHELP.HLP
$ EXIT
$
$SRCLIB:
$ !
$ !	AUTHORIZE has no macro libraries, but it has a help library
$ !
$ LIBRAR/HELP/CREATE=(MODULES:9) OBJ$:UAFHELP SRC$:UAFHELP
$ EXIT
$
$ASSEM:
$ !
$ !	HPWD is assembled by login and SETPRIV comes out of STARLET.OLB
$ !	Delete and re-create the objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*,LIS$:*.LSS;*,*.LIS;*
$ @SYSBLDCOM$:FASM 'FACNAM' "" NOLIB 'UPDATES'
$ SET COMMAND/OBJ=OBJ$: SRC$:AUTHORIZE
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB UAF
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
$ !	Delete authorize map and image then re-create EXE$:AUTHORIZE.EXE
$ !			and MAP$:AUTHORIZE.MAP
$ !
$ DELETE EXE$:AUTHORIZE.EXE;*,MAP$:.MAP;*
$ @COM$:UAFLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE, MAP, and HLB  to a System area
$ !
$ CPYRESEXE EXE$:AUTHORIZE.EXE
$ CPYRESMAP MAP$:AUTHORIZE.MAP
$ CPYSYSHLP OBJ$:UAFHELP.HLB
$ !
$ !	Build the concatenated listing
$ !
$ CPYRESLIS LIS$:*.LIS AUTHORIZE.LSS
