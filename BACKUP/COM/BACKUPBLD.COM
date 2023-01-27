$ !
$ !	[ B A C K U P . C O M ] B A C K U P B L D . C O M
$ !
$ GOTO 'PHASE'
$
$INIT:
$ !
$ !	Create the directories.
$ !
$ @SYSBLDCOM$:CREATEDIR
$ EXIT
$
$UPDATE:
$ !
$ !	Create updated require sources.
$ !
$ SRCUPDATE BACKDEF.MDL
$ SRCUPDATE COMMON.REQ
$ EXIT
$
$SRCLIB:
$ !
$ !	Compile MDL structure definitions.
$ !
$ DELETE LIB$:BACKDEF.B32;*,.MAR;*
$ MCR MDL LIB$:BACKDEF=SRC$:BACKDEF
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the objects and listings.
$ !
$ DELETE SRC$:OTHERMSG.MSG;*, OBJ$:*.OBJ;*, LIS$:*.LIS;*
$ GETSYSMSG CLIMSG,LIBMSG,SSMSG,RMSMSG SRC$:OTHERMSG
$ MESSAGE/OBJ=OBJ$:OTHERMSG/LIS=LIS$:OTHERMSG SRC$:OTHERMSG
$ @SYSBLDCOM$:FASM 'FACNAM' "" NOLIB 'UPDATES'
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB BACKUP
$ EXIT
$
$LNKLIB:
$ !
$ ! Null LNKLIB phase.
$ !
$ EXIT
$
$LINK:
$ !
$ ! Delete maps and images then re-create
$ !	EXE$:BACKUP.EXE and LIS$:BACKUP.MAP
$ !	EXE$:STABACKUP.EXE and LIS$:STABACKUP.MAP
$ !
$ DELETE EXE$:BACKUP.EXE;*, MAP$:.MAP;*, EXE$:STABACKUP.EXE;*, MAP$:.MAP;*
$ @COM$:BACKUPLNK
$ @COM$:STABACLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to the system area.
$ !
$ CPYRESEXE EXE$:BACKUP.EXE
$ CPYRESMAP MAP$:BACKUP.MAP
$ CPYRESEXE EXE$:STABACKUP.EXE
$ CPYRESMAP MAP$:STABACKUP.MAP
$ !
$ !	Build the concatenated listing LIS$:BACKUP.LSS
$ !
$ CPYRESLIS SRC$:COMMON.REQ,LIS$:*.LIS BACKUP.LSS
