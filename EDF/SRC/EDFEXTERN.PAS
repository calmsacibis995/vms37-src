{ ++
         File: SRC$:EDFEXTERN.PAS--PASCAL INCLUDE file
         to define VAX/VMS SYSTEM ROUTINES and other
    	 EDF-only support routines.

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

		V03-003	KFH0002		Ken Henderson		2 April 1982
			Added ISECNUM_PTR to call to
			FDL$GLOBAL.

		V03-001	KFH0001		Ken Henderson		23-Mar-1982
			Modified LIB$OUTPUT_HELP to fix
			FT2 QAR 381

-- }

{ ++
EXTERNAL ROUTINE DECLARATIONS:

The following functions and procedures are part of the VMS RunTimeLibrary.
They are documented in the RTL Reference Manual and the Utilities Reference
Manual.
-- }

{ +
These are the 'Terminal Independent Screen Procedures'.
- }

FUNCTION LIB$ERASE_LINE (

		VAR LINE,
		    COLUMN	: INTEGER

		    ) : INTEGER; EXTERN;

FUNCTION LIB$ERASE_PAGE (

		VAR LINE,
		    COLUMN	: INTEGER

		    ) : INTEGER; EXTERN;

FUNCTION LIB$SET_CURSOR (

		VAR LINE,
		    COLUMN	: INTEGER

		    ) : INTEGER; EXTERN;

FUNCTION LIB$SET_SCROLL (

		VAR START_LINE,
		    END_LINE	: INTEGER

		    ) : INTEGER; EXTERN;

FUNCTION LIB$PUT_SCREEN (

	   %STDESCR TEXT	: PACKED ARRAY [INTEGER] OF CHAR;
		VAR LINE,
		    COLUMN	: INTEGER

		    ) : INTEGER; EXTERN;

FUNCTION LIB$PUT_OUTPUT (

	   %STDESCR TEXT	: PACKED ARRAY [INTEGER] OF CHAR

		    ) : INTEGER; EXTERN;

FUNCTION LIB$GET_SCREEN (

	   %STDESCR INPUT_TEXT	: PACKED ARRAY [INTEGER] OF CHAR;
	   %STDESCR PROMPT_STR	: PACKED ARRAY [INTEGER] OF CHAR;
		VAR LENGTH	: INTEGER

		    ) : INTEGER; EXTERN;

FUNCTION LIB$SCREEN_INFO (

		    FLAGS		: CTRL_ARRAY;
		    DEV_TYPE		: INTEGER;
		    LINE_WIDTH		: INTEGER;
		    LINES_PER_PAGE	: INTEGER

		    ) : INTEGER; EXTERN;

FUNCTION LIB$DOWN_SCROLL : INTEGER; EXTERN;

{ +
The following is the famed "TPARSE" table-driven parsing routine.
- }
FUNCTION LIB$TPARSE (

		VAR PARAM_BLK	: TPA_REC;
	     %IMMED STATE_TBL	: LONG_PTR;
	     %IMMED KEY_TBL	: LONG_PTR

		    ) : INTEGER; EXTERN;

{ +
The following are general string handling routines.
- }

PROCEDURE STR$UPCASE (

	   	VAR DST		: DESCRIPTOR;
	   	VAR SRC		: DESCRIPTOR

		    ); EXTERN;

PROCEDURE STR$TRIM (

	   	VAR DST		: DESCRIPTOR;
	   %STDESCR SRC		: PACKED ARRAY [INTEGER] OF CHAR

		    ); EXTERN;

PROCEDURE STR$FREE1_DX (

    		VAR DSC		: DESCRIPTOR

    		    ); EXTERN;

FUNCTION LIB$SCOPY_DXDX	(

		    SRC		: DESCRIPTOR;
		    DST		: DESCRIPTOR

		    ) : INTEGER; EXTERN;

FUNCTION OTS$SCOPY_DXDX	(

	   %STDESCR SRC		: PACKED ARRAY [INTEGER] OF CHAR;
		    DST		: DESCRIPTOR

		    ) : INTEGER; EXTERN;

FUNCTION OTS$CVT_TI_L (

		    STR		: DESCRIPTOR;
		VAR NUM		: INTEGER

		    ) : INTEGER; EXTERN;

FUNCTION LIB$DATE_TIME (

	   %STDESCR DST		: PACKED ARRAY [INTEGER] OF CHAR

		    ) : INTEGER; EXTERN;

{ +
This routine will set a bit field (SRC) in a location (BASE).
- }
PROCEDURE LIB$INSV (

		    SRC,
		    POS		: LONG;
		    SIZE	: BYTE;
		VAR BASE	: LONG

		    ); EXTERN;

{ +
This routine will get a bit field from a location.
- }
FUNCTION LIB$EXTZV (

		    POS,
		    SIZE,
		    BASE	: LONG

		    ) : INTEGER; EXTERN;

{ +
This routine gets the system time (in Real seconds) for us.
- }
FUNCTION FOR$SECNDS (

		    ORIG	: REAL

		    ) : REAL; EXTERN;

