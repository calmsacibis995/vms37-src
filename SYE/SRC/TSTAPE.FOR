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

	SUBROUTINE TSTAPE (LUN)

C
C	AUTHOR	BRIAN PORTER		CREATION DATE	20-SEP-1979
C
C	Functional description:
C
C	TS11 tape handler device error/timeout display module
C
C	Modified by:
C
C	v03-001	BP0006		Brian Porter,		05-MAR-1982
C		Corrected tssr and tsba in 'b' and 'c' formats.
C**

	INCLUDE 'SRC$:MSGHDR.FOR /NOLIST'
	INCLUDE 'SRC$:DEVERR.FOR /NOLIST'



	BYTE		LUN

	INTEGER*4	MODE

	INTEGER*4	FIELD

	INTEGER*4	COMPRESS4

	INTEGER*4	COMPRESSC

	INTEGER*4	TSBA

	INTEGER*4	TSSR

	INTEGER*4	TS_FUNCTION

	INTEGER*4	UBA_REGS(0:4)

	INTEGER*4	CMD_BUF(0:7)

	INTEGER*4	MSG_BUF(0:6)

	INTEGER*4	MSG_HDR

	INTEGER*4	MSG_LWD

	INTEGER*4	RBPCR

	INTEGER*4	XSTAT0

	INTEGER*4	XSTAT1

	INTEGER*4	XSTAT2

	INTEGER*4	XSTAT3

	integer*4	brief_and_cryptk_buffer(0:6)

	PARAMETER	REWIND = 4

	PARAMETER	READ = 1

	PARAMETER	WRITE_CHAR = 4

	PARAMETER	WRITE = 5

	PARAMETER	WRITE_SUB = 6

	PARAMETER	POSITION = 8

	PARAMETER	FORMAT = 9

	PARAMETER	CONTROL = 10

	PARAMETER	INITIALIZE = 11

	PARAMETER	GET_STATUS = 15

	PARAMETER	TIMEOUT = 96

	PARAMETER	XFER_ERR = 1

	CHARACTER*28	V1XSTAT0(0:15)

	CHARACTER*20	V1XSTAT1(0:7)

	CHARACTER*19	V2XSTAT1(9:13)

	CHARACTER*10	V3XSTAT1(15:15)

	CHARACTER*19	V1XSTAT2(10:10)

	CHARACTER*29	V2XSTAT2(12:15)

	CHARACTER*25	V1XSTAT3(0:7)

	CHARACTER*34	FATAL_ERROR(0:3)

	CHARACTER*34	TERMINATION(0:7)

	CHARACTER*10	V1MSG_HDR(15:20)

	CHARACTER*16	V2MSG_HDR(0:1)

	CHARACTER*31	V3MSG_HDR(0:2)

	CHARACTER*33	V4MSG_HDR(0:4)

	CHARACTER*33	V5MSG_HDR(15:15)

	CHARACTER*13	V1MSG_LWD(9:11)

	CHARACTER*22	TS_COMMAND(0:11)

	CHARACTER*17	READ_MODE(0:4)

	CHARACTER*17	WRITE_MODE(0:2)

	CHARACTER*24	POSITION_MODE(0:5)

	CHARACTER*23	CONTROL_MODE(0:3)

	CHARACTER*13	NORMAL_MODE(0:1)

	CHARACTER*22	FORMAT_MODE(0:3)

	CHARACTER*16	V1CMD_HDR(0:1)

	CHARACTER*17	V2CMD_HDR(7:7)

	CHARACTER*34	V3CMD_HDR(12:15)

	CHARACTER*17	V1TSSR(6:7)

	CHARACTER*30	V2TSSR(10:15)

	CHARACTER*2	EX_ADDR(8:9)

	CHARACTER*7	V1MODE

	character*6	reg_herald(0:6)

	EQUIVALENCE	(EMB$L_DV_REGSAV(0),TSBA)

	EQUIVALENCE	(EMB$L_DV_REGSAV(1),TSSR)

	EQUIVALENCE	(EMB$L_DV_REGSAV(2),UBA_REGS(0))

	EQUIVALENCE	(EMB$L_DV_REGSAV(7),CMD_BUF(0))

	EQUIVALENCE	(EMB$L_DV_REGSAV(15),MSG_BUF(0))

	EQUIVALENCE	(MSG_BUF(0),MSG_HDR)

	EQUIVALENCE	(MSG_BUF(1),MSG_LWD)

	EQUIVALENCE	(MSG_BUF(2),RBPCR)

	EQUIVALENCE	(MSG_BUF(3),XSTAT0)

	EQUIVALENCE	(MSG_BUF(4),XSTAT1)

	EQUIVALENCE	(MSG_BUF(5),XSTAT2)

	EQUIVALENCE	(MSG_BUF(6),XSTAT3)

	EQUIVALENCE	(V2MSG_HDR(0),V1CMD_HDR(0))




	DATA	V1XSTAT0(0)	/'END OF TAPE*'/

	DATA	V1XSTAT0(1)	/'BEGINNING OF TAPE*'/

	DATA	V1XSTAT0(2)	/'WRITE PROTECTED*'/

	DATA	V1XSTAT0(3)	/'PHASE ENCODED DRIVE*'/

	DATA	V1XSTAT0(4)	/'VOLUME CHECK*'/

	DATA	V1XSTAT0(5)	/'INTERRUPT ENABLE*'/

	DATA	V1XSTAT0(6)	/'DEVICE ON-LINE*'/

	DATA	V1XSTAT0(7)	/'TAPE MOTION ON LAST COMMAND*'/

	DATA	V1XSTAT0(8)	/'ILLEGAL ADDRESS*'/

	DATA	V1XSTAT0(9)	/'ILLEGAL COMMAND*'/

	DATA	V1XSTAT0(10)	/'NON-EXECUTABLE FUNCTION*'/

	DATA	V1XSTAT0(11)	/'WRITE LOCK ERROR*'/

	DATA	V1XSTAT0(12)	/'RECORD LENGTH LONG*'/

	DATA	V1XSTAT0(13)	/'LOGICAL END OF TAPE*'/

	DATA	V1XSTAT0(14)	/'RECORD LENGTH SHORT*'/

	DATA	V1XSTAT0(15)	/'TAPE MARK DETECTED*'/



	DATA	V1XSTAT1(0)	/'MULTI-TRACK ERROR*'/

	DATA	V1XSTAT1(1)	/'UNCORRECTABLE ERROR*'/

	DATA	V1XSTAT1(2)	/'POSTAMBLE LONG*'/

	DATA	V1XSTAT1(3)	/'POSTAMBLE SHORT*'/

	DATA	V1XSTAT1(4)	/'INVALID END DATA*'/

	DATA	V1XSTAT1(5)	/'INVALID POSTAMBLE*'/

	DATA	V1XSTAT1(6)	/'SYNCH FAILURE*'/

	DATA	V1XSTAT1(7)	/'INVALID PREAMBLE*'/



	DATA	V2XSTAT1(9)	/'SPEED CHECK*'/

	DATA	V2XSTAT1(10)	/'DESKEW BUFFER FAIL*'/

	DATA	V2XSTAT1(11)	/'TRASH IN GAP*'/

	DATA	V2XSTAT1(12)	/'CREASE DETECTED*'/

	DATA	V2XSTAT1(13)	/'CORRECTABLE ERROR*'/



	DATA	V3XSTAT1(15)	/'DATA LATE*'/




	DATA	V1XSTAT2(10)	/'WRITE CARD FAILURE*'/



	DATA	V2XSTAT2(12)	/'CAPSTAN ACCELERATION FAILURE*'/

	DATA	V2XSTAT2(13)	/'SERIAL BUS PE AT DRIVE*'/

	DATA	V2XSTAT2(14)	/'SILO PARITY ERROR*'/

	DATA	V2XSTAT2(15)	/'OPERATION IN PROGRESS*'/



	DATA	V1XSTAT3(0)	/'REVERSE INTO BOT*'/

	DATA	V1XSTAT3(1)	/'LIMIT EXCEEDED (STATIC)*'/

	DATA	V1XSTAT3(2)	/'NOISE RECORD*'/

	DATA	V1XSTAT3(3)	/'DENSITY CHECK*'/

	DATA	V1XSTAT3(4)	/'CAPSTAN RESPONSE FAIL*'/

	DATA	V1XSTAT3(5)	/'REVERSE*'/

	DATA	V1XSTAT3(6)	/'OPERATION INCOMPLETE*'/

	DATA	V1XSTAT3(7)	/'LIMIT EXCEEDED (DYNAMIC)*'/




	DATA	FATAL_ERROR(0)	/'INTERNAL MICRO DIAGNOSTIC FAILURE*'/

	DATA	FATAL_ERROR(1)	/'I/O SEQUENCER CROM PARITY ERROR*'/

	DATA	FATAL_ERROR(2)	/'MICRO PROCESSOR CROM PARITY ERROR*'/

	DATA	FATAL_ERROR(3)	/'AC LO*'/




	DATA	TERMINATION(0)	/'NORMAL TERMINATION*'/

	DATA	TERMINATION(1)	/'ATTENTION*'/

	DATA	TERMINATION(2)	/'TAPE STATUS ALERT*'/

	DATA	TERMINATION(3)	/'FUNCTION REJECT*'/

	DATA	TERMINATION(4)	/'RECOVERABLE ERROR (MOTION)*'/

	DATA	TERMINATION(5)	/'RECOVERABLE ERROR (NO MOTION)*'/

	DATA	TERMINATION(6)	/'NON-RECOVERABLE ERROR (POS. LOST)*'/

	DATA	TERMINATION(7)	/'FATAL CONTROLLER ERROR*'/




	DATA	V1MSG_HDR(15)	/'ILLEGAL*'/

	DATA	V1MSG_HDR(16)	/'END*'/

	DATA	V1MSG_HDR(17)	/'FAIL*'/

	DATA	V1MSG_HDR(18)	/'ERROR*'/

	DATA	V1MSG_HDR(19)	/'ATTENTION*'/

	DATA	V1MSG_HDR(20)	/'ILLEGAL*'/




	DATA	V2MSG_HDR(0)	/'ONE WORD HEADER*'/

	DATA	V2MSG_HDR(1)	/'ILLEGAL*'/




	DATA	V3MSG_HDR(0)	/'ON-LINE OR OFF-LINE TRANSITION*'/

	DATA	V3MSG_HDR(1)	/'MICRO DIAGNOSTIC FAILURE*'/

	DATA	V3MSG_HDR(2)	/'ILLEGAL CLASS CODE*'/



	DATA	V4MSG_HDR(0)	/'PACKET BAD*'/

	DATA	V4MSG_HDR(1)	/'ILC,ILA OR NBA AFTER TAPE MOTION*'/

	DATA	V4MSG_HDR(2)	/'NON-EXECUTABLE FUNCTION*'/

	DATA	V4MSG_HDR(3)	/'MICRO DIAGNOSTIC FAILURE*'/

	DATA	V4MSG_HDR(4)	/'ILLEGAL CLASS CODE*'/




	DATA	V5MSG_HDR(15)	/'ACKNOWLEDGE, CPU OWNS CMD BUFFER*'/




	DATA	V1MSG_LWD(9)	/'ILLEGAL*'/

	DATA	V1MSG_LWD(10)	/'= 10.(BYTES)*'/

	DATA	V1MSG_LWD(11)	/'ILLEGAL*'/




	DATA	TS_COMMAND(0)	/'INITIALIZE*'/

	DATA	TS_COMMAND(1)	/'READ*'/

	DATA	TS_COMMAND(2)	/'ILLEGAL*'/

	DATA	TS_COMMAND(3)	/'ILLEGAL*'/

	DATA	TS_COMMAND(4)	/'WRITE CHARACTERISTICS*'/

	DATA	TS_COMMAND(5)	/'WRITE*'/

	DATA	TS_COMMAND(6)	/'DIAGNOSTIC COMMAND*'/

	DATA	TS_COMMAND(7)	/'ILLEGAL*'/

	DATA	TS_COMMAND(8)	/'POSITION*'/

	DATA	TS_COMMAND(9)	/'FORMAT*'/

	DATA	TS_COMMAND(10)	/'CONTROL*'/

	DATA	TS_COMMAND(11)	/'ILLEGAL*'/





	DATA	READ_MODE(0)	/'READ NEXT*'/

	DATA	READ_MODE(1)	/'READ PREVIOUS*'/

	DATA	READ_MODE(2)	/'RE-READ PREVIOUS*'/

	DATA	READ_MODE(3)	/'RE-READ NEXT*'/

	DATA	READ_MODE(4)	/'ILLEGAL MODE*'/



	DATA	WRITE_MODE(0)	/'WRITE DATA*'/

	DATA	WRITE_MODE(1)	/'WRITE DATA RETRY*'/

	DATA	WRITE_MODE(2)	/'ILLEGAL MODE*'/



	DATA	POSITION_MODE(0)/'SPACE RECORDS FORWARD*'/

	DATA	POSITION_MODE(1)/'SPACE RECORDS REVERSE*'/

	DATA	POSITION_MODE(2)/'SKIP TAPE MARKS FORWARD*'/

	DATA	POSITION_MODE(3)/'SKIP TAPE MARKS REVERSE*'/

	DATA	POSITION_MODE(4)/'REWIND*'/

	DATA	POSITION_MODE(5)/'ILLEGAL MODE*'/



	DATA	CONTROL_MODE(0)	/'MESSAGE BUFFER RELEASE*'/

	DATA	CONTROL_MODE(1)	/'REWIND AND RELOAD*'/

	DATA	CONTROL_MODE(2)	/'CLEAN*'/

	DATA	CONTROL_MODE(3)	/'ILLEGAL MODE*'/



	DATA	NORMAL_MODE(0)	/'NORMAL MODE*'/

	DATA	NORMAL_MODE(1)	/'ILLEGAL MODE*'/




	DATA	FORMAT_MODE(0)	/'WRITE TAPE MARK*'/

	DATA	FORMAT_MODE(1)	/'ERASE*'/

	DATA	FORMAT_MODE(2)	/'WRITE TAPE MARK ENTRY*'/

	DATA	FORMAT_MODE(3)	/'ILLEGAL MODE*'/




	DATA	V2CMD_HDR(7)	/'INTERRUPT ENABLE*'/



	DATA	V3CMD_HDR(12)	/'SWAP BYTES*'/

	DATA	V3CMD_HDR(13)	/'OPPOSITE*'/

	DATA	V3CMD_HDR(14)	/'CLEAR VOLUME CHECK*'/

	DATA	V3CMD_HDR(15)	/'ACKNOWLEDGE, TS11 OWNS MSG BUFFER*'/




	DATA	V1TSSR(6)	/'OFF LINE*'/

	DATA	V1TSSR(7)	/'SUB-SYSTEM READY*'/



	DATA	V2TSSR(10)	/'NEED BUFFER ADDRESS*'/

	DATA	V2TSSR(11)	/'NON-EXISTENT MEMORY*'/

	DATA	V2TSSR(12)	/'REGISTER MODIFICATION REFUSED*'/

	DATA	V2TSSR(13)	/'SERIAL BUS PARITY ERROR*'/

	DATA	V2TSSR(14)	/'UNIBUS PARITY ERROR*'/

	DATA	V2TSSR(15)	/'SPECIAL CONDITION*'/




	DATA	EX_ADDR(8)	/'16'/

	DATA	EX_ADDR(9)	/'17'/




	DATA	V1MODE		/'MODE = '/



	data	reg_herald(0)	/'BA*'/

	data	reg_herald(1)	/'SR*'/

	data	reg_herald(2)	/'X0*'/

	data	reg_herald(3)	/'X1*'/

	data	reg_herald(4)	/'X2*'/

	data	reg_herald(5)	/'X3*'/

	data	reg_herald(6)	/'RBPCR*'/




	CALL FRCTOF (LUN)

	call dhead1 (lun,'UBA TS11')

	CALL LINCHK (LUN,2)

	WRITE(LUN,10) TSBA
