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
C	AUTHOR	BRIAN PORTER		CREATION DATE	30-JAN-1980
C

c++
c	Functional description
c
c	This routine maintains a list of counts of error log entry types
c	for different CPU's.  The list has absolute linkage and has the
c	following format.
c
c	+------------------------+
c	I         flink          I
c	+------------------------+
c	I         blink          I
c	+------------------------+
c	I      logging SID       I
c	+------------------------+
c	I    64 bit time of      I
c	+--                    --+
c	I    earliest entry      I
c	+------------------------+
c	I    64 bit time of      I
c	+--                    --+
c	I     latest entry       I
c	+------------------------+
c	I                        I
c	+--                    --+
c	I                        I
c	+--   128 entry type   --+
c	I        buffers         I
c	+--                    --+
c	I                        I
c	+------------------------+
c	I                        I
c	+--                    --+
c	I                        I
c	+--                    --+
c	I                        I
c	+--      48 byte       --+
c	I     histogram buffer   I
c	+--                    --+
c	I                        I
c	+--                    --+
c	I                        I
c	+------------------------+
c
c	Each entry buffer within the list has the following format
c
c	+------------------------+
c	I                        I
c	+-- entry title descr. --+
c	I                        I
c	+------------------------+
c	I complete entry  count  I
c	+------------------------+
c	I incomplete entry count I
c	+------------------------+
c
c	As entries are encountered in the error log file a search of the
c	list is made for a list entry with the same logging SID.  When a
c	match is found then the appropriate entry buffer counter is updated.
c	Valid entry types are in the range 1 to 255.  Complete entry types
c	are from 1 to 127, incomplete types are weighted by 128.
c	Entry title descriptors that are zero indicate that this entry
c	type for the particular logging SID are unknown.
c	The last entry buffer is used to count unknown entry types within
c	and outside of the valid ranges.
c	The histogram buffer is used to display graphically the occurrance
c	of processed records in the file for the given logging sid.
c	The buffer is dimensioned internally into twenty-four 16-bit integer
c	counters.  As a record is processed by SYE the hour of the day
c	value in EMB$Q_HD_TIME is used as an index into the array and the
c	counter incremented.
c
c	Modified by:
c
c	v03-001	BP0014		Brian Porter,		05-APR--1982
c		Added more mscp.
c**
c--



	subroutine entry_summary_update (cpu,entry,class,type)




	include 'src$:msghdr.for /nolist'




	byte		lun

	logical*1	cpu

	logical*1	entry

	logical*1	class

	logical*1	type

	integer*4	buffer1(2)

	integer*4	root_summary_flink

	integer*4	root_summary_blink

	equivalence	(root_summary_flink,buffer1(1))

	equivalence	(root_summary_blink,buffer1(2))

	integer*4	buffer2(531)

	integer*4	flink

	integer*4	blink

	integer*4	logging_sid

	integer*4	earliest_entry_time(2)

	integer*4	latest_entry_time(2)

	integer*4	entry_type_buffer(4,128)

	integer*2	processed_entry_histogram(0:23)

	parameter	entry_title_descriptor_length = 1

	parameter	entry_title_descriptor_address = 2

	parameter	unknown_entry = 3

	parameter	complete_entry = 3

	parameter	incomplete_entry = 4

	equivalence	(flink,buffer2(1))

	equivalence	(blink,buffer2(2))

	equivalence	(logging_sid,buffer2(3))

	equivalence	(earliest_entry_time,buffer2(4))

	equivalence	(latest_entry_time,buffer2(6))

	equivalence	(entry_type_buffer,buffer2(8))

	equivalence	(processed_entry_histogram,buffer2(520))

	integer*4	summary_list_entry_count

	integer*4	lib$extzv

	integer*4	summary_list_entry_address

	logical*1	lib$get_vm

	logical*1	sys$numtim

	character*24	time1

	character*24	time2

	logical*1	possible_invalid_time

	integer*4	timcmp

	integer*2	time_buffer(7)



