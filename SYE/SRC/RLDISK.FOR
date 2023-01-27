	SUBROUTINE RLDISK (LUN)
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
C	AUTHOR:	BRIAN PORTER		CREATION DATE:5-FEB-1979
C

C++
C	Functional description:
C
C	This module displays entries made for the rl11 controller.
C
C	Modified by:
C
C	v02-006	BP0006		Brian Porter,		23-NOV-1981
C		Minor edit.
C
C	v02-005	BP0005		Brian Porter,		05-NOV-1981
C		Added 'device attention' support.
C
C	v02-004	BP0004		Brian Porter,		30-SEP-1981
C		Corrected call to uba_mapping.
C
C	v02-003	BP0003		Brian Porter,		23-JUL-1981
C		Added different uba handling.
C
C	v02-002	BP0002		Brian Porter,		29-JUN-1981
C		Removed call to UNUSED_BITS.  Added call to DHEAD and
C		LOGGER.  Removed call to ILLEGAL_BITS.
C
C	v02-001	BP0001		Brian Porter,		17-JUN-1980
C		Fixed problem of reset bit being set.
C**
C--

	INCLUDE 'SRC$:MSGHDR.FOR /NOLIST'

	INCLUDE	'SRC$:DEVERR.FOR /NOLIST'

	INTEGER*4	RLCS
	INTEGER*4	RLBA
	INTEGER*4	RLDA
	INTEGER*4	RLMP

	INTEGER*4	UBA_REGS(4)

	INTEGER*4	FIELD
	INTEGER*4	FIELD1
	INTEGER*4	FIELD2

	INTEGER*4	COMPRESS4

	INTEGER*4	COMPRESSC

	BYTE		DRIVE_FUNC
	BYTE		LUN

	EQUIVALENCE	(RLCS,EMB$L_DV_REGSAV(0))
	EQUIVALENCE	(RLBA,EMB$L_DV_REGSAV(1))
	EQUIVALENCE	(RLDA,EMB$L_DV_REGSAV(2))
	EQUIVALENCE	(RLMP,EMB$L_DV_REGSAV(3))
	EQUIVALENCE	(UBA_REGS,EMB$L_DV_REGSAV(4))


	PARAMETER	NO_OPERATION	= 0
	PARAMETER	XFER_ERR	= 1
	PARAMETER	WRITE_CHECK	= 1
	PARAMETER	GET_STATUS	= 2
	PARAMETER	SEEK		= 3
	PARAMETER	READ_HEADER	= 4
	PARAMETER	WRITE_DATA	= 5
	PARAMETER	READ_DATA	= 6

	PARAMETER	TIMEOUT		= 96

	CHARACTER*12	V1RL_CS(0:0)
	CHARACTER*17	V2RL_CS(6:7)
	CHARACTER*21	V3RL_CS(10:10)
	CHARACTER*20	V4RL_CS(13:15)

	CHARACTER*17	DCRC_HCRC(0:1)
	CHARACTER*22	DLT_HNF(0:1)

	CHARACTER*2	ADDR_EXTN(4:5)

	CHARACTER*23	RL_FUNC(0:7)

	CHARACTER*6	V1RL_DA(3:3)

	CHARACTER*15	V1RL_STATUS(0:7)
	CHARACTER*13	V2RL_STATUS(3:5)
	CHARACTER*19	V3RL_STATUS(8:15)

	CHARACTER*4	DRIVE_TYPE(0:1)

	CHARACTER*7	DIRECTION(0:1)

	CHARACTER*24	HEAD_SELECT(0:1)

	CHARACTER*4	REG_HERALD(0:3)

	CHARACTER*33	MUST_BE




	DATA	V1RL_CS(0)	/'DRIVE READY*'/




	DATA 	V2RL_CS(6)	/'INTERRUPT ENABLE*'/

	DATA	V2RL_CS(7)	/'CONTROLLER READY*'/



	DATA	V3RL_CS(10)	/'OPERATION INCOMPLETE*'/



	DATA	V4RL_CS(13)	/'NON-EXISTENT MEMORY*'/

	DATA	V4RL_CS(14)	/'DRIVE ERROR*'/

	DATA	V4RL_CS(15)	/'COMPOSITE ERROR*'/



	DATA	DCRC_HCRC(0)	/'DATA CRC ERROR*'/

	DATA	DCRC_HCRC(1)	/'HEADER CRC ERROR*'/



	DATA	DLT_HNF(0)	/'DATA LATE ERROR*'/

	DATA	DLT_HNF(1)	/'HEADER NOT FOUND*'/



	DATA	V1RL_DA(3)	/'RESET*'/



	DATA	DIRECTION(0)	/'REVERSE'/

	DATA	DIRECTION(1)	/'FORWARD'/



	DATA	HEAD_SELECT(0)	/'HEAD SELECT = UPPER HEAD'/

	DATA	HEAD_SELECT(1)	/'HEAD SELECT = LOWER HEAD'/




	DATA	ADDR_EXTN(4)	/'16'/

	DATA	ADDR_EXTN(5)	/'17'/



	DATA	V2RL_STATUS(3)	/'BRUSHES HOME*'/

	DATA	V2RL_STATUS(4)	/'HEADS OUT*'/

	DATA	V2RL_STATUS(5)	/'COVER OPEN*'/


	DATA	V3RL_STATUS(8)	/'DRIVE SELECT ERROR*'/

	DATA	V3RL_STATUS(9)	/'VOLUME CHECK*'/

	DATA	V3RL_STATUS(10)	/'WRITE GATE ERROR*'/

	DATA	V3RL_STATUS(11)	/'SPIN ERROR*'/

	DATA	V3RL_STATUS(12)	/'SEEK TIME-OUT*'/

	DATA	V3RL_STATUS(13)	/'WRITE PROTECTED*'/

	DATA	V3RL_STATUS(14)	/'HEAD CURRENT ERROR*'/

	DATA	V3RL_STATUS(15)	/'WRITE DATA ERROR*'/



	DATA	DRIVE_TYPE(0)	/'RL01'/

	DATA	DRIVE_TYPE(1)	/'RL02'/



	DATA	V1RL_STATUS(0)	/'LOAD CARTRIDGE*'/

	DATA	V1RL_STATUS(1)	/'SPIN UP*'/

	DATA	V1RL_STATUS(2)	/'BRUSH CYCLE*'/

	DATA	V1RL_STATUS(3)	/'LOAD HEADS*'/

	DATA	V1RL_STATUS(4)	/'SEEK*'/

	DATA	V1RL_STATUS(5)	/'LOCK ON*'/

	DATA	V1RL_STATUS(6)	/'UNLOAD HEADS*'/

	DATA	V1RL_STATUS(7)	/'SPIN DOWN*'/


	DATA	RL_FUNC(0)	/'NO OPERATION*'/

	DATA	RL_FUNC(1)	/'WRITE CHECK*'/

	DATA	RL_FUNC(2)	/'GET STATUS*'/

	DATA	RL_FUNC(3)	/'SEEK*'/

	DATA	RL_FUNC(4)	/'READ HEADER*'/

	DATA	RL_FUNC(5)	/'WRITE DATA*'/

	DATA	RL_FUNC(6)	/'READ DATA*'/

	DATA	RL_FUNC(7)	/'READ DATA NO HDR CHECK*'/



	DATA	REG_HERALD(0)	/'CS*'/

	DATA	REG_HERALD(1)	/'BA*'/

	DATA	REG_HERALD(2)	/'DA*'/

	DATA	REG_HERALD(3)	/'MP*'/




	DATA	MUST_BE	/'MUST BE SET/CLEAR INCORRECT'/





	CALL FRCTOF (LUN)

	call dhead1 (lun,'UBA RL11')

	CALL LINCHK (LUN,2)

	WRITE(LUN,100) RLCS
