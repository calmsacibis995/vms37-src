$ !
$ !	VMS unsupported utilities
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
$ SRCUPDATE CHKSUM.CLD
$ EXIT
$
$SRCLIB:
$ !
$ !	Delete and re-create the macro library
$ !
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*, LIS$:*.LIS;*
$ @SYSBLDCOM$:FASM 'FACNAM' "" NOLIB 'UPDATES'
$ EXIT
$
$OBJLIB:
$ @SYSBLDCOM$:OBJLIB UTIL32
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
$ !	Delete link map and image then re-create the image and maps
$ !
$ @COM$:CHKSUMLNK
$ @COM$:DISKQLNK
$ @COM$:RTBLNK
$ @COM$:SEARCHLNK
$ @COM$:SETUSRLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE to a System area
$ !
$ CPYRESEXE EXE$:CHECKSUM.EXE
$ CPYRESEXE SRC$:CHKSUM.CLD
$ CPYRESEXE EXE$:DISKQ.EXE
$ CPYRESEXE EXE$:RTB.EXE
$ CPYRESEXE EXE$:SEARCH.EXE
$ CPYRESEXE EXE$:SETUSER.EXE
