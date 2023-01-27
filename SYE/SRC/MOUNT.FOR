C
C	v02-003
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
C	Author	BRIAN PORTER		Creation Date	1-JUN-1980
C
C
C	Modified by:
C
C	v02-003	BP0003		Brian Porter,		16-JUN-1981
C		Added '_' and ':' to device name in display.  Added
C		'"'s to the label name. Added call to LOGGER.
C
C	v02-002	BP0002		Brian Porter,		19-MAY-1981
C		Removed RETURN 1 argument from MOUNT_VOLUME and
C		DISMOUNT_VOLUME.
C
C	v02-001	BP0001		Brian Porter,		04-FEB-1981
C		Changed queuing code.
C**




c++
c	functional description
c
c	This routine maintains a list of device names and associated volume
c	label that is currently mounted.
c
c	The format of the list entries is as follows.
c
c	+--------------------------------------+
c	I                flink1                I
c	+--------------------------------------+
c	I                blink1                I
c	+--------------------------------------+
c	I              logging sid             I
c	+--------------------------------------+
c	I           root name flink            I
c	+--------------------------------------+
c	I           root name blink            I
c	+--------------------------------------+
c	I           name entry count           I
c	+--------------------------------------+
c
c
c
c	+--------------------------------------+
c	I                flink2                I
c	+--------------------------------------+
c	I                blink2                I
c	+--------------------------------------+
c	I                                      I
c	+--                                  --+
c	I          16 bytes for name           I
c	+--                                  --+
c	I                string                I
c	+--                                  --+
c	I                                      I
c	+--------------------------------------+
c	I           root unit flink            I
c	+--------------------------------------+
c	I           root unit blink            I
c	+--------------------------------------+
c	I           unit entry count           I
c	+--------------------------------------+
c
c
c
c	+--------------------------------------+
c	I                flink3                I
c	+--------------------------------------+
c	I                blink3                I
c	+--------------------------------------+
c	I           ucb unit number            I
c	+--------------------------------------+
c	I                                      I
c	+--                                  --+
c	I        12 byte label field           I
c	+--                                  --+
c	I                                      I
c	+--------------------------------------+
c	I     ucb operation count at mount     I
c	+--------------------------------------+
c	I       ucb error count at mount       I
c	+--------------------------------------+
c
c	As mount entries are encountered an appropriate list entry is created.
c	When a dismount entry is encountered the entry is removed.
c	If when a mount is encountered and an entry already exists then that
c	entry is updated with the current ucb data.
c--




	subroutine mount_volume (entrance,search_sid,
	1 search_name_length,search_name_string,search_unit,
	2 vcb_label,ucb_operation_count,ucb_error_count)



c++
c	Functional description:
c
c	This entry point is called when a MOUNT VOLUME error log
c	entry type is encountered.  The volume list is searched for
c	an entry corresponding to SEARCH_SID,SEARCH_NAME_STRING and
c	SEARCH_UNIT.  If found then the contents of the entry are updated
c	with VCB_LABEL,UCB_OPERATION_COUNT and UCB_ERROR_COUNT.  It
c	is assumed that the corresponding DISMOUNT VOLUME error log entry
c	is not part of the current file being processed.  If an entry is not
c	found then one is made and the above mentioned information stored.
c	If the call for virtual memory fails then the routine exits.
c--



	entry dismount_volume (entrance,search_sid,
	1 search_name_length,search_name_string,search_unit,
	2 vcb_label,mount_operation_count,mount_error_count)




c++
c	Functional description:
c
c	This routine is called when a DISMOUNT VOLUME error log entry
c	is encountered.  The volume list is searched for an entry corresponding
c	to SEARCH_SID,SEARCH_NAME_STRING,SEARCH_UNIT and VCB_LABEL.  If an
c	entry is found then the operation and error counts are returned in
c	arguments MOUNT_OPERATION_COUNT and MOUNT_ERROR_COUNT. The
c	entry in the mount list is then removed.  If an entry is not found then
c	the routine exits.
c--




	entry get_current_label (entrance,search_sid,
	1 search_name_length,search_name_string,search_unit,
	2 caller_label_buffer,*)




