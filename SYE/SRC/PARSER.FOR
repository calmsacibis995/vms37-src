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

c	Author	Brian Porter			Creation date	01-OCT-1981

c++
c	Functional description:
c
c	These routines parse the device name list input by the user,
c	they also do the comparisons against any error log record that
c	is in the input file.
c
c	Modified by:
c**
c--



	subroutine string_parse (names_string,negate,*)



	character*(*)	names_string

	logical*1	negate

	integer*4	device_string_index1

	integer*4	device_string_index2

	character*15	selected_name

	integer*4	selected_name_length

	logical*4	name_wild

	integer*4	selected_unit

	integer*4	selected_negate




10	device_string_index1 = 0

15	device_string_index2 = lib$locc (',',
	1 names_string(device_string_index1 + 1:))

	if (device_string_index2 .ne. 0) then

	call unit_parse (names_string(device_string_index1 + 1:
	1 (device_string_index1 + device_string_index2) - 1),
	1 selected_name,selected_name_length,name_wild,selected_unit,
	1 selected_negate,*20)
	else

	call unit_parse (
	1 names_string(device_string_index1 + 1:),
	1 selected_name,selected_name_length,name_wild,selected_unit,
	1 selected_negate,*20)
	endif

	if (
	1 negate
	1 .and.
	1 selected_negate
	1 ) return 1

	call name_q (selected_name(1:selected_name_length),name_wild,
	1 selected_unit,selected_negate,.false.,)

	if (device_string_index2 .eq. 0) return

	device_string_index1 = device_string_index1 + device_string_index2

	goto 15

20	return 1





	entry name_parse (names_string,negate,*)




	call unit_parse (names_string,selected_name,selected_name_length,
	1 name_wild,selected_unit,selected_negate,*20)

	call name_q (selected_name(1:selected_name_length),name_wild,
	1 selected_unit,selected_negate,.false.,)

	return

	end




	subroutine unit_parse (device_string,selected_name,
	1 selected_name_length,name_wild,selected_unit,selected_negate,*)



	character*(*)	device_string

	character*15	selected_name

	integer*4	selected_name_length

	logical*4	name_wild

	integer*4	selected_unit

	logical*4	selected_negate

	integer*4	device_string_length

	character*15	unit_string




	name_wild = .false.

	selected_unit = -1

	selected_negate = .false.

	i = 1

	j = 1

	device_string_length = len(device_string)

	if (device_string_length .eq. 0) return 1

	if (device_string(1:1) .eq. '-') then

	selected_negate = .true.

	if (negate) return 1

	j = 2
	endif

	do while (
	1 (device_string(j:j) .ge. 'A'
	1 .and.
	1 device_string(j:j) .le. 'Z')
	1 )

	selected_name(i:i) = device_string(j:j)

	selected_name_length = i

	i = i + 1

	j = j + 1
	enddo

	if (device_string(j:j) .eq. '*') then

	name_wild = .true.

	j = j + 1
	endif

	do while (
	1 (device_string(j:j) .ge. '0'
	1 .and.
	1 device_string(j:j) .le. '9')
	1 )

	selected_unit = (ichar(device_string(j:j))-48) +
	1 (max(0,selected_unit)*10)

	j = j + 1
	enddo

	if (
	1 (j .eq. device_string_length
	1 .and.
	1 device_string(j:j) .ne. ':')
	1 .or.
	1 j .lt. device_string_length
	1 ) then

	return 1
	endif

	return

	end	




