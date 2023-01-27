	SUBROUTINE MASSDISK (LUN)
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
C	AUTHOR	BRIAN PORTER		CREATION DATE 19-FEB-1979
C
C	Functional description:
C
C	This module displays error log entries for all massbus disks.
C
C	Modified by:
C
C	v02-004	BP0004		Brian Porter,		16-NOV-1981
C		Added different mba handling.
C
C	v02-003	BP0003		Brian Porter,		06-NOV-1981
C		Added 'device attention' support.  Corrected ac lo, dc lo
C		reversal in er3.
C
C	v02-002	BP0002		Brian Porter,		29-JUN-1981
C		Added call to LOGGER and DHEAD.  Added DIAGNOSTIC_MODE.
C
C	v02-001	BP0001		Brian Porter,		31-AUG-1980
C		Removed call to UNUSED_BITS.  Changed format statements
C		so that 32 bit registers are printed.
C**

	INCLUDE 'SRC$:MSGHDR.FOR /NOLIST'
	INCLUDE 'SRC$:DEVERR.FOR /NOLIST'


	BYTE		LUN

	integer*4	mba_control_register(7)

	INTEGER*4	DRIVE_CS1
	INTEGER*4	DRIVE_DS
	INTEGER*4	DRIVE_ER1
	INTEGER*4	DRIVE_MR1
	INTEGER*4	DRIVE_AS
	INTEGER*4	DRIVE_LA
	INTEGER*4	DRIVE_DA
	INTEGER*4	DRIVE_DT
	INTEGER*4	DRIVE_SN
	INTEGER*4	DRIVE_OF
	INTEGER*4	DRIVE_DC
	INTEGER*4	RP_CC
	INTEGER*4	RM_ER2
	INTEGER*4	RP_ER2
	INTEGER*4	RM_MR2
	INTEGER*4	RP_ER3
	INTEGER*4	RM_HR
	INTEGER*4	DRIVE_EC1
	INTEGER*4	DRIVE_EC2
	INTEGER*4	DRIVE_FUNC

	logical*1	diagnostic_mode

	INTEGER*4	FUNCN(0:31)

	INTEGER*4	DESCR(2)

	INTEGER*4	FIELD

	INTEGER*4	COMPRESS4

	INTEGER*4	COMPRESSC

	integer*4	selected_mapping_register

	EQUIVALENCE	(RM03_DS(0),RP07_DS(0))

	equivalence	(mba_control_register,emb$l_dv_regsav(0))

	EQUIVALENCE	(DRIVE_CS1,EMB$L_DV_REGSAV(7))
	EQUIVALENCE	(DRIVE_DS,EMB$L_DV_REGSAV(8))
	EQUIVALENCE	(DRIVE_ER1,EMB$L_DV_REGSAV(9))
	EQUIVALENCE	(DRIVE_MR1,EMB$L_DV_REGSAV(10))
	EQUIVALENCE	(DRIVE_AS,EMB$L_DV_REGSAV(11))
	EQUIVALENCE	(DRIVE_DA,EMB$L_DV_REGSAV(12))
	EQUIVALENCE	(DRIVE_DT,EMB$L_DV_REGSAV(13))
	EQUIVALENCE	(DRIVE_LA,EMB$L_DV_REGSAV(14))
	EQUIVALENCE	(DRIVE_SN,EMB$L_DV_REGSAV(15))
	EQUIVALENCE	(DRIVE_OF,EMB$L_DV_REGSAV(16))
	EQUIVALENCE	(DRIVE_DC,EMB$L_DV_REGSAV(17))
	EQUIVALENCE	(RP_CC,RM_HR,EMB$L_DV_REGSAV(18))
	EQUIVALENCE	(RP_ER2,RM_MR2,EMB$L_DV_REGSAV(19))
	EQUIVALENCE	(RP_ER3,RM_ER2,EMB$L_DV_REGSAV(20))
	EQUIVALENCE	(DRIVE_EC1,EMB$L_DV_REGSAV(21))
	EQUIVALENCE	(DRIVE_EC2,EMB$L_DV_REGSAV(22))

	CHARACTER*7	MASS1_CS1(0:0)
	CHARACTER*4	REG_HERALD1(0:11)
	CHARACTER*4	REG_HERALD2(0:11)
	CHARACTER*16	MASS2_CS1(11:11)
	CHARACTER*12	RM03_DS(0:0)
	CHARACTER*20	RP07_DS(0:2)
	CHARACTER*24	MASS_DS(6:15)
	CHARACTER*30	MASS_ER1(0:15)
	CHARACTER*29	V1RP056_ER2(0:11)
	CHARACTER*11	V2RP056_ER2(13:13)
	CHARACTER*29	V1RP04_ER2(0:13)
	CHARACTER*10	V2RP04_ER2(15:15)
	CHARACTER*21	V1RP07_ER2(8:13)
	CHARACTER*14	V2RP07_ER2(15:15)
	CHARACTER*17	V1RP056_ER3(0:1)
	CHARACTER*22	V2RP056_ER3(4:6)
	CHARACTER*20	V3RP056_ER3(13:15)
	CHARACTER*18	V1RP04_ER3(0:1)
	CHARACTER*22	V2RP04_ER3(3:3)
	CHARACTER*6	V3RP04_ER3(5:6)
	CHARACTER*16	V4RP04_ER3(14:15)
	CHARACTER*23	V1RP07_ER3(0:11)

	CHARACTER*18	V2RP07_ER3(13:15)

	CHARACTER*18	V1RM03_ER2(3:3)
	CHARACTER*13	V2RM03_ER2(7:7)
	CHARACTER*21	V3RM03_ER2(10:15)
	CHARACTER*18	V1RM80_ER2(5:5)
	CHARACTER*15	RP0456_LA(0:3)
	CHARACTER*29	V1RP0456_OF(7:8)
	CHARACTER*12	V2RP0456_OF(15:15)
	CHARACTER*23	MASS_OF(10:12)
	CHARACTER*5	RP0456_OF(1:6)
	CHARACTER*22	RP07_OF(14:15)
	CHARACTER*25	V1RM03_OFF(7:7)
	CHARACTER*26	V1RM80_OFF(9:9)
	CHARACTER*8	OFFSET_DIR(0:1)
	CHARACTER*10	V1MASS_DT(11:11)
	CHARACTER*12	V2MASS_DT(13:13)

	CHARACTER*13	NO_OPERATION

	CHARACTER*7	UNLOAD

	CHARACTER*5	SEEK

	CHARACTER*12	RECALIBRATE

	CHARACTER*12	DRIVE_CLEAR

	CHARACTER*13	RELEASE_PORT

	CHARACTER*7	OFFSET

	CHARACTER*21	RTZ

	CHARACTER*15	READ_IN_PRESET

	CHARACTER*17	PACK_ACKNOWLEDGE

	CHARACTER*17	ILLEGAL_FUNCTION

	CHARACTER*7	SEARCH

	CHARACTER*17	WRITE_CHECKD

	CHARACTER*28	WRITE_CHECKH

	CHARACTER*11	WRITE_DATA

	CHARACTER*22	WRITEH_DATA

	CHARACTER*10	READ_DATA

	CHARACTER*21	READH_DATA

	CHARACTER*11	DIAGNOSTIC

	CHARACTER*13	FORMAT_TRACK

	CHARACTER*23	WRITE_TRACKD

	CHARACTER*11	DRIVE_TYPE

	CHARACTER*22	READ_TRACKD

	PARAMETER	DT_RP04 = 16
	PARAMETER	DT_RP05 = 17
	PARAMETER	DT_RP06 = 18
	PARAMETER	DT_RP07 = 34
	PARAMETER	DT_RM03 = 20
	PARAMETER	DT_RM05 = 23
	PARAMETER	DT_RM80 = 22

	PARAMETER	RM03 = 6
	PARAMETER	RP06 = 5
	PARAMETER	RP05 = 4
	PARAMETER	RP04 = 3
	PARAMETER	RP07 = 7
	PARAMETER	RM80 = 13
	PARAMETER	RM05 = 15

	PARAMETER	XFER_CMD = 20
	PARAMETER	TIMEOUT  = 96

	PARAMETER	NO_MOL = 1







	DATA	MASS1_CS1(0)	/'GO BIT*'/




	DATA	MASS2_CS1(11)	/'DRIVE AVAILABLE*'/




	DATA	RP07_DS(0)	/'OFFSET MODE*'/

	DATA	RP07_DS(1)	/'EARLY WARNING*'/

	DATA	RP07_DS(2)	/'INTERLEAVED SECTORS*'/




	DATA	MASS_DS(6)	/'VOLUME VALID*'/

	DATA	MASS_DS(7)	/'DRIVE READY*'/

	DATA	MASS_DS(8)	/'DRIVE PRESENT*'/

	DATA	MASS_DS(9)	/'PROGRAMMABLE*'/

	DATA	MASS_DS(10)	/'LAST SECTOR TRANSFERRED*'/

	DATA	MASS_DS(11)	/'WRITE PROTECTED*'/

	DATA	MASS_DS(12)	/'MEDIUM ON-LINE*'/

	DATA	MASS_DS(13)	/'POSITIONING IN PROGRESS*'/

	DATA	MASS_DS(14)	/'COMPOSITE ERROR*'/

	DATA	MASS_DS(15)	/'ATTENTION ACTIVE*'/




	DATA	MASS_ER1(0)	/'ILLEGAL FUNCTION*'/

	DATA	MASS_ER1(1)	/'ILLEGAL REGISTER*'/

	DATA	MASS_ER1(2)	/'REGISTER MODIFICATION REFUSED*'/

	DATA	MASS_ER1(3)	/'PARITY ERROR*'/

	DATA	MASS_ER1(4)	/'FORMAT ERROR*'/

	DATA	MASS_ER1(5)	/'WRITE CLOCK FAIL*'/

	DATA	MASS_ER1(6)	/'ECC HARD ERROR*'/

	DATA	MASS_ER1(7)	/'HDR COMPARE ERROR*'/

	DATA	MASS_ER1(8)	/'HDR CRC ERROR*'/

	DATA	MASS_ER1(9)	/'ADDRESS OVERFLOW ERROR*'/

	DATA	MASS_ER1(10)	/'INVALID ADDRESS ERROR*'/

	DATA	MASS_ER1(11)	/'WRITE LOCK ERROR*'/

	DATA	MASS_ER1(12)	/'DRIVE TIMING ERROR*'/

	DATA	MASS_ER1(13)	/'OPERATION INCOMPLETE*'/

	DATA	MASS_ER1(14)	/'DRIVE UNSAFE*'/

	DATA	MASS_ER1(15)	/'DATA CHECK*'/



	DATA	V1RP056_ER2(0)	/'WRITE CURRENT UNSAFE*'/

	DATA	V1RP056_ER2(1)	/'CURRENT SINK FAILURE*'/

	DATA	V1RP056_ER2(2)	/'WRITE SELECT UNSAFE*'/

	DATA	V1RP056_ER2(3)	/'CURRENT SWITCH UNSAFE*'/

	DATA	V1RP056_ER2(4)	/'READ AND WRITE*'/

	DATA	V1RP056_ER2(5)	/'TRANSITIONS DETECTED FAILURE*'/

	DATA	V1RP056_ER2(6)	/'TRANSITIONS UNSAFE*'/

	DATA	V1RP056_ER2(7)	/'ABNORMAL STOP*'/

	DATA	V1RP056_ER2(8)	/'WRITE READY UNSAFE*'/

	DATA	V1RP056_ER2(9)	/'MULTIPLE HEAD SELECT*'/

	DATA	V1RP056_ER2(10)	/'NO HEAD SELECT*'/

	DATA	V1RP056_ER2(11)	/'INDEX ERROR*'/





	DATA	V2RP056_ER2(13)	/'PLO UNSAFE*'/




	DATA	V1RP04_ER2(0)	/'WRITE CURRENT UNSAFE*'/

	DATA	V1RP04_ER2(1)	/'CURRENT SINK FAILURE*'/

	DATA	V1RP04_ER2(2)	/'WRITE SELECT UNSAFE*'/

	DATA	V1RP04_ER2(3)	/'CURRENT SWITCH UNSAFE*'/

	DATA	V1RP04_ER2(4)	/'MOTOR SEQUENCE ERROR*'/

	DATA	V1RP04_ER2(5)	/'TRANSITIONS DETECTED FAILURE*'/

	DATA	V1RP04_ER2(6)	/'TRANSITIONS UNSAFE*'/

	DATA	V1RP04_ER2(7)	/'FAILSAFE ENABLE*'/

	DATA	V1RP04_ER2(8)	/'WRITE READY UNSAFE*'/

	DATA	V1RP04_ER2(9)	/'MULTIPLE HEAD SELECT*'/

	DATA	V1RP04_ER2(10)	/'NO HEAD SELECT*'/

	DATA	V1RP04_ER2(11)	/'INDEX ERROR*'/

	DATA	V1RP04_ER2(12)	/'30V UNSAFE*'/

	DATA	V1RP04_ER2(13)	/'PLO UNSAFE*'/





	DATA	V2RP04_ER2(15)	/'AC UNSAFE*'/




	DATA	V1RP07_ER2(8)	/'WRITE READY UNSAFE*'/

	DATA	V1RP07_ER2(9)	/'WRITE OVERRUN*'/

	DATA	V1RP07_ER2(10)	/'READ WRITE UNSAFE #1*'/

	DATA	V1RP07_ER2(11)	/'READ WRITE UNSAFE #2*'/

	DATA	V1RP07_ER2(12)	/'READ WRITE UNSAFE #3*'/

	DATA	V1RP07_ER2(13)	/'8080 UNSAFE*'/




	DATA	V2RP07_ER2(15)	/'PROGRAM ERROR*'/




	DATA	V1RP056_ER3(0)	/'DC UNSAFE*'/

	DATA	V1RP056_ER3(1)	/'WRITE AND OFFSET*'/



	DATA	V2RP056_ER3(4)	/'35V REGULATOR FAILURE*'/

	DATA	V2RP056_ER3(5)	/'DC LO*'/

	DATA	V2RP056_ER3(6)	/'AC LO*'/



	DATA	V3RP056_ER3(13)	/'OPERATOR PLUG ERROR*'/

	DATA	V3RP056_ER3(14)	/'SEEK INCOMPLETE*'/

	DATA	V3RP056_ER3(15)	/'OFF CYLINDER*'/



	DATA	V1RP04_ER3(0)	/'PACK SPEED UNSAFE*'/

	DATA	V1RP04_ER3(1)	/'VELOCITY UNSAFE*'/





	DATA	V2RP04_ER3(3)	/'ANY UNSAFE EXCEPT R/W*'/





	DATA	V3RP04_ER3(5)	/'DC LO*'/

	DATA	V3RP04_ER3(6)	/'AC LO*'/




	DATA	V4RP04_ER3(14)	/'SEEK INCOMPLETE*'/

	DATA	V4RP04_ER3(15)	/'OFF CYLINDER*'/




	DATA	V1RP07_ER3(0)	/'RUN TIMEOUT ERROR*'/

	DATA	V1RP07_ER3(1)	/'SYNC CLOCK FAILURE*'/

	DATA	V1RP07_ER3(2)	/'SYNC BYTE ERROR*'/

	DATA	V1RP07_ER3(3)	/'DATA PARITY ERROR*'/

	DATA	V1RP07_ER3(4)	/'SERDES DATA FAILURE*'/

	DATA	V1RP07_ER3(5)	/'DC UNSAFE*'/

	DATA	V1RP07_ER3(6)	/'INDEX UNSAFE*'/

	DATA	V1RP07_ER3(7)	/'DEVICE CHECK*'/

	DATA	V1RP07_ER3(8)	/'8080 HANDSHAKE FAILURE*'/

	DATA	V1RP07_ER3(9)	/'LOSS OF CYLINDER ERROR*'/

	DATA	V1RP07_ER3(10)	/'LOSS OF BIT CLOCK*'/

	DATA	V1RP07_ER3(11)	/'CONTROL LOGIC FAILURE*'/



	DATA	V2RP07_ER3(13)	/'DEFECT SKIP ERROR*'/

	DATA	V2RP07_ER3(14)	/'SEEK INCOMPLETE*'/

	DATA	V2RP07_ER3(15)	/'BAD SECTOR ERROR*'/




	DATA	V1RM03_ER2(3)	/'DATA PARITY ERROR*'/




	DATA	V2RM03_ER2(7)	/'DEVICE CHECK*'/




	DATA	V3RM03_ER2(10)	/'LOSS OF BIT CLOCK*'/

	DATA	V3RM03_ER2(11)	/'LOSS OF SYSTEM CLOCK*'/

	DATA	V3RM03_ER2(12)	/'INVALID COMMAND*'/

	DATA	V3RM03_ER2(13)	/'OPERATOR PLUG ERROR*'/

	DATA	V3RM03_ER2(14)	/'SEEK INCOMPLETE*'/

	DATA	V3RM03_ER2(15)	/'BAD SECTOR ERROR*'/



	DATA	V1RM80_ER2(5)	/'SKIP SECTOR ERROR*'/




	DATA	RP0456_LA(0)	/'FIRST QUARTER*'/

	DATA	RP0456_LA(1)	/'SECOND QUARTER*'/

	DATA	RP0456_LA(2)	/'THIRD QUARTER*'/

	DATA	RP0456_LA(3)	/'FOURTH QUARTER*'/



	DATA	V1RP0456_OF(7)	/'OFFSET DIRECTION BIT SET*'/

	DATA	V1RP0456_OF(8)	/'DATA CHECK IN PROGRESS (VMS)*'/



	DATA	V2RP0456_OF(15)	/'SIGN CHANGE*'/



	DATA	MASS_OF(10)	/'HDR COMPARE INHIBIT*'/

	DATA	MASS_OF(11)	/'ECC INHIBIT*'/

	DATA	MASS_OF(12)	/'16-BIT FORMAT*'/



	DATA	RP0456_OF(1)	/'200*'/

	DATA	RP0456_OF(2)	/'400*'/

	DATA	RP0456_OF(3)	/'600*'/

	DATA	RP0456_OF(4)	/'800*'/

	DATA	RP0456_OF(6)	/'1200*'/



	DATA	RP07_OF(14)	/'MOVE TRACK DESCRIPTOR*'/

	DATA	RP07_OF(15)	/'COMMAND MODIFIER BIT*'/



	DATA	V1MASS_DT(11)	/'DUAL PORT*'/




	DATA	V2MASS_DT(13)	/'MOVING HEAD*'/



	DATA	OFFSET_DIR(0)	/'REVERSE*'/

	DATA	OFFSET_DIR(1)	/'FORWARD*'/





	DATA	V1RM03_OFF(7)	/'OFFSET DIRECTION BIT SET*'/




	DATA	V1RM80_OFF(9)	/'SKIP SECTOR ERROR INHIBIT*'/



	DATA	REG_HERALD1(0)	/'CS*'/

	DATA	REG_HERALD1(1)	/'DS*'/

	DATA	REG_HERALD1(2)	/'ER1*'/

	DATA	REG_HERALD1(3)	/'MR*'/

	DATA	REG_HERALD1(4)	/'AS*'/

	DATA	REG_HERALD1(5)	/'DA*'/

	DATA	REG_HERALD1(6)	/'DT*'/

	DATA	REG_HERALD1(7)	/'LA*'/

	DATA	REG_HERALD1(8)	/'SN*'/

	DATA	REG_HERALD1(9)	/'OF*'/

	DATA	REG_HERALD1(10)	/'DC*'/

	DATA	REG_HERALD1(11)	/'CC*'/






	DATA	REG_HERALD2(0)	/'CS*'/

	DATA	REG_HERALD2(1)	/'DS*'/

	DATA	REG_HERALD2(2)	/'ER1*'/

	DATA	REG_HERALD2(3)	/'MR1*'/

	DATA	REG_HERALD2(4)	/'AS*'/

	DATA	REG_HERALD2(5)	/'DA*'/

	DATA	REG_HERALD2(6)	/'DT*'/

	DATA	REG_HERALD2(7)	/'LA*'/

	DATA	REG_HERALD2(8)	/'SN*'/

	DATA	REG_HERALD2(9)	/'OF*'/

	DATA	REG_HERALD2(10)	/'DC*'/

	DATA	REG_HERALD2(11)	/'HR*'/



	DATA	NO_OPERATION	/'NO-OPERATION*'/

	DATA	UNLOAD		/'UNLOAD*'/

	DATA	SEEK		/'SEEK*'/

	DATA	RECALIBRATE	/'RECALIBRATE*'/

	DATA	DRIVE_CLEAR	/'DRIVE CLEAR*'/

	DATA	RELEASE_PORT	/'RELEASE PORT*'/

	DATA	OFFSET		/'OFFSET*'/

	DATA	RTZ		/'RETURN TO CENTRELINE*'/

	DATA	READ_IN_PRESET	/'READ IN PRESET*'/

	DATA	PACK_ACKNOWLEDGE/'PACK ACKNOWLEDGE*'/

	DATA	SEARCH		/'SEARCH*'/

	DATA	WRITE_CHECKD	/'WRITE CHECK DATA*'/

	DATA	WRITE_CHECKH	/'WRITE CHECK HEADER AND DATA*'/

	DATA	WRITE_DATA	/'WRITE DATA*'/

	DATA	WRITEH_DATA	/'WRITE HEADER AND DATA*'/

	DATA	READ_DATA	/'READ DATA*'/

	DATA	READH_DATA	/'READ HEADER AND DATA*'/

	DATA	ILLEGAL_FUNCTION/'ILLEGAL FUNCTION*'/

	DATA	DIAGNOSTIC	/'DIAGNOSTIC*'/

	DATA	FORMAT_TRACK	/'FORMAT TRACK*'/

	DATA	WRITE_TRACKD	/'WRITE TRACK DESCRIPTOR*'/

	DATA	READ_TRACKD	/'READ TRACK DESCRIPTOR*'/




	DATA	DRIVE_TYPE	/'DRIVE TYPE '/




	CALL FRCTOF(LUN)

	call dhead1 (lun,'MASSBUS')

	DRIVE_FUNC=LIB$EXTZV(1,5,DRIVE_CS1)

	if (
	1 emb$w_dv_bcnt .ne. 0
	1 .and.
	1 drive_func .ge. xfer_cmd
	1 .and.
	1 emb$w_hd_entry .ne. 98
	1 ) then

	call mba_control_registers (lun,5,mba_control_register,
	1 selected_mapping_register)

	call mba_mapping_register (lun,selected_mapping_register,
	1 mba_control_register(6))

	if (selected_mapping_register .gt. 0) then

	call mba_mapping_register (lun,(selected_mapping_register - 1),
	1 mba_control_register(7))
	endif
	endif

	DO 250,I = 0,31

	FUNCN(I) = %LOC(ILLEGAL_FUNCTION)

