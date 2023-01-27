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

c	Author	Brian Porter			Creation date	10-FEB-1982

c++
c	Functional description:
c
c	This module displays entries logged by dudriver.
c
c	Modified by:
c
c	v03-001	BP0001		Brian Porter,		19-APR-1982
c		Made changes to accomodate invalid command mscp messages.
c**
c--



	subroutine dudriver_mscp_dispatcher (lun,option,reccnt,
	1 mount_flag_and_label)



	include 'src$:msghdr.for /nolist'

	include 'src$:emblmdef.for /nolist'

	include 'src$:embspdef.for /nolist'



	byte		lun

	character*1	option

	integer*4	reccnt

	integer*4	mount_flag_and_label

	byte		mslg$b_format
	equivalence	(emb(46),mslg$b_format)


	
	if (emb$w_hd_entry .eq. 100) then

	if (emb$w_lm_msgtyp .eq. 1) then

	call frctof (lun)

	call header2 (lun,reccnt)

	call logger (lun,'ERL$LOGMESSAGE ENTRY')

	call dhead3 (lun,'I/O',emb$b_lm_namlng,emb$t_lm_name,emb$w_lm_unit,
	1 mount_flag_and_label)

	if (mslg$b_format .eq. 0) then

	if (option .eq. 'S') then

	call mslg$k_cnt_err (lun)
	endif

	else if (mslg$b_format .eq. 1) then

	if (option .eq. 'S') then

	call mslg$k_bus_addr (lun)
	endif

	else if (mslg$b_format .eq. 2) then

	if (option .eq. 'S') then

	call mslg$k_disk_trn (lun)
	endif

	else if (mslg$b_format .eq. 3) then

	if (option .eq. 'S') then

	call mslg$k_sdi (lun)
	endif

	else if (mslg$b_format .eq. 4) then

	if (option .eq. 'S') then

	call mslg$k_sml_dsk (lun)
	endif
	else

	call erllogmsg2 (lun)
	endif

	else if (emb$w_lm_msgtyp .eq. 7) then

	call frctof (lun)

	call header2 (lun,reccnt)

	call logger (lun,'ERL$LOGMESSAGE ENTRY')

	call dhead3 (lun,'I/O',emb$b_lm_namlng,emb$t_lm_name,emb$w_lm_unit,
	1 mount_flag_and_label)

	call linchk (lun,2)

	write(lun,10) '"INVALID COMMAND" MSCP END MESSAGE'
10	format('0',a)

	call mscp_invalid_command_end_mesage (lun)
	endif

	else if (emb$w_hd_entry .eq. 99) then

	call frctof (lun)

	call header2 (lun,reccnt)

	call logger (lun,'ERL$LOGSTATUS ENTRY')

	call dhead3 (lun,'I/O',emb$b_sp_namlng,emb$t_sp_name,emb$w_sp_unit,
	1 mount_flag_and_label)

	call erllogsts2 (lun)
	endif

	return

	end



