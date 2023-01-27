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
	SUBROUTINE DR11W (LUN)
C
C	AUTHOR	BRIAN PORTER		CREATION DATE	17-SEP-1979
C

C++
C	Functional description:
C
C	This module displays entries made for the dr11w.
C
C	Modified by:
C
C	v03-001	BP0006		Brian Porter,		09-MAR-1982
C		Corrected output conversion error bug.
C**
C--

	INCLUDE 'SRC$:MSGHDR.FOR /NOLIST'

	INCLUDE 'SRC$:DEVERR.FOR /NOLIST'



	BYTE		LUN

	INTEGER*4	FIELD

	INTEGER*4	DRCSR

	INTEGER*4	DREIR

	INTEGER*4	DRIDR

	INTEGER*4	DRBA

	INTEGER*4	DRWC

	INTEGER*4	UBA_REGS(4)

	integer*4	compress4

	logical*1	diagnostic_mode

	EQUIVALENCE	(DRCSR,EMB$L_DV_REGSAV(2))

	EQUIVALENCE	(DREIR,EMB$L_DV_REGSAV(3))

	EQUIVALENCE	(DRIDR,EMB$L_DV_REGSAV(4))

	EQUIVALENCE	(DRBA,EMB$L_DV_REGSAV(5))

	EQUIVALENCE	(DRWC,EMB$L_DV_REGSAV(6))

	EQUIVALENCE	(UBA_REGS,EMB$L_DV_REGSAV(7))

	PARAMETER	TIMEOUT = 96

	CHARACTER*7	V1DRCSR(0:0)

	CHARACTER*17	V2DRCSR(6:8)

	CHARACTER*20	V3DRCSR(13:15)

	CHARACTER*14	V1DREIR(0:0)

	CHARACTER*24	V2DREIR(8:15)

	CHARACTER*1	USER_STATUS(0:2)

	CHARACTER*4	REG_HERALD(0:4)

	EQUIVALENCE	(V3DRCSR(13),V2DREIR(13))




	DATA	V1DRCSR(0)	/'GO BIT*'/



	DATA	V2DRCSR(6)	/'INTERRUPT ENABLE*'/

	DATA	V2DRCSR(7)	/'CONTROLLER READY*'/

	DATA	V2DRCSR(8)	/'DMA CYCLE*'/



	DATA	V3DRCSR(13)	/'USER ATTENTION*'/

	DATA	V3DRCSR(14)	/'NON-EXISTENT MEMORY*'/

	DATA	V3DRCSR(15)	/'ERROR*'/



	DATA	V1DREIR(0)	/'READING ''EIR''*'/



	DATA	V2DREIR(8)	/'DMA BURST MODE SELECTED*'/

	DATA	V2DREIR(9)	/'DMA BURST USER TIMEOUT*'/

	DATA	V2DREIR(10)	/'MEMORY PARITY ERROR*'/

	DATA	V2DREIR(11)	/'AC LO*'/

	DATA	V2DREIR(12)	/'MULTI-CYCLE REQUEST*'/




	DATA	USER_STATUS(0)	/'A'/

	DATA	USER_STATUS(1)	/'B'/

	DATA	USER_STATUS(2)	/'C'/




	DATA	REG_HERALD(0)	/'CSR*'/

	DATA	REG_HERALD(1)	/'EIR*'/

	DATA	REG_HERALD(2)	/'IDR*'/

	DATA	REG_HERALD(3)	/'BA*'/

	DATA	REG_HERALD(4)	/'WC*'/




	CALL FRCTOF (LUN)

	call dhead1 (lun,'UBA DR11W')

	diagnostic_mode = .false.

	if (lib$extzv(12,1,drcsr) .eq. 1) diagnostic_mode = .true.

	CALL LINCHK (LUN,2)

	WRITE(LUN,10) DRCSR
10	FORMAT('0',t8,'DRCSR',T24,Z8.4)

	if (.not. diagnostic_mode) then

	CALL OUTPUT (LUN,DRCSR,V1DRCSR,0,0,0,'0')

	FIELD = LIB$EXTZV(1,3,DRCSR)

	CALL LINCHK (LUN,1)

	WRITE(LUN,25) FIELD
25	format(' ',t40,'USER FUNCTION = ',i<compress4 (field)>,'.')

	DO 35,I = 4,5

	FIELD = LIB$EXTZV(I,1,DRCSR)

	IF (FIELD .NE. 0) THEN

	CALL LINCHK (LUN,1)

	WRITE(LUN,30) I+12
