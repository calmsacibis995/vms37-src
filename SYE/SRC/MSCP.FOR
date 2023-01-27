C
C	Version 'V03-002'
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

c	Author	Brian Porter			Creation date	10-FEB-1982

c++
c	Functional description:
c
c	This module displays entries logged by pudriver and dudriver.
c
c	Modified by:
c
c	v03-002	BP0002		Brian Porter,		22-APR-1982
c		Modified invalid command.
c
c	v03-001	BP0001		Brian Porter,		12-APR-1982
c		Added unit available, duplicate unit and invalid command
c		message support.
c**
c--



	subroutine mscp$$k_op_avatn (lun,expand)



	include 'src$:msghdr.for /nolist'

	include 'src$:emblmdef.for /nolist'



	byte		lun

	logical*1	expand

	integer*4	reserved1

	integer*2	mscp$w_unit

	integer*2	reserved2

	byte		mscp$b_opcode

	byte		reserved3

	integer*2	reserved4

	integer*2	mscp$w_mult_unt

	integer*2	mscp$w_unt_flags

	integer*4	undefined

	integer*4	mscp$l_unit_id1

	integer*4	mscp$l_unit_id2

	integer*4	mscp$l_media_id

	equivalence	(emb(38),reserved1)

	equivalence	(emb(42),mscp$w_unit)

	equivalence	(emb(44),reserved2)

	equivalence	(emb(46),mscp$b_opcode)

	equivalence	(emb(47),reserved3)

	equivalence	(emb(48),reserved4)

	equivalence	(emb(50),mscp$w_mult_unt)

	equivalence	(emb(52),mscp$w_unt_flags)

	equivalence	(emb(54),undefined)

	equivalence	(emb(58),mscp$l_unit_id1)

	equivalence	(emb(62),mscp$l_unit_id2)

	equivalence	(emb(66),mscp$l_media_id)



	call linchk (lun,1)

	write(lun,10)
10	format(' ',:)

	call mscp_first_twelve_bytes2 (lun,expand)



	entry invalid_mscp$$k_op_avatn (lun,expand)



	call mscp$$w_mult_unt (lun,mscp$w_mult_unt)

	call mscp$$w_unt_flgs (lun,mscp$w_unt_flgs,expand)

	call linchk (lun,1)

	write(lun,15) undefined
15	format(' ',t8,'UNDEFINED',t24,z8.8)

	call mscp$$q_unit_id (lun,mscp$l_unit_id1,mscp$l_unit_id2,expand)

	call mscp$$l_media_id (lun,mscp$l_media_id,expand)

	return

	end



	subroutine mscp$$k_op_acpth (lun,expand)



	include 'src$:msghdr.for /nolist'

	include 'src$:emblmdef.for /nolist'



	byte		lun

	logical*1	expand

	integer*4	reserved1

	integer*2	mscp$w_unit

	integer*2	reserved2

	byte		mscp$b_opcode

	byte		reserved3

	integer*2	reserved4

	equivalence	(emb(38),reserved1)

	equivalence	(emb(42),mscp$w_unit)

	equivalence	(emb(44),reserved2)

	equivalence	(emb(46),mscp$b_opcode)

	equivalence	(emb(47),reserved3)

	equivalence	(emb(48),reserved4)



	entry mscp$$k_op_dupun (lun,expand)



	call linchk (lun,1)

	write(lun,10)
10	format(' ',:)

	call mscp_first_twelve_bytes2 (lun,expand)



	entry invalid_mscp$$k_op_acpth (lun,expand)



	entry invalid_mscp$$k_op_dupun (lun,expand)



	return

	end



	subroutine mslg$k_cnt_err (lun)



	include 'src$:msghdr.for /nolist'

	include 'src$:emblmdef.for /nolist'



	byte		lun

	integer*4	mslg$l_cmd_ref

	integer*2	reserved

	integer*2	mslg$w_seq_num

	byte		mslg$b_format

	byte		mslg$b_flags

	integer*2	mslg$w_event

	integer*4	mslg$l_cnt_id1

	integer*4	mslg$l_cnt_id2

	byte		mslg$b_cnt_svr

	byte		mslg$b_cnt_hvr

	integer*2	lastfail_code

	equivalence	(emb(38),mslg$l_cmd_ref)

	equivalence	(emb(42),reserved)

	equivalence	(emb(44),mslg$w_seq_num)

	equivalence	(emb(46),mslg$b_format)

	equivalence	(emb(47),mslg$b_flags)

	equivalence	(emb(48),mslg$w_event)

	equivalence	(emb(50),mslg$l_cnt_id1)

	equivalence	(emb(54),mslg$l_cnt_id2)

	equivalence	(emb(58),mslg$b_cnt_svr)

	equivalence	(emb(59),mslg$b_cnt_hvr)

	equivalence	(emb(60),lastfail_code)




	call linchk (lun,1)

	write(lun,10)
10	format(' ',:)

	call mslg$$l_cmd_ref (lun,mslg$l_cmd_ref)

	call mslg$$w_seq_num (lun,mslg$w_seq_num)

	call mslg$$b_format (lun,mslg$b_format)

	call mslg$$b_flags (lun,mslg$b_flags)

	call mslg$$w_event (lun,mslg$w_event)

	call mslg$$q_cnt_id (lun,mslg$l_cnt_id1,mslg$l_cnt_id2)

	call mslg$$b_cnt_svr (lun,mslg$b_cnt_svr)

	call mslg$$b_cnt_hvr (lun,mslg$b_cnt_hvr)

	if (
	1 lib$extzv(0,8,emb$b_lm_class) .eq. 128
	1 .and.
	1 emb$b_lm_type .eq. 3
	1 ) then

	call pudriver_lastfail_error (lun,lastfail_code)
	endif

	return

	end




	subroutine mslg$k_bus_addr (lun)



	include 'src$:msghdr.for /nolist'

	include 'src$:emblmdef.for /nolist'



	byte		lun

	integer*4	mslg$l_cmd_ref

	integer*2	reserved1

	integer*2	mslg$w_seq_num

	byte		mslg$b_format

	byte		mslg$b_flags

	integer*2	mslg$w_event

	integer*4	mslg$l_cnt_id1

	integer*4	mslg$l_cnt_id2

	byte		mslg$b_cnt_svr

	byte		mslg$b_cnt_hvr

	integer*2	reserved2

	integer*4	mslg$l_bus_addr

	equivalence	(emb(38),mslg$l_cmd_ref)

	equivalence	(emb(42),reserved1)

	equivalence	(emb(44),mslg$w_seq_num)

	equivalence	(emb(46),mslg$b_format)

	equivalence	(emb(47),mslg$b_flags)

	equivalence	(emb(48),mslg$w_event)

	equivalence	(emb(50),mslg$l_cnt_id1)

	equivalence	(emb(54),mslg$l_cnt_id2)

	equivalence	(emb(58),mslg$b_cnt_svr)

	equivalence	(emb(59),mslg$b_cnt_hvr)

	equivalence	(emb(60),reserved2)

	equivalence	(emb(62),mslg$l_bus_addr)



	call linchk (lun,1)

	write(lun,10)
10	format(' ',:)

	call mslg$$l_cmd_ref (lun,mslg$l_cmd_ref)

	call mslg$$w_seq_num (lun,mslg$w_seq_num)

	call mslg$$b_format (lun,mslg$b_format)

	call mslg$$b_flags (lun,mslg$b_flags)

	call mslg$$w_event (lun,mslg$w_event)

	call mslg$$q_cnt_id (lun,mslg$l_cnt_id1,mslg$l_cnt_id2)

	call mslg$$b_cnt_svr (lun,mslg$b_cnt_svr)

	call mslg$$b_cnt_hvr (lun,mslg$b_cnt_hvr)

	call mslg$$l_bus_addr (lun,mslg$l_bus_addr)

	return

	end



	subroutine mslg$k_disk_trn (lun)



	include 'src$:msghdr.for /nolist'

	include 'src$:emblmdef.for /nolist'



	byte		lun

	integer*4	mslg$l_cmd_ref

	integer*2	mslg$w_unit

	integer*2	mslg$w_seq_num

	byte		mslg$b_format

	byte		mslg$b_flags

	integer*2	mslg$w_event

	integer*4	mslg$l_cnt_id1

	integer*4	mslg$l_cnt_id2

	byte		mslg$b_cnt_svr

	byte		mslg$b_cnt_hvr

	integer*2	mslg$w_mult_unt

	integer*4	mslg$l_unit_id1

	integer*4	mslg$l_unit_id2

	byte		mslg$b_unit_svr

	byte		mslg$b_unit_hvr

	byte		mslg$b_level

	byte		mslg$b_retry

	integer*4	mslg$l_vol_ser

	integer*4	mslg$l_header

	equivalence	(emb(38),mslg$l_cmd_ref)

	equivalence	(emb(42),mslg$w_unit)

	equivalence	(emb(44),mslg$w_seq_num)

	equivalence	(emb(46),mslg$b_format)

	equivalence	(emb(47),mslg$b_flags)

	equivalence	(emb(48),mslg$w_event)

	equivalence	(emb(50),mslg$l_cnt_id1)

	equivalence	(emb(54),mslg$l_cnt_id2)

	equivalence	(emb(58),mslg$b_cnt_svr)

	equivalence	(emb(59),mslg$b_cnt_hvr)

	equivalence	(emb(60),mslg$w_mult_unt)

	equivalence	(emb(62),mslg$l_unit_id1)

	equivalence	(emb(66),mslg$l_unit_id2)

	equivalence	(emb(70),mslg$b_unit_svr)

	equivalence	(emb(71),mslg$b_unit_hvr)

	equivalence	(emb(72),mslg$b_level)

	equivalence	(emb(73),mslg$b_retry)

	equivalence	(emb(74),mslg$l_vol_ser)

	equivalence	(emb(78),mslg$l_header)



	call linchk (lun,1)

	write(lun,10)