10	FORMAT('0',T8,'TSBA',T24,Z8.4)

	CALL LINCHK (LUN,1)

	WRITE(LUN,15) TSSR
15	FORMAT(' ',T8,'TSSR',T24,Z8.4)

	IF (JIAND(TSSR,'800E'X) .EQ. '800E'X) THEN

	FIELD = LIB$EXTZV(4,2,TSSR)

	CALL LINCHK (LUN,2)

	WRITE(LUN,20) FATAL_ERROR(FIELD)
20	FORMAT(' ',T40,A<COMPRESSC (FATAL_ERROR(FIELD))>,/,
	1 T40,'FATAL CONTROLLER ERROR')
	ELSE

	FIELD = LIB$EXTZV(1,3,TSSR)

	CALL LINCHK (LUN,1)

	WRITE(LUN,25) TERMINATION(FIELD)
25	FORMAT(' ',T40,A<COMPRESSC (TERMINATION(FIELD))>)
	ENDIF

	CALL OUTPUT (LUN,TSSR,V1TSSR,6,7,7,'0')

	DO 28,I = 8,9

	IF (JIAND(TSSR,2**I) .NE. 0) THEN

	CALL LINCHK (LUN,1)

	WRITE(LUN,27) EX_ADDR(I)
27	FORMAT(' ',T40,'EXTENDED BUS ADDRESS BIT ',A2,'.')
	ENDIF

