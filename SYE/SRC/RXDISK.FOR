	SUBROUTINE RXDISK (LUN)
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
C	AUTHOR	BRIAN PORTER		CREATION DATE	9-APR-1979
C
C++
C	Functional description:
C
C	This module displays entries for the RX211 controller.  The format
C	of the error log buffer is as follows.
C
C	+----------------------------------+
C	|    control and status register   |
C	+----------------------------------+
C	|    device data buffer register   |
C	+----------------------------------+
C	|         data path number         |
C	+----------------------------------+
C	|        data path register        |
C	+----------------------------------+
C	|        final map register        |
C	+----------------------------------+
C	|       previous map register      |
C	+----------------------------------+
C	|       special error register     |
C	+----------------------------------+
C	|                                  |
C	+--  extended error information  --+
C	|                                  |
C	+----------------------------------+
C
C	Modified by:
C
C	v02-004	BP0004		Brian Porter,		23-NOV-1981
C		Minor edit.
C
C	v02-003	BP0003		Brian Porter,		22-OCT-1981
C		Added extended status processing.  Added 'device attention'
C		support.
C
C	v02-002	BP0002		Brian Porter,		23-JUL-1981
C		Added different uba handling.
C
C	v02-001	BP0001		Brian Porter,		1-JUL-1981
C		Added call to DHEAD and LOGGER.
C--
C**




	INCLUDE 'SRC$:MSGHDR.FOR /NOLIST'
	INCLUDE 'SRC$:DEVERR.FOR /NOLIST'




	byte		lun

	INTEGER*4	RX2_CS

	INTEGER*4	RX2_ES

	INTEGER*4	UBA_REGS(4)

	integer*4	special_error_register

	integer*4	extended_registers(2)

	EQUIVALENCE	(RX2_CS,EMB$L_DV_REGSAV(0))

	EQUIVALENCE	(RX2_ES,EMB$L_DV_REGSAV(1))

	EQUIVALENCE	(UBA_REGS,EMB$L_DV_REGSAV(2))

	equivalence	(special_error_register,emb$l_dv_regsav(6))

	equivalence	(extended_registers,emb$l_dv_regsav(7))

	integer*2	extended_status(4)

	equivalence	(extended_registers,extended_status)

	INTEGER*4	FIELD

	INTEGER*4	COMPRESSC

	INTEGER*4	COMPRESS4

	logical*1	done

	integer*4	definitive_error_code

	integer*4	word_count_register

	integer*4	current_track_address_drive0

	integer*4	current_track_address_drive1

	integer*4	target_track

	integer*4	target_sector

	integer*4	soft_status

	integer*4	bad_track

	integer*4	buffer(6)

	CHARACTER*5	REG_HERALD(0:5)

	CHARACTER*5	DRIVE_TYPE(0:1)

	CHARACTER*20	RX_HEADSELCT(0:1)

	CHARACTER*7	RX_DENSITY(0:1)

	CHARACTER*17	V1RX2_CS(5:7)

	character*20	v2rx2_cs(8:9,0:1)

	CHARACTER*6	V3RX2_CS(15:15)

	CHARACTER*20	V1RX2_ES(0:4)

	character*21	v2rx2_es(5:5,0:1)

	CHARACTER*13	V3RX2_ES(6:7)

	CHARACTER*20	V4RX2_ES(10:11)

	character*27	v1soft_status(0:0,0:1)

	character*26	v2soft_status(4:4,0:1)

	character*12	v3soft_status(5:5)

	character*26	v4soft_status(6:7,0:1)




	data	reg_herald(0)	/'CS*'/

	data	reg_herald(1)	/'ES*'/

	data	reg_herald(2)	/'ES 1*'/

	data	reg_herald(3)	/'ES 2*'/

	data	reg_herald(4)	/'ES 3*'/

	data	reg_herald(5)	/'ES 4*'/




	DATA	DRIVE_TYPE(0)	/'RX01*'/

	DATA	DRIVE_TYPE(1)	/'RX02*'/




	DATA	V1RX2_CS(5)	/'DONE*'/

	DATA	V1RX2_CS(6)	/'INTERRUPT ENABLE*'/

	DATA	V1RX2_CS(7)	/'TRANSFER REQUEST*'/




	data	v2rx2_cs(8,0)	/'SINGLE DENSITY*'/

	data	v2rx2_cs(8,1)	/'DOUBLE DENSITY*'/

	data	v2rx2_cs(9,0)	/'LOWER HEAD SELECTED*'/

	data	v2rx2_cs(9,1)	/'UPPER HEAD SELECTED*'/




	data	v3rx2_cs(15)	/'ERROR*'/




	DATA	V1RX2_ES(0)	/'CRC ERROR*'/

	DATA	V1RX2_ES(1)	/'SIDE 1 READY (RX03)*'/

	DATA	V1RX2_ES(2)	/'INITIALIZE DONE*'/

	DATA	V1RX2_ES(3)	/'DRIVE AC LO*'/

	DATA	V1RX2_ES(4)	/'DENSITY ERROR*'/




	data	v2rx2_es(5,0)	/'SINGLE DENSITY DRIVE*'/

	data	v2rx2_es(5,1)	/'DOUBLE DENSITY DRIVE*'/




	data	v3rx2_es(6)	/'DELETED DATA*'/

	data	v3rx2_es(7)	/'DRIVE READY*'/




	data	v4rx2_es(10)	/'WORD COUNT OVERFLOW*'/

	data	v4rx2_es(11)	/'NON-EXISTENT MEMORY*'/




	data	v1soft_status(0,0)	/'COMMAND WAS SINGLE DENSITY*'/

	data	v1soft_status(0,1)	/'COMMAND WAS DOUBLE DENSITY*'/




	data	v2soft_status(4,0)	/'DRIVE #0., SINGLE DENSITY*'/

	data	v2soft_status(4,1)	/'DRIVE #0., DOUBLE DENSITY*'/




	data	v3soft_status(5)	/'HEAD LOADED*'/




	data	v4soft_status(6,0)	/'DRIVE #1., SINGLE DENSITY*'/

	data	v4soft_status(6,1)	/'DRIVE #1., DOUBLE DENSITY*'/

	data	v4soft_status(7,0)	/'DRIVE #0. SELECTED*'/

	data	v4soft_status(7,1)	/'DRIVE #1. SELECTED*'/

	CALL FRCTOF (LUN)

	call dhead1 (lun,'UBA RX211')

	done = .false.

	if (lib$extzv (5,1,rx2_cs) .eq. 1) done = .true.

	CALL LINCHK (LUN,2)

	WRITE(LUN,20) RX2_CS