250	CONTINUE

	FUNCN(0) = %LOC(NO_OPERATION)

	FUNCN(2) = %LOC(SEEK)

	FUNCN(3) = %LOC(RECALIBRATE)

	FUNCN(4) = %LOC(DRIVE_CLEAR)

	FUNCN(5) = %LOC(RELEASE_PORT)

	FUNCN(6) = %LOC(OFFSET)

	FUNCN(7) = %LOC(RTZ)

	FUNCN(8) = %LOC(READ_IN_PRESET)

	FUNCN(9) = %LOC(PACK_ACKNOWLEDGE)

	FUNCN(12) = %LOC(SEARCH)

	FUNCN(20) = %LOC(WRITE_CHECKD)

	FUNCN(21) = %LOC(WRITE_CHECKH)

	FUNCN(24) = %LOC(WRITE_DATA)

	FUNCN(25) = %LOC(WRITEH_DATA)

	FUNCN(28) = %LOC(READ_DATA)

	FUNCN(29) = %LOC(READH_DATA)

	diagnostic_mode = .false.

	IF (EMB$B_DV_TYPE .EQ. RP04
	1 .OR.
	2 EMB$B_DV_TYPE .EQ. RP05
	3 .OR.
	4 EMB$B_DV_TYPE .EQ. RP06
	5 .OR.
	6 EMB$B_DV_TYPE .EQ. RP07) THEN
	
	if (lib$extzv(0,1,drive_mr1) .eq. 1) diagnostic_mode = .true.

	IF (EMB$B_DV_TYPE .EQ. RP07) THEN

	diagnostic_mode = .false.

	if (lib$extzv(15,1,drive_mr1) .eq. 1) diagnostic_mode = .true.

	FUNCN(14) = %LOC(DIAGNOSTIC)

	FUNCN(25) = %LOC(FORMAT_TRACK)

	FUNCN(26) = %LOC(WRITE_TRACKD)

	FUNCN(30) = %LOC(READ_TRACKD)
	ELSE

	FUNCN(1) = %LOC(UNLOAD)
	ENDIF

