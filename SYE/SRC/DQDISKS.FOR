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

c	Author Brian Porter			Creation Date	20-JUL-1981

c++
c	Functional description:
c
c	This module is used to display error log entries logged for the
c	11/7zz IDC.  The format of the device specific portion of the record
c	is as follows.
c
c	+----------------------------------+
c	|               csr                |
c	+----------------------------------+
c	|               bar                |
c	+----------------------------------+
c	|               bcr                |
c	+----------------------------------+
c	|               dar                |
c	+----------------------------------+
c	|               mpr                |
c	+----------------------------------+
c	|               ecc1               |
c	+----------------------------------+
c	|               ecc2               |
c	+----------------------------------+
c	|        data path number          |
c	+----------------------------------+
c	|     data path reg (always 0)     |
c	+----------------------------------+
c	|           final uba map          |
c	+----------------------------------+
c	|        previous uba map          |
c	+----------------------------------+
c	|     vec$l_mapreg (from crb)      |
c	+----------------------------------+
c
c	Modified by:
c
c	v02-008	BP0008		Brian Porter,		23-JAN-1982
c		Corrected polarity of 'plug valid' for the r80.
c
c	v02-007	BP0007		Brian Porter,		23-NOV-1981
c		Minor edit.
c
c	v02-006	BP0006		Brian Porter,		04-NOV-1981
c		Corrected 'DAR' output error.  Added 'device attention'
c		support.
c
c	v02-005	BP0005		Brian Porter,		30-SEP-1981
c		Corrected random problems.
c
c	v02-004	BP0004		Brian Porter,		29-SEP-1981
c		Added 'DAR' decoding functionality.
c
c	v02-003	BP0003		Brian Porter,		14-SEP-1981
c		Corrected problem in attention logic.  Added CSR
c		functionality.
c
c	v02-002	BP0002		Brian Porter,		31-AUG-1981
c		Corrected call to calc_map.
c
c	v02-001	BP0001		Brian Porter,		24-AUG-1981
c		Changed record format to conform to other drivers.
c**
c--



	subroutine dqdisks (lun)



	include	'src$:msghdr.for /nolist'

	include 'src$:deverr.for /nolist'



	byte		lun

	integer*4	control_status_register

	integer*4	bus_address_register

	integer*4	byte_control_register

	integer*4	disk_address_register

	integer*4	multi_purpose_register

	integer*4	ecc_position_register

	integer*4	ecc_pattern_register

	integer*4	data_path_number

	integer*4	data_path_register

	integer*4	final_map_register

	integer*4	previous_map_register

	integer*4	vec$l_mapreg

	equivalence	(emb$l_dv_regsav(0),control_status_register)

	equivalence	(emb$l_dv_regsav(1),bus_address_register)

	equivalence	(emb$l_dv_regsav(2),byte_control_register)

	equivalence	(emb$l_dv_regsav(3),disk_address_register)

	equivalence	(emb$l_dv_regsav(4),multi_purpose_register)

	equivalence	(emb$l_dv_regsav(5),ecc_position_register)

	equivalence	(emb$l_dv_regsav(6),ecc_pattern_register)

	equivalence	(emb$l_dv_regsav(7),data_path_number)

	equivalence	(emb$l_dv_regsav(8),data_path_register)

	equivalence	(emb$l_dv_regsav(9),final_map_register)

	equivalence	(emb$l_dv_regsav(10),previous_map_register)

	equivalence	(emb$l_dv_regsav(11),vec$l_mapreg)

	character*12	v1csr(0:0)

	data		v1csr(0)	/'DRIVE READY*'/

	character*17	v2csr(6:7)

	data		v2csr(6)	/'INTERRUPT ENABLE*'/

	data		v2csr(7)	/'CONTROLLER READY*'/

	character*21	v3csr(10:10)

	data		v3csr(10)	/'OPERATION INCOMPLETE*'/

	character*20	v4csr(13:15)

	data		v4csr(13)	/'NON-EXISTENT MEMORY*'/

	data		v4csr(14)	/'DRIVE ERROR*'/

	data		v4csr(15)	/'COMPOSITE ERROR*'/

	character*22	v5csr(22:24)

	data		v5csr(22)	/'R80 SKIP SECTOR ERROR*'/

	data		v5csr(23)	/'R80 SKIP SECTOR ERROR*'/

	data		v5csr(24)	/'INTERRUPT REQUEST*'/

	character*30	v6csr(26:28)

	data		v6csr(26)	/'R80*'/

	data		v6csr(27)	/'AUTOMATIC SKIP SECTOR INHIBIT*'/

	data		v6csr(28)	/'TIMEOUT INHIBIT*'/

	character*11	v1rl02_mpr(3:5)

	data		v1rl02_mpr(3)	/'BRUSH HOME*'/

	data		v1rl02_mpr(4)	/'HEADS OUT*'/

	data		v1rl02_mpr(5)	/'COVER OPEN*'/

	character*19	v2rl02_mpr(8:15)

	data		v2rl02_mpr(8)	/'DRIVE SELECT ERROR*'/

	data		v2rl02_mpr(9)	/'VOLUME CHECK*'/

	data		v2rl02_mpr(10)	/'WRITE GATE ERROR*'/

	data		v2rl02_mpr(11)	/'SPINDLE ERROR*'/

	data		v2rl02_mpr(12)	/'SEEK TIMEOUT*'/

	data		v2rl02_mpr(13)	/'WRITE LOCK*'/

	data		v2rl02_mpr(14)	/'HEAD CURRENT ERROR*'/

	data		v2rl02_mpr(15)	/'WRITE DATE ERROR*'/

	character*14	v1r80_mpr(8:13)

	data		v1r80_mpr(8)	/'FAULT*'/

	data		v1r80_mpr(9)	/'PLUG VALID*'/

	data		v1r80_mpr(10)	/'SEEK ERROR*'/

	data		v1r80_mpr(11)	/'ON CYLINDER*'/

	data		v1r80_mpr(12)	/'DRIVE READY*'/

	data		v1r80_mpr(13)	/'WRITE PROTECT*'/

	integer*4	compress4

	integer*4	compressc

	integer*4	field

	character*27	idc_command(0:7)

	data		idc_command(0)	/'NO DRIVE OPERATION*'/

	data		idc_command(1)	/'WRITE CHECK DATA*'/

	data		idc_command(2)	/'GET STATUS*'/

	data		idc_command(3)	/'SEEK*'/

	data		idc_command(4)	/'READ HEADER*'/

	data		idc_command(5)	/'WRITE DATA*'/

	data		idc_command(6)	/'READ DATA*'/

	data		idc_command(7)	/'READ DATA W/O HEADER CHECK*'/

	integer*4	lib$extzv

	logical*1	diagnostic_mode

	integer*4	data_check_and_opi_bits

	integer*4	data_late_and_opi_bits

	integer*4	sector_count

	integer*4	ecc_status_bits

	integer*4	rl02_status_bits

	character*20	v1rl02_status_bits(0:7)

	data	v1rl02_status_bits(0)	/'LOAD STATE*'/

	data	v1rl02_status_bits(1)	/'SPIN UP*'/

	data	v1rl02_status_bits(2)	/'BRUSH CYCLE*'/

	data	v1rl02_status_bits(3)	/'LOAD HEADS*'/

	data	v1rl02_status_bits(4)	/'SEEK TRACK COUNTING*'/

	data	v1rl02_status_bits(5)	/'SEEK LINEAR MODE*'/

	data	v1rl02_status_bits(6)	/'UNLOAD HEADS*'/

	data	v1rl02_status_bits(7)	/'SPIN DOWN*'/

	character*8	reg_herald(0:6)

	data		reg_herald(0)	/'RB CSR*'/

	data		reg_herald(1)	/'RB BAR*'/

	data		reg_herald(2)	/'RB BCR*'/

	data		reg_herald(3)	/'RB DAR*'/

	data		reg_herald(4)	/'RB MPR*'/

	data		reg_herald(5)	/'RB ECC1*'/

	data		reg_herald(6)	/'RB ECC2*'/

	integer*4	device_function

	integer*4	device_type

	integer*4	sector

	integer*4	cylinder

	integer*4	tag

	integer*4	head

	character*11	v1dar(0:1)

	data		v1dar(0)	/'MARKER*'/

	data		v1dar(1)	/'GET STATUS*'/

	character*6	v2dar(3:3)

	data		v2dar(3)	/'RESET*'/

	character*8	v4dar(2:2,0:1)

	data		v4dar(2,0)	/'REVERSE*'/

	data		v4dar(2,1)	/'FORWARD*'/

	character*18	v6dar(4:4,0:1)

	data		v6dar(4,0)	/'SELECT LOWER HEAD*'/

	data		v6dar(4,1)	/'SELECT UPPER HEAD*'/

	character*15	v7dar(6:6)

	data		v7dar(6)	/'RETURN-TO-ZERO*'/





	call frctof (lun)

	call dhead1 (lun,'RB730')

	diagnostic_mode = .false.

	if (lib$extzv(25,1,control_status_register) .eq. 1)
	1 diagnostic_mode = .true.

	device_function = lib$extzv (1,3,control_status_register)

	device_type = lib$extzv (26,1,control_status_register)

	call linchk (lun,2)

	write(lun,5) 'RB CSR',control_status_register
