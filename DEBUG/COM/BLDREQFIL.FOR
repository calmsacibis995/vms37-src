C	****************************************************************
C	*                                                              *
C	*	BLDREQFIL -- BUILD VAX DEBUGGER REQUIRE FILES          *
C	*                                                              *
C	****************************************************************
C
C
C	This program is used to build the REQUIRE files that the language-
C	specific DEBUG modules use.  Those REQUIRE files are a subset of the
C	SRC$:DBGLIB.REQ and SRC$:DBGPROLOG.REQ require files used by the
C	kernel DEBUG modules, where the subset includes only those definitions
C	that the language-specific modules need and are allowed to see.
C
C	Specifically, this program reads through SRC$:DBGLIB.REQ and extracts
C	those definitions which are enclosed by the brackets '!**+' and '!**-'.
C	These brackets must appear on separate lines as illustrated here:
C
C			IGNORED DEFINITION LINES
C			!**+
C			EXTRACTED DEFINITION LINES
C			!**-
C			IGNORED DEFINITION LINES
C
C	The extracted definition lines are copied to the file SRC$:DBGCOMLIB.REQ
C	which can then be REQUIREd by the language-specific REQUIRE files used
C	by the language-specific DEBUG modules.  In addition, the same defini-
C	tions are converted from BLISS to MACRO format and written out to the
C	file SRC$:DBGCOMLIB.MAR.
C
C	Thereafter the program reads in SRC$:DBGPROLOG.REQ and converts it to a
C	file SRC$:DBGCOMPLG.REQ which can be REQUIREd by the language-specific
C	modules to define all PSECTs, messages, and SYS$LIBRARY:LIB definitions.
C	The only change here is that SRC$:DBGLIB.L32 is not LIBRARYd.
C
C	The purpose of this is to allow SRC$:DBGLIB.REQ to be the only REQUIRE
C	file that has to be updated when Debugger definitions are added or modi-
C	fied.  The subset file used by the language-specific routines is auto-
C	matically built from the DBGLIB.REQ file.  Similarly the DBGCOMPLG.REQ
C	file is automatically built from DBGPROLOG.REQ.
C
C
C
C	***Define the LINE we read from the input file and the COPYMODE flag
C	***which says that we are between the !**+ and !**- brackets.  We also
C	***define MACROFLAG which is .TRUE. when processing BLISS macros--such
C	***macros are not copied to DBGCOMLIB.MAR.  Finally we define and ini-
C	***tialize some translate tables used to process FIELD definitions.
	IMPLICIT INTEGER(A - Z)
	PARAMETER MAX_SDEFTBL = 14
	CHARACTER*200 LINE
	LOGICAL COPYMODE, MACROFLAG
	CHARACTER*1 DIGTBL(10)
	CHARACTER*1 TAB
	PARAMETER(TAB = CHAR(9))
	CHARACTER*3 SDEFTBL(MAX_SDEFTBL)
	DIMENSION BOFFTBL(MAX_SDEFTBL), NUMBER(20)
C
	DATA DIGTBL/'0','1','2','3','4','5','6','7','8','9'/
	DATA SDEFTBL/'A_ ', 'A0_', 'A1_', 'A2_', 'A3_', 'L_ ', 'W_ ',
     $		     'B_ ', 'W0_', 'W1_', 'B0_', 'B1_', 'B2_', 'B3_'/
	DATA BOFFTBL/0, 0,1,2,3, 0,0,0, 0,2, 0,1,2,3/
C
C
C	***Open DBGLIB.REQ as an input file and open DBGCOMLIB.REQ and
C	***DBGCOMLIB.MAR as output files.
	OPEN(UNIT=11, FILE='SRC$:DBGLIB.REQ', TYPE='OLD')
	OPEN(UNIT=12, FILE='SRC$:DBGCOMLIB.REQ', TYPE='NEW',
     $			CARRIAGECONTROL='LIST')
	OPEN(UNIT=13, FILE='SRC$:DBGCOMLIB.MAR', TYPE='NEW',
     $			CARRIAGECONTROL='LIST')