C
C	RP04/5/6/7 DISK DRIVE SUPPORT
C

350	CALL LINCHK (LUN,2)

	WRITE(LUN,400) DRIVE_CS1
400	FORMAT('0',T8,'RPCS',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_cs1,drive_cs1,0)

	CALL OUTPUT (LUN,DRIVE_CS1,MASS1_CS1,0,0,0,'0')

	FIELD = LIB$EXTZV(1,5,DRIVE_CS1)

	DESCR(2) = FUNCN(FIELD)

	DESCR(1) = 33

	DESCR(1) = LIB$LOCC('*',DESCR)

	CALL OUTPUTD (LUN,DESCR)

	CALL OUTPUT (LUN,DRIVE_CS1,MASS2_CS1,11,11,11,'0')
	endif

C
C	'DS' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,505) DRIVE_DS
505	FORMAT(' ',T8,'RPDS',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_cs1,drive_ds,1)

	IF (EMB$B_DV_TYPE .EQ. RP07) THEN

	CALL OUTPUT (LUN,DRIVE_DS,RP07_DS,0,0,2,'0')
	ENDIF

	CALL OUTPUT (LUN,DRIVE_DS,MASS_DS,6,6,15,'0')
	endif

C
C	'ER1' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,520) DRIVE_ER1
520	FORMAT(' ',T8,'RPER1',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_ds,drive_er1,1)

	CALL OUTPUT (LUN,DRIVE_ER1,MASS_ER1,0,0,15,'0')
	endif

