	SUBROUTINE TUTAPE (LUN)
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
C	AUTHOR	BRIAN PORTER		CREATION DATE	5-OCT-1979
C
C	Fucntional description:
C
C	This module displays TU58 errors.
C
C	Modified by:
C
C	v02-004	BP0004		Brian Porter,		23-NOV-1981
C		Minor edit.
C
C	v02-003	BP0003		Brian Porter,		05-NOV-1981
C		Added 'device attention' support.
C
C	v02-002	BP0002		Brian Porter,		01-JUL-1981
C		Added call to LOGGER and DHEAD.  Added DIAGNOSTIC_MODE.
C
C	v02-001	BP0001		Brian Porter,		19-JUL-1980
C		Corrected Fortran format error when end packet has illegal
C		byte count.  Removed call to UNUSED_BITS.
C**


	INCLUDE 'SRC$:MSGHDR.FOR /NOLIST'
	INCLUDE 'SRC$:DEVERR.FOR /NOLIST'



	BYTE		LUN

	BYTE		CMD_PKT(0:13)

	BYTE		END_PKT(0:13)

	BYTE		V1SUCCESS_CODE(0:11)

	INTEGER*4	FIELD

	INTEGER*4	RCSR

	INTEGER*4	RBUF

	INTEGER*4	XCSR

	INTEGER*4	XBUF

	INTEGER*4	COMPRESS4

	INTEGER*4	COMPRESSC

	logical*1	diagnostic_mode

	CHARACTER*14	UNIT_NUMBER

	CHARACTER*11	UNUSED_BYTE

	CHARACTER*19	CONTROL_PACKET

	CHARACTER*14	COMMAND_PACKET

	CHARACTER*7	OP_CODE

	CHARACTER*17	PBYTE_COUNT

	CHARACTER*15	SEQUENCE_LO

	CHARACTER*17	BYTECOUNT_LO

	CHARACTER*19	BLOCK_LO

	CHARACTER*15	CHECKSUM_LO

	CHARACTER*17	V1RCSR(6:7)

	CHARACTER*16	V2RCSR(11:11)

	CHARACTER*15	V1RBUF(12:15)

	CHARACTER*6	V1XCSR(0:0)

	CHARACTER*18	V2XCSR(6:7)

	CHARACTER*20	V1OP_CODE(-1:12)

	CHARACTER*16	V2OP_CODE(63:65)

	CHARACTER*10	MODIFIER(0:0)

	CHARACTER*18	V1SUM_STATUS(4:7)

	CHARACTER*22	V2SUCCESS_CODE(0:12)

	CHARACTER*9	BYTE_COUNT(9:11)

	CHARACTER*5	REG_HERALD(0:3)

	PARAMETER	TIMEOUT = 96

	PARAMETER	READ = 2

	PARAMETER	WRITE = 3

	PARAMETER	POSITION = 5

	EQUIVALENCE	(EMB$L_DV_REGSAV(0),XCSR)

	EQUIVALENCE	(EMB$L_DV_REGSAV(1),XBUF)

	EQUIVALENCE	(EMB$L_DV_REGSAV(2),RCSR)

	EQUIVALENCE	(EMB$L_DV_REGSAV(3),RBUF)

	EQUIVALENCE	(EMB(98),CMD_PKT(0))

	EQUIVALENCE	(EMB(112),END_PKT(0))



	DATA	UNIT_NUMBER	/'UNIT NUMBER = '/



	DATA	UNUSED_BYTE	/'UNUSED BYTE'/



	DATA	CONTROL_PACKET	/'TU58 CONTROL PACKET'/



	DATA	COMMAND_PACKET	/'COMMAND PACKET'/



	DATA	OP_CODE		/'OP CODE'/



	DATA	PBYTE_COUNT	/'PACKET BYTE COUNT'/



	DATA	SEQUENCE_LO	/'SEQUENCE LO, HI'/



	DATA	BYTECOUNT_LO	/'BYTE COUNT LO, HI'/



	DATA	BLOCK_LO	/'BLOCK NUMBER LO, HI'/




	DATA	CHECKSUM_LO	/'CHECKSUM LO, HI'/




	DATA	V1RCSR(6)	/'INTERRUPT ENABLE*'/

	DATA	V1RCSR(7)	/'RECEIVER DONE*'/




	DATA	V2RCSR(11)	/'RECEIVER ACTIVE*'/



	DATA	V1RBUF(12)	/'PARITY ERROR*'/

	DATA	V1RBUF(13)	/'FRAMING ERROR*'/

	DATA	V1RBUF(14)	/'OVER-RUN ERROR*'/

	DATA	V1RBUF(15)	/'ERROR*'/



	DATA	V1XCSR(0)	/'BREAK*'/



	DATA	V2XCSR(6)	/'INTERRUPT ENABLE*'/

	DATA	V2XCSR(7)	/'TRANSMITTER READY*'/




	DATA	V1OP_CODE(-1)	/'ILLEGAL FUNCTION*'/

	DATA	V1OP_CODE(0)	/'NO OPERATION*'/

	DATA	V1OP_CODE(1)	/'INITIALIZE*'/

	DATA	V1OP_CODE(2)	/'READ*'/

	DATA	V1OP_CODE(3)	/'WRITE*'/

	DATA	V1OP_CODE(4)	/'COMPARE*'/

	DATA	V1OP_CODE(5)	/'POSITION*'/

	DATA	V1OP_CODE(6)	/'ABORT*'/

	DATA	V1OP_CODE(7)	/'DIAGNOSE*'/

	DATA	V1OP_CODE(8)	/'GET STATUS*'/

	DATA	V1OP_CODE(9)	/'SET STATUS*'/

	DATA	V1OP_CODE(10)	/'GET CHARACTERISTICS*'/

	DATA	V1OP_CODE(11)	/'SET CHARACTERISTICS*'/

	DATA	V1OP_CODE(12)	/'ILLEGAL FUNCTION*'/




	DATA	V2OP_CODE(63)	/'ILLEGAL OP CODE*'/

	DATA	V2OP_CODE(64)	/'SEND END PACKET*'/

	DATA	V2OP_CODE(65)	/'ILLEGAL OP CODE*'/




	DATA	MODIFIER(0)	/'DATACHECK*'/




	DATA	V1SUM_STATUS(4)/'LOGIC ERROR*'/

	DATA	V1SUM_STATUS(5)/'MOTION ERROR*'/

	DATA	V1SUM_STATUS(6)/'TRANSFER ERROR*'/

	DATA	V1SUM_STATUS(7)/'SPECIAL CONDITION*'/



	DATA	V1SUCCESS_CODE(0)/'00'X/

	DATA	V1SUCCESS_CODE(1)/'01'X/

	DATA	V1SUCCESS_CODE(2)/'FF'X/

	DATA	V1SUCCESS_CODE(3)/'FE'X/

	DATA	V1SUCCESS_CODE(4)/'F8'X/

	DATA	V1SUCCESS_CODE(5)/'F7'X/

	DATA	V1SUCCESS_CODE(6)/'F5'X/

	DATA	V1SUCCESS_CODE(7)/'EF'X/

	DATA	V1SUCCESS_CODE(8)/'E0'X/

	DATA	V1SUCCESS_CODE(9)/'DF'X/

	DATA	V1SUCCESS_CODE(10)/'D0'X/

	DATA	V1SUCCESS_CODE(11)/'C9'X/



	DATA	V2SUCCESS_CODE(0)/'NORMAL COMPLETION*'/

	DATA	V2SUCCESS_CODE(1)/'RETRY COMPLETION*'/

	DATA	V2SUCCESS_CODE(2)/'SELF TEST FAILURE*'/

	DATA	V2SUCCESS_CODE(3)/'PARTIAL OPERATION*'/

	DATA	V2SUCCESS_CODE(4)/'INVALID UNIT NUMBER*'/

	DATA	V2SUCCESS_CODE(5)/'NO CARTRIDGE PRESENT*'/

	DATA	V2SUCCESS_CODE(6)/'WRITE PROTECTED*'/

	DATA	V2SUCCESS_CODE(7)/'DATA CHECK*'/

	DATA	V2SUCCESS_CODE(8)/'BLOCK NOT FOUND*'/

	DATA	V2SUCCESS_CODE(9)/'MOTOR STOPPED*'/

	DATA	V2SUCCESS_CODE(10)/'INVALID OP CODE*'/

	DATA	V2SUCCESS_CODE(11)/'INVALID RECORD NUMBER*'/

	DATA	V2SUCCESS_CODE(12)/'ILLEGAL SUCCESS CODE*'/




	DATA	BYTE_COUNT(9)	/' ILLEGAL*'/

	DATA	BYTE_COUNT(10)	/' = 10.*'/

	DATA	BYTE_COUNT(11)	/' ILLEGAL*'/




	DATA	REG_HERALD(0)	/'RCSR*'/

	DATA	REG_HERALD(1)	/'RBUF*'/

	DATA	REG_HERALD(2)	/'XCSR*'/

	DATA	REG_HERALD(3)	/'XBUF*'/



	CALL FRCTOF (LUN)

	if (emb$t_dv_name(1:3) .eq. 'CSA') then

	call dhead1 (lun,'CONSOLE TU58')
	else

	call dhead1 (lun,'UBA TU58')
	endif

	diagnostic_mode = .false.

	if (lib$extzv(2,1,xcsr) .eq. 1) diagnostic_mode = .true.

	CALL LINCHK (LUN,2)

	WRITE(LUN,10) RCSR
