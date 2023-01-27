PROGRAM EDF (INPUT,OUTPUT,FDL_DEST);

{ ++

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

		V03-004	KFH0003		Ken Henderson		26-Mar-1982
			Modified Mainline code to establish
			the CTRLZ handler before asking to
			continue after an error parsing the
			FDL definition file - QAR 885.

		V03-002	KFH0002		Ken Henderson		23-Mar-1982
			Modified routines INPUT_FDL_FILE and
			INPUT_ANALYSIS_FILE and the mainline
			code to fix FT2 QARs 694,699

		V03-001	KFH0001		Ken Henderson		17-Mar-1982
			Reset TEMP_FULL_PROMPT to false in the main
			loop. (dispatch_function)

-- }

CONST
    %INCLUDE 'SYS$LIBRARY:SIGDEF.PAS'

    %INCLUDE 'SYS$LIBRARY:LIBDEF.PAS'

    %INCLUDE 'SYS$LIBRARY:PASDEF.PAS'

    %INCLUDE 'SRC$:EDFCONST.PAS'

TYPE
    %INCLUDE 'SRC$:EDFTYPE.PAS'

VAR
    %INCLUDE 'SRC$:EDFVAR.PAS'

VALUE
    %INCLUDE 'SRC$:EDFVALUE.PAS'

{ EXTERN }
    %INCLUDE 'SRC$:EDFEXTERN.PAS'

{ +
Forward declare these routines so that early routines can use them.
- }
PROCEDURE DELAY (
		DELTA : REAL
		); FORWARD;

PROCEDURE ASK_RETURN; FORWARD;

PROCEDURE POINT_AT_DEFINITION; FORWARD;

PROCEDURE EDF$RESET_SCROLL; FORWARD;

PROCEDURE SHOW_ALL_PRIMARIES; FORWARD;

PROCEDURE SHOW_PRIMARY_SECTION (
		TEST : LINE_OBJECT
		); FORWARD;

PROCEDURE SHOW_CUR_PRI_SEC (
		PLUS_VALUE : PLUS_VALUE_TYPE
		); FORWARD;

    { This forward declaration code is in file SRC$:EDFMAIN.PAS }

    %INCLUDE 'SRC$:EDFCHF.PAS'

    %INCLUDE 'SRC$:EDFUTIL.PAS'

    %INCLUDE 'SRC$:EDFASK.PAS'

    %INCLUDE 'SRC$:EDFSHOW.PAS'

    %INCLUDE 'SRC$:EDFDESIGN.PAS'

    %INCLUDE 'SRC$:EDFFUNCS.PAS'

{ ++

INIT_EDITOR -- Initialize EDF upon startup.

This is the setup code to create the initial conditions for EDF.

CALLING SEQUENCE:

INIT_EDITOR;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

DCL (through the CLI$ routines)

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

EDITING
ANSI_RESET
ANSI_BOLD
ANSI_UNDERSCORE
ANSI_BLINK
ANSI_REVERSE
NULL_STRING4
SHIFT
LOW_SHIFT
TERMINAL_SPEED
RMS_INPUT_ERROR
VID_TERM
DEV_TYPE
LINE_WIDTH
LINES_PER_PAGE
VIDEO_TERMINAL
NULL_CHAR
CONTROL_G
CONTROL_W
CONTROL_Z
TAB
CRLF
ESCAPE
QUESTION_MARK
FDL$AB_LINE
FDL$AB_CTRL
FDL$GL_PCALL
FDL$AB_COMMENT
FDL$AB_STRING
FDL$GL_PRIMARY
FDL$GL_PRINUM
FDL$GL_SECONDARY
FDL$GL_SECNUM
FDL$GL_QUALIFIER
FDL$GL_NUMBER
FDL$GL_NUMTYPE
FDL$GL_SWITCH
FDL$GL_UIC_GROUP
FDL$GL_UIC_MEMBER
FDL$GL_PROTECTION
FDL$GL_FID1
FDL$GL_FID2
FDL$GL_FID3
EDF$GL_PROT_MASK
EDF$GL_FID1
EDF$GL_FID2
EDF$GL_FID3
EDF$GL_UIC_GROUP
EDF$GL_UIC_MEMBER
EDF$AB_STRING
EDF$AB_COMMENT
LIB$PUT_OUTPUT_PTR
LIB$GET_INPUT_PTR
STATUS
DEF_CURRENT
DEF_HEAD
DEF_TAIL
DEF_PRED
DEF_SUCC
INPUT_FILENAME_DESC
OUTPUT_FILENAME_DESC
ANALYSIS_FILENAME_DESC
FIRST_SCRIPT
FULL_PROMPT

ROUTINES CALLED:

EDF$TERM_SETUP
EDF$GLOBAL
FDL$$PARSE
LIB$ESTABLISH
LIB$SIGNAL
CLI$GET_VALUE
CLI$PRESENT

ROUTINE VALUE:

none

SIGNALS:

EDF$_INTSWERR - if bugcheck
EDF$_SMALLPAGE - if term screen size too small

SIDE EFFECTS:

EDF is initialized.

-- }

