	SUBROUTINE RKDISK (LUN)
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
C	AUTHOR	BRIAN PORTER		CREATION DATE	31-MAR-1979
C

c++
c	Functional description:
c
c	This module displays entries made for the RK611 controller.
c	The format of the error log packet after the 4 longword header
c	is as follows.
c
c	+-------------------------------------+
c	|               rkcs1                 |
c	+-------------------------------------+
c	|               rkwc                  |
c	+-------------------------------------+
c	|               rkba                  |
c	+-------------------------------------+
c	|               rkda                  |
c	+-------------------------------------+
c	|               rkcs2                 |
c	+-------------------------------------+
c	|               rkds                  |
c	+-------------------------------------+
c	|               rker                  |
c	+-------------------------------------+
c	|               rkas                  |
c	+-------------------------------------+
c	|               rkdc                  |
c	+-------------------------------------+
c	|               rkmr1                 |
c	+-------------------------------------+
c	|               rkec1                 |
c	+-------------------------------------+
c	|               rkec2                 |
c	+-------------------------------------+
c	|               rkmr2                 |
c	+-------------------------------------+
c	|               rkmr3                 |
c	+-------------------------------------+
c	|         uba datapath number         |
c	+-------------------------------------+
c	|        uba datapath register        |
c	+-------------------------------------+
c	|      uba final mapping register     |
c	+-------------------------------------+
c	|     uba previous mapping register   |
c	+-------------------------------------+
c
c	Modified by:
c
c	v02-005	BP0005		Brian Porter,		23-NOV-1981
c		minor edit.
c
c	v02-004	BP0004		Brian Porter,		03-NOV-1981
c		Added device attention support.
c
c	v02-003	BP0003		Brian Porter,		30-SEP-1981
c		Corrected call to uba_mapping.
c
c	v02-002	BP0002		Brian Porter,		23-JUL-1981
c		Added new uba handling routines.
c
c	v02-001	BP0001		Brian Porter,		29-JUN-1981
c		Made the default register output 16-bit.  Added call
c		to new DHEAD and LOGGER modules.  Removed call to
c		UNUSED_BITS, ILLEGAL_BITS and REGCHK.
c**
c--

	INCLUDE 'SRC$:MSGHDR.FOR /NOLIST'

	INCLUDE 'SRC$:DEVERR.FOR /NOLIST'


	BYTE		LUN

	INTEGER*4	RKCS1
	INTEGER*4	RKWC
	INTEGER*4	RKBA
	INTEGER*4	RKDA
	INTEGER*4	RKCS2
	INTEGER*4	RKDS
	INTEGER*4	RKER
	INTEGER*4	RKAS
	INTEGER*4	RKDC
	INTEGER*4	RKMR1
	INTEGER*4	RKEC1
	INTEGER*4	RKEC2
	INTEGER*4	RKMR2
	INTEGER*4	RKMR3

	INTEGER*4	UBA_REGS(4)

	INTEGER*4	FIELD
	INTEGER*4	DRIVE_FUNC

	INTEGER*4	COMPRESSC

	INTEGER*4	COMPRESS4

	logical*1	diagnostic_mode

	PARAMETER	TIMEOUT  = 96
	PARAMETER	XFER_ERR = 32
	PARAMETER	XFER_CMD = 8
	PARAMETER	RK06     = 1
	PARAMETER	RK07     = 2
	PARAMETER	SEEK	 = 7

	CHARACTER*17	RK_FUNC(0:15)
	CHARACTER*5	RK06_OFFSET(1:5)
	CHARACTER*5	RK07_OFFSET(1:5)
	CHARACTER*8	OFFSET_DIR(0:1)
	CHARACTER*4	REG_HERALD(0:11)
	CHARACTER*7	RKCS1_1(0:0)
	CHARACTER*28	RKCS1_2(5:9)
	CHARACTER*5	RKCS1_10(0:1)
	CHARACTER*20	RKCS1_3(11:11)
	CHARACTER*14	RK_FORMAT(0:1)
	CHARACTER*33	RKCS1_4(13:15)
	CHARACTER*30	RKCS2_1(3:15)
	CHARACTER*16	RKDS_1(0:0)
	CHARACTER*16	RKDS_2(2:7)
	CHARACTER*14	RK_DRIVETYPE(0:1)
	CHARACTER*16	RKDS_3(11:11)
	CHARACTER*24	RKDS_4(13:15)
	CHARACTER*33	RKER_1(0:15)

	CHARACTER*21	V1RKMR2(4:15)

	CHARACTER*29	V1RKMR3(4:15)

	EQUIVALENCE	(RKCS1,EMB$L_DV_REGSAV(0))
	EQUIVALENCE	(RKWC,EMB$L_DV_REGSAV(1))
	EQUIVALENCE	(RKBA,EMB$L_DV_REGSAV(2))
	EQUIVALENCE	(RKDA,EMB$L_DV_REGSAV(3))
	EQUIVALENCE	(RKCS2,EMB$L_DV_REGSAV(4))
	EQUIVALENCE	(RKDS,EMB$L_DV_REGSAV(5))
	EQUIVALENCE	(RKER,EMB$L_DV_REGSAV(6))
	EQUIVALENCE	(RKAS,EMB$L_DV_REGSAV(7))
	EQUIVALENCE	(RKDC,EMB$L_DV_REGSAV(8))
	EQUIVALENCE	(RKMR1,EMB$L_DV_REGSAV(9))
	EQUIVALENCE	(RKEC1,EMB$L_DV_REGSAV(10))
	EQUIVALENCE	(RKEC2,EMB$L_DV_REGSAV(11))
	EQUIVALENCE	(RKMR2,EMB$L_DV_REGSAV(12))
	EQUIVALENCE	(RKMR3,EMB$L_DV_REGSAV(13))

	EQUIVALENCE	(UBA_REGS,EMB$L_DV_REGSAV(14))





	DATA	OFFSET_DIR(0)	/'FORWARD*'/

	DATA	OFFSET_DIR(1)	/'REVERSE*'/




	DATA	RK06_OFFSET(1)	/'25*'/

	DATA	RK06_OFFSET(2)	/'200*'/

	DATA	RK06_OFFSET(3)	/'400*'/

	DATA	RK06_OFFSET(4)	/'800*'/

	DATA	RK06_OFFSET(5)	/'1200*'/




	DATA	RK07_OFFSET(1)	/'12.5*'/

	DATA	RK07_OFFSET(2)	/'100*'/

	DATA	RK07_OFFSET(3)	/'200*'/

	DATA	RK07_OFFSET(4)	/'400*'/

	DATA	RK07_OFFSET(5)	/'600*'/




	DATA	RK_FUNC(0)	/'SELECT DRIVE*'/

	DATA	RK_FUNC(1)	/'PACK ACKNOWLEDGE*'/

	DATA	RK_FUNC(2)	/'DRIVE_CLEAR*'/

	DATA	RK_FUNC(3)	/'UNLOAD*'/

	DATA	RK_FUNC(4)	/'START SPINDLE*'/

	DATA	RK_FUNC(5)	/'RECALIBRATE*'/

	DATA	RK_FUNC(6)	/'OFFSET*'/

	DATA	RK_FUNC(7)	/'SEEK*'/

	DATA	RK_FUNC(8)	/'READ DATA*'/

	DATA	RK_FUNC(9)	/'WRITE DATA*'/

	DATA	RK_FUNC(10)	/'READ HEADER*'/

	DATA	RK_FUNC(11)	/'WRITE HEADER*'/

	DATA	RK_FUNC(12)	/'WRITE CHECK*'/

	DATA	RK_FUNC(13)	/'ILLEGAL FUNCTION*'/

	DATA	RK_FUNC(14)	/'ILLEGAL FUNCTION*'/

	DATA	RK_FUNC(15)	/'ILLEGAL FUNCTION*'/




	DATA	RKCS1_1(0)	/'GO BIT*'/





	DATA	RKCS1_2(5)	/'TRANSFER ERROR (VMS)*'/

	DATA	RKCS1_2(6)	/'INTERRUPT ENABLE*'/

	DATA	RKCS1_2(7)	/'CONTROLLER READY*'/

	DATA	RKCS1_2(8)	/'EXTENDED BUS ADDRESS BIT 16*'/

	DATA	RKCS1_2(9)	/'EXTENDED BUS ADDRESS BIT 17*'/




	DATA	RKCS1_10(0)	/'RK06*'/

	DATA	RKCS1_10(1)	/'RK07*'/




	DATA	RKCS1_3(11)	/'CONTROLLER TIME-OUT*'/




	DATA	RK_FORMAT(0)	/'16-BIT FORMAT*'/

	DATA	RK_FORMAT(1)	/'18-BIT FORMAT*'/





	DATA	RKCS1_4(13)	/'DRIVE-TO-CONTROLLER PARITY ERROR*'/

	DATA	RKCS1_4(14)	/'DRIVE INTERRUPT*'/

	DATA	RKCS1_4(15)	/'COMBINED ERROR*'/





	DATA	RKCS2_1(3)	/'RELEASE*'/

	DATA	RKCS2_1(4)	/'BUS ADDRESS INCREMENT INHIBIT*'/

	DATA	RKCS2_1(5)	/'SUBSYSTEM CLEAR*'/

	DATA	RKCS2_1(6)	/'INPUT READY*'/

	DATA	RKCS2_1(7)	/'OUTPUT READY*'/

	DATA	RKCS2_1(8)	/'UNIT FIELD ERROR*'/

	DATA	RKCS2_1(9)	/'MULTIPLE DRIVE SELECT*'/

	DATA	RKCS2_1(10)	/'PROGRAMMING ERROR*'/

	DATA	RKCS2_1(11)	/'NON-EXISTENT MEMORY*'/

	DATA	RKCS2_1(12)	/'NON-EXISTENT DRIVE*'/

	DATA	RKCS2_1(13)	/'UNIBUS PARITY ERROR*'/

	DATA	RKCS2_1(14)	/'WRITE CHECK ERROR*'/

	DATA	RKCS2_1(15)	/'DATA LATE ERROR*'/




	DATA	RKDS_1(0)	/'DRIVE AVAILABLE*'/





	DATA	RKDS_2(2)	/'OFFSET MODE*'/

	DATA	RKDS_2(3)	/'DRIVE AC LO*'/

	DATA	RKDS_2(4)	/'SPEED LOSS*'/

	DATA	RKDS_2(5)	/'DRIVE OFF TRACK*'/

	DATA	RKDS_2(6)	/'VOLUME VALID*'/

	DATA	RKDS_2(7)	/'DRIVE READY*'/




	DATA	RK_DRIVETYPE(0)	/'DRIVE IS RK06*'/

	DATA	RK_DRIVETYPE(1)	/'DRIVE IS RK07*'/






	DATA	RKDS_3(11)	/'WRITE PROTECTED*'/





	DATA	RKDS_4(13)	/'POSITIONING IN PROGRESS*'/

	DATA	RKDS_4(14)	/'CURRENT DRIVE ATTENTION*'/

	DATA	RKDS_4(15)	/'STATUS VALID*'/






	DATA	RKER_1(0)	/'ILLEGAL FUNCTION*'/

	DATA	RKER_1(1)	/'SEEK INCOMPLETE*'/

	DATA	RKER_1(2)	/'NON-EXECUTABLE FUNCTION*'/

	DATA	RKER_1(3)	/'CONTROLLER-TO-DRIVE PARITY ERROR*'/

	DATA	RKER_1(4)	/'FORMAT ERROR*'/

	DATA	RKER_1(5)	/'DRIVE TYPE ERROR*'/

	DATA	RKER_1(6)	/'ERROR CORRECTION HARD*'/

	DATA	RKER_1(7)	/'BAD SECTOR ERROR*'/

	DATA	RKER_1(8)	/'HEADER VERTICAL CHECK ERROR*'/

	DATA	RKER_1(9)	/'CYLINDER OVERFLOW ERROR*'/

	DATA	RKER_1(10)	/'INVALID DISK ADDRESS ERROR*'/

	DATA	RKER_1(11)	/'WRITE LOCK ERROR*'/

	DATA	RKER_1(12)	/'DRIVE TIMING ERROR*'/

	DATA	RKER_1(13)	/'OPERATION INCOMPLETE*'/

	DATA	RKER_1(14)	/'DRIVE UNSAFE*'/

	DATA	RKER_1(15)	/'DATA CHECK*'/




	DATA	V1RKMR2(4)	/'SERVO SIGNAL PRESENT*'/

	DATA	V1RKMR2(5)	/'HEADS HOME*'/

	DATA	V1RKMR2(6)	/'BRUSHES HOME*'/

	DATA	V1RKMR2(7)	/'DOOR LATCHED*'/

	DATA	V1RKMR2(8)	/'CARTRIDGE PRESENT*'/

	DATA	V1RKMR2(9)	/'SPEED OK*'/

	DATA	V1RKMR2(10)	/'FORWARD*'/

	DATA	V1RKMR2(11)	/'REVERSE*'/

	DATA	V1RKMR2(12)	/'HEADS LOADING*'/

	DATA	V1RKMR2(13)	/'RETURN TO ZERO*'/

	DATA	V1RKMR2(14)	/'UNLOADING HEADS*'/

	DATA	V1RKMR2(15)	/'ODD PARITY BIT*'/



	DATA	V1RKMR3(4)	/'SECTOR ERROR*'/

	DATA	V1RKMR3(5)	/'WRITE CURRENT, NO WRITE GATE*'/

	DATA	V1RKMR3(6)	/'WRITE GATE, NO TRANSITIONS*'/

	DATA	V1RKMR3(7)	/'HEAD FAULT*'/

	DATA	V1RKMR3(8)	/'MULTIPLE HEAD SELECT*'/

	DATA	V1RKMR3(9)	/'INDEX ERROR*'/

	DATA	V1RKMR3(10)	/'TRIBIT ERROR*'/

	DATA	V1RKMR3(11)	/'SERVO SIGNAL ERROR*'/

	DATA	V1RKMR3(12)	/'SEEK AND NO MOTION*'/

	DATA	V1RKMR3(13)	/'LIMIT DETECT ON SEEK*'/

	DATA	V1RKMR3(14)	/'SERVO UNSAFE*'/

	DATA	V1RKMR3(15)	/'ODD PARITY BIT*'/



	DATA	REG_HERALD(0)	/'CS1*'/

	DATA	REG_HERALD(1)	/'WC*'/

	DATA	REG_HERALD(2)	/'BA*'/

	DATA	REG_HERALD(3)	/'DA*'/

	DATA	REG_HERALD(4)	/'CS2*'/

	DATA	REG_HERALD(5)	/'DS*'/

	DATA	REG_HERALD(6)	/'ER*'/

	DATA	REG_HERALD(7)	/'AS*'/

	DATA	REG_HERALD(8)	/'DC*'/

	DATA	REG_HERALD(9)	/'MR*'/

	DATA	REG_HERALD(10)	/'EC1*'/

	DATA	REG_HERALD(11)	/'EC2*'/







	CALL FRCTOF (LUN)

	call dhead1 (lun,'UBA RK611')

	diagnostic_mode = .false.

	if (lib$extzv(5,1,rkmr1) .eq. 1) diagnostic_mode = .true.

	call linchk (lun,2)

	write(lun,20) rkcs1
