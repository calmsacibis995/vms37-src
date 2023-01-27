C
C	v02-000
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

c	Author	Brian Porter			Creation Date	11-NOV-1981


c++
c	Functional description:
c
c	This is a collection of routines that display the VAX-11 family
c	of MBA adapter registers.  It is called by various massbus device
c	modules.
c
c	Modified by:
c**
c--



	subroutine mba_control_registers (lun,number_of_registers,
	1 adapter_registers,selected_mapping_register)



	include 'src$:msghdr.for /nolist'



	byte		lun

	integer*4	number_of_registers

	integer*4	adapter_registers(number_of_registers)

	integer*4	selected_mapping_register

	integer*4	compress4




	if (
	1 lib$extzv(24,8,emb$l_hd_sid) .eq. 255
	1 .or.
	1 lib$extzv(24,8,emb$l_hd_sid) .eq. 1
	1 ) then

	call rh780_control_registers (lun,adapter_registers,
	1 selected_mapping_register)

	else if (lib$extzv(24,8,emb$l_hd_sid) .eq. 2) then

	call rh750_control_registers (lun,adapter_registers,
	1 selected_mapping_register)

c
c	for future MBA support the ELSE-IF-THEN should be expanded
c	at this point.
c

	else

	call linchk (lun,(number_of_registers + 1))

	do 20,i = 1,number_of_registers

	write(lun,10) '"RH" REGISTER #',i,adapter_registers(i)
10	format(' ',t8,a,i<compress4 (i)>,t24,z8.8)

20	continue

	selected_mapping_register = -1
	endif

	return

	end



	subroutine rh780_control_registers (lun,adapter_registers,
	1 selected_mapping_register)


c++
c	This routine displays the RH780 adapter registers.  It expects
c	the registers in the following order.
c
c	+------------------------------+
c	|    configuration register    |
c	+------------------------------+
c	|       control register       |
c	+------------------------------+
c	|        status register       |
c	+------------------------------+
c	|   virtual address register   |
c	+------------------------------+
c	|      byte count register     |
c	+------------------------------+
c--




	byte		lun

	integer*4	adapter_registers(5)

	integer*4	selected_mapping_register

	integer*4	compress4

	logical*1	diagnostic_mode

	integer*4	byte_offset

	integer*4	selected_map_register

	integer*4	sbi_byte_count

	integer*4	massbus_byte_count

	character*17	v1rh780_control_register(0:2)

	data	v1rh780_control_register(0)	/'INITIALIZATION*'/

	data	v1rh780_control_register(1)	/'ABORT*'/

	data	v1rh780_control_register(2)	/'INTERRUPT ENABLE*'/

	character*28	v1rh780_status_register(0:13)

	data	v1rh780_status_register(0)  /'READ DATA TIMEOUT*'/

	data	v1rh780_status_register(1)  /'INTERFACE SEQUENCE TIMEOUT*'/

	data	v1rh780_status_register(2)  /'READ DATA SUBSTITUTE*'/

	data	v1rh780_status_register(3)  /'ERROR CONFIRMATION*'/

	data	v1rh780_status_register(4)  /'INVALID MAP*'/

	data	v1rh780_status_register(5)  /'PAGE FRAME MAP PARITY ERROR*'/

	data	v1rh780_status_register(6)  /'"MASSBUS" DATA PARITY ERROR*'/

	data	v1rh780_status_register(7) /'"MASSBUS" EXCEPTION*'/

	data	v1rh780_status_register(8)  /'MISS TRANSFER ERROR*'/

	data	v1rh780_status_register(9)  /'WRITE CHECK LOWER ERROR*'/

	data	v1rh780_status_register(10) /'WRITE CHECK UPPER ERROR*'/

	data	v1rh780_status_register(11) /'DATA LATE*'/

	data	v1rh780_status_register(12) /'DATA TRANSFER ABORTED*'/

	data	v1rh780_status_register(13) /'DATA TRANSFER COMPLETED*'/



	diagnostic_mode = .false.

	if (lib$extzv(3,1,adapter_registers(2)) .eq. 1)
	1 diagnostic_mode = .true.

	if (.not. diagnostic_mode) then

	call rh780_configuration_register (lun,adapter_registers(1))
	else

	call linchk (lun,2)

	write(lun,10) adapter_registers(1)
