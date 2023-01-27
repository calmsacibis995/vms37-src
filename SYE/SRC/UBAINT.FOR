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
C	AUTHOR	BRIAN PORTER		CREATION DATE	3-FEB-1979
C
C	Functional description:
C
C	This module is called to display UBA interrupts.
C
C	Modified by:
C
C	v02-003	BP0003		Brian Porter,		11-NOV-1981
C		Changed register heralds.  Added dispatching code.
C
C	v02-002	BP0002		Brian Porter,		01-JUL-1981
C		Added call to LOGGER.  Added DIAGNOSTIC_MODE.
C
C	v02-001	BP0001		Brian Porter,		11-FEB-1981
C		Added code to print 32-bit registers.  Removed call to
C		UNUSED_BITS.
C**



	subroutine uba_interrupts (lun,option)



	include 'src$:msghdr.for /nolist'



	byte		lun

	character*1	option



	if (
	1 lib$extzv(24,8,emb$l_hd_sid) .eq. 255
	1 .or.
	1 lib$extzv(24,8,emb$l_hd_sid) .eq. 1
	1 ) then

	if (option .eq. 'S') then

	call dw780_interrupt (lun)

	else if (option .eq. 'B') then

	call b_dw780_interrupt (lun)

	else if (option .eq. 'C') then

	call c_dw780_interrupt (lun)
	endif

c
c	for additional UBA support the ELSE-IF-THEN should be expanded
c	at this point.
c

	endif

	return

	end



	SUBROUTINE DW780_INTERRUPT (LUN)



	INCLUDE 'SRC$:MSGHDR.FOR /NOLIST'



	BYTE		LUN

	INTEGER*4	FIELD

	INTEGER*4	COMPRESS4

	INTEGER*4	UBA_CR

	INTEGER*4	UBA_SR

	INTEGER*4	UBA_DCR

	INTEGER*4	UBA_FMER

	INTEGER*4	UBA_FUBAR

	INTEGER*4	ADAPTER_TR

	INTEGER*4	ERROR_PC

	INTEGER*4	ERROR_PSL

	logical*1	diagnostic_mode

	CHARACTER*31	V1UBACR(0:6)

	CHARACTER*25	V1UBASR(0:10)

	CHARACTER*3	TR

	CHARACTER*6	REG_HERALD(0:5)

	EQUIVALENCE	(EMB(16),UBA_CSR)

	EQUIVALENCE	(EMB(20),UBA_CR)

	EQUIVALENCE	(EMB(24),UBA_SR)

	EQUIVALENCE	(EMB(28),UBA_DCR)

	EQUIVALENCE	(EMB(32),UBA_FMER)

	EQUIVALENCE	(EMB(36),UBA_FUBAR)

	EQUIVALENCE	(EMB(40),ADAPTER_TR)

	EQUIVALENCE	(EMB(44),ERROR_PC)

	EQUIVALENCE	(EMB(48),ERROR_PSL)





	DATA	V1UBACR(0)	/'ADAPTER INIT*'/

	DATA	V1UBACR(1)	/'UNIBUS POWER FAIL*'/

	DATA	V1UBACR(2)	/'CONFIGURATION INTERRUPT ENABLE*'/

	DATA	V1UBACR(3)	/'SBI TO UNIBUS ERROR INT ENABLE*'/

	DATA	V1UBACR(4)	/'UNIBUS TO SBI ERROR INT ENABLE*'/

	DATA	V1UBACR(5)	/'BR INTERRUPT ENABLE*'/

	DATA	V1UBACR(6)	/'INTERRUPT FIELD SWITCH*'/



	DATA	V1UBASR(0)	/'UNIBUS ''SSYN'' TIMEOUT*'/

	DATA	V1UBASR(1)	/'UNIBUS SELECT TIMEOUT*'/

	DATA	V1UBASR(2)	/'LOST ERROR*'/

	DATA	V1UBASR(3)	/'MAP REGISTER PARITY FAIL*'/

	DATA	V1UBASR(4)	/'INVALID MAP REGISTER*'/

	DATA	V1UBASR(5)	/'DATA PATH PARITY ERROR*'/

	DATA	V1UBASR(6)	/'COMMAND TRANSMIT TIMEOUT*'/

	DATA	V1UBASR(7)	/'COMMAND TRANSMIT ERROR*'/

	DATA	V1UBASR(8)	/'CORRECTED READ DATA*'/

	DATA	V1UBASR(9)	/'READ DATA SUBSTITUTE*'/

	DATA	V1UBASR(10)	/'READ DATA TIMEOUT*'/




	DATA	REG_HERALD(0)	/'CSR*'/

	DATA	REG_HERALD(1)	/'CR*'/

	DATA	REG_HERALD(2)	/'SR*'/

	DATA	REG_HERALD(3)	/'DCR*'/

	DATA	REG_HERALD(4)	/'FMER*'/

	DATA	REG_HERALD(5)	/'FUBAR*'/



	DATA	TR		/'TR '/





	CALL FRCTOF (LUN)

	call header (lun)

	call logger (lun,'DW780 INTERRUPT')

	diagnostic_mode = .false.

	if (lib$extzv(28,3,uba_dcr) .ne. 0) diagnostic_mode = .true.

	CALL LINCHK (LUN,2)

	WRITE(LUN,10) ERROR_PC