C
C
C	***Write a standard header in each of the output files.
	WRITE(12,350)
	WRITE(13,360)
C
C
C	***Now loop through the DBGLIB.REQ input file.  Check each input line
C	***for !**+ or !**- and, when copy mode is set, copy the input line to
C	***the output files.  Note that the line can be copied without change
C	***for the BLISS output file but needs some massaging for MACRO output.
	COPYMODE = .FALSE.
	MACROFLAG = .FALSE.
   10	LINE = ' '
	READ(11,20,END=250) N, LINE(1:N)
   20	FORMAT(Q,A)
	IF(LINE(1:4) .EQ. '!**+') THEN
	    COPYMODE = .TRUE.
	ELSE IF(LINE(1:4) .EQ. '!**-') THEN
	    COPYMODE = .FALSE.
	ELSE IF(COPYMODE) THEN
C
C
C	    ***Handle the BLISS case--just write the line to the output file.
	    WRITE(12,30) LINE(1:N)
   30	    FORMAT(A)
C
C
C	    ***Handle the MACRO case.  First set up a line terminator "!" and
C	    ***scan for the first non-blank.
	    IF(N .GT. 198) N = 198
	    LINE(199:200) = ' !'
	    LPT = 1
   50	    IF(LINE(LPT:LPT) .NE. ' ' .AND.
     $	       LINE(LPT:LPT) .NE. TAB) GO TO 60
	    LPT = LPT + 1
	    GO TO 50
C
C
C	    ***If this is just a comment line, change ! to ; and write it out.
   60	    IF(LINE(LPT:LPT) .EQ. '!') THEN
		LINE(LPT:LPT) = ';'
		WRITE(13,30) LINE(1:N)
		GO TO 10
	    ENDIF
C
C
C	    ***If this is the start of a MACRO declaration, set MACROFLAG.  If
C	    ***MACROFLAG is set, ignore the current line and search for the
C	    ***macro terminator "%;".
	    IF((LINE(LPT:LPT+4) .EQ. 'MACRO') .AND.
     $	       (LINE(LPT+5:LPT+5) .EQ. ' ' .OR.
     $	        LINE(LPT+5:LPT+5) .EQ. TAB)) MACROFLAG = .TRUE.
	    IF(MACROFLAG) THEN
   70		IF(LINE(LPT:LPT) .EQ. '!') GO TO 10
		IF(LINE(LPT:LPT+1) .EQ. '%;') GO TO 80
		LPT = LPT + 1
		GO TO 70
   80		MACROFLAG = .FALSE.
		GO TO 10
	    ENDIF
C
C
C	    ***Search the rest of the line for an = sign.  If it is not found,
C	    ***we ignore the line (it may be a SET or TES line, for example).
C	    ***Then scan for the first non-blank after the equal sign.  If no
C	    ***such non-blank is found, we also ignore the line.
   90	    IF(LINE(LPT:LPT) .EQ. '!') GO TO 10
	    IF(LINE(LPT:LPT) .EQ. '=') GO TO 100
	    LPT = LPT + 1
	    GO TO 90
  100	    LPT = LPT + 1
	    IF(LINE(LPT:LPT) .EQ. '!') GO TO 10
	    IF(LINE(LPT:LPT) .EQ. ' ') GO TO 100
	    IF(LINE(LPT:LPT) .EQ. TAB) GO TO 100
C
C
C	    ***See if this is a FIELD declaration.  If so, convert the FIELD
C	    ***specification to a byte offset.
	    IF(LINE(LPT:LPT) .EQ. '[') THEN
		BRKTLPT = LPT
		BYTEOFFSET = 0
  110		LPT = LPT + 1
		IF(LINE(LPT:LPT) .EQ. ' ') GO TO 110
		IF(LINE(LPT:LPT) .EQ. TAB) GO TO 110
		IF(LINE(LPT:LPT) .EQ. ',') GO TO 140
		DO 120 I = 0, 9
		    IF(LINE(LPT:LPT) .EQ. DIGTBL(I+1)) THEN
			BYTEOFFSET = 10*BYTEOFFSET + I
			GO TO 110
		    ENDIF
  120		CONTINUE
		PRINT 130, LINE(1:N)
  130		FORMAT('***Error:  Improper FIELD specification--ignored'/
     $			'-->',A)
		GO TO 10
