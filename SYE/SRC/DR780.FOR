	SUBROUTINE DR780 (LUN)
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
C	AUTHOR	BRIAN PORTER		CREATION DATE	8-MAY-1979
C

C++
C	Functional description:
C
C	This module display entries for the DR780.
C
C	Modified by:
C
C	v02-003	BP0003		Brian Porter,		23-NOV-1981
C		Minor edit.
C
C	V02-002	SR0002		Sharon Reynolds,	04-Aug-1981
C		Removed some character arrays to put in a common for 
C		use by the DR780/DR750 modules. Added the include 
C		statement for DR32COM.FOR.
C		Added 'device attention' support. (Brian Porter)
C
C	v02-001	BP0001		Brian Porter,		29-JUN-1981
C		Removed call to UNUSED_BITS. Added call to DHEAD and
C		LOGGER.
C**
C--

	Include 'SRC$:DR32COM.FOR /NOLIST'

	INCLUDE 'SRC$:MSGHDR.FOR /NOLIST'

	INCLUDE 'SRC$:DEVERR.FOR /NOLIST'




	BYTE		LUN

	INTEGER*4	FIELD

	INTEGER*4	COMPRESSC

	REAL		FLOAT

	INTEGER*4	COMPRESS4

	INTEGER*4	COMPRESSF

	INTEGER*4	DR_CR
	INTEGER*4	DR_UTL
	INTEGER*4	DR_WCS(1:3)
	INTEGER*4	DR_BA
	INTEGER*4	DR_BC(1:2)
	INTEGER*4	DR_CA(1:2)
	INTEGER*4	DR_WD(1:5)
	INTEGER*4	DR_SL
	INTEGER*4	DR_SBR
	INTEGER*4	DR_GBR
	INTEGER*4	DR_CB(1:3)
	INTEGER*4	DR_BB(1:3)
	INTEGER*4	DR_GPR(0:15)

	INTEGER*4	CRYPTK_REG(0:5)

	EQUIVALENCE	(DR_CR,EMB$L_DV_REGSAV(0))
	EQUIVALENCE	(DR_UTL,EMB$L_DV_REGSAV(1))
	EQUIVALENCE	(DR_WCS,EMB$L_DV_REGSAV(2))
	EQUIVALENCE	(DR_BA,EMB$L_DV_REGSAV(5))
	EQUIVALENCE	(DR_BC,EMB$L_DV_REGSAV(6))
	EQUIVALENCE	(DR_CA,EMB$L_DV_REGSAV(9))
	EQUIVALENCE	(DR_WD,EMB$L_DV_REGSAV(11))
	EQUIVALENCE	(DR_SL,EMB$L_DV_REGSAV(16))
	EQUIVALENCE	(DR_SBR,EMB$L_DV_REGSAV(17))
	EQUIVALENCE	(DR_GBR,EMB$L_DV_REGSAV(18))
	EQUIVALENCE	(DR_CB,EMB$L_DV_REGSAV(19))
	EQUIVALENCE	(DR_BB,EMB$L_DV_REGSAV(22))
	EQUIVALENCE	(DR_GPR,EMB$L_DV_REGSAV(25))

	CHARACTER*10	V1DR_UTL(11:11)
	CHARACTER*31	V2DR_UTL(25:31)

	CHARACTER*3	BYTE_COUNT(1:2)

	CHARACTER*15	SILO_DIR

	CHARACTER*1	V1DR_WD(1:6)

	CHARACTER*1	V1DR_ID(1:6)

	CHARACTER*4	REG_HERALD(0:5)

	PARAMETER	TIMEOUT = 96 

	PARAMETER	DR_780 = 48

	PARAMETER	SBI_FUNC1 = 1
	PARAMETER	SBI_FUNC2 = 2
	PARAMETER	SBI_FUNC7 = 7
	PARAMETER	SBI_FUNC11 = 11



	DATA	V1DR_UTL(11)	/'WCS VALID*'/




	DATA	V2DR_UTL(25)	/'FORCE DDI CONTROL PARITY ERROR*'/

	DATA	V2DR_UTL(26)	/'FORCE DDI DATA PARITY ERROR*'/

	DATA	V2DR_UTL(27)	/'ENABLE DDI DATA PE ABORT*'/

	DATA	V2DR_UTL(28)	/'WCS PARITY ERROR*'/

	DATA	V2DR_UTL(29)	/'DDI CONTROL PARITY ERROR*'/

	DATA	V2DR_UTL(30)	/'DDI DATA PARITY ERROR*'/

	DATA	V2DR_UTL(31)	/'PARITY ERROR*'/



C	DATA	V1DR_CFLAG(0)	/'TRANSMIT INHIBIT SELECT*'/