10	format(' ',:)

	call mslg$$l_cmd_ref (lun,mslg$l_cmd_ref)

	call mslg$$w_unit (lun,mslg$w_unit,.true.)

	call mslg$$w_seq_num (lun,mslg$w_seq_num)

	call mslg$$b_format (lun,mslg$b_format)

	call mslg$$b_flags (lun,mslg$b_flags)

	call mslg$$w_event (lun,mslg$w_event)

	call mslg$$q_cnt_id (lun,mslg$l_cnt_id1,mslg$l_cnt_id2)

	call mslg$$b_cnt_svr (lun,mslg$b_cnt_svr)

	call mslg$$b_cnt_hvr (lun,mslg$b_cnt_hvr)

	call mslg$$w_mult_unt (lun,mslg$w_mult_unt)

	call mslg$$q_unit_id (lun,mslg$l_unit_id1,mslg$l_unit_id2,.true.)

	call mslg$$b_unit_svr (lun,mslg$b_unit_svr)

	call mslg$$b_unit_hvr (lun,mslg$b_unit_hvr)

	call mslg$$b_level (lun,mslg$b_level)

	call mslg$$b_retry (lun,mslg$b_retry)

	call mslg$$l_vol_ser (lun,mslg$l_vol_ser)

	call mslg$$l_header (lun,mslg$l_header)

	return

	end



	subroutine mslg$k_sdi (lun)



	include 'src$:msghdr.for /nolist'

	include 'src$:emblmdef.for /nolist'



	byte		lun

	integer*4	mslg$l_cmd_ref

	integer*2	mslg$w_unit

	integer*2	mslg$w_seq_num

	byte		mslg$b_format

	byte		mslg$b_flags

	integer*2	mslg$w_event

	integer*4	mslg$l_cnt_id1

	integer*4	mslg$l_cnt_id2

	byte		mslg$b_cnt_svr

	byte		mslg$b_cnt_hvr

	integer*2	mslg$w_mult_unt

	integer*4	mslg$l_unit_id1

	integer*4	mslg$l_unit_id2

	byte		mslg$b_unit_svr

	byte		mslg$b_unit_hvr

	integer*2	reserved

	integer*4	mslg$l_vol_ser

	integer*4	mslg$l_header

	integer*4	mslg$l_sdi1

	integer*4	mslg$l_sdi2

	integer*4	mslg$l_sdi3

	equivalence	(emb(38),mslg$l_cmd_ref)

	equivalence	(emb(42),mslg$w_unit)

	equivalence	(emb(44),mslg$w_seq_num)

	equivalence	(emb(46),mslg$b_format)

	equivalence	(emb(47),mslg$b_flags)

	equivalence	(emb(48),mslg$w_event)

	equivalence	(emb(50),mslg$l_cnt_id1)

	equivalence	(emb(54),mslg$l_cnt_id2)

	equivalence	(emb(58),mslg$b_cnt_svr)

	equivalence	(emb(59),mslg$b_cnt_hvr)

	equivalence	(emb(60),mslg$w_mult_unt)

	equivalence	(emb(62),mslg$l_unit_id1)

	equivalence	(emb(66),mslg$l_unit_id2)

	equivalence	(emb(70),mslg$b_unit_svr)

	equivalence	(emb(71),mslg$b_unit_hvr)

	equivalence	(emb(72),reserved)

	equivalence	(emb(74),mslg$l_vol_ser)

	equivalence	(emb(78),mslg$l_header)

	equivalence	(emb(82),mslg$l_sdi1)

	equivalence	(emb(86),mslg$l_sdi2)

	equivalence	(emb(90),mslg$l_sdi3)




	call linchk (lun,1)

	write(lun,10)
10	format(' ',:)

	call mslg$$l_cmd_ref (lun,mslg$l_cmd_ref)

	call mslg$$w_unit (lun,mslg$w_unit,.true.)

	call mslg$$w_seq_num (lun,mslg$w_seq_num)

	call mslg$$b_format (lun,mslg$b_format)

	call mslg$$b_flags (lun,mslg$b_flags)

	call mslg$$w_event (lun,mslg$w_event)

	call mslg$$q_cnt_id (lun,mslg$l_cnt_id1,mslg$l_cnt_id2)

	call mslg$$b_cnt_svr (lun,mslg$b_cnt_svr)

	call mslg$$b_cnt_hvr (lun,mslg$b_cnt_hvr)

	call mslg$$w_mult_unt (lun,mslg$w_mult_unt)

	call mslg$$q_unit_id (lun,mslg$l_unit_id1,mslg$l_unit_id2,.true.)

	call mslg$$b_unit_svr (lun,mslg$b_unit_svr)

	call mslg$$b_unit_hvr (lun,mslg$b_unit_hvr)

	call mslg$$l_vol_ser (lun,mslg$l_vol_ser)

	call mslg$$l_header (lun,mslg$l_header)

	call mslg$$z_sdi (lun,mlsg$l_sdi1,mslg$l_sdi2,mslg$l_sdi3)

	return

	end



	subroutine mslg$k_sml_dsk (lun)



	include 'src$:msghdr.for /nolist'

	include 'src$:emblmdef.for /nolist'



	byte		lun

	integer*4	mslg$l_cmd_ref

	integer*2	mslg$w_unit

	integer*2	mslg$w_seq_num

	byte		mslg$b_format

	byte		mslg$b_flags

	integer*2	mslg$w_event

	integer*4	mslg$l_cnt_id1

	integer*4	mslg$l_cnt_id2

	byte		mslg$b_cnt_svr

	byte		mslg$b_cnt_hvr

	integer*2	mslg$w_mult_unt

	integer*4	mslg$l_unit_id1

	integer*4	mslg$l_unit_id2

	byte		mslg$b_unit_svr

	byte		mslg$b_unit_hvr

	integer*2	mslg$w_sde_cyl

	integer*4	mslg$l_vol_ser

	equivalence	(emb(38),mslg$l_cmd_ref)

	equivalence	(emb(42),mslg$w_unit)

	equivalence	(emb(44),mslg$w_seq_num)

	equivalence	(emb(46),mslg$b_format)

	equivalence	(emb(47),mslg$b_flags)

	equivalence	(emb(48),mslg$w_event)

	equivalence	(emb(50),mslg$l_cnt_id1)

	equivalence	(emb(54),mslg$l_cnt_id2)

	equivalence	(emb(58),mslg$b_cnt_svr)

	equivalence	(emb(59),mslg$b_cnt_hvr)

	equivalence	(emb(60),mslg$w_mult_unt)

	equivalence	(emb(62),mslg$l_unit_id1)

	equivalence	(emb(66),mslg$l_unit_id2)

	equivalence	(emb(70),mslg$b_unit_svr)

	equivalence	(emb(71),mslg$b_unit_hvr)

	equivalence	(emb(72),mslg$w_sde_cyl)

	equivalence	(emb(74),mslg$l_vol_ser)




	call linchk (lun,1)

	write(lun,10)
10	format(' ',:)

	call mslg$$l_cmd_ref (lun,mslg$l_cmd_ref)

	call mslg$$w_unit (lun,mslg$w_unit,.true.)

	call mslg$$w_seq_num (lun,mslg$w_seq_num)

	call mslg$$b_format (lun,mslg$b_format)

	call mslg$$b_flags (lun,mslg$b_flags)

	call mslg$$w_event (lun,mslg$w_event)

	call mslg$$q_cnt_id (lun,mslg$l_cnt_id1,mslg$l_cnt_id2)

	call mslg$$b_cnt_svr (lun,mslg$b_cnt_svr)

	call mslg$$b_cnt_hvr (lun,mslg$b_cnt_hvr)

	call mslg$$w_mult_unt (lun,mslg$w_mult_unt)

	call mslg$$q_unit_id (lun,mslg$l_unit_id1,mslg$l_unit_id2,.true.)

	call mslg$$b_unit_svr (lun,mslg$b_unit_svr)

	call mslg$$b_unit_hvr (lun,mslg$b_unit_hvr)

	call mslg$$w_sde_cyl (lun,mslg$w_sde_cyl)

	call mslg$$l_vol_ser (lun,mslg$l_vol_ser)

	return

	end



	subroutine mscp$$k_op_abort (lun,expand)



	include 'src$:msghdr.for /nolist'

	include 'src$:emblmdef.for /nolist'



	byte		lun

	logical*1	expand

	integer*4	mscp$l_cmd_ref

	integer*2	mscp$w_unit

	integer*2	reserved1

	byte		mscp$b_opcode

	byte		reserved2

	integer*2	mscp$w_modifier

	integer*4	mscp$l_out_ref

	equivalence	(emb(38),mscp$l_cmd_ref)

	equivalence	(emb(42),mscp$w_unit)

	equivalence	(emb(44),reserved1)

	equivalence	(emb(46),mscp$b_opcode)

	equivalence	(emb(47),reserved2)

	equivalence	(emb(48),mscp$w_modifier)

	equivalence	(emb(50),mscp$l_out_ref)




	entry mscp$$k_op_gtcmd (lun,expand)




	entry mscp$$k_op_gtunt (lun,expand)




	call linchk (lun,1)

	write(lun,5)
5	format(' ',:)

	call mscp_first_twelve_bytes1 (lun,expand)



	entry invalid_mscp$$k_op_abort (lun,expand)



	entry invalid_mscp$$k_op_gtcmd (lun,expand)




	entry invalid_mscp$$k_op_gtunt (lun,expand)




	if (mscp$b_opcode .eq. 3) goto 15

	call linchk (lun,1)

	write(lun,10) mscp$l_out_ref
10	format(' ',t8,'MSCP$L_OUT_REF',t24,z8.8)

15	return

	end



	subroutine mscp$$k_op_acces (lun,expand)



	include 'src$:msghdr.for /nolist'

	include 'src$:emblmdef.for /nolist'



	byte		lun

	logical*1	expand

	integer*4	mscp$l_cmd_ref

	integer*2	mscp$w_unit

	integer*2	reserved1

	byte		mscp$b_opcode

	byte		reserved2

	integer*2	mscp$w_modifier

	integer*4	mscp$l_byte_cnt
	integer*4	mscp$l_rbn

	integer*4	reserved3(3)
	integer*4	mscp$z_buffer(3)

	integer*4	mscp$l_lbn

	equivalence	(emb(38),mscp$l_cmd_ref)

	equivalence	(emb(42),mscp$w_unit)

	equivalence	(emb(44),reserved1)

	equivalence	(emb(46),mscp$b_opcode)

	equivalence	(emb(47),reserved2)

	equivalence	(emb(48),mscp$w_modifier)

	equivalence	(emb(50),mscp$l_byte_cnt)
	equivalence	(emb(50),mscp$l_rbn)

	equivalence	(emb(54),reserved3)
	equivalence	(emb(54),mscp$z_buffer)

	equivalence	(emb(66),mscp$l_lbn)

	integer*4	compress4



	entry mscp$$k_op_cmpcd (lun,expand)



	entry mscp$$k_op_comp (lun,expand)



	entry mscp$$k_op_erase (lun,expand)



	entry mscp$$k_op_flush (lun,expand)



	entry mscp$$k_op_read (lun,expand)



	entry mscp$$k_op_replc (lun,expand)



	entry mscp$$k_op_write (lun,expand)



	call linchk (lun,1)

	write(lun,5)
5	format(' ',:)

	call mscp_first_twelve_bytes1 (lun,expand)




	entry invalid_mscp$$k_op_acces (lun,expand)



	entry invalid_mscp$$k_op_cmpcd (lun,expand)



	entry invalid_mscp$$k_op_comp (lun,expand)



	entry invalid_mscp$$k_op_erase (lun,expand)



	entry invalid_mscp$$k_op_flush (lun,expand)



	entry invalid_mscp$$k_op_read (lun,expand)




	entry invalid_mscp$$k_op_replc (lun,expand)



	entry invalid_mscp$$k_op_write (lun,expand)



	call linchk (lun,1)

	if (mscp$b_opcode .eq. 20) then

	write(lun,7) mscp$l_rbn
7	format(' ',t8,'MSCP$L_RBN',t24,z8.8)

	if (expand) then

	call linchk (lun,1)

	write(lun,8) mscp$l_rbn
8	format(' ',t40,'REPLACEMENT BLOCK #',i<compress4 (mscp$l_rbn)>,'.')
	endif
	else

	write(lun,10) mscp$l_byte_cnt
10	format(' ',t8,'MSCP$L_BYTE_CNT',t24,z8.8)

	if (expand) then

	call linchk (lun,1)

	write(lun,11) mscp$l_byte_cnt
