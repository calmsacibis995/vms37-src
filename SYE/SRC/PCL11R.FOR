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




	subroutine pcl11r (lun)

c++
c	Functional description:
c
c	This routine displays error log entries made by the
c	PCL11-B receiver driver.
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

	integer*4	rcr

	integer*4	rsr

	integer*4	rddb

	integer*4	rdbc

	integer*4	rdba

	integer*4	rdcrc

	integer*4	ucb$l_lr_dpn

	integer*4	ucb$l_lr_dpr

	integer*4	ucb$l_lr_fmpr

	integer*4	ucb$l_lr_pmpr

	integer*4	ucb$l_trigblk

	integer*4	ucb$l_devdepend

	equivalence	(emb$l_dv_regsav(0),rcr)

	equivalence	(emb$l_dv_regsav(1),rsr)

	equivalence	(emb$l_dv_regsav(2),rddb)

	equivalence	(emb$l_dv_regsav(3),rdbc)

	equivalence	(emb$l_dv_regsav(4),rdba)

	equivalence	(emb$l_dv_regsav(5),rdcrc)

	equivalence	(emb$l_dv_regsav(6),ucb$l_lr_dpn)

	equivalence	(emb$l_dv_regsav(7),ucb$l_lr_dpr)

	equivalence	(emb$l_dv_regsav(8),ucb$l_lr_fmpr)

	equivalence	(emb$l_dv_regsav(8),ucb$l_lr_pmpr)

	equivalence	(emb$l_dv_regsav(10),ucb$l_trigblk)

	equivalence	(emb$l_dv_regsav(11),ucb$l_devdepend)

	integer*4	compressc

	integer*4	compress4

	integer*4	response_bits

	integer*4	current_or_last_transmitter

	integer*4	selected_map_register

	character*26	v1rcr(0:7)

	data		v1rcr(0)	/'RECEIVE DATA*'/

	data		v1rcr(1)	/'RECEIVER INITIALIZE*'/

	data		v1rcr(2)	/'INHIBIT ADDRESS INCREMENT*'/

	data		v1rcr(3)	/'DATA INPUT READY*'/

	data		v1rcr(4)	/'EXTENDED BUS ADDRESS 16*'/

	data		v1rcr(5)	/'EXTENDED BUS ADDRESS 17*'/

	data		v1rcr(6)	/'INTERRUPT ENABLE*'/

	data		v1rcr(7)	/'LOAD SILO*'/

	character*13	v2rcr(13:15)

	data		v2rcr(13)	/'RECEIVE WORD*'/

	data		v2rcr(14)	/'RECEIVER NPR*'/

	data		v2rcr(15)	/'REJECT*'/

	character*22	v1rsr(4:15)

	data		v1rsr(4)	/'CHANNEL OPEN*'/

	data		v1rsr(5)	/'REJECT COMPLETE*'/

	data		v1rsr(6)	/'BUSY*'/

	data		v1rsr(7)	/'SUC TXF*'/

	data		v1rsr(8)	/'DATA OUTPUT READY*'/

	data		v1rsr(9)	/'BYTE COUNT OVERFLOW*'/

	data		v1rsr(10)	/'TIMEOUT*'/

	data		v1rsr(11)	/'PARITY*'/

	data		v1rsr(12)	/'TRANSMISSION ERROR*'/

	data		v1rsr(13)	/'MEMORY OVERFLOW*'/

	data		v1rsr(14)	/'NON-EXISTENT LOCATION*'/

	data		v1rsr(15)	/'ERROR*'/

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

	character*6	reg_herald(0:5)

	data		reg_herald(0)	/'RCR*'/

	data		reg_herald(1)	/'RSR*'/

	data		reg_herald(2)	/'RDDB*'/

	data		reg_herald(3)	/'RDBC*'/

	data		reg_herald(4)	/'RDBA*'/

	data		reg_herald(5)	/'RDCRC*'/

c++
c	The format of the receiver driver buffer is as follows.
c
c	+-------------------------------------+
c	|                 rcr                 |
c	+-------------------------------------+
c	|                 rsr                 |
c	+-------------------------------------+
c	|              ucb$w_rddb             |
c	+-------------------------------------+
c	|                 rdbc                |
c	+-------------------------------------+
c	|                 rdba                |
c	+-------------------------------------+
c	|                 rdcrc               |
c	+-------------------------------------+
c	|              ucb$w_lr_dpn           |
c	+-------------------------------------+
c	|              ucb$l_lr_dpr           |
c	+-------------------------------------+
c	|              ucb$l_lr_fmpr          |
c	+-------------------------------------+
c	|              ucb$l_lr_pmpr          |
c	+-------------------------------------+
c	|              ucb$l_trigblk          |
c	+-------------------------------------+
c	|              ucb$l_devdepend        |
c	+-------------------------------------+
c	|              ucb$w_sts              |
c	+-------------------------------------+
c--




	call frctof (lun)

	call dhead1 (lun,'UBA PCL11 (RECEIVER)')

	call linchk (lun,2)

	write(lun,10) 'RCR',rcr