20	format('0',T8,'RKCS1',t24,z8.4)

	if (.not. diagnostic_mode) then

	CALL OUTPUT (LUN,RKCS1,RKCS1_1,0,0,0,'0')

	DRIVE_FUNC=LIB$EXTZV(1,4,RKCS1)

	CALL LINCHK (LUN,1)

	WRITE(LUN,30) RK_FUNC(DRIVE_FUNC)
30	FORMAT(' ',T40,A<COMPRESSC (RK_FUNC(DRIVE_FUNC))>)

	CALL OUTPUT (LUN,RKCS1,RKCS1_2,5,5,9,'0')

	FIELD=LIB$EXTZV(10,1,RKCS1)

	CALL LINCHK (LUN,1)

	WRITE(LUN,40) RKCS1_10(FIELD)
40	FORMAT(' ',T40,'CONTROLLER DRIVE TYPE ',
	1 A<COMPRESSC (RKCS1_10(FIELD))>)

	CALL OUTPUT (LUN,RKCS1,RKCS1_3,11,11,11,'0')

	FIELD=LIB$EXTZV(12,1,RKCS1)

	CALL LINCHK (LUN,1)

	WRITE(LUN,44) RK_FORMAT(FIELD)
44	FORMAT(' ',T40,A<COMPRESSC (RK_FORMAT(FIELD))>)

	CALL OUTPUT (LUN,RKCS1,RKCS1_4,13,13,15,'0')
	endif

	CALL LINCHK (LUN,1)

	WRITE(LUN,50) RKWC
