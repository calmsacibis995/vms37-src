$ VERIFY='F$VERIFY(0)
$ !
$ !	FASM - Generalized, data driven assembly command file
$ !		   The data file name is COM$:'FACILITY'ASM.DAT
$ !
$ !	P1 - Facility name, defaults to symbol "FACILITY"
$ !	P2 - Module name
$ !	P3 - Library switch, defaults to true
$ !	P4 - The keywords "BUG", "ENH", "EXP", in any order, separated by commas,
$ !			which indicate the updates to be applied.
$ !
$ !	The updates are always applied in the order: BUG, ENH, EXP
$ !	such that the earlier updates can be overridden by later ones.
$ !
$ !	P5 - Source library switch, defaults to false. This flag enables
$ !	     the processing of SRCLIB commands.
$ !
$ !	P6 - Checkpointing switch, defaults to FALSE.
$ !	     If enabled, FASM looks for a file named FASMCHECK.CHK in the
$ !	     current default directory.  If it exists, the previous assembly
$ !	     is assumed to have not completed.  The version number of the
$ !	     FASMCHECK.CHK file indicates the highest checkpoint number
$ !	     successfully completed.  Checkpoints are indicated in the
$ !	     facASM.DAT file by records of the form:
$ !			@n
$ !	     where "n" is a checkpoint number from 1 through 9.
$ !
$ !	Assumes: TMP$: - Device and directory for temp files.
$ !		 EXP$: - Device and directory for experimental updates.
$ !		 MSRC$:, OBJ$:, LIS$:, BUG$:, ENH$:, LIB$:
$ !
$ IF P1 .NES. "" THEN FACILITY:='P1'
$ IF P2 .NES. "" THEN MODULE:='P2'
$ MODNAME:=%'MODULE'
$ IF P3 .EQS. "" THEN P3:=TRUE
$ IF P4 .EQS. "" THEN P4:=ENH
$ IF P5 .EQS. "" THEN P5=0
$ IF P6 .EQS. "" THEN P6=0
$ LASTCHK=0	! Last checkpoint completed, initally none
$ CURRCHK=0	! Current checkpoint found, initially none
$ IF (.NOT. P6) THEN GOTO CK1
$ FN=F$SEARCH("FASMCHECK.CHK")
$ IF FN .EQS. "" THEN GOTO CK1
$ LASTCHK=F$PARSE(FN,,,"VERSION")-";"
$ WRITE SYS$OUTPUT "%FASM-W-RESTART, restarting assembly from checkpoint ''LASTCHK'"
$CK1:
$ GBL:=GLOBALS
$ OLB:='FACILITY'
$ OPT:=""
$ SRCLIB=0
$ AUDIT_POSITION=80
$ AUDIT_SIZE=0		! 0 = Audit trail default off, 9 = normal width
$ TEMP:=""
$ STATUS = 1
$ IF 'F$LOC("BUG",P4) .LT. 'F$LEN(P4) THEN TEMP:=",'BUG'"
$ IF 'F$LOC("ENH",P4) .LT. 'F$LEN(P4) THEN TEMP:="''TEMP','ENH'
$ IF 'F$LOC("EXP",P4) .LT. 'F$LEN(P4) THEN TEMP:="''TEMP','EXP'
$ P4:=UPDLIS:="''F$EXT(1,999,TEMP)'
$ ON ERROR THEN GOTO EOF
$ ON CONTROL_Y THEN GOTO CTRLY
$ OPEN ASM COM$:'FACILITY'ASM.DAT
$ IF P2 .EQS. "" THEN SET NOON
$
$NEXT: SET NOVERIFY
$ READ/END=EOF ASM ASMREC
$ TEMP:='F$EXTRACT(0,1,ASMREC)
$ P='F$LOCATE(MODNAME,ASMREC)
$ IF (P .EQ. 0)  THEN GOTO FOUND
$
$SEARCH:	
$ IF TEMP .EQS. "@" THEN GOTO CHKPT
$ IF TEMP .NES. "$" THEN GOTO NEXT
$ L='F$LENGTH(ASMREC)'-1
$ ASMREC:='F$EXTRACT(1,L,ASMREC)
$ IF 'F$LENGTH(ASMREC) .EQ. 0 THEN GOTO NEXT
$
$EQLOOP:	
$ X='F$LOCATE(";",ASMREC)
$ 'F$EXTRACT(0,X,ASMREC)
$ Y='F$LENGTH(ASMREC)-X
$ IF Y .LE. 0 THEN GOTO NEXT
$ X=X+1
$ ASMREC:='F$EXTRACT(X,Y,ASMREC)
$ GOTO EQLOOP
$
$CHKPT:
$ IF .NOT. P6 THEN GOTO NEXT
$ CURRCHK=F$EXTRACT(1,1,ASMREC)
$ IF CURRCHK .LE. LASTCHK THEN GOTO NEXT
$ IF LASTCHK .EQ. 0 THEN CREATE FASMCHECK.CHK;1
$ RENAME FASMCHECK.CHK FASMCHECK.CHK;'CURRCHK
$ LASTCHK=CURRCHK
$ WRITE SYS$OUTPUT "%FASM-I-CHECKPT, assembly at checkpoint ''CURRCHK'"
$ GOTO NEXT
$
$EOF: V = 'F$VERIFY(0)'		! In case we get here from an error
$ STATUS = '$STATUS'
$ IF (LASTCHK .NE. 0) THEN DELETE FASMCHECK.CHK;*
$ IF MODNAME .NES. "%" THEN WRITE SYS$OUTPUT "No module description"
$CTRLY:
$ SET NOON
$ CLOSE ASM
$ GOTO END
$
$FOUND:
$ IF (CURRCHK .LT. LASTCHK) THEN GOTO NEXT
$ DELLIS:=""
$ X='F$LOCATE("/",ASMREC)
$ TEMP:='F$EXTRACT(0,X,ASMREC)
$ IF (TEMP .NES. MODNAME) .AND. (MODNAME .NES. "%") THEN GOTO NEXT
$ IF((P5.AND..NOT.SRCLIB).OR.(SRCLIB.AND..NOT.P5)).AND.(MODNAME.EQS."%")THEN GOTO NEXT
$ L=X-1
$ MODULE:='F$EXTRACT(1,L,ASMREC)
$ N=1
$ X=X+1
$ IF MODNAME .NES. "%" THEN CLOSE ASM
$
$NEXTSRC:	
$ P='F$LOCATE("+",ASMREC)
$ L=P-X
$ SRC'N':='F$EXTRACT(X,L,ASMREC)
$ L='F$LENGTH(ASMREC)-P-1
$ X=P+1
$ ASMREC:='F$EXTRACT(X,L,ASMREC)
$ X=0
$ N=N+1
$ IF L .GT. 0 THEN GOTO NEXTSRC
$ M=1
$ SRCLISC:=""
$
$SRCFLOOP:	
$ SRC:=SRC:="'"SRC'M
$ 'SRC
$ P='F$LOCATE(".",SRC)
$ SRCN:='F$EXTRACT(0,P,SRC)
$ BUG:=BUG$:'SRCN
$ ENH:=ENH$:'SRCN
$ EXP:=EXP$:'SRCN
$ SRCD:=MSRC$:
$ P='F$LOCATE("]",SRC)
$ IF P .LT. 'F$LENGTH(SRC) THEN GOTO GOTDEV
$ P='F$LOCATE(":",SRC)
$ IF P .LT. 'F$LENGTH(SRC) THEN GOTO GOTDEV
$ 'P4
$
$DO_UPD:
$ IF UPDLIS .NES. "" THEN GOTO 'LANG'_UPD
$ GOTO COMMONSRC
$
$MACRO_UPD:	SRC:='SRC'/UPDATE=('UPDLIS')
$COMMONSRC:	SRC'M':=+'SRCD''SRC'
$ IF SRCLISC .NES. "" THEN SRCLISC:='SRCLISC','SRCD''SRC
$ IF SRCLISC .EQS. "" THEN SRCLISC:='SRCD''SRC
$ M=M+1
$ IF M .LT. N THEN GOTO SRCFLOOP
$
$PADLOOP:	
$ SRC'M':=""
$ M=M+1
$ IF M .LE. 5 THEN GOTO PADLOOP
$ M=1
$ MLIS:=""
$
$MLOOP:		
$ MLIB:=MLIB:="'"ML'M
$ 'MLIB
$ IF MLIB .EQS. "" THEN GOTO BLDCOM
$ MLIS:='MLIS'+'MLIB'/LIB
$ M=M+1
$ GOTO MLOOP
$
$BLDCOM:	
$ LIBR_TYPE:=""
$ GOTO 'LANG'_ASM
$
$BASIC_ASM:
$BLISS_ASM:
$FORTRAN_ASM:
$MESSAGE_ASM:
$MACRO_ASM:
$PLI_ASM:
$PASCAL_ASM:
$
$NATIVE:	SET VERIFY
$ 'LANG''OPT'-
	/LIS=LIS$:'MODULE'-
	/OBJ=OBJ$:'MODULE'-
	'F$EXTRACT(1,999,SRC1)'-
	'SRC2'-
	'SRC3'-
	'SRC4'-
	'SRC5'-
	'MLIS'
