	SUBROUTINE MASSTAPE (LUN)
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
C	AUTHOR	BRIAN PORTER		CREATION DATE	26-MAR-1979
C
C	Functional description:
C
C	This module displays error log entries to all drive types connected
C	to the TM03 formatter.
C
C	Modified by:
C
C	v02-004	BP0004		Brian Porter,		18-NOV-1981
C		Added different mba code.  Minor edit.
C
C	v02-003	BP0003		Brian Porter,		06-NOV-1981
C		Added 'device attention' support.
C
C	v02-002	BP0002		Brian Porter,		29-JUN-1981
C		Added call to LOGGER and DHEAD.  Added DIAGNOSTIC_MODE.
C
C	v02-001	BP0001		Brian Porter,		30-AUG-1980
C		Removed call to UNUSED_BITS.  Changed code to print
C		32 bit registers.
C**


	INCLUDE 'SRC$:MSGHDR.FOR /NOLIST'
	INCLUDE 'SRC$:DEVERR.FOR /NOLIST'



	BYTE		LUN

	INTEGER*4	FIELD

	INTEGER*4	COMPRESSC

	integer*4	selected_mapping_register

	integer*4	adapter_registers(7)

	INTEGER*4	DRIVE_CS1
	INTEGER*4	DRIVE_DS
	INTEGER*4	DRIVE_ER
	INTEGER*4	DRIVE_MR
	INTEGER*4	DRIVE_AS
	INTEGER*4	DRIVE_FC
	INTEGER*4	DRIVE_DT
	INTEGER*4	DRIVE_CK
	INTEGER*4	DRIVE_SN
	INTEGER*4	DRIVE_TC
	INTEGER*4	DRIVE_FUNC

	equivalence	(adapter_registers,emb$l_dv_regsav(0))

	EQUIVALENCE	(DRIVE_CS1,EMB$L_DV_REGSAV(7))
	EQUIVALENCE	(DRIVE_DS,EMB$L_DV_REGSAV(8))
	EQUIVALENCE	(DRIVE_ER,EMB$L_DV_REGSAV(9))
	EQUIVALENCE	(DRIVE_MR,EMB$L_DV_REGSAV(10))
	EQUIVALENCE	(DRIVE_AS,EMB$L_DV_REGSAV(11))
	EQUIVALENCE	(DRIVE_FC,EMB$L_DV_REGSAV(12))
	EQUIVALENCE	(DRIVE_DT,EMB$L_DV_REGSAV(13))
	EQUIVALENCE	(DRIVE_CK,EMB$L_DV_REGSAV(14))
	EQUIVALENCE	(DRIVE_SN,EMB$L_DV_REGSAV(15))
	EQUIVALENCE	(DRIVE_TC,EMB$L_DV_REGSAV(16))

	logical*1	diagnostic_mode

	PARAMETER	TIMEOUT  = 96
	PARAMETER	XFER_CMD = 20
	PARAMETER	I600_BPI = 1

	CHARACTER*7	MASS1_CS1(0:0)
	CHARACTER*4	REG_HERALD(0:9)
	CHARACTER*16	MASS2_CS1(11:11)
	CHARACTER*24	MASS1_DS(0:8)
	CHARACTER*24	MASS2_DS(10:15)
	CHARACTER*30	MASS1_ER(0:5)
	CHARACTER*25	PE1_ER(6:7)
	CHARACTER*17	PE2_ER(10:10)
	CHARACTER*23	PE3_ER(15:15)
	CHARACTER*26	NRZI1_ER(6:7)
	CHARACTER*18	NRZI2_ER(10:10)
	CHARACTER*10	NRZI3_ER(15:15)
	CHARACTER*26	MASS_ER7(0:1)
	CHARACTER*18	MASS2_ER(8:9)
	CHARACTER*18	MASS_ER10(0:1)
	CHARACTER*24	MASS3_ER(11:14)
	CHARACTER*23	MASS_ER15(0:1)
	CHARACTER*27	MASS1_DT(0:3)
	CHARACTER*15	MASS_DT5(0:1)
	CHARACTER*18	MASS2_DT(10:10)
	CHARACTER*10	MASS3_DT(12:12)
	CHARACTER*23	MASS4_DT(14:15)
	CHARACTER*12	MASS1_TC(3:3)
	CHARACTER*13	MASS1_FORMAT(0:2)
	CHARACTER*13	MASS2_FORMAT(12:14)
	CHARACTER*9	MASS_DENSITY(3:4)
	CHARACTER*32	MASS2_TC(12:15)
	CHARACTER*24	MASS_FUNC(0:31)





	DATA	MASS1_CS1(0)	/'GO BIT*'/




	DATA	MASS2_CS1(11)	/'DRIVE AVAILABLE*'/



	DATA	MASS1_DS(0)	/'TRANSPORT ATTENTION*'/

	DATA	MASS1_DS(1)	/'BEGINNING OF TAPE*'/

	DATA	MASS1_DS(2)	/'TAPE MARK*'/

	DATA	MASS1_DS(3)	/'IDENTIFICATION BURST*'/

	DATA	MASS1_DS(4)	/'SETTLE DOWN*'/

	DATA	MASS1_DS(5)	/'PHASE ENCODED STATUS*'/

	DATA	MASS1_DS(6)	/'TRANSPORT STATUS CHANGE*'/

	DATA	MASS1_DS(7)	/'DRIVE READY*'/

	DATA	MASS1_DS(8)	/'DRIVE PRESENT*'/



	DATA	MASS2_DS(10)	/'END OF TAPE*'/

	DATA	MASS2_DS(11)	/'WRITE PROTECTED*'/

	DATA	MASS2_DS(12)	/'MEDIUM ON-LINE*'/

	DATA	MASS2_DS(13)	/'POSITIONING IN PROGRESS*'/

	DATA	MASS2_DS(14)	/'COMPOSITE ERROR*'/

	DATA	MASS2_DS(15)	/'ATTENTION ACTIVE*'/



	DATA	MASS1_ER(0)	/'ILLEGAL FUNCTION*'/

	DATA	MASS1_ER(1)	/'ILLEGAL REGISTER*'/

	DATA	MASS1_ER(2)	/'REGISTER MODIFICATION REFUSED*'/

	DATA	MASS1_ER(3)	/'MASSBUS CONTROL PARITY ERROR*'/

	DATA	MASS1_ER(4)	/'FORMAT CODE ERROR*'/

	DATA	MASS1_ER(5)	/'MASSBUS DATA PARITY ERROR*'/





	DATA	PE1_ER(6)	/'UNCORRECTABLE DATA ERROR*'/

	DATA	PE1_ER(7)	/'FORMAT ERROR*'/




	DATA	NRZI1_ER(6)	/'VERTICAL PARITY ERROR*'/

	DATA	NRZI1_ER(7)	/'LONGITUDINAL PARITY ERROR*'/




	DATA	MASS2_ER(8)	/'NON-STANDARD GAP*'/

	DATA	MASS2_ER(9)	/'FRAME COUNT ERROR*'/




	DATA	PE2_ER(10)	/'CORRECTABLE SKEW*'/




	DATA	NRZI2_ER(10)	/'ILLEGAL TAPE MARK*'/






	DATA	MASS3_ER(11)	/'NON-EXECUTABLE FUNCTION*'/

	DATA	MASS3_ER(12)	/'DRIVE TIMING ERROR*'/

	DATA	MASS3_ER(13)	/'OPERATION INCOMPLETE*'/

	DATA	MASS3_ER(14)	/'TRANSPORT UNSAFE*'/




	DATA	PE3_ER(15)	/'CORRECTABLE DATA ERROR*'/




	DATA	NRZI3_ER(15)	/'CRC ERROR*'/







	DATA	MASS1_DT(0)	/'45 IPS TRANSPORT SELECTED*'/

	DATA	MASS1_DT(1)	/'75 IPS TRANSPORT SELECTED*'/

	DATA	MASS1_DT(2)	/'125 IPS TRANSPORT SELECTED*'/

	DATA	MASS1_DT(3)	/'BIT 3 ALWAYS SET*'/





	DATA	MASS_DT5(0)	/'TM02 FORMATTER*'/

	DATA	MASS_DT5(1)	/'TM03 FORMATTER*'/





	DATA	MASS2_DT(10)	/'TRANSPORT PRESENT*'/





	DATA	MASS3_DT(12)	/'7-CHANNEL*'/





	DATA	MASS4_DT(14)	/'TAPE DRIVE*'/

	DATA	MASS4_DT(15)	/'NOT SECTOR ADDRESSABLE*'/






	DATA	MASS1_TC(3)	/'EVEN PARITY*'/





	DATA	MASS1_FORMAT(0)	/'10-CORE DUMP*'/

	DATA	MASS1_FORMAT(1)	/'15-CORE DUMP*'/

	DATA	MASS1_FORMAT(2)	/'10-COMPATIBLE*'/





	DATA	MASS2_FORMAT(12)/'11-NORMAL*'/

	DATA	MASS2_FORMAT(13)/'11-CORE DUMP*'/

	DATA	MASS2_FORMAT(14)/'15-NORMAL*'/





	DATA	MASS_DENSITY(3)/'800 NRZI*'/

	DATA	MASS_DENSITY(4)/'1600 PE*'/





	DATA	MASS2_TC(12)	/'ENABLE ABORT ON DATA XFER ERROR*'/

	DATA	MASS2_TC(13)	/'TRANSPORT ADDRESS CHANGE*'/

	DATA	MASS2_TC(14)	/'FRAME COUNT STATUS*'/

	DATA	MASS2_TC(15)	/'ACCELERATION*'/




	DATA	MASS_FUNC(0)	/'NO-OPERATION*'/

	DATA	MASS_FUNC(1)	/'REWIND AND SET OFF-LINE*'/

	DATA	MASS_FUNC(2)	/'ILLEGAL FUNCTION*'/

	DATA	MASS_FUNC(3)	/'REWIND*'/

	DATA	MASS_FUNC(4)	/'DRIVE CLEAR*'/

	DATA	MASS_FUNC(5)	/'ILLEGAL FUNCTION*'/

	DATA	MASS_FUNC(6)	/'ILLEGAL FUNCTION*'/

	DATA	MASS_FUNC(7)	/'ILLEGAL FUNCTION*'/

	DATA	MASS_FUNC(8)	/'READ-IN PRESET*'/

	DATA	MASS_FUNC(9)	/'ILLEGAL FUNCTION*'/

	DATA	MASS_FUNC(10)	/'ERASE*'/

	DATA	MASS_FUNC(11)	/'WRITE TAPE MARK*'/

	DATA	MASS_FUNC(12)	/'SPACE FORWARD*'/

	DATA	MASS_FUNC(13)	/'SPACE REVERSE*'/

	DATA	MASS_FUNC(14)	/'ILLEGAL FUNCTION*'/

	DATA	MASS_FUNC(15)	/'ILLEGAL FUNCTION*'/

	DATA	MASS_FUNC(16)	/'ILLEGAL FUNCTION*'/

	DATA	MASS_FUNC(17)	/'ILLEGAL FUNCTION*'/

	DATA	MASS_FUNC(18)	/'ILLEGAL FUNCTION*'/

	DATA	MASS_FUNC(19)	/'ILLEGAL FUNCTION*'/

	DATA	MASS_FUNC(20)	/'WRITE CHECK FORWARD*'/

	DATA	MASS_FUNC(21)	/'ILLEGAL FUNCTION*'/

	DATA	MASS_FUNC(22)	/'ILLEGAL FUNCTION*'/

	DATA	MASS_FUNC(23)	/'WRITE CHECK REVERSE*'/

	DATA	MASS_FUNC(24)	/'WRITE FORWARD*'/

	DATA	MASS_FUNC(25)	/'ILLEGAL FUNCTION*'/

	DATA	MASS_FUNC(26)	/'ILLEGAL FUNCTION*'/

	DATA	MASS_FUNC(27)	/'ILLEGAL FUNCTION*'/

	DATA	MASS_FUNC(28)	/'READ FORWARD*'/

	DATA	MASS_FUNC(29)	/'ILLEGAL FUNCTION*'/

	DATA	MASS_FUNC(30)	/'ILLEGAL FUNCTION*'/

	DATA	MASS_FUNC(31)	/'READ REVERSE*'/




	DATA	REG_HERALD(0)	/'CS*'/

	DATA	REG_HERALD(1)	/'DS*'/

	DATA	REG_HERALD(2)	/'ER*'/

	DATA	REG_HERALD(3)	/'MR*'/

	DATA	REG_HERALD(4)	/'AS*'/

	DATA	REG_HERALD(5)	/'FC*'/

	DATA	REG_HERALD(6)	/'DT*'/

	DATA	REG_HERALD(7)	/'CK*'/

	DATA	REG_HERALD(8)	/'SN*'/

	DATA	REG_HERALD(9)	/'TC*'/





	CALL FRCTOF (LUN)

	call dhead1 (lun,'MASSBUS')

	DRIVE_FUNC=LIB$EXTZV(1,5,DRIVE_CS1)

	if (
	1 emb$w_dv_bcnt .ne. 0
	1 .and.
	1 drive_func .ge. xfer_cmd
	1 .and.
	1 emb$w_hd_entry .ne. 98
	1 ) then

	call mba_control_registers (lun,5,adapter_registers,
	1 selected_mapping_register)

	call mba_mapping_register (lun,selected_mapping_register,
	1 adapter_registers(6))

	if (selected_mapping_register .gt. 0) then

	call mba_mapping_register (lun,(selected_mapping_register - 1),
	1 adapter_registers(7))
	endif
	endif

	diagnostic_mode = .false.

	if (lib$extzv(0,1,drive_mr1) .eq. 1) diagnostic_mode = .true.

