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
C	AUTHOR	BRIAN PORTER		CREATION DATE	22-MAY-1980
C
C

c++
c	Modified by:
c
c	v02-004	BP0004		Brian Porter,		23-JAN-1982
c		Made label list alphabetical.
c
c	v02-003	BP0003		Brian Porter,		16-NOV-1981
c		Added control-o code.
c
c	v02-002	BP0002		Brian Porter,		06-MAY-1981
c		Added an extra linefeed to the 'volume' herald.  Removed
c		RETURN 1 argument.
c
c	v02-001	BP0001		Brian Porter,		27-JAN-1981
c		Added code to put unit's in ascending order.  Added code
c		to reprint label heading for devices of different names.
c
c	Functional description:
c
c	This routine maintains a four dimensional list that keeps
c	track of the errors that occur on unique volume labels
c	as they traverse various devices.
c
c	The first dimension has absolute linkage and the following format.
c
c	+----------------------------------+
c	I             flink1               I
c	+----------------------------------+
c	I             blink1               I
c	+----------------------------------+
c	I           logging SID            I
c	+----------------------------------+
c	I         root label flink         I
c	+----------------------------------+
c	I         root label blink         I
c	+----------------------------------+
c	I         label entry count        I
c	+----------------------------------+
c
c	The second dimension has absolute linkage and the following format.
c
c	+------------------------+
c	I         flink2         I
c	+------------------------+
c	I         blink2         I
c	+------------------------+
c	I                        I
c	+--                    --+
c	I  12 byte label field   I
c	+--                    --+
c	I                        I
c	+------------------------+
c	I     root name flink    I
c	+------------------------+
c	I     root name blink    I
c	+------------------------+
c	I     name entry count   I
c	+------------------------+
c
c	The third dimension has absolute linkage and the following format.
c
c	+---------------------------+
c	I          flink3           I
c	+---------------------------+
c	I          blink3           I
c	+---------------------------+
c	I                           I
c	+--                       --+
c	I       16 byte name        I
c	+--                       --+
c	I          field            I
c	+--                       --+
c	I                           I
c	+---------------------------+
c	I      root unit flink      I
c	+---------------------------+
c	I      root unit blink      I
c	+---------------------------+
c	I      unit entry count     I
c	+---------------------------+
c
c	The fourth dimension has absolute linkage and the following format
c
c	+---------------------------+
c	I          flink4           I
c	+---------------------------+
c	I          blink4           I
c	+---------------------------+
c	I       ucb unit number     I
c	+---------------------------+
c	I   mount operation count   I
c	+---------------------------+
c	I   mount error count       I
c	+---------------------------+
c	I dismount operation count  I
c	+---------------------------+
c	I  dismount error count     I
c	+---------------------------+
c	I      mount count          I
c	+---------------------------+
c	I      mounted flag         I
c	+---------------------------+
c	I   mount before dismount   I
c	+---------------------------+
c	I  last mount operation cnt I
c	+---------------------------+
c	I  last mount error count   I
c	+---------------------------+
c
c	Subroutine LABEL is called whenever mount/dismount or device
c	error/timeout entries are encountered.
c
c	If the entry type is mount then an a search is made for a list entry
c	where the device name,	volume label and unit number are the same as
c	the error log entry.  If found then the counters for that list entry
c	are updated, otherwise a new list entry is created.
c	If the entry type is dismount then a search is made for a list entry
c	that corresponds to this device name,volume label and unit number.
c
c	To overcome the problem of random mounts and dismounts of the same
c	volume label on a particular drive two boolean variables and
c	two counters are used.  The boolean variables are used to synchronize
c	correctness of mount/dismount sequences, the counters are used to
c	store values of operation and error counts for individual units for
c	particular volume labels.
c**
c--


	subroutine label (entrance,search_sid,search_name_length,
	1 search_name_string,search_unit,search_label,operation_count,
	1 error_count)




	byte		lun

	integer*4	buffer0(2)

	integer*4	buffer1(6)

	integer*4	buffer2(8)

	integer*4	buffer3(9)

	integer*4	buffer4(12)

	integer*4	root_logging_sid_flink

	integer*4	root_logging_sid_blink

	equivalence	(buffer0(1),root_logging_sid_flink)

	equivalence	(buffer0(2),root_logging_sid_blink)

	integer*4	flink1

	integer*4	blink1

	integer*4	logging_sid

	integer*4	root_label_flink

	integer*4	root_label_blink

	integer*4	label_entry_count

	equivalence	(buffer1(1),flink1)

	equivalence	(buffer1(2),blink1)

	equivalence	(buffer1(3),logging_sid)

	equivalence	(buffer1(4),root_label_flink)

	equivalence	(buffer1(5),root_label_blink)

	equivalence	(buffer1(6),label_entry_count)

	integer*4	flink2

	integer*4	blink2

	byte		label_array(12)

	character*12	label_string

	integer*4	root_name_flink

	integer*4	root_name_blink

	integer*4	name_entry_count

	equivalence	(buffer2(1),flink2)

	equivalence	(buffer2(2),blink2)

	equivalence	(buffer2(3),label_array)

	equivalence	(label_array,label_string)

	equivalence	(buffer2(6),root_name_flink)

	equivalence	(buffer2(7),root_name_blink)

	equivalence	(buffer2(8),name_entry_count)

	integer*4	flink3

	integer*4	blink3

	byte		name_array(16)

	byte		name_length

	character*15	name_string

	integer*4	root_unit_flink

	integer*4	root_unit_blink

	integer*4	unit_entry_count

	equivalence	(buffer3(1),flink3)

	equivalence	(buffer3(2),blink3)

	equivalence	(buffer3(3),name_array)

	equivalence	(name_array,name_length)

	equivalence	(name_array(2),name_string)

	equivalence	(buffer3(7),root_unit_flink)

	equivalence	(buffer3(8),root_unit_blink)

	equivalence	(buffer3(9),unit_entry_count)

	integer*4	flink4

	integer*4	blink4

	integer*4	ucb_unit_number

	integer*4	ucb_mount_operation_count

	integer*4	ucb_mount_error_count

	integer*4	ucb_dismount_operation_count

	integer*4	ucb_dismount_error_count

	integer*4	sye_mount_count

	logical*4	mounted

	logical*4	mount_before_dismount

	integer*4	last_valid_mount_opration_count

	integer*4	last_valid_mount_error_count

	equivalence	(buffer4(1),flink4)

	equivalence	(buffer4(2),blink4)

	equivalence	(buffer4(3),ucb_unit_number)

	equivalence	(buffer4(4),ucb_mount_operation_count)

	equivalence	(buffer4(5),ucb_mount_error_count)

	equivalence	(buffer4(6),ucb_dismount_operation_count)

	equivalence	(buffer4(7),ucb_dismount_error_count)

	equivalence	(buffer4(8),sye_mount_count)

	equivalence	(buffer4(9),mounted)

	equivalence	(buffer4(10),mount_before_dismount)

	equivalence	(buffer4(11),last_valid_mount_opration_count)

	equivalence	(buffer4(12),last_valid_mount_error_count)

	integer*4	logging_sid_entry_count

	integer*4	logging_sid_entry_address

	integer*4	label_entry_address

	integer*4	name_entry_address

	integer*4	unit_entry_address

	integer*4	search_sid

	integer*4	entrance

	integer*2	search_unit

	character*15	search_name_string

	character*15	search_name

	byte		search_name_length

	character*12	search_label

	logical*1	lib$get_vm

	integer*4	lib$extzv

	integer*4	compress4

	integer*4	operation_count

	integer*4	error_count

	integer*4	label_operation_count

	integer*4	label_error_count

	logical*1	label_herald_printed

	logical*1	sid_herald_printed

	byte		operation_width

	byte		error_width

	byte		mount_width

	integer*4	insert_blink

	character*15	previous_name_string




	call movc5 (%val(search_name_length),%ref(search_name_string),%val(42),
	1 %val(15),%ref(search_name))

	logging_sid_entry_address = root_logging_sid_flink

	do 100,i = 1,logging_sid_entry_count

	call movc3 (%val(24),%val(logging_sid_entry_address),buffer1)