11	format(' ',t40,'BYTE COUNT, ',i<compress4 (mscp$l_byte_cnt)>,
	1 '. BYTE(S)')
	endif
	endif

	if (
	1 mscp$b_opcode .eq. 32
	1 .or.
	1 mscp$b_opcode .eq. 33
	1 .or.
	1 mscp$b_opcode .eq. 34
	1 ) then

	call mscp$$z_buffer (lun,mscp$z_buffer)
	else

	call mscp_reservedq (lun,reserved3)

	call linchk (lun,4)

	write(lun,15) reserved3(3)
15	format(' ',t24,z8.8)
	endif

	call linchk (lun,1)

	write(lun,20) mscp$l_lbn
20	format(' ',t8,'MSCP$L_LBN',t24,z8.8)

	if (expand) then

	call linchk (lun,1)

	write(lun,22) mscp$l_lbn
22	format(' ',t40,'LOGICAL BLOCK #',i<compress4 (mscp$l_lbn)>,'.')
	endif

	return

	end



	subroutine mscp$$k_op_avail (lun,expand)



	include 'src$:msghdr.for /nolist'

	include 'src$:emblmdef.for /nolist'



	byte		lun

	logical*1	expand

	integer*4	mscp$l_cmd_ref

	integer*2	mscp$w_unit

	integer*2	reserved1

	byte		mscp$b_opcode

	byte		reserved2

	integer*2	mscp$w_modifier

	equivalence	(emb(38),mscp$l_cmd_ref)

	equivalence	(emb(42),mscp$w_unit)

	equivalence	(emb(44),reserved1)

	equivalence	(emb(46),mscp$b_opcode)

	equivalence	(emb(47),reserved2)

	equivalence	(emb(48),mscp$w_modifier)



	entry mscp$$k_op_dtacp (lun,expand)



	call linchk (lun,1)

	write(lun,5)
5	format(' ',:)

	call mscp_first_twelve_bytes1 (lun,expand)



	entry invalid_mscp$$k_op_avail (lun,expand)



	entry invalid_mscp$$k_op_dtacp (lun,expand)



	return

	end



	subroutine mscp$$k_op_onlin (lun,expand)



	include 'src$:msghdr.for /nolist'

	include 'src$:emblmdef.for /nolist'



	byte		lun

	logical*1	expand

	integer*4	mscp$l_cmd_ref

	integer*2	mscp$w_unit

	integer*2	reserved1

	byte		mscp$b_opcode

	byte		reserved2

	integer*2	mscp$w_modifier

	integer*2	reserved3

	integer*2	mscp$w_unt_flgs

	integer*4	reserved4(3)

	integer*4	mscp$l_dev_parm

	integer*2	mscp$w_shdw_unt

	integer*2	mscp$w_copy_spd

	equivalence	(emb(38),mscp$l_cmd_ref)

	equivalence	(emb(42),mscp$w_unit)

	equivalence	(emb(44),reserved1)

	equivalence	(emb(46),mscp$b_opcode)

	equivalence	(emb(47),reserved2)

	equivalence	(emb(48),mscp$w_modifier)

	equivalence	(emb(50),reserved3)

	equivalence	(emb(52),mscp$w_unt_flgs)

	equivalence	(emb(54),reserved4)

	equivalence	(emb(66),mscp$l_dev_parm)

	equivalence	(emb(70),mscp$w_shdw_unt)

	equivalence	(emb(72),mscp$w_copy_spd)




	entry mscp$$k_op_stunt (lun,expand)




	call linchk (lun,1)

	write(lun,5)
5	format(' ',:)

	call mscp_first_twelve_bytes1 (lun,expand)



	entry invalid_mscp$$k_op_onlin (lun,expand)



	entry invalid_mscp$$k_op_stunt (lun,expand)



	call mscp$$w_unt_flgs (lun,mscp$w_unt_flgs,expand)

	call mscp_reservedq (lun,reserved4)

	call linchk (lun,1)

	write(lun,10) reserved4(3)
10	format(' ',t24,z8.8)

	call mscp$$l_dev_parm (lun,mscp$l_dev_parm)

	call mscp$$w_shdw_unt (lun,mscp$w_shdw_unt,expand)

	call mscp$$w_copy_spd (lun,mscp$w_copy_spd)

	return

	end



	subroutine mscp$$k_op_stcon (lun,expand)



	include 'src$:msghdr.for /nolist'

	include 'src$:emblmdef.for /nolist'



	byte		lun

	logical*1	expand

	integer*4	mscp$l_cmd_ref

	integer*2	mscp$w_unit

	integer*2	reserved1

	byte		mscp$b_opcode

	byte		reserved2

	integer*2	mscp$w_modifier

	integer*2	mscp$w_version

	integer*2	mscp$w_cnt_flgs

	integer*2	mscp$w_hst_tmo

	integer*2	reserved3

	integer*4	mscp$l_time1

	integer*4	mscp$l_time2

	equivalence	(emb(38),mscp$l_cmd_ref)

	equivalence	(emb(42),mscp$w_unit)

	equivalence	(emb(44),reserved1)

	equivalence	(emb(46),mscp$b_opcode)

	equivalence	(emb(47),reserved2)

	equivalence	(emb(48),mscp$w_modifier)

	equivalence	(emb(50),mscp$w_version)

	equivalence	(emb(52),mscp$w_cnt_flgs)

	equivalence	(emb(54),mscp$w_hst_tmo)

	equivalence	(emb(56),reserved3)

	equivalence	(emb(58),mscp$l_time1)

	equivalence	(emb(60),mscp$l_time2)



	call linchk (lun,1)

	write(lun,5)
5	format(' ',:)

	call mscp_first_twelve_bytes1 (lun,expand)



	entry invalid_mscp$$k_op_stcon (lun,expand)



	call mscp$$w_version (lun,mscp$w_version)

	call mscp$$w_cnt_flgs (lun,mscp$w_cnt_flgs,expand)

	call mscp$$w_hst_tmo (lun,mscp$w_hst_tmo,expand)

	call mscp_reservedw (lun,reserved3)

	call mscp$$q_time (lun,mscp$l_time1,expand)

	return

	end



	subroutine mslg$$l_cmd_ref (lun,command_reference_number)



	byte		lun

	integer*4	command_reference_number



	call linchk (lun,1)

	write(lun,10) command_reference_number
10	format(' ',t8,'MSLG$L_CMD_REF',t24,z8.8)

	return



	entry mscp$$l_cmd_ref (lun,command_reference_number)



	call linchk (lun,1)

	write(lun,15) command_reference_number
15	format(' ',t8,'MSCP$L_CMD_REF',t24,z8.8)

	return

	end



	subroutine mslg$$w_unit (lun,unit_number,expand)



	byte		lun

	integer*2	unit_number

	logical*1	expand

	integer*4	unit

	integer*4	compress4


	call linchk (lun,2)

	write(lun,10) 'MSLG$W_UNIT',unit_number
10	format(' ',t8,a,t28,z4.4)

15	if (expand) then

	unit = lib$extzv(0,16,unit_number)

	write(lun,20) unit
20	format(' ',t40,'UNIT #',i<compress4 (unit)>,'.')
	endif

	return



	entry mscp$$w_unit (lun,unit_number,expand)



	call linchk (lun,2)

	write(lun,10) 'MSCP$W_UNIT',unit_number

	goto 15

	end



	subroutine mslg$$w_seq_num (lun,sequence_number)



	byte		lun

	integer*2	sequence_number

	integer*4	sequence

	integer*4	compress4



	call linchk (lun,2)

	write(lun,10) sequence_number
10	format(' ',t8,'MSLG$W_SEQ_NUM',t28,z4.4)

	sequence = lib$extzv(0,16,sequence_number)

	write(lun,20) sequence
20	format(' ',t40,'SEQUENCE #',i<compress4 (sequence)>,'.')

	return

	end



	subroutine mslg$$b_format (lun,format)



	byte		lun

	byte		format

	integer*4	message_format

	integer*4	compress4


	call linchk (lun,2)

	write(lun,10) format
10	format(' ',t8,'MSLG$B_FORMAT',t30,z2.2)

	message_format = lib$extzv(0,8,format)

	if (message_format .eq. 0) then

	write(lun,20) 'CONTROLLER ERROR'
20	format(' ',t40,a)

	else if (message_format .eq. 1) then

	write(lun,20) 'HOST MEMORY ACCESS ERROR'

	else if (message_format .eq. 2) then

	write(lun,20) 'DISK TRANSFER ERROR'

	else if (message_format .eq. 3) then

	write(lun,20) '"SDI" ERROR'

	else if (message_format .eq. 4) then

	write(lun,20) '"SMALL DISK" ERROR'
	else

	write(lun,25) message_format
25	format(' ',t40,'FORMAT #',i<compress4 (message_format)>,'.')
	endif

	return

	end



	subroutine mslg$$b_flags (lun,error_log_message_flags)



	byte		lun

	byte		error_log_message_flags

	character*22	v1error_log_message_flags(0:0)

	data		v1error_log_message_flags(0) /'SEQUENCE NUMBER RESET*'/

	character*21	v2error_log_message_flags(6:7)

	data		v2error_log_message_flags(6) /'OPERATION CONTINUING*'/

	data		v2error_log_message_flags(7) /'OPERATION SUCCESSFUL*'/



	call linchk (lun,1)

	write(lun,10) error_log_message_flags
10	format(' ',t8,'MSLG$B_FLAGS',t30,z2.2)

	call output (lun,lib$extzv(0,8,error_log_message_flags),
	1 v1error_log_message_flags,0,0,0,'0')

	call output (lun,lib$extzv(0,8,error_log_message_flags),
	1 v2error_log_message_flags,6,6,7,'0')

	return

	end



	subroutine mscp$$b_flags (lun,end_message_flags,expand)



	byte		lun

	byte		end_message_flags

	logical*1	expand

	character*21	v1end_message_flags(4:7)

	data		v1end_message_flags(4)	/'SERIOUS EXCEPTION*'/

	data		v1end_message_flags(5)	/'ERROR LOG GENERATED*'/

	data		v1end_message_flags(6)	/'BAD BLOCK UNREPORTED*'/

	data		v1end_message_flags(7)	/'BAD BLOCK REPORTED*'/



	call linchk (lun,1)

	write(lun,10) end_message_flags
10	format(' ',t8,'MSCP$B_FLAGS',t30,z2.2)

	if (expand) then

	call output (lun,end_message_flags,v1end_message_flags,4,4,7,'0')
	endif

	return

	end



	subroutine mslg$$w_event (lun,event_code)



	byte		lun

	integer*2	event_code

	integer*4	code

	integer*4	sub_code

	integer*4	compress4

	logical*1	valid_subcode




	call linchk (lun,1)

	write(lun,10) event_code
10	format(' ',t8,'MSLG$W_EVENT',t28,z4.4)

	code = lib$extzv(0,5,event_code)

	sub_code = lib$extzv(5,11,event_code)

	valid_subcode = .false.

	call linchk (lun,1)

	if (code .eq. 0) then

	write(lun,10) 'SUCCESS'
