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
C	AUTHOR	BRIAN PORTER		CREATION DATE	29-MAY-1979
C

C++
C	Functional description:
C
C	This module decodes syndrome bits.  If it can be determined that a
C	double bit failure has occured then -1 is returned.  Otherwise
C	a failing bit position is returned.
C
C	Modified by:
C
C	v03-001	BP0004		Brian Porter,		23-MAR-1982
C		Corrected bug in syndrome array.
C**
C--

	integer*4 function decode_ecc (error_syndrome,
	1 sbi_configuration_register)


	include 'src$:msghdr.for /nolist'



	byte		error_syndrome

	integer*4	sbi_configuration_register

	byte		ms780e_syndrome(0:38)

	data		ms780e_syndrome(0)	/'4f'x/

	data		ms780e_syndrome(1)	/'4a'x/

	data		ms780e_syndrome(2)	/'52'x/

	data		ms780e_syndrome(3)	/'54'x/

	data		ms780e_syndrome(4)	/'57'x/

	data		ms780e_syndrome(5)	/'58'x/

	data		ms780e_syndrome(6)	/'5b'x/

	data		ms780e_syndrome(7)	/'5d'x/

	data		ms780e_syndrome(8)	/'23'x/

	data		ms780e_syndrome(9)	/'25'x/

	data		ms780e_syndrome(10)	/'26'x/

	data		ms780e_syndrome(11)	/'29'x/

	data		ms780e_syndrome(12)	/'2a'x/

	data		ms780e_syndrome(13)	/'2c'x/

	data		ms780e_syndrome(14)	/'31'x/

	data		ms780e_syndrome(15)	/'34'x/

	data		ms780e_syndrome(16)	/'0e'x/

	data		ms780e_syndrome(17)	/'0b'x/

	data		ms780e_syndrome(18)	/'13'x/

	data		ms780e_syndrome(19)	/'15'x/

	data		ms780e_syndrome(20)	/'16'x/

	data		ms780e_syndrome(21)	/'19'x/

	data		ms780e_syndrome(22)	/'1a'x/

	data		ms780e_syndrome(23)	/'1c'x/

	data		ms780e_syndrome(24)	/'62'x/

	data		ms780e_syndrome(25)	/'64'x/

	data		ms780e_syndrome(26)	/'67'x/

	data		ms780e_syndrome(27)	/'68'x/

	data		ms780e_syndrome(28)	/'6b'x/

	data		ms780e_syndrome(29)	/'6d'x/

	data		ms780e_syndrome(30)	/'70'x/

	data		ms780e_syndrome(31)	/'75'x/

	data		ms780e_syndrome(32)	/'01'x/

	data		ms780e_syndrome(33)	/'04'x/

	data		ms780e_syndrome(34)	/'02'x/

	data		ms780e_syndrome(35)	/'08'x/

	data		ms780e_syndrome(36)	/'10'x/

	data		ms780e_syndrome(37)	/'20'x/

	data		ms780e_syndrome(38)	/'40'x/

	byte		mx780_syndrome(0:71)

	data		mx780_syndrome(0)	/'38'x/

	data		mx780_syndrome(1)	/'19'x/

	data		mx780_syndrome(2)	/'1a'x/

	data		mx780_syndrome(3)	/'3b'x/

	data		mx780_syndrome(4)	/'1c'x/

	data		mx780_syndrome(5)	/'3d'x/

	data		mx780_syndrome(6)	/'3e'x/

	data		mx780_syndrome(7)	/'1f'x/

	data		mx780_syndrome(8)	/'68'x/

	data		mx780_syndrome(9)	/'49'x/

	data		mx780_syndrome(10)	/'4a'x/

	data		mx780_syndrome(11)	/'6b'x/

	data		mx780_syndrome(12)	/'4c'x/

	data		mx780_syndrome(13)	/'6d'x/

	data		mx780_syndrome(14)	/'6e'x/

	data		mx780_syndrome(15)	/'4f'x/

	data		mx780_syndrome(16)	/'70'x/

	data		mx780_syndrome(17)	/'51'x/

	data		mx780_syndrome(18)	/'52'x/

	data		mx780_syndrome(19)	/'73'x/

	data		mx780_syndrome(20)	/'54'x/

	data		mx780_syndrome(21)	/'75'x/

	data		mx780_syndrome(22)	/'76'x/

	data		mx780_syndrome(23)	/'56'x/

	data		mx780_syndrome(24)	/'58'x/

	data		mx780_syndrome(25)	/'79'x/

	data		mx780_syndrome(26)	/'7a'x/

	data		mx780_syndrome(27)	/'5b'x/

	data		mx780_syndrome(28)	/'7c'x/

	data		mx780_syndrome(29)	/'5d'x/

	data		mx780_syndrome(30)	/'5e'x/

	data		mx780_syndrome(31)	/'7f'x/

	data		mx780_syndrome(32)	/'a8'x/

	data		mx780_syndrome(33)	/'89'x/

	data		mx780_syndrome(34)	/'8a'x/

	data		mx780_syndrome(35)	/'ab'x/

	data		mx780_syndrome(36)	/'8c'x/

	data		mx780_syndrome(37)	/'ad'x/

	data		mx780_syndrome(38)	/'ae'x/

	data		mx780_syndrome(39)	/'8f'x/

	data		mx780_syndrome(40)	/'b0'x/

	data		mx780_syndrome(41)	/'91'x/

	data		mx780_syndrome(42)	/'92'x/

	data		mx780_syndrome(43)	/'b3'x/

	data		mx780_syndrome(44)	/'94'x/

	data		mx780_syndrome(45)	/'b5'x/

	data		mx780_syndrome(46)	/'b6'x/

	data		mx780_syndrome(47)	/'97'x/

	data		mx780_syndrome(48)	/'98'x/

	data		mx780_syndrome(49)	/'b9'x/

	data		mx780_syndrome(50)	/'ba'x/

	data		mx780_syndrome(51)	/'9b'x/

	data		mx780_syndrome(52)	/'bc'x/

	data		mx780_syndrome(53)	/'9d'x/

	data		mx780_syndrome(54)	/'9e'x/

	data		mx780_syndrome(55)	/'bf'x/

	data		mx780_syndrome(56)	/'e0'x/

	data		mx780_syndrome(57)	/'c1'x/

	data		mx780_syndrome(58)	/'c2'x/

	data		mx780_syndrome(59)	/'e3'x/

	data		mx780_syndrome(60)	/'c4'x/

	data		mx780_syndrome(61)	/'e5'x/

	data		mx780_syndrome(62)	/'e6'x/

	data		mx780_syndrome(63)	/'c7'x/

	data		mx780_syndrome(64)	/'01'x/

	data		mx780_syndrome(65)	/'02'x/

	data		mx780_syndrome(66)	/'04'x/

	data		mx780_syndrome(67)	/'08'x/

	data		mx780_syndrome(68)	/'10'x/

	data		mx780_syndrome(69)	/'20'x/

	data		mx780_syndrome(70)	/'40'x/

	data		mx780_syndrome(71)	/'80'x/

	byte		ms7x0_syndrome(0:38)

	data		ms7x0_syndrome(0)	/'58'x/

	data		ms7x0_syndrome(1)	/'19'x/

	data		ms7x0_syndrome(2)	/'1a'x/

	data		ms7x0_syndrome(3)	/'5b'x/

	data		ms7x0_syndrome(4)	/'1c'x/

	data		ms7x0_syndrome(5)	/'5d'x/

	data		ms7x0_syndrome(6)	/'5e'x/

	data		ms7x0_syndrome(7)	/'1f'x/

	data		ms7x0_syndrome(8)	/'68'x/

	data		ms7x0_syndrome(9)	/'29'x/

	data		ms7x0_syndrome(10)	/'2a'x/

	data		ms7x0_syndrome(11)	/'6b'x/

	data		ms7x0_syndrome(12)	/'2c'x/

	data		ms7x0_syndrome(13)	/'6d'x/

	data		ms7x0_syndrome(14)	/'6e'x/

	data		ms7x0_syndrome(15)	/'2f'x/

	data		ms7x0_syndrome(16)	/'70'x/

	data		ms7x0_syndrome(17)	/'31'x/

	data		ms7x0_syndrome(18)	/'32'x/

	data		ms7x0_syndrome(19)	/'73'x/

	data		ms7x0_syndrome(20)	/'34'x/

	data		ms7x0_syndrome(21)	/'75'x/

	data		ms7x0_syndrome(22)	/'76'x/

	data		ms7x0_syndrome(23)	/'37'x/

	data		ms7x0_syndrome(24)	/'38'x/

	data		ms7x0_syndrome(25)	/'79'x/

	data		ms7x0_syndrome(26)	/'7a'x/

	data		ms7x0_syndrome(27)	/'3b'x/

	data		ms7x0_syndrome(28)	/'7c'x/

	data		ms7x0_syndrome(29)	/'3d'x/

	data		ms7x0_syndrome(30)	/'3e'x/

	data		ms7x0_syndrome(31)	/'7f'x/

	data		ms7x0_syndrome(32)	/'01'x/

	data		ms7x0_syndrome(33)	/'02'x/

	data		ms7x0_syndrome(34)	/'04'x/

	data		ms7x0_syndrome(35)	/'08'x/

	data		ms7x0_syndrome(36)	/'10'x/

	data		ms7x0_syndrome(37)	/'20'x/

	data		ms7x0_syndrome(38)	/'40'x/




	decode_ecc = -1

c
c	11/780
c

	if (
	1 lib$extzv(24,8,emb$l_hd_sid) .eq. 255
	1 .or.
	1 lib$extzv(24,8,emb$l_hd_sid) .eq. 1
	1 ) then

c
c	ms780c and ma780
c

	if (
	1 lib$extzv(5,3,sbi_configuration_register) .eq. 0
	1 .or.
	1 lib$extzv(5,3,sbi_configuration_register) .eq. 2
	1 ) then

	do 5,i = 0,71

	if (error_syndrome .eq. mx780_syndrome(i)) decode_ecc = i

5	continue

c
c	ms780e
c

	else if (lib$extzv(5,3,sbi_configuration_register) .eq. 3) then

	do 10,i = 0,38

	if  (error_syndrome .eq. ms780e_syndrome(i)) decode_ecc = i

10	continue
	endif

c
c	11/750, 11/730
c

	else if (
	1 lib$extzv(24,8,emb$l_hd_sid) .eq. 2
	1 .or.
	1 lib$extzv(24,8,emb$l_hd_sid) .eq. 3
	1 ) then

	do 15,i = 0,38

	if (error_syndrome .eq. ms7x0_syndrome(i)) decode_ecc = i

15	continue
	endif

	return

	end