10	FORMAT('0',T8,'RCSR',T24,Z8.4)

	if (.not. diagnostic_mode) then

	CALL OUTPUT (LUN,RCSR,V1RCSR,6,6,7,'0')

	CALL OUTPUT (LUN,RCSR,V2RCSR,11,11,11,'0')
	endif

	CALL LINCHK (LUN,1)

	WRITE(LUN,15) RBUF
15	FORMAT(' ',T8,'RBUF',T24,Z8.4)

	if (.not. diagnostic_mode) then

	DO 19,I = 12,15

	IF (JIAND(RBUF,2**I) .NE. 0) THEN

	CALL LINCHK (LUN,1)

	WRITE(LUN,18) V1RBUF(I)
18	FORMAT(' ',T40,'RECEIVE DATA ',A<COMPRESSC (V1RBUF(I))>)
	ENDIF

19	CONTINUE
	endif

	CALL LINCHK (LUN,1)

	WRITE(LUN,20) XCSR
20	FORMAT(' ',T8,'XCSR',T24,Z8.4)

	if (.not. diagnostic_mode) then

	CALL OUTPUT (LUN,XCSR,V1XCSR,0,0,0,'0')

	CALL OUTPUT (LUN,XCSR,V2XCSR,6,6,7,'0')
	else

	CALL LINCHK (LUN,1)

	WRITE(LUN,25)
