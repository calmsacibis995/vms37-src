C
C	SYS$LIBRARY:SIGDEF.FOR - Define some SS$ symbols for condition handlers
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
	1 SS$_ACCVIO    = '000C'X,	! access violation
	1 SS$_OPCCUS	= '0434'X,	! opcode reserved to customer fault
	1 SS$_OPCDEC	= '043C'X,	! opcode reserved to DIGITAL fault
	1 SS$_RADRMOD	= '044C'X,	! reserved addressing fault
	1 SS$_ROPRAND   = '0454'X, 	! reserved operand fault
	1 SS$_FAIL	= '045C'X,	! system service failure exception
	1 SS$_TBIT	= '0464'X	! T-bit pending trap

	PARAMETER
	1 SS$_INTOVF	= '047C'X,	! arithmetic trap, integer overflow
	1 SS$_INTDIV	= '0484'X,	! arithmetic trap, integer divide by zero
	1 SS$_FLTOVF	= '048C'X,	! arithmetic trap, floating overflow
	1 SS$_FLTDIV	= '0494'X,	! arithmetic trap, floating/decimal divide by zero
	1 SS$_FLTUND	= '049C'X,	! arithmetic trap, floating underflow
	1 SS$_DECOVF	= '04A4'X,	! arithmetic trap, decimal overflow
	1 SS$_SUBRNG	= '04AC'X,	! arithmetic trap, subscript out of range
	1 SS$_FLTOVF_F	= '04B4'X,	! arithmetic fault, floating overflow
	1 SS$_FLTDIV_F	= '04BC'X,	! arithmetic fault, floating divide by zero
	1 SS$_FLTUND_F	= '04C4'X	! arithmetic fault, floating underflow

	PARAMETER
	1 SS$_NORMAL    = '0001'X 	! normal successful completion

	PARAMETER
	1 SS$_CONTINUE  = '0001'X,	! continue execution at point of exception
	1 SS$_RESIGNAL  = '0918'X,	! resignal condition to next handler
	1 SS$_UNWIND    = '0920'X 	! unwind currently in progress

C
C	End of file SIGDEF.FOR
C
