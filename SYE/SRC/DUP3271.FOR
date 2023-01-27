	SUBROUTINE DUP3271 (lun)
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
C	Author:	Sharon Reynolds			Creation date:10-Sept-80
C
C
C++
C	Functional description:
C
C	This module builds the error log report for the Dup11/3271
C	Protocol Emulator (XKDRIVER). 
C
C	Modified by:
C
C	v02-003	BP0003		Brian Porter,		23-NOV-1981
C		Minor edit.
C
C	v02-002	BP0002		Brian Porter,		06-NOV-1981
C		Added 'device attention' support.
C
C	v02-001	BP0001		Brian Porter,		29-JUN-1981
C		Added call to logger.
C**
C--

	Include 'SRC$:MSGHDR.FOR /NOLIST'
	Include 'SRC$:DEVERR.FOR /NOLIST'




	Byte		lun


	Parameter	timeout = 96
	Parameter	count = 18


	Integer*4	field
	Integer*4	compress4
	Integer*4	compressC
	Integer*4	rxcsr
	Integer*4	rxdbuf
	Integer*4	parcsr
	Integer*4	txcsr
	Integer*4	txdbuf
	Integer*4	stats(0:18)
	Integer*4	tnak
	Integer*4	rnak
	Integer*4	tenq
	Integer*4	renq
	Integer*4	trvi
	Integer*4	rrvi
	Integer*4	rcnv
	Integer*4	chai
	Integer*4	gpol
	Integer*4	xack
	Integer*4	habo
	Integer*4	dabo
	Integer*4	rtim
	Integer*4	disc
	Integer*4	hard
	Integer*4	tblk
	Integer*4	rblk
	Integer*4	habx
	Integer*4	teot


	Character*11	offset(0:18)
	Character*32	descrp(0:18)
	Character*5	reg_herald(0:4)


C
C	Make the contents of the register save area in the error log 
C	buffer available to this module
C

	Equivalence	(stats(0),tnak)
	Equivalence	(parcsr,EMB$L_DV_REGSAV(1))
	Equivalence	(rxcsr,EMB$L_DV_REGSAV(2))
	Equivalence	(rxdbuf,EMB$L_DV_REGSAV(3))
	Equivalence	(txcsr,EMB$L_DV_REGSAV(4))
	Equivalence	(txdbuf,EMB$L_DV_REGSAV(5))
	Equivalence	(tnak,EMB$L_DV_REGSAV(6))
	Equivalence	(rnak,EMB$L_DV_REGSAV(7))
	Equivalence	(tenq,EMB$L_DV_REGSAV(8))
	Equivalence	(renq,EMB$L_DV_REGSAV(9))
	Equivalence	(trvi,EMB$L_DV_REGSAV(10))
	Equivalence	(rrvi,EMB$L_DV_REGSAV(11))
	Equivalence	(rcnv,EMB$L_DV_REGSAV(12))
	Equivalence	(chai,EMB$L_DV_REGSAV(13))
	Equivalence	(gpol,EMB$L_DV_REGSAV(14))
	Equivalence	(xack,EMB$L_DV_REGSAV(15))
	Equivalence	(habo,EMB$L_DV_REGSAV(16))
	Equivalence	(dabo,EMB$L_DV_REGSAV(17))
	Equivalence	(rtim,EMB$L_DV_REGSAV(18))
	Equivalence	(disc,EMB$L_DV_REGSAV(19))
	Equivalence	(hard,EMB$L_DV_REGSAV(20))
	Equivalence	(tblk,EMB$L_DV_REGSAV(21))
	Equivalence	(rblk,EMB$L_DV_REGSAV(22))
	Equivalence	(habx,EMB$L_DV_REGSAV(23))
	Equivalence	(teot,EMB$L_DV_REGSAV(24))



C
C	Define register mnemonics for the BRIEF report
C

	Data	reg_herald(0)	/'PCSR*'/
	Data	reg_herald(1)	/'RCSR*'/
	Data	reg_herald(2)	/'RBUF*'/
	Data	reg_herald(3)	/'TCSR*'/
	Data	reg_herald(4)	/'TBUF*'/


C
C	Define driver offsets for PROTOCOL STATISTICS
C

	Data	offset(0)	/'LCB$W_TNAK*'/
	Data	offset(1)	/'LCB$W_RNAK*'/
	Data	offset(2)	/'LCB$W_TENQ*'/
	Data	offset(3)	/'LCB$W_RENQ*'/
	Data	offset(4)	/'LCB$W_TRVI*'/
	Data	offset(5)	/'LCB$W_RRVI*'/
	Data	offset(6)	/'LCB$W_RCNV*'/
	Data	offset(7)	/'LCB$W_CHAI*'/
	Data	offset(8)	/'LCB$W_GPOL*'/
	Data	offset(9)	/'LCB$W_XACK*'/
	Data	offset(10)	/'LCB$W_HABO*'/
	Data	offset(11)	/'LCB$W_DABO*'/
	Data	offset(12)	/'LCB$W_RTIM*'/
	Data	offset(13)	/'LCB$W_DISC*'/
	Data	offset(14)	/'LCB$W_HARD*'/
	Data	offset(15)	/'LCB$W_TBLK*'/
	Data	offset(16)	/'LCB$W_RBLK*'/
	Data	offset(17)	/'LCB$W_HABX*'/
	Data	offset(18)	/'LCB$W_TEOT*'/