10	format('0',t8,a,t24,z8.4)

	call output (lun,rcr,v1rcr,0,0,7,'0')

	current_or_last_transmitter = lib$extzv(8,5,rcr)

	call linchk (lun,1)

	write(lun,15) 'CURRENT/LAST TRANSMITTER ID# ',
	1 current_or_last_transmitter,'.'
15	format(' ',t40,a,i<compress4 (current_or_last_transmitter)>,a)

	call output (lun,rcr,v2rcr,13,13,15,'0')

	call linchk (lun,1)

	write(lun,20) 'RSR',rsr
20	format(' ',t8,a,t24,z8.4)	

	response_bits = lib$extzv(0,2,rsr)

	call linchk (lun,1)

	write(lun,25) response_a(response_bits)
25	format(' ',t40,a<compressc (response_a(response_bits))>)

	response_bits = lib$extzv(2,2,rsr)

	call linchk (lun,1)

	write(lun,30) response_b(response_bits)
30	format(' ',t40,a<compressc (response_b(response_bits))>)

	call output (lun,rsr,v1rsr,4,4,15,'0')

	call linchk (lun,1)

	write(lun,35) 'UCB$W_RDDB',rddb
35	format(' ',t8,a,t24,z8.4)

	call linchk (lun,1)

	write(lun,40) 'RDBC',rdbc
40	format(' ',t8,a,t24,z8.4)

	call linchk (lun,1)

	write(lun,45) 'RDBA',rdba
45	format(' ',t8,a,t24,z8.4)

	call calc_map (lun,4,rcr,rdba)

	call linchk (lun,1)

	write(lun,50) 'RDCRC',rdcrc
50	format(' ',t8,a,t24,z8.4)

	if (emb$w_hd_entry .ne. 98) then

	if (ucb$l_lr_dpn .ne. 0) then

	call uba_datapath (lun,ucb$l_lr_dpn,ucb$l_lr_dpr)
	endif

	call calc_map2 (4,rcr,rdba,selected_map_register)

	call uba_mapping (lun,selected_map_register,ucb$l_lr_fmpr)

	if (
	1 lib$extzv (16,16,emb$l_dv_iosb1) .gt. 512
	1 .and.
	1 selected_map_register .ne. 0
	1 ) then

	call uba_mapping (lun,(selected_map_register-1),ucb$l_lr_pmpr)
	endif
	endif

	call linchk (lun,1)

	write(lun,55)
55	format(' ',:)

	call ucb$l_ownuic (lun,emb$l_dv_ownuic)

	call ucb$l_char (lun,emb$l_dv_char)

	call ucb$w_sts (lun,emb$w_dv_sts)

	call ucb$l_opcnt (lun,emb$l_dv_opcnt)

	call ucb$w_errcnt (lun,emb$w_dv_errcnt)

	call linchk (lun,1)

	write(lun,65) ucb$l_trigblk
65	format(' ',t8,'UCB$L_TRIGBLK',t24,z8.8)

	if (emb$w_hd_entry .ne. 98) then

	call linchk (lun,1)

	write(lun,55)

	call pcl11r_qio (lun,emb$w_dv_func)

	call irp$w_bcnt (lun,emb$w_dv_bcnt)

	call irp$w_boff (lun,emb$w_dv_boff)

	call irp$l_pid (lun,emb$l_dv_rqpid)

	call irp$q_iosb (lun,emb$l_dv_iosb1)
	endif

	return




	entry b_pcl11r (lun)



	call dhead1 (lun,'UBA PCL11 (RECEIVER)')

	call brief16 (lun,(6),rcr,reg_herald,emb$t_dv_name,emb$w_dv_unit)

	return



	entry c_pcl11r (lun)



	call cryptk (lun,16,(6),rcr,reg_herald,emb$t_dv_name,emb$w_dv_unit)

	return

	end



	subroutine pcl11r_qio (lun,emb$w_dv_func)



	include 'src$:qiocommon.for /nolist'



	byte		lun

	integer*2	emb$w_dv_func

	integer*4	qiocode(0:1,0:63)




	if (qiocode(0,0) .eq. 0) then

	qiocode(1,12) = %loc(io$_readpblk)

	qiocode(1,33) = %loc(io$_readlblk)

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
