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

c	Author Brian Porter			Creation Date 20-AUG-1981

c++
c	Functional description:
c
c	This module formats errorlog entries made by the lcdriver.  The format
c	of the buffer is as follows.
c
c	+-----------------------------------+
c	|            ucb$w_csr              |
c	+-----------------------------------+
c	|           ucb$w_bytxfer           |
c	+-----------------------------------+
c	|            ucb$w_lincnt           |
c	+-----------------------------------+
c	|            ucb$w_prefix           |
c	+-----------------------------------+
c	|            ucb$w_suffix           |
c	+-----------------------------------+
c	|            ucb$w_bufadr           |
c	+-----------------------------------+
c	|           ucb$w_bytecnt           |
c	+-----------------------------------+
c	|            ucb$w_csr2             |
c	+-----------------------------------+
c	|            ucb$w_lines            |
c	+-----------------------------------+
c	|         final map register        |
c	+-----------------------------------+
c	|        previous map register      |
c	+-----------------------------------+
c	|            vec$l_mapreg           |
c	+-----------------------------------+
c
c	Modified by:
c
c	v02-002	BP0002		Brian Porter,		23-NOV-1981
c		Minor edit.
c
c	v02-001	BP0001		Brian Porter,		06-NOV-1981
c		Added 'device attention' support.
c**
c--



	subroutine lcprinter (lun)




	include 'src$:msghdr.for /nolist'

	include 'src$:deverr.for /nolist'




	byte		lun

	integer*4	csr

	integer*4	bytxfer

	integer*4	lincnt

	integer*4	prefix

	integer*4	suffix

	integer*4	bufadr

	integer*4	bytecnt

	integer*4	csr2

	integer*4	lines

	integer*4	final_map_register

	integer*4	previous_map_register

	integer*4	vec$l_mapreg

	equivalence	(emb$l_dv_regsav(0),csr)

	equivalence	(emb$l_dv_regsav(1),bytxfer)

	equivalence	(emb$l_dv_regsav(2),lincnt)

	equivalence	(emb$l_dv_regsav(3),prefix)

	equivalence	(emb$l_dv_regsav(4),suffix)

	equivalence	(emb$l_dv_regsav(5),bufadr)

	equivalence	(emb$l_dv_regsav(6),bytecnt)

	equivalence	(emb$l_dv_regsav(7),csr2)

	equivalence	(emb$l_dv_regsav(8),lines)

	equivalence	(emb$l_dv_regsav(9),final_map_register)

	equivalence	(emb$l_dv_regsav(10),previous_map_register)

	equivalence	(emb$l_dv_regsav(11),vec$l_mapreg)

	integer*4	compress4

	integer*4	compressc

	logical*1	diagnostic_mode

	integer*4	indirect_address

	integer*4	bytes_to_printer

	integer*4	paper_lines_moved

	byte		prefix_array(2)

	equivalence	(prefix,prefix_array)

	integer*4	prefix_value

	integer*4	prefix_count

	character*1	prefix_character

	byte		suffix_array(2)

	equivalence	(suffix,suffix_array)

	integer*4	suffix_value

	integer*4	suffix_count

	character*1	suffix_character

	integer*4	page_length

	integer*4	carriage_width

	integer*4	selected_map_register

	integer*4	field

	character*15	v1csr(0:2)

	data		v1csr(0)	/'PRINT ENABLE*'/

	data		v1csr(1)	/'MASTER RESET*'/

	data		v1csr(2)	/'FORMAT CONTROL*'/

	character*17	v2csr(6:7)

	data		v2csr(6)	/'INTERRUPT ENABLE*'/

	data		v2csr(7)	/'PRINT DONE*'/

	character*27	v3csr(12:15)

	data		v3csr(12)	/'LINE PRINTER NOT CONNECTED*'/

	data		v3csr(13)	/'"DAVFU" READY*'/

	data		v3csr(14)	/'LINE PRINTER OFF-LINE*'/

	data		v3csr(15)	/'NON-EXISTENT MEMORY*'/

	character*28	v1csr2(0:1)

	data		v1csr2(0)	/'EXTENDED BUS ADDRESS BIT 16*'/

	data		v1csr2(1)	/'EXTENDED BUS ADDRESS BIT 17*'/

	character*31	v2csr2(8:10)

	data		v2csr2(8)	/'AUTO INSERT <CR>*'/

	data		v2csr2(9)	/'<FF> TO <LF> CONVERT*'/

	data		v2csr2(10)	/'NON-PRINTING BYTE(S) DISCARDED*'/

	character*10	v3csr2(11:12)

	data		v3csr2(11)	/'"DAVFU"*'/

	data		v3csr2(12)	/'LINE WRAP*'/

	character*33	v4csr2(15:15)

	data		v4csr2(15)	/'LOWER CASE TO UPPER CASE CONVERT*'/

	character*8	reg_herald(0:8)

	data		reg_herald(0)	/'CSR*'/

	data		reg_herald(1)	/'BYTXFER*'/

	data		reg_herald(2)	/'LINCNT*'/

	data		reg_herald(3)	/'PREFIX*'/

	data		reg_herald(4)	/'SUFFIX*'/

	data		reg_herald(5)	/'BUFADR*'/

	data		reg_herald(6)	/'BYTECNT*'/

	data		reg_herald(7)	/'CSR2*'/

	data		reg_herald(8)	/'LINES*'/



	call frctof (lun)

	call dhead1 (lun,'UBA DMF-32')

	diagnostic_mode = .false.

	if (lib$extzv (5,1,csr) .eq. 1) diagnostic_mode = .true.

	call linchk (lun,2)

	write(lun,10) 'CSR',csr
