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
C
C	Author Brian Porter			Creation Date 30-DEC-1980
C
C	Modified by:
C
C	v03-001	BP0001		Brian Porter,		04-APR-1982
C		Corrected output conversion error.
C**



	subroutine memory (lun,option)




C++
C	Functional description:
C
C	This module extracts the varies arguments from the memory error
C	entry and calls memory_q.  The format of a memory error entry is as
C	follows.  The area occupied by the adaptor TR and registers is
C	repeated for the 'number of controllers' times.  The register area
C	size is dependent on the memory controller of the system being logged.
C	The error pc and error psl are manufactured by VMS and have no meaning,
C	therefore they are not printed in any of the reports.
C
C	+-----------------------------+
C	|                             |
C	+--                         --+
C	|        header space         |
C	+--                         --+
C	|                             |
C	+--                         --+
C	|                             |
C	+-----------------------------+
C	|    number of controllers    |
C	+-----------------------------+
C	| adprtor tr# (or equivalent) |
C	+-----------------------------+
C	|                             |
C	+--                         --+
C	|                             |
C	+--     memory registers    --+
C	|                             |
C	+--                         --+
C	|                             |
C	+-----------------------------+
C	|           error pc          |
C	+-----------------------------+
C	|           error psl         |
C	+-----------------------------+
C--




	include	'src$:msghdr.for /nolist'

	include	'src$:syecom.for /nolist'




	byte		lun

	character*1	option

	integer*4	buffer(0:120)

	equivalence	(emb(16),buffer)

	integer*4	controller_count

	equivalence	(buffer(0),controller_count)

	integer*4	compress4

	integer*4	error_array

	integer*4	error_bank

	integer*4	error_bit

	integer*4	page_count

	integer*4	array_code

	logical*1	l0011

	logical*1	l0016

	integer*4	decode_ecc


	if (
	1 lib$extzv(24,8,emb$l_hd_sid) .eq. 255
	1 .or.
	1 lib$extzv(24,8,emb$l_hd_sid) .eq. 1
	1 ) then

	j = 0

	do 20,i = 1,controller_count

	if (option .ne. 'R'
	1 .and.
	1 option .ne. 'C'
	1 .and.
	1 j .eq. 0) then

	call header (lun)

	if (emb$w_hd_entry .eq. 5) then

	call logger (lun,'SBI ALERT')

	else if (emb$w_hd_entry .eq. 8) then

	call logger (lun,'MEMORY ERROR*')
	else

	call logger (lun,'MEMORY ERROR')
	endif
	endif

	if (lib$extzv(5,3,buffer(2 + j)) .eq. 0) then

	if (emb$w_hd_entry .ne. '05'x
	1 .and.
	1 option .ne. 'C') then

	if (lib$extzv(28,1,buffer(4 + j)) .eq. 1) then

	if (lib$extzv(4,1,buffer(2 + j)) .eq. 0) then

	call memory_q (emb$l_hd_sid,buffer(1 + j),
	1 lib$extzv(24,4,buffer(4 + j)),lib$extzv(21,1,buffer(4+j)),
	1 decode_ecc(lib$extzv(0,8,buffer(4 + j)),buffer(2 + j)))

	else if (lib$extzv(4,1,buffer(2 + j)) .eq. 1) then

	call memory_q (emb$l_hd_sid,buffer(1 + j),
	1 lib$extzv(24,4,buffer(4 + j)),lib$extzv(23,1,buffer(4+j)),
	1 decode_ecc(lib$extzv(0,8,buffer(4 + j)),buffer(2 + j)))
	endif
	endif
	endif

	if (option .eq. 'S') then

	call linchk (lun,2)

	write(lun,10) buffer(1 + j)
10	format('0','CONTROLLER AT TR #',i<compress4 (buffer(1 + j))>,'.')
	endif

	if (option.eq. 'S') then

	call ms780c (lun,buffer(2 + j))

	else if (option .eq. 'B') then

	call b_ms780c (lun,buffer(2 + j),buffer(1 + j))

	else if (option .eq. 'C') then

	call c_ms780c (lun,buffer(2 + j),buffer(1 + j))
	endif

	j = j + 4

	else if (lib$extzv(5,3,buffer(2 + j)) .eq. 3) then

	if (emb$w_hd_entry .ne. '05'x
	1 .and.
	1 option .ne. 'C') then

	if (lib$extzv(28,1,buffer(4 + j)) .eq. 1) then

	call memory_q (emb$l_hd_sid,buffer(1 + j),
	1 lib$extzv(24,3,buffer(4 + j)),lib$extzv(22,2,buffer(4+j)),
	1 decode_ecc(lib$extzv(0,7,buffer(4 + j)),buffer(2 + j)))

	else if (lib$extzv(28,1,buffer(5 + j)) .eq. 1) then

	call memory_q (emb$l_hd_sid,buffer(1 + j),
	1 lib$extzv(24,3,buffer(5 + j)),lib$extzv(22,2,buffer(5+j)),
	1 decode_ecc(lib$extzv(0,7,buffer(5 + j)),buffer(2 + j)))

	else if (
	1 lib$extzv(18,2,buffer(2 + j)) .ne. 0
	1 .or.
	1 lib$extzv(7,1,buffer(3 + j)) .eq. 1
	1 .or.
	1 lib$extzv(7,1,buffer(4 + j)) .eq. 1
	1 .or.
	1 lib$extzv(7,1,buffer(5 + j)) .eq. 1
	1 ) then

	call memory_q (emb$l_hd_sid,buffer(1 + j),-1,-1,-1)
	endif
	endif

	if (option .eq. 'S') then

	call linchk (lun,2)

	write(lun,10) buffer(1 + j)
	endif

	if (option.eq. 'S') then

	call ms780e (lun,buffer(2 + j))

	else if (option .eq. 'B') then

	call b_ms780e (lun,buffer(2 + j),buffer(1 + j))

	else if (option .eq. 'C') then

	call c_ms780e (lun,buffer(2 + j),buffer(1 + j))
	endif

	j = j + 5

	else if (lib$extzv(5,3,buffer(2 + j)) .eq. 2) then

	if (emb$w_hd_entry .ne. '05'x
	1 .and.
	1 option .ne. 'C') then

	if (lib$extzv (28,1,buffer(6 + j)) .eq. 1) then

	call memory_q (emb$l_hd_sid,buffer(1 + j),
	1 lib$extzv(24,4,buffer(6 + j)),lib$extzv(23,1,buffer(6+j)),
	1 decode_ecc(lib$extzv(0,8,buffer(6 + j)),buffer(2 + j)))

	else if (
	1 lib$extzv(26,6,buffer(3 + j)) .ne. 0
	1 .or.
	1 lib$extzv(14,2,buffer(4 + j)) .ne. 0
	1 .or.
	1 lib$extzv(28,1,buffer(4 + j)) .eq. 1
	1 .or.
	1 lib$extzv(30,2,buffer(4 + j)) .ne. 0
	1 .or.
	1 lib$extzv(31,1,buffer(6 + j)) .eq. 1
	1 ) then
	
	call memory_q (emb$l_hd_sid,buffer(1 + j),-1,-1,-1)
	endif
	endif

	if (option .eq. 'S') then

	call linchk (lun,2)

	write(lun,10) buffer(1 + j)
	endif

	if (option .eq. 'S') then

	call ma780 (lun,buffer(2 + j))

	else if (option .eq. 'B') then

	call b_ma780 (lun,buffer(2 + j),buffer(1 + j))

	else if (option .eq. 'C') then

	call c_ma780 (lun,buffer(2 + j),buffer(1 + j))
	endif

	j = j + 9
	endif

