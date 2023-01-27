$ !
$ !	[ I N I T . C O M ] I N I T B L D . C O M
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
$ !	Create updated require file sources
$ !
$ DELETE SRC$:*.*;*
$ SRCUPDATE INIDEF.B32
$ EXIT
$
$SRCLIB:
$ PREVDIR:='F$LOG("SYS$DISK")''F$DIR()'
$ SET DEFAULT [VMSLIB]
$ MESSAGE/MDL=SRC$:INITMSG/NOOBJ SRC$:INITMSG
$ MCR MDL LIB$:INITMSG=SRC$:INITMSG
$ COPY LIB$:INITMSG.B32 LIB$:INITMSG.REQ
$ SET DEF 'PREVDIR'
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and recompile objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*, LIS$:*.LIS;*
$ @SYSBLDCOM$:FASM 'FACNAM "" N 'UPDATES
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB INIT
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
$ !	Delete INIT map and image then re-create EXE$:INIT.EXE
$ !			and MAP$:INIT.MAP
$ !
$ DELETE EXE$:INIT.EXE;*, MAP$:.MAP;*
$ @COM$:INITLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:INIT.EXE
$ CPYRESMAP MAP$:INIT.MAP
$ !
$ !	Build the concatenated listing RESLIS$:INIT.LSS
$ !
$ CPYRESLIS SRC$:INIDEF.B32,LIS$:*.LIS INIT.LSS
