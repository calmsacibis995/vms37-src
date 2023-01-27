{ ++
    		FILE: SRC$:EDFSHOW.PAS - Pascal include file to implement
		display routines for EDF.

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

		V03-002	KFH0002		Ken Henderson		23-Mar-1982
			Reorderred the EDF$_INTSWERR numbers.

		V03-001	KFH0001		Ken Henderson		17-Mar-1982
			Modified SHOW_CURRENT to fix FT2 QARs
			440,449

-- }

{ ++

SHOW_PRIMARY -- Output the text string for the primary.

This routine outputs the primary keyword.

CALLING SEQUENCE:

SHOW_PRIMARY;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

DEF_CURRENT
PRIMARY_WIDTH

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

FDL_DEST

ROUTINES CALLED:

none

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

The text is shown on the terminal or put in the file. Wherever FDL_DEST points.

-- }

PROCEDURE SHOW_PRIMARY;

VAR
    TEMP_PRI	: PRIMARY_TYPE;

BEGIN

    WITH DEF_CURRENT^ DO

    BEGIN

	{ +
	Fetch the primary we're showing.
	- }
	TEMP_PRI	:= PRIMARY;
    
	{ +
	Output it, using the correct width.
	- }
	WRITE (FDL_DEST,TEMP_PRI:PRIMARY_WIDTH[TEMP_PRI]);
    
	{ +
	If it's one with a PRINUM, put that out too.
	- }
	IF TEMP_PRI IN [ ANALYSIS_OF_AREA, ANALYSIS_OF_KEY, AREA, KEY ] THEN
    
	    WRITE (FDL_DEST,' ',PRINUM:NUM_LEN(PRINUM));
    
	{ +
	If it's one with a string value, put that out too.
	- }
	IF TEMP_PRI IN [ IDENT, TITLE ] THEN
    
	    WRITE (FDL_DEST,TAB,STRING.DSC$A_POINTER^:STRING.DSC$W_LENGTH);

    END;	{ WITH DEF_CURRENT^ }

END;	{ SHOW_PRIMARY }

{ ++

SHOW_SECONDARY -- Output a text string for the secondary keyword.

This routine outputs a secondary keyword.

CALLING SEQUENCE:

SHOW_SECONDARY;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

DEF_CURRENT
SECONDARY_WIDTH
TAB

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

FDL_DEST

ROUTINES CALLED:

none

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

The secondary keyword is put into the file or onto the terminal. (FDL_DEST)

-- }

PROCEDURE SHOW_SECONDARY;

VAR
    TEMP_SEC	: SECONDARY_TYPE;

BEGIN

    WITH DEF_CURRENT^ DO

    BEGIN

	{ +
	Fetch the secondary.
	- }
	TEMP_SEC	:= SECONDARY;
    
	{ +
	BUGCHECK if we're showing a bad secondary.
	- }
	IF TEMP_SEC = DUMMY_SECONDARY$ THEN
    
	    LIB$SIGNAL (EDF$_INTSWERR,1,37,0);
    
	{ +
	Output the secondary if it's a simply structured one.
	- }
	IF NOT ( TEMP_SEC IN [ SEG_LENGTH, SEG_POSITION, SEG_TYPE ] ) THEN
    
	BEGIN
    
	    WRITE (FDL_DEST,TAB,TEMP_SEC:SECONDARY_WIDTH[TEMP_SEC]);
    
	    { +
	    Put out extra tabs to compensate for short secondaries.
	    - }
	    IF (
	    (TEMP_SEC = POSITION$)
	    AND
	    (NOT (QUALIFIER IN [ ANY_CYLINDER, NOPOS ]))
	    ) THEN

		WRITE (FDL_DEST,'    ')

	    ELSE IF SECONDARY_WIDTH[TEMP_SEC] < 8 THEN
    
		WRITE (FDL_DEST,TAB,TAB)
    
	    ELSE IF SECONDARY_WIDTH[TEMP_SEC] < 16 THEN
    
		WRITE (FDL_DEST,TAB);
    
	END
    
	ELSE
    
	{ +
	Here for the complicated secondaries: SEGn_xxx
	- }
	BEGIN
    
	    IF TEMP_SEC = SEG_LENGTH THEN
    
		WRITE (FDL_DEST,TAB,'SEG',SECNUM:1,'_LENGTH',TAB);
    
	    { +
	    Now do the same for the SEGn_POSITION secondary.
	    - }
	    IF TEMP_SEC = SEG_POSITION THEN
    
		WRITE (FDL_DEST,TAB,'SEG',SECNUM:1,'_POSITION',TAB);
    
	    { +
	    Ditto for SEGn_TYPE.
	    - }
	    IF TEMP_SEC = SEG_TYPE THEN
    
		WRITE (FDL_DEST,TAB,'TYPE',TAB,TAB);