C
C	'MR' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,525) DRIVE_MR1
525	FORMAT(' ',T8,'RPMR',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_er1,drive_mr1,1)
	else

	CALL LINCHK (LUN,1)

	WRITE(LUN,526)
526	FORMAT(' ',T40,'DIAGNOSTIC MODE')
	endif

C
C	'AS' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,527) DRIVE_AS
527	FORMAT(' ',T8,'RPAS',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_mr1,drive_as,1)

	DO 529 I=0,7

	if (lib$extzv(i,1,drive_as) .eq. 1) then

	CALL LINCHK (LUN,1)

	WRITE(LUN,528) I
528	FORMAT(' ',T40,'ATTENTION UNIT ',I1,'.')
	endif

529	CONTINUE
	endif

C
C	'DA' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,530) DRIVE_DA
530	FORMAT(' ',T8,'RPDA',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_as,drive_da,1)

	CALL LINCHK (LUN,2)

	IF (EMB$B_DV_TYPE .EQ. RP07) THEN

	FIELD=LIB$EXTZV(0,6,DRIVE_DA)
	ELSE

	FIELD=LIB$EXTZV(0,5,DRIVE_DA)
	ENDIF

	WRITE(LUN,535) FIELD
535	FORMAT(' ',T40,'SECTOR = ',I<COMPRESS4 (FIELD)>,'.')

	FIELD=LIB$EXTZV(8,5,DRIVE_DA)

	WRITE(LUN,537) FIELD