25	FORMAT(' ',T40,'DIAGNOSTIC MODE')
	endif

	CALL LINCHK (LUN,1)

	WRITE (LUN,30) XBUF
30	FORMAT(' ',T8,'XBUF',T24,Z8.4)

	if (.not. diagnostic_mode) then

	CALL LINCHK (LUN,3)

	IF (CMD_PKT(0) .NE. 2) THEN

	WRITE(LUN,40)
40	FORMAT('0','COMMAND PACKET HAS INVALID FLAG',/)

	DO 44,I = 0,14

	CALL LINCHK (LUN,1)

	WRITE(LUN,42) CMD_PKT(I)
42	FORMAT(' ',T30,Z2.2)

44	CONTINUE
	ELSE

	WRITE(LUN,45)
45	FORMAT('0','COMMAND MESSAGE PACKET',/)

	CALL LINCHK (LUN,2)

	WRITE(LUN,50) CMD_PKT(0),CONTROL_PACKET
50	FORMAT(' ',T8,'FLAG',T30,Z2.2,/,T40,A19)

	CALL LINCHK (LUN,2)

	FIELD = LIB$EXTZV(0,8,CMD_PKT(1))

	WRITE(LUN,55) PBYTE_COUNT,CMD_PKT(1),PBYTE_COUNT,
	1 BYTE_COUNT(MAX(9,MIN(11,FIELD)))
55	FORMAT(' ',T8,A17,T30,Z2.2,/,
	1 T40,A17,A<COMPRESSC (BYTE_COUNT(MAX(9,MIN(11,FIELD))))>)

	CALL LINCHK (LUN,2)

	FIELD = LIB$EXTZV(0,8,CMD_PKT(2))

	WRITE(LUN,60) OP_CODE,CMD_PKT(2),V1OP_CODE(MAX(-1,MIN(11,FIELD)))
60	FORMAT(' ',T8,A7,T30,Z2.2,/,T40,
	1 'FUNCTION = ',A<COMPRESSC (V1OP_CODE(MAX(-1,MIN(11,FIELD))))>)

	CALL LINCHK (LUN,1)

	WRITE(LUN,65) CMD_PKT(3)
