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

c	Author	Brian Porter			Creation date	06-JAN-1982

c++
c	Functional description:
c
c	This is an include file for entries logged by MSCP type devices.
c
c	Modified by:
c
c	v03-001	BP0001		Brian Porter,		05-APR-1982
c		Minor edits.
c**
c--

	byte		emb$b_sp_class

	byte		emb$b_sp_type

	integer*2	emb$w_sp_boff

	integer*4	emb$l_sp_bcnt

	integer*4	emb$l_sp_media

	integer*4	emb$l_sp_rqpid

	integer*4	emb$l_sp_iosb1

	integer*4	emb$l_sp_iosb2

	integer*2	emb$w_sp_func

	integer*2	emb$w_sp_unit

	integer*4	emb$l_sp_opcnt

	integer*2	emb$w_sp_errcnt

	integer*2	emb$w_sp_sts

	integer*4	emb$l_sp_ownuic

	integer*4	emb$l_sp_char

	integer*4	emb$l_sp_cmdref

	byte		emb$b_sp_namlng

	character*15	emb$t_sp_name

	equivalence	(emb(16),emb$b_sp_class)

	equivalence	(emb(17),emb$b_sp_type)

	equivalence	(emb(18),emb$w_sp_boff)

	equivalence	(emb(20),emb$l_sp_bcnt)

	equivalence	(emb(24),emb$l_sp_media)

	equivalence	(emb(28),emb$l_sp_rqpid)

	equivalence	(emb(32),emb$l_sp_iosb1)

	equivalence	(emb(36),emb$l_sp_iosb2)

	equivalence	(emb(40),emb$w_sp_func)

	equivalence	(emb(42),emb$w_sp_unit)

	equivalence	(emb(44),emb$l_sp_opcnt)

	equivalence	(emb(48),emb$w_sp_errcnt)

	equivalence	(emb(50),emb$w_sp_sts)

	equivalence	(emb(52),emb$l_sp_ownuic)

	equivalence	(emb(56),emb$l_sp_char)

	equivalence	(emb(60),emb$l_sp_cmdref)

	equivalence	(emb(64),emb$b_sp_namlng)

	equivalence	(emb(65),emb$t_sp_name)