C
C	'CS1' REGISTER
C

	CALL LINCHK (LUN,2)

	WRITE(LUN,75) DRIVE_CS1
75	FORMAT('0',T8,'TMCS1',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_cs1,drive_cs1,0)

	CALL OUTPUT (LUN,DRIVE_CS1,MASS1_CS1,0,0,0,'0')

	CALL LINCHK (LUN,1)

	FIELD=LIB$EXTZV(1,5,DRIVE_CS1)

	WRITE(LUN,100) MASS_FUNC(FIELD)
100	FORMAT(' ',T40,A<COMPRESSC (MASS_FUNC(FIELD))>)

	CALL OUTPUT (LUN,DRIVE_CS1,MASS2_CS1,11,11,11,'0')
	endif

C
C	'DS' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,125) DRIVE_DS
125	FORMAT(' ',T8,'TMDS',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_cs1,drive_ds,1)

	CALL OUTPUT (LUN,DRIVE_DS,MASS1_DS,0,0,8,'0')

	CALL OUTPUT (LUN,DRIVE_DS,MASS2_DS,10,10,15,'0')
	endif

C
C	'ER' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,140) DRIVE_ER
140	FORMAT(' ',T8,'TMER',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_ds,drive_er,1)

	CALL OUTPUT (LUN,DRIVE_ER,MASS1_ER,0,0,5,'0')

	FIELD=LIB$EXTZV(10,1,DRIVE_TC)

	IF (FIELD .EQ. I600_BPI) THEN

	CALL OUTPUT (LUN,DRIVE_ER,PE1_ER,6,6,7,'0')
	ELSE

	CALL OUTPUT (LUN,DRIVE_ER,NRZI1_ER,6,6,7,'0')
	ENDIF

	CALL OUTPUT (LUN,DRIVE_ER,MASS2_ER,8,8,9,'0')

	IF (FIELD .EQ. I600_BPI) THEN

	CALL OUTPUT (LUN,DRIVE_ER,PE2_ER,10,10,10,'0')
	ELSE

	CALL OUTPUT (LUN,DRIVE_ER,NRZI2_ER,10,10,10,'0')
	ENDIF

	CALL OUTPUT (LUN,DRIVE_ER,MASS3_ER,11,11,14,'0')

	IF (FIELD .EQ. I600_BPI) THEN

	CALL OUTPUT (LUN,DRIVE_ER,PE3_ER,15,15,15,'0')
	ELSE

	CALL OUTPUT (LUN,DRIVE_ER,NRZI3_ER,15,15,15,'0')
	ENDIF
	endif

