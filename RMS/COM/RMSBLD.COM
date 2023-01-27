$ !
$ !
$ !	This command file builds the Record Management Services (RMS32)
$ !	facility.
$ !
$ !	Assume default directory is [RMS] and logical names
$ !	BUG$, COM$, ENH$, EXE$, EXECML$, EXSM, LIB$, LIS$, MAP$, OBJ$, 
$ !	RESD$, RESOBJ$, SRC$, SRCD$, and SYSBLDCOM$ are defined.
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
$ DELSHRLIB SRC$:RMSCALLS.MAR
$ DELSHRLIB SRC$:RMS32MAC.MAR
$ DELSHRLIB SRC$:RMSDEF.MDL
$ DELSHRLIB SRC$:RMSMAC.REQ
$ @COM$:RMSUPD
$ CPYSHRLIB SRC$:RMSMAC.REQ		! Share file with VMSLIB component
$ CPYSHRLIB SRC$:RMSCALLS.MAR		! Share file with VMSLIB component
$ CPYSHRLIB SRC$:RMS32MAC.MAR		! Share file with VMSLIB component
$ CPYSHRLIB SRC$:RMSDEF.MDL		! Share file with MSGFIL component
$ PUTSYSMSG SRC$:RMSFALMSG.MSG		! Share file with MSGFIL component
$ !
$ !	Delete and re-create the macro libraries.  (This must be done in
$ !	the UPDATE phase instead of the SRCLIB phase because it shares
$ !	MDL output with VMSLIB during the SRCLIB phase and there is a
$ !	time synchronization problem.)
$ !
$ DELSHRLIB LIB$:RMSDEF.MAR
$ DELSHRLIB LIB$:RMSFALMSG.MAR
$ DELSHRLIB LIB$:RMSUSR.MAR
$ DELSHRLIB LIB$:RMSDEF.B32
$ DELSHRLIB LIB$:RMSFALMSG.B32
$ DELSHRLIB LIB$:RMSUSR.B32
$ DELSHRLIB LIB$:RMSFILSTR.B32
$ DELSHRLIB LIB$:RMSINTSTR.B32
$ DELSHRLIB LIB$:RMSFILSTR.MAR
$ DELSHRLIB LIB$:RMSINTSTR.MAR
$ DELSHRLIB LIB$:RMS.MLB		! Share with SYS (BACKUP)
$ DELETE LIB$:*.B32;*,*.MAR;*,*.MLB;*,*.R32;*,RMS.L32;*,LIB$:RMS.LST;*
$ @COM$:RMSMLB
$ CPYSHRLIB LIB$:RMSDEF.MAR		! Share file with VMSLIB component
$ CPYSHRLIB LIB$:RMSFALMSG.MAR		! Share file with VMSLIB component
$ CPYSHRLIB LIB$:RMSUSR.MAR		! Share file with VMSLIB component
$ CPYSHRLIB LIB$:RMSDEF.B32		! Share file with VMSLIB component
$ CPYSHRLIB LIB$:RMSFALMSG.B32		! Share file with VMSLIB component
$ CPYSHRLIB LIB$:RMSUSR.B32		! Share file with VMSLIB component
$ CPYSHRLIB LIB$:RMSFILSTR.B32		! Share file with VMSLIB component
$ CPYSHRLIB LIB$:RMSINTSTR.B32		! Share file with CJF	 component
$ CPYSHRLIB LIB$:RMSFILSTR.MAR
$ CPYSHRLIB LIB$:RMSINTSTR.MAR
$ CPYSHRLIB LIB$:RMS.MLB		! Share with SYS (BACKUP)
$ EXIT
$
$SRCLIB:
$ !
$ !	Macro libraries created during UPDATE phase.
$ !
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language object and listing files.
$ !
$ DELETE OBJ$:*.OBJ;*,LIS$:*.LIS;*,*.LSS;*
$ @SYSBLDCOM$:FASM 'FACNAM "" N 'UPDATES
$ RENAME OBJ$:RMSGBL.OBJ OBJ$:RMSGBL.OBB/NEW_VERSION	! FOR VMSBUILD
$ EXIT
$
$OBJLIB:
$ !
$ !	Concatenate the object files, delete and re-create the object
$ !	library file, then delete the concatenated object file.
$ !
$ COPY OBJ$:*.OBJ OBJ$:RMS.OBS
$ DELETE LIB$:RMS.OLB;*
$ LIBRARY/CREATE=(BLOCKS:500,MODULES=200,GLOBALS=1000)/OBJECT-
	LIB$:RMS OBJ$:RMS.OBS
$ DELETE OBJ$:RMS.OBS;*,OBJ$:*.OBJ;*
$ !
$ !	Copy the object library just created to a System area for use by
$ !	other facilities.
$ !
$ IF CPYOLB .EQS. "Y" THEN CPYRESOBJ LIB$:RMS.OLB
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
$ !	Note: This link assumes that OBJ$:RMSGBL.OBJ produced in the
$ !	assembly phase above has been added to RESOBJ$:STARLET.OLB.
$ !
$ DELETE EXE$:RMS.EXE;*,MAP$:.MAP;*,EXE$:.STB;*
$ DELETE EXE$:RMSSHARE.EXE;*,MAP$:.MAP;*
$ @COM$:RMSLNK
$ EXIT
$
$RESULT:
$ !
$ !
$ !	Copy the image and map files to a System area.
$ !
$ CPYRESEXE EXE$:RMS.EXE
$ CPYRESEXE EXE$:RMS.STB
$ CPYRESEXE MAP$:RMS.MAP
$ CPYRESMAP MAP$:RMS.MAP
$ CPYRESEXE EXE$:RMSSHARE.EXE
$ !
$ !	Concatenate the listing files and copy them to the System area.
$ !
$ CPYRESLIS LIS$:*.LIS RMS.LSS
