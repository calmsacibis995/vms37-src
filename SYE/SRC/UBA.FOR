C
C	v02-003
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

c	Author	Brian Porter			Creation date	21-JUL-1981

c++
c	Functional description:
c
c	This file is a collection of routines that support the VAX-11
c	family of UBA adapters.  The routines are used by device-specific
c	modules to display datapath and map register information.
c
c	Modified by:
c
c	v02-003	BP0003		Brian Porter,		28-SEP-1981
c		Corrected 11/7zz mapping register decoding.
c
c	v02-002	BP0002		Brian Porter,		31-AUG-1981
c		Added call to compress4 in appropriate places.  Corrected
c		dw730 mapping register code.
c
c	v02-001	BP0001		Brian Porter,		24-AUG-1981
c		Added 11/7zz support.
c**
c--



	subroutine uba_datapath (lun,datapath_number,datapath_register)



c++
c	This routine dispatches to the correct display module for
c	UBA datapath registers.
c--


	include 'src$:msghdr.for /nolist'


	byte		lun

	integer*4	datapath_register

	integer*4	datapath_number

	integer*4	compress4



	if (
	1 lib$extzv(24,8,emb$l_hd_sid) .eq. 255
	1 .or.
	1 lib$extzv(24,8,emb$l_hd_sid) .eq. 1
	1 ) then

	call dw780_datapath (lun,datapath_number,datapath_register)

	else if (lib$extzv(24,8,emb$l_hd_sid) .eq. 2) then

	call dw750_datapath (lun,datapath_number,datapath_register)

	else if (lib$extzv(24,8,emb$l_hd_sid) .eq. 3) then

	call dw7zz_datapath (lun,datapath_number)
c
c	for future UBA support the ELSE-IF-THEN should be expanded at
c	this point.
c

	else

	call linchk (lun,2)

	write(lun,5) 'DATAPATH #',datapath_number,'.',
	1 datapath_register
5	format('0',a,i<compress4 (datapath_number)>,a,t24,z8.8)
	endif

	return

	end




	subroutine dw780_datapath (lun,datapath_number,datapath_register)



c++
c	This routine displays the 11/780 DW780 datapath register.
c--



	byte		lun

	integer*4	datapath_register

	integer*4	datapath_number

	character*22	v1dpr(30:31)

	data		v1dpr(30)	/'BUFFER TRANSFER ERROR*'/

	data		v1dpr(31)	/'BUFFER NOT EMPTY*'/

	integer*4	compress4

	integer*4	lib$extzv

	integer*4	selected_map



	call linchk (lun,2)

	write(lun,5) 'DW780 DPR #',datapath_number,'.',datapath_register
5	format('0',t8,a,i<compress4 (datapath_number)>,a,t24,z8.8)

	selected_map = lib$extzv (7,9,datapath_register)

	call linchk (lun,1)

	write(lun,10) 'MAPPING REGISTER #',selected_map,'.'
10	format(' ',t40,a,i<compress4 (selected_map)>,a)

	do 20,i = 0,7

	if (lib$extzv ((i+16),1,datapath_register) .eq. 1) then

	call linchk (lun,1)

	write(lun,15) 'BUFFER #',i,'. NOT EMPTY'
15	format(' ',t40,a,i1.1,a)
	endif

20	continue

	if (lib$extzv (29,1,datapath_register) .eq. 1) then

	call linchk (lun,1)

	write(lun,25) 'DMA READ'
25	format(' ',t40,a)
	endif

	call output (lun,datapath_register,v1dpr,30,30,31,'0')

	return

	end



	subroutine dw750_datapath (lun,datapath_number,datapath_register)


c++
c	This routine displays the 11/750 DW750 datapath register.
c--


	byte		lun

	integer*4	datapath_number

	integer*4	datapath_register

	integer*4	compress4

	character*6	v1dpr(0:0)

	data		v1dpr(0)	/'PURGE*'/

	character*20	v2dpr(29:31)

	data		v2dpr(29)	/'ERROR*'/

	data		v2dpr(30)	/'NON-EXISTENT MEMORY*'/

	data		v2dpr(31)	/'UNCORRECTABLE ERROR*'/



	call linchk (lun,2)

	write(lun,5) 'DW750 BDP #',datapath_number,'.',datapath_register