20	continue

	else if (lib$extzv(24,8,emb$l_hd_sid) .eq. 2) then

	if (option .ne. 'C') then

	error_array = lib$extzv(9,15,buffer(2))

	l0011 = .false.

	l0016 = .false.

	if (jiand(buffer(4),'01000000'x) .ne. 0) then

	l0016 = .true.
	else

	l0011 = .true.
	endif

	do 30,i = 0,15,2

	array_code = lib$extzv(i,2,buffer(4))

	if (l0016) then

	if (array_code .eq. 3) then

	error_array = error_array - 512

	if (lib$extzv(17,1,buffer(2)) .eq. 0) then

	error_bank = 0
	else

	error_bank = 1
	endif

	else if (array_code .eq. 2) then

	error_array = error_array - 2048

	if (lib$extzv(19,1,buffer(2)) .eq. 0) then

	error_bank = 0
	else

	error_bank = 1
	endif
	endif

	else if (l0011) then

	if (array_code .eq. 1) then

	error_array = error_array - 256

	error_bank = 0

	else if (array_code .eq. 3) then

	error_array = error_array - 512

	if (lib$extzv(17,1,buffer(2)) .eq. 0) then

	error_bank = 0
	else

	error_bank = 1
	endif
	endif
	endif

	if (error_array .le. 0) then

	error_array = i/2

	goto 40
	endif

30	continue

40	if (lib$extzv(29,1,buffer(2)) .eq. 1) then

	call memory_q (emb$l_hd_sid,lib$extzv(0,3,buffer(1)),
	1 error_array,error_bank,decode_ecc(lib$extzv(0,7,buffer(2))))

	else if (lib$extzv(31,1,buffer(2)) .eq. 1) then

	call memory_q (emb$l_hd_sid,lib$extzv(0,3,buffer(1)),
	1 error_array,error_bank,-1)
	endif
	endif

	if (option .ne. 'C'
	1 .and.
	1 option .ne. 'R') then

	call header (lun)

	call logger (lun,'MEMORY ERROR')
	endif

	if (option .eq. 'S') then

	call linchk (lun,2)

	write(lun,50) lib$extzv(0,3,buffer(1))
50	format('0','CONTROLLER AT SLOT INDEX #',
	1 i<compress4 (lib$extzv(0,3,buffer(1)))>,'.')
	endif

	if (option.eq. 'S') then

	call ms750 (lun,buffer(2))

	else if (option .eq. 'B') then

	call b_ms750 (lun,buffer(2),lib$extzv(0,3,buffer(1)))

	else if (option .eq. 'C') then

	call c_ms750 (lun,buffer(2),lib$extzv(0,3,buffer(1)))
	endif

	else if (lib$extzv(24,8,emb$l_hd_sid) .eq. 3) then

	if (option .ne. 'C') then

	error_bit = decode_ecc (lib$extzv(0,7,buffer(0)))

	error_array = lib$extzv(9,15,buffer(0))

	if (lib$extzv(24,1,buffer(2)) .eq. 1) then

	page_count = 1024
	else

	page_count = 256
	endif

	do 60,i = 0,15

	if (lib$extzv(i,1,buffer(2)) .eq. 1) then

	error_array = error_array - page_count

	if (error_array .le. 0) then

	error_array = i/2

	goto 65
	endif
	endif

60	continue

	if (page_count .eq. 1024) then

	error_bank = lib$extzv (19,1,buffer(0))
	else

	error_bank = lib$extzv (17,1,buffer(0))
	endif

65	continue

	if (error_bit .eq. -1) then

	call memory_q (emb$l_hd_sid,0,
	1 error_array,error_bank,-1)
	else

	call memory_q (emb$l_hd_sid,0,
	1 error_array,error_bank,error_bit)
	endif
	endif

	if (option .ne. 'C'
	1 .and.
	1 option .ne. 'R') then

	call header (lun)

	call logger (lun,'MEMORY ERROR')
	endif

	if (option .eq. 'S') then

	call ms7zz (lun,buffer)

	else if (option .eq. 'B') then

	call b_ms7zz (lun,buffer)

	else if (option .eq. 'C') then

	call c_ms7zz (lun,buffer)
	endif
	endif

	return

	end




	subroutine ma780 (lun,memory_registers)




c++
c	This routine displays the ma780 memory registers.
c	The format of the multi-port memory sub packet is as follows.
c
c	+---------------------------------+
c	|   port configuration register   |
c	+---------------------------------+
c	| port interface control register |
c	+---------------------------------+
c	| port controller status register |
c	+---------------------------------+
c	| port invalidation control reg   |
c	+---------------------------------+
c	|      array error register       |
c	+---------------------------------+
c	| configuration status register 0 |
c	+---------------------------------+
c	| configuration status register 1 |
c	+---------------------------------+
c	|   maintenance control register  |
c	+---------------------------------+
c--




	byte		lun

	integer*4	memory_registers

	integer*4	buffer(8)

	integer*4	port_configuration_register

	integer*4	port_interface_control_register

	integer*4	port_controller_status_register

	integer*4	port_invalidation_control_reg

	integer*4	array_error_register

	integer*4	configuration_status_register0

	integer*4	configuration_status_register1

	integer*4	maintenance_control_register

	equivalence	(buffer(1),port_configuration_register)

	equivalence	(buffer(2),port_interface_control_register)

	equivalence	(buffer(3),port_controller_status_register)

	equivalence	(buffer(4),port_invalidation_control_reg)

	equivalence	(buffer(5),array_error_register)

	equivalence	(buffer(6),configuration_status_register0)

	equivalence	(buffer(7),configuration_status_register1)

	equivalence	(buffer(8),maintenance_control_register)

	integer*4	ram_count

	integer*4	array_count

	integer*4	starting_address

	integer*4	error_syndrome

	integer*4	error_bit

	integer*4	error_array

	integer*4	array_init_status_bits

	integer*4	port_type_bits

	equivalence	(ram_count,array_count,starting_address,error_syndrome,
	1 error_bit,error_array,array_init_status_bits,port_type_bits)

	integer*4	compress4

	integer*4	compressc

	integer*4	lib$extzv

	integer*4	decode_ecc

	integer*4	adapter_tr

	logical*1	diagnostic_mode

	character*32	v1register2(0:1)

	data		v1register2(0)	/'MASTER INTERRUPT ENABLE*'/

	data		v1register2(1)	/'PORT INTERFACE INTERRUPT ENABLE*'/

	character*30	v3register2(23:31)

	data		v3register2(23)	/'MARK INTERLOCK IN PROGRESS*'/

	data		v3register2(24)	/'MARK TIMEOUT*'/

	data		v3register2(25)	/'MARK REQUESTER*'/

	data		v3register2(26)	/'OUTPUT BUFFER OVERFLOW*'/

	data		v3register2(27)	/'INVALIDATION ACK NOT RECEIVED*'/

	data		v3register2(28)	/'OUTPUT BUFFER PARITY ERROR*'/

	data		v3register2(29)	/'INVALIDATE LOST ON BDI*'/

	data		v3register2(30)	/'BDI PARITY FAULT ON OUTPUT*'/

	data		v3register2(31)	/'BDI PARITY FAULT ON INPUT*'/

	character*23	v1register3(1)

	data		v1register3(1)	/'ERROR INTERRUPT ENABLE*'/

	character*25	v2register3(6:8)

	data		v2register3(6)	/'SELF INVALIDATE ENABLE*'/

	data		v2register3(7)	/'INVALIDATION DISABLE*'/

	data		v2register3(8)	/'INHIBIT ADMI ARBITRATION*'/

	character*25	v3register3(10:15)

	data		v3register3(10)	/'INTERLOCK GRANT ACCEPTED*'/

	data		v3register3(11)	/'INTERLOCK FLIP-FLOP*'/

	data		v3register3(12)	/'ARRAY INIT IN PROGRESS*'/

