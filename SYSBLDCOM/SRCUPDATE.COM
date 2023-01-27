$ VERIFY = 'F$VERIFY(0)'
$ !
$ !	This procedure creates a new copy of the source files
$ !	from a master source file and a list of SLP update files.
$ !
$ !	P1	= Source file name (filename.typ)
$ !	P2	= Update file name used on BUG,ENH update files
$ !		  (defaults to name in P1 with type .UPD)
$ !	P3-P8	= List of optional SLP update files
$ !
$ !	By default, the MBUG$ or MENH$ directory is searched
$ !	for any files named 'P2', depending on whether the symbol
$ !	UPDATES is defined as BUG or ENH.  If any can be found, they are
$ !	merged together to form a result SLP file.  If none are
$ !	found and none are specified in P3-P8, then the source
$ !	file is simply copied to the result area.
$ !
$ !	The master copy of the source is obtained from the
$ !	MSRC$ directory and the result source file is put
$ !	into the SRC$: directory.
$ !
$ ON ERROR THEN GOTO EXIT
$ DOT = 'F$LOCATE(".",P1)	! FIND THE FILE TYPE
$ FILE := 'F$EXTRACT(0,DOT,P1)	! EXTRACT THE FILE NAME ONLY
$ N = 3
$ INPUTS := ""
$LOOP:
$ TEMP := "'P"'N'
$ TEMP := 'TEMP'
$ IF 'F$LENGTH(TEMP) .EQ. 0 THEN GOTO DEFAULT
$ IF 'F$LENGTH(INPUTS) .NE. 0 THEN INPUTS := 'INPUTS',
$ INPUTS := 'INPUTS''TEMP'
$ N = N + 1
$ IF N .LE. 8 THEN GOTO LOOP
$DEFAULT:
$ IF P2 .EQS. "" THEN P2 := 'FILE'.UPD
$ IF "''UPDATES'" .EQS. "" THEN UPDATES := ENH
$ IF 'F$LOCATE("BUG",UPDATES) .NE. 'F$LENGTH(UPDATES) THEN GOTO DOBUG
$ UPD:=MENH$:'P2''INPUTS'
$ GOTO END
$DOBUG:
$ UPD:=MBUG$:'P2''INPUTS'
$END:
$!EDIT/SUM/AUDIT_TRAIL=(POSITION:80,SIZE:8)/OUTPUT=SRC$:'P1' -
$!	MSRC$:'P1'/UPDATE=('UPD')
$ EDIT/SUM/OUTPUT=SRC$:'P1' MSRC$:'P1'/UPDATE=('UPD')
$ IF "''CPYSRCLIS'" .NES. "" THEN CPYSRCLIS SRC$:'P1'
$EXIT:
$ IF VERIFY THEN SET VERIFY
