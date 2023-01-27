$ !
$ !	[ DTSDTR.COM ] D T S D T R B L D . C O M
$ !
$ !	This command file builds DTSEND.EXE and DTRECV.EXE which
$ !		are DECNET test programs that exercise NETACP and
$ !		compute throughput statistics.
$ !
$ !
$ GOTO 'PHASE'
$
$INIT:
$ !
$ !	Create directories.
$ !
$ @SYSBLDCOM$:CREATEDIR
$ EXIT
$
$UPDATE:
$ !
$ !	Create updated require files sources.
$ !
$ DELETE SRC$:*.*;*
$ SRCUPDATE DTPREFIX.MAR
$ SRCUPDATE DTMACROS.MAR
$ SRCUPDATE DTSMSG.MSG
$ EXIT
$
$SRCLIB:
$ !
$ !	Delete and re-create the macro library DTSDTR.MLB.
$ !
$ DELETE LIB$:DTSDTR.MLB;*
$ MESSAGE/MDL=SRC$:DTSMSG/OBJ=OBJ$:DTSMSG SRC$:DTSMSG
$ MCR MDL LIB$:DTSMSG=SRC$:DTSMSG
$ LIB/MAC/CREATE LIB$:DTSDTR SRC$:DTMACROS,LIB$:DTSMSG
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the object and listing files.
$ !
$ !	Note: COM$:DTSDTRASM.CMD references LIB$:DTSDTR.MLB
$ !		via the prefix file SRC$:DTPREFIX.MAR.
$ !
$ DELETE OBJ$:*.OBJ;*,	LIS$:*.LSS;*,*.LIS;*
$ COPY SRC$:DTPREFIX.MAR,DTMACROS LIS$:DTDEFINE.LIS
$ @SYSBLDCOM$:FASM 'FACNAM "" N 'UPDATES
$ EXIT
$
$OBJLIB:
$ !
$ ! 	Create object library from object modules.
$ !
$ @SYSBLDCOM$:OBJLIB DTSDTR
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
$ !		EXE$:DTSEND.EXE,DTRECV.EXE, MAP$:DTSEND.MAP,DTRECV.MAP.
$ !
$ DELETE EXE$:DTSEND.EXE;*,DTRECV.EXE;*, MAP$:DTSEND.MAP;*,DTRECV.MAP;*
$ @COM$:DTSDTRLNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP files to a System area.
$ !
$ CPYRESEXE EXE$:DTSEND.EXE
$ CPYRESMAP MAP$:DTSEND.MAP
$ CPYRESEXE EXE$:DTRECV.EXE
$ CPYRESMAP MAP$:DTRECV.MAP
$ !
$ !	Build the concatenated listing file DTSDTR.LSS.
$ !
$ CPYRESLIS LIS$:*.LIS DTSDTR.LSS
