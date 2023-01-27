{ ++
    		FILE: SRC$:EDFCHF.PAS - Pascal include file to implement
		condition handling facilities in EDF.

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

		V03-002	KFH0002		Ken Henderson		31 March 1982
			Modified RMS_INPUT_COND_HANDLER to fix
			FT2 QAR 968

		V03-001	KFH0001		Ken Henderson		23-Mar-1982
			Modified RMS_INPUT_COND_HANDLER to fix
			FT2 QAR 694

-- }

{ ++

CTRLZ_COND_HANDLER -- Handle user typing control/Z.

This routine checks for control/Z signal from sys$input_cond_handler
and unwinds to the top level if found.
It also is the outermost handler and does a putmsg if it wasn't a ^Z.

CALLING SEQUENCE:

LIB$SIGNAL;

INPUT PARAMETERS:

SIGARGS
MECHARGS

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

SIGARGS
MECHARGS

IMPLICIT OUTPUTS:

none

ROUTINES CALLED:

LIB$MATCH_COND
SYS$UNWIND

ROUTINE VALUE:

SS$_RESIGNAL if unable to handle error.  N/A if able (ignored on unwind).

SIGNALS:

Resignals if unable to handle error.

SIDE EFFECTS:

none

-- }

FUNCTION CTRLZ_COND_HANDLER (
			    VAR SIGARGS : SIGARR;
			    VAR MECHARGS : MECHARR
				) : INTEGER;

BEGIN

    { +
    If we're already unwinding, skip everything.
    - }
    IF NOT (
    (LIB$MATCH_COND (SIGARGS[1],SS$_UNWIND))
    ) THEN

    BEGIN

	{ +
	Check for the ^Z "error".
	- }
	IF NOT (
	(LIB$MATCH_COND (SIGARGS[1],EDF$_CTRLZ))
	) THEN

	BEGIN

	    { +
	    Tell the user what the disaster was. In reverse video of course.
	    - }
	    STATUS	:= SYS$PUTMSG (SIGARGS);

	    { +
	    Wait for the user to see what happened.
	    - }
	    DELAY (5.0);

	END;	{ IF NOT LIB$MATCH_COND }

	{ +
	Put the terminal straight.
	And close any files open to the terminal.
	- }
	EDF$RESET_SCROLL;

	IF DEST_IS_TERMINAL THEN

	    CLOSE (FDL_DEST);

	{ +
	Unwind (pop up) to the caller of the handler establisher.
	- }
	STATUS			:= SYS$UNWIND (0,0);

	{ +
	The function value is ignored if we did an unwind.
	- }
	CTRLZ_COND_HANDLER	:= SS$_RESIGNAL;

    END;	{ IF NOT UNWINDING }

END;	{ CTRLZ_COND_HANDLER }

{ ++

RMS_INPUT_COND_HANDLER -- Handle input file errors.

This routine checks for recoverable input errors from RMS files.

CALLING SEQUENCE:

LIB$SIGNAL;

INPUT PARAMETERS:

SIGARGS
MECHARGS

IMPLICIT INPUTS:

TAB
ANSI_REVERSE

OUTPUT PARAMETERS:

SIGARGS
MECHARGS

IMPLICIT OUTPUTS:

RMS_INPUT_ERROR
SYS$OUTPUT:, if the error is one we handle.

ROUTINES CALLED:

DELAY
LIB$MATCH_COND
SYS$UNWIND

ROUTINE VALUE:

SS$_RESIGNAL if unable to handle error.  N/A if able (ignored on unwind).

SIGNALS:

Resignals if unable to handle error.

SIDE EFFECTS:

none

-- }

FUNCTION RMS_INPUT_COND_HANDLER (
			    VAR SIGARGS : SIGARR;
			    VAR MECHARGS : MECHARR
				) : INTEGER;

VAR
    SEVERITY	: INTEGER;
    NEW_SEV	: INTEGER;

