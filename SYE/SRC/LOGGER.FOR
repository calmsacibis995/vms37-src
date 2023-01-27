C
C	v02-003
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

c	Author	Brian Porter			Creation Date	17-JUN-1981

c++
c	Functional description:
c
c	This module displays the vms time and decoded logging sid for
c	the error log entry.
c
c	Modified by:
c
c	v02-003	BP0003		Brian Porter,		28-SEP-1981
c		Corrected hardware revision problem with 11/780.
c
c	v02-002	BP0002		Brian Porter,		17-AUG-1981
c		Added 11/730 support.
c
c	v02-001	BP0001		Brian Porter,		5-AUG-1981
c		Added code to count lines output.
c**
c--



	subroutine logger (lun,entry_herald)



	include 'src$:msghdr.for /nolist'




	byte		lun

	character*(*)	entry_herald

	logical*4	sys$asctim

	character*26	sys$asctim_string
	data		sys$asctim_string(1:2)		/', '/
	data		sys$asctim_string(26:26)	/'*'/

	integer*4	compress4

	integer*4	compressc

	integer*4	logging_cpu_type

	integer*4	hardware_revision

	integer*4	serial_number



	if (.not. sys$asctim(,sys$asctim_string(3:25),emb$q_hd_time,%val(0)))
	1 then

	sys$asctim_string(3:3) = '*'
	endif

	logging_cpu_type = lib$extzv(24,8,emb$l_hd_sid)

	call linchk (lun,2)

c
c	11/780
c

	if (logging_cpu_type .eq. 255) then

	hardware_revision = lib$extzv(19,5,emb$l_hd_sid)

	serial_number = lib$extzv(0,12,emb$l_hd_sid)

	write(lun,10) entry_herald,sys$asctim_string,' KA780 REV# ',
	1 hardware_revision,' SERIAL# ',serial_number
10	format('0',a<min(len(entry_herald),24)>,
	1 a<compressc (sys$asctim_string)>,a,i<compress4 (hardware_revision)>,
	1 '.',a,i<compress4 (serial_number)>,'.')

	else if (logging_cpu_type .eq. 1) then

	hardware_revision = lib$extzv(19,5,emb$l_hd_sid)

	serial_number = lib$extzv(0,12,emb$l_hd_sid)

	write(lun,10) entry_herald,sys$asctim_string,' KA780 REV# ',
	1 hardware_revision,' SERIAL# ',serial_number

c
c	11/750
c

	else if (logging_cpu_type .eq. 2) then

	hardware_revision = lib$extzv(0,8,emb$l_hd_sid)

	micro_code_revision = lib$extzv(8,8,emb$l_hd_sid)

	write(lun,20) entry_herald,sys$asctim_string,' KA750 REV# ',
	1 hardware_revision,' MIC# ',micro_code_revision
20	format('0',a<min(len(entry_herald),24)>,
	1 a<compressc (sys$asctim_string)>,a,i<compress4 (hardware_revision)>,
	1 '.',a,i<compress4 (micro_code_revision)>,'.')

c
c	11/730
c

	else if (logging_cpu_type .eq. 3) then

	hardware_revision = lib$extzv(0,8,emb$l_hd_sid)

	micro_code_revision = lib$extzv(8,8,emb$l_hd_sid)

	write(lun,25) entry_herald,sys$asctim_string,' KA730 REV# ',
	1 hardware_revision,' MIC# ',micro_code_revision
25	format('0',a<min(len(entry_herald),24)>,
	1 a<compressc (sys$asctim_string)>,a,i<compress4 (hardware_revision)>,
	1 '.',a,i<compress4 (micro_code_revision)>,'.')

c
c	Additional "cpu type" support should be added be expanding
c	the ELSE-IF-THEN at this point.
c
	else

	write(lun,1000) entry_herald,sys$asctim_string
1000	format('0',a<min(len(entry_herald),24)>,
	1 a<compressc (sys$asctim_string)>)
	endif

	return

	end