537	FORMAT(' ',T40,'TRACK  = ',I<COMPRESS4 (FIELD)>,'.')
	endif

C
C	'DT' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,541) DRIVE_DT
541	FORMAT(' ',T8,'RPDT',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_da,drive_dt,1)

	CALL LINCHK (LUN,1)

	FIELD=LIB$EXTZV(0,9,DRIVE_DT)

	IF (FIELD .EQ. DT_RP04) THEN

	WRITE(LUN,544) DRIVE_TYPE
544	FORMAT(' ',T40,A11,'RP04')

	ELSE IF (FIELD .EQ. DT_RP05) THEN

	WRITE(LUN,545) DRIVE_TYPE
545	FORMAT(' ',T40,A11,'RP05')

	ELSE IF (FIELD .EQ. DT_RP06) THEN

	WRITE(LUN,546) DRIVE_TYPE
546	FORMAT(' ',T40,A11,'RP06')

	ELSE IF (FIELD .EQ. DT_RP07) THEN

	WRITE(LUN,547) DRIVE_TYPE
547	FORMAT(' ',T40,A11,'RP07')
	ENDIF

554	CALL OUTPUT (LUN,DRIVE_DT,V1MASS_DT,11,11,11,'0')

	CALL OUTPUT (LUN,DRIVE_DT,V2MASS_DT,13,13,13,'0')
	endif

C
C	'LA' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,560) DRIVE_LA
560	FORMAT(' ',T8,'RPLA',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_dt,drive_la,1)

	IF (EMB$B_DV_TYPE .EQ. RP07) THEN

	FIELD=LIB$EXTZV(5,7,DRIVE_LA)
	ELSE

	FIELD=LIB$EXTZV(4,2,DRIVE_LA)

	CALL LINCHK (LUN,1)

	WRITE(LUN,563) RP0456_LA(FIELD)
563	FORMAT(' ',T40,A<COMPRESSC (RP0456_LA(FIELD))>)

	FIELD=LIB$EXTZV(6,5,DRIVE_LA)
	ENDIF

	CALL LINCHK (LUN,1)

	WRITE(LUN,565) FIELD
565	FORMAT(' ',T40,'SECTOR COUNTER = ',I<COMPRESS4 (FIELD)>,'.')
	endif

C
C	'ER2' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,570) RP_ER2
570	FORMAT(' ',T8,'RPER2',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_la,rp_er2,1)

	IF (EMB$B_DV_TYPE .EQ. RP04) THEN

	CALL OUTPUT (LUN,RP_ER2,V1RP04_ER2,0,0,13,'0')

	CALL OUTPUT (LUN,RP_ER2,V2RP04_ER2,15,15,15,'0')

	ELSE IF (
	1 EMB$B_DV_TYPE .EQ. RP05
	1 .OR.
	2 EMB$B_DV_TYPE .EQ. RP06
	1 ) THEN

	CALL OUTPUT (LUN,RP_ER2,V1RP056_ER2,0,0,11,'0')

	CALL OUTPUT (LUN,RP_ER2,V2RP056_ER2,13,13,13,'0')

	ELSE IF (EMB$B_DV_TYPE .EQ. RP07) THEN

	FIELD = LIB$EXTZV(0,8,RP_ER2)

	IF (FIELD .NE. 0) THEN

	CALL LINCHK (LUN,1)

	WRITE(LUN,575) FIELD
575	FORMAT(' ',T40,'ERROR CODE = ',Z2,' (HEX)')
	ENDIF

	CALL OUTPUT (LUN,RP_ER2,V1RP07_ER2,8,8,13,'0')

	CALL OUTPUT (LUN,RP_ER2,V2RP07_ER2,15,15,15,'0')
	ENDIF
	endif

