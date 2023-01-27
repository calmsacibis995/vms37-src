{ ++
         File: SRC$:EDFTYPE.PAS--PASCAL INCLUDE file
         to define user data types for EDF utility.

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
-- }

    { +
    These are the Primary Attributes.
    - }
    PRIMARY_TYPE = (
		    ANALYSIS_OF_AREA,
		    ANALYSIS_OF_KEY,
		    AREA,
		    DATE,
		    FILE$,
		    IDENT,
		    JOURNALING,
		    KEY,
		    RECORD$,
		    SYSTEM,
		    TITLE
		    );

    { +
    These are the Secondary Attributes.
    - }
    SECONDARY_TYPE = (

{ RESERVE 0 }	    DUMMY_SECONDARY$,

{ ANALYSIS_OF_AREA PRIMARY }

		    RECLAIMED_SPACE,

{ ANALYSIS_OF_KEY PRIMARY }

		    DATA_FILL$,
		    DATA_KEY_COMPRESSION$,
		    DATA_RECORD_COMPRESSION$,
		    DATA_RECORD_COUNT,
		    DATA_SPACE_OCCUPIED,
		    DELETIONS,
		    DEPTH,
		    DUPLICATES_PER_SIDR,
		    INDEX_COMPRESSION$,
		    INDEX_FILL$,
		    INDEX_SPACE_OCCUPIED,
		    MEAN_DATA_LENGTH,
		    MEAN_INDEX_LENGTH,
		    RANDOM_ACCESSES,
		    RANDOM_INSERTS,
		    SEQUENTIAL_ACCESSES,

{ AREA PRIMARY }

		    ALLOCATION$,
		    BEST_TRY_CONTIGUOUS$,
		    BUCKET_SIZE$,
		    CONTIGUOUS$,
		    EXACT_POSITIONING$,
		    EXTENSION$,
		    POSITION$,
		    VOLUME$,

{ DATE PRIMARY }

		    BACKUP$,
		    CREATION$,
		    EXPIRATION$,
		    REVISION$,

{ FILE PRIMARY }

		    ALLOCATION,
		    BACKUP,
		    BEST_TRY_CONTIGUOUS,
		    BUCKET_SIZE,
		    CLUSTER_SIZE,
		    CONTIGUOUS,
		    DEFAULT_NAME,
		    DELETE_ON_CLOSE,
		    DIRECTORY_ENTRY,
		    ERASE_ON_DELETE,
		    EXTENSION,
		    GLOBAL_BUFFER_COUNT,
		    MAGTAPE_BLOCK_SIZE,
		    MAGTAPE_CURRENT_POSITION,
		    MAGTAPE_PROTECTION,
		    MAGTAPE_REWIND,
		    MAX_RECORD_NUMBER,
		    MAXIMIZE_VERSION,
		    NAME,
		    ORGANIZATION,
		    OWNER,
		    PRINT_ON_CLOSE,
		    PROTECTION,
		    READ_CHECK,
		    REVISION,
		    SUBMIT_ON_CLOSE,
		    SUPERSEDE,
		    TRUNCATE_ON_CLOSE,
		    WRITE_CHECK,

{ JOURNALING PRIMARY }

		    AFTER_IMAGE,
		    AUDIT_TRAIL,
		    BEFORE_IMAGE,
		    RECOVERY_UNIT,

{ KEY PRIMARY }

		    CHANGES,
		    DATA_AREA,
		    DATA_FILL,
		    DATA_KEY_COMPRESSION,
		    DATA_RECORD_COMPRESSION,
		    DUPLICATES,
		    INDEX_AREA,
		    INDEX_COMPRESSION,
		    INDEX_FILL,
		    LEVEL1_INDEX_AREA,
		    NAME$,
		    NULL_KEY,
		    NULL_VALUE,
		    PROLOGUE,
		    SEG_LENGTH,
		    SEG_POSITION,
		    SEG_TYPE,

{ RECORD PRIMARY }

		    BLOCK_SPAN,
		    CARRIAGE_CONTROL,
		    CONTROL_FIELD_SIZE,
		    FORMAT,
		    SIZE,

{ SYSTEM PRIMARY }

		    DEVICE,
		    SOURCE,
		    TARGET

		    );

    QUALIFIER_TYPE  = (

{ POSITION }
		    ANY_CYLINDER,	{ FDL$C_ANYPOS }
		    CLUSTER,		{ FDL$C_CLUSPOS }
		    CYLINDER,		{ FDL$C_CYLPOS }
		    FILE_ID,		{ FDL$C_FIDPOS }
		    FILE_NAME,		{ FDL$C_FNMPOS }
		    LOGICAL,		{ FDL$C_LOGPOS }
		    NOPOS,		{ FDL$C_NOPOS }
		    VIRTUAL,		{ FDL$C_VIRPOS }

{ ORGANIZATION }
		    INDEXED,		{ FAB$C_IDX }
		    RELATIVE,		{ FAB$C_REL }
		    SEQUENTIAL,		{ FAB$C_SEQ }

{ SOURCE/TARGET }
		    IAS,		{ FDL$C_IAS }
		    RSTSE,		{ FDL$C_RSTS }
		    RSX11M,		{ FDL$C_M }
		    RSX11MPLUS,		{ FDL$C_MPLUS }
		    RT11,		{ FDL$C_RT }
		    TRAX11,		{ FDL$C_TRAX }
		    VAXVMS,		{ FDL$C_VMS }

{ AUDIT_TRAIL }
		    ACCESSES,
		    ALL,
		    NO_TRAIL,
		    READS,
		    WRITES,

{ RECOVERY_UNIT }
		    DURING_RU,
		    NO_RU,
		    RU_REQUIRED,

{ CARRIAGE_CONTROL }
		    CARRIAGE_RETURN,	{ FDL$C_CR }
		    FORTRAN,		{ FDL$C_FTN }
		    NONE,		{ FDL$C_NONE }
		    PRINT,		{ FDL$C_PRINT }

{ FORMAT }
		    FIXED,		{ FAB$C_FIX }
		    STREAM,		{ FAB$C_STM }
		    STREAM_CR,		{ FAB$C_STMCR }
        	    STREAM_LF,		{ FAB$C_STMLF }
		    UNDEFINED,		{ FAB$C_UDF }
		    VARIABLE,		{ FAB$C_VAR }
		    VFC,		{ FAB$C_VFC }

{ TYPE }
		    BIN2,		{ XAB$C_BN2 }
		    BIN4,		{ XAB$C_BN4 }
		    DECIMAL,		{ XAB$C_PAC }
		    INT2,		{ XAB$C_IN2 }
		    INT4,		{ XAB$C_IN4 }
		    STRING,		{ XAB$C_STG }

		    NOT_QUALIFIED	{ DUMMY_VALUE }
		);

    NUMBER_TYPE	= (
		    DEFAULT$,
		    BITS,
		    BLOCKS,
		    BUCKETS,
		    BYTES,
		    CHAR$,
		    PERCENT,
		    RECORDS
		    );

    FUNCTION_TYPE  = (
		    ADD,
		    DELETE,
		    EXIT,
		    HELP,
		    INVOKE,
		    MODIFY,
		    QUIT,
		    VIEW
		    );

    COMPARE_TYPE = (
		    EXACT,
		    PRIMARY
		    );

    COLLISION_ACTION_TYPE = (
		    REPLACE_OBJ,
		    IGNORE_OBJ,
		    AFTER_OBJ
		    );

    LOAD_TYPE	= (
		    FAST_CONVERT,
		    NOFAST_CONVERT,
		    RMS_PUTS
		    );

    DESIGN_TYPE = (
		    LINE_PLOT,
		    SURFACE_PLOT
		    );

    SURFACE_TYPE = (
		    FILL_SURFACE,
		    SIZE_SURFACE,
		    INIT_SURFACE,
		    ADDED_SURFACE,
		    KEY_SURFACE
		    );

    LINE_OBJECT_TYPE = (
    		    PRI,
		    SEC,
		    COM
		    );

    WHERE	= (
		    IF_FULL_PROMPT,
		    LOWER_AREA,
		    PAUSE,
		    SCREEN
		);

    TERM_FUNC	= (
		    BOLD,
		    UNDERSCORE,
		    BLINK,
		    REVERSE,
		    VT$RESET
		);

    SCRIPT_TITLES = (
		    DESIGN_FDL,
		    OPTIMIZE_FDL,
		    REDESIGN_FDL,
		    ZERO_SCRIPT
		);

    MATCH_TYPE	= (
		    PRIMARY_ONLY,
		    EXACTLY
		);

    DISPLAY_TYPE = (
		    EXTANT_ONLY,
		    ALL_POSSIBLE
		);

    PLUS_VALUE_TYPE = (
		    INCLUDING_VALUE,
		    NOT_INCLUDING_VALUE
		);

    YES_NO_TYPE	= (YES,NO);

    LIST_POINTER_TYPE = (
		    DEFINITION_LIST,
		    ANALYSIS_LIST
		);

    SUB1	= 1..1;
    SUB2	= 1..2;
    SUB3	= 1..3;
    SUB4	= 1..4;
    SUB5	= 1..5;
    SUB6	= 1..6;
    SUB7	= 1..7;
    SUB8	= 1..8;
    SUB9	= 1..9;
    SUB10	= 1..10;
    SUB11	= 1..11;
    SUB12	= 1..12;
    SUB14	= 1..14;
    SUB15	= 1..15;
    SUB16	= 1..16;
    SUB17	= 1..17;
    SUB18	= 1..18;
    SUB19	= 1..19;
    SUB20	= 1..20;
    SUB24	= 1..24;
    SUB25	= 1..25;
    SUB26	= 1..26;
    SUB30	= 1..30;
    SUB32	= 1..32;
    SUB35	= 1..35;
    SUB40	= 1..40;
    SUB41	= 1..41;
    SUB47	= 1..47;
    SUB80	= 1..80;
    SUB132	= 1..132;
    SUB255	= 1..255;

    BYTE	= 0..255;
    WORD	= 0..65535;
    LONG	= INTEGER;
    QUADWORD	= PACKED ARRAY [0..7] OF BYTE;
    SWITCH	= (LARGE,SMALL);
    PRI_SWITCH	= (NOPRIM,PRIM);
    SEC_SWITCH	= (NOSECO,SECO);
    QUAL_SWITCH	= (NOQUAL,QUAL);

    XY_ARRAY_TYPE = ARRAY [0..12, 0..31] OF BYTE;

    STRING1	= PACKED ARRAY [SUB1] OF CHAR;
    STRING2	= PACKED ARRAY [SUB2] OF CHAR;
    STRING3	= PACKED ARRAY [SUB3] OF CHAR;
    STRING4	= PACKED ARRAY [SUB4] OF CHAR;
    STRING5	= PACKED ARRAY [SUB5] OF CHAR;
    STRING6	= PACKED ARRAY [SUB6] OF CHAR;
    STRING7	= PACKED ARRAY [SUB7] OF CHAR;
    STRING8	= PACKED ARRAY [SUB8] OF CHAR;
    STRING9	= PACKED ARRAY [SUB9] OF CHAR;
    STRING10	= PACKED ARRAY [SUB10] OF CHAR;
    STRING11	= PACKED ARRAY [SUB11] OF CHAR;
    STRING12	= PACKED ARRAY [SUB12] OF CHAR;
    STRING14	= PACKED ARRAY [SUB14] OF CHAR;
    STRING15	= PACKED ARRAY [SUB15] OF CHAR;
    STRING16	= PACKED ARRAY [SUB16] OF CHAR;
    STRING17	= PACKED ARRAY [SUB17] OF CHAR;
    STRING18	= PACKED ARRAY [SUB18] OF CHAR;
    STRING19	= PACKED ARRAY [SUB19] OF CHAR;
    STRING20	= PACKED ARRAY [SUB20] OF CHAR;
    STRING24	= PACKED ARRAY [SUB24] OF CHAR;
    STRING25	= PACKED ARRAY [SUB25] OF CHAR;
    STRING26	= PACKED ARRAY [SUB26] OF CHAR;
    STRING30	= PACKED ARRAY [SUB30] OF CHAR;
    STRING32	= PACKED ARRAY [SUB32] OF CHAR;
    STRING35	= PACKED ARRAY [SUB35] OF CHAR;
    STRING40	= PACKED ARRAY [SUB40] OF CHAR;
    STRING41	= PACKED ARRAY [SUB41] OF CHAR;
    STRING47	= PACKED ARRAY [SUB47] OF CHAR;
    STRING80	= PACKED ARRAY [SUB80] OF CHAR;
    STRING132	= PACKED ARRAY [SUB132] OF CHAR;
    STRING255	= PACKED ARRAY [SUB255] OF CHAR;

    DESCRIPTOR	= PACKED RECORD
		    DSC$W_LENGTH	: WORD;
		    DSC$B_DTYPE		: BYTE;
		    DSC$B_CLASS		: BYTE;
		    DSC$A_POINTER	: ^STRING255;
		END;

    CTRL_ARRAY	= PACKED ARRAY [0..31] OF BOOLEAN;
    CTRL_ARRAY_ADDR = ^CTRL_ARRAY;

    LINE_OBJECT	= RECORD
		    OBJECT_TYPE		: LINE_OBJECT_TYPE;
		    FORE		: ^LINE_OBJECT;
		    BACK		: ^LINE_OBJECT;
		    COMMENT		: DESCRIPTOR;
		    STRING		: DESCRIPTOR;
		    PRIMARY		: PRIMARY_TYPE;
		    PRINUM		: LONG;
		    SECONDARY		: SECONDARY_TYPE;
		    SECNUM		: LONG;
		    QUALIFIER		: QUALIFIER_TYPE;
		    NUMBER		: LONG;
		    NUMTYPE		: NUMBER_TYPE;
		    SWITCH		: BOOLEAN;
		    UIC_GROUP		: LONG;
		    UIC_MEMBER		: LONG;
		    PROT_MASK		: CTRL_ARRAY;
		    FID1		: LONG;
		    FID2		: LONG;
		    FID3		: LONG;
		END;

    TPA_REC	= RECORD
		    TPA$L_COUNT		: INTEGER;
		    TPA$L_OPTIONS	: CTRL_ARRAY;
		    TPA$L_STRINGCNT	: INTEGER;
		    TPA$L_STRINGPTR	: ^STRING255;
		    TPA$L_TOKENCNT	: INTEGER;
		    TPA$L_TOKENPTR	: ^STRING255;
		    TPA$L_INFO		: PACKED RECORD
		    			    TPA$B_CHAR,FILL1,FILL2,FILL3 : BYTE
		    			  END;
		    TPA$L_NUMBER	: INTEGER;
		    TPA$L_PARAM		: INTEGER
    END;

    DESCRIPTOR_PTR = ^DESCRIPTOR;

    FAB_PTR	= ^INTEGER;
    FDL_PTR	= ^INTEGER;
    LONG_PTR	= ^LONG;
    PRI_PTR	= ^PRIMARY_TYPE;
    SEC_PTR	= ^SECONDARY_TYPE;
    QUAL_PTR	= ^QUALIFIER_TYPE;
    NUMT_PTR	= ^NUMBER_TYPE;
    BOOLE_PTR	= ^BOOLEAN;
    STR24_PTR	= ^STRING24;

    SIGARR	= ARRAY [0..9] OF INTEGER;	{ cond handling signal array }
    MECHARR	= ARRAY [0..4] OF INTEGER;	{ cond handling mechanism array }

{      End of file SRC$:EDFTYPE.PAS      }
