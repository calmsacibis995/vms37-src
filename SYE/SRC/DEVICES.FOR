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

c	Author	Brian Porter		Creation date	14-MAY-1981

c++
c	Functional description:
c
c	This module dispatches to the correct device module.  Dispatching
c	is done using emb$b_dv_class and emb$b_dv_type.
c
c	Modified by:
c
c	v03-001 BP0008		Brian Porter,		03-MAR-1980
c		Added UDA50.
c**
c--



	subroutine devices (lun,emb$b_dv_class,emb$b_dv_type,option)



	byte		lun

	byte		emb$b_dv_class

	byte		emb$b_dv_type

	character*1	option

c
c	dispatching is done by multiplying the class by 100 to get
c	the line number
c

	goto (

	1 100,		! - disks

	1 200,		! - tapes

	1               30000, 30000, 30000, 30000, 30000, 30000, ! - 3/8

	1 30000, 30000, 30000, 30000, 30000, 30000, 30000, 30000, ! - 9/16

	1 30000, 30000, 30000, 30000, 30000, 30000, 30000, 30000, ! - 17/24

	1 30000, 30000, 30000, 30000, 30000, 30000, 30000,        ! - 25/31

	1 3200,		! - synchronous communications

	1 30000, 30000, 30000, 30000, 30000, 30000, 30000, 30000, ! - 33/40

	1 30000, 30000, 30000, 30000, 30000, 30000, 30000, 30000, ! - 41/48

	1 30000, 30000, 30000, 30000, 30000, 30000, 30000, 30000, ! - 49/56

	1 30000, 30000, 30000, 30000, 30000, 30000, 30000, 30000, ! - 57/64

	1 30000, 30000,                                           ! - 65/66

	1 6700,		! - line printers

	1 30000, 30000, 30000, 30000,                             ! - 68/71

	1 30000, 30000, 30000, 30000, 30000, 30000, 30000, 30000, ! - 72/79

	1 30000, 30000, 30000, 30000, 30000, 30000, 30000, 30000, ! - 80/87

	1 30000, 30000, 30000, 30000, 30000, 30000, 30000, 30000, ! - 88/95

	1 9600,		! - real time

	1 30000, 30000, 30000, 30000, 30000, 30000, 30000, 30000, ! - 97/104

	1 30000, 30000, 30000, 30000, 30000, 30000, 30000, 30000, ! - 105/112

	1 30000, 30000, 30000, 30000, 30000, 30000, 30000, 30000, ! - 113/120

	1 30000, 30000, 30000, 30000, 30000, 30000, 30000,        ! - 121/127

	1 12800		! - bus

	1 ) lib$extzv (0,8,emb$b_dv_class)

	goto 30000

c
c	dispatching is done by appending the type to the class line number
c

c
c	disks
c

100	continue


	goto (

	1 101,		! - rk06

	1 102,		! - rk07

	1 103,		! - rp04

	1 104,		! - rp05

	1 105,		! - rp06

	1 106,		! - rm03

	1 107,		! - rp07

	1 30000,	! - use other dispatcher

	1 109,		! - rl01

	1 110,		! - rl02

	1 111,		! - rx02

	1 112,		! - rx03

	1 113,		! - rm80

	1 114,		! - tu58

	1 115,		! - rm05

	1 30000,	! - rx01

	1 117,		! - ml11

	1 118,		! - rb02

	1 119		! - rb80

	1 ) lib$extzv (0,8,emb$b_dv_type)

	goto 30000

101	continue

102	continue

	if (option .eq. 'S') then

	call rkdisk (lun)

	else if (option .eq. 'B') then

	call b_rkdisk (lun)

	else if (option .eq. 'C') then

	call c_rkdisk (lun)
	endif

	return

103	continue

104	continue

105	continue

106	continue

107	continue

	if (option .eq. 'S') then

	call massdisk (lun)

	else if (option .eq. 'B') then

	call b_massdisk (lun)

	else if (option .eq. 'C') then

	call c_massdisk (lun)
	endif

	return

109	continue

110	continue

	if (option .eq. 'S') then

	call rldisk (lun)

	else if (option .eq.'B') then

	call b_rldisk (lun)

	else if (option .eq.'C') then

	call c_rldisk (lun)
	endif

	return

111	continue

112	continue

	if (option .eq. 'S') then

	call rxdisk (lun)

	else if (option .eq. 'B') then

	call b_rxdisk (lun)

	else if (option .eq. 'C') then

	call c_rxdisk (lun)
	endif

	return

113	continue

	if (option .eq. 'S') then

	call massdisk (lun)

	else if (option .eq. 'B') then

	call b_massdisk (lun)

	else if (option .eq. 'C') then

	call c_massdisk (lun)
	endif

	return

114	continue

	if (option .eq. 'S') then

	call tutape (lun)

	else if (option .eq. 'B') then

	call b_tutape (lun)

	else if (option .eq. 'C') then

	call c_tutape (lun)
	endif

	return

