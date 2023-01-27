{ ++
    		FILE: SRC$:EDFDESIGN.PAS - Pascal include file to implement
		the file designing routines for EDF.

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
			Modified several routines to fix FT2
			QAR 746

		V03-001	KFH0001		Ken Henderson		17-Mar-1982
			Modified several routines to fix FT2
			QARs 509,559,510,574

-- }

{ ++

PROLOGUE3_BUCKETS -- Routine to calculate the number of buckets at a level.

This routine combines the various file parameters of a prologue3 file and
calls itself recursively to find the number of buckets at each level.

CALLING SEQUENCE:

PROLOGUE3_BUCKETS (INIT_NUMBER_RECORDS,ADDED_NUMBER_RECORDS,INDEX_LEVEL);

INPUT PARAMETERS:

NUMBER_RECORDS
INDEX_LEVEL

IMPLICIT INPUTS:

VARIABLE_RECORDS
KEY_DUPS
KEY_SIZE
MEAN_RECORD_SIZE
LOAD_FILL
BYTES_PER_BUCKET

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

INIT_NUMBER_BUCKETS
ADDED_NUMBER_BUCKETS
DEEPEST

ROUTINES CALLED:

PROLOGUE3_BUCKETS
LIB$SIGNAL

ROUTINE VALUE:

none

SIGNALS:

EDF$_CTRLZ - if a file > 31 index levels was spec'd

SIDE EFFECTS:

none

-- }

PROCEDURE PROLOGUE3_BUCKETS (
			INIT_NUMBER_RECORDS	: INTEGER;
			ADDED_NUMBER_RECORDS	: INTEGER;
			INDEX_LEVEL		: INTEGER
			);

VAR
    INIT_RECORDS_PER_BUCKET	: INTEGER;
    ADDED_RECORDS_PER_BUCKET	: INTEGER;
    RECORD_OVERHEAD		: INTEGER;
    RECORD_SIZE			: INTEGER;
    INIT_AVAILABLE_BYTES	: INTEGER;
    ADDED_AVAILABLE_BYTES	: INTEGER;
    KEY_SAVINGS			: INTEGER;
    DATA_SAVINGS		: INTEGER;
    INDEX_SAVINGS		: INTEGER;
    BUCKET_OVERHEAD		: INTEGER;

