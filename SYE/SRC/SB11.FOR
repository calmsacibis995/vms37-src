	Subroutine SB11 (lun)
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
C
C	Author:	Sharon Reynolds			Creation date:	20-Jan-1981
C
C
C	Functional description:
C
C	This module produces the error log report for the SB11
C	DECdataway I/O subsystem.
C
C	Modified by:
C
C	v02-004	BP0004		Brian Porter,		23-NOV-1981
C		Minor edit.
C
C	v02-003	BP0003		Brian Porter,		05-NOV-1981
C		Added 'device attention' support.
C
C	v02-002	BP0002		Brian Porter,		23-JUL-1981
C		Added new uba routines.
C
C	v02-001	BP0001		Brian Porter,		15-JUL-1981
C		Misc. changes made by S. Reynolds in response to input
C		from W. Saltz.  Added call to DHEAD1.
C**


	Include 'SRC$:MSGHDR.FOR /NOLIST'
	Include 'SRC$:DEVERR.FOR /NOLIST'



	Byte		lun
	Byte		hdr_map_valid
	Byte		dat_map_valid
	Byte		att_ucb0
	Byte		port_id

	Integer*2	csr0
	Integer*2	csr1
	Integer*2	csr2

	Integer*4	COMPRESS4
	Integer*4	COMPRESSC

	Integer*4	no_irp
	Integer*4	field
	Integer*4	unit
	Integer*4	devdepend
	Integer*4	devsts
	Integer*4	tt_retry_cnt
	Integer*4	tt_protocol_err
	Integer*4	tumble_table
	Integer*4	registers
	Integer*4	err_sts
	Integer*4	uba_reg1(0:2)
	Integer*4	uba_reg2(0:2)
	Integer*4	dataway_addr
	Integer*4	reg_copy(0:3)

	Parameter	timeout = 96
	Parameter	rt80 = 1
	Parameter	dyt01 = 2
	Parameter	dpm01 = 4
	Parameter	dis = 8

	Character*83	tt_protocol_id(0:7)
	Character*15	tumble_tbl(5:7)
	Character*35	err_num(0:31)
	Character*29	func(0:7)
	Character*22	csr0_1(5:7)
	Character*32	csr2_1(6:7)
	Character*6	device(1:8)
	Character*46	dvsts(0:11)
	Character*7	reg_herald(0:3)

C
C	Make the register save area of the error log buffer available
C	to this module
C

	Equivalence	(err_sts,EMB$L_DV_REGSAV(0))
	Equivalence	(registers,EMB$L_DV_REGSAV(1))
	Equivalence	(devdepend,EMB$L_DV_REGSAV(2))
	Equivalence	(devsts,EMB$L_DV_REGSAV(3))
	Equivalence	(uba_reg1,EMB$L_DV_REGSAV(4))
	Equivalence	(uba_reg2,EMB$L_DV_REGSAV(7))


C
C	Define the register mnemonics for the BRIEF and CRYPTK reports
C

	Data	reg_herald(0)	/'CSR0*'/
	Data	reg_herald(1)	/'CSR1*'/
	Data	reg_herald(2)	/'CSR2*'/
	Data	reg_herald(3)	/'ERRSTS*'/

C
C	Define text for the tumble table
C

	Data	tt_protocol_id(0)	/'PREMATURE END OF MESSAGE'/
	Data	tt_protocol_id(1)	/'BAD ADDRESS'/
	Data	tt_protocol_id(2)	/'ILLEGAL RESPONSE CONTROL CODE'/
	Data	tt_protocol_id(3)	/'SEQUENCE BIT WRONG-NO REPEAT|COMMAND SENT'/
	Data	tt_protocol_id(4)	/'ILLEGAL MSG-LENGTH ON|NON ''SI'' RESPONSE'/
	Data	tt_protocol_id(5)	/'ILLEGAL RESPONSE OF ''SI''|WHEN NOT
	1 REQUESTED'/
	Data	tt_protocol_id(6)	/'ILLEGAL RESPONSE OF ''RNR'' TO|''RI''
	1 COMMAND WHEN READY TO|RECEIVE NOT REQUESTED'/
	Data	tt_protocol_id(7)	/'ILLEGAL RESPONSE OF ''RNR'' TO|''RPS''
	1 COMMAND WHEN READY TO|RECEIVE NOT REQUIRED'/

	Data	tumble_tbl(5)	/'PROTOCOL ERROR*'/
	Data	tumble_tbl(6)	/'TIMEOUT ERROR*'/
	Data	tumble_tbl(7)	/'CRC ERROR*'/