10	FORMAT('0',T8,'ERROR PC',T24,Z8.8)

	if (.not. diagnostic_mode) then

	CALL VAXPSL (LUN,ERROR_PSL)

	CALL LINCHK (LUN,2)

	WRITE(LUN,12) ADAPTER_TR
12	FORMAT('0',T8,'ADAPTER TR# ',I<COMPRESS4 (ADAPTER_TR)>,'.')

	CALL UBA_REGA (LUN,UBA_CSR)
	else

	call linchk (lun,6)

	write(lun,13) error_psl,adapter_tr,uba_csr
13	format('0',t8,'ERROR PSL',t24,z8.8,//,
	1 t8,'ADAPTER TR# ',i<compress4 (adapter_tr)>,'.',//,
	1 t8,'DW780 CSR',t24,z8.8)
	endif

	CALL LINCHK (LUN,1)

	WRITE(LUN,15) UBA_CR
15	FORMAT(' ',T8,'DW780 CR',T24,Z8.8)

	if (.not. diagnostic_mode) then

	CALL OUTPUT (LUN,UBA_CR,V1UBACR,0,0,6,'0')

	FIELD = LIB$EXTZV(26,5,UBA_CR)

	IF (FIELD .NE. 0) THEN

	FIELD = (FIELD*16) - 1

	CALL LINCHK (LUN,1)

	WRITE(LUN,20) FIELD
20	FORMAT(' ',T40,'MAPS 0. THRU ',I<COMPRESS4 (FIELD)>,'. DISABLED')
	ENDIF
	endif

	CALL LINCHK (LUN,1)

	WRITE(LUN,25) UBA_SR
25	FORMAT(' ',T8,'DW780 SR',T24,Z8.8)

	if (.not. diagnostic_mode) then

	CALL OUTPUT (LUN,UBA_SR,V1UBASR,0,0,10,'0')

	DO 35,I = 24,27

	IF (JIAND(UBA_SR,2**I) .NE. 0) THEN

	CALL LINCHK (LUN,1)

	WRITE(LUN,30) I - 20
30	FORMAT(' ',T40,'BRRVR ',I1,'. FULL')
	ENDIF

35	CONTINUE
	endif

	CALL LINCHK (LUN,1)

	WRITE(LUN,40) UBA_DCR
40	FORMAT(' ',T8,'DW780 DCR',T24,Z8.8)

	if (diagnostic_mode) then

	CALL LINCHK (LUN,1)

	WRITE(LUN,45)
45	FORMAT(' ',T40,'DIAGNOSTIC MODE')
	endif

	CALL LINCHK (LUN,1)

	WRITE(LUN,50) UBA_FMER
50	FORMAT(' ',T8,'DW780 FMER',T24,Z8.8)

	if (.not. diagnostic_mode) then

	IF (JIAND(UBA_SR,'000006F8'X) .NE. 0) THEN

	FIELD = LIB$EXTZV(0,9,UBA_FMER)

	CALL LINCHK (LUN,1)

	WRITE(LUN,55) FIELD
55	FORMAT(' ',T40,'SELECTED MAP = ',I<COMPRESS4 (FIELD)>,'.')
	ENDIF
	endif

	CALL LINCHK (LUN,1)

	WRITE(LUN,60) UBA_FUBAR
60	FORMAT(' ',T8,'DW780 FUBAR',T24,Z8.8)

	if (.not. diagnostic_mode) then

	IF (JIAND(UBA_SR,'00000003'X) .NE. 0) THEN

	FIELD = JISHFT(JIAND(UBA_FUBAR,'0000FFFE'X),-1)

	CALL LINCHK (LUN,1)

	WRITE(LUN,65) FIELD
65	FORMAT(' ',T40,'UNIBUS ADDRESS = ',O5.5,'X (OCTAL)')
	ENDIF
	endif

	RETURN




	ENTRY B_DW780_INTERRUPT (LUN)




	call header (lun)

	call logger (lun,'DW780 INTERRUPT')

	CALL BRIEF32 (LUN,(6),UBA_CSR,REG_HERALD,TR,ADAPTER_TR)

	RETURN



	ENTRY C_DW780_INTERRUPT (LUN)




	CALL CRYPTK (LUN,32,(6),UBA_CSR,REG_HERALD,TR,ADAPTER_TR)

	RETURN

	END