5	format('0',t8,a,t24,z8.8)

	if (.not. diagnostic_mode) then

	call output (lun,control_status_register,v1csr,0,0,0,'0')

	call linchk (lun,1)

	if (lib$extzv(29,1,control_status_register) .eq. 1) then

	write(lun,10) 'R80 WRITE FORMAT FUNCTION'
10	format(' ',t40,a)
	else

	idc_function = lib$extzv(1,3,control_status_register)

	write(lun,15) idc_command(idc_function)
15	format(' ',t40,a<compressc (idc_command(idc_function))>)
	endif

	call output (lun,control_status_register,v2csr,6,6,7,'0')

	call linchk (lun,1)

	write(lun,20) 'DRIVE #',lib$extzv(8,2,control_status_register),
	1 '. SELECTED'
20	format(' ',t40,a,i1.1,a)

	call output (lun,control_status_register,v3csr,10,10,10,'0')	

	data_check_and_opi_bits = lib$extzv(10,2,control_status_register)

	if (
	1 data_check_and_opi_bits .eq. 2
	1 .or.
	1 data_check_and_opi_bits .eq. 3
	1 ) then

	call linchk (lun,1)
	endif

	if (data_check_and_opi_bits .eq. 2) then

	write(lun,25) 'DATA CHECK ERROR'
