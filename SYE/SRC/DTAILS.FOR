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

c	Author	Brian Porter			Creation Date	03-NOV-1981

c++
c	Functional description:
c
c	This a collection of routines that are called to output
c	software information in device error entries.
c
c	Modified by:
c
c	v03-001	BP0002		Brian Porter,			01-MAR-1982
c		Added more routines.
c**
c--




	subroutine ucb$b_ertcnt (lun,emb$b_dv_ertcnt)




	byte		lun

	byte		emb$b_dv_ertcnt

	integer*4	remaining_retries

	integer*4	compress4



	remaining_retries = lib$extzv(0,8,emb$b_dv_ertcnt)

	call linchk (lun,2)

	write(lun,10) emb$b_dv_ertcnt,remaining_retries
10	format(' ',t8,'UCB$B_ERTCNT',t30,z2.2,/,
	1 t40,i<compress4 (remaining_retries)>,'. RETRIES REMAINING')

	return

	end




	subroutine ucb$b_ertmax (lun,emb$b_dv_ertmax)




	byte		lun

	byte		emb$b_dv_ertmax

	integer*4	maximum_retries

	integer*4	compress4



	maximum_retries = lib$extzv(0,8,emb$b_dv_ertmax)

	call linchk (lun,2)

	write(lun,10) emb$b_dv_ertmax,maximum_retries
10	format(' ',t8,'UCB$B_ERTMAX',t30,z2.2,/,
	1 t40,i<compress4 (maximum_retries)>,'. RETRIES ALLOWABLE')

	return

	end




	subroutine ucb$l_ownuic (lun,emb$l_dv_ownuic)




	byte		lun

	integer*4	emb$l_dv_ownuic

	integer*4	group

	integer*4	member




	group = lib$extzv (16,8,emb$l_dv_ownuic)

	member = lib$extzv (0,8,emb$l_dv_ownuic)

	call linchk (lun,2)

	write(lun,10) emb$l_dv_ownuic,group,member
10	format(' ',t8,'UCB$L_OWNUIC',t24,z8.8,/,
	1 t40,'OWNER UIC [',o3.3,',',o3.3,']')

	return

	end




	subroutine ucb$l_opcnt (lun,emb$l_dv_opcnt)




	byte		lun

	integer*4	emb$l_dv_opcnt

	integer*4	compress4




	call linchk (lun,2)

	write(lun,10) (emb$l_dv_opcnt,i = 1,2)
