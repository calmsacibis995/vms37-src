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
c	This module provides dispatching for entries logged by erl$logstatus.
c
c	Modified by:
c
c	v03-001	BP0001		Brian Porter,		18-APR-1982
c		Added brief.
c--
c**



	subroutine erl$logstatus_dispatcher (lun,record_length,reccnt,option)


	include	'src$:msghdr.for /nolist'

	include	'src$:embspdef.for /nolist'




	byte		lun

	integer*4	record_length

	integer*4	reccnt

	character*1	option




	if (
	1 option .eq. 'S'
	1 .or.
	1 option .eq. 'B'
	1 ) then

	call header (lun)

	call logger (lun,'ERL$LOGSTATUS ENTRY')

	call dhead2 (lun,'I/O',emb$b_sp_namlng,emb$t_sp_name,emb$w_sp_unit)
	endif

	if (
	1 (emb$b_sp_class .eq. 128
	1 .and.
	1 emb$b_sp_type .eq. 3)
	1 ) then

	if (option .eq. 'S') then

	call pudriver_mscp_dispatcher (lun,option,reccnt)
	endif

	else if (
	1 emb$b_sp_class .eq. 1
	1 .and.
	1 (emb$b_sp_type .eq. 20
	1 .or.
	1 emb$b_sp_type .eq. 21)
	1 ) then

	if (option .eq. 'S') then

	call linchk (lun,2)

	write(lun,5)
5	format('0',t8,'REPORT WILL BE PRINTED AFTER INPUT FILE "<EOF>"')

	call dudriver_mscp_q (record_length,reccnt,emb$l_sp_cmdref)
	endif

c
c	The IF-THEN-ELSE should be expanded at this point to add
c	new entry sub codes.
c

	else

	call erllogsts2 (lun)
	endif

	return

	end



	subroutine erllogsts (lun)



	include 'src$:msghdr.for /nolist'

	include	'src$:embspdef.for /nolist'



	byte		lun

	integer*4	compress4



	call frctof (lun)

	call header (lun)

	call logger (lun,'ERL$LOGSTATUS ENTRY')

	call dhead2 (lun,'I/O',emb$b_sp_namlng,emb$t_sp_name,emb$w_sp_unit)




	entry erllogsts2 (lun)




	call linchk (lun,1)

	write(lun,10)
10	format(' ',:)

	call mslg$$l_cmd_ref (lun,emb$l_sp_cmdref)

	call ucb$l_ownuic (lun,emb$l_sp_ownuic)

	call ucb$l_char (lun,emb$l_sp_char)

	call ucb$l_opcnt (lun,emb$l_sp_opcnt)

	call ucb$w_errcnt (lun,emb$w_sp_errcnt)

	call ucb$w_sts (lun,emb$w_sp_sts)

	call linchk (lun,1)

	write(lun,10)

	call cdrp$l_media (lun,emb$l_sp_media)

	if (emb$b_sp_class .eq. 1) then

	call dudriver_qio (lun,emb$w_sp_func)
	else

	call cdrp$w_func (lun,emb$w_sp_func,'QIO FUNCTION')
	endif

	call cdrp$l_bcnt (lun,emb$l_sp_bcnt)

	call cdrp$w_boff (lun,emb$w_sp_boff)

	call cdrp$l_pid (lun,emb$l_sp_rqpid)

	call cdrp$q_iosb (lun,emb$l_sp_iosb1)

	return

	end
