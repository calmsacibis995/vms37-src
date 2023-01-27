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

c	Author	Brian Porter		Creation Date	31-MAY-1981




	subroutine pcl11t (lun)

c++
c	Functional description:
c
c	This routine displays error log entries made by the
c	PCL11-B transmitter driver.
c
c	Modified by:
c
c	v02-002	BP0002		Brian Porter,			23-NOV-1981
c		Minor edit.
c
c	v02-001	BP0001		Brian Porter,			30-SEP-1981
c		Corrected call to uba_mapping.
c		Added 'device attention' support.
c**
c--



	include	'src$:msghdr.for /nolist'

	include	'src$:deverr.for /nolist'



	byte		lun

	integer*4	tcr

	integer*4	tsr

	integer*4	tsdb

	integer*4	tsbc

	integer*4	tsba

	integer*4	tmmr

	integer*4	tscrc

	integer*4	ucb$w_flagword

	integer*4	ucb$l_lt_dpn

	integer*4	ucb$l_lt_dpr

	integer*4	ucb$l_lt_fmpr

	integer*4	ucb$l_lt_pmpr

	integer*4	ucb$l_devdepend

	equivalence	(emb$l_dv_regsav(0),tcr)

	equivalence	(emb$l_dv_regsav(1),tsr)

	equivalence	(emb$l_dv_regsav(2),tsdb)

	equivalence	(emb$l_dv_regsav(3),tsbc)

	equivalence	(emb$l_dv_regsav(4),tsba)

	equivalence	(emb$l_dv_regsav(5),tmmr)

	equivalence	(emb$l_dv_regsav(6),tscrc)

	equivalence	(emb$l_dv_regsav(7),ucb$w_flagword)

	equivalence	(emb$l_dv_regsav(9),ucb$l_lt_dpn)

	equivalence	(emb$l_dv_regsav(10),ucb$l_lt_dpr)

	equivalence	(emb$l_dv_regsav(11),ucb$l_lt_fmpr)

	equivalence	(emb$l_dv_regsav(12),ucb$l_lt_pmpr)

	equivalence	(emb$l_dv_regsav(13),ucb$l_devdepend)

	integer*4	compressc

	integer*4	compress4

	integer*4	destination_code

	integer*4	response_bits

	integer*4	selected_map_register

	character*26	v1tcr(0:8)

	data		v1tcr(0)	/'START TRANSMISSION*'/

	data		v1tcr(1)	/'TRANSMITTER INITIALIZE*'/

	data		v1tcr(2)	/'INHIBIT ADDRESS INCREMENT*'/

	data		v1tcr(3)	/'DATA OUTPUT READY*'/

	data		v1tcr(4)	/'EXTENDED BUS ADDRESS 16*'/

	data		v1tcr(5)	/'EXTENDED BUS ADDRESS 17*'/

	data		v1tcr(6)	/'INTERRUPT ENABLE*'/

	data		v1tcr(7)	/'READ SILO*'/

	character*16	v2tcr(13:15)

	data		v2tcr(13)	/'SEND WORD*'/

	data		v2tcr(14)	/'TRANSMITTER NPR*'/

	data		v2tcr(15)	/'RETRY IF BUSY*'/

	character*22	v1tsr(4:15)

	data		v1tsr(4)	/'TDM BUS BUSY*'/

	data		v1tsr(5)	/'SOFTWARE REJECT*'/

	data		v1tsr(6)	/'BUSY*'/

	data		v1tsr(7)	/'SUCCESSFUL TRANSFER*'/

	data		v1tsr(8)	/'DATA INPUT READY*'/

	data		v1tsr(9)	/'DATA OVERRUN*'/

	data		v1tsr(10)	/'TIMEOUT*'/

	data		v1tsr(11)	/'MASTER DOWN*'/

	data		v1tsr(12)	/'TRANSMISSION ERROR*'/

	data		v1tsr(13)	/'MEMORY OVERFLOW*'/

	data		v1tsr(14)	/'NON-EXISTENT LOCATION*'/

	data		v1tsr(15)	/'ERROR*'/

	character*29	response_a(0:3)

	data		response_a(0)	/'TRANSMITTER ERROR/OFF-LINE*'/

	data		response_a(1)	/'NULL CYCLE*'/

	data		response_a(2)	/'VALID WORD/CRC ON DATA LINES*'/

	data		response_a(3)	/'LAST CRC ON DATA LINES*'/

	character*28	response_b(0:3)

	data		response_b(0)	/'RECEIVER ERROR/OFF-LINE*'/

	data		response_b(1)	/'NULL CYCLE*'/

	data		response_b(2)	/'CHECK FAILURE PREVIOUS DATA*'/

	data		response_b(3)	/'ACKNOWLEDGE CRC OR DATA*'/

	character*6	reg_herald(0:6)

	data		reg_herald(0)	/'TCR*'/

	data		reg_herald(1)	/'TSR*'/

	data		reg_herald(2)	/'TSDB*'/

	data		reg_herald(3)	/'TSBC*'/

	data		reg_herald(4)	/'TSBA*'/

	data		reg_herald(5)	/'TMMR*'/

	data		reg_herald(6)	/'TSCRC*'/

