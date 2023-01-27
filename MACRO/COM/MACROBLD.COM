$ !
$ !	[ M A C R O . C O M ] M A C R O B L D . C O M
$ !
$ !	This command file builds the VAX/VMS MACRO assembler.
$ !
$ !	Assume default directory is [MACRO] and logical names
$ !	BUG$, COM$, ENH$, EXE$, LIB$, LIS$, MAP$, OBJ$ and SRC$
$ !	are defined.
$ !
$ GOTO 'PHASE'
$
$INIT:
$ !
$ !	Create the directories
$ !
$ @SYSBLDCOM$:CREATEDIR
$ EXIT
$
$UPDATE:
$ !
$ !	Update the master Macro Library source files.
$ !
$ SRCUPDATE CRFMACROS.MAR
$ SRCUPDATE DEFINE.MAR
$ SRCUPDATE MACMSG.MSG
$ EXIT
$
$SRCLIB:
$ !
$ !	Delete and re-create the macro library.
$ !
$ DELETE LIB$:MACRO.MLB;*,CRFMAC.MLB;*
$ MESSAGE/MDL=SRC$:MACMSG/NOOBJ SRC$:MACMSG
$ MCR MDL LIB$:MACMSG=SRC$:MACMSG
$ LIBRARY/CREATE=(BLOCKS:40,GLOBALS:0,MODULES:64)/MACRO-
	LIB$:MACRO SRC$:DEFINE,LIB$:MACMSG
$ LIBRARY/CREATE/MACRO LIB$:CRFMAC SRC$:CRFMACROS
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the object and listing files.
$ !
$ DELETE OBJ$:*.OBJ;*,LIS$:*.LIS;*,*.LSS;*
$ COPY SRC$:DEFINE.MAR LIS$:DEFINE.LIS
$ @SYSBLDCOM$:FASM MACRO "" N 'UPDATES'
$ EXIT
$
$OBJLIB:
$ !
$ !	Concatenate the object files, delete and re-create the object
$ !	library file, then delete the concatenated object file.
$ !
$ @SYSBLDCOM$:OBJLIB MACRO 420 1024 64
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
$ !	Delete and re-create the image and map files
$ !
$ DELETE EXE$:MACRO32.EXE;*,MAP$:MACRO32.MAP;*
$ @COM$:MACROLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the image and map files to a SYSTEM area
$ !
$ CPYRESEXE EXE$:MACRO32.EXE
$ CPYRESMAP MAP$:MACRO32.MAP
$ !
$ !	Concatenate the listing files and copy them to the SYSTEM area.
$ !
$ CPYRESLIS LIS$:*.LIS MACRO32.LSS