c++
c	functional description
c
c	This entry point is used to create and update the list entries
c	as the different error log entries for the various logging CPU's
c	making up the error log file are encountered.
c--




	if (root_summary_flink .eq. 0
	1 .and.
	2 root_summary_blink .eq. 0) then

	root_summary_flink = %loc(root_summary_flink)

	root_summary_blink = %loc(root_summary_flink)
	endif

	summary_list_entry_address = root_summary_flink

	do 100,i = 1,summary_list_entry_count

	call movc3 (%val(2076),%val(summary_list_entry_address),flink)

	if (emb$l_hd_sid .eq. logging_sid) then

	possible_invalid_time = .false.

c
c	unknown entry type
c

10	if (.not. entry) then

	entry_type_buffer(unknown_entry,128) =
	1 entry_type_buffer(unknown_entry,128) + 1

	possible_invalid_time = .true.

c
c	incomplete entry type for a known cpu type
c

	else if (
	1 cpu
	1 .and.
	1 entry
	1 .and.
	1 emb$w_hd_entry .ge. 128
	1 ) then

	entry_type_buffer(incomplete_entry,lib$extzv(0,7,emb$w_hd_entry)) =
	1 entry_type_buffer(incomplete_entry,lib$extzv(0,7,emb$w_hd_entry)) + 1

	possible_invalid_time = .true.

c
c	device entry for a known cpu with an unknown device
c

	else if (
	1 cpu
	1 .and.
	1 ((emb$w_hd_entry .eq. 1
	1 .or.
	1 emb$w_hd_entry .eq. 96
	1 .or.
	1 emb$w_hd_entry .eq. 98
	1 .or.
	1 emb$w_hd_entry .eq. 99
	1 .or.
	1 emb$w_hd_entry .eq. 100)
	1 .and.
	1 (.not. class
	1 .or.
	1 .not. type))) then

	entry_type_buffer(unknown_entry,128) =
	1 entry_type_buffer(unknown_entry,128) + 1

c
c	 unknown cpu type (implies that all entries are unknown)
c

	else if (.not. cpu) then

	entry_type_buffer(unknown_entry,128) =
	1 entry_type_buffer(unknown_entry,128) + 1

	possible_invalid_time = .true.

c
c	known entry type for a known cpu
c

	else if (
	1 cpu
	1 .and.
	1 entry
	1 ) then

	entry_type_buffer(complete_entry,emb$w_hd_entry) =
	1 entry_type_buffer(complete_entry,emb$w_hd_entry) + 1
	endif

	if (.not. possible_invalid_time) then

	if (timcmp(emb$q_hd_time,earliest_entry_time)) 20,25,25

20	call movq (emb$q_hd_time,earliest_entry_time)

25	if (timcmp(emb$q_hd_time,latest_entry_time)) 35,35,30

30	call movq (emb$q_hd_time,latest_entry_time)
	endif

35	call movc3 (%val(2068),logging_sid,
	1 %val(summary_list_entry_address + 8))

	return
	endif

	summary_list_entry_address = flink

100	continue

	if (lib$get_vm(((2124+7)/8)*8,summary_list_entry_address)) then

	call movc5 (%val(0),,%val(0),%val(2124),buffer2)

	logging_sid = emb$l_hd_sid

	earliest_entry_time(1) = 'ffffffff'x

	earliest_entry_time(2) = '7fffffff'x

	latest_entry_time(1) = '0'x

	latest_entry_time(2) = '0'x

	call entry_summary_descriptor_load (logging_sid,
	1 entry_type_buffer(entry_title_descriptor_length,1))

	call insque (%val(summary_list_entry_address),%val(root_summary_blink))

	summary_list_entry_count = summary_list_entry_count + 1

	goto 10
	endif

	return



	entry entry_summary_output (lun)



c++
c	functional description
c
c	This entry point is used when the processing of the error log
c	file is finished and the entry summaries are to be output.
c--




	summary_list_entry_address = root_summary_flink

	do 200,i = 1,summary_list_entry_count

	call movc3 (%val(2124),%val(summary_list_entry_address),flink)

