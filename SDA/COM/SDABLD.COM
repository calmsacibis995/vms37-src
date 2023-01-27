$ !
$ !	System Dump Analyzer Build Procedure
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
$ SRCUPDATE MACROS.MAR
$ SRCUPDATE SDADEF.MDL
$ SRCUPDATE SCRDEF.MDL
$ SRCUPDATE VAXOPS.REQ
$
$ SRCUPDATE SYSDEF.MAR		! Auxiliary global symbols
$ SRCUPDATE RMSDEF.MAR
$ SRCUPDATE IMGDEF.MAR
$ SRCUPDATE DCLDEF.MAR
$ SRCUPDATE NETDEF.MAR
$ SRCUPDATE SCSDEF.MAR
$ SRCUPDATE SDA.HLP
$ EXIT
$
$SRCLIB:
$ !
$ !	Delete and re-create the macro library LIB$:SDALIB.MLB
$ !
$ DELETE LIB$:SDALIB.MLB;*
$ MCR MDL LIB$:SDADEF=SRC$:SDADEF
$ MCR MDL LIB$:SCRDEF=SRC$:SCRDEF
$ LIB/MAC/CREATE LIB$:SDALIB LIB$:SDADEF,SCRDEF,SRC$:MACROS
$ DELETE LIB$:SDADEF.MAR;*, .B32;*
$ DELETE LIB$:SCRDEF.MAR;*, .B32;*
$ !
$ !	Create auxiliary help library
$ !
$ DELETE LIB$:SDA.HLB;*
$ LIB/CREATE/HELP LIB$:SDA SRC$:SDA
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ @SYSBLDCOM$:FASM 'FACNAM' "" NOLIB 'UPDATES'
$ !
$ !	Create the auxiliary global symbol files for use with SDA
$ !
$ MACRO SRC$:SYSDEF /OBJECT=LIB$:SYSDEF.STB /NOLIST
$ MACRO SRC$:RMSDEF /OBJECT=LIB$:RMSDEF.STB /NOLIST
$ MACRO SRC$:IMGDEF /OBJECT=LIB$:IMGDEF.STB /NOLIST
$ MACRO SRC$:DCLDEF+SHRLIB$:DCL/LIB -
	/OBJECT=LIB$:DCLDEF.STB /NOLIST
$ MACRO SRC$:NETDEF+LIBD$:[SYS.OBJ]LIB/LIB /OBJECT=LIB$:NETDEF.STB /NOLIST
$ MACRO SRC$:SCSDEF+LIBD$:[SYS.OBJ]LIB/LIB+SHRLIB$:PALIB/LIB -
	/OBJECT=LIB$:SCSDEF.STB /NOLIST
$ EXIT
$
$OBJLIB:
$ !
$ !	The object library is created during the assembly phase.
$ !
$ @SYSBLDCOM$:OBJLIB 'FACNAM'
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
$ !	Delete link map and image then re-create EXE$:SDA.EXE
$ !			and MAP$:SDA.MAP
$ !
$ !
$ ! Link SDA twice, the first time without SYS.STB to catch undefined
$ ! symbols that are not supposed to be resolved by linking against
$ ! the system symbol table.  Then link against SYS.STB.
$ !
$ @COM$:SDALNK "" "TEST"
$ @COM$:SDALNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:SDA.EXE
$ CPYRESMAP MAP$:SDA.MAP
$ !
$ !	Copy the auxiliary global symbol files
$ !
$ CPYRESEXE LIB$:SYSDEF.STB
$ CPYRESEXE LIB$:RMSDEF.STB
$ CPYRESEXE LIB$:IMGDEF.STB
$ CPYRESEXE LIB$:DCLDEF.STB
$ CPYRESEXE LIB$:NETDEF.STB
$ CPYRESEXE LIB$:SCSDEF.STB
$ !
$ !	Copy the help library to [syshlp]
$ !
$ CPYSYSHLP LIB$:SDA.HLB
$ !
$ !	Build the concatenated listing SDA.LSS
$ !
$ CPYRESLIS SRC$:LIS$:*.LIS SDA.LSS
