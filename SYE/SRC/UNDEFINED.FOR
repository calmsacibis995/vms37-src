	SUBROUTINE UNDEFINED (LUN)

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
C	AUTHOR	BRIAN PORTER		CREATION DATE	11-DEC-1979
C
C++
C	Functional description:
C
C	This module displays entries that are caused by UNDEFINED INTERRUPTS.
C	An Undefined Interrupt is when an interrupt occurs through an
C	uninitialized SCB vector.
C
C	Modified by:
C
C	v02-001	BP0001		Brian Porter,		1-JUL-1981
C		Added call to LOGGER.  Added 11/7zz support.
C--
C**



	INCLUDE 'SRC$:MSGHDR.FOR /NOLIST'
	INCLUDE 'SRC$:SYECOM.FOR /NOLIST'




	BYTE		LUN

	INTEGER*4	ADAPTER_TR

	INTEGER*4	SLOT_INDEX

	INTEGER*4	SBI_REGA

	INTEGER*4	CSR0

	INTEGER*4	COMPRESS4

	EQUIVALENCE	(EMB(16),ADAPTER_TR,SLOT_INDEX)

	EQUIVALENCE	(EMB(20),SBI_REGA,CSR0)





	CALL FRCTOF (LUN)




	entry b_undefined (lun)




	call header (lun)

	call logger (lun,'UNDEFINED INTERRUPT')

	if (
	1 lib$extzv(24,8,emb$l_hd_sid) .eq. 255
	1 .or.
	1 lib$extzv(24,8,emb$l_hd_sid) .eq. 1
	1 ) then

	CALL LINCHK (LUN,2)

	WRITE(LUN,10) ADAPTER_TR
10	FORMAT('0','ADAPTER TR# ',I<COMPRESS4 (ADAPTER_TR)>,'.')

	CALL CLASSIFY (LUN,SBI_REGA)

	else if (
	1 lib$extzv(24,8,emb$l_hd_sid) .eq. 2
	1 .or.
	1 lib$extzv(24,8,emb$l_hd_sid) .eq. 3
	1 ) then

	CALL LINCHK (LUN,2)

	WRITE(LUN,20) SLOT_INDEX
20	FORMAT('0','ADAPTER SLOT INDEX# ',I<COMPRESS4 (SLOT_INDEX)>,'.')

	CALL LINCHK (LUN,1)

	WRITE(LUN,30) CSR0
30	FORMAT(' ',T8,'ADAPTER CSR ',T24,Z8.8)
	endif

	RETURN

	END
