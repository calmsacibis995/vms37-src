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
C
C
C	AUTHOR	BRIAN PORTER		CREATION DATE	20-AUG-1979
C
C
C	Funtional description:
C
C	This include file defines the header section of every error log
C	entry type record.
C
C	Modified by:
C
C	v02-001	BP0001		Brian Porter,		4-SEP-1980
C		Changed EMB$Q_HD_TIME from a REAL*8 to a INTEGER*4 array.
C**

	BYTE		EMB(0:511)

	COMMON	/EMB/	EMB

	INTEGER*4	EMB$L_HD_SID		!SYSTEM ID REGISTER
	EQUIVALENCE	(EMB$L_HD_SID,EMB(0))

	INTEGER*2	EMB$W_HD_ENTRY		!MESSAGE ENTRY TYPE
	EQUIVALENCE	(EMB$W_HD_ENTRY,EMB(4))

	integer*4	EMB$Q_HD_TIME(2)	!TIME ENTRY LOGGED
	EQUIVALENCE	(EMB$Q_HD_TIME,EMB(6))

	INTEGER*2	EMB$W_HD_ERRSEQ		!UNIQUE SEQUENCE NUMBER
	EQUIVALENCE	(EMB$W_HD_ERRSEQ,EMB(14))