15	format(' ',t40,a)

	call linchk (lun,1)

	if (sub_code .eq. 0) then

	write(lun,15) 'NORMAL'

	valid_subcode = .true.
	else

	if (lib$extzv(0,1,sub_code) .eq. 1) then

	write(lun,15) 'SPIN-DOWN IGNORED'

	valid_subcode = .true.
	endif

	if (lib$extzv(1,1,sub_code) .eq. 1) then

	write(lun,15) 'STILL CONNECTED'

	valid_subcode = .true.
	endif

	if (lib$extzv(2,1,sub_code) .eq. 1) then

	write(lun,15) 'DUPLICATE UNIT #'

	valid_subcode = .true.
	endif

	if (lib$extzv(3,1,sub_code) .eq. 1) then

	write(lun,15) 'ALREADY ON-LINE'

	valid_subcode = .true.
	endif

	if (lib$extzv(4,1,sub_code) .eq. 1) then

	write(lun,15) 'STILL ON-LINE'

	valid_subcode = .true.
	endif
	endif

	if (.not. valid_subcode) then

	write(lun,19) sub_code
	endif

	else if (code .eq. 1) then

	write(lun,15) 'INVALID COMMAND'

	call linchk (lun,1)

	if (sub_code .eq. 0) then

	write(lun,15) 'INVALID MESSAGE LENGTH'
	else

	call linchk (lun,1)

	write(lun,15) 'INVALID MESSAGE FIELD'

	write(lun,19) sub_code
	endif

	else if (code .eq. 2) then

	write(lun,15) 'COMMAND ABORTED'

	else if (code .eq. 3) then

	write(lun,15) 'UNIT-OFFLINE'

	call linchk (lun,1)

	if (sub_code .eq. 0) then

	write(lun,15) 'UNIT UNKNOWN OR NOT AVAILABLE'

	valid_subcode = .true.
	else
	
	if (lib$extzv(0,1,sub_code) .eq. 1) then

	write(lun,15) 'KNOWN SUB-STATE OF "UNIT-OFFLINE"'

	valid_subcode = .true.
	endif

	if (lib$extzv(1,1,sub_code) .eq. 1) then

	write(lun,15) 'UNIT IS INOPERATIVE'

	valid_subcode = .true.
	endif

	if (lib$extzv(2,1,sub_code) .eq. 1) then

	write(lun,15) 'DUPLICATE UNIT #'

	valid_subcode = .true.
	endif

	if (lib$extzv(3,1,sub_code) .eq. 1) then

	write(lun,15) 'UNIT DISABLED'

	valid_subcode = .true.
	endif
	endif

	if (.not. valid_subcode) then

	write(lun,19) sub_code
	endif

	else if (code .eq. 4) then

	write(lun,15) 'UNIT-AVAILABLE'

	else if (code .eq. 5) then

	write(lun,15) 'MEDIA FORMAT ERROR'

	if (sub_code .ne. 0) then

	call linchk (lun,1)

	if (sub_code .eq. 1) then

	write(lun,15) 'FCT UNREADABLE, EDC ERROR'

	else if (sub_code .eq. 2) then

	write(lun,15) 'FCT UNREADABLE, INVALID HEADER'

	else if (sub_code .eq. 3) then

	write(lun,15) 'FCT UNREADABLE, DATA SYNC TIMEOUT'

	else if (sub_code .eq. 5) then

	write(lun,15) 'FORMAT NOT 512 BYTE SECTORS'

	else if (sub_code .eq. 6) then

	write(lun,15) 'NOT FORMATTED, FCT CORRUPT'

	else if (sub_code .eq. 7) then

	write(lun,15) 'FCT UNREADABLE, HARD ECC ERROR'
	else

	write(lun,19) sub_code
	endif
	endif

	else if (code .eq. 6) then

	write(lun,15) 'WRITE PROTECTED'

	if (sub_code .ne. 0) then

	call linchk (lun,1)

	if (lib$extzv(7,1,sub_code) .eq. 1) then

	write(lun,15) 'UNIT SOFTWARE WRITE PROTECTED'

	valid_subcode = .true.
	endif

	if (lib$extzv(8,1,sub_code) .eq. 1) then

	write(lun,15) 'UNIT HARDWARE WRITE PROTECTED'

	valid_subcode = .true.
	endif

	if (.not. valid_subcode) then

	write(lun,19) sub_code
	endif
	endif

	else if (code .eq. 7) then

	write(lun,15) 'COMPARE ERROR'

	else if (code .eq. 8) then

	write(lun,15) 'DATA ERROR'

	if (sub_code .ne. 0) then

	call linchk (lun,1)

	if (sub_code .eq. 2) then

	write(lun,15) 'HEADER COMPARE ERROR'

	else if (sub_code .eq. 3) then

	write(lun,15) 'DATA SYNC NOT FOUND'

	else if (sub_code .eq. 7) then

	write(lun,15) 'UNCORRECTABLE "ECC" ERROR'

	else if (
	1 sub_code .ge. 8
	1 .and.
	1 sub_code .le. 15
	1 ) then

	write(lun,17) sub_code,'. SYMBOL "ECC" ERROR'
17	format(' ',t40,i<compress4 (sub_code)>,a)
	else

	write(lun,19) sub_code
19	format(' ',t40,'EVENT SUB-CODE ',i<compress4 (sub_code)>,'.')
	endif
	endif

	else if (code .eq. 9) then

	write(lun,15) 'HOST BUFFER ACCESS ERROR'

	if (sub_code .ne. 0) then

	call linchk (lun,1)

	if (sub_code .eq. 1) then

	write(lun,15) 'ODD TRANSFER ADDRESS'

	else if (sub_code .eq. 2) then

	write(lun,15) 'ODD BYTE COUNT'

	else if (sub_code .eq. 3) then

	write(lun,15) 'NON-EXISTENT MEMORY ERROR'

	else if (sub_code .eq. 4) then

	write(lun,15) 'HOST MEMORY PARITY ERROR'
	else

	write(lun,19) sub_code
	endif
	endif

	else if (code .eq. 10) then

	write(lun,15) 'CONTROLLER ERROR'

	if (sub_code .ne. 0) then


	call linchk (lun,1)

	if (sub_code .eq. 1) then

	write(lun,15) '"SERDES" OVERRUN ERROR'

	else if (sub_code .eq. 2) then

	write(lun,15) '"EDC" ERROR'

	else if (sub_code .eq. 3) then

	write(lun,15) 'INTERNAL DATA-STRUCTURE ERROR'
	else

	write(lun,19) sub_code
	endif
	endif

	else if (code .eq. 11) then

	write(lun,15) 'DRIVE ERROR'

	if (sub_code .ne. 0) then

	call linchk (lun,1)

	if (sub_code .eq. 1) then

	write(lun,15) '"SDI" COMMAND TIMEOUT'

	else if (sub_code .eq. 2) then

	write(lun,15) 'CONTROLLER DETECTED "SDI" ERROR'

	else if (sub_code .eq. 3) then

	write(lun,15) 'POSITIONER ERROR'

	else if (sub_code .eq. 4) then

	write(lun,15) 'LOST "R/W READY", (TRANSFER)'

	else if (sub_code .eq. 5) then

	write(lun,15) 'DRIVE CLOCK DROPOUT'

	else if (sub_code .eq. 6) then

	write(lun,15) 'LOST "RECEIVER READY", (TRANSFER)'

	else if (sub_code .eq. 7) then

	write(lun,15) 'DRIVE DETECTED ERROR'

	else if (sub_code .eq. 8) then

	write(lun,15) 'PULSE OR STATE PARITY ERROR'
	else

	write(lun,19) sub_code
	endif

	endif
	else

	write(lun,20) 'EVENT CODE ',code
20	format(' ',t40,a,i<compress4 (code)>,'.')
	endif

	return

	end



	subroutine mslg$$q_cnt_id (lun,controller_id1,controller_id2)



	byte		lun

	integer*4	controller_id1

	integer*4	controller_id2

	integer*4	unique_identifier_high

	integer*4	class

	integer*4	model

	character*24	subsystem_class(3)

	data		subsystem_class(1)	/'MASS STORAGE CONTROLLER*'/

	data		subsystem_class(2)	/'DISK CLASS DEVICE*'/

	data		subsystem_class(3)	/'TAPE CLASS DEVICE*'/

	character*6	class_model(2)

	data		class_model(1)		/'HSC50*'/

	data		class_model(2)		/'UDA50*'/

	integer*4	compressc



	call linchk (lun,2)

	write(lun,10) controller_id1,controller_id2
10	format(' ',t8,'MSLG$Q_CNT_ID',t24,z8.8,/,t24,z8.8)

	unique_identifier_high = lib$extzv (0,16,controller_id2)

	call linchk (lun,1)

	write(lun,15) unique_identifier_high,controller_id1
15	format(' ',t40,'UNIQUE IDENTIFIER, ',z4.4,z8.8)

	class = lib$extzv(24,8,controller_id2)

	model = lib$extzv(16,8,controller_id2)

	if (
	1 class .gt. 0
	1 .and.
	1 class .le. 3
	1 ) then

	call linchk (lun,1)

	write(lun,20) subsystem_class(class)
20	format(' ',t40,a<compressc (subsystem_class(class))>)
	endif

	if (
	1 model .gt. 0
	1 .and.
	1 model .le. 2
	1 ) then

	call linchk (lun,1)

	write(lun,25) class_model(model)
25	format(' ',t40,a<compressc (class_model(model))>)
	endif

	return

	end



	subroutine mslg$$b_cnt_svr (lun,controller_software_version)



	byte		lun

	byte		controller_software_version

	integer*4	compress4



	call linchk (lun,2)

	write(lun,10) (controller_software_version,i = 1,2)
10	format(' ',t8,'MSLG$B_CNT_SVR',t30,z2.2,/,
	1 t40,'CONTROLLER SOFTWARE VERSION #',
	1 i<compress4 (lib$extzv(0,8,controller_software_version))>,'.')

	return

	end



	subroutine mslg$$b_cnt_hvr (lun,controller_hardware_version)



	byte		lun

	byte		controller_hardware_version

	integer*4	compress4



	call linchk (lun,2)

	write(lun,10) (controller_hardware_version,i = 1,2)
10	format(' ',t8,'MSLG$B_CNT_HVR',t30,z2.2,/,
	1 t40,'CONTROLLER HARDWARE REVISION #',
	1 i<compress4 (lib$extzv(0,8,controller_hardware_version))>,'.')

	return

	end



	subroutine mslg$$w_mult_unt (lun,multi_unit_code)



	byte		lun

	integer*2	multi_unit_code



	call linchk (lun,1)

	write(lun,10) 'MSLG$W_MULT_UNT',multi_unit_code
10	format(' ',t8,a,t28,z4.4)

	return



	entry mscp$$w_mult_unt (lun,multi_unit_code)



	call linchk (lun,1)

	write(lun,10) 'MSCP$W_MULT_UNT',multi_unit_code

	return

	end



	subroutine mslg$$q_unit_id (lun,unit_id1,unit_id2,expand)



	byte		lun

	integer*4	unit_id1

	integer*4	unit_id2

	logical*1	expand

	integer*4	class

	integer*4	model

	integer*4	unique_identifier_high

	integer*4	compressc

	character*24	subsystem_class(3)

	data		subsystem_class(1)	/'MASS STORAGE CONTROLLER*'/

	data		subsystem_class(2)	/'DISK CLASS DEVICE*'/

	data		subsystem_class(3)	/'TAPE CLASS DEVICE*'/




	call linchk (lun,2)

	write(lun,5) 'MSLG$Q_UNIT_ID',unit_id1,unit_id2
5	format(' ',t8,a,t24,z8.8,/,t24,z8.8)

10	if (expand) then

	unique_identifier_high = lib$extzv (0,16,unit_id2)

	call linchk (lun,1)

	write(lun,15) unique_identifier_high,unit_id1