C
C	'OF' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,580) DRIVE_OF
580	FORMAT(' ',T8,'RPOF',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,rp_er2,drive_of,1)

	IF (EMB$B_DV_TYPE .NE. RP07) THEN

	FIELD=LIB$EXTZV(3,3,DRIVE_OF)

	IF (FIELD .EQ. 0) THEN

	CALL OUTPUT (LUN,DRIVE_OF,V1RP0456_OF,7,7,8,'0')

	ELSE IF (
	1 ((FIELD .EQ. 2
	1 .OR.
	2 FIELD .EQ. 4
	3 .OR.
	4 FIELD .EQ. 6)
	5 .AND.
	6 EMB$B_DV_TYPE .EQ. RP04)
	7 .OR.
	8 (FIELD .GE. 1
	9 .AND.
	1 FIELD .LE. 3
	2 .AND.
	3 (EMB$B_DV_TYPE .EQ. RP05
	4 .OR.
	5 EMB$B_DV_TYPE .EQ. RP06))
	1 ) THEN

	CALL LINCHK (LUN,1)

	WRITE(LUN,581) RP0456_OF(FIELD)
581	FORMAT(' ',T40,'OFFSET = ',A<COMPRESSC (RP0456_OF(FIELD))>,
	1 ' MICRO INCHES')

	FIELD=LIB$EXTZV(7,1,DRIVE_OF)

	CALL LINCHK (LUN,1)

	WRITE(LUN,582) OFFSET_DIR(FIELD)
582	FORMAT(' ',T40,'OFFSET DIRECTION = ',
	1 A<COMPRESSC (OFFSET_DIR(FIELD))>)

	CALL OUTPUT (LUN,DRIVE_OF,V1RP0456_OF,7,8,8,'0')
	ELSE

	CALL OUTPUT (LUN,DRIVE_OF,V1RP0456_OF,7,8,8,'0')
	ENDIF
	ENDIF

	CALL OUTPUT (LUN,DRIVE_OF,MASS_OF,10,10,12,'0')

	IF (EMB$B_DV_TYPE .EQ. RP07) THEN

	CALL OUTPUT (LUN,DRIVE_OF,RP07_OF,14,14,15,'0')
	ELSE

	CALL OUTPUT (LUN,DRIVE_OF,V2RP0456_OF,15,15,15,'0')
	ENDIF
	endif

C
C	'DC' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,590) DRIVE_DC
590	FORMAT(' ',T8,'RPDC',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_of,drive_dc,1)

	IF (
	1 EMB$B_DV_TYPE .EQ. RP06
	1 .OR.
	1 EMB$B_DV_TYPE .EQ. RP07
	1 ) THEN

	FIELD=LIB$EXTZV(0,10,DRIVE_DC)
	ELSE

	FIELD=LIB$EXTZV(0,9,DRIVE_DC)
	ENDIF

	CALL LINCHK (LUN,1)

	WRITE(LUN,595) FIELD
595	FORMAT(' ',T40,'DESIRED CYLINDER = ',I<COMPRESS4 (FIELD)>,'.')
	endif

C
C	'CC' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,600) RP_CC
600	FORMAT(' ',T8,'RPCC',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_dc,rp_cc,1)

	IF (
	1 EMB$B_DV_TYPE .EQ. RP06
	1 .OR.
	1 EMB$B_DV_TYPE .EQ. RP07
	1 ) THEN

	FIELD=LIB$EXTZV(0,10,RP_CC)
	ELSE

	FIELD=LIB$EXTZV(0,9,RP_CC)
	ENDIF

	CALL LINCHK (LUN,1)

	WRITE(LUN,605) FIELD
605	FORMAT(' ',T40,'CURRENT CYLINDER = ',I<COMPRESS4 (FIELD)>,'.')
	endif

C
C	'SN' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,610) DRIVE_SN
610	FORMAT(' ',T8,'RPSN',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,rp_cc,drive_sn,1)
	endif

C
C	'ER3' REGISTER
C

614	CALL LINCHK (LUN,1)

	WRITE(LUN,615) RP_ER3
615	FORMAT(' ',T8,'RPER3',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_sn,rp_er3,1)

	IF (EMB$B_DV_TYPE .EQ. RP04) THEN

	CALL OUTPUT (LUN,RP_ER3,V1RP04_ER3,0,0,1,'0')

	CALL OUTPUT (LUN,RP_ER3,V2RP04_ER3,3,3,3,'0')

	CALL OUTPUT (LUN,RP_ER3,V3RP04_ER3,5,5,6,'0')

	CALL OUTPUT (LUN,RP_ER3,V4RP04_ER3,14,14,15,'0')

	ELSE IF (
	1 EMB$B_DV_TYPE .EQ. RP05
	1 .OR.
	1 EMB$B_DV_TYPE .EQ. RP06
	1 ) THEN

	CALL OUTPUT (LUN,RP_ER3,V1RP056_ER3,0,0,1,'0')

	CALL OUTPUT (LUN,RP_ER3,V2RP056_ER3,4,4,6,'0')

	CALL OUTPUT (LUN,RP_ER3,V3RP056_ER3,13,13,15,'0')

	ELSE IF (EMB$B_DV_TYPE .EQ. RP07) THEN

	CALL OUTPUT (LUN,RP_ER3,V1RP07_ER3,0,0,11,'0')

	CALL OUTPUT (LUN,RP_ER3,V2RP07_ER3,13,13,15,'0')
	ENDIF
	endif

C
C	'EC1' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,645) DRIVE_EC1
645	FORMAT(' ',T8,'RPEC1',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,rp_er3,drive_ec1,1)
	endif

C
C	'EC2' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,650) DRIVE_EC2
650	FORMAT(' ',T8,'RPEC2',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_ec1,drive_ec2,1)
	endif

	call linchk (lun,1)

	write(lun,655)
655	format(' ',:)

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

	write(lun,655)

	call dbdriver_qio (lun,emb$w_dv_func)

	call irp$w_bcnt (lun,emb$w_dv_bcnt)

	call irp$w_boff (lun,emb$w_dv_boff)

	call irp$l_pid (lun,emb$l_dv_rqpid)

	call irp$q_iosb (lun,emb$l_dv_iosb1)
	endif

C
C	START OF RM03, RM05 AND RM80 DISK DRIVE SUPPORT
C

	ELSE IF (
	1 EMB$B_DV_TYPE .EQ. RM03
	1 .OR.
	2 EMB$B_DV_TYPE .EQ. RM05
	3 .OR.
	4 EMB$B_DV_TYPE .EQ. RM80
	1 ) THEN

	if (lib$extzv(0,1,drive_mr1) .eq. 1) diagnostic_mode = .true.

	CALL LINCHK (LUN,2)

	WRITE(LUN,1005) DRIVE_CS1