30	format(' ',t40,'EXTENDED BUS ADDRESS BIT ',i<compress4 (i+12)>,'.')
	ENDIF

35	CONTINUE

	CALL OUTPUT (LUN,DRCSR,V2DRCSR,6,6,8,'0')

	DO 45,I = 9,11

	FIELD = LIB$EXTZV(I,1,DRCSR)

	IF (FIELD .NE. 0) THEN

	CALL LINCHK (LUN,1)

	WRITE(LUN,40) USER_STATUS(FIELD),I
40	format(' ',t40,'USER STATUS ',a1,' (BIT ',i<compress4 (i)>,'.) SET')
	ENDIF

45	CONTINUE

	CALL OUTPUT (LUN,DRCSR,V3DRSCR,13,13,15,'0')
	else

	CALL LINCHK (LUN,1)

	WRITE(LUN,15)
15	FORMAT(' ',T40,'DIAGNOSTIC MODE')
	endif

	CALL LINCHK (LUN,1)

	WRITE(LUN,50) DREIR
50	FORMAT(' ',T8,'DREIR',T24,Z8.4)

	if (.not. diagnostic_mode) then

	CALL OUTPUT (LUN,DREIR,V1DREIR,0,0,0,'0')

	CALL OUTPUT (LUN,DREIR,V2DREIR,8,8,15,'0')
	endif

	CALL LINCHK (LUN,1)

	WRITE(LUN,55) DRIDR
55	FORMAT(' ',T8,'DRIDR',T24,Z8.4)

	CALL LINCHK (LUN,1)

	WRITE(LUN,60) DRBA
60	FORMAT(' ',T8,'DRBA',T24,Z8.4)

	if (.not. diagnostic_mode) then

	CALL CALC_MAP (LUN,4,DRCSR,DRBA)
	endif

	CALL LINCHK (LUN,1)

	WRITE(LUN,75) DRWC
75	FORMAT(' ',T8,'DRWC',T24,Z8.4)

	if (
	1 emb$w_hd_entry .ne. 96
	1 .or.
	1 emb$w_hd_entry .ne. 98
	1 ) then

	IF (IAND(EMB$W_DV_FUNC,'0040'X) .EQ. 0) THEN

	if (uba_regs(1) .ne. 0) then

	call uba_datapath (lun,uba_regs(1),uba_regs(2))
	endif

	call calc_map2 (4,drcsr,drba,field)

	call uba_mapping (lun,field,uba_regs(3))

	if (
	1 lib$extzv (16,16,emb$l_dv_iosb1) .gt. 512
	1 .and.
	1 field .ne. 0
	1 ) then

	call uba_mapping (lun,(field-1),uba_regs(4))
	endif
	ENDIF
	endif

	call linchk (lun,1)

	write(lun,80)
80	format(' ',:)

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

	write(lun,80)

	call dr11w_qio (lun,emb$w_dv_func)

	call irp$w_bcnt (lun,emb$w_dv_bcnt)

	call irp$w_boff (lun,emb$w_dv_boff)

	call irp$l_pid (lun,emb$l_dv_rqpid)

	call irp$q_iosb (lun,emb$l_dv_iosb1)
	endif

	RETURN




	ENTRY B_DR11W (LUN)



	call dhead1 (lun,'UBA DR11W')

	CALL BRIEF16 (LUN,5,DRCSR,REG_HERALD,EMB$T_DV_NAME,EMB$W_DV_UNIT)

	RETURN




	ENTRY C_DR11W (LUN)




	CALL CRYPTK (LUN,16,5,DRCSR,REG_HERALD,EMB$T_DV_NAME,EMB$W_DV_UNIT)

	RETURN

	END



	subroutine dr11w_qio (lun,emb$w_dv_func)



	include 'src$:qiocommon.for /nolist'



	byte		lun

	integer*2	emb$w_dv_func

	integer*4	qiocode(0:1,0:63)




	if (qiocode(0,0) .eq. 0) then

	qiocode(1,11) = %loc(io$_writepblk)

	qiocode(1,12) = %loc(io$_readpblk)

	qiocode(1,26) = %loc(io$_setchar)

	qiocode(1,27) = %loc(io$_sensechar)

	qiocode(1,32) = %loc(io$_writelblk)

	qiocode(1,35) = %loc(io$_setmode)

	qiocode(1,39) = %loc(io$_sensemode)

	qiocode(1,48) = %loc(io$_writevblk)

	qiocode(1,49) = %loc(io$_readvblk)

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
