C
C	SYS$LIBRARY:MTHDEF.FOR - Define MTH$ error symbols
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

	PARAMETER
	1 MTH$_WRONUMARG = '168284'X,	! 80 wrong number of arguments
	1 MTH$_INVARGMAT = '16828C'X,	! 81 invalid argument to math library
	1 MTH$_UNDEXP    = '168294'X,	! 82 undefined exponentiation
	1 MTH$_LOGZERNEG = '16829C'X,	! 83 logarithm of zero or negative value
	1 MTH$_SQUROONEG = '1682A4'X,	! 84 square root of negative value
	1 MTH$_SIGLOSMAT = '1682BC'X,	! 87 significance lost in math library
	1 MTH$_SINCOSSIG = '1682BC'X,	! 87 obsolete error code
	1 MTH$_FLOOVEMAT = '1682C4'X,	! 88 floating overflow in math library
	1 MTH$_FLOUNDMAT = '1682CC'X	! 89 floating underflow in math library

C
C	End of file MTHDEF.FOR
C