5	format('0',t8,a,i<compress4 (datapath_number)>,a,t24,z8.8)

	call output (lun,datapath_register,v1dpr,0,0,0,'0')

	call output (lun,datapath_register,v2dpr,29,29,31,'0')

	return

	end



	subroutine dw7zz_datapath (lun,datapath_number)


c++
c	This routine displays the 11/7zz DW7zz datapath register.
c--


	byte		lun

	integer*4	datapath_number

	integer*4	compress4



	call linchk (lun,3)

	write(lun,5) 'DW730 BDP #',datapath_number,'. ASSIGNED TO QIO REQUEST'
5	format('0',t8,a,i<compress4 (datapath_number)>,a,/)

	return

	end




	subroutine uba_mapping (lun,map_number,mapping_register)




c++
c	This routine dispatches to the correct display module for
c	UBA mapping registers.
c--



	include 'src$:msghdr.for /nolist'


	byte		lun

	integer*4	map_number

	integer*4	mapping_register

	integer*4	compress4



	if (
	1 lib$extzv (24,8,emb$l_hd_sid) .eq. 255
	1 .or.
	1 lib$extzv (24,8,emb$l_hd_sid) .eq. 1
	1 ) then

	call dw780_mapping (lun,map_number,mapping_register)

	else if (lib$extzv (24,8,emb$l_hd_sid) .eq. 2) then

	call dw750_mapping (lun,map_number,mapping_register)

	else if (lib$extzv (24,8,emb$l_hd_sid) .eq. 3) then

	call dw7zz_mapping (lun,map_number,mapping_register)


c
c	for future UBA support the ELSE-IF-THEN should be expanded at
c	this point.
c

	else

	call linchk (lun,2)

	write(lun,5) 'MAP REGISTER #',map_number,'.',mapping_register
5	format('0',a,i<compress4 (map_number)>,a,t24,z8.8)
	endif

	return

	end




	subroutine dw780_mapping (lun,map_number,mapping_register)


c++
c	This routine displays the 11/780 DW780 mapping register.
c--


	byte		lun

	integer*4	map_number

	integer*4	mapping_register

	integer*4	pfn

	integer*4	dpr

	integer*4	compress4

	common		mrd

	character*12	v1mr(25:25)

	common	/mrd/	v1mr

	data		v1mr(25)	/'BYTE OFFSET*'/

	character*19	v2mr(31:31)

	common	/mrd/	v2mr

	data		v2mr(31)	/'MAP REGISTER VALID*'/


	call linchk (lun,1)

	if (map_number .eq. -1) then

	write(lun,3) 'DW780 MPR #???',mapping_register
3	format(' ',t8,a,t24,z8.8)
	else

	write(lun,5) 'DW780 MPR #',map_number,'.',mapping_register
5	format(' ',t8,a,i<compress4 (map_number)>,a,t24,z8.8)
	endif

	if (lib$extzv (31,1,mapping_register) .eq. 1) then

	pfn = lib$extzv (0,21,mapping_register)

	if (pfn .ne. 0) then

	call linchk (lun,1)

	if ((pfn/2)*2 .eq. pfn) then

	write(lun,10) 'SBI PAGE ADDRESS ',pfn/2,'.K'
10	format(' ',t40,a,i<compress4 (pfn/2)>,a)
	else

	write(lun,15) 'SBI PAGE ADDRESS ',(floatj(pfn))/2,'.K'
15	format(' ',t40,a,f<(compress4(pfn/2)+2)>.1,a)
	endif
	endif

	dpr = lib$extzv (21,4,mapping_register)

	call linchk (lun,1)

	if (dpr .ne. 0) then

	write(lun,20) 'DATAPATH REGISTER #',dpr,'.'