C	DATA	V1DR_CFLAG(1)	/'TRANSMIT MASTER STROBE*'/

C	DATA	V1DR_CFLAG(2)	/'TRANSMIT SLAVE STROBE*'/

C	DATA	V1DR_CFLAG(3)	/'TRANSMIT TO SLAVE*'/

C	DATA	V1DR_CFLAG(4)	/'TRANSMIT RSEL*'/

C	DATA	V1DR_CFLAG(5)	/'SWITCH ON DATA DRIVERS*'/




C	DATA	V2DR_CFLAG(9)	/'CSTAT*'/

C	DATA	V2DR_CFLAG(10)	/'CIRDXP*'/

C	DATA	V2DR_CFLAG(11)	/'CMDXP*'/

C	DATA	V2DR_CCFLAG(12)	/'CIWDXP*'/




	DATA	BYTE_COUNT(1)	/'SBI'/

	DATA	BYTE_COUNT(2)	/'DDI'/



	DATA	SILO_DIR	/'SILO DIRECTION '/




	DATA	V1DR_WD(1)	/'2'/

	DATA	V1DR_WD(2)	/'*'/

	DATA	V1DR_WD(3)	/'1'/

	DATA	V1DR_WD(4)	/'1'/

	DATA	V1DR_WD(5)	/'2'/

	DATA	V1DR_WD(6)	/'*'/




	DATA	V1DR_ID(1)	/'1'/

	DATA	V1DR_ID(2)	/'*'/

	DATA	V1DR_ID(3)	/'1'/

	DATA	V1DR_ID(4)	/'2'/

	DATA	V1DR_ID(5)	/'2'/

	DATA	V1DR_ID(6)	/'*'/




	DATA	REG_HERALD(0)	/'CR*'/

	DATA	REG_HERALD(1)	/'UTL*'/

	DATA	REG_HERALD(2)	/'BA*'/

	DATA	REG_HERALD(3)	/'SL*'/

	DATA	REG_HERALD(4)	/'CA1*'/

	DATA	REG_HERALD(5)	/'CA2*'/






	CALL FRCTOF (LUN)

	call dhead1 (lun,'DR32')

C
C	DR780 CONTROL REGISTER
C

	CALL DR780_REGA (LUN,DR_CR)

C
C	DR780 UTILITY REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,25) DR_UTL
25	FORMAT(' ',T8,'DR UTL',T24,Z8.8)

	FIELD = LIB$EXTZV(0,8,DR_UTL)

	IF (FIELD .LE. 'FB'X) THEN

	CALL LINCHK (LUN,2)

c
c	2's complement value and get data rate in Mbytes.
c	The value 5 (maximum) = 8 Mbytes.
c

	field = jidim(256,field)

c
c	Use Table 3-9 dr780 users guide formulae to calculate data rate
c

	float = floatj(field)

	float = 40/float

c
c	Calculate clock period.  Since 32 bits are transfered at a time
c	then the number of micro-seconds in one second are divided by
c	the number of bytes transfered in one second to obtain the clock
c	period.
c

	float = (1024*1024) / ((float*1024*1024)/4)

	WRITE(LUN,26) FLOAT
26	FORMAT(' ',T40,'PERIOD = ',F<COMPRESSF (FLOAT,1)>.1,'. MICRO/SEC')

c
c	Calculate the Kbyte data rate.
c

	float = floatj(field)

	float = (40/float)*1024

	WRITE(LUN,27) FLOAT
27	FORMAT(' ',T40,'TRANSFER RATE = ',
	1 F<COMPRESSF (FLOAT,2)>.2,'. KB/SEC')
	ENDIF

	CALL OUTPUT (LUN,DR_UTL,V1DR_UTL,11,11,11,'0')

	CALL OUTPUT (LUN,DR_UTL,V2DR_UTL,25,25,31,'0')

C
C	DR780 WCS REGISTERS
C

	DO 40 I = 1,3

	FIELD = LIB$EXTZV(0,31,DR_WCS(I))

	IF (FIELD .NE. 0) THEN

	CALL LINCHK (LUN,1)

	WRITE(LUN,30) I,DR_WCS(I)
30	FORMAT(' ',T8,'DR WCS',I1,T24,Z8.8)
	ENDIF

40	CONTINUE

C
C	DR780 SBI ADDRESS REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,50) DR_BA
50	FORMAT(' ',T8,'DR BA',T24,Z8.8)

	FIELD = LIB$EXTZV(28,2,DR_BA)

	CALL LINCHK (LUN,1)

	IF (FIELD .EQ. 0) THEN

	WRITE(LUN,65) SILO_DIR
65	FORMAT(' ',T40,A15,'= SBI READ')

	ELSE IF (FIELD .EQ. 3) THEN

	WRITE(LUN,70) SILO_DIR