15	format(' ',t40,'UNIQUE IDENTIFIER, ',z4.4,z8.8)

	class = lib$extzv(24,8,unit_id2)

	model = lib$extzv(16,8,unit_id2)

	if (
	1 class .gt. 0
	1 .and.
	1 class .le. 3
	1 ) then

	call linchk (lun,1)

	write(lun,20) subsystem_class(class)
20	format(' ',t40,a<compressc (subsystem_class(class))>)
	endif

	if (model .eq. 1) then

	call linchk (lun,1)

	write(lun,25) 'RA80'
25	format(' ',t40,a)

	else if (model .eq. 5) then

	call linchk (lun,1)

	write(lun,25) 'RA81'
	endif
	endif

	return




	entry mscp$$q_unit_id (lun,unit_id1,unit_id2,expand)




	call linchk (lun,2)

	write(lun,5) 'MSCP$Q_UNIT_ID',unit_id1,unit_id2

	goto 10

	end



	subroutine mslg$$b_unit_svr (lun,unit_software_version)



	byte		lun

	byte		unit_software_version

	integer*4	compress4



	call linchk (lun,2)

	write(lun,10) (unit_software_version,i = 1,2)
10	format(' ',t8,'MSLG$B_UNIT_SVR',t30,z2.2,/,
	1 t40,'UNIT SOFTWARE VERSION #',
	1 i<compress4 (lib$extzv(0,8,unit_software_version))>,'.')

	return

	end



	subroutine mslg$$b_unit_hvr (lun,unit_hardware_version)



	byte		lun

	byte		unit_hardware_version

	integer*4	compress4



	call linchk (lun,2)

	write(lun,10) (unit_hardware_version,i = 1,2)
10	format(' ',t8,'MSLG$B_UNIT_HVR',t30,z2.2,/,
	1 t40,'UNIT HARDWARE REVISION #',
	1 i<compress4 (lib$extzv(0,8,unit_hardware_version))>,'.')

	return

	end



	subroutine mslg$$l_vol_ser (lun,volume_serial_number)



	byte		lun

	integer*4	volume_serial_number

	integer*4	compress4



	call linchk (lun,2)

	write(lun,10) (volume_serial_number,i = 1,2)
10	format(' ',t8,'MSLG$L_VOL_SER',t24,z8.8,/,
	1 t40,'VOLUME SERIAL #',i<compress4 (volume_serial_number)>,'.')

	return

	end



	subroutine mslg$$l_bus_addr (lun,bus_address)



	byte		lun

	integer*4	bus_address



	call linchk (lun,1)

	write(lun,10) bus_address
10	format(' ',t8,'MSLG$L_BUS_ADDR',t24,z8.8)

	call calc_map (lun,16,bus_address,bus_address)

	return

	end



	subroutine mslg$$b_level (lun,level)



	byte		lun

	byte		level



	call linchk (lun,1)

	write(lun,10) level
10	format(' ',t8,'MSLG$B_LEVEL',t30,z2.2)

	return

	end



	subroutine mslg$$b_retry (lun,retry)



	byte		lun

	byte		retry



	call linchk (lun,1)

	write(lun,10) retry
10	format(' ',t8,'MSLG$B_RETRY',t30,z2.2)

	return

	end



	subroutine mslg$$z_sdi (lun,sdi1,sdi2,sdi3)



	include 'src$:msghdr.for /nolist'

	include 'src$:emblmdef.for /nolist'



	byte		lun

	integer*4	sdi1

	integer*4	sdi2

	integer*4	sdi3

	integer*4	c_flags

	integer*4	retry_count

	logical*1	init_diagnostic_failure

	integer*4	previous_command

	integer*4	cylinder_low

	integer*4	cylinder_high

	integer*4	cylinder

	integer*4	current_group

	integer*4	led_display_code

	integer*4	front_panel_fault_code

	integer*4	compress4

	character*19	v1generic_sdi_status(0:1)

	data		v1generic_sdi_status(0)
	1 /'RUN/STOP SWITCH IN*'/

	data		v1generic_sdi_status(1)
	1 /'PORT SWITCH IN*'/

	character*33	v2generic_sdi_status(3:15)

	data		v2generic_sdi_status(3)
	1 /'LOG INFORMATION IN EXTENDED AREA*'/

	data		v2generic_sdi_status(4)
	1 /'SPINDLE READY*'/

	data		v2generic_sdi_status(5)
	1 /'DIAGNOSTIC LOAD REQUEST*'/

	data		v2generic_sdi_status(6)
	1 /'RE-ADJUSTMENT REQUESTED*'/

	data		v2generic_sdi_status(7)
	1 /'DRIVE UNAVAILABLE, BUT ONLINE*'/

	data		v2generic_sdi_status(8)
	1 /'576 BYTE SECTOR*'/

	data		v2generic_sdi_status(9)
	1 /'DIAG. CYLINDER ACCESS ENABLED*'/

	data		v2generic_sdi_status(10)
	1 /'FORMATTING OPERATIONS ENABLED*'/

	data		v2generic_sdi_status(11)
	1 /'FAULT*'/

	data		v2generic_sdi_status(12)
	1 /'WRITE PROTECT, UNIT #0.*'/

	data		v2generic_sdi_status(13)
	1 /'WRITE PROTECT, UNIT #1.*'/

	data		v2generic_sdi_status(14)
	1 /'WRITE PROTECT, UNIT #2.*'/

	data		v2generic_sdi_status(15)
	1 /'WRITE PROTECT, UNIT #3.*'/

	character*34	v3generic_sdi_status(19:23)

	data		v3generic_sdi_status(19)
	1 /'WRITE LOCK ERROR*'/

	data		v3generic_sdi_status(20)
	1 /'INITIALIZATION DIAGNOSTIC FAILURE*'/

	data		v3generic_sdi_status(21)
	1 /'LEVEL 2 PROTOCOL ERROR*'/

	data		v3generic_sdi_status(22)
	1 /'TRANSMISSION ERROR*'/

	data		v3generic_sdi_status(23)
	1 /'DRIVE ERROR*'/

	character*33	v1ra8x_interface_error_status(3:5)

	data		v1ra8x_interface_error_status(3)
	1 /'OVERRUN ERROR*'/

	data		v1ra8x_interface_error_status(4)
	1 /'CONTROL R/T STATUS, PARITY ERROR*'/

	data		v1ra8x_interface_error_status(5)
	1 /'CONTROL PULSE ERROR*'/

	character*17	v2ra8x_interface_error_status(7:7)

	data		v2ra8x_interface_error_status(7)
	1 /'DATA PULSE ERROR*'/




	call linchk (lun,3)

	write(lun,10) sdi1,sdi2,sdi3
10	format(' ',t8,'MSLG$Z_SDI',t24,z8.8,/,t24,z8.8,/,t24,z8.8)

	call output (lun,sdi1,v1generic_sdi_status,0,0,1,'0')

	call output (lun,sdi1,v2generic_sdi_status,3,3,15,'0')

	call output (lun,sdi1,v3generic_sdi_status,19,19,23,'0')

	c_flags = lib$extzv(24,4,sdi1)

	if (c_flags .eq. 8) then

	call linchk (lun,1)

	write(lun,15) '"DIAGNOSTICS"'
15	format(' ',t40,'DRIVE-OFFLINE, ',a)

	else if (c_flags .eq. 9) then

	call linchk (lun,1)

	write(lun,15) 'DUPLICATE UNIT IDENT'
	endif

	do 25,i = 28,31

	if (lib$extzv(i,1,sdi1) .eq. 1) then

	call linchk (lun,1)

	write(lun,20) 'SEND "MSCP" AVAILABLE SUB-UNIT #',28-i,'.'
20	format(' ',t40,a,i<compress4 (28-i)>,a)
	endif

25	continue

	if (lib$extzv (20,1,sdi1) .eq. 1) then

	init_diagnostic_failure = .true.
	else

	init_diagnostic_failure = .false.
	endif

	retry_count = lib$extzv (0,8,sdi2)

	call linchk (lun,1)

	if (.not. init_diagnostic_failure) then

	write(lun,30) 'RETRY COUNT ',retry_count
30	format(' ',t40,a,i<compress4 (retry_count)>,'.')
	else

	write(lun,32) 'FAILURE CODE ',retry_count,' (HEX)'
32	format(' ',t40,a,i<compress4 (retry_count)>,a)
	endif

c
c	ra80, ra81
c

	if (
	1 emb$b_lm_class .eq. 1
	1 .and.
	1 (emb$b_lm_type .eq. 20
	1 .or.
	1 emb$b_lm_type .eq. 21)
	1 ) then

	if (.not. init_diagnostic_failure) then

	if (retry_count .ne. 0) then

	previous_command = lib$extzv (8,8,sdi2)

	if (previous_command .eq. '8e'x) then

	call linchk (lun,1)

	write(lun,34) 'RECALIBRATE'
34	format(' ',t40,a)

	else if (previous_command .eq. '0a'x) then

	call linchk (lun,1)

	write(lun,34) 'SEEK'
	endif
	endif
	endif

	call output (lun,sdi2,v1ra8x_interface_error_status,3,3,5,'0')

	call output (lun,sdi2,v2ra8x_interface_error_status,7,7,7,'0')

	if (
	1 .not. init_diagnostic_failure
	1 .and.
	1 retry_count .ne. 0
	1 .and.
	1 (previous_command .eq. '8e'x
	1 .or.
	1 previous_command .eq. '0a'x)
	1 ) then

	cylinder_low = lib$extzv (24,8,sdi2)

	cylinder_high = lib$extzv (0,8,sdi3)

	cylinder = (cylinder_high*256) + cylinder_low

	call linchk (lun,1)

	write(lun,40) cylinder
40	format(' ',t40,'CYLINDER #',i<compress4 (cylinder)>,'.')

	current_group = lib$extzv (16,8,sdi3)

	call linchk (lun,1)

	write(lun,45) current_group
45	format(' ',t40,'CURRENT GROUP #',i<compress4 (current_group)>,'.')
	endif

	led_display_code = lib$extzv (16,8,sdi3)

	call linchk (lun,1)

	write(lun,50) led_display_code
50	format(' ',t40,'"LED" DISPLAY CODE, ',z2.2,' (HEX)')

	front_panel_fault_code = lib$extzv (24,8,sdi3)

	call linchk (lun,1)

c
c	ra80
c

	if (emb$b_lm_type .eq. 20) then

	if (front_panel_fault_code .eq. '14'x) then

	write(lun,55) 'R/W DIAGNOSTIC ERROR (SPIN-UP)'
55	format(' ',t40,a)

	else if (front_panel_fault_code .eq. '16'x) then

	write(lun,55) 'SPINDLE MOTOR INTERLOCK'

	else if (front_panel_fault_code .eq. '18'x) then

	write(lun,55) 'SPIN-UP ERROR'

	else if (front_panel_fault_code .eq. '1c'x) then

	write(lun,55) 'R/W UNSAFE'

	else if (front_panel_fault_code .eq. '1e'x) then

	write(lun,55) 'SPINDLE MOTOR SPEED ERROR'

	else if (front_panel_fault_code .eq. '34'x) then

	write(lun,55) 'HDA OR SERVO BOARD OVER-TEMP'

	else if (front_panel_fault_code .eq. '36'x) then

	write(lun,55) 'INITIAL RECAL FAILURE'

	else if (front_panel_fault_code .eq. '38'x) then

	write(lun,55) 'DRIVE DISABLED BY "DD" BIT'

	else if (front_panel_fault_code .eq. '3a'x) then

	write(lun,55) 'SERVO DIAGNOSTIC ERROR (SPIN-UP)'
	endif