c++
c	Functional description:
c
c	This routine is called to retrieve the name of the currently
c	mounted volume of a unit.  The mount list is searched using
c	SEARCH_SID,SEARCH_NAME_STRING and SEARCH_UNIT.  If an entry
c	is found the label field of the entry is written to
c	CALLER_LABEL_BUFFER.  If an entry is not found then the routine
c	exits via RETURN 1.
c--



	integer*4	buffer0(2)

	integer*4	buffer1(6)

	integer*4	buffer2(9)

	integer*4	buffer3(8)

	integer*4	root_logging_sid_flink

	integer*4	root_logging_sid_blink

	equivalence	(buffer0(1),root_logging_sid_flink)

	equivalence	(buffer0(2),root_logging_sid_blink)

	integer*4	flink1

	integer*4	blink1

	integer*4	logging_sid

	integer*4	root_name_flink

	integer*4	root_name_blink

	integer*4	name_entry_count

	equivalence	(buffer1(1),flink1)

	equivalence	(buffer1(2),blink1)

	equivalence	(buffer1(3),logging_sid)

	equivalence	(buffer1(4),root_name_flink)

	equivalence	(buffer1(5),root_name_blink)

	equivalence	(buffer1(6),name_entry_count)

	integer*4	flink2

	integer*4	blink2

	byte		name_array(16)

	byte		name_length

	character*15	name_string

	integer*4	root_unit_flink

	integer*4	root_unit_blink

	integer*4	unit_entry_count

	equivalence	(buffer2(1),flink2)

	equivalence	(buffer2(2),blink2)

	equivalence	(buffer2(3),name_array)

	equivalence	(name_array(1),name_length)

	equivalence	(name_array(2),name_string)

	equivalence	(buffer2(7),root_unit_flink)

	equivalence	(buffer2(8),root_unit_blink)

	equivalence	(buffer2(9),unit_entry_count)

	integer*4	flink3

	integer*4	blink3

	integer*4	ucb_unit_number

	byte		label_array

	character*12	label_string

	integer*4	mount_ucb_operation_count

	integer*4	mount_ucb_error_count

	equivalence	(buffer3(1),flink3)

	equivalence	(buffer3(2),blink3)

	equivalence	(buffer3(3),ucb_unit_number)

	equivalence	(buffer3(4),label_array)

	equivalence	(label_array,label_string)

	equivalence	(buffer3(7),mount_ucb_operation_count)

	equivalence	(buffer3(8),mount_ucb_error_count)

	integer*4	logging_sid_entry_count

	integer*4	logging_sid_entry_address

	integer*4	name_entry_address

	integer*4	unit_entry_address

	integer*4	entrance

	integer*4	search_sid

	byte		search_name_length

	character*15	search_name_string

	integer*2	search_unit

	character*15	search_name

	character*12	vcb_label

	integer*4	ucb_operation_count

	integer*4	ucb_error_count

	integer*4	caller_label_buffer

	logical*1	lib$get_vm



	call movc5 (%val(search_name_length),%ref(search_name_string),%val(42),
	1 %val(15),%ref(search_name))

	logging_sid_entry_address = root_logging_sid_flink

	do 45,i = 1,logging_sid_entry_count

	call movc3 (%val(24),%val(logging_sid_entry_address),buffer1)

5	if (search_sid .eq. logging_sid) then

	name_entry_address = root_name_flink

	do 35,j = 1,name_entry_count

	call movc3 (%val(36),%val(name_entry_address),buffer2)

10	if (search_name .eq. name_string) then

	unit_entry_address = root_unit_flink

	do 25,k = 1,unit_entry_count

	call movc3 (%val(32),%val(unit_entry_address),buffer3)

