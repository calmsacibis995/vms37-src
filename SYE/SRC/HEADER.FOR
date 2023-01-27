C
C	Version 'V03-001'
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
	SUBROUTINE HEADER (LUN)

C
C	AUTHOR	BRIAN PORTER		CREATION DATE	3-MAR-1979
C
C	Functional description:
C
C	This module displays the herald for individual entries.
C
C	Modified by:
C
C	v03-001	BP0003		Brian Porter,		05-MAR-1982
C		Added mscp support.
C
C**



	INCLUDE 'SRC$:MSGHDR.FOR /NOLIST'

	INCLUDE 'SRC$:SYECOM.FOR/NOLIST'



	BYTE		LUN

	integer*4	record_number

	CHARACTER*24	TIME

	LOGICAL*4	SYS$ASCTIM
	EXTERNAL	SYS$ASCTIM

	INTEGER*4	FIELD
 
	INTEGER*4	COMPRESS4

 
	CALL LINCHK(LUN,2)
 
	WRITE(LUN,5) ('*',I=1,28),RECCNT,('*',I=1,28)
5	FORMAT(' ',28A1,' ENTRY ',I7,'. ',28A1)
 
7	FIELD = LIB$EXTZV(0,16,EMB$W_HD_ERRSEQ)

	WRITE(LUN,10) FIELD,EMB$L_HD_SID		
10	FORMAT(' ','ERROR SEQUENCE ',I<COMPRESS4 (FIELD)>,'.',T52,
	1 'LOGGED ON SID',T66,Z8.8)
 
	RETURN



	entry header2 (lun,record_number)



	call linchk(lun,2)
 
	write(lun,5) ('*',i=1,28),record_number,('*',i=1,28)
 
	goto 7

	end