28	CONTINUE

	CALL OUTPUT (LUN,TSSR,V2TSSR,10,10,15,'0')

	CALL LINCHK (LUN,3)

	WRITE(LUN,30)
30	FORMAT('0','COMMAND BUFFER',/)

	CALL LINCHK (LUN,1)

	WRITE(LUN,35) CMD_BUF(0)
35	FORMAT(' ',T8,'CMD HDR',T24,Z8.4)

	TS_FUNCTION = LIB$EXTZV(0,5,CMD_BUF(0))

	CALL LINCHK (LUN,1)

	WRITE(LUN,40) TS_COMMAND(MIN(11,TS_FUNCTION))
40	FORMAT(' ',T40,'FUNCTION = ',
	1 A<COMPRESSC (TS_COMMAND(MIN(11,TS_FUNCTION)))>)

	FIELD = LIB$EXTZV(5,2,CMD_BUF(0))

	CALL LINCHK (LUN,1)

	WRITE(LUN,45) V1CMD_HDR(MIN(1,FIELD))
45	FORMAT(' ',T40,A<COMPRESSC (V1CMD_HDR(MIN(1,FIELD)))>)

	CALL OUTPUT (LUN,CMD_BUF(0),V2CMD_HDR,7,7,7,'0')

	IF (TS_FUNCTION .EQ. INITIALIZE
	1 .OR.
	2 TS_FUNCTION .EQ. CONTROL
	3 .OR.
	4 TS_FUNCTION .EQ. FORMAT
	5 .OR.
	6 TS_FUNCTION .EQ. POSITION
	7 .OR.
	8 TS_FUNCTION .EQ. WRITE_SUB
	9 .OR.
	1 TS_FUNCTION .EQ. WRITE
	2 .OR.
	3 TS_FUNCTION .EQ. WRITE_CHAR
	4 .OR.
	5 TS_FUNCTION .EQ. READ
	6 .OR.
	7 TS_FUNCTION .EQ. GET_STATUS) THEN

	CALL LINCHK (LUN,1)

	MODE = LIB$EXTZV(8,4,CMD_BUF(0))

	IF (TS_FUNCTION .EQ. INITIALIZE
	1 .OR.
	2 TS_FUNCTION .EQ. WRITE_SUB
	3 .OR.
	4 TS_FUNCTION .EQ. WRITE_CHAR
	5 .OR.
	6 TS_FUNCTION .EQ. GET_STATUS) THEN

	WRITE(LUN,50) V1MODE,NORMAL_MODE(MIN(1,MODE))