c
c	ra81
c

	else if (emb$b_lm_type .eq. 21) then

	if (front_panel_fault_code .eq. '18'x) then

	write(lun,55) 'SPIN-UP ERROR'

	else if (front_panel_fault_code .eq. '14'x) then

	write(lun,55) 'UPROC FAULT'

	else if (front_panel_fault_code .eq. '1c'x) then

	write(lun,55) 'SDI ERROR'

	else if (front_panel_fault_code .eq. '12'x) then

	write(lun,55) 'MASTER/SLAVE ERROR'

	else if (front_panel_fault_code .eq. '1a'x) then

	write(lun,55) 'SERVO FINE POSITIONING ERROR'

	else if (front_panel_fault_code .eq. '16'x) then

	write(lun,55) 'SERVO COARSE POSITIONING ERROR'

	else if (front_panel_fault_code .eq. '1e'x) then

	write(lun,55) 'SPINDLE MOTOR INTERLOCK'

	else if (front_panel_fault_code .eq. '30'x) then

	write(lun,55) 'HDA OR SERVO BOARD OVER-TEMP'

	else if (front_panel_fault_code .eq. '38'x) then

	write(lun,55) 'R/W UNSAFE'

	else if (front_panel_fault_code .eq. '34'x) then

	write(lun,55) 'R/W COMMAND ERROR'

	else if (front_panel_fault_code .eq. '3c'x) then

	write(lun,55) 'SERVO/HDA INTERLOCK'

	else if (front_panel_fault_code .eq. '32'x) then

	write(lun,55) 'SERVO/MICRO INTERLOCK'

	else if (front_panel_fault_code .eq. '3a'x) then

	write(lun,55) 'RW/MICRO INTERLOCK'

	else if (front_panel_fault_code .eq. '36'x) then

	write(lun,55) 'CTL PAN/MICRO INTERLOCK'

	else if (front_panel_fault_code .eq. '3e'x) then

	write(lun,55) 'PER/MICRO INTERLOCK'

	else if (front_panel_fault_code .eq. '11'x) then

	write(lun,55) 'INDEX ERROR'

	else if (front_panel_fault_code .eq. '19'x) then

	write(lun,55) 'WRITE AND BAD IMBEDDED'

	else if (front_panel_fault_code .eq. '15'x) then

	write(lun,55) 'DRIVE DISABLED BY "DD" BIT'

	else if (front_panel_fault_code .eq. '1d'x) then

	write(lun,55) 'WRITE AND WRITE PROTECT'

	else if (front_panel_fault_code .eq. '13'x) then

	write(lun,55) 'SERVO DIAGNOSTICS FAILED'

	else if (front_panel_fault_code .eq. '1b'x) then

	write(lun,55) 'R/W DIAGNOSTICS FAILED'

	else if (front_panel_fault_code .eq. '17'x) then

	write(lun,55) 'IDLE LOOP DIAGNOSTICS FAILED'

	else if (front_panel_fault_code .eq. '3f'x) then

	write(lun,55) 'HARDCORE FAILURE'
	endif
	else

	write(lun,60) 'FRONT PANEL FAULT CODE, ',front_panel_fault_code,
	1 ' (HEX)'
60	format(' ',t40,a,z2.2,a)
	endif
	endif

	return

	end



	subroutine mslg$$w_sde_cyl (lun,small_disk_cylinder)



	byte		lun

	integer*2	small_disk_cylinder



	call linchk (lun,1)

	write(lun,10) small_disk_cylinder
10	format(' ',t8,'MSLG$W_SDE_CYL',t28,z4.4)

	return

	end



	subroutine mslg$$l_header (lun,header)



	byte		lun

	integer*4	header

	integer*4	lbn

	integer*4	code

	integer*4	compress4



	call linchk (lun,1)

	write(lun,5) header
5	format(' ',t8,'MSLG$L_HEADER',t24,z8.8)

	lbn = lib$extzv(0,28,header)

	code = lib$extzv(28,4,header)

	call linchk (lun,2)

	if (code .eq. 0) then

	write(lun,10) lbn,'GOOD LOGICAL SECTOR'
10	format(' ',t40,'LBN #',i<compress4 (lbn)>,'.',/,t40,a)

	else if (code .eq. 3) then

	write(lun,10) lbn,'BAD REVECTORED LOG. SECTOR'

	else if (code .eq. 5) then

	write(lun,10) lbn,'BAD PRIMARY REVECT. LOG. SECTOR'

	else if (code .eq. 6) then

	write(lun,11) lbn,'BAD REPLACEMENT SECTOR'
11	format(' ',t40,'RBN #',i<compress4 (lbn)>,'.',/,t40,a)

	else if (code .eq. 11) then

	write(lun,12) 'BAD SECTOR #',lbn
12	format(' ',t40,a,i<compress4 (lbn)>,'.')

	else if (code .eq. 12) then

	write(lun,13) lbn,'GOOD EXTERNAL SECTOR'
13	format(' ',t40,'XBN #',i<compress4 (lbn)>,'.',/,t40,a)

	else if (code .eq. 14) then

	write(lun,14) lbn,'GOOD DIAGNOSTIC SECTOR'
14	format(' ',t40,'DBN #',i<compress4 (lbn)>,'.',/,t40,a)
	else

	write(lun,15) 'HEADER #',lbn,'.','RESERVED HEADER CODE, #',code,'.'
15	format(' ',t40,a,i<compress4 (lbn)>,a,/,t40,a,i<compress4 (code)>,a)
	endif

	return

	end



	subroutine mscp_reservedb (lun,reservedb)



	byte		lun

	byte		reservedb




	call linchk (lun,1)

	write(lun,10) 'RESERVED',reservedb
10	format(' ',t8,a,t30,z2.2)

	return

	end



	subroutine mscp_reservedw (lun,reservedw)



	byte		lun

	integer*2	reservedw



	call linchk (lun,1)

	write(lun,10) 'RESERVED',reservedw
10	format(' ',t8,a,t28,z4.4)

	return

	end



	subroutine mscp_reservedl (lun,reservedl)



	byte		lun

	integer*4	reservedl



	call linchk (lun,1)

	write(lun,10) 'RESERVED',reservedl
10	format(' ',t8,a,t24,z8.8)

	return

	end



	subroutine mscp_reservedq (lun,reservedq)



	byte		lun

	integer*4	reservedq(2)



	call linchk (lun,2)

	write(lun,10) 'RESERVED',(reservedq(i),i = 1,2)
10	format(' ',t8,a,t24,z8.8,/,t24,z8.8)

	return

	end



	subroutine mscp$$w_unt_flgs (lun,unit_flags,expand)



	byte		lun

	integer*2	unit_flags

	logical*1	expand

	character*17	v1unit_flags(0:2)

	data		v1unit_flags(0)	/'COMPARE READS*'/

	data		v1unit_flags(1)	/'COMPARE WRITES*'/

	data		v1unit_flags(2)	/'576 BYTE SECTORS*'/

	character*26	v2unit_flags(6:7)

	data		v2unit_flags(6)	/'WRITE BACK (NON-VOLATILE)*'/

	data		v2unit_flags(7)	/'REMOVABLE MEDIA*'/

	character*35	v3unit_flags(10:15)

	data		v3unit_flags(10)/'SUPPRESS CACHING (LOW SPEED)*'/

	data		v3unit_flags(11)/'SUPPRESS CACHING (HIGH SPEED*'/

	data		v3unit_flags(12)/'WRITE PROTECT (SOFTWARE OR VOLUME)*'/

	data		v3unit_flags(13)/'WRITE PROTECT (HARDWARE)*'/

	data		v3unit_flags(14)/'INACTIVE SHADOW SET UNIT*'/

	data		v3unit_flags(15)/'CONTROLLER BAD BLOCK REPLACEMENT*'/



	call linchk (lun,1)

	write(lun,10) unit_flags
10	format(' ',t8,'MSCP$W_UNT_FLGS',t28,z4.4)

	if (expand) then

	call output (lun,unit_flags,v1unit_flags,0,0,2,'0')

	call output (lun,unit_flags,v2unit_flags,6,6,7,'0')

	call output (lun,unit_flags,v3unit_flags,10,10,15,'0')
	endif

	return

	end



	subroutine mscp$$l_media_id (lun,media_id,expand)




	byte		lun

	integer*4	media_id

	logical*1	expand

	character*2		letter(31)

	data		letter(1)	/'A*'/

	data		letter(2)	/'B*'/

	data		letter(3)	/'C*'/

	data		letter(4)	/'D*'/

	data		letter(5)	/'E*'/

	data		letter(6)	/'F*'/

	data		letter(7)	/'G*'/

	data		letter(8)	/'H*'/

	data		letter(9)	/'I*'/

	data		letter(10)	/'J*'/

	data		letter(11)	/'K*'/

	data		letter(12)	/'L*'/

	data		letter(13)	/'M*'/

	data		letter(14)	/'N*'/

	data		letter(15)	/'O*'/

	data		letter(16)	/'P*'/

	data		letter(17)	/'Q*'/

	data		letter(18)	/'R*'/

	data		letter(19)	/'S*'/

	data		letter(20)	/'T*'/

	data		letter(21)	/'U*'/

	data		letter(22)	/'V*'/

	data		letter(23)	/'W*'/

	data		letter(24)	/'X*'/

	data		letter(25)	/'Y*'/

	data		letter(26)	/'Z*'/

	data		letter(27)	/'.*'/

	data		letter(28)	/'.*'/

	data		letter(29)	/'.*'/

	data		letter(30)	/'.*'/

	data		letter(31)	/'.*'/

	integer*4	d(0:1)

	integer*4	a(0:2)

	integer*4	n

	integer*4	compress4

	character*2	d_string

	character*3	a_string



	call linchk (lun,1)

	write(lun,5) 'MSCP$L_MEDIA_ID',media_id
5	format(' ',t8,a,t24,z8.8)

	if (expand) then

	d(0) = lib$extzv(27,5,media_id)

	d(1) = lib$extzv(22,5,media_id)

	a(0) = lib$extzv(17,5,media_id)

	a(1) = lib$extzv(12,5,media_id)

	a(2) = lib$extzv(7,5,media_id)

	n = lib$extzv(0,7,media_id)

	do 10,i = 0,1

	if (d(i) .eq. 0) then

	d_string(i+1:i+1) = char(0)
	else

	d_string(i+1:i+1) = letter(d(i))
	endif

10	continue

	do 15,i = 0,2

	if (a(i) .eq. 0) then

	a_string(i+1:i+1) = char(0)
	else

	a_string(i+1:i+1) = letter(a(i))
	endif

15	continue

	call linchk (lun,2)

	write(lun,20) 'DEVICE TYPE, /',d_string,'/'
20	format(' ',t40,3(a))

	write(lun,25) 'MEDIA TYPE, /',a_string,n,'/'
25	format(' ',t40,a,a,i<compress4 (n)>,a)
	endif

	return

	end



	subroutine mscp$$b_opcode (lun,opcode,expand)



	byte		lun

	byte		opcode

	logical*1	expand

	integer*4	control_message_type

	integer*4	compress4



	call linchk (lun,1)

	write(lun,10) opcode