c
c	Cell 13 of this array unused
c

	data		v3register3(14)	/'INVALIDATE DATA LOST*'/

	data		v3register3(15)	/'INTERLOCK TIMEOUT*'/

	character*30	v4register3(21)

	data		v4register3(21)	/'NO C/A ON ADMI WHEN REQUESTED*'/

	character*23	v5register3(22:25,0:1)

	data		v5register3(22,0)/'32-BIT OPERATION*'/

	data		v5register3(22,1)/'64-BIT OPERATION*'/

	data		v5register3(23,0)/'I/O SELECT*'/

	data		v5register3(23,1)/'ARRAY SELECT*'/

	data		v5register3(24,0)/'REQUESTER HAS NO CACHE*'/

	data		v5register3(24,1)/'REQUESTER HAS CACHE*'/

	data		v5register3(25,0)/'ADMI READ*'/

	data		v5register3(25,1)/'ADMI WRITE*'/

	character*32	v6register3(26:31)

	data		v6register3(26)	/'ADMI PORT ID0*'/

	data		v6register3(27)	/'ADMI PORT ID1*'/

	data		v6register3(28)	/'MULTIPLE ADMI GRANT*'/

	data		v6register3(29)	/'PORT TRANSMITTING DURING FAULT*'/

	data		v6register3(30)	/'ADMI MULTIPLE TRANSMITTER FAULT*'/

	data		v6register3(31)	/'ADMI COMMAND ABORT*'/

	character*14	v1register4(31:31)

	data		v1register4(31)	/'CACHED FORCED*'/

	character*18	v1register5(28:31)

	data		v1register5(28)	/'ERROR LOG REQUEST*'/

	data		v1register5(29)	/'HIGH ERROR RATE*'/

	data		v1register5(30)	/'CRD TAG*'/

	data		v1register5(31)	/'MAP PARITY ERROR*'/

	character*27	v1register6(0:1)

	data		v1register6(0)	/'NONCONTIGUOUS ARRAY ERROR*'/

	data		v1register6(1)	/'4K CHIP ARRAY ERROR*'/

	character*28	v1register7(10:11)

	data		v1register7(10)	/'MULTIPLE INTERLOCK ACCEPTED*'/

	data		v1register7(11)	/'INVALIDATION MAP PRESENT*'/

	character*27	array_init_status

	character*22	port_type

	character*8	register_herald(8)

	data		register_herald(1)/'PRTCFNG*'/

	data		register_herald(2)/'PRTCR*'/

	data		register_herald(3)/'PCSR*'/

	data		register_herald(4)/'IVDTCR*'/

	data		register_herald(5)/'AER*'/

	data		register_herald(6)/'CSR0*'/

	data		register_herald(7)/'CSR1*'/

	data		register_herald(8)/'MAT*'/



	call movc3 (%val(32),memory_registers,buffer)

	diagnostic_mode = .false.

	if (lib$extzv(4,3,port_interface_control_register) .ne. 0
	1 .or.
	1 lib$extzv(4,2,port_controller_status_register) .ne. 0
	1 .or.
	1 lib$extzv(13,1,port_controller_status_register) .ne. 0
	1 .or.
	1 lib$extzv(8,2,configuration_status_register1) .ne. 0
	1 .or.
	1 lib$extzv(8,6,maintenance_control_register) .ne. 0) then

	diagnostic_mode = .true.

	call linchk (lun,1)

	write(lun,5) port_configuration_register
5	format('0',t8,'PRTCFNG',t24,z8.8)
	endif

	call ma780_rega (lun,port_configuration_register)

	call linchk (lun,1)

	write(lun,10) port_interface_control_register
10	format(' ',t8,'PRTCR',t24,z8.8)

	if (.not. diagnostic_mode) then

	call output (lun,port_interface_control_register,v1register2,0,0,1,'0')

	call linchk (lun,1)

	ram_count =  lib$extzv(16,4,port_interface_control_register)

	write(lun,15) ram_count
15	format(' ',t40,'RAM COUNT ',i<compress4 (ram_count)>,'.')

	call output (lun,port_interface_control_register,v3register2,23,23,31,
	1 '0')
	endif

	if (lib$extzv(4,3,port_interface_control_register) .ne. 0) then

	call linchk (lun,1)

	write(lun,17)
17	format(' ',t40,'DIAGNOSTIC MODE')
	endif

	call linchk (lun,1)

	write(lun,20) port_controller_status_register
20	format(' ',t8,'PCSR',t24,z8.8)

	if (lib$extzv(13,1,port_controller_status_register) .ne. 0
	1 .or.
	1 lib$extzv (4,2,port_controller_status_register) .ne. 0) then

	call linchk (lun,1)

	write(lun,17)
	endif

	if (.not. diagnostic_mode) then

	call output (lun,port_controller_status_register,v1register3,1,1,1,'0')

	call output (lun,port_controller_status_register,v2register3,6,6,8,'0')

	call output (lun,port_controller_status_register,v3register3,10,10,12,
	1 '0')

	call output (lun,port_controller_status_register,v3register3,10,14,15,
	1 '0')

	if (jiand(port_controller_status_register,'d0000000'x) .ne. 0) then

	call output (lun,port_controller_status_register,v4register3,21,21,21,
	1 '0')

	call output (lun,port_controller_status_register,v5register3,22,22,25,
	1 '2')

	call output (lun,port_controller_status_register,v6register3,26,26,31,
	1 '0')
	endif
	endif

	call linchk (lun,1)

	write(lun,30) port_invalidation_control_reg
30	format(' ',t8,'IVDTCR',t24,z8.8)

	if (.not. diagnostic_mode) then

	do 50,i = 0,15

	if (lib$extzv(i,1,port_invalidation_control_reg) .eq. 1) then

	call linchk (lun,1)

	write(lun,40) i
40	format(' ',t40,'INVALIDATE CACHE DEVICE ID = ',i<compress4 (i)>,'.')
	endif

50	continue

	call linchk (lun,1)

	array_count = lib$extzv(16,3,port_invalidation_control_reg)

	if (array_count .eq. 0
	1 .and.
	1 lib$extzv(0,2,configuration_status_register0) .ne. 0) then

	write(lun,60) 'INVALID ARRAY CONFIGURATION'
60	format(' ',t40,a)
	else

	write(lun,70) array_count + 1
70	format(' ',t40,i<compress4 (array_count + 1)>,
	1 '. ARRAY BOARD(S) PRESENT')
	endif

	starting_address = lib$extzv(20,11,port_invalidation_control_reg)*256

	call linchk (lun,1)

	write(lun,80) starting_address
80	format(' ',t40,'MEMORY BASE ADDRESS = ',
	1 i<compress4 (starting_address)>,'.K')

	call output (lun,port_invalidation_control_reg,v1register4,31,31,31,
	1 '0')
	endif

	call linchk (lun,1)

	write(lun,90) array_error_register
90	format(' ',t8,'AER',t24,z8.8)

	if (.not. diagnostic_mode) then

	if (lib$extzv (28,1,array_error_register) .eq. 1) then

	error_syndrome = lib$extzv(0,8,array_error_register)

	call linchk (lun,1)

	write(lun,100) error_syndrome
100	format(' ',t40,'ERROR SYNDROME = ',z2.2)

	error_bit = decode_ecc (error_syndrome,port_configuration_register)

	call linchk (lun,1)

	if (error_bit .eq. -1) then

	write(lun,110) 'RDS ERROR'
110	format(' ',t40,a)
	else

	write(lun,120) 'CRD ERROR, CORRECTED BIT #',error_bit,'.'
120	format(' ',t40,a,i<compress4 (error_bit)>,a)
	endif

	error_array = lib$extzv (24,4,array_error_register)

	call linchk (lun,1)

	write(lun,140) error_array
140	format(' ',t40,'ARRAY #',i<compress4 (error_array)>,'. IN ERROR')
	endif

	call output (lun,array_error_register,v1register5,28,28,31,'0')
	endif

	call linchk (lun,1)

	write(lun,170) configuration_status_register0
170	format(' ',t8,'CSR0',t24,z8.8)

	if (.not. diagnostic_mode) then

	call output (lun,configuration_status_register0,v1register6,0,0,1,'0')

	array_init_status_bits = lib$extzv(2,2,configuration_status_register0)

	if (array_init_status_bits .eq. 0) then

	array_init_status = 'INITIALIZATION IN PROGRESS*'

	else if (array_init_status_bits .eq. 2) then

	array_init_status = 'MEMORY CONTAINS VALID DATA*'

	else if (array_init_status_bits .eq. 3) then

	array_init_status = 'INITIALIZATION COMPLETE*'
	endif

	call linchk (lun,1)

	write(lun,180) array_init_status(:(lib$locc('*',array_init_status)-1))