c++
c	Since mscp error log entries are delivered from the port via
c	the datagram service it is possible for them to be delivered
c	out of sequence or duplicated.  It is the responsibility of 
c	this queue to collect all entries containing the same command
c	reference for a given cpu together.  They are placed in order
c	of error log entry type.
c
c	The format of the elements are as follows
c
c	+----------------------------------+
c	|             flink1               |
c	+----------------------------------+
c	|             blink1               |
c	+----------------------------------+
c	|           logging sid            |
c	+----------------------------------+
c	|   root command reference flink   |
c	+----------------------------------+
c	|   root command reference blink   |
c	+----------------------------------+
c	|   command reference entry count  |
c	+----------------------------------+
c
c	+----------------------------------+
c	|             flink2               |
c	+----------------------------------+
c	|             blink2               |
c	+----------------------------------+
c	|     command reference number     |
c	+----------------------------------+
c	|    root_emb$$w_hd_entry_flink    |
c	+----------------------------------+
c	|    root_emb$$w_hd_entry_blink    |
c	+----------------------------------+
c	|      emb$$w_hd_entry count       |
c	+----------------------------------+
c
c	+----------------------------------+
c	|             flink3               |
c	+----------------------------------+
c	|             blink3               |
c	+----------------------------------+
c	|          emb$$w_hd_entry         |
c	+----------------------------------+
c	|      error log record number     |
c	+----------------------------------+
c	|   error log record size (bytes)  |
c	+----------------------------------+
c	|                                  |
c	+--                              --+
c	.                                  .
c	.        error log record          .
c	.                                  .
c	+--                              --+
c	|                                  |
c	+----------------------------------+
c	|         mounted flag             |
c	+----------------------------------+
c	|                                  |
c	+--                              --+
c	|   mounted volume label (if any)  |
c	+--                              --+
c	|                                  |
c	+----------------------------------+
c--



	subroutine dudriver_mscp_q (record_length,reccnt,
	1 search_command_reference_number)




	include 'src$:msghdr.for /nolist'

	include 'src$:emblmdef.for /nolist'

	include 'src$:embspdef.for /nolist'




	byte		lun

	character*1	option

	integer*4	record_length

	integer*4	reccnt

	integer*4	search_command_reference_number

	integer*4	buffer(2)

	logical*4	lib$get_vm

	integer*4	insert_blink

	integer*4	logging_sid_entry_address

	integer*4	command_reference_entry_address

	integer*4	emb$$w_hd_entry_address

	integer*4	root_logging_sid_flink

	integer*4	root_logging_sid_blink

	equivalence	(buffer(1),root_logging_sid_flink)

	equivalence	(buffer(2),root_logging_sid_blink)

	integer*4	logging_sid_entry_count
	data		logging_sid_entry_count	/0/

	integer*4	buffer1(6)

	integer*4	flink1

	integer*4	blink1

	integer*4	logging_sid

	integer*4	root_command_reference_flink

	integer*4	root_command_reference_blink

	integer*4	command_reference_entry_count

	equivalence	(buffer1(1),flink1)

	equivalence	(buffer1(2),blink1)

	equivalence	(buffer1(3),logging_sid)

	equivalence	(buffer1(4),root_command_reference_flink)

	equivalence	(buffer1(5),root_command_reference_blink)

	equivalence	(buffer1(6),command_reference_entry_count)

	integer*4	buffer2(6)

	integer*4	flink2

	integer*4	blink2

	integer*4	command_reference_number

	integer*4	root_emb$$w_hd_entry_flink

	integer*4	root_emb$$w_hd_entry_blink

	integer*4	emb$$w_hd_entry_count

	equivalence	(buffer2(1),flink2)

	equivalence	(buffer2(2),blink2)

	equivalence	(buffer2(3),command_reference_number)

	equivalence	(buffer2(4),root_emb$$w_hd_entry_flink)

	equivalence	(buffer2(5),root_emb$$w_hd_entry_blink)

	equivalence	(buffer2(6),emb$$w_hd_entry_count)

	integer*4	buffer3(5)

	integer*4	flink3

	integer*4	blink3

	integer*4	emb$$w_hd_entry

	integer*4	error_log_record_number

	integer*4	error_log_record_length

	equivalence	(buffer3(1),flink3)

	equivalence	(buffer3(2),blink3)

	equivalence	(buffer3(3),emb$$w_hd_entry)

	equivalence	(buffer3(4),error_log_record_number)

	equivalence	(buffer3(5),error_log_record_length)




	if (logging_sid_entry_count .eq. 0) then

	root_logging_sid_flink = %loc(root_logging_sid_flink)

	root_logging_sid_blink = root_logging_sid_flink
	endif

	logging_sid_entry_address = root_logging_sid_flink

	do 100,i = 1,logging_sid_entry_count

	call movc3 (%val(24),%val(logging_sid_entry_address),buffer1)

	if (logging_sid .eq. emb$l_hd_sid) then

10	command_reference_entry_address = root_command_reference_flink

	do 90,j = 1,command_reference_entry_count

	call movc3 (%val(24),%val(command_reference_entry_address),buffer2)

	if (command_reference_number .eq. search_command_reference_number)
	1 then

25	insert_blink = root_emb$$w_hd_entry_blink

	if (emb$$w_hd_entry_count .ne. 0) then

	call movc3 (%val(12),%val(root_emb$$w_hd_entry_blink),buffer3)

	if (emb$$w_hd_entry .lt. emb$w_hd_entry) then

	insert_blink = blink3
	endif
	endif

	call movc5 (%val(0),,%val(0),%val(20),buffer3)

	if (lib$get_vm((20+record_length+16),emb$$w_hd_entry_address)) then

	call insque (%val(emb$$w_hd_entry_address),%val(insert_blink))

	emb$$w_hd_entry = emb$w_hd_entry

	error_log_record_number = reccnt

	error_log_record_length = record_length

	call movc3 (%val(12),emb$$w_hd_entry,
	1 %val(emb$$w_hd_entry_address + 8))

	call movc3 (%val(record_length),emb,%val(emb$$w_hd_entry_address + 20))

	call movl (-1,%val(emb$$w_hd_entry_address+20+record_length))

	if (emb$w_hd_entry .eq. 100) then

	call get_current_label (3,emb$l_hd_sid,emb$b_lm_namlng,emb$t_lm_name,
	1 emb$w_lm_unit,%val(emb$$w_hd_entry_address+20+record_length+4),*30)

	else if (emb$w_hd_entry .eq. 99) then

	call get_current_label (3,emb$l_hd_sid,emb$b_sp_namlng,emb$t_sp_name,
	1 emb$w_sp_unit,%val(emb$$w_hd_entry_address+20+record_length+4),*30)
	endif

	call movl (emb$$w_hd_entry_address+20+record_length+4,
	1 %val(emb$$w_hd_entry_address+20+record_length))

