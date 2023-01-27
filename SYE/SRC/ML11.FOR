	SUBROUTINE ML11 (lun)
C
C	Version	'V03-000'
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
C	Author:	Sharon Reynolds			Creation date:	12-Dec-80
C
C
C++
C	Functional description:
C
C	This module builds the error log report for the ML11 solid-state
C	disk.
C
C	Modified by:
C
C	v02-003	BP0003		Brian Porter,		18-NOV-1981
C		Added new mba code. Minor edit.
C
C	v02-002	BP0002		Brian Porter,		05-NOv-1981
C		Added 'device attention' support.
C
C	v02-001	BP0001		Brian Porter,		01-JUL-1981
C		Added call to DHEAD and LOGGER.  Added DIAGNOSTIC_MODE.
C--
C**


	Include 'SRC$:MSGHDR.FOR /NOLIST'
	Include 'SRC$:DEVERR.FOR /NOLIST'


	Byte		lun


	Parameter	timeout = 96
	Parameter	xfer_cmd = 20


	Integer*4	COMPRESSC
	Integer*4	COMPRESS4

	Integer*4	field

	integer*4	adapter_registers(7)

	integer*4	selected_map_register

	Integer*4	irp_flag
	Integer*4	mlcs1
	Integer*4	mlds
	Integer*4	mler
	Integer*4	mlmr
	Integer*4	mlas
	Integer*4	mlda
	Integer*4	mldt
	Integer*4	mlsn
	Integer*4	mle1
	Integer*4	mle2
	Integer*4	mlee
	Integer*4	mlel
	Integer*4	prom_dis
	Integer*4	prom_rw
	Integer*4	drv_func
	Integer*4	type
	Integer*4	cards
	Integer*4	chan
	Integer*4	err_func
	Integer*4	crc_err
	Integer*4	sngl_err
	Integer*4	unc_err
	Integer*4	wrd

	Integer*4	reg_copy(0:11)

	logical*1	diagnostic_mode

	Character*7	mlcs1_1(0:0)
	Character*16	mlcs1_2(11:11)
	Character*14	mlds_1(6:8)
	Character*23	mlds_2(10:10)
	Character*17	mlds_3(14:15)
	Character*16	mlds_mol(0:1)
	Character*24	mler_1(0:3)
	Character*15	mler_2(5:6)
	Character*23	mler_3(9:10)
	Character*21	mler_4(13:15)
	Character*18	mlmr_1(1:2)
	Character*30	mlmr_2(7:7)
	Character*17	xfer_rate(0:3)
	Character*16	aray_typ(0:1)
	Character*5	reg_herald(0:11)


C
C	Make the contents of the register save area in the error log
C	buffer available to this module
C

	equivalence	(adapter_registers,emb$l_dv_regsav(0))

	Equivalence	(irp_flag,EMB$L_DV_REGSAV(7))
	Equivalence	(mlcs1,EMB$L_DV_REGSAV(8))
	Equivalence	(mlds,EMB$L_DV_REGSAV(9))
	Equivalence	(mler,EMB$L_DV_REGSAV(10))
	Equivalence	(mlmr,EMB$L_DV_REGSAV(11))
	Equivalence	(mlas,EMB$L_DV_REGSAV(12))
	Equivalence	(mlda,EMB$L_DV_REGSAV(13))
	Equivalence	(mldt,EMB$L_DV_REGSAV(14))
	Equivalence	(mlsn,EMB$L_DV_REGSAV(16))
	Equivalence	(mle1,EMB$L_DV_REGSAV(17))
	Equivalence	(mle2,EMB$L_DV_REGSAV(18))
	Equivalence	(mlee,EMB$L_DV_REGSAV(21))
	Equivalence	(mlel,EMB$L_DV_REGSAV(22))


C
C	Define register mnuemonics for BRIEF report
C

	Data	reg_herald(0)	/'CS1*'/
	Data	reg_herald(1)	/'DS*'/
	Data	reg_herald(2)	/'ER*'/
	Data	reg_herald(3)	/'MR*'/
	Data	reg_herald(4)	/'AS*'/
	Data	reg_herald(5)	/'DA*'/
	Data	reg_herald(6)	/'DT*'/
	Data	reg_herald(7)	/'SN*'/
	Data	reg_herald(8)	/'E1*'/
	Data	reg_herald(9)	/'E2*'/
	Data	reg_herald(10)	/'EE*'/
	Data	reg_herald(11)	/'EL*'/


C
C	Define text for bits in the ML11 control/status register
C

	Data	mlcs1_1(0)	/'GO BIT*'/

	Data	mlcs1_2(11)	/'DRIVE AVAILABLE*'/


