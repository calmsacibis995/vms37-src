	SUBROUTINE CLASSIFY (LUN,SBI_REGA)
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
C
C	AUTHOR	BRIAN PORTER		CREATION DATE	11-DEC-1979
C

C++
C	Functional description:
C
C	This module is called to identify SBI adapters.
C
C	Modified by:
C
C	v03-001	BP0004		Brian Porter,		19-FEB-1982
C		Added ci780 support.
C**
C--




	BYTE		LUN

	INTEGER*4	SBI_REGA

	INTEGER*4	FIELD

	parameter	ci780 = 56

	PARAMETER	DR780 = 48

	PARAMETER	MBA = 32

	PARAMETER	UBA_0 = 40

	PARAMETER	UBA_3 = 43


c
c	Extract adapter type information
c

	field = lib$extzv(0,8,sbi_rega)

c
c	Is it the DR780?
c

	if (field .eq. dr780) then

	call dr780_rega (lun,sbi_rega)

c
c	Is it the RH780?
c

	else if (field .eq. mba) then

	call rh780_configuration_register (lun,sbi_rega)

c
c	Is it the DW780?
c

	else if (field .ge. uba_0 .and. field .le. uba_3) then

	call uba_rega (lun,sbi_rega)

c
c	Is it the CI780?
c

	else if (field .eq. ci780) then

	call ci780_rega (lun,sbi_rega)
	
c
c	Is it a memory?
c

	else if (lib$extzv(5,3,sbi_rega) .eq. 0) then

	call ms780c_rega (lun,sbi_rega)

	else if (lib$extzv(5,3,sbi_rega) .eq. 2) then

	call ma780_rega (lun,sbi_rega)

	else if (lib$extzv(5,3,sbi_rega) .eq. 3) then

	call ms780e_rega (lun,sbi_rega)

c
c	The if-then-else should be expanded at this point to add
c	new adapter support.
c

	ELSE

	CALL LINCHK (LUN,2)

	WRITE(LUN,70) SBI_REGA
70	FORMAT('0',T8,'SBI REG "A"',T24,Z8.8)
	ENDIF

	RETURN

	END