25	format(' ',t40,a)

	else if (data_check_and_opi_bits .eq. 3) then

	write(lun,25) 'HEADER CRC ERROR'
	endif

	data_late_and_opi_bits = lib$extzv(10,3,control_status_register)

	if (
	1 data_late_and_opi_bits .eq. 4
	1 .or.
	1 data_late_and_opi_bits .eq. 5
	1 ) then

	call linchk (lun,1)
	endif

	if (data_late_and_opi_bits .eq. 4) then

	write(lun,25) 'DATA LATE'

	else if (data_late_and_opi_bits .eq. 5) then

	write(lun,25) 'HEADER NOT FOUND'
	endif

	call output (lun,control_status_register,v4csr,13,13,15,'0')

	do 35,i = 16,19

	if (lib$extzv(i,1,control_status_register) .eq. 1) then

	call linchk (lun,1)

	write(lun,30) 'ATTENTION DRIVE #',i-16,'.'
30	format(' ',t40,a,i1.1,a)
	endif

35	continue

	if (lib$extzv (26,1,control_status_register) .eq. 1) then

	ecc_status_bits = lib$extzv (20,2,control_status_register)

	if (ecc_status_bits .ne. 0) then

	call linchk (lun,1)

	if (ecc_status_bits .eq. 1) then

	write(lun,40) 'DATA ERROR'