20	FORMAT('0',T8,'RX2CS',T24,Z8.4)

	if (done) then

	call linchk (lun,1)

	write(lun,25) lib$extzv(4,1,rx2_cs)
25	format(' ',t40,'DRIVE #',i1,'. SELECTED')
	endif

	CALL OUTPUT (LUN,RX2_CS,V1RX2_CS,5,5,7,'0')

	if (done) then

	call output (lun,rx2_cs,v2rx2_cs,8,8,9,'2')
	endif

	FIELD=LIB$EXTZV(11,1,RX2_CS)

	CALL LINCHK (LUN,1)

	WRITE(LUN,45) DRIVE_TYPE(FIELD)
45	FORMAT(' ',T40,'CONTROLLER DRIVE TYPE ',
	1 A<COMPRESSC (DRIVE_TYPE(FIELD))>)

	CALL OUTPUT (LUN,RX2_CS,V3RX2_CS,15,15,15,'0')

	CALL LINCHK (LUN,1)

	WRITE(LUN,55) RX2_ES
55	FORMAT(' ',T8,'RX2ES',T24,Z8.4)

	if (done) then

	if (lib$extzv(1,3,rx2_cs) .eq. 7) then

	call linchk (lun,1)

	definitive_error_code = lib$extzv(0,7,rx2_es)

	if (definitive_error_code .eq. '010'o) then

	write(lun,60)
60	format(' ',t40,'DRIVE #0., "HOME" FAILURE ON INIT')

	else if (definitive_error_code .eq. '020'o) then

	write(lun,65)
65	format(' ',t40,'DRIVE #1., "HOME" FAILURE ON INIT')

	else if (definitive_error_code .eq. '040'o) then

	write(lun,70)
70	format(' ',t40,'TRIED TO ACCESS TRACK >77.')

	else if (definitive_error_code .eq. '050'o) then

	write(lun,75)
75	format(' ',t40,'"HOME" BEFORE DESIRED TRACK')

	else if (definitive_error_code .eq. '070'o) then

	write(lun,80)
80	format(' ',t40,'2. REVOLUTIONS, SECTOR NOT FOUND')

	else if (definitive_error_code .eq. '110'o) then

	write(lun,85)
85	format(' ',t40,'>40 MICRO-SEC, NO "SEP" CLOCK')

	else if (definitive_error_code .eq. '120'o) then

	write(lun,90)
90	format(' ',t40,'A PREAMBLE NOT FOUND')

	else if (definitive_error_code .eq. '130'o) then

	write(lun,95)
