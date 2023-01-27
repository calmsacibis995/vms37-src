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
C		AUTHOR	BRIAN PORTER		CREATION DATE	10-SEP-1980

C++
C	Functional description:
C
C	This module displays the device error roll-up report.
C
C	Modified by:
C
C	v03-001	BP0004		Brian Porter,		05-APR-1982
C		Added stuff for mscp.
C**
C--

C++
C
C	+---------------------------------+
C	|             flink1              |
C	+---------------------------------+
C	|             blink1              |
C	+---------------------------------+
C	|           logging sid           |
C	+---------------------------------+
C	|         root name flink         |
C	+---------------------------------+
C	|         root name blink         |
C	+---------------------------------+
C	|        name entry count         |
C	+---------------------------------+
C
C
C	+---------------------------------+
C	|             flink2              |
C	+---------------------------------+
C	|             blink2              |
C	+---------------------------------+
C	|                                 |
C	+--                             --+
C	|         16 bytes for name       |
C	+--                             --+
C	|              string             |
C	+--                             --+
C	|                                 |
C	+---------------------------------+
C	|          root unit flink        |
C	+---------------------------------+
C	|          root unit blink        |
C	+---------------------------------+
C	|          unit entry count       |
C	+---------------------------------+
C
C
C	+---------------------------------+
C	|             flink3              |
C	+---------------------------------+
C	|             blink3              |
C	+---------------------------------+
C	|          ucb unit number        |
C	+---------------------------------+
C	|     device hard error count     |
C	+---------------------------------+
C	|     device soft error count     |
C	+---------------------------------+
C	|     timeout hard error count    |
C	+---------------------------------+
C	|     timeout soft error count    |
C	+---------------------------------+
C	|    ucb unit operation count     |
C	+---------------------------------+
C	|     ucb unit error count        |
C	+---------------------------------+
C	|           pack count            |
C	+---------------------------------+
C	|                                 |
C	+--                             --+
C	|          current label          |
C	+--        previous error       --+
C	|                                 |
C	+---------------------------------+
C--


	subroutine rollup (search_sid,search_name_length,search_name_string,
	1 search_unit,entry_type,iosb,ucb$l_opcnt,ucb$w_errcnt)



	byte		lun

	integer*4	buffer0(3)

	integer*4	root_logging_sid_flink

	integer*4	root_logging_sid_blink

	integer*4	logging_sid_entry_count

	equivalence	(buffer0(1),root_logging_sid_flink)

	equivalence	(buffer0(2),root_logging_sid_blink)

	equivalence	(buffer0(3),logging_sid_entry_count)

	integer*4	buffer1(6)

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

	integer*4	buffer2(9)

	integer*4	flink2

	integer*4	blink2

	byte		name_string_array(0:15)

	byte		name_string_length

	character*15	name_string

	equivalence	(name_string_array(0),name_string_length)

	equivalence	(name_string_array(1),name_string)

	integer*4	root_unit_flink

	integer*4	root_unit_blink

	integer*4	unit_entry_count

	equivalence	(buffer2(1),flink2)

	equivalence	(buffer2(2),blink2)

	equivalence	(buffer2(3),name_string_array)

	equivalence	(buffer2(7),root_unit_flink)

	equivalence	(buffer2(8),root_unit_blink)

	equivalence	(buffer2(9),unit_entry_count)

	integer*4	buffer3(13)

	integer*4	flink3

	integer*4	blink3

	integer*4	ucb_unit_number

	integer*4	device_hard_error_count

	integer*4	device_soft_error_count

	integer*4	timeout_hard_error_count

	integer*4	timeout_soft_error_count

	integer*4	ucb_unit_operation_count

	integer*4	ucb_unit_error_count

	integer*4	pack_count

	byte		previous_label_at_error_array(12)

	character*12	previous_label_at_error

	equivalence	(previous_label_at_error_array,previous_label_at_error)

	equivalence	(buffer3(1),flink3)

	equivalence	(buffer3(2),blink3)

	equivalence	(buffer3(3),ucb_unit_number)

	equivalence	(buffer3(4),device_hard_error_count)

	equivalence	(buffer3(5),device_soft_error_count)

	equivalence	(buffer3(6),timeout_hard_error_count)

	equivalence	(buffer3(7),timeout_soft_error_count)

	equivalence	(buffer3(8),ucb_unit_operation_count)

	equivalence	(buffer3(9),ucb_unit_error_count)

	equivalence	(buffer3(10),pack_count)

	equivalence	(buffer3(11),previous_label_at_error_array)

	integer*4	logging_sid_entry_address

	integer*4	name_entry_address

	integer*4	unit_entry_address

	character*15	search_name

	character*12	current_label_at_error

	logical*1	lib$extzv

	logical*1	lib$get_vm

	integer*4	search_sid

	byte		search_name_length

	character*15	search_name_string

	integer*2	search_unit

	integer*2	entry_type

	integer*4	compress4

	integer*4	column

	integer*4	iosb

	integer*4	ucb$l_opcnt

	integer*2	ucb$w_errcnt

	integer*4	device_count

	integer*4	insert_blink



	call movc5 (%val(search_name_length),%ref(search_name_string),%val(42),
	1 %val(15),%ref(search_name))

	logging_sid_entry_address = root_logging_sid_flink

	do 50,i = 1,logging_sid_entry_count

	call movc3 (%val(24),%val(logging_sid_entry_address),buffer1)