180	format(' ',t40,a)

	do 200,i = 4,7

	if (lib$extzv(i,1,configuration_status_register0) .eq. 1) then

	call linchk (lun,1)

	write(lun,190) 'PORT #',i - 4,'. POWERED DOWN'
190	format(' ',t40,a,i<compress4 (i - 4)>,a)
	endif

200	continue

	do 220,i = 8,11

	if (lib$extzv(i,1,configuration_status_register0) .eq. 1) then

	call linchk (lun,1)

	write(lun,210) 'ERROR INTERRUPT FROM PORT #',i - 8,'.'
210	format(' ',t40,a,i<compress4 (i - 8)>,a)
	endif

220	continue

	do 240,i = 12,15

	if (lib$extzv(i,1,configuration_status_register0) .eq. 1) then

	call linchk (lun,1)

	write(lun,230) 'PORT #',i - 12,'. OFFLINE'
230	format(' ',t40,a,i<compress4 (i - 12)>,a)
	endif

240	continue
	endif

	call linchk (lun,1)

	write(lun,250) configuration_status_register1
250	format(' ',t8,'CSR1',t24,z8.8)

	if (.not. diagnostic_mode) then

	do 270,i = 0,6,2

	port_type_bits = lib$extzv(i,2,configuration_status_register1)

	if (port_type_bits .eq. 0) then

	port_type = '. NOT PRESENT*'

	else if (port_type_bits .eq. 2) then

	port_type = '. CONNECTED TO AN SBI*'
	endif

	if (port_type_bits .ne. 1
	1 .or.
	1 port_type_bits .ne. 3) then

	call linchk (lun,1)

	write(lun,260) i/2,port_type
260	format(' ',t40,'PORT #',i<compress4 (i/2)>,a<compressc (port_type)>)
	endif

270	continue

	call output (lun,configuration_status_register1,v1register7,10,10,11,
	1 '0')

	do 290,i = 12,15

	if (lib$extzv(i,1,configuration_status_register1) .eq. 1) then

	call linchk (lun,1)

	write(lun,280) 'PORT #',i - 12,'. INVALIDATION ACK RECEIVED'
280	format(' ',t40,a,i<compress4 (i - 12)>,a)
	endif

290	continue
	endif

	if (lib$extzv(8,2,configuration_status_register1) .ne. 0) then

	call linchk (lun,1)

	write(lun,17)
	endif

	call linchk (lun,1)

	write(lun,295) maintenance_control_register
295	format(' ',t8,'MAT',t24,z8.8)

	if (lib$extzv(8,6,maintenance_control_register) .ne. 0) then

	call linchk (lun,1)

	write(lun,17)
	endif

	return




	entry b_ma780 (lun,memory_registers,adapter_tr)



	call movc3 (%val(32),memory_registers,buffer)

	call brief32 (lun,(8),port_configuration_register,register_herald,
	1 'TR ',adapter_tr)

	return



	entry c_ma780 (lun,memory_registers,adapter_tr)



	call movc3 (%val(32),memory_registers,buffer)

	call cryptk (lun,32,(8),port_configuration_register,register_herald,
	1 'TR ',adapter_tr)

	return

	end




	subroutine ms780c (lun,memory_registers)



c++
c	This routine displays the error log packet for the ms780c
c	memory controller.  The format of the packet is as follows.
c
c	+-----------------------------------+
c	|         memory register A         |
c	+-----------------------------------+
c	|         memory register B         |
c	+-----------------------------------+
c	|         memory register C         |
c	+-----------------------------------+
c--




	byte		lun

	integer*4	memory_registers

	integer*4	adapter_tr

	integer*4	buffer(3)

	integer*4	memory_register_a

	integer*4	memory_register_b

	integer*4	memory_register_c

	equivalence	(buffer(1),memory_register_a)

	equivalence	(buffer(2),memory_register_b)

	equivalence	(buffer(3),memory_register_c)

	character*27	memory_init_status(0:3)

	data		memory_init_status(0)	/'INITIALIZATION IN PROGRESS*'/

	data		memory_init_status(1)	/'MEMORY CONTAINS VALID DATA*'/

	data		memory_init_status(2)	/'INVALID STATE*'/

	data		memory_init_status(3)	/'INITIALIZATION COMPLETE*'/

	character*27	v2memory_registerb(14:14)

	data		v2memory_registerb(14)	/'START ADDRESS WRITE ENABLE*'/

	character*18	v1memory_registerc(28:30)

	data		v1memory_registerc(28)	/'ERROR LOG REQUEST*'/

	data		v1memory_registerc(29)	/'HIGH ERROR RATE*'/

	data		v1memory_registerc(30)	/'INHIBIT CRD TAG*'/

	integer*4	lib$extzv

	integer*4	decode_ecc

	integer*4	compress4

	integer*4	compressc

	integer*4	init_status

	integer*4	starting_address

	integer*4	error_syndrome

	integer*4	error_bit

	integer*4	error_page_address

	integer*4	error_array

	equivalence	(init_status,starting_address,error_syndrome,error_bit,
	1 error_page_address,error_array)

	logical*1	diagnostic_mode

	character*5	register_herald(3)

	data		register_herald(1)/'CSRA*'/

	data		register_herald(2)/'CSRB*'/

	data		register_herald(3)/'CSRC*'/




	call movc3 (%val(12),memory_registers,buffer)

	diagnostic_mode = .false.

	if (lib$extzv (8,2,memory_register_b) .ne. 0) diagnostic_mode = .true.

	if (.not. diagnostic_mode) then

	call ms780c_rega (lun,memory_register_a)
	else

	call linchk (lun,1)

	write(lun,5) memory_register_a
5	format(' ',t8,'CSRA',t24,z8.8)
	endif

	call linchk (lun,1)

	write(lun,10) 'CSRB',memory_register_b
10	format(' ',t8,a,t24,z8.8)

	if (diagnostic_mode) then

	call linchk (lun,1)

	write(lun,12) 'DIAGNOSTIC MODE'
12	format(' ',t40,a)
	endif

	if (.not. diagnostic_mode) then

	init_status = lib$extzv(12,2,memory_register_b)

	call linchk (lun,1)

	write(lun,30) memory_init_status(init_status)
30	format(' ',t40,a<compressc (memory_init_status(init_status))>)

	call output (lun,memory_register_b,v2memory_registerb,14,14,14,'0')

	starting_address = lib$extzv(15,13,memory_register_b)*64

	call linchk (lun,1)

	write(lun,35) starting_address
35	format(' ',t40,'MEMORY BASE ADDRESS = ',
	1 i<compress4 (starting_address)>,'.K')

	call linchk (lun,2)

	write(lun,40) (lib$extzv(i,2,memory_register_b),i = 28,30,2)
40	format(' ',t40,'FILE INPUT POINTER ',
	1 i<compress4 (lib$extzv(i,2,memory_register_b))>,'.',/,
	1 t40,'FILE OUTPUT POINTER ',
	1 i<compress4 (lib$extzv(i,2,memory_register_b))>,'.')
	endif

	call linchk (lun,1)

	write(lun,45) 'CSRC',memory_register_c
45	format(' ',t8,a,t24,z8.8)

	if (.not. diagnostic_mode) then

	if (lib$extzv(28,1,memory_register_c) .eq. 1) then

	error_syndrome = lib$extzv(0,8,memory_register_c)

	call linchk (lun,1)

	write(lun,15) error_syndrome
15	format(' ',t40,'ERROR SYNDROME = ',z2.2)

	error_bit = decode_ecc (error_syndrome,memory_register_a)

	call linchk (lun,1)

	if (error_bit .eq. -1) then

	write(lun,20) 'RDS ERROR'
20	format(' ',t40,a)
	else

	write(lun,25) 'CRD ERROR, CORRECTED BIT #',error_bit,'.'
25	format(' ',t40,a,i<compress4 (error_bit)>,a)
	endif

	error_page_address = lib$extzv(8,16,memory_register_c)/128	

	call linchk (lun,1)

	write(lun,47) error_page_address
