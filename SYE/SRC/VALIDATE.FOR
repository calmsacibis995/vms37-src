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


	subroutine validate_cpu_and_entry (emb$l_hd_sid,emb$w_hd_entry,cpu,
	1 entry)



C++
C
C	Functional description:
C
C	This routine validates the error log entry type for the
C	logging SID.
C
C	Modified by:
C
C	v03-001	BP0010		Brian Porter,		05-APR-1982
C		Added more mscp.
C**
C--




	include	'src$:syecom.for /nolist'



	integer*4	emb$l_hd_sid

	integer*2	emb$w_hd_entry

	logical*1	cpu

	logical*1	entry

	integer*4	processor_type

	integer*2	entry_type



	
c
c	Processor type validation and entry type size validation
c

	entry = .false.

	processor_type = lib$extzv(24,8,emb$l_hd_sid)

	if (iand(emb$w_hd_entry,'ffffff00'x) .eq. 0) then

	entry_type = lib$extzv(0,7,emb$w_hd_entry)
	else

	entry_type = emb$w_hd_entry
	endif

	if (processor_type .eq. 255) processor_type = 1

	cp_11780 = .false.

	cp_11750 = .false.

	cp_117zz = .false.

	cpu = .true.

	goto (

	1 10, ! 11780

	1 20, ! 11750

	1 30  ! 117zz

	1 ) processor_type

	cpu = .false.

	return

c
c	11/780 entry type validation
c

10	continue

	cp_11780  = .true.

	goto (

	1 110,	! - device error bit(s) set

	1 110,	! - machine check

	1 105,						! - entry type 3

	1 110,	! - bus error

	1 110,	! - SBI alert

	1 110,	! - CRD memory error

	1 110,  ! - SBI asynchronous write error

	1 110,	! - RDS memory error

	1 110,	! - DW780 (UBA) interrupt

	1 105, 105,                                     ! - entry types 10/11

	1 110,	! - RH780 (MBA) interrupt

	1 105, 105, 105,        			! - entry types 13/15

	1 105, 105, 105, 105, 105, 105, 105, 105, 	! - entry types 16/23

	1 105, 105, 105, 105, 105, 105, 105, 105, 	! - entry types 24/31

	1 110,	! - system start-up (cold start)

	1 110,	! - operator shutdown

	1 110,	! - system power fail

	1 110,	! - ERRLOG.SYS created

	1 110,	! - system start-up (power-fail restart)

	1 110,	! - fatal bugcheck shutdown

	1 110,	! - periodic time-stamp

	1 110,	! - $SNDERR system service message

	1 110,	! - non-fatal bugcheck

	1 110,	! - operator message

	1 110,	! - network message

	1 105, 105, 105, 105, 105,			! - entry types 43/47

	1 105, 105, 105, 105, 105, 105, 105, 105,	! - entry types 48/55

	1 105, 105, 105, 105, 105, 105, 105, 105,	! - entry types 56/63

	1 110,	! - mount volume

	1 110,	! - dismount volume

	1 105, 105, 105, 105, 105, 105,			! - entry types 66/71

	1 105, 105, 105, 105, 105, 105, 105, 105,	! - entry types 72/79

	1 105, 105, 105, 105, 105, 105, 105, 105,	! - entry types 80/87

	1 105, 105, 105, 105, 105, 105, 105, 105,	! - entry types 88/95

	1 110,	! - device function software timeout

	1 110,	! - undefined interrupt (unconfigured SCB vector)

	1 110,	! - device attention

	1 110,	! - mscp I/O completion

	1 110,	! - mscp message

	1 105, 105,105,					! - entry types 101/103

	1 105, 105, 105, 105, 105, 105, 105, 105,	! - entry types 104/111

	1 110,	! - user bugcheck

	1 105, 105, 105, 105, 105, 105, 105,		! - entry types 113/119

	1 105, 105, 105, 105, 105, 105, 105, 105	! - entry types 120/127

	1 ) entry_type

	goto 105

