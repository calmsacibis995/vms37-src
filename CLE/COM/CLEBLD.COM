$ !
$ !	Build the command language editor facility
$ !
$ GOTO 'PHASE'
$
$INIT:
$ !
$ ! Create the directories
$ !
$ @SYSBLDCOM$:CREATEDIR
$ EXIT
$
$UPDATE:
$ !
$ !	Create updated sources.
$ !
$ DELETE SRC$:*.*;*
$ SRCUPDATE CLEDEF.REQ
$ SRCUPDATE SYMDEF.MDL
$ SRCUPDATE UTILDEF.REQ
$ DELSHRLIB LIB$:UTILDEF.REQ
$ COPY SRC$:UTILDEF.REQ LIB$:
$ CPYSHRLIB LIB$:UTILDEF.REQ			! Allow others to use it
$ EXIT
$
$SRCLIB:
$ !
$ !	Translate the MDL files
$ !
$ DELETE LIB$:SYMDEF.MAR;*, .B32;*
$ MCR MDL LIB$:SYMDEF=SRC$:SYMDEF
$ EXIT
$
$ASSEM:
$ !
$ ! Do the compilations
$ !
$ REMSHRLIB PPDDEF.B32
$ REMSHRLIB CLIDEF.B32
$ DELETE OBJ$:*.OBJ;* , LIS$:*.LIS;*
$ GETSHRLIB PPDDEF.B32			! Get LOGIN structure definitions
$ GETSHRLIB CLIDEF.B32			! Get DCL structure definitions
$ @SYSBLDCOM$:FASM 'FACNAM' "" NOLIB 'UPDATES'
$ COPY OBJ$:CLINT.OBJ OBJ$:CLINT.OBB
$ EXIT
$
$OBJLIB:
$ !
$ ! Create the object library
$ !
$ @SYSBLDCOM$:OBJLIB CLEDITOR
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
$ ! Create the linked image and map
$ !
$ @COM$:CLELNK
$ EXIT
$
$RESULT:
$ !
$ ! Copy the .EXE and .MAP to the system area
$ !
$ CPYRESEXE EXE$:CLEDITOR.EXE
$ CPYRESMAP MAP$:CLEDITOR.MAP
$ CPYRESLIS LIS$:*.LIS CLEDITOR.LSS