47	format(' ',t40,'ARRAY LOGICAL PAGE #',
	1 i<compress4 (error_page_address)>,'. IN ERROR')

	error_array = lib$extzv(24,4,memory_register_c)

	call linchk (lun,1)

	write(lun,50) error_array
50	format(' ',t40,'ARRAY #',i<compress4 (error_array)>,'. IN ERROR')
	endif

	call output (lun,memory_register_c,v1memory_registerc,28,28,30,'0')
	endif

	return



	entry b_ms780c (lun,memory_registers,adapter_tr)



	call movc3 (%val(12),memory_registers,buffer)

	call brief32 (lun,(3),memory_register_a,register_herald,'TR ',
	1 adapter_tr)

	return




	entry c_ms780c (lun,memory_registers,adapter_tr)



	call movc3 (%val(12),memory_registers,buffer)

	call cryptk (lun,32,(3),memory_register_a,register_herald,'TR ',
	1 adapter_tr)

	return

	end




	subroutine ms780e (lun,memory_registers)



c++
c	This routine displays the error log packet for the ms780e
c	memory controller.  The format of the packet is as follows.
c
c	+-----------------------------------+
c	|         memory register A         |
c	+-----------------------------------+
c	|         memory register B         |
c	+-----------------------------------+
c	|         memory register C         |
c	+-----------------------------------+
c	|         memory register D         |
c	+-----------------------------------+
c--




	byte		lun

	integer*4	memory_registers

	integer*4	buffer(4)

	integer*4	memory_register_a

	integer*4	memory_register_b

	integer*4	memory_register('c'x:'d'x)

	equivalence	(buffer(1),memory_register_a)

	equivalence	(buffer(2),memory_register_b)

	equivalence	(buffer(3),memory_register)

	logical*1	diagnostic_mode

	integer*4	decode_ecc

	integer*4	compress4

	integer*4	compressc

	character*27	memory_init_status(0:3)

	data		memory_init_status(0)	/'INITIALIZATION IN PROGRESS*'/

	data		memory_init_status(1)	/'MEMORY CONTAINS VALID DATA*'/

	data		memory_init_status(2)	/'INVALID STATE*'/

	data		memory_init_status(3)	/'INITIALIZATION COMPLETE*'/

	character*33	v1memory_registerb(7:7)

	data		v1memory_registerb(7)
	1 /'SBI INTERFACE WRITE PARITY ERROR*'/

	character*27	v2memory_registerb(14:14)

	data		v2memory_registerb(14)	/'START ADDRESS WRITE ENABLE*'/

	character*29	v1memory_register(7:7)

	data		v1memory_register(7)
	1 /'MICRO-SEQUENCER PARITY ERROR*'/

	character*18	v2memory_register(28:30)

	data		v2memory_register(28)	/'ERROR LOG REQUEST*'/

	data		v2memory_register(29)	/'HIGH ERROR RATE*'/

	data		v2memory_register(30)	/'INHIBIT CRD TAG*'/

	character*5	register_herald(4)

	data		register_herald(1)/'CSRA*'/

	data		register_herald(2)/'CSRB*'/

	data		register_herald(3)/'CSRC*'/

	data		register_herald(4)/'CSRD*'/

	integer*4	init_status

	integer*4	starting_address

	integer*4	error_syndrome

	integer*4	error_bit

	integer*4	error_page_address

	integer*4	error_array

	equivalence	(init_status,starting_address,error_syndrome,error_bit,
	1 error_page_address,error_array)

	integer*4	adapter_tr



	call movc3 (%val(16),memory_registers,buffer)

	diagnostic_mode = .false.

	if (
	1 lib$extzv(7,3,memory_register_b) .ne. 0
	1 .or.
	1 lib$extzv(11,1,memory_register_b) .eq. 1
	1 .or.
	1 lib$extzv(31,1,memory_register('c'x)) .eq. 1
	1 .or.
	1 lib$extzv(31,1,memory_register('d'x)) .eq. 1
	1 ) then

	diagnostic_mode = .true.
	endif

	if (.not. diagnostic_mode) then

	call ms780e_rega (lun,memory_register_a)
	else

	call linchk (lun,1)

	write(lun,5) memory_register_a
5	format(' ',t8,'CSRA',t24,z8.8)
	endif

	call linchk (lun,1)

	write(lun,10) 'CSRB',memory_register_b
10	format(' ',t8,a,t24,z8.8)

	if (diagnostic_mode) then

	call linchk (lun,1)

	write(lun,12) 'DIAGNOSTIC MODE'
12	format(' ',t40,a)
	endif

	if (.not. diagnostic_mode) then

	init_status = lib$extzv(12,2,memory_register_b)

	call linchk (lun,1)

	write(lun,15) memory_init_status(init_status)
15	format(' ',t40,a<compressc (memory_init_status(init_status))>)
	
	call output (lun,memory_register_b,v1memory_registerb,7,7,7,'0')

	call output (lun,memory_register_b,v2memory_registerb,14,14,14,'0')

	starting_address = lib$extzv(19,9,memory_register_b)*1024*1024

	call linchk (lun,1)

	write(lun,20) starting_address
20	format(' ',t40,'MEMORY BASE ADDRESS = ',
	1 i<compress4 (starting_address)>,'.K')
	endif

	do 55,i = 'c'x,'d'x

	call linchk (lun,1)

	if (i .eq. 'c'x) then

	write(lun,25) 'C',memory_register(i)
25	format(' ',t8,'CSR',a,t24,z8.8)

	else if (i .eq.'d'x) then

	write(lun,25) 'D',memory_register(i)
	endif

	if (.not. diagnostic_mode) then

	if (lib$extzv(28,1,memory_register(i)) .eq. 1) then

	error_syndrome = lib$extzv(0,7,memory_register(i))

	call linchk (lun,1)

	write(lun,30) error_syndrome
30	format(' ',t40,'ERROR SYNDROME = ',z2.2)

	error_bit = decode_ecc (error_syndrome,memory_register_a)

	call linchk (lun,1)

	if (error_bit .eq. -1) then

	write(lun,35) 'RDS ERROR'
35	format(' ',t40,a)
	else

	write(lun,40) 'CRD ERROR, CORRECTED BIT #',error_bit,'.'
40	format(' ',t40,a,i<compress4 (error_bit)>,a)
	endif

	call output (lun,memory_register(i),v1memory_register,7,7,7,'0')

	error_page_address = lib$extzv(11,17,memory_register(i))

	if (lib$extzv(3,2,memory_register_a) .eq. 1) then

	error_page_address = error_page_address*128

	else if (lib$extzv(3,2,memory_register_a) .eq. 2) then

	error_page_address = error_page_address*512
	endif

	call linchk (lun,1)

	write(lun,45) error_page_address
45	format(' ',t40,'ARRAY LOGICAL PAGE #',
	1 i<compress4 (error_page_address)>,'. IN ERROR')

	error_array = lib$extzv(24,3,memory_register(i))

	call linchk (lun,1)

	write(lun,50) error_array
50	format(' ',t40,'ARRAY #',i<compress4 (error_array)>,'. IN ERROR')
	endif

	call output (lun,memory_register(i),v2memory_register,28,28,30,'0')
	endif

55	continue

	return




	entry b_ms780e (lun,memory_registers,adapter_tr)




	call movc3 (%val(16),memory_registers,buffer)

	call brief32 (lun,(4),memory_register_a,register_herald,'TR ',
	1 adapter_tr)

	return




	entry c_ms780e (lun,memory_registers,adapter_tr)



	call movc3 (%val(16),memory_registers,buffer)

	call cryptk (lun,32,(4),memory_register_a,register_herald,'TR ',
	1 adapter_tr)

	return

	end




	subroutine ms750 (lun,memory_registers)



