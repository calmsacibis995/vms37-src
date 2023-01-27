$ !
$ ! Make a new source file from the specified source and update files
$ !
$ !	P1 = Master source file
$ !	P2 = Output file specifier
$ !	P3 = Update file specifier list
$ !	P4 = switches to EDIT /SUM or EDIT /SLP
$ !		""  - 	no edit history to be placed in the output file
$ !		/HEAD - for BLISS-32 and BLISS-16 edit history in the
$ !			fixed control field of VFC format records
$ !		/AUDIT_TRAIL=(POSITION:80,SIZE:9)/[NO]REPORT/[NO]TAB
$ !			for other sources that must have audit trail
$ !			appended to the source lines.
$ !				Choose the starting position and size
$ !			for the audit trail according to the source language
$ !			and your needs.  The size of the audit trail needs
$ !			to include the comment character, the author's
$ !			initials, and upto 5 digits of SPR #.
$ !				REPORT is the default and requests SLP
$ !			to issue an error if a line truncation occurs.
$ !			NOREPORT does not work due to a bug in BACKTRANS
$ !			If a truncation does occur this procedure produces
$ !			a file with no audit trail.
$ !				TAB is the default.  SLP will pad with
$ !			tab characters rather than spaces.
$ VERIFY='F$VERIFY()
$ SET NOON
$ IF 'F$LOCATE("/AUDI",P4) .EQ. 'F$LENGTH(P4) THEN GOTO SUMSLP
$ IF 'F$LOCATE(",",P3) .LT. 'F$LENGTH(P3) THEN GOTO SUMSLP
$ OUTNAM:=""
$ TMPNAM:='P2
$NAME_LOOP:
$ L1='F$LENGTH(TMPNAM)
$ L='F$LOCATE(".",TMPNAM)
$ IF L .EQ. L1 THEN GOTO LAST_DOT
$ L=L+1
$ OUTNAM:='OUTNAM''F$EXTRACT(0,L,TMPNAM)
$ TMPNAM:='F$EXTRACT(L,L1,TMPNAM)
$ GOTO NAME_LOOP
$LAST_DOT:
$ OUTNAM:="''OUTNAM'XXX"
$ IF 'F$LOCATE("/NOREPO",P4) .EQ. 'F$LENGTH(P4) THEN P4:='P4'/REPORT
$ IF 'F$LOCATE("/NOTAB",P4)  .EQ. 'F$LENGTH(P4) THEN P4:='P4'/TAB
$ OPEN /WRITE /ERROR=DO_SUMSLP OUT 'OUTNAM'
$ ON ERROR THEN GOTO CLOSE_DEL_OUTNAM
$ WRITE OUT "$ EDIT /SLP''P4' /OUTPUT=''P2' ''P1'"
$ WRITE OUT "@''P3'"
$ CLOSE OUT
$ SET NOON
$ SET VERIFY
$ @'OUTNAM'
$ SAVE_STATUS=$STATUS
$ IF .NOT. VERIFY THEN SET NOVERIFY
$ DELETE 'OUTNAM';
$ IF SAVE_STATUS THEN EXIT
$ DELETE 'P2';
$DO_SUMSLP:
$ P4:=""
$SUMSLP:
$ SET VERIFY
$ EDIT /SUM'P4' /OUTPUT='P2' 'P1' /UPDATE=('P3')
$ IF .NOT. VERIFY THEN SET NOVERIFY
$ EXIT
$CLOSE_DEL_OUTNAM:
$ SET NOON
$ CLOSE OUT
$ DELETE 'OUTNAM';
$ GOTO DO_SUMSLP