C
C	Define descriptions for PROTOCOL STATISTICS
C

	Data	descrp(0)	/'NAK''S TRANSMITTED = *'/
	Data	descrp(1)	/'NAK''S RECEIVED = *'/
	Data	descrp(2)	/'ENQ''S TRANSMITTED = *'/
	Data	descrp(3)	/'ENQ''S RECEIVED = *'/
	Data	descrp(4)	/'RVI''S TRANSMITTED = *'/
	Data	descrp(5)	/'RVI''S RECEIVED = *'/
	Data	descrp(6)	/'CONVERSATIONAL REPLIES IN = *'/
	Data	descrp(7)	/'CHAINED WRITES RECEIVED = *'/
	Data	descrp(8)	/'GENERAL POLLS RECEIVED = *'/
	Data	descrp(9)	/'INVALID ACK''S RECEIVED = *'/
	Data	descrp(10)	/'HOST ABORTED XMISSIONS = *'/
	Data	descrp(11)	/'DRIVER ABORTED XMISSIONS = *'/
	Data	descrp(12)	/'XMISSION RESPONSE TIMEOUTS = *'/
	Data	descrp(13)	/'DETECTED LINE DISCONNECTS = *'/
	Data	descrp(14)	/'DETECTED HARDWARE ERRORS = *'/
	Data	descrp(15)	/'USER BLOCKS TRANSMITTED = *'/
	Data	descrp(16)	/'USER BLOCKS RECEIVED = *'/
	Data	descrp(17)	/'AMBIGUOUS ACK''S SENT = *'/
	Data	descrp(18)	/'IMPLIED ACK''S SENT (EOT) = *'/

	

C
C	Contruct the report header
C

	Call FRCTOF (lun)

	call dhead1 (lun,'UBA DUP11')

C
C	Decode and output the DUP11 registers
C

	Call DUP11 (lun,parcsr,rxcsr,rxdbuf,txcsr,txdbuf)

C
C	Output PROTOCOL STATISTICAL INFORMATION for report
C

	Call LINCHK (lun,3)

	Write (lun,5)
5	Format ('0','PROTOCOL STATISTICAL INFORMATION',/)


	Do 20 I=0,count

	Call LINCHK (lun,2)

	Field=LIB$EXTZV (0,16,stats(I))

	Write (lun,10) offset(I),stats(I),descrp(I),field
10	Format (' ',T8,A<compressC (offset(I))>,T24,Z8.4,/,
	1 T40,A<compressC (descrp(I))>,I<compress4 (field)>,'.')


20	Continue


C
C	Decode and output SOFTWARE INFORMATION for report
C

	call linchk (lun,1)

	write(lun,25)
25	format(' ',:)

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

	write(lun,25)

	call dup3271_qio (lun,emb$w_dv_func)

	call irp$w_bcnt (lun,emb$w_dv_bcnt)

	call irp$w_boff (lun,emb$w_dv_boff)

	call irp$l_pid (lun,emb$l_dv_rqpid)

	call irp$q_iosb (lun,emb$l_dv_iosb1)
	endif

	Return




	ENTRY B_DUP3271 (lun)




	call dhead1 (lun,'UBA DUP11')

	Call BRIEF16 (lun,5,parcsr,reg_herald,EMB$T_DV_NAME,EMB$W_DV_UNIT)

	Return

	END



	subroutine dup3271_qio (lun,emb$w_dv_func)



	include 'src$:qiocommon.for /nolist'



	byte		lun

	integer*2	emb$w_dv_func

	integer*4	qiocode(0:1,0:63)




	if (qiocode(0,0) .eq. 0) then

	Qiocode(1,11) = %loc(IO$_WRITEPBLK)

	Qiocode(1,12) = %loc(IO$_READPBLK)

	Qiocode(1,13) = %loc(IO$_RDSTATS)

	Qiocode(1,26) = %loc(IO$_SETCHAR)

	Qiocode(1,29) = %loc(IO$_DIAGNOSE)

	Qiocode(1,32) = %loc(IO$_WRITELBLK)

	Qiocode(1,33) = %loc(IO$_READLBLK)

	Qiocode(1,48) = %loc(IO$_WRITEVBLK)

	Qiocode(1,49) = %loc(IO$_READVBLK)

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
