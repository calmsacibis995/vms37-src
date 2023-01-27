{ ++

    		FILE: SRC$:EDFVALUE.PAS - Pascal include file to define
		initial values of selected top-level variables.

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

		V03-001	KFH0001		Ken Henderson		23-Mar-1982
			Took out reference to EDITFDL_STRING

-- }

    LINE_ONE			:= 1;
    COL_ONE			:= 1;

    ANSI_RESET			:= (' ','[','0','m');
    ANSI_BOLD			:= (' ','[','1','m');
    ANSI_UNDERSCORE		:= (' ','[','4','m');
    ANSI_BLINK			:= (' ','[','5','m');
    ANSI_REVERSE		:= (' ','[','7','m');

    LOWER_LINE			:= 17;
    PROMPT_LINE			:= 23;

    MINIMUM_TERM_WIDTH		:= 80;
    MINIMUM_VIDEO_PAGE		:= 24;
    SCROLLING_SET		:= FALSE;

    EDF_HEADER			:= 'VAX-11 FDL Editor';
    EDFHLP_STRING		:= 'EDFHLP';
    IDENT_STRING		:= '                        VAX-11 FDL Editor';
    IDENT_STRING_LENGTH		:= 41;
    CONTINUE_TEXT		:= ' Press RETURN to continue ';
    SYS$OUTPUT_NAME		:= 'SYS$OUTPUT:';

    EVEN_KEY_DIST_VALID		:= FALSE;
    CARR_CTRL_VALID		:= FALSE;
    MEAN_RECORD_SIZE_VALID	:= FALSE;
    DATA_KEY_COMP_VALID		:= FALSE;
    DATA_RECORD_COMP_VALID	:= FALSE;
    INDEX_RECORD_COMP_VALID	:= FALSE;
    INITIAL_COUNT_VALID		:= FALSE;
    ADDED_COUNT_VALID		:= FALSE;
    LOAD_METHOD_VALID		:= FALSE;
    ASCENDING_LOAD_VALID	:= FALSE;
    ASCENDING_ADDED_VALID	:= FALSE;
    RECORD_FORMAT_VALID		:= FALSE;
    PROLOGUE_VERSION_VALID	:= FALSE;

    { +
    Initialize the sequencing array.
    - }
    PRI_SEQ	:= (
		    9,		{ ANALYSIS_OF_AREA, }
		    10,		{ ANALYSIS_OF_KEY, }
		    7,		{ AREA, }
		    4,		{ DATE, }
		    3,		{ FILE$, }
		    1,		{ IDENT, }
		    5,		{ JOURNALING, }
		    8,		{ KEY, }
		    6,		{ RECORD$, }
		    2,		{ SYSTEM, }
		    0		{ TITLE }
		    );

    { +
    Initialize the 'width' arrays - that indicate how long a particular
    keyword should be printed.
    - }
    PRIMARY_WIDTH := (
		    16,		{ ANALYSIS_OF_AREA, }
		    15,		{ ANALYSIS_OF_KEY, }
		    4,		{ AREA, }
		    4,		{ DATE, }
		    4,		{ FILE$, }
		    5,		{ IDENT, }
		    10,		{ JOURNALING, }
		    3,		{ KEY, }
		    6,		{ RECORD$, }
		    6,		{ SYSTEM, }
		    5		{ TITLE }
		    );

    SECONDARY_WIDTH := (

{ RESERVE 0 }	    0,		{ DUMMY_SECONDARY$, }

{ ANALYSIS_OF_AREA PRIMARY }
		    15,		{ RECLAIMED_SPACE }

{ ANALYSIS_OF_KEY PRIMARY }

		    9,		{ DATA_FILL$, }
		    20,		{ DATA_KEY_COMPRESSION, }
		    23,		{ DATA_RECORD_COMPRESSION, }
		    17,		{ DATA_RECORD_COUNT, }
		    19,		{ DATA_SPACE_OCCUPIED, }
		    9,		{ DELETIONS, }
		    5,		{ DEPTH, }
		    19,		{ DUPLICATES_PER_SIDR, }
		    17,		{ INDEX_COMPRESSION, }
		    10,		{ INDEX_FILL$, }
		    20,		{ INDEX_SPACE_OCCUPIED, }
		    16,		{ MEAN_DATA_LENGTH, }
		    17,		{ MEAN_INDEX_LENGTH, }
		    15,		{ RANDOM_ACCESSES, }
		    14,		{ RANDOM_INSERTS, }
		    19,		{ SEQUENTIAL_ACCESSES, }

{ AREA PRIMARY }

		    10,		{ ALLOCATION$, }
		    19,		{ BEST_TRY_CONTIGUOUS$, }
		    11,		{ BUCKET_SIZE$, }
		    10,		{ CONTIGUOUS$, }
		    17,		{ EXACT_POSITIONING$, }
		    9,		{ EXTENSION$, }
		    8,		{ POSITION$, }
		    6,		{ VOLUME$, }

{ DATE PRIMARY }

		    6,		{ BACKUP$, }
		    8,		{ CREATION$, }
		    10,		{ EXPIRATION$, }
		    8,		{ REVISION$, }

{ FILE PRIMARY }

		    10,		{ ALLOCATION, }
		    6,		{ BACKUP, }
		    19,		{ BEST_TRY_CONTIGUOUS, }
		    11,		{ BUCKET_SIZE, }
		    12,		{ CLUSTER_SIZE, }
		    10,		{ CONTIGUOUS, }
    		    12,		{ DEFAULT_NAME, }
		    15,		{ DELETE_ON_CLOSE, }
		    15,		{ DIRECTORY_ENTRY, }
		    15,		{ ERASE_ON_DELETE, }
		    9,		{ EXTENSION, }
		    19,		{ GLOBAL_BUFFER_COUNT, }
		    18,		{ MAGTAPE_BLOCK_SIZE, }
		    24,		{ MAGTAPE_CURRENT_POSITION, }
		    18,		{ MAGTAPE_PROTECTION, }
		    14,		{ MAGTAPE_REWIND, }
		    17,		{ MAX_RECORD_NUMBER, }
		    16,		{ MAXIMIZE_VERSION, }
		    4,		{ NAME, }
		    12,		{ ORGANIZATION, }
		    5,		{ OWNER, }
		    14,		{ PRINT_ON_CLOSE, }
		    10,		{ PROTECTION, }
		    10,		{ READ_CHECK, }
		    8,		{ REVISION, }
		    15,		{ SUBMIT_ON_CLOSE, }
		    9,		{ SUPERSEDE, }
		    17,		{ TRUNCATE_ON_CLOSE, }
		    11,		{ WRITE_CHECK, }

{ JOURNALING PRIMARY }

		    11,		{ AFTER_IMAGE, }
		    11,		{ AUDIT_TRAIL, }
		    12,		{ BEFORE_IMAGE, }
		    13,		{ RECOVERY_UNIT, }

{ KEY PRIMARY }

		    7,		{ CHANGES, }
		    9,		{ DATA_AREA, }
		    9,		{ DATA_FILL, }
		    20,		{ DATA_KEY_COMPRESSION, }
		    23,		{ DATA_RECORD_COMPRESSION, }
		    10,		{ DUPLICATES, }
		    10,		{ INDEX_AREA, }
		    17,		{ INDEX_COMPRESSION, }
		    10,		{ INDEX_FILL, }
		    17,		{ LEVEL1_INDEX_AREA, }
		    4,		{ NAME$, }
		    8,		{ NULL_KEY, }
		    10,		{ NULL_VALUE, }
		    8,		{ PROLOGUE, }
		    0,		{ SEG_LENGTH, }
		    0,		{ SEG_POSITION, }
		    0,		{ SEG_TYPE, }

{ RECORD PRIMARY }

		    10,		{ BLOCK_SPAN, }
		    16,		{ CARRIAGE_CONTROL, }
		    18,		{ CONTROL_FIELD_SIZE, }
		    6,		{ FORMAT, }
		    4,		{ SIZE, }

{ SYSTEM PRIMARY }

		    6,		{ DEVICE, }
		    6,		{ SOURCE, }
		    6		{ TARGET, }

		    );

    QUALIFIER_WIDTH  := (
{ POSITION }
		    12,		{ ANY_CYLINDER,	{ FDL$C_ANYPOS }
		    7,		{ CLUSTER,	{ FDL$C_CLUSPOS }
		    8,		{ CYLINDER,	{ FDL$C_CYLPOS }
		    7,		{ FILE_ID,	{ FDL$C_FIDPOS }
		    9,		{ FILE_NAME,	{ FDL$C_FNMPOS }
		    7,		{ LOGICAL,	{ FDL$C_LOGPOS }
		    4,		{ NOPOS,	{ FDL$C_NOPOS }
		    7,		{ VIRTUAL,	{ FDL$C_VIRPOS }

{ ORGANIZATION }
		    7,		{ INDEXED,	{ FAB$C_IDX }
		    8,		{ RELATIVE,	{ FAB$C_REL }
		    10,		{ SEQUENTIAL,	{ FAB$C_SEQ }

{ SOURCE/TARGET }
		    3,		{ IAS,		{ FDL$C_IAS }
		    6,		{ RSTSE,	{ FDL$C_RSTS }
		    7,		{ RSX11M,	{ FDL$C_M }
		    12,		{ RSX11MPLUS,	{ FDL$C_MPLUS }
		    5,		{ RT11,		{ FDL$C_RT }
		    7,		{ TRAX11,	{ FDL$C_TRAX }
		    7,		{ VAXVMS,	{ FDL$C_VMS }

{ AUDIT_TRAIL }
		    8,		{ ACCESSES, }
		    3,		{ ALL, }
		    4,		{ NO_TRAIL, }
		    5,		{ READS, }
		    6,		{ WRITES, }

{ RECOVERY_UNIT }
		    9,		{ DURING_RU, }
		    4,		{ NO_RU, }
		    11,		{ RU_REQUIRED, }

{ CARRIAGE_CONTROL }
		    15,		{ CARRIAGE_RETURN, { FDL$C_CR }
		    7,		{ FORTRAN,	{ FDL$C_FTN }
		    4,		{ NONE,		{ FDL$C_NONE }
		    5,		{ PRINT,	{ FDL$C_PRINT }

{ FORMAT }
		    5,		{ FIXED,	{ FAB$C_FIX }
		    6,		{ STREAM,	{ FAB$C_STM }
		    9,		{ STREAM_CR,	{ FAB$C_STMCR }
		    9,		{ STREAM_LF,	{ FAB$C_STMLF }
		    9,		{ UNDEFINED,	{ FAB$C_UDF }
		    8,		{ VARIABLE,	{ FAB$C_VAR }
		    3,		{ VFC,		{ FAB$C_VFC }

{ TYPE }
		    4,		{ BIN2,		{ XAB$C_BN2 }
		    4,		{ BIN4,		{ XAB$C_BN4 }
		    7,		{ DECIMAL,	{ XAB$C_PAC }
		    4,		{ INT2,		{ XAB$C_IN2 }
		    4,		{ INT4,		{ XAB$C_IN4 }
		    6,		{ STRING,	{ XAB$C_STG }

		    0		{ NOT_QUALIFIED	{ DUMMY_VALUE }
		);

    { +
    These are the maximum values of number-valued secondaries.
    - }

    SECONDARY_MAX := (

{ RESERVE 0 }	    0,		{ DUMMY_SECONDARY$, }

{ ANALYSIS_OF_AREA PRIMARY }
		    0,		{ RECLAIMED_SPACE }

{ ANALYSIS_OF_KEY PRIMARY }

		    0,		{ DATA_FILL$, }
		    0,		{ DATA_KEY_COMPRESSION, }
		    0,		{ DATA_RECORD_COMPRESSION, }
		    0,		{ DATA_RECORD_COUNT, }
		    0,		{ DATA_SPACE_OCCUPIED, }
		    0,		{ DELETIONS, }
		    0,		{ DEPTH, }
		    0,		{ DUPLICATES_PER_SIDR, }
		    0,		{ INDEX_COMPRESSION, }
		    0,		{ INDEX_FILL$, }
		    0,		{ INDEX_SPACE_OCCUPIED, }
		    0,		{ MEAN_DATA_LENGTH, }
		    0,		{ MEAN_INDEX_LENGTH, }
		    0,		{ RANDOM_ACCESSES, }
		    0,		{ RANDOM_INSERTS, }
		    0,		{ SEQUENTIAL_ACCESSES, }

{ AREA PRIMARY }

		    EDF$C_1GIGA,{ ALLOCATION$, }
		    0,		{ BEST_TRY_CONTIGUOUS$, }
		    32,		{ BUCKET_SIZE$, }
		    0,		{ CONTIGUOUS$, }
		    0,		{ EXACT_POSITIONING$, }
		    EDF$C_1GIGA,{ EXTENSION$, }
		    16777215,	{ POSITION$, }
		    65535,	{ VOLUME$, }

{ DATE PRIMARY }

		    0,		{ BACKUP$, }
		    0,		{ CREATION$, }
		    0,		{ EXPIRATION$, }
		    0,		{ REVISION$, }

{ FILE PRIMARY }

		    EDF$C_1GIGA,{ ALLOCATION, }
		    0,		{ BACKUP, }
		    0,		{ BEST_TRY_CONTIGUOUS, }
		    32,		{ BUCKET_SIZE, }
		    0,		{ CLUSTER_SIZE, }
		    0,		{ CONTIGUOUS, }
    		    0,		{ DEFAULT_NAME, }
		    0,		{ DELETE_ON_CLOSE, }
		    0,		{ DIRECTORY_ENTRY, }
		    0,		{ ERASE_ON_DELETE, }
		    EDF$C_1GIGA,{ EXTENSION, }
		    32767,	{ GLOBAL_BUFFER_COUNT, }
		    65532,	{ MAGTAPE_BLOCK_SIZE, }
		    0,		{ MAGTAPE_CURRENT_POSITION, }
		    0,		{ MAGTAPE_PROTECTION, }
		    0,		{ MAGTAPE_REWIND, }
		    EDF$C_1GIGA,{ MAX_RECORD_NUMBER, }
		    0,		{ MAXIMIZE_VERSION, }
		    0,		{ NAME, }
		    0,		{ ORGANIZATION, }
		    0,		{ OWNER, }
		    0,		{ PRINT_ON_CLOSE, }
		    0,		{ PROTECTION, }
		    0,		{ READ_CHECK, }
		    65535,	{ REVISION, }
		    0,		{ SUBMIT_ON_CLOSE, }
		    0,		{ SUPERSEDE, }
		    0,		{ TRUNCATE_ON_CLOSE, }
		    0,		{ WRITE_CHECK, }

{ JOURNALING PRIMARY }

		    0,		{ AFTER_IMAGE, }
		    0,		{ AUDIT_TRAIL, }
		    0,		{ BEFORE_IMAGE, }
		    0,		{ RECOVERY_UNIT, }

{ KEY PRIMARY }

		    0,		{ CHANGES, }
		    254,	{ DATA_AREA, }
		    100,	{ DATA_FILL, }
		    99,		{ DATA_KEY_COMPRESSION, }
		    99,		{ DATA_RECORD_COMPRESSION, }
		    0,		{ DUPLICATES, }
		    254,	{ INDEX_AREA, }
		    99,		{ INDEX_COMPRESSION, }
		    100,	{ INDEX_FILL, }
		    254,	{ LEVEL1_INDEX_AREA, }
		    0,		{ NAME$, }
		    0,		{ NULL_KEY, }
		    255,	{ NULL_VALUE, }
		    3,		{ PROLOGUE, }
		    255,	{ SEG_LENGTH, }
		    16299,	{ SEG_POSITION, }
		    0,		{ SEG_TYPE, }

{ RECORD PRIMARY }

		    0,		{ BLOCK_SPAN, }
		    0,		{ CARRIAGE_CONTROL, }
		    255,	{ CONTROL_FIELD_SIZE, }
		    0,		{ FORMAT, }
		    16300,	{ SIZE, }

{ SYSTEM PRIMARY }

		    0,		{ DEVICE, }
		    0,		{ SOURCE, }
		    0		{ TARGET, }

		    );

    { End of File SRC$:EDFVALUE.PAS }
