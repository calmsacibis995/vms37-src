$ !
$ !	DIRECTORY COMMAND BUILD PROCEDURE
$ !
$ GOTO 'PHASE'
$
$INIT:
$ !
$ !	Create the Directories
$ !
$ @SYSBLDCOM$:CREATEDIR
$ EXIT

$UPDATE:
$ !
$ !	UPDATE THE REQUIRE FILES WITH SLP CHANGES
$ !
$ SRCUPDATE DIRDEF.REQ
$ EXIT
$
$SRCLIB:
$ !
$ !	GET STRUCTURE DEFINITIONS
$ !
$ EXIT
$
$ASSEM:
$ !
$ !	DELETE AND RE-CREATE THE OBJECT MODULES AND LISTINGS
$ !
$ REMSHRLIB CLIMSG.B32
$ GETSHRLIB CLIMSG.B32		! Share file with DCL
$ @SYSBLDCOM$:FASM 'FACNAM' "" NOLIB 'UPDATES'
$ EXIT
$
$OBJLIB:
$ !
$ !	The object library is created during the assembly phase.
$ !
$ @SYSBLDCOM$:OBJLIB DIRECTORY
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
$ !	Delete AND re-create EXE$:DIRECTORY.EXE AND MAP$:DIRECTORY.MAP
$ !
$ @COM$:DIRLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:DIRECTORY.EXE
$ CPYRESMAP MAP$:DIRECTORY.MAP
$ !
$ !	Build the concatenated listing DIRECTORY.LSS
$ !
$ CPYRESLIS SRC$:LIS$:*.LIS DIRECTORY.LSS