$ V = 'F$VERIFY(0)'
$
$LIBRARY_INS:
$ IF (.NOT. P3) .OR. (OLB .EQS. "") THEN GOTO LIBRARY_NO_INS
$ SET VERIFY
$ LIB'LIBR_TYPE' LIB$:'OLB' OBJ$:'MODULE'/REPLACE/'GBL'
$LIBRARY_NO_INS: V = 'F$VERIFY(0)'
$ IF DELLIS .NES. "" THEN DELETE 'DELLIS'
$ IF MODNAME .EQS. "%" THEN GOTO NEXT
$ STATUS = 1
$
$END:		IF VERIFY THEN SET VERIFY
$ EXIT 'STATUS'
$
$BLISS16_ASM:	BLISS16:="BLISS/PDP11"
$ LIBR_TYPE:="/RSX11"
$ GOTO NATIVE
$
$MAC_ASM:	MAC:="MACRO/RSX11"
$ LIBR_TYPE:="/RSX11"
$ IF MLIS .NES. "" THEN MLIS := 'F$EXTRACT(1,999,MLIS)+
$ SET VERIFY
$ 'LANG''OPT'-
	/LIS=LIS$:'MODULE'-
	/OBJ=OBJ$:'MODULE'-
	'MLIS'-
	'F$EXTRACT(1,999,SRC1)'-
	'SRC2'-
	'SRC3'-
	'SRC4'-
	'SRC5'