1005	FORMAT('0',T8,'RMCS',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_cs1,drive_cs1,0)

	CALL OUTPUT (LUN,DRIVE_CS1,MASS1_CS1,0,0,0,'0')

	FIELD = LIB$EXTZV(1,5,DRIVE_CS1)

	DESCR(2) = FUNCN(FIELD)

	DESCR(1) = 33

	DESCR(1) = LIB$LOCC('*',DESCR)

	CALL OUTPUTD (LUN,DESCR)

	CALL OUTPUT (LUN,DRIVE_CS1,MASS2_CS1,11,11,11,'0')
	endif

C
C	'DS' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,1030) DRIVE_DS
1030	FORMAT(' ',T8,'RMDS',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_cs1,drive_ds,1)

	CALL OUTPUT (LUN,DRIVE_DS,RM03_DS,0,0,0,'0')

	CALL OUTPUT (LUN,DRIVE_DS,MASS_DS,6,6,15,'0')
	endif

C
C	'ER1' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,1035) DRIVE_ER1
1035	FORMAT(' ',T8,'RMER1',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_ds,drive_er1,1)

	CALL OUTPUT (LUN,DRIVE_ER1,MASS_ER1,0,0,15,'0')
	endif

C
C	'MR' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,1040) DRIVE_MR1
1040	FORMAT(' ',T8,'RMMR1',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_er1,drive_mr1,1)
	else

	call linchk (lun,1)

	WRITE(LUN,1042)
1042	FORMAT(' ',T40,'DIAGNOSTIC MODE')
	endif

C
C	'AS' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,1045) DRIVE_AS
1045	FORMAT(' ',T8,'RMAS',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_mr1,drive_as,1)

	DO 1048 I=0,7

	if (lib$extzv(i,1,drive_as) .eq. 1) then

	CALL LINCHK (LUN,1)

	WRITE(LUN,1046) I
1046	FORMAT(' ',T40,'ATTENTION UNIT ',I1,'.')
	endif

1048	CONTINUE
	endif

C
C	'DA' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,1050) DRIVE_DA
1050	FORMAT(' ',T8,'RMDA',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_as,drive_da,1)

	CALL LINCHK (LUN,2)

	FIELD=LIB$EXTZV(0,5,DRIVE_DA)

	WRITE(LUN,1055) FIELD
1055	FORMAT(' ',T40,'SECTOR = ',I<COMPRESS4 (FIELD)>,'.')

	IF (EMB$B_DV_TYPE .EQ. RM03) THEN

	FIELD = LIB$EXTZV(8,3,DRIVE_DA)

	ELSE IF (EMB$B_DV_TYPE .EQ. RM80) THEN

	FIELD = LIB$EXTZV(8,4,DRIVE_DA)

	ELSE IF (EMB$B_DV_TYPE .EQ. RM05) THEN

	FIELD = LIB$EXTZV(8,5,DRIVE_DA)
	ENDIF

	WRITE(LUN,1060) FIELD
1060	FORMAT(' ',T40,'TRACK  = ',I<COMPRESS4 (FIELD)>,'.')
	endif

C
C	'DT' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,1065) DRIVE_DT
1065	FORMAT(' ',T8,'RMDT',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_da,drive_dt,1)

	FIELD=LIB$EXTZV(0,9,DRIVE_DT)

	CALL LINCHK (LUN,1)

	IF (FIELD .EQ. DT_RM03) THEN

	WRITE(LUN,1067) DRIVE_TYPE
1067	FORMAT(' ',T40,A11,'RM03')

	ELSE IF (FIELD .EQ. DT_RM80) THEN

	WRITE(LUN,1068) DRIVE_TYPE
1068	FORMAT(' ',T40,A11,'RM80')

	ELSE IF (FIELD .EQ. DT_RM05) THEN

	WRITE(LUN,1069) DRIVE_TYPE
1069	FORMAT(' ',T40,A11,'RM05')
	ENDIF

	CALL OUTPUT (LUN,DRIVE_DT,V1MASS_DT,11,11,11,'0')

	CALL OUTPUT (LUN,DRIVE_DT,V2MASS_DT,13,13,13,'0')
	endif

C
C	'LA' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,1075) DRIVE_LA
1075	FORMAT(' ',T8,'RMLA',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_dt,drive_la,1)

	FIELD=LIB$EXTZV(6,5,DRIVE_LA)

	CALL LINCHK (LUN,1)

	WRITE(LUN,1080) FIELD
1080	FORMAT(' ',T40,'SECTOR COUNTER = ',I<COMPRESS4 (FIELD)>,'.')
	endif

C
C	'SN' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,1085) DRIVE_SN
1085	FORMAT(' ',T8,'RMSN',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_la,drive_sn,1)
	endif

C
C	'OF' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,1090) DRIVE_OF
1090	FORMAT(' ',T8,'RMOF',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_sn,drive_of,1)

	IF (JIAND(DRIVE_DS,1) .EQ. 1) THEN

	FIELD=LIB$EXTZV(1,1,DRIVE_OF)

	CALL LINCHK (LUN,1)

	WRITE(LUN,1095) OFFSET_DIR(FIELD)
1095	FORMAT(' ',T40,'OFFSET DIRECTION = ',
	1 A<COMPRESSC (OFFSET_DIR(FIELD))>)
	ELSE

	CALL OUTPUT (LUN,DRIVE_OF,V1RM03_OFF,7,7,7,'0')
	ENDIF

	IF (EMB$B_DV_TYPE .EQ. RM80) THEN

	CALL OUTPUT (LUN,DRIVE_OF,V1RM80_OFF,9,9,9,'0')
	ENDIF

	CALL OUTPUT (LUN,DRIVE_OF,MASS_OF,10,10,12,'0')
	endif

C
C	'DC' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,1100) DRIVE_DC
1100	FORMAT(' ',T8,'RMDC',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_of,drive_dc,1)

	FIELD=LIB$EXTZV(0,10,DRIVE_DC)

	CALL LINCHK (LUN,1)

	WRITE(LUN,1105) FIELD
1105	FORMAT(' ',T40,'DESIRED CYLINDER = ',I<COMPRESS4 (FIELD)>,'.')
	endif

C
C	'HR' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,1110) RM_HR
1110	FORMAT(' ',T8,'RMHR',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_dc,rm_hr,1)
	endif

