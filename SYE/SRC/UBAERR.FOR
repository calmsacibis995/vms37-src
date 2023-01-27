C
C	Version	'V03-000'
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
C	Author	Brian Porter		Creation date	06-MAY-1981
C

c++
c	Functional description:
c
c	This module displays uba entries for the 11/7zz.
c
c	Modified by:
c
c	v02-003	BP0003		Brian Porter,		19-NOV-1981
c		Added dispatching.
c
c	v02-002	BP0002		Brian Porter,		11-NOV-1981
c		Changed register herald.
c
c	v02-001	BP0001		Brian Porter,		01-JUL-1981
c		Added call to LOGGER.
c**
c--



	subroutine uba_errors (lun,option)



	include 'src$:msghdr.for /nolist'



	byte		lun

	character*1	option



	if (lib$extzv(24,8,emb$l_hd_sid) .eq. 3) then

	if (option .eq. 'S') then

	call dw730_error (lun)

	else if (option .eq. 'B') then

	call b_dw730_error (lun)

	else if (option .eq. 'C') then

	call c_dw730_error (lun)
	endif

c
c	for future expansion the IF-THEN-ELSE should be expanded
c	at this point.
c
	endif

	return

	end



	subroutine dw730_error (lun)



	include	'src$:msghdr.for /nolist'


	byte		lun

	integer*4	uba_csr

	equivalence	(emb(16),uba_csr)

	character*20	v1uba_csr(14:16)

	data		v1uba_csr(14)	/'WRITE ERROR*'/

	data		v1uba_csr(15)	/'MAP PARITY ERROR*'/

	data		v1uba_csr(16)	/'NON-EXISTENT MEMORY*'/

	character*21	v2uba_csr(31:31)

	data		v2uba_csr(31)	/'READ DATA SUBSTITUTE*'/



	call frctof (lun)

	call header (lun)

	call logger (lun,'DW730 ERROR')

	call linchk (lun,2)

	write(lun,10) uba_csr
10	format('0',t8,'DW730 CSR',t24,z8.8)

	call output (lun,uba_csr,v1uba_csr,14,14,16,'0')

	call output (lun,uba_csr,v2uba_csr,31,31,31,'0')

	return




	entry b_dw730_error (lun)



	call header (lun)

	call logger (lun,'DW730 ERROR')

	call brief32 (lun,(1),uba_csr,'UBA CSR','UBA',0)

	return



	entry c_dw730_error (lun)



	call cryptk (lun,32,(1),uba_csr,'UBA CSR','UBA',0)

	return

	end