5	if (logging_sid .eq. search_sid) then

	label_entry_address = root_label_flink

	do 90,j = 1,label_entry_count

	call movc3 (%val(32),%val(label_entry_address),buffer2)

8	if (search_label .eq. label_string) then

	name_entry_address = root_name_flink

	do 80,k = 1,name_entry_count

	call movc3 (%val(36),%val(name_entry_address),buffer3)

10	if (search_name .eq. name_string) then

	unit_entry_address = root_unit_flink

	do 60,l = 1,unit_entry_count

	call movc3 (%val(48),%val(unit_entry_address),buffer4)

15	if (search_unit .eq. ucb_unit_number) then

	goto (300,400) entrance

	return
	endif

	insert_blink = blink4

	if (ucb_unit_number .gt. search_unit) goto 65

	unit_entry_address = flink4

60	continue

	insert_blink = root_unit_blink

65	if (entrance .eq. 2) return

	call movc5 (%val(0),,%val(0),%val(48),buffer4)

	if(lib$get_vm(((48+7)/8)*8,unit_entry_address)) then

	call insque (%val(unit_entry_address),%val(insert_blink))

	ucb_unit_number = search_unit

	unit_entry_count = unit_entry_count + 1

	call movl (unit_entry_count,%val(name_entry_address + 32))

	goto 15
	endif

	return
	endif

	name_entry_address = flink3