C
C
C		***Now look for the field specifier within the longword (such as
C		***L_, A_, W0_, etc.) and add that into the byte offset.
  140		LPT = LPT + 1
		IF(LINE(LPT:LPT) .EQ. ' ') GO TO 140
		IF(LINE(LPT:LPT) .EQ. TAB) GO TO 140
		IF(LINE(LPT:LPT) .EQ. 'S') LPT = LPT + 1
		DO 150 I = 1, MAX_SDEFTBL
		    IF(LINE(LPT:LPT+1) .EQ. SDEFTBL(I) .OR.
     $		       LINE(LPT:LPT+2) .EQ. SDEFTBL(I)) GO TO 160
  150		CONTINUE
		IF(LINE(LPT:LPT+1) .EQ. 'V_') THEN
		    WRITE(13,155) LINE(1:N)
  155		    FORMAT(';************ Untranslatable Bliss construct ',
     $			    '************'/';',A)
		    GO TO 10
		ENDIF
		PRINT 130, LINE(1:N)
		GO TO 10
  160		BYTEOFFSET = 4*BYTEOFFSET + BOFFTBL(I)
C
C
C		***We got the byte offset corresponding to the FIELD specifica-
C		***tion.  Fill that offset into the LINE image.  Then pad with
C		***blanks up to the comment character (which we change to ";").
		NPT = 0
  170		NPT = NPT + 1
		IF(NPT .GT. 20) THEN
		    PRINT 130, LINE(1:N)
		    GO TO 10
		ENDIF
		NUMBER(NPT) = MOD(BYTEOFFSET, 10)
		BYTEOFFSET = BYTEOFFSET/10
		IF(BYTEOFFSET .NE. 0) GO TO 170
		LPT = BRKTLPT
		DO 180 I = NPT, 1, -1
		    LINE(LPT:LPT) = DIGTBL(NUMBER(I) + 1)
		    LPT = LPT + 1
  180		CONTINUE
  190		IF(LINE(LPT:LPT) .EQ. '!') GO TO 200
		LINE(LPT:LPT) = ' '
		LPT = LPT + 1
		GO TO 190
  200		LINE(LPT:LPT) = ';'
C
C
C		***We have now converted the BLISS FIELD declaration to a MACRO
C		***byte offset declaration.  Write it to DBGCOMLIB.MAR.
		WRITE(13,30) LINE(1:N)
C
C
C	    ***It is not a FIELD so we assume it is a LITERAL declaration.  Make
C	    ***it look like a MACRO literal declaration and write it out.
	    ELSE
  220		IF(LINE(LPT:LPT) .EQ. '!') GO TO 230
		IF(LINE(LPT:LPT) .EQ. ',') LINE(LPT:LPT) = ' '
		IF(LINE(LPT:LPT) .EQ. ';') LINE(LPT:LPT) = ' '
		LPT = LPT + 1
		GO TO 220
  230		LINE(LPT:LPT) = ';'
		WRITE(13,30) LINE(1:N)
	    ENDIF
C
	ENDIF
	GO TO 10
C
C
C	***We are done with DBGLIB.REQ.  Terminate the DBGCOMLIB.MAR file with
C	***Macro END statements.  Then close the input and output files and
C	***print a message saying all went well.
  250	WRITE(13,260)
  260	FORMAT('        .ENDM $DBGLIB'/'        .END')
	CLOSE(UNIT=11)
	CLOSE(UNIT=12)
	CLOSE(UNIT=13)
	PRINT 270
  270	FORMAT('---SRC$:DBGCOMLIB.REQ successfully built'/
     $	       '---SRC$:DBGCOMLIB.MAR successfully built')