{ +
This routine converts a string to 64bit time.
- }
FUNCTION SYS$BINTIM (

		    INPUT_DESC	: DESCRIPTOR;
		VAR OUTPUT_QUAD	: QUADWORD

		    ) : INTEGER; EXTERN;

{ +
This routine does our help processing for us.
- }
FUNCTION LBR$OUTPUT_HELP (

	     %IMMED PUT_PTR 	: LONG_PTR;
		    WIDTH	: LONG;
	     %IMMED LINE	: LONG;
	   %STDESCR LIBRARY	: PACKED ARRAY [INTEGER] OF CHAR;
	     %IMMED FLAGS	: LONG;
	     %IMMED GET_PTR	: LONG_PTR

		    ) : INTEGER; EXTERN;

{ +
These are used in error handling.
- }

FUNCTION LIB$MATCH_COND (

		    CONDVAL,
		    COMPVAL	: INTEGER

		    ) : BOOLEAN; EXTERN;

PROCEDURE LIB$ESTABLISH (

    %IMMED FUNCTION FIXER	: INTEGER

		    ); EXTERN;

PROCEDURE LIB$REVERT; EXTERN;

PROCEDURE LIB$SIGNAL (

	     %IMMED CONDITION	: INTEGER;
	     %IMMED NUMARGS	: INTEGER;
	     %IMMED ARG1	: INTEGER;
	     %IMMED ARG2	: INTEGER

		    ); EXTERN;

PROCEDURE LIB$STOP (

	     %IMMED CONDITION	: INTEGER;
	     %IMMED NUMARGS	: INTEGER;
	     %IMMED ARG1	: INTEGER;
	     %IMMED ARG2	: INTEGER

		    ); EXTERN;

FUNCTION SYS$UNWIND (

	     %IMMED DEPTH	: INTEGER;
	     %IMMED NEWPC	: INTEGER

		    ) : INTEGER; EXTERN;

FUNCTION SYS$PUTMSG (

		    MSG_LST	: SIGARR

		    ) : INTEGER; EXTERN;

PROCEDURE SYS$EXIT (

		    STATUS	: INTEGER

		    ); EXTERN;

{ +
This is used to check for the EDF$MAKE_FDL logical name.
- }
FUNCTION SYS$TRNLOG (

		    LOGNAM	: DESCRIPTOR;
		    RSLLEN	: INTEGER;
		    RSLBUF	: DESCRIPTOR;
		    TABLE	: INTEGER;
		    ACMODE	: INTEGER;
	     %IMMED DSBMSK	: INTEGER

		    ) : INTEGER; EXTERN;

{ +
These are used to process the DCL command string.
- }

FUNCTION CLI$GET_VALUE (

	   %STDESCR SELECT	: PACKED ARRAY [INTEGER] OF CHAR;
	   	VAR RETURNED	: DESCRIPTOR

		    ) : INTEGER; EXTERN;

FUNCTION CLI$PRESENT (

	   %STDESCR TEXT	: PACKED ARRAY [INTEGER] OF CHAR

		    ) : INTEGER; EXTERN;

FUNCTION CLI$END_PARSE : INTEGER; EXTERN;


{ +
The following is used to plot graphs on the terminal.
- }
PROCEDURE EDF$GRAPH (

		    GRAPH_TYPE	: INTEGER;
	     %DESCR XY_ARRAY	: XY_ARRAY_TYPE;
		    CURRENT_INDEX,
		    LAST_INDEX,
		    Y_HIGH,
		    Y_LOW,
		    Y_INCR	: INTEGER;
	   %STDESCR Y_LABEL	: PACKED ARRAY [INTEGER] OF CHAR;
	     %DESCR COLOR_ARRAY	: XY_ARRAY_TYPE

		    ) ; EXTERN;

{ +
The following is used to parse the input FDL file for storage into the
database.
- }
FUNCTION FDL$$PARSE (

	   	    FNM		: DESCRIPTOR;
		    FAB		: FAB_PTR

		    ) : INTEGER; EXTERN;

{ +
The following is used to first parse an input FDL file and then create the
RMS file specified by it.
- }
FUNCTION FDL$CREATE (

		    FDLNAM	: DESCRIPTOR;
		    OUTNAM	: DESCRIPTOR;
		    DFTNAM	: DESCRIPTOR;
		    RESNAM	: DESCRIPTOR

		    ) : INTEGER; EXTERN;

{ +
The following routines are used to interface to TTDRV.
- }
FUNCTION  EDF$TERM_SETUP : BYTE; EXTERN;

PROCEDURE EDF$RESET_TERM; EXTERN;

PROCEDURE EDF$CTRLCAST; EXTERN;

{ +
The following interface routine won't be needed in Pascal V2.
- }