80	continue

	if (entrance .eq. 2) return

	call movc5 (%val(0),,%val(0),%val(36),buffer3)

	if (lib$get_vm(((36+7)/8)*8,name_entry_address)) then

	call insque (%val(name_entry_address),%val(root_name_blink))

	name_length = search_name_length

	name_string = search_name

	root_unit_flink = name_entry_address + 24

	root_unit_blink = root_unit_flink

	call movc3 (%val(28),name_length,%val(name_entry_address + 8))

	name_entry_count = name_entry_count + 1

	call movl (name_entry_count,%val(label_entry_address + 28))

	goto 10	
	endif

	return
	endif

	insert_blink = blink2

	do 85,m = 1,12

	if (ichar(label_string(m:m)) - ichar(search_label(m:m))) 87,85,95

85	continue

87	label_entry_address = flink2

90	continue

	insert_blink = root_label_blink

95	if (entrance .eq. 2) return

	call movc5 (%val(0),,%val(0),%val(32),buffer2)

	if (lib$get_vm(((32+7)/8)*8,label_entry_address)) then

	call insque (%val(label_entry_address),%val(insert_blink))

	root_name_flink = label_entry_address + 20

	root_name_blink = root_name_flink

	label_string = search_label

	call movc3 (%val(24),%ref(label_string),%val(label_entry_address + 8))

	label_entry_count = label_entry_count + 1

	call movl (label_entry_count,%val(logging_sid_entry_address + 20))

	goto 8
	endif

	return
	endif

	logging_sid_entry_address = flink1