100	FORMAT('0',T8,'RLCS',T24,Z8.4)

	CALL OUTPUT (LUN,RLCS,V1RL_CS,0,0,0,'0')

	DRIVE_FUNC = LIB$EXTZV(1,3,RLCS)

	CALL LINCHK (LUN,1)

	WRITE(LUN,125) RL_FUNC(DRIVE_FUNC)
125	FORMAT(' ',T40,'FUNCTION = ',
	1 A<COMPRESSC (RL_FUNC(DRIVE_FUNC))>)

	DO 140,I = 4,5

	FIELD = LIB$EXTZV(I,1,RLCS)

	IF (FIELD .NE. 0) THEN

	CALL LINCHK (LUN,1)

	WRITE(LUN,130) ADDR_EXTN(I)
130	FORMAT(' ',T40,'BUS ADDRESS EXTENSION BIT ',A2,'.')
	ENDIF

140	CONTINUE

	CALL OUTPUT (LUN,RLCS,V2RL_CS,6,6,7,'0')

	CALL LINCHK (LUN,1)

	FIELD = LIB$EXTZV(8,2,RLCS)

	WRITE(LUN,150) FIELD
150	FORMAT(' ',T40,'SELECTED DRIVE = ',I1,'.')

	CALL OUTPUT (LUN,RLCS,V3RL_CS,10,10,10,'0')

	FIELD = LIB$EXTZV(10,1,RLCS)

	FIELD1 = LIB$EXTZV(11,1,RLCS)

	IF (FIELD1 .EQ. 1) THEN

	CALL LINCHK (LUN,1)

	IF (DRIVE_FUNC .NE. WRITE_CHECK) THEN

	WRITE(LUN,160) DCRC_HCRC(FIELD)