50	FORMAT(' ',T40,A7,A<COMPRESSC (NORMAL_MODE(MIN(1,MODE)))>)

	ELSE IF (TS_FUNCTION .EQ. CONTROL) THEN

	WRITE(LUN,55) V1MODE,CONTROL_MODE(MIN(4,MODE))
55	FORMAT(' ',T40,A7,A<COMPRESSC (CONTROL_MODE(MIN(4,MODE)))>)

	ELSE IF (TS_FUNCTION .EQ. FORMAT) THEN

	WRITE(LUN,60) V1MODE,FORMAT_MODE(MIN(3,MODE))
60	FORMAT(' ',T40,A7,A<COMPRESSC (FORMAT_MODE(MIN(3,MODE)))>)

	ELSE IF (TS_FUNCTION .EQ. POSITION) THEN

	WRITE(LUN,65) V1MODE,POSITION_MODE(MIN(5,MODE))
65	FORMAT(' ',T40,A7,A<COMPRESSC (POSITION_MODE(MIN(5,MODE)))>)

	ELSE IF (TS_FUNCTION .EQ. WRITE) THEN

	WRITE(LUN,70) V1MODE,WRITE_MODE(MIN(3,MODE))
70	FORMAT(' ',T40,A7,A<COMPRESSC (WRITE_MODE(MIN(3,MODE)))>)

	ELSE IF (TS_FUNCTION .EQ. READ) THEN

	WRITE(LUN,75) V1MODE,READ_MODE(MIN(4,MODE))
