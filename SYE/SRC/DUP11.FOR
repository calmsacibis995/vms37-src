	SUBROUTINE DUP11 (lun,parcsr,rxcsr,rxdbuf,txcsr,txdbuf)
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
C	Author:	Sharon Reynolds			Creation date: 8-Sept-80
C
C
C
C	Functional description:
C
C	This module decodes the Dup11 register contents. It is called
C	by the DUP3271 module.
C
C	Modified by:
C
C	v02-002	BP0002		Brian Porter,		06-NOV-1981
C		Deleted 'device registers' banner.
C
C	v02-001	BP0001		Brian Porter,		29-JUN-1981
C		Removed call to ILLEGAL_BITS.  Added DIAGNOSTIC_MODE.
C**
C--

	


	Byte		lun

	Integer*4	addrs
	Integer*4	char
	Integer*4	field
	Integer*4	rxcsr
	Integer*4	rxdbuf
	Integer*4	txcsr
	Integer*4	txdbuf
	Integer*4	parcsr
	Integer*4	compressC
	Integer*4	compress4

	logical*1	diagnostic_mode

	Character*23	protocol(0:1)
	Character*12	oper_mode(0:1)
	Character*18	rxcsr_1(0:0)
	Character*26	rxcsr_2(3:8)
	Character*24	rxcsr_3(10:11)
	Character*18	rxcsr_4(14:15)
	Character*26	rxdbuf_1(8:10)
	Character*19	rxdbuf_2(12:12)
	Character*17	rxdbuf_3(14:15)
	Character*5	txcsr_1(4:4)
	Character*29	txcsr_2(6:9)
	Character*28	txcsr_3(15:15)
	Character*27	txdbuf_1(8:10)
	Character*12	parcsr_1(9:9)
	Character*26	dtr_status(0:1)
	Character*22	rts_status(0:1)
	Character*21	dsr_status(0:1)
	Character*21	car_status(0:1)
	Character*20	cts_status(0:1)



C
C	Define text for bits in the RXCSR register
C

	Data	rxcsr_1(0)	/'DATA SET CHANGE B*'/
	Data	rxcsr_2(3)	/'SECONDARY TRANSMIT DATA*'/
	Data	rxcsr_2(4)	/'RECEIVER ENABLE*'/
	Data	rxcsr_2(5)	/'DATA SET INTERRUPT ENABLE*'/
	Data	rxcsr_2(6)	/'RECEIVER INTERRUPT ENABLE*'/
	Data	rxcsr_2(7)	/'RECEIVER DONE*'/
	Data	rxcsr_2(8)	/'STRIP SYNC CHARACTER*'/
	Data	rxcsr_3(10)	/'SECONDARY RECEIVED DATA*'/
	Data	rxcsr_3(11)	/'RECEIVER ACTIVE*'/
	Data	rxcsr_4(14)	/'RING*'/
	Data	rxcsr_4(15)	/'DATA SET CHANGE A*'/


C
C	Define bits for MODEM/LINE STATUS from rxcsr register
C

	Data	dtr_status(0)	/'DATA TERMINAL READY = OFF*'/
	Data	dtr_status(1)	/'DATA TERMINAL READY = ON*'/

	Data	rts_status(0)	/'REQUEST TO SEND = OFF*'/
	Data	rts_status(1)	/'REQUEST TO SEND = ON*'/

	Data	dsr_status(0)	/'DATA SET READY = OFF*'/
	Data	dsr_status(1)	/'DATA SET READY = ON*'/

	Data	car_status(0)	/'CARRIER DETECT = OFF*'/
	Data	car_status(1)	/'CARRIER DETECT = ON*'/

	Data	cts_status(0)	/'CLEAR TO SEND = OFF*'/
	Data	cts_status(1)	/'CLEAR TO SEND = ON*'/