C
C	'MR2' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,1115) RM_MR2
1115	FORMAT(' ',T8,'RMMR2',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,rm_hr,rm_mr2,1)
	endif

C
C	'ER2' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,1120) RM_ER2
1120	FORMAT(' ',T8,'RMER2',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,rm_mr2,rm_er2,1)

	CALL OUTPUT (LUN,RM_ER2,V1RM03_ER2,3,3,3,'0')

	IF (EMB$B_DV_TYPE .EQ. RM80) THEN

	CALL OUTPUT (LUN,RM_ER2,V1RM80_ER2,5,5,5,'0')
	ENDIF

	CALL OUTPUT (LUN,RM_ER2,V2RM03_ER2,7,7,7,'0')

	CALL OUTPUT (LUN,RM_ER2,V3RM03_ER2,10,10,15,'0')
	endif

C
C	'EC1' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,1125) DRIVE_EC1
1125	FORMAT(' ',T8,'RMEC1',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,rm_er2,drive_ec1,1)
	endif

C
C	'EC2' REGISTER
C

	CALL LINCHK (LUN,1)

	WRITE(LUN,1130) DRIVE_EC2
1130	FORMAT(' ',T8,'RMEC2',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,drive_ec1,drive_ec2,1)
	endif

	call linchk (lun,1)

	write(lun,1135)
1135	format(' ',:)

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

	write(lun,1135)

	call drdriver_qio (lun,emb$w_dv_func)

	call irp$w_bcnt (lun,emb$w_dv_bcnt)

	call irp$w_boff (lun,emb$w_dv_boff)

	call irp$l_pid (lun,emb$l_dv_rqpid)

	call irp$q_iosb (lun,emb$l_dv_iosb1)
	endif
	ENDIF

	RETURN




	ENTRY	B_MASSDISK (LUN)




	call dhead1 (lun,'MASSBUS')

	IF (
	1 EMB$B_DV_TYPE .EQ. RP04
	1 .OR.
	2 EMB$B_DV_TYPE .EQ. RP05
	3 .OR.
	4 EMB$B_DV_TYPE .EQ. RP06
	5 .OR.
	6 EMB$B_DV_TYPE .EQ. RP07
	1 ) THEN

	CALL BRIEF16 (LUN,12,DRIVE_CS1,REG_HERALD1,
	1 EMB$T_DV_NAME,EMB$W_DV_UNIT)
	ELSE

	CALL BRIEF16 (LUN,12,DRIVE_CS1,REG_HERALD2,
	1 EMB$T_DV_NAME,EMB$W_DV_UNIT)
	ENDIF

	RETURN




	ENTRY	C_MASSDISK (LUN)




	IF (
	1 EMB$B_DV_TYPE .EQ. RP04
	1 .OR.
	2 EMB$B_DV_TYPE .EQ. RP05
	3 .OR.
	4 EMB$B_DV_TYPE .EQ. RP06
	5 .OR.
	6 EMB$B_DV_TYPE .EQ. RP07
	1 ) THEN

	CALL CRYPTK (LUN,16,12,DRIVE_CS1,REG_HERALD1,
	1 EMB$T_DV_NAME,EMB$W_DV_UNIT)
	ELSE

	CALL CRYPTK (LUN,16,12,DRIVE_CS1,REG_HERALD2,
	1 EMB$T_DV_NAME,EMB$W_DV_UNIT)
	ENDIF

	RETURN

	END



	subroutine dbdriver_qio (lun,emb$w_dv_func)



	include 'src$:qiocommon.for /nolist'



	byte		lun

	integer*2	emb$w_dv_func

	integer*4	qiocode(0:1,0:63)




	if (qiocode(0,0) .eq. 0) then

	qiocode(1,00) = %loc(io$_nop)

	qiocode(1,01) = %loc(io$_unload)

	qiocode(1,02) = %loc(io$_seek)

	qiocode(1,03) = %loc(io$_recal)

	qiocode(1,04) = %loc(io$_drvclr)

	qiocode(1,05) = %loc(io$_release)

	qiocode(1,06) = %loc(io$_offset)

	qiocode(1,07) = %loc(io$_retcenter)

	qiocode(1,08) = %loc(io$_packack)

	qiocode(1,09) = %loc(io$_search)

	qiocode(1,10) = %loc(io$_writecheck)

	qiocode(1,11) = %loc(io$_writepblk)

	qiocode(1,12) = %loc(io$_readpblk)

	qiocode(1,13) = %loc(io$_writehead)

	qiocode(1,14) = %loc(io$_readhead)

	qiocode(1,24) = %loc(io$_writecheckh)

	qiocode(1,25) = %loc(io$_readpreset)

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

	call irp$w_func (lun,emb$w_dv_func,
	1 qiocode(0,lib$extzv(0,6,emb$w_dv_func)))

	return

	end



	subroutine drdriver_qio (lun,emb$w_dv_func)



	include 'src$:qiocommon.for /nolist'



	byte		lun

	integer*2	emb$w_dv_func

	integer*4	qiocode(0:1,0:63)




	if (qiocode(0,0) .eq. 0) then

	qiocode(1,00) = %loc(io$_nop)

	qiocode(1,02) = %loc(io$_seek)

	qiocode(1,03) = %loc(io$_recal)

	qiocode(1,04) = %loc(io$_drvclr)

	qiocode(1,05) = %loc(io$_release)

	qiocode(1,06) = %loc(io$_offset)

	qiocode(1,07) = %loc(io$_retcenter)

	qiocode(1,08) = %loc(io$_packack)

	qiocode(1,09) = %loc(io$_search)

	qiocode(1,10) = %loc(io$_writecheck)

	qiocode(1,11) = %loc(io$_writepblk)

	qiocode(1,12) = %loc(io$_readpblk)

	qiocode(1,13) = %loc(io$_writehead)

	qiocode(1,14) = %loc(io$_readhead)

	qiocode(1,15) = %loc(io$_writetrackd)

	qiocode(1,16) = %loc(io$_readtrackd)

	qiocode(1,24) = %loc(io$_writecheckh)

	qiocode(1,25) = %loc(io$_readpreset)

	qiocode(1,26) = %loc(io$_setchar)

	qiocode(1,27) = %loc(io$_sensechar)

	qiocode(1,29) = %loc(io$_diagnose)

	qiocode(1,32) = %loc(io$_writelblk)

	qiocode(1,33) = %loc(io$_readlblk)

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