50	FORMAT(' ',T8,'RKWC',T24,Z8.4)

	CALL LINCHK (LUN,1)

	WRITE(LUN,60) RKBA
60	FORMAT(' ',T8,'RKBA',T24,Z8.4)

	if (.not. diagnostic_mode) then

	IF (DRIVE_FUNC .GE. XFER_CMD) THEN

	CALL CALC_MAP (LUN,8,RKCS1,RKBA)
	ENDIF
	endif

	CALL LINCHK (LUN,1)

	WRITE(LUN,70) RKDA
70	FORMAT(' ',T8,'RKDA',T24,Z8.4)

	if (.not. diagnostic_mode) then

	CALL LINCHK (LUN,2)

	FIELD=LIB$EXTZV(0,5,RKDA)

	WRITE(LUN,80) FIELD
80	FORMAT(' ',T40,'SECTOR = ',I<COMPRESS4 (FIELD)>,'.')

	FIELD=LIB$EXTZV(8,3,RKDA)

	WRITE(LUN,90) FIELD
90	FORMAT(' ',T40,'TRACK  = ',I<COMPRESS4 (FIELD)>,'.')
	endif

	CALL LINCHK (LUN,1)

	WRITE(LUN,100) RKCS2
100	FORMAT(' ',T8,'RKCS2',T24,Z8.4)

	if (.not. diagnostic_mode) then

	CALL LINCHK (LUN,1)

	FIELD=LIB$EXTZV(0,3,RKCS2)

	WRITE(LUN,110) FIELD
