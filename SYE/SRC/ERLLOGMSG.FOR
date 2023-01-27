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

c	Author	Brian Porter			Creation date	07-FEB-1982

c++
c	Functional description
c
c	This module provides dispatching for entries logged by erl$logmessage.
c	Dispatching is done by emb$w_lm_msgtyp.
c
c	Modified by:
c
c	v03-001	BP0001		Brian Porter,		14-APR-1982
c		Added more routines.
c--
c**



	subroutine erl$logmessage_dispatcher (lun,record_length,reccnt,option)


	include	'src$:msghdr.for /nolist'

	include	'src$:emblmdef.for /nolist'




	byte		lun

	integer*4	record_length

	integer*4	reccnt

	character*1	option




	if (emb$w_lm_msgtyp .eq. 1) then

	if (
	1 option .eq. 'S'
	1 .or.
	1 option .eq. 'B'
	1 ) then

	call header (lun)

	call logger (lun,'ERL$LOGMESSAGE ENTRY')

	call dhead2 (lun,'I/O',emb$b_lm_namlng,emb$t_lm_name,emb$w_lm_unit)
	endif

	if (option .eq. 'S') then

	call linchk (lun,2)

	write(lun,5)
5	format('0',t8,'REPORT WILL BE PRINTED AFTER INPUT FILE "<EOF>"')

	call dudriver_mscp_q (record_length,reccnt,emb$b_lm_msgtxt)
	endif

	else if (emb$w_lm_msgtyp .eq. 2) then

	call erllogmsg (lun)

	else if (emb$w_lm_msgtyp .eq. 3) then

	call erllogmsg (lun)

	else if (emb$w_lm_msgtyp .eq. 4) then

	call pudriver_mscp_dispatcher (lun,option,reccnt)

	else if (emb$w_lm_msgtyp .eq. 5) then

	if (
	1 option .eq. 'S'
	1 .or.
	1 option .eq. 'B'
	1 ) then

	call frctof (lun)

	call header (lun)

	call logger (lun,'ERL$LOGMESSAGE ENTRY')

	call dhead2 (lun,'I/O',emb$b_lm_namlng,emb$t_lm_name,emb$w_lm_unit)

	call linchk (lun,2)

	write(lun,10) '"AVAILABLE" MSCP ATTENTION MESSAGE'
10	format('0',a)
	endif

	if (option .eq. 'S') then

	call mscp$$k_op_avatn (lun,.true.)
	endif

	else if (emb$w_lm_msgtyp .eq. 6) then

	if (
	1 option .eq. 'S'
	1 .or.
	1 option .eq. 'B'
	1 ) then

	call frctof (lun)

	call header (lun)

	call logger (lun,'ERL$LOGMESSAGE ENTRY')

	call dhead2 (lun,'I/O',emb$b_lm_namlng,emb$t_lm_name,emb$w_lm_unit)

	call linchk (lun,2)

	write(lun,10) '"DUPLICATE UNIT NUMBER" MSCP ATTENTION MESSAGE'
	endif

	if (option .eq. 'S') then

	call mscp$$k_op_dupun (lun,.true.)
	endif

	else if (emb$w_lm_msgtyp .eq. 7) then

	if (
	1 option .eq. 'S'
	1 .or.
	1 option .eq. 'B'
	1 ) then

	call header (lun)

	call logger (lun,'ERL$LOGMESSAGE ENTRY')

	call dhead2 (lun,'I/O',emb$b_lm_namlng,emb$t_lm_name,emb$w_lm_unit)
	endif

	if (option .eq. 'S') then

	call linchk (lun,2)

	write(lun,5)

	call dudriver_mscp_q (record_length,reccnt,emb$b_lm_msgtxt)
	endif

	else if (emb$w_lm_msgtyp .eq. 8) then

	if (
	1 option .eq. 'S'
	1 .or.
	1 option .eq. 'B'
	1 ) then

	call frctof (lun)

	call header (lun)

	call logger (lun,'ERL$LOGMESSAGE ENTRY')

	call dhead2 (lun,'I/O',emb$b_lm_namlng,emb$t_lm_name,emb$w_lm_unit)

	call linchk (lun,2)

	write(lun,10) '"ACCESS PATH" MSCP ATTENTION MESSAGE'
	endif

	if (option .eq. 'S') then

	call mscp$$k_op_acpth (lun,.true.)
	endif

c
c	The IF-THEN-ELSE should be expanded at this point to add
c	new entry sub codes.
c

	else

	call erllogmsg (lun)
	endif

	return

	end



	subroutine erllogmsg (lun)



	include 'src$:msghdr.for /nolist'

	include	'src$:emblmdef.for /nolist'



	byte		lun

	integer*4	compress4



	call frctof (lun)

	call header (lun)

	call logger (lun,'ERL$LOGMESSAGE ENTRY')

	call dhead2 (lun,'I/O',emb$b_lm_namlng,emb$t_lm_name,emb$w_lm_unit)




	entry erllogmsg2 (lun)




	call linchk (lun,3)

	write(lun,90) 'EMB$W_LM_MSGTYP',(emb$w_lm_msgtyp,i = 1,2)
90	format('0',t8,a,t28,z4.4,/,
	1 t40,a,i<compress4 (lib$extzv(0,16,emb$w_lm_msgtyp))>)

	call dumpreg (lun,((record_length + 3)/4) - 9,emb(38))

	return

	end