c++
c
c	Functional description:
c
c	This module displays ms750 memory error packets.  The format is as
c	follows.
c
c	+-------------------------------+
c	|        memory register 0      |
c	+-------------------------------+
c	|        memory register 1      |
c	+-------------------------------+
c	|        memory register 2      |
c	+-------------------------------+
c--



	byte		lun

	integer*4	memory_registers

	integer*4	slot_index

	integer*4	buffer(3)

	integer*4	memory_register_0

	integer*4	memory_register_1

	integer*4	memory_register_2

	equivalence	(buffer(1),memory_register_0)

	equivalence	(buffer(2),memory_register_1)

	equivalence	(buffer(3),memory_register_2)

	character*35	v1memory_register0(29:31)

	data		v1memory_register0(29)	/'CORRECTED ERROR FLAG*'/

	data		v1memory_register0(30)	
	1 /'UNCORRECTED ERROR INFORMATION LOST*'/

	data		v1memory_register0(31)	/'UNCORRECTED ERROR FLAG*'/

	character*34	v1memory_register1(28:28)

	data		v1memory_register1(28)
	1 /'ENABLE REPORTING CORRECTED ERRORS*'/

	character*23	v1memory_register2(16:16)

	data		v1memory_register2(16)	/'BATTERY BACKUP FAILURE*'/

	integer*4	compress4

	integer*4	lib$extzv

	integer*4	decode_ecc

	integer*4	error_bit

	integer*4	error_array

	integer*4	arrays_present

	integer*4	start_address

	equivalence	(error_bit,error_array,arrays_present,
	1 start_address)

	integer*4	array_code

	logical*1	diagnostic_mode

	logical*1	l0011

	logical*1	l0016

	character*5	register_herald(3)

	data		register_herald(1)/'CSR0*'/

	data		register_herald(2)/'CSR1*'/

	data		register_herald(3)/'CSR2*'/




	call movc3 (%val(12),memory_registers,buffer)

	diagnostic_mode = .false.

	if (lib$extzv(25,3,memory_register_1) .ne. 0) diagnostic_mode = .true.

	call linchk (lun,2)

	write(lun,10) memory_register_0
10	format('0',t8,'CSR0',t24,z8.8)

	if (.not. diagnostic_mode) then

	call linchk (lun,1)

	write(lun,15) lib$extzv(0,7,memory_register_0)
15	format(' ',t40,'ERROR SYNDROME = ',z2.2)

	if (lib$extzv(29,1,memory_register_0) .eq. 1) then

	error_bit = decode_ecc (lib$extzv(0,7,memory_register_0))

	call linchk (lun,1)

	if (error_bit .eq. -1) then

	write(lun,20) '"ECC" CODE, UNCORRECTED ERROR'
	else

	write(lun,20) 'CORRECTED ERROR, BIT #',error_bit,'.'
20	format(' ',t40,a,:i<compress4 (error_bit)>,:a)
	endif
	endif

	if (lib$extzv(30,1,memory_register_0) .eq. 0) then

	error_array = lib$extzv(9,15,memory_register_0)

	l0011 = .false.

	l0016 = .false.

	if (lib$extzv(24,1,memory_register_2) .eq. 1) then

	l0016 = .true.
	else

	l0011 = .true.
	endif

	do 25,i = 0,15,2

	array_code = lib$extzv(i,2,memory_register_2)

	if (l0016) then

	if (array_code .eq. 3) then

	error_array = error_array - 512

	else if (array_code .eq. 2) then

	error_array = error_array - 2048
	endif

	else if (l0011) then

	if (array_code .eq. 1) then

	error_array = error_array - 256

	else if (array_code .eq. 3) then

	error_array = error_array - 512
	endif
	endif

	if (error_array .le. 0) then

	error_array = i/2

	goto 28
	endif

25	continue

28	call linchk (lun,1)

	write(lun,30) error_array
30	format(' ',t40,'ARRAY #',i<compress4 (error_array)>,'. IN ERROR')
	endif

	call output (lun,memory_register_0,v1memory_register0,29,29,31,'0')
	endif

	call linchk (lun,1)

	write(lun,35) memory_register_1
35	format(' ',t8,'CSR1',t24,z8.8)

	if (lib$extzv(25,3,memory_register_1) .eq. 0) then

	call output (lun,memory_register_1,v1memory_register1,28,28,28,'0')
	else

	call linchk (lun,1)

	write(lun,40) 'DIAGNOSTIC MODE'
40	format(' ',t40,a)
	endif

	call linchk (lun,1)

	write(lun,45) memory_register_2
45	format(' ',t8,'CSR2',t24,z8.8)

	if (.not. diagnostic_mode) then

	arrays_present = 0

	do 47,i = 0,15,2

	array_code = lib$extzv(i,2,memory_register_2)

	if (l0016) then

	if (array_code .eq. 3) then

	arrays_present = arrays_present + 2

	else if (array_code .eq. 2) then

	arrays_present = arrays_present + 8
	endif

	else if (l0011) then

	if (array_code .eq. 1) then

	arrays_present = arrays_present + 1

	else if (array_code .eq. 3) then

	arrays_present = arrays_present + 2
	endif
	endif

47	continue

	call linchk (lun,1)

	write(lun,50) arrays_present*128
50	format(' ',t40,'MEMORY SIZE = ',
	1 i<compress4 (arrays_present*128)>,'.K')

	call output (lun,memory_register_2,v1memory_register2,16,16,16,'0')

	start_address = lib$extzv (17,7,memory_register_2)

	call linchk (lun,1)

	write(lun,55) start_address*128
55	format(' ',t40,'MEMORY BASE ADDRESS = ',
	1 i<compress4 (start_address*128)>,'.K')
	endif

	call linchk (lun,1)

	if (l0016) then

	write(lun,60) 'L0016'
60	format(' ',t40,'CONTROLLER IS ',a)
	else

	write(lun,60) 'L0011'
	endif

	return

	


	entry b_ms750 (lun,memory_registers,slot_index)




	call movc3 (%val(12),memory_registers,buffer)

	call brief32 (lun,(3),memory_register_0,register_herald,'SI ',
	1 slot_index)

	return




	entry c_ms750 (lun,memory_registers,slot_index)



	call movc3 (%val(12),memory_registers,buffer)

	call cryptk (lun,32,(3),memory_register_0,register_herald,'SI ',
	1 slot_index)

	return

	end




	subroutine ms7zz (lun,memory_register_0)




c++
c	Functional description:
c
c	This routine displays the memory registers for the 11/7zz.  The
c	format of the buffer is as follows.
c
c	+--------------------------------+
c	|           memory csr0          |
c	+--------------------------------+
c	|           memory csr1          |
c	+--------------------------------+
c	|           memory csr2          |
c	+--------------------------------+
c--




	byte		lun

	integer*4	memory_register_0

	integer*4	buffer(3)

	integer*4	memory_csr0

	integer*4	memory_csr1

	integer*4	memory_csr2

	equivalence	(buffer(1),memory_csr0)

	equivalence	(buffer(2),memory_csr1)

	equivalence	(buffer(3),memory_csr2)

	logical*1	diagnostic_mode

	integer*4	compress4

	integer*4	decode_ecc

	integer*4	error_bit

	integer*4	error_array

	integer*4	kilo_bytes_present

	character*23	v1memory_register_1(27:28)

	data		v1memory_register_1(27)	/'MEMORY MAPPING ENABLE*'/

	data		v1memory_register_1(28)	/'ENABLE "CRD" REPORTING*'/

	character*12	v2memory_register_1(30:30)

	data		v2memory_register_1(30)	/'"CRD" ERROR*'/

	character*17	v1memory_register_2(24:24,0:1)

	data		v1memory_register_2(24,0) /'16K RAMS PRESENT*'/

	data		v1memory_register_2(24,1) /'64K RAMS PRESENT*'/

	character*5	register_herald(3)

	data		register_herald(1)/'CSR0*'/

	data		register_herald(2)/'CSR1*'/

	data		register_herald(3)/'CSR2*'/




	call movc3 (%val(12),memory_register_0,buffer)

	diagnostic_mode = .false.

	if (iand(memory_csr1,'26000000'x) .ne. 0) diagnostic_mode = .true.

	call linchk (lun,2)

	write(lun,10) memory_csr0