160	FORMAT(' ',T40,A<COMPRESSC (DCRC_HCRC(FIELD))>)
	ELSE

	WRITE(LUN,170)
170	FORMAT(' ',T40,'WRITE CHECK ERROR')
	ENDIF
	ENDIF

	FIELD1 = LIB$EXTZV(12,1,RLCS)

	IF (FIELD1 .NE. 0) THEN

	CALL LINCHK (LUN,1)

	WRITE(LUN,180) DLT_HNF(FIELD)
180	FORMAT(' ',T40,A<INDEX(DLT_HNF(FIELD),'*')-1>)
	ENDIF

	CALL OUTPUT (LUN,RLCS,V4RL_CS,13,13,15,'0')

	CALL LINCHK (LUN,1)

	WRITE(LUN,250) RLBA
250	FORMAT(' ',T8,'RLBA',T24,Z8.4)

	IF (DRIVE_FUNC .EQ. WRITE_CHECK
	1 .OR.
	2 DRIVE_FUNC .GE. WRITE_DATA) THEN

	CALL CALC_MAP (LUN,4,RLCS,RLBA)
	ENDIF

	CALL LINCHK (LUN,1)

	WRITE(LUN,275) RLDA
275	FORMAT(' ',T8,'RLDA',T24,Z8.4)

	IF (DRIVE_FUNC .EQ. SEEK) THEN

	IF (JIAND(RLDA,'A'X) .NE. 'A'X
	1 .OR.
	2 JIAND(RLDA,'1'X) .EQ. 0) THEN

	CALL LINCHK (LUN,1)

	WRITE(LUN,280) MUST_BE
280	FORMAT(' ',T40,A33)
	ENDIF

	FIELD = LIB$EXTZV(2,1,RLDA)

	CALL LINCHK (LUN,1)

	WRITE(LUN,285) DIRECTION(FIELD)
285	FORMAT(' ',T40,A7)

	FIELD = LIB$EXTZV(4,1,RLDA)

	CALL LINCHK (LUN,1)

	WRITE(LUN,290) HEAD_SELECT(FIELD)
290	FORMAT(' ',T40,A24)

	FIELD = LIB$EXTZV(7,9,RLDA)

	CALL LINCHK (LUN,1)

	WRITE(LUN,295) FIELD
295	FORMAT(' ',T40,'CYLINDER DIFFERENCE = ',I<COMPRESS4 (FIELD)>,'.')

	ELSE IF (DRIVE_FUNC .EQ. GET_STATUS) THEN

	IF (JIAND(RLDA,'F4'X) .NE. 0
	1 .OR.
	2 JIAND(RLDA,'3'X) .NE. '3'X) THEN

	CALL LINCHK (LUN,1)

	WRITE(LUN,300) MUST_BE
300	FORMAT(' ',T40,A33)
	ENDIF

	CALL OUTPUT (LUN,RLDA,V1RL_DA,3,3,3,'0')

	ELSE IF (DRIVE_FUNC .EQ. WRITE_CHECK
	1 .OR.
	2 DRIVE_FUNC .GE. WRITE_DATA) THEN

	FIELD = LIB$EXTZV(0,6,RLDA)

	CALL LINCHK (LUN,1)

	WRITE(LUN,305) FIELD
305	FORMAT(' ',T40,'SECTOR = ',I<COMPRESS4 (FIELD)>,'.')

	FIELD = LIB$EXTZV(6,1,RLDA)

	CALL LINCHK (LUN,1)

	WRITE(LUN,310) HEAD_SELECT(FIELD)
