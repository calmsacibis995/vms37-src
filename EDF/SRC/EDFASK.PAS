{ ++
    		FILE: SRC$:EDFASK.PAS - Pascal include file to implement
		question asking routines for EDF.

*****************************************************************************
**									    *
**  COPYRIGHT (c) 1978, 1980, 1982 BY					    *
**  DIGITAL EQUIPMENT CORPORATION, MAYNARD, MASSACHUSETTS.		    *
**  ALL RIGHTS RESERVED.						    *
** 									    *
**  THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED AND COPIED   *
**  ONLY IN  ACCORDANCE WITH  THE  TERMS  OF  SUCH  LICENSE  AND WITH THE   *
**  INCLUSION OF THE ABOVE COPYRIGHT NOTICE. THIS SOFTWARE OR  ANY  OTHER   *
**  COPIES THEREOF MAY NOT BE PROVIDED OR OTHERWISE MADE AVAILABLE TO ANY   *
**  OTHER PERSON.  NO TITLE TO AND OWNERSHIP OF  THE  SOFTWARE IS  HEREBY   *
**  TRANSFERRED.							    *
** 									    *
**  THE INFORMATION IN THIS SOFTWARE IS  SUBJECT TO CHANGE WITHOUT NOTICE   *
**  AND  SHOULD  NOT  BE  CONSTRUED AS  A COMMITMENT BY DIGITAL EQUIPMENT   *
**  CORPORATION.							    *
** 									    *
**  DIGITAL ASSUMES NO RESPONSIBILITY FOR THE USE  OR  RELIABILITY OF ITS   *
**  SOFTWARE ON EQUIPMENT WHICH IS NOT SUPPLIED BY DIGITAL.		    *
** 									    *
**									    *
*****************************************************************************




FACILITY:	VAX/VMS EDF (EDIT/FDL) UTILITY

ABSTRACT:	This facility is used to create, modify, and optimize
		FDL specification files.

ENVIRONMENT:	NATIVE/USER MODE

AUTHOR:		Ken F. Henderson Jr.

CREATION DATE:	27-Mar-1981

MODIFIED BY:

		V03-005	KFH0004		Ken Henderson		19 April 1982
			Modified ASK_BUCKET to correct its
			handling of alternate keys.

		V03-003	KFH0003		Ken Henderson		24-Mar-1982
			Modified ASK_TEST_SECONDARY_VALUE to fix
			QAR 833

		V03-002	KFH0002		Ken Henderson		23-Mar-1982
			Modified several 'ASK_' routines to fix
			FT2 QARs 745,746

		V03-001	KFH0001		Ken Henderson		17-Mar-1982
			Modified several 'ASK_' routines to fix
			FT2 QARs 509,449,574,575

-- }

{ ++

ASK_CONFIRM -- Query the user to see if he's sure.

This function assumes the value of true if the user is really sure.

CALLING SEQUENCE:

confirmation-status := ASK_CONFIRM;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

TAB
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$OUTPUT:

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

TRUE if confirmed, FALSE otherwise

SIGNALS:

none

SIDE EFFECTS:


-- }

FUNCTION ASK_CONFIRM : BOOLEAN;

    PROCEDURE THE_QUESTION;

	BEGIN

	    { +
	    Set up to handle user input garbage.
	    - }
	    SYS$INPUT_ERROR	:= FALSE;
	    LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	    { +
	    Ask the user how to proceed, and wait for his response.
	    - }
	    WRITE (
	    SHIFT,
	    'Type "Yes" to confirm the above',TAB,'(Yes/No)[No]',TAB,': ');
	    PARSE_INPUT (
	    EDF$AB_YES_NO_TABLE_KEY,EDF$AB_YES_NO_TABLE_STA,TRUE,EDF$C_NO
	    );

	    { +
	    Make sure this is true for one cycle only.
	    - }
	    TEMP_FULL_PROMPT	:= FALSE;

	END;	{ THE_QUESTION }

BEGIN

    { +
    Keep at it until the user gets it right.
    - }
    REPEAT

	THE_QUESTION;

    UNTIL NOT SYS$INPUT_ERROR;

    { +
    Now that he's answered, what did he say?
    - }
    ASK_CONFIRM		:= (INPUT_VALUE = EDF$C_YES);

END;	{ ASK_CONFIRM }

{ ++

ASK_CONT_WITH_PRI -- Query the user.

This function asks the user if he wan't so stay with the current primary.

CALLING SEQUENCE:

continue-status := ASK_CONT_WITH_PRI;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

TAB
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$OUTPUT:

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

TRUE if confirmed, FALSE otherwise

SIGNALS:

none

SIDE EFFECTS:


-- }

FUNCTION ASK_CONT_WITH_PRI : BOOLEAN;

    PROCEDURE THE_QUESTION;

	BEGIN

	    { +
	    Set up to handle user input garbage.
	    - }
	    SYS$INPUT_ERROR	:= FALSE;
	    LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	    { +
	    Ask the user how to proceed, and wait for his response.
	    - }
	    WRITE (
	    SHIFT,
	    'Continue with this Same Primary',TAB,'(Yes/No)[No]',TAB,': ');
	    PARSE_INPUT (
	    EDF$AB_YES_NO_TABLE_KEY,EDF$AB_YES_NO_TABLE_STA,TRUE,EDF$C_NO
	    );

	    { +
	    Make sure this is true for one cycle only.
	    - }
	    TEMP_FULL_PROMPT	:= FALSE;

	END;	{ THE_QUESTION }

BEGIN

    { +
    Keep at it until the user gets it right.
    - }
    REPEAT

	THE_QUESTION;

    UNTIL NOT SYS$INPUT_ERROR;

    { +
    Now that he's answered, what did he say?
    - }
    ASK_CONT_WITH_PRI	:= (INPUT_VALUE = EDF$C_YES);

END;	{ ASK_CONT_WITH_PRI }