BEGIN

    { +
    If we're already unwinding, skip everything.
    - }
    IF NOT (
    (LIB$MATCH_COND (SIGARGS[1],SS$_UNWIND))
    ) THEN

    BEGIN

	RMS_INPUT_ERROR	:= TRUE;

	{ +
	Find out the severity of the error.
	- }
	SEVERITY  := LIB$EXTZV (STS$V_SEVERITY,STS$S_SEVERITY,SIGARGS[1]);

	{ +
	Show the user what's wrong, unless it'll come out on exit anyway.
	- }
	IF SEVERITY <> STS$K_SEVERE THEN

	    STATUS	:= SYS$PUTMSG (SIGARGS);

	{ +
	Don't continue editing if this was a bad error.
	- }
	IF (SEVERITY IN [ STS$K_ERROR, STS$K_SEVERE ]) THEN

	    EDITING	:= FALSE;

	{ +
	Unwind if it's a file-not-found (only for definition file).
	Otherwise, let EDF exit on bad errors.
	- }
	IF (
	(SIGARGS[5] = RMS$_FNF)
	AND
	(NOT ANALYSIS_ONLY)
	) THEN

	BEGIN

	    { +
	    Keep editing;
	    Make the FDL error informational;
	    Tell the user what file wasn't found;
	    Unwind (pop up) to the caller of the handler establisher.
	    - }
	    EDITING	:= TRUE;
	    NEW_SEV	:= STS$K_INFO;
	    LIB$INSV (NEW_SEV,STS$V_SEVERITY,STS$S_SEVERITY,SIGARGS[1]);

	    WRITELN;
	    STATUS	:= SYS$PUTMSG (SIGARGS);
	    WRITELN (CRLF,SHIFT,'A new FDL file will be created.');

	    STATUS	:= SYS$UNWIND (0,0);

	END;

	{ +
	The function value is ignored if we did an unwind.
	- }
	RMS_INPUT_COND_HANDLER	:= SS$_CONTINUE;

    END;	{ IF NOT UNWINDING }

END;	{ RMS_INPUT_COND_HANDLER }

{ ++

SYS$INPUT_COND_HANDLER -- Check for recoverable typing errors.

This routine handles Pascal input errors caused by user garbage.

CALLING SEQUENCE:

LIB$SIGNAL;

INPUT PARAMETERS:

SIGARGS
MECHARGS

IMPLICIT INPUTS:

CONTROL_Z
TAB
ANSI_REVERSE

OUTPUT PARAMETERS:

SIGARGS
MECHARGS

IMPLICIT OUTPUTS:

CONTROL_ZEE_TYPED
ERR_CHAR
QUESTION_TYPED
TEMP_FULL_PROMPT
SYS$INPUT_ERROR
SYS$OUTPUT:, if the error is one we can handle.

ROUTINES CALLED:

DELAY
LIB$MATCH_COND
SYS$UNWIND

ROUTINE VALUE:

SS$_RESIGNAL, if not unwinding.  N/A if it is unwinding.

SIGNALS:

Resignals if it can't process the signal.

SIDE EFFECTS:

none

-- }

FUNCTION SYS$INPUT_COND_HANDLER (
			    VAR SIGARGS : SIGARR;
			    VAR MECHARGS : MECHARR
				) : INTEGER;