{ +
SEGn_TYPE will be supported for V3B
- }

{		WRITE (FDL_DEST,TAB,'SEG',SECNUM:1,'_TYPE',TAB); }

	END;

    END;	{ WITH DEF_CURRENT^ }

END;	{ SHOW_SECONDARY }

{ ++

SHOW_QUALIFIER -- Output a text string for the qualifier keyword.

This routine outputs the qualifier keyword.

CALLING SEQUENCE:

SHOW_QUALIFIER;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

DEF_CURRENT
TAB

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

FDL_DEST

ROUTINES CALLED:

none

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

The keyword is put into the file or onto the terminal. (FDL_DEST)

-- }

PROCEDURE SHOW_QUALIFIER;

VAR
    TEMP_QUAL	: QUALIFIER_TYPE;

BEGIN

    { +
    Fetch the qualifier.
    - }
    TEMP_QUAL		:= DEF_CURRENT^.QUALIFIER;

    { +
    BUGCHECK if bad qualifier.
    - }
    IF TEMP_QUAL = NOT_QUALIFIED THEN

	LIB$SIGNAL (EDF$_INTSWERR,1,38,0);

    { +
    Output the qualifiers.
    - }
    CASE TEMP_QUAL OF

	ANY_CYLINDER :		WRITE (FDL_DEST,TAB,'any_cylinder');
	CLUSTER :		WRITE (FDL_DEST,'cluster');
	CYLINDER :		WRITE (FDL_DEST,'cylinder');
	FILE_ID :		WRITE (FDL_DEST,'file_ID');
	FILE_NAME :		WRITE (FDL_DEST,'file_name');
	LOGICAL :		WRITE (FDL_DEST,'logical');
	VIRTUAL :		WRITE (FDL_DEST,'virtual');
	NOPOS :			WRITE (FDL_DEST,TAB,'none');
	NO_TRAIL :		WRITE (FDL_DEST,TAB,'none');
	NO_RU :			WRITE (FDL_DEST,TAB,'none');
	NONE :			WRITE (FDL_DEST,TAB,'none');
	INDEXED :		WRITE (FDL_DEST,TAB,'indexed');
	RELATIVE :		WRITE (FDL_DEST,TAB,'relative');
	SEQUENTIAL :		WRITE (FDL_DEST,TAB,'sequential');
	ACCESSES :		WRITE (FDL_DEST,TAB,'accesses');
	ALL :			WRITE (FDL_DEST,TAB,'all');
	READS :			WRITE (FDL_DEST,TAB,'reads');
	WRITES :		WRITE (FDL_DEST,TAB,'writes');
	DURING_RU :		WRITE (FDL_DEST,TAB,'during_RU');
	RU_REQUIRED :		WRITE (FDL_DEST,TAB,'RU_required');
	CARRIAGE_RETURN :	WRITE (FDL_DEST,TAB,'carriage_return');
	FORTRAN :		WRITE (FDL_DEST,TAB,'FORTRAN');
	PRINT :			WRITE (FDL_DEST,TAB,'print');
	FIXED :			WRITE (FDL_DEST,TAB,'fixed');
	STREAM :		WRITE (FDL_DEST,TAB,'stream');
	STREAM_CR :		WRITE (FDL_DEST,TAB,'stream_CR');
	STREAM_LF :		WRITE (FDL_DEST,TAB,'stream_LF');
	UNDEFINED :		WRITE (FDL_DEST,TAB,'undefined');
	VARIABLE :		WRITE (FDL_DEST,TAB,'variable');
	VFC :			WRITE (FDL_DEST,TAB,'VFC');
	BIN2 :			WRITE (FDL_DEST,TAB,'bin2');
	BIN4 :			WRITE (FDL_DEST,TAB,'bin4');
	DECIMAL :		WRITE (FDL_DEST,TAB,'decimal');
	INT2 :			WRITE (FDL_DEST,TAB,'int2');
	INT4 :			WRITE (FDL_DEST,TAB,'int4');
	STRING :		WRITE (FDL_DEST,TAB,'string');
	IAS :			WRITE (FDL_DEST,TAB,'IAS');
	RSTSE :			WRITE (FDL_DEST,TAB,'RSTS/E');
	RSX11M :		WRITE (FDL_DEST,TAB,'RSX-11M');
	RSX11MPLUS :		WRITE (FDL_DEST,TAB,'RSX-11M-PLUS');
	RT11 :			WRITE (FDL_DEST,TAB,'RT-11');
	TRAX11 :		WRITE (FDL_DEST,TAB,'TRAX-11');
	VAXVMS :		WRITE (FDL_DEST,TAB,'VAX/VMS');

    OTHERWISE

	LIB$SIGNAL (EDF$_INTSWERR,1,39,0);

    END;	{ CASE }