c	call set_rab$v_cco

	call frctof (lun)

	call linchk (lun,3)

	write(lun,110) logging_sid
110	format('0','SUMMARY OF ALL ENTRIES LOGGED BY SID ',z8.8,/)

	do 190,j = 1,128

	if (entry_type_buffer(entry_title_descriptor_address,j) .ne. 0) then

	if (entry_type_buffer(complete_entry,j) .ne. 0
	1 .or.
	2 entry_type_buffer(incomplete_entry,j) .ne. 0) then

	call entry_summary_write (lun,
	1 entry_type_buffer(entry_title_descriptor_length,j),
	2 entry_type_buffer(complete_entry,j),
	3 entry_type_buffer(incomplete_entry,j))
	endif
	endif

190	continue

	call linchk (lun,3)

	if (earliest_entry_time(1) .ne. 'ffffffff'x
	1 .and.
	1 earliest_entry_time(2) .ne. '7fffffff'x
	1 .and.
	1 latest_entry_time(1) .ne. '0'x
	1 .and.
	1 latest_entry_time(2) .ne. '0'x) then

	call sys$asctim(,time1,earliest_entry_time,%val(0))

	call sys$asctim(,time2,latest_entry_time,%val(0))

	write(lun,120) time1,time2
120	format('0',t8,'DATE OF EARLIEST ENTRY',t40,a,/,
	1 t8,'DATE OF LATEST ENTRY',t40,a)
	endif

	do 122,j = 0,23

	if (processed_entry_histogram(j) .ne. 0) goto 124

122	continue

	goto 150

124	call linchk (lun,27)

	write(lun,125) logging_sid
125	format('0','PROCESSED ENTRIES HOUR-OF-DAY HISTOGRAM LOGGED BY SID ',
	1 z8.8,/)

	do 145,j = 0,23

	k = min(50,processed_entry_histogram(j))

	write(lun,130) j,processed_entry_histogram(j),('*',l = 1,k)
130	format(' ',t8,i2.2,':00',i7,'. ',<k>a1)

145	continue

150	summary_list_entry_address = flink

200	continue

	return



	entry processed_entries_histo_update


c++
c	Functional description:
c
c	This routine counts the entries that are processed
c	during each hour of the day that they are logged.
c--




	summary_list_entry_address = root_summary_flink

	do 300,i = 1,summary_list_entry_count

	call movc3 (%val(12),%val(summary_list_entry_address),flink)

	if (emb$l_hd_sid .eq. logging_sid) then

	call movc3 (%val(48),%val(summary_list_entry_address + 2076),
	1 processed_entry_histogram)

	if (sys$numtim(time_buffer,emb$q_hd_time)) then

	processed_entry_histogram(time_buffer(4)) =
	1 processed_entry_histogram(time_buffer(4)) + 1

	call movc3 (%val(48),processed_entry_histogram,
	1 %val(summary_list_entry_address + 2076))
	endif

	return
	endif

	summary_list_entry_address = flink

300	continue

	return

	end




	subroutine entry_summary_descriptor_load (logging_sid,buffer)