PROCEDURE EDF$GLOBAL (

	    VAR LINE_PTR			: DESCRIPTOR_PTR;
		CTRL_PTR			: CTRL_ARRAY_ADDR;
		PCALL_PTR			: FDL_PTR;
		COMMENT_PTR			: DESCRIPTOR_PTR;
		STRING_PTR			: DESCRIPTOR_PTR;
		PRIMARY_PTR			: PRI_PTR;
		PRINUM_PTR			: LONG_PTR;
		SECONDARY_PTR			: SEC_PTR;
		SECNUM_PTR			: LONG_PTR;
		QUALIFIER_PTR			: LONG_PTR;
		NUMBER_PTR			: LONG_PTR;
		NUMTYPE_PTR			: NUMT_PTR;
		SWITCH_PTR			: LONG_PTR;
		UIC_GROUP_PTR			: LONG_PTR;
		UIC_MEMBER_PTR			: LONG_PTR;
		PROTECTION_PTR			: CTRL_ARRAY_ADDR;
		FID1_PTR			: LONG_PTR;
		FID2_PTR			: LONG_PTR;
		FID3_PTR			: LONG_PTR;
		PUT_OUTPUT_PTR			: LONG_PTR;
		GET_INPUT_PTR			: LONG_PTR;
		ISECNUM_PTR			: LONG_PTR;
		PROT_MASK_PTR			: CTRL_ARRAY_ADDR;
		IFID1_PTR			: LONG_PTR;
		IFID2_PTR			: LONG_PTR;
		IFID3_PTR			: LONG_PTR;
		IUIC_GROUP_PTR			: LONG_PTR;
		IUIC_MEMBER_PTR			: LONG_PTR;
		ISTRING_PTR			: DESCRIPTOR_PTR;
		ICOMMENT_PTR			: DESCRIPTOR_PTR;
		FID_TABLE_KEY			: LONG_PTR;
		FID_TABLE_STA			: LONG_PTR;
		UIC_TABLE_KEY			: LONG_PTR;
		UIC_TABLE_STA			: LONG_PTR;
		PRIMARY_TABLE_KEY		: LONG_PTR;
		PRIMARY_TABLE_STA		: LONG_PTR;
		AREA_TABLE_KEY			: LONG_PTR;
		AREA_TABLE_STA			: LONG_PTR;
		DATE_TABLE_KEY			: LONG_PTR;
		DATE_TABLE_STA			: LONG_PTR;
		FILE_TABLE_KEY			: LONG_PTR;
		FILE_TABLE_STA			: LONG_PTR;
{		JOURNAL_TABLE_KEY		: LONG_PTR; }
{		JOURNAL_TABLE_STA		: LONG_PTR; }
		KEY_TABLE_KEY			: LONG_PTR;
		KEY_TABLE_STA			: LONG_PTR;
		RECORD_TABLE_KEY		: LONG_PTR;
		RECORD_TABLE_STA		: LONG_PTR;
		SYSTEM_TABLE_KEY		: LONG_PTR;
		SYSTEM_TABLE_STA		: LONG_PTR;
		POSIT_TABLE_KEY			: LONG_PTR;
		POSIT_TABLE_STA			: LONG_PTR;
		PROT_TABLE_KEY			: LONG_PTR;
		PROT_TABLE_STA			: LONG_PTR;
		ORG_TABLE_KEY			: LONG_PTR;
		ORG_TABLE_STA			: LONG_PTR;
		SOURCE_TABLE_KEY		: LONG_PTR;
		SOURCE_TABLE_STA		: LONG_PTR;
{		AT_TABLE_KEY			: LONG_PTR; }
{		AT_TABLE_STA			: LONG_PTR; }
{		RU_TABLE_KEY			: LONG_PTR; }
{		RU_TABLE_STA			: LONG_PTR; }
		CARR_TABLE_KEY			: LONG_PTR;
		CARR_TABLE_STA			: LONG_PTR;
		FORMAT_TABLE_KEY		: LONG_PTR;
		FORMAT_TABLE_STA		: LONG_PTR;
		TYPE_TABLE_KEY			: LONG_PTR;
		TYPE_TABLE_STA			: LONG_PTR;
		LOAD_METHOD_TABLE_KEY		: LONG_PTR;
		LOAD_METHOD_TABLE_STA		: LONG_PTR;
		CREATE_OPTION_TABLE_KEY		: LONG_PTR;
		CREATE_OPTION_TABLE_STA		: LONG_PTR;
		DESIGN_STYLE_TABLE_KEY		: LONG_PTR;
		DESIGN_STYLE_TABLE_STA		: LONG_PTR;
		SURFACE_OPTION_TABLE_KEY	: LONG_PTR;
		SURFACE_OPTION_TABLE_STA	: LONG_PTR;
		CURRENT_FUNCTION_TABLE_KEY	: LONG_PTR;
		CURRENT_FUNCTION_TABLE_STA	: LONG_PTR;
		DESIGN_CYCLE_TABLE_KEY		: LONG_PTR;
		DESIGN_CYCLE_TABLE_STA		: LONG_PTR;
		SCRIPT_OPTION_TABLE_KEY		: LONG_PTR;
		SCRIPT_OPTION_TABLE_STA		: LONG_PTR;
		YES_NO_TABLE_KEY		: LONG_PTR;
		YES_NO_TABLE_STA		: LONG_PTR

		); EXTERN;

{      End of file SRC$:EDFEXTERN.PAS      }
