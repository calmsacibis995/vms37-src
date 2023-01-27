	INTEGER*4 FUNCTION TIMCMP(A,B)

C 
C	Version 'V03-000'
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

C	Author	Bill Storey			Creation Date:	Unknown

C++
C
C	FUNCTIONAL DESCRIPTION:
C
C
C	INTEGER*4 FUNCTION TIMCMP is used to compare two VAX/VMS
C	absolute time values.  Each time value is a binary number
C	in 100-nanosecond units offset from the system base date
C	and time, which is 17-NOV-1858 00:00:00.0.   Each absolute
C	time is a positive value.
C
C	If A > B then a positive number is returned.
C
C	If A = B then 0 is returned.
C
C	If A < B then a negative number is returned.
C
C	Modified by:
C
C	v02-001	BP0001		Brian Porter,		01-DEC-1981
C		Added protection against garbage being in date field
C		of error log entry header.
C**
C--


 
	INTEGER*4	A(0:1)

	INTEGER*4	B(0:1)
 

 
	TIMCMP	= lib$extzv(0,30,A(1)) - lib$extzv(0,30,B(1))
 
	IF(TIMCMP .NE. 0)  RETURN
 
	IF(IAND(IEOR(A(0),B(0)),'80000000'X) .EQ. 0)
	1	THEN
			TIMCMP = A(0) - B(0)
		ELSE
			TIMCMP = B(0)
	ENDIF
 
	RETURN
 
	END