C
C	Define text for error number
C

	Data	err_num(0)	/'LATENCY ERROR-NO DATA|TRANSFERRED'/
	Data	err_num(1)	/'LATENCY ERROR-DATA TRANSFERRED'/
	Data	err_num(2)	/'MEMORY TIMEOUT ERROR'/
	Data	err_num(3)	/'ONLINE TRANSITION'/
	Data	err_num(4)	/'OFFLINE TRANSITION'/
	Data	err_num(5)	/'DATA OVERRUN ERROR'/
	Data	err_num(6)	/'WRITE FUNCTION TIMEOUT'/
	Data	err_num(7)	/'UNSOLICITED DATA'/
	Data	err_num(8)	/'LINE ERROR'/
	Data	err_num(9)	/'RESERVED'/
	Data	err_num(10)	/'NO DATA TRANSFERRED'/
	Data	err_num(11)	/'INVALID TYPE 2 TUMBLE|TABLE ENTRY'/
	Data	err_num(12)	/'I/O DONE WITH NO TRANSFER'/
	Data	err_num(13)	/'ONLINE I/O DONE'/
	Data	err_num(14)	/'INVALID DEVICE UNIT NUMBER'/
	Data	err_num(15)	/'NON-EXISTENT MEMORY'/
	Data	err_num(16)	/'PORT WAIT QUEUE TIMEOUT'/
	Data	err_num(17)	/'USER INITIATED SHUTDOWN'/
	Data	err_num(18)	/'CONTROLLER STARTUP'/
	Data	err_num(19)	/'INVALID TYPE 1 TUMBLE|TABLE ENTRY'/
	Data	err_num(20)	/'DRIVER DATA STRUCTURE ERROR'/
	Data	err_num(21)	/'RESERVED'/
	Data	err_num(22)	/'RESERVED'/
	Data	err_num(23)	/'RESERVED'/
	Data	err_num(24)	/'AST NOT DELIVERABLE'/
	Data	err_num(25)	/'ENABLE LOGGING OF DECDATAWAY|ERROR'/
	Data	err_num(26)	/'DISABLE LOGGING OF DECDATAWAY|ERROR'/
	Data	err_num(27)	/'RESERVED'/
	Data	err_num(28)	/'RESERVED'/
	Data	err_num(29)	/'DRIVER INITIATED SHUTDOWN'/
	Data	err_num(30)	/'RESERVED'/
	Data	err_num(31)	/'RESERVED'/


C
C	Define text for bits in CSR0
C

	Data	func(0)		/'NO-OP*'/
	Data	func(1)		/'INITIATE TRANSFER OUT*'/
	Data	func(2)		/'INITIATE TRANSFER IN*'/
	Data	func(3)		/'SEND TRANSPARENT DATA*'/
	Data	func(4)		/'SEND TRANSPARENT DATA-NO CRC*'/
	Data	func(5)		/'RESERVED*'/
	Data	func(6)		/'RESERVED*'/
	Data	func(7)		/'CANCEL OPERATION*'/

	Data	csr0_1(5)	/'HARDWARE ERROR*'/
	Data	csr0_1(6)	/'DONE INTERRUPT ENABLE*'/
	Data	csr0_1(7)	/'DONE*'/


C
C	Define text for bits in CSR2
C

	Data	csr2_1(6)	/'PORT AVAILABLE INTERRUPT ENABLE*'/
	Data	csr2_1(7)	/'PORT LOCK*'/


C
C	Define the devices currently allowed on the DECdataway
C

	Data	device(1)	/'RT80*'/
	Data	device(2)	/'DYT01*'/
	Data	device(4)	/'DPM01*'/
	Data	device(8)	/'DIS*'/

