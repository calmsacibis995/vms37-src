$ !
$ !	[ E D T C A I . C O M ] E D T C A I B L D . C O M
$ !
$ !	Assume default directory is [EDTCAI] and logical names
$ !	BUG$, COM$, ENH$, EXE$, LIB$, LIS$, MAP$, OBJ$, and SRC$
$ !	are defined.
$ !
$ GOTO 'PHASE'
$ 
$INIT:
$ !
$ !	Create the Directories
$ !
$ @SYSBLDCOM$:CREATEDIR MASTER		! MASTER so we get .COM directory also
$ EXIT
$
$UPDATE:
$ !
$ !	Create updated sources.
$ !
$ EXIT
$
$SRCLIB:
$ EXIT
$
$ASSEM:
$ !
$ !	Delete and re-create the assembly language objects and listings
$ !
$ IF F$SEARCH("SYS$SYSTEM:BASIC.EXE") .EQS. "" THEN GOTO NOASSEM
$ DELETE OBJ$:*.OBJ;*,	LIS$:*.LIS;*
$ SET NOON				! In case of errors
$ @SYSBLDCOM$:FASM EDTCAI "" N 'UPDATES'
$NOASSEM:
$ EXIT
$
$OBJLIB:
$ !
$ !	Create object library from object modules.
$ !
$ !
$ IF F$SEARCH("SYS$SYSTEM:BASIC.EXE") .EQS. "" THEN GOTO COPYOLB
$ @SYSBLDCOM$:OBJLIB EDTCAI
$ COPY OBJ$:EDTCAI.OLB PRMOBJ$:
$ IF F$SEARCH("PRMOBJ$:EDTCAI.OLB;0") .NES. F$SEARCH("PRMOBJ$:EDTCAI.OLB;-0") -
	THEN PURGE PRMOBJ$:EDTCAI.OLB
$ EXIT
$COPYOLB:
$ COPY PRMOBJ$:EDTCAI.OLB OBJ$:
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
$ !	Delete and recreate images
$ !
$ @COM$:EDTCAILNK
$ EXIT
$
$RESULT:
$ !
$ !	Copy the EXE and MAP to a System area
$ !
$ CPYRESEXE EXE$:EDTCAI.EXE
$ CPYRESEXE EXE$:ADMIN.EXE
$ CPYRESEXE EXE$:EDTCAICNV.EXE
$ DELETE OBJ$:*.DLB;*,EDTEXER%.*;*,EDTCAI.DIC;*,CBICOURSE.DAT;*
$ COPY PRMOBJ$:*.DLB,EDTEXER%.*,EDTCAI.DIC OBJ$:
$ COPY PRMOBJ$:CBICOURSE.DAT OBJ$:
$ CPYSYSCBI OBJ$:CBICOURSE.DAT
$ CPYSYSCBI OBJ$:EDTV52.DLB
$ CPYSYSCBI OBJ$:EDTVT1.DLB
$ CPYSYSCBI OBJ$:EDTEXER4.COM
$ CPYSYSCBI OBJ$:EDTEXER4.DAT
$ CPYSYSCBI OBJ$:EDTEXER5.COM
$ CPYSYSCBI OBJ$:EDTEXER5.DAT
$ CPYSYSCBI OBJ$:EDTCAI.DIC
$ COPY COM$:EDTCAI.COM OBJD$:[SYSUPD]
$ !
$ !	Build the concatenated listing EDTCAI.LSS
$ !
$ EXIT