C
C	Define text for bits in the RXDBUF register
C

	Data	rxdbuf_1(8)	/'START OF RECEIVED MESSAGE*'/
	Data	rxdbuf_1(9)	/'END OF RECEIVED MESSAGE*'/
	Data	rxdbuf_1(10)	/'RECEIVER ABORT*'/
	Data	rxdbuf_2(12)	/'RECEIVER CRC ERROR*'/
	Data	rxdbuf_3(14)	/'RECEIVER OVERRUN*'/
	Data	rxdbuf_3(15)	/'RECEIVER ERROR*'/


C
C	Define text for bits in the TXCSR register
C

	Data	oper_mode(0)	/'FULL DUPLEX*'/
	Data	oper_mode(1)	/'HALF DUPLEX*'/
	Data	txcsr_1(4)	/'SEND*'/
	Data	txcsr_2(6)	/'TRANSMITTER INTERRUPT ENABLE*'/
	Data	txcsr_2(7)	/'TRANSMITTER DONE*'/
	Data	txcsr_2(8)	/'DEVICE RESET*'/
	Data	txcsr_2(9)	/'TRANSMITTER ACTIVE*'/
	Data	txcsr_3(15)	/'TRANSMITTER DATA LATE ERROR*'/


C
C	Define text for bits in the TXDBUF register
C

	Data	txdbuf_1(8)	/'TRANSMIT START OF MESSAGE*'/
	Data	txdbuf_1(9)	/'END OF TRANSMITTED MESSAGE*'/
	Data	txdbuf_1(10)	/'TRANSMIT ABORT*'/


C
C	Define text for bits in the PARCSR register
C

	Data	parcsr_1(9)	/'CRC INHIBIT*'/
	Data	protocol(0)	/'BIT ORIENTED PROTOCOL*'/
	Data	protocol(1)	/'BYTE ORIENTED PROTOCOL*'/





	diagnostic_mode = .false.

	if (lib$extzv(11,2,txcsr) .ne. 0) diagnostic_mode = .true.
C
C	Decode receiver control and status register
C

	Call LINCHK (lun,2)
	Write (lun,20) rxcsr
20	Format ('0',T8,'RXCSR',T24,Z8.4)

	if (.not. diagnostic_mode) then

	Call LINCHK (lun,1)
	Write (lun,30) ('*',I=1,34)
30	Format (' ',T40,34A1)

	Call LINCHK (lun,1)
	Write (lun,40)
40	Format (' ',T47,'MODEM/LINE STATUS')

	Field=LIB$EXTZV (1,1,rxcsr)

	Call LINCHK (lun,1)
	Write (lun,50) dtr_status(field)
50	Format (' ',T40,A<compressC (dtr_status(field))>)


	Field=LIB$EXTZV (2,1,rxcsr)

	Call LINCHK (lun,1)
	Write (lun,60) rts_status(field)
60	Format (' ',T40,A<compressC (rts_status(field))>)


	Field=LIB$EXTZV (9,1,rxcsr)

	Call LINCHK (lun,1)
	Write (lun,70) dsr_status(field)
70	Format (' ',T40,A<compressC (dsr_status(field))>)


	Field=LIB$EXTZV (12,1,rxcsr)

	Call LINCHK (lun,1)
	Write (lun,80) car_status(field)
80	Format (' ',T40,A<compressC (car_status(field))>)


	Field=LIB$EXTZV (13,1,rxcsr)

	Call LINCHK (lun,1)
	Write (lun,90) cts_status(field)
90	Format (' ',T40,A<compressC (cts_status(field))>)

	Call LINCHK (lun,1)
	Write (lun,100) ('*',I=1,34)
100	Format (' ',T40,34A1)

	Call OUTPUT (lun,rxcsr,rxcsr_1,0,0,0,'0')

	Call OUTPUT (lun,rxcsr,rxcsr_2,3,3,8,'0')

	Call OUTPUT (lun,rxcsr,rxcsr_3,10,10,11,'0')

	Call OUTPUT (lun,rxcsr,rxcsr_4,14,14,15,'0')
	endif