END;	{ SHOW_QUALIFIER }

{ ++

SHOW_CURRENT -- Display (or output) the current line_object.

This routine outputs the textual representation of the line_object pointed
to by DEF_HEAD.

CALLING SEQUENCE:

SHOW_CURRENT (PLUS_VALUE);

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

DEF_CURRENT
TAB
DEST_IS_TERMINAL
LINES_PER_PAGE

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

FDL_DEST

ROUTINES CALLED:

SHOW_PRIMARY
SHOW_SECONDARY
SHOW_QUALIFIER
CLEAR
LIB$SIGNAL

ROUTINE VALUE:

none

SIGNALS:

EDF$_INTSWERR - if bugcheck

SIDE EFFECTS:

none

-- }

PROCEDURE SHOW_CURRENT (PLUS_VALUE : PLUS_VALUE_TYPE);

    PROCEDURE SHOW_PROT (PROTECTION : CTRL_ARRAY; FIELD_OFFSET : INTEGER);

    BEGIN

	IF PROTECTION[FIELD_OFFSET+EDF$V_NOREAD] THEN

	    WRITE (FDL_DEST,'R');

	IF PROTECTION[FIELD_OFFSET+EDF$V_NOWRITE] THEN

	    WRITE (FDL_DEST,'W');

	IF PROTECTION[FIELD_OFFSET+EDF$V_NOEXE] THEN

	    WRITE (FDL_DEST,'E');

	IF PROTECTION[FIELD_OFFSET+EDF$V_NODEL] THEN

	    WRITE (FDL_DEST,'D');

    END;	{ SHOW_PROT }