75	FORMAT(' ',T40,A7,A<COMPRESSC (READ_MODE(MIN(4,MODE)))>)
	ENDIF
	ENDIF

	CALL OUTPUT (LUN,CMD_BUF(0),V3CMD_HDR,12,12,15,'0')

	IF (TS_FUNCTION .EQ. WRITE
	1 .OR.
	2 TS_FUNCTION .EQ. WRITE_CHAR
	3 .OR.
	4 TS_FUNCTION .EQ. READ) THEN

	CALL LINCHK (LUN,1)

	WRITE(LUN,80) CMD_BUF(1)
80	FORMAT(' ',T8,'LO ADDR BITS',T24,Z8.4)

	CALL LINCHK (LUN,1)

	WRITE(LUN,85) CMD_BUF(2)
85	FORMAT(' ',T8,'HI ADDR BITS',T24,Z8.4)

	CALL CALC_MAP (LUN,0,CMD_BUF(2),CMD_BUF(1))

	CALL LINCHK (LUN,1)

	WRITE(LUN,90) CMD_BUF(3)
90	FORMAT(' ',T8,'SIZE',T24,Z8.4)

	CALL LINCHK (LUN,1)

	WRITE(LUN,95) CMD_BUF(3)
95	FORMAT(' ',T40,'BUFFER SIZE = ',I<COMPRESS4 (CMD_BUF(3))>,'. BYTES')

	ELSE IF (TS_FUNCTION .EQ. POSITION) THEN

	CALL LINCHK (LUN,1)

	WRITE(LUN,98) CMD_BUF(1)