c++
c	functional description
c
c	This routine constructs the entry type title descriptor
c	for valid entry values for each CPU type.  Unknown entry values
c	for the particular CPU type are left zero.
c--




	integer*4	logging_sid

	integer*4	buffer(2,2,128)

	integer*4	sid_high_byte




	character*21	device_error
	data	device_error		/'DEVICE ERROR BIT SET*'/

	character*14	machine_check
	data	machine_check		/'MACHINE CHECK*'/

	character*10	sbi_fault
	data	sbi_fault		/'SBI FAULT*'/

	character*10	sbi_alert
	data	sbi_alert		/'SBI ALERT*'/

	character*13	soft_ecc
	data	soft_ecc		/'MEMORY ERROR*'/

	character*23	async_write
	data	async_write		/'SBI ASYNCHRONOUS WRITE*'/

	character*16	write_bus_error
	data	write_bus_error		/'WRITE BUS ERROR*'/

	character*19	hard_ecc
	data	hard_ecc		/'FATAL MEMORY ERROR*'/

	character*13	volume_mount
	data	volume_mount		/'VOLUME MOUNT*'/

	character*16	volume_dismount
	data	volume_dismount		/'VOLUME DISMOUNT*'/

	character*16	start_up
	data	start_up		/'SYSTEM START-UP*'/

	character*11	power_fail
	data	power_fail		/'POWER-FAIL*'/

	character*19	new_logfile
	data	new_logfile		/'ERRLOG.SYS CREATED*'/

	character*19	power_start
	data	power_start		/'POWER-FAIL RESTART*'/

	character*15	fatal_bugcheck
	data	fatal_bugcheck		/'FATAL BUGCHECK*'/

	character*11	time_stamp
	data	time_stamp		/'TIME-STAMP*'/

	character*16	ss_message
	data	ss_message		/'$SNDERR MESSAGE*'/

	character*16	sys_bugcheck
	data	sys_bugcheck		/'SYSTEM BUGCHECK*'/

	character*17	op_message
	data	op_message		/'OPERATOR MESSAGE*'/

	character*16	nt_message
	data	nt_message		/'NETWORK MESSAGE*'/

	character*19	device_timeout
	data	device_timeout		/'DEVICE I/O TIMEOUT*'/

	character*20	undefined_int
	data	undefined_int		/'UNDEFINED INTERRUPT*'/

	character*17	device_attention
	data	device_attention	/'DEVICE ATTENTION*'/

	character*14	user_bugcheck
	data	user_bugcheck		/'USER BUGCHECK*'/

	character*14	uba_interrupt
	data	uba_interrupt		/'UBA INTERRUPT*'/

	character*10	uba_error
	data	uba_error		/'UBA ERROR*'/

	character*14	mba_interrupt
	data	mba_interrupt		/'MBA INTERRUPT*'/

	character*19	unknown_entry
	data	unknown_entry		/'UNKNOWN ENTRY TYPE*'/

	character*15	mscp_message
	data	mscp_message		/'ERL$LOGMESSAGE*'/

	character*14	mscp_software_status
	data	mscp_software_status	/'ERL$LOGSTATUS*'/



	sid_high_byte = lib$extzv (24,8,logging_sid)

c
c	11/780
c

	if (sid_high_byte .eq. 255
	1 .or.
	1 sid_high_byte .eq. 1) then

	buffer(2,1,1) = %loc(device_error)

	buffer(2,1,2) = %loc(machine_check)

	buffer(2,1,4) = %loc(sbi_fault)

	buffer(2,1,5) = %loc(sbi_alert)

	buffer(2,1,6) = %loc(soft_ecc)

	buffer(2,1,7) = %loc(async_write)

	buffer(2,1,8) = %loc(hard_ecc)

	buffer(2,1,9) = %loc(uba_interrupt)

	buffer(2,1,12) = %loc(mba_interrupt)

	buffer(2,1,32) = %loc(start_up)

	buffer(2,1,34) = %loc(power_fail)

	buffer(2,1,35) = %loc(new_logfile)

	buffer(2,1,36) = %loc(power_start)

	buffer(2,1,37) = %loc(fatal_bugcheck)

	buffer(2,1,38) = %loc(time_stamp)

	buffer(2,1,39) = %loc(ss_message)

	buffer(2,1,40) = %loc(sys_bugcheck)

	buffer(2,1,41) = %loc(op_message)

	buffer(2,1,42) = %loc(nt_message)

	buffer(2,1,64) = %loc(volume_mount)

	buffer(2,1,65) = %loc(volume_dismount)

	buffer(2,1,96) = %loc(device_timeout)

	buffer(2,1,97) = %loc(undefined_int)

	buffer(2,1,98) = %loc(device_attention)

	buffer(2,1,99) = %loc(mscp_software_status)

	buffer(2,1,100) = %loc(mscp_message)

	buffer(2,1,112) = %loc(user_bugcheck)