110	FORMAT(' ',T40,'SELECTED DRIVE = ',I1,'.')

	CALL OUTPUT (LUN,RKCS2,RKCS2_1,3,3,15,'0')
	endif

	CALL LINCHK (LUN,1)

	WRITE(LUN,120) RKDS
120	FORMAT(' ',T8,'RKDS',T24,Z8.4)

	if (.not. diagnostic_mode) then

	CALL OUTPUT (LUN,RKDS,RKDS_1,0,0,0,'0')

	CALL OUTPUT (LUN,RKDS,RKDS_2,2,2,7,'0')

	CALL LINCHK (LUN,1)

	FIELD=LIB$EXTZV(8,1,RKDS)

	WRITE(LUN,130) RK_DRIVETYPE(FIELD)
130	FORMAT(' ',T40,A<COMPRESSC (RK_DRIVETYPE(FIELD))>)

	CALL OUTPUT (LUN,RKDS,RKDS_3,11,11,11,'0')

	CALL OUTPUT (LUN,RKDS,RKDS_4,13,13,15,'0')
	endif

	CALL LINCHK (LUN,1)

	WRITE(LUN,140) RKER
140	FORMAT(' ',T8,'RKER',T24,Z8.4)

	if (.not. diagnostic_mode) then

	IF (JIAND(RKDS,'8000'X) .NE. 0) THEN

	CALL OUTPUT (LUN,RKER,RKER_1,0,0,15,'0')
	ENDIF
	endif

	CALL LINCHK (LUN,1)

	WRITE(LUN,150) RKAS
