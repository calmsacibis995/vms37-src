$ !
$ !	[ RUF.COM ] R U F B L D . C O M
$ !
$ !
$ !	Assumes [RUF] and definitions for  EXE$:,OBJ$:,LIS$:,
$ !		MAP$:,COM$:
$ !
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
$ !	Create updated sources
$ !
$ DELETE SRC$:*.*;*
$ SRCUPDATE RUF.MDL
$ SRCUPDATE RUFUSR.MDL
$ CPYSHRLIB SRC$:RUFUSR.MDL		! Share file with VMSLIB component
$ EXIT
$
$SRCLIB:
$ !
$ !	Delete and re-create the macro library LIB$:RUF.MLB
$ !
$ DELETE LIB$:*.MAR;*,*.B32;*,*.MLB;*
$ MCR MDL LIB$:RUF=SRC$:RUF
$ MCR MDL LIB$:RUFUSR=SRC$:RUFUSR
$ !MESSAGE/MDL=SRC$:RUFMSG/NOOBJ SRC$:RUFMSG
$ !
$ LIBRARY/MACRO/CREATE LIB$:RUFLIB LIB$:RUF, LIB$:RUFUSR
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly and bliss objects and listings
$ !
$ DELETE OBJ$:*.OBJ;*,LIS$:*.LSS;*,*.LIS;*
$ @SYSBLDCOM$:FASM 'FACNAM "" N 'UPDATES
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB RUF
$ EXIT
$
$LNKLIB:
$ !
$ !	Delete ruflibrary map and image then re-create EXE$:RUFSHR.EXE
$ !			and MAP$:RUFSHR.MAP
$ !
$ DELETE EXE$:RUFSHR.EXE;*,.STB;*,MAP$:.MAP;*
$ @COM$:RUFSHRLNK
$ !CPYSYSLIB EXE$:RUFSHR.EXE		! Copy to library area
$ !INSHARLIB EXE$:RUFSHR		! Insert into IMAGELIB
$ EXIT
$
$LINK:
$ !
$ !	Delete RUFTEST map and image then re-create EXE$:RUFTEST.EXE
$ !			and MAP$:RUFTEST.MAP
$ !
$ DELETE EXE$:RUFTEST.EXE;*,MAP$:.MAP;*
$ LINK/NOSYSSHR/DEBUG /EXE=EXE$:RUFTEST	/MAP=MAP$:RUFTEST /FULL /CROSS-
	LIB$:RUF/INCLUDE=(RUFTEST),SYS$INPUT:/OPTIONS
!
! SYSTEM IMAGE
!
	EXSM:SYS.STB/SELECT
!
! RECOVERY-UNIT SHAREABLE IMAGE
!
	EXE$:RUFSHR/SHARE=NOCOPY
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:RUFSHR.EXE
$ CPYRESMAP MAP$:RUFSHR.MAP
$ !
$ !	Build the concatenated listing LIS$:RUF.LSS
$ !
$ CPYRESLIS LIS$:*.LIS RUF.LSS