10	format(' ',t8,'UCB$L_OPCNT',t24,z8.8,/,
	1 t40,i<compress4 (emb$l_dv_opcnt)>,17h. QIO'S THIS UNIT)

	return

	end




	subroutine ucb$w_errcnt (lun,emb$w_dv_errcnt)




	byte		lun

	integer*2	emb$w_dv_errcnt

	integer*4	errors_this_unit

	integer*4	compress4




	errors_this_unit = lib$extzv (0,16,emb$w_dv_errcnt)

	call linchk (lun,2)

	write(lun,10) emb$w_dv_errcnt,errors_this_unit
10	format(' ',t8,'UCB$W_ERRCNT',t28,z4.4,/,
	1 t40,i<compress4 (errors_this_unit)>,'. ERRORS THIS UNIT')

	return

	end




	subroutine ucb$l_char (lun,emb$l_dv_char)




	byte		lun

	integer*4	emb$l_dv_char

	character*33	v1device_characteristics(0:7)

	data	v1device_characteristics(0)  /'RECORD ORIENTED*'/

	data	v1device_characteristics(1)  /'CARRIAGE CONTROL*'/

	data	v1device_characteristics(2)  /'TERMINAL*'/

	data	v1device_characteristics(3)  /'DIRECTORY STRUCTURED*'/

	data	v1device_characteristics(4)  /'SINGLE DIRECTORY*'/

	data	v1device_characteristics(5)  /'"SEQUENTIAL BLOCK" ORIENTED*'/

	data	v1device_characteristics(6)  /'SPOOLED*'/

	data	v1device_characteristics(7)  /'OPERATOR*'/

	character*22	v2device_characteristics(13:31)

	data	v2device_characteristics(13) /'NETWORK*'/

	data	v2device_characteristics(14) /'FILE ORIENTED*'/

	data	v2device_characteristics(15) /'DUAL ACCESS*'/

	data	v2device_characteristics(16) /'SHARABLE*'/

	data	v2device_characteristics(17) /'GEN*'/

	data	v2device_characteristics(18) /'AVAILABLE*'/

	data	v2device_characteristics(19) /'MOUNTED*'/

	data	v2device_characteristics(20) /'MAILBOX*'/

	data	v2device_characteristics(21) /'"MARKED" FOR DISMOUNT*'/

	data	v2device_characteristics(22) /'ERROR LOGGING*'/

	data	v2device_characteristics(23) /'ALLOCATED*'/

	data	v2device_characteristics(24) /'FOREIGN*'/

	data	v2device_characteristics(25) /'SOFTWARE "WRITE LOCK"*'/

	data	v2device_characteristics(26) /'CAPABLE OF INPUT*'/

	data	v2device_characteristics(27) /'CAPABLE OF OUTPUT*'/

	data	v2device_characteristics(28) /'RANDOM ACCESS*'/

	data	v2device_characteristics(29) /'REAL TIME*'/

	data	v2device_characteristics(30) /'DATA CHECK, READS*'/

	data	v2device_characteristics(31) /'DATA CHECK, WRITES*'/



	call linchk (lun,1)

	write(lun,10) emb$l_dv_char
10	format(' ',t8,'UCB$L_CHAR',t24,z8.8)

	call output (lun,emb$l_dv_char,v1device_characteristics,0,0,6,'0')

	call output (lun,emb$l_dv_char,v2device_characteristics,
	1 13,13,31,'0')

	return

	end




	subroutine ucb$w_sts (lun,emb$w_dv_sts)




	byte		lun

	integer*2	emb$w_dv_sts

	character*26	v1device_status(0:12)

	data	v1device_status(0)	/'TIMEOUT ENABLED*'/

	data	v1device_status(1)	/'INTERRUPT EXPECTED*'/

	data	v1device_status(2)	/'ERROR LOGGING IN-PROGRESS*'/

	data	v1device_status(3)	/'CANCEL I/O*'/

	data	v1device_status(4)	/'ONLINE*'/

	data	v1device_status(5)	/'POWER FAILED WHILE BUSY*'/

	data	v1device_status(6)	/'TIMED OUT*'/

	data	v1device_status(7)	/'RECEIVER INTERRUPT*'/

	data	v1device_status(8)	/'BUSY*'/

	data	v1device_status(9)	/'MOUNT IN-PROGRESS*'/

	data	v1device_status(10)	/'DEALLOCATE AT DISMOUNT*'/

	data	v1device_status(11)	/'SOFTWARE VALID*'/

	data	v1device_status(12)	/'UNLOAD AT DISMOUNT*'/

	character*33	v2device_status(14:15)

	data	v2device_status(14)	/'"MOUNT VERIFICATION" IN-PROGRESS*'/

	data	v2device_status(15)	/'WRONG VOLUME DETECTED*'/



	call linchk (lun,1)

	write(lun,10) emb$w_dv_sts
10	format(' ',t8,'UCB$W_STS',t28,z4.4)

	call output (lun,emb$w_dv_sts,v1device_status,0,0,12,'0')

	call output (lun,emb$w_dv_sts,v2device_status,14,14,15,'0')

	return

	end




	subroutine ucb$l_media (lun,emb$l_dv_media)




	byte		lun

	integer*4	emb$l_dv_media

	integer*4	cylinder

	integer*4	track

	integer*4	sector

	integer*4	compress4




	cylinder = lib$extzv (16,16,emb$l_dv_media)

	track = lib$extzv (8,8,emb$l_dv_media)

	sector = lib$extzv (0,8,emb$l_dv_media)

	call linchk (lun,5)

	write(lun,10) emb$l_dv_media,cylinder,track,sector
10	format(' ',t8,'UCB$L_MEDIA',t24,z8.8,/,
	1 t40,'FUNCTION START ADDRESS,',/,
	1 t40,' - CYLINDER #',i<compress4 (cylinder)>,'.,',/,
	1 t40,' - TRACK #',i<compress4 (track)>,'.,',/,
	1 t40,' - SECTOR #',i<compress4 (sector)>,'.')

	return

	end




	subroutine irp$w_func (lun,emb$w_dv_func,qio_string)




	byte		lun

	integer*2	emb$w_dv_func

	character*(*)	qio_string

	integer*4	device_dependent_modifiers

	character*15	v1device_independent_modifiers(14:15)

	data		v1device_independent_modifiers(14)
	1 /'IO$M_DATACHECK*'/

	data		v1device_independent_modifiers(15)
	1 /'IO$M_INHRETRY*'/

	integer*4	compressc




	call linchk (lun,2)

	write(lun,10) emb$w_dv_func,qio_string
10	format(' ',t8,'IRP$W_FUNC',t28,z4.4,/,
	1 t40,a<compressc (qio_string)>)



	entry qio_function_modifiers (lun,emb$w_dv_func)



	device_dependent_modifiers = lib$extzv(6,7,emb$w_dv_func)

	if (device_dependent_modifers .ne. 0) then

	call linchk (lun,1)

	write(lun,15)
15	format(' ',t40,'DEVICE DEPENDENT MODIFIER(S)')
	endif

	call output (lun,emb$w_dv_func,v1device_independent_modifiers,
	1 14,14,15,'0')

	return

	end




	subroutine irp$w_bcnt (lun,emb$w_dv_bcnt)




	byte		lun

	integer*2	emb$w_dv_bcnt

	integer*4	transfer_byte_count

	integer*4	compress4




	transfer_byte_count = lib$extzv(0,16,emb$w_dv_bcnt)

	call linchk (lun,2)

	write(lun,10) emb$w_dv_bcnt,transfer_byte_count
10	format(' ',t8,'IRP$W_BCNT',t28,z4.4,/,
	1 t40,'TRANSFER SIZE ',i<compress4 (transfer_byte_count)>,'. BYTE(S)')

	return

	end



	subroutine irp$w_boff (lun,emb$w_dv_boff)



	byte		lun

	integer*2	emb$w_dv_boff

	integer*4	page_byte_offset

	integer*4	compress4



	page_byte_offset = lib$extzv (0,16,emb$w_dv_boff)

	call linchk (lun,2)

	if (page_byte_offset .eq. 0) then

	write(lun,10) emb$w_dv_boff
10	format(' ',t8,'IRP$W_BOFF',t28,z4.4,/,
	1 t40,'TRANSFER PAGE ALIGNED')
	else

	write(lun,15) emb$w_dv_boff,page_byte_offset
15	format(' ',t8,'IRP$W_BOFF',t28,z4.4,/,
	1 t40,i<compress4 (page_byte_offset)>,'. BYTE PAGE OFFSET')
	endif

	return

	end




	subroutine irp$l_pid (lun,emb$l_dv_rqpid)




	byte		lun

	integer*4	emb$l_dv_rqpid




	call linchk (lun,2)

	write(lun,10) emb$l_dv_rqpid
10	format(' ',t8,'IRP$L_PID',t24,z8.8,/,
	1 t40,'REQUESTOR "PID"')

	return

	end




	subroutine irp$q_iosb (lun,emb$l_dv_iosb)




	byte		lun

	integer*4	emb$l_dv_iosb(2)

	integer*4	bytes_transfered

	integer*4	compress4




	bytes_transfered = lib$extzv (16,16,emb$l_dv_iosb(1))

	call linchk (lun,2)

	write(lun,10) (emb$l_dv_iosb(i),i = 1,2),bytes_transfered
10	format(' ',t8,'IRP$Q_IOSB',t24,z8.8,/,
	1 t24,z8.8,t40,'IOSB, ',i<compress4 (bytes_transfered)>,
	1 '. BYTE(S) TRANSFERRED')

	return

	end




	subroutine cdrp$w_boff (lun,emb$w_sp_boff)




	byte		lun

	integer*2	emb$w_sp_boff

	integer*4	page_byte_offset

	integer*4	compress4



	page_byte_offset = lib$extzv (0,16,emb$w_sp_boff)

	call linchk (lun,2)

	if (page_byte_offset .eq. 0) then

	write(lun,10) emb$w_sp_boff
10	format(' ',t8,'CDRP$W_BOFF',t28,z4.4,/,
	1 t40,'TRANSFER PAGE ALIGNED')
	else

	write(lun,15) emb$w_sp_boff,page_byte_offset
15	format(' ',t8,'CDRP$W_BOFF',t28,z4.4,/,
	1 t40,i<compress4 (page_byte_offset)>,'. BYTE PAGE OFFSET')
	endif

	return

	end



	subroutine cdrp$l_bcnt (lun,emb$l_sp_bcnt)




	byte		lun

	integer*4	emb$l_sp_bcnt

	integer*4	compress4




	call linchk (lun,2)

	write(lun,10) (emb$l_sp_bcnt,i = 0,1)
10	format(' ',t8,'CDRP$L_BCNT',t24,z8.8,/,
	1 t40,'TRANSFER SIZE ',i<compress4 (emb$l_sp_bcnt)>,'. BYTE(S)')

	return

	end




	subroutine cdrp$w_func (lun,emb$w_sp_func,qio_string)




	byte		lun

	integer*2	emb$w_sp_func

	character*(*)	qio_string

	integer*4	compressc




	call linchk (lun,2)

	write(lun,10) emb$w_sp_func,qio_string
10	format(' ',t8,'CDRP$W_FUNC',t28,z4.4,/,
	1 t40,a<compressc (qio_string)>)

	call qio_function_modifiers (lun,emb$w_sp_func)

	return

	end



	subroutine cdrp$l_pid (lun,emb$l_sp_rqpid)




	byte		lun

	integer*4	emb$l_sp_rqpid




	call linchk (lun,2)

	write(lun,10) emb$l_sp_rqpid
10	format(' ',t8,'CDRP$L_PID',t24,z8.8,/,
	1 t40,'REQUESTOR "PID"')

	return

	end




	subroutine cdrp$q_iosb (lun,emb$l_sp_iosb)




	byte		lun

	integer*4	emb$l_sp_iosb(2)

	integer*4	bytes_transfered

	integer*4	compress4




	bytes_transfered = lib$extzv (16,16,emb$l_sp_iosb(1))

	call linchk (lun,2)

	write(lun,10) (emb$l_sp_iosb(i),i = 1,2),bytes_transfered
10	format(' ',t8,'CDRP$Q_IOSB',t24,z8.8,/,
	1 t24,z8.8,t40,'IOSB, ',i<compress4 (bytes_transfered)>,
	1 '. BYTE(S) TRANSFERRED')

	return

	end




	subroutine cdrp$l_media (lun,emb$l_sp_media)




	byte		lun

	integer*4	emb$l_sp_media

	integer*4	compress4




	call linchk (lun,2)

	write(lun,10) (emb$l_sp_media,i = 0,1)
10	format(' ',t8,'CDRP$L_MEDIA',t24,z8.8,/,
	1 t40,'STARTING LBN #',i<compress4 (emb$l_sp_media)>,'.')

	return

	end
