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
C Function Codes
C
	PARAMETER	XF$K_PKT_RD = 0	,	!read device
	1		XF$K_PKT_RDCHN = 1,	!read device chained
	1		XF$K_PKT_WRT = 2,	!write device
	1		XF$K_PKT_WRTCHN = 3,	!write device chained
	1		XF$K_PKT_WRTCM = 4,	!write control message
	1		XF$K_PKT_SETTST = 6,	!set self test
	1		XF$K_PKT_CLRTST = 7,	!clear self test
	1		XF$K_PKT_NOP = 8,	!no-op
	1		XF$K_PKT_DIAGRI = 9,	!diagnstic read internal
	1		XF$K_PKT_DIAGWI = 10,	!diagnostic wrt internal
	1		XF$K_PKT_DIAGRD = 11,	!diagnostic read DDI
	1		XF$K_PKT_DIAGWC = 12,	!diag write control msg
	1		XF$K_PKT_SETRND = 13,	!set random enable
	1		XF$K_PKT_CLRRND = 14,	!clear random enable
	1		XF$K_PKT_HALT = 15	!set halt

C
C Interrupt Control Codes
C
	PARAMETER	XF$K_PKT_UNCOND = 0,	!unconditional interrupt
	1		XF$K_PKT_TMQMT = 64,	!int if TERMQ empty
	1		XF$K_PKT_NOINT = 128	!do not deliver int

C
C Command Control Codes
C
	PARAMETER	XF$K_PKT_NOTRAN = 0,	!no transmission
	1		XF$K_PKT_CB = 8,	!send only command byte
	1					!on Control Interconnect
	1		XF$K_PKT_CBDM = 16,	!send command byte and
	1					!device message
	1		XF$K_PKT_CBDMBC	= 24	!send command byte,
	1					!dev msg, and byte count
C
C Other Modes Values
C
	PARAMETER	XF$K_PKT_SUPLEN = 32	!suppress length error
	PARAMETER	XF$K_PKT_INSHD = 256	!insert pkt at head
	PARAMETER	XF$K_PKT_INSTL = 0	!insert pkt at tail of q
C
C Masks for error bits set in the IO Status Block
C
	PARAMETER	XF$M_IOS_CIPE = '20000000'X,
	1		XF$M_IOS_CMDSTD = '2000'X,
	1		XF$M_IOS_DDIDIS = '10'X,
	1		XF$M_IOS_DDIERR = '80'X,
	1		XF$M_IOS_DIPE = '40000000'X,
	1		XF$M_IOS_DRVABT = '2'X,
	1		XF$M_IOS_FREQMT = '200'X,
	1		XF$M_IOS_FREQPK = '8'X,
	1		XF$M_IOS_INVDDI = '800'X,
	1		XF$M_IOS_INVPKT = '100'X,
	1		XF$M_IOS_INVPTE = '4'X,
	1		XF$M_IOS_LENERR = '1000'X,
	1		XF$M_IOS_LOG = '40'X,
	1		XF$M_IOS_NEXREG = '20'X,
	1		XF$M_IOS_NORMAL = 1,
	1		XF$M_IOS_PARERR = '80000000'X,
	1		XF$M_IOS_RDSERR = '2000000'X,
	1		XF$M_IOS_RNDENB = '400'X,
	1		XF$M_IOS_RNGERR = '40'X,
	1		XF$M_IOS_SBIERR = '1000000'X,
	1		XF$M_IOS_SLFTST = '20'X,
	1		XF$M_IOS_UNQERR = '80'X,
	1		XF$M_IOS_WCSPE = '10000000'X

C
C Masks for error bits set in DSL in packet
C
	PARAMETER	XF$M_PKT_CMDSTD = '2000'X,
	1		XF$M_PKT_DDIDIS = '10'X,
	1		XF$M_PKT_DDIERR = '80'X,
	1		XF$M_PKT_DRVABT = '2'X,
	1		XF$M_PKT_FREQMT = '200'X,
	1		XF$M_PKT_FREQPK = '8'X,
	1		XF$M_PKT_INVDDI = '800'X,
	1		XF$M_PKT_INVPKT = '100'X,
	1		XF$M_PKT_INVPTE = '4'X,
	1		XF$M_PKT_LENERR = '1000'X,
	1		XF$M_PKT_LOG = '40'X,
	1		XF$M_PKT_NEXREG = '20'X,
	1		XF$M_PKT_NORMAL = '1'X,
	1		XF$M_PKT_RNDENB = '400'X,
	1		XF$M_PKT_RNGERR = '40'X,
	1		XF$M_PKT_SLFTST = '20'X,
	1		XF$M_PKT_UNQERR = '80'X

C
C SHR$ Status Returns
C
	PARAMETER	SHR$_HALTED = '1270'X	!transfer is halted
	PARAMETER	SHR$_QEMPTY = '1280'X	!no packet on TERMQ
	PARAMETER	SHR$_NOCMDMEM = '1278'X !no cmd memory allocated