{ ++

ASK_DESIGN_STYLE -- Query the user on his style.

This routine asks the user by what method he wants to design his file.

CALLING SEQUENCE:

ASK_DESIGN_STYE;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SHIFT
TAB
CRLF
SYS$INPUT_ERROR
TEMP_FULL_PROMPT
FULL_PROMPT
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

DESIGN_STYLE
SYS$INPUT_ERROR
SYS$OUTPUT:
TEMP_FULL_PROMPT

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_DESIGN_STYLE;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up the condition handler to catch typing errors.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN
    
	BEGIN

	    WRITELN (SHIFT,
	    'Line_plot:    Bucket Size vs Index Depth');
	    WRITELN (SHIFT,
	    'Surface_plot: Bucket Size vs a File Variable vs Index Depth');

	END;

	{ +
	Pop the question.
	- }
	WRITELN (SHIFT,'(Line_plot Surface_plot)');
	WRITE (SHIFT,'Key ',ACTIVE_KEY:ACTIVE_KEY_LENGTH,ACTIVE_KEY_FILL,
	' Design Mode',TAB,TAB,'(Keyword)',
	ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');
	PARSE_INPUT (
	EDF$AB_DESIGN_STYLE_TABLE_KEY,EDF$AB_DESIGN_STYLE_TABLE_STA,FALSE,0
	);

	CASE INPUT_VALUE OF

	    EDF$C_LINE_PLOT :		DESIGN_STYLE	:= LINE_PLOT;
	    EDF$C_SURFACE_PLOT :	DESIGN_STYLE	:= SURFACE_PLOT;

	OTHERWISE

	    { +
	    BUGCHECK!!
	    - }
	    LIB$SIGNAL (EDF$_INTSWERR,1,1,0);

	END;	{ CASE }

	{ +
	Make sure this is true only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;
    
    END;	{ THE_QUESTION }

BEGIN

    { +
    Keep at it until the user gets it right.
    - }
    REPEAT

	THE_QUESTION;

    UNTIL NOT SYS$INPUT_ERROR;

END;	{ ASK_DESIGN_STYLE }

{ ++

ASK_SURFACE_OPTION -- Query the user about his surface plot.

This routine asks the user which surface graph he wants.

CALLING SEQUENCE:

ASK_SURFACE_OPTION;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SHIFT
TAB
CRLF
SYS$INPUT_ERROR
TEMP_FULL_PROMPT
FULL_PROMPT
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SURFACE_OPTION
SYS$INPUT_ERROR
SYS$OUTPUT:
TEMP_FULL_PROMPT

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_SURFACE_OPTION;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up the condition handler to catch typing errors.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	{ +
	See which surface.
	- }
	CLEAR (IF_FULL_PROMPT);
    
	IF FULL_PROMPT OR TEMP_FULL_PROMPT THEN
    
	BEGIN
    
	    WRITELN (
	    SHIFT,
	    TAB,TAB,
	    ANSI_REVERSE,DASH,
	    ' Surface Plot Y-Axis Selection ',
	    DASH,ANSI_RESET,
	    CRLF,
	    CRLF,
	    SHIFT,
	    'Fill',TAB,
	    'Bucket Size vs     Load Fill Percent     vs Index Depth',
	    CRLF,
	    SHIFT,
	    'Key',TAB,
	    'Bucket Size vs         Key Length        vs Index Depth'
	    );

	    IF ACTIVE_KEY = 0 THEN

	    BEGIN

		WRITELN (SHIFT,
		'Record',TAB,
		'Bucket Size vs        Record Size        vs Index Depth'
		);
		WRITELN (SHIFT,
		'Init',TAB,
		'Bucket Size vs Initial Load Record Count vs Index Depth'
		);
		WRITELN (SHIFT,
		'Add',TAB,
		'Bucket Size vs  Additional Record Count  vs Index Depth'
		);

	    END;

	    WRITELN;

	END

	ELSE

	BEGIN

	    WRITE (SHIFT,'(Fill Key');

	    IF ACTIVE_KEY = 0 THEN

		WRITE (' Record Init Add)')

	    ELSE

		WRITE (')');

	    WRITELN;

	END;

	{ +
	Always ask the question, even for brief prompting.
	- }
	WRITE (SHIFT,'Y-Axis of Surface Plot',TAB,TAB,'(Keyword)',
	ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');

	PARSE_INPUT (
	EDF$AB_SURFACE_OPTION_TABLE_KEY,EDF$AB_SURFACE_OPTION_TABLE_STA,FALSE,0
	);

	CASE INPUT_VALUE OF

	    EDF$C_FILL_SURFACE :	SURFACE_OPTION	:= FILL_SURFACE;
	    EDF$C_SIZE_SURFACE :	SURFACE_OPTION	:= SIZE_SURFACE;
	    EDF$C_INIT_SURFACE :	SURFACE_OPTION	:= INIT_SURFACE;
	    EDF$C_ADDED_SURFACE :	SURFACE_OPTION	:= ADDED_SURFACE;
	    EDF$C_KEY_SURFACE :		SURFACE_OPTION	:= KEY_SURFACE;

	OTHERWISE

	    { +
	    BUGCHECK!!
	    - }
	    LIB$SIGNAL (EDF$_INTSWERR,1,2,0);

	END;	{ CASE }

	{ +
	Disallow queer options.
	- }
	IF (
	(ACTIVE_KEY <> 0)
	AND
	(
	(SURFACE_OPTION = SIZE_SURFACE)
	OR
	(SURFACE_OPTION = INIT_SURFACE)
	OR
	(SURFACE_OPTION = ADDED_SURFACE)
	)
	) THEN

	    LIB$SIGNAL (EDF$_BADVALUE,0,0,0);

	{ +
	Make sure this is true only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;
    
    END;	{ THE_QUESTION }

BEGIN

    { +
    Keep at it until the user gets it right.
    - }
    REPEAT

	THE_QUESTION;

    UNTIL NOT SYS$INPUT_ERROR;

END;	{ ASK_SURFACE_OPTION }

{ ++

ASK_DESIGN_ORG -- See what type of file the user is designing.

This routine asks the user what type of file he's designing.

CALLING SEQUENCE:

ASK_DESIGN_ORG;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SHIFT
TAB
CRLF
SYS$INPUT_ERROR
TEMP_FULL_PROMPT
FULL_PROMPT
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

DESIGN_ORG
SYS$INPUT_ERROR
SYS$OUTPUT:
TEMP_FULL_PROMPT

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_DESIGN_ORG;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up the condition handler to catch typing errors.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	{ +
	See what organization he wants.
	- }
	IF TEMP_FULL_PROMPT THEN
    
	    WRITELN (
	    SHIFT,
	    'This determines the class of VAX-11 RMS file desired.'
	    );

	{ +
	Always ask the question, even for brief prompting.
	- }
	WRITELN (SHIFT,'(Sequential Relative Indexed)');
	WRITE (SHIFT,'File Organization',TAB,TAB,'(Keyword)[Ind]',TAB,': ');
	PARSE_INPUT (EDF$AB_ORG_TABLE_KEY,EDF$AB_ORG_TABLE_STA,TRUE,08);

	DESIGN_ORG	:= CVT_INT_QUAL (INPUT_VALUE);

	{ +
	Make sure this is true only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;
    
    END;	{ THE_QUESTION }

BEGIN

    { +
    Keep at it until the user gets it right.
    - }
    REPEAT

	THE_QUESTION;

    UNTIL NOT SYS$INPUT_ERROR;

END;	{ ASK_DESIGN_ORG }

{ ++

ASK_DATA_FILE_NAME -- Query the user for the filename to put into his FDL file.

This routine queries the user for filename.

CALLING SEQUENCE:

ASK_DATA_FILE_NAME;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

CRLF
TAB
SYS$INPUT_ERROR
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$OUTPUT:

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_DATA_FILE_NAME;

VAR
    TEMP_STRING255	: STRING255;
    LENGTH		: INTEGER;

    PROCEDURE THE_QUESTION;

    BEGIN

	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	{ +
	Pop the question.
	- }
	WRITE (SHIFT,'Data File file-spec',TAB,TAB,'(1-126 chars)[null]',
	CRLF,SHIFT,': ');
	READLN (TEMP_STRING255);
	WRITELN (CRLF);

	SETUP_DESC (DATA_FILE_NAME_DESC);
	STR$TRIM (DATA_FILE_NAME_DESC,TEMP_STRING255);
	LENGTH	:= DATA_FILE_NAME_DESC.DSC$W_LENGTH;

	{ +
	Set the function value for the routine.
	- }
	IF LENGTH = 0 THEN

	    FILENAME_WANTED	:= FALSE

	ELSE

	BEGIN

	    IF LENGTH > 126 THEN

	    BEGIN

		STR$FREE1_DX (DATA_FILE_NAME_DESC);
		LIB$SIGNAL (EDF$_BADSYNTAX,0,0,0);

	    END;

	    FILENAME_WANTED	:= TRUE;

	END;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Don't actually ask if the user is optimizing a key.
    - }
    IF NOT OPTIMIZING THEN

    BEGIN

	{ +
	Assume a filename isn't wanted.
	- }
	FILENAME_WANTED	:= FALSE;

	{ +
	Keep at it until the user gets it right.
	- }
	REPEAT

	    THE_QUESTION;

	UNTIL NOT SYS$INPUT_ERROR;

    END;	{ IF NOT OPTIMIZING }

END;	{ ASK_DATA_FILE_NAME }

{ ++

ASK_KEY_NAME -- Query the user for the key name to put into his FDL file.

This routine queries the user for key name.

CALLING SEQUENCE:

ASK_KEY_NAME;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

CRLF
TAB
SYS$INPUT_ERROR
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$OUTPUT:

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_KEY_NAME;

VAR
    TEMP_STRING255	: STRING255;
    LENGTH		: INTEGER;

    PROCEDURE THE_QUESTION;

    BEGIN

	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	{ +
	Pop the question.
	- }
	WRITE (SHIFT,'Key ',
	ACTIVE_KEY:ACTIVE_KEY_LENGTH,ACTIVE_KEY_FILL,
	' Name',TAB,TAB,TAB,'(1-32 chars)[null]',
	CRLF,SHIFT,': ');
	READLN (TEMP_STRING255);
	WRITELN (CRLF);

	SETUP_DESC (KEY_NAME_DESC);
	STR$TRIM (KEY_NAME_DESC,TEMP_STRING255);
	LENGTH	:= KEY_NAME_DESC.DSC$W_LENGTH;

	{ +
	Set the function value for the routine.
	- }
	IF LENGTH = 0 THEN

	    KEYNAME_WANTED	:= FALSE

	ELSE

	BEGIN

	    { +
	    Key names can be only 32 chars long.
	    - }
	    IF LENGTH > 32 THEN

	    BEGIN

		STR$FREE1_DX (KEY_NAME_DESC);
		LIB$SIGNAL (EDF$_BADSYNTAX,0,0,0);

	    END;

	    KEYNAME_WANTED	:= TRUE;

	END;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Don't actually ask if the user is optimizing a key.
    - }
    IF NOT OPTIMIZING THEN

    BEGIN

	{ +
	Assume key name isn't wanted.
	- }
	KEYNAME_WANTED	:= FALSE;

	{ +
	Keep at it until the user gets it right.
	- }
	REPEAT

	    THE_QUESTION;

	UNTIL NOT SYS$INPUT_ERROR;

    END;	{ IF NOT OPTIMIZING }

END;	{ ASK_KEY_NAME }

{ ++

ASK_FDL_TITLE -- Query the user for the title of the FDL file.

This routine queries the user for his title.

CALLING SEQUENCE:

ASK_FDL_TITLE;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

CRLF
TAB
SYS$INPUT_ERROR
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$OUTPUT:

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

True if a title is wanted, false if not.

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_FDL_TITLE;

VAR
    TEMP_STRING255	: STRING255;
    LENGTH		: INTEGER;

    PROCEDURE THE_QUESTION;

    BEGIN

	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	{ +
	Pop the question.
	- }
	WRITE (SHIFT,'Text for FDL Title Section',TAB,'(1-126 chars)[null]',
	CRLF,SHIFT,': ');
	READLN (TEMP_STRING255);
	WRITELN (CRLF);

	SETUP_DESC (FDL_TITLE_DESC);
	STR$TRIM (FDL_TITLE_DESC,TEMP_STRING255);
	LENGTH	:= FDL_TITLE_DESC.DSC$W_LENGTH;

	{ +
	Set the function value for the routine.
	- }
	IF LENGTH = 0 THEN

	    TITLE_WANTED	:= FALSE

	ELSE

	BEGIN

	    IF LENGTH > 126 THEN

	    BEGIN

		STR$FREE1_DX (FDL_TITLE_DESC);
		LIB$SIGNAL (EDF$_BADSYNTAX,0,0,0);

	    END;

	    TITLE_WANTED	:= TRUE;

	END;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Assume title isn't wanted.
    - }
    TITLE_WANTED	:= FALSE;

    { +
    Keep at it until the user gets it right.
    - }
    REPEAT

	THE_QUESTION;

    UNTIL NOT SYS$INPUT_ERROR;

END;	{ ASK_FDL_TITLE }

{ ++

ASK_KEY_TYPE -- Find out what kind of keys the user has.

This routine queries the user for his key datatype.

CALLING SEQUENCE:

ASK_KEY_TYPE;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

CRLF
TAB
SYS$INPUT_ERROR
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$OUTPUT:

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_KEY_TYPE;

    PROCEDURE THE_QUESTION;

    BEGIN

	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	BEGIN

	    WRITELN (
	    SHIFT,'Use',CRLF,
	    SHIFT,'"Bin2" or "Bin4" type for unsigned binary keys of 2 or 4 bytes,',CRLF,
	    SHIFT,'"Int2" or "Int4" type for signed binary key of 2 or 4 bytes,');
	    WRITELN (
	    SHIFT,'"Decimal" type for packed decimal key of 1 to 16 bytes,',CRLF,
	    SHIFT,'"String" type for character string key of 1 to 255 bytes.'
	    );

	END;

	{ +
	Pop the question.
	- }
	WRITELN (SHIFT,'(Bin2 Bin4 Int2 Int4 Decimal String)');
	WRITE (
	SHIFT,'Key ',ACTIVE_KEY:ACTIVE_KEY_LENGTH,ACTIVE_KEY_FILL,
	' Data Type',TAB,TAB,'(Keyword)[Str]',TAB,': ');
	PARSE_INPUT (
	EDF$AB_TYPE_TABLE_KEY,EDF$AB_TYPE_TABLE_STA,TRUE,ORD(STRING)
	);

	KEY_TYPE 	:= CVT_INT_QUAL (INPUT_VALUE);

	IF KEY_TYPE <> STRING THEN

	BEGIN

	    PROLOGUE_VERSION		:= 2;
	    PROLOGUE_VERSION_VALID	:= TRUE;

	    DATA_RECORD_COMP		:= 0.0;
	    DATA_KEY_COMP		:= 0.0;
	    INDEX_RECORD_COMP		:= 0.0;

	END;

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    IF (
    (VISIBLE_QUESTION)
    OR
    (NOT OPTIMIZING)
    ) THEN

    BEGIN

	{ +
	Keep at it until the user gets it right.
	- }
	REPEAT

	    THE_QUESTION;

	UNTIL NOT SYS$INPUT_ERROR;

    END		{ IF TRUE NOT OPTIMIZING }

    ELSE

    BEGIN

	IF FIND_OBJECT (SEC,KEY,ACTIVE_KEY,SEG_TYPE,0) THEN

	    KEY_TYPE	:= DEF_CURRENT^.QUALIFIER

	ELSE

	BEGIN

	    REPEAT

		THE_QUESTION;

	    UNTIL NOT SYS$INPUT_ERROR;

	END;

    END;	{ IF FALSE NOT OPTIMIZING }

END;	{ ASK_KEY_TYPE }

{ ++

ASK_ACTIVE_KEY -- Query the user about which he wants to play with.

This routine queries the user for ACTIVE_KEY.

CALLING SEQUENCE:

ASK_ACTIVE_KEY;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

CRLF
TAB
SYS$INPUT_ERROR
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$OUTPUT:
ACTIVE_KEY

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_ACTIVE_KEY;

VAR
    LOW_KEY	: INTEGER;
    HIGH_KEY	: INTEGER;

    PROCEDURE THE_QUESTION;

    BEGIN

	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'Select an already defined key.'
	    );

	{ +
	Pop the question.
	- }
	WRITE (
	SHIFT,'Key of Reference',TAB,TAB,'(',
	LOW_KEY:NUM_LEN(LOW_KEY),'-',HIGH_KEY:NUM_LEN(HIGH_KEY)
	,')[0]',TAB,': ');
	NUMBER_INPUT (ACTIVE_KEY,TRUE,0);

	{ +
	Now do a little bounds checking.
	- }
	CHECK_WITHIN_LIMITS (LOW_KEY,ACTIVE_KEY,HIGH_KEY);

	IF ACTIVE_KEY > 0 THEN

	BEGIN

	    PROLOGUE_VERSION		:= 2;
	    PROLOGUE_VERSION_VALID	:= TRUE;

	    DATA_RECORD_COMP		:= 0.0;
	    DATA_KEY_COMP		:= 0.0;
	    INDEX_RECORD_COMP		:= 0.0;

	END;

	SETUP_KEY_LENGTH;

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Find out the range of existing keys (assume contiguous).
    - }
    DEF_CURRENT		:= DEF_HEAD;
    LOW_KEY		:= 0;
    HIGH_KEY		:= 0;

    REPEAT

	WITH DEF_CURRENT^ DO

	BEGIN

	    IF (
	    (OBJECT_TYPE = PRI)
	    AND
	    (PRIMARY = KEY)
	    ) THEN

	    BEGIN

		IF PRINUM < LOW_KEY THEN

		    LOW_KEY	:= PRINUM;

		IF PRINUM > HIGH_KEY THEN

		    HIGH_KEY	:= PRINUM;

	    END;	{ IF }

	END;	{ WITH DEF_CURRENT^ DO }

	DEF_CURRENT	:= DEF_CURRENT^.FORE;

    UNTIL DEF_CURRENT = NIL;

    { +
    Keep at it until the user gets it right.
    - }
    REPEAT

	THE_QUESTION;

    UNTIL NOT SYS$INPUT_ERROR;

END;	{ ASK_ACTIVE_KEY }

{ ++

ASK_NUMBER_KEYS -- Query the user about how many keys he wants.

This routine queries the user for NUMBER_KEYS.

CALLING SEQUENCE:

ASK_NUMBER_KEYS;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

CRLF
TAB
SYS$INPUT_ERROR
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$OUTPUT:
NUMBER_KEYS

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_NUMBER_KEYS;

    PROCEDURE THE_QUESTION;

    BEGIN

	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'An Indexed file can have from 1 to 255 keys.'
	    );

	{ +
	Pop the question.
	- }
	WRITE (
	SHIFT,'Number of Keys to Define',TAB,'(1-255)[1]',TAB,': ');
	NUMBER_INPUT (NUMBER_KEYS,TRUE,1);

	{ +
	Now do a little bounds checking.
	- }
	CHECK_WITHIN_LIMITS (1,NUMBER_KEYS,255);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Keep at it until the user gets it right.
    - }
    REPEAT

	THE_QUESTION;

    UNTIL NOT SYS$INPUT_ERROR;

    IF NUMBER_KEYS > 1 THEN

    BEGIN

	PROLOGUE_VERSION	:= 2;
	PROLOGUE_VERSION_VALID	:= TRUE;

	DATA_RECORD_COMP	:= 0.0;
	DATA_KEY_COMP		:= 0.0;
	INDEX_RECORD_COMP	:= 0.0;

    END;

END;	{ ASK_NUMBER_KEYS }

{ ++

ASK_CONTROL_SIZE -- Query the user.

This routine queries the user for the size of the fixed control portion of
his VFC record.

CALLING SEQUENCE:

ASK_CONTROL_SIZE;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

CRLF
TAB
SYS$INPUT_ERROR
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$OUTPUT:
CONTROL_SIZE

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_CONTROL_SIZE;

VAR
    CUR_MAX_FIXED	: INTEGER;

    PROCEDURE THE_QUESTION;

    BEGIN

	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'This refers to the Fixed portion of the record.'
	    );

	{ +
	Pop the question.
	- }
	WRITE (
	SHIFT,'Control Field Size',TAB,TAB,'(1-',
	CUR_MAX_FIXED:NUM_LEN(CUR_MAX_FIXED),
	')[2]',TAB,': ');
	NUMBER_INPUT (CONTROL_SIZE,TRUE,2);

	{ +
	Now do a little bounds checking.
	- }
	CHECK_WITHIN_LIMITS (1,CONTROL_SIZE,CUR_MAX_FIXED);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    IF MEAN_RECORD_SIZE < 256 THEN

	CUR_MAX_FIXED	:= MEAN_RECORD_SIZE

    ELSE

	CUR_MAX_FIXED	:= 255;

    { +
    Don't actually ask the question if the user is optimizing a key.
    - }
    IF (
    (VISIBLE_QUESTION)
    OR
    (NOT OPTIMIZING)
    ) THEN

    BEGIN

	{ +
	Keep at it until the user gets it right.
	- }
	REPEAT

	    THE_QUESTION;

	UNTIL NOT SYS$INPUT_ERROR;

    END		{ IF TRUE NOT OPTIMIZING }

    ELSE

    BEGIN

	IF FIND_OBJECT (SEC,RECORD$,0,CONTROL_FIELD_SIZE,0) THEN

	    CONTROL_SIZE	:= DEF_CURRENT^.NUMBER

	ELSE

	BEGIN

	    REPEAT

		THE_QUESTION;

	    UNTIL NOT SYS$INPUT_ERROR;

	END;

    END;	{ IF FALSE NOT OPTIMIZING }

    { +
    Tighten the limit on record size now.
    - }
    CUR_MAX_REC		:= CUR_MAX_REC - CONTROL_SIZE;

END;	{ ASK_CONTROL_SIZE }

{ ++

ASK_MAX_REC_SIZE -- Query the user about his maximum record size.

This routine queries the user for MAX_RECORD_SIZE.

CALLING SEQUENCE:

ASK_MAX_REC_SIZE;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

CRLF
TAB
SYS$INPUT_ERROR
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$OUTPUT:
MAX_RECORD_SIZE

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_MAX_REC_SIZE;

VAR
    EXTRA	: INTEGER;
    LOWMAX	: INTEGER;

    PROCEDURE THE_QUESTION;

    BEGIN

	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	BEGIN

	    WRITELN (
	    SHIFT,'This sets the longest record that can be stored in the file.'
	    );

	    IF DESIGN_ORG <> RELATIVE THEN

		WRITELN (
		SHIFT,'A maximum of 0 means to set no explicit maximum.'
		);

	END;

	{ +
	Pop the question.
	- }
	WRITE (
	SHIFT,'Maximum Record Size',TAB,TAB,'(');

	IF DESIGN_ORG = RELATIVE THEN

	BEGIN

	    EXTRA	:= 0;

	END

	ELSE

	BEGIN

	    WRITE ('0,');
	    EXTRA	:= 2;

	END;

	WRITE (
	LOWMAX:NUM_LEN(LOWMAX),'-',CUR_MAX_REC:NUM_LEN(CUR_MAX_REC),')',
	ANSI_REVERSE,'[-]',ANSI_RESET);

	IF (
	( EXTRA + NUM_LEN(LOWMAX) + NUM_LEN(CUR_MAX_REC) ) > 9
	) THEN

	    WRITE (' : ')

	ELSE

	    WRITE (TAB,': ');

	NUMBER_INPUT (MAX_RECORD_SIZE,FALSE,0);

	{ +
	Now do a little bounds checking.
	- }
	IF (
	(DESIGN_ORG = RELATIVE)
	OR
	(MAX_RECORD_SIZE <> 0)
	) THEN

	    CHECK_WITHIN_LIMITS (LOWMAX,MAX_RECORD_SIZE,CUR_MAX_REC);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Because mean_record_size includes fixed control area, and maximum
    record size doesn't, it's possible to get a mean that's larger
    than the max. Don't get confused by it.
    - }
    IF CUR_MAX_REC < MEAN_RECORD_SIZE THEN

	LOWMAX	:= CUR_MAX_REC

    ELSE

	LOWMAX	:= MEAN_RECORD_SIZE;

    { +
    Don't actually ask the question if the user is optimizing a key.
    - }
    IF (
    (VISIBLE_QUESTION)
    OR
    (NOT OPTIMIZING)
    ) THEN

    BEGIN

	{ +
	Keep at it until the user gets it right.
	- }
	REPEAT

	    THE_QUESTION;

	UNTIL NOT SYS$INPUT_ERROR;

    END		{ IF TRUE NOT OPTIMIZING }

    ELSE

    BEGIN

	IF FIND_OBJECT (SEC,RECORD$,0,SIZE,0) THEN

	    MAX_RECORD_SIZE	:= DEF_CURRENT^.NUMBER

	ELSE

	BEGIN

	    REPEAT

		THE_QUESTION;

	    UNTIL NOT SYS$INPUT_ERROR;

	END;

    END;	{ IF FALSE NOT OPTIMIZING }

END;	{ ASK_MAX_REC_SIZE }

{ ++

ASK_CARR_CTRL -- Find out what kind of carriage control he wants.

This routine queries the user for his carriage control.

CALLING SEQUENCE:

ASK_CARR_CTRL;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

CRLF
TAB
SYS$INPUT_ERROR
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$OUTPUT:

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_CARR_CTRL;

    PROCEDURE THE_QUESTION;

    BEGIN

	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'This sets the Record attributes of the file.'
	    );

	{ +
	Pop the question.
	- }
	WRITELN (SHIFT,'(Carriage_Return FORTRAN None Print)');
	WRITE (
	SHIFT,'Carriage Control',TAB,TAB,'(Keyword)[Carr]',TAB,': ');
	PARSE_INPUT (
	EDF$AB_CARR_TABLE_KEY,EDF$AB_CARR_TABLE_STA,TRUE,ORD(CARRIAGE_RETURN)
	);

	CARR_CTRL	:= CVT_INT_QUAL (INPUT_VALUE);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Don't actually ask the question if the user is optimizing a key, or if
    it's an alternate key - unless it hasn't been asked yet.
    - }
    IF NOT OPTIMIZING THEN

    BEGIN

	IF (
	((ACTIVE_KEY = 0) OR (NOT CARR_CTRL_VALID))
	) THEN

	BEGIN

	    { +
	    Keep at it until the user gets it right.
	    - }
	    REPEAT

		THE_QUESTION;

	    UNTIL NOT SYS$INPUT_ERROR;

	END;

    END

    ELSE

    BEGIN

	IF FIND_OBJECT (SEC,RECORD$,0,CARRIAGE_CONTROL,0) THEN

	    CARR_CTRL	:= DEF_CURRENT^.QUALIFIER

	ELSE

	BEGIN

	    REPEAT

		THE_QUESTION;

	    UNTIL NOT SYS$INPUT_ERROR;

	END;

    END;

END;	{ ASK_CARR_CTRL }

{ ++

ASK_TEST_PRIMARY -- Input the user's choice of primary.

This routine queries the user for his primary.

CALLING SEQUENCE:

ASK_TEST_PRIMARY (TEST,DISPLAY);

INPUT PARAMETERS:

TEST
DISPLAY

IMPLICIT INPUTS:

CRLF
TAB
SYS$INPUT_ERROR
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$OUTPUT:

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_TEST_PRIMARY (VAR TEST : LINE_OBJECT; DISPLAY : DISPLAY_TYPE);

VAR
    HIGH_AREA	: INTEGER;
    HIGH_KEY	: INTEGER;
    FOUND_AREA	: BOOLEAN;
    FOUND_KEY	: BOOLEAN;

    PROCEDURE THE_QUESTION;

    BEGIN

	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	CLEAR (IF_FULL_PROMPT);

	CASE DISPLAY OF

	    ALL_POSSIBLE :

	    BEGIN

		IF FULL_PROMPT OR TEMP_FULL_PROMPT THEN

		BEGIN
	
		    WRITELN (
		    SHIFT,TAB,TAB,
		    ANSI_REVERSE,DASH,
		    ' Legal Primary Attributes ',
		    DASH,ANSI_RESET,
		    CRLF
		    );
		    WRITELN (SHIFT,
		    'TITLE',TAB,'is the header line for the FDL file',
		    CRLF,SHIFT,
		    'SYSTEM',TAB,'is useful for cross-system compatibility');
		    WRITELN (SHIFT,
		    'FILE',TAB,'attributes affect the entire RMS data file',
		    CRLF,SHIFT,
		    'DATE',TAB,'attributes set the date parameters of the file',
		    CRLF,SHIFT,
		    'RECORD',TAB,'attributes set the non-key aspects of each record');
		    WRITELN (SHIFT,
		    'AREA x',TAB,'attributes define the characteristics of file area x',
		    CRLF,SHIFT,
		    'KEY y',TAB,'attributes define the characteristics of key y',
		    CRLF
		    );
	
		END
	
		ELSE
	
		    WRITELN (
		    SHIFT,'(TITLE SYSTEM FILE DATE RECORD AREA KEY)'
		    );

	    END;	{ ALL_POSSIBLE }

	    EXTANT_ONLY :

	    BEGIN

		IF FULL_PROMPT OR TEMP_FULL_PROMPT THEN

		BEGIN

		    WRITELN (
		    SHIFT,TAB,TAB,
		    ANSI_REVERSE,DASH,
		    ' Current Primary Attributes ',
		    DASH,ANSI_RESET,
		    CRLF
		    );

		    { +
		    Setup to display definition on the terminal.
		    - }
		    OPEN	(FDL_DEST,SYS$OUTPUT_NAME,NEW);
		    REWRITE	(FDL_DEST);

		    SHOW_ALL_PRIMARIES;

		    CLOSE	(FDL_DEST);

		END

		ELSE

		    WRITELN (SHIFT,
		    '(Type "?" for a list of existing Primary Attributes)');

	    END;	{ EXTANT_ONLY }

	OTHERWISE

	    { +
	    BUGCHECK!!
	    - }
	    LIB$SIGNAL (EDF$_INTSWERR,1,3,0);

	END;	{ CASE }

	{ +
	Pop the question.
	- }
	WRITE (SHIFT,'Enter Desired Primary',TAB,TAB,'(Keyword)',
	ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');
	PARSE_INPUT (
	EDF$AB_PRIMARY_TABLE_KEY,EDF$AB_PRIMARY_TABLE_STA,FALSE,0
	);

	TEST.OBJECT_TYPE	:= PRI;
	TEST.PRIMARY		:= CVT_INT_PRI (INPUT_VALUE);
	TEST.PRINUM		:= INPUT_NUMBER;
	ACTIVE_PRIMARY		:= TEST.PRIMARY;

	IF (
	(TEST.PRIMARY = AREA)
	OR
	(TEST.PRIMARY = KEY)
	) THEN

	BEGIN

	    IF TEST.PRINUM > 254 THEN

		LIB$SIGNAL (EDF$_BADVALUE,0,0,0);

	    HIGH_AREA	:= 0;
	    HIGH_KEY	:= 0;
	    FOUND_AREA	:= FALSE;
	    FOUND_KEY	:= FALSE;
	    DEF_CURRENT	:= DEF_HEAD;

	    REPEAT

		IF DEF_CURRENT^.PRIMARY = AREA THEN

		    FOUND_AREA	:= TRUE;

		IF (
		(DEF_CURRENT^.PRIMARY = AREA)
		AND
		(DEF_CURRENT^.PRINUM > HIGH_AREA)
		) THEN

		    HIGH_AREA	:= DEF_CURRENT^.PRINUM;

		IF DEF_CURRENT^.PRIMARY = KEY THEN

		    FOUND_KEY	:= TRUE;

		IF (
		(DEF_CURRENT^.PRIMARY = KEY)
		AND
		(DEF_CURRENT^.PRINUM > HIGH_KEY)
		) THEN

		    HIGH_KEY	:= DEF_CURRENT^.PRINUM;

		INCR_CURRENT;

	    UNTIL DEF_CURRENT = NIL;

	    IF (
	    (FOUND_AREA)
	    AND
	    (TEST.PRIMARY = AREA)
	    AND
	    ((TEST.PRINUM - HIGH_AREA) > 1)
	    ) THEN

		LIB$SIGNAL (EDF$_BADVALUE,0,0,0);

	    IF (
	    (FOUND_KEY)
	    AND
	    (TEST.PRIMARY = KEY)
	    AND
	    ((TEST.PRINUM - HIGH_KEY) > 1)
	    ) THEN

		LIB$SIGNAL (EDF$_BADVALUE,0,0,0);

	    IF (
	    (NOT FOUND_AREA)
	    AND
	    (TEST.PRIMARY = AREA)
	    AND
	    (TEST.PRINUM > 0)
	    ) THEN

		LIB$SIGNAL (EDF$_BADVALUE,0,0,0);

	    IF (
	    (NOT FOUND_KEY)
	    AND
	    (TEST.PRIMARY = KEY)
	    AND
	    (TEST.PRINUM > 0)
	    ) THEN

		LIB$SIGNAL (EDF$_BADVALUE,0,0,0);

	END	{ IF TRUE (TEST.PRIMARY = AREA) OR (TEST.PRIMARY = KEY) }

	ELSE

	    TEST.PRINUM		:= 0;

	{ +
	If we're asking for only ones that exist, make sure this one does.
	- }
	IF DISPLAY = EXTANT_ONLY THEN

	BEGIN

	    DEF_CURRENT	:= DEF_HEAD;

	    REPEAT

		IF NOT CURRENT_EQ_TEST(TEST,PRIMARY) THEN

		    INCR_CURRENT;

	    UNTIL (CURRENT_EQ_TEST(TEST,PRIMARY) OR (DEF_CURRENT^.FORE = NIL));

	    IF DEF_CURRENT <> NIL THEN

	    BEGIN

		IF NOT CURRENT_EQ_TEST(TEST,PRIMARY) THEN

		    LIB$SIGNAL (EDF$_BADVALUE,0,0,0);

	    END

	    ELSE

		LIB$SIGNAL (EDF$_BADVALUE,0,0,0);

	END;	{ IF DISPLAY = EXTANT_ONLY }

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Keep at it until the user gets it right.
    - }
    REPEAT

	THE_QUESTION;

    UNTIL NOT SYS$INPUT_ERROR;

    { +
    Setup for later...
    - }
    IF ACTIVE_PRIMARY = AREA THEN

	ACTIVE_AREA		:= INPUT_NUMBER

    ELSE IF ACTIVE_PRIMARY = KEY THEN

    BEGIN

	ACTIVE_KEY		:= INPUT_NUMBER;
	SETUP_KEY_LENGTH;

	IF HIGH_KEY > 0 THEN

	BEGIN

	    PROLOGUE_VERSION		:= 2;
	    PROLOGUE_VERSION_VALID	:= TRUE;

	    DATA_RECORD_COMP		:= 0.0;
	    DATA_KEY_COMP		:= 0.0;
	    INDEX_RECORD_COMP		:= 0.0;

	END;

    END;	{ IF TRUE ACTIVE_PRIMARY = KEY }

END;	{ ASK_TEST_PRIMARY }

{ ++

ASK_TEST_SECONDARY -- Get the user's choice of secondary.

This routine queries the user.

CALLING SEQUENCE:

ASK_TEST_SECONDARY (TEST,DISPLAY);

INPUT PARAMETERS:

TEST
DISPLAY

IMPLICIT INPUTS:

CRLF
TAB
SYS$INPUT_ERROR
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$OUTPUT:

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_TEST_SECONDARY (VAR TEST : LINE_OBJECT; DISPLAY : DISPLAY_TYPE);

    PROCEDURE THE_QUESTION;

    BEGIN

	{ +
	Set up to catch bad user input.
	- }
	EDF$GL_SECNUM^	:= 0;
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	CASE ACTIVE_PRIMARY OF

	    IDENT :

		INPUT_VALUE	:= 0;	{ DUMMY_SECONDARY$ }

	    TITLE :

		INPUT_VALUE	:= 0;	{ DUMMY_SECONDARY$ }

	    ANALYSIS_OF_AREA :

		INPUT_VALUE	:= 0;	{ DUMMY_SECONDARY$ }

	    ANALYSIS_OF_KEY :

		INPUT_VALUE	:= 0;	{ DUMMY_SECONDARY$ }

	    AREA :

	    BEGIN

		CASE DISPLAY OF

		    ALL_POSSIBLE :

			BEGIN

			    CLEAR (IF_FULL_PROMPT);

			    IF FULL_PROMPT OR TEMP_FULL_PROMPT THEN

			    BEGIN

				WRITELN (SHIFT,TAB,TAB,ANSI_REVERSE,DASH,
				' Legal AREA ',ACTIVE_AREA:NUM_LEN(ACTIVE_AREA),
				' Secondary Attributes ',
				DASH,ANSI_RESET,CRLF);

				WRITELN (SHIFT,
				'ALLOCATION',TAB,TAB,'number');
				WRITELN (SHIFT,
				'BEST_TRY_CONTIGUOUS',TAB,'yes/no');
				WRITELN (SHIFT,
				'BUCKET_SIZE',TAB,TAB,'number');
				WRITELN (SHIFT,
				'CONTIGUOUS',TAB,TAB,'yes/no');
				WRITELN (SHIFT,
				'EXACT_POSITIONING',TAB,'yes/no');
				WRITELN (SHIFT,
				'EXTENSION',TAB,TAB,'number');
				WRITELN (SHIFT,
				'POSITION    qualifier',TAB,'number');
				WRITELN (SHIFT,
				'VOLUME',TAB,TAB,TAB,'number');
				WRITELN;

			    END	{ IF FULL_PROMPT OR TEMP_FULL_PROMPT TRUE }

			    ELSE

				WRITELN (SHIFT,'(Type "?" for list of Keywords)');

			END;	{ ALL_POSSIBLE }

		    EXTANT_ONLY :
	
			BEGIN
	
			    CLEAR (IF_FULL_PROMPT);

			    IF FULL_PROMPT OR TEMP_FULL_PROMPT THEN

			    BEGIN

				WRITELN (SHIFT,TAB,TAB,ANSI_REVERSE,DASH,
				' Current AREA ',
				ACTIVE_AREA:NUM_LEN(ACTIVE_AREA),
				' Secondary Attributes ',
				DASH,ANSI_RESET,CRLF);

				{ +
				Setup to display definition on the terminal.
				- }
				OPEN	(FDL_DEST,SYS$OUTPUT_NAME,NEW);
				REWRITE	(FDL_DEST);

				SHOW_PRIMARY_SECTION (TEST);

				CLOSE (FDL_DEST);
	
			    END	{ IF FULL_PROMPT OR TEMP_FULL_PROMPT TRUE }

			    ELSE

				WRITELN (SHIFT,'(Type "?" for list of Keywords)');

			END;	{ EXTANT_ONLY }
	
		OTHERWISE

		    { +
		    BUGCHECK!!
		    - }
		    LIB$SIGNAL (EDF$_INTSWERR,1,4,0);

		END;	{ CASE }

		WRITE (SHIFT,'Enter AREA ',ACTIVE_AREA:NUM_LEN(ACTIVE_AREA),
		' Attribute',TAB,TAB,'(Keyword)',
		ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');
		PARSE_INPUT (
		EDF$AB_AREA_TABLE_KEY,EDF$AB_AREA_TABLE_STA,FALSE,0
		);

	    END;	{ AREA }

	    DATE :

	    BEGIN

		CASE DISPLAY OF

		    ALL_POSSIBLE :

			BEGIN

			    CLEAR (IF_FULL_PROMPT);
	    
			    IF FULL_PROMPT OR TEMP_FULL_PROMPT THEN
	    
			    BEGIN
	    
				WRITELN (SHIFT,TAB,TAB,ANSI_REVERSE,DASH,
				' Legal DATE Secondary Attributes ',
				DASH,ANSI_RESET,CRLF);
	    
				WRITELN (SHIFT,
				'BACKUP',TAB,TAB,TAB,'string');
				WRITELN (SHIFT,
				'CREATION',TAB,TAB,'string');
				WRITELN (SHIFT,
				'EXPIRATION',TAB,TAB,'string');
				WRITELN (SHIFT,
				'REVISION',TAB,TAB,'string');
				WRITELN;
	    
			    END	{ IF FULL_PROMPT OR TEMP_FULL_PROMPT TRUE }
	    
			    ELSE
	    
				WRITELN (SHIFT,'(Type "?" for list of Keywords)');

			END;	{ ALL_POSSIBLE }

		    EXTANT_ONLY :
	
			BEGIN
	
			    CLEAR (IF_FULL_PROMPT);

			    IF FULL_PROMPT OR TEMP_FULL_PROMPT THEN

			    BEGIN

				WRITELN (SHIFT,TAB,TAB,ANSI_REVERSE,DASH,
				' Current DATE Secondary Attributes ',
				DASH,ANSI_RESET,CRLF);

				{ +
				Setup to display definition on the terminal.
				- }
				OPEN	(FDL_DEST,SYS$OUTPUT_NAME,NEW);
				REWRITE	(FDL_DEST);

				SHOW_PRIMARY_SECTION (TEST);

				CLOSE (FDL_DEST);
	
			    END	{ IF FULL_PROMPT OR TEMP_FULL_PROMPT TRUE }

			    ELSE

				WRITELN (SHIFT,'(Type "?" for list of Keywords)');

			END;	{ EXTANT_ONLY }

		OTHERWISE

		    { +
		    BUGCHECK!!
		    - }
		    LIB$SIGNAL (EDF$_INTSWERR,1,5,0);

		END;	{ CASE }

		WRITE (SHIFT,'Enter DATE Attribute',TAB,TAB,'(Keyword)',
		ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');
		PARSE_INPUT (
		EDF$AB_DATE_TABLE_KEY,EDF$AB_DATE_TABLE_STA,FALSE,0
		);

	    END;	{ DATE }

	    FILE$ :

	    BEGIN

		CASE DISPLAY OF

		    ALL_POSSIBLE :

			BEGIN

			    CLEAR (IF_FULL_PROMPT);

			    IF FULL_PROMPT OR TEMP_FULL_PROMPT THEN
	    
			    BEGIN
	    
				WRITELN (SHIFT,TAB,TAB,ANSI_REVERSE,DASH,
				' Legal FILE Secondary Attributes ',
				DASH,ANSI_RESET,CRLF);
	    
{ ** NOW V3B ** 'BACKUP',TAB,TAB,TAB,'yes/no',TAB,TAB, ** }
	    
				WRITELN (SHIFT,
'ALLOCATION',TAB,TAB,'number',TAB,TAB,'MAX_RECORD_NUMBER',TAB,'number');
				WRITELN (SHIFT,
'BEST_TRY_CONTIGUOUS',TAB,'yes/no',TAB,TAB,'MAXIMIZE_VERSION',TAB,'yes/no');
				WRITELN (SHIFT,
'BUCKET_SIZE',TAB,TAB,'number',TAB,TAB,'NAME',TAB,TAB,TAB,'string');
				WRITELN (SHIFT,
'CONTIGUOUS',TAB,TAB,'yes/no',TAB,TAB,'ORGANIZATION',TAB,TAB,'keyword');
				WRITELN (SHIFT,
'DEFAULT_NAME',TAB,TAB,'string',TAB,TAB,'OWNER',TAB,TAB,TAB,'string');
				WRITELN (SHIFT,
'DELETE_ON_CLOSE',TAB,TAB,'yes/no',TAB,TAB,'PRINT_ON_CLOSE',TAB,TAB,'yes/no');
				WRITELN (SHIFT,
'DIRECTORY_ENTRY',TAB,TAB,'yes/no',TAB,TAB,'PROTECTION',TAB,TAB,'string');
				WRITELN (SHIFT,
'EXTENSION',TAB,TAB,'number',TAB,TAB,'READ_CHECK',TAB,TAB,'yes/no');
				WRITELN (SHIFT,
'GLOBAL_BUFFER_COUNT',TAB,'number',TAB,TAB,'REVISION',TAB,TAB,'number');
				WRITELN (SHIFT,
'MAGTAPE_BLOCK_SIZE',TAB,'number',TAB,TAB,'SUBMIT_ON_CLOSE',TAB,TAB,'yes/no');
				WRITELN (SHIFT,
'MAGTAPE_CURRENT_POSITION yes/no',TAB,TAB,'SUPERSEDE',TAB,TAB,'yes/no');
				WRITELN (SHIFT,
'MAGTAPE_PROTECTION',TAB,'char',TAB,TAB,'TRUNCATE_ON_CLOSE',TAB,'yes/no');
				WRITELN (SHIFT,
'MAGTAPE_REWIND',TAB,TAB,'yes/no',TAB,TAB,'WRITE_CHECK',TAB,TAB,'yes/no');
	    
				WRITELN;
	    
			    END	{ IF FULL_PROMPT OR TEMP_FULL_PROMPT TRUE }
	    
			    ELSE
	    
				WRITELN (SHIFT,'(Type "?" for list of Keywords)');

			END;	{ ALL_POSSIBLE }

		    EXTANT_ONLY :
	
			BEGIN
	
			    CLEAR (IF_FULL_PROMPT);

			    IF FULL_PROMPT OR TEMP_FULL_PROMPT THEN

			    BEGIN

				WRITELN (SHIFT,TAB,TAB,ANSI_REVERSE,DASH,
				' Current FILE Secondary Attributes ',
				DASH,ANSI_RESET,CRLF);

				{ +
				Setup to display definition on the terminal.
				- }
				OPEN	(FDL_DEST,SYS$OUTPUT_NAME,NEW);
				REWRITE	(FDL_DEST);

				SHOW_PRIMARY_SECTION (TEST);

				CLOSE (FDL_DEST);
	
			    END	{ IF FULL_PROMPT OR TEMP_FULL_PROMPT TRUE }

			    ELSE

				WRITELN (SHIFT,'(Type "?" for list of Keywords)');

			END;	{ EXTANT_ONLY }

		OTHERWISE

		    { +
		    BUGCHECK!!
		    - }
		    LIB$SIGNAL (EDF$_INTSWERR,1,6,0);

		END;	{ CASE }

		WRITE (SHIFT,'Enter FILE Attribute',TAB,TAB,'(Keyword)',
		ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');
		PARSE_INPUT (
		EDF$AB_FILE_TABLE_KEY,EDF$AB_FILE_TABLE_STA,FALSE,0
		);

	    END;	{ FILE }

{
	    JOURNALING :

	    BEGIN

		CASE DISPLAY OF

		    ALL_POSSIBLE :

			BEGIN

			    CLEAR (IF_FULL_PROMPT);

			    IF FULL_PROMPT OR TEMP_FULL_PROMPT THEN
	    
			    BEGIN
	    
				WRITELN (SHIFT,TAB,TAB,ANSI_REVERSE,DASH,
				' Legal JOURNALING Secondary Attributes ',
				DASH,ANSI_RESET,CRLF);
	    
				WRITELN (SHIFT,
				'AFTER_IMAGE',TAB,TAB,'yes/no');
				WRITELN (SHIFT,
				'AUDIT_TRAIL',TAB,TAB,'keyword');
				WRITELN (SHIFT,
				'BEFORE_IMAGE',TAB,TAB,'yes/no');
				WRITELN (SHIFT,
				'RECOVERY_UNIT',TAB,TAB,'keyword');
				WRITELN;
	    
			    END	{ IF FULL_PROMPT OR TEMP_FULL_PROMPT TRUE }
{
			    ELSE
	    
				WRITELN (SHIFT,'(Type "?" for list of Keywords)');
	    
				    END;	{ ALL_POSSIBLE }
{
		    EXTANT_ONLY :
	
			BEGIN
	
			    CLEAR (IF_FULL_PROMPT);

			    IF FULL_PROMPT OR TEMP_FULL_PROMPT THEN

			    BEGIN

				WRITELN (SHIFT,TAB,TAB,ANSI_REVERSE,DASH,
				' Current JOURNALING Secondary Attributes ',
				DASH,ANSI_RESET,CRLF);

				{ +
				Setup to display definition on the terminal.
				- }
{				OPEN	(FDL_DEST,SYS$OUTPUT_NAME,NEW);
				REWRITE	(FDL_DEST);

				SHOW_PRIMARY_SECTION (TEST);

				CLOSE (FDL_DEST);
	
			    END	{ IF FULL_PROMPT OR TEMP_FULL_PROMPT TRUE }
{
			    ELSE

				WRITELN (SHIFT,'(Type "?" for list of Keywords)');

			END;	{ EXTANT_ONLY }
{
		OTHERWISE

		    { +
		    BUGCHECK!!
		    - }
{		    LIB$SIGNAL (EDF$_INTSWERR,1,7,0);

		END;	{ CASE }
{
		WRITE (SHIFT,'Enter JOURNALING Attribute',TAB,TAB,'(Keyword)',
		ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');
		PARSE_INPUT (
		EDF$AB_JOURNAL_TABLE_KEY,EDF$AB_JOURNAL_TABLE_STA,FALSE,0
		);

	    END;	{ JOURNALING }

	    KEY :

	    BEGIN

		CASE DISPLAY OF

		    ALL_POSSIBLE :

			BEGIN

			    CLEAR (IF_FULL_PROMPT);

			    IF FULL_PROMPT OR TEMP_FULL_PROMPT THEN
	    
			    BEGIN
	    
				WRITELN (SHIFT,TAB,TAB,ANSI_REVERSE,DASH,
				' Legal KEY ',
				ACTIVE_KEY:ACTIVE_KEY_LENGTH,
				' Secondary Attributes ',
				DASH,ANSI_RESET,CRLF);
	    
				WRITELN (SHIFT,

'CHANGES',TAB,TAB,TAB,'yes/no',TAB,TAB,'LEVEL1_INDEX_AREA',TAB,'number');
				WRITELN (SHIFT,
'DATA_AREA',TAB,TAB,'number',TAB,TAB,'NAME',TAB,TAB,TAB,'string');
				WRITELN (SHIFT,
'DATA_FILL',TAB,TAB,'number',TAB,TAB,'NULL_KEY',TAB,TAB,'yes/no');
				WRITELN (SHIFT,
'DATA_KEY_COMPRESSION',TAB,'yes/no',TAB,TAB,'NULL_VALUE',TAB,TAB,'char/num');
				WRITELN (SHIFT,
'DATA_RECORD_COMPRESSION',TAB,'yes/no',TAB,TAB,'POSITION',TAB,TAB,'number');
				WRITELN (SHIFT,
'DUPLICATES',TAB,TAB,'yes/no',TAB,TAB,'PROLOGUE',TAB,TAB,'number');
				WRITELN (SHIFT,
'INDEX_AREA',TAB,TAB,'number',TAB,TAB,'TYPE',TAB,TAB,TAB,'keyword');
				WRITELN (SHIFT,
'INDEX_COMPRESSION',TAB,'yes/no',TAB,TAB,'SEGn_LENGTH',TAB,TAB,'number');
				WRITELN (SHIFT,
'INDEX_FILL',TAB,TAB,'number',TAB,TAB,'SEGn_POSITION',TAB,TAB,'number');
				WRITELN (SHIFT,
'LENGTH',TAB,TAB,TAB,'number'{,TAB,TAB,'SEGn_TYPE',TAB,TAB,'keyword'});

				WRITELN;
	    
			    END	{ IF FULL_PROMPT OR TEMP_FULL_PROMPT TRUE }
	    
			    ELSE
	    
				WRITELN (SHIFT,'(Type "?" for list of Keywords)');

			END;	{ ALL_POSSIBLE }

		    EXTANT_ONLY :
	
			BEGIN
	
			    CLEAR (IF_FULL_PROMPT);

			    IF FULL_PROMPT OR TEMP_FULL_PROMPT THEN

			    BEGIN

				WRITELN (SHIFT,TAB,TAB,ANSI_REVERSE,DASH,
				' Current KEY ',
				ACTIVE_KEY:ACTIVE_KEY_LENGTH,
				' Secondary Attributes ',
				DASH,ANSI_RESET,CRLF);

				{ +
				Setup to display definition on the terminal.
				- }
				OPEN	(FDL_DEST,SYS$OUTPUT_NAME,NEW);
				REWRITE	(FDL_DEST);

				SHOW_PRIMARY_SECTION (TEST);

				CLOSE (FDL_DEST);
	
			    END	{ IF FULL_PROMPT OR TEMP_FULL_PROMPT TRUE }

			    ELSE

				WRITELN (SHIFT,'(Type "?" for list of Keywords)');

			END;	{ EXTANT_ONLY }

		OTHERWISE

		    { +
		    BUGCHECK!!
		    - }
		    LIB$SIGNAL (EDF$_INTSWERR,1,8,0);

		END;	{ CASE }

		WRITE (SHIFT,'Enter KEY ',
		ACTIVE_KEY:ACTIVE_KEY_LENGTH,ACTIVE_KEY_FILL,
		' Attribute',TAB,TAB,'(Keyword)',
		ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');
		PARSE_INPUT (
		EDF$AB_KEY_TABLE_KEY,EDF$AB_KEY_TABLE_STA,FALSE,0
		);

	    END;	{ KEY }

	    RECORD$ :

	    BEGIN

		CASE DISPLAY OF

		    ALL_POSSIBLE :

			BEGIN

			    CLEAR (IF_FULL_PROMPT);

			    IF FULL_PROMPT OR TEMP_FULL_PROMPT THEN
	    
			    BEGIN
	    
				WRITELN (SHIFT,TAB,TAB,ANSI_REVERSE,DASH,
				' Legal RECORD Secondary Attributes ',
				DASH,ANSI_RESET,CRLF);
	    
				WRITELN (SHIFT,
				'BLOCK_SPAN',TAB,TAB,'yes/no');
				WRITELN (SHIFT,
				'CARRIAGE_CONTROL',TAB,'keyword');
				WRITELN (SHIFT,
				'CONTROL_FIELD_SIZE',TAB,'number');
				WRITELN (SHIFT,
				'FORMAT',TAB,TAB,TAB,'keyword');
				WRITELN (SHIFT,
				'SIZE',TAB,TAB,TAB,'number');
				WRITELN;
	    
			    END	{ IF FULL_PROMPT OR TEMP_FULL_PROMPT TRUE }
	    
			    ELSE
	    
				WRITELN (SHIFT,'(Type "?" for list of Keywords)');

				    END;	{ ALL_POSSIBLE }

		    EXTANT_ONLY :
	
			BEGIN
	
			    CLEAR (IF_FULL_PROMPT);

			    IF FULL_PROMPT OR TEMP_FULL_PROMPT THEN

			    BEGIN

				WRITELN (SHIFT,TAB,TAB,ANSI_REVERSE,DASH,
				' Current RECORD Secondary Attributes ',
				DASH,ANSI_RESET,CRLF);

				{ +
				Setup to display definition on the terminal.
				- }
				OPEN	(FDL_DEST,SYS$OUTPUT_NAME,NEW);
				REWRITE	(FDL_DEST);

				SHOW_PRIMARY_SECTION (TEST);

				CLOSE (FDL_DEST);
	
			    END	{ IF FULL_PROMPT OR TEMP_FULL_PROMPT TRUE }

			    ELSE

				WRITELN (SHIFT,'(Type "?" for list of Keywords)');

			END;	{ EXTANT_ONLY }

		OTHERWISE

		    { +
		    BUGCHECK!!
		    - }
		    LIB$SIGNAL (EDF$_INTSWERR,1,9,0);

		END;	{ CASE }

		WRITE (SHIFT,'Enter RECORD Attribute',TAB,TAB,'(Keyword)',
		ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');
		PARSE_INPUT (
		EDF$AB_RECORD_TABLE_KEY,EDF$AB_RECORD_TABLE_STA,FALSE,0
		);

	    END;	{ RECORD }

	    SYSTEM :

	    BEGIN

		CASE DISPLAY OF

		    ALL_POSSIBLE :

			BEGIN

			    CLEAR (IF_FULL_PROMPT);

			    IF FULL_PROMPT OR TEMP_FULL_PROMPT THEN
	    
			    BEGIN
	    
				WRITELN (SHIFT,TAB,TAB,ANSI_REVERSE,DASH,
				' Legal SYSTEM Secondary Attributes ',
				DASH,ANSI_RESET,CRLF);
	    
				WRITELN (SHIFT,
				'DEVICE',TAB,'string');
				WRITELN (SHIFT,
				'SOURCE',TAB,'keyword');
				WRITELN (SHIFT,
				'TARGET',TAB,'keyword');
				WRITELN;
	    
			    END	{ IF FULL_PROMPT OR TEMP_FULL_PROMPT TRUE }
	    
			    ELSE
	    
				WRITELN (SHIFT,'(Type "?" for list of Keywords)');

			END;		{ ALL_POSSIBLE }

		    EXTANT_ONLY :
	
			BEGIN
	
			    CLEAR (IF_FULL_PROMPT);

			    IF FULL_PROMPT OR TEMP_FULL_PROMPT THEN

			    BEGIN

				WRITELN (SHIFT,TAB,TAB,ANSI_REVERSE,DASH,
				' Current SYSTEM Secondary Attributes ',
				DASH,ANSI_RESET,CRLF);

				{ +
				Setup to display definition on the terminal.
				- }
				OPEN	(FDL_DEST,SYS$OUTPUT_NAME,NEW);
				REWRITE	(FDL_DEST);

				SHOW_PRIMARY_SECTION (TEST);

				CLOSE (FDL_DEST);
	
			    END	{ IF FULL_PROMPT OR TEMP_FULL_PROMPT TRUE }

			    ELSE

				WRITELN (SHIFT,'(Type "?" for list of Keywords)');

			END;	{ EXTANT_ONLY }

		OTHERWISE

		    { +
		    BUGCHECK!!
		    - }
		    LIB$SIGNAL (EDF$_INTSWERR,1,10,0);

		END;	{ CASE }

		WRITE (SHIFT,'Enter SYSTEM Attribute',TAB,TAB,'(Keyword)',
		ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');
		PARSE_INPUT (
		EDF$AB_SYSTEM_TABLE_KEY,EDF$AB_SYSTEM_TABLE_STA,FALSE,0
		);

	    END;	{ SYSTEM }

	OTHERWISE

	    { +
	    BUGCHECK!!
	    - }
	    LIB$SIGNAL (EDF$_INTSWERR,1,11,0);

	END;	{ CASE }

	IF TEST.PRIMARY <> TITLE THEN

	    TEST.OBJECT_TYPE	:= SEC;

	TEST.SECONDARY	:= CVT_INT_SEC (INPUT_VALUE);

	{ +
	Get the secondary number if there was one, it's inited to 0;
	only SEGn_LENGTH,_POSITION,_TYPE(V3B) set it.
	- }
	TEST.SECNUM	:= EDF$GL_SECNUM^;

	CHECK_WITHIN_LIMITS (0,TEST.SECNUM,7);

	{ +
	If we're only to ask for what exists, then make sure this does.
	- }
	IF DISPLAY = EXTANT_ONLY THEN

	BEGIN

	    DEF_CURRENT		:= DEF_HEAD;

	    REPEAT

		IF NOT CURRENT_EQ_TEST(TEST,EXACT) THEN

		    INCR_CURRENT;

	    UNTIL (CURRENT_EQ_TEST(TEST,EXACT) OR (DEF_CURRENT^.FORE = NIL));

	    IF DEF_CURRENT <> NIL THEN

	    BEGIN

		IF NOT CURRENT_EQ_TEST(TEST,EXACT) THEN

		    LIB$SIGNAL (EDF$_BADVALUE,0,0,0);

	    END

	    ELSE

		    LIB$SIGNAL (EDF$_BADVALUE,0,0,0);

	END;	{ IF DISPLAY = EXTANT_ONLY }

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Keep at it until the user gets it right.
    - }
    REPEAT

	THE_QUESTION;

    UNTIL NOT SYS$INPUT_ERROR;

END;	{ ASK_TEST_SECONDARY }

{ ++

ASK_TEST_SECONDARY_VALUE -- Input the user's value for the secondary.

This routine queries the user about his secondary.

CALLING SEQUENCE:

ASK_TEST_SECONDARY_VALUE (TEST);

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
SYS$OUTPUT:

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_TEST_SECONDARY_VALUE (VAR TEST : LINE_OBJECT);

VAR
    I			: INTEGER;
    TEMP_INT		: INTEGER;
    TEMP_DESC		: DESCRIPTOR;
    TEMP_MAX		: INTEGER;
    TEMP_STRING255	: STRING255;

    PROCEDURE THE_QUESTION;

    BEGIN

	{ +
	Set up the condition handler to catch typing errors.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (SHIFT,
	    'The value entered will be put into the Definition.');

	{ +
	Pop the question.
	- }
	IF TEST.SECONDARY = POSITION$ THEN

	    WRITE (CRLF,SHIFT,'Enter POSITION qualifier',TAB,'(')

	ELSE

	    WRITE (CRLF,SHIFT,'Enter value for this Secondary',TAB,'(');

	IF QUALIFIER_VALUED (TEST.SECONDARY) THEN

	BEGIN

	    WRITE ('Keyword)',ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');

	    CASE TEST.SECONDARY OF

		ORGANIZATION :

		PARSE_INPUT (
		EDF$AB_ORG_TABLE_KEY,EDF$AB_ORG_TABLE_STA,FALSE,0
		);

		SOURCE :

		PARSE_INPUT (
		EDF$AB_SOURCE_TABLE_KEY,EDF$AB_SOURCE_TABLE_STA,FALSE,0
		);

		TARGET :

		PARSE_INPUT (
		EDF$AB_SOURCE_TABLE_KEY,EDF$AB_SOURCE_TABLE_STA,FALSE,0
		);

{
		AUDIT_TRAIL :

		PARSE_INPUT (
		EDF$AB_AT_TABLE_KEY,EDF$AB_AT_TABLE_STA,FALSE,0
		);

		RECOVERY_UNIT :

		PARSE_INPUT (
		EDF$AB_RU_TABLE_KEY,EDF$AB_RU_TABLE_STA,FALSE,0
		);
}

		CARRIAGE_CONTROL :

		PARSE_INPUT (
		EDF$AB_CARR_TABLE_KEY,EDF$AB_CARR_TABLE_STA,FALSE,0
		);

		FORMAT :

		PARSE_INPUT (
		EDF$AB_FORMAT_TABLE_KEY,EDF$AB_FORMAT_TABLE_STA,FALSE,0
		);

		SEG_TYPE :

		PARSE_INPUT (
		EDF$AB_TYPE_TABLE_KEY,EDF$AB_TYPE_TABLE_STA,FALSE,0
		);

	    OTHERWISE

		{ +
		BUGCHECK!!
		- }
		LIB$SIGNAL (EDF$_INTSWERR,1,12,0);

	    END;	{ CASE }

	    TEST.QUALIFIER	:= CVT_INT_QUAL (INPUT_VALUE);

	END;	{ IF QUALIFIER_VALUED }

	IF NUMBER_VALUED (TEST.SECONDARY) THEN

	BEGIN

	    TEMP_MAX	:= SECONDARY_MAX[TEST.SECONDARY];

	    IF (TEST.SECONDARY IN

	    [ DATA_KEY_COMPRESSION,
	    DATA_RECORD_COMPRESSION,
	    INDEX_COMPRESSION ]

	    ) THEN

		WRITE ('Abs<100)')

	    ELSE IF TEMP_MAX = EDF$C_1GIGA THEN

		WRITE ('0-1Giga)')

	    ELSE IF TEST.SECONDARY = PROLOGUE THEN

		WRITE ('0,2-3)')

	    ELSE

		WRITE ('0-',TEMP_MAX:NUM_LEN(TEMP_MAX),')');

	    WRITE (ANSI_REVERSE,'[-]',ANSI_RESET);

	    IF (
	    (NUM_LEN(TEMP_MAX) > 8)
	    AND
	    (TEMP_MAX <> EDF$C_1GIGA)
	    ) THEN

		WRITE (' : ')

	    ELSE

		WRITE (TAB,': ');

	    NUMBER_INPUT (TEST.NUMBER,FALSE,0);

	    IF (TEST.SECONDARY IN

	    [ DATA_KEY_COMPRESSION,
	    DATA_RECORD_COMPRESSION,
	    INDEX_COMPRESSION ]

	    ) THEN

	    BEGIN

		IF (
		((PROLOGUE_VERSION_VALID = TRUE) AND (PROLOGUE_VERSION = 2))
		AND
		(TEST.NUMBER <> 0)
		) THEN

		    LIB$SIGNAL (EDF$_BADVALUE,0,0,0);

		CHECK_WITHIN_LIMITS (-TEMP_MAX,TEST.NUMBER,TEMP_MAX);

	    END

	    ELSE IF TEST.SECONDARY = CONTROL_FIELD_SIZE THEN

		CHECK_WITHIN_LIMITS (1,TEST.NUMBER,TEMP_MAX)

	    ELSE

		CHECK_WITHIN_LIMITS (0,TEST.NUMBER,TEMP_MAX);

	    IF (
	    (TEST.SECONDARY = PROLOGUE)
	    AND
	    (TEST.NUMBER = 1)
	    ) THEN

		LIB$SIGNAL (EDF$_BADVALUE,0,0,0);

	    IF (
	    (TEST.SECONDARY = MAGTAPE_BLOCK_SIZE)
	    AND
	    (TEST.NUMBER > 0)
	    AND
	    (TEST.NUMBER < 20)
	    ) THEN

		LIB$SIGNAL (EDF$_BADVALUE,0,0,0);

	END;	{ IF NUMBER_VALUED }

	IF (
	(STRING_VALUED (TEST.SECONDARY))
	OR
	(TEST.PRIMARY = TITLE)
	) THEN

	BEGIN

	    IF TEST.PRIMARY = DATE THEN

		WRITE ('Date-str)',ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ')

	    ELSE IF TEST.SECONDARY = NAME$ THEN

		WRITE ('1-32 chars)[null]',TAB,': ')

	    ELSE

		WRITE ('1-126 chars)[null]',CRLF,SHIFT,': ');

	    READLN (TEMP_STRING255);
	    WRITELN (CRLF);

	    SETUP_DESC (TEST.STRING);
	    STR$TRIM (TEST.STRING,TEMP_STRING255);

	    IF TEST.PRIMARY = DATE THEN

	    BEGIN

		STR$UPCASE (TEST.STRING,TEST.STRING);
		STATUS	:= SYS$BINTIM (TEST.STRING,QUAD_TIME);

		IF TEST.STRING.DSC$W_LENGTH = 0 THEN

		BEGIN

		    STR$FREE1_DX (TEST.STRING);
		    LIB$SIGNAL (EDF$_NODEFAULT,0,0,0);

		END;

		IF NOT ODD (STATUS) THEN

		BEGIN

		    STR$FREE1_DX (TEST.STRING);
		    LIB$SIGNAL (EDF$_BADSYNTAX,0,0,0);

		END;

	    END;	{ IF TEST.PRIMARY = DATE }

	    IF (
	    (
	    (TEST.SECONDARY = NAME$)
	    AND
	    (TEST.STRING.DSC$W_LENGTH > 32)
	    )
	    OR
	    (TEST.STRING.DSC$W_LENGTH > 126)
	    ) THEN

	    BEGIN

		STR$FREE1_DX (TEST.STRING);
		LIB$SIGNAL (EDF$_BADSYNTAX,0,0,0);

	    END;

	END;	{ IF STRING_VALUED }

	IF SWITCH_VALUED (TEST.SECONDARY) THEN

	BEGIN

	    WRITE ('Yes/No)',ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');
	    PARSE_INPUT (
	    EDF$AB_YES_NO_TABLE_KEY,EDF$AB_YES_NO_TABLE_STA,FALSE,0
	    );

	    TEST.SWITCH	:= (INPUT_VALUE = EDF$C_YES);

	    IF (
	    (TEST.PRIMARY = KEY)
	    AND
	    (TEST.PRINUM = 0)
	    AND
	    (TEST.SECONDARY = CHANGES)
	    AND
	    (TEST.SWITCH = TRUE)
	    ) THEN

		LIB$SIGNAL (EDF$_BADVALUE,0,0,0);

	    IF (
	    (TEST.PRIMARY = RECORD$)
	    AND
	    (TEST.SECONDARY = BLOCK_SPAN)
	    AND
	    (TEST.SWITCH = TRUE)
	    ) THEN

	    BEGIN

		IF FIND_OBJECT (SEC,FILE$,0,ORGANIZATION,0) THEN

		BEGIN

		    IF DEF_CURRENT^.QUALIFIER <> SEQUENTIAL THEN

			LIB$SIGNAL (EDF$_BADVALUE,0,0,0);

		END;

	    END;

	END;	{ IF SWITCH_VALUED }

	IF TEST.SECONDARY = OWNER THEN

	BEGIN

	    EDF$GL_UIC_GROUP^	:= 0;
	    EDF$GL_UIC_MEMBER^	:= 0;

	    WRITE ('UIC-str)',ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');
	    PARSE_INPUT (
	    EDF$AB_UIC_TABLE_KEY,EDF$AB_UIC_TABLE_STA,FALSE,0
	    );

	    TEST.UIC_GROUP	:= EDF$GL_UIC_GROUP^;
	    TEST.UIC_MEMBER	:= EDF$GL_UIC_MEMBER^;

	END;	{ IF TEST.SECONDARY = OWNER }

	IF TEST.SECONDARY = PROTECTION THEN

	BEGIN

	    FOR I := 0 TO 31 DO

		EDF$GL_PROT_MASK^[I]	:= FALSE;

	    WRITE ('Prot-str)',ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');
	    PARSE_INPUT (
	    EDF$AB_PROT_TABLE_KEY,EDF$AB_PROT_TABLE_STA,FALSE,0
	    );

	    TEST.PROT_MASK	:= EDF$GL_PROT_MASK^;

	END;	{ IF TEST.SECONDARY = PROTECTION }

	IF TEST.SECONDARY = POSITION$ THEN

	BEGIN

	    WRITE ('Keyword)',ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');
	    PARSE_INPUT (
	    EDF$AB_POSIT_TABLE_KEY,EDF$AB_POSIT_TABLE_STA,FALSE,0
	    );

	    TEST.QUALIFIER	:= CVT_INT_QUAL (INPUT_VALUE);

	    IF NOT (TEST.QUALIFIER IN [ NOPOS, ANY_CYLINDER ]) THEN

	    BEGIN

		WRITE (CRLF,SHIFT,'Enter POSITION value',TAB,TAB,'(');

		CASE TEST.QUALIFIER OF

		    CLUSTER, CYLINDER, LOGICAL, VIRTUAL :

		    BEGIN

			WRITE ('0-1Giga)',ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');
			NUMBER_INPUT (TEST.NUMBER,FALSE,0);

		    END;

		    FILE_ID :

		    BEGIN

			EDF$GL_FID1^	:= 0;
			EDF$GL_FID2^	:= 0;
			EDF$GL_FID3^	:= 0;

			WRITE ('FID-str)',ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');
			PARSE_INPUT (
			EDF$AB_FID_TABLE_KEY,EDF$AB_FID_TABLE_STA,FALSE,0
			);

			TEST.FID1		:= EDF$GL_FID1^;
			TEST.FID2		:= EDF$GL_FID2^;
			TEST.FID3		:= EDF$GL_FID3^;

		    END;

		    FILE_NAME :

		    BEGIN

			WRITE ('1-109 chars)[null]',CRLF,SHIFT,': ');
			READLN (TEMP_STRING255);
			WRITELN (CRLF);

			SETUP_DESC (TEST.STRING);
			STR$TRIM (TEST.STRING,TEMP_STRING255);

			IF TEST.STRING.DSC$W_LENGTH > 109 THEN

			    LIB$SIGNAL (EDF$_BADSYNTAX,0,0,0);

		    END;

		OTHERWISE

		    { +
		    BUGCHECK!!
		    - }
		    LIB$SIGNAL (EDF$_INTSWERR,1,13,0);

		END;	{ CASE }

	    END;	{ IF NOT (TEST.QUALIFIER IN [ NOPOS, ANY_CYLINDER ]) }

	END;	{ IF TEST.SECONDARY = POSITION$ }

	IF (
	(TEST.SECONDARY = NULL_VALUE)
	OR
	(TEST.SECONDARY = MAGTAPE_PROTECTION)
	) THEN

	BEGIN

	    WRITE ('''char''/num)',ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');


	    READLN (TEMP_STRING255);
	    WRITELN (CRLF);

	    SETUP_DESC (TEMP_DESC);
	    STR$TRIM (TEMP_DESC,TEMP_STRING255);

	    IF TEMP_DESC.DSC$W_LENGTH = 0 THEN

	    BEGIN

		STR$FREE1_DX (TEMP_DESC);
		LIB$SIGNAL (EDF$_NODEFAULT,0,0,0);

	    END;

	    STATUS		:= OTS$CVT_TI_L (TEMP_DESC,TEMP_INT);

	    IF ODD (STATUS) THEN

		TEST.NUMBER	:= TEMP_INT

	    ELSE IF (
	    (TEMP_DESC.DSC$A_POINTER^[1] <> APOSTROPHE)
	    OR
	    (TEMP_DESC.DSC$A_POINTER^[3] <> APOSTROPHE)
	    ) THEN

	    BEGIN

		STR$FREE1_DX (TEMP_DESC);
		LIB$SIGNAL (EDF$_BADSYNTAX,0,0,0);

	    END

	    ELSE

		TEST.NUMBER	:= ORD (TEMP_DESC.DSC$A_POINTER^[2]);

	    IF TEST.SECONDARY = MAGTAPE_PROTECTION THEN

	    BEGIN

		{ +
		Make sure it's a legal ANSI-a character.
		- }
		IF (
		(TEST.NUMBER < %X20)	{ SPACE }
		OR
		(TEST.NUMBER > %X5A)	{ CAPITAL Z }
		OR
		(TEST.NUMBER = %X23)	{ # }
		OR
		(TEST.NUMBER = %X24)	{ $ }
		OR
		(TEST.NUMBER = %X40)	{ @ }
		) THEN		

		BEGIN

		    STR$FREE1_DX (TEMP_DESC);
		    LIB$SIGNAL (EDF$_BADVALUE,0,0,0);

		END;

	    END; { IF TEST.SECONDARY = MAGTAPE_PROTECTION }

	END;	{ IF TEST.SECONDARY = NULL_VALUE OR MAGTAPE_PROTECTION }

	{ +
	Make sure this is true only for one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    IF TEST.PRIMARY = TITLE THEN

	TEST.OBJECT_TYPE	:= PRI

    ELSE

	TEST.OBJECT_TYPE	:= SEC;

    { +
    Keep at it until the user gets it right.
    - }
    REPEAT

	THE_QUESTION;

    UNTIL NOT SYS$INPUT_ERROR;

END;		{ ASK_TEST_SECONDARY_VALUE }

{ ++

ASK_RECORD_FORMAT -- Query the user about his record format.

This routine asks the question.

CALLING SEQUENCE:

ASK_RECORD_FORMAT;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

RECORD_FORMAT
VARIABLE_RECORDS
SYS$INPUT_ERROR

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_RECORD_FORMAT;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'Indexed files are only Fixed or Variable.',CRLF,
	    SHIFT,'Stream format (Seq only) is Stream, Stream_CR, or Stream_LF.'
	    );

	{ +
	Pop the question.
	- }
	CASE DESIGN_ORG OF

	    INDEXED :		WRITELN (SHIFT,'(Fixed Variable)');
	    RELATIVE :		WRITELN (SHIFT,'(Fixed Variable VFC)');
	    SEQUENTIAL :	WRITELN (SHIFT,
				'(Fixed Stream _CR _LF Undefined Variable VFC)');

	OTHERWISE

	    { +
	    BUGCHECK!!
	    - }
	    LIB$SIGNAL (EDF$_INTSWERR,1,14,0);

	END;	{ CASE }

	WRITE (SHIFT,'Record Format',TAB,TAB,TAB,'(Keyword)[Var]',TAB,': ');
	PARSE_INPUT (
	EDF$AB_FORMAT_TABLE_KEY,EDF$AB_FORMAT_TABLE_STA,TRUE,35);

	RECORD_FORMAT	:= CVT_INT_QUAL (INPUT_VALUE);

	{ +
	Indexed files can have only fixed or variable record format.
	- }
	IF (
	(DESIGN_ORG = INDEXED)
	AND
	(NOT (RECORD_FORMAT IN [ VARIABLE, FIXED ]))
	) THEN

	    LIB$SIGNAL (EDF$_BADVALUE,0,0,0);

	IF (
	(DESIGN_ORG = RELATIVE)
	AND
	(RECORD_FORMAT IN [ STREAM, STREAM_CR, STREAM_LF, UNDEFINED ])
	) THEN

	    LIB$SIGNAL (EDF$_BADVALUE,0,0,0);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    This question shouldn't be asked for alternate keys, unless it hasn't been
    asked before.
    - }
    IF (
    (DESIGN_ORG <> INDEXED)
    OR
    (ACTIVE_KEY = 0)
    OR
    (NOT RECORD_FORMAT_VALID)
    ) THEN

    BEGIN

	{ +
	Don't actually ask the question if the user is optimizing.
	- }
	IF (
	(VISIBLE_QUESTION)
	OR
	(NOT OPTIMIZING)
	) THEN

	BEGIN

	    { +
	    Keep at it until the user gets it right.
	    - }
	    REPEAT

		THE_QUESTION;

	    UNTIL NOT SYS$INPUT_ERROR;

	END

	ELSE

	BEGIN

	    IF FIND_OBJECT (SEC,RECORD$,0,FORMAT,0) THEN

		RECORD_FORMAT	:= DEF_CURRENT^.QUALIFIER

	    ELSE

	    BEGIN

		REPEAT

		    THE_QUESTION;

		UNTIL NOT SYS$INPUT_ERROR;

	    END;

	END;

    END;

    { +
    Set a convenience boolean.
    - }
    VARIABLE_RECORDS	:= (
			    (RECORD_FORMAT <> FIXED)
			    AND
			    (RECORD_FORMAT <> UNDEFINED)
			    );

    RECORD_FORMAT_VALID	:= TRUE;

END;	{ ASK_RECORD_FORMAT }

{ ++

ASK_BUCKET_WEIGHT -- Queery the user.

This routine asks the question.

CALLING SEQUENCE:

ASK_BUCKET_WEIGHT;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

BUCKET_WEIGHT
SYS$INPUT_ERROR

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_BUCKET_WEIGHT;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'Smaller_Buffers: uses less memory, less RMS processing',
	    CRLF,
	    SHIFT,'Flatter_Files:   fewer random disk accesses'
	    );

	{ +
	Pop the question.
	- }
	WRITELN (SHIFT,'(Smaller_Buffers Flatter_Files)');
	WRITE (SHIFT,
	'Emphasis for Default Bucket_Size(Keyword)[Small]: ');
	PARSE_INPUT (
	EDF$AB_WEIGHT_TABLE_KEY,EDF$AB_WEIGHT_TABLE_STA,TRUE,
	EDF$C_SMALLER_BUFFERS
	);
    
	BUCKET_WEIGHT	:= INPUT_VALUE;

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Keep at it until the user gets it right.
    - }
    REPEAT

	THE_QUESTION;

    UNTIL NOT SYS$INPUT_ERROR;

END;	{ ASK_BUCKET_WEIGHT }

{ ++

ASK_PROLOGUE_VERSION -- Query the user.

This routine asks about which prologue version the user wants.

CALLING SEQUENCE:

ASK_PROLOGUE_VERSION;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

PROLOGUE_VERSION
SYS$INPUT_ERROR

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_PROLOGUE_VERSION;

VAR
    MAX_PROLOGUE	: INTEGER;
    HIGH_KEY		: INTEGER;
    LOW_KEY		: INTEGER;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'This refers to the structure level of the data file.'
	    );

	{ +
	Pop the question.
	- }
	WRITE (SHIFT,'File Prologue Version',TAB,TAB,
	'(2-',MAX_PROLOGUE:NUM_LEN(MAX_PROLOGUE),')[',
	MAX_PROLOGUE:NUM_LEN(MAX_PROLOGUE),']',TAB,': ');

	NUMBER_INPUT (PROLOGUE_VERSION,TRUE,MAX_PROLOGUE);

	CHECK_WITHIN_LIMITS (2,PROLOGUE_VERSION,MAX_PROLOGUE);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Find out the range of existing keys (assume contiguous).
    - }
    DEF_CURRENT		:= DEF_HEAD;
    LOW_KEY		:= 0;
    HIGH_KEY		:= 0;

    REPEAT

	WITH DEF_CURRENT^ DO

	BEGIN

	    IF (
	    (OBJECT_TYPE = PRI)
	    AND
	    (PRIMARY = KEY)
	    ) THEN

	    BEGIN

		IF PRINUM < LOW_KEY THEN

		    LOW_KEY	:= PRINUM;

		IF PRINUM > HIGH_KEY THEN

		    HIGH_KEY	:= PRINUM;

	    END;	{ IF }

	END;	{ WITH DEF_CURRENT^ DO }

	DEF_CURRENT	:= DEF_CURRENT^.FORE;

    UNTIL DEF_CURRENT = NIL;

    { +
    Setup highest we can have.
    - }
    IF (
    (ACTIVE_KEY > 0)
    OR
    (NUMBER_KEYS > 1)
    OR
    (HIGH_KEY > 0)
    OR
    (LOW_KEY > 0)
    OR
    (KEY_TYPE <> STRING)
    ) THEN

	MAX_PROLOGUE	:= 2

    ELSE

	MAX_PROLOGUE	:= 3;

    { +
    This question shouldn't be asked for alternate keys. Unless redesigning,
    and we don't already have a value for it.
    - }
    IF (
    (DESIGN_ORG <> INDEXED)
    OR
    ((DESIGN_ORG = INDEXED) AND (ACTIVE_KEY = 0))
    OR
    (NOT PROLOGUE_VERSION_VALID)
    ) THEN

    BEGIN

	{ +
	Keep at it until the user gets it right.
	- }
	REPEAT

	    THE_QUESTION;

	UNTIL NOT SYS$INPUT_ERROR;

	PROLOGUE_VERSION_VALID	:= TRUE;

    END;

    IF PROLOGUE_VERSION < 3 THEN

    BEGIN

	DATA_RECORD_COMP	:= 0.0;
	DATA_KEY_COMP		:= 0.0;
	INDEX_RECORD_COMP	:= 0.0;

    END;

END;	{ ASK_PROLOGUE_VERSION }

{ ++

ASK_REC_SIZE -- Query the user.

This routine asks about the user's record size.

CALLING SEQUENCE:

ASK_REC_SIZE;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

MEAN_RECORD_SIZE
SYS$INPUT_ERROR

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_REC_SIZE;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'This refers to the records in the data file.'
	    );

	{ +
	Pop the question.
	- }
	WRITE (SHIFT);

	IF VARIABLE_RECORDS THEN

	    WRITE ('Mean ');

	WRITE ('Record Size');

	IF RECORD_FORMAT = VFC THEN

	    WRITE (' w/fix');

	IF NOT VARIABLE_RECORDS THEN

	    WRITE (TAB);

	WRITE (TAB,TAB,'(1-',CUR_MAX_REC:NUM_LEN(CUR_MAX_REC),')',
	ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');

	NUMBER_INPUT (MEAN_RECORD_SIZE,FALSE,0);

	CHECK_WITHIN_LIMITS (1,MEAN_RECORD_SIZE,CUR_MAX_REC);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    This question shouldn't be asked for alternate keys. Unless redesigning,
    and we don't already have a value for it.
    - }
    IF (
    (DESIGN_ORG <> INDEXED)
    OR
    ((DESIGN_ORG = INDEXED) AND (ACTIVE_KEY = 0))
    OR
    (NOT MEAN_RECORD_SIZE_VALID)
    ) THEN

    BEGIN

	{ +
	Setup the max allowable record size.
	- }
	CASE DESIGN_ORG OF

	    SEQUENTIAL :	CUR_MAX_REC	:= BIGGEST_SEQ_FIXED;
	    INDEXED :		CUR_MAX_REC	:= BIGGEST_P3_RECORD;
	    RELATIVE :		IF VARIABLE_RECORDS THEN

				    CUR_MAX_REC	:= BIGGEST_REL_VAR

				ELSE

				    CUR_MAX_REC	:= BIGGEST_REL_FIXED;

	OTHERWISE

	    { +
	    BUGCHECK!!
	    - }
	    LIB$SIGNAL (EDF$_INTSWERR,1,15,0);

	END;	{ CASE }

	IF (
	(DESIGN_ORG = SEQUENTIAL)
	AND
	(BLOCK_SPAN_ALLOWED = FALSE)
	) THEN

	    IF VARIABLE_RECORDS THEN

		CUR_MAX_REC	:= 510

	    ELSE

		CUR_MAX_REC	:= 512;

	{ +
	Don't actually ask the question if the user is optimizing.
	- }
	IF (
	(VISIBLE_QUESTION)
	OR
	(NOT OPTIMIZING)
	) THEN

	BEGIN

	    { +
	    Keep at it until the user gets it right.
	    - }
	    REPEAT
	
		THE_QUESTION;
	
	    UNTIL NOT SYS$INPUT_ERROR;

	END

	ELSE

	BEGIN

	    IF VARIABLE_RECORDS THEN

	    BEGIN

		POINT_AT_ANALYSIS;

		IF FIND_OBJECT (
		SEC,ANALYSIS_OF_KEY,0,MEAN_DATA_LENGTH,0
		) THEN

		BEGIN

		    MEAN_RECORD_SIZE	:= DEF_CURRENT^.NUMBER;
		    POINT_AT_DEFINITION;

		END

		ELSE

		BEGIN

		    POINT_AT_DEFINITION;

		    REPEAT

			THE_QUESTION;

		    UNTIL NOT SYS$INPUT_ERROR;

		END;

	    END		{ IF TRUE VARIABLE_RECORDS }

	    ELSE

	    BEGIN

		POINT_AT_DEFINITION;

		IF FIND_OBJECT (
		SEC,RECORD$,0,SIZE,0
		) THEN

		    MEAN_RECORD_SIZE	:= DEF_CURRENT^.NUMBER

		ELSE

		BEGIN

		    REPEAT

			THE_QUESTION;

		    UNTIL NOT SYS$INPUT_ERROR;

		END;

	    END;	{ IF FALSE VARIABLE_RECORDS }

	END;
    
	{ +
	Get (or set) the other record size parameter.

	THE ASK_CONTROL_SIZE QUESTION MUST COME BEFORE THE ASK_MAX_REC_SIZE
	QUESTION!

	- }
	IF RECORD_FORMAT = VFC THEN

	    ASK_CONTROL_SIZE;

	IF VARIABLE_RECORDS THEN
    
	    ASK_MAX_REC_SIZE
    
	ELSE
    
	    MAX_RECORD_SIZE	:= MEAN_RECORD_SIZE;

	MEAN_RECORD_SIZE_VALID	:= TRUE;

    END;

END;	{ ASK_REC_SIZE }

{ ++

ASK_KEY_SIZE -- Query the user.

This routine asks about the user's key size.

CALLING SEQUENCE:

ASK_KEY_SIZE;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
KEY_SIZE

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_KEY_SIZE;

VAR
    MAX_KEY_SIZE	: INTEGER;
    MIN_KEY_SIZE	: INTEGER;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'Valid key sizes (in bytes) for key types:',CRLF,
	    SHIFT,'Bin, Int: (2, 4); Decimal: (1 - 16); String: (1 - 255)'
	    );

	{ +
	Pop the question.
	- }
	WRITE (SHIFT,'Key ',ACTIVE_KEY:ACTIVE_KEY_LENGTH,ACTIVE_KEY_FILL,
	' Length',TAB,TAB,TAB,'(',MIN_KEY_SIZE:NUM_LEN(MIN_KEY_SIZE),'-',
	MAX_KEY_SIZE:NUM_LEN(MAX_KEY_SIZE),')',
	ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');
	NUMBER_INPUT (KEY_SIZE,FALSE,0);

	CHECK_WITHIN_LIMITS (MIN_KEY_SIZE,KEY_SIZE,MAX_KEY_SIZE);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Check according to key type.
    - }
    CASE KEY_TYPE OF

	BIN2, INT2 :

	BEGIN

	    MAX_KEY_SIZE	:= 2;
	    MIN_KEY_SIZE	:= 2;

	END;

	BIN4, INT4 :

	BEGIN

	    MAX_KEY_SIZE	:= 4;
	    MIN_KEY_SIZE	:= 4;

	END;

	DECIMAL :

	BEGIN

	    MAX_KEY_SIZE	:= 16;
	    MIN_KEY_SIZE	:= 1;

	END;

	STRING :

	BEGIN

	    MAX_KEY_SIZE	:= 255;
	    MIN_KEY_SIZE	:= 1;

	END;

    OTHERWISE

	{ +
	BUGCHECK!!
	- }
	LIB$SIGNAL (EDF$_INTSWERR,1,16,0);

    END;	{ CASE }

    { +
    See how far we can go.
    - }
    IF (
    (MAX_RECORD_SIZE <> 0)
    AND
    (MAX_RECORD_SIZE < MAX_KEY_SIZE)
    ) THEN

	MAX_KEY_SIZE	:= MAX_RECORD_SIZE;

    { +
    Don't actually ask the question if the user is optimizing.
    - }
    IF (
    (VISIBLE_QUESTION)
    OR
    (NOT OPTIMIZING)
    ) THEN

    BEGIN

	{ +
	Keep at it until the user gets it right.
	- }
	REPEAT

	    THE_QUESTION;

	UNTIL NOT SYS$INPUT_ERROR;

    END

    ELSE

    BEGIN

	IF FIND_OBJECT (SEC,KEY,ACTIVE_KEY,SEG_LENGTH,0) THEN

	    KEY_SIZE	:= DEF_CURRENT^.NUMBER

	ELSE

	BEGIN

	    REPEAT

		THE_QUESTION;

	    UNTIL NOT SYS$INPUT_ERROR;

	END;

    END;

END;	{ ASK_KEY_SIZE }

{ ++

ASK_BUCKET -- Query the user.

This routine asks the user about the bucketsize he wants.

CALLING SEQUENCE:

ASK_BUCKET;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
BLOCKS_IN_BUCKET

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_BUCKET;

VAR
    BUCKET_OVERHEAD	: INTEGER;
    MIN_BUCKET		: INTEGER;
    ENTRY_SIZE		: INTEGER;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'Legal range is 1 to 32 blocks per bucket,',CRLF,
	    SHIFT,'and buckets must be large enough to hold',CRLF,
	    SHIFT,'at least 1 record plus overhead.'
	    );

	{ +
	Pop the question.
	- }
	WRITE (SHIFT,'Bucket Size Emphasis:    ( ');

	IF BUCKET_WEIGHT = EDF$C_SMALLER_BUFFERS THEN

	    WRITELN ('Smaller_buffers )')

	ELSE

	    WRITELN ('Flatter_files )');

	WRITELN (SHIFT,'Bucket Size Breakpoints: ( ',
	BREAKPOINT_LEFT:NUM_LEN(BREAKPOINT_LEFT),
	BREAKPOINT_MID:3,BREAKPOINT_RIGHT:3,' )');

	WRITE (CRLF,SHIFT,'Key ',
	ACTIVE_KEY:ACTIVE_KEY_LENGTH,ACTIVE_KEY_FILL,' Bucket Size',
	TAB,TAB,'(',MIN_BUCKET:NUM_LEN(MIN_BUCKET),
	'-32)[',BUCKET_DEFAULT:NUM_LEN(BUCKET_DEFAULT),']',TAB,': ');
	NUMBER_INPUT (BLOCKS_IN_BUCKET,TRUE,BUCKET_DEFAULT);

	{ +
	Do some range checking.
	- }
	CHECK_WITHIN_LIMITS (MIN_BUCKET,BLOCKS_IN_BUCKET,32);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Calculate the bucket overhead. THIS QUESTION IS ONLY FOR INDEXED_DESIGN.
    - }
    IF ACTIVE_KEY = 0 THEN

	BUCKET_OVERHEAD	:= P3_BUCKET_OVERHEAD_PD

    ELSE

	BUCKET_OVERHEAD	:= P3_BUCKET_OVERHEAD_SD;

    IF KEY_DUPS THEN

	BUCKET_OVERHEAD	:= BUCKET_OVERHEAD + P3_BUCKET_DUPS_LCB;

    { +
    See what the smallest allowable bucketsize is.
    - }
    IF ACTIVE_KEY = 0 THEN

	ENTRY_SIZE	:= MAX_RECORD_SIZE

    ELSE

	ENTRY_SIZE	:= KEY_SIZE;

    MIN_BUCKET		:= (ENTRY_SIZE + BUCKET_OVERHEAD) DIV 512;

    IF (
    (((ENTRY_SIZE + BUCKET_OVERHEAD) MOD 512) <> 0)
    OR
    (MIN_BUCKET = 0)
    ) THEN

	MIN_BUCKET	:= MIN_BUCKET + 1;

    { +
    Keep at it until the user gets it right.
    - }
    REPEAT

	THE_QUESTION;

    UNTIL NOT SYS$INPUT_ERROR;

END;	{ ASK_BUCKET }

{ ++

ASK_FILL - Query the user.

This routine asks the user about his fill percentage.

CALLING SEQUENCE:

ASK_FILL;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
FDL_FILL
DESIRED_FILL
LOAD_FILL

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_FILL;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'This sets the initial file loading fill factor.'
	    );

	{ +
	Pop the question.
	- }
	WRITE (SHIFT,'Key ',ACTIVE_KEY:ACTIVE_KEY_LENGTH,ACTIVE_KEY_FILL,
	' Load Fill Percent',TAB,'(50-100)[100]',TAB,': ');
	NUMBER_INPUT (DESIRED_FILL,TRUE,100);

	CHECK_WITHIN_LIMITS (0,DESIRED_FILL,100);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Only ask if there are initial records.
    - }
    IF INITIAL_COUNT > 0 THEN

    BEGIN

	{ +
	Don't actually ask the question if the user is optimizing.
	- }
	IF (
	(VISIBLE_QUESTION)
	OR
	(NOT OPTIMIZING)
	) THEN

	BEGIN

	    { +
	    Keep at it until the user gets it right.
	    - }
	    REPEAT

		THE_QUESTION;

	    UNTIL NOT SYS$INPUT_ERROR;

	END

	ELSE

	BEGIN

	    POINT_AT_ANALYSIS;

	    IF FIND_OBJECT (SEC,ANALYSIS_OF_KEY,ACTIVE_KEY,DATA_FILL$,0) THEN

		DESIRED_FILL	:= DEF_CURRENT^.NUMBER

	    ELSE

	    BEGIN

		REPEAT

		    THE_QUESTION;

		UNTIL NOT SYS$INPUT_ERROR;

	    END;

	    POINT_AT_DEFINITION;

	END;

	IF DESIRED_FILL < 50 THEN

	BEGIN

	    DESIRED_FILL	:= 50;
	    WRITELN (SHIFT,'Initial Fill of 50% assumed');

	END;

    END		{ IF INITIAL_COUNT > 0 }

    ELSE

	DESIRED_FILL		:= 100;

    FDL_FILL			:= DESIRED_FILL;

END;	{ ASK_FILL }

{ ++

ASK_FILL_RANGE -- Query user.

This routine asks the user about the range of fill factors wanted.

CALLING SEQUENCE:

ASK_FILL_RANGE;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
Y_HIGH
Y_LOW
Y_INCR

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_FILL_RANGE;

VAR
    TEMP_REAL	: REAL;
    TEMP_INT2	: INTEGER;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	SHIFT,'These questions set the range of Initial Fill Percents graphed.'
	    );

	{ +
	Pop the questions.
	- }
	WRITE (SHIFT,'Low bound: Key ',
	ACTIVE_KEY:ACTIVE_KEY_LENGTH,ACTIVE_KEY_FILL,
	' Init Fill %',TAB,'(50-100)[50]',TAB,': ');
	NUMBER_INPUT (Y_LOW,TRUE,50);

	IF Y_LOW < 50 THEN

	BEGIN

	    Y_LOW	:= 50;
	    WRITELN (SHIFT,'Initial Fill of 50% assumed for low bound');

	END;

	WRITE (SHIFT,'High bound: Key ',
	ACTIVE_KEY:ACTIVE_KEY_LENGTH,ACTIVE_KEY_FILL,
	' Init Fill %',TAB,'(50-100)[100]',TAB,': ');
	NUMBER_INPUT (Y_HIGH,TRUE,100);

	IF Y_HIGH < 50 THEN

	BEGIN

	    Y_HIGH	:= 50;
	    WRITELN (SHIFT,'Initial Fill of 50% assumed for high bound');

	END;

	CHECK_WITHIN_LIMITS (0,Y_LOW,100);
	CHECK_WITHIN_LIMITS (Y_LOW,Y_HIGH,100);

	{ +
	Make sure the bounds are at least 5 apart.
	- }
	IF (Y_HIGH - Y_LOW) < 5 THEN

	BEGIN

	    REPEAT
    
		IF Y_LOW > 50 THEN
    
		    Y_LOW	:= Y_LOW - 1;
    
		IF Y_HIGH < 100 THEN
    
		    Y_HIGH	:= Y_HIGH + 1;
    
	    UNTIL (Y_HIGH - Y_LOW) > 4;

	END;

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Keep at it until the user gets it right.
    - }
    REPEAT

	THE_QUESTION;

    UNTIL NOT SYS$INPUT_ERROR;

    { +
    Figure out what the step between lines should be.
    We always have max_array_row steps.
    - }
    TEMP_INT2		:= Y_HIGH;
    TEMP_REAL		:= (Y_HIGH - Y_LOW) / MAX_ARRAY_ROW;
    Y_INCR		:= TRUNC (TEMP_REAL);

    IF ((Y_HIGH - Y_LOW) MOD MAX_ARRAY_ROW) > 0 THEN

	Y_INCR		:= Y_INCR + 1;

    { +
    Juggle the margins and the step until we get it to fit.
    - }
    REPEAT

	Y_HIGH		:= Y_LOW + (MAX_ARRAY_ROW * Y_INCR);
    
	{ +
	Adjust down if too high.
	- }
	WHILE Y_HIGH > 100 DO
    
	BEGIN
    
	    Y_LOW		:= Y_LOW - 1;
	    Y_HIGH		:= Y_HIGH - 1;
    
	END;

	{ +
	Adjust up if too low.
	- }
	WHILE Y_LOW < 31 DO

	BEGIN

	    Y_LOW		:= Y_LOW + 1;
	    Y_HIGH		:= Y_HIGH + 1;

	END;

	{ +
	Try a smaller step if this didn't work.
	- }
	IF (Y_LOW < 31) OR (Y_HIGH > 100) THEN

	    Y_INCR		:= Y_INCR - 1;

    UNTIL (Y_LOW > 30) AND (Y_HIGH <= 100);

    { +
    Adjust the range up if we've squeezed it low.
    - }
    IF Y_HIGH < TEMP_INT2 THEN

    BEGIN

	Y_LOW			:= Y_LOW + (TEMP_INT2 - Y_HIGH);
	Y_HIGH			:= Y_HIGH + (TEMP_INT2 - Y_HIGH);

    END;

END;	{ ASK_FILL_RANGE }

{ ++

ASK_SIZE_RANGE -- Query user.

This routine asks the user about his range of record sizes.

CALLING SEQUENCE:

ASK_SIZE_RANGE;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
Y_HIGH
Y_LOW
Y_INCR

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_SIZE_RANGE;

VAR
    TEMP_REAL	: REAL;
    TEMP_INT2	: INTEGER;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'These set the range of Record Sizes graphed.'
	    );

	{ +
	Pop the questions.
	- }
	WRITE (SHIFT,'Low bound: Record Size',TAB,TAB,'(1-',
	BIGGEST_P3_RECORD:5,')[1]',TAB,': ');
	NUMBER_INPUT (Y_LOW,TRUE,1);

	WRITE (SHIFT,'High bound: Record Size',TAB,TAB,'(',
	Y_LOW:NUM_LEN(Y_LOW),'-',BIGGEST_P3_RECORD:5,')[500]');

	IF NUM_LEN(Y_LOW) < 3 THEN

	    WRITE (TAB,': ')

	ELSE

	    WRITE (' : ');

	NUMBER_INPUT (Y_HIGH,TRUE,500);

	{ +
	Do some bounds checking.
	- }
	CHECK_WITHIN_LIMITS (1,Y_LOW,BIGGEST_P3_RECORD);
	CHECK_WITHIN_LIMITS (Y_LOW,Y_HIGH,BIGGEST_P3_RECORD);

	{ +
	Make sure the bounds are at least 5 apart.
	- }
	IF (Y_HIGH - Y_LOW) < 5 THEN

	BEGIN

	    REPEAT
    
		IF Y_LOW > 1 THEN
    
		    Y_LOW	:= Y_LOW - 1;
    
		IF Y_HIGH < BIGGEST_P3_RECORD THEN
    
		    Y_HIGH	:= Y_HIGH + 1;
    
	    UNTIL (Y_HIGH - Y_LOW) > 4;

	END;

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Keep at it until the user gets it right.
    - }
    REPEAT

	THE_QUESTION;

    UNTIL NOT SYS$INPUT_ERROR;

    { +
    Setup so that asking key size works.
    - }
    MAX_RECORD_SIZE	:= Y_HIGH;

    { +
    Figure out what the step between lines should be.
    We always have max_array_row steps.
    - }
    TEMP_INT2		:= Y_HIGH;
    TEMP_REAL		:= (Y_HIGH - Y_LOW) / MAX_ARRAY_ROW;
    Y_INCR		:= TRUNC (TEMP_REAL);

    IF ((Y_HIGH - Y_LOW) MOD MAX_ARRAY_ROW) > 0 THEN

	Y_INCR		:= Y_INCR + 1;

    { +
    Juggle the margins and the step until we get it to fit.
    - }
    REPEAT

	Y_HIGH		:= Y_LOW + (MAX_ARRAY_ROW * Y_INCR);
    
	{ +
	Adjust down if too high.
	- }
	WHILE Y_HIGH > BIGGEST_P3_RECORD DO
    
	BEGIN
    
	    Y_LOW		:= Y_LOW - 1;
	    Y_HIGH		:= Y_HIGH - 1;
    
	END;

	{ +
	Adjust up if too low.
	- }
	WHILE Y_LOW < 1 DO

	BEGIN

	    Y_LOW		:= Y_LOW + 1;
	    Y_HIGH		:= Y_HIGH + 1;

	END;

	{ +
	Try a smaller step if this didn't work.
	- }
	IF (Y_LOW < 1) OR (Y_HIGH > BIGGEST_P3_RECORD) THEN

	    Y_INCR		:= Y_INCR - 1;

    UNTIL (Y_LOW > 0) AND (Y_HIGH <= BIGGEST_P3_RECORD);

    { +
    Adjust the range up if we've squeezed it low.
    - }
    IF Y_HIGH < TEMP_INT2 THEN

    BEGIN

	Y_LOW			:= Y_LOW + (TEMP_INT2 - Y_HIGH);
	Y_HIGH			:= Y_HIGH + (TEMP_INT2 - Y_HIGH);

    END;

END;	{ ASK_SIZE_RANGE }

{ ++

ASK_KEY_RANGE -- Query user.

This routine asks the user about his range of key sizes.

CALLING SEQUENCE:

ASK_KEY_RANGE;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
Y_HIGH
Y_LOW
Y_INCR

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_KEY_RANGE;

VAR
    MAX_KEY_SIZE	: INTEGER;
    TEMP_REAL		: REAL;
    TEMP_INT2		: INTEGER;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'These set the range of Key Sizes graphed.'
	    );

	{ +
	Pop the questions.
	- }
	WRITE (SHIFT,'Low bound: Key ',
	ACTIVE_KEY:ACTIVE_KEY_LENGTH,ACTIVE_KEY_FILL,
	' Length',TAB,'(1-',
	MAX_KEY_SIZE:NUM_LEN(MAX_KEY_SIZE),')[1]',TAB,': ');
	NUMBER_INPUT (Y_LOW,TRUE,1);

	WRITE (SHIFT,'High bound: Key ',
	ACTIVE_KEY:ACTIVE_KEY_LENGTH,ACTIVE_KEY_FILL,
	' Length',TAB,'(',Y_LOW:NUM_LEN(Y_LOW),'-',
	MAX_KEY_SIZE:NUM_LEN(MAX_KEY_SIZE),')[',
	MAX_KEY_SIZE:NUM_LEN(MAX_KEY_SIZE),']',TAB,': ');
	NUMBER_INPUT (Y_HIGH,TRUE,MAX_KEY_SIZE);

	{ +
	Do some bounds checking.
	- }
	CHECK_WITHIN_LIMITS (Y_LOW,Y_HIGH,MAX_KEY_SIZE);

	{ +
	Make sure the bounds are at least 5 apart.
	- }
	IF (Y_HIGH - Y_LOW) < 5 THEN

	BEGIN

	    REPEAT
    
		IF Y_LOW > 1 THEN
    
		    Y_LOW	:= Y_LOW - 1;
    
		IF Y_HIGH < (MAXINT - 1) THEN
    
		    Y_HIGH	:= Y_HIGH + 1;
    
	    UNTIL (Y_HIGH - Y_LOW) > 4;

	END;

	CHECK_WITHIN_LIMITS (1,Y_LOW,255);
	CHECK_WITHIN_LIMITS (Y_LOW,Y_HIGH,255);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    See how far we can go.
    - }
    IF (
    (MAX_RECORD_SIZE = 0)
    OR
    (MAX_RECORD_SIZE > 255)
    ) THEN

	MAX_KEY_SIZE	:= 255

    ELSE

	MAX_KEY_SIZE	:= MAX_RECORD_SIZE;

    { +
    Keep at it until the user gets it right.
    - }
    REPEAT

	THE_QUESTION;

    UNTIL NOT SYS$INPUT_ERROR;

    { +
    Figure out what the step between lines should be.
    We always have max_array_row steps.
    - }
    TEMP_INT2		:= Y_HIGH;
    TEMP_REAL		:= (Y_HIGH - Y_LOW) / MAX_ARRAY_ROW;
    Y_INCR		:= TRUNC (TEMP_REAL);

    IF ((Y_HIGH - Y_LOW) MOD MAX_ARRAY_ROW) > 0 THEN

	Y_INCR		:= Y_INCR + 1;

    { +
    Juggle the margins and the step until we get it to fit.
    - }
    REPEAT

	Y_HIGH		:= Y_LOW + (MAX_ARRAY_ROW * Y_INCR);
    
	{ +
	Adjust down if too high.
	- }
	WHILE Y_HIGH > MAX_KEY_SIZE DO
    
	BEGIN
    
	    Y_LOW		:= Y_LOW - 1;
	    Y_HIGH		:= Y_HIGH - 1;
    
	END;

	{ +
	Adjust up if too low.
	- }
	WHILE Y_LOW < 1 DO

	BEGIN

	    Y_LOW		:= Y_LOW + 1;
	    Y_HIGH		:= Y_HIGH + 1;

	END;

	{ +
	Try a smaller step if this didn't work.
	- }
	IF (Y_LOW < 1) OR (Y_HIGH > MAX_KEY_SIZE) THEN

	    Y_INCR		:= Y_INCR - 1;

    UNTIL (Y_LOW > 0) AND (Y_HIGH <= MAX_KEY_SIZE);

    { +
    Adjust the range up if we've squeezed it low.
    - }
    IF Y_HIGH < TEMP_INT2 THEN

    BEGIN

	Y_LOW			:= Y_LOW + (TEMP_INT2 - Y_HIGH);
	Y_HIGH			:= Y_HIGH + (TEMP_INT2 - Y_HIGH);

    END;

END;	{ ASK_KEY_RANGE }

{ ++

ASK_ADDED_COUNT_RANGE -- Query user.

This routine asks the user about his range of additional record counts.

CALLING SEQUENCE:

ASK_ADDED_COUNT_RANGE;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
Y_HIGH
Y_LOW
Y_INCR

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_ADDED_COUNT_RANGE;

VAR
    TEMP_REAL	: REAL;
    TEMP_INT2	: INTEGER;

    PROCEDURE THE_QUESTION;
    
    VAR
	DEF	: INTEGER;

    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'These refer to records added after the initial file load.'
	    );

	{ +
	Pop the questions.
	- }
	WRITE (SHIFT,'Low bound: Number of Added Recs',TAB,
	'(0-1Giga)[0]',TAB,': ');
	NUMBER_INPUT (Y_LOW,TRUE,0);

	ADDED_COUNT	:= Y_HIGH;

	CHECK_WITHIN_LIMITS (0,Y_LOW,EDF$C_1GIGA);

	DEF		:= 50 * Y_LOW;

	IF DEF = 0 THEN

	    DEF		:= 100000;

	WRITE (SHIFT,'High bound: Number of Added Recs',
	'(',Y_LOW:NUM_LEN(Y_LOW),'-1Giga)[',DEF:NUM_LEN(DEF),']');

	IF (NUM_LEN(Y_LOW)+NUM_LEN(DEF)) <= 3 THEN

	    WRITE (TAB,': ')

	ELSE

	    WRITE (' : ');

	NUMBER_INPUT (Y_HIGH,TRUE,DEF);

	CHECK_WITHIN_LIMITS (0,Y_HIGH,EDF$C_1GIGA);

	{ +
	Do some more bounds checking on the inputted values.
	- }
	CHECK_WITHIN_LIMITS (Y_LOW,Y_HIGH,EDF$C_1GIGA);

	{ +
	Make sure the bounds are at least 5 apart.
	- }
	IF (Y_HIGH - Y_LOW) < 5 THEN

	BEGIN

	    REPEAT
    
		IF Y_LOW > 1 THEN
    
		    Y_LOW	:= Y_LOW - 1;
    
		IF Y_HIGH < (MAXINT - 1) THEN
    
		    Y_HIGH	:= Y_HIGH + 1;
    
	    UNTIL (Y_HIGH - Y_LOW) > 4;

	END;

	CHECK_WITHIN_LIMITS (0,Y_LOW,EDF$C_1GIGA);
	CHECK_WITHIN_LIMITS (0,Y_HIGH,EDF$C_1GIGA);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Keep at it until the user gets it right.
    - }
    REPEAT

	THE_QUESTION;

    UNTIL NOT SYS$INPUT_ERROR;

    { +
    Figure out what the step between lines should be.
    We always have max_array_row steps.
    - }
    TEMP_INT2		:= Y_HIGH;
    TEMP_REAL		:= (Y_HIGH - Y_LOW) / MAX_ARRAY_ROW;
    Y_INCR		:= TRUNC (TEMP_REAL);

    IF ((Y_HIGH - Y_LOW) MOD MAX_ARRAY_ROW) > 0 THEN

	Y_INCR		:= Y_INCR + 1;

    { +
    Juggle the margins and the step until we get it to fit.
    - }
    REPEAT

	Y_HIGH		:= Y_LOW + (MAX_ARRAY_ROW * Y_INCR);
    
	{ +
	Adjust down if too high.
	- }
	WHILE Y_HIGH > EDF$C_1GIGA DO
    
	BEGIN
    
	    Y_LOW		:= Y_LOW - 1;
	    Y_HIGH		:= Y_HIGH - 1;
    
	END;

	{ +
	Adjust up if too low.
	- }
	WHILE Y_LOW < 0 DO

	BEGIN

	    Y_LOW		:= Y_LOW + 1;
	    Y_HIGH		:= Y_HIGH + 1;

	END;

	{ +
	Try a smaller step if this didn't work.
	- }
	IF (Y_LOW < 0) OR (Y_HIGH > EDF$C_1GIGA) THEN

	    Y_INCR		:= Y_INCR - 1;

    UNTIL (Y_LOW >= 0) AND (Y_HIGH <= EDF$C_1GIGA);

    { +
    Adjust the range up if we've squeezed it low.
    - }
    IF Y_HIGH < TEMP_INT2 THEN

    BEGIN

	Y_LOW			:= Y_LOW + (TEMP_INT2 - Y_HIGH);
	Y_HIGH			:= Y_HIGH + (TEMP_INT2 - Y_HIGH);

    END;

END;	{ ASK_ADDED_COUNT_RANGE }

{ ++

ASK_INITIAL_COUNT_RANGE -- Query user.

This routine asks the user about his range of record counts.

CALLING SEQUENCE:

ASK_INITIAL_COUNT_RANGE;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
Y_HIGH
Y_LOW
Y_INCR

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_INITIAL_COUNT_RANGE;

VAR
    TEMP_REAL	: REAL;
    TEMP_INT2	: INTEGER;

    PROCEDURE THE_QUESTION;
    
    VAR
	DEF	: INTEGER;

    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'These are the records initially loaded into the file.'
	    );

	{ +
	Pop the questions.
	- }
	WRITE (SHIFT,'Low bound: Initial Load of Recs',TAB,
	'(0-1Giga)[0]',TAB,': ');
	NUMBER_INPUT (Y_LOW,TRUE,0);

	CHECK_WITHIN_LIMITS (0,Y_LOW,EDF$C_1GIGA);

	DEF		:= 50 * Y_LOW;

	IF DEF = 0 THEN

	    DEF		:= 100000;

	WRITE (SHIFT,'High bound: Initial Load of Recs(',
	Y_LOW:NUM_LEN(Y_LOW),'-1Giga)[',DEF:NUM_LEN(DEF),']');

	IF (NUM_LEN(Y_LOW)+NUM_LEN(DEF)) <= 3 THEN

	    WRITE (TAB,': ')

	ELSE

	    WRITE (' : ');

	NUMBER_INPUT (Y_HIGH,TRUE,DEF);

	{ +
	Do some more bounds checking on the inputted values.
	- }
	CHECK_WITHIN_LIMITS (Y_LOW,Y_HIGH,EDF$C_1GIGA);

	{ +
	Make sure the bounds are at least 5 apart.
	- }
	IF (Y_HIGH - Y_LOW) < 5 THEN

	BEGIN

	    REPEAT
    
		IF Y_LOW > 1 THEN
    
		    Y_LOW	:= Y_LOW - 1;
    
		IF Y_HIGH < (MAXINT - 1) THEN
    
		    Y_HIGH	:= Y_HIGH + 1;
    
	    UNTIL (Y_HIGH - Y_LOW) > 4;

	END;

	CHECK_WITHIN_LIMITS (0,Y_LOW,EDF$C_1GIGA);
	CHECK_WITHIN_LIMITS (Y_LOW,Y_HIGH,EDF$C_1GIGA);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Keep at it until the user gets it right.
    - }
    REPEAT

	THE_QUESTION;

    UNTIL NOT SYS$INPUT_ERROR;

    { +
    Figure out what the step between lines should be.
    We always have max_array_row steps.
    - }
    TEMP_INT2		:= Y_HIGH;
    TEMP_REAL		:= (Y_HIGH - Y_LOW) / MAX_ARRAY_ROW;
    Y_INCR		:= TRUNC (TEMP_REAL);

    IF ((Y_HIGH - Y_LOW) MOD MAX_ARRAY_ROW) > 0 THEN

	Y_INCR		:= Y_INCR + 1;

    { +
    Juggle the margins and the step until we get it to fit.
    - }
    REPEAT

	Y_HIGH		:= Y_LOW + (MAX_ARRAY_ROW * Y_INCR);
    
	{ +
	Adjust down if too high.
	- }
	WHILE Y_HIGH > EDF$C_1GIGA DO
    
	BEGIN
    
	    Y_LOW		:= Y_LOW - 1;
	    Y_HIGH		:= Y_HIGH - 1;
    
	END;

	{ +
	Adjust up if too low.
	- }
	WHILE Y_LOW < 0 DO

	BEGIN

	    Y_LOW		:= Y_LOW + 1;
	    Y_HIGH		:= Y_HIGH + 1;

	END;

	{ +
	Try a smaller step if this didn't work.
	- }
	IF (Y_LOW < 0) OR (Y_HIGH > EDF$C_1GIGA) THEN

	    Y_INCR		:= Y_INCR - 1;

    UNTIL (Y_LOW >= 0) AND (Y_HIGH <= EDF$C_1GIGA);

    { +
    Adjust the range up if we've squeezed it low.
    - }
    IF Y_HIGH < TEMP_INT2 THEN

    BEGIN

	Y_LOW			:= Y_LOW + (TEMP_INT2 - Y_HIGH);
	Y_HIGH			:= Y_HIGH + (TEMP_INT2 - Y_HIGH);

    END;

END;	{ ASK_INITIAL_COUNT_RANGE }

{ ++

ASK_ASCENDING_ADDED -- Query user.

This routine asks the user about the order of records to be added to the file.

CALLING SEQUENCE:

ASK_ASCENDING_ADDED;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
ASCENDING_ADDED

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_ASCENDING_ADDED;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'This refers to the orderring of additional records.'
	    );

	{ +
	Pop the question.
	- }
	WRITE (SHIFT,'Will Additional Records Typically be Added in',CRLF,
	SHIFT,'Order by Ascending Primary Key ',TAB,'(Yes/No)[No]',TAB,': ');
	PARSE_INPUT (
	EDF$AB_YES_NO_TABLE_KEY,EDF$AB_YES_NO_TABLE_STA,TRUE,EDF$C_NO
	);

	ASCENDING_ADDED	:= (INPUT_VALUE = EDF$C_YES);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    This question shouldn't be asked for alternate keys, unless it hasn't been
    asked yet.
    - }
    IF (
    (ADDED_COUNT > 0)
    AND
    ((ACTIVE_KEY = 0) OR (NOT ASCENDING_ADDED_VALID))
    ) THEN

    BEGIN

	{ +
	Keep at it until the user gets it right.
	- }
	REPEAT
    
	    THE_QUESTION;
    
	UNTIL NOT SYS$INPUT_ERROR;

	ASCENDING_ADDED_VALID	:= TRUE;

    END;

END;	{ ASK_ASCENDING_ADDED }

{ ++

ASK_SUCCESSIVE_CLOSE -- Query the user.

This routine asks the user about the closeness of accesses to the file.

CALLING SEQUENCE:

ASK_SUCCESSIVE_CLOSE;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
SUCCESSIVE_CLOSE

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_SUCCESSIVE_CLOSE;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'Answer Yes, if accesses will be clustered, or slowly',CRLF,
	    SHIFT,'increasing or decreasing; No, if they will be very random.'
	    );

	{ +
	Pop the question.
	- }
	WRITE (SHIFT,'Typically, would two successive accesses be',CRLF,
	SHIFT,'to the same part of the file ',TAB,'(Yes/No)',
	ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');
	PARSE_INPUT (
	EDF$AB_YES_NO_TABLE_KEY,EDF$AB_YES_NO_TABLE_STA,FALSE,0
	);

	SUCCESSIVE_CLOSE	:= (INPUT_VALUE = EDF$C_YES);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Keep at it until the user gets it right.
    - }
    REPEAT

	THE_QUESTION;

    UNTIL NOT SYS$INPUT_ERROR;

END;	{ ASK_SUCCESSIVE_CLOSE }

{ ++

ASK_BLOCK_SPAN -- Query the user.

This routine asks the user about whether his records will span blocks.

CALLING SEQUENCE:

ASK_BLOCK_SPAN;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
BLOCK_SPAN_ALLOWED

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_BLOCK_SPAN;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'If no, each record plus overhead must fit in a disk block.',
	    CRLF,SHIFT,'Also, some space may be wasted at the end of blocks.'
	    );

	{ +
	Pop the question.
	- }
	WRITE (SHIFT,'Records can span disk blocks',TAB,'(Yes/No)[Yes]',
	TAB,': ');
	PARSE_INPUT (
	EDF$AB_YES_NO_TABLE_KEY,EDF$AB_YES_NO_TABLE_STA,TRUE,EDF$C_YES
	);

	BLOCK_SPAN_ALLOWED	:= (INPUT_VALUE = EDF$C_YES);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    IF DESIGN_ORG = SEQUENTIAL THEN

    BEGIN

	{ +
	Keep at it until the user gets it right.
	- }
	REPEAT

	    THE_QUESTION;

	UNTIL NOT SYS$INPUT_ERROR;

    END

    ELSE

	BLOCK_SPAN_ALLOWED	:= TRUE;

END;	{ ASK_BLOCK_SPAN }

{ ++

ASK_ADDED_COUNT -- Query user.

This routine asks the user about the number of records he'll be adding.

CALLING SEQUENCE:

ASK_ADDED_COUNT;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
ADDED_COUNT

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_ADDED_COUNT;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'This refers to records added after the initial file load.'
	    );

	{ +
	Pop the question.
	- }
	WRITELN (SHIFT,'Number of Additional Records to be Added After');

	IF NOT OPTIMIZING THEN

	    WRITE (SHIFT,'the Initial File Load')

	ELSE

	    WRITE (SHIFT,'the Reloading the File');

	WRITE (TAB,TAB,'(0-1Giga)',ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');
	NUMBER_INPUT (ADDED_COUNT,FALSE,0);

	CHECK_WITHIN_LIMITS (0,ADDED_COUNT,EDF$C_1GIGA);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    This question shouldn't be asked for alternate keys, unless it hasn't
    been asked yet.
    - }
    IF (
    (ACTIVE_KEY = 0)
    OR
    (NOT ADDED_COUNT_VALID)
    ) THEN

    BEGIN

	{ +
	Keep at it until the user gets it right.
	- }
	REPEAT
    
	    THE_QUESTION;
    
	UNTIL NOT SYS$INPUT_ERROR;

	ADDED_COUNT_VALID	:= TRUE;

    END;

END;	{ ASK_ADDED_COUNT }

{ ++

ASK_ASCENDING_LOAD -- Query user.

This routine asks the user about the orderring of his records during file load.

CALLING SEQUENCE:

ASK_ASCENDING_LOAD;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
ASCENDING_LOAD

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_ASCENDING_LOAD;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'This refers to the order of the initial records loaded.'
	    );

	{ +
	Pop the question.
	- }
	IF NOT OPTIMIZING THEN

	    WRITELN (SHIFT,'Will Initial Records Typically be Loaded in Order')

	ELSE

	    WRITELN (SHIFT,'Will the Records be Reloaded Typically in Order');

	WRITE (SHIFT,'by Ascending Primary Key ',TAB,'(Yes/No)[No]',TAB,': ');
	PARSE_INPUT (
	EDF$AB_YES_NO_TABLE_KEY,EDF$AB_YES_NO_TABLE_STA,TRUE,EDF$C_NO
	);

	ASCENDING_LOAD	:= (INPUT_VALUE = EDF$C_YES);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    This question shouldn't be asked if we're doing a conv/fast, or
    for alternate keys, unless it hasn't been asked yet.
    - }
    IF (
    (INITIAL_COUNT > 0)
    AND
    (LOAD_METHOD <> FAST_CONVERT)
    AND
    ((ACTIVE_KEY = 0) OR (NOT ASCENDING_LOAD_VALID))
    ) THEN

    BEGIN

	{ +
	Keep at it until the user gets it right.
	- }
	REPEAT
    
	    THE_QUESTION;
    
	UNTIL NOT SYS$INPUT_ERROR;

	ASCENDING_LOAD_VALID	:= TRUE;

    END;

END;	{ ASK_ASCENDING_LOAD }

{ ++

ASK_LOAD_METHOD -- Query user.

This routine asks the user about the method used to load the file.

CALLING SEQUENCE:

ASK_LOAD_METHOD;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
LOAD_METHOD

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_LOAD_METHOD;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	BEGIN

	    WRITELN (
	    SHIFT,'Fast_Convert:   using the VAX-11 Convert/Fast_Load option'
	    );
	    WRITELN (
	    SHIFT,'NoFast_Convert: using the VAX-11 Convert/NoFast_Load option'
	    );
	    WRITELN (
	    SHIFT,'RMS_Puts:       writing to a file from a High Level Language'
	    );

	END;

	{ +
	Pop the question.
	- }
	WRITELN (SHIFT,'(Fast_Convert NoFast_Convert RMS_Puts)');

	IF NOT OPTIMIZING THEN

	    WRITE (SHIFT,'Initial File Load Method',TAB)

	ELSE

	    WRITE (SHIFT,'File Reloading Method',TAB,TAB);

	WRITE ('(Keyword)[Fast]',TAB,': ');
	PARSE_INPUT (
	EDF$AB_LOAD_METHOD_TABLE_KEY,EDF$AB_LOAD_METHOD_TABLE_STA,TRUE,
	EDF$C_FAST_CONVERT
	);

	CASE INPUT_VALUE OF

	    EDF$C_FAST_CONVERT :	LOAD_METHOD	:= FAST_CONVERT;
	    EDF$C_NOFAST_CONVERT :	LOAD_METHOD	:= NOFAST_CONVERT;
	    EDF$C_RMS_PUTS :		LOAD_METHOD	:= RMS_PUTS;

	OTHERWISE

	    { +
	    BUGCHECK!!
	    - }
	    LIB$SIGNAL (EDF$_INTSWERR,1,17,0);

	END;	{ CASE }

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    IF INITIAL_COUNT > 0 THEN

    BEGIN

	IF (
	(ACTIVE_KEY = 0)
	OR
	(NOT LOAD_METHOD_VALID)
	) THEN

	BEGIN

	    { +
	    Keep at it until the user gets it right.
	    - }
	    REPEAT

		THE_QUESTION;

	    UNTIL NOT SYS$INPUT_ERROR;

	END;

    END

    ELSE

	{ +
	If we have no initial load, default it to rms puts
	- }
	LOAD_METHOD	:= RMS_PUTS;

    LOAD_METHOD_VALID	:= TRUE;

END;	{ ASK_LOAD_METHOD }

{ ++

ASK_INITIAL_COUNT -- Query user.

This routine asks the user about the initial number of records in his file.

CALLING SEQUENCE:

ASK_INITIAL_COUNT;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
INITIAL_COUNT

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_INITIAL_COUNT;

VAR
    OLD_COUNT	: INTEGER;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'If the file will have no "Load" operation, specify zero.'
	    );

	{ +
	Pop the question.
	- }
	IF NOT OPTIMIZING THEN

	    WRITELN (SHIFT,'Number of Records that will be Initially Loaded')

	ELSE

	    WRITELN (SHIFT,'Number of Records that will be Reloaded');

	WRITE (SHIFT,'into the File',TAB,TAB,TAB,'(0-1Giga)');

	IF NOT OPTIMIZING THEN

	BEGIN

	    WRITE (ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');
	    NUMBER_INPUT (INITIAL_COUNT,FALSE,0);

	END

	ELSE

	BEGIN

	    WRITE ('[',OLD_COUNT:NUM_LEN(OLD_COUNT),']');

	    IF NUM_LEN(OLD_COUNT) > 4 THEN

		WRITE (' : ')

	    ELSE

		WRITE (TAB,': ');

	    NUMBER_INPUT (INITIAL_COUNT,TRUE,OLD_COUNT);

	END;

	CHECK_WITHIN_LIMITS (0,INITIAL_COUNT,EDF$C_1GIGA);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    This question shouldn't be asked for alternate keys, unless it hasn't
    been asked yet.
    - }
    IF (
    (ACTIVE_KEY = 0)
    OR
    (NOT INITIAL_COUNT_VALID)
    ) THEN

    BEGIN

	IF OPTIMIZING THEN

	BEGIN

	    POINT_AT_ANALYSIS;

	    IF FIND_OBJECT (SEC,ANALYSIS_OF_KEY,0,DATA_RECORD_COUNT,0) THEN

		OLD_COUNT	:= DEF_CURRENT^.NUMBER

	    ELSE

		OLD_COUNT	:= 0;

	    POINT_AT_DEFINITION;

	END;

	{ +
	Keep at it until the user gets it right.
	- }
	REPEAT
    
	    THE_QUESTION;
    
	UNTIL NOT SYS$INPUT_ERROR;

	INITIAL_COUNT_VALID	:= TRUE;

    END;

END;	{ ASK_INITIAL_COUNT }

{ ++

ASK_NUMBER_RECORDS -- Query the user.

This routine asks the user about the number of records in his file.

CALLING SEQUENCE:

ASK_NUMBER_RECORDS;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
INITIAL_COUNT

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_NUMBER_RECORDS;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'This will determine the allocation of the file.'
	    );

	{ +
	Pop the question.
	- }
	WRITE (SHIFT,'File Capacity in Records',TAB,'(0-1Giga)',
	ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');
	NUMBER_INPUT (INITIAL_COUNT,FALSE,0);

	CHECK_WITHIN_LIMITS (0,INITIAL_COUNT,EDF$C_1GIGA);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Keep at it until the user gets it right.
    - }
    REPEAT

	THE_QUESTION;

    UNTIL NOT SYS$INPUT_ERROR;

END;	{ ASK_NUMBER_RECORDS }

{ ++

ASK_GLOBAL_COUNT -- See how many global buffers the user wants for his file.

This routine asks the user about the number of global buffers wanted.

CALLING SEQUENCE:

ASK_GLOBAL_COUNT;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
GLOBAL_COUNT

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_GLOBAL_COUNT;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'The number of global buffers will be twice the number',
	    CRLF,SHIFT,'of processes sharing the file.'
	    );

	{ +
	Pop the question.
	- }
	WRITE (SHIFT,'Typical number of processes that will open the',CRLF,
	SHIFT,'file for sharing',TAB,TAB,'(0-65535)',
	ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');
	NUMBER_INPUT (GLOBAL_COUNT,FALSE,0);

	{ +
	Do some bounds checking.
	- }
	CHECK_WITHIN_LIMITS (0,GLOBAL_COUNT,65535);

	{ +
	Just 1 process doesn't need global buffers.
	- }
	IF GLOBAL_COUNT = 1 THEN

	    GLOBAL_COUNT	:= 0

	{ +
	Allocate 2 global buffers for each process.
	- }
	ELSE

	BEGIN

	    GLOBAL_COUNT	:= 2 * GLOBAL_COUNT;

	    { +
	    Up to an RMS maximum.
	    - }
	    IF GLOBAL_COUNT > EDF$C_MAX_GBL_BUFS THEN

		GLOBAL_COUNT	:= EDF$C_MAX_GBL_BUFS;

	END;

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Don't actually ask the question if the user is optimizing.
    - }
    IF NOT OPTIMIZING THEN

    BEGIN

	{ +
	Keep at it until the user gets it right.
	- }
	REPEAT

	    THE_QUESTION;

	UNTIL NOT SYS$INPUT_ERROR;

    END

    ELSE

    BEGIN

	IF FIND_OBJECT (SEC,FILE$,0,GLOBAL_BUFFER_COUNT,0) THEN

	BEGIN

	    GLOBAL_COUNT	:= DEF_CURRENT^.NUMBER;

	    { +
	    Up to an RMS maximum.
	    - }
	    IF GLOBAL_COUNT > EDF$C_MAX_GBL_BUFS THEN

		GLOBAL_COUNT	:= EDF$C_MAX_GBL_BUFS;

	END

	ELSE

	BEGIN

	    REPEAT

		THE_QUESTION;

	    UNTIL NOT SYS$INPUT_ERROR;

	END;

    END;

END;	{ ASK_GLOBAL_COUNT }

{ ++

ASK_GLOBAL_WANTED -- Query the user.

This routine asks the user if he wants duplicates on his key.

CALLING SEQUENCE:

ASK_GLOBAL_WANTED;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
GLOBAL_WANTED
SYS$OUTPUT:

ROUTINES CALLED:

none

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_GLOBAL_WANTED;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'These usually increase the speed of file sharing, at the',
	    CRLF,
	    SHIFT,'expense of using more physical memory.'
	    );

	{ +
	Pop the question.
	- }
	WRITE (SHIFT,'Global Buffers desired',TAB,TAB,'(Yes/No)[No]',TAB,': ');
	PARSE_INPUT (
	EDF$AB_YES_NO_TABLE_KEY,EDF$AB_YES_NO_TABLE_STA,TRUE,EDF$C_NO
	);

	GLOBAL_WANTED		:= (INPUT_VALUE = EDF$C_YES);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Only ask if we're doing indexed files.
    - }
    IF DESIGN_ORG = INDEXED THEN

    BEGIN

	{ +
	Don't actually ask the question if the user is optimizing.
	- }
	IF NOT OPTIMIZING THEN

	BEGIN

	    { +
	    Keep at it until the user gets it right.
	    - }
	    REPEAT

		THE_QUESTION;

	    UNTIL NOT SYS$INPUT_ERROR;

	END

	ELSE

	BEGIN

	    GLOBAL_WANTED	:=
	    	FIND_OBJECT (SEC,FILE$,0,GLOBAL_BUFFER_COUNT,0);

	END;

    END	{ IF DESIGN_ORG = INDEXED }

    ELSE

	GLOBAL_WANTED	:= FALSE;

    { +
    If we want that sort of sharing, see how many.
    - }
    IF GLOBAL_WANTED THEN

	ASK_GLOBAL_COUNT

    ELSE

	GLOBAL_COUNT	:= 0;

END;	{ ASK_GLOBAL_WANTED }

{ ++

ASK_NUMBER_KEY_DUPS -- Query the user.

This routine asks the user about the number of dups per value his keys have.

CALLING SEQUENCE:

ASK_NUMBER_KEY_DUPS;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
NUMBER_DUPS

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_NUMBER_DUPS;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'This is a mean value for the file.'
	    );

	{ +
	Pop the question.
	- }
	WRITE (SHIFT,'Typical Dups per Key ',
	ACTIVE_KEY:ACTIVE_KEY_LENGTH,ACTIVE_KEY_FILL,
	' Value',TAB,'(0-1Giga)[0]',TAB,': ');
	NUMBER_INPUT (NUMBER_DUPS,TRUE,0);

	CHECK_WITHIN_LIMITS (0,NUMBER_DUPS,EDF$C_1GIGA);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Don't actually ask the question if the user is optimizing.
    - }
    IF (
    (VISIBLE_QUESTION)
    OR
    (NOT OPTIMIZING)
    ) THEN

    BEGIN

	{ +
	Keep at it until the user gets it right.
	- }
	REPEAT

	    THE_QUESTION;

	UNTIL NOT SYS$INPUT_ERROR;

    END

    ELSE

    BEGIN

	POINT_AT_ANALYSIS;

	IF FIND_OBJECT (SEC,ANALYSIS_OF_KEY,ACTIVE_KEY,DUPLICATES_PER_SIDR,0)
	THEN

	    NUMBER_DUPS	:= DEF_CURRENT^.NUMBER

	ELSE

	BEGIN

	    REPEAT

		THE_QUESTION;

	    UNTIL NOT SYS$INPUT_ERROR;

	END;

	POINT_AT_DEFINITION;

    END;

END;	{ ASK_NUMBER_KEY_DUPS }

{ ++

ASK_KEY_DUPS -- Query the user.

This routine asks the user if he wants duplicates on his key.

CALLING SEQUENCE:

ASK_KEY_DUPS;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
KEY_DUPS
SYS$OUTPUT:

ROUTINES CALLED:

none

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_KEY_DUPS;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'This enables or disables the RMS option.'
	    );

	{ +
	Pop the question.
	- }
	WRITE (SHIFT,'Key ',ACTIVE_KEY:ACTIVE_KEY_LENGTH,ACTIVE_KEY_FILL,
	' Duplicates Allowed ',TAB);

	{ +
	The default for the primary key is NO, for alternates YES.
	- }
	IF ACTIVE_KEY = 0 THEN

	BEGIN

	    WRITE ('(Yes/No)[No]',TAB,': ');
	    PARSE_INPUT (
	    EDF$AB_YES_NO_TABLE_KEY,EDF$AB_YES_NO_TABLE_STA,TRUE,EDF$C_NO
	    );

	END

	ELSE

	BEGIN

	    WRITE ('(Yes/No)[Yes]',TAB,': ');
	    PARSE_INPUT (
	    EDF$AB_YES_NO_TABLE_KEY,EDF$AB_YES_NO_TABLE_STA,TRUE,EDF$C_YES
	    );

	END;

	KEY_DUPS	:= (INPUT_VALUE = EDF$C_YES);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Don't actually ask the question if the user is optimizing.
    - }
    IF (
    (VISIBLE_QUESTION)
    OR
    (NOT OPTIMIZING)
    ) THEN

    BEGIN

	{ +
	Keep at it until the user gets it right.
	- }
	REPEAT

	    THE_QUESTION;

	UNTIL NOT SYS$INPUT_ERROR;

    END

    ELSE

    BEGIN

	IF FIND_OBJECT (SEC,KEY,ACTIVE_KEY,DUPLICATES,0) THEN

	    KEY_DUPS	:= DEF_CURRENT^.SWITCH

	ELSE

	BEGIN

	    REPEAT

		THE_QUESTION;

	    UNTIL NOT SYS$INPUT_ERROR;

	END;

    END;

    IF KEY_DUPS THEN

	ASK_NUMBER_DUPS

    ELSE

	NUMBER_DUPS	:= 0;

END;	{ ASK_KEY_DUPS }

{ ++

ASK_KEY_CHANGES -- Query the user.

This routine asks the user if he wants to allow key changes.

CALLING SEQUENCE:

ASK_KEY_CHANGES;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
KEY_CHANGES
SYS$OUTPUT:

ROUTINES CALLED:

none

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_KEY_CHANGES;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'This enables or disables the RMS option.'
	    );

	{ +
	Pop the question.
	- }
	WRITE (SHIFT,'Key ',ACTIVE_KEY:ACTIVE_KEY_LENGTH,ACTIVE_KEY_FILL,
	' Changes Allowed ',TAB,'(Yes/No)[Yes]',TAB,': ');
	PARSE_INPUT (
	EDF$AB_YES_NO_TABLE_KEY,EDF$AB_YES_NO_TABLE_STA,TRUE,EDF$C_YES
	);
    
	KEY_CHANGES	:= (INPUT_VALUE = EDF$C_YES);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Key changes are never allowed on the primary key.
    - }
    IF ACTIVE_KEY <> 0 THEN

    BEGIN

	{ +
	Don't actually ask the question if the user is optimizing.
	- }
	IF NOT OPTIMIZING THEN

	BEGIN

	    { +
	    Keep at it until the user gets it right.
	    - }
	    REPEAT

		THE_QUESTION;

	    UNTIL NOT SYS$INPUT_ERROR;

	END

	ELSE

	BEGIN

	    IF FIND_OBJECT (SEC,KEY,ACTIVE_KEY,CHANGES,0) THEN

		KEY_CHANGES	:= DEF_CURRENT^.SWITCH

	    ELSE

	    BEGIN

		REPEAT

		    THE_QUESTION;

		UNTIL NOT SYS$INPUT_ERROR;

	    END

	END

    END

    ELSE

	KEY_CHANGES	:= FALSE;

END;	{ ASK_KEY_CHANGES }

{ ++

ASK_KEY_DIST -- See what the user's key dist is.

This routine asks the user if his key dist is even or not.

CALLING SEQUENCE:

ASK_KEY_DIST;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
EVEN_KEY_DIST
SYS$OUTPUT:

ROUTINES CALLED:

none

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_KEY_DIST;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'This refers to records that are added to the',CRLF,
	    SHIFT,'file after it is initially loaded.'
	    );

	{ +
	Pop the question.
	- }
	WRITELN (SHIFT,'Will Added Records be Distributed Evenly over the');

	IF NOT OPTIMIZING THEN

	    WRITE (SHIFT,'Initial')

	ELSE

	    WRITE (SHIFT,'Reloaded');

	WRITE (' Range of Pri Key Values');

	IF NOT OPTIMIZING THEN

	    WRITE (TAB);

	WRITE ('(Yes/No)[No]',TAB,': ');
	PARSE_INPUT (
	EDF$AB_YES_NO_TABLE_KEY,EDF$AB_YES_NO_TABLE_STA,TRUE,EDF$C_NO
	);
    
	EVEN_KEY_DIST		:= (INPUT_VALUE = EDF$C_YES);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    This question shouldn't be asked for alternate keys, unless it hasn't been
    asked yet.
    - }
    IF (
    (ADDED_COUNT > 0)
    AND
    ((ACTIVE_KEY = 0) OR (NOT EVEN_KEY_DIST_VALID))
    ) THEN

    BEGIN

	{ +
	Moot question if no records will be added.
	- }
	IF ADDED_COUNT = 0 THEN

	    EVEN_KEY_DIST	:= TRUE

	ELSE

	BEGIN
    
	    { +
	    Keep at it until the user gets it right.
	    - }
	    REPEAT
	
		THE_QUESTION;
	
	    UNTIL NOT SYS$INPUT_ERROR;

	END;	{ IF FALSE ADDED_COUNT = 0 }

    EVEN_KEY_DIST_VALID	:= TRUE;

    END;	{ IF TRUE ACTIVE_KEY = 0 }

END;	{ ASK_KEY_DIST }

{ ++

ASK_KEY_POSITION -- Query the user.

This routine asks the user about his key position.

CALLING SEQUENCE:

ASK_KEY_POSITION;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
KEY_POSITION
SYS$OUTPUT:

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_KEY_POSITION;

VAR
    MAX_KEY_POSITION	: INTEGER;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'This is the starting byte of the key.'
	    );

	{ +
	Pop the question.
	- }
	WRITE (SHIFT,'Key ',ACTIVE_KEY:ACTIVE_KEY_LENGTH,ACTIVE_KEY_FILL,
	' Position',TAB,TAB,'(0-',
	MAX_KEY_POSITION:NUM_LEN(MAX_KEY_POSITION),
	')[0]',TAB,': ');
	NUMBER_INPUT (KEY_POSITION,TRUE,0);

	CHECK_WITHIN_LIMITS (0,KEY_POSITION,MAX_KEY_POSITION);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    See how far we can go.
    - }
    IF MAX_RECORD_SIZE = 0 THEN

	MAX_KEY_POSITION	:= BIGGEST_P3_RECORD - KEY_SIZE

    ELSE

	MAX_KEY_POSITION	:= MAX_RECORD_SIZE - KEY_SIZE;

    { +
    Don't actually ask the question if the user is optimizing.
    - }
    IF (
    (VISIBLE_QUESTION)
    OR
    (NOT OPTIMIZING)
    ) THEN

    BEGIN

	{ +
	Keep at it until the user gets it right.
	- }
	REPEAT

	    THE_QUESTION;

	UNTIL NOT SYS$INPUT_ERROR;

    END

    ELSE

    BEGIN

	IF FIND_OBJECT (SEC,KEY,ACTIVE_KEY,SEG_POSITION,0) THEN

	    KEY_POSITION	:= DEF_CURRENT^.NUMBER

	ELSE

	BEGIN

	    REPEAT

		THE_QUESTION;

	    UNTIL NOT SYS$INPUT_ERROR;

	END;

    END;

END;	{ ASK_KEY_POSITION }

{ ++

ASK_DATA_KEY_COMP -- Query the user.

This routine asks the user for his estimated compression of keys at level 0.

CALLING SEQUENCE:

ASK_DATA_KEY_COMP;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR
SYS$INPUT:

OUTPUT PARAMETERS:
none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
DATA_KEY_COMP
SYS$OUTPUT:

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_DATA_KEY_COMP;

VAR
    TEMP_REAL	: REAL;
    TEMP_COMP	: INTEGER;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'This is the compression of the key at the data level.');

	{ +
	Pop the question.
	- }
	WRITE (SHIFT,'Percent Data Key Compression',TAB,'(Abs<100)[0]',TAB,': ');
	NUMBER_INPUT (TEMP_COMP,TRUE,0);

	CHECK_WITHIN_LIMITS (-99,TEMP_COMP,99);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    This question shouldn't be asked for alternate keys.
    For VMS V3.0, this only applies to key 0.
    - }
    IF (
    (PROLOGUE_VERSION_VALID = TRUE)
    AND
    (PROLOGUE_VERSION = 3)
    AND
    ((ACTIVE_KEY = 0) OR (NOT DATA_KEY_COMP_VALID))
    ) THEN

    BEGIN

	{ +
	Don't actually ask the question if the user is optimizing.
	- }
	IF (
	(VISIBLE_QUESTION)
	OR
	(NOT OPTIMIZING)
	) THEN

	BEGIN

	    { +
	    Keep at it until the user gets it right.
	    - }
	    REPEAT

		THE_QUESTION;

	    UNTIL NOT SYS$INPUT_ERROR;

	END

	ELSE

	BEGIN

	    POINT_AT_ANALYSIS;

	    IF FIND_OBJECT
	    (SEC,ANALYSIS_OF_KEY,ACTIVE_KEY,DATA_KEY_COMPRESSION$,0)
	    THEN

		TEMP_COMP	:= DEF_CURRENT^.NUMBER

	    ELSE

	    BEGIN

		REPEAT

		    THE_QUESTION;

		UNTIL NOT SYS$INPUT_ERROR;

	    END;

	    POINT_AT_DEFINITION;

	END;

	TEMP_REAL	:= TEMP_COMP;
	DATA_KEY_COMP	:= TEMP_REAL / 100.0;

    END

    ELSE

	DATA_KEY_COMP	:= 0;

    DATA_KEY_COMP_VALID	:= TRUE;

END;	{ ASK_DATA_KEY_COMP }

{ ++

ASK_DATA_RECORD_COMP -- Query the user.

This routine asks the user about how many inserts will be done to his file.

CALLING SEQUENCE:

ASK_DATA_RECORD_COMP;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
DATA_RECORD_COMP
SYS$OUTPUT:

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_DATA_RECORD_COMP;

VAR
    TEMP_REAL	: REAL;
    TEMP_COMP	: INTEGER;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'Compression of the non-key record at the data level.');

	{ +
	Pop the question.
	- }
	WRITE (SHIFT,'Percent Data Record Compression',
	TAB,'(Abs<100)[0]',TAB,': ');
	NUMBER_INPUT (TEMP_COMP,TRUE,0);

	CHECK_WITHIN_LIMITS (-99,TEMP_COMP,99);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    This question shouldn't be asked for alternate keys.
    For VMS V3.0 this only applies to key 0.
    - }
    IF (
    (PROLOGUE_VERSION_VALID = TRUE)
    AND
    (PROLOGUE_VERSION = 3)
    AND
    ((ACTIVE_KEY = 0) OR (NOT DATA_RECORD_COMP_VALID))
    ) THEN

    BEGIN

	{ +
	Don't actually ask the question if the user is optimizing.
	- }
	IF (
	(VISIBLE_QUESTION)
	OR
	(NOT OPTIMIZING)
	) THEN

	BEGIN

	    { +
	    Keep at it until the user gets it right.
	    - }
	    REPEAT

		THE_QUESTION;

	    UNTIL NOT SYS$INPUT_ERROR;

	END

	ELSE

	BEGIN

	    POINT_AT_ANALYSIS;

	    IF FIND_OBJECT
	    (SEC,ANALYSIS_OF_KEY,ACTIVE_KEY,DATA_RECORD_COMPRESSION$,0)
	    THEN

		TEMP_COMP	:= DEF_CURRENT^.NUMBER

	    ELSE

	    BEGIN

		REPEAT

		    THE_QUESTION;

		UNTIL NOT SYS$INPUT_ERROR;

	    END;

	    POINT_AT_DEFINITION;

	END;

	TEMP_REAL		:= TEMP_COMP;
	DATA_RECORD_COMP	:= TEMP_REAL / 100.0;

    END

    ELSE

	DATA_RECORD_COMP	:= 0;

    DATA_RECORD_COMP_VALID	:= TRUE;

END;	{ ASK_DATA_RECORD_COMP }

{ ++

ASK_INDEX_RECORD_COMP -- Query the user.

This routine asks the user about how many inserts will be done to his file.

CALLING SEQUENCE:

ASK_INDEX_RECORD_COMP;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
INDEX_RECORD_COMP
SYS$OUTPUT:

ROUTINES CALLED:

LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_INDEX_RECORD_COMP;

VAR
    TEMP_REAL	: REAL;
    TEMP_COMP	: INTEGER;

    PROCEDURE THE_QUESTION;
    
    BEGIN
    
	{ +
	Set up to catch bad user input.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'Compression of key records at the index level.');

	{ +
	Pop the question.
	- }
	WRITE (SHIFT,'Percent Index Record Compression(Abs<100)[0]',TAB,': ');
	NUMBER_INPUT (TEMP_COMP,TRUE,0);

	CHECK_WITHIN_LIMITS (-99,TEMP_COMP,99);

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    For VMS Version 3.0, this question applies only to key 0.
    - }
    IF (
    (PROLOGUE_VERSION_VALID = TRUE)
    AND
    (PROLOGUE_VERSION = 3)
    AND
    ((ACTIVE_KEY = 0) OR (NOT INDEX_RECORD_COMP_VALID))
    ) THEN

    BEGIN

	{ +
	Don't actually ask the question if the user is optimizing.
	- }
	IF (
	(VISIBLE_QUESTION)
	OR
	(NOT OPTIMIZING)
	) THEN

	BEGIN

	    { +
	    Keep at it until the user gets it right.
	    - }
	    REPEAT

		THE_QUESTION;

	    UNTIL NOT SYS$INPUT_ERROR;

	END

	ELSE

	BEGIN

	    POINT_AT_ANALYSIS;

	    IF FIND_OBJECT
	    (SEC,ANALYSIS_OF_KEY,ACTIVE_KEY,INDEX_COMPRESSION$,0)
	    THEN

		TEMP_COMP	:= DEF_CURRENT^.NUMBER

	    ELSE

	    BEGIN

		REPEAT

		    THE_QUESTION;

		UNTIL NOT SYS$INPUT_ERROR;

	    END;

	    POINT_AT_DEFINITION;

	END;

	TEMP_REAL		:= TEMP_COMP;
	INDEX_RECORD_COMP	:= TEMP_REAL / 100.0;

    END

    ELSE

	INDEX_RECORD_COMP	:= 0;

    INDEX_RECORD_COMP_VALID	:= TRUE;

END;	{ ASK_INDEX_RECORD_COMP }

{ ++

ASK_FUNCTION -- Find out what the user wants to do.

This routine inputs the user's top-level function.

CALLING SEQUENCE:

ASK_FUNCTION;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR
FULL_PROMPT
TEMP_FULL_PROMPT
ANSI_REVERSE
TAB
CRLF
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
TEMP_FULL_PROMPT
CURRENT_FUNCTION
CONTROL_ZEE_TYPED
SYS$OUTPUT:

ROUTINES CALLED:

CLEAR
LIB$ESTABLISH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_FUNCTION;

    PROCEDURE THE_QUESTION;
    
    BEGIN

	{ +
	Set up the condition handler to catch typing errors.
	- }
	MAIN_LEVEL		:= TRUE;
	MAIN_CTRLZ		:= FALSE;
	SYS$INPUT_ERROR		:= FALSE;
	CONTROL_ZEE_TYPED	:= FALSE;

	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);
    
	{ +
	Now, prompt the user, pop the question, and read in the answer.
	- }
	CLEAR (SCREEN);
    
	{ +
	Only show the menu if we're being verbose.
	- }
	IF FULL_PROMPT OR TEMP_FULL_PROMPT THEN
    
	BEGIN

	    { +
	    Show the header in reverse video, and then the rest of the menu.
	    - }
	    WRITELN (
	    SHIFT,
	    TAB,TAB,
	    ANSI_REVERSE,
	    DASH,' ',EDF_HEADER,' ',DASH,
	    ANSI_RESET,
	    CRLF,
	    CRLF,
	    SHIFT,
	    'Add',TAB,	'to insert one or more lines into the FDL definition',
	    CRLF,
	    SHIFT,
	    'Delete',TAB,'to remove one or more lines from the FDL definition'
	    );

	    { +
	    This is broken into several WRITELNs because of the limit of
	    I/O buffersize in Pascal I/O (diff for Pascal Version 2?)
	    - }
	    WRITELN (
	    SHIFT,
	    'Exit',TAB,	'to leave the FDL Editor after creating the FDL file',
	    CRLF,
	    SHIFT,
	    'Help',TAB,'to obtain information about the FDL Editor',
	    CRLF,
	    SHIFT,
	    'Invoke',TAB,'to initiate a script of related questions',
	    CRLF,
	    SHIFT,
	    'Modify',TAB,'to change existing line(s) in the FDL definition'
	    );

	    WRITELN (
	    SHIFT,
	    'Quit',TAB,	'to abort the FDL Editor with no FDL file creation',
	    CRLF,
	    SHIFT,
	    'View',TAB,	'to display the current FDL Definition',
	    CRLF
	    );

	END	{ IF TRUE FULL_PROMPT OR TEMP_FULL_PROMPT }

	ELSE

	    WRITELN (
	    SHIFT,'(Add Delete Exit Help Invoke Modify Quit View)'
	    );

	{ +
	Pop the question.
	- }
	WRITE (SHIFT,'Main Editor Function',TAB,TAB,'(Keyword)[Help]',TAB,': ');
	PARSE_INPUT (
	EDF$AB_CURRENT_FUNC_TABLE_KEY,EDF$AB_CURRENT_FUNC_TABLE_STA,TRUE,
	EDF$C_HELP
	);

	CASE INPUT_VALUE OF

	    EDF$C_ADD :		CURRENT_FUNCTION	:= ADD;
	    EDF$C_DELETE :	CURRENT_FUNCTION	:= DELETE;
	    EDF$C_EXIT :	CURRENT_FUNCTION	:= EXIT;
	    EDF$C_HELP :	CURRENT_FUNCTION	:= HELP;
	    EDF$C_INVOKE :	CURRENT_FUNCTION	:= INVOKE;
	    EDF$C_MODIFY :	CURRENT_FUNCTION	:= MODIFY;
	    EDF$C_QUIT :	CURRENT_FUNCTION	:= QUIT;
	    EDF$C_VIEW :	CURRENT_FUNCTION	:= VIEW;

	OTHERWISE

	    { +
	    BUGCHECK!!
	    - }
	    LIB$SIGNAL (EDF$_INTSWERR,1,18,0);

	END;	{ CASE }

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Keep at it until the user gets it right.
    - }
    REPEAT

	THE_QUESTION;

    UNTIL NOT SYS$INPUT_ERROR;

    { +
    Reset the script pointer (only auto-invoke on 1st entry).
    - }
    SCRIPT_OPTION	:= ZERO_SCRIPT;

    { +
    Reset the ^Z flag.
    - }
    MAIN_LEVEL		:= FALSE;
    
END;	{ ASK_FUNCTION }

{ ++

ASK_DESIGN_OPTION -- Query the user on what variable he wants to vary.

This routine lets the use specify which design variable he wishes to change.

CALLING SEQUENCE:

ASK_DESIGN_OPTION;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR
SYS$INPUT:
CRLF
TAB
SHIFT

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
SYS$OUTPUT:
DESIGN_CYCLE

ROUTINES CALLED:

none

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_DESIGN_OPTION;

    PROCEDURE THE_QUESTION;

    BEGIN

	{ +
	Set up the condition handler to catch typing errors.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	IF TEMP_FULL_PROMPT THEN

	    WRITELN (
	    SHIFT,'Type the 2 letter mnemonic of the selected option.'
	    );

	{ +
	Pop the question.
	- }
	WRITE (SHIFT,'Which File Parameter',TAB,'(Mnemonic)[refresh]',TAB,': ');
	PARSE_INPUT (
	EDF$AB_DESIGN_CYCLE_TABLE_KEY,EDF$AB_DESIGN_CYCLE_TABLE_STA,TRUE,
	EDF$C_WP
	);

	DESIGN_CYCLE	:= INPUT_VALUE;

	{ +
	Make sure he hasn't typed a temporarily disabled option.
	- }
	IF DESIGN_STYLE = SURFACE_PLOT THEN

	    IF (
	    ((SURFACE_OPTION = FILL_SURFACE) AND (DESIGN_CYCLE = EDF$C_BF))
	    OR
	    ((SURFACE_OPTION = INIT_SURFACE) AND (DESIGN_CYCLE = EDF$C_IL))
	    OR
	    ((SURFACE_OPTION = ADDED_SURFACE) AND (DESIGN_CYCLE = EDF$C_AR))
	    OR
	    ((SURFACE_OPTION = SIZE_SURFACE) AND (DESIGN_CYCLE = EDF$C_RS))
	    OR
	    ((SURFACE_OPTION = KEY_SURFACE) AND (DESIGN_CYCLE = EDF$C_KL))
	    ) THEN

		LIB$SIGNAL (EDF$_BADVALUE,0,0,0);

	{ +
	Make sure that he modifies only reasonable things.
	The following options make sense only for the primary key.
	- }
	IF (
	(ACTIVE_KEY <> 0) AND (DESIGN_CYCLE IN
	[ EDF$C_RC, EDF$C_KC, EDF$C_RF, EDF$C_RS, EDF$C_IL, EDF$C_AR,
	EDF$C_PV, EDF$C_KT ])
	) THEN

	    LIB$SIGNAL (EDF$_BADVALUE,0,0,0);

	IF (
	(PROLOGUE_VERSION < 3) AND (DESIGN_CYCLE IN
	[ EDF$C_KC, EDF$C_RC, EDF$C_IC ])
	) THEN

	    LIB$SIGNAL (EDF$_BADVALUE,0,0,0);

	IF (INITIAL_COUNT < 1) AND (DESIGN_CYCLE = EDF$C_LM) THEN

	    LIB$SIGNAL (EDF$_BADVALUE,0,0,0);

	IF (INITIAL_COUNT < 1) AND (DESIGN_CYCLE = EDF$C_BF) THEN

	BEGIN

	    WRITELN (SHIFT,ANSI_REVERSE,DASH,
	    ' Fill Factor used is 100% when Initial Load is zero. ',
	    DASH,ANSI_RESET);

	    DELAY (2.0);

	END;

	{ +
	Make sure this is true for only one cycle.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Display the current value of the file parameters.
    - }
    CLEAR (LOWER_AREA);

    { +
    Special support for the VT125. Turn on graphics mode, setup text.
    - }
    IF REGIS THEN

    BEGIN

	WRITE (ESCAPE,'Pp;');

	IF DESIGN_STYLE = SURFACE_PLOT THEN

	    WRITELN ('P[27,285];T(W(I3))',APOSTROPHE,
	    ' Key:    Good   ',APOSTROPHE,';',
	    'T(W(I2))',APOSTROPHE,'Fair   ',APOSTROPHE,';',
	    'T(W(I1))',APOSTROPHE,'Poor',APOSTROPHE,';');

	{ +
	****************
	THIS MUST BE BROKEN HERE WITH THE NEW 'WRITE' SO TTDRV WON'T DO A
	SCREEN WRAP ON US - BECAUSE OF ALL THE INVISIBLE REGIS CHARACTARS
	****************
	- }

	WRITELN (
	'P[27,320];T(W(I3))',APOSTROPHE);

    END;	{ IF REGIS }

    WRITE (LOW_SHIFT,' ');

    WRITE ('PV-Prologue Version     ',PROLOGUE_VERSION:1,' ');
    WRITE ('KT-Key ',
    ACTIVE_KEY:ACTIVE_KEY_LENGTH,ACTIVE_KEY_FILL,
    ' Type   ');

    CASE KEY_TYPE OF

	BIN2 :		WRITE ('   Bin2 ');
	BIN4 :		WRITE ('   Bin4 ');
	DECIMAL :	WRITE ('Decimal ');
	INT2 :		WRITE ('   Int2 ');
	INT4 :		WRITE ('   Int4 ');
	STRING :	WRITE (' String ');

    OTHERWISE

	{ +
	BUGCHECK!!
	- }
	LIB$SIGNAL (EDF$_INTSWERR,1,19,0);

    END;	{ CASE }

    WRITE ('FD-Final Design Phase');

    WRITELN;
    WRITE (LOW_SHIFT,' ');

    WRITE ('DK-Dup Key ',
    ACTIVE_KEY:ACTIVE_KEY_LENGTH,ACTIVE_KEY_FILL,
    ' Values ');

    IF KEY_DUPS THEN

	WRITE ('Yes ')

    ELSE

	WRITE (' No ');

    IF (DESIGN_STYLE = LINE_PLOT) OR (SURFACE_OPTION <> KEY_SURFACE) THEN

	WRITE ('KL-Key ',ACTIVE_KEY:ACTIVE_KEY_LENGTH,ACTIVE_KEY_FILL,
	' Length     ',KEY_SIZE:3,' ');

    WRITE ('KP-Key ',ACTIVE_KEY:ACTIVE_KEY_LENGTH,ACTIVE_KEY_FILL,
    ' Position ',KEY_POSITION:5,' ');

    WRITELN;
    WRITE (LOW_SHIFT,' ');

    IF PROLOGUE_VERSION = 3 THEN

    BEGIN

	WRITE ('RC-Data Record Comp  ',TRUNC(DATA_RECORD_COMP*100.0):3,'% ');
	WRITE ('KC-Data Key Comp     ',TRUNC(DATA_KEY_COMP*100.0):3,'% ');
	WRITE ('IC-Index Record Comp ',TRUNC(INDEX_RECORD_COMP*100.0):3,'% ');

	WRITELN;
	WRITE (LOW_SHIFT,' ');

    END;	{ IF PROLOGUE_VERSION = 3 }

    IF (DESIGN_STYLE = LINE_PLOT) OR (SURFACE_OPTION <> FILL_SURFACE) THEN

	WRITE ('BF-Bucket Fill       ',DESIRED_FILL:3,'% ');

    WRITE ('RF-Record Format ');

    IF VARIABLE_RECORDS THEN

	WRITE ('Variable ')

    ELSE

	WRITE ('   Fixed ');

    IF (DESIGN_STYLE = LINE_PLOT) OR (SURFACE_OPTION <> SIZE_SURFACE) THEN

    BEGIN

	WRITE ('RS-');

	IF VARIABLE_RECORDS THEN
    
	    WRITE ('Mean Record Size ')

	ELSE

	    WRITE ('Record Size      ');
    
	WRITE (MEAN_RECORD_SIZE:5,' ');

    END;


    WRITELN;
    WRITE (LOW_SHIFT,' ');

    WRITE ('LM-Load Method ');

    CASE LOAD_METHOD OF

	FAST_CONVERT :		WRITE (' Fast_Conv ');
	NOFAST_CONVERT :	WRITE ('NoFast_Con ');
	RMS_PUTS :		WRITE ('  RMS_Puts ');

    OTHERWISE

	{ +
	BUGCHECK!!
	- }
	LIB$SIGNAL (EDF$_INTSWERR,1,20,0);

    END;	{ CASE }

    IF (DESIGN_STYLE = LINE_PLOT) OR (SURFACE_OPTION <> INIT_SURFACE) THEN

	WRITE ('IL-Initial Load ',INITIAL_COUNT:9,' ');

    IF (DESIGN_STYLE = LINE_PLOT) OR (SURFACE_OPTION <> ADDED_SURFACE) THEN

	WRITE ('AR-Added Records',ADDED_COUNT:9,' ');

    { +
    Done with display, now turn Graphics Mode off.
    - }
    IF REGIS THEN

	WRITELN (APOSTROPHE,';',ESCAPE,'\',CRLF,CRLF);

    WRITELN;

    { +
    Compensate for absent compression line.
    - }
    IF PROLOGUE_VERSION < 3 THEN

	WRITELN;

    { +
    Keep at it until the user gets it right.
    - }
    REPEAT

	THE_QUESTION;

    UNTIL NOT SYS$INPUT_ERROR;

END;	{ ASK_DESIGN_OPTION }

{ ++

ASK_RETURN -- Ask the user to press RETURN.

This procedure waits for the user to hit the return key.

CALLING SEQUENCE:

ASK_RETURN;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

TAB
LINE_ONE
COL_ONE
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$OUTPUT:
STATUS

ROUTINES CALLED:

LIB$ESTABLISH
LIB$ERASE_PAGE

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:


-- }

PROCEDURE ASK_RETURN;

    PROCEDURE THE_QUESTION;

	BEGIN

	    { +
	    Set up to handle user input garbage.
	    - }
	    SYS$INPUT_ERROR	:= FALSE;
	    LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	    { +
	    Ask the user how to proceed, and wait for his response.
	    - }
	    WRITE (
	    CRLF,
	    SHIFT,
	    ANSI_REVERSE,DASH,
	    ' ',CONTINUE_TEXT,' ',
	    DASH,ANSI_RESET,
	    TAB,TAB,TAB
	    );

	    READLN;

	END;	{ THE_QUESTION }

BEGIN

    { +
    Pop the question.
    - }
    THE_QUESTION;

    { +
    Now that he's answered, clear his screen.
    - }
    IF REGIS THEN

	WRITELN (
	ESCAPE,'Pp;S(E);',
	ESCAPE,'\');

    STATUS	:= LIB$ERASE_PAGE (LINE_ONE,COL_ONE);

END;	{ ASK_RETURN }

{ ++

ASK_SCRIPT -- Query the user as to which script to invoke.

This routine asks the user for his script.

CALLING SEQUENCE:

ASK_SCRIPT;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT_ERROR
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SCRIPT_OPTION
SYS$OUTPUT:

ROUTINES CALLED:

none

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ASK_SCRIPT;

    PROCEDURE THE_QUESTION;

    BEGIN

	{ +
	Set up condition handler.
	- }
	SYS$INPUT_ERROR	:= FALSE;
	LIB$ESTABLISH (SYS$INPUT_COND_HANDLER);

	{ +
	Here we go...
	- }
	CLEAR (IF_FULL_PROMPT);
    
	{ +
	Show the menu only if we're being verbose.
	- }
	IF FULL_PROMPT OR TEMP_FULL_PROMPT THEN
    
	BEGIN

	    { +
	    Put the title out in reverse video.
	    - }
	    WRITELN (
	    SHIFT,
	    TAB,TAB,
	    ANSI_REVERSE,DASH,
	    ' Script Title Selection ',
	    DASH,ANSI_RESET,
	    CRLF,
	    CRLF,
	    SHIFT,
'Design    Any file org: a dialog of file info and parameter calculations'
	    );
	    WRITELN (
	    SHIFT,
'Optimize  Indexed only: a redesign using actual file data from Analyze',
	    CRLF,
	    SHIFT,
'Redesign  Indexed only: a rework of just one index''s parameters',
	    CRLF
	    );

	END

	ELSE

	    WRITELN (SHIFT,'(Design Optimize Redesign)');

	{ +
	Pop the question.
	- }
	WRITE (SHIFT,'Editing Script Title',TAB,TAB,'(Keyword)',
	ANSI_REVERSE,'[-]',ANSI_RESET,TAB,': ');
	PARSE_INPUT (
	EDF$AB_SCRIPT_OPTION_TABLE_KEY,EDF$AB_SCRIPT_OPTION_TABLE_STA,FALSE,0
	);

	CASE INPUT_VALUE OF

	    EDF$C_DESIGN_FDL :		SCRIPT_OPTION	:= DESIGN_FDL;
	    EDF$C_OPTIMIZE_FDL :	SCRIPT_OPTION	:= OPTIMIZE_FDL;
	    EDF$C_REDESIGN_FDL :	SCRIPT_OPTION	:= REDESIGN_FDL;

	OTHERWISE

	    { +
	    BUGCHECK!!
	    - }
	    LIB$SIGNAL (EDF$_INTSWERR,1,21,0);

	END;	{ CASE }

	{ +
	Make sure this is true for one cycle only.
	- }
	TEMP_FULL_PROMPT	:= FALSE;

    END;	{ THE_QUESTION }

BEGIN

    { +
    Keep at it until the user gets it right.
    - }
    REPEAT

	THE_QUESTION;

    UNTIL NOT SYS$INPUT_ERROR;

END;	{ ASK_SCRIPT }

    { End of file: SRC$:EDFASK.PAS }