c
c	11/750
c

	else if (sid_high_byte .eq. 2) then

	buffer(2,1,1) = %loc(device_error)

	buffer(2,1,2) = %loc(machine_check)

	buffer(2,1,6) = %loc(soft_ecc)

	buffer(2,1,7) = %loc(write_bus_error)

	buffer(2,1,8) = %loc(hard_ecc)

	buffer(2,1,32) = %loc(start_up)

	buffer(2,1,34) = %loc(power_fail)

	buffer(2,1,35) = %loc(new_logfile)

	buffer(2,1,36) = %loc(power_start)

	buffer(2,1,37) = %loc(fatal_bugcheck)

	buffer(2,1,38) = %loc(time_stamp)

	buffer(2,1,39) = %loc(ss_message)

	buffer(2,1,40) = %loc(sys_bugcheck)

	buffer(2,1,41) = %loc(op_message)

	buffer(2,1,42) = %loc(nt_message)

	buffer(2,1,64) = %loc(volume_mount)

	buffer(2,1,65) = %loc(volume_dismount)

	buffer(2,1,96) = %loc(device_timeout)

	buffer(2,1,97) = %loc(undefined_int)

	buffer(2,1,98) = %loc(device_attention)

	buffer(2,1,99) = %loc(mscp_software_status)

	buffer(2,1,100) = %loc(mscp_message)

	buffer(2,1,112) = %loc(user_bugcheck)

c
c	11/7zz
c

	else if (sid_high_byte .eq. 3) then

	buffer(2,1,1) = %loc(device_error)

	buffer(2,1,2) = %loc(machine_check)

	buffer(2,1,6) = %loc(soft_ecc)

	buffer(2,1,8) = %loc(hard_ecc)

	buffer(2,1,11) = %loc(uba_error)

	buffer(2,1,32) = %loc(start_up)

	buffer(2,1,34) = %loc(power_fail)

	buffer(2,1,35) = %loc(new_logfile)

	buffer(2,1,36) = %loc(power_start)

	buffer(2,1,37) = %loc(fatal_bugcheck)

	buffer(2,1,38) = %loc(time_stamp)

	buffer(2,1,39) = %loc(ss_message)

	buffer(2,1,40) = %loc(sys_bugcheck)

	buffer(2,1,41) = %loc(op_message)

	buffer(2,1,42) = %loc(nt_message)

	buffer(2,1,64) = %loc(volume_mount)

	buffer(2,1,65) = %loc(volume_dismount)

	buffer(2,1,96) = %loc(device_timeout)

	buffer(2,1,97) = %loc(undefined_int)

	buffer(2,1,98) = %loc(device_attention)

	buffer(2,1,99) = %loc(mscp_software_status)

	buffer(2,1,100) = %loc(mscp_message)

	buffer(2,1,112) = %loc(user_bugcheck)
	endif

	buffer(2,1,128) = %loc(unknown_entry)

	do 10,i = 1,128

	buffer(1,1,i) = 33

10	continue

	return

	end



	subroutine entry_summary_write (lun,summary_title,complete_count,
	1 incomplete_count)



C++
C
C	This routine writes the summary totals to the listing device.
C
C--




	byte		lun

	character*(*)	summary_title

	integer*4	complete_count

	integer*4	incomplete_count

	integer*4	compress4

	integer*4	compressc

	integer*4	field



	call linchk (lun,1)

	field = compress4 (complete_count)

	write(lun,10) summary_title,complete_count
10	format(' ',t8,a<compressc (summary_title)>,t<47 - field>,
	1 i<field>,'.')

	if (incomplete_count .ne. 0) then

	field = compress4 (incomplete_count)

	call linchk (lun,1)

	write(lun,20) summary_title,incomplete_count
20	format(' ',t8,'INCOMPLETE ',a<compressc (summary_title)>,
	1 t<47 - field>,i<field>,'.')
	endif

	return

	end