C
C	'MR' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,150) DRIVE_MR
150	FORMAT(' ',T8,'TMMR',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_er,drive_mr,1)
	else

	CALL LINCHK (LUN,1)

	WRITE(LUN,160)
160	FORMAT(' ',T40,'DIAGNOSTIC MODE')
	endif

C
C	'AS' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,175) DRIVE_AS
175	FORMAT(' ',T8,'TMAS',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_mr,drive_as,1)

	DO 184 I=0,7

	if (lib$extzv(i,1,drive_as) .eq. 1) then

	CALL LINCHK (LUN,1)

	WRITE(LUN,183) I
183	FORMAT(' ',T40,'ATTENTION UNIT ',I1,'.')
	endif

184	CONTINUE
	endif

C
C	'FC' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,185) DRIVE_FC
185	FORMAT(' ',T8,'TMFC',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_as,drive_fc,1)
	endif

C
C	'DT' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,200) DRIVE_DT
200	FORMAT(' ',T8,'TMDT',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_fc,drive_dt,1)

	FIELD=LIB$EXTZV(0,3,DRIVE_DT)

	IF (FIELD .EQ. 0) THEN

	CALL LINCHK (LUN,1)

	WRITE(LUN,215)
215	FORMAT(' ',T40,'TRANSPORT NOT SELECTED')
	ELSE

	CALL OUTPUT (LUN,DRIVE_DT,MASS1_DT,0,0,3,'0')
	ENDIF

	CALL LINCHK (LUN,1)

	FIELD=LIB$EXTZV(5,1,DRIVE_DT)

	WRITE(LUN,225) MASS_DT5(FIELD)
