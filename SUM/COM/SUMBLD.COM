$ !
$ !	[ S U M . C O M ] S U M B L D . C O M
$ !
$ !	This command file builds the Source Update Merge (SUM)
$ !	procedures.
$ !
$ !	Assume default directory is [SUM] and logical names
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
$ SRCUPDATE SUMDEF.MAR
$ SRCUPDATE SUMMSG.MSG
$ PUTSYSMSG SRC$:SUMMSG.MSG			! Insert in SYSMSG.TLB
$ !
$ EXIT
$
$SRCLIB:
$ !
$ !	Delete and re-create the macro library.
$ !
$ DELSHRLIB LIB$:SUM.MLB
$ DELETE LIB$:SUMMSG.B32;*,.MAR;*
$ MESSAGE/MDL=SRC$:SUMMSG/NOOBJ SRC$:SUMMSG
$ MCR MDL LIB$:SUMMSG=SRC$:SUMMSG
$ LIBRARY/MACRO/CREATE=(BLOCKS:10,GLOBALS:0,MODULES:64)  LIB$:SUM -
		  SRC$:SUMDEF,LIB$:SUMMSG
$ CPYSHRLIB LIB$:SUM.MLB		! Share file with MACRO
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the object and listing files.
$ !
$ DELETE OBJ$:*.OBJ;*,LIS$:*.LIS;*,*.LSS;*
$ @SYSBLDCOM$:FASM SUM "" N 'UPDATES'
$ EXIT
$
$OBJLIB:
$ !
$ !	Concatenate the object files, delete and re-create the object
$ !	library file, then delete the concatenated object file.
$ !
$ @SYSBLDCOM$:OBJLIB SUM 75 64 64
$ EXIT
$
$LNKLIB:
$ !
$ !	Link sharable section and copy to sys$library
$ !
$ @COM$:SUMSHRLNK
$ CPYSYSLIB EXE$:SUMSHR.EXE
$ INSHARLIB EXE$:SUMSHR			!Insert into IMAGELIB
$ EXIT
$
$LINK:
$ !
$ ! Link utilities
$ !
$ !
$ !	Link SUMSLP utility
$ !
$ @COM$:SUMSLPLNK
$ !
$ !	Link SUM utility
$ !
$ @COM$:SUMLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the image and map files to a SYSTEM area
$ !
$ CPYRESMAP MAP$:SUMSHR.MAP
$ CPYRESEXE EXE$:SUMSLP.EXE
$ CPYRESMAP MAP$:SUMSLP.MAP
$ CPYRESEXE EXE$:SUM.EXE
$ CPYRESMAP MAP$:SUM.MAP
$ !
$ !	Concatenate the listing files and copy them to the SYSTEM area.
$ !
$ CPYRESLIS LIS$:*.LIS SUM.LSS