c++
c	The format for the pcl11b transmitter buffer is as follows.
c
c	+-------------------------------------+
c	|                tcr                  |
c	+-------------------------------------+
c	|                tsr                  |
c	+-------------------------------------+
c	|                tsdb                 |
c	+-------------------------------------+
c	|                tsbc                 |
c	+-------------------------------------+
c	|                tsba                 |
c	+-------------------------------------+
c	|                tmmr                 |
c	+-------------------------------------+
c	|                tscrc                |
c	+-------------------------------------+
c	|            ucb$w_flagword           |
c	+-------------------------------------+
c	|   ucb$b_lt_retry, ucb$b_lt_maxtry   |
c	+-------------------------------------+
c	|            ucb$w_lt_dpn             |
c	+-------------------------------------+
c	|            ucb$l_lt_dpr             |
c	+-------------------------------------+
c	|            ucb$l_lt_fmpr            |
c	+-------------------------------------+
c	|            ucb$l_lt_pmpr            |
c	+-------------------------------------+
c	|            ucb$l_devdepend          |
c	+-------------------------------------+
c	|            ucb$w_sts                |
c	+-------------------------------------+
c--




	call frctof (lun)

	call dhead1 (lun,'UBA PCL11 (TRANSMITTER)')

	call linchk (lun,2)

	write(lun,10) 'TCR',tcr
10	format('0',t8,a,t24,z8.4)

	call output (lun,tcr,v1tcr,0,0,7,'0')

	destination_code = lib$extzv (8,5,tcr)

	call linchk (lun,1)

	write(lun,15) destination_code
15	format(' ',t40,'DESTINATION ADDRESS ',
	1 i<compress4 (destination_code)>,'.')

	call output (lun,tcr,v2tcr,13,13,15,'0')

	call linchk (lun,1)

	write(lun,20) 'TSR',tsr
20	format(' ',t8,a,t24,z8.4)

	response_bits = lib$extzv (0,2,tsr)

	call linchk (lun,1)

	write(lun,25) response_a(response_bits)
25	format(' ',t40,a<compressc (response_a(response_bits))>)

	response_bits = lib$extzv (2,2,tsr)

	call linchk (lun,1)

	write(lun,30) response_b(response_bits)
30	format(' ',t40,a<compressc (response_b(response_bits))>)

	call output (lun,tsr,v1tsr,4,4,15,'0')

	call linchk (lun,1)

	write(lun,20) 'TSDB',tsdb

	call linchk (lun,1)

	write(lun,20) 'TSBC',tsbc

	call linchk (lun,1)

	write(lun,20) 'TSBA',tsba

	call calc_map (lun,4,tcr,tsba)

	call linchk (lun,1)

	write(lun,20) 'TMMR',tmmr

	call linchk (lun,1)

	write(lun,20) 'TSCRC',tscrc

	if (emb$w_hd_entry .ne. 98) then

	if (ucb$l_lt_dpn .ne. 0) then

	call uba_datapath (lun,ucb$l_lt_dpn,ucb$l_lt_dpr)
	endif

	call calc_map2 (4,tcr,tsba,selected_map_register)

	call uba_mapping (lun,selected_map_register,ucb$l_lt_fmpr)

	if (
	1 lib$extzv (16,16,emb$l_dv_iosb1) .gt. 512
	1 .and.
	1 selected_map_register .ne. 0
	1 ) then

	call uba_mapping (lun,(selected_map_register-1),ucb$l_lt_pmpr)
	endif
	endif

	call linchk (lun,1)

	write(lun,35)
35	format(' ',:)

	call ucb$l_ownuic (lun,emb$l_dv_ownuic)

	call ucb$l_char (lun,emb$l_dv_char)

	call ucb$w_sts (lun,emb$w_dv_sts)

	call ucb$l_opcnt (lun,emb$l_dv_opcnt)

	call ucb$w_errcnt (lun,emb$w_dv_errcnt)

	call linchk (lun,1)

	write(lun,40) 'UCB$W_FLAGWORD',ucb$w_flagword
40	format(' ',t8,a,t28,z4.4)

	call linchk (lun,1)

	write(lun,45) 'UCB$L_DEVDEPEND',ucb$l_devdepend
45	format(' ',t8,a,t24,z8.8)

	if (emb$w_hd_entry .ne. 98) then

	call linchk (lun,1)

	write(lun,35)

	call pcl11t_qio (lun,emb$w_dv_func)

	call irp$w_bcnt (lun,emb$w_dv_bcnt)

	call irp$w_boff (lun,emb$w_dv_boff)

	call irp$l_pid (lun,emb$l_dv_rqpid)

	call irp$q_iosb (lun,emb$l_dv_iosb1)
	endif

	return



	entry	b_pcl11t (lun)



	call dhead1 (lun,'UBA PCL11 (TRANSMITTER)')

	call brief16 (lun,(7),tcr,reg_herald,emb$t_dv_name,emb$w_dv_unit)

	return



	entry c_pcl11t (lun)



	call cryptk (lun,16,(7),tcr,reg_herald,emb$t_dv_name,emb$w_dv_unit)

	return

	end



	subroutine pcl11t_qio (lun,emb$w_dv_func)



	include 'src$:qiocommon.for /nolist'



	byte		lun

	integer*2	emb$w_dv_func

	integer*4	qiocode(0:1,0:63)




	if (qiocode(0,0) .eq. 0) then

	qiocode(1,11) = %loc(io$_writepblk)

	qiocode(1,32) = %loc(io$_writelblk)

	qiocode(1,35) = %loc(io$_setmode)

	qiocode(1,39) = %loc(io$_sensemode)

	do 10,i = 0,63

	qiocode(0,i) = 33

	if (qiocode(1,i) .eq. 0) then

	qiocode(1,i) = %loc(qio_string)
	endif

10	continue
	endif

	call irp$w_func (lun,emb$w_dv_func,
	1 qiocode(0,lib$extzv(0,6,emb$w_dv_func)))

	return

	end