10	format(' ',t8,'MSCP$B_OPCODE',t30,z2.2)

	if (expand) then

	call linchk (lun,1)

	control_message_type = lib$extzv(0,8,opcode)

	if (control_message_type .eq. 1) then

	write(lun,15) 'ABORT'
15	format(' ',t40,a)

	else if (control_message_type .eq. 2) then

	write(lun,15) 'GET COMMAND STATUS'

	else if (control_message_type .eq. 3) then

	write(lun,15) 'GET UNIT STATUS'

	else if (control_message_type .eq. 4) then

	write(lun,15) 'SET CONTROLLER CHARACTERISTICS'

	else if (control_message_type .eq. 8) then

	write(lun,15) 'AVAILABLE'

	else if (control_message_type .eq. 9) then

	write(lun,15) 'ONLINE'

	else if (control_message_type .eq. 10) then

	write(lun,15) 'SET UNIT CHARACTERISTICS'

	else if (control_message_type .eq. 11) then

	write(lun,15) 'DETERMINE ACCESS PATH(S)'

	else if (control_message_type .eq. 16) then

	write(lun,15) 'ACCESS'

	else if (control_message_type .eq. 17) then

	write(lun,15) 'COMPARE CONTROLLER DATA'

	else if (control_message_type .eq. 18) then

	write(lun,15) 'ERASE'

	else if (control_message_type .eq. 19) then

	write(lun,15) 'FLUSH'

	else if (control_message_type .eq. 20) then

	write(lun,15) 'REPLACE'

	else if (control_message_type .eq. 32) then

	write(lun,15) 'COMPARE HOST DATA'

	else if (control_message_type .eq. 33) then

	write(lun,15) 'READ'

	else if (control_message_type .eq. 34) then

	write(lun,15) 'WRITE'

	else if (control_message_type .eq. 64) then

	write(lun,15) 'AVAILABLE'

	else if (control_message_type .eq. 65) then

	write(lun,15) 'DUPLICATE UNIT NUMBER'

	else if (control_message_type .eq. 66) then

	write(lun,15) 'ACCESS PATH'
	else

	write(lun,20) control_message_type
20	format(' ',t40,'CONTROL MESSAGE TYPE, #',
	1 i<compress4 (control_message_type)>,'.')
	endif
	endif

	return

	end




	subroutine mscp$$w_modifier (lun,opcode,command_modifier,expand)



	byte		lun

	byte		opcode

	integer*2	command_modifier

	logical*1	expand

	integer*4	control_message_type

	character*33	v1modifier(4:15)

	data		v1modifier(4)	/'WRITE SHADOW SET, SINGLE UNIT(S)*'/

	data		v1modifier(5)	/'WRITE BACK (VOLATILE)*'/

	data		v1modifier(6)	/'WRITE BACK (NON-VOLATILE)*'/

	data		v1modifier(7)	/'SUPPRESS SHADOWING*'/

	data		v1modifier(8)	/'SUPRESS ERROR RECOVERY*'/

	data		v1modifier(9)	/'SUPRESS ERROR CORRECTION*'/

	data		v1modifier(10)	/'SUPRESS CACHING (LOW SPEED)*'/

	data		v1modifier(11)	/'SUPPRESS CACHING (HIGH SPEED)*'/

	data		v1modifier(12)	/'FORCE ERROR*'/

	data		v1modifier(13)	/'CLEAR SERIOUS EXCEPTION*'/

	data		v1modifier(14)	/'COMPARE*'/

	data		v1modifier(15)	/'EXPRESS REQUEST*'/

	character*10	v1gus_modifier(0:0)

	data		v1gus_modifier(0)	/'NEXT UNIT*'/

	character*18	v1available_modifier(0:1)

	data		v1available_modifier(0)	/'ALL CLASS DRIVERS*'/

	data		v1available_modifier(1)	/'SPIN-DOWN*'/

	character*27	v1online_modifier(0:4)

	data		v1online_modifier(0)	/'ALLOW SELF DESTRUCTION*'/

	data		v1online_modifier(1)	/'IGNORE MEDIA FORMAT ERROR*'/

	data		v1online_modifier(2)	/'ENABLE SET WRITE PROTECT*'/

	data		v1online_modifier(3)	/'CLEAR WRITE-BACK DATA LOST*'/

	data		v1online_modifier(4)	/'SHADOW UNIT SPECIFIED*'/

	character*27	v1suc_modifier(2:4)

	equivalence	(v1suc_modifier(2),v1online_modifier(2))

	character*18	v1flush_modifier(0:1)

	data		v1flush_modifier(0)	/'FLUSH ENTIRE UNIT*'/

	data		v1flush_modifier(1)	/'VOLATILE ONLY*'/

	character*26	v1replace_modifier(0:0)

	data		v1replace_modifier(0)	/'PRIMARY REPLACEMENT BLOCK*'/



	call linchk (lun,1)

	write(lun,10) command_modifier
10	format(' ',t8,'MSCP$W_MODIFIER',t28,z4.4)

	if (expand) then

	control_message_type = lib$extzv(0,8,opcode)

	if (control_message_type .eq. 3) then

	call output (lun,command_modifier,v1gus_modifier,0,0,0,'0')

	call output (lun,command_modifier,v1modifier,4,13,13,'0')

	else if (control_message_type .eq. 8) then

	call output (lun,command_modifier,v1available_modifier,0,0,1,'0')

	call output (lun,command_modifier,v1modifier,4,13,13,'0')

	else if (control_message_type .eq. 9) then

	call output (lun,command_modifier,v1online_modifier,0,0,4,'0')

	call output (lun,command_modifier,v1modifier,4,13,13,'0')

	else if (control_message_type .eq. 10) then

	call output (lun,command_modifier,v1suc_modifier,2,2,4,'0')

	call output (lun,command_modifier,v1modifier,4,13,13,'0')

	else if (
	1 control_message_type .eq. 16
	1 .or.
	1 control_message_type .eq. 17
	1 .or.
	1 control_message_type .eq. 32
	1 ) then

	call output (lun,command_modifier,v1modifier,4,7,11,'0')

	call output (lun,command_modifier,v1modifier,4,13,13,'0')

	call output (lun,command_modifier,v1modifier,4,15,15,'0')

	else if (control_message_type .eq. 18) then

	call output (lun,command_modifier,v1modifier,4,4,8,'0')

	call output (lun,command_modifier,v1modifier,4,12,13,'0')

	call output (lun,command_modifier,v1modifier,4,15,15,'0')

	else if (control_message_type .eq. 19) then

	call output (lun,command_modifier,v1flush_modifier,0,0,1,'0')

	call output (lun,command_modifier,v1modifier,4,7,9,'0')

	call output (lun,command_modifier,v1modifier,4,13,13,'0')

	call output (lun,command_modifier,v1modifier,4,15,15,'0')

	else if (control_message_type .eq. 20) then

	call output (lun,command_modifier,v1replace_modifier,0,0,0,'0')

	call output (lun,command_modifier,v1modifier,4,13,13,'0')

	call output (lun,command_modifier,v1modifier,4,15,15,'0')

	else if (control_message_type .eq. 33) then

	call output (lun,command_modifier,v1modifier,4,7,11,'0')

	call output (lun,command_modifier,v1modifier,4,13,15,'0')

	else if (control_message_type .eq. 34) then

	call output (lun,command_modifier,v1modifier,4,4,9,'0')

	call output (lun,command_modifier,v1modifier,4,12,15,'0')
	endif
	endif

	return

	end



	subroutine mscp$$z_buffer (lun,buffer)



	include 'src$:msghdr.for /nolist'

	include 'src$:emblmdef.for /nolist'



	byte		lun

	integer*4	buffer(3)



	call linchk (lun,3)

	write(lun,10) (buffer(i),i = 1,3)
10	format(' ',t8,'MSCP$Z_BUFFER',t24,z8.8,/,t24,z8.8,/,t24,z8.8)

	return

	end



	subroutine mscp$$l_dev_parm (lun,device_dependant_parameters)



	byte		lun

	integer*4	device_dependant_parameters



	call linchk (lun,1)

	write(lun,10) device_dependant_parameters
10	format(' ',t8,'MSCP$L_DEV_PARM',t24,z8.8)

	return

	end




	subroutine mscp$$w_shdw_unt (lun,shadow_unit,expand)




	byte		lun

	integer*2	shadow_unit

	logical*1	expand

	integer*4	compress4



	call linchk (lun,1)

	write(lun,10) shadow_unit
10	format(' ',t8,'MSCP$W_SHDW_UNT',t28,z4.4)

	if (expand) then

	call linchk (lun,1)

	write(lun,15) shadow_unit
15	format(' ',t40,'SHADOW UNIT #',i<compress4 (shadow_unit)>,'.')
	endif

	return

	end



	subroutine mscp$$w_copy_spd (lun,copy_speed)



	byte		lun

	integer*2	copy_speed



	call linchk (lun,1)

	write(lun,10) copy_speed
10	format(' ',t8,'MSCP$W_COPY_SPD',t28,z4.4)

	return

	end



	subroutine mscp$$w_version (lun,mscp_version)



	byte		lun

	integer*2	mscp_version



	call linchk (lun,1)

	write(lun,10) mscp_version
10	format(' ',t8,'MSCP$W_VERSION',t28,z4.4)

	return

	end



	subroutine mscp$$w_cnt_flgs (lun,controller_flags,expand)



	byte		lun

	integer*2	controller_flags

	logical*1	expand

	character*17	v1controller_flags(0:1)

	data		v1controller_flags(0)	/'576 BYTE SECTORS*'/

	data		v1controller_flags(1)	/'SHADOWING*'/

	character*34	v2controller_flags(4:7)

	data		v2controller_flags(4)
	1 /'ENABLE ERROR LOG MSG., THIS HOST*'/

	data		v2controller_flags(5)
	1 /'ENABLE ERROR LOG MSG., OTHER HOST*'/

	data		v2controller_flags(6)
	1 /'ENABLE MISC. ERROR LOG MESSAGES*'/

	data		v2controller_flags(7)
	1 /'ENABLE "ATTENTION" MESSAGES*'/

	character*33	v3controller_flags(15:15)

	data		v3controller_flags(15)
	1 /'CONTROLLER BAD BLOCK REPLACEMENT*'/



	call linchk (lun,1)

	write(lun,10) controller_flags
10	format(' ',t8,'MSCP$W_CNT_FLGS',t28,z4.4)

	if (expand) then

	call output (lun,controller_flags,v1controller_flags,0,0,1,'0')

	call output (lun,controller_flags,v2controller_flags,4,4,7,'0')

	call output (lun,controller_flags,v3controller_flags,15,15,15,'0')
	endif

	return

	end



	subroutine mscp$$w_hst_tmo (lun,host_timeout,expand)



	byte		lun

	integer*2	host_timeout

	logical*1	expand

	integer*4	compress4



	call linchk (lun,1)

	write(lun,10) host_timeout
10	format(' ',t8,'MSCP$W_HST_TMO',t28,z4.4)

	if (expand) then

	call linchk (lun,1)

	write(lun,15) host_timeout