95	format(' ',t40,'PREAMBLE BUT NO "ID"')

	else if (definitive_error_code .eq. '140'o) then

	write(lun,100)
100	format(' ',t40,'CRC ERROR, HEADER')

	else if (definitive_error_code .eq. '150'o) then

	write(lun,105)
105	format(' ',t40,'HEADER/DESIRED TRACK MISMATCH')

	else if (definitive_error_code .eq. '160'o) then

	write(lun,110)
110	format(' ',t40,'TOO MANY TRIES FOR "IDAM"')

	else if (definitive_error_code .eq. '200'o) then

	write(lun,115)
115	format(' ',t40,'CRC ERROR, DATA')

	else if (definitive_error_code .eq. '220'o) then

	write(lun,120)
120	format(' ',t40,'DIAGNOSTIC MODE TEST FAILURE')

	else if (definitive_error_code .eq. '240'o) then

	write(lun,125)
125	format(' ',t40,'DENSITY ERROR')

	else if (definitive_error_code .eq. '250'o) then

	write(lun,130)
130	format(' ',t40,'SET DENSITY, INCORRECT "KEYWORD"')
	endif
	else

	CALL OUTPUT (LUN,RX2_ES,V1RX2_ES,0,0,4,'0')

	call output (lun,rx2_es,v2rx2_es,5,5,5,'2')

	CALL OUTPUT (LUN,RX2_ES,V3RX2_ES,6,6,6,'0')
	endif

	call output (lun,rx2_es,v3rx2_es,6,7,7,'0')

	CALL LINCHK (LUN,1)

	write(lun,25) lib$extzv (8,1,rx2_es)

	CALL OUTPUT (LUN,RX2_ES,V3RX2_ES,10,10,11,'0')
	endif

	call linchk (lun,4)

	write(lun,135) (extended_status(i),i = 1,4)
135	format(' ',t8,'EXTENDED STATUS',4(t28,z4.4,:/))

	definitive_error_code = lib$extzv(0,8,extended_registers(1))

	call linchk (lun,1)

	if (definitive_error_code .eq. '010'o) then

	write(lun,60)

	else if (definitive_error_code .eq. '020'o) then

	write(lun,65)

	else if (definitive_error_code .eq. '040'o) then

	write(lun,70)

	else if (definitive_error_code .eq. '050'o) then

	write(lun,75)

	else if (definitive_error_code .eq. '070'o) then

	write(lun,80)

	else if (definitive_error_code .eq. '110'o) then

	write(lun,85)

	else if (definitive_error_code .eq. '120'o) then

	write(lun,90)

	else if (definitive_error_code .eq. '130'o) then

	write(lun,95)

	else if (definitive_error_code .eq. '140'o) then

	write(lun,100)

	else if (definitive_error_code .eq. '150'o) then

	write(lun,105)

	else if (definitive_error_code .eq. '160'o) then

	write(lun,110)

	else if (definitive_error_code .eq. '200'o) then

	write(lun,115)

	else if (definitive_error_code .eq. '220'o) then

	write(lun,120)

	else if (definitive_error_code .eq. '240'o) then

	write(lun,125)

	else if (definitive_error_code .eq. '250'o) then

	write(lun,130)
	endif

	word_count_register = lib$extzv(8,8,extended_registers(1))

	call linchk (lun,1)

	write(lun,137) 'WORD COUNT REGISTER ',word_count_register,' (HEX)'
137	format(' ',t40,a,z4.4,a)

	current_track_address_drive0 = lib$extzv(16,8,extended_registers(1))

	call linchk (lun,1)

	write(lun,140) current_track_address_drive0
140	format(' ',t40,'CURRENT TRACK #',
	1 i<compress4 (current_track_address_drive0)>,'., DRIVE #0.')

	current_track_address_drive1 = lib$extzv(24,8,extended_registers(1))

	call linchk (lun,1)

	write(lun,145) current_track_address_drive1
145	format(' ',t40,'CURRENT TRACK #',
	1 i<compress4 (current_track_address_drive1)>,'., DRIVE #1.')

	target_track = lib$extzv(0,8,extended_registers(2))

	call linchk (lun,1)

	write (lun,150) target_track
150	format(' ',t40,'TRACK #',i<compress4 (target_track)>,
	1 '., TARGET TRACK')

	target_sector = lib$extzv(8,8,extended_registers(2))

	call linchk (lun,1)

	write(lun,155) target_sector