10	format('0',t8,'RH780 CSR',t24,z8.8)
	endif

	call linchk (lun,1)

	write(lun,15) adapter_registers(2)
15	format(' ',t8,'RH780 CR',t24,z8.8)

	if (.not. diagnostic_mode) then

	call output (lun,adapter_registers(2),v1rh780_control_register,
	1 0,0,2,'0')
	else

	call linchk (lun,1)

	write(lun,20) 'DIAGNOSTIC MODE'
20	format(' ',t40,a)
	endif

	call linchk (lun,1)

	write(lun,25) adapter_registers(3)
25	format(' ',t8,'RH780 SR',t24,z8.8)

	if (.not. diagnostic_mode) then

	call output (lun,adapter_registers(3),v1rh780_status_register,
	1 0,0,13,'0')

	call rh780_status_register16_31 (lun,adapter_registers(3))
	endif

	call linchk (lun,1)

	write(lun,30) adapter_registers(4)
30	format(' ',t8,'RH780 VAR',t24,z8.8)

	if (.not. diagnostic_mode) then

	byte_offset = lib$extzv(0,9,adapter_registers(4))

	selected_map_register = lib$extzv(9,8,adapter_registers(4))

	call linchk (lun,2)

	if (byte_offset .eq. 0) then

	write(lun,20) 'PAGE ALIGNED'
	else

	write(lun,35) byte_offset
35	format(' ',t40,i<compress4 (byte_offset)>,'. BYTE, PAGE OFFSET')
	endif

	write(lun,40) selected_map_register
40	format(' ',t40,'MAPPING REGISTER #',
	1 i<compress4 (selected_map_register)>,'. SELECTED')
	endif

	call linchk (lun,1)

	write(lun,45) adapter_registers(5)
45	format(' ',t8,'RH780 BCR',t24,z8.8)

	if (.not. diagnostic_mode) then

	sbi_byte_count = lib$extv(0,16,adapter_registers(5))

	sbi_byte_count = max(0,sbi_byte_count) - min(0,sbi_byte_count)

	if (sbi_byte_count .ne. 0) then

	call linchk (lun,1)

	write(lun,50) sbi_byte_count
50	format(' ',t40,'"SBI" BYTE COUNT, ',i<compress4 (sbi_byte_count)>,
	1 '.')
	endif

	massbus_byte_count = lib$extv(16,16,adapter_registers(5))

	massbus_byte_count = max(0,massbus_byte_count) -
	1 min(0,massbus_byte_count)

	if (massbus_byte_count .ne. 0) then

	call linchk (lun,1)

	write(lun,55) massbus_byte_count
55	format(' ',t40,'"MASSBUS" BYTE COUNT, ',
	1 i<compress4 (massbus_byte_count)>,'.')
	endif
	endif

	selected_mapping_register = selected_map_register

	return

	end



	subroutine rh750_control_registers (lun,adapter_registers,
	1 selected_mapping_register)