98	FORMAT(' ',T8,'SKIP/SPACE COUNT',T24,Z8.4)

	CALL LINCHK (LUN,1)

	WRITE(LUN,100) CMD_BUF(1)
100	FORMAT(' ',T40,'SKIP/SPACE ',I<COMPRESS4 (CMD_BUF(1))>
	1 ,'. TAPE MARKS/REC')
	ENDIF

	IF (EMB$W_DV_ENTRY .NE. TIMEOUT) THEN

	CALL LINCHK (LUN,3)

	IF (JIAND(TSSR,'400'X) .NE. 0) THEN

	WRITE(LUN,105)
105	FORMAT(' ','MESSAGE BUFFER NOT VALID',/)
	ELSE

	WRITE(LUN,110)
110	FORMAT('0','MESSAGE BUFFER',/)

	CALL LINCHK (LUN,1)

	WRITE(LUN,115) MSG_HDR
115	FORMAT(' ',T8,'MSG HDR',T24,Z8.4)

	CALL LINCHK (LUN,1)

	FIELD = LIB$EXTZV(0,5,MSG_HDR)

	WRITE(LUN,120) V1MSG_HDR(MAX(15,MIN(20,FIELD)))
120	FORMAT(' ',T40,'MESSAGE TYPE = ',
	1 A<COMPRESSC (V1MSG_HDR(MAX(15,MIN(20,FIELD))))>)

	CALL LINCHK (LUN,1)

	FIELD = LIB$EXTZV(5,3,MSG_HDR)

	WRITE(LUN,125) V2MSG_HDR(MIN(1,FIELD))
125	FORMAT(' ',T40,A<COMPRESSC (V2MSG_HDR(MIN(1,FIELD)))>,
	1 ' PACKET FORMAT')

	IF (JIAND(MSG_HDR,'11'X) .EQ. '11'X) THEN

	FIELD = LIB$EXTZV(8,4,MSG_HDR)

	CALL LINCHK (LUN,1)

	IF (JIAND(MSG_HDR,'2'X) .EQ. '2'X) THEN

	WRITE(LUN,130) V3MSG_HDR(MIN(2,FIELD))
130	FORMAT(' ',T40,A<COMPRESSC (V3MSG_HDR(MIN(2,FIELD)))>)
	ELSE

	WRITE(LUN,135) V4MSG_HDR(MIN(4,FIELD))
135	FORMAT(' ',T40,A<COMPRESSC (V4MSG_HDR(MIN(4,FIELD)))>)
	ENDIF
	ENDIF

	CALL OUTPUT (LUN,MSG_HDR,V5MSG_HDR,15,15,15,'0')

	CALL LINCHK (LUN,1)

	WRITE(LUN,140) MSG_LWD
140	FORMAT(' ',T8,'MSG LEN',T24,Z8.4)

	CALL LINCHK (LUN,1)

	FIELD = LIB$EXTZV(0,16,MSG_LWD)

	WRITE(LUN,145) V1MSG_LWD(MAX(9,MIN(11,FIELD)))
145	FORMAT(' ',T40,'MESSAGE LENGTH ',
	1 A<COMPRESSC (V1MSG_LWD(MAX(9,MIN(11,FIELD))))>)

	CALL LINCHK (LUN,1)

	WRITE(LUN,150) RBPCR
