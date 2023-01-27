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
C	AUTHOR	BRIAN PORTER		CREATION DATE	18-SEP-1979
C

c++
c	Functional description:
c
c	This module returns the which map register is selected by a
c	device.  
c
c	Modified by:
c
c	v02-001	BP0001		Brian Porter,		22-JUL-1981
c		Added second entry point.
c**
c--


	subroutine calc_map (lun,bit_number,register1,register2)


	byte		lun

	byte		bit_number

	integer*4	register1

	integer*4	register2

	integer*4	map_number

	integer*4	field

	integer*4	compress4


	field = lib$extzv (9,7,register2)

	call lib$insv (lib$extzv (bit_number,2,register1),7,2,field)

	call linchk (lun,1)

	if (field .gt. 495) then

	write(lun,5) 'MAPPING REGISTER >495. SELECTED'
5	format(' ',t40,a)
	else

	write(lun,10) 'MAPPING REGISTER #',field,'. SELECTED'
10	format(' ',t40,a,i<compress4 (field)>,a)
	endif

	return



	entry calc_map2 (bit_number,register1,register2,map_number)



	map_number = lib$extzv (9,7,register2)

	call lib$insv(lib$extzv(bit_number,2,register1),7,2,map_number)

	return

	end