c
c	11/750 entry type validation
c

20	continue

	cp_11750 = .true.

	goto (

	1 110,	! - device error bit(s) set

	1 110,	! - machine check

	1 105, 105, 105,				! - entry types 3/5

	1 110,	! - CRD memory error

	1 110,  ! - write bus error

	1 110,	! - RDS memory error

	1 105, 105, 105, 105, 105, 105,	105,		! - entry types 9/15

	1 105, 105, 105, 105, 105, 105, 105, 105, 	! - entry types 16/23

	1 105, 105, 105, 105, 105, 105, 105, 105, 	! - entry types 24/31

	1 110,	! - system start-up (cold start)

	1 110,	! - operator shutdown

	1 110,	! - system power fail

	1 110,	! - ERRLOG.SYS created

	1 110,	! - system start-up (power-fail restart)

	1 110,	! - fatal bugcheck shutdown

	1 110,	! - periodic time-stamp

	1 110,	! - $SNDERR system service message

	1 110,	! - non-fatal bugcheck

	1 110,	! - operator message

	1 110,	! - network message

	1 105, 105, 105, 105, 105,			! - entry types 43/47

	1 105, 105, 105, 105, 105, 105, 105, 105,	! - entry types 48/55

	1 105, 105, 105, 105, 105, 105, 105, 105,	! - entry types 56/63

	1 110,	! - mount volume

	1 110,	! - dismount volume

	1 105, 105, 105, 105, 105, 105,			! - entry types 66/71

	1 105, 105, 105, 105, 105, 105, 105, 105,	! - entry types 72/79

	1 105, 105, 105, 105, 105, 105, 105, 105,	! - entry types 80/87

	1 105, 105, 105, 105, 105, 105, 105, 105,	! - entry types 88/95

	1 110,	! - device function software timeout

	1 110,	! - undefined interrupt (unconfigured SCB vector)

	1 110,	! - device attention

	1 110,	! - mscp I/O completion

	1 110,	! - mscp message

	1 105, 105,105,					! - entry types 101/103

	1 105, 105, 105, 105, 105, 105, 105, 105,	! - entry types 104/111

	1 110,	! - user bugcheck

	1 105, 105, 105, 105, 105, 105, 105,		! - entry types 113/119

	1 105, 105, 105, 105, 105, 105, 105, 105	! - entry types 120/127

	1 ) entry_type

	goto 105

c
c	11/730 entry type validation
c

30	continue

	cp_117zz = .true.

	goto (

	1 110,	! - device error bit(s) set

	1 110,	! - machine check

	1 105, 105, 105,				! - entry type 3/5

	1 110,	! - CRD memory error

	1 105,						! - entry type 7

	1 110,	! - RDS memory error

	1 105, 105,					! - entry type 9/10

	1 110,	! - DW730 (UBA) error

	1 105, 105, 105, 105,                           ! - entry types 12/15

	1 105, 105, 105, 105, 105, 105, 105, 105, 	! - entry types 16/23

	1 105, 105, 105, 105, 105, 105, 105, 105, 	! - entry types 24/31

	1 110,	! - system start-up (cold start)

	1 110,	! - operator shutdown

	1 110,	! - system power fail

	1 110,	! - ERRLOG.SYS created

	1 110,	! - system start-up (power-fail restart)

	1 110,	! - fatal bugcheck shutdown

	1 110,	! - periodic time-stamp

	1 110,	! - $SNDERR system service message

	1 110,	! - non-fatal bugcheck

	1 110,	! - operator message

	1 110,	! - network message

	1 105, 105, 105, 105, 105,			! - entry types 43/47

	1 105, 105, 105, 105, 105, 105, 105, 105,	! - entry types 48/55

	1 105, 105, 105, 105, 105, 105, 105, 105,	! - entry types 56/63

	1 110,	! - mount volume

	1 110,	! - dismount volume

	1 105, 105, 105, 105, 105, 105,			! - entry types 66/71

	1 105, 105, 105, 105, 105, 105, 105, 105,	! - entry types 72/79

	1 105, 105, 105, 105, 105, 105, 105, 105,	! - entry types 80/87

	1 105, 105, 105, 105, 105, 105, 105, 105,	! - entry types 88/95

	1 110,	! - device function software timeout

	1 110,	! - undefined interrupt (unconfigured SCB vector)

	1 110,	! - device attention

	1 110,	! - mscp I/O completion

	1 110,	! - mscp message

	1 105, 105,105,					! - entry types 101/103

	1 105, 105, 105, 105, 105, 105, 105, 105,	! - entry types 104/111

	1 110,	! - user bugcheck

	1 105, 105, 105, 105, 105, 105, 105,		! - entry types 113/119

	1 105, 105, 105, 105, 105, 105, 105, 105	! - entry types 120/127

	1 ) entry_type

	goto 105