C
C
C	***Now open DBGPROLOG and DBGCOMPLG so that the latter can be built
C	***from the former.
	OPEN(UNIT=14, FILE='SRC$:DBGPROLOG.REQ', TYPE='OLD')
	OPEN(UNIT=15, FILE='SRC$:DBGCOMPLG.REQ', TYPE='NEW',
     $			CARRIAGECONTROL='LIST')
C
C
C	***Build DBGCOMPLG by copying all of DBGPROLOG and making two changes:
C	***a header message is added and the line invoking DBGLIB is removed.
	WRITE(15,370)
  300	LINE = ' '
	READ(14,20,END=320) N, LINE(1:N)
	IF(LINE(1:26) .EQ. 'REQUIRE ''SRC$:DBGPAR.REQ'';') GO TO 300
	IF(LINE(1:29) .EQ. 'LIBRARY ''SRC$:DSTRECRDS.L32'';') GO TO 300
	IF(LINE(1:26) .EQ. 'REQUIRE ''LIB$:DBGMSG.REQ'';') GO TO 300
	IF(LINE(1:26) .NE. 'LIBRARY ''SRC$:DBGLIB.L32'';') THEN
	    WRITE(15,30) LINE(1:N)
	ENDIF
	GO TO 300
C
C
C	***We are all done--close the two files and print a message saying that
C	***all went well.
  320	CLOSE(UNIT=14)
	CLOSE(UNIT=15)
	PRINT 330
  330	FORMAT('---SRC$:DBGCOMPLG.REQ successfully built')
C
C
C	***Here we have standard header formats we write to the output files.
  350	FORMAT(
     $	'!-----------------------------------------------------------!'/
     $	'!                                                           !'/
     $	'!  DBGCOMLIB.REQ -- COMMON DEFINITION FILE FOR LANGUAGE-    !'/
     $	'!                   SPECIFIC MODULES IN THE VAX DEBUGGER    !'/
     $	'!                                                           !'/
     $	'!  THIS REQUIRE FILE IS BUILT AUTOMATICALLY FROM DBGLIB.REQ !'/
     $	'!     AND SHOULD THEREFORE NEVER BE UPDATED DIRECTLY--ALL   !'/
     $	'!     SOURCE UPDATES MUST BE MADE IN SRC$:DBGLIB.REQ        !'/
     $	'!                                                           !'/
     $	'!-----------------------------------------------------------!'/
     $	//)
  360	FORMAT(
     $	';!----------------------------------------------------------!'/
     $	';!                                                          !'/
     $	';! DBGCOMLIB.MAR -- COMMON DEFINITION FILE FOR LANGUAGE-    !'/
     $	';!                  SPECIFIC MACRO MODULES IN VAX DEBUGGER  !'/
     $	';!                                                          !'/
     $	';! THIS REQUIRE FILE IS BUILT AUTOMATICALLY FROM DBGLIB.REQ !'/
     $	';!    AND SHOULD THEREFORE NEVER BE UPDATED DIRECTLY--ALL   !'/
     $	';!    SOURCE UPDATES MUST BE MADE IN SRC$:DBGLIB.REQ        !'/
     $	';!                                                          !'/
     $	';!----------------------------------------------------------!'/
     $	';'/'        .MACRO $DBGLIB'//)
  370	FORMAT(
     $	'!-----------------------------------------------------------!'/
     $	'!                                                           !'/
     $	'!  DBGCOMPLG.REQ -- STANDARD PROLOG FOR LANGUAGE-SPECIFIC   !'/
     $	'!                   BLISS MODULES IN THE VAX DEBUGGER       !'/
     $	'!                                                           !'/
     $	'!  THIS REQUIRE FILE IS BUILT AUTOMATICALLY FROM DBGPROLOG  !'/
     $	'!     AND SHOULD THEREFORE NEVER BE UPDATED DIRECTLY--ALL   !'/
     $	'!     SOURCE UPDATES MUST BE MADE IN SRC$:DBGPROLOG.REQ     !'/
     $	'!                                                           !'/
     $	'!-----------------------------------------------------------!'/
     $	//)
	END