65	FORMAT(' ',T8,'OP CODE MODIFIER',T30,Z2.2)

	CALL OUTPUT (LUN,CMD_PKT(3),MODIFIER,0,0,0,'0')

	CALL LINCHK (LUN,2)

	FIELD = LIB$EXTZV(0,8,CMD_PKT(4))

	WRITE(LUN,68) CMD_PKT(4),UNIT_NUMBER,FIELD
68	FORMAT(' ',T8,'UNIT',T30,Z2.2,/,
	1 T40,A14,I<COMPRESS4 (FIELD)>,'.')

	CALL LINCHK (LUN,1)

	WRITE(LUN,70) UNUSED_BYTE,CMD_PKT(5)
70	FORMAT(' ',T8,A11,T30,Z2.2)

	CALL LINCHK (LUN,2)

	WRITE(LUN,75) SEQUENCE_LO,CMD_PKT(6),CMD_PKT(7)
75	FORMAT(' ',T8,A15,T30,Z2.2,/,T30,Z2.2)

	CALL LINCHK (LUN,2)

	WRITE(LUN,80) BYTECOUNT_LO,CMD_PKT(8),CMD_PKT(9)
80	FORMAT(' ',T8,A17,T30,Z2.2,/,'$',T30,Z2.2)

	IF (CMD_PKT(2) .EQ. READ
	1 .OR.
	2 CMD_PKT(2) .EQ. WRITE) THEN

	FIELD = LIB$EXTZV(0,16,CMD_PKT(8))

	WRITE(LUN,85) FIELD
85	FORMAT('+',T10,'TRANSFER BYTE COUNT = ',I<COMPRESS4 (FIELD)>,'.')
	ENDIF

	CALL LINCHK (LUN,2)

	WRITE(LUN,90) BLOCK_LO,CMD_PKT(10),CMD_PKT(11)
90	FORMAT('$',T8,A19,T30,Z2.2,/,'$',T30,Z2.2)

	IF (CMD_PKT(2) .EQ. POSITION
	1 .OR.
	2 CMD_PKT(2) .EQ. READ
	3 .OR.
	4 CMD_PKT(2) .EQ. WRITE) THEN

	FIELD = LIB$EXTZV(0,16,CMD_PKT(10))

	WRITE(LUN,95) FIELD
95	FORMAT('+',T10,'REQUESTED BLOCK = ',I<COMPRESS4 (FIELD)>,'.')
	ENDIF

	CALL LINCHK (LUN,2)

	WRITE(LUN,100) CHECKSUM_LO,CMD_PKT(12),CMD_PKT(13)
100	FORMAT(' ',T8,A15,T30,Z2.2,/,T30,Z2.2)
	ENDIF


	CALL LINCHK (LUN,3)

	IF (END_PKT(0) .NE. 2) THEN

	WRITE(LUN,105)
105	FORMAT('0','END PACKET HAS INVALID FLAG',/)

	DO 115,I = 0,13

	CALL LINCHK (LUN,1)

	WRITE(LUN,110) END_PKT(I)
110	FORMAT(' ',T30,Z2.2)

115	CONTINUE
	ELSE

	WRITE(LUN,120)
120	FORMAT('0','END MESSAGE PACKET',/)

	CALL LINCHK (LUN,2)

	WRITE(LUN,125) END_PKT(0),CONTROL_PACKET
125	FORMAT(' ',T8,'FLAG',T30,Z2.2,/,T40,A19)

	CALL LINCHK (LUN,2)

	FIELD = LIB$EXTZV(0,8,END_PKT(1))

	WRITE(LUN,130) PBYTE_COUNT,END_PKT(1),PBYTE_COUNT,
	1 BYTE_COUNT(MAX(9,MIN(11,FIELD)))
130	FORMAT(' ',T8,A17,T30,Z2.2,/,
	1 T40,A17,A<COMPRESSC (BYTE_COUNT(MAX(9,MIN(11,FIELD))))>)

	CALL LINCHK (LUN,2)

	FIELD = LIB$EXTZV(0,8,END_PKT(2))

	WRITE(LUN,135) OP_CODE,END_PKT(2),V2OP_CODE(MAX(63,MIN(65,FIELD)))
135	FORMAT(' ',T8,A7,T30,Z2.2,/,
	1 T40,A<COMPRESSC (V2OP_CODE(MAX(63,MIN(65,FIELD))))>)

	CALL LINCHK (LUN,2)

	WRITE(LUN,140) END_PKT(3)