225	FORMAT(' ',T40,A<COMPRESSC (MASS_DT5(FIELD))>)

	CALL OUTPUT (LUN,DRIVE_DT,MASS2_DT,10,10,10,'0')

	CALL OUTPUT (LUN,DRIVE_DT,MASS3_DT,12,12,12,'0')

	CALL OUTPUT (LUN,DRIVE_DT,MASS4_DT,14,14,15,'0')
	endif

C
C	'CK' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,325) DRIVE_CK
325	FORMAT(' ',T8,'TMCK',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_dt,drive_ck,1)

	FIELD=LIB$EXTZV(10,1,DRIVE_TC)

	IF (FIELD .EQ. I600_BPI) THEN

	DO 340 I=0,8

	if (lib$extzv(i,1,drive_ck) .eq. 1) then

	CALL LINCHK (LUN,1)

	IF (I .LE. 7) THEN

	WRITE(LUN,330) I
330	FORMAT(' ',T40,'DEAD TRACK CHANNEL ',I1,'.')
	ELSE

	WRITE(LUN,335)
335	FORMAT(' ',T40,'DEAD TRACK PARITY CHANNEL')
	ENDIF
	endif

340	CONTINUE
	ENDIF
	endif

C
C	'SN' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,350) DRIVE_SN
350	FORMAT(' ',T8,'TMSN',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_ck,drive_sn,1)
	endif

