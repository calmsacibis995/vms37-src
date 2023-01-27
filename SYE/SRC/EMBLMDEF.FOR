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

	byte		emb$b_lm_class

	byte		emb$b_lm_type

	integer*2	emb$w_lm_unit

	byte		emb$b_lm_namlng

	character*15	emb$t_lm_name

	integer*2	emb$w_lm_msgtyp

	byte		emb$b_lm_msgtxt(460)

	equivalence	(emb(16),emb$b_lm_class)

	equivalence	(emb(17),emb$b_lm_type)

	equivalence	(emb(18),emb$w_lm_unit)

	equivalence	(emb(20),emb$b_lm_namlng)

	equivalence	(emb(21),emb$t_lm_name)

	equivalence	(emb(36),emb$w_lm_msgtyp)

	equivalence	(emb(38),emb$b_lm_msgtxt)