BEGIN

    { +
    If it's going to the terminal, shift it.
    - }
    IF DEST_IS_TERMINAL THEN

	WRITE (FDL_DEST,SHIFT);

    { +
    Write to FDL_DEST, according to the type of object it is.
    - }
    CASE DEF_CURRENT^.OBJECT_TYPE OF

	PRI :

	WITH DEF_CURRENT^ DO

	BEGIN

	    { +
	    Output the primary.
	    - }
	    SHOW_PRIMARY;

	    { +
	    Show only the primary if wanted.
	    - }
	    IF PLUS_VALUE = INCLUDING_VALUE THEN

		{ +
		If it has an end-of-line comment on it, output that also.
		- }
		IF (COMMENT.DSC$W_LENGTH > 0) THEN
    
		    WRITE (FDL_DEST,TAB,COMMENT.DSC$A_POINTER^:COMMENT.DSC$W_LENGTH);

	    { +
	    This actually does the QIO.
	    - }
	    WRITELN (FDL_DEST);

	END;	{ PRI }

	SEC :

	WITH DEF_CURRENT^ DO

	BEGIN

	    { +
	    Output the secondary.
	    - }
	    SHOW_SECONDARY;

	    { +
	    Don't show the value unless wanted.
	    - }
	    IF PLUS_VALUE = INCLUDING_VALUE THEN

	    BEGIN

		{ +
		If it's a string valued secondary, put the string out.
		- }
		IF STRING_VALUED (SECONDARY) THEN
    
		    WRITE (FDL_DEST,TAB,STRING.DSC$A_POINTER^:
				    STRING.DSC$W_LENGTH);
    
		{ +
		If it's a qualifier valued secondary, put the qualifier out.
		- }
		IF QUALIFIER_VALUED (SECONDARY) THEN
    
		    SHOW_QUALIFIER;
    
		{ +
		If it's a number valued secondary, put the number out.
		- }
		IF NUMBER_VALUED (SECONDARY) THEN
    
		    { +
		    Show the number.
		    - }
		    WRITE (FDL_DEST,TAB,NUMBER:NUM_LEN(NUMBER));

		{ +
		If it's a boolean valued secondary, put YES or NO out.
		- }
		IF SWITCH_VALUED (SECONDARY) THEN
    
		    IF SWITCH THEN
    
			WRITE (FDL_DEST,TAB,'yes')
    
		    ELSE
    
			WRITE (FDL_DEST,TAB,'no');
    
		IF (
		(SECONDARY = NULL_VALUE)
		OR
		(SECONDARY = MAGTAPE_PROTECTION)
		) THEN

		BEGIN

		    IF (
		    (NUMBER < %X20)	{ SPACE }
		    OR
		    (NUMBER > %X7E)	{ ~ }
		    ) THEN

			WRITE (FDL_DEST,TAB,NUMBER:NUM_LEN(NUMBER))

		    ELSE

			WRITE (FDL_DEST,TAB,APOSTROPHE,CHR(NUMBER),APOSTROPHE);

		END;	{ IF SECONDARY = NULL_VALUE OR MAGTAPE_PROTECTION }

		{ +
		Area Position is a special case.
		- }
		IF SECONDARY = POSITION$ THEN

		BEGIN

		    SHOW_QUALIFIER;

		    IF (
		    QUALIFIER IN [ CYLINDER, LOGICAL, VIRTUAL, CLUSTER ]
		    ) THEN

			{ +
			Show the number.
			- }
			WRITE (FDL_DEST,TAB,NUMBER:NUM_LEN(NUMBER))

		    ELSE

		    BEGIN

			CASE QUALIFIER OF

			    ANY_CYLINDER :	{ NOP } ;

			    NOPOS :		{ NOP } ;

			    FILE_ID :

			    BEGIN

				WRITE (FDL_DEST,TAB,
				'(',FID1:NUM_LEN(FID1),',',
				FID2:NUM_LEN(FID2),',',
				FID3:NUM_LEN(FID3),')');

			    END;	{ FILE_ID }

			    FILE_NAME :

			    BEGIN

				WRITE (FDL_DEST,TAB,STRING.DSC$A_POINTER^:
				STRING.DSC$W_LENGTH);

			    END;	{ FILE_NAME }

			OTHERWISE

			    { NOP } ;

			END;	{ CASE }

		    END;	{ IF FALSE QUALIFIER IN [ ... ] }
    
		END;	{ IF SECONDARY = POSITION$ }

		{ +
		OWNER is a special case.
		The extra fooling with fields is because Pascal will pad on the
		left with blanks.
		- }
		IF (SECONDARY = OWNER) THEN
    
		BEGIN
    
		    IF UIC_GROUP > %O77 THEN
    
			WRITE (FDL_DEST,TAB,'[',UIC_GROUP:3 OCT,',')
    
		    ELSE IF UIC_GROUP > %O7 THEN
    
			WRITE (FDL_DEST,TAB,'[',UIC_GROUP:2 OCT,',')
    
		    ELSE
    
			WRITE (FDL_DEST,TAB,'[',UIC_GROUP:1 OCT,',');
    
    
		    IF UIC_MEMBER > %O77 THEN
    
			WRITE (FDL_DEST,UIC_MEMBER:3 OCT,']')
    
		    ELSE IF UIC_MEMBER > %O7 THEN
    
			WRITE (FDL_DEST,UIC_MEMBER:2 OCT,']')
    
		    ELSE
    
			WRITE (FDL_DEST,UIC_MEMBER:1 OCT,']');
    
		END;
    
		{ +
		PROTECTION is also a special case.
		- }
		IF (SECONDARY = PROTECTION) THEN
    
		BEGIN

		    WRITE (FDL_DEST,TAB,'(system:');
		    SHOW_PROT (PROT_MASK,EDF$V_SYS);
		    WRITE (FDL_DEST,', owner:');
		    SHOW_PROT (PROT_MASK,EDF$V_OWN);
		    WRITE (FDL_DEST,', group:');
		    SHOW_PROT (PROT_MASK,EDF$V_GRP);
		    WRITE (FDL_DEST,', world:');
		    SHOW_PROT (PROT_MASK,EDF$V_WLD);
		    WRITE (FDL_DEST,')');

		END;	{ IF TRUE SECONDARY = PROTECTION }
    
		{ +
		If it has an end-of-line comment, put that out too.
		- }
		IF (COMMENT.DSC$W_LENGTH > 0) THEN
    
		    WRITE (FDL_DEST,TAB,COMMENT.DSC$A_POINTER^:COMMENT.DSC$W_LENGTH);
    
		{ +
		This actually does the QIO.
		- }
		WRITELN (FDL_DEST);

	    END;	{ IF PLUS_VALUE = INCLUDING_VALUE }

	END;	{ SEC }

	COM :

	WITH DEF_CURRENT^ DO

	BEGIN

	    { +
	    This is a full-line comment. Just output it.
	    - }
	    WRITELN (FDL_DEST,COMMENT.DSC$A_POINTER^:COMMENT.DSC$W_LENGTH);

	END;	{ COM }

    OTHERWISE

	{ +
	BUGCHECK!!
	- }
	LIB$SIGNAL (EDF$_INTSWERR,1,40,0);

    END;	{ CASE }

    { +
    Keep track of the number of lines shown (if outputting to terminal).
    - }
    IF DEST_IS_TERMINAL THEN

    BEGIN

	LINES_SHOWN	:= LINES_SHOWN + 1;

	IF DEF_CURRENT^.FORE <> NIL THEN

	    IF (
	    (((LINES_PER_PAGE - EDF$C_HEADROOM) - LINES_SHOWN) < 4)
	    AND
	    ((DEF_CURRENT^.PRIMARY <> DEF_CURRENT^.FORE^.PRIMARY)
	    OR
	    (DEF_CURRENT^.PRINUM <> DEF_CURRENT^.FORE^.PRINUM))
	    ) THEN

	    BEGIN

		{ +
		We're about to output a short primary, reset and
		clear the screen (after the user hits RETURN).
		- }
		LINES_SHOWN	:= 0;
		CLEAR (PAUSE);

	    END;

	IF (
	(LINES_SHOWN >= (LINES_PER_PAGE - EDF$C_HEADROOM))
	) THEN

	BEGIN

	    { +
	    The counter tripped, reset and clear the screen
	    (after the user hits RETURN).
	    - }
	    LINES_SHOWN	:= 0;
	    CLEAR (PAUSE);

	END;

    END;	{ IF DEST_IS_TERMINAL }