40	format(' ',t40,a)

	else if (ecc_status_bits .eq. 2) then

	write(lun,40) 'HARD ERROR'

	else if (ecc_status_bits .eq. 3) then

	write(lun,40) 'CORRECTABLE ERROR'
	endif
	endif
	endif

	call output (lun,control_status_register,v5csr,22,22,24,'0')

	if (lib$extzv (26,1,control_status_register) .eq. 1) then

	call output (lun,control_status_register,v6csr,26,26,28,'0')
	endif
	else

	call linchk (lun,1)

	write(lun,40) 'DIAGNOSTIC MODE'
	endif

	call linchk (lun,1)

	write(lun,45) 'RB BAR',bus_address_register
45	format(' ',t8,a,t24,z8.8)

	if (.not. diagnostic_mode) then

	if (
	1 device_function .eq. 1
	1 .or.
	1 device_function .eq. 5
	1 .or.
	1 device_function .eq. 6
	1 .or.
	1 device_function .eq. 7
	1 ) then

	call calc_map (lun,16,bus_address_register,bus_address_register)
	endif
	endif

	call linchk (lun,1)

	write(lun,45) 'RB BCR',byte_control_register

	call linchk (lun,1)

	write(lun,45) 'RB DAR',disk_address_register

	if (.not. diagnostic_mode) then

	if (
	1 device_function .eq. 1
	1 .or.
	1 device_function .eq. 5
	1 .or.
	1 device_function .eq. 6
	1 .or.
	1 device_function .eq. 7
	1 ) then

	if (device_type .eq. 0) then

	sector = lib$extzv (0,6,disk_address_register)

	cylinder = lib$extzv (7,9,disk_address_register)

	else if (device_type .eq. 1) then

	sector = lib$extzv (0,5,disk_address_register)

	cylinder = lib$extzv (9,10,disk_address_register)
	endif

	call linchk (lun,2)

	write(lun,46) sector,cylinder
46	format(' ',t40,'SECTOR #',i<compress4 (sector)>,'.',/,
	1 t40,'CYLINDER #',i<compress4 (cylinder)>,'.')

	else if (device_function .eq. 2) then

	if (device_type .eq. 0) then

	call output (lun,disk_address_register,v1dar,0,0,1,'0')

	call output (lun,disk_address_register,v2dar,3,3,3,'0')
	endif

	else if (device_function .eq. 3) then

	if (device_type .eq. 0) then

	call output (lun,disk_address_register,v1dar,0,0,1,'0')

	call output (lun,disk_address_register,v4dar,2,2,2,'2')

	call output (lun,disk_address_register,v2dar,3,3,3,'0')

	call output (lun,disk_address_register,v6dar,4,4,4,'2')

	cylinder = lib$extzv (7,9,disk_address_register)

	call linchk (lun,1)

	write(lun,47) cylinder
47	format(' ',t40,i<compress4 (cylinder)>,'. CYLINDER(S) TO MOVE')

	else if (device_type .eq. 1) then

	tag = lib$extzv (13,3,disk_address_register)

	call linchk (lun,1)

	if (tag .eq. 1) then

	cylinder = lib$extzv (0,10,disk_address_register)

	write(lun,48) 'CYLINDER #',cylinder
48	format(' ',t40,a,i<compress4 (cylinder)>,'. SELECTED')

	else if (tag .eq. 2) then

	head = lib$extzv (0,4,disk_address_register)

	write(lun,48) 'HEAD #',head

	else if (tag .eq. 4) then

	call output (lun,disk_address_register,v7dar,6,6,6,'0')
	endif
	endif
	endif
	endif

	call linchk (lun,1)

	write(lun,50) 'RB MPR',multi_purpose_register
50	format(' ',t8,a,t24,z8.8)

	if (.not. diagnostic_mode) then

	if (lib$extzv (26,1,control_status_register) .eq. 1) then

	sector_count = lib$extzv (0,5,multi_purpose_register)

	call linchk (lun,1)

	write(lun,55) 'SECTOR COUNT ',sector_count,'.'