C
C	Define the text for the bit assignments in ucb$w_devsts
C

	Data	dvsts(0)	/'REQUEST IN THE PORT-WAIT-QUEUE*'/
	Data	dvsts(1)	/'CANCEL IN PROGRESS*'/
	Data	dvsts(2)	/'TRANSFER OPERATION IS REQUESTED*'/
	Data	dvsts(3)	/'UNIT IS ACTIVE*'/
	Data	dvsts(4)	/'SYSTEM ERROR LOGGING ENABLED*'/
	Data	dvsts(5)	/'LOGGING OF ON/OFF LINE ENABLED*'/
	Data	dvsts(6)	/'USER ERROR LOG IS ENABLED*'/
	Data	dvsts(7)	/'INHIBIT ERROR LOGGING*'/
	Data	dvsts(8)	/'UNIT IS SHUTDOWN*'/
	Data	dvsts(9)	/'REQUEST HAS TIMED OUT*'/
	Data	dvsts(10)	/'RESERVED*'/
	Data	dvsts(11)	/'REQUEST ONLINE*'/

	
C
C	Construct the error log report header
C

	Call FRCTOF (lun)

	call dhead1 (lun,'UBA DEC DATAWAY')

C
C	Extract necessary information for later use
C

	Hdr_map_valid = LIB$EXTZV (30,1,EMB$L_DV_NUMREG)

	Dat_map_valid = LIB$EXTZV (31,1,EMB$L_DV_NUMREG)

	No_irp = LIB$EXTZV (0,16,EMB$L_DV_NUMREG)

C
C	Decode and output the bits in the csr0 register
C

	Csr0 = LIB$EXTZV (0,8,registers)

	Call LINCHK (lun,2)
	Write (lun,30) csr0
30	Format ('0',T8,'CSR0',T24,Z8.8)

	Field = LIB$EXTZV (0,3,csr0)

	Call LINCHK (lun,1)
	Write (lun,40) func(field)
40	Format (' ',T40,'FUNCTION = ',A<COMPRESSC (func(field))> )

	Call OUTPUT (lun,csr0,csr0_1,5,5,7,'0')		

C
C	Decode and output the bits in the csr1 register
C

	Csr1 = LIB$EXTZV (8,8,registers)

	Call LINCHK (lun,2)
	Write (lun,50) csr1
50	Format ('0',T8,'CSR1',T24,Z8.8)



C
C	Decode and output the bits in the csr2 register
C

	Csr2 = LIB$EXTZV (16,8,registers)

	Call LINCHK (lun,2)
	Write (lun,55) csr2
55	Format ('0',T8,'CSR2',T24,Z8.8)

	Dataway_addr = LIB$EXTZV (0,6,csr2)

	Call LINCHK (lun,1)
	Write (lun,60) dataway_addr
60	Format (' ',T40,'DECDATAWAY ADDRESS = ',
	1 I<COMPRESS4 (dataway_addr)>,'.')

	Call OUTPUT (lun,csr2,csr2_1,6,6,7,'0')

C
C	Decode and output the mapping information for the header and/or
C	data buffers
C

	If (no_irp .eq. 10) then

	If (hdr_map_valid .eq. 1) then

	Call LINCHK (lun,3)
	Write (lun,70)
70	Format ('0','HEADER BUFFER MAPPING INFORMATION',/)

	call uba_mapping (lun,-1,uba_reg1(0))

	call uba_mapping (lun,-1,uba_reg1(1))

	call vecmapreg (lun,uba_reg1(2))
	endif

	If (dat_map_valid .eq. 1) then 

	Call LINCHK (lun,2)
	Write (lun,80)
80	Format ('0','DATA BUFFER MAPPING INFORMATION')

	call uba_mapping (lun,-1,uba_reg2(0))

	call uba_mapping (lun,-1,uba_reg2(1))

	call vecmapreg (lun,uba_reg2(2))
	Endif
	Endif

C
C	Decode and output the 'dataway' protocol and error status 
C	information
C

	Call LINCHK (lun,2)
	Write (lun,90)