C
C	Define text for bits in the ML11 drive status register
C

	Data	mlds_1(6)	/'VOLUME VALID*'/
	Data	mlds_1(7)	/'DRIVE READY*'/
	Data	mlds_1(8)	/'DRIVE PRESENT*'/

	Data	mlds_2(10)	/'LAST BLOCK TRANSFERRED*'/

	Data	mlds_3(14)	/'ERROR*'/
	Data	mlds_3(15)	/'ATTENTION ACTIVE*'/

	Data	mlds_mol(0)	/'MEDIUM OFF LINE*'/
	Data	mlds_mol(1)	/'MEDIUM ON LINE*'/

C
C	Define text for bits in the ML11 error register
C

	Data	mler_1(0)	/'ILLEGAL FUNCTION*'/
	Data	mler_1(1)	/'ILLEGAL REGISTER*'/
	Data	mler_1(2)	/'REGISTER MODIFY REFUSED*'/
	Data	mler_1(3)	/'CONTROL PARITY*'/

	Data	mler_2(5)	/'DATA PARITY*'/
	Data	mler_2(6)	/'ECC HARD ERROR*'/

	Data	mler_3(9)	/'ADDRESS OVERFLOW ERROR*'/
	Data	mler_3(10)	/'INVALID ADDRESS ERROR*'/

	Data	mler_4(13)	/'OPERATION INCOMPLETE*'/
	Data	mler_4(14)	/'DRIVE UNSAFE*'/
	Data	mler_4(15)	/'DATA CHECK*'/


C
C	Define text for bits in the ML11 maintenance register
C

	Data	mlmr_1(1)	/'ECC DISABLED*'/
	Data	mlmr_1(2)	/'DATA CHECK ENABLE*'/

	Data	mlmr_2(7)	/'REFRESH RATE DECREASED BY 50%*'/

	Data	xfer_rate(0)	/'2.0 MBYTE/SECOND*'/
	Data	xfer_rate(1)	/'1.0 MBYTE/SECOND*'/
	Data	xfer_rate(2)	/'.5 MBYTE/SECOND*'/
	Data	xfer_rate(3)	/'.25 MBYTE/SECOND*'/

	Data	aray_typ(0)	/'16K CHIP ARRAYS*'/
	Data	aray_typ(1)	/'64K CHIP ARRAYS*'/


C
C	Construct the report header
C

	Call FRCTOF (lun)

	call dhead1 (lun,'MASSBUS')

C
C	Establish if it was a data transfer type command and get the
C	massbus registers if so
C

	diagnostic_mode = .false.

	if (lib$extzv(0,1,mlmr) .eq. 1) diagnostic_mode = .true.

	if (lib$extzv(3,1,mlmr) .eq. 1) diagnostic_mode = .true.

	if (lib$extzv(5,2,mlmr) .ne. 0) diagnostic_mode = .true.

	Drv_func = LIB$EXTZV (1,5,mlcs1)

	If (
	1 EMB$W_DV_BCNT .ne. 0
	1 .and.
	1 drv_func .ge. xfer_cmd
	1 .and.
	1 emb$w_hd_entry .ne. 98
	1 ) then

	call mba_control_registers (lun,5,adapter_registers,
	1 selected_map_register)

	call mba_mapping_register (lun,selected_map_register,
	1 adapter_registers(6))

	if (selected_map_register .gt. 0) then

	call mba_mapping_register (lun,(selected_map_register - 1),
	1 adapter_registers(7))
	endif
	Endif


C
C	Decode and output the bits in the control and status register
C

	Call LINCHK (lun,2)
	Write (lun,20) mlcs1
20	Format ('0',T8,'MLCS1',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mlcs1,mlcs1,0)

	Call OUTPUT (lun,mlcs1,mlcs1_1,0,0,0,'0')

	Call LINCHK (lun,1)
	If (drv_func .eq. 0) then
	Write (lun,22)
22	Format (' ',T40,'NO-OPERATION')

	Else if (drv_func .eq. 4) then 
	Write (lun,24)
24	Format (' ',T40,'DRIVE CLEAR')

	Else if (drv_func .eq. 8) then
	Write (lun,26)
26	Format (' ',T40,'READ IN PRESET')

	Else if (drv_func .eq. 12) then
	Write (lun,28)
28	Format (' ',T40,'SEARCH')

	Else if (drv_func .eq. 20) then
	Write (lun,30)
30	Format (' ',T40,'WRITE CHECK')

	Else if (drv_func .eq. 24) then
	Write (lun,32)
32	Format (' ',T40,'WRITE DATA')

	Else if (drv_func .eq. 28) then
	Write (lun,34)