10	format('0',t8,'CSR0',t24,z8.8)

	if (.not. diagnostic_mode) then

	call linchk (lun,1)

	write(lun,15) lib$extzv(0,7,memory_csr0)
15	format(' ',t40,'ERROR SYNDROME = ',z2.2)

	error_bit = decode_ecc (lib$extzv(0,7,memory_csr0))

	call linchk (lun,1)

	if (error_bit .eq. -1) then

	write(lun,20) '"ECC" CODE, UNCORRECTED ERROR'
	else

	write(lun,20) 'CORRECTED ERROR, BIT #',error_bit,'.'
20	format(' ',t40,a,:i<compress4 (error_bit)>,:a)
	endif

	error_array = lib$extzv(9,15,memory_csr0)

	do 25,i = 0,15

	if (lib$extzv(i,1,memory_csr2) .eq. 1) then

	if (lib$extzv(24,1,memory_csr2) .eq. 1) then

	error_array = error_array - 1024
	else

	error_array = error_array - 256
	endif
	endif

	if (error_array .le. 0) then

	error_array = i/2

	goto 27
	endif

25	continue

27	call linchk (lun,1)

	write(lun,30) error_array
30	format(' ',t40,'ARRAY #',i<compress4 (error_array)>,'. IN ERROR')
	endif
	
	call linchk (lun,1)

	write(lun,35) memory_csr1
35	format(' ',t8,'CSR1',t24,z8.8)

	if (.not. diagnostic_mode) then

	call output (lun,memory_csr1,v1memory_register_1,27,27,28,'0')

	call output (lun,memory_csr1,v2memory_register_1,30,30,30,'0')
	else

	call linchk (lun,1)

	write(lun,40) 'DIAGNOSTIC MODE'
40	format(' ',t40,a)
	endif

	call linchk (lun,1)

	write(lun,45) memory_csr2
45	format(' ',t8,'CSR2',t24,z8.8)

	if (.not. diagnostic_mode) then

	do 50,i = 0,15

	if (lib$extzv(i,1,memory_csr2) .eq. 1) then

	if (lib$extzv(24,1,memory_csr2) .eq. 1) then

	kilo_bytes_present = kilo_bytes_present + 512
	else

	kilo_bytes_present = kilo_bytes_present + 128
	endif
	endif

50	continue

	call linchk (lun,1)

	write(lun,55) kilo_bytes_present
55	format(' ',t40,'MEMORY SIZE = ',i<compress4 (kilo_bytes_present)>,
	1 '.K')

	call output (lun,memory_csr2,v1memory_register_2,24,24,24,'2')
	endif

	return




	entry b_ms7zz (lun,memory_register_0)




	call movc3 (%val(12),memory_register_0,buffer)

	call brief32 (lun,(3),memory_csr0,register_herald,'MEM',0)

	return




	entry c_ms7zz (lun,memory_register_0)



	call movc3 (%val(12),memory_register_0,buffer)

	call cryptk (lun,32,(3),memory_csr0,register_herald,'MEM',0)

	return

	end




C++
C	Functional description:
C
C	This module maintains a list which is used to produce a display
C	that shows where and how many memory errors have occured.  The format
C	of the list is shown below.
C
C	+--------------------------------+
C	|            flink1              |
C	+--------------------------------+
C	|            blink1              |
C	+--------------------------------+
C	|           logging sid          |
C	+--------------------------------+
C	|      root node memory flink    |
C	+--------------------------------+
C	|      root memory node blink    |
C	+--------------------------------+
C	|     memory node entry count    |
C	+--------------------------------+
C
C
C	+--------------------------------+
C	|            flink2              |
C	+--------------------------------+
C	|            blink2              |
C	+--------------------------------+
C	|         memory node            |
C	+--------------------------------+
C	|       root array flink         |
C	+--------------------------------+
C	|       root array blink         |
C	+--------------------------------+
C	|       array entry count        |
C	+--------------------------------+
C
C
C	+--------------------------------+
C	|            flink3              |
C	+--------------------------------+
C	|            blink3              |
C	+--------------------------------+
C	|            array               |
C	+--------------------------------+
C	|      root array bank flink     |
C	+--------------------------------+
C	|      root array bank blink     |
C	+--------------------------------+
C	|     array bank entry count     |
C	+--------------------------------+
C
C
C	+--------------------------------+
C	|            flink4              |
C	+--------------------------------+
C	|            blink4              |
C	+--------------------------------+
C	|          array bank            |
C	+--------------------------------+
C	|        root array bit flink    |
C	+--------------------------------+
C	|        root array bit blink    |
C	+--------------------------------+
C	|       array page entry count   |
C	+--------------------------------+
C
C
C	+--------------------------------+
C	|            flink5              |
C	+--------------------------------+
C	|            blink5              |
C	+--------------------------------+
C	|           array bit            |
C	+--------------------------------+
C	|          error count           |
C	+--------------------------------+
C--



	subroutine memory_q (search_sid,search_memory_node,search_array,
	1 search_array_bank,search_array_bit)




	integer*4	buffer0(2)

	integer*4	buffer1(6)

	integer*4	buffer2(6)

	integer*4	buffer3(6)

	integer*4	buffer4(6)

	integer*4	buffer5(4)

	integer*4	root_logging_sid_flink

	integer*4	root_logging_sid_blink

	equivalence	(buffer0(1),root_logging_sid_flink)

	equivalence	(buffer0(2),root_logging_sid_blink)

	integer*4	flink1

	integer*4	blink1

	integer*4	logging_sid

	integer*4	root_memory_node_flink

	integer*4	root_memory_node_blink

	integer*4	memory_node_entry_count

	equivalence	(buffer1(1),flink1)

	equivalence	(buffer1(2),blink1)

	equivalence	(buffer1(3),logging_sid)

	equivalence	(buffer1(4),root_memory_node_flink)

	equivalence	(buffer1(5),root_memory_node_blink)

	equivalence	(buffer1(6),memory_node_entry_count)

	integer*4	flink2

	integer*4	blink2

	integer*4	memory_node

	integer*4	root_array_flink

	integer*4	root_array_blink

	integer*4	array_entry_count

	equivalence	(buffer2(1),flink2)

	equivalence	(buffer2(2),blink2)

	equivalence	(buffer2(3),memory_node)

	equivalence	(buffer2(4),root_array_flink)

	equivalence	(buffer2(5),root_array_blink)

	equivalence	(buffer2(6),array_entry_count)

	integer*4	flink3

	integer*4	blink3

	integer*4	array

	integer*4	root_array_bank_flink

	integer*4	root_array_bank_blink

	integer*4	array_bank_entry_count

	equivalence	(buffer3(1),flink3)

	equivalence	(buffer3(2),blink3)

	equivalence	(buffer3(3),array)

	equivalence	(buffer3(4),root_array_bank_flink)

	equivalence	(buffer3(5),root_array_bank_blink)

	equivalence	(buffer3(6),array_bank_entry_count)

	integer*4	flink4

	integer*4	blink4

	integer*4	array_bank

	integer*4	root_array_bit_flink

	integer*4	root_array_bit_blink

	integer*4	array_bit_entry_count

	equivalence	(buffer4(1),flink4)

	equivalence	(buffer4(2),blink4)

	equivalence	(buffer4(3),array_bank)

	equivalence	(buffer4(4),root_array_bit_flink)

	equivalence	(buffer4(5),root_array_bit_blink)

	equivalence	(buffer4(6),array_bit_entry_count)

	integer*4	flink5

	integer*4	blink5

	integer*4	array_bit

	integer*4	error_count

	equivalence	(buffer5(1),flink5)

	equivalence	(buffer5(2),blink5)

	equivalence	(buffer5(3),array_bit)

	equivalence	(buffer5(4),error_count)

	integer*4	insert_blink

	integer*4	logging_sid_entry_count

	integer*4	logging_sid_entry_address

	integer*4	memory_node_entry_address

	integer*4	array_entry_address

	integer*4	array_bank_entry_address

	integer*4	array_bit_entry_address

	integer*4	search_sid

	integer*4	search_memory_node

	integer*4	search_array

	integer*4	search_array_bank

	integer*4	search_array_bit

	logical*1	lib$get_vm

	integer*4	compress4

	byte		lun



	logging_sid_entry_address = root_logging_sid_flink

	do 100,i = 1,logging_sid_entry_count

	call movc3 (%val(24),%val(logging_sid_entry_address),buffer1)

	if (search_sid .eq. logging_sid) then