150	FORMAT(' ',T8,'RBPCR',T24,Z8.4)

	FIELD = LIB$EXTZV(0,16,RBPCR)

	IF (TS_FUNCTION .EQ. READ) THEN

	CALL LINCHK (LUN,1)

	WRITE(LUN,152) FIELD
152	FORMAT(' ',T40,'RES. BYTES OF XFER = ',I<COMPRESS4 (FIELD)>,'.')

	ELSE IF (TS_FUNCTION .EQ. POSITION
	1 .AND.
	2 MODE .NE. REWIND) THEN

	CALL LINCHK (LUN,1)

	WRITE(LUN,154) FIELD
154	FORMAT(' ',T40,'RES. REC/MARKS OF SKIP = ',I<COMPRESS4 (FIELD)>,'.')
	ENDIF

	CALL LINCHK (LUN,1)

	WRITE(LUN,155) XSTAT0
155	FORMAT(' ',T8,'XSTAT0',T24,Z8.4)

	CALL OUTPUT (LUN,XSTAT0,V1XSTAT0,0,0,15,'0')

	CALL LINCHK (LUN,1)

	WRITE(LUN,160) XSTAT1
160	FORMAT(' ',T8,'XSTAT1',T24,Z8.4)

	CALL OUTPUT (LUN,XSTAT1,V1XSTAT1,0,0,7,'0')

	CALL OUTPUT (LUN,XSTAT1,V2XSTAT1,9,9,13,'0')

	CALL OUTPUT (LUN,XSTAT1,V3XSTAT1,15,15,15,'0')

	CALL LINCHK (LUN,1)

	WRITE(LUN,165) XSTAT2
165	FORMAT(' ',T8,'XSTAT2',T24,Z8.4)

	DO 178,I = 0,8

	IF (JIAND(XSTAT2,2**I) .NE. 0) THEN

	CALL LINCHK (LUN,1)

	IF (I .NE. 8) THEN

	WRITE(LUN,170) I
170	FORMAT(' ',T40,'DEAD TRACK CHANNEL ',I1,'.')
	ELSE

	WRITE(LUN,175)
175	FORMAT(' ',T40,'DEAD TRACK PARITY CHANNEL')
	ENDIF
	ENDIF

178	CONTINUE

	CALL OUTPUT (LUN,XSTAT2,V1XSTAT2,10,10,10,'0')

	CALL OUTPUT (LUN,XSTAT2,V2XSTAT2,12,12,15,'0')

	CALL LINCHK (LUN,1)

	WRITE(LUN,180) XSTAT3
180	FORMAT(' ',T8,'XSTAT3',T24,Z8.4)

	CALL OUTPUT (LUN,XSTAT3,V1XSTAT3,0,0,7,'0')

	FIELD = LIB$EXTZV(8,8,XSTAT3)

	IF (FIELD .NE. 0) THEN

	CALL LINCHK (LUN,1)

	WRITE(LUN,185) FIELD
185	FORMAT(' ',T40,'MICRO DIAGNOSTIC ERROR CODE ',O3.3)
	ENDIF
	ENDIF


	if (
	1 ((ts_function .eq. read
	1 .or.
	1 ts_function .eq. write
	1 .or.
	1 ts_function .eq. write_char
	1 .or.
	1 ts_function .eq. write_sub)
	1 .and.
	1 emb$w_hd_entry .ne. 96)
	1 .or.
	1 emb$w_hd_entry .ne. 98
	1 ) then

C
C	IF THE TS11 FUNCTION IS A READ REVERSE THEN
C	THE PREVIOUS MAP IS THE FINAL MAP PLUS ONE.
C

	if (uba_regs(0) .ne. 0) then

	call uba_datapath (lun,uba_regs(0),uba_regs(1))
	endif

	call calc_map2 (0,cmd_buf(2),cmd_buf(1),field)

	call uba_mapping (lun,field,uba_regs(2))

	if (lib$extzv (16,16,emb$l_dv_iosb1) .gt. 512) then

	IF (TS_FUNCTION .EQ. READ
	1 .AND.
	2 (MODE .EQ. 1
	3 .OR.
	4 MODE .EQ. 2)) THEN

	call uba_mapping (lun,(field+2),uba_regs(4))
	ELSE

	call uba_mapping (lun,(field+1),uba_regs(3))
	ENDIF
	endif
	ENDIF
	endif

	call linchk (lun,1)

	write(lun,190)