34	Format (' ',T40,'READ DATA')
	Endif

	Call OUTPUT (lun,mlcs1,mlcs1_2,11,11,11,'0')
	endif

C
C	Decode and output the bits in the drive status register
C

	Call LINCHK (lun,1)
	Write (lun,40) mlds
40	Format (' ',T8,'MLDS',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mlcs1,mlds,1)

	Call OUTPUT (lun,mlds,mlds_1,6,6,8,'0')

	Call OUTPUT (lun,mlds,mlds_2,10,10,10,'0')

	Field = LIB$EXTZV (12,1,mlds)

	Call LINCHK (lun,1)
	Write (lun,45) mlds_mol(field)
45	Format (' ',T40,A<COMPRESSC (mlds_mol(field))>)

	Call OUTPUT (lun,mlds,mlds_3,14,14,15,'0')
	endif

C
C	Decode and output the bits in the error register
C

	Call LINCHK (lun,1)
	Write (lun,50) mler
50	Format (' ',T8,'MLER',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mlds,mler,1)

	Call OUTPUT (lun,mler,mler_1,0,0,3,'0')

	Call OUTPUT (lun,mler,mler_2,5,5,6,'0')

	Call OUTPUT (lun,mler,mler_3,9,9,10,'0')

	Call OUTPUT (lun,mler,mler_4,13,13,15,'0')
	endif

C
C	Decode and output the bits in the maintenance register
C

	Call LINCHK (lun,1)
	Write (lun,60) mlmr
60	Format (' ',T8,'MLMR',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mler,mlmr,1)

	call output (lun,mlmr,mlmr_1,1,1,2,'0')

	Call OUTPUT (lun,mlmr,mlmr_2,7,7,7,'0')

	Field = LIB$EXTZV (8,2,mlmr)

	Call LINCHK (lun,1)
	Write (lun,75) xfer_rate(field)
75	Format (' ',T40,'XFER RATE = ',
	1 A<COMPRESSC (xfer_rate(field))>)

	Type = LIB$EXTZV (10,1,mlmr)
	Cards = LIB$EXTZV (11,5,mlmr)

	Call LINCHK (lun,2)

	Write (lun,80) aray_typ(type)
80	Format (' ',T40,A<COMPRESSC (aray_typ(type))>)

	Write (lun,85) cards
85	Format (' ',T40,I<COMPRESS4 (cards)>,
	1 '. ARRAY MODULES')
	else

	Call LINCHK (lun,1)
	Write (lun,70)
70	Format (' ',T40,'DIAGNOSTIC MODE')
	Endif

C
C	Decode and output the bits in the attention summary register
C

	Call LINCHK (lun,1)
	Write (lun,100) mlas
100	Format (' ',T8,'MLAS',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mlmr,mlas,1)

	Do 106, I=0,7

	If (JIAND(mlas,2**I) .ne. 0) then

	Call LINCHK (lun,1)
	Write (lun,105) I
105	Format (' ',T40,'ATTENTION UNIT ',I1,'.')
	Endif

106	Continue
	endif


C
C	Decode and output the bits in the desired address register
C

	Call LINCHK (lun,1)
	Write (lun,120) mlda
120	Format (' ',T8,'MLDA',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mlas,mlda,1)

	Field = LIB$EXTZV (0,16,mlda)

	Call LINCHK (lun,1)
	Write (lun,130) field
130	Format (' ',T40,'SECTOR = ',I<COMPRESS4 (field)>,'.')
	endif


C
C	Decode and output the bits in the drive type register
C

	Call LINCHK (lun,1)

	Write (lun,140) mldt
140	Format (' ',T8,'MLDT',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mlda,mldt,1)

	Field = LIB$EXTZV (0,9,mldt)

	If (field .eq. 110) then 

	Call LINCHK (lun,1)
	Write (lun,150)
150	Format (' ',T40,'DRIVE TYPE = ML11')
	Endif
	endif

C
C	Decode and output bits in the serial number register
C

	Call LINCHK (lun,1)
	Write (lun,160) mlsn
160	Format (' ',T8,'MLSN',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mldt,mlsn,1)
	endif

C
C	Decode and output the bits in the ECC CRC word register 1
C

	Call LINCHK (lun,1)
	Write (lun,170) mle1
170	Format (' ',T8,'MLE1',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mlsn,mle1,1)
	endif

C
C	Decode and output the bits in the ECC CRC word register 2
C

	Call LINCHK (lun,1)
	Write (lun,180) mle2
180	Format (' ',T8,'MLE2',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mle1,mle2,1)
	endif

C
C	Decode and output bits in the ECC error register
C

	Call LINCHK (lun,1)
	Write (lun,190) mlee
