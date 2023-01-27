	PROGRAM BASMSG
C	Version: 1-015, File: BASMSG.FOR, JBS, 24-SEP-1979
C
C****************************************************************************
C*									    *
C*  COPYRIGHT (c) 1978, 1980, 1982 BY					    *
C*  DIGITAL EQUIPMENT CORPORATION, MAYNARD, MASSACHUSETTS.		    *
C*  ALL RIGHTS RESERVED.						    *
C* 									    *
C*  THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED AND COPIED   *
C*  ONLY IN  ACCORDANCE WITH  THE  TERMS  OF  SUCH  LICENSE  AND WITH THE   *
C*  INCLUSION OF THE ABOVE COPYRIGHT NOTICE. THIS SOFTWARE OR  ANY  OTHER   *
C*  COPIES THEREOF MAY NOT BE PROVIDED OR OTHERWISE MADE AVAILABLE TO ANY   *
C*  OTHER PERSON.  NO TITLE TO AND OWNERSHIP OF  THE  SOFTWARE IS  HEREBY   *
C*  TRANSFERRED.							    *
C* 									    *
C*  THE INFORMATION IN THIS SOFTWARE IS  SUBJECT TO CHANGE WITHOUT NOTICE   *
C*  AND  SHOULD  NOT  BE  CONSTRUED AS  A COMMITMENT BY DIGITAL EQUIPMENT   *
C*  CORPORATION.							    *
C* 									    *
C*  DIGITAL ASSUMES NO RESPONSIBILITY FOR THE USE  OR  RELIABILITY OF ITS   *
C*  SOFTWARE ON EQUIPMENT WHICH IS NOT SUPPLIED BY DIGITAL.		    *
C* 									    *
C*									    *
C****************************************************************************
C
C

C++
C FACILITY:  BASIC-PLUS-2 Error Messages
C
C ABSTRACT:
C
C	This file, BASMSG.FOR, is a FORTRAN program that writes
C	the file BASMSG.MDL, which is read by the SYSMSG program
C	(among other files) to produce the system error message file.
C
C ENVIRONMENT:  VAX-11 user mode
C
C AUTHOR: John Sauter, CREATION DATE: 03-Nov-78
C
C MODIFIED BY:
C
C 1-001	- Write BASMSG.MDL on LIB$:  JBS 27-NOV-78
C 1-002	- Change PC printed by ON_CHAFIL to be hex.  JBS 19-DEC-78
C 1-003	- Add I/O List message.  JBS 08-FEB-1979
C 1-004	- Correct a typo in the I/O List message.  JBS 09-FEB-1979
C 1-005	- Write output on SRC$:.  JBS 21-MAR-1979
C 1-006 - Correct spelling of I/O List message.  JBS 20-APR-1979
C 1-007	- Change the prefixes of the traceback messages to make
C	   them less confusing.  JBS 20-APR-1979
C 1-008	- Change the text of the traceback messages to refer to a SUB
C	   as a SUBPROGRAM, not a SUBROUTINE.  JBS 07-MAY-1979
C 1-009	- Add a message for showing the user PC and PSL at the time
C	   of the error.  JBS 11-MAY-1979
C 1-010	- Correct a typo in edit 009.  JBS 13-MAY-1979
C 1-011	- Add an I/O error message which does not have a channel number,
C	   for the non-channel I/O statements.  JBS 09-AUG-1979
C 1-012	- Change I/O List to Immediate Mode.  JBS 17-SEP-1979
C 1-013	- Write output on LIB$.  JBS 17-SEP-1979
C 1-014	- Write output on SRC$, to conform to SBL's new procedure.
C	   JBS 20-SEP-1979
C 1-015	- Allow up to 60-character message text.  JBS 24-SEP-1979
C
C--

C
	IMPLICIT INTEGER (A-Z)
	CHARACTER*60 TEXT
	CHARACTER*9 NAME
C
C	Open BASMSG.MDL, the file which will be read by SYSMSG.
C
	OPEN (UNIT=1,NAME='SRC$:BASMSG.MDL',TYPE='NEW',CARRIAGECONTROL='LIST')
C
C	First write out the 'header' information for the file
C
	WRITE (1, 900)
900	FORMAT (1X,';',/,
     1	 1X,'; This file, BASMSG.MDL,',
     1	  ' contains the definitions of the BASIC',/,
     2	 1X,'; error messages.  ',
     2	  'This file is read by SYSMSG when it builds',/,
     3	 1X,'; the system error message file.',/,
     4	 1X,';',/,
     5	 1X,'       $STRUCT   BAS',/,
     6	 1X,';',/,
     7	 1X,'C<BAS,$_')
C
C	Now write out the message for each of the 256 BASIC error
C	 codes.  To assist with this we call a BLISS routine which
C	 interprets the data structure used by the Runtime Library.
C
	DO 100 CODE = 0, 255
	CALL ERRTXT (CODE, VALUE, NAMLEN, NAME, TXTLEN, TEXT)
	WRITE (1, 901) NAME, VALUE, TEXT
901	FORMAT (1X,A<NAMLEN>,',',I7,' ; MSG <',A<TXTLEN>,'>')
100	CONTINUE
C
C	Continued on next page
C

C
C	Finally, write out the 'trailing' codes and the tail text.
C	The trailing codes live at the end of the BASIC
C	error message space.
C
	WRITE (1, 902)
902	FORMAT (
     8  1X,'FORFILUSE,1769387 ; MSG FAOCNT=2,',
     8   '< for file !AS at user PC !XL>',/,
     9  1X,'USEPC_PSL,1769395 ; MSG FAOCNT=2,',
     9   '< at user PC=!XL, PSL=!XL>',/,
     1	1X,'FROIOL,1769403 ; MSG FAOCNT=1,',
     1	 '< from immediate mode in module !AC>',/,
     1	1X,'ON_CHAFIL,1769411 ; MSG FAOCNT=3,',
     1	 '< on channel !SL for file !AS at user PC !XL>',/,
     1	1X,'FROLINMOD,1769419 ; MSG FAOCNT=2,'
     1	 '< from line !SL in module !AC>',/,
     2	1X,'FROLINSUB,1769427 ; MSG FAOCNT=2,'
     2	 '< from line !SL in subprogram !AC>',/,
     3	1X,'FROLINFUN,1769435 ; MSG FAOCNT=2,'
     3	 '< from line !SL in external function !AC>',/,
     4	1X,'FROLINDEF,1769443 ; MSG FAOCNT=3,'
     4	 '< from line !SL in DEF !AC in module !AC>',/,
     5	1X,'FROLINDFS,1769451 ; MSG FAOCNT=3,'
     5	 '< from line !SL in DEF* !AC in module !AC>',/,
     6  1X,'FROLINGSB,1769459 ; MSG FAOCNT=3,'
     6	 '< from line !SL in GOSUB !SL in module !AC>',/,
     7	1X,'FROLINOEG,1769467 ; MSG FAOCNT=3,'
     7	 '< from line !SL in ON ERROR GOTO !SL in module !AC>',/,
     8	1X,'>',/,1X,'E',/)
C
C	All done.
C
	CALL EXIT
	END