115	continue

	if (option .eq. 'S') then

	call massdisk (lun)

	else if (option .eq. 'B') then

	call b_massdisk (lun)

	else if (option .eq. 'C') then

	call c_massdisk (lun)
	endif

	return
	
117	continue

	if (option .eq. 'S') then

	call ml11 (lun)

	else if (option .eq. 'B') then

	call b_ml11 (lun)

	else if (option .eq. 'C') then

	call c_ml11 (lun)
	endif

	return

118	continue

119	continue

	if (option .eq. 'S') then

	call dqdisks (lun)

	else if (option .eq. 'B') then

	call b_dqdisks (lun)

	else if (option .eq. 'C') then

	call c_dqdisks (lun)
	endif

	return

c
c	tapes
c

200	continue

	goto (

	1 201,		! - te16

	1 202,		! - tu45

	1 203,		! - tu77

	1 204,		! - ts11

	1 205		! - tu78

	1 ) lib$extzv (0,8,emb$b_dv_type)

	goto 30000

201	continue

202	continue

203	continue

	if (option .eq. 'S') then

	call masstape (lun)

	else if (option .eq. 'B') then

	call b_masstape (lun)

	else if (option .eq. 'C') then

	call c_masstape (lun)
	endif

	return

204	continue

	if (option .eq. 'S') then

	call tstape (lun)

	else if (option .eq. 'B') then

	call b_tstape (lun)

	else if (option .eq. 'C') then

	call c_tstape (lun)
	endif

	return

205	continue

	if (option .eq. 'S') then

	call mftape (lun)

	else if (option .eq. 'B') then

	call b_mftape (lun)

	else if (option .eq. 'C') then

	call c_mftape (lun)
	endif

	return

c
c	scom
c

3200	continue

	goto (

	1 30000,	! - use other dispatcher

	1 30000,	! - use other dispatcher

	1 3203,		! - dup11 (3271)

	1 30000,	! - use other dispatcher

	1 30000,	! - use other dispatcher

	1 30000,	! - use other dispatcher

	1 3207		! - sb11

	1 ) lib$extzv (0,8,emb$b_dv_type)

	goto 30000

3203	continue

	if (option .eq. 'S') then

	call dup3271 (lun)

	else if (option .eq. 'B') then

	call b_dup3271 (lun)
	endif

	return

3207	continue

	if (option .eq. 'S') then

	call sb11 (lun)

	else if (option .eq. 'B') then

	call b_sb11 (lun)

	else if (option .eq. 'C') then

	call c_sb11 (lun)
	endif

	return

c
c	line printers
c

6700	continue

	goto (

	1 6701

	1 ) lib$extzv (0,8,emb$b_dv_type)

	goto 30000

6701	continue

	if (option .eq. 'S') then

	call lcprinter (lun)

	else if (option .eq. 'B') then

	call b_lcprinter (lun)

	else if (option .eq. 'C') then

	call c_lcprinter (lun)
	endif

	return

c
c	realtime
c

9600	continue

	goto (

	1 9601,		! - lpa11

	1 9602,		! - dr780

	1 9603,		! - dr750

	1 9604,		! - dr11w

	1 9605,		! - pcl11 (receiver)

	1 9606		! - pcl11 (transmitter)

	1 ) lib$extzv (0,8,emb$b_dv_type)

	goto 30000

9601	continue

	if (option .eq. 'S') then

	call lpa11k (lun)

	else if (option .eq. 'B') then

	call b_lpa11k (lun)

	else if (option .eq. 'C') then

	call c_lpa11k (lun)
	endif

	return

9602	continue

	if (option .eq. 'S') then

	call dr780 (lun)

	else if (option .eq. 'B') then

	call b_dr780 (lun)

	else if (option .eq. 'C') then

	call c_dr780 (lun)
	endif

	return

9603	continue

	if (option .eq. 'S') then

	call dr750 (lun)

	else if (option .eq. 'B') then

	call b_dr750 (lun)

	else if (option .eq. 'C') then

	call c_dr750 (lun)
	endif

	return

9604	continue

	if (option .eq. 'S') then

	call dr11w (lun)

	else if (option .eq. 'B') then

	call b_dr11w (lun)
	endif

	return

9605	continue

	if (option .eq. 'S') then

	call pcl11r (lun)

	else if (option .eq. 'B') then

	call b_pcl11r (lun)

	else if (option .eq. 'C') then

	call c_pcl11r (lun)
	endif

	return

9606	continue

	if (option .eq. 'S') then

	call pcl11t (lun)

	else if (option .eq. 'B') then

	call b_pcl11t (lun)

	else if (option .eq. 'C') then

	call c_pcl11t (lun)
	endif

	return

c
c	bus
c

12800	continue

	goto (

	1 30000,	! - ci780

	1 30000,	! - ci750

	1 12803		! - uda50

	1 ) lib$extzv (0,8,emb$b_dv_type)

	goto 30000

12803	continue

	if (option .eq. 'S') then

	call pudriver (lun)

	else if (option .eq. 'B') then

	call b_pudriver (lun)
	endif

	return

30000	continue

	return

	end
