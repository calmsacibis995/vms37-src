{ ++
         File: SRC$:EDFCONST.PAS--PASCAL INCLUDE file
         to define constants used by EDF. (EDIT/FDL)

 ****************************************************************************
 *									    *
 *  COPYRIGHT (c) 1978, 1980, 1982 BY					    *
 *  DIGITAL EQUIPMENT CORPORATION, MAYNARD, MASSACHUSETTS.		    *
 *  ALL RIGHTS RESERVED.						    *
 * 									    *
 *  THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED AND COPIED   *
 *  ONLY IN  ACCORDANCE WITH  THE  TERMS  OF  SUCH  LICENSE  AND WITH THE   *
 *  INCLUSION OF THE ABOVE COPYRIGHT NOTICE. THIS SOFTWARE OR  ANY  OTHER   *
 *  COPIES THEREOF MAY NOT BE PROVIDED OR OTHERWISE MADE AVAILABLE TO ANY   *
 *  OTHER PERSON.  NO TITLE TO AND OWNERSHIP OF  THE  SOFTWARE IS  HEREBY   *
 *  TRANSFERRED.							    *
 * 									    *
 *  THE INFORMATION IN THIS SOFTWARE IS  SUBJECT TO CHANGE WITHOUT NOTICE   *
 *  AND  SHOULD  NOT  BE  CONSTRUED AS  A COMMITMENT BY DIGITAL EQUIPMENT   *
 *  CORPORATION.							    *
 * 									    *
 *  DIGITAL ASSUMES NO RESPONSIBILITY FOR THE USE  OR  RELIABILITY OF ITS   *
 *  SOFTWARE ON EQUIPMENT WHICH IS NOT SUPPLIED BY DIGITAL.		    *
 * 									    *
 *									    *
 ****************************************************************************





FACILITY:	VAX/VMS EDF (EDIT/FDL) UTILITY

ABSTRACT:	This facility is used to create, modify, and optimize
		FDL specification files.

ENVIRONMENT:	NATIVE/USER MODE

AUTHOR:		Ken F. Henderson Jr.

CREATION DATE:	27-Mar-1981

MODIFIED BY:

		V03-003	KFH0002		Ken Henderson		23-Mar-1982
			Added RMS$_FNF to fix FT2 QAR 694.

		V03-001	KFH0001		Ken Henderson		17-Mar-1982
			Added BIGGEST_REL_VAR to support VFC better.

-- }

    { +
    The following constants are specific to the TPARSE facility itself.
    - }
    TPA$K_COUNT0	= %X0008;	{ Argument count (zero level) }
    TPA$M_BLANKS	= %X0001;	{ Process blanks and tabs explicitly }
    TPA$V_BLANKS	= %X0000;
    TPA$M_ABBREV	= %X0002;	{ Allow minimal abbreviation }
    TPA$V_ABBREV	= %X0001;
    TPA$M_ABBRFM	= %X0004;	{ Allow first match abbreviation }
    TPA$V_ABBRFM	= %X0002;
    TPA$M_AMBIG		= %X10000;	{ Ambiguous keyword at this state }
    TPA$V_AMBIG		= %X0010;

    { +
    The following are for manipulating string descriptors.
    - }
    DSC$K_CLASS_S	= 1;		{ String descriptor class }
    DSC$K_CLASS_D	= 2;		{ Dynamic string descriptor class }
    DSC$K_DTYPE_T	= 14;		{ Text data type }

    { +
    The following are for condition handling.
    - }
    STS$K_WARNING	= 0;
    STS$K_SUCCESS	= 1;
    STS$K_ERROR		= 2;
    STS$K_INFO		= 3;
    STS$K_SEVERE	= 4;

    { 5,6,7 RESERVED TO DIGITAL }

    STS$V_SEVERITY	= 0;
    STS$S_SEVERITY	= 3;
    STS$M_SEVERITY	= 7;

    { +
    The following are general constants used by EDF.
    - }
    EDF$C_HEADROOM	= 3;		{ Margin of lines left on screen }
    EDF$C_SHIFTPOINT	= 100;		{ For shifting the Menus }
    EDF$C_1GIGA		= 999999999;	{ 10**9 minus 1 }

    { +
    The following are used to display and parse file protection codes.
    In a line_object's PROT_MASK field.

    THE PROTECTION WORD IS:

    (MSF in word) WORLD | GROUP | OWNER | SYSTEM  (LSF in word)

    EACH 4 BIT FIELD IS:

    (MSB in field) NODEL | NOEXE | NOWRITE | NOREAD (LSB in field)

    FALSE = DENY ACCESS		NOTE: THIS IS THE TRUE/FALSE SENSE OF JUST
    TRUE = ALLOW ACCESS		FDL$GL_PROTECTION AND EDF$GL_PROT_MASK.
    				THE ACTUAL XABPRO BITS ARE (1=DENY/0=ALLOW)

    - }
    EDF$V_SYS		= 0;
    EDF$V_OWN		= 4;
    EDF$V_GRP		= 8;
    EDF$V_WLD		= 12;
    EDF$V_NOREAD	= 0;
    EDF$V_NOWRITE	= 1;
    EDF$V_NOEXE		= 2;
    EDF$V_NODEL		= 3;

    { +
    The following are the error codes from the EDF$ facility.
    Defined by the Message source.
    - }
    EDF$_FACILITY	= %X000000B3;

    EDF$_DEVCLASS	= %X00B3800C;	{ device class of SYS$INPUT must be terminal }
    EDF$_SMALLPAGE	= %X00B38014;	{ video terminal pagesize too small }
    EDF$_INTSWERR	= %X00B3801C;	{ internal S/W error }
    EDF$_AMBIG		= %X00B38020;	{ ambiguous keyword }
    EDF$_BADSYNTAX	= %X00B38028;	{ bad syntax }
    EDF$_BADVALUE	= %X00B38030;	{ bad arguments }
    EDF$_NODEFAULT	= %X00B38038;	{ ans defaulted when shouldn't }
    EDF$_CTRLZ		= %X00B38043;	{ control/Z typed }

    RMS$_FNF		= %X00000910;	{ RMS file not found }

    { +
    The following are the error codes from the FDL$ facility.
    - }
    FDL$_FACILITY	= %X000000B4;
    FDL$_FAO_MAX	= %X00000005;

    FDL$_ABKW		= %X00B48010;	{ ambiguous keyword }
    FDL$_ABPRIKW	= %X00B48052;	{ ambiguous primary keyword }
    FDL$_CREATE		= %X00B4805A;	{ error creating file }
    FDL$_FDLPAR		= %X00B4806A;	{ error parsing FDL file }
    FDL$_ILL_ARG	= %X00B48072;	{ wrong number of arguments }
    FDL$_MULPRI		= %X00B4807A;	{ multiple primary definition }
    FDL$_MULSEC		= %X00B48018;	{ multiple secondary definition }
    FDL$_NOQUAL		= %X00B48020;	{ no qualifier on line }
    FDL$_NULLPRI	= %X00B48028;	{ null primary block }
    FDL$_OPENFDL	= %X00B48082;	{ error opening FDL file }
    FDL$_OUTORDER	= %X00B4808A;	{ key or area prim. def'd out of order }
    FDL$_SYNTAX		= %X00B4809A;	{ syntax error }
    FDL$_TITLE		= %X00B4800B;	{ empty ident or title }
    FDL$_UNPRIKW	= %X00B480A2;	{ unrecognized primary keyword }
    FDL$_UNQUAKW	= %X00B48040;	{ unrecognized qualifier keyword }
    FDL$_UNSECKW	= %X00B48048;	{ unrecognized secondary keyword }
    FDL$_VALPRI		= %X00B48038;	{ value required on primary }
    FDL$_EXPVIR		= %X00B48062;	{ error allocating virtual memory }
    FDL$_RFLOC		= %X00B48030;	{ unable to locate related file }
    FDL$_READERR	= %X00B48092;	{ error reading ... }

    { +
    The following are bit-offsets for the FDL$CTRL control longword.
    - }
    FDL$V_STATUS	= 0;		{ 3-bit STD status code }
    FDL$V_WARNING	= 3;		{ a warning has been issued for sec }
    FDL$V_PRIMARY	= 4;		{ Primary has been parsed }
    FDL$V_NEWPRI	= 5;		{ Set if primary only }
    FDL$V_SECONDARY	= 6;		{ Secondary has been parsed }
    FDL$V_INITIAL	= 7;		{ Initial pass - of FDL$PARSE }
    FDL$V_COMMENT	= 8;		{ Comment has been detected }
    FDL$V_LINECMT	= 9;		{ Set if full-line comment }
    FDL$V_PCALL		= 10;		{ Set to use EDF$LINE_PARSED }
    FDL$V_DCL		= 11;		{ Set to have FDL$PARSE signal errors }

    { +
    The following are Qualifier values from FDL$PARSE.
    - }
    FDL$C_ANYPOS	= %X000;	{ ANY_CYLINDER }
    FDL$C_CLUSPOS	= %X001;	{ CLUSTER }
    FDL$C_CYLPOS	= %X002;	{ CYLINDER }
    FDL$C_FIDPOS	= %X003;	{ FILE_ID }
    FDL$C_FNMPOS	= %X004;	{ FILE_NAME }
    FDL$C_LOGPOS	= %X005;	{ LOGICAL }
    FDL$C_NOPOS		= %X006;	{ NOPOS }
    FDL$C_VIRPOS	= %X007;	{ VIRTUAL }

    FAB$C_SEQ		= 0;		{ SEQUENTIAL }
    FAB$C_REL		= 16;		{ RELATIVE }
    FAB$C_IDX		= 32;		{ INDEXED }
    FAB$C_HSH		= 64;		{ * HASHED * }

    FDL$C_IAS		= %X000;	{ IAS }
    FDL$C_RSTS		= %X001;	{ RSTSE }
    FDL$C_M		= %X002;	{ RSX11M }
    FDL$C_MPLUS		= %X003;	{ RSX11MPLUS }
    FDL$C_RT		= %X004;	{ RT11 }
    FDL$C_TRAX		= %X005;	{ TRAX11 }
    FDL$C_VMS		= %X006;	{ VAXVMS }

    { JOURNALING... }

    FDL$C_NONE		= %X000;	{ NONE }
    FDL$C_CR		= %X001;	{ CARRIAGE_RETURN }
    FDL$C_FTN		= %X002;	{ FORTRAN }
    FDL$C_PRINT		= %X003;	{ PRINT }

    FAB$C_UDF		= %X000;	{ UNDEFINED }
    FAB$C_FIX		= %X001;	{ FIXED }
    FAB$C_VAR		= %X002;	{ VARIABLE }
    FAB$C_VFC		= %X003;	{ VFC }
    FAB$C_STM		= %X004;	{ STREAM }
    FAB$C_STMLF		= %X005;	{ STREAM_LF }
    FAB$C_STMCR		= %X006;	{ STREAM_CR }

    XAB$C_STG		= 0;		{ STRING }
    XAB$C_IN2		= 1;		{ INT2 }
    XAB$C_BN2		= 2;		{ BIN2 }
    XAB$C_IN4		= 3;		{ INT4 }
    XAB$C_BN4		= 4;		{ BIN4 }
    XAB$C_PAC		= 5;		{ DECIMAL }

    { +
    The following are used to interface to the EDF$GRAPH routine.
    + }
    EDF$C_LINE			= 0;
    EDF$C_SRF_INCREASING	= 1;
    EDF$C_SRF_DECREASING	= 2;

    EDF$C_BACKGROUND_COLOR	= 0;
    EDF$C_LIGHT_GREEN		= 3;
    EDF$C_MEDIUM_YELLOW		= 2;
    EDF$C_DARK_RED		= 1;

    { +
    The following are supplied by LIB$TPARSE after parsing a string.
    - }

    EDF$C_SMALLER_BUFFERS	= 0;
    EDF$C_FLATTER_FILES		= 1;

    EDF$C_FAST_CONVERT		= 0;
    EDF$C_NOFAST_CONVERT	= 1;
    EDF$C_RMS_PUTS		= 2;

    EDF$C_LINE_PLOT		= 0;
    EDF$C_SURFACE_PLOT		= 1;

    EDF$C_FILL_SURFACE		= 0;
    EDF$C_SIZE_SURFACE		= 1;
    EDF$C_INIT_SURFACE		= 2;
    EDF$C_ADDED_SURFACE		= 3;
    EDF$C_KEY_SURFACE		= 4;

    EDF$C_ADD			= 0;
    EDF$C_DELETE		= 1;
    EDF$C_EXIT			= 2;
    EDF$C_HELP			= 3;
    EDF$C_INVOKE		= 4;
    EDF$C_MODIFY		= 5;
    EDF$C_QUIT			= 6;
    EDF$C_VIEW			= 7;

    EDF$C_RS			= 0;
    EDF$C_KL			= 1;
    EDF$C_KP			= 2;
    EDF$C_IL			= 3;
    EDF$C_BF			= 4;
    EDF$C_RF			= 5;
    EDF$C_RC			= 6;
    EDF$C_KC			= 7;
    EDF$C_DK			= 8;
    EDF$C_LM			= 9;
    EDF$C_AR			= 10;
    EDF$C_IC			= 11;
    EDF$C_WP			= 12;
    EDF$C_FINIS			= 13;
    EDF$C_PV			= 14;
    EDF$C_KT			= 15;

    EDF$C_DESIGN_FDL		= 1;
    EDF$C_OPTIMIZE_FDL		= 2;
    EDF$C_REDESIGN_FDL		= 3;

    EDF$C_NO			= 0;
    EDF$C_YES			= 1;

    { +
    The following define the terminal speed codes that come back from the
    EDF$TERM_SPEED routine.
    - }
    TT$C_BAUD_50	= %X001;
    TT$C_BAUD_75	= %X002;
    TT$C_BAUD_110	= %X003;
    TT$C_BAUD_134	= %X004;
    TT$C_BAUD_150	= %X005;
    TT$C_BAUD_300	= %X006;
    TT$C_BAUD_600	= %X007;
    TT$C_BAUD_1200	= %X008;
    TT$C_BAUD_1800	= %X009;
    TT$C_BAUD_2000	= %X00A;
    TT$C_BAUD_2400	= %X00B;
    TT$C_BAUD_3600	= %X00C;
    TT$C_BAUD_4800	= %X00D;
    TT$C_BAUD_7200	= %X00E;
    TT$C_BAUD_9600	= %X00F;
    TT$C_BAUD_19200	= %X010;

    { +
    The following define the terminal type codes that come back from the
    LIB$SCREEN_INFO routine.
    - }
    TT$_FT1		= %X010;		{ foreign terminal type 1 }
    TT$_FT2		= %X011;		{ foreign terminal type 2 }
    TT$_FT3		= %X012;		{ foreign terminal type 3 }
    TT$_FT4		= %X013;		{ foreign terminal type 4 }
    TT$_FT5		= %X014;		{ foreign terminal type 5 }
    TT$_FT6		= %X015;		{ foreign terminal type 6 }
    TT$_FT7		= %X016;		{ foreign terminal type 7 }
    TT$_FT8		= %X017;		{ foreign terminal type 8 }
    TT$_LA120		= %X021;		{ DEC LA120 }
    TT$_LA36		= %X020;		{ DEC LA36 }
    TT$_LAX		= %X020;		{ DEC LA series hardcopy }
    TT$_UNKNOWN		= %X000;		{ TTDRV doesn't know what it is }
    TT$_VT05		= %X001;		{ DEC VT05 }
    TT$_VT52		= %X040;		{ DEC VT52 }
    TT$_VT5X		= %X040;		{ DEC VT50 series scope }
    TT$_VT55		= %X041;		{ DEC VT55 }
    TT$_VT100		= %X060;		{ DEC VT100 }

    { +
    The following define bit-offsets that come back from EDF$GET_EXTENDED.
    - }
    TT2$V_ALTYPEAHD	= %X007;
    TT2$V_DECCRT	= %X018;
    TT2$V_ANSICRT	= %X018;	{ get new offset }
    TT2$V_AUTOBAUD	= %X001;
    TT2$V_AVO		= %X01B;
    TT2$V_BLOCK		= %X01A;
    TT2$V_BRDCSTMBX	= %X004;
    TT2$V_DMA		= %X006;
    TT2$V_HANGUP	= %X002;
    TT2$V_LOCALECHO	= %X000;
    TT2$V_MODHANGUP	= %X003;
    TT2$V_REGIS		= %X019;
    TT2$V_XON		= %X005;

    { +
    The following define bit-offsets that come back from LIB$SCREEN_INFO.
    - }
    SCR$V_VIDEO		= %X000;
    SCR$V_DECCRT	= %X001;
    SCR$V_ANSICRT	= %X001; { get new offset }
    SCR$V_REGIS		= %X002;
    SCR$V_BLOCK		= %X003;
    SCR$V_AVO		= %X004;

    { +
    The following define RMS Prologue 2 and 3 structure constants.
    - }
    P2_BUCKET_OVERHEAD		= 15;
    BIGGEST_P2_FIX_RECORD	= 16362;
    BIGGEST_P2_VAR_RECORD	= 16360;
    BIGGEST_SEQ_FIXED		= 32767;
    BIGGEST_REL_FIXED		= 16383;
    BIGGEST_REL_VAR		= 16381;
    BIGGEST_P3_RECORD		= 16300;
    BIGGEST_ANSI_TAPE		= 9995;
    P3_RRV_OVERHEAD		= 9;
    P3_RECORD_OVERHEAD_FIX	= 7;
    P3_RECORD_OVERHEAD_VAR	= 9;
    P3_BUCKET_OVERHEAD_PD	= 16;
    P3_BUCKET_OVERHEAD_SD	= 18;
    P3_BUCKET_OVERHEAD_IDX	= 18;
    P3_BUCKET_DUPS_LCB		= 13;	{ including dups size pointer }
    P3_SIDR_POINTER		= 7;
    P3_SIDR_OVERHEAD		= 6;

    EDF$C_MAX_GBL_BUFS		= 32767; { RMS field is a word; pos values only }
    BUCKET_LEFT_WEIGHT		= 0.10;	{ These are used to help find the }
    BUFFER_SPACE_FACTOR		= 3;	{ 'Right' bucketsize }

    MAX_ARRAY_ROW		= 12;	{ this value affects edfgrf.b32 }

{      End of file SRC$:EDFCONST.PAS      }