10	format('0',t8,a,t24,z8.8)

	if (.not. diagnostic_mode) then

	call output (lun,csr,v1csr,0,0,2,'0')

	call output (lun,csr,v2csr,6,6,7,'0')

	indirect_address  = lib$extzv (8,3,csr)

	call linchk (lun,1)

	write(lun,15) 'INDIRECT ADDRESS #',indirect_address,'.'
15	format(' ',t40,a,i<compress4 (indirect_address)>,a)

	call output (lun,csr,v3csr,12,12,15,'0')
	else

	call linchk (lun,1)

	write(lun,20) 'DIAGNOSTIC MODE'
20	format(' ',t40,a)
	endif

	call linchk (lun,1)

	write(lun,25) 'BYTXFER',bytxfer
25	format(' ',t8,a,t24,z8.8)

	if (.not. diagnostic_mode) then

	bytes_to_printer = lib$extzv(0,16,bytxfer)

	call linchk (lun,1)

	write(lun,30) bytes_to_printer,'. BYTE(S) TO PRINTER'
30	format(' ',t40,i<compress4 (bytes_to_printer)>,a)	
	endif

	call linchk (lun,1)

	write(lun,25) 'LINCNT',lincnt

	if (.not. diagnostic_mode) then

	if (lib$extzv(11,1,csr2) .eq. 0) then

	paper_lines_moved = lib$extzv(0,16,lincnt)

	call linchk (lun,1)

	write(lun,35) paper_lines_moved,'. PAPER LINE(S) THIS BUFFER'
35	format(' ',t40,i<compress4 (paper_lines_moved)>,a)
	endif
	endif

	call linchk (lun,1)

	write(lun,25) 'PREFIX',prefix

	if (.not. diagnostic_mode) then

	prefix_count = lib$extzv(0,8,prefix)

	prefix_value = lib$extzv(8,8,prefix)

	prefix_character = char(prefix_array(2))

	if (prefix_count .ne. 0) then

	if (prefix_value .ne. 0) then

	call linchk (lun,2)

	write(lun,40) 'PREFIX COUNT ',prefix_count,'.'
40	format(' ',t40,a,i<compress4 (prefix_count)>,a)

	prefix_character = '.'

	call sys$fao ('!af',,prefix_character,%val(1),prefix_value)

	if (prefix_character .eq. '.') then

	write(lun,20) 'PREFIX CHARACTER NON-PRINTABLE'
	else

	write(lun,20) 'PREFIX CHARACTER "'//prefix_character//'"'
	endif

	else if (
	1 prefix_value .eq. 0
	1 .and.
	1 lib$extzv(8,1,csr2) .eq. 1
	1 ) then

	call linchk (lun,1)

	write(lun,45) prefix_count,'. <CR><LF> SEQUENCE(S) PREFIXED'
45	format(' ',t40,i<compress4 (prefix_count)>,a)

	else if (prefix_value .eq. 0) then

	call linchk (lun,1)

	write(lun,45) prefix_count,'. <LF> SEQUENCE(S) PREFIXED'
	endif
	endif
	endif

	call linchk (lun,1)

	write(lun,25) 'SUFFIX',suffix

	if (.not. diagnostic_mode) then

	suffix_count = lib$extzv(0,8,suffix)

	suffix_character = char(suffix_array(2))

	suffix_value = lib$extzv(8,8,suffix)

	if (suffix_count .ne. 0) then

	if (suffix_value .ne. 0) then

	call linchk (lun,2)

	write(lun,50) 'SUFFIX COUNT ',suffix_count,'.'