15	format(' ',t40,'HOST TIMEOUT, ',i<compress4 (host_timeout)>,
	1 '. SECONDS')
	endif

	return

	end



	subroutine mscp$$q_time (lun,vms_time,expand)



	byte		lun

	integer*4	vms_time(2)

	logical*1	expand

	logical*4	sys$asctim

	character*23	timbuf


	call linchk (lun,2)

	write(lun,10) vms_time(1)
10	format(' ',t8,'MSCP$Q_TIME',t24,z8.8)

	if (expand) then

	if (sys$asctim (,timbuf,vms_time,%val(0))) then

	write(lun,15) vms_time(2),timbuf
15	format(' ',t24,z8.8,:t40,:a)

	goto 20
	endif
	endif

	write(lun,15) vms_time(2)

20	return

	end



	subroutine mscp$$w_status (lun,end_message_status_code,expand)



	byte		lun

	integer*2	end_message_status_code

	logical*1	expand

	integer*4	status_code

	integer*4	compress4



	call linchk (lun,1)

	write(lun,10) end_message_status_code
10	format(' ',t8,'MSCP$W_STATUS',t28,z4.4)

	if (expand) then

	status_code = lib$extzv(0,16,end_message_status_code)

	call linchk (lun,1)

	if (status_code .eq. 1) then

	write(lun,15) 'INVALID MESSAGE LENGTH'
15	format(' ',t40,a)

	else if (status_code .eq. (12*256)+1) then

	write(lun,15) 'INVALID "MSCP" VERSION'

	else if (status_code .eq. (8*256)+1) then

	write(lun,15) 'INVALID "MSCP$B_OPCODE"'

	else if (status_code .eq. (10*256)+1) then

	write(lun,15) 'INVALID "MSCP$W_MODIFIER"'
	else

	status_code = (status_code - 1)/256

	write(lun,20) status_code
20	format(' ',t40,'INVALID FIELD, STARTING BYTE #',
	1 i<compress4 (status_code)>,'.')
	endif
	endif

	return

	end



	subroutine mscp_first_twelve_bytes1 (lun,expand)



	include 'src$:msghdr.for /nolist'

	include 'src$:emblmdef.for /nolist'



	byte		lun

	logical*1	expand

	integer*4	mscp$l_cmd_ref

	integer*2	mscp$w_unit

	integer*2	reserved1

	byte		mscp$b_opcode

	byte		reserved2

	integer*2	mscp$w_modifier

	integer*4	mscp$l_out_ref

	equivalence	(emb(38),mscp$l_cmd_ref)

	equivalence	(emb(42),mscp$w_unit)

	equivalence	(emb(44),reserved1)

	equivalence	(emb(46),mscp$b_opcode)

	equivalence	(emb(47),reserved2)

	equivalence	(emb(48),mscp$w_modifier)



	call mscp$$l_cmd_ref (lun,mscp$l_cmd_ref)

	call mscp$$w_unit (lun,mscp$w_unit,expand)

	call mscp_reservedw (lun,reserved1)

	call mscp$$b_opcode (lun,mscp$b_opcode,expand)

	call mscp_reservedb (lun,reserved2)

	call mscp$$w_modifier (lun,mscp$b_opcode,mscp$w_modifier,expand)

	return

	end




	subroutine mscp_first_twelve_bytes2 (lun,expand)




	include 'src$:msghdr.for /nolist'

	include 'src$:emblmdef.for /nolist'



	byte		lun

	logical*1	expand

	integer*4	reserved1

	integer*2	mscp$w_unit

	integer*2	reserved2

	byte		mscp$b_opcode

	byte		reserved3

	integer*2	reserved4

	equivalence	(emb(38),reserved1)

	equivalence	(emb(42),mscp$w_unit)

	equivalence	(emb(44),reserved2)

	equivalence	(emb(46),mscp$b_opcode)

	equivalence	(emb(47),reserved3)

	equivalence	(emb(48),reserved4)



	call mscp_reservedl (lun,reserved1)

	call mscp$$w_unit (lun,mscp$w_unit,expand)

	call mscp_reservedw (lun,reserved2)

	call mscp$$b_opcode (lun,mscp$b_opcode,expand)

	call mscp_reservedb (lun,reserved3)

	call mscp_reservedw (lun,reserved4)

	return

	end



	subroutine mscp_invalid_command_end_mesage (lun)



	include 'src$:msghdr.for /nolist'

	include 'src$:emblmdef.for /nolist'



	byte		lun

	integer*4	mscp$l_cmd_ref

	integer*2	mscp$w_unit

	integer*2	reserved1

	byte		mscp$b_endcode

	byte		mscp$b_flags

	integer*2	mscp$w_status

	byte		manufactured_mscp$b_opcode

	equivalence	(emb(38),mscp$l_cmd_ref)

	equivalence	(emb(42),mscp$w_unit)

	equivalence	(emb(44),reserved1)

	equivalence	(emb(46),mscp$b_endcode)

	equivalence	(emb(47),mscp$b_flags)

	equivalence	(emb(48),mscp$w_status)

	equivalence	(emb(94),manufactured_mscp$b_opcode)

	call linchk (lun,1)

	write(lun,10)
10	format(' ',:)

	call mscp$$l_cmd_ref (lun,mscp$l_cmd_ref)

	call mscp$$w_unit (lun,mscp$w_unit,.true.)

	call mscp_reservedw (lun,reserved1)

	call linchk (lun,1)

	write(lun,15) mscp$b_endcode
15	format(' ',t8,'MSCP$B_ENDCODE',t30,z2.2)

	if (mscp$b_endcode .eq. '80'x) then

	call linchk (lun,1)

	write(lun,17)
17	format(' ',t40,'MSCP$K_OP_END')
	endif

	call mscp$$b_flags (lun,mscp$b_flags,.true.)

	call mscp$$w_status (lun,mscp$w_status,.true.)

	call mscp$b_opcode_dispatcher (lun,manufactured_mscp$b_opcode,.false.,
	1 .true.)

	call linchk (lun,1)

	write(lun,25)
25	format('0','RE-MANUFACTURED "MSCP COMMAND" MESSAGE')

	call movc3 (%val(36),emb(86),emb(38))

	call mscp$b_opcode_dispatcher (lun,manufactured_mscp$b_opcode,.true.,
	1 .false.)

	return

	end



	subroutine mscp$b_opcode_dispatcher (lun,mscp$b_opcode,expand,invalid)



	include 'src$:msghdr.for /nolist'



	byte		lun

	byte		mscp$b_opcode

	logical*1	expand

	logical*1	invalid

	integer*4	mscp$l_opcode



	mscp$l_opcode = lib$extzv(0,8,mscp$b_opcode)

	if (.not. invalid) then

	if (mscp$l_opcode .eq. 1) then

	call mscp$$k_op_abort (lun,expand)

	else if (mscp$l_opcode .eq. 2) then

	call mscp$$k_op_gtcmd (lun,expand)

	else if (mscp$l_opcode .eq. 3) then

	call mscp$$k_op_gtunt (lun,expand)

	else if (mscp$l_opcode .eq. 4) then

	call mscp$$k_op_stcon (lun,expand)

	else if (mscp$l_opcode .eq. 8) then

	call mscp$$k_op_avail (lun,expand)

	else if (mscp$l_opcode .eq. 9) then

	call mscp$$k_op_onlin (lun,expand)

	else if (mscp$l_opcode .eq. 10) then

	call mscp$$k_op_stunt (lun,expand)

	else if (mscp$l_opcode .eq. 11) then

	call mscp$$k_op_dtacp (lun,expand)

	else if (mscp$l_opcode .eq. 16) then

	call mscp$$k_op_acces (lun,expand)

	else if (mscp$l_opcode .eq. 17) then

	call mscp$$k_op_cmpcd (lun,expand)

	else if (mscp$l_opcode .eq. 18) then

	call mscp$$k_op_erase (lun,expand)

	else if (mscp$l_opcode .eq. 19) then

	call mscp$$k_op_flush (lun,expand)

	else if (mscp$l_opcode .eq. 20) then

	call mscp$$k_op_replc (lun,expand)

	else if (mscp$l_opcode .eq. 32) then

	call mscp$$k_op_comp (lun,expand)

	else if (mscp$l_opcode .eq. 33) then

	call mscp$$k_op_read (lun,expand)

	else if (mscp$l_opcode .eq. 34) then

	call mscp$$k_op_write (lun,expand)

	else if (mscp$l_opcode .eq. 64) then

	call mscp$$k_op_avatn (lun,expand)

	else if (mscp$l_opcode .eq. 65) then

	call mscp$$k_op_dupun (lun,expand)

	else if (mscp$l_opcode .eq. 66) then

	call mscp$$k_op_acpth (lun,expand)
	else

	call linchk (lun,1)

	write(lun,5)
5	format(' ',:)

	do 15,i = 50,74,4

	call linchk (lun,1)

	write(lun,10) (emb(i+j),j = 3,0,-1)
10	format(' ',t24,4z2.2)

15	continue
	endif

	else if (invalid) then

	if (mscp$l_opcode .eq. 1) then

	call invalid_mscp$$k_op_abort (lun,expand)

	else if (mscp$l_opcode .eq. 2) then

	call invalid_mscp$$k_op_gtcmd (lun,expand)

	else if (mscp$l_opcode .eq. 3) then

	call invalid_mscp$$k_op_gtunt (lun,expand)

	else if (mscp$l_opcode .eq. 4) then

	call invalid_mscp$$k_op_stcon (lun,expand)

	else if (mscp$l_opcode .eq. 8) then

	call invalid_mscp$$k_op_avail (lun,expand)

	else if (mscp$l_opcode .eq. 9) then

	call invalid_mscp$$k_op_onlin (lun,expand)

	else if (mscp$l_opcode .eq. 10) then

	call invalid_mscp$$k_op_stunt (lun,expand)

	else if (mscp$l_opcode .eq. 11) then

	call invalid_mscp$$k_op_dtacp (lun,expand)

	else if (mscp$l_opcode .eq. 16) then

	call invalid_mscp$$k_op_acces (lun,expand)

	else if (mscp$l_opcode .eq. 17) then

	call invalid_mscp$$k_op_cmpcd (lun,expand)

	else if (mscp$l_opcode .eq. 18) then

	call invalid_mscp$$k_op_erase (lun,expand)

	else if (mscp$l_opcode .eq. 19) then

	call invalid_mscp$$k_op_flush (lun,expand)

	else if (mscp$l_opcode .eq. 20) then

	call invalid_mscp$$k_op_replc (lun,expand)

	else if (mscp$l_opcode .eq. 32) then

	call invalid_mscp$$k_op_comp (lun,expand)

	else if (mscp$l_opcode .eq. 33) then

	call invalid_mscp$$k_op_read (lun,expand)

	else if (mscp$l_opcode .eq. 34) then

	call invalid_mscp$$k_op_write (lun,expand)

	else if (mscp$l_opcode .eq. 64) then

	call invalid_mscp$$k_op_avatn (lun,expand)

	else if (mscp$l_opcode .eq. 65) then

	call invalid_mscp$$k_op_dupun (lun,expand)

	else if (mscp$l_opcode .eq. 66) then

	call invalid_mscp$$k_op_acpth (lun,expand)
	else

	call linchk (lun,1)

	write(lun,5)

	do 20,i = 50,74,4

	call linchk (lun,1)

	write(lun,10) (emb(i+j),j = 3,0,-1)

20	continue
	endif
	endif

	return

	end
