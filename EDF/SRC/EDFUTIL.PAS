{ ++
    		FILE: SRC$:EDFUTIL.PAS - Pascal include file to implement
		utility procedures for EDF.

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

		V03-002	KFH0002		Ken Henderson		2 April 1982
			Modified INSERT_IN_ORDER to not
			start at DEF_HEAD if it was already
			at the correct place.

		V03-001	KFH0001		Ken Henderson		23-Mar-1982
			Modified EDF$RESET_SCROLL to not
			reset the scrolling region unless
			it has been set.

-- }

{ ++

EDF$RESET_SCROLL -- Reset an ANSI terminal's scroll region.

This routine will put the scroll region back to full screen.
It also clears graphics mode.
It is a Global routine, which is called by the exit handler as well.

CALLING SEQUENCE:

EDF$RESET_SCROLL;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

LINE_ONE
LINES_PER_PAGE

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

STATUS
SYS$OUTPUT: - the scroll region is reset, and possibly graphics mode reset

ROUTINES CALLED:

LIB$SET_SCROLL

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE EDF$RESET_SCROLL;

BEGIN

    { +
    Clear graphics mode if this is a Regis device.
    - }
    IF REGIS THEN

	WRITELN (ESCAPE,'\');

    { +
    Now make the scroll region from top to bottom - if it was ever set.
    - }
    IF SCROLLING_SET THEN

	STATUS	:= LIB$SET_SCROLL (LINE_ONE,LINES_PER_PAGE);

    IF FILE_CREATED THEN

	{ +
	Announce that the file has been created.
	- }
	WRITELN (CRLF,CRLF,SHIFT,'Created:',CRLF,SHIFT,
RES_OUTPUT_FILENAME_DESC.DSC$A_POINTER^:RES_OUTPUT_FILENAME_DESC.DSC$W_LENGTH);

END;	{ EDF$RESET_SCROLL }

{ ++

SETUP_DESC -- Initialize a string descriptor

This routine will set up a string desc.

CALLING SEQUENCE:

SETUP_DESC (DESC);

INPUT PARAMETERS:

NUMBER

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

PROCEDURE SETUP_DESC (VAR DESC : DESCRIPTOR);

BEGIN

    DESC.DSC$B_DTYPE	:= DSC$K_DTYPE_T;
    DESC.DSC$B_CLASS	:= DSC$K_CLASS_D;
    DESC.DSC$A_POINTER	:= NIL;
    DESC.DSC$W_LENGTH	:= 0;

END;	{ SETUP_DESC }

{ ++

SETUP_KEY_LENGTH -- Setup the active key variables.

This routine will set up active_key_length and active_key_fill.

CALLING SEQUENCE:

SETUP_KEY_LENGTH;

INPUT PARAMETERS:

NUMBER

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

PROCEDURE SETUP_KEY_LENGTH;

BEGIN

    IF ACTIVE_KEY > 99 THEN

    BEGIN

	ACTIVE_KEY_LENGTH	:= 3;
	ACTIVE_KEY_FILL[1]	:= NULL_CHAR;
	ACTIVE_KEY_FILL[2]	:= NULL_CHAR;

    END	{ IF TRUE ACTIVE_KEY > 99 }

    ELSE IF ACTIVE_KEY > 9 THEN

    BEGIN

	ACTIVE_KEY_LENGTH	:= 2;
	ACTIVE_KEY_FILL[1]	:= ' ';
	ACTIVE_KEY_FILL[2]	:= NULL_CHAR;

    END	{ IF TRUE ACTIVE_KEY > 9 }

    ELSE

    BEGIN

	ACTIVE_KEY_LENGTH	:= 1;
	ACTIVE_KEY_FILL[1]	:= ' ';
	ACTIVE_KEY_FILL[2]	:= ' ';

    END;	{ IF FALSE ACTIVE_KEY > 9 }

END;	{ SETUP_KEY_LENGTH }

{ ++

CHECK_WITHIN_LIMITS -- Signal if value is not within limits.

This routine will signal EDF$_BADVALUE if the the value isn't within the
specified limits (inclusive).

CALLING SEQUENCE:

CHECK_WITH_LIMITS (LOW_LIMIT,VARIABLE,HIGH_LIMIT);

INPUT PARAMETERS:

NUMBER

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

EDF$_BADVALUE if the value isn't with the limits

SIDE EFFECTS:

none

-- }

PROCEDURE CHECK_WITHIN_LIMITS (LOW_LIMIT, VARIABLE, HIGH_LIMIT : INTEGER);

BEGIN

    IF (
    (VARIABLE < LOW_LIMIT)
    OR
    (VARIABLE > HIGH_LIMIT)
    ) THEN

	LIB$SIGNAL (EDF$_BADVALUE,0,0,0);

END;	{ CHECK_WITHIN_LIMITS }

{ ++

NUM_LEN -- Calculate the field width of an integer.

This routine will return the number of characters an integer will take up
when printed.

CALLING SEQUENCE:

field-width	:= NUM_LEN (NUMBER);

INPUT PARAMETERS:

NUMBER

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

none

ROUTINES CALLED:

none

ROUTINE VALUE:

The field width

SIGNALS:

none

SIDE EFFECTS:

none

-- }

FUNCTION NUM_LEN (
		    NUMBER	: INTEGER
		    ) : INTEGER;

VAR
    TEST_VAR	: INTEGER;
    TEST_LEN	: INTEGER;

BEGIN

    IF NUMBER = 0 THEN

	{ +
	Just plug a width of 1 if the number is 0.
	- }
	NUM_LEN			:= 1

    ELSE

    BEGIN

	{ +
	Set the function value according to the magnitude of the number.
	- }
	TEST_VAR		:= 1000000000;
	TEST_LEN		:= 10;
    
	REPEAT
    
	    IF ABS (NUMBER) < TEST_VAR THEN
    
		TEST_LEN	:= TEST_LEN - 1;
    
	    TEST_VAR		:= TEST_VAR DIV 10;
    
	UNTIL ABS (NUMBER) >= TEST_VAR;
    
	{ +
	Allow for a - sign if negative.
	- }
	IF NUMBER < 0 THEN
    
	    TEST_LEN		:= TEST_LEN + 1;

	{ +
	Now stuff the function value.
	- }
	NUM_LEN			:= TEST_LEN;
    
    END;	{ IF FALSE NUMBER = 0 }

END;	{ NUM_LEN }

{ ++

CLEAR -- Clear a designated area of the screen.

This routine clears a specific area on the screen and leaves the cursor there.
It bypasses screwing up non-CRT terminals.

CALLING SEQUENCE:

CLEAR (DESTINATION);

INPUT PARAMETERS:

DESTINATION

IMPLICIT INPUTS:

PROMPT_LINE
LINE_ONE

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$OUTPUT:

ROUTINES CALLED:

LIB$ERASE_PAGE
LIB$ERASE_LINE

ROUTINE VALUE:

none

SIGNALS:

EDF$_INTSWERR - if bugcheck

SIDE EFFECTS:

The selected lines on the screen are cleared (unless hardcopy).

-- }

PROCEDURE CLEAR (
		DESTINATION : WHERE
		);

BEGIN

    { +
    All this stuff affects only video terminals.
    - }
    IF VIDEO_TERMINAL THEN

	CASE DESTINATION OF
    
	    SCREEN :

		BEGIN

		    { +
		    The following sequence of junk to the screen
		    is overkill to make sure the titles don't
		    jump around. (interaction of Pascal I/O and
		    screen package I/O...)
		    - }
		    IF REGIS THEN
		
			WRITELN (
			ESCAPE,'Pp;S(E);',
			ESCAPE,'\');

		    STATUS	:= LIB$ERASE_PAGE (LINE_ONE,COL_ONE);
		    WRITELN (' ');
		    STATUS	:= LIB$SET_CURSOR (LINE_ONE,COL_ONE);

		END;	{ SCREEN }

	    LOWER_AREA :

	    BEGIN

		IF REGIS THEN

		BEGIN

		    WRITELN (
		    ESCAPE,'Pp','P[27,320];V(W(I0,S1,E,S[,479]))[+767];',
		    ESCAPE,'\');

		    STATUS	:= LIB$SET_CURSOR (PROMPT_LINE,COL_ONE);

		END

		ELSE

		    STATUS	:= LIB$ERASE_PAGE (LOWER_LINE,COL_ONE);

	    END;

	    IF_FULL_PROMPT :	IF FULL_PROMPT OR TEMP_FULL_PROMPT THEN

		BEGIN

		    IF TEMP_FULL_PROMPT THEN

			DELAY (1.3);

		    { +
		    The following sequence of junk to the screen
		    is overkill to make sure the titles don't
		    jump around. (interaction of Pascal I/O and
		    screen package I/O...)
		    - }

		    IF REGIS THEN

			WRITELN (
			ESCAPE,'Pp;S(E);',
			ESCAPE,'\');

		    STATUS	:= LIB$ERASE_PAGE (LINE_ONE,COL_ONE);
		    WRITELN (' ');
		    STATUS	:= LIB$SET_CURSOR (LINE_ONE,COL_ONE);

		END;	{ IF_FULL_PROMPT }

	    PAUSE :		ASK_RETURN;

	OTHERWISE
    
	    { +
	    BUGCHECK!
	    - }
	    LIB$SIGNAL (EDF$_INTSWERR,1,42,0);
    
	END;		{ CASE }
	    
END;	{ CLEAR }

{ ++

DELAY -- Wait a length of time.

This routine sits in a test loop for a specified amount of time.

CALLING SEQUENCE:

DELAY (DELTA);

INPUT PARAMETERS:

DELTA

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

none

ROUTINES CALLED:

FOR$SECNDS

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

The program's execution is effectively stopped until the time expires.

-- }

PROCEDURE DELAY; { REFER TO THE PREVIOUS FORWARD DECL'S FOR ARGUMENT DEFS }

BEGIN

    { +
    Save the current time.
    - }
    ORIG_TIME	:= FOR$SECNDS (0.0);

    { +
    Spin our wheels until the time has run out.
    - }
    REPEAT

	{ NOP }

    UNTIL FOR$SECNDS (ORIG_TIME) >= DELTA;

END;	{ DELAY }

{ ++

CVT_INT_PRI -- Routine to find out what the primary is.

This routine will convert an integer to the primary type.

CALLING SEQUENCE:

PRIMARY_VAR	:= CVT_INT_PRI (INT);

INPUT PARAMETERS:

INT

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

none

ROUTINES CALLED:

none

ROUTINE VALUE:

PRIMARY_VAR

SIGNALS:

none

SIDE EFFECTS:

none

-- }

FUNCTION CVT_INT_PRI (INT : INTEGER) : PRIMARY_TYPE;

BEGIN

    WITH INTEGER_PRIMARY DO

    BEGIN

	{ +
	Select the integer type variant and stuff it.
	- }
	PWHICH		:= NOPRIM;
	NUM		:= INT;

	{ +
	Now select the enumerated type variant and get it.
	- }
	PWHICH		:= PRIM;
	CVT_INT_PRI	:= ENUM;

    END;

END;	{ CVT_INT_PRI }

{ ++

CVT_INT_SEC -- Routine to find out what the secondary is.

This routine will convert an integer to the secondary type.

CALLING SEQUENCE:

SECONDARY_VAR	:= CVT_INT_SEC (INT);

INPUT PARAMETERS:

INT

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

none

ROUTINES CALLED:

none

ROUTINE VALUE:

SECONDARY_VAR

SIGNALS:

none

SIDE EFFECTS:

none

-- }

FUNCTION CVT_INT_SEC (INT : INTEGER) : SECONDARY_TYPE;

BEGIN

    WITH INTEGER_SECONDARY DO

    BEGIN

	{ +
	Select the integer type variant and stuff it.
	- }
	SWHICH		:= NOSECO;
	NUM		:= INT;

	{ +
	Now select the enumerated type variant and get it.
	- }
	SWHICH		:= SECO;
	CVT_INT_SEC	:= ENUM;

    END;

END;	{ CVT_INT_SEC }

{ ++

CVT_INT_QUAL -- Routine to find out what the qualifier is.

This routine will convert an integer to the qualifier type.

CALLING SEQUENCE:

QUALIFIER_VAR	:= CVT_INT_QUAL (INT);

INPUT PARAMETERS:

INT

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

none

ROUTINES CALLED:

none

ROUTINE VALUE:

QUALIFIER_VAR

SIGNALS:

none

SIDE EFFECTS:

none

-- }

FUNCTION CVT_INT_QUAL (INT : INTEGER) : QUALIFIER_TYPE;

BEGIN

    WITH INTEGER_QUALIFIER DO

    BEGIN

	{ +
	Select the integer type variant and stuff it.
	- }
	QWHICH		:= NOQUAL;
	NUM		:= INT;

	{ +
	Now select the enumerated type variant and get it.
	- }
	QWHICH		:= QUAL;
	CVT_INT_QUAL	:= ENUM;

    END;

END;	{ CVT_INT_QUAL }

{ ++

PARSE_INPUT -- Routine to parse input string.

This routine will look at the chosen LIB$TPARSE table.

CALLING SEQUENCE:

PARSE_INPUT (KEY_TABLE_PTR,STATE_TABLE_PTR,DEFAULT_OK,DEFAULT_VALUE);

INPUT PARAMETERS:

KEY_TABLE_PTR
STATE_TABLE_PTR

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

INPUT_VALUE

ROUTINES CALLED:

none

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE PARSE_INPUT (
    			KEY_TABLE_PTR	: LONG_PTR;
    			STATE_TABLE_PTR	: LONG_PTR;
			DEFAULT_OK	: BOOLEAN;
			DEFAULT_VALUE	: INTEGER
    			);

BEGIN

    { +
    Get the input from the terminal.
    - }
    SETUP_DESC (INPUT_DESC);
    READLN (INPUT_STRING);
    WRITELN (CRLF);

    { +
    Cut off trailing blanks and make it upper case.
    - }
    STR$TRIM (INPUT_DESC,INPUT_STRING);
    STR$UPCASE (INPUT_DESC,INPUT_DESC);

    { +
    See if the answer was defaulted, and if it's allowed to be.
    - }
    IF INPUT_DESC.DSC$W_LENGTH = 0 THEN

	IF DEFAULT_OK THEN

	    INPUT_VALUE		:= DEFAULT_VALUE

	ELSE

	BEGIN

	    STR$FREE1_DX (INPUT_DESC);
	    LIB$SIGNAL (EDF$_NODEFAULT,0,0,0);

	END

    ELSE

    BEGIN

	{ +
	See if it's valid and get it's value.
	- }
	PARAM_BLOCK.TPA$L_STRINGPTR^	:= INPUT_DESC.DSC$A_POINTER^;
	PARAM_BLOCK.TPA$L_STRINGCNT	:= INPUT_DESC.DSC$W_LENGTH;

	STATUS	:= LIB$TPARSE (
				PARAM_BLOCK,
				STATE_TABLE_PTR,
				KEY_TABLE_PTR
				);

	INPUT_VALUE	:= PARAM_BLOCK.TPA$L_PARAM;
	INPUT_NUMBER	:= PARAM_BLOCK.TPA$L_NUMBER;

	{ +
	Even status (low bit clear) means failure.
	- }
	IF NOT ODD (STATUS) THEN

	BEGIN

	    STR$FREE1_DX (INPUT_DESC);

	    IF PARAM_BLOCK.TPA$L_OPTIONS[TPA$V_AMBIG] THEN

		LIB$SIGNAL (EDF$_AMBIG,0,0,0)

	    ELSE

		LIB$SIGNAL (EDF$_BADSYNTAX,0,0,0);

	END;

    END;    { IF NOT INPUT_DESC.DSC$W_LENGTH = 0 }

    { +
    Give up the string's Virt Mem
    - }
    STR$FREE1_DX (INPUT_DESC);

END;	{ PARSE_INPUT }

{ ++

NUMBER_INPUT -- Routine to get a number from the input string.

This routine will return the integer typed.

CALLING SEQUENCE:

NUMBER_INPUT (NUM_VALUE,DEFAULT_OK,DEFAULT_VALUE);

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

NUM_VALUE

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

PROCEDURE NUMBER_INPUT (
    			VAR NUM_VALUE	: INTEGER;
			DEFAULT_OK	: BOOLEAN;
			DEFAULT_VALUE	: INTEGER
    			);

BEGIN

    { +
    Get the input from the terminal.
    - }
    SETUP_DESC (INPUT_DESC);
    READLN (INPUT_STRING);
    WRITELN (CRLF);

    { +
    Cut off trailing blanks and make it upper case.
    - }
    STR$TRIM (INPUT_DESC,INPUT_STRING);
    STR$UPCASE (INPUT_DESC,INPUT_DESC);

    { +
    See if the answer was defaulted, and if it's allowed to be.
    - }
    IF INPUT_DESC.DSC$W_LENGTH = 0 THEN

	IF DEFAULT_OK THEN

	    NUM_VALUE		:= DEFAULT_VALUE

	ELSE

	BEGIN

	    STR$FREE1_DX (INPUT_DESC);
	    LIB$SIGNAL (EDF$_NODEFAULT,0,0,0);

	END

    ELSE

    BEGIN

	{ +
	Convert it to an integer.
	- }
	STATUS	:= OTS$CVT_TI_L (INPUT_DESC,NUM_VALUE);
    
	{ +
	Even status (low bit clear) means failure.
	- }
	IF NOT ODD (STATUS) THEN
    
	BEGIN
    
	    STR$FREE1_DX (INPUT_DESC);
	    LIB$SIGNAL (EDF$_BADSYNTAX,0,0,0);
    
	END;
    
    END;    { IF NOT INPUT_DESC.DSC$W_LENGTH = 0 }

    { +
    Give up the string's Virt Mem
    - }
    STR$FREE1_DX (INPUT_DESC);

END;	{ NUMBER_INPUT }

{ ++

MAKE_SCRATCH -- Create a new peice of dynamic memory and init it.

This routine creates a new Line_object, and sets its links to nil.

CALLING SEQUENCE:

MAKE_SCRATCH;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

DEF_SCRATCH

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

PROCEDURE MAKE_SCRATCH;

BEGIN

    { +
    Allocate some dynamic memory.
    - }
    NEW (DEF_SCRATCH);

    { +
    Set up the links.
    - }
    DEF_SCRATCH^.FORE	:= NIL;
    DEF_SCRATCH^.BACK	:= NIL;

END;	{ MAKE_SCRATCH }

{ ++

CURRENT_GT_TEST -- Compare def_current with test.

This function has the boolean value of the whether or not DEF_CURRENT is
greater than TEST.

CALLING SEQUENCE:

test-val	:= CURRENT_GT_TEST (TEST,SCOPE);

INPUT PARAMETERS:

SCOPE

IMPLICIT INPUTS:

DEF_CURRENT

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

none

ROUTINES CALLED:

none

ROUTINE VALUE:

True if DEF_CURRENT > TEST, false if not.

SIGNALS:

none

SIDE EFFECTS:

none

-- }

FUNCTION CURRENT_GT_TEST (
			    TEST	: LINE_OBJECT;
			    SCOPE	: COMPARE_TYPE
			    ) : BOOLEAN;

BEGIN

    { +
    Just do a boolean assignment.
    - }
    CASE SCOPE OF

	EXACT :

	BEGIN

	    CURRENT_GT_TEST	:= FALSE;

	    IF
	    (PRI_SEQ[DEF_CURRENT^.PRIMARY] > PRI_SEQ[TEST.PRIMARY])
	    THEN

		CURRENT_GT_TEST	:= TRUE;

	    IF
	    (PRI_SEQ[DEF_CURRENT^.PRIMARY] = PRI_SEQ[TEST.PRIMARY])
	    AND
	    (DEF_CURRENT^.PRINUM > TEST.PRINUM)
	    THEN

		CURRENT_GT_TEST	:= TRUE;

	    IF
	    (PRI_SEQ[DEF_CURRENT^.PRIMARY] = PRI_SEQ[TEST.PRIMARY])
	    AND
	    (DEF_CURRENT^.PRINUM = TEST.PRINUM)
	    AND
	    (DEF_CURRENT^.SECONDARY > TEST.SECONDARY)
	    THEN

		CURRENT_GT_TEST	:= TRUE;

	    IF
	    (PRI_SEQ[DEF_CURRENT^.PRIMARY] = PRI_SEQ[TEST.PRIMARY])
	    AND
	    (DEF_CURRENT^.PRINUM = TEST.PRINUM)
	    AND
	    (DEF_CURRENT^.SECONDARY = TEST.SECONDARY)
	    AND
	    (DEF_CURRENT^.SECNUM > TEST.SECNUM)
	    THEN

		CURRENT_GT_TEST	:= TRUE;

	END;

	PRIMARY :

	BEGIN

	    CURRENT_GT_TEST	:= FALSE;

	    IF(
	    PRI_SEQ[DEF_CURRENT^.PRIMARY] > PRI_SEQ[TEST.PRIMARY])
	    THEN

		CURRENT_GT_TEST	:= TRUE;

	    IF
	    (PRI_SEQ[DEF_CURRENT^.PRIMARY] = PRI_SEQ[TEST.PRIMARY])
	    AND
	    (DEF_CURRENT^.PRINUM > TEST.PRINUM)
	    THEN

		CURRENT_GT_TEST	:= TRUE;

	END;

    OTHERWISE

	{ +
	BUGCHECK!!
	- }
	LIB$SIGNAL (EDF$_INTSWERR,1,43,0);

    END;	{ CASE }

END;	{ CURRENT_GT_TEST }

{ ++

CURRENT_LT_TEST -- Compare def_current and test.

This function has the boolean value of the whether or not TEST greater than
DEF_CURRENT.

CALLING SEQUENCE:

test-val	:= CURRENT_LT_TEST (TEST,SCOPE);

INPUT PARAMETERS:

SCOPE

IMPLICIT INPUTS:

DEF_CURRENT

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

none

ROUTINES CALLED:

none

ROUTINE VALUE:

True if DEF_CURRENT < TEST, false if not.

SIGNALS:

none

SIDE EFFECTS:

none

-- }

FUNCTION CURRENT_LT_TEST (
			    TEST	: LINE_OBJECT;
			    SCOPE	: COMPARE_TYPE
			    ) : BOOLEAN;

BEGIN

    { +
    Just do a boolean assignment.
    - }
    CASE SCOPE OF

	EXACT :

	BEGIN

	    CURRENT_LT_TEST	:= FALSE;

	    IF(
	    PRI_SEQ[DEF_CURRENT^.PRIMARY] < PRI_SEQ[TEST.PRIMARY])
	    THEN

		CURRENT_LT_TEST	:= TRUE;

	    IF
	    (PRI_SEQ[DEF_CURRENT^.PRIMARY] = PRI_SEQ[TEST.PRIMARY])
	    AND
	    (DEF_CURRENT^.PRINUM < TEST.PRINUM)
	    THEN

		CURRENT_LT_TEST	:= TRUE;

	    IF
	    (PRI_SEQ[DEF_CURRENT^.PRIMARY] = PRI_SEQ[TEST.PRIMARY])
	    AND
	    (DEF_CURRENT^.PRINUM = TEST.PRINUM)
	    AND
	    (DEF_CURRENT^.SECONDARY < TEST.SECONDARY)
	    THEN

		CURRENT_LT_TEST	:= TRUE;

	    IF
	    (PRI_SEQ[DEF_CURRENT^.PRIMARY] = PRI_SEQ[TEST.PRIMARY])
	    AND
	    (DEF_CURRENT^.PRINUM = TEST.PRINUM)
	    AND
	    (DEF_CURRENT^.SECONDARY = TEST.SECONDARY)
	    AND
	    (DEF_CURRENT^.SECNUM < TEST.SECNUM)
	    THEN

		CURRENT_LT_TEST	:= TRUE;

	END;

	PRIMARY :

	BEGIN

	    CURRENT_LT_TEST	:= FALSE;

	    IF(
	    PRI_SEQ[DEF_CURRENT^.PRIMARY] < PRI_SEQ[TEST.PRIMARY])
	    THEN

		CURRENT_LT_TEST	:= TRUE;

	    IF
	    (PRI_SEQ[DEF_CURRENT^.PRIMARY] = PRI_SEQ[TEST.PRIMARY])
	    AND
	    (DEF_CURRENT^.PRINUM < TEST.PRINUM)
	    THEN

		CURRENT_LT_TEST	:= TRUE;

	END;

    OTHERWISE

	{ +
	BUGCHECK!!
	- }
	LIB$SIGNAL (EDF$_INTSWERR,1,44,0);

    END;	{ CASE }

END;	{ CURRENT_LT_TEST }

{ ++

CURRENT_EQ_TEST -- Compare def_current and test.

This function has the boolean value of the whether or not TEST is the
same as DEF_CURRENT.

CALLING SEQUENCE:

test-val	:= CURRENT_EQ_TEST (TEST,SCOPE);

INPUT PARAMETERS:

SCOPE

IMPLICIT INPUTS:

DEF_CURRENT

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

none

ROUTINES CALLED:

none

ROUTINE VALUE:

True if DEF_CURRENT = TEST, false if not.

SIGNALS:

none

SIDE EFFECTS:

none

-- }

FUNCTION CURRENT_EQ_TEST (
			    TEST	: LINE_OBJECT;
			    SCOPE	: COMPARE_TYPE
			    ) : BOOLEAN;

BEGIN

    { +
    Just do a boolean assignment.
    - }
    CASE SCOPE OF

	EXACT :

	    CURRENT_EQ_TEST	:= (

	    (TEST.OBJECT_TYPE = DEF_CURRENT^.OBJECT_TYPE)
	    AND
	    (TEST.PRIMARY = DEF_CURRENT^.PRIMARY)
	    AND
	    (TEST.PRINUM = DEF_CURRENT^.PRINUM)
	    AND
	    (TEST.SECONDARY = DEF_CURRENT^.SECONDARY)
	    AND
	    (TEST.SECNUM = DEF_CURRENT^.SECNUM)

	    );

	PRIMARY :

	    CURRENT_EQ_TEST	:= (

	    (TEST.PRIMARY = DEF_CURRENT^.PRIMARY)
	    AND
	    (TEST.PRINUM = DEF_CURRENT^.PRINUM)

	    );

    OTHERWISE

	{ +
	BUGCHECK!!
	- }
	LIB$SIGNAL (EDF$_INTSWERR,1,45,0);

    END;	{ CASE }

END;	{ CURRENT_EQ_TEST }

{ ++

INSERT_BEFORE_CURRENT -- Link the DEF_SCRATCH line_object into the list.

This routine adds DEF_SCRATCH into the list just before DEF_CURRENT.

CALLING SEQUENCE:

INSERT_BEFORE_CURRENT;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

DEF_SCRATCH
DEF_CURRENT
DEF_HEAD

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

PROCEDURE INSERT_BEFORE_CURRENT;

BEGIN

    { +
    Make it the new head, if we're adding it before the old head.
    - }
    IF DEF_CURRENT = DEF_HEAD THEN

	DEF_HEAD	:= DEF_SCRATCH;

    { +
    Update the fore and back pointers.
    - }
    DEF_PRED		:= DEF_CURRENT^.BACK;
    DEF_SCRATCH^.FORE	:= DEF_CURRENT;
    DEF_SCRATCH^.BACK	:= DEF_PRED;

    IF DEF_PRED <> NIL THEN

	DEF_PRED^.FORE	:= DEF_SCRATCH;

    DEF_CURRENT^.BACK	:= DEF_SCRATCH;

    { +
    Leave looking at the just inserted line_object.
    - }
    DEF_CURRENT		:= DEF_SCRATCH;

END;	{ INSERT_BEFORE_CURRENT }

{ ++

INSERT_AT_CURRENT -- Link the DEF_SCRATCH line_object into the list.

This routine adds DEF_SCRATCH into the list at DEF_CURRENT.

CALLING SEQUENCE:

INSERT_AT_CURRENT;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

DEF_SCRATCH
DEF_CURRENT
DEF_HEAD

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

PROCEDURE INSERT_AT_CURRENT;

BEGIN

    { +
    Make new head or tail, if we're replacing this one.
    - }
    IF DEF_CURRENT = DEF_HEAD THEN

	DEF_HEAD	:= DEF_SCRATCH;

    IF DEF_CURRENT = DEF_TAIL THEN

	DEF_TAIL	:= DEF_SCRATCH;

    { +
    Substitute the links to def_current with links to def_scratch.
    - }
    DEF_PRED		:= DEF_CURRENT^.BACK;
    DEF_SUCC		:= DEF_CURRENT^.FORE;
    DEF_SCRATCH^.FORE	:= DEF_CURRENT^.FORE;
    DEF_SCRATCH^.BACK	:= DEF_CURRENT^.BACK;

    IF DEF_PRED <> NIL THEN

	DEF_PRED^.FORE	:= DEF_SCRATCH;

    IF DEF_SUCC <> NIL THEN

	DEF_SUCC^.BACK	:= DEF_SCRATCH;

    { +
    Get rid of the old def_current, and point def_current to the new king.
    - }
    DISPOSE (DEF_CURRENT);

    DEF_CURRENT		:= DEF_SCRATCH;

END;	{ INSERT_AT_CURRENT }

{ ++

INSERT_AFTER_CURRENT -- Link the DEF_SCRATCH line_object into the list.

This routine adds DEF_SCRATCH to the list after DEF_CURRENT.

CALLING SEQUENCE:

INSERT_AFTER_CURRENT;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

DEF_CURRENT
DEF_SCRATCH
DEF_TAIL

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

PROCEDURE INSERT_AFTER_CURRENT;

BEGIN

    { +
    Make it the new tail if we're adding it after the old tail.
    - }
    IF DEF_CURRENT = DEF_TAIL THEN

	DEF_TAIL	:= DEF_SCRATCH;

    { +
    Update the fore and back pointers.
    - }
    DEF_SUCC		:= DEF_CURRENT^.FORE;
    DEF_SCRATCH^.FORE	:= DEF_SUCC;
    DEF_SCRATCH^.BACK	:= DEF_CURRENT;
    DEF_CURRENT^.FORE	:= DEF_SCRATCH;

    IF DEF_SUCC <> NIL THEN

	DEF_SUCC^.BACK	:= DEF_SCRATCH;

    { +
    Leave looking at the just inserted line_object.
    - }
    DEF_CURRENT		:= DEF_SCRATCH;

END;	{ INSERT_AFTER_CURRENT }

{ ++

INCR_CURRENT -- Bump DEF_CURRENT pointer one.

This routine makes DEF_CURRENT point to the next line_object in the list,
as long as it won't fall off the end.

CALLING SEQUENCE:

INCR_CURRENT;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

DEF_CURRENT

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

none

ROUTINES CALLED:

LIB$SIGNAL

ROUTINE VALUE:

none

SIGNALS:

EDF$_INTSWERR - if falling off the end

SIDE EFFECTS:

none

-- }

PROCEDURE INCR_CURRENT;

BEGIN

    { +
    .FORE points to the next line_object in the list.
    - }
    IF DEF_CURRENT = NIL THEN

	{ +
	BUGCHECK!!
	- }
	LIB$SIGNAL (EDF$_INTSWERR,1,46,0)

    ELSE

	DEF_CURRENT	:= DEF_CURRENT^.FORE;

END;	{ INCR_CURRENT }

{ ++

DECR_CURRENT -- Bump back the DEF_CURRENT pointer one.

This routine points DEF_CURRENT to the previous line_object in the list,
as long as it won't run off the end.

CALLING SEQUENCE:

DECR_CURRENT;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

DEF_CURRENT

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

none

ROUTINES CALLED:

LIB$SIGNAL

ROUTINE VALUE:

none

SIGNALS:

EDF$_INTSWERR - if falling off end

SIDE EFFECTS:

none

-- }

PROCEDURE DECR_CURRENT;

BEGIN

    { +
    .BACK points to the previous line_object in the list.
    - }
    IF DEF_CURRENT = NIL THEN

	{ +
	BUGCHECK!!
	- }
	LIB$SIGNAL (EDF$_INTSWERR,1,47,0)

    ELSE

	DEF_CURRENT	:= DEF_CURRENT^.BACK;

END;	{ DECR_CURRENT }

{ ++

NEW_IDENT_LINE -- Make a new Ident and stuff it into the definition.

This routine gets the date and time from the system and makes a new Ident
Line_object, and puts it into the definition linked list.

IT ASSUMES THAT THE LIST IS COMPLETELY EMPTY!!!

CALLING SEQUENCE:

NEW_IDENT_LINE;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

DEF_SCRATCH
IDENT_STRING

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

DEF_SCRATCH
DEF_HEAD
DEF_TAIL
DEF_CURRENT

ROUTINES CALLED:

LIB$DATE_TIME
OTS$SCOPY_DXDX
MAKE_SCRATCH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE NEW_IDENT_LINE;

VAR
    DATE_STRING	: STRING20;
    I		: INTEGER;

BEGIN

    { +
    Create a place for the Ident to go.
    - }
    MAKE_SCRATCH;

    { +
    Get system date and time to put into IDENT line.
    - }
    STATUS	:= LIB$DATE_TIME (DATE_STRING);

    { +
    Now, copy it into the ident string.
    - }
    FOR I := 1 TO 20 DO

	IDENT_STRING[I]		:= DATE_STRING[I];

    { +
    Put an IDENT primary at the head of the linked list.
    - }
    WITH DEF_SCRATCH^ DO

    BEGIN

	NEW (STRING.DSC$A_POINTER);

	STRING.DSC$W_LENGTH	:= IDENT_STRING_LENGTH;
	OBJECT_TYPE		:= PRI;
	PRIMARY			:= IDENT;
	PRINUM			:= 0;
	SECONDARY		:= DUMMY_SECONDARY$;
	SECNUM			:= 0;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;

	{ +
	OTS$SCOPY_DXDX is just defined differently than LIB$SCOPY_DXDX
	to let us put a packed array string into it.
	- }
	STATUS		:= OTS$SCOPY_DXDX (IDENT_STRING,STRING);

    END;	{ WITH DEF_SCRATCH^ }

    { +
    Make the just created line_object the head (and only) one
    - }
    DEF_CURRENT		:= DEF_SCRATCH;
    DEF_HEAD		:= DEF_SCRATCH;
    DEF_TAIL		:= DEF_SCRATCH;

END;	{ NEW_IDENT_LINE }

{ ++

DELETE_CURRENT -- Unlink DEF_CURRENT from the list and kill it.

This routine removes the line_object pointed to by DEF_CURRENT from the list.

CALLING SEQUENCE:

DELETE_CURRENT;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

DEF_CURRENT
DEF_TAIL
DEF_HEAD
DEF_SCRATCH

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

none

ROUTINES CALLED:

EXTRACT_CURRENT

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE DELETE_CURRENT;

BEGIN

    IF DEF_CURRENT^.PRIMARY = TITLE THEN

    BEGIN

	{ +
	TITLE is always the very 1st line_object in the list.
	- }
	IF DEF_CURRENT^.FORE = NIL THEN

	BEGIN

	    DISPOSE (DEF_CURRENT);
	    NEW_IDENT_LINE;

	END	{ IF TRUE DEF_CURRENT^.FORE = NIL }

	ELSE

	BEGIN

	    DEF_HEAD		:= DEF_CURRENT^.FORE;
	    DEF_HEAD^.BACK	:= NIL;
	    DISPOSE (DEF_CURRENT);
	    DEF_CURRENT		:= DEF_HEAD;

	END;	{ IF FALSE DEF_CURRENT^.FORE = NIL }

    END		{ IF TRUE DEF_CURRENT^.PRIMARY = TITLE }

    ELSE

    BEGIN

    { +
    Make new tail, if we're deleting old tail.
    - }
    IF (DEF_CURRENT <> NIL) AND (DEF_CURRENT = DEF_TAIL) THEN

	DEF_TAIL	:= DEF_CURRENT^.BACK;

    { +
    Make new head, if we're deleting old head.
    - }
    IF (DEF_CURRENT <> NIL) AND (DEF_CURRENT = DEF_HEAD) THEN

	DEF_HEAD	:= DEF_CURRENT^.FORE;

    { +
    Update fore and back pointers.
    - }
    DEF_PRED		:= DEF_CURRENT^.BACK;
    DEF_SUCC		:= DEF_CURRENT^.FORE;

    IF DEF_PRED <> NIL THEN

	DEF_PRED^.FORE	:= DEF_SUCC;

    IF DEF_SUCC <> NIL THEN

	DEF_SUCC^.BACK	:= DEF_PRED;

    WITH DEF_CURRENT^ DO

    BEGIN

	IF STRING.DSC$A_POINTER <> NIL THEN

	    DISPOSE (STRING.DSC$A_POINTER);

	IF COMMENT.DSC$A_POINTER <> NIL THEN

	    DISPOSE (COMMENT.DSC$A_POINTER);

    END;	{ WITH DEF_CURRENT^ DO }

    DISPOSE (DEF_CURRENT);

    IF DEF_SUCC <> NIL THEN

	DEF_CURRENT	:= DEF_SUCC

    ELSE IF DEF_PRED <> NIL THEN

	DEF_CURRENT	:= DEF_PRED

    ELSE

	NEW_IDENT_LINE;

    END;	{ IF FALSE DEF_CURRENT^.PRIMARY = TITLE }

END;	{ DELETE_CURRENT }

{ ++

INIT_DEF -- Clear out the definition and setup for a new one.

This routine makes room to put a brand new definition in the linked list.

CALLING SEQUENCE:

INIT_DEF;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

DEF_CURRENT
DEF_HEAD

ROUTINES CALLED:

none

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE INIT_DEF;

BEGIN

    { +
    Clear out the list starting at the beginning (if not already empty).
    - }
    DEF_CURRENT	:= DEF_HEAD;

    IF DEF_CURRENT <> NIL THEN

    BEGIN

	REPEAT

	    DELETE_CURRENT;

	UNTIL DEF_HEAD = DEF_TAIL;

	IF DEF_CURRENT <> NIL THEN

	    DELETE_CURRENT;

    END;

END;	{ INIT_DEF }

{ ++

INSERT_IN_ORDER -- Put DEF_SCRATCH into the list in proper order.

This routine places the line_object pointed to by def_scratch in the definition
linked list in its proper place.

CALLING SEQUENCE:

INSERT_IN_ORDER (COLLISION_ACTION);

INPUT PARAMETERS:

COLLISION_ACTION

IMPLICIT INPUTS:

DEF_CURRENT
DEF_TAIL
DEF_HEAD
DEF_SCRATCH

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

PROCEDURE INSERT_IN_ORDER (
			    COLLISION_ACTION	: COLLISION_ACTION_TYPE
			    );

VAR
    BACKUP_WORKED	: BOOLEAN;

BEGIN

    { +
    1st, a little conditioning.
    - }
    IF (
    (DEF_SCRATCH^.OBJECT_TYPE = PRI)
    AND
    (DEF_SCRATCH^.PRIMARY <> TITLE)
    ) THEN

    BEGIN

	DEF_SCRATCH^.STRING.DSC$A_POINTER	:= NIL;
	DEF_SCRATCH^.STRING.DSC$W_LENGTH	:= 0;

    END;

    DEF_SCRATCH^.FORE	:= NIL;
    DEF_SCRATCH^.BACK	:= NIL;

    { +
    Now, find the proper place. Start looking at the previous line_object.
    - }
    BACKUP_WORKED	:= FALSE;

    IF DEF_CURRENT <> NIL THEN

	IF DEF_CURRENT^.BACK <> NIL THEN

	BEGIN

	    DECR_CURRENT;

	    WHILE NOT (
	    (CURRENT_GT_TEST(DEF_SCRATCH^,EXACT))
	    OR
	    (CURRENT_EQ_TEST(DEF_SCRATCH^,EXACT))
	    OR
	    (DEF_CURRENT^.FORE = NIL)
	    ) DO

		INCR_CURRENT;

	    BACKUP_WORKED	:= (
				(
				    (CURRENT_LT_TEST(DEF_SCRATCH^,EXACT))
				    AND
				    (DEF_CURRENT^.FORE = NIL)
				)
				OR
				    (CURRENT_EQ_TEST(DEF_SCRATCH^,EXACT))
	    			);

	END;	{ IF DEF_CURRENT^.BACK <> NIL }

    IF NOT BACKUP_WORKED THEN

    BEGIN

	{ +
	The quick look didn't work, now scan the entire list.
	- }
	DEF_CURRENT	:= DEF_HEAD;

	WHILE NOT (
	(CURRENT_GT_TEST(DEF_SCRATCH^,EXACT))
	OR
	(CURRENT_EQ_TEST(DEF_SCRATCH^,EXACT))
	OR
	(DEF_CURRENT^.FORE = NIL)
	) DO

	    INCR_CURRENT;

    END;	{ IF NOT BACKUP_WORKED }

    { +
    Now insert it according to how it was (found).
    - }
    IF CURRENT_GT_TEST(DEF_SCRATCH^,EXACT) THEN

	INSERT_BEFORE_CURRENT

    ELSE IF CURRENT_EQ_TEST(DEF_SCRATCH^,EXACT) THEN

	CASE COLLISION_ACTION OF

	    REPLACE_OBJ :	INSERT_AT_CURRENT;
	    AFTER_OBJ :		INSERT_AFTER_CURRENT;
	    IGNORE_OBJ :	{ NOP } ;

	OTHERWISE

	    { +
	    BUGCHECK!!
	    - }
	    LIB$SIGNAL (EDF$_INTSWERR,1,48,0);

	END	{ CASE }

    ELSE IF DEF_CURRENT^.FORE = NIL THEN

    BEGIN

	DEF_TAIL	:= DEF_CURRENT;
    	INSERT_AFTER_CURRENT;

    END

    ELSE

	{ +
	BUGCHECK!!
	- }
	LIB$SIGNAL (EDF$_INTSWERR,1,49,0);

END;	{ INSERT_IN_ORDER }

{ ++

FIND_OBJECT -- Locate a line_object in the definition list.

This function returns with DEF_CURRENT pointing to the desired line
object - if it finds it, in which case it's function value is true.

CALLING SEQUENCE:

BOOLEAN_VAR := FIND_OBJECT (LINE_OBJECT_TYPE,PRIMARY,PRINUM,SECONDARY,SECNUM);

INPUT PARAMETERS:

OBJECT_TYPE
PRIMARY
PRINUM
SECONDARY
SECNUM

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

DEF_CURRENT

ROUTINES CALLED:

none

ROUTINE VALUE:

TRUE/FALSE DEPENDING ON FOUND STATUS

SIGNALS:

none

SIDE EFFECTS:

none

-- }

FUNCTION FIND_OBJECT (
			OBJ_TYP		: LINE_OBJECT_TYPE;
			PRIM		: PRIMARY_TYPE;
			PRIMNUM		: INTEGER;
			SECO		: SECONDARY_TYPE;
			SECONUM		: INTEGER
			) : BOOLEAN;

VAR
    TEST	: LINE_OBJECT;
    FOUND_IT	: BOOLEAN;
    PAST_IT	: BOOLEAN;

BEGIN

    { +
    Stuff test object for comparison routine.
    - }
    TEST.OBJECT_TYPE	:= OBJ_TYP;
    TEST.PRIMARY	:= PRIM;
    TEST.PRINUM		:= PRIMNUM;
    TEST.SECONDARY	:= SECO;
    TEST.SECNUM		:= SECONUM;

    { +
    Start looking at head of list.
    - }
    DEF_CURRENT		:= DEF_HEAD;
    FOUND_IT		:= FALSE;
    PAST_IT		:= FALSE;

    REPEAT

	FOUND_IT	:= CURRENT_EQ_TEST (TEST,EXACT);
	PAST_IT		:= CURRENT_GT_TEST (TEST,EXACT);

	IF NOT FOUND_IT THEN

	    INCR_CURRENT;

    UNTIL (FOUND_IT) OR (PAST_IT) OR (DEF_CURRENT = NIL);

    { +
    Function value indicates whether we found it or not.
    - }
    FIND_OBJECT			:= FOUND_IT;

END;	{ FIND_OBJECT }

{ ++

POINT_AT_DEFINITION -- Setup the list pointers.

This routine makes the list pointers point at the Definition Linked List.

CALLING SEQUENCE:

POINT_AT_DEFINITION;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

DEF_HEAD
DEF_TAIL
DEF_ANL_HEAD
DEF_ANL_TAIL
POINTING_DIRECTION

ROUTINES CALLED:

none

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

the current list is the definition list

-- }

PROCEDURE POINT_AT_DEFINITION;

BEGIN

    IF POINTING_DIRECTION <> DEFINITION_LIST THEN

    BEGIN

	DEF_ANL_HEAD		:= DEF_HEAD;
	DEF_ANL_TAIL		:= DEF_TAIL;
	DEF_HEAD		:= DEF_SAVE_HEAD;
	DEF_TAIL		:= DEF_SAVE_TAIL;

	POINTING_DIRECTION	:= DEFINITION_LIST;

    END;

END;	{ POINT_AT_DEFINITION }

{ ++

POINT_AT_ANALYSIS -- Setup the list pointers.

This routine makes the list pointers point at the Analysis Linked List.

CALLING SEQUENCE:

POINT_AT_ANALYSIS;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

DEF_HEAD
DEF_TAIL
DEF_ANL_HEAD
DEF_ANL_TAIL
POINTING_DIRECTION

ROUTINES CALLED:

none

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

the current list is the analysis list

-- }

PROCEDURE POINT_AT_ANALYSIS;

BEGIN

    IF POINTING_DIRECTION <> ANALYSIS_LIST THEN

    BEGIN

	DEF_SAVE_HEAD		:= DEF_HEAD;
	DEF_SAVE_TAIL		:= DEF_TAIL;
	DEF_HEAD		:= DEF_ANL_HEAD;
	DEF_TAIL		:= DEF_ANL_TAIL;

	POINTING_DIRECTION	:= ANALYSIS_LIST;

    END;

END;	{ POINT_AT_ANALYSIS }

{ ++

STRING_VALUED - Is this secondary string valued?

This routine returns the boolean value depending on it type.

CALLING SEQUENCE:

BOOLEAN	:= STRING_VALUED (SECONDARY);

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

DEF_HEAD
DEF_TAIL
DEF_ANL_HEAD
DEF_ANL_TAIL
POINTING_DIRECTION

ROUTINES CALLED:

none

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:


-- }

FUNCTION STRING_VALUED (INPUT_SECONDARY : SECONDARY_TYPE): BOOLEAN;

BEGIN

    STRING_VALUED	:=

    (INPUT_SECONDARY IN

    [ BACKUP$, CREATION$, EXPIRATION$, REVISION$, NAME, DEFAULT_NAME,
    NAME$, DEVICE ]);

END;	{ STRING_VALUED }

{ ++

NUMBER_VALUED - Is it a number type?

This routine returns true if the secondary has a number value.

CALLING SEQUENCE:

BOOLEAN	:= NUMBER_VALUED (SECONDARY);

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

DEF_HEAD
DEF_TAIL
DEF_ANL_HEAD
DEF_ANL_TAIL
POINTING_DIRECTION

ROUTINES CALLED:

none

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:


-- }

FUNCTION NUMBER_VALUED (INPUT_SECONDARY : SECONDARY_TYPE) : BOOLEAN;

BEGIN

    NUMBER_VALUED	:=

    (INPUT_SECONDARY IN

    [ ALLOCATION, BUCKET_SIZE, EXTENSION, MAGTAPE_BLOCK_SIZE,
    MAX_RECORD_NUMBER, PROLOGUE, REVISION, CONTROL_FIELD_SIZE,
    SIZE, ALLOCATION$, BUCKET_SIZE$, EXTENSION$,
    VOLUME$, DATA_AREA, DATA_FILL, INDEX_AREA, INDEX_FILL,
    LEVEL1_INDEX_AREA, SEG_LENGTH, SEG_POSITION, 
    DATA_KEY_COMPRESSION$, DATA_RECORD_COMPRESSION$,
    INDEX_COMPRESSION$, RECLAIMED_SPACE, DATA_SPACE_OCCUPIED,
    DATA_FILL$, DATA_RECORD_COUNT, DELETIONS, DUPLICATES_PER_SIDR,
    MEAN_DATA_LENGTH, MEAN_INDEX_LENGTH, DEPTH, INDEX_FILL$,
    GLOBAL_BUFFER_COUNT, RANDOM_ACCESSES, RANDOM_INSERTS,
    SEQUENTIAL_ACCESSES, INDEX_SPACE_OCCUPIED ]);

END;	{ NUMBER_VALUED }

{ ++

QUALIFIER_VALUED - Does it have a qualifier value?

This routine returns true if the secondary has a qualifier value.

CALLING SEQUENCE:

BOOLEAN	:= QUALIFIER_VALUED (SECONDARY);

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

DEF_HEAD
DEF_TAIL
DEF_ANL_HEAD
DEF_ANL_TAIL
POINTING_DIRECTION

ROUTINES CALLED:

none

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:


-- }

FUNCTION QUALIFIER_VALUED (INPUT_SECONDARY : SECONDARY_TYPE) : BOOLEAN;

BEGIN

    QUALIFIER_VALUED	:=

    (INPUT_SECONDARY IN

    [ SOURCE, TARGET, ORGANIZATION, AUDIT_TRAIL, RECOVERY_UNIT,
    CARRIAGE_CONTROL, FORMAT, SEG_TYPE ]);

END;	{ QUALIFIER_VALUED }

{ ++

SWITCH_VALUED - Is it a boolean?

This routine returns true if the secondary is a boolean.

CALLING SEQUENCE:

BOOLEAN	:= SWITCH_VALUED (SECONDARY);

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

DEF_HEAD
DEF_TAIL
DEF_ANL_HEAD
DEF_ANL_TAIL
POINTING_DIRECTION

ROUTINES CALLED:

none

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:


-- }

FUNCTION SWITCH_VALUED (INPUT_SECONDARY : SECONDARY_TYPE) : BOOLEAN;

BEGIN

    SWITCH_VALUED	:=

    (INPUT_SECONDARY IN

    [ BACKUP, BEST_TRY_CONTIGUOUS, CONTIGUOUS, DELETE_ON_CLOSE,
    DIRECTORY_ENTRY, ERASE_ON_DELETE, MAGTAPE_REWIND,
    DATA_KEY_COMPRESSION, DATA_RECORD_COMPRESSION, INDEX_COMPRESSION,
    MAGTAPE_CURRENT_POSITION, MAXIMIZE_VERSION, READ_CHECK,
    EXACT_POSITIONING$, SUBMIT_ON_CLOSE, SUPERSEDE, TRUNCATE_ON_CLOSE,
    WRITE_CHECK, AFTER_IMAGE, BEFORE_IMAGE, BLOCK_SPAN,
    BEST_TRY_CONTIGUOUS$, CONTIGUOUS$, CHANGES, DUPLICATES, NULL_KEY ]);

END;	{ SWITCH_VALUED }

{ ++

INTERPRET_QUALIFIER -- Store an enumerated value according to the qualifier.

This routine gets the qualifier value from FDL$GL_QUALIFIER and figures out
which enumerated value to store.

CALLING SEQUENCE:

QUAL_VAR := INTERPRET_QUALIFIER;

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

The enumerated value that represents the qualifier from FDL$PARSE.

SIGNALS:

none

SIDE EFFECTS:

none

-- }

FUNCTION INTERPRET_QUALIFIER : QUALIFIER_TYPE;

BEGIN

    { +
    See which secondary we have.
    - }
    CASE FDL$GL_SECONDARY^ OF

	POSITION$ :

	    { +
	    Interpret the POSITION qualifiers using the values coming
	    back from FDL$PARSE.
	    - }
	    CASE FDL$GL_QUALIFIER^ OF
    
		FDL$C_ANYPOS :	INTERPRET_QUALIFIER := ANY_CYLINDER;
		FDL$C_CLUSPOS :	INTERPRET_QUALIFIER := CLUSTER;
		FDL$C_CYLPOS :	INTERPRET_QUALIFIER := CYLINDER;
		FDL$C_FIDPOS :	INTERPRET_QUALIFIER := FILE_ID;
		FDL$C_FNMPOS :	INTERPRET_QUALIFIER := FILE_NAME;
		FDL$C_LOGPOS :	INTERPRET_QUALIFIER := LOGICAL;
		FDL$C_NOPOS :	INTERPRET_QUALIFIER := NOPOS;
		FDL$C_VIRPOS :	INTERPRET_QUALIFIER := VIRTUAL;
    
	    OTHERWISE
    
		{ +
		BUGCHECK!!
		- }
		LIB$SIGNAL (EDF$_INTSWERR,1,50,0);
    
	    END;	{ CASE FDL$GL_QUALIFIER^ }

	ORGANIZATION :

	    CASE FDL$GL_QUALIFIER^ OF

		FAB$C_IDX :	INTERPRET_QUALIFIER := INDEXED;
		FAB$C_REL :	INTERPRET_QUALIFIER := RELATIVE;
		FAB$C_SEQ :	INTERPRET_QUALIFIER := SEQUENTIAL;

	    OTHERWISE

		{ +
		BUGCHECK!!
		- }
		LIB$SIGNAL (EDF$_INTSWERR,1,51,0);

	    END;	{ CASE FDL$GL_QUALIFIER^ }

	SOURCE, TARGET :

	    CASE FDL$GL_QUALIFIER^ OF

		FDL$C_IAS :	INTERPRET_QUALIFIER := IAS;
		FDL$C_RSTS :	INTERPRET_QUALIFIER := RSTSE;
		FDL$C_M	 :	INTERPRET_QUALIFIER := RSX11M;
		FDL$C_MPLUS :	INTERPRET_QUALIFIER := RSX11MPLUS;
		FDL$C_RT :	INTERPRET_QUALIFIER := RT11;
		FDL$C_TRAX :	INTERPRET_QUALIFIER := TRAX11;
		FDL$C_VMS :	INTERPRET_QUALIFIER := VAXVMS;

	    OTHERWISE

		{ +
		BUGCHECK!!
		- }
		LIB$SIGNAL (EDF$_INTSWERR,1,52,0);

	    END;	{ CASE FDL$GL_QUALIFIER^ }

	AUDIT_TRAIL :		{ NOP } ;

	RECOVERY_UNIT :		{ NOP } ;

	CARRIAGE_CONTROL :

	    CASE FDL$GL_QUALIFIER^ OF

		FDL$C_CR :	INTERPRET_QUALIFIER := CARRIAGE_RETURN;
		FDL$C_FTN :	INTERPRET_QUALIFIER := FORTRAN;
		FDL$C_NONE :	INTERPRET_QUALIFIER := NONE;
		FDL$C_PRINT :	INTERPRET_QUALIFIER := PRINT;

	    OTHERWISE

		{ +
		BUGCHECK!!
		- }
		LIB$SIGNAL (EDF$_INTSWERR,1,53,0);

	    END;	{ CASE FDL$GL_QUALIFIER^ }

	FORMAT :

	    CASE FDL$GL_QUALIFIER^ OF

		FAB$C_FIX :	INTERPRET_QUALIFIER := FIXED;
	        FAB$C_STM :	INTERPRET_QUALIFIER := STREAM;
		FAB$C_STMCR :	INTERPRET_QUALIFIER := STREAM_CR;
		FAB$C_STMLF :	INTERPRET_QUALIFIER := STREAM_LF;
		FAB$C_UDF :	INTERPRET_QUALIFIER := UNDEFINED;
		FAB$C_VAR :	INTERPRET_QUALIFIER := VARIABLE;
		FAB$C_VFC :	INTERPRET_QUALIFIER := VFC;

	    OTHERWISE

		{ +
		BUGCHECK!!
		- }
		LIB$SIGNAL (EDF$_INTSWERR,1,54,0);

	    END;	{ CASE FDL$GL_QUALIFIER^ }

	SEG_TYPE :

	    CASE FDL$GL_QUALIFIER^ OF

		XAB$C_BN2 :	INTERPRET_QUALIFIER := BIN2;
		XAB$C_BN4 :	INTERPRET_QUALIFIER := BIN4;
		XAB$C_PAC :	INTERPRET_QUALIFIER := DECIMAL;
		XAB$C_IN2 :	INTERPRET_QUALIFIER := INT2;
		XAB$C_IN4 :	INTERPRET_QUALIFIER := INT4;
		XAB$C_STG :	INTERPRET_QUALIFIER := STRING;

	    OTHERWISE

		{ +
		BUGCHECK!!
		- }
		LIB$SIGNAL (EDF$_INTSWERR,1,55,0);

	    END;	{ CASE FDL$GL_QUALIFIER^ }

    OTHERWISE

	INTERPRET_QUALIFIER	:= NOT_QUALIFIED;

    END	{ CASE FDL$GL_SECONDARY^ }

END;	{ INTERPRET_QUALIFIER }

{ ++

EDF$LINE_PARSED -- Action routine for FDL$PARSE routine.

This routine stores into the definition database the values from FDL$PARSE.

CALLING SEQUENCE:

Called from the FDL$PARSE routine.

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

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

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

DEF_CURRENT
DEF_TAIL
DEF_HEAD
DEF_SCRATCH
STATUS

ROUTINES CALLED:

MAKE_SCRATCH
LIB$SCOPY_DXDX
INTERPRET_QUALIFIER

ROUTINE VALUE:

Always 1 (for success).

SIGNALS:

none

SIDE EFFECTS:

none

-- }

FUNCTION EDF$LINE_PARSED : INTEGER;

VAR
    TEMP_BIT_ARRAY	: CTRL_ARRAY;

BEGIN

    { +
    This routine always succeeds.
    - }
    EDF$LINE_PARSED	:= 1;

    { +
    Create a new line object to be added to the list.
    - }
    MAKE_SCRATCH;

    { +
    First see if the list even exists.
    - }
    IF DEF_CURRENT = NIL	THEN

	{ +
	BUGCHECK!!
	- }
	LIB$SIGNAL (EDF$_INTSWERR,1,56,0);

    { +
    Get the flag word.
    - }
    TEMP_BIT_ARRAY		:= FDL$AB_CTRL^;

    { +
    Completely ignore a line if it's an IDENT, or if the Warning bit is set.
    - }
    IF ( NOT (
    ((TEMP_BIT_ARRAY [FDL$V_NEWPRI]) AND (FDL$GL_PRIMARY^ = IDENT))
    OR
    (TEMP_BIT_ARRAY [FDL$V_WARNING])
    )) THEN

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	Set the type of this line_object.
	- }
	IF TEMP_BIT_ARRAY [FDL$V_NEWPRI] THEN
    
	    OBJECT_TYPE	:= PRI
    
	ELSE
    
	    OBJECT_TYPE	:= SEC;
    
	{ +
	Check for a full line comment, as it is a 3rd object type.
	- }
	IF TEMP_BIT_ARRAY[FDL$V_LINECMT] THEN
    
	    OBJECT_TYPE	:= COM;
    
	{ +
	Store the comment string if a comment was detected.
	- }
	IF TEMP_BIT_ARRAY[FDL$V_COMMENT] OR TEMP_BIT_ARRAY[FDL$V_LINECMT] THEN
    
	BEGIN
    
	    { +
	    Allocate space for the string255 in the list.
	    - }
	    NEW (COMMENT.DSC$A_POINTER);
    
	    { +
	    Make the saved length equal to the passed length.
	    - }
	    COMMENT.DSC$W_LENGTH	:= FDL$AB_COMMENT^.DSC$W_LENGTH;
    
	    { +
	    Copy the string from FDL$PARSE's storage to the list's storage.
	    - }
	    STATUS	:= LIB$SCOPY_DXDX (FDL$AB_COMMENT^,COMMENT);
    
	END

	ELSE

	BEGIN

	    COMMENT.DSC$W_LENGTH	:= 0;
	    COMMENT.DSC$A_POINTER	:= NIL;

	END;	{ IF FALSE }
    
	{ +
	Store the string if it's an attribute with a string value.
	- }
	IF (
((NOT TEMP_BIT_ARRAY [FDL$V_NEWPRI]) AND (STRING_VALUED (FDL$GL_SECONDARY^)))
	OR
((NOT TEMP_BIT_ARRAY [FDL$V_NEWPRI]) AND (FDL$GL_SECONDARY^ = POSITION$))
	OR
((TEMP_BIT_ARRAY [FDL$V_NEWPRI]) AND (FDL$GL_PRIMARY^ = TITLE))
	) THEN
    
	    BEGIN
    
		{ +
		Allocate space for the string255 in the list.
		- }
		NEW (STRING.DSC$A_POINTER);
    
		{ +
		Make the saved length equal to the passed length.
		- }
		STRING.DSC$W_LENGTH	:= FDL$AB_STRING^.DSC$W_LENGTH;
    
		{ +
		Copy the string from FDL$PARSE's storage to the list's storage.
		- }
		STATUS	:= LIB$SCOPY_DXDX (FDL$AB_STRING^,STRING);
    
	    END

	    ELSE

	    BEGIN

		STRING.DSC$W_LENGTH	:= 0;
		STRING.DSC$A_POINTER	:= NIL;

	    END;	{ IF FALSE }
    
	{ +
	Now stuff the new line_object with the remaining data from FDL$PARSE.
	- }
	PRIMARY		:= FDL$GL_PRIMARY^;
	SECONDARY	:= FDL$GL_SECONDARY^;

	IF PRIMARY IN [ AREA, KEY ] THEN

	    PRINUM	:= FDL$GL_PRINUM^

	ELSE

	    PRINUM	:= 0;

	IF SECONDARY IN [ SEG_LENGTH, SEG_POSITION, SEG_TYPE ] THEN

	    SECNUM	:= FDL$GL_SECNUM^

	ELSE

	    SECNUM	:= 0;

	{ +
	Qualifiers values are more complicated, store the enumerated value instead.
	- }
	IF (
	(SECONDARY = MAGTAPE_PROTECTION)
	OR
	(SECONDARY = NULL_VALUE)
	) THEN

	BEGIN

	    { +
	    These two come back in a funny place.
	    - }
	    QUALIFIER	:= NOT_QUALIFIED;
	    NUMBER	:= FDL$GL_QUALIFIER^;

	END

	ELSE

	BEGIN

	    QUALIFIER	:= INTERPRET_QUALIFIER;
	    NUMBER	:= FDL$GL_NUMBER^;

	END;

	NUMTYPE		:= FDL$GL_NUMTYPE^;
    
	{ +
	Now store the other information coming back from FDL$PARSE.
	- }
	IF ODD (FDL$GL_SWITCH^) THEN
    
	    SWITCH	:= TRUE
    
	ELSE
    
	    SWITCH	:= FALSE;
    
	UIC_GROUP	:= FDL$GL_UIC_GROUP^;
	UIC_MEMBER	:= FDL$GL_UIC_MEMBER^;
	PROT_MASK	:= FDL$GL_PROTECTION^;
	FID1		:= FDL$GL_FID1^;
	FID2		:= FDL$GL_FID2^;
	FID3		:= FDL$GL_FID3^;

	{ +
	Now put def_scratch into the linked list. Depending upon whether
	we're inputting an FDL file or a analysis file.
	- }

	IF (
	(ANALYSIS_ONLY AND (PRIMARY IN [ ANALYSIS_OF_KEY, ANALYSIS_OF_AREA ]))
	OR
	((NOT ANALYSIS_ONLY) AND (NOT (PRIMARY IN [ ANALYSIS_OF_KEY,
	ANALYSIS_OF_AREA ])))
	) THEN

	    IF OBJECT_TYPE = COM THEN

		INSERT_IN_ORDER (AFTER_OBJ)

	    ELSE

		INSERT_IN_ORDER (IGNORE_OBJ);
    
    END;	{ IF NOT IDENT PRIMARY; ALSO WITH DEF_SCRATCH^ DO }

END;	{ EDF$LINE_PARSED }

    { End of file: SRC$:EDFUTIL.PAS }