150	FORMAT(' ',T8,'RKAS/OF',T24,Z8.4)

	if (.not. diagnostic_mode) then

	FIELD=LIB$EXTZV(0,6,RKAS)

	IF (FIELD .NE. 0) THEN

	CALL LINCHK (LUN,1)

	IF (FIELD .NE. 1 .AND.
	1   FIELD .NE. 8 .AND.
	2   FIELD .NE. 16 .AND.
	3   FIELD .NE. 32 .AND.
	4   FIELD .NE. 48) THEN

	WRITE(LUN,155)
155	FORMAT(' ',T40,'INVALID OFFSET')

	GOTO 185

	ELSE IF (EMB$B_DV_TYPE .EQ. RK06) THEN

	FIELD=FIELD/8

	WRITE(LUN,160) RK06_OFFSET(FIELD)
160	FORMAT(' ',T40,'OFFSET = ',
	1 A<COMPRESSC (RK06_OFFSET(FIELD))>,' MICRO INCHES')

	ELSE IF (EMB$B_DV_TYPE .EQ. RK07) THEN

	FIELD=FIELD/8

	WRITE(LUN,165) RK07_OFFSET(FIELD)
165	FORMAT(' ',T40,'OFFSET = ',
	1 A<COMPRESSC (RK07_OFFSET(FIELD))>,' MICRO INCHES')
	ENDIF

	FIELD=LIB$EXTZV(7,1,RKAS)

	CALL LINCHK (LUN,1)

	WRITE(LUN,170) OFFSET_DIR(FIELD)