c++
c	This routine displays the RH750 adapter registers.  It expects
c	the registers in the following order.
c
c	+------------------------------+
c	|       garbage longword       |
c	+------------------------------+
c	|       control register       |
c	+------------------------------+
c	|        status register       |
c	+------------------------------+
c	|   virtual address register   |
c	+------------------------------+
c	|      byte count register     |
c	+------------------------------+
c--




	byte		lun

	integer*4	adapter_registers(5)

	integer*4	selected_mapping_register

	byte		diagnostic_mode

	integer*4	byte_offset

	integer*4	selected_map_register

	integer*4	cmi_byte_count

	integer*4	massbus_byte_count

	integer*4	compress4

	character*17	v1rh750_control_register(0:2)

	data	v1rh750_control_register(0)  /'INITIALIZATION*'/

	data	v1rh750_control_register(1)  /'ABORT*'/

	data	v1rh750_control_register(2)  /'INTERRUPT ENABLE*'/

	character*25	v2rh750_control_register(4:4)

	data	v2rh750_control_register(4)  /'"IGNORE BYTE COUNT" MODE*'/

	character*19	v1rh750_status_register(1:1)

	data	v1rh750_status_register(1)  /'NO RESPONSE STATUS*'/

	character*28	v2rh750_status_register(3:14)

	data	v2rh750_status_register(3)  /'ERROR STATUS*'/

	data	v2rh750_status_register(4)  /'INVALID MAP*'/

	data	v2rh750_status_register(5)  /'PAGE FRAME MAP PARITY ERROR*'/

	data	v2rh750_status_register(6)  /'"MASSBUS" DATA PARITY ERROR*'/

	data	v2rh750_status_register(7)  /'"MASSBUS" EXCEPTION*'/

	data	v2rh750_status_register(8)  /'MISS TRANSFER ERROR*'/

	data	v2rh750_status_register(9)  /'WRITE CHECK LOWER ERROR*'/

	data	v2rh750_status_register(10) /'WRITE CHECK UPPER ERROR*'/

	data	v2rh750_status_register(11) /'DATA LATE*'/

	data	v2rh750_status_register(12) /'DATA TRANSFER ABORTED*'/

	data	v2rh750_status_register(13) /'DATA TRANSFER COMPLETED*'/

	data	v2rh750_status_register(14) /'SILO PARITY ERROR*'/




	diagnostic_mode = .false.

	if (lib$extzv(3,1,adapter_registers(2)) .eq. 1)
	1 diagnostic_mode = .true.

	call linchk (lun,2)

	write(lun,15) adapter_registers(2)
15	format('0',t8,'RH750 CR',t24,z8.8)

	if (.not. diagnostic_mode) then

	call output (lun,adapter_registers(2),v1rh750_control_register,
	1 0,0,2,'0')

	call output (lun,adapter_registers(2),v2rh750_control_register,
	1 4,4,4,'0')
	else

	call linchk (lun,1)

	write(lun,20) 'DIAGNOSTIC MODE'
20	format(' ',t40,a)
	endif

	call linchk (lun,1)

	write(lun,25) adapter_registers(3)
25	format(' ',t8,'RH750 SR',t24,z8.8)

	if (.not. diagnostic_mode) then

	call output (lun,adapter_registers(3),v1rh750_status_register,
	1 1,1,1,'0')

	call output (lun,adapter_registers(3),v2rh750_status_register,
	1 3,3,14,'0')

	call rh750_status_register16_31 (lun,adapter_registers(3))
	endif

	call linchk (lun,1)

	write(lun,30) adapter_registers(4)
30	format(' ',t8,'RH750 VAR',t24,z8.8)

	if (.not. diagnostic_mode) then

	byte_offset = lib$extzv(0,9,adapter_registers(4))

	selected_map_register = lib$extzv(9,8,adapter_registers(4))

	call linchk (lun,2)

	if (byte_offset .eq. 0) then

	write(lun,20) 'PAGE ALIGNED'
	else

	write(lun,35) byte_offset
35	format(' ',t40,i<compress4 (byte_offset)>,'. BYTE, PAGE OFFSET')
	endif

	write(lun,40) selected_map_register
40	format(' ',t40,'MAPPING REGISTER #',
	1 i<compress4 (selected_map_register)>,'. SELECTED')
	endif

	call linchk (lun,1)

	write(lun,45) adapter_registers(5)
45	format(' ',t8,'RH750 BCR',t24,z8.8)

	if (.not. diagnostic_mode) then

	cmi_byte_count = lib$extv(0,16,adapter_registers(5))

	cmi_byte_count = max(0,cmi_byte_count) - min(0,cmi_byte_count)

	if (cmi_byte_count .ne. 0) then

	call linchk (lun,1)

	write(lun,50) cmi_byte_count