50	format(' ',t40,a,i<compress4 (suffix_count)>,a)

	suffix_character = '.'

	call sys$fao ('!af',,suffix_character,%val(1),suffix_value)

	if (suffix_character .eq. '.') then

	write(lun,20) 'SUFFIX CHARACTER NON-PRINTABLE'
	else

	write(lun,20) 'SUFFIX CHARACTER "'//suffix_character//'"'
	endif

	else if (
	1 suffix_value .eq. 0
	1 .and.
	1 lib$extzv(8,1,csr2) .eq. 1
	1 ) then

	call linchk (lun,1)

	write(lun,55) suffix_count,'. <CR><LF> SEQUENCE(S) SUFFIXED'
55	format(' ',t40,i<compress4 (suffix_count)>,a)

	else if (suffix_value .eq. 0) then

	call linchk (lun,1)

	write(lun,55) suffix_count,'. <LF> SEQUENCE(S) SUFFIXED'
	endif
	endif
	endif

	call linchk (lun,1)

	write(lun,25) 'BUFADR',bufadr

	if (.not. diagnostic_mode) then

	call calc_map (lun,0,csr2,bufadr)
	endif

	call linchk (lun,1)

	write(lun,25) 'BYTECNT',bytecnt

	call linchk (lun,1)

	write(lun,25) 'CSR2',csr2

	if (.not. diagnostic_mode) then

	call output (lun,csr2,v1csr2,0,0,1,'0')

	if (lib$extzv(2,1,csr) .eq. 1) then

	call output (lun,csr2,v2csr2,8,8,10,'1')
	endif

	call output (lun,csr2,v3csr2,11,11,12,'0')

	call output (lun,csr2,v4csr2,15,15,15,'0')
	endif

	call linchk (lun,1)

	write(lun,25) 'LINES',lines

	if (.not. diagnostic_mode) then

	if (
	1 lib$extzv(2,1,csr) .eq. 1
	1 .and.
	1 lib$extzv(11,1,csr2) .eq. 0
	1 ) then

	page_length = lib$extzv(0,8,lines)

	carriage_width = lib$extzv(8,8,lines)

	call linchk (lun,2)

	write(lun,60) 'PAGE LENGTH, ',page_length,'. LINE(S)',
	1 'PAGE WIDTH, ',carriage_width,'. CHARACTER(S)'
60	format(' ',t40,a,i<compress4 (page_length)>,a,/,
	1 t40,a,i<compress4 (carriage_width)>,a)
	endif
	endif

	if (emb$w_hd_entry .ne. 98) then

c	call calc_map2 (0,csr2,bufadr,selected_map_register)

c	call uba_mapping (lun,selected_map_register,final_map_register)

c	if (lib$extzv(16,16,emb$l_dv_iosb1) .gt. 512) then

c	call uba_mapping (lun,(selected_map_register-1),previous_map_register)
c	endif

c	call vecmapreg (lun,vec$l_mapreg)
	endif

	call linchk (lun,1)

	write(lun,65)
65	format(' ',:)

	call ucb$l_ownuic (lun,emb$l_dv_ownuic)

	call ucb$l_char (lun,emb$l_dv_char)

	call ucb$w_sts (lun,emb$w_dv_sts)

	call ucb$l_opcnt (lun,emb$l_dv_opcnt)

	call ucb$w_errcnt (lun,emb$w_dv_errcnt)

	if (emb$w_hd_entry .ne. 98) then

	call linchk (lun,1)

	write(lun,65)

	call lcprinter_qio (lun,emb$w_dv_func)

	call irp$w_bcnt (lun,emb$w_dv_bcnt)

	call irp$w_boff (lun,emb$w_dv_boff)

	call irp$l_pid (lun,emb$l_dv_rqpid)

	call irp$q_iosb (lun,emb$l_dv_iosb1)
	endif

	return



	entry b_lcprinter (lun)



	call dhead1 (lun,'UBA DMF-32')

	call brief32 (lun,(9),csr,reg_herald,emb$t_dv_name,emb$w_dv_unit)

	return



	entry c_lcprinter (lun)



	call cryptk (lun,32,(9),csr,reg_herald,emb$t_dv_name,emb$w_dv_unit)

	return

	end




	subroutine lcprinter_qio (lun,emb$w_dv_func)



	include 'src$:qiocommon.for /nolist'



	byte		lun

	integer*2	emb$w_dv_func

	integer*4	qiocode(0:1,0:63)




	if (qiocode(0,0) .eq. 0) then

	qiocode(1,11) = %loc(io$_writepblk)

	qiocode(1,26) = %loc(io$_setchar)

	qiocode(1,27) = %loc(io$_sensechar)

	qiocode(1,32) = %loc(io$_writelblk)

	qiocode(1,35) = %loc(io$_setmode)

	qiocode(1,39) = %loc(io$_sensemode)

	qiocode(1,48) = %loc(io$_writevblk)

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