170	FORMAT(' ',T40,'OFFSET DIRECTION = ',
	1 A<COMPRESSC (OFFSET_DIR(FIELD))>)
	ENDIF

185	DO 195 I=8,15

	FIELD=LIB$EXTZV(I,1,RKAS)

	IF (FIELD .NE. 0) THEN

	CALL LINCHK (LUN,1)

	WRITE(LUN,190) (I-8)
190	FORMAT(' ',T40,'ATTENTION DRIVE ',I1,'.')
	ENDIF

195	CONTINUE
	endif

	CALL LINCHK (LUN,1)

	WRITE(LUN,200) RKDC
200	FORMAT(' ',T8,'RKDC',T24,Z8.4)

	if (.not. diagnostic_mode) then

	FIELD=LIB$EXTZV(0,10,RKDC)

	IF (FIELD .NE. 0) THEN

	CALL LINCHK (LUN,1)

	WRITE(LUN,210) FIELD
210	FORMAT(' ',T40,'DESIRED CYLINDER = ',I<COMPRESS4 (FIELD)>,'.')
	ENDIF
	endif

	CALL LINCHK (LUN,1)

	WRITE(LUN,230) RKMR1
230	FORMAT(' ',T8,'RKMR1',T24,Z8.4)

	if (diagnostic_mode) then

	call linchk (lun,1)

	WRITE(LUN,235)
235	FORMAT(' ',T40,'DIAGNOSTIC MODE')
	endif

	CALL LINCHK (LUN,1)

	WRITE(LUN,240) RKEC1
240	FORMAT(' ',T8,'RKEC1',T24,Z8.4)

	CALL LINCHK (LUN,1)

	WRITE(LUN,250) RKEC2
250	FORMAT(' ',T8,'RKEC2',T24,Z8.4)

	CALL LINCHK (LUN,1)

	WRITE(LUN,260) RKMR2