BEGIN

    { +
    If we're already unwinding, skip everything.
    - }
    IF NOT (
    (LIB$MATCH_COND (SIGARGS[1],SS$_UNWIND))
    ) THEN

    BEGIN

	{ +
	Check for bad typed input.
	- }
	IF (
	(LIB$MATCH_COND (SIGARGS[1],PAS$_ERRACCFIL))
	OR
	(LIB$MATCH_COND (SIGARGS[1],PAS$_SUBASGBOU))
	OR
	(LIB$MATCH_COND (SIGARGS[1],EDF$_AMBIG))
	OR
	(LIB$MATCH_COND (SIGARGS[1],EDF$_BADSYNTAX))
	OR
	(LIB$MATCH_COND (SIGARGS[1],EDF$_BADVALUE))
	OR
	(LIB$MATCH_COND (SIGARGS[1],EDF$_NODEFAULT))
	) THEN

	BEGIN

	    { +
	    Set the ^Z flag to true or false according to if the user typed ^Z.
	    But it's defined to be false if we just forced the error.
	    - }
	    IF (
	    (LIB$MATCH_COND (SIGARGS[1],EDF$_AMBIG))
	    OR
	    (LIB$MATCH_COND (SIGARGS[1],EDF$_BADSYNTAX))
	    OR
	    (LIB$MATCH_COND (SIGARGS[1],EDF$_BADVALUE))
	    OR
	    (LIB$MATCH_COND (SIGARGS[1],EDF$_NODEFAULT))
	    ) THEN

		CONTROL_ZEE_TYPED	:= FALSE

	    ELSE

		CONTROL_ZEE_TYPED	:= EOF (INPUT);

	    { +
	    Fudge for top-level ^Z exiting.
	    - }
	    IF MAIN_LEVEL THEN

		MAIN_CTRLZ		:= CONTROL_ZEE_TYPED;

	    { +
	    If it was ^Z, don't look at the input string - there's nothing there.
	    - }
	    IF CONTROL_ZEE_TYPED THEN

		ERR_CHAR		:= CONTROL_Z

	    ELSE

		{ +
		Get the offending character to see what it is.
		- }
		ERR_CHAR		:= INPUT_STRING[1];

	    { +
	    One "garbage" character is "?" - which causes flags to get set.
	    - }
	    IF ERR_CHAR = QUESTION_MARK THEN

	    BEGIN

		QUESTION_TYPED		:= TRUE;
		TEMP_FULL_PROMPT	:= TRUE;

	    END

	    ELSE

		QUESTION_TYPED	:= FALSE;

	    { +
	    Now clear the garbage out of the input buffer.
	    But only if we it was a control/Z.
	    - }
	    IF CONTROL_ZEE_TYPED THEN

		RESET (INPUT);

	    { +
	    Tell the user he messed up, if he didn't type control/Z or "?".
	    - }
	    IF NOT ( CONTROL_ZEE_TYPED OR QUESTION_TYPED ) THEN

	    BEGIN

		{ +
		Show the error message in reverse video.
		- }
		WRITE (SHIFT,ANSI_REVERSE,DASH);

		IF (LIB$MATCH_COND (SIGARGS[1],EDF$_AMBIG)) THEN

		    WRITE (' That answer is ambiguous in this context. ');

		IF (LIB$MATCH_COND (SIGARGS[1],EDF$_BADSYNTAX)) THEN

		    WRITE (' That answer has invalid syntax. ');

		IF (LIB$MATCH_COND (SIGARGS[1],EDF$_BADVALUE)) THEN

		    WRITE (' That answer is not appropriate in this context. ');

		IF (LIB$MATCH_COND (SIGARGS[1],EDF$_NODEFAULT)) THEN

		    WRITE (' You must provide an answer here (or press CTRL/Z). ');

		WRITELN (DASH,ANSI_RESET);

		{ +
		Let the user see the message.
		- }
		DELAY (2.0);

		{ +
		Give the user some help.
		- }
		QUESTION_TYPED		:= TRUE;
		TEMP_FULL_PROMPT	:= TRUE;

	    END;

	    { +
	    Flag the error and unwind back to the caller of the establisher.
	    - }
	    SYS$INPUT_ERROR	:= TRUE;

	    IF CONTROL_ZEE_TYPED THEN

		{ +
		Don't unwind yet if the user typed control/Z.
		Let the CTRLZ_COND_HANDLER do it.
		- }
		SIGARGS[1]	:= EDF$_CTRLZ

	    ELSE

		{ +
		Unwind (pop up) to the caller of the handler establisher.
		- }
		STATUS	:= SYS$UNWIND (0,0);

	END;

	{ +
	If we unwound, the function value will be ignored.
	If we didn't, we couldn't handle the error, so resignal.
	- }
	SYS$INPUT_COND_HANDLER	:= SS$_RESIGNAL;

    END;	{ IF NOT UNWINDING }

END;	{ SYS$INPUT_COND_HANDLER }

    { End of file: SRC$:EDFCHF.PAS }
