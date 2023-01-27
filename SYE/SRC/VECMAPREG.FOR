C
C	v02-001
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

c	Author	Brian Porter			Creation Date	01-SEP-1981

c++
c	Functional description:
c
c	This module displays the CRB longword VEC$L_MAPREG.
c
c	Modified by:
c
c	v02-001	BP0001		Brian Porter,		05-NOV-1981
c		Added direct datapath filter.
c**
c--




	subroutine vecmapreg (lun,vec$l_mapreg)



	byte		lun

	integer*4	vec$l_mapreg

	integer*4	field

	integer*4	compress4

	character*31	vec$v_maplock(15:15)

	data		vec$v_maplock(15)
	1 /'"MPR"(S) PERMANENTLY ALLOCATED*'/

	character*23	vec$v_lwae(29:29)

	data		vec$v_lwae(29)
	1 /'LONGWORD ACCESS ENABLE*'/

	character*28	vec$v_pathlock(31:31)

	data		vec$v_pathlock(31)
	1 /'"BDP" PERMANENTLY ALLOCATED*'/



	call linchk (lun,4)

	write(lun,75) 'MAPPING ALLOCATION INFORMATION'
75	format('0',a)

	write(lun,80) 'VEC$L_MAPREG',vec$l_mapreg
80	format('0',t8,a,t24,z8.8)

	field = lib$extzv(0,15,vec$l_mapreg)

	call linchk (lun,1)

	write(lun,85) '"MPR" #',field,'. STARTING MAP REGISTER'
85	format(' ',t40,a,i<compress4 (field)>,a)

	call output (lun,vec$l_mapreg,vec$v_maplock,15,15,15,'0')

	field = lib$extzv(16,8,vec$l_mapreg)

	call linchk (lun,1)

	write(lun,90) field,'. MAP REGISTER(S) ALLOCATED'
90	format(' ',t40,i<compress4 (field)>,a)

	field = lib$extzv(24,5,vec$l_mapreg)

	call linchk (lun,1)

	if (field .ne. 0) then

	write(lun,95) 'DATAPATH #',field,'. ALLOCATED'
95	format(' ',t40,a,i<compress4 (field)>,a)
	else

	write(lun,100) 'DIRECT DATAPATH'
100	format(' ',t40,a)
	endif

	call output (lun,vec$l_mapreg,vec$v_lwae,29,29,29,'0')

	call output (lun,vec$l_mapreg,vec$v_pathlock,31,31,31,'0')

	return

	end