260	FORMAT(' ',T8,'RKMR2',T24,Z8.4)

	if (.not. diagnostic_mode) then

	IF ((JIAND(RKMR1,'01'X) .NE. 0)
	1 .AND.
	2 (EMB$W_HD_ENTRY .EQ. TIMEOUT)
	3 .AND.
	4 (JIAND(RKMR3,'01'X) .NE. 0)) THEN

	CALL LINCHK (LUN,1)

	WRITE(LUN,261)
261	FORMAT(' ',T40,'*** MESSAGE A1 ***')

	FIELD = LIB$EXTZV(0,3,RKMR2)

	CALL LINCHK (LUN,1)

	WRITE(LUN,262) FIELD
262	FORMAT(' ',T40,'SELECTED DRIVE = ',I<COMPRESS4 (FIELD)>,'.')

	CALL OUTPUT (LUN,RKMR2,V1RKMR2,4,4,15,'0')
	ENDIF
	endif

	CALL LINCHK (LUN,1)

	WRITE(LUN,270) RKMR3
270	FORMAT(' ',T8,'RKMR3',T24,Z8.4)

	if (.not. diagnostic_mode) then

	IF ((JIAND(RKMR1,'01'X) .NE. 0)
	1 .AND.
	2 (EMB$W_HD_ENTRY .EQ. TIMEOUT)
	3 .AND.
	4 (JIAND(RKMR3,'01'X) .NE. 0)
	5 .AND.
	6 (JIAND(RKMR3,'FFFC'X) .NE.0)) THEN

	CALL LINCHK (LUN,1)

	WRITE(LUN,272)
272	FORMAT(' ',T40,'*** MESSAGE B1 ***')

	CALL OUTPUT (LUN,RKMR3,V1RKMR3,4,4,15,'0')
	ENDIF
	endif

	if (
	1 drive_func .ge. xfer_cmd
	1 .and.
	1 emb$w_hd_entry .ne. 96
	1 .and.
	1 emb$w_hd_entry .ne. 98
	1 ) then

	if (uba_regs(1)  .ne. 0) then

	call uba_datapath (lun,uba_regs(1),uba_regs(2))
	endif

	call calc_map2 (8,rkcs1,rkba,field)

	call uba_mapping (lun,field,uba_regs(3))

	if (
	1 lib$extzv(16,16,emb$l_dv_iosb1) .gt. 512
	1 .and.
	1 field .ne. 0
	1 ) then

	call uba_mapping (lun,(field-1),uba_regs(4))
	endif
	endif

	call linchk (lun,1)

	write(lun,275)
275	format(' ',:)

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

	write(lun,275)

	call rkdisk_qio (lun,emb$w_dv_func)

	call irp$w_bcnt (lun,emb$w_dv_bcnt)

	call irp$w_boff (lun,emb$w_dv_boff)

	call irp$l_pid (lun,emb$l_dv_rqpid)

	call irp$q_iosb (lun,emb$l_dv_iosb1)
	endif

	RETURN




	ENTRY	B_RKDISK (LUN)



	call dhead1 (lun,'UBA RK611')

	CALL BRIEF16 (LUN,12,RKCS1,REG_HERALD,EMB$T_DV_NAME,EMB$W_DV_UNIT)

	RETURN




	ENTRY	C_RKDISK (LUN)




	CALL CRYPTK (LUN,16,12,RKCS1,REG_HERALD,EMB$T_DV_NAME,EMB$W_DV_UNIT)
 
	RETURN

	END




	subroutine rkdisk_qio (lun,emb$w_dv_func)




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

	qiocode(1,10) = %loc(io$_writecheck)

	qiocode(1,11) = %loc(io$_writepblk)

	qiocode(1,12) = %loc(io$_readpblk)

	qiocode(1,13) = %loc(io$_writehead)

	qiocode(1,14) = %loc(io$_readhead)

	qiocode(1,25) = %loc(io$_startspndl)

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

	do  10,i = 0,63

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