50	format(' ',t40,'"CMI" BYTE COUNT, ',i<compress4 (cmi_byte_count)>,
	1 '.')
	endif

	massbus_byte_count = lib$extv(16,16,adapter_registers(5))

	massbus_byte_count = max(0,massbus_byte_count) -
	1 min(0,massbus_byte_count)

	if (massbus_byte_count .ne. 0) then

	call linchk (lun,1)

	write(lun,55) massbus_byte_count
55	format(' ',t40,'"MASSBUS" BYTE COUNT, ',
	1 i<compress4 (massbus_byte_count)>,'.')
	endif
	endif

	selected_mapping_register = selected_map_register

	return

	end



	subroutine mba_status_register16_31 (lun,register1,register2,flag)



c++
c	'flag' is used in the following way.  If flag is equal to 0
c	then the status represented in 'register1' is output.  If flag
c	is equal to 1 then the status represented by the difference of
c	additionally set bits in 'register1' and 'register2'.
c--



	include 'src$:msghdr.for /nolist'




	byte		lun

	integer*4	register1

	integer*4	register2

	byte		flag

	integer*4	pseudo_status_register

	integer*4	status_register1_bits

	integer*4	status_register2_bits




	if (flag .eq. 0) then

	pseudo_status_register = iand(register1,'ffff0000'x)

	else if (flag .eq. 1) then

	status_register1_bits = iand(register1,'ffff0000'x)

	status_register2_bits = iand(register2,'ffff0000'x)

	pseudo_status_register =
	1 iand(not(status_register1_bits),status_register2_bits)
	endif

	if (pseudo_status_register .ne. 0) then

	if (
	1 lib$extzv(24,8,emb$l_hd_sid) .eq. 255
	1 .or.
	1 lib$extzv(24,8,emb$l_hd_sid) .eq. 1
	1 ) then

	call rh780_status_register16_31 (lun,pseudo_status_register)

	else if (lib$extzv(24,8,emb$l_hd_sid) .eq. 2) then

	call rh750_status_register16_31 (lun,pseudo_status_register)

c
c	for future MBA support the ELSE-IF-THEN should be expanded
c	at this point.
c

	endif
	endif

	return

	end




	subroutine rh780_status_register16_31 (lun,status_register)




	byte		lun

	integer*4	status_register

	character*31	v1rh780_status_register(16:19)

	data	v1rh780_status_register(16) /'ATTENTION*'/

	data	v1rh780_status_register(17) /'"MASSBUS" CONTROL PARITY ERROR*'/

	data	v1rh780_status_register(18) /'NON-EXISTING DRIVE*'/

	data	v1rh780_status_register(19) /'PROGRAMMING ERROR*'/

	character*25	v2rh780_status_register(29:31)

	data	v2rh780_status_register(29) /'CORRECTED READ DATA*'/

	data	v2rh780_status_register(30) /'NO RESPONSE CONFIRMATION*'/

	data	v2rh780_status_register(31) /'DATA TRANSFER BUSY*'/



	call output (lun,status_register,v1rh780_status_register,16,16,19,'0')

	call output (lun,status_register,v2rh780_status_register,29,29,31,'0')

	return

	end



	subroutine rh750_status_register16_31 (lun,status_register)



	byte		lun

	integer*4	status_register

	character*31	v1rh750_status_register(16:19)

	data	v1rh750_status_register(16) /'ATTENTION*'/

	data	v1rh750_status_register(17) /'"MASSBUS" CONTROL PARITY ERROR*'/

	data	v1rh750_status_register(18) /'NON-EXISTENT DRIVE*'/

	data	v1rh750_status_register(19) /'PROGRAMMING ERROR*'/

	character*17	v2rh750_status_register(23:23)

	data	v2rh750_status_register(23) /'CONTROL BUS HUNG*'/

	character*20	v3rh750_status_register(29:29)

	data	v3rh750_status_register(29) /'CORRECTED READ DATA*'/

	character*19	v4rh750_status_register(31:31)

	data	v4rh750_status_register(31) /'DATA TRANSFER BUSY*'/




	call output (lun,status_register,v1rh750_status_register,16,16,19,'0')

	call output (lun,status_register,v2rh750_status_register,23,23,23,'0')

	call output (lun,status_register,v3rh750_status_register,29,29,29,'0')

	call output (lun,status_register,v4rh750_status_register,31,31,31,'0')

	return

	end




	subroutine mba_mapping_register (lun,mapping_register_number,
	1 mapping_register_image)




	include 'src$:msghdr.for /nolist'




	byte		lun

	integer*4	mapping_register_number

	integer*4	mapping_register_image

	integer*4	compress4




	if (
	1 lib$extzv(24,8,emb$l_hd_sid) .eq. 255
	1 .or.
	1 lib$extzv(24,8,emb$l_hd_sid) .eq. 1
	1 ) then

	call rh780_mapping_register (lun,mapping_register_number,
	1 mapping_register_image)

	else if (lib$extzv(24,8,emb$l_hd_sid) .eq. 2) then

	call rh750_mapping_register (lun,mapping_register_number,
	1 mapping_register_image)