90	Format ('0','DECDATAWAY PROTOCOL AND STATUS INFORMATION')

	Call LINCHK (lun,2)
	Write (lun,100) err_sts
100	Format ('0',T8,'ERROR STATUS',T24,Z8.8)

	Field = LIB$EXTZV (0,5,err_sts)

	Call OUTPUT_MLINES (lun,err_num(field),'|',32)

C
C	Find out if the tumble table entry is valid and output it when
C	necessary
C

	If (field .eq. 7
	1 .or.
	2 field  .eq. 8) then

	Call LINCHK (lun,1)
	Write (lun,110) 
110	Format (' ',T40,'********** TUMBLE TABLE **********')

	Tumble_table = LIB$EXTZV (16,8,err_sts)

	If (field .eq. 8) then

	Tt_retry_cnt = LIB$EXTZV (0,2,tumble_table)

	Call LINCHK (lun,2)
	Write (lun,120) tt_retry_cnt + 1
120	Format (' ',T40,'REPEAT COUNT = ',
	1 I<COMPRESS4 (tt_retry_cnt)>,'.')
	Write (lun,121)
121	Format (' ')

	Call OUTPUT (lun,tumble_table,tumble_tbl,5,5,7,'0')

	Tt_protocol_err = LIB$EXTZV (5,1,tumble_table)

	If (tt_protocol_err .eq. 1) then

	Field = LIB$EXTZV (2,3,tumble_table)

	Call OUTPUT_MLINES (lun,tt_protocol_id(field),'|',32)
	Endif
	Endif

	If (field .eq. 7) then

	Call LINCHK (lun,2)
	Write (lun,130) tumble_table
130	Format ('0',T40, 'DATA = ',Z4.4)

	Endif

	Call LINCHK (lun,1)
	Write (lun,140) ('*', I=1,34)
140	Format (' ',T40,34A1)
	Endif

	Unit = LIB$EXTZV (5,6,err_sts)

	Call LINCHK (lun,1)
	Write (lun,150) unit
150	Format (' ',T40,'UNIT = ',I<COMPRESS4 (unit)>,'.')

C
C	Decode the 'SOFTWARE INFORMATION' and return to ERRPRT
C
C	If there was no I/O pending, not all of the data included under 
C	software information will be valid, so only output the software
C	information that is valid.
C

	call linchk (lun,1)

	write(lun,155)
155	format(' ',:)

	if (no_irp .ne. 4) then

	if (emb$w_hd_entry .ne. 98) then

	call ucb$b_ertcnt (lun,emb$b_dv_ertcnt)

	call ucb$b_ertmax (lun,emb$b_dv_ertmax)
	endif
	endif

	call ucb$l_ownuic (lun,emb$l_dv_ownuic)

	call ucb$l_char (lun,emb$l_dv_char)

	call ucb$w_sts (lun,emb$w_dv_sts)

	call ucb$l_opcnt (lun,emb$l_dv_opcnt)

	call ucb$w_errcnt (lun,emb$w_dv_errcnt)

	Att_ucb0 = LIB$EXTZV (31,1,devdepend)
	Field = LIB$EXTZV (4,4,devdepend)
	Port_id = LIB$EXTZV (0,4,devdepend)

	Call LINCHK (lun,2)
	Write (lun,160) devdepend
160	Format ('0',T8,'UCB$L_DEVDEPEND',T24,Z8.8)

C
C	The port id for the RT80x indicates whether the device is 
C	an RT801, RT803, RT805. Determine if the device is an RT80x
C	and if so set up the port id to the proper value to output
C
	Call LINCHK (lun,1)
	If (field .eq. rt80) then

	If (port_id .eq. 2) then
	Port_id = port_id + 1

	Else if (port_id .eq. 3) then
	Port_id = port_id + 2
	Endif

	Write (lun,165) device(field),port_id
165	Format (' ',T40,A<COMPRESSC (device(field))>,I1)


	Else if (field .eq. dyt01) then
C
C	Device is a DYT01 , it has only one port so output the
C	device type
C
	Write (lun,167) device(field)