30	emb$$w_hd_entry_count = emb$$w_hd_entry_count + 1

	call movl (emb$$w_hd_entry_count,
	1 %val(command_reference_entry_address + 20))
	endif

	return
	endif

	command_reference_entry_address = flink2

90	continue

	call movc5 (%val(0),,%val(0),%val(24),buffer2)

	if (lib$get_vm(24,command_reference_entry_address)) then

	call insque (%val(command_reference_entry_address),
	1 %val(root_command_reference_blink))

	command_reference_number = search_command_reference_number

	root_emb$$w_hd_entry_flink = command_reference_entry_address + 12

	root_emb$$w_hd_entry_blink = root_emb$$w_hd_entry_flink

	call movc3 (%val(16),command_reference_number,
	1 %val(command_reference_entry_address + 8))

	command_reference_entry_count = command_reference_entry_count + 1

	call movl (command_reference_entry_count,
	1 %val(logging_sid_entry_address + 20))

	goto 25
	endif

	return
	endif

	logging_sid_entry_address = flink1

100	continue

	call movc5 (%val(0),,%val(0),%val(24),buffer1)

	if (lib$get_vm(24,logging_sid_entry_address)) then

	call insque (%val(logging_sid_entry_address),
	1 %val(root_logging_sid_blink))

	logging_sid = emb$l_hd_sid

	root_command_reference_flink = logging_sid_entry_address + 12

	root_command_reference_blink = root_command_reference_flink

	call movc3 (%val(16),logging_sid,%val(logging_sid_entry_address + 8))

	logging_sid_entry_count = logging_sid_entry_count + 1

	goto 10
	endif

	return



	entry dudriver_mscp_dq (lun,option)



	logging_sid_entry_address = root_logging_sid_flink

	do 150,i = 1,logging_sid_entry_count

	call movc3 (%val(24),%val(logging_sid_entry_address),buffer1)

	command_reference_entry_address = root_command_reference_flink

	do 200,j = 1,command_reference_entry_count

	call movc3 (%val(24),%val(command_reference_entry_address),buffer2)

	emb$$w_hd_entry_address = root_emb$$w_hd_entry_flink

	do 250,k = 1,emb$$w_hd_entry_count

	call movc3 (%val(20),%val(emb$$w_hd_entry_address),buffer3)

	call movc5 (%val(0),,%val(0),%val(512),emb)

	call movc3 (%val(error_log_record_length),
	1 %val(emb$$w_hd_entry_address + 20),emb)

	call dudriver_mscp_dispatcher (lun,option,error_log_record_number,
	1 %val(emb$$w_hd_entry_address+20+error_log_record_length))

	emb$$w_hd_entry_address = flink3

250	continue

	command_reference_entry_address = flink2

200	continue

	logging_sid_entry_address = flink1

150	continue

	return

	end



	subroutine dudriver_qio (lun,emb$w_dv_func)



	include 'src$:qiocommon.for /nolist'



	byte		lun

	integer*2	emb$w_dv_func

	integer*4	qiocode(0:1,0:63)




	if (qiocode(0,0) .eq. 0) then

	qiocode(1,00) = %loc(io$_nop)

	qiocode(1,01) = %loc(io$_unload)

	qiocode(1,08) = %loc(io$_packack)

	qiocode(1,10) = %loc(io$_writecheck)

	qiocode(1,11) = %loc(io$_writepblk)

	qiocode(1,12) = %loc(io$_readpblk)

	qiocode(1,17) = %loc(io$_available)

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

	call cdrp$w_func (lun,emb$w_dv_func,
	1 qiocode(0,lib$extzv(0,6,emb$w_dv_func)))

	return

	end