END;	{ SHOW_CURRENT }

{ ++

GENERATE_FDL -- Routine to output the FDL definition.

This routine outputs the FDL definition.

CALLING SEQUENCE:

GENERATE_FDL;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

DEF_CURRENT
TAB
ANSI_REVERSE

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

FDL_DEST
LINES_SHOWN

ROUTINES CALLED:

CLEAR
SHOW_CURRENT
INCR_CURRENT
LIB$SIGNAL

ROUTINE VALUE:

none

SIGNALS:

EDF$_INTSWERR - if bugcheck

SIDE EFFECTS:

none

-- }

PROCEDURE GENERATE_FDL;

VAR
    PREV_PRIMARY	: PRIMARY_TYPE;
    PREV_PRINUM		: INTEGER;

BEGIN

    { +
    Do the Primaries as stored in the Definition Linked List.
    - }
    DEF_CURRENT	:= DEF_HEAD;

    { +
    Setup to keep track of new primaries.
    - }
    PREV_PRINUM	:= -1;

    { +
    Initialize the line counter (incremented in SHOW_CURRENT).
    - }
    LINES_SHOWN	:= 0;

    { +
    Is there something to show?
    - }
    IF DEF_CURRENT = NIL THEN

	{ +
	No, that's very bad.
	- }
	LIB$SIGNAL (EDF$_INTSWERR,1,41,0)

    ELSE

    BEGIN

	{ +
	List isn't empty, cycle through the line_objects and show them.
	At least until the end of the list, or until the user types ^Z.
	- }

	REPEAT

	    { +
	    Produce the textual version of the Definition Linked List.
	    Precede the 1st occurance of a primary with 2 blank lines.
	    - }
	    WITH DEF_CURRENT^ DO

	    BEGIN

		IF PREV_PRINUM < 0 THEN
    
		BEGIN
    
		    { +
		    Initial primary, don't skip lines here, just setup.
		    - }
		    PREV_PRIMARY	:= PRIMARY;
		    PREV_PRINUM		:= PRINUM;
    
		END
    
		ELSE
    
		BEGIN
    
		    { +
		    Skip 2 lines if this is a new primary.
		    - }
		    IF NOT (
		    (PREV_PRIMARY = PRIMARY) AND (PREV_PRINUM = PRINUM)
		    ) THEN

		    BEGIN;

			PREV_PRIMARY	:= PRIMARY;
			PREV_PRINUM	:= PRINUM;

			{ +
			This is a new primary, put out a blank line.
			- }
			WRITELN (FDL_DEST);

			IF DEST_IS_TERMINAL THEN

			    LINES_SHOWN	:= LINES_SHOWN + 1;

		    END;
    
		END;	{ IF FALSE PREV_PRINUM >= 0 }

	    END;	{ WITH DEF_CURRENT^ }

	    SHOW_CURRENT (INCLUDING_VALUE);
	    INCR_CURRENT;

	UNTIL DEF_CURRENT = NIL;

    END;	{ IF FALSE DEF_CURRENT = NIL }