$ V = 'F$VERIFY(0)'
$ GOTO LIBRARY_INS
$
$BASIC_UPD:	IF LANG .EQS. "BASIC" THEN TYP:=".BAS"
$F4P_UPD:	IF LANG .EQS. "F4P" THEN TYP:=".FTN"
$FORTRAN_UPD:	IF LANG .EQS. "FORTRAN" THEN TYP:=".FOR"
$MAC_UPD:	IF LANG .EQS. "MAC" THEN TYP:=".MAC"
$MDL_UPD:	IF LANG .EQS. "MDL" THEN TYP:=".MDL"
$MESSAGE_UPD:	IF LANG .EQS. "MESSAGE" THEN TYP:=".MSG"
$PLI_UPD:	IF LANG .EQS. "PLI" THEN TYP:=".PLI"
$PASCAL_UPD:	IF LANG .EQS. "PASCAL" THEN TYP:=".PAS"
$ SUM_QUAL:=""
$ IF AUDIT_SIZE .EQ. 0 THEN GOTO SUM_BEGIN
$ SUM_QUAL:="/AUDIT=(POSIT:''AUDIT_POSITION',SIZE:''AUDIT_SIZE')"
$ GOTO SUM_BEGIN
$
$BLISS_UPD:	IF LANG .EQS. "BLISS" THEN TYP:=".B32"
$BLISS16_UPD:	IF LANG .EQS. "BLISS16" THEN TYP:=".B16"
$ SUM_QUAL:="/HEADER"  			! Use special VFC for BLISS
$
$SUM_BEGIN:
$ P='F$LOCATE(".",SRC)
$ L='F$LENGTH(SRC)-P
$ IF L .GT. 0 THEN TYP:='F$EXTRACT(P,L,SRC)
$ UPD:=""
$
$SUM_LOOP:	P='F$LOCATE(",",UPDLIS)
$ TEMP:='F$EXTRACT(0,P,UPDLIS)'.UPD
$ P=P+1
$ L='F$LENGTH(UPDLIS)-P
$ UPDLIS:='F$EXTRACT(P,L,UPDLIS)
$ OPEN/ERROR=NOFILE TEMP 'TEMP
$ CLOSE TEMP
$ IF UPD .NES. "" THEN UPD:='UPD','TEMP
$ IF UPD .EQS. "" THEN UPD:='TEMP
$
$NOFILE:	IF UPDLIS .NES. "" THEN GOTO SUM_LOOP
$ IF UPD .EQS. "" THEN GOTO COMMONSRC
$ @SYSBLDCOM$:MAKSRCUPD 'SRCD''SRCN''TYP' TMP$:'SRCN'.TMP 'UPD' 'SUM_QUAL'
$ V = 'F$VERIFY(0)'
$ IF DELLIS .NES. "" THEN DELLIS:='DELLIS',TMP$:'SRCN'.TMP;
$ IF DELLIS .EQS. "" THEN DELLIS:=TMP$:'SRCN'.TMP;
$ SRC:='SRCN'.TMP
$ SRCD:=TMP$:
$ GOTO COMMONSRC
$
$GOTDEV:
$ P=P+1
$ SRCD:='F$EXTRACT(0,P,SRC)
$ IF 'F$LOCATE(":",SRCD) .EQ. 'F$LENGTH(SRCD) THEN SRCD:=MASD$:'SRCD'
$ L='F$LENGTH(SRC)-P
$ SRCNAM:='F$EXTRACT(P,L,SRC)
$ P='F$LOCATE(".SRC",SRCD)
$ TEMP:=""
$ IF P .LT. 'F$LENGTH(SRCD) THEN TEMP:='F$EXTRACT(0,P,SRCD)'
$ P='F$LOCATE(".",SRCNAM)
$ SRCN:='F$EXTRACT(0,P,SRCNAM)
$ BUG:='TEMP'.BUG]'SRCN'
$ ENH:='TEMP'.ENH]'SRCN'
$ EXP:=EXP$:'SRCN'
$ SRC:='SRCNAM'
$ 'P4
$ IF TEMP .NES. "" THEN GOTO DO_UPD
$ BUG:='SRCD''SRCN
$ UPDLIS:=""
$ IF 'F$LOC("BUG",P4) .LT. 'F$LEN(P4) THEN UPDLIS:=,'BUG'
$ IF 'F$LOC("EXP",P4) .LT. 'F$LEN(P4) THEN UPDLIS:='UPDLIS','EXP'
$ UPDLIS:='F$EXTRACT(1,999,UPDLIS)
$ GOTO DO_UPD
$
$MDL_ASM:	SET VERIFY
$ MCR MDL LIB$:'MODULE'='SRCLISC'
$ V = 'F$VERIFY(0)'
$ LIBR_TYPE:="/MACRO"
$ GOTO LIBRARY_INS
$
$F4P_ASM:	SET VERIFY
$ MCR F4P OBJ$:'MODULE',LIS$:'MODULE'/-SP='SRCLISC'
$ V = 'F$VERIFY(0)'
$ LIBR_TYPE:="/RSX11"
$ GOTO LIBRARY_INS