140	FORMAT(' ',T8,'SUCCESS CODE',T30,Z2.2)

	J = 12

	DO 155,I = 0,11

	IF (END_PKT(3) .EQ. V1SUCCESS_CODE(I)) J = I

155	CONTINUE

	WRITE(LUN,160) V2SUCCESS_CODE(J)
160	FORMAT(' ',T40,A<COMPRESSC (V2SUCCESS_CODE(J))>)

	CALL LINCHK (LUN,2)

	FIELD = LIB$EXTZV(0,8,END_PKT(4))

	WRITE(LUN,170) END_PKT(4),UNIT_NUMBER,FIELD
170	FORMAT(' ',T8,'UNIT',T30,Z2.2,/,T40,A14,
	1 I<COMPRESS4 (FIELD)>,'.')

	CALL LINCHK (LUN,1)

	WRITE(LUN,175) UNUSED_BYTE,END_PKT(5)
175	FORMAT(' ',T8,A11,T30,Z2.2)

	CALL LINCHK (LUN,2)

	WRITE(LUN,180) SEQUENCE_LO,END_PKT(6),END_PKT(7)
180	FORMAT(' ',T8,A15,T30,Z2.2,/,T30,Z2.2)

	CALL LINCHK (LUN,2)

	FIELD = LIB$EXTZV(0,16,END_PKT(8))

	WRITE(LUN,185) BYTECOUNT_LO,END_PKT(8),END_PKT(9),FIELD
185	FORMAT(' ',T8,A17,T30,Z2.2,/,
	1 T30,Z2.2,T40,'BYTES TRANSFERED = ',I<COMPRESS4 (FIELD)>,'.')

	CALL LINCHK (LUN,2)

	WRITE(LUN,190) END_PKT(10),END_PKT(11)
190	FORMAT(' ',T8,'STATUS',T30,Z2.2,/,T30,Z2.2)

	CALL OUTPUT (LUN,END_PKT(12),V1SUM_STATUS,4,4,7,'0')

	CALL LINCHK (LUN,2)

	WRITE(LUN,195) CHECKSUM_LO,END_PKT(12),END_PKT(13)
195	FORMAT(' ',T8,A15,T30,Z2.2,/,T30,Z2.2)
	ENDIF
	endif

	call linchk (lun,1)

	write(lun,200)
200	format(' ',:)

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

	call ucb$l_media (lun,emb$l_dv_media)

	call linchk (lun,1)

	write(lun,200)

	call tutape_qio (lun,emb$w_dv_func)

	call irp$w_bcnt (lun,emb$w_dv_bcnt)

	call irp$w_boff (lun,emb$w_dv_boff)

	call irp$l_pid (lun,emb$l_dv_rqpid)

	call irp$q_iosb (lun,emb$l_dv_iosb1)
	endif

	RETURN



	ENTRY B_TUTAPE (LUN)



	if (emb$t_dv_name(1:3) .eq. 'CSA') then

	call dhead1 (lun,'CONSOLE TU58')
	else

	call dhead1 (lun,'UBA TU58')
	endif

	CALL BRIEF16 (LUN,4,RCSR,REG_HERALD,EMB$T_DV_NAME,EMB$W_DV_UNIT)

	RETURN



	ENTRY C_TUTAPE (LUN)



	CALL CRYPTK (LUN,16,4,RCSR,REG_HERALD,EMB$T_DV_NAME,EMB$W_DV_UNIT)

	RETURN

	END



	subroutine tutape_qio (lun,emb$w_dv_func)



	include 'src$:qiocommon.for /nolist'



	byte		lun

	integer*2	emb$w_dv_func

	integer*4	qiocode(0:1,0:63)




	if (qiocode(0,0) .eq. 0) then

	qiocode(1,09) = %loc(io$_search)

	qiocode(1,11) = %loc(io$_writepblk)

	qiocode(1,12) = %loc(io$_readpblk)

	qiocode(1,26) = %loc(io$_setchar)

	qiocode(1,27) = %loc(io$_sensechar)

	qiocode(1,29) = %loc(io$_diagnose)

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

	call irp$w_func (lun,emb$w_dv_func,
	1 qiocode(0,lib$extzv(0,6,emb$w_dv_func)))

	return

	end