C
C	Decode receiver data buffer register
C

	Call LINCHK (lun,1)
	Write (lun,110) rxdbuf
110	Format (' ',T8,'RXDBUF',T24,Z8.4)

	if (.not. diagnostic_mode) then

	Field=LIB$EXTZV(0,8,rxdbuf)

	Call LINCHK (lun,1)
	Write (lun,120) field
120	Format (' ',T40,'RECEIVER DATA BUFFER = ',
	1 I<compress4 (field)>,'.')

	Call OUTPUT (lun,rxdbuf,rxdbuf_1,8,8,10,'0')

	Call OUTPUT (lun,rxdbuf,rxdbuf_2,12,12,12,'0')

	Call OUTPUT (lun,rxdbuf,rxdbuf_3,14,14,15,'0')
	endif

C
C	Decode tranmitter control and status register
C

	Call LINCHK (lun,1)
	Write (lun,130) txcsr
130	Format (' ',T8,'TXCSR',T24,Z8.4)

	if (.not. diagnostic_mode) then

	Field=LIB$EXTZV(3,1,txcsr)

	Call LINCHK (lun,1)
	Write (lun,140) oper_mode(field)
140	Format (' ',T40,'OPERATION MODE = ', 
	1 A<compressC (oper_mode(field))>)

	Call OUTPUT (lun,txcsr,txcsr_1,4,4,4,'0')

	Call OUTPUT (lun,txcsr,txcsr_2,6,6,9,'0')

	Call OUTPUT (lun,txcsr,txcsr_3,15,15,15,'0')
	else

	Call LINCHK (lun,1)
	Write (lun,150)
150	Format (' ',T40,'DIAGNOSTIC MODE')
	endif

C
C	Decode transmitter data buffer register
C

	Call LINCHK (lun,1)
	Write (lun,160) txdbuf
160	Format (' ',T8,'TXDBUF',T24,Z8.4)

	if (.not. diagnostic_mode) then

	Field=LIB$EXTZV(0,8,txdbuf)

	Call LINCHK (lun,1)
	Write (lun,170) field
170	Format (' ',T40,'TRANSMITTER DATA BUFFER = ',
	1 I<compress4 (field)>,'.')

	Call OUTPUT (lun,txdbuf,txdbuf_1,8,8,10,'0')
	endif

C
C	Decode and output PARCSR register contents
C



	Call LINCHK (lun,1)
	Write (lun,180) parcsr
180	Format (' ',T8,'PARCSR',T24,Z8.4,/,
	1 T40,'**  LOADED WITH  **')

	if (.not. diagnostic_mode) then

	Call OUTPUT (lun,parcsr,parcsr_1,9,9,9,'0')

	Temp=LIB$EXTZV (12,1,parcsr)

	Field=LIB$EXTZV (15,1,parcsr)

	Call LINCHK (lun,1)
	Write (lun,190) protocol(field)
190	Format (' ',T40, A<compressC (protocol(field))> )

	Call LINCHK (lun,1)
	If (field .eq. 0 .and. temp .eq.0) then

	Write (lun,200)
200	Format (' ',T40,'OPERATING AS A PRIMARY STATION')

	Else if (field .eq. 0 .and. temp .eq. 1) then 

	Write (lun,210) 
210	Format (' ',T40,'OPERATING AS A SECONDARY STATION')

	Addrs=LIB$EXTZV (0,8,parcsr)

	Call LINCHK (lun,1)
	Write (lun,220) addrs
220	Format (' ',T40,'SECONDARY STATION ADDRESS = ',
	1 I<Compress4 (addrs)>,'.')

	Else

	Char=LIB$EXTZV (0,8,parcsr)

	Write (lun,230) char
230	Format (' ',T40,'EXPECTED SYNC CHAR = ', 
	1 I<Compress4 (char)>,'.')


	Endif
	endif

	Return


	END