310	FORMAT(' ',T40,A24)

	FIELD = LIB$EXTZV(7,9,RLDA)

	CALL LINCHK (LUN,1)

	WRITE(LUN,315) FIELD
315	FORMAT(' ',T40,'CYLINDER = ',I<COMPRESS4 (FIELD)>,'.')
	ENDIF

C
C	THE RLMP REGISTER RETURNED TO SYE IS NOT THE CONTENTS AT THE
C	TIME OF THE ERROR.IT IS THE CONTENTS AFTER A GET STATUS
C	COMMAND HAS BEEN EXECUTED ON THE FAILING DRIVE.A GET STATUS
C	IS EXECUTED UNCONDITIONALLY WHEN ANY ERROR IS DETECTED BY
C	THE RL DISK DRIVER.
C

	CALL LINCHK (LUN,2)

	WRITE(LUN,605) RLMP
605	FORMAT(' ',T8,'RLMP',T24,Z8.4,/,T48,'**ERROR STATUS**')

	FIELD = LIB$EXTZV(0,3,RLMP)

	CALL LINCHK (LUN,1)

	WRITE(LUN,615) V1RL_STATUS(FIELD)
615	FORMAT(' ',T40,A<INDEX(V1RL_STATUS(FIELD),'*')-1>)

	CALL OUTPUT (LUN,RLMP,V2RL_STATUS,3,3,5,'0')

	FIELD = LIB$EXTZV(6,1,RLMP)

	CALL LINCHK (LUN,1)

	WRITE(LUN,620) HEAD_SELECT(FIELD)
620	FORMAT(' ',T40,A24)

	FIELD = LIB$EXTZV(7,1,RLMP)

	CALL LINCHK (LUN,1)

	WRITE(LUN,625) DRIVE_TYPE(FIELD)
625	FORMAT(' ',T40,'DRIVE IS ',A4)

	CALL OUTPUT (LUN,RLMP,V3RL_STATUS,8,8,15,'0')

	if (emb$w_entry .ne. 98) then

	IF ((DRIVE_FUNC .EQ. WRITE_CHECK
	1 .OR.
	2 DRIVE_FUNC .GE. WRITE_DATA)
	3 .AND.
	4 EMB$W_HD_ENTRY .NE. TIMEOUT) THEN

	if (uba_regs(1) .ne. 0) then

	call uba_datapath (lun,uba_regs(1),uba_regs(2))
	endif

	call calc_map2 (4,rlcs,rlba,field)

	call uba_mapping (lun,field,uba_regs(3))

	if (
	1 lib$extzv(16,16,emb$l_dv_iosb1) .gt. 512
	1 .and.
	1 field .ne. 0
	1 ) then

	call uba_mapping (lun,(field-1),uba_regs(4))
	endif
	ENDIF
	endif

	call linchk (lun,1)

	write(lun,630)
630	format(' ',:)

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

	write(lun,630)

	call rldisk_qio (lun,emb$w_dv_func)

	call irp$w_bcnt (lun,emb$w_dv_bcnt)

	call irp$w_boff (lun,emb$w_dv_boff)

	call irp$l_pid (lun,emb$l_dv_rqpid)

	call irp$q_iosb (lun,emb$l_dv_iosb1)
	endif

	RETURN



	ENTRY B_RLDISK (LUN)



	call dhead1 (lun,'UBA RL11')

	CALL BRIEF16 (LUN,4,RLCS,REG_HERALD,EMB$T_DV_NAME,EMB$W_DV_UNIT)

	RETURN




	ENTRY	C_RLDISK (LUN)




	CALL CRYPTK (LUN,16,4,RLCS,REG_HERALD,EMB$T_DV_NAME,EMB$W_DV_UNIT)

	RETURN

	END



	subroutine rldisk_qio (lun,emb$w_dv_func)



	include 'src$:qiocommon.for /nolist'



	byte		lun

	integer*2	emb$w_dv_func

	integer*4	qiocode(0:1,0:63)



	if (qiocode(0,0) .eq. 0) then

	qiocode(1,00) = %loc(io$_nop)

	qiocode(1,02) = %loc(io$_seek)

	qiocode(1,04) = %loc(io$_drvclr)

	qiocode(1,08) = %loc(io$_packack)

	qiocode(1,10) = %loc(io$_writecheck)

	qiocode(1,11) = %loc(io$_writepblk)

	qiocode(1,12) = %loc(io$_readpblk)

	qiocode(1,14) = %loc(io$_readhead)

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