55	format(' ',t40,a,i<compress4 (sector_count)>,a)

	call output (lun,multi_purpose_register,v1r80_mpr,8,8,13,'0')
	else

	rl02_status_bits = lib$extzv (0,3,multi_purpose_register)

	call linchk (lun,1)

	write(lun,60) v1rl02_status_bits(rl02_status_bits)
60	format(' ',t40,a<compressc (v1rl02_status_bits(rl02_status_bits))>)

	call output (lun,multi_purpose_register,v1rl02_mpr,3,3,5,'0')

	call linchk (lun,1)

	if (lib$extzv (6,1,multi_purpose_register) .eq. 1) then

	write(lun,65) 'LOWER HEAD SELECTED'
65	format(' ',t40,a)
	else

	write(lun,65) 'UPPER HEAD SELECTED'
	endif

	call output (lun,multi_purpose_register,v2rl02_mpr,8,8,15,'0')
	endif	
	endif

	call linchk (lun,2)

	write(lun,70) 'RB ECC1',ecc_position_register,
	1 'RB ECC2',ecc_pattern_register
70	format(' ',t8,a,t24,z8.8,/,t8,a,t24,z8.8)

	if (
	1 (device_function .eq. 1
	1 .or.
	1 device_function .eq. 5
	1 .or.
	1 device_function .eq. 6
	1 .or.
	1 device_function .eq. 7)
	1 .and.
	1 emb$w_hd_entry .ne. 98
	1 ) then

	call uba_datapath (lun,iand(data_path_number,'0000007f'x),
	1 data_path_register)

	call calc_map2 (16,bus_address_register,bus_address_register,field)

	call uba_mapping (lun,field,final_map_register)

	if (
	1 lib$extzv (16,16,emb$l_dv_iosb1) .gt. 512
	1 .and.
	1 field .ne. 0
	1 ) then

	call uba_mapping (lun,(field-1),previous_map_register)
	endif

	call vecmapreg (lun,vec$l_mapreg)
	endif

	call linchk (lun,1)

	write(lun,75)
75	format(' ',:)

	if (emb$w_hd_entry .ne. 98) then

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

	write(lun,75)

	call dqdisks_qio (lun,emb$w_dv_func)

	call irp$w_bcnt (lun,emb$w_dv_bcnt)

	call irp$w_boff (lun,emb$w_dv_boff)

	call irp$l_pid (lun,emb$l_dv_rqpid)

	call irp$q_iosb (lun,emb$l_dv_iosb1)
	endif

	return



	entry b_dqdisks (lun)



	call dhead1 (lun,'RB730')

	call brief32 (lun,(7),control_status_register,reg_herald,emb$t_dv_name,
	1 emb$w_dv_unit)

	return




	entry c_dqdisks (lun)



	call cryptk (lun,32,(7),control_status_register,reg_herald,
	1 emb$t_dv_name,emb$w_dv_unit)

	return

	end




	subroutine dqdisks_qio (lun,emb$w_dv_func)




	include 'src$:qiocommon.for /nolist'




	byte		lun

	integer*2	emb$w_dv_func

	integer*4	qiocode(0:1,0:63)




	if (qiocode(0,0) .eq. 0) then

	qiocode(1,00) = %loc(io$_nop)

	qiocode(1,02) = %loc(io$_seek)

	qiocode(1,03) = %loc(io$_recal)

	qiocode(1,04) = %loc(io$_drvclr)

	qiocode(1,08) = %loc(io$_packack)

	qiocode(1,10) = %loc(io$_writecheck)

	qiocode(1,11) = %loc(io$_writepblk)

	qiocode(1,12) = %loc(io$_readpblk)

	qiocode(1,14) = %loc(io$_readhead)

	qiocode(1,26) = %loc(io$_setchar)

	qiocode(1,27) = %loc(io$_sensechar)

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