c
c	Unsupported entry type, supported cpu type
c

105	return

c
c	Supported entry type, supported cpu type
c

110	entry = .true.

	return

c
c	Unsupported cpu type, implies no supported entry types.
c

115	return

	end



	subroutine validate_device_class_and_type (emb$b_xx_class,
	1 emb$b_xx_type,class,type)



c++
c	Functional description:
c
c	This routine validates device class and types for device entries.
c
c	Modified by:
c**
c--




	byte		emb$b_xx_class

	byte		emb$b_xx_type

	logical*1	class

	logical*1	type

	integer*4	emb$l_xx_class

	integer*4	emb$l_xx_type




	class = .false.

	type = .false.

	emb$l_xx_class = lib$extzv (0,8,emb$b_xx_class)

	emb$l_xx_type = lib$extzv (0,8,emb$b_xx_type)

c
c	Disks
c

	if (emb$l_xx_class .eq. 1) then

	class = .true.

	goto (

	1 535,	! RK06

	1 535,	! RK07

	1 535,	! RP04

	1 535,	! RP05

	1 535,	! RP06

	1 535,	! RM03

	1 535,	! RP07

	1 540,	! SPARE

	1 535,	! RL01

	1 535,	! RL02

	1 535,	! RX02

	1 535,	! RX03

	1 535,	! RM80

	1 535,	! TU58

	1 535,	! RM05

	1 535,	! RX01

	1 535,	! ML11

	1 535,	! RB02

	1 535,	! RB80

	1 535,	! RA80

	1 535	! RA81

	1 ) emb$l_xx_type

c
c	Tapes
c

	else if (emb$l_xx_class .eq. 2) then

	class = .true.

	goto (

	1 535,	! TE16

	1 535,	! TU45

	1 535,	! TU77

	1 535,	! TS11

	1 535	! TU78

	1 ) emb$l_xx_type

c
c	Scom
c

	else if (emb$l_xx_class .eq. 32) then

	class = .true.

	goto (

	1 540,	! spare

	1 540,	! spare

	1 535,	! DUP11 (3271)

	1 540,	! spare

	1 540,	! spare

	1 540,	! spare

	1 535   ! SB11

	1 ) emb$l_xx_type

c
c	Line printers
c

	else if (emb$l_xx_class .eq. 67) then

	class = .true.

	goto (

	1 535	! LP11

	1 ) emb$l_xx_type

c
c	Real time
c

	else if (emb$l_xx_class .eq. 96) then

	class = .true.

	goto (

	1 535,	! LPA11

	1 535,	! DR780

	1 535,	! DR750

	1 535,	! DR11W

	1 535,	! PCL11 (receiver)

	1 535	! PCL11 (transmitter)

	1 ) emb$l_xx_type

c
c	Bus
c

	else if (emb$l_xx_class .eq. 128) then

	class = .true.

	goto (

	1 540,	! CI780

	1 540,	! CI750

	1 535	! UDA50

	1 ) emb$l_xx_type

c
c	The IF-THEN-ELSE should be expanded at this point to add
c	additional support.
c

	endif

	return

535	type = .true.

540	return

	end