c++
c
c	The following routine maintains a list of device names that the user
c	has input for input file processing.  The format of each list
c	entry is as follows.
c
c	+------------------------------+
c	|             flink            |
c	+------------------------------+
c	|             blink            |
c	+------------------------------+
c	|                              |
c	+--                          --+
c	|                              |
c	+--      selected name       --+
c	|       (counted ascii)        |
c	+--                          --+
c	|                              |
c	+------------------------------+
c	|      selected name wild      |
c	+------------------------------+
c	|        selected unit         |
c	+------------------------------+
c	|       selected negate        |
c	+------------------------------+
c
c--





	subroutine name_q (search_name,name_wild,search_unit,negate,
	1 search_mode,*)




	character*(*)	search_name

	logical*4	name_wild

	integer*4	search_unit

	integer*4	negate

	logical*4	search_mode

	integer*4	buffer(11)

	integer*4	root_flink

	integer*4	root_blink

	integer*4	flink

	integer*4	blink

	byte		selected_name_array(16)

	byte		selected_name_length

	equivalence	(selected_name_array,selected_name_length)

	character*15	selected_name

	equivalence	(selected_name_array(2),selected_name)

	logical*4	selected_name_wild

	integer*4	selected_unit

	logical*4	selected_negate

	equivalence	(buffer(1),root_flink)

	equivalence	(buffer(2),root_blink)

	equivalence	(buffer(3),flink)

	equivalence	(buffer(4),blink)

	equivalence	(buffer(5),selected_name_array)

	equivalence	(buffer(9),selected_name_wild)

	equivalence	(buffer(10),selected_unit)

	equivalence	(buffer(11),selected_negate)

	integer*4	name_queue_entry_count

	integer*4	name_queue_entry_address

	logical*4	lib$get_vm

	logical*1	wild_name_match

	logical*1	name_match

	logical*1	wild_unit_match

	logical*1	unit_match

	logical*1	selected



	call movc5 (%val(0),,%val(0),%val(36),buffer(3))

	name_queue_entry_address = root_flink

	if (search_mode) selected = .false.

	do 100,i = 1,name_queue_entry_count

	call movc3 (%val(36),%val(name_queue_entry_address),buffer(3))

	if (search_mode) then

	wild_name_match = .false.

	name_match = .false.

	wild_unit_match = .false.

	unit_match = .false.

	if (selected_name_wild) then

	if (
	1 search_name(1:min(lib$extzv(0,8,selected_name_length),
	1 len(search_name)))
	1 .eq.
	1 selected_name(1:min(lib$extzv(0,8,selected_name_length),
	1 len(search_name)))
	1 ) then

	wild_name_match = .true.
	endif
	else

	if (
	1 search_name(1:max(lib$extzv(0,8,selected_name_length),
	1 len(search_name)))
	1 .eq.
	1 selected_name(1:max(lib$extzv(0,8,selected_name_length),
	1 len(search_name)))
	1 ) then

	name_match = .true.
	endif
	endif

	if (
	1 wild_name_match
	1 .or.
	1 name_match
	1 ) then

	if (selected_unit .eq. -1) then

	wild_unit_match = .true.

	else if (search_unit .eq. selected_unit) then

	unit_match = .true.
	endif
	endif

	if (
	1 (wild_name_match
	1 .or.
	1 name_match)
	1 .and.
	1 (wild_unit_match
	1 .or.
	1 unit_match)
	1 ) then

	selected = .true.

	if (selected_negate) selected = .false.
	endif
	endif

	name_queue_entry_address = flink

100	continue

	if (.not. search_mode) then

	if (name_queue_entry_count .eq. 0) then

	root_flink = %loc(root_flink)

	root_blink = root_flink
	endif

	call movc5 (%val(0),,%val(0),%val(36),buffer(3))

	if (lib$get_vm(((36+7)/8)*8,name_queue_entry_address)) then

	call insque (%val(name_queue_entry_address),%val(root_blink))

	selected_name_length = len(search_name)

	selected_name = search_name

	selected_name_wild = name_wild

	selected_unit = search_unit

	selected_negate = negate

	call movc3 (%val(28),buffer(5),%val(name_queue_entry_address + 8))

	name_queue_entry_count = name_queue_entry_count + 1
	endif

	return
	endif

	if (selected) return

	return 1

	end