c
c	for future MBA support the ELSE-IF-THEN should be expanded
c	at this point.
c

	else

	call linchk (lun,1)

	if (mapping_register_number .ne. -1) then

	write(lun,10) mapping_register_number,mapping_register_image
10	format(' ',t8,'"RH" MPR #',i<compress4 (mapping_register_number)>,
	1 '.',t24,z8.8)
	else

	write(lun,15) mapping_register_image
15	format(' ',t8,'"RH" MPR #???',t24,z8.8)
	endif
	endif

	return

	end




	subroutine rh780_mapping_register (lun,mapping_register_number,
	1 mapping_register_image)



	byte		lun

	integer*4	mapping_register_number

	integer*4	mapping_register_image

	integer*4	compress4

	integer*4	compressf

	integer*4	pfn

	real*4		transfer_address




	call linchk (lun,1)

	if (mapping_register_number .ne. -1) then

	write(lun,10) mapping_register_number,mapping_register_image
10	format(' ',t8,'RH780 MPR #',i<compress4 (mapping_register_number)>,
	1 '.',t24,z8.8)
	else

	write(lun,15) mapping_register_image
15	format(' ',t8,'RH780 MPR #???',t24,z8.8)
	endif
	
	if (lib$extzv(31,1,mapping_register_image) .eq. 1) then

	call linchk (lun,2)

	write(lun,20) 'VALID'
20	format(' ',t40,a)

	pfn = lib$extzv(0,21,mapping_register_image)

	transfer_address = real(pfn)/2

	write(lun,25) transfer_address
25	format(' ',t40,'TRANSFER PAGE, ',
	1 f<compressf (transfer_address,1)>.1,'. K')
	endif

	return

	end




	subroutine rh750_mapping_register (lun,mapping_register_number,
	1 mapping_register_image)




	byte		lun

	integer*4	mapping_register_number

	integer*4	mapping_register_image

	integer*4	compress4

	integer*4	compressf

	integer*4	pfn

	real*4		transfer_address




	call linchk (lun,1)

	if (mapping_register_number .ne. -1) then

	write(lun,10) mapping_register_number,mapping_register_image
10	format(' ',t8,'RH750 MPR #',i<compress4 (mapping_register_number)>,
	1 '.',t24,z8.8)
	else

	write(lun,15) mapping_register_image
15	format(' ',t8,'RH750 MPR #???',t24,z8.8)
	endif
	
	if (lib$extzv(31,1,mapping_register_image) .eq. 1) then

	call linchk (lun,2)

	write(lun,20) 'VALID'
20	format(' ',t40,a)

	pfn = lib$extzv(0,16,mapping_register_image)

	transfer_address = real(pfn)/2

	write(lun,25) transfer_address
25	format(' ',t40,'TRANSFER PAGE, ',
	1 f<compressf (transfer_address,1)>.1,'. K')
	endif

	return

	end
