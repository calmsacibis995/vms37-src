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

c	Author	Brian Porter		Creation Date	15-JUN-1981

c++
c	Functional description:
c
c	This routine is called to identify the device for 'DEVICE ERROR',
c	'DEVICE ATTENTION' and 'DEVICE TIMEOUT' entries.
c
c	Modified by:
c
c	v03-001	BP0003		Brian Porter,		03-MAR-1982
c		Added more arguments to dhead2 call.  Added dhead3
c		routine
c**
c--




	subroutine dhead1 (lun,device_type)




	include 'src$:msghdr.for /nolist'

	include 'src$:deverr.for /nolist'




	byte		lun

	character*(*)	device_type



	call header (lun)

	if (emb$w_hd_entry .eq. 1) then

	call logger (lun,'DEVICE ERROR')

	else if (emb$w_hd_entry .eq. 96) then

	call logger (lun,'DEVICE TIMEOUT')

	else if (emb$w_hd_entry .eq. 98) then

	call logger (lun,'DEVICE ATTENTION')	
	endif

	call dhead2 (lun,device_type,emb$b_dv_namlng,emb$t_dv_name,
	1 emb$w_dv_unit)

	return

	end




	subroutine dhead2 (lun,device_type,emb$b_zz_namlng,emb$t_zz_name,
	1 emb$w_zz_unit)




	include 'src$:msghdr.for /nolist'




	byte		lun

	character*(*)	device_type

	byte		emb$b_zz_namlng

	character*(*)	emb$t_zz_name

	integer*2	emb$w_zz_unit

	integer*4	caller_mount_flag_and_label

	character*12	last_emb$t_vm_label

	integer*4	last_emb$t_vm_label_length

	logical*1	last_emb$t_vm_label_valid

	logical*1	str$trim

	integer*4	compress4




	last_emb$t_vm_label_valid = .false.

	call get_current_label (3,emb$l_hd_sid,emb$b_zz_namlng,emb$t_zz_name,
	1 emb$w_zz_unit,%ref(last_emb$t_vm_label),*5)

	last_emb$t_vm_label_valid = .true.

5	continue

	if (.not. str$trim (last_emb$t_vm_label,last_emb$t_vm_label,
	1 last_emb$t_vm_label_length)) then

	last_emb$t_vm_label_length = 12
	endif

	if (
	1 last_emb$t_vm_label_valid
	1 .and.
	1 last_emb$t_vm_label_length .gt. 1
	1 ) then

10	continue

	call linchk (lun,2)

	write(lun,15) device_type,emb$t_zz_name(1:emb$b_zz_namlng),
	1 emb$w_zz_unit,', CURRENT LABEL "',
	1 last_emb$t_vm_label(1:last_emb$t_vm_label_length),'"'
15	format('0',a,' SUB-SYSTEM, UNIT _',a,
	1 i<compress4 (lib$extzv(0,16,emb$w_zz_unit))>,':',3(:a))

	return
	endif

20	continue

	call linchk (lun,2)

	write(lun,15) device_type,emb$t_zz_name(1:emb$b_zz_namlng),
	1 emb$w_zz_unit

	return



	entry dhead3 (lun,device_type,emb$b_zz_namlng,emb$t_zz_name,
	1 emb$w_zz_unit,caller_mount_flag_and_label)



	last_emb$t_vm_label_valid = .false.

	if (caller_mount_flag_and_label .eq. -1) goto 20

	call movc3 (%val(12),%val(caller_mount_flag_and_label),
	1 %ref(last_emb$t_vm_label))

	if (.not. str$trim (last_emb$t_vm_label,last_emb$t_vm_label,
	1 last_emb$t_vm_label_length)) then

	last_emb$t_vm_label_length = 12
	endif

	last_emb$t_vm_label_valid = .true.

	goto 10

	end