C
C	'TC' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,375) DRIVE_TC
375	FORMAT(' ',T8,'TMTC',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_sn,drive_tc,1)

	CALL LINCHK (LUN,1)

	FIELD=LIB$EXTZV(0,3,DRIVE_TC)

	WRITE(LUN,400) FIELD
400	FORMAT(' ',T40,'TRANSPORT SELECT = ',I1,'.')

	CALL LINCHK (LUN,1)

	FIELD=LIB$EXTZV(4,4,DRIVE_TC)

	IF (FIELD .LE. 2) THEN

	WRITE(LUN,425) MASS1_FORMAT(FIELD)
425	FORMAT(' ',T40,A<COMPRESSC (MASS1_FORMAT(FIELD))>)

	ELSE IF (FIELD .GE. 12 .AND. FIELD .LE. 14) THEN

	WRITE(LUN,450) MASS2_FORMAT(FIELD)
450	FORMAT(' ',T40,'FORMAT  = ',
	1 A<COMPRESSC (MASS2_FORMAT(FIELD))>)
	ENDIF

	CALL LINCHK (LUN,1)

	FIELD=LIB$EXTZV(8,3,DRIVE_TC)

	IF (FIELD .EQ. 3 .OR. FIELD .EQ. 4) THEN

	WRITE(LUN,500) MASS_DENSITY(FIELD)