5	if (search_sid .eq. logging_sid) then

	name_entry_address = root_name_flink

	do 40,j = 1,name_entry_count

	call movc3 (%val(36),%val(name_entry_address),buffer2)

10	if (search_name .eq. name_string) then

	unit_entry_address = root_unit_flink

	do 30,k = 1,unit_entry_count

	call movc3 (%val(52),%val(unit_entry_address),buffer3)

15	if (search_unit .eq. ucb_unit_number) then

	if (
	1 ucb$l_opcnt .ne. -1
	1 .and.
	1 ucb$w_errcnt .ne. -1
	1 ) then

	if (
	1 ucb_unit_operation_count .eq. -1
	1 .and.
	1 ucb_unit_error_count .eq. -1
	1 ) then

	ucb_unit_operation_count = 0

	ucb_unit_error_count = 0
	endif

	ucb_unit_operation_count = ucb$l_opcnt

	ucb_unit_error_count = ucb$w_errcnt
	endif

	if (iosb .ne. -1) then

	if (
	1 entry_type .eq. 1
	1 .or.
	1 entry_type .eq. 98
	1 .or.
	1 entry_type .eq. 99
	1 .or.
	1 entry_type .eq. 100
	1 ) then

	if (lib$extzv(0,1,iosb) .eq. 1) then

	if (device_soft_error_count .eq. -1) then

	device_soft_error_count = 0
	endif

	device_soft_error_count = device_soft_error_count + 1
	else

	if (device_hard_error_count .eq. -1) then

	device_hard_error_count = 0
	endif

	device_hard_error_count = device_hard_error_count + 1
	endif

	else if (entry_type .eq. 96) then

	if (lib$extzv(0,1,iosb) .eq. 1) then

	if (timeout_soft_error_count .eq. -1) then

	timeout_soft_error_count = 0
	endif

	timeout_soft_error_count = timeout_soft_error_count + 1
	else

	if (timeout_hard_error_count .eq. -1) then

	timeout_hard_error_count = 0
	endif

	timeout_hard_error_count = timeout_hard_error_count + 1
	endif
	endif
	endif

	call get_current_label(3,search_sid,search_name_length,
	1 search_name_string,search_unit,%ref(current_label_at_error),*20)

	if (current_label_at_error .ne. previous_label_at_error) then

	pack_count = pack_count + 1

	previous_label_at_error = current_label_at_error
	endif

20	call movc3 (%val(44),ucb_unit_number,%val(unit_entry_address + 8))

	return
	endif

	insert_blink = blink3

	if (ucb_unit_number .gt. search_unit) goto 35

	unit_entry_address = flink3

30	continue

	insert_blink = root_unit_blink

35	call movc5 (%val(0),,%val(0),%val(52),buffer3)

	if (lib$get_vm(((52+7)/8)*8,unit_entry_address)) then

	call insque (%val(unit_entry_address),%val(insert_blink))

	ucb_unit_number = search_unit

	device_hard_error_count = -1

	device_soft_error_count = -1

	timeout_hard_error_count = -1

	timeout_soft_error_count = -1

	ucb_unit_operation_count = -1

	ucb_unit_error_count = -1

	unit_entry_count = unit_entry_count + 1

	call movl (unit_entry_count,%val(name_entry_address + 32))

	goto 15
	endif

	return
	endif

	name_entry_address = flink2

