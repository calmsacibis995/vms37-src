$ !
$ !	[ M C L D R . C O M ] M C L D R B L D . C O M
$ !
$ !	This component file builds microcode loading facilities.
$ !
$ !	Assume default directory is [MCLDR] and logical names
$ !	BUG$, COM$, ENH$, EXE$, LIB$, LIS$, MAP$, OBJ$, EXECML$, and SRC$ are defined.
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
$ !	Update the master source files.
$ !
$ EXIT
$
$SRCLIB:
$ !
$ !	No macro libraries
$ !
$ EXIT
$
$ ASSEM:
$ !
$ !	Delete and re-create the object and listing files.
$ !
$ DELETE OBJ$:*.OBJ;*,LIS$:*.LIS;*,*.LSS;*
$ @SYSBLDCOM$:FASM 'FACNAM' "" NOLIB 'UPDATES'
$ EXIT
$
$ OBJLIB:
$ !
$ !	No object library.
$ !
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
$ !	Delete and re-create the image and map files.
$ !
$ DELETE EXE$:LALOADER.EXE;*,MAP$:LALOADER.MAP;*
$ DELETE EXE$:LALOAD.EXE;*,MAP$:LALOAD.MAP;*
$ DELETE EXE$:XFLOADER.EXE;*,MAP$:XFLOADER.MAP;*
$ LINK /NOTRACE /EXE=EXE$:LALOADER /MAP=MAP$:LALOADER /FULL /CROSS -
	OBJ$:LALOADER+LAMRMCODE+LAADMCODE+LADAMCODE+LADMDT
$ LINK /NOTRACE /EXE=EXE$:LALOAD /MAP=MAP$:LALOAD /FULL /CROSS -
	OBJ$:LALOAD
$ LINK /NOTRACE /EXE=EXE$:XFLOADER /MAP=MAP$:XFLOADER /FULL /CROSS -
	OBJ$:XFLOADER+EXSM:SYS.STB/SELECTIVE
$ EXIT
$
$RESULT:
$ !
$ !	Copy the image and map files to a System area.
$ !
$ CPYRESEXE EXE$:LALOADER.EXE
$ CPYRESEXE EXE$:LALOAD.EXE
$ CPYRESEXE EXE$:XFLOADER.EXE
$ CPYRESMAP MAP$:LALOADER.MAP
$ CPYRESMAP MAP$:LALOAD.MAP
$ CPYRESMAP MAP$:XFLOADER.MAP
$ !
$ !	Concatenate the listing files and copy them to the System area.
$ !
$ CPYRESLIS LIS$:LALOADER.LIS,LAMRMCODE,LAADMCODE,LADAMCODE,LADMDT -
	LALOADER.LSS
$ CPYRESLIS LIS$:LALOAD.LIS LALOAD.LSS
$ CPYRESLIS LIS$:XFLOADER.LIS XFLOADER.LSS