70	FORMAT(' ',T40,A15,'= SBI WRITE')
	ENDIF

C
C	DR780 BYTE COUNT REGISTERS
C

	DO 100 I = 1,2

	CALL LINCHK (LUN,2)

	WRITE(LUN,80) I,DR_BC(I),BYTE_COUNT(I)
80	FORMAT(' ',T8,'DR BC',I1,T24,Z8.8,/,
	1 T40,A3,' BYTE COUNT')

100	CONTINUE

C
C	DR780 COMMAND ADDRESS REGISTERS
C

	DO 150 I = 1,2

	FIELD = LIB$EXTZV(0,28,DR_CA(I))

	FIELD = JISHFT(FIELD,2)

	CALL LINCHK (LUN,3)

	WRITE(LUN,120) I,DR_CA(I),I,FIELD
120	FORMAT(' ',T8,'DR CA',I1,T24,Z8.8,/,
	1 T40,'LAST COMMAND ADDRESS EXECUTED ID',I1,/,
	2 T40,'LONGWORD ADDRESS = ',Z8.8)

	FIELD = LIB$EXTZV(28,4,DR_CA(I))

	CALL SBI_COMMAND (LUN,FIELD)

150	CONTINUE

C
C	DR780 WRITE DATA REGISTERS
C

	DO 165,J = 1,2

	FIELD = LIB$EXTZV(28,4,DR_CA(J))

	IF (FIELD .EQ. SBI_FUNC2
	1 .OR.
	2 FIELD .EQ. SBI_FUNC7
	3 .OR.
	4 FIELD .EQ. SBI_FUNC11) THEN

	DO 160,I = J**2,(J**2) + 2

	IF (V1DR_WD(I) .NE. '*') THEN

	CALL LINCHK (LUN,2)

	WRITE(LUN,155) I,DR_WD(I),V1DR_WD(I),V1DR_ID(I)
155	FORMAT(' ',T8,'DR WD',I1,T24,Z8.8,/,
	1 T40,'WRITE DATA',A1,' ID',A1)
	ENDIF

160	CONTINUE
	ENDIF

165	CONTINUE

C
C	DR780 STATUS LONGWORD
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,180) DR_SL
180	FORMAT(' ',T8,'DR SL',T24,Z8.8)

	CALL OUTPUT (LUN,DR_SL,V1DR_SL,0,0,14,'0')

	FIELD = LIB$EXTZV(16,8,DR_SL)

	IF (FIELD .NE. 0) THEN

	CALL LINCHK (LUN,3)

	WRITE(LUN,182) ('*',I = 0,32)
182	FORMAT(' ',T40,33A1,/,T47,'FAR-END STATUS BYTE',/)

	DO 186,I = 0,4

	FIELD1 = LIB$EXTZV(I,1,FIELD)

	IF (FIELD1 .NE. 0) THEN

	CALL LINCHK (LUN,1)

	WRITE(LUN,184) I
184	FORMAT(' ',T40,'FAR-END DEVICE STATUS BIT ',I1,'. SET')
	ENDIF

186	CONTINUE

	CALL OUTPUT (LUN,DR_SL,V2DR_SL,21,21,23,'0')

	CALL LINCHK (LUN,1)

	WRITE(LUN,188) ('*',I = 0,32)
188	FORMAT(' ',T40,33A1)
	ENDIF

C
C	DR780 SYSTEM BASE REGISTER
C

	CALL LINCHK (LUN,2)

	WRITE(LUN,190) DR_SBR
190	FORMAT(' ',T8,'DR SBR',T24,Z8.8,/,
	1 T40,'DR SYSTEM BASE REG (PHY ADDR)')

C
C	DR780 GLOBAL BASE REGISTER
C

	CALL LINCHK (LUN,2)

	WRITE(LUN,200) DR_GBR
200	FORMAT(' ',T8,'DR GBR',T24,Z8.8,/,
	1 T40,'DR GLOBAL BASE REG (VIRT ADDR)')

C
C	DR780 COMMAND BLOCK INFORMATION
C

	CALL LINCHK (LUN,3)

	WRITE(LUN,215)
215	FORMAT('0','DR CURRENT COMMAND BLOCK',/)

	DO 220 I = 1,3

	CALL LINCHK (LUN,2)

	WRITE(LUN,210) I,DR_CB(I),V1DR_CB(I)
210	FORMAT(' ',T8,'DR CB',I1,T24,Z8.8,/,
	1 T40,A<COMPRESSC (V1DR_CB(I))>)

220	CONTINUE

C
C	DR780 BUFFER BLOCK INFORMATION
C

	CALL LINCHK (LUN,3)

	WRITE(LUN,225)