15	if (search_unit .eq. ucb_unit_number) then

	goto (50,75,100) entrance
	endif

	unit_entry_address = flink3

25	continue

	goto (28,80,110) entrance

	return

28	continue

	call movc5 (%val(0),,%val(0),%val(32),buffer3)

	if (lib$get_vm(((32+7)/8)*8,unit_entry_address)) then

	call insque (%val(unit_entry_address),%val(root_unit_blink))

	ucb_unit_number = search_unit

	call movc3 (%val(24),ucb_unit_number,%val(unit_entry_address + 8))

	unit_entry_count = unit_entry_count + 1

	call movl (unit_entry_count,%val(name_entry_address + 32))

	goto 15
	endif

	return
	endif

	name_entry_address = flink2

35	continue

	goto (38,80,110) entrance

	return

38	continue

	call movc5 (%val(0),,%val(0),%val(36),buffer2)

	if (lib$get_vm(((36+7)/8)*8,name_entry_address)) then

	call insque (%val(name_entry_address),%val(root_name_blink))

	name_length = search_name_length

	name_string = search_name

	root_unit_flink = name_entry_address + 24

	root_unit_blink = root_unit_flink

	call movc3 (%val(28),name_length,%val(name_entry_address + 8))

	name_entry_count = name_entry_count + 1

	call movl (name_entry_count,%val(logging_sid_entry_address + 20))

	goto 10
	endif

	return
	endif

	logging_sid_entry_address = flink1

45	continue

	goto (48,80,110) entrance

	return

48	continue

	call movc5 (%val(0),,%val(0),%val(24),buffer1)

	if (logging_sid_entry_count .eq. 0) then

	root_logging_sid_flink = %loc(root_logging_sid_flink)

	root_logging_sid_blink = root_logging_sid_flink
	endif

	if (lib$get_vm(((24+7)/8)*8,logging_sid_entry_address)) then

	call insque (%val(logging_sid_entry_address),
	1 %val(root_logging_sid_blink))

	logging_sid = search_sid

	root_name_flink = logging_sid_entry_address + 12

	root_name_blink = root_name_flink

	call movc3 (%val(16),logging_sid,%val(logging_sid_entry_address + 8))

	logging_sid_entry_count = logging_sid_entry_count + 1

	goto 5
	endif

	return

50	continue

c
c	Action routine for MOUNT_VOLUME
c

	label_string = vcb_label

	mount_ucb_operation_count = ucb_operation_count

	mount_ucb_error_count = ucb_error_count

	call movc3 (%val(20),%ref(label_string),%val(unit_entry_address + 12))

	return

75	continue

c
c	Action routine for DISMOUNT_VOLUME
c

	if (vcb_label .eq. label_string) then

	mount_operation_count = mount_ucb_operation_count

	mount_error_count = mount_ucb_error_count

	call remque (%val(unit_entry_address),unit_entry_address)

	call lib$free_vm (((32+7)/8)*8,unit_entry_address)

	unit_entry_count = unit_entry_count - 1

	call movl (unit_entry_count,%val(name_entry_address + 32))

	if (unit_entry_count .eq. 0) then

	call remque (%val(name_entry_address),name_entry_address)

	call lib$free_vm (((36+7)/8)*8,name_entry_address)

	name_entry_count = name_entry_count - 1

	call movl (name_entry_count,%val(logging_sid_entry_address + 20))

	if (name_entry_count .eq. 0) then

	call remque (%val(logging_sid_entry_address),logging_sid_entry_address)

	call lib$free_vm (((24+7)/8)*8,logging_sid_entry_address)

	logging_sid_entry_count = logging_sid_entry_count - 1
	endif
	endif

	return
	endif

80	return

100	continue

c
c	Action routine for GET_CURRENT_LABEL
c

	call movc3 (%val(12),%ref(label_string),caller_label_buffer)

	return