190	Format (' ',T8,'MLEE',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mle2,mlee,1)

	Crc_err = LIB$EXTZV (13,1,mlee)
	Sngl_err = LIB$EXTZV (14,1,mlee)
	Unc_err = LIB$EXTZV (15,1,mlee)
	Chan = LIB$EXTZV (6,6,mlee)
	Err_func = LIB$EXTZV (0,6,mlee)

	Do 194, I=0,5
	If (JIAND(err_func,2**I) .ne. 0) then
	Wrd = I+1
	Endif

194	Continue


	If (crc_err .eq. 1) then 

	Call LINCHK (lun,2)
	Write (lun,195)
195	Format (' ',T40,'CRC ERROR')

	Write (lun,196) wrd,chan
196	Format (' ',T40,'WORD ',I1,', BIT ',
	1 I<COMPRESS4 (chan)>, ' IN ERROR')

	Else if (sngl_err .eq. 1) then 

	Call LINCHK (lun,2)
	Write (lun,197)
197	Format (' ',T40,'SINGLE ERROR')

	Write (lun,198) wrd,chan
198	Format (' ',T40,'WORD ',I1,', BIT ',
	1 I<COMPRESS4 (chan)>,' IN ERROR')

	Else if (unc_err .eq. 1) then

	Call LINCHK (lun,1)
	Write (lun,199)
199	Format (' ',T40,'UNCORRECTABLE ERROR')

	Endif
	endif

C
C	Decode and output the bits in the ECC error location register
C

	Call LINCHK (lun,1)

	Write (lun,200) mlel
200	Format (' ',T8,'MLEL',T24,Z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mlee,mlel,1)
	endif


C
C	Get software information and return to ERRPRT
C

	call linchk (lun,1)

	write(lun,205)
205	format(' ',:)

	if (
	1 emb$w_hd_entry .ne. 98
	1 .and.
	1 irp_flag .ne. 0
	1 ) then

	call ucb$b_ertcnt (lun,emb$b_dv_ertcnt)

	call ucb$b_ertmax (lun,emb$b_dv_ertmax)
	endif

	call ucb$l_ownuic (lun,emb$l_dv_ownuic)

	call ucb$l_char (lun,emb$l_dv_char)

	call ucb$w_sts (lun,emb$w_dv_sts)

	call ucb$l_opcnt (lun,emb$l_dv_opcnt)

	call ucb$w_errcnt (lun,emb$w_dv_errcnt)

	if (
	1 emb$w_hd_entry .ne. 98
	1 .and.
	1 irp_flag .ne. 0
	1 ) then

	call linchk (lun,1)

	write(lun,205)

	call ml11_qio (lun,emb$w_dv_func)

	call irp$w_bcnt (lun,emb$w_dv_bcnt)

	call irp$w_boff (lun,emb$w_dv_boff)

	call irp$l_pid (lun,emb$l_dv_rqpid)

	call irp$q_iosb (lun,emb$l_dv_iosb1)
	endif

	Return




C
C	Output the BRIEF report for the ML11 disk
C


	Entry B_ML11 (lun)

	call dhead1 (lun,'MASSBUS')

C
C	Make a sequential copy of the device registers for the BRIEF module
C

	Reg_copy(0) = mlcs1
	Reg_copy(1) = mlds
	Reg_copy(2) = mler
	Reg_copy(3) = mlmr
	Reg_copy(4) = mlas
	Reg_copy(5) = mlda
	Reg_copy(6) = mldt
	Reg_copy(7) = mlsn
	Reg_copy(8) = mle1
	Reg_copy(9) = mle2
	Reg_copy(10) = mlee
	Reg_copy(11) = mlel

	Call BRIEF16 (lun,(12),reg_copy,reg_herald,
	1 EMB$T_DV_NAME,EMB$W_DV_UNIT)

	Return





C
C	Output the CRYPTK report for the ML11 disk
C


	Entry C_ML11 (lun)


C
C	Make a sequential copy of the device registers for the CRYPTK module
C

	Reg_copy(0) = mlcs1
	Reg_copy(1) = mlds
	Reg_copy(2) = mler
	Reg_copy(3) = mlmr
	Reg_copy(4) = mlas
	Reg_copy(5) = mlda
	Reg_copy(6) = mldt
	Reg_copy(7) = mlsn
	Reg_copy(8) = mle1
	Reg_copy(9) = mle2
	Reg_copy(10) = mlee
	Reg_copy(11) = mlel

	Call CRYPTK (lun,16,(12),reg_copy,reg_herald,
	1 EMB$T_DV_NAME, EMB$W_DV_UNIT)

	Return

	End



	subroutine ml11_qio (lun,emb$w_dv_func)



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