40	continue

	call movc5 (%val(0),,%val(0),%val(36),buffer2)

	if (lib$get_vm(((36+7)/8)*8,name_entry_address)) then

	call insque (%val(name_entry_address),%val(root_name_blink))

	name_string_length = search_name_length

	name_string = search_name

	root_unit_flink = name_entry_address + 24

	root_unit_blink = root_unit_flink

	call movc3 (%val(28),name_string_length,%val(name_entry_address + 8))

	name_entry_count = name_entry_count + 1

	call movl (name_entry_count,%val(logging_sid_entry_address + 20))

	goto 10
	endif

	return
	endif

	logging_sid_entry_address = flink1

50	continue

	call movc5 (%val(0),,%val(0),%val(24),buffer1)

	if (lib$get_vm(((24+7)/8)*8,logging_sid_entry_address)) then

	if (logging_sid_entry_count .eq. 0) then

	root_logging_sid_flink = %loc(root_logging_sid_flink)

	root_logging_sid_blink = root_logging_sid_flink
	endif

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




	entry display_rollup (lun)




	logging_sid_entry_address = root_logging_sid_flink

	do 100,i = 1,logging_sid_entry_count

	call movc3 (%val(24),%val(logging_sid_entry_address),buffer1)

	call frctof (lun)

	call linchk (lun,7)

	write(lun,55) logging_sid
55	format('0','DEVICE ROLLUP LOGGED BY SID ',z8.8,:a,/)

	write(lun,60)
60	format('0','DEVICE',t16,'ERROR BITS',t44,'ERRORS THIS',
	1 t57,'QIOS THIS',/,
	1 t19,'SET',t31,'QIO TIMEOUT',t46,'SESSION',t58,'SESSION')

	write(lun,65)
65	format('0',t14,'[HARD]',t21,'[SOFT]',
	1 t29,'[HARD]',t36,'[SOFT]')

	device_count = 0

	name_entry_address = root_name_flink

	do 90,j = 1,name_entry_count

	call movc3 (%val(36),%val(name_entry_address),buffer2)

	unit_entry_address = root_unit_flink

	do 80,k = 1,unit_entry_count

	if (device_count .eq. 23) then

	call frctof (lun)

	device_count = 0
	endif

	call movc3 (%val(44),%val(unit_entry_address),buffer3)

	call linchk (lun,2)

	write(lun,66)
66	format(' ',:)

	write(lun,67) name_string,ucb_unit_number
67	format('$','_',a<name_string_length>,
	1 i<compress4 (ucb_unit_number)>,':')

	column = name_string_length + (compress4 (ucb_unit_number)) + 2

	if (device_hard_error_count .ne. -1) then

	write(lun,69) device_hard_error_count
69	format('+',tr<12-column>,i5,'.',$)

	column = column + (12-column) + 6
	endif

	if (device_soft_error_count .ne. -1) then

	write(lun,71) device_soft_error_count
71	format('+',tr<19-column>,i5,'.',$)

	column = column + (19-column) + 6
	endif

	if (timeout_hard_error_count .ne. -1) then

	write(lun,73) timeout_hard_error_count
73	format('+',tr<27-column>,i5,'.',$)

	column = column + (27-column) + 6
	endif

	if (timeout_soft_error_count .ne. -1) then

	write(lun,75) timeout_soft_error_count
75	format('+',tr<34-column>,i5,'.',$)

	column = column + (34-column) + 6
	endif

	if (ucb_unit_error_count .ne. -1) then

	write(lun,77) ucb_unit_error_count
77	format('+',tr<44-column>,i6,'.',$)

	column = column + (44-column) + 7
	endif

	if (ucb_unit_operation_count .ne. -1) then

	write(lun,79) ucb_unit_operation_count
79	format('+',tr<55-column>,i7,'.')
	endif

	device_count = device_count + 1

	unit_entry_address = flink3

80	continue

	name_entry_address = flink2

90	continue

	logging_sid_entry_address = flink1

100	continue

	return
	
	end