167	Format (' ',T40,A<COMPRESSC (device(field))>)


	Else if (field .eq. dpm01
	1  .or. 
	2  field .eq. dis) then
C
C	The device is either a DPM01 or Distributed Intelligent Subsystem,
C	both currently support four ports (0-3). Output the device type
C	and the port identification
C
	Write (lun,170) device(field),port_id
170	Format (' ',T40,A<COMPRESSC (device(field))>,
	1 ' - PORT #',I1)
	endif

	If (att_ucb0 .eq. 1) then

	Call LINCHK (lun,1)
	Write (lun,175)
175	Format (' ',T40,'ATTENTION UCB0')

	Endif

	Call LINCHK (lun,2)
	Write (lun,180) devsts
180	Format ('0',T8,'UCB$W_DEVSTS',T24,Z8.8)

	Call OUTPUT (lun,devsts,dvsts,0,0,11,'0')

	if (no_irp .ne. 4) then

	if (emb$w_hd_entry .ne. 98) then

	call linchk (lun,1)

	write(lun,155)

	call sb11_qio (lun,emb$w_dv_func)

	call irp$w_bcnt (lun,emb$w_dv_bcnt)

	call irp$w_boff (lun,emb$w_dv_boff)

	call irp$l_pid (lun,emb$l_dv_rqpid)

	call irp$q_iosb (lun,emb$l_dv_iosb1)
	endif
	endif

	Return



C
C
C

	ENTRY B_SB11 (lun)

	call dhead1 (lun,'UBA DEC DATAWAY')

	Reg_copy(0) = LIB$EXTZV (0,8,registers)
	Reg_copy(1) = LIB$EXTZV (8,8,registers)
	Reg_copy(2) = LIB$EXTZV (16,8,registers)
	Reg_copy(3) = err_sts

	Call BRIEF32 (lun,(4),reg_copy,reg_herald,
	1 EMB$T_DV_NAME,EMB$W_DV_UNIT)

	Return


C
C
C

	ENTRY C_SB11 (lun)

	Reg_copy(0) = LIB$EXTZV (0,8,registers)
	Reg_copy(1) = LIB$EXTZV (8,8,registers)
	Reg_copy(2) = LIB$EXTZV (16,8,registers)
	Reg_copy(3) = err_sts

	Call CRYPTK (lun,32,(4),reg_copy,reg_herald,
	1 EMB$T_DV_NAME,EMB$W_DV_UNIT)

	Return

	End



	subroutine sb11_qio (lun,emb$w_dv_func)



	include 'src$:qiocommon.for /nolist'



	byte		lun

	integer*2	emb$w_dv_func

	integer*4	qiocode(0:1,0:63)




	if (qiocode(0,0) .eq. 0) then

	Qiocode(1,24)	= %loc(IO$_WRITECSR)

	Qiocode(1,25)	= %loc(IO$_READCSR)

	Qiocode(1,26)	= %loc(IO$_SETCHAR)

	Qiocode(1,32)	= %loc(IO$_WRITELBLK)

	Qiocode(1,33)	= %loc(IO$_READLBLK)

	Qiocode(1,34)	= %loc(IO$_ABORT)

	Qiocode(1,35)	= %loc(IO$_SETMODE)

	Qiocode(1,36)	= %loc(IO$_WRITEWTHBUF)

	Qiocode(1,37)	= %loc(IO$_READWTHBUF)

	Qiocode(1,39)	= %loc(IO$_SENSEMODE)

	Qiocode(1,40)	= %loc(IO$_WRITEBUFNCRC)

	Qiocode(1,41)	= %loc(IO$_READWTHXBUF)

	Qiocode(1,48)	= %loc(IO$_WRITEVBLK)

	Qiocode(1,49)	= %loc(IO$_READVBLK)

	do 10,i = 0,63

	qiocode(0,i) = 33

	if (qiocode(1,i) .eq. 0) then

	qiocode(1,i) = %loc(qio_string)
	endif

10	continue
	endif

	call irp$w_func (lun,emb$w_dv_func,
	1 qiocode(0,lib$extzv(0,6,emb$w_dv_func)))

	return

	end