BEGIN

    { +
    Level 0 is the data level, calculate the filling of the data buckets.
    - }
    IF INDEX_LEVEL = 0 THEN

    BEGIN

	IF ACTIVE_KEY = 0 THEN

	BEGIN

	    IF KEY_DUPS THEN

		BUCKET_OVERHEAD	:= P3_BUCKET_OVERHEAD_PD + P3_BUCKET_DUPS_LCB

	    ELSE

		BUCKET_OVERHEAD	:= P3_BUCKET_OVERHEAD_PD;

	    IF VARIABLE_RECORDS THEN

		RECORD_OVERHEAD	:= P3_RECORD_OVERHEAD_VAR

	    ELSE

		RECORD_OVERHEAD	:= P3_RECORD_OVERHEAD_FIX;

	    { +
	    Combine the two compression factors to get one to weight the record
	    size by.
	    - }
	    KEY_SAVINGS		:= TRUNC (KEY_SIZE * DATA_KEY_COMP);
	    DATA_SAVINGS	:=
		TRUNC ((MEAN_RECORD_SIZE - KEY_SIZE) * DATA_RECORD_COMP);

	    { +
	    The 'actual' record size will have the compression subtracted from it.
	    - }
	    RECORD_SIZE		:=
		(MEAN_RECORD_SIZE - KEY_SAVINGS) - DATA_SAVINGS;

	END	{ IF TRUE KEY = 0 }

	ELSE

	BEGIN

	    BUCKET_OVERHEAD	:= P3_BUCKET_OVERHEAD_SD;

	    IF KEY_DUPS THEN

		BUCKET_OVERHEAD	:= BUCKET_OVERHEAD + P3_BUCKET_DUPS_LCB;

	    RECORD_OVERHEAD	:= P3_SIDR_OVERHEAD;
	    INDEX_SAVINGS	:= TRUNC (KEY_SIZE * INDEX_RECORD_COMP);
	    RECORD_SIZE		:= (KEY_SIZE - INDEX_SAVINGS) +
	    			   ((2 + NUMBER_DUPS) * P3_SIDR_POINTER);

	END;	{ IF FALSE KEY = 0 }

    END		{ IF TRUE INDEX_LEVEL = 0 (DATA LEVEL) }

    ELSE

    { +
    For the index levels (L>0), the overheads are as follows.
    - }
    BEGIN

	RECORD_OVERHEAD		:= 5; { ASSUMING 4 BYTE VBN'S - WORST CASE }
	INDEX_SAVINGS		:= TRUNC (KEY_SIZE * INDEX_RECORD_COMP);
	BUCKET_OVERHEAD		:= P3_BUCKET_OVERHEAD_IDX;
	RECORD_SIZE		:= KEY_SIZE - INDEX_SAVINGS;

    END;	{ IF FALSE INDEX_LEVEL = 0 }

    { +
    Now that we've figured out the overheads, how many records can we fit
    in a bucket at this level?
    - }

    { +
    First figure out how many bytes are available to use for records.
    - }
    INIT_AVAILABLE_BYTES	:=
    		TRUNC ((BYTES_PER_BUCKET - BUCKET_OVERHEAD) * LOAD_FILL);
    ADDED_AVAILABLE_BYTES	:=
    		TRUNC ((BYTES_PER_BUCKET - BUCKET_OVERHEAD) * ADDED_FILL);

    { +
    The number of records that will fit is simply the space available
    divided by the space for each record. (integer division)
    - }
    INIT_RECORDS_PER_BUCKET	:=
		INIT_AVAILABLE_BYTES DIV (RECORD_SIZE + RECORD_OVERHEAD);
    ADDED_RECORDS_PER_BUCKET	:=
		ADDED_AVAILABLE_BYTES DIV (RECORD_SIZE + RECORD_OVERHEAD);

    { +
    CONVERT or RMS will put at least one (1) record in a data level bucket.
    And it will put at least two (2) records in an index level bucket.
    - }
    IF (INDEX_LEVEL = 0) AND (INIT_RECORDS_PER_BUCKET < 1) THEN

	INIT_RECORDS_PER_BUCKET		:= 1

    ELSE IF (INDEX_LEVEL > 0) AND (INIT_RECORDS_PER_BUCKET < 2) THEN

	INIT_RECORDS_PER_BUCKET		:= 2;

    IF (INDEX_LEVEL = 0) AND (ADDED_RECORDS_PER_BUCKET < 1) THEN

	ADDED_RECORDS_PER_BUCKET	:= 1

    ELSE IF (INDEX_LEVEL > 0) AND (ADDED_RECORDS_PER_BUCKET < 2) THEN

	ADDED_RECORDS_PER_BUCKET	:= 2;

    { +
    Now record the number of buckets at this level.
    - }
    INIT_NUMBER_BUCKETS [INDEX_LEVEL] :=
		INIT_NUMBER_RECORDS DIV INIT_RECORDS_PER_BUCKET;
    ADDED_NUMBER_BUCKETS [INDEX_LEVEL] :=
		ADDED_NUMBER_RECORDS DIV ADDED_RECORDS_PER_BUCKET;

    { +
    If there was a remainder, we need just one more bucket at this level.
    - }
    IF (INIT_NUMBER_RECORDS MOD INIT_RECORDS_PER_BUCKET) <> 0 THEN

	INIT_NUMBER_BUCKETS [INDEX_LEVEL] :=
	INIT_NUMBER_BUCKETS [INDEX_LEVEL] + 1;

    IF (ADDED_NUMBER_RECORDS MOD ADDED_RECORDS_PER_BUCKET) <> 0 THEN

	ADDED_NUMBER_BUCKETS [INDEX_LEVEL] :=
	ADDED_NUMBER_BUCKETS [INDEX_LEVEL] + 1;

    { +
    Bump the high-water marker.
    - }
    DEEPEST		:= INDEX_LEVEL;

    { +
    If we're at the data level, or we had more than one bucket at this level,
    then repeat the calculations for the next level up (down?).
    - }
    IF (
    (INDEX_LEVEL = 0)
    OR
    (INIT_NUMBER_BUCKETS [INDEX_LEVEL] > 1)
    OR
    (ADDED_NUMBER_BUCKETS [INDEX_LEVEL] > 1)
    ) THEN

    BEGIN

	{ +
	In the index, the records merely point to buckets.
	- }
	INIT_NUMBER_RECORDS	:= INIT_NUMBER_BUCKETS [INDEX_LEVEL];
	ADDED_NUMBER_RECORDS	:= ADDED_NUMBER_BUCKETS [INDEX_LEVEL];

	INDEX_LEVEL		:= INDEX_LEVEL + 1;

	{ +
	Pathological file here - tell the user and pop him up.
	- }
	IF INDEX_LEVEL > 31 THEN

	BEGIN

	    WRITELN (SHIFT,ANSI_REVERSE,DASH,
	    ' A File of Greater than 31 Index Levels has been specified. ',
	    DASH,ANSI_RESET);

	    DELAY (5.0);

	    LIB$SIGNAL (EDF$_CTRLZ,0,0,0);

	END;

	{ +
	Recurse to the next level.
	- }
	PROLOGUE3_BUCKETS (
			    INIT_NUMBER_RECORDS,
			    ADDED_NUMBER_RECORDS,
			    INDEX_LEVEL
			    );

    END;

END;	{ PROLOGUE3_BUCKETS }

{ ++

PROLOGUE3_DEPTH -- Routine to calculate the depth of a prologue3 index.

This routine combines the various file parameters of a prologue3 file and
'builds' and index from the data level up to the root - to find its depth.

CALLING SEQUENCE:

DEPTH	:= PROLOGUE3_DEPTH;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

TOTAL_RECORDS
BLOCKS_IN_BUCKET
DEEPEST

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

BYTES_PER_BUCKET
NUMBER_BUCKETS

ROUTINES CALLED:

PROLOGUE3_BUCKETS

ROUTINE VALUE:

Depth of the index

SIGNALS:

none

SIDE EFFECTS:

none

-- }

FUNCTION PROLOGUE3_DEPTH : INTEGER;

VAR
    BUCKET_OVERHEAD	: INTEGER;
    RECORD_SIZE		: INTEGER;
    I			: INTEGER;

BEGIN

    { +
    Clear out the arrays that holds the number of buckets per level.
    - }
    FOR I := 0 TO 31 DO

    BEGIN

	INIT_NUMBER_BUCKETS [I]		:= 0;
	ADDED_NUMBER_BUCKETS [I]	:= 0;

    END;

    { +
    Convert block/bucket to bytes/bucket.
    - }
    BYTES_PER_BUCKET		:= BLOCKS_IN_BUCKET * 512;

    { +
    Reset depth and calculate how deep the index will be.
    - }
    DEEPEST			:= 0;

    { +
    Figure depth only if the record will fit in the bucket.
    Otherwise flag it.
    - }
    IF ACTIVE_KEY = 0 THEN

	BUCKET_OVERHEAD	:= P3_BUCKET_OVERHEAD_PD

    ELSE

	BUCKET_OVERHEAD	:= P3_BUCKET_OVERHEAD_SD;

    IF KEY_DUPS THEN

	BUCKET_OVERHEAD	:= BUCKET_OVERHEAD + P3_BUCKET_DUPS_LCB;

    IF MAX_RECORD_SIZE = 0 THEN

	RECORD_SIZE	:= BIGGEST_P3_RECORD

    ELSE

	RECORD_SIZE	:= MAX_RECORD_SIZE;

    { +
    Only do the depth calculation if the record will fit in the bucket,
    and the key will fit in the record.
    - }
    IF (
    ((BYTES_PER_BUCKET - BUCKET_OVERHEAD) >= MEAN_RECORD_SIZE)
    AND
    (RECORD_SIZE >= (KEY_SIZE + KEY_POSITION))
    ) THEN

    BEGIN

	CASE LOAD_METHOD OF

	    FAST_CONVERT :

		LOAD_FILL	:= DESIRED_FILL / 100.0;

	    NOFAST_CONVERT :

		IF ASCENDING_LOAD THEN

		    LOAD_FILL	:= 0.90 * (DESIRED_FILL / 100.0)

		ELSE

		    LOAD_FILL	:= 0.6667 * (DESIRED_FILL / 100.0);

	    RMS_PUTS :

	    BEGIN

		IF ASCENDING_LOAD THEN

		    LOAD_FILL	:= 0.90 * (DESIRED_FILL / 100.0)

		ELSE

		    LOAD_FILL	:= 0.6667 * (DESIRED_FILL / 100.0);

		FDL_FILL	:= 100;

	    END;

	OTHERWISE

	    { +
	    BUGCHECK!!
	    - }
	    LIB$SIGNAL (EDF$_INTSWERR,1,22,0);

	END;	{ CASE }

	IF ASCENDING_ADDED THEN

	    ADDED_FILL	:= 0.90

	ELSE

	    ADDED_FILL	:= 0.6667;

	PROLOGUE3_BUCKETS (INITIAL_COUNT,ADDED_COUNT,0);
    
	{ +
	The deepest we went is the function value.
	- }
	PROLOGUE3_DEPTH		:= DEEPEST;

    END

    ELSE

	PROLOGUE3_DEPTH		:= 0;

END;	{ PROLOGUE3_DEPTH }

{ ++

NATURAL_DEPTH -- Find most typical depth of file.

This routine does calculations to find out the most reasonable bucketsize
for an index.

CALLING SEQUENCE:

BUCKET_DEFAULT	:= NATURAL_DEPTH;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

COLOR_ROW

ROUTINES CALLED:

none

ROUTINE VALUE:

BUCKET_DEFAULT

SIGNALS:

none

SIDE EFFECTS:

none

-- }

FUNCTION NATURAL_DEPTH : INTEGER;

VAR
    DEPTH		: ARRAY [1..32] OF INTEGER;
    TALLY		: ARRAY [1..32] OF REAL;
    CURRENT_WEIGHT	: REAL;
    CURRENT_TALLY	: REAL;
    MAX_TALLY		: REAL;
    DIST_FROM_NATURAL	: INTEGER;
    DIST_FROM_UPPER	: INTEGER;
    LEFT_ADJ_RANGE	: INTEGER;
    MAX_RIGHT_OFFSET	: INTEGER;
    CURRENT_DEPTH	: INTEGER;
    RANGE		: INTEGER;
    MAX_RANGE		: INTEGER;

BEGIN

    { +
    Fill the depth array with the depths at each bucketsize.
    And zero out the tally array.
    - }
    FOR RANGE := 1 TO 32 DO

    BEGIN

	BLOCKS_IN_BUCKET	:= RANGE;
	DEPTH[RANGE]		:= PROLOGUE3_DEPTH;
	TALLY[RANGE]		:= 0;

    END;	{ FOR }

    { +
    Add up the lengths of the ranges.
    - }
    CURRENT_WEIGHT	:= 1.0;
    CURRENT_DEPTH	:= 0;
    CURRENT_TALLY	:= 0;

    FOR RANGE := 32 DOWNTO 1 DO

    BEGIN

	IF DEPTH[RANGE] = 0 THEN

	BEGIN

	    IF RANGE < 32 THEN

		IF DEPTH[RANGE+1] > 0 THEN

		    TALLY[RANGE+1]	:= CURRENT_TALLY;

	    TALLY[RANGE]	:= 0;

	END

	ELSE IF DEPTH[RANGE] > CURRENT_DEPTH THEN

	BEGIN

	    IF RANGE < 32 THEN

		TALLY[RANGE+1]	:= CURRENT_TALLY;

	    CURRENT_DEPTH	:= DEPTH[RANGE];
	    CURRENT_TALLY	:= CURRENT_WEIGHT;

	END

	ELSE

	BEGIN

	    CURRENT_TALLY	:= CURRENT_TALLY + CURRENT_WEIGHT;

	END;

	IF BUCKET_WEIGHT = EDF$C_SMALLER_BUFFERS THEN

	    CURRENT_WEIGHT	:= CURRENT_WEIGHT + BUCKET_LEFT_WEIGHT;

    END;	{ FOR }

    { +
    Now find the left end of the most common range (that's not 0).
    - }
    MAX_TALLY		:= 0;
    MAX_RANGE		:= 0;

    FOR RANGE := 32 DOWNTO 1 DO

	IF TALLY[RANGE] > MAX_TALLY THEN

	BEGIN

	    MAX_TALLY	:= TALLY[RANGE];
	    MAX_RANGE	:= RANGE;

	END;

    { +
    Sometimes there aren't any values at all on a row...
    - }
    IF MAX_RANGE < 1 THEN

	MAX_RANGE	:= 1;

    { +
    Now let's calculate what the colors are for this row.
    Right part 1st...
    - }
    MAX_RIGHT_OFFSET	:= (32 - MAX_RANGE) DIV 3;

    FOR RANGE := MAX_RANGE TO 32 DO

    BEGIN

	DIST_FROM_NATURAL	:= RANGE - MAX_RANGE;
	DIST_FROM_UPPER		:= 32 - RANGE;

	IF ABS (DIST_FROM_NATURAL - DIST_FROM_UPPER) <= MAX_RIGHT_OFFSET THEN

	    COLOR_ROW[RANGE-1]	:= EDF$C_MEDIUM_YELLOW

	ELSE IF DIST_FROM_NATURAL < DIST_FROM_UPPER THEN

	    COLOR_ROW[RANGE-1]	:= EDF$C_LIGHT_GREEN

	ELSE IF DIST_FROM_NATURAL > DIST_FROM_UPPER THEN

	    COLOR_ROW[RANGE-1]	:= EDF$C_DARK_RED

	ELSE

	    { +
	    BUGCHECK!!
	    - }
	    LIB$SIGNAL (EDF$_INTSWERR,1,23,0);

    { +
    Make suere the green region includes only one depth.
    - }
    IF (
    (DEPTH[RANGE] <> DEPTH[MAX_RANGE])
    AND
    (COLOR_ROW[RANGE-1] = EDF$C_LIGHT_GREEN)
    ) THEN

	COLOR_ROW[RANGE-1]	:= EDF$C_MEDIUM_YELLOW;

    END;	{ FOR }

    { +
    Now do to the left of natural.
    - }
    IF MAX_RANGE = 1 THEN

    BEGIN

	COLOR_ROW[0]	:= EDF$C_LIGHT_GREEN;
	LEFT_ADJ_RANGE	:= DEPTH[MAX_RANGE];

    END

    ELSE

    BEGIN

	LEFT_ADJ_RANGE	:= DEPTH[MAX_RANGE-1];
    
	FOR RANGE := (MAX_RANGE-1) DOWNTO 1 DO
    
	BEGIN
    
	    IF DEPTH[RANGE] = LEFT_ADJ_RANGE THEN
    
		COLOR_ROW[RANGE-1]	:= EDF$C_MEDIUM_YELLOW
    
	    ELSE
    
		COLOR_ROW[RANGE-1]	:= EDF$C_DARK_RED;
    
	END;

    END;	{ IF FALSE MAX_RANGE = 1 }

    { +
    Now blank out any illegal spots.
    - }
    FOR RANGE := 1 TO 32 DO

	IF DEPTH[RANGE] < 1 THEN

	    COLOR_ROW[RANGE-1]	:= EDF$C_BACKGROUND_COLOR;

    { +
    Now fill in the breakpoint variables.
    Mid is easy.
    - }
    BREAKPOINT_MID	:= MAX_RANGE;

    { +
    Breakpoint_right.
    - }
    RANGE		:= MAX_RANGE;

    WHILE (RANGE < 32) AND (COLOR_ROW[RANGE-1] = EDF$C_LIGHT_GREEN) DO

	RANGE		:= RANGE + 1;

    IF COLOR_ROW[RANGE-1] <> EDF$C_BACKGROUND_COLOR THEN

	BREAKPOINT_RIGHT := RANGE

    ELSE IF RANGE <> MAX_RANGE THEN

	BREAKPOINT_RIGHT := RANGE - 1

    ELSE

	BREAKPOINT_RIGHT := MAX_RANGE;

    { +
    Breakpoint_left.
    - }
    RANGE		:= MAX_RANGE - 1;

    IF RANGE > 0 THEN

	WHILE (RANGE > 1) AND (DEPTH[RANGE] = LEFT_ADJ_RANGE) DO

	    RANGE		:= RANGE - 1;

    { +
    Backup
    - }
    RANGE		:= RANGE + 1;

    IF RANGE >= MAX_RANGE THEN

	BREAKPOINT_LEFT	:= MAX_RANGE

    ELSE

	BREAKPOINT_LEFT	:= RANGE;

    { +
    Now stuff the function value and leave.
    - }
    NATURAL_DEPTH	:= MAX_RANGE;

END;	{ NATURAL_DEPTH }

{ ++

PLOT_SIMPLE_GRAPH -- Calculate index depths and plot them.

This routine figures out what the index depths will be for all bucketsizes
and plots them on the screen.

CALLING SEQUENCE:

PLOT_SIMPLE_GRAPH;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

FIRST_PLOT

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$OUTPUT:
BLOCKS_IN_BUCKET
XY_ARRAY

ROUTINES CALLED:

PROLOGUE3_DEPTH
EDF$GRAPH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE PLOT_SIMPLE_GRAPH;

VAR
    RANGE		: INTEGER;
    GRAPH_SWITCH	: INTEGER;
    TEMP_INTEGER	: INTEGER;
    TEMP_INT2		: INTEGER;

BEGIN

    { +
    Do the simple graph.
    - }
    GRAPH_TYPE		:= EDF$C_LINE;
    Y_LABEL		:= 'Index Depth                     ';

    { +
    Swap the graph_index (for double buffering)
    - }
    TEMP_INTEGER	:= CURRENT_GRAPH_INDEX;
    CURRENT_GRAPH_INDEX	:= LAST_GRAPH_INDEX;
    LAST_GRAPH_INDEX	:= TEMP_INTEGER;

    IF FIRST_PLOT THEN

    BEGIN

	{ +
	Hard set the graph index if this is the 1st time through.
	Plus set the graph switch to non-move-mode to plot the entire
	axis as well as the points.
	- }
	GRAPH_SWITCH		:= -1;
	CURRENT_GRAPH_INDEX	:= 0;
	LAST_GRAPH_INDEX	:= 1;

    END	{ IF TRUE FIRST_PLOT }

    ELSE

	{ +
	Not the 1st time through, just 'move' the points from their
	last position.
	- }
	GRAPH_SWITCH		:= LAST_GRAPH_INDEX;

    { +
    Fill the row in the xy_array with the depths at each bucketsize.
    - }
    FOR RANGE := 0 TO 31 DO

    BEGIN

	BLOCKS_IN_BUCKET			:= RANGE + 1;
	XY_ARRAY[CURRENT_GRAPH_INDEX,RANGE]	:= PROLOGUE3_DEPTH;

    END;	{ FOR }

    { +
    Fill the color_row, and copy that into the array.
    - }
    TEMP_INTEGER	:= NATURAL_DEPTH;

    FOR TEMP_INT2 := 0 TO 31 DO

	COLOR_ARRAY[CURRENT_GRAPH_INDEX,TEMP_INT2] := COLOR_ROW[TEMP_INT2];

    { +
    Since edfgrf doesn't for VT125s...
    - }
    IF REGIS THEN

	{ +
	Can't use CLEAR (SCREEN) because that also does a graphics clear.
	- }
	STATUS	:= LIB$ERASE_PAGE (LINE_ONE,COL_ONE);

    { +
    Plot that graph, tote that barge, lift that bale...
    - }
    EDF$GRAPH (
		GRAPH_TYPE,
		XY_ARRAY,
		CURRENT_GRAPH_INDEX,
		GRAPH_SWITCH,
		Y_HIGH,
		Y_LOW,
		Y_INCR,
		Y_LABEL,
		COLOR_ARRAY
		);

    { +
    Only DEC_CRTs can scroll only at the bottom, so if we don't have one of
    those, always do a complete screen rewrite (in case of full screen scroll).
    - }
    IF DEC_CRT THEN

	FIRST_PLOT	:= FALSE;

END;	{ PLOT_SIMPLE_GRAPH }

{ ++

PLOT_SURFACE_GRAPH -- Calculate index depths and plot them.

This routine figures out what the index depths will be for all bucketsizes
and plots them on the screen.

CALLING SEQUENCE:

PLOT_SURFACE_GRAPH;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

SYS$OUTPUT:
BLOCKS_IN_BUCKET
XY_ARRAY

ROUTINES CALLED:

PROLOGUE3_DEPTH
EDF$GRAPH

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE PLOT_SURFACE_GRAPH;

VAR
    GRAPH_SWITCH	: INTEGER;

BEGIN

    IF FIRST_PLOT THEN

    BEGIN

	{ +
	Hard set the graph index if this is the 1st time through.
	Plus set the graph switch to non-move-mode to plot the entire
	axis as well as the points.
	- }
	GRAPH_SWITCH		:= -1;
	CURRENT_GRAPH_INDEX	:= 0;
	LAST_GRAPH_INDEX	:= 1;

    END	{ IF TRUE FIRST_PLOT }

    ELSE

	{ +
	Not the 1st time through, just 'move' the points from their
	last position.
	- }
	GRAPH_SWITCH		:= 1;

    CURRENT_GRAPH_INDEX	:= 0;	{ meaningless on with surfaces }

    { +
    Since edfgrf doesn't for VT125s...
    - }
    IF REGIS THEN

	{ +
	Can't use CLEAR (SCREEN) because that also does a graphics clear.
	- }
	STATUS	:= LIB$ERASE_PAGE (LINE_ONE,COL_ONE);

    EDF$GRAPH (
		GRAPH_TYPE,
		XY_ARRAY,
		CURRENT_GRAPH_INDEX,
		GRAPH_SWITCH,
		Y_HIGH,
		Y_LOW,
		Y_INCR,
		Y_LABEL,
		COLOR_ARRAY
		);

    { +
    Only DEC_CRTs can scroll only at the bottom, so if we don't have one of
    those, always do a complete screen rewrite (in case of full screen scroll).
    - }
    IF DEC_CRT THEN

	FIRST_PLOT	:= FALSE;

END;	{ PLOT_SURFACE_GRAPH }

{ ++

WARN_OF_ERASE -- Tell user we're about to clobber his definition.

This routine warns the user that we're about to erase the definition and
asks for confirmation.

CALLING SEQUENCE:

BOOLEAN := WARN_OF_ERASE;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

none

ROUTINES CALLED:

none

ROUTINE VALUE:

TRUE/FALSE DEPENDING ON HIS CONFIRMATION

SIGNALS:

none

SIDE EFFECTS:

none

-- }

FUNCTION WARN_OF_ERASE : BOOLEAN;

VAR
    CLEAR_OK	: BOOLEAN;

BEGIN

    { +
    If the list has more than the IDENT in it,
    query the user about replacing it.
    - }
    CLEAR_OK	:= TRUE;

    IF (
    (DEF_HEAD <> DEF_TAIL)
    OR
    (DEF_HEAD^.PRIMARY <> IDENT)
    ) THEN

    BEGIN

	IF (
	((SCRIPT_OPTION = REDESIGN_FDL) OR (SCRIPT_OPTION = OPTIMIZE_FDL))
	AND
	(DESIGN_ORG = INDEXED)
	) THEN

	BEGIN

	    WRITE (SHIFT,ANSI_REVERSE,DASH,
	    ' This Key Definition will be Replaced during the ');

	    IF NOT OPTIMIZING THEN

		WRITELN ('Redesign. ',DASH,ANSI_RESET)

	    ELSE

		WRITELN ('Optimization. ',DASH,ANSI_RESET);

	END

	ELSE

	    WRITELN (SHIFT,ANSI_REVERSE,DASH,
	    ' The Current Definition will be Erased Now. ',
	    DASH,ANSI_RESET);

	{ +
	Ask for his confirmation.
	- }
	CLEAR_OK	:= ASK_CONFIRM;

    END;	{ IF TRUE DEF_HEAD <> DEF_TAIL }

    WARN_OF_ERASE	:= CLEAR_OK;

END;	{ WARN_OF_ERASE }

{ ++

NON_KEY_DEF -- Put into the definition the File, Record, etc stuff.

This routine handles the initial addition of the non-repeating attributes.

CALLING SEQUENCE:

NON_KEY_DEF;

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

PROCEDURE NON_KEY_DEF;

BEGIN

    { +
    Get the rest of the non-key data.
    - }
    ASK_FDL_TITLE;
    ASK_DATA_FILE_NAME;
    ASK_GLOBAL_WANTED;
    ASK_CARR_CTRL;

    { +
    Now make up the rest of the definition.
    - }
    IF TITLE_WANTED THEN

    BEGIN

	MAKE_SCRATCH;

	WITH DEF_SCRATCH^ DO

	BEGIN

	    { +
	    TITLE primary.
	    - }
	    NEW (STRING.DSC$A_POINTER);
	    STRING.DSC$A_POINTER^	:= FDL_TITLE_DESC.DSC$A_POINTER^;
	    STRING.DSC$W_LENGTH		:= FDL_TITLE_DESC.DSC$W_LENGTH;
	    STRING.DSC$B_DTYPE		:= FDL_TITLE_DESC.DSC$B_DTYPE;
	    STRING.DSC$B_CLASS		:= FDL_TITLE_DESC.DSC$B_CLASS;

	    PRIMARY			:= TITLE;
	    PRINUM			:= 0;
	    SECONDARY			:= DUMMY_SECONDARY$;
	    SECNUM			:= 0;
	    OBJECT_TYPE			:= PRI;
	    COMMENT.DSC$W_LENGTH	:= 0;
	    COMMENT.DSC$A_POINTER	:= NIL;

	    INSERT_IN_ORDER (REPLACE_OBJ);
	    STR$FREE1_DX (FDL_TITLE_DESC);

	END;	{ WITH DEF_SCRATCH^ DO }

    END		{ IF TRUE TITLE_WANTED }

    ELSE

    BEGIN

	IF FIND_OBJECT (PRI,TITLE,0,DUMMY_SECONDARY$,0) THEN

	    DELETE_CURRENT;

    END;	{ IF FALSE TITLE_WANTED }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	SYSTEM primary.
	- }
	OBJECT_TYPE		:= PRI;
	PRIMARY			:= SYSTEM;
	PRINUM			:= 0;
	SECONDARY		:= DUMMY_SECONDARY$;
	SECNUM			:= 0;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	SOURCE Secondary.
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= SYSTEM;
	PRINUM			:= 0;
	SECONDARY		:= SOURCE;
	SECNUM			:= 0;
	QUALIFIER		:= VAXVMS;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	FILE primary.
	- }
	OBJECT_TYPE		:= PRI;
	PRIMARY			:= FILE$;
	PRINUM			:= 0;
	SECONDARY		:= DUMMY_SECONDARY$;
	SECNUM			:= 0;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    { +
    GLOBAL_BUFFER_COUNT secondary.
    - }
    IF GLOBAL_WANTED THEN

    BEGIN

	MAKE_SCRATCH;

	WITH DEF_SCRATCH^ DO

	BEGIN

	    OBJECT_TYPE			:= SEC;
	    PRIMARY			:= FILE$;
	    PRINUM			:= 0;
	    SECONDARY			:= GLOBAL_BUFFER_COUNT;
	    SECNUM			:= 0;
	    NUMBER			:= GLOBAL_COUNT;
	    COMMENT.DSC$W_LENGTH	:= 0;
	    COMMENT.DSC$A_POINTER	:= NIL;
	    STRING.DSC$W_LENGTH		:= 0;
	    STRING.DSC$A_POINTER	:= NIL;

	    INSERT_IN_ORDER (REPLACE_OBJ);

	END;	{ WITH DEF_SCRATCH^ DO }

    END		{ IF TRUE GLOBAL_WANTED }

    ELSE

    BEGIN

	IF FIND_OBJECT (SEC,FILE$,0,GLOBAL_BUFFER_COUNT,0) THEN

	    DELETE_CURRENT;

    END;	{ IF FALSE GLOBAL_WANTED }

    { +
    NAME secondary.
    - }
    IF FILENAME_WANTED THEN

    BEGIN

	MAKE_SCRATCH;

	WITH DEF_SCRATCH^ DO

	BEGIN

	    NEW (STRING.DSC$A_POINTER);
	    STRING.DSC$A_POINTER^	:= DATA_FILE_NAME_DESC.DSC$A_POINTER^;
	    STRING.DSC$W_LENGTH		:= DATA_FILE_NAME_DESC.DSC$W_LENGTH;
	    STRING.DSC$B_DTYPE		:= DATA_FILE_NAME_DESC.DSC$B_DTYPE;
	    STRING.DSC$B_CLASS		:= DATA_FILE_NAME_DESC.DSC$B_CLASS;

	    PRIMARY			:= FILE$;
	    PRINUM			:= 0;
	    SECONDARY			:= NAME;
	    SECNUM			:= 0;
	    OBJECT_TYPE			:= SEC;
	    COMMENT.DSC$W_LENGTH	:= 0;
	    COMMENT.DSC$A_POINTER	:= NIL;

	    INSERT_IN_ORDER (REPLACE_OBJ);
	    STR$FREE1_DX (DATA_FILE_NAME_DESC);

	END;	{ WITH DEF_SCRATCH^ }

    END		{ IF TRUE FILENAME_WANTED }

    ELSE

    BEGIN

	IF FIND_OBJECT (SEC,FILE$,0,NAME,0) THEN

	    DELETE_CURRENT;

    END;	{ IF FALSE FILENAME_WANTED }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	ORGANIZATION secondary.
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= FILE$;
	PRINUM			:= 0;
	SECONDARY		:= ORGANIZATION;
	SECNUM			:= 0;
	QUALIFIER		:= DESIGN_ORG;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	RECORD primary.
	- }
	OBJECT_TYPE		:= PRI;
	PRIMARY			:= RECORD$;
	PRINUM			:= 0;
	SECONDARY		:= DUMMY_SECONDARY$;
	SECNUM			:= 0;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    IF DESIGN_ORG = SEQUENTIAL THEN

    BEGIN

	{ +
	BLOCK_SPAN secondary.
	- }
	MAKE_SCRATCH;

	WITH DEF_SCRATCH^ DO

	BEGIN

	    PRIMARY			:= RECORD$;
	    PRINUM			:= 0;
	    SECONDARY			:= BLOCK_SPAN;
	    SECNUM			:= 0;
	    OBJECT_TYPE			:= SEC;
	    SWITCH			:= BLOCK_SPAN_ALLOWED;
	    COMMENT.DSC$W_LENGTH	:= 0;
	    COMMENT.DSC$A_POINTER	:= NIL;
	    STRING.DSC$W_LENGTH		:= 0;
	    STRING.DSC$A_POINTER	:= NIL;

	    INSERT_IN_ORDER (REPLACE_OBJ);

	END;	{ WITH DEF_SCRATCH^ DO }

    END;	{ IF TRUE DESIGN_ORG = SEQUENTIAL }

    { +
    CARRIAGE_CONTROL secondary.
    - }
    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	PRIMARY			:= RECORD$;
	PRINUM			:= 0;
	SECONDARY		:= CARRIAGE_CONTROL;
	SECNUM			:= 0;
	OBJECT_TYPE		:= SEC;
	QUALIFIER		:= CARR_CTRL;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;

    IF (
    ((DESIGN_ORG = SEQUENTIAL) OR (DESIGN_ORG = RELATIVE))
    AND
    (RECORD_FORMAT = VFC)
    ) THEN

    BEGIN

	{ +
	CONTROL_FIELD_SIZE secondary.
	- }
	MAKE_SCRATCH;
    
	WITH DEF_SCRATCH^ DO
    
	BEGIN
    
	    OBJECT_TYPE			:= SEC;
	    PRIMARY			:= RECORD$;
	    PRINUM			:= 0;
	    SECONDARY			:= CONTROL_FIELD_SIZE;
	    SECNUM			:= 0;
	    NUMBER			:= CONTROL_SIZE;
	    COMMENT.DSC$W_LENGTH	:= 0;
	    COMMENT.DSC$A_POINTER	:= NIL;
	    STRING.DSC$W_LENGTH		:= 0;
	    STRING.DSC$A_POINTER	:= NIL;
    
	    INSERT_IN_ORDER (REPLACE_OBJ);
    
	END;

    END;	{ IF DESIGN_ORG = SEQ OR REL AND RECORD_FORMAT = VFC }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	FORMAT secondary.
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= RECORD$;
	PRINUM			:= 0;
	SECONDARY		:= FORMAT;
	SECNUM			:= 0;
	QUALIFIER		:= RECORD_FORMAT;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    { +
    SIZE secondary.
    - }
    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	OBJECT_TYPE		:= SEC;
	PRIMARY			:= RECORD$;
	PRINUM			:= 0;
	SECONDARY		:= SIZE;
	SECNUM			:= 0;
	NUMBER			:= MAX_RECORD_SIZE;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;

END;	{ NON_KEY_DEF }

{ ++

ROUND_ALLOC -- Make the allocation numbers look more reasonable.

This routine makes the allocations more conservative and also more 'even'.

CALLING SEQUENCE:

NEW_ALLOC	:= ROUND_ALLOC (ALLOC);

INPUT PARAMETERS:

ALLOC

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

none

ROUTINES CALLED:

none

ROUTINE VALUE:

NEW_ALLOC

SIGNALS:

none

SIDE EFFECTS:

none

-- }

FUNCTION ROUND_ALLOC ( ALLOC : INTEGER ) : INTEGER;

VAR
    DIV_FRAC		: REAL;
    TEMP_REAL		: REAL;
    TEMP_INT2		: INTEGER;
    TEMP_INTEGER	: INTEGER;

BEGIN

    TEMP_INT2		:= NUM_LEN (ALLOC) DIV 2;
    TEMP_INTEGER	:= 10 ** TEMP_INT2;

    IF TEMP_INTEGER < 1 THEN

	TEMP_INTEGER	:= 1;

    TEMP_REAL		:= TEMP_INTEGER;
    DIV_FRAC		:= (ALLOC/TEMP_INTEGER) - TRUNC (ALLOC/TEMP_INTEGER);
    ALLOC		:= ROUND (ALLOC/TEMP_INTEGER);
    ALLOC		:= ROUND (ALLOC * TEMP_REAL);

    IF DIV_FRAC < 0.5 THEN

	ALLOC		:= ALLOC + ROUND (TEMP_REAL * 0.5);

    ROUND_ALLOC		:= ALLOC;

END;	{ ROUND_ALLOC }

{ ++

CALC_ALLOC -- Calculate the allocation for seq and rel files.

This routine handles the calculations for allocation for seq and rel files.

CALLING SEQUENCE:

ALLOC	:= CALC_ALLOC (RECORD_TOT);

INPUT PARAMETERS:

RECORD_TOT

IMPLICIT INPUTS:

none

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:


ROUTINES CALLED:

none

ROUTINE VALUE:

ALLOCATION CALCULATED

SIGNALS:

none

SIDE EFFECTS:

none

-- }

FUNCTION CALC_ALLOC (RECORD_TOT : INTEGER) : INTEGER;

VAR
    ALLOC	: INTEGER;
    RATIO	: REAL;
    BYTES_REAL	: REAL;
    NUMRECS_REAL : REAL;

BEGIN

    { +
    Now let's figure out the allocation needed.
    - }
    BYTES_REAL		:= RECORD_TOT;
    NUMRECS_REAL	:= INITIAL_COUNT;
    RATIO		:= BYTES_REAL / 512.0;

    IF (RATIO * NUMRECS_REAL) > EDF$C_1GIGA THEN

	CALC_ALLOC	:= EDF$C_1GIGA

    ELSE

    BEGIN

	ALLOC		:= ROUND (RATIO * NUMRECS_REAL);
	CALC_ALLOC	:= ROUND_ALLOC (ALLOC);

    END;

END;	{ CALC_ALLOC }

{ ++

SEQ_DEF -- Handle seq file stuff.

This routine handles the addition of the sequential file attributes.

CALLING SEQUENCE:

SEQ_DEF;

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

PROCEDURE SEQ_DEF;

VAR
    ALLOC	: INTEGER;
    RECORD_TOT	: INTEGER;
    RECORD_INT	: INTEGER;
    RECORD_REAL	: REAL;

BEGIN

    { +
    Figure out how big each record is.
    - }
    RECORD_TOT		:= MEAN_RECORD_SIZE;

    IF VARIABLE_RECORDS THEN

	RECORD_TOT	:= RECORD_TOT + 2;

    { +
    Assumes record size is less than 512 if block_span_allowed is false.
    - }
    IF NOT BLOCK_SPAN_ALLOWED THEN

    BEGIN

	{ +
	Increase the virtual size of each record so that it looks like
	an integer number of them fit in a block.
	- }
	RECORD_REAL	:= 512.0 / RECORD_TOT;
	RECORD_INT	:= TRUNC (RECORD_REAL);
	RECORD_TOT	:= 512 DIV RECORD_INT;

    END;

    ALLOC		:= CALC_ALLOC (RECORD_TOT);

    { +
    Now actually stuff the secondary from the above calculations.
    - }
    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	ALLOCATION secondary.
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= FILE$;
	PRINUM			:= 0;
	SECONDARY		:= ALLOCATION;
	SECNUM			:= 0;
	NUMBER			:= ALLOC;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	BEST_TRY_CONTIGUOUS secondary.
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= FILE$;
	PRINUM			:= 0;
	SECONDARY		:= BEST_TRY_CONTIGUOUS;
	SECNUM			:= 0;
	SWITCH			:= TRUE;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	EXTENSION secondary.
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= FILE$;
	PRINUM			:= 0;
	SECONDARY		:= EXTENSION;
	SECNUM			:= 0;
	NUMBER			:= ALLOC DIV 10;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

END;	{ SEQ_DEF }

{ ++

REL_DEF -- Handle relative file stuff.

This routine handles the addition of the relative file attributes.

CALLING SEQUENCE:

REL_DEF;

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

PROCEDURE REL_DEF;

VAR
    ALLOC		: INTEGER;
    RECORD_TOT		: INTEGER;
    BUCKET_TOT		: INTEGER;
    BUCKET		: INTEGER;
    RECS_PER_BUCKET	: INTEGER;
    NUM_BUCKETS		: INTEGER;

BEGIN

    { +
    See how the user is going to access his records.
    - }
    ASK_SUCCESSIVE_CLOSE;

    { +
    Calculate how large the bucketsize should be.
    (random: 4 * record_size; close 16 * record_size)
    - }
    RECORD_TOT		:= MAX_RECORD_SIZE + 1;

    IF VARIABLE_RECORDS THEN

	RECORD_TOT	:= RECORD_TOT + 2;

    IF SUCCESSIVE_CLOSE THEN

	BUCKET_TOT	:= 16 * RECORD_TOT

    ELSE

	BUCKET_TOT	:= 4 * RECORD_TOT;

    BUCKET		:= BUCKET_TOT DIV 512;

    IF BUCKET < 1 THEN

	BUCKET		:= 1;

    IF (BUCKET_TOT MOD 512) <> 0 THEN

	BUCKET		:= BUCKET + 1;

    IF BUCKET > 32 THEN

	BUCKET		:= 32;

    RECS_PER_BUCKET	:= (BUCKET * 512) DIV RECORD_TOT;

    IF RECS_PER_BUCKET < 1 THEN

	RECS_PER_BUCKET	:= 1;

    NUM_BUCKETS		:= INITIAL_COUNT DIV RECS_PER_BUCKET;

    IF NUM_BUCKETS < 1 THEN

	NUM_BUCKETS	:= 1;

    IF (INITIAL_COUNT MOD RECS_PER_BUCKET) <> 0 THEN

	NUM_BUCKETS	:= NUM_BUCKETS + 1;

    ALLOC		:= ROUND_ALLOC (BUCKET * NUM_BUCKETS);

    { +
    Now actually stuff the secondary from the above calculations.
    - }
    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	ALLOCATION secondary.
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= FILE$;
	PRINUM			:= 0;
	SECONDARY		:= ALLOCATION;
	SECNUM			:= 0;
	NUMBER			:= ALLOC;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	BEST_TRY_CONTIGUOUS secondary.
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= FILE$;
	PRINUM			:= 0;
	SECONDARY		:= BEST_TRY_CONTIGUOUS;
	SECNUM			:= 0;
	SWITCH			:= TRUE;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	BUCKET_SIZE secondary.
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= FILE$;
	PRINUM			:= 0;
	SECONDARY		:= BUCKET_SIZE;
	SECNUM			:= 0;
	NUMBER			:= BUCKET;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	EXTENSION secondary.
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= FILE$;
	PRINUM			:= 0;
	SECONDARY		:= EXTENSION;
	SECNUM			:= 0;
	NUMBER			:= ALLOC DIV 10;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

END;	{ REL_DEF }

{ ++

APPEND_DEF -- Add a key/areas def segment onto the end of the definition.

This routine puts all the attributes for a key and its areas onto the tail
of the linked list.

CALLING SEQUENCE:

APPEND_DEF;

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

PROCEDURE APPEND_DEF;

VAR
    INIT_DATA_ALLOC		: INTEGER;
    INIT_INDEX_ALLOC		: INTEGER;
    ADDED_DATA_ALLOC		: INTEGER;
    ADDED_INDEX_ALLOC		: INTEGER;
    DATA_ALLOC			: INTEGER;
    INDEX_ALLOC			: INTEGER;
    DATA_EXT			: INTEGER;
    INDEX_EXT			: INTEGER;
    USED_DATA_BUCKETS		: INTEGER;
    UNUSED_DATA_BUCKETS		: INTEGER;
    USED_INDEX_BUCKETS		: INTEGER;
    UNUSED_INDEX_BUCKETS	: INTEGER;
    CHOSEN_DEPTH		: INTEGER;
    CHOSEN_DEPTH2		: INTEGER;
    TEMP_ALLOC			: INTEGER;
    I				: INTEGER;

BEGIN

    { +
    Get the user's decision on the value of the plotted file parameter.
    - }
    IF DESIGN_STYLE = SURFACE_PLOT THEN

	CASE SURFACE_OPTION OF

	    FILL_SURFACE :	ASK_FILL;

	    INIT_SURFACE :	ASK_INITIAL_COUNT;

	    ADDED_SURFACE :	ASK_ADDED_COUNT;

	    KEY_SURFACE :	ASK_KEY_SIZE;

	    SIZE_SURFACE :

	    BEGIN

		ASK_REC_SIZE;

		{ +
		Redo the SIZE secondary if this was a Record Size Surface.
		- }
		MAKE_SCRATCH;

		WITH DEF_SCRATCH^ DO
	    
		BEGIN
	    
		    OBJECT_TYPE			:= SEC;
		    PRIMARY			:= RECORD$;
		    SECONDARY			:= SIZE;
		    SECNUM			:= 0;
		    NUMBER			:= MAX_RECORD_SIZE;
		    COMMENT.DSC$W_LENGTH	:= 0;
		    COMMENT.DSC$A_POINTER	:= NIL;
		    STRING.DSC$W_LENGTH		:= 0;
		    STRING.DSC$A_POINTER	:= NIL;
	    
		    INSERT_IN_ORDER (REPLACE_OBJ);
	    
		END;	{ WITH DEF_SCRATCH^ DO }

	    END;	{ SIZE_SURFACE }

	OTHERWISE

	    { +
	    BUGCHECK!!
	    - }
	    LIB$SIGNAL (EDF$_INTSWERR,1,24,0);

	END;	{ CASE }

    { +
    See what bucketsize the user chose and recalculate the depth
    based on that bucketsize alone.  Find out the most reasonable
    bucketsize default by looking for the left end of the 'natural depth'.
    - }
    BUCKET_DEFAULT	:= NATURAL_DEPTH;

    ASK_BUCKET;

    CHOSEN_DEPTH	:= PROLOGUE3_DEPTH;

    { +
    Now finish getting the info to flesh out the FDL definition.
    - }
    ASK_KEY_CHANGES;
    ASK_KEY_NAME;

    { +
    Figure the index allocation at the same time, though.
    - }
    INIT_DATA_ALLOC	:= INIT_NUMBER_BUCKETS[0];
    ADDED_DATA_ALLOC	:= ADDED_NUMBER_BUCKETS[0];

    { +
    Find total number of buckets in index.
    - }
    INIT_INDEX_ALLOC	:= 0;
    ADDED_INDEX_ALLOC	:= 0;

    FOR I := 1 TO CHOSEN_DEPTH DO

    BEGIN

	INIT_INDEX_ALLOC	:= INIT_INDEX_ALLOC + INIT_NUMBER_BUCKETS[I];
	ADDED_INDEX_ALLOC	:= ADDED_INDEX_ALLOC + ADDED_NUMBER_BUCKETS[I];

    END;

    { +
    Now merge any additional records into the existing ones.
    - }
    IF ADDED_COUNT <> 0 THEN

    BEGIN

	USED_DATA_BUCKETS	:= TRUNC (LOAD_FILL * INIT_DATA_ALLOC) + 1;
	USED_INDEX_BUCKETS	:= TRUNC (LOAD_FILL * INIT_INDEX_ALLOC) + 1;
	UNUSED_DATA_BUCKETS	:= INIT_DATA_ALLOC - USED_DATA_BUCKETS;
	UNUSED_INDEX_BUCKETS	:= INIT_INDEX_ALLOC - USED_INDEX_BUCKETS;

	IF ADDED_DATA_ALLOC > UNUSED_DATA_BUCKETS THEN

	    ADDED_DATA_ALLOC	:= ADDED_DATA_ALLOC - UNUSED_DATA_BUCKETS

	ELSE

	    ADDED_DATA_ALLOC	:= 0;

	IF ADDED_INDEX_ALLOC > UNUSED_INDEX_BUCKETS THEN

	    ADDED_INDEX_ALLOC	:= ADDED_INDEX_ALLOC - UNUSED_INDEX_BUCKETS

	ELSE

	    ADDED_INDEX_ALLOC	:= 0;

	IF ADDED_DATA_ALLOC > 0 THEN

	    INIT_DATA_ALLOC	:= INIT_DATA_ALLOC + ADDED_DATA_ALLOC;

	IF ADDED_INDEX_ALLOC > 0 THEN

	    INIT_INDEX_ALLOC	:= INIT_INDEX_ALLOC + ADDED_INDEX_ALLOC;

    END;	{ IF TRUE ADDED_COUNT <> 0 }

    { +
    Calc to get total number of blocks for that many buckets.
    And also round the allocations 'slightly' up.
    Double check boundaries to prevent integer overflows. Enforce max of 1Giga.
    - }
    IF INIT_DATA_ALLOC > (EDF$C_1GIGA DIV BLOCKS_IN_BUCKET) THEN

	DATA_ALLOC	:= EDF$C_1GIGA

    ELSE

	DATA_ALLOC	:= ROUND_ALLOC (INIT_DATA_ALLOC * BLOCKS_IN_BUCKET);

    IF INIT_INDEX_ALLOC > (EDF$C_1GIGA DIV BLOCKS_IN_BUCKET) THEN

	INDEX_ALLOC	:= EDF$C_1GIGA

    ELSE

	INDEX_ALLOC	:= ROUND_ALLOC (INIT_INDEX_ALLOC * BLOCKS_IN_BUCKET);

    { +
    Make the area primary.
    - }
    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	AREA m primary (for data).
	- }
	OBJECT_TYPE		:= PRI;
	PRIMARY			:= AREA;

	IF ACTIVE_KEY < 127 THEN

	    PRINUM		:= (2*ACTIVE_KEY)

	ELSE

	    PRINUM		:= 254;

	SECONDARY		:= DUMMY_SECONDARY$;
	SECNUM			:= 0;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    { +
    Now actually stuff the secondary from the above calculations.
    - }
    IF ACTIVE_KEY < 127 THEN

	TEMP_ALLOC	:= 0

    ELSE IF FIND_OBJECT (SEC,AREA,254,ALLOCATION$,0) THEN

	TEMP_ALLOC	:= DEF_CURRENT^.NUMBER

    ELSE

	TEMP_ALLOC	:= 0;

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	ALLOCATION secondary (for data area).
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= AREA;

	IF ACTIVE_KEY < 127 THEN

	    PRINUM		:= (2*ACTIVE_KEY)

	ELSE

	    PRINUM		:= 254;

	SECONDARY		:= ALLOCATION$;
	SECNUM			:= 0;
	NUMBER			:= DATA_ALLOC + TEMP_ALLOC;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	BEST_TRY_CONTIGUOUS secondary (for data area).
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= AREA;

	IF ACTIVE_KEY < 127 THEN

	    PRINUM		:= (2*ACTIVE_KEY)

	ELSE

	    PRINUM		:= 254;

	SECONDARY		:= BEST_TRY_CONTIGUOUS$;
	SECNUM			:= 0;
	SWITCH			:= TRUE;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	BUCKET_SIZE secondary (for data area).
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= AREA;

	IF ACTIVE_KEY < 127 THEN

	    PRINUM		:= (2*ACTIVE_KEY)

	ELSE

	    PRINUM		:= 254;

	SECONDARY		:= BUCKET_SIZE$;
	SECNUM			:= 0;
	NUMBER			:= BLOCKS_IN_BUCKET;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	EXTENSION secondary (for data area).
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= AREA;

	IF ACTIVE_KEY < 127 THEN

	    PRINUM		:= (2*ACTIVE_KEY)

	ELSE

	    PRINUM		:= 254;

	SECONDARY		:= EXTENSION$;
	SECNUM			:= 0;
	NUMBER			:= (DATA_ALLOC + TEMP_ALLOC) DIV 10;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	AREA n primary (for index).
	- }
	OBJECT_TYPE		:= PRI;
	PRIMARY			:= AREA;

	IF ACTIVE_KEY < 127 THEN

	    PRINUM		:= (1+(2*ACTIVE_KEY))

	ELSE

	    PRINUM		:= 255;

	SECONDARY		:= DUMMY_SECONDARY$;
	SECNUM			:= 0;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    MAKE_SCRATCH;

    IF ACTIVE_KEY < 127 THEN

	TEMP_ALLOC	:= 0

    ELSE IF FIND_OBJECT (SEC,AREA,255,ALLOCATION$,0) THEN

	TEMP_ALLOC	:= DEF_CURRENT^.NUMBER

    ELSE

	TEMP_ALLOC	:= 0;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	ALLOCATION secondary (for index area).
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= AREA;

	IF ACTIVE_KEY < 127 THEN

	    PRINUM		:= (1+(2*ACTIVE_KEY))

	ELSE

	    PRINUM		:= 255;

	SECONDARY		:= ALLOCATION$;
	SECNUM			:= 0;
	NUMBER			:= INDEX_ALLOC + TEMP_ALLOC;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	BEST_TRY_CONTIGUOUS secondary (for index area).
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= AREA;

	IF ACTIVE_KEY < 127 THEN

	    PRINUM		:= (1+(2*ACTIVE_KEY))

	ELSE

	    PRINUM		:= 255;

	SECONDARY		:= BEST_TRY_CONTIGUOUS$;
	SECNUM			:= 0;
	SWITCH			:= TRUE;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	BUCKET_SIZE secondary (for index area).
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= AREA;

	IF ACTIVE_KEY < 127 THEN

	    PRINUM		:= (1+(2*ACTIVE_KEY))

	ELSE

	    PRINUM		:= 255;

	SECONDARY		:= BUCKET_SIZE$;
	SECNUM			:= 0;
	NUMBER			:= BLOCKS_IN_BUCKET;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	EXTENSION secondary (for index area).
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= AREA;

	IF ACTIVE_KEY < 127 THEN

	    PRINUM		:= (1+(2*ACTIVE_KEY))

	ELSE

	    PRINUM		:= 255;

	SECONDARY		:= EXTENSION$;
	SECNUM			:= 0;
	NUMBER			:= (INDEX_ALLOC + TEMP_ALLOC) DIV 10;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	KEY n primary.
	- }
	OBJECT_TYPE		:= PRI;
	PRIMARY			:= KEY;
	PRINUM			:= ACTIVE_KEY;
	SECONDARY		:= DUMMY_SECONDARY$;
	SECNUM			:= 0;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	CHANGES secondary.
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= KEY;
	PRINUM			:= ACTIVE_KEY;
	SECONDARY		:= CHANGES;
	SECNUM			:= 0;
	SWITCH			:= KEY_CHANGES;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	DATA_AREA secondary.
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= KEY;
	PRINUM			:= ACTIVE_KEY;
	SECONDARY		:= DATA_AREA;
	SECNUM			:= 0;

	IF ACTIVE_KEY < 127 THEN

	    NUMBER		:= (2*ACTIVE_KEY)

	ELSE

	    NUMBER		:= 254;

	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	DATA_FILL secondary.
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= KEY;
	PRINUM			:= ACTIVE_KEY;
	SECONDARY		:= DATA_FILL;
	SECNUM			:= 0;
	NUMBER			:= FDL_FILL;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	DUPLICATES secondary.
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= KEY;
	PRINUM			:= ACTIVE_KEY;
	SECONDARY		:= DUPLICATES;
	SECNUM			:= 0;
	SWITCH			:= KEY_DUPS;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	INDEX_AREA secondary.
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= KEY;
	PRINUM			:= ACTIVE_KEY;
	SECONDARY		:= INDEX_AREA;
	SECNUM			:= 0;

	IF ACTIVE_KEY < 127 THEN

	    NUMBER		:= (1+(2*ACTIVE_KEY))

	ELSE

	    NUMBER		:= 255;

	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	INDEX_FILL secondary.
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= KEY;
	PRINUM			:= ACTIVE_KEY;
	SECONDARY		:= INDEX_FILL;
	SECNUM			:= 0;
	NUMBER			:= FDL_FILL;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    { +
    LENGTH secondary.
    - }
    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	OBJECT_TYPE		:= SEC;
	PRIMARY			:= KEY;
	PRINUM			:= ACTIVE_KEY;
	SECONDARY		:= SEG_LENGTH;
	SECNUM			:= 0;
	NUMBER			:= KEY_SIZE;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	LEVEL1_INDEX_AREA secondary.
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= KEY;
	PRINUM			:= ACTIVE_KEY;
	SECONDARY		:= LEVEL1_INDEX_AREA;
	SECNUM			:= 0;

	IF ACTIVE_KEY < 127 THEN

	    NUMBER		:= (1+(2*ACTIVE_KEY))

	ELSE

	    NUMBER		:= 255;

	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    { +
    NAME secondary.
    - }
    IF KEYNAME_WANTED THEN

    BEGIN

	MAKE_SCRATCH;

	WITH DEF_SCRATCH^ DO
    
	BEGIN
    
	    OBJECT_TYPE			:= SEC;
    
	    NEW (STRING.DSC$A_POINTER);
	    STRING.DSC$A_POINTER^	:= KEY_NAME_DESC.DSC$A_POINTER^;
	    STRING.DSC$W_LENGTH		:= KEY_NAME_DESC.DSC$W_LENGTH;
	    STRING.DSC$B_DTYPE		:= KEY_NAME_DESC.DSC$B_DTYPE;
	    STRING.DSC$B_CLASS		:= KEY_NAME_DESC.DSC$B_CLASS;
    
	    PRIMARY			:= KEY;
	    PRINUM			:= ACTIVE_KEY;
	    SECONDARY			:= NAME$;
	    SECNUM			:= 0;
	    COMMENT.DSC$W_LENGTH	:= 0;
	    COMMENT.DSC$A_POINTER	:= NIL;
    
	    INSERT_IN_ORDER (REPLACE_OBJ);
	    STR$FREE1_DX (KEY_NAME_DESC);
    
	END;	{ WITH DEF_SCRATCH^ }

    END		{ IF TRUE KEYNAME_WANTED }

    ELSE

    BEGIN

	IF FIND_OBJECT (SEC,KEY,ACTIVE_KEY,NAME$,0) THEN

	    DELETE_CURRENT;

    END;	{ IF FALSE KEYNAME_WANTED }

    IF (
    (ACTIVE_KEY = 0)
    AND
    (PROLOGUE_VERSION_VALID)
    ) THEN

    BEGIN

	MAKE_SCRATCH;

	WITH DEF_SCRATCH^ DO

	BEGIN

	    { +
	    PROLOGUE secondary.
	    - }
	    OBJECT_TYPE			:= SEC;
	    PRIMARY			:= KEY;
	    PRINUM			:= ACTIVE_KEY; { = 0 }
	    SECONDARY			:= PROLOGUE;
	    SECNUM			:= 0;
	    NUMBER			:= PROLOGUE_VERSION;
	    COMMENT.DSC$W_LENGTH	:= 0;
	    COMMENT.DSC$A_POINTER	:= NIL;
	    STRING.DSC$W_LENGTH		:= 0;
	    STRING.DSC$A_POINTER	:= NIL;

	    INSERT_IN_ORDER (REPLACE_OBJ);

	END;	{ WITH DEF_SCRATCH^ DO }

    END;	{ IF (ACTIVE_KEY = 0) AND (PROLOGUE_VERSION_VALID) }

    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	{ +
	POSITION secondary.
	- }
	OBJECT_TYPE		:= SEC;
	PRIMARY			:= KEY;
	PRINUM			:= ACTIVE_KEY;
	SECONDARY		:= SEG_POSITION;
	SECNUM			:= 0;
	NUMBER			:= KEY_POSITION;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    { +
    TYPE secondary.
    - }
    MAKE_SCRATCH;

    WITH DEF_SCRATCH^ DO

    BEGIN

	PRIMARY			:= KEY;
	PRINUM			:= ACTIVE_KEY;
	SECONDARY		:= SEG_TYPE;
	SECNUM			:= 0;
	OBJECT_TYPE		:= SEC;
	QUALIFIER		:= KEY_TYPE;
	COMMENT.DSC$W_LENGTH	:= 0;
	COMMENT.DSC$A_POINTER	:= NIL;
	STRING.DSC$W_LENGTH	:= 0;
	STRING.DSC$A_POINTER	:= NIL;

	INSERT_IN_ORDER (REPLACE_OBJ);

    END;	{ WITH DEF_SCRATCH^ DO }

    { +
    Show the user what he has.
    - }
    CHOSEN_DEPTH2	:= CHOSEN_DEPTH + 1;

    WRITELN (
    CRLF,
    SHIFT,'The Depth of Key ',ACTIVE_KEY:ACTIVE_KEY_LENGTH,
    ' is Estimated to be No Greater',CRLF,
    SHIFT,
    'than ',
    CHOSEN_DEPTH:NUM_LEN(CHOSEN_DEPTH),' Index levels, which is ',
    CHOSEN_DEPTH2:NUM_LEN(CHOSEN_DEPTH2),' Total levels.'
    );

    ASK_RETURN;

END;	{ APPEND_DEF }

{ ++

LINK_RESULTS -- Incorporate the 'designed' variables into the linked list.

This routine puts the final state of the variables into the Definition.

CALLING SEQUENCE:

LINK_RESULTS;

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

PROCEDURE LINK_RESULTS;

BEGIN

    { +
    Put the terminal back and announce what phase we're in.
    - }
    EDF$RESET_SCROLL;

    CLEAR (SCREEN);

    WRITE (SHIFT,TAB,TAB,ANSI_REVERSE,DASH,' Final ');

    CASE SCRIPT_OPTION OF

	DESIGN_FDL :		WRITE ('Design');
	OPTIMIZE_FDL :		WRITE ('Optimization');
	REDESIGN_FDL :		WRITE ('Redesign');

    OTHERWISE

	{ +
	BUGCHECK!!
	- }
	LIB$SIGNAL (EDF$_INTSWERR,1,25,0);

    END;	{ CASE }

    WRITELN (' Phase for Key ',
    ACTIVE_KEY:ACTIVE_KEY_LENGTH,' ',DASH,ANSI_RESET,CRLF);

    { +
    If this is the 1st time through, get the general file attributes.
    - }
    IF ACTIVE_KEY = 0 THEN

	NON_KEY_DEF;

    { +
    Add this key's data to the linked list.
    - }
    APPEND_DEF;

    LINKED	:= TRUE;

END;	{ LINK_RESULTS }

{ ++

CALC_ARRAY -- Do the calculations for a surface plot.

This routine sets up xy_array.

CALLING SEQUENCE:

CALC_ARRAY;

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

PROCEDURE CALC_ARRAY;

VAR
    I			: INTEGER;
    J			: INTEGER;
    TEMP_INTEGER	: INTEGER;
    TEMP_INT2		: INTEGER;

BEGIN

    WRITELN (SHIFT,'Working ...');

    IF SURFACE_OPTION = FILL_SURFACE THEN

	GRAPH_TYPE	:= EDF$C_SRF_DECREASING

    ELSE

	GRAPH_TYPE	:= EDF$C_SRF_INCREASING;

    CASE SURFACE_OPTION OF

	FILL_SURFACE :

	BEGIN

	    Y_LABEL	:= 'Initial Load Fill Percent       ';
	    DESIRED_FILL := Y_LOW;

	END;

	SIZE_SURFACE :

	BEGIN

	    IF VARIABLE_RECORDS THEN

		Y_LABEL	:= 'Mean Record Size                '

	    ELSE

		Y_LABEL	:= 'Record Size                     ';

	    MEAN_RECORD_SIZE	:= Y_LOW;

	END;

	KEY_SURFACE :

	BEGIN

	    Y_LABEL	:= 'Key Length                      ';
	    KEY_SIZE	:= Y_LOW;

	END;

	INIT_SURFACE :

	BEGIN

	    Y_LABEL	:= 'Initial Load Record Count       ';
	    INITIAL_COUNT := Y_LOW;

	END;

	ADDED_SURFACE :

	BEGIN

	    Y_LABEL	:= 'Additional Record Count         ';
	    ADDED_COUNT	:= Y_LOW;

	END;

    OTHERWISE

	{ +
	BUGCHECK!!
	- }
	LIB$SIGNAL (EDF$_INTSWERR,1,26,0);

    END;	{ CASE }

    FOR I := 0 TO MAX_ARRAY_ROW DO

    BEGIN

	FOR J := 0 TO 31 DO

	BEGIN

	    { +
	    Bump the bucketsize and recalculate.
	    - }
	    BLOCKS_IN_BUCKET	:= J + 1;
	    XY_ARRAY[I,J]	:= PROLOGUE3_DEPTH;

	END;	{ FOR J }

	{ +
	Fill the color_row, and copy that into the array.
	- }
	TEMP_INTEGER	:= NATURAL_DEPTH;

	FOR TEMP_INT2 := 0 TO 31 DO

	    COLOR_ARRAY[I,TEMP_INT2]	:= COLOR_ROW[TEMP_INT2];

	CASE SURFACE_OPTION OF

	    FILL_SURFACE :	DESIRED_FILL	:= DESIRED_FILL + Y_INCR;

	    SIZE_SURFACE :	MEAN_RECORD_SIZE := MEAN_RECORD_SIZE + Y_INCR;

	    KEY_SURFACE :	KEY_SIZE	:= KEY_SIZE + Y_INCR;

	    INIT_SURFACE :	INITIAL_COUNT	:= INITIAL_COUNT + Y_INCR;

	    ADDED_SURFACE :	ADDED_COUNT	:= ADDED_COUNT + Y_INCR;

	OTHERWISE

	    { +
	    BUGCHECK!!
	    - }
	    LIB$SIGNAL (EDF$_INTSWERR,1,27,0);

	END;	{ CASE }

    END;	{ FOR I }

END;	{ CALC_ARRAY }

{ ++

SETUP_SURFACE_GRAPHS -- Do the surface plots.

This routine sets up and calls EDF$GRAPH in surface mode.

CALLING SEQUENCE:

SETUP_SURFACE_GRAPHS;

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

PROCEDURE SETUP_SURFACE_GRAPHS;

BEGIN

    WRITELN;

    { +
    Now fill up the xy_array.
    - }
    IF SURFACE_OPTION = INIT_SURFACE THEN

	ASK_INITIAL_COUNT_RANGE

    ELSE

	ASK_INITIAL_COUNT;

    ASK_LOAD_METHOD;
    ASK_ASCENDING_LOAD;

    IF SURFACE_OPTION = ADDED_SURFACE THEN

	ASK_ADDED_COUNT_RANGE

    ELSE

	ASK_ADDED_COUNT;

    ASK_ASCENDING_ADDED;
    ASK_KEY_DIST;

    IF SURFACE_OPTION = FILL_SURFACE THEN

	ASK_FILL_RANGE

    ELSE

	ASK_FILL;

    ASK_RECORD_FORMAT;

    IF SURFACE_OPTION = SIZE_SURFACE THEN

	ASK_SIZE_RANGE

    ELSE

	ASK_REC_SIZE;

    ASK_KEY_TYPE;

    IF SURFACE_OPTION = KEY_SURFACE THEN

	ASK_KEY_RANGE

    ELSE

	ASK_KEY_SIZE;

    ASK_KEY_POSITION;
    ASK_KEY_DUPS;
    ASK_PROLOGUE_VERSION;
    ASK_DATA_KEY_COMP;
    ASK_DATA_RECORD_COMP;
    ASK_INDEX_RECORD_COMP;

    { +
    Now fill the xy_array.
    - }
    CALC_ARRAY;

END;	{ SETUP_SURFACE_GRAPHS }

{ ++

SURFACE_DESIGN -- Plot the surface graph.

This routine uses the surface graph to plot a 3 dim surface of values.

CALLING SEQUENCE:

SURFACE_DESIGN;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

CONTROL_ZEE_TYPED
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

CONTROL_ZEE_TYPED
SYS$OUTPUT:

ROUTINES CALLED:

ASK_SURFACE_OPTION
SETUP_SURFACE_GRAPHS

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE SURFACE_DESIGN;

BEGIN

    { +
    See what kind of surface graph he wants.
    - }
    ASK_SURFACE_OPTION;

    { +
    Find out what the user's parameters are, and fill the xy_array.
    - }
    SETUP_SURFACE_GRAPHS;
    VISIBLE_QUESTION	:= TRUE;
    { +
    Make bottom lines of screen scroll.
    - }
    STATUS		:= LIB$SET_SCROLL (PROMPT_LINE,LINES_PER_PAGE);
    SCROLLING_SET	:= TRUE;

    { +
    Init to do non-move on 1st time thru
    - }
    FIRST_PLOT		:= TRUE;

    { +
    Show the user the calculated depths.
    - }
    PLOT_SURFACE_GRAPH;

    { +
    This will loop until the user types control/Z or
    LINK_RESULTS makes LINKED true.
    - }
    LINKED	:= FALSE;

    WHILE NOT LINKED DO

    BEGIN

	{ +
	See what the user wants to vary.
	- }
	ASK_DESIGN_OPTION;

	CASE DESIGN_CYCLE OF

	    EDF$C_RF :		ASK_RECORD_FORMAT;

	    EDF$C_RS :		ASK_REC_SIZE;

	    EDF$C_KL :		ASK_KEY_SIZE;

	    EDF$C_BF :		ASK_FILL;

	    EDF$C_IL :		ASK_INITIAL_COUNT;

	    EDF$C_KP :		ASK_KEY_POSITION;

	    EDF$C_LM :		ASK_LOAD_METHOD;

	    EDF$C_AR :		ASK_ADDED_COUNT;

	    EDF$C_DK :		ASK_KEY_DUPS;

	    EDF$C_RC :		ASK_DATA_RECORD_COMP;

	    EDF$C_KC :		ASK_DATA_KEY_COMP;

	    EDF$C_IC :		ASK_INDEX_RECORD_COMP;

	    EDF$C_PV :		ASK_PROLOGUE_VERSION;

	    EDF$C_KT :		ASK_KEY_TYPE;

	    EDF$C_FINIS :	LINK_RESULTS;

	    EDF$C_WP :

	    BEGIN

		{ +
		This is the write fresh plot function.
		- }
		FIRST_PLOT	:= TRUE;
		PLOT_SURFACE_GRAPH;

	    END;

	OTHERWISE

	    LIB$SIGNAL (EDF$_INTSWERR,1,28,0);

	END;	{ CASE }

	{ +
	If we just finished putting up a new plot, or we're done,
	don't do it again.
	- }
	IF NOT ((DESIGN_CYCLE = EDF$C_WP) OR LINKED) THEN

	BEGIN

	    CALC_ARRAY;
	    PLOT_SURFACE_GRAPH;

	END;	{ IF DESIGN_CYCLE <> EDF$C_WP }

    END;	{ WHILE }

    EDF$RESET_SCROLL;

END;	{ SURFACE_DESIGN }

{ ++

LINE_DESIGN -- Let the user step through values interactively.

This routine uses move-mode in the simple graph to interact with the user.

CALLING SEQUENCE:

LINE_DESIGN;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

CONTROL_ZEE_TYPED
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

CONTROL_ZEE_TYPED
SYS$OUTPUT:

ROUTINES CALLED:

ASK_RECORD_FORMAT
ASK_REC_SIZE
ASK_KEY_SIZE
ASK_FILL
ASK_TOTAL
ASK_KEY_POSITION
ASK_NUMBER_RANDOM_INSERTS
ASK_NUMBER_DELETES
ASK_KEY_DUPS
ASK_DATA_KEY_COMP;
ASK_DATA_RECORD_COMP;
ASK_INDEX_RECORD_COMP;
ASK_DESIGN_OPTION
LIB$SET_SCROLL

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE LINE_DESIGN;

BEGIN

    WRITELN;

    ASK_INITIAL_COUNT;
    ASK_LOAD_METHOD;
    ASK_ASCENDING_LOAD;
    ASK_ADDED_COUNT;
    ASK_ASCENDING_ADDED;
    ASK_KEY_DIST;
    ASK_FILL;
    ASK_RECORD_FORMAT;
    ASK_REC_SIZE;
    ASK_KEY_TYPE;
    ASK_KEY_SIZE;
    ASK_KEY_POSITION;
    ASK_KEY_DUPS;
    ASK_PROLOGUE_VERSION;
    ASK_DATA_KEY_COMP;
    ASK_DATA_RECORD_COMP;
    ASK_INDEX_RECORD_COMP;

    WRITELN;

    VISIBLE_QUESTION	:= TRUE;

    STATUS		:= LIB$SET_SCROLL (PROMPT_LINE,LINES_PER_PAGE);
    SCROLLING_SET	:= TRUE;

    FIRST_PLOT		:= TRUE;
    PLOT_SIMPLE_GRAPH;

    { +
    This will loop until the user types control/Z or
    LINK_RESULTS makes LINKED true.
    - }
    LINKED	:= FALSE;

    WHILE NOT LINKED DO

    BEGIN

	{ +
	See what the user wants to vary.
	- }
	ASK_DESIGN_OPTION;

	CASE DESIGN_CYCLE OF

	    EDF$C_RF :		ASK_RECORD_FORMAT;

	    EDF$C_RS :		ASK_REC_SIZE;

	    EDF$C_KL :		ASK_KEY_SIZE;

	    EDF$C_BF :		ASK_FILL;

	    EDF$C_IL :		ASK_INITIAL_COUNT;

	    EDF$C_KP :		ASK_KEY_POSITION;

	    EDF$C_LM :		ASK_LOAD_METHOD;

	    EDF$C_AR :		ASK_ADDED_COUNT;

	    EDF$C_DK :		ASK_KEY_DUPS;

	    EDF$C_RC :		ASK_DATA_RECORD_COMP;

	    EDF$C_KC :		ASK_DATA_KEY_COMP;

	    EDF$C_IC :		ASK_INDEX_RECORD_COMP;

	    EDF$C_PV :		ASK_PROLOGUE_VERSION;

	    EDF$C_KT :		ASK_KEY_TYPE;

	    EDF$C_FINIS :	LINK_RESULTS;

	    EDF$C_WP :

	    BEGIN

		{ +
		This is the write fresh plot function.
		- }
		FIRST_PLOT	:= TRUE;
		PLOT_SIMPLE_GRAPH;

	    END;

	OTHERWISE

	    LIB$SIGNAL (EDF$_INTSWERR,1,29,0);

	END;	{ CASE }

	IF NOT ((DESIGN_CYCLE = EDF$C_WP) OR LINKED) THEN

	    PLOT_SIMPLE_GRAPH;

    END;	{ WHILE }

    EDF$RESET_SCROLL;

END;	{ LINE_DESIGN }

{ ++

SEQ_REL_WORK -- Do the calculations for designing Seq and Rel files.

This routine does all the work.

CALLING SEQUENCE:

SEQ_REL_WORK;

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

PROCEDURE SEQ_REL_WORK;

BEGIN

    { +
    Find out how the user is going to use the file.
    - }
    ASK_NUMBER_RECORDS;
    ASK_RECORD_FORMAT;
    ASK_BLOCK_SPAN;
    ASK_REC_SIZE;

    { +
    Stuff the definition.
    - }
    INIT_DEF;
    NON_KEY_DEF;

END;	{ SEQ_REL_WORK }

{ ++

SEQUENTIAL_DESIGN -- Let the user design SEQ files.

This routine allows the user to specify SEQ files.

CALLING SEQUENCE:

SEQUENTIAL_DESIGN;

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

PROCEDURE SEQUENTIAL_DESIGN;

BEGIN

    CLEAR (SCREEN);

    WRITELN (SHIFT,TAB,TAB,ANSI_REVERSE,DASH,
    ' Sequential File Design ',
    DASH,ANSI_RESET,CRLF);

    { +
    Find out how the user is going to use the file.
    - }
    SEQ_REL_WORK;
    SEQ_DEF;

    { +
    Now show the user what he has.
    - }
    VIEW_DEF;

END;	{ SEQUENTIAL_DESIGN }

{ ++

RELATIVE_DESIGN -- Let the user design REL files.

This routine allows the user to specify REL files.

CALLING SEQUENCE:

RELATIVE_DESIGN;

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

PROCEDURE RELATIVE_DESIGN;

BEGIN

    CLEAR (SCREEN);

    WRITELN (SHIFT,TAB,TAB,ANSI_REVERSE,DASH,
    ' Relative File Design ',
    DASH,ANSI_RESET,CRLF);

    { +
    Find out how the user is going to use the file.
    - }
    SEQ_REL_WORK;
    REL_DEF;

    { +
    Now show the user what he has.
    - }
    VIEW_DEF;

END;	{ RELATIVE_DESIGN }

{ ++

INDEXED_WORK -- Do the dirty work to design an indexed file.

This routine does all the calculations needed to design or redesign
an indexed file.

CALLING SEQUENCE:

INDEXED_WORK;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

CONTROL_ZEE_TYPED
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

CONTROL_ZEE_TYPED
SYS$OUTPUT:

ROUTINES CALLED:

ASK_DESIGN_STYLE
SURFACE_DESIGN
LINE_DESIGN

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE INDEXED_WORK;

BEGIN

    SETUP_KEY_LENGTH;

    CLEAR (SCREEN);

    WRITE (SHIFT,TAB,TAB,ANSI_REVERSE,DASH,' Initial ');

    CASE SCRIPT_OPTION OF

	DESIGN_FDL :		WRITE ('Design');
	OPTIMIZE_FDL :		WRITE ('Optimization');
	REDESIGN_FDL :		WRITE ('Redesign');

    OTHERWISE

	{ +
	BUGCHECK!!
	- }
	LIB$SIGNAL (EDF$_INTSWERR,1,30,0);

    END;	{ CASE }

    WRITELN (' Phase for Key ',
    ACTIVE_KEY:ACTIVE_KEY_LENGTH,' ',DASH,ANSI_RESET,CRLF);

    ASK_DESIGN_STYLE;
    ASK_BUCKET_WEIGHT;

    CASE DESIGN_STYLE OF

	SURFACE_PLOT :		SURFACE_DESIGN;

	LINE_PLOT :		LINE_DESIGN;

    OTHERWISE

	{ +
	BUGCHECK!!
	- }
	LIB$SIGNAL (EDF$_INTSWERR,1,31,0);

    END;	{ CASE }

END;	{ INDEXED_WORK }

{ ++

INDEXED_DESIGN -- Do the dirty work to design an indexed file.

This routine does all the calculations needed to design an indexed file.

CALLING SEQUENCE:

INDEXED_DESIGN;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

CONTROL_ZEE_TYPED
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

CONTROL_ZEE_TYPED
SYS$OUTPUT:

ROUTINES CALLED:

INDEXED_WORK

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE INDEXED_DESIGN;

BEGIN

    { +
    Initialize the script.
    - }
    ASK_NUMBER_KEYS;

    { +
    Now loop until all his keys are defined.
    - }
    FOR ACTIVE_KEY := 0 TO (NUMBER_KEYS-1) DO

	INDEXED_WORK;

    { +
    Now show the user what he has.
    - }
    VIEW_DEF;

END;	{ INDEXED_DESIGN }

{ ++

INDEXED_REDESIGN -- Do the dirty work to redesign an indexed file.

This routine does all the calculations needed to redesign an indexed file.

CALLING SEQUENCE:

INDEXED_REDESIGN;

INPUT PARAMETERS:

none

IMPLICIT INPUTS:

CONTROL_ZEE_TYPED
SYS$INPUT:

OUTPUT PARAMETERS:

none

IMPLICIT OUTPUTS:

CONTROL_ZEE_TYPED
SYS$OUTPUT:

ROUTINES CALLED:

INDEXED_WORK

ROUTINE VALUE:

none

SIGNALS:

none

SIDE EFFECTS:

none

-- }

PROCEDURE INDEXED_REDESIGN;

BEGIN

    { +
    Initialize the script.
    - }
    ASK_ACTIVE_KEY;

    IF WARN_OF_ERASE THEN

    BEGIN

	{ +
	Now do a design on just that key.
	- }
	INDEXED_WORK;

	{ +
	Now show the user what he has.
	- }
	VIEW_DEF;

    END;

END;	{ INDEXED_REDESIGN }

    { End of file: SRC$:EDFDESIGN.PAS }
