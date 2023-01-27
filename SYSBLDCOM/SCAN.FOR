C	SCAN - Scan systembuild logs for errors
C
C****************************************************************************
C*									    *
C*  Copyright (c) 1980, 1981                                                *
C*  by DIGITAL Equipment Corporation, Maynard, Mass.			    *
C* 									    *
C*  This software is furnished under a license and may be used and  copied  *
C*  only  in  accordance  with  the  terms  of  such  license and with the  *
C*  inclusion of the above copyright notice.  This software or  any  other  *
C*  copies  thereof may not be provided or otherwise made available to any  *
C*  other person.  No title to and ownership of  the  software  is  hereby  *
C*  transferred.							    *
C* 									    *
C*  The information in this software is subject to change  without  notice  *
C*  and  should  not  be  construed  as  a commitment by DIGITAL Equipment  *
C*  Corporation.							    *
C* 									    *
C*  DIGITAL assumes no responsibility for the use or  reliability  of  its  *
C*  software on equipment which is not supplied by DIGITAL.		    *
C*									    *
C****************************************************************************
C
C	Version 2.4 - Steve Lionel
C	This program requires VAX-11 FORTRAN X1.94 or later.
C
C 2-005 - Open terminal file UNKNOWN so that it can be directed
C	  to a file.  Use routines CCOPEN, SETCCO and CLRCCO.  SBL 18-Jun-1980
C 2-006 - Use DFLTOPEN to set default file name to .LOG.  Remove parsing
C	  here.  SBL 18-June-1980
C 2-007 - Allow for -S- level messages.  SBL 30-June-1980
C 2-008	- Add wildcarding by moving main routine to macro portion and passing
C	  filespec into here.  Add comments.  Tim Halvorsen 08-Aug-1980
C 2-009 - Call SETCCO/CLRCCO around write for filespec.  SBL 9-July-1981
C 2-010 - Ignore PURGE warnings.  SBL 10-Sep-1981
C 2-011 - Ignore MODULE REPLACED messages from LBR.  SBL 13-Oct-1981
C 2-012 - Make FILESPEC be of arbitrary length.  Remove trailing CRLFs from 
C	  line.  SBL 3-Nov-1981
C 2-013 - Use ERR_HANDLER to recover from OPEN errors.  Reflect change in
C	  phase/facility marker syntax.  SBL 16-Dec-1981
C
	SUBROUTINE SCAN (FILESPEC)	! Scan a given file for errors
	PARAMETER NLINES$ = 10
	PARAMETER CRLF = CHAR(13)//CHAR(10)
	CHARACTER*(*) FILESPEC
	CHARACTER*255 PASTLINES(NLINES$),CURLINE
	CHARACTER FACNAME*6,PHASE*6,FAC*6,SEV*1,FIRSTCHAR*1
	LOGICAL*1 FACPRT,CR
	INTEGER*4 CUR,LAST$,LENGTHS(NLINES$),LENGTH
	EXTERNAL CCOPEN,ERR_HANDLER
	OPEN (UNIT=2,FILE='SYS$OUTPUT',RECORDTYPE='VARIABLE',
	1 RECL=512,CARRIAGECONTROL='FORTRAN',STATUS='UNKNOWN',
	2 USEROPEN=CCOPEN,ACCESS='APPEND')
	CALL SETCCO
	WRITE (2,*)
	CALL CLRCCO
	CALL LIB$ESTABLISH(ERR_HANDLER)
	OPEN (UNIT=1,FILE=FILESPEC,STATUS='OLD',READONLY,SHARED,
	1 FORM='FORMATTED',CARRIAGECONTROL='NONE')
	CALL LIB$REVERT
	REWIND (UNIT=1)
	CUR=0
	LAST$=0
	FACPRT=.TRUE.
	WRITE (2,10) FILESPEC
10	FORMAT(' *** Log file ',A)
C
C Read next line from the log file
C
100	CUR=CUR+1
	IF (CUR .GT. NLINES$) CUR=1
	READ (1,101,END=9000,ERR=900) LENGTH,CURLINE
101	FORMAT(Q,A)
	IF (LENGTH .LT. 4) GO TO 900
	LENGTH=MIN(LENGTH,255)
	DO WHILE (CURLINE(LENGTH-1:LENGTH) .EQ. CRLF)
	  CURLINE=CURLINE(1:LENGTH-2)
	  LENGTH=LENGTH-2
	  END DO
	FIRSTCHAR=CURLINE(1:1)
	CR=.FALSE.
	IF (CURLINE(1:1) .EQ. CHAR(13)) THEN
	    CURLINE=CURLINE(2:LENGTH)
	    FIRSTCHAR=CURLINE(1:1)
	    LENGTH=LENGTH-1
	    CR=.TRUE.
	    ENDIF
	IF (FIRSTCHAR .EQ. '$') GO TO 500
	IF (FIRSTCHAR .EQ. '!') GO TO 900
	IF (FIRSTCHAR .EQ. '%') GO TO 600
	IF (FIRSTCHAR .EQ. ' ') GO TO 900
	IF (FIRSTCHAR .EQ. CHAR(9)) GO TO 900	! Tab character
	IF (FIRSTCHAR .EQ. ';') GO TO 900	! BLISS Comment
	IF (FIRSTCHAR .EQ. '*') GO TO 700	! Phase/facility marker
	IF (CURLINE(1:6) .EQ. 'END OF') GO TO 900  !MDL end of file
	IF (CURLINE(1:6) .EQ. 'Edit c') GO TO 1000  !SUM edit clash
	IF (CURLINE(1:3) .EQ. 'TKB') GO TO 1000		! TKB errors
	IF (CURLINE(1:6) .EQ. 'ERRORS') GO TO 1000	! MAC errors
	IF ((CURLINE(2:7) .EQ. 'MODULE') .AND.
	1  (INDEX(CURLINE,' REPLACED') .NE. 0)) GO TO 900 ! LBR informational

	IF (.NOT. CR) GO TO 900
	GO TO 1000	! Error, so we think.