END;	{ GENERATE_FDL }

{ ++

VIEW_DEF -- Routine to show the user the Definition Linked List.

This routine will display the definition on the user's terminal.

CALLING SEQUENCE:

VIEW_DEF;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$OUTPUT_NAME
DEF_CURRENT
CONTROL_ZEE_TYPED

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$INPUT: the terminal
DEST_IS_TERMINAL

ROUTINES CALLED:

CLEAR
GENERATE_FDL

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE VIEW_DEF;

BEGIN

    { +
    Erase the user's screen.
    - }
    CLEAR (SCREEN);

    { +
    'Open' his terminal and initialize it.
    Close it first to avoid conflicts.
    - }
    DEST_IS_TERMINAL	:= TRUE;
    CLOSE (FDL_DEST);
    OPEN	(FDL_DEST,SYS$OUTPUT_NAME,NEW);
    REWRITE	(FDL_DEST);

    { +
    Put the current definition out to the terminal.
    - }
    GENERATE_FDL;

    { +
    We're done, close it off.
    - }
    CLOSE	(FDL_DEST);

    { +
    Don't clear if the user hit ^Z, or if SHOW_CURRENT had just done a PAUSE.
    - }
    IF (NOT CONTROL_ZEE_TYPED) AND (LINES_SHOWN <> 0) THEN

    BEGIN

	WRITELN;
	CLEAR (PAUSE);

    END;

END;	{ VIEW_DEF }

{ ++

SHOW_PRIMARY_SECTION -- Display the whole primary section.

This routine outputs the selected primary section to the screen.

CALLING SEQUENCE:

SHOW_PRIMARY_SECTION (TEST);

INPUT PARAMETERS:

TEST

IMPLICIT INPUTS:

FDL_DEST
CONTROL_ZEE_TYPED
DEF_CURRENT
DEF_HEAD

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$OUTPUT:
DEF_CURRENT

ROUTINES CALLED:

CLEAR
INCR_CURRENT
SECTION_MATCH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE SHOW_PRIMARY_SECTION; { ARGUMENT LIST IS FORWARD DECLARED }

BEGIN

    { +
    Show him that whole primary section.
    - }
    LINES_SHOWN		:= 0;

    { +
    Step through the whole list.
    - }
    DEF_CURRENT		:= DEF_HEAD;

    REPEAT

	{ +
	If DEF_CURRENT points to a line_object in that primary, show it.
	- }
	IF CURRENT_EQ_TEST (TEST,PRIMARY) THEN
    
	    SHOW_CURRENT (INCLUDING_VALUE);
    
	{ +
	Try the next.
	- }
	INCR_CURRENT;

    UNTIL DEF_CURRENT = NIL;
	
    WRITELN (FDL_DEST);

END;	{ SHOW_PRIMARY_SECTION }

{ ++

SHOW_ALL_PRIMARIES -- Display the existing primary attributes.

This routine outputs the existing primaries on the screen.

CALLING SEQUENCE:

SHOW_ALL_PRIMARIES;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

FDL_DEST
CONTROL_ZEE_TYPED
DEF_CURRENT
DEF_HEAD

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$OUTPUT:
DEF_CURRENT

ROUTINES CALLED:

CLEAR
INCR_CURRENT
SECTION_MATCH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE SHOW_ALL_PRIMARIES;

BEGIN

    { +
    Show him all the primary attributes.
    - }
    LINES_SHOWN		:= 0;

    { +
    Step through the whole list.
    - }
    DEF_CURRENT		:= DEF_HEAD;

    REPEAT

	{ +
	If DEF_CURRENT points to a line_object that is a primary, show it.
	But not the Ident.
	- }
	IF (
	(DEF_CURRENT^.OBJECT_TYPE = PRI)
	AND
	(DEF_CURRENT^.PRIMARY <> IDENT)
	) THEN
    
	    SHOW_CURRENT (INCLUDING_VALUE);
    
	{ +
	Try the next.
	- }
	INCR_CURRENT;

    UNTIL DEF_CURRENT = NIL;

    WRITELN (FDL_DEST);

END;	{ SHOW_ALL_PRIMARIES }

{ ++

SHOW_CUR_PRI_SEC -- Display the line_object pointed to by def_current.

This routine outputs the def_current line_object.

CALLING SEQUENCE:

SHOW_CUR_PRI_SEC;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

FDL_DEST
CONTROL_ZEE_TYPED
DEF_CURRENT
DEF_HEAD

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$OUTPUT:
DEF_CURRENT

ROUTINES CALLED:

CLEAR
INCR_CURRENT
SECTION_MATCH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE SHOW_CUR_PRI_SEC; { FORWARD DECLARED }

VAR
    SAVE_OBJECT_TYPE		: LINE_OBJECT_TYPE;

BEGIN

    LINES_SHOWN			:= 0;

    { +
    Now display the 2 versions of the line_object.
    All this only works because the primary that a line_object is in
    is stored redundantly in all the subsequent secondaries.
    - }
    SAVE_OBJECT_TYPE		:= DEF_CURRENT^.OBJECT_TYPE;

    DEF_CURRENT^.OBJECT_TYPE	:= PRI;
    SHOW_CURRENT (PLUS_VALUE);

    IF DEF_CURRENT^.PRIMARY <> TITLE THEN

    BEGIN

	DEF_CURRENT^.OBJECT_TYPE := SEC;
	SHOW_CURRENT (PLUS_VALUE);

    END;

    DEF_CURRENT^.OBJECT_TYPE	:= SAVE_OBJECT_TYPE;

END;	{ SHOW_CUR_PRI_SEC }

    { End of file: SRC$:EDFSHOW.PAS }