5	memory_node_entry_address = root_memory_node_flink

	do 90,j = 1,memory_node_entry_count

	call movc3 (%val(24),%val(memory_node_entry_address),buffer2)

	if (search_memory_node .eq. memory_node) then

10	array_entry_address = root_array_flink

	do 80,k = 1,array_entry_count

	call movc3 (%val(24),%val(array_entry_address),buffer3)

	if (search_array .eq. array) then

15	array_bank_entry_address = root_array_bank_flink

	do 70,l = 1,array_bank_entry_count

	call movc3 (%val(24),%val(array_bank_entry_address),buffer4)

	if (search_array_bank .eq. array_bank) then

20	array_bit_entry_address = root_array_bit_flink

	do 60,m = 1,array_bit_entry_count

	call movc3 (%val(16),%val(array_bit_entry_address),buffer5)

	if (search_array_bit .eq. array_bit) then

25	error_count = error_count + 1

	call movl (error_count,%val(array_bit_entry_address + 12))

	return
	endif

	array_bit_entry_address = flink5

60	continue

	call movc5 (%val(0),,%val(0),%val(16),buffer5)

	if (lib$get_vm(((16+7)/8)*8,array_bit_entry_address)) then

	call insque (%val(array_bit_entry_address),
	1 %val(root_array_bit_blink))

	array_bit = search_array_bit

	call movq (array_bit,%val(array_bit_entry_address + 8))

	array_bit_entry_count = array_bit_entry_count + 1

	call movl (array_bit_entry_count,%val(array_bank_entry_address + 20))

	goto 25
	endif

	return
	endif

	insert_blink = blink4

	if (array_bank .gt. search_array_bank) goto 75

	array_bank_entry_address = flink4

70	continue

	insert_blink = root_array_bank_blink

75	call movc5 (%val(0),,%val(0),%val(24),buffer4)

	if (lib$get_vm(((24+7)/8)*8,array_bank_entry_address)) then

	call insque (%val(array_bank_entry_address),%val(insert_blink))
	
	array_bank = search_array_bank

	root_array_bit_flink = array_bank_entry_address + 12

	root_array_bit_blink = root_array_bit_flink

	call movc3 (%val(16),array_bank,%val(array_bank_entry_address + 8))

	array_bank_entry_count = array_bank_entry_count + 1

	call movl (array_bank_entry_count,%val(array_entry_address + 20))

	goto 20
	endif

	return
	endif

	insert_blink = blink3

	if (array .gt. search_array) goto 85

	array_entry_address = flink3

80	continue

	insert_blink = root_array_blink

85	call movc5 (%val(0),,%val(0),%val(24),buffer3)

	if (lib$get_vm(((24+7)/8)*8,array_entry_address)) then

	call insque (%val(array_entry_address),%val(insert_blink))

	array = search_array

	root_array_bank_flink = array_entry_address + 12

	root_array_bank_blink = root_array_bank_flink

	call movc3 (%val(16),array,%val(array_entry_address + 8))

	array_entry_count = array_entry_count + 1

	call movl (array_entry_count,%val(memory_node_entry_address + 20))

	goto 15
	endif

	return
	endif

	insert_blink = blink2

	if (memory_node .gt. search_memory_node) goto 95

	memory_node_entry_address = flink2

90	continue

	insert_blink = root_memory_node_blink

95	call movc5 (%val(0),,%val(0),%val(24),buffer2)

	if (lib$get_vm(((24+7)/8)*8,memory_node_entry_address)) then

	call insque (%val(memory_node_entry_address),%val(insert_blink))

	memory_node = search_memory_node

	root_array_flink = memory_node_entry_address + 12

	root_array_blink = root_array_flink

	call movc3 (%val(16),memory_node,%val(memory_node_entry_address + 8))

	memory_node_entry_count = memory_node_entry_count + 1

	call movl (memory_node_entry_count,
	1 %val(logging_sid_entry_address + 20))

	goto 10
	endif

	return
	endif

	logging_sid_entry_address = flink1

100	continue

	call movc5 (%val(0),,%val(0),%val(24),buffer1)

	if (logging_sid_entry_count .eq. 0) then

	root_logging_sid_flink = %loc(root_logging_sid_flink)

	root_logging_sid_blink = root_logging_sid_flink
	endif

	if (lib$get_vm(((24+7)/8)*8,logging_sid_entry_address)) then

	call insque (%val(logging_sid_entry_address),
	1 %val(root_logging_sid_blink))

	logging_sid = search_sid

	root_memory_node_flink = logging_sid_entry_address + 12

	root_memory_node_blink = root_memory_node_flink

	call movc3 (%val(16),logging_sid,%val(logging_sid_entry_address + 8))

	logging_sid_entry_count = logging_sid_entry_count + 1

	goto 5
	endif

	return




C++
C	Functional description:
C
C	This entry point is used to display the memory error occurrance list
C	built by memory_q.
C--




	entry memory_display (lun)




	logging_sid_entry_address = root_logging_sid_flink

	do 200,i = 1,logging_sid_entry_count

	call movc3 (%val(24),%val(logging_sid_entry_address),buffer1)

c	call set_rab$v_cco

	call frctof (lun)

	call linchk (lun,2)

	write(lun,110) logging_sid
110	format('0','SUMMARY OF MEMORY ERRORS LOGGED BY SID ',z8.8)

	memory_node_entry_address = root_memory_node_flink

	do 190,j = 1,memory_node_entry_count

	call movc3 (%val(24),%val(memory_node_entry_address),buffer2)

	call linchk (lun,5)

	if (lib$extzv(24,8,logging_sid) .eq. 1) then

	write(lun,115) 'TR #',memory_node
115	format('0','CONTROLLER AT ',a,i<compress4 (memory_node)>,'.')

	else if (lib$extzv(24,8,logging_sid) .eq. 2) then

	write(lun,115) 'SLOT INDEX #',memory_node
	endif

	write(lun,117) 'ARRAY#','BIT#','BANK','CORRECTED','FATAL',
	1 'ERRORS','ERRORS'
117	format('0',t8,a,t16,a,t24,a,t35,a,t50,a,/,
	1 t37,a,t50,a)

	array_entry_address = root_array_flink

	do 180,k = 1,array_entry_count

	call movc3 (%val(24),%val(array_entry_address),buffer3)

	array_bank_entry_address = root_array_bank_flink

	do 170,l = 1,array_bank_entry_count

	call movc3 (%val(24),%val(array_bank_entry_address),buffer4)

	array_bit_entry_address = root_array_bit_flink

	do 160,m = 1,array_bit_entry_count

	call movc3 (%val(16),%val(array_bit_entry_address),buffer5)

	call linchk (lun,2)

	if (
	1 array .ne. -1
	1 .and.
	1 array_bank .ne. -1
	1 .and.
	1 array_bit .ne. -1
	1 ) then

	write(lun,120) array,array_bit,array_bank,error_count
120	format('0',t10,i2.2,'.',t17,i2.2,'.',t25,i2.2,'.',t31,i10.1,'.')

	else if (
	1 array .ne. -1
	1 .and.
	1 array_bank .ne. -1
	1 .and.
	1 array_bit .eq. -1
	1 ) then

	write(lun,125) array,array_bank,error_count
125	format('0',t10,i2.2,'.',t25,i2.2,'.',t44,i10.1,'.')
	else

	write(lun,130) error_count
130	format('0',t44,i10.1,'.')
	endif

155	array_bit_entry_address = flink5

160	continue

165	array_bank_entry_address = flink4

170	continue

175	array_entry_address = flink3

180	continue

185	memory_node_entry_address = flink2

190	continue

195	logging_sid_entry_address = flink1

200	continue

	return

	end