190	format(' ',:)

	if (emb$w_hd_entry .ne. 98) then

	call ucb$b_ertcnt (lun,emb$b_dv_ertcnt)

	call ucb$b_ertmax (lun,emb$b_dv_ertmax)
	endif

	call ucb$l_ownuic (lun,emb$l_dv_ownuic)

	call ucb$l_char (lun,emb$l_dv_char)

	call ucb$w_sts (lun,emb$w_dv_sts)

	call ucb$l_opcnt (lun,emb$l_dv_opcnt)

	call ucb$w_errcnt (lun,emb$w_dv_errcnt)

	if (emb$w_hd_entry .ne. 98) then

	call linchk (lun,1)

	write(lun,190)

	call tstape_qio (lun,emb$w_dv_func)

	call irp$w_bcnt (lun,emb$w_dv_bcnt)

	call irp$w_boff (lun,emb$w_dv_boff)

	call irp$l_pid (lun,emb$l_dv_rqpid)

	call irp$q_iosb (lun,emb$l_dv_iosb1)
	endif

	RETURN




	ENTRY B_TSTAPE (LUN)



	call dhead1 (lun,'UBA TS11')

	brief_and_cryptk_buffer(0) = tsba

	brief_and_cryptk_buffer(1) = tssr

	brief_and_cryptk_buffer(2) = xstat0

	brief_and_cryptk_buffer(3) = xstat1

	brief_and_cryptk_buffer(4) = xstat2

	brief_and_cryptk_buffer(5) = xstat3

	brief_and_cryptk_buffer(6) = rbpcr

	call brief16 (lun,(7),brief_and_cryptk_buffer,reg_herald,emb$t_dv_name,
	1 emb$w_dv_unit)

	RETURN




	ENTRY C_TSTAPE (LUN)



	brief_and_cryptk_buffer(0) = tsba

	brief_and_cryptk_buffer(1) = tssr

	brief_and_cryptk_buffer(2) = xstat0

	brief_and_cryptk_buffer(3) = xstat1

	brief_and_cryptk_buffer(4) = xstat2

	brief_and_cryptk_buffer(5) = xstat3

	brief_and_cryptk_buffer(6) = rbpcr

	call cryptk (lun,16,(7),brief_and_cryptk_buffer,reg_herald,
	1 emb$t_dv_name,emb$w_dv_unit)

	RETURN

	END



	subroutine tstape_qio (lun,emb$w_dv_func)



	include 'src$:qiocommon.for /nolist'



	byte		lun

	integer*2	emb$w_dv_func

	integer*4	qiocode(0:1,0:63)




	if (qiocode(0,0) .eq. 0) then

	qiocode(1,00) = %loc(io$_nop)

	qiocode(1,01) = %loc(io$_unload)

	qiocode(1,02) = %loc(io$_spacefile)

	qiocode(1,03) = %loc(io$_recal)

	qiocode(1,06) = %loc(io$_erasetape)

	qiocode(1,08) = %loc(io$_packack)

	qiocode(1,09) = %loc(io$_spacerecord)

	qiocode(1,10) = %loc(io$_writecheck)

	qiocode(1,11) = %loc(io$_writepblk)

	qiocode(1,12) = %loc(io$_readpblk)

	qiocode(1,22) = %loc(io$_rereadn)

	qiocode(1,23) = %loc(io$_rereadp)

	qiocode(1,24) = %loc(io$_writeret)

	qiocode(1,25) = %loc(io$_readpreset)

	qiocode(1,26) = %loc(io$_setchar)

	qiocode(1,27) = %loc(io$_sensechar)

	qiocode(1,28) = %loc(io$_writemark)

	qiocode(1,29) = %loc(io$_wrttmkr)

	qiocode(1,30) = %loc(io$_clean)

	qiocode(1,32) = %loc(io$_writelblk)

	qiocode(1,33) = %loc(io$_readlblk)

	qiocode(1,34) = %loc(io$_rewindoff)

	qiocode(1,35) = %loc(io$_setmode)

	qiocode(1,36) = %loc(io$_rewind)

	qiocode(1,37) = %loc(io$_skipfile)

	qiocode(1,38) = %loc(io$_skiprecord)

	qiocode(1,39) = %loc(io$_sensemode)

	qiocode(1,40) = %loc(io$_writeof)

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

	call irp$w_func (lun,emb$w_dv_func,
	1 qiocode(0,lib$extzv(0,6,emb$w_dv_func)))

	return

	end