20	format(' ',t40,a,i<compress4 (dpr)>,a)
	else

	write(lun,25) 'DIRECT DATAPATH'
25	format(' ',t40,a)
	endif

	call output (lun,mapping_register,v1mr,25,25,25,'0')

	call output (lun,mapping_register,v2mr,31,31,31,'0')
	endif

	return

	end



	subroutine dw750_mapping (lun,map_number,mapping_register)


c++
c	This routine displays the 11/750 DW750 mapping register.
c--


	byte		lun

	integer*4	map_number

	integer*4	mapping_register

	integer*4	pfn

	integer*4	bdp

	integer*4	compress4

	common		mrd

	character*12	v1mr(25:25)

	common	/mrd/	v1mr

	character*19	v2mr(31:31)

	common	/mrd/	v2mr



	call linchk (lun,1)

	if (map_number .eq. -1) then

	write(lun,3) 'DW750 MPR #???',mapping_register
3	format(' ',t8,a,t24,z8.8)
	else

	write(lun,5) 'DW750 MPR #',map_number,'.',mapping_register
5	format(' ',t8,a,i<compress4 (map_number)>,a,t24,z8.8)
	endif

	if (lib$extzv (31,1,mapping_register) .eq. 1) then

	pfn = lib$extzv (0,15,mapping_register)

	if (pfn .ne. 0) then

	call linchk (lun,1)

	if ((pfn/2)*2 .eq. pfn) then

	write(lun,10) 'PAGE ADDRESS ',pfn/2,'.K'
10	format(' ',t40,a,i<compress4 (pfn/2)>,a)
	else

	write(lun,15) 'PAGE ADDRESS ',(floatj(pfn))/2,'.K'
15	format(' ',t40,a,f<(compress4(pfn/2)+2)>.1,a)
	endif
	endif

	bdp = lib$extzv (21,2,mapping_register)

	call linchk (lun,1)

	if (bdp .ne. 0) then

	write(lun,20) 'BUFFERED DATAPATH REGISTER #',bdp,'.'
20	format(' ',t40,a,i<compress4 (bdp)>,a)
	else

	write(lun,25) 'DIRECT DATAPATH'
25	format(' ',t40,a)
	endif

	call output (lun,mapping_register,v1mr,25,25,25,'0')

	call output (lun,mapping_register,v2mr,31,31,31,'0')
	endif

	return

	end



	subroutine dw7zz_mapping (lun,map_number,mapping_register)


c++
c	This routine displays the 11/7zz DW7zz mapping register.
c--


	byte		lun

	integer*4	map_number

	integer*4	mapping_register

	integer*4	pfn

	integer*4	compress4

	common		mrd

	character*12	v1mr(25:25)

	common	/mrd/	v1mr

	character*19	v2mr(31:31)

	common	/mrd/	v2mr



	call linchk (lun,1)

	if (map_number .eq. -1) then

	write(lun,3) 'DW730 MPR #???',mapping_register
3	format(' ',t8,a,t24,z8.8)
	else

	write(lun,5) 'DW730 MPR #',map_number,'.',mapping_register
5	format(' ',t8,a,i<compress4 (map_number)>,a,t24,z8.8)
	endif

	if (lib$extzv (31,1,mapping_register) .eq. 1) then

	pfn = lib$extzv (0,15,mapping_register)

	if (pfn .ne. 0) then

	call linchk (lun,1)

	if ((pfn/2)*2 .eq. pfn) then

	write(lun,10) 'PAGE ADDRESS ',pfn/2,'.K'
10	format(' ',t40,a,i<compress4 (pfn/2)>,a)
	else

	write(lun,15) 'PAGE ADDRESS ',(floatj(pfn))/2,'.K'
15	format(' ',t40,a,f<(compress4(pfn/2)+2)>.1,a)
	endif
	endif

	call output (lun,mapping_register,v1mr,25,25,25,'0')

	call output (lun,mapping_register,v2mr,31,31,31,'0')
	endif

	return

	end