225	FORMAT('0','DR CURRENT BUFFER BLOCK',/)

	DO 250,I = 1,3

	CALL LINCHK (LUN,2)

	WRITE(LUN,240) I,DR_BB(I),V1DR_BB(I)
240	FORMAT(' ',T8,'DR BB',I1,T24,Z8.8,/,
	1 T40,A<COMPRESSC (V1DR_BB(I))>)

250	CONTINUE

C
C	DR780 'GENERAL PURPOSE REGISTERS'
C

	CALL LINCHK (LUN,3)

	WRITE(LUN,265)
265	FORMAT('0','DR GENERAL PURPOSE REGISTERS',/)

	DO 280,I = 0,8

	CALL LINCHK (LUN,1)

	WRITE(LUN,270) I,DR_GPR(I)
270	FORMAT(' ',T8,'DR R',I1,T24,Z8.8)

280	CONTINUE

	CALL LINCHK (LUN,2)

	WRITE(LUN,290) DR_GPR(9)
290	FORMAT(' ',T8,'DR R9',T24,Z8.8,/,
	1 T40,'PAGE COUNT')

	CALL LINCHK (LUN,2)

	WRITE(LUN,300) DR_GPR(10)
300	FORMAT(' ',T8,'DR R11',T24,Z8.8,/,
	1 T40,'DDI CONTROL FLAG REGISTER')

	CALL LINCHK (LUN,2)

	WRITE(LUN,310) DR_GPR(11)
310	FORMAT(' ',T8,'DR R12',T24,Z8.8,/,
	1 T40,'COPY OF STATE REGISTER')

	CALL LINCHK (LUN,2)

	WRITE(LUN,320) DR_GPR(12)
320	FORMAT(' ',T8,'DR R13',T24,Z8.8,/,
	1 T40,'COPY OF FLAG REGISTER 0')

	CALL LINCHK (LUN,2)

	WRITE(LUN,330) DR_GPR(13)
330	FORMAT(' ',T8,'DR R14',T24,Z8.8,/,
	1 T40,'COPY OF LS.SAV')

	CALL LINCHK (LUN,2)

	WRITE(LUN,340) DR_GPR(14)
340	FORMAT(' ',T8,'DR R15',T24,Z8.8,/,
	1 T40,'MICRO STATUS REGISTER')

	call linchk (lun,1)

	write(lun,345)
345	format(' ',:)

	call ucb$l_ownuic (lun,emb$l_dv_ownuic)

	call ucb$l_char (lun,emb$l_dv_char)

	call ucb$w_sts (lun,emb$w_dv_sts)

	call ucb$l_opcnt (lun,emb$l_dv_opcnt)

	call ucb$w_errcnt (lun,emb$w_dv_errcnt)

	if (emb$w_hd_entry .ne. 98) then

	call linchk (lun,1)

	write(lun,345)

	call xfdriver_qio (lun,emb$w_dv_func)

	call irp$w_bcnt (lun,emb$w_dv_bcnt)

	call irp$w_boff (lun,emb$w_dv_boff)

	call irp$l_pid (lun,emb$l_dv_rqpid)

	call irp$q_iosb (lun,emb$l_dv_iosb1)
	endif

	RETURN




	ENTRY B_DR780 (LUN)




	call dhead1 (lun,'DR32')

	CRYPTK_REG(0) = DR_CR

	CRYPTK_REG(1) = DR_UTL

	CRYPTK_REG(2) = DR_BA

	CRYPTK_REG(3) = DR_SL

	CRYPTK_REG(4) = DR_CA(1)

	CRYPTK_REG(5) = DR_CA(2)

	CALL BRIEF32 (LUN,6,CRYPTK_REG,REG_HERALD,
	1 EMB$T_DV_NAME,EMB$W_DV_UNIT)

	RETURN




	ENTRY C_DR780 (LUN)




	CRYPTK_REG(0) = DR_CR

	CRYPTK_REG(1) = DR_UTL

	CRYPTK_REG(2) = DR_BA

	CRYPTK_REG(3) = DR_SL

	CRYPTK_REG(4) = DR_CA(1)

	CRYPTK_REG(5) = DR_CA(2)

	CALL CRYPTK (LUN,32,6,CRYPTK_REG,REG_HERALD,
	1 EMB$T_DV_NAME,EMB$W_DV_UNIT)

	RETURN

	END



	subroutine xfdriver_qio (lun,emb$w_dv_func)



	include 'src$:qiocommon.for /nolist'



	byte		lun

	integer*2	emb$w_dv_func

	integer*4	qiocode(0:1,0:63)




	if (qiocode(0,0) .eq. 0) then

	qiocode(1,01) = %loc(io$_loadmcode)

	qiocode(1,06) = %loc(io$_startdatap)

	qiocode(1,56) = %loc(io$_startdata)

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
