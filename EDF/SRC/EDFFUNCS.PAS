{ ++
    		FILE: SRC$:EDFFUNCS.PAS - Pascal include file to implement
		higher-level function routines for EDF.

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

		V03-004	KFH0004		Ken Henderson		31 March 1982
			Modified CREATE_NEW_FDL to fix
			FT2 QAR 967

		V03-003	KFH0003		Ken Henderson		28 March 1982
			Modified CREATE_NEW_FDL to not output
			FDL file if the definition is empty.

		V03-002	KFH0002		Ken Henderson		23-Mar-1982
			Modified HELP_PROC to fix FT2 QAR 831

		V03-001	KFH0001		Ken Henderson		17-Mar-1982
			Modified a few routines to fix FT2
			QARs 500,510

-- }

{ ++

CREATE_NEW_FDL -- Routine to output a new FDL file.

This routine outputs the FDL file to the disk.

CALLING SEQUENCE:

CREATE_NEW_FDL;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

none

ROUTINES CALLED:

none

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE CREATE_NEW_FDL;

VAR
    CREATED			: BOOLEAN;
    USING_LOGICAL		: BOOLEAN;
    TEMP_STRING255		: STRING255;
    TEMP_DESCRIPTOR		: DESCRIPTOR;
    TEMP_BIT_ARRAY		: CTRL_ARRAY;
    SCRATCH1			: INTEGER;
    SCRATCH2			: INTEGER;
    SCRATCH3			: INTEGER;
    I				: INTEGER;
    J				: INTEGER;

BEGIN

    { +
    Only output the FDL file if the definition is not empty.
    - }
    IF DEF_HEAD = DEF_TAIL THEN

    BEGIN

	FILE_CREATED	:= FALSE;

	WRITELN (CRLF,SHIFT,
	'Output not created:',CRLF,SHIFT,
	'Current FDL Definition empty.'
	);

    END		{ IF TRUE DEF_HEAD = DEF_TAIL }

    ELSE

    BEGIN

	CREATED		:= FALSE;

	{ +
	1st, see if the EDF$MAKE_FDL logical name exists.
	- }
	SETUP_DESC (TEMP_DESCRIPTOR);

	SETUP_DESC (RES_OUTPUT_FILENAME_DESC);
	NEW (RES_OUTPUT_FILENAME_DESC.DSC$A_POINTER);
	RES_OUTPUT_FILENAME_DESC.DSC$W_LENGTH	:= 255;

	STATUS	:= SYS$TRNLOG (
				EDF$MAKE_FDL_DESC,
				SCRATCH1,
				TEMP_DESCRIPTOR,
				SCRATCH2,
				SCRATCH3,
				0
				);

	IF ODD (STATUS) THEN

	    USING_LOGICAL	:= (STATUS = SS$_NORMAL)

	ELSE

	    USING_LOGICAL	:= FALSE;

	IF USING_LOGICAL THEN

	BEGIN

	    STATUS		:= FDL$CREATE (
				    EDF$MAKE_FDL_DESC,
				    OUTPUT_FILENAME_DESC,
				    DEFAULT_FILENAME_DESC,
				    RES_OUTPUT_FILENAME_DESC
				    );

	    IF ODD (STATUS) THEN

		CREATED		:= TRUE

	    ELSE

	    BEGIN

		WRITELN (CRLF,SHIFT,ANSI_REVERSE,DASH,
	' Using the logical name EDF$MAKE_FDL failed, retrying without it. ',
		DASH,ANSI_RESET);

		USING_LOGICAL	:= FALSE;

	    END;	{ IF FALSE ODD (STATUS) }

	END;	{ IF USING_LOGICAL }

	IF NOT USING_LOGICAL THEN

	BEGIN

	    TEMP_BIT_ARRAY		:= FDL$AB_CTRL^;
	    TEMP_BIT_ARRAY[FDL$V_DCL]	:= TRUE;
	    FDL$AB_CTRL^		:= TEMP_BIT_ARRAY;

	    STATUS		:= FDL$CREATE (
				    NL_DEV_DESC,
				    OUTPUT_FILENAME_DESC,
				    DEFAULT_FILENAME_DESC,
				    RES_OUTPUT_FILENAME_DESC
				    );

	    CREATED		:= ODD (STATUS);

	    TEMP_BIT_ARRAY		:= FDL$AB_CTRL^;
	    TEMP_BIT_ARRAY[FDL$V_DCL]	:= FALSE;
	    FDL$AB_CTRL^		:= TEMP_BIT_ARRAY;

	END;	{ IF NOT USING_LOGICAL }

	IF CREATED THEN

	BEGIN

	    { +
	    Open his file and initialize it.
	    - }
	    DEST_IS_TERMINAL	:= FALSE;

	    WITH RES_OUTPUT_FILENAME_DESC DO

	    BEGIN

		FOR I := 1 TO 255 DO

		    IF I > DSC$W_LENGTH THEN

			TEMP_STRING255[I]	:= ' '

		    ELSE

			TEMP_STRING255[I]	:= DSC$A_POINTER^[I];

	    END;

	    { +
	    Clear out the terminal in case the terminal is the output.
	    - }
	    OPEN (FDL_DEST,SYS$OUTPUT_NAME,NEW);
	    CLOSE (FDL_DEST);

	    { +
	    Now open the 'real' FDL file.
	    - }
	    OPEN (FDL_DEST,TEMP_STRING255,OLD);
	    REWRITE (FDL_DEST);

	    { +
	    Put the current definition out to the disk.
	    - }
	    GENERATE_FDL;

	    { +
	    We're done, close the file.
	    - }
	    CLOSE (FDL_DEST);

	    { +
	    Setup to show the created filename on exit.
	    - }
	    FILE_CREATED	:= TRUE;

	END;	{ IF CREATED }

    END;	{ IF FALSE DEF_HEAD = DEF_TAIL }

END;	{ CREATE_NEW_FDL }

{ ++

ADD_FDL_LINE -- Let user add a line_object to the Definition Linked List.

This routine prompts the user for his information and puts it into the
Deifinition.

CALLING SEQUENCE:

ADD_FDL_LINE;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

The Definition Linked List
DEF_CURRENT

ROUTINES CALLED:

none

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE ADD_FDL_LINE;

VAR
    DEF_TEST		: ^LINE_OBJECT;
    TEST		: LINE_OBJECT;
    SAVE_CURRENT	: ^LINE_OBJECT;
    SAVE		: LINE_OBJECT;
    DOIT		: BOOLEAN;
    FOUND_PRI		: BOOLEAN;
    CYCLE		: BOOLEAN;

BEGIN

    SAVE.STRING.DSC$W_LENGTH	:= 0;
    SAVE.STRING.DSC$A_POINTER	:= NIL;
    SAVE.COMMENT.DSC$W_LENGTH	:= 0;
    SAVE.COMMENT.DSC$A_POINTER	:= NIL;

    TEST.STRING.DSC$W_LENGTH	:= 0;
    TEST.STRING.DSC$A_POINTER	:= NIL;
    TEST.COMMENT.DSC$W_LENGTH	:= 0;
    TEST.COMMENT.DSC$A_POINTER	:= NIL;

    ASK_TEST_PRIMARY (TEST,ALL_POSSIBLE);

    CYCLE	:= TRUE;

    WHILE CYCLE DO

    BEGIN

	ASK_TEST_SECONDARY (TEST,ALL_POSSIBLE);

	SAVE		:= TEST;
    
	{ +
	Setup to display definition on the terminal.
	- }
	OPEN	(FDL_DEST,SYS$OUTPUT_NAME,NEW);
	REWRITE	(FDL_DEST);
    
	NEW (DEF_TEST);
	DEF_TEST^		:= TEST;
	DEF_TEST^.FORE		:= NIL;
	DEF_TEST^.BACK		:= NIL;
	SAVE_CURRENT		:= DEF_CURRENT;
	DEF_CURRENT		:= DEF_TEST;
    
	SHOW_CUR_PRI_SEC (NOT_INCLUDING_VALUE);
    
	DEF_CURRENT		:= SAVE_CURRENT;
	DISPOSE (DEF_TEST);
    
	CLOSE	(FDL_DEST);
    
	DOIT			:= TRUE;
    
	IF FIND_OBJECT (
	SAVE.OBJECT_TYPE,SAVE.PRIMARY,SAVE.PRINUM,SAVE.SECONDARY,SAVE.SECNUM
	) THEN
    
	BEGIN
    
	    WRITELN (CRLF,SHIFT,ANSI_REVERSE,DASH,
	    ' This line already exists, but will now be replaced. ',
	    DASH,ANSI_RESET);
    
	    DOIT		:= ASK_CONFIRM;
    
	END;	{ IF TRUE FIND_OBJECT }
    
	IF DOIT THEN
    
	BEGIN
    
	    TEST		:= SAVE;

	    ASK_TEST_SECONDARY_VALUE (TEST);
	
	    MAKE_SCRATCH;

	    DEF_SCRATCH^	:= TEST;

	    IF DEF_SCRATCH^.PRIMARY = TITLE THEN

		DEF_SCRATCH^.OBJECT_TYPE	:= PRI

	    ELSE

		DEF_SCRATCH^.OBJECT_TYPE	:= SEC;

	{ **** SUPPORT END OF LINE COMMENTS !!! *** }
	
	    INSERT_IN_ORDER (REPLACE_OBJ);
    
	    IF TEST.PRIMARY <> TITLE THEN

	    BEGIN

		{ +
		If there wasn't one of these primaries, make one.
		- }
		DEF_CURRENT	:= DEF_HEAD;
		FOUND_PRI	:= FALSE;

		REPEAT

		    IF (
		    (DEF_CURRENT^.OBJECT_TYPE = PRI)
		    AND
		    (DEF_CURRENT^.PRIMARY = SAVE.PRIMARY)
		    AND
		    (DEF_CURRENT^.PRINUM = SAVE.PRINUM)
		    ) THEN

			FOUND_PRI	:= TRUE

		    ELSE

			INCR_CURRENT;

		UNTIL (FOUND_PRI OR (DEF_CURRENT = NIL));

		IF NOT FOUND_PRI THEN

		BEGIN

		    TEST.OBJECT_TYPE		:= PRI;
		    TEST.PRIMARY		:= SAVE.PRIMARY;
		    TEST.PRINUM			:= SAVE.PRINUM;
		    TEST.SECONDARY		:= DUMMY_SECONDARY$;
		    TEST.SECNUM			:= 0;
		    TEST.STRING.DSC$W_LENGTH	:= 0;
		    TEST.STRING.DSC$A_POINTER	:= NIL;
		    TEST.COMMENT.DSC$W_LENGTH	:= 0;
		    TEST.COMMENT.DSC$A_POINTER	:= NIL;

		    MAKE_SCRATCH;

		    DEF_SCRATCH^		:= TEST;

		    INSERT_IN_ORDER (REPLACE_OBJ);

		END;	{ IF NOT FIND_OBJECT }

	    END;	{ IF TEST.PRIMARY <> TITLE }

	    CLEAR (SCREEN);
	
	    WRITELN (SHIFT,TAB,TAB,ANSI_REVERSE,DASH,
	    ' Resulting Primary Section ',
	    DASH,ANSI_RESET,CRLF);
	
	    OPEN	(FDL_DEST,SYS$OUTPUT_NAME,NEW);
	    REWRITE	(FDL_DEST);
	
	    SHOW_PRIMARY_SECTION (SAVE);
	
	    CLOSE (FDL_DEST);
    
	END;	{ IF TRUE DOIT }

    TEST	:= SAVE;

    CYCLE	:= ASK_CONT_WITH_PRI;

    END;	{ WHILE CYCLE DO }

END;	{ ADD_FDL_LINE }

{ ++

DELETE_FDL_LINE -- Get rid of a line_object.

This routine lets the user find and remove a line_object from the Definition
Linked List.

CALLING SEQUENCE:

DELETE_FDL_LINE;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

FULL_PROMPT
ANSI_REVERSE
TAB
DEF_HEAD
DEF_CURRENT
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

FDL_DEST
DEF_CURRENT
SYS$OUTPUT:

ROUTINES CALLED:

CLEAR
ASK_DELETE_OPTION
SHOW_CURRENT
INCR_CURRENT

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE DELETE_FDL_LINE;

VAR
    TEST		: LINE_OBJECT;
    SAVE		: LINE_OBJECT;
    DEF_REM_PRI		: ^LINE_OBJECT;
    REMAINING_PRI	: BOOLEAN;
    REMAINING_SEC	: BOOLEAN;
    CYCLE		: BOOLEAN;
    NO_MORE_PRI		: BOOLEAN;
    FOUND_IT		: BOOLEAN;

BEGIN

    { +
    If the Definition Linked List is not empty, then do it, else skip it.
    - }
    IF DEF_HEAD <> DEF_TAIL THEN

    BEGIN

	SAVE.STRING.DSC$W_LENGTH	:= 0;
	SAVE.STRING.DSC$A_POINTER	:= NIL;
	SAVE.COMMENT.DSC$W_LENGTH	:= 0;
	SAVE.COMMENT.DSC$A_POINTER	:= NIL;

	TEST.STRING.DSC$W_LENGTH	:= 0;
	TEST.STRING.DSC$A_POINTER	:= NIL;
	TEST.COMMENT.DSC$W_LENGTH	:= 0;
	TEST.COMMENT.DSC$A_POINTER	:= NIL;

	{ +
	These routines will only return if an existing line_object has been given.
	If 'EXTANT_ONLY' is specified.
	- }
	ASK_TEST_PRIMARY (TEST,EXTANT_ONLY);

	CYCLE	:= TRUE;

	WHILE CYCLE DO

	BEGIN

	    NO_MORE_PRI	:= FALSE;

	    ASK_TEST_SECONDARY (TEST,EXTANT_ONLY);

	    { +
	    Remember which primary it was.
	    - }
	    SAVE		:= TEST;

	    FOUND_IT		:= FIND_OBJECT (
					    TEST.OBJECT_TYPE,TEST.PRIMARY,
					    TEST.PRINUM,TEST.SECONDARY,TEST.SECNUM
					    );

	    { +
	    Setup to display definition on the terminal.
	    - }
	    OPEN	(FDL_DEST,SYS$OUTPUT_NAME,NEW);
	    REWRITE	(FDL_DEST);

	    SHOW_CUR_PRI_SEC (INCLUDING_VALUE);

	    CLOSE	(FDL_DEST);

	    IF TEST.PRIMARY <> TITLE THEN

		WRITELN (CRLF,SHIFT,ANSI_REVERSE,DASH,
		' This Secondary will now be Deleted. ',DASH,ANSI_RESET)

	    ELSE

		WRITELN (CRLF,SHIFT,ANSI_REVERSE,DASH,
		' This Primary will now be Deleted. ',DASH,ANSI_RESET);

	    IF ASK_CONFIRM THEN

		DELETE_CURRENT;

	    IF TEST.PRIMARY <> TITLE THEN

	    BEGIN

		{ +
		Look through the list to see what remains of this primary.
		- }
		REMAINING_PRI	:= FALSE;
		REMAINING_SEC	:= FALSE;

		DEF_CURRENT	:= DEF_HEAD;

		REPEAT

		    IF (
		    (DEF_CURRENT^.PRIMARY = SAVE.PRIMARY)
		    AND
		    (DEF_CURRENT^.PRINUM = SAVE.PRINUM)
		    ) THEN

		    BEGIN

			IF DEF_CURRENT^.OBJECT_TYPE = PRI THEN

			BEGIN

			    REMAINING_PRI	:= TRUE;
			    DEF_REM_PRI		:= DEF_CURRENT;

			END

			ELSE IF DEF_CURRENT^.OBJECT_TYPE = SEC THEN

			    REMAINING_SEC	:= TRUE;

		    END;

		    INCR_CURRENT;

		UNTIL (REMAINING_PRI AND REMAINING_SEC) OR (DEF_CURRENT = NIL);

		IF (
		(REMAINING_PRI)
		AND
		(NOT REMAINING_SEC)
		) THEN

		BEGIN

		    WRITELN (CRLF,SHIFT,ANSI_REVERSE,DASH,
		    ' No more Secondaries with this Primary, deleting Primary. ',
		    DASH,ANSI_RESET);

		    DEF_CURRENT		:= DEF_REM_PRI;
		    DELETE_CURRENT;
		    NO_MORE_PRI		:= TRUE;

		    DELAY (3.0);

		END

		ELSE IF (
		(NOT REMAINING_PRI)
		AND
		(REMAINING_SEC)
		) THEN

		    { +
		    BUGCHECK!!
		    - }
		    LIB$SIGNAL (EDF$_INTSWERR,1,32,0)

		ELSE IF (
		(NOT REMAINING_PRI)
		AND
		(NOT REMAINING_SEC)
		) THEN

		BEGIN

		    WRITELN (CRLF,SHIFT,ANSI_REVERSE,DASH,
		    ' This Primary Section has now been entirely Deleted. ',
		    DASH,ANSI_RESET);
		    NO_MORE_PRI		:= TRUE;

		    DELAY (2.0);

		END

		ELSE IF (
		(REMAINING_PRI)
		AND
		(REMAINING_SEC)
		) THEN

		BEGIN

		    CLEAR (SCREEN);

		    WRITELN (SHIFT,TAB,TAB,ANSI_REVERSE,DASH,
		    ' Resulting Primary Section ',
		    DASH,ANSI_RESET,CRLF);

		    OPEN	(FDL_DEST,SYS$OUTPUT_NAME,NEW);
		    REWRITE	(FDL_DEST);

		    SHOW_PRIMARY_SECTION (SAVE);

		    CLOSE (FDL_DEST);

		END;

		TEST.PRIMARY		:= SAVE.PRIMARY;
		TEST.PRINUM		:= SAVE.PRINUM;

		IF NO_MORE_PRI THEN

		    CYCLE	:= FALSE

		ELSE

		    CYCLE	:= ASK_CONT_WITH_PRI;

	    END	{ IF TEST.PRIMARY <> TITLE }

	    ELSE

		CYCLE	:= FALSE;

	END;	{ WHILE CYCLE DO }

    END		{ IF TRUE DEF_HEAD <> DEF_TAIL }

    ELSE

    BEGIN

	WRITELN (
	SHIFT,ANSI_REVERSE,DASH,' The Current Definition is Empty. ',DASH,ANSI_RESET);

	DELAY (3.0);

    END;	{ IF FALSE DEF_HEAD <> DEF_TAIL }

END;	{ DELETE_FDL_LINE }

{ ++

MODIFY_FDL_LINE -- Modify an extant line_object.

This routine lets the user view and change the contents of a particular
line_object in the Definition Linked List.

CALLING SEQUENCE:

MODIFY_FDL_LINE;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT:
The Definition Linked List

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$OUTPUT:
The Definition Linked List

ROUTINES CALLED:

none

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE MODIFY_FDL_LINE;

VAR
    TEST	: LINE_OBJECT;
    SAVE	: LINE_OBJECT;
    CYCLE	: BOOLEAN;
    FOUND_IT	: BOOLEAN;

BEGIN

    { +
    If the Definition Linked List is not empty, then do it, else skip it.
    - }
    IF DEF_HEAD <> DEF_TAIL THEN

    BEGIN

	SAVE.STRING.DSC$W_LENGTH	:= 0;
	SAVE.STRING.DSC$A_POINTER	:= NIL;
	SAVE.COMMENT.DSC$W_LENGTH	:= 0;
	SAVE.COMMENT.DSC$A_POINTER	:= NIL;

	TEST.STRING.DSC$W_LENGTH	:= 0;
	TEST.STRING.DSC$A_POINTER	:= NIL;
	TEST.COMMENT.DSC$W_LENGTH	:= 0;
	TEST.COMMENT.DSC$A_POINTER	:= NIL;

	{ +
	These routines will only return if an existing line_object has been given.
	If 'EXTANT_ONLY' is specified.
	- }
	ASK_TEST_PRIMARY (TEST,EXTANT_ONLY);

	CYCLE	:= TRUE;

	WHILE CYCLE DO

	BEGIN

	    ASK_TEST_SECONDARY (TEST,EXTANT_ONLY);

	    FOUND_IT	:= FIND_OBJECT (
					TEST.OBJECT_TYPE,TEST.PRIMARY,TEST.PRINUM,
					TEST.SECONDARY,TEST.SECNUM
					);

	    SAVE	:= DEF_CURRENT^;

	    { +
	    Setup to display definition on the terminal.
	    - }
	    OPEN	(FDL_DEST,SYS$OUTPUT_NAME,NEW);
	    REWRITE	(FDL_DEST);

	    SHOW_CUR_PRI_SEC (INCLUDING_VALUE);

	    CLOSE	(FDL_DEST);

	    TEST	:= SAVE;

	    ASK_TEST_SECONDARY_VALUE (TEST);

	    MAKE_SCRATCH;

	    DEF_SCRATCH^	:= TEST;

	    IF DEF_SCRATCH^.PRIMARY = TITLE THEN

		DEF_SCRATCH^.OBJECT_TYPE	:= PRI

	    ELSE

		DEF_SCRATCH^.OBJECT_TYPE	:= SEC;

	    INSERT_IN_ORDER (REPLACE_OBJ);

	    CLEAR (SCREEN);

	    WRITELN (SHIFT,TAB,TAB,ANSI_REVERSE,DASH,
	    ' Resulting Primary Section ',
	    DASH,ANSI_RESET,CRLF);

	    OPEN	(FDL_DEST,SYS$OUTPUT_NAME,NEW);
	    REWRITE	(FDL_DEST);

	    SHOW_PRIMARY_SECTION (SAVE);

	    CLOSE (FDL_DEST);

	    TEST	:= SAVE;

	    CYCLE	:= ASK_CONT_WITH_PRI;

	END;	{ WHILE CYCLE DO }

    END		{ IF TRUE DEF_HEAD <> DEF_TAIL }

    ELSE

    BEGIN

	WRITELN (
	SHIFT,ANSI_REVERSE,DASH,' The Current Definition is Empty. ',DASH,ANSI_RESET);

	DELAY (3.0);

    END;	{ IF FALSE DEF_HEAD <> DEF_TAIL }

END;	{ MODIFY_FDL_LINE }

{ ++

HELP_PROC -- Prompt for help and process it.

This routine interfaces to the LBR$OUTPUT_HELP routine to access the
help library.

CALLING SEQUENCE:

HELP_PROC;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

The help library: SYS$LIBRARY:EDF.HLB

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$OUTPUT: (through lib$put_output)

ROUTINES CALLED:

LBR$OUTPUT_HELP

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE HELP_PROC;

BEGIN

    { +
    Call the Librarian's help routine that will prompt the user for any
    additional information.
    - }
    STATUS	:= LBR$OUTPUT_HELP (
				    LIB$PUT_OUTPUT_PTR,
				    LINE_WIDTH,
				    0,
				    EDFHLP_STRING,
				    0,
				    LIB$GET_INPUT_PTR
				    );

    { +
    Show what the problem is.
    - }
    IF NOT ODD (STATUS) THEN

	LIB$SIGNAL (STATUS,0,0,0);

END;	{ HELP_PROC }

{ ++

REDESIGN_SCRIPT_PROC -- Redesign a definition.

This routine allows old definitions to done over.

CALLING SEQUENCE:

REDESIGN_SCRIPT_PROC;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

none

ROUTINES CALLED:

INDEXED_REDESIGN
SEQUENTIAL_DESIGN
RELATIVE_DESIGN

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE REDESIGN_SCRIPT_PROC;

BEGIN

    { +
    Check for a definition that has more than an Ident.
    - }
    IF (
    (DEF_HEAD <> DEF_TAIL)
    OR
    (DEF_HEAD^.PRIMARY <> IDENT)
    ) THEN

    BEGIN

	{ +
	See what type of file the definition is now.
	1st, find the line_object that tells that.
	- }
	IF FIND_OBJECT (SEC,FILE$,0,ORGANIZATION,0) THEN

	    DESIGN_ORG	:= DEF_CURRENT^.QUALIFIER

	ELSE

	    DESIGN_ORG	:= SEQUENTIAL;

	{ +
	The redesign of Seq and Rel is actually a new design.
	- }
	IF DESIGN_ORG = INDEXED THEN

	BEGIN

	    INDEXED_REDESIGN;

	END

	ELSE

	BEGIN

	    WRITELN (SHIFT,ANSI_REVERSE,DASH,
	    ' Only Indexed Files can be Redesigned; use Design. ',
	    DASH,ANSI_RESET);

	    DELAY (4.0);

	END;	{ IF FALSE DESIGN_ORG = INDEXED }

    END	{ IF TRUE (DEF_HEAD <> DEF_TAIL) OR (DEF_HEAD^.PRIMARY <> IDENT) }

    ELSE

    BEGIN

	{ +
	Slap the user's wrist.
	- }
	WRITELN (SHIFT,ANSI_REVERSE,DASH,
	' A Null or Ident-only Definition cannot be Redesigned; use Design. ',
	DASH,ANSI_RESET);

	DELAY (4.0);

    END; { IF FALSE (DEF_HEAD <> DEF_TAIL) OR (DEF_HEAD^.PRIMARY <> IDENT) }

END;	{ REDESIGN_SCRIPT_PROC }

{ ++

OPTIMIZE_SCRIPT_PROC -- Optimize extant definitions.

This routine allows old definitions to modified and optimized.

CALLING SEQUENCE:

OPTIMIZE_SCRIPT_PROC;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

none

ROUTINES CALLED:

none

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE OPTIMIZE_SCRIPT_PROC;

VAR
    AN_KEY_FOUND	: BOOLEAN;

BEGIN

    IF ANALYSIS_SPECIFIED THEN

    BEGIN

	AN_KEY_FOUND	:= FALSE;

	POINT_AT_ANALYSIS;

	DEF_CURRENT	:= DEF_HEAD;

	REPEAT

	    IF DEF_CURRENT^.PRIMARY = ANALYSIS_OF_KEY THEN

		AN_KEY_FOUND	:= TRUE;

	    INCR_CURRENT;

	UNTIL (AN_KEY_FOUND = TRUE) OR (DEF_CURRENT = NIL);

	POINT_AT_DEFINITION;

	IF AN_KEY_FOUND THEN

	BEGIN

	    OPTIMIZING	:= TRUE;
	    REDESIGN_SCRIPT_PROC;

	END

	ELSE

	BEGIN

	    WRITELN (SHIFT,
	    'The Analysis File must contain ANALYSIS_OF_KEY primary sections.');
	    WRITELN (SHIFT,
	    'The ANALYZE/RMS_FILE/FDL DCL command produces Analysis Files.');
	    CLEAR (PAUSE);

	END;

    END

    ELSE

    BEGIN

	WRITELN (SHIFT,
	'An Input Analysis File is necessary for Optimizing Keys.');
	WRITELN (SHIFT,
	'Use the /ANALYSIS qualifier when starting the FDL Editor.');
	CLEAR (PAUSE);

    END;

    OPTIMIZING	:= FALSE;

END;	{ OPTIMIZE_SCRIPT_PROC }

{ ++

DESIGN_SCRIPT_PROC -- Specify a brand new FDL definition.

This routine controls the user's session when he's producing a new definition.

CALLING SEQUENCE:

DESIGN_SCRIPT_PROC;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

???

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

none

ROUTINES CALLED:

none

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE DESIGN_SCRIPT_PROC;

BEGIN

    { +
    See what kind of file the user wants.
    - }
    ASK_DESIGN_ORG;

    { +
    Proceed only if the user wants to.
    - }
    IF WARN_OF_ERASE THEN

    BEGIN

	INIT_DEF;

	CASE DESIGN_ORG OF
    
	    SEQUENTIAL :	SEQUENTIAL_DESIGN;
	    RELATIVE :		RELATIVE_DESIGN;
	    INDEXED :		INDEXED_DESIGN;
    
	OTHERWISE
    
	    { +
	    BUGCHECK!!
	    - }
	    LIB$SIGNAL (EDF$_INTSWERR,1,33,0);
    
	END;	{ CASE }

    END;	{ IF TRUE CLEAR_OK }

END;		{ DESIGN_SCRIPT_PROC }

{ ++

INVOKE_SCRIPT -- Start up a series of questions.

This routine dispatches to the script procedures.

CALLING SEQUENCE:

INVOKE_SCRIPT;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SCRIPT_OPTION
SYS$INPUT_ERROR
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT_ERROR
TEMP_FULL_PROMPT

ROUTINES CALLED:

OPTIMIZE_SCRIPT_PROC
DESIGN_SCRIPT_PROC

ROUTINE VALUE:

none

SIGNALS:

EDF$_INTSWERR - if bugcheck

SIDE EFFECTS:

none

-- }

PROCEDURE INVOKE_SCRIPT;

BEGIN

    { +
    Reset so 1st (DCL) script only gets done once.
    - }
    FIRST_SCRIPT	:= ZERO_SCRIPT;

    { +
    Prompt for the desired script if we don't already have one. (from DCL)
    - }
    IF SCRIPT_OPTION = ZERO_SCRIPT THEN

    BEGIN

	{ +
	See which script the user wants.
	- }
	ASK_SCRIPT;

    END		{ IF TRUE SCRIPT_OPTION = ZERO_SCRIPT }

    ELSE

    BEGIN

	CLEAR (SCREEN);
	WRITE (SHIFT,TAB,TAB,ANSI_REVERSE,DASH);

	CASE SCRIPT_OPTION OF

	    DESIGN_FDL :	WRITE (' Design');
	    OPTIMIZE_FDL :	WRITE (' Optimize');
	    REDESIGN_FDL :	WRITE (' Redesign');

	OTHERWISE

	    { +
	    BUGCHECK!!
	    - }
	    LIB$SIGNAL (EDF$_INTSWERR,1,34,0);

	END;	{ CASE }

	WRITELN (' Script ',DASH,ANSI_RESET,CRLF);

    END;	{ IF FALSE SCRIPT_OPTION = ZERO_SCRIPT }

    CASE SCRIPT_OPTION OF

	DESIGN_FDL :	DESIGN_SCRIPT_PROC;
	OPTIMIZE_FDL :	OPTIMIZE_SCRIPT_PROC;
	REDESIGN_FDL :	REDESIGN_SCRIPT_PROC;

    OTHERWISE

	{ +
	BUGCHECK!!
	- }
	LIB$SIGNAL (EDF$_INTSWERR,1,35,0);

    END;	{ CASE }

END;	{ INVOKE_SCRIPT }

    { End of file: SRC$:EDFFUNCS.PAS }