PROCEDURE INIT_EDITOR;

VAR
    TEMP_DESCRIPTOR	: DESCRIPTOR;
    I			: INTEGER;

BEGIN

    { +
    Do initialization on the terminal. Get its speed, setup exit handler,
    Also check to make sure that indeed the
    input is a terminal (and STOPs if not) and if the terminal isn't a scope,
    then it sets the page length to 16
    (as required by hardcopy surface plots).

    *******************
    The call to EDF$TERM_SETUP Must come BEFORE ANY calls to the
    SCREEN PACKAGE!!!
    *******************

    - }
    TERMINAL_SPEED	:= EDF$TERM_SETUP;

    { +
    Set up ^C ast routine.
    - }
    EDF$CTRLCAST;

    { +
    First find out what terminal characteristics we have.
    - }
    STATUS := LIB$SCREEN_INFO (
				SCREEN_FLAGS,
				DEV_TYPE,
				LINE_WIDTH,
				LINES_PER_PAGE
				);

    { +
    Instead of using the actual terminal type,
    we'll just test on deccrt or not.
    - }
    VIDEO_TERMINAL		:= SCREEN_FLAGS[SCR$V_VIDEO];
    DEC_CRT			:= SCREEN_FLAGS[SCR$V_DECCRT];
    ANSI_CRT			:= SCREEN_FLAGS[SCR$V_ANSICRT];
    REGIS			:= SCREEN_FLAGS[SCR$V_REGIS];

    { +
    See if we have enough room on the terminal.
    - }
    IF (
    (LINE_WIDTH < MINIMUM_TERM_WIDTH)
    OR
    (VIDEO_TERMINAL AND (LINES_PER_PAGE < MINIMUM_VIDEO_PAGE))
    ) THEN

	{ +
	Not enough room!
	- }
	LIB$SIGNAL (EDF$_SMALLPAGE,2,LINE_WIDTH,LINES_PER_PAGE);

    { +
    Finish setting up the character sequences to control a DEC_CRT terminal's
    video attributes.
    - }
    NULL_CHAR			:= CHR (00);	{ NULL }
    CONTROL_G			:= CHR (07);	{ BELL }
    TAB				:= CHR (09);	{ TAB }
    CRLF[2]			:= CHR (10);	{ LF }
    CRLF[1]			:= CHR (13);	{ CR }
    CONTROL_W			:= CHR (23);	{ ^W }
    CONTROL_Z			:= CHR (26);	{ ^Z }
    ESCAPE			:= CHR (27);	{ ESC }
    APOSTROPHE			:= CHR (39);	{ ' }
    QUESTION_MARK		:= CHR (63);	{ ? }

    NULL_STRING4[1]		:= NULL_CHAR;
    NULL_STRING4[2]		:= NULL_CHAR;
    NULL_STRING4[3]		:= NULL_CHAR;
    NULL_STRING4[4]		:= NULL_CHAR;

    ANSI_RESET[1]		:= ESCAPE;
    ANSI_BOLD[1]		:= ESCAPE;
    ANSI_UNDERSCORE[1]		:= ESCAPE;
    ANSI_BLINK[1]		:= ESCAPE;
    ANSI_REVERSE[1]		:= ESCAPE;

    SHIFT[1]			:= TAB;
    SHIFT[2]			:= NULL_CHAR;
    SHIFT[3]			:= NULL_CHAR;
    SHIFT[4]			:= NULL_CHAR;

    DASH			:= NULL_CHAR;

    { +
    If we don't have an ANSI terminal (VT100-series and up), then zero out the
    video attribute arrays.
    - }
    IF NOT DEC_CRT THEN

    BEGIN

	DASH	:= '-';

	FOR I := 1 TO 4 DO

	BEGIN

	    ANSI_RESET[I]		:= NULL_CHAR;
	    ANSI_BOLD[I]		:= NULL_CHAR;
	    ANSI_UNDERSCORE[I]		:= NULL_CHAR;
	    ANSI_BLINK[I]		:= NULL_CHAR;
	    ANSI_REVERSE[I]		:= NULL_CHAR;

	END;

    END;	{ IF NOT DEC_CRT }

    { +
    If we have more than 80 chars per line, we may have to shift everything
    over to the right. (if we also have a video terminal)
    - }
    IF (LINE_WIDTH > EDF$C_SHIFTPOINT) AND VIDEO_TERMINAL THEN

    BEGIN

	SHIFT[2]		:= TAB;
	SHIFT[3]		:= TAB;
	SHIFT[4]		:= TAB;

    END;

    { +
    The 'under-graph' text comes out in graphics mode for Regis devices.
    - }
    IF REGIS THEN

    BEGIN

	LOW_SHIFT[1]		:= NULL_CHAR;
	LOW_SHIFT[2]		:= NULL_CHAR;
	LOW_SHIFT[3]		:= NULL_CHAR;

    END		{ IF TRUE REGIS }

    ELSE

    BEGIN

	LOW_SHIFT[1]		:= SHIFT[2];
	LOW_SHIFT[2]		:= SHIFT[3];
	LOW_SHIFT[3]		:= SHIFT[4];

    END;	{ IF FALSE REGIS }

    { +
    OK, so let the user know that we're here.
    - }
    CLEAR (SCREEN);

    { +
    Set up the FDL variables - also global with V2.
    - }
    NEW (FDL$AB_LINE);
    NEW (FDL$AB_CTRL);
    NEW (FDL$GL_PCALL);
    NEW (FDL$AB_COMMENT);
    NEW (FDL$AB_STRING);
    NEW (FDL$GL_PRIMARY);
    NEW (FDL$GL_PRINUM);
    NEW (FDL$GL_SECONDARY);
    NEW (FDL$GL_SECNUM);
    NEW (FDL$GL_QUALIFIER);
    NEW (FDL$GL_NUMBER);
    NEW (FDL$GL_NUMTYPE);
    NEW (FDL$GL_SWITCH);
    NEW (FDL$GL_UIC_GROUP);
    NEW (FDL$GL_UIC_MEMBER);
    NEW (FDL$GL_PROTECTION);
    NEW (FDL$GL_FID1);
    NEW (FDL$GL_FID2);
    NEW (FDL$GL_FID3);
    NEW (LIB$PUT_OUTPUT_PTR);
    NEW (LIB$GET_INPUT_PTR);
    NEW (EDF$GL_SECNUM);
    NEW (EDF$GL_PROT_MASK);
    NEW (EDF$GL_FID1);
    NEW (EDF$GL_FID2);
    NEW (EDF$GL_FID3);
    NEW (EDF$GL_UIC_GROUP);
    NEW (EDF$GL_UIC_MEMBER);
    NEW (EDF$AB_STRING);
    NEW (EDF$AB_COMMENT);

    { +
    Initialize the TPARSE block.
    - }
    WITH PARAM_BLOCK DO

    BEGIN

	TPA$L_COUNT			:= TPA$K_COUNT0;
	TPA$L_OPTIONS[TPA$V_ABBREV]	:= TRUE;

	NEW (TPA$L_STRINGPTR);
	NEW (TPA$L_TOKENPTR);

    END;	{ DO }

    { +
    These pointers initially point to some integers.
    Now make them point to the global symbols that locate the actual
    variables. (this code can be improved for Pascal V2)
    - }
    EDF$GLOBAL (
		FDL$AB_LINE,
		FDL$AB_CTRL,
		FDL$GL_PCALL,
		FDL$AB_COMMENT,
		FDL$AB_STRING,
		FDL$GL_PRIMARY,
		FDL$GL_PRINUM,
		FDL$GL_SECONDARY,
		FDL$GL_SECNUM,
		FDL$GL_QUALIFIER,
		FDL$GL_NUMBER,
		FDL$GL_NUMTYPE,
		FDL$GL_SWITCH,
		FDL$GL_UIC_GROUP,
		FDL$GL_UIC_MEMBER,
		FDL$GL_PROTECTION,
		FDL$GL_FID1,
		FDL$GL_FID2,
		FDL$GL_FID3,
		LIB$PUT_OUTPUT_PTR,
		LIB$GET_INPUT_PTR,
		EDF$GL_SECNUM,
		EDF$GL_PROT_MASK,
		EDF$GL_FID1,
		EDF$GL_FID2,
		EDF$GL_FID3,
		EDF$GL_UIC_GROUP,
		EDF$GL_UIC_MEMBER,
		EDF$AB_STRING,
		EDF$AB_COMMENT,
		EDF$AB_FID_TABLE_KEY,
		EDF$AB_FID_TABLE_STA,
		EDF$AB_UIC_TABLE_KEY,
		EDF$AB_UIC_TABLE_STA,
		EDF$AB_PRIMARY_TABLE_KEY,
		EDF$AB_PRIMARY_TABLE_STA,
		EDF$AB_AREA_TABLE_KEY,
		EDF$AB_AREA_TABLE_STA,
		EDF$AB_DATE_TABLE_KEY,
		EDF$AB_DATE_TABLE_STA,
		EDF$AB_FILE_TABLE_KEY,
		EDF$AB_FILE_TABLE_STA,
{		EDF$AB_JOURNAL_TABLE_KEY, }
{		EDF$AB_JOURNAL_TABLE_STA, }
		EDF$AB_KEY_TABLE_KEY,
		EDF$AB_KEY_TABLE_STA,
		EDF$AB_RECORD_TABLE_KEY,
		EDF$AB_RECORD_TABLE_STA,
		EDF$AB_SYSTEM_TABLE_KEY,
		EDF$AB_SYSTEM_TABLE_STA,
		EDF$AB_POSIT_TABLE_KEY,
		EDF$AB_POSIT_TABLE_STA,
		EDF$AB_PROT_TABLE_KEY,
		EDF$AB_PROT_TABLE_STA,
		EDF$AB_ORG_TABLE_KEY,
		EDF$AB_ORG_TABLE_STA,
		EDF$AB_SOURCE_TABLE_KEY,
		EDF$AB_SOURCE_TABLE_STA,
{		EDF$AB_AT_TABLE_KEY, }
{		EDF$AB_AT_TABLE_STA, }
{		EDF$AB_RU_TABLE_KEY, }
{		EDF$AB_RU_TABLE_STA, }
		EDF$AB_CARR_TABLE_KEY,
		EDF$AB_CARR_TABLE_STA,
		EDF$AB_FORMAT_TABLE_KEY,
		EDF$AB_FORMAT_TABLE_STA,
		EDF$AB_TYPE_TABLE_KEY,
		EDF$AB_TYPE_TABLE_STA,
		EDF$AB_LOAD_METHOD_TABLE_KEY,
		EDF$AB_LOAD_METHOD_TABLE_STA,
		EDF$AB_WEIGHT_TABLE_KEY,
		EDF$AB_WEIGHT_TABLE_STA,
		EDF$AB_DESIGN_STYLE_TABLE_KEY,
		EDF$AB_DESIGN_STYLE_TABLE_STA,
		EDF$AB_SURFACE_OPTION_TABLE_KEY,
		EDF$AB_SURFACE_OPTION_TABLE_STA,
		EDF$AB_CURRENT_FUNC_TABLE_KEY,
		EDF$AB_CURRENT_FUNC_TABLE_STA,
		EDF$AB_DESIGN_CYCLE_TABLE_KEY,
		EDF$AB_DESIGN_CYCLE_TABLE_STA,
		EDF$AB_SCRIPT_OPTION_TABLE_KEY,
		EDF$AB_SCRIPT_OPTION_TABLE_STA,
		EDF$AB_YES_NO_TABLE_KEY,
		EDF$AB_YES_NO_TABLE_STA
		);

    { +
    Initialize the pointers to the Definition Linked List.
    - }
    DEF_CURRENT		:= NIL;
    DEF_HEAD		:= NIL;
    DEF_TAIL		:= NIL;
    DEF_PRED		:= NIL;
    DEF_SUCC		:= NIL;

    DEF_ANL_HEAD	:= NIL;
    DEF_ANL_TAIL	:= NIL;
    DEF_SAVE_HEAD	:= NIL;
    DEF_SAVE_TAIL	:= NIL;

    FILE_CREATED	:= FALSE;
    BLOCK_SPAN_ALLOWED	:= TRUE;

    { +
    Create a line objects for general use.
    - }
    MAKE_SCRATCH;

    POINTING_DIRECTION	:= DEFINITION_LIST;

    { +
    Create an Ident line_object and put it into the list.
    - }
    NEW_IDENT_LINE;

    { +
    See what we have.
    - }
    ANALYSIS_SPECIFIED	:= ODD (CLI$PRESENT ('ANALYSIS'));

    IF ANALYSIS_SPECIFIED THEN

    BEGIN

	{ +
	Save the analysis filename.
	- }
	SETUP_DESC (ANALYSIS_FILENAME_DESC);
	STATUS	:= CLI$GET_VALUE ('ANALYSIS',ANALYSIS_FILENAME_DESC);

    END;	{ IF ANALYSIS_SPECIFIED }

    { +
    Save the input filename.
    - }
    SETUP_DESC (INPUT_FILENAME_DESC);
    STATUS	:= CLI$GET_VALUE ('P1',INPUT_FILENAME_DESC);

    { +
    Find out which output filename we're using, the /OUTPUT, or the
    command parameter.
    - }
    SETUP_DESC (OUTPUT_FILENAME_DESC);

    IF ODD (CLI$PRESENT ('OUTPUT')) THEN

    BEGIN

	{ +
	The /OUTPUT switch overrides, so use it if present.
	- }
	STATUS	:= CLI$GET_VALUE ('OUTPUT',OUTPUT_FILENAME_DESC);

    END

    ELSE

	{ +
	The user just wants another version of the input file.
	- }
	STATUS	:= LIB$SCOPY_DXDX (INPUT_FILENAME_DESC,OUTPUT_FILENAME_DESC);

    { +
    Set up the script to the one specified in the DCL command. (if any)
    - }
    IF ODD (CLI$PRESENT('SCRIPT')) THEN

    BEGIN

	SETUP_DESC (TEMP_DESCRIPTOR);
	STATUS	:= CLI$GET_VALUE ('SCRIPT',TEMP_DESCRIPTOR);

	{ +
	Case on the 1st letter.
	- }
	CASE TEMP_DESCRIPTOR.DSC$A_POINTER^[1] OF

	    'D' :	FIRST_SCRIPT	:= DESIGN_FDL;

	    'O' :	FIRST_SCRIPT	:= OPTIMIZE_FDL;

	    'R' :	FIRST_SCRIPT	:= REDESIGN_FDL;

	OTHERWISE

	    { +
	    If the user blows it, give him nothing.
	    - }
	    FIRST_SCRIPT		:= ZERO_SCRIPT;

	END;	{ CASE }

	STR$FREE1_DX (TEMP_DESCRIPTOR);

    END		{ IF TRUE SCRIPT PRESENT }

    ELSE

	FIRST_SCRIPT	:= ZERO_SCRIPT;

    { +
    If the user specified a prompt level, set EDF's level to that,
    otherwise set it according to the type of terminal (hardcopy gets Brief).
    - }
    IF ODD (CLI$PRESENT ('PROMPT')) THEN

    BEGIN

	{ +
	Get the prompting level specified by the user.
	- }
	SETUP_DESC (TEMP_DESCRIPTOR);
	STATUS	:= CLI$GET_VALUE ('PROMPT',TEMP_DESCRIPTOR);
    
	{ +
	The 1st character of the string is unique.
	- }
	CASE TEMP_DESCRIPTOR.DSC$A_POINTER^[1] OF
    
	    { +
	    Brief prompting
	    - }
	    'B' :

		FULL_PROMPT	:= FALSE;
    
	    { +
	    Full prompting
	    - }
	    'F' :
    
		FULL_PROMPT	:= TRUE;
    
	OTHERWISE
    
	    { +
	    Automatic prompting.
	    Default to Brief prompting for non-scope (or slow) terminals.
	    - }
	    IF ( VIDEO_TERMINAL
		AND
		( TERMINAL_SPEED >= TT$C_BAUD_2400 ) ) THEN

		FULL_PROMPT	:= TRUE

	    ELSE

		FULL_PROMPT	:= FALSE;

	END;		{ CASE }

	STR$FREE1_DX (TEMP_DESCRIPTOR);

    END		{ IF TRUE (ODD) }

    ELSE

    BEGIN

	{ +
	Default to Brief prompting for non-scope (or slow) terminals.
	- }
	IF VIDEO_TERMINAL AND (TERMINAL_SPEED >= TT$C_BAUD_2400) THEN
    
	    FULL_PROMPT	:= TRUE

	ELSE

	    FULL_PROMPT	:= FALSE;

    END;	{ IF FALSE (ODD) }

    { +
    Now prepare for handling the logical name when creating the output file.
    - }
    SETUP_DESC (EDF$MAKE_FDL_DESC);
    STR$TRIM (EDF$MAKE_FDL_DESC,'EDF$MAKE_FDL');

    SETUP_DESC (DEFAULT_FILENAME_DESC);
    STR$TRIM (DEFAULT_FILENAME_DESC,'.FDL');

    SETUP_DESC (NL_DEV_DESC);
    STR$TRIM (NL_DEV_DESC,'NL:');

    { +
    Set the main loop variable to true so we can execute the main cycle.
    - }
    EDITING		:= TRUE;

END;	{ INIT_EDITOR }

{ ++

INPUT_FDL_FILE -- Uses FDL$$PARSE to read the user's input FDL file.

This routine parses the input file using FDL$$PARSE.

CALLING SEQUENCE:

INPUT_FDL_FILE;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

The Definition Linked List

ROUTINES CALLED:

FDL$$PARSE

ROUTINE VALUE:

none

SIGNALS:

EDF$_INTSWERR - if bugcheck

SIDE EFFECTS:

none

-- }

PROCEDURE INPUT_FDL_FILE;

VAR
    TEMP_BIT_ARRAY	: CTRL_ARRAY;

BEGIN

    { +
    Set up the condition handler for the disk.
    - }
    LIB$ESTABLISH (RMS_INPUT_COND_HANDLER);

    { +
    Now tell the user what we're doing.
    - }
    WRITELN (SHIFT,TAB,TAB,'Parsing Definition File');

    { +
    Make sure edf$line_parsed gets the non-analysis stuff.
    - }
    ANALYSIS_ONLY	:= FALSE;

    { +
    Turn on the PCALL bit in FDL$AB_CTRL to make FDL$$PARSE call us.
    Also, turn on the DCL bit to make FDL$$PARSE signal errors to us.
    - }
    TEMP_BIT_ARRAY		:= FDL$AB_CTRL^;
    TEMP_BIT_ARRAY[FDL$V_PCALL]	:= TRUE;
    TEMP_BIT_ARRAY[FDL$V_DCL]	:= TRUE;
    FDL$AB_CTRL^		:= TEMP_BIT_ARRAY;

    { +
    Parse the input file to get the old definition.
    If the input file doesn't exist, this will signal up to the main loop.
    - }
    STATUS	:= FDL$$PARSE (INPUT_FILENAME_DESC,FAB_DUMMY);

    { +
    Turn off the PCALL and DCL bits in FDL$AB_CTRL.
    - }
    TEMP_BIT_ARRAY		:= FDL$AB_CTRL^;
    TEMP_BIT_ARRAY[FDL$V_PCALL]	:= FALSE;
    TEMP_BIT_ARRAY[FDL$V_DCL]	:= FALSE;
    FDL$AB_CTRL^		:= TEMP_BIT_ARRAY;

    IF ODD (STATUS) THEN

	WRITELN (SHIFT,TAB,TAB,'Definition Parse Complete');

END;	{ INPUT_FDL_FILE }

{ ++

INPUT_ANALYSIS_FILE -- Read in the analysis file if specified.

This routine parses the user's analysis file if he has specified one.

CALLING SEQUENCE:

INPUT_ANALYSIS_FILE;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

The Analysis Linked List

ROUTINES CALLED:

FDL$$PARSE

ROUTINE VALUE:

none

SIGNALS:

EDF$_INTSWERR - if bugcheck

SIDE EFFECTS:

none

-- }

PROCEDURE INPUT_ANALYSIS_FILE;

VAR
    TEMP_BIT_ARRAY	: CTRL_ARRAY;

BEGIN

    { +
    Only do this if the user wants to.
    - }
    IF EDITING AND ANALYSIS_SPECIFIED THEN

    BEGIN

	{ +
	Set up the condition handler for the disk.
	- }
	LIB$ESTABLISH (RMS_INPUT_COND_HANDLER);

	{ +
	Now tell the user what we're doing.
	- }
	WRITELN (SHIFT,TAB,TAB,'Parsing Analysis File');

	{ +
	Make sure edf$line_parsed gets only the analysis stuff.
	- }
	ANALYSIS_ONLY	:= TRUE;
	POINT_AT_ANALYSIS;

	{ +
	Create an Ident line_object and put it into the list.
	- }
	NEW_IDENT_LINE;

	{ +
	Turn on the PCALL bit in FDL$AB_CTRL to make FDL$$PARSE call us.
	Also, turn on the DCL bit to make FDL$$PARSE signal errors to us.
	- }
	TEMP_BIT_ARRAY			:= FDL$AB_CTRL^;
	TEMP_BIT_ARRAY[FDL$V_PCALL]	:= TRUE;
	TEMP_BIT_ARRAY[FDL$V_DCL]	:= TRUE;
	FDL$AB_CTRL^			:= TEMP_BIT_ARRAY;

	{ +
	Parse the analysis file to get the analysis sections.
	If it doesn't exist, this will signal up to the main loop.
	- }
	STATUS	:= FDL$$PARSE (ANALYSIS_FILENAME_DESC,FAB_DUMMY);

	{ +
	Turn off the PCALL and DCL bits in FDL$AB_CTRL.
	- }
	TEMP_BIT_ARRAY			:= FDL$AB_CTRL^;
	TEMP_BIT_ARRAY[FDL$V_PCALL]	:= FALSE;
	TEMP_BIT_ARRAY[FDL$V_DCL]	:= FALSE;
	FDL$AB_CTRL^			:= TEMP_BIT_ARRAY;

	ANALYSIS_ONLY	:= FALSE;
	POINT_AT_DEFINITION;

	IF ODD (STATUS) THEN

	    WRITELN (SHIFT,TAB,TAB,'Analysis Parse Complete');

    END;	{ IF EDITING AND ANALYSIS_SPECIFIED }

END;		{ INPUT_ANALYSIS_FILE }

{ ++

SETUP_CONTINUE -- Get ready to ask the user if he wants to continue after
an input parse error.

CALLING SEQUENCE:

SETUP_CONTINUE;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

none

ROUTINES CALLED:

CLEAR

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE SETUP_CONTINUE;

BEGIN

    { +
    Set up the control/Z handler in case the user types ^Z.
    - }
    LIB$ESTABLISH (CTRLZ_COND_HANDLER);

    CLEAR (PAUSE);

END;	{ SETUP_CONTINUE }

{ ++

DISPATCH_FUNCTION -- Branch off to the selected function.

This routine is just a big CASE statement to execute the operation the
user wants.

CALLING SEQUENCE:

DISPATCH_FUNCTION

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

FIRST_SCRIPT
CURRENT_FUNCTION

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

EDITING
SCRIPT_OPTION

ROUTINES CALLED:

ADD_FDL_LINE
DELETE_FDL_LINE
CREATE_NEW_FDL
HELP_PROC
MODIFY_FDL_LINE
INVOKE_SCRIPT
VIEW_DEF

ROUTINE VALUE:

none

SIGNALS:

EDF$_INTSWERR - if bugcheck

SIDE EFFECTS:

none

-- }

PROCEDURE DISPATCH_FUNCTION;

BEGIN

    { +
    Set up the control/Z handler and reinitialize some flags.
    - }
    LIB$ESTABLISH (CTRLZ_COND_HANDLER);

    CLOSE (FDL_DEST);
    POINT_AT_DEFINITION;
    DEST_IS_TERMINAL	:= TRUE;
    OPTIMIZING		:= FALSE;
    VISIBLE_QUESTION	:= FALSE;
    TEMP_FULL_PROMPT	:= FALSE;

    { +
    Ask the user only if he hadn't requested one from DCL.
    - }
    IF FIRST_SCRIPT = ZERO_SCRIPT THEN

    BEGIN

	{ +
	Get the user's top-level function and dispatch on it.
	- }
	ASK_FUNCTION;

	CASE CURRENT_FUNCTION OF

	    ADD :	ADD_FDL_LINE;	{ Add a new line_object to the list. }

	    DELETE :	DELETE_FDL_LINE; { Remove a line_object from the list. }

	    EXIT :

	    BEGIN

		{ +
		Stop the editing loop and output the new FDL file.
		- }
		EDITING	:= FALSE;
		CREATE_NEW_FDL;

	    END;

	    HELP :	HELP_PROC;	{ Prompt for help and process it. }

	    INVOKE :	INVOKE_SCRIPT; { Ask a bunch of related questions. }

	    MODIFY :	MODIFY_FDL_LINE; { Edit an extant line_object. }

	    QUIT :	EDITING := FALSE; { Wipe out! All bets are off! }

	    VIEW :	VIEW_DEF;	{ Show the user the definition. }

	OTHERWISE

	    { +
	    BUGCHECK!!
	    - }
	    LIB$SIGNAL (EDF$_INTSWERR,1,36,0);

	END;	{ CASE }

    END		{ IF TRUE FIRST_SCRIPT = ZERO_SCRIPT }

    ELSE

    BEGIN

	{ +
	The user wants to do a script right off, do it.
	- }
	SCRIPT_OPTION	:= FIRST_SCRIPT;

	INVOKE_SCRIPT;

    END;	{ IF FALSE FIRST_SCRIPT = ZERO_SCRIPT }

END;	{ DISPATCH_FUNCTION }

{ ++
+----------------------------------------------------+
| *** THIS IS THE TOP LEVEL CODE IN THE UTILITY. *** |
+----------------------------------------------------+
-- }


BEGIN

    { +
    Set up the editor, setup the exit and condition hanlders, a control/C
    AST routine, and get all the DCL switch options.
    Set EDITING to TRUE.
    - }
    INIT_EDITOR;

    { +
    Read in the FDL file, and possibly an analysis file.
    1st clear the error flag.
    - }
    RMS_INPUT_ERROR	:= FALSE;

    INPUT_FDL_FILE;
    INPUT_ANALYSIS_FILE;

    { +
    If we had an error, pause to let the user read the messages,
    otherwise, continue on.
    - }
    IF EDITING AND RMS_INPUT_ERROR THEN

	SETUP_CONTINUE

    ELSE

	DELAY (1.3);

    { +
    This is the Main Loop.
    - }
    WHILE EDITING DO

    BEGIN

	DISPATCH_FUNCTION;

	IF MAIN_CTRLZ THEN

	BEGIN

	    { +
	    Stop the editing loop and output the new FDL file.
	    - }
	    EDITING	:= FALSE;
	    CREATE_NEW_FDL;

	END;

    END;	{ WHILE EDITING }

END.	{ EDF UTILITY. }