110	return 1

	end




	subroutine mount (lun,option)


	include 'src$:msghdr.for /nolist'

	include	'src$:volmount.for /nolist'




c++
c	Functional description:
c
c	This routine is called by the SYE dispatcher when a MOUNT VOLUME
c	error log entry is read.
c--



	byte		lun

	character*1	option

	integer*4	compress4

	integer*4	lib$extzv

	logical*1	str$trim

	integer*4	emb$t_vm_label_length

	integer*4	mount_operation_count

	integer*4	mount_error_count

	integer*4	volume_operation_count

	integer*4	volume_error_count




	if (option .ne. 'C') then

	call mount_volume (1,emb$l_hd_sid,emb$b_vm_namlng,emb$t_vm_name,
	1 emb$w_vm_unit,emb$t_vm_label,emb$l_vm_oprcnt,emb$l_vm_errcnt)
	endif

	if (
	1 option .eq. 'S'
	1 .or.
	1 option .eq. 'B'
	1 ) then

	call header (lun)

	call logger (lun,'MOUNT VOLUME')

	call linchk (lun,4)

	if (.not. str$trim (emb$t_vm_label,emb$t_vm_label,
	1 emb$t_vm_label_length)) then

	emb$t_vm_label_length = 12
	endif

	write(lun,10) emb$t_vm_name,emb$w_vm_unit,
	1 emb$t_vm_label(1:emb$t_vm_label_length)
10	format('0',t8,'UNIT _',a<emb$b_vm_namlng>,
	1 i<compress4 (lib$extzv(0,16,emb$w_vm_unit))>,':, VOLUME LABEL "',a,
	1 '"',/)


	write(lun,15) emb$l_vm_oprcnt,emb$l_vm_errcnt
15	format(' ',t8,i<compress4 (emb$l_vm_oprcnt)>,
	1 '. QIO OPERATIONS THIS UNIT, ',i<compress4 (emb$l_vm_errcnt)>,
	1 '. ERRORS THIS UNIT')
	endif

	return




	entry dismount (lun,option)



c++
c	Functional description:
c
c	This routine is called when a DISMOUNT VOLUME error log entry is read
c--



	if (option .ne. 'C') then

	mount_operation_count = -1

	mount_error_count = -1

	call dismount_volume (2,emb$l_hd_sid,emb$b_vm_namlng,emb$t_vm_name,
	1 emb$w_vm_unit,emb$t_vm_label,mount_operation_count,
	1 mount_error_count)
	endif

	if (
	1 option .eq. 'S'
	1 .or.
	1 option .eq. 'B'
	1 ) then

	call header (lun)

	call logger (lun,'DISMOUNT VOLUME')

	call linchk (lun,4)

	if (.not. str$trim (emb$t_vm_label,emb$t_vm_label,
	1 emb$t_vm_label_length)) then

	emb$t_vm_label_length = 12
	endif

	write(lun,10) emb$t_vm_name,emb$w_vm_unit,
	1 emb$t_vm_label(1:emb$t_vm_label_length)

	write(lun,15) emb$l_vm_oprcnt,emb$l_vm_errcnt

	if (
	1 mount_operation_count .ne. -1
	1 .and.
	1 mount_error_count .ne. -1
	1 ) then

	volume_operation_count = emb$l_vm_oprcnt - mount_operation_count

	volume_error_count = emb$l_vm_errcnt - mount_error_count

	if (volume_operation_count) 60,25,25

25	if (volume_error_count) 60,30,30

30	call linchk (lun,1)

	write(lun,35) volume_operation_count,volume_error_count
35	format(' ',t8,i<compress4 (volume_operation_count)>,
	1 '. QIO OPERATIONS THIS VOLUME, ',i<compress4 (volume_error_count)>,
	1 '. ERRORS THIS VOLUME')
	endif
	endif

60	return

	end
