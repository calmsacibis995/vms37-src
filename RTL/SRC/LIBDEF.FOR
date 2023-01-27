C
C	SYS$LIBRARY:LIBDEF.FOR - Define LIB$ error symbols
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
	1 LIB$_AMBKEY    = '15823C'X,	! ambiguous keyword 
	1 LIB$_ATTCONSTO = '15827C'X,	! attempt to continue from stop
	1 LIB$_BADBLOADR = '158264'X,	! bad block address            
	1 LIB$_BADBLOSIZ = '15826C'X,	! bad block size            
	1 LIB$_BADSTA    = '158204'X,	! bad stack           
	1 LIB$_EF_ALRFRE = '15829C'X,	! event flag already free
	1 LIB$_EF_ALRRES = '1582A4'X,	! event flag already reserved
	1 LIB$_EF_RESSYS = '1582AC'X,	! event flag reserved to system
	1 LIB$_FATERRLIB = '15820C'X,	! fatal error in library
	1 LIB$_INPSTRTRU = '15821C'X,	! input string truncated
	1 LIB$_INSEF 	 = '158294'X,	! insufficient event flags
	1 LIB$_INSLUN	 = '1582B4'X,	! insufficient logical units
	1 LIB$_INSVIRMEM = '158214'X,	! insufficient virtual memory
	1 LIB$_INTLOGERR = '15822C'X,	! internal logic error
	1 LIB$_INVARG    = '158234'X,	! invalid argument(s)
	1 LIB$_INVCHA	 = '1582E4'X	! invalid character

	PARAMETER
	1 LIB$_INVSCRPOS = '1582D4'X,	! invalid screen position
	1 LIB$_INVSTRDES = '158224'X,	! invalid string descriptor
	1 LIB$_INVTYPE   = '15828C'X,	! invalid state table
	1 LIB$_LUNALRFRE = '1582BC'X,	! logical unit number already free
	1 LIB$_LUNRESSYS = '1582C4'X,	! logical unit number reserved to system
	1 LIB$_NORMAL    = '1'X,	! routine successfully completed
	1 LIB$_NOTFOU    = '158274'X,	! not found            
	1 LIB$_ONEENTQUE = '158019'X,	! one entry in queue
	1 LIB$_PUSSTAOVE = '15824C'X,	! pushdown stack overflow
	1 LIB$_QUEWASEMP = '1582EC'X,	! queue was empty
	1 LIB$_SCRBUFOVF = '1582CC'X,	! screen buffer overflow
	1 LIB$_SECINTFAI = '1582DC'X,	! secondary interlock failure in queue
	1 LIB$_SIGNO_ARG = '15825C'X,	! signal with no arguments
	1 LIB$_STRIS_INT = '1582F4'X,	! string is interlocked
	1 LIB$_STRTRU    = '158011'X,	! string truncated            
	1 LIB$_SYNTAXERR = '158284'X,	! failure to parse input string
	1 LIB$_UNRKEY    = '158244'X,	! unrecognized keyword
	1 LIB$_USEFLORES = '158254'X 	! use of floating reserved operand
C
C	End of file LIBDEF.FOR
C