500	FORMAT(' ',T40,'DENSITY = ',
	1 A<COMPRESSC (MASS_DENSITY(FIELD))>)
	ENDIF

	CALL OUTPUT (LUN,DRIVE_TC,MASS2_TC,12,12,15,'0')
	endif

	call linchk (lun,1)

	write(lun,530)
530	format(' ',:)

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

	write(lun,530)

	call masstape_qio (lun,emb$w_dv_func)

	call irp$w_bcnt (lun,emb$w_dv_bcnt)

	call irp$w_boff (lun,emb$w_dv_boff)

	call irp$l_pid (lun,emb$l_dv_rqpid)

	call irp$q_iosb (lun,emb$l_dv_iosb1)
	endif

	RETURN




	ENTRY B_MASSTAPE (LUN)




	call dhead1 (lun,'MASSBUS')

	CALL BRIEF16 (LUN,10,DRIVE_CS1,REG_HERALD,EMB$T_DV_NAME,EMB$W_DV_UNIT)

	RETURN




	ENTRY C_MASSTAPE (LUN)




	CALL CRYPTK (LUN,16,10,DRIVE_CS1,REG_HERALD,
	1 EMB$T_DV_NAME,EMB$W_DV_UNIT)

	RETURN

	END




	subroutine masstape_qio (lun,emb$w_dv_func)



	include 'src$:qiocommon.for /nolist'



	byte		lun

	integer*2	emb$w_dv_func

	integer*4	qiocode(0:1,0:63)




	if (qiocode(0,0) .eq. 0) then

	qiocode(1,00) = %loc(io$_nop)

	qiocode(1,01) = %loc(io$_unload)

	qiocode(1,03) = %loc(io$_recal)

	qiocode(1,04) = %loc(io$_drvclr)

	qiocode(1,06) = %loc(io$_erasetape)

	qiocode(1,08) = %loc(io$_packack)

	qiocode(1,09) = %loc(io$_spacerecord)

	qiocode(1,10) = %loc(io$_writecheck)

	qiocode(1,11) = %loc(io$_writepblk)

	qiocode(1,12) = %loc(io$_readpblk)

	qiocode(1,25) = %loc(io$_readpreset)

	qiocode(1,26) = %loc(io$_setchar)

	qiocode(1,27) = %loc(io$_sensechar)

	qiocode(1,28) = %loc(io$_writemark)

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