C
C Process a line starting with '$'
C
500	LAST$=0
590	IF (CURLINE(LENGTH:LENGTH) .NE. '-') GOTO 900
	PASTLINES(CUR)=CURLINE
	LENGTHS(CUR)=LENGTH
	READ (1,101,END=9000,ERR=900) LENGTH,CURLINE
	LENGTH=MIN(LENGTH,255)
	IF (CURLINE(1:1) .EQ. CHAR(13)) THEN
	  CURLINE=CURLINE(2:LENGTH)
	  LENGTH=LENGTH-1
	  ENDIF
	CUR=CUR+1
	LAST$=LAST$+1
	IF (CUR .GT. NLINES$) CUR=1
	GO TO 590
C
C Process lines starting with '%'
C
600	IF (CURLINE(2:2) .EQ. ' ') GOTO 400  ! BLISS error
	N=INDEX(CURLINE,'-')
	FAC=CURLINE(2:N-1)
	SEV=CURLINE(N+1:N+1)
	IF (SEV .EQ. 'F') GO TO 1000
	IF (SEV .EQ. 'I') GO TO 650
	IF (SEV .EQ. 'S') GO TO 650
	IF (SEV .EQ. 'E') GO TO 1000
	IF (FAC .EQ. 'DELETE') GO TO 650	! Ignore warnings from:
	IF (FAC .EQ. 'COPY') GO TO 650
	IF (FAC .EQ. 'APPEND') GO TO 650
	IF (FAC .EQ. 'PURGE') GO TO 650
	GO TO 1000
650	PASTLINES(CUR)=CURLINE
	LENGTHS(CUR)=LENGTH
	CUR=CUR+1
	IF (CUR .GT. NLINES$) CUR=1
	LAST$=LAST$+1
660	READ (1,101,END=9000,ERR=900) LENGTH,CURLINE
	IF (CURLINE(1:1) .EQ. '%') GO TO 600
	LENGTH=MIN(LENGTH,255)
	IF (CURLINE(1:1) .EQ. CHAR(13)) THEN
	  CURLINE=CURLINE(2:LENGTH)
	  LENGTH=LENGTH-1
	  ENDIF
	IF (CURLINE(1:1) .NE. '$') GO TO 650
	LAST$=0
	GO TO 900
C
C Here if looks like a BLISS error message
C
400	IF (CURLINE(7:7) .NE. '#') GO TO 900
	IF (CURLINE(3:6) .EQ. 'INFO') GO TO 900
	GO TO 1000
C
C Process comment from log delimiting the start of a new facility
C
700	N=INDEX(CURLINE,'BUILD	')
	IF (N .EQ. 0) GO TO 900
	N=N+6
	M=INDEX(CURLINE,'(')-1
	FACNAME=CURLINE(N:M)
	N=M+2
	M=N+INDEX(CURLINE(N:LENGTH),' ')-1
	PHASE=CURLINE(N:M)
	FACPRT=.FALSE.
	GO TO 900
C
C Here if line is not recognized as an error message
C
900	PASTLINES(CUR)=CURLINE
	LENGTHS(CUR)=LENGTH
	LAST$=LAST$+1
	GO TO 100
C
C Here if line is an error message
C
1000	IF (.NOT. FACPRT) THEN
	  CALL SETCCO
	  WRITE (2,1001) FACNAME,PHASE
	  CALL CLRCCO
1001	FORMAT(/1X,A,' -- ',A,' phase'/
	1  ' ----------------------'/)
	FACPRT=.TRUE.
	ENDIF
	N=MIN(LAST$,NLINES$)
	M=CUR-N
	IF (M .LE. 0) M=M+NLINES$
	DO I=1,N
	WRITE (2, 1002)PASTLINES(M)(1:LENGTHS(M))
1002	FORMAT(1X,A)
	M=M+1
	IF (M .GT. NLINES$) M=1
	ENDDO
	WRITE (2,1002) CURLINE(1:LENGTH)
1010	READ (1,101,END=9000,ERR=900) LENGTH,CURLINE
	LENGTH=MIN(LENGTH,255)
	DO WHILE (CURLINE(LENGTH-1:LENGTH) .EQ. CRLF)
	  CURLINE=CURLINE(1:LENGTH-2)
	  LENGTH=LENGTH-2
	  END DO
	IF (CURLINE(1:1) .EQ. CHAR(13)) THEN
	  CURLINE=CURLINE(2:LENGTH)
	  LENGTH=LENGTH-1
	  ENDIF
	IF (CURLINE(1:1) .EQ. '$') GO TO 1020
	WRITE (2,1002) CURLINE(1:LENGTH)
	GO TO 1010
1020	LAST$=0
	GO TO 900
9000	CLOSE (UNIT=1)
	END

	INTEGER*4 FUNCTION ERR_HANDLER (SIGARGS,MCHARGS)
	INTEGER*4 SIGARGS(*),MCHARGS(*)
	INCLUDE 'SYS$LIBRARY:SIGDEF'
	IF (SIGARGS(2) .NE. SS$_UNWIND) THEN
	  SIGARGS(1) = SIGARGS(1)-2
	  CALL SYS$PUTMSG(SIGARGS,,'SCAN')
	  SIGARGS(1) = SIGARGS(1)+2
	  CALL SYS$UNWIND (,)
	  END IF
	ERR_HANDLER = SS$_RESIGNAL
	RETURN
	END