100	continue

	if (entrance .eq. 2) return

	call movc5 (%val(0),,%val(0),%val(24),buffer1)

	if (lib$get_vm(((24+7)/8)*8,logging_sid_entry_address)) then

	if (logging_sid_entry_count .eq. 0) then

	root_logging_sid_flink = %loc(root_logging_sid_flink)

	root_logging_sid_blink = %loc(root_logging_sid_flink)
	endif

	call insque (%val(logging_sid_entry_address),
	1 %val(root_logging_sid_blink))

	logging_sid = search_sid

	root_label_flink = logging_sid_entry_address + 12

	root_label_blink = root_label_flink

	logging_sid_entry_count = logging_sid_entry_count + 1

	call movc3 (%val(16),logging_sid,%val(logging_sid_entry_address + 8))

	goto 5
	endif

	return




	entry label_out (lun)




	logging_sid_entry_address = root_logging_sid_flink

	do 200,i = 1,logging_sid_entry_count

	call movc3 (%val(24),%val(logging_sid_entry_address),buffer1)

	sid_herald_printed = .false.

	label_entry_address = root_label_flink

	do 195,j = 1,label_entry_count

	label_herald_printed = .false.

	call movc3 (%val(32),%val(label_entry_address),buffer2)

	name_entry_address = root_name_flink

	do 190,k = 1,name_entry_count

	call movc3 (%val(36),%val(name_entry_address),buffer3)

	unit_entry_address = root_unit_flink

	do 185,l = 1,unit_entry_count

	call movc3 (%val(48),%val(unit_entry_address),buffer4)

	if (sye_mount_count .ne. 0) then

	if (.not. sid_herald_printed) then

c	call set_rab$v_cco

	call frctof (lun)

	call linchk (lun,3)

	write(lun,105) logging_sid
105	format('0','VOLUME LABEL(S) LOGGED BY SID ',z8.8,//,
	1 t34,'QIO(S)',t44,'ERROR(S)',t54,'MOUNT(S)')

	sid_herald_printed = .true.
	endif

	if (name_string .ne. previous_name_string)
	1 label_herald_printed = .false.

	if (.not. label_herald_printed) then

	call linchk (lun,3)

	write(lun,110) label_string
110	format('0',t8,'LABEL -- ',a,/)

	label_herald_printed = .true.
	endif

	label_operation_count = ucb_dismount_operation_count -
	1 ucb_mount_operation_count

	label_error_count = ucb_dismount_error_count - ucb_mount_error_count

	operation_width = compress4 (label_operation_count)

	error_width = compress4 (label_error_count)

	mount_width = compress4 (sye_mount_count)

	call linchk (lun,1)

	write(lun,115) name_string(1:name_length),ucb_unit_number,
	1 label_operation_count,label_error_count,sye_mount_count
115	format(' ',t8,'_',a<name_length>,i<compress4 (ucb_unit_number)>,':',
	1 t<40 - operation_width>,i<operation_width>,'.',
	1 t<52 - error_width>,i<error_width>,'.',
	1 t<62 - mount_width>,i<mount_width>,'.')
	endif

	unit_entry_address = flink4

	previous_name_string = name_string

185	continue

	name_entry_address = flink3

190	continue

	label_entry_address = flink2

195	continue

	logging_sid_entry_address = flink1

200	continue

	return
c
c	action routine for MOUNT VOLUME calls
c

300	continue

	last_valid_mount_opration_count = operation_count

	last_valid_mount_error_count = error_count

	mounted = .true.

	call movc3 (%val(40),ucb_unit_number,%val(unit_entry_address + 8))

	return

c
c	action routine for DISMOUNT VOLUME calls
c

400	continue

	if (mounted) then

	if (operation_count .ge. last_valid_mount_opration_count
	1 .and.
	1 error_count .ge. last_valid_mount_error_count) then

	ucb_mount_operation_count = ucb_mount_operation_count +
	1 last_valid_mount_opration_count

	ucb_mount_error_count = ucb_mount_error_count +
	1 last_valid_mount_error_count

	ucb_dismount_operation_count = ucb_dismount_operation_count +
	1 operation_count

	ucb_dismount_error_count = ucb_dismount_error_count + error_count

	sye_mount_count = sye_mount_count + 1

	mounted = .false.

	call movc3 (%val(40),ucb_unit_number,%val(unit_entry_address + 8))
	endif
	endif

	return

	end