155	format(' ',t40,'SECTOR #',i<compress4 (target_sector)>,
	1 '., TARGET SECTOR')

	soft_status = lib$extzv(16,8,extended_registers(2))

	call output (lun,soft_status,v1soft_status,0,0,0,'2')

	call output (lun,soft_status,v2soft_status,4,4,4,'2')

	call output (lun,soft_status,v3soft_status,5,5,5,'0')

	call output (lun,soft_status,v4soft_status,6,6,7,'2')

	if (definitive_error_code .eq. '150'o) then

	bad_track = lib$extzv(24,8,extended_registers(2))

	call linchk (lun,1)

	write(lun,160) bad_track
160	format(' ',t40,'SELECTED DRIVE AT TRACK #',
	1 i<compress4 (bad_track)>,'.')
	endif

	if (emb$w_hd_entry .ne. 98) then

	call uba_datapath (lun,uba_regs(1),uba_regs(2))

	call uba_mapping (lun,-1,uba_regs(3))

	if (lib$extzv (16,16,emb$l_dv_iosb1) .gt. 512) then

	call uba_mapping (lun,-1,uba_regs(4))
	endif

	call linchk (lun,1)

	write(lun,165)
165	format(' ',:)

	call ucb$b_ertcnt (lun,emb$b_dv_ertcnt)

	call ucb$b_ertmax (lun,emb$b_dv_ertmax)
	endif

	call ucb$l_ownuic (lun,emb$l_dv_ownuic)

	call ucb$l_char (lun,emb$l_dv_char)

	call ucb$w_sts (lun,emb$w_dv_sts)

	call ucb$l_opcnt (lun,emb$l_dv_opcnt)

	call ucb$w_errcnt (lun,emb$w_dv_errcnt)

	if (emb$w_hd_entry .ne. 98) then

	call ucb$l_media (lun,emb$l_dv_media)

	call linchk (lun,1)

	write(lun,165)

	call rxdisk_qio (lun,emb$w_dv_func)

	call irp$w_bcnt (lun,emb$w_dv_bcnt)

	call irp$w_boff (lun,emb$w_dv_boff)

	call irp$l_pid (lun,emb$l_dv_rqpid)

	call irp$q_iosb (lun,emb$l_dv_iosb1)
	endif

	RETURN




	ENTRY B_RXDISK (LUN)




	buffer(1) = rx2_cs

	buffer(2) = rx2_es

	buffer(3) = lib$extzv(0,16,extended_registers(1))

	buffer(4) = lib$extzv(16,16,extended_registers(1))

	buffer(5) = lib$extzv(0,16,extended_registers(2))

	buffer(6) = lib$extzv(16,16,extended_registers(2))

	call dhead1 (lun,'UBA RX211')

	CALL BRIEF16 (LUN,(6),buffer,REG_HERALD,EMB$T_DV_NAME,EMB$W_DV_UNIT)

	RETURN




	ENTRY C_RXDISK (LUN)




	buffer(1) = rx2_cs

	buffer(2) = rx2_es

	buffer(3) = lib$extzv(0,16,extended_registers(1))

	buffer(4) = lib$extzv(16,16,extended_registers(1))

	buffer(5) = lib$extzv(0,16,extended_registers(2))

	buffer(6) = lib$extzv(16,16,extended_registers(2))

	CALL CRYPTK (LUN,16,(6),buffer,REG_HERALD,EMB$T_DV_NAME,EMB$W_DV_UNIT)

	RETURN

	END



	subroutine rxdisk_qio (lun,emb$w_dv_func)



	include 'src$:qiocommon.for /nolist'



	byte		lun

	integer*2	emb$w_dv_func

	integer*4	qiocode(0:1,0:63)




	if (qiocode(0,0) .eq. 0) then

	qiocode(1,08) = %loc(io$_packack)

	qiocode(1,11) = %loc(io$_writepblk)

	qiocode(1,12) = %loc(io$_readpblk)

	qiocode(1,26) = %loc(io$_setchar)

	qiocode(1,27) = %loc(io$_sensechar)

	qiocode(1,30) = %loc(io$_format)

	qiocode(1,32) = %loc(io$_writelblk)

	qiocode(1,33) = %loc(io$_readlblk)

	qiocode(1,35) = %loc(io$_setmode)

	qiocode(1,39) = %loc(io$_sensemode)

	qiocode(1,48) = %loc(io$_writevblk)

	qiocode(1,49) = %loc(io$_readvblk)

	qiocode(1,50) = %loc(io$_access)

	qiocode(1,51) = %loc(io$_create)

	qiocode(1,52) = %loc(io$_deaccess)

	qiocode(1,53) = %loc(io$_delete)

	qiocode(1,54) = %loc(io$_modify)

	qiocode(1,56) = %loc(io$_acpcontrol)

	qiocode(1,57) = %loc(io$_mount)

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
