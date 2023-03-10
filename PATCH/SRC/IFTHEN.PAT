TERMINAL

ALIGN		= 1
CANCEL		= 2
CHECK		= 3
DEFINE		= 4
DELETE		= 5
DEPOSIT		= 6
EVALUATE	= 7
EXAMINE		= 8
EXIT		= 9
GOTO		= 10
IF		= 11
INSERT		= 12
REPLACE		= 13
SET		= 14
SHOW		= 15
THEN		= 16
UPDATE		= 17
VERIFY		= 18

ALL		= 19
AND		= 20
ASCII		= 21
BYTE		= 22
DBLQUOTE	= 23
DECIMAL		= 24
ECO		= 25
EQ		= 26
GE		= 27
GLOBALS		= 28
GT		= 29
HEXADECIMAL	= 30
INSTRUCTION	= 31
LE		= 32
LONG		= 33
LT		= 34
MODE		= 35
MODULE		= 36
NE		= 37
NOASCII		= 38
NOGLOBALS	= 39
NOINSTRUCTION	= 40
NOSCOPE		= 41
NOSYMBOLS	= 42
NOT		= 43
OCTAL		= 44
OR		= 45
PAGE		= 46
PATCH_AREA	= 47
QUAD		= 48
SCOPE		= 49
SYMBOLS		= 50
WORD		= 51

ASTERISK	= 52
AT_SIGN		= 53
BACKSLASH	= 54
CL_PAREN	= 55
COLON		= 56
COMMA		= 57
EQUALS		= 58
HASH		= 59
LANGLE		= 60
LSQUARE		= 61
MINUS		= 62
ALPHA_STRING	= 63
DIGIT_STRING	= 64
OP_PAREN	= 65
PERCENT		= 66
PERIOD		= 67
PLUS		= 68
QUOTE		= 69
QTD_STG		= 70
RANGLE		= 71
RSQUARE		= 72
SEMI_COLON	= 73
SLASH		= 74
UP_ARROW	= 75

OLDPMT		= 81
NEWPMT		= 82
LOCPMT		= 83
NAMPMT		= 84
EXPPMT		= 85
ECOPMT		= 86
THNPMT		= 87

EOL		= 99

GOALSY 	= 100;

END


BEGIN

S = COMMAND_LINE GOALSY ;

COMMAND_LINE = SINGLE_COMMAND
	! COMMAND_LINE SINGLE_COMMAND ;

SINGLE_COMMAND = PATCH_COMMAND EOL	/PATCOMLIN
	! PATCH_COMMAND SEMI_COLON	/PATCOMLIN ;

PATCH_COMMAND = ALIGN SLASH ALIGN_LIST ALIGN_NAME
	! CANCEL PATCH_AREA				/PATSETPAT
	! CANCEL MODE					/PATSETMOD
	! CANCEL MODULE SLASH ALL			/PATSETALL
	! CANCEL MODULE MODULE_LIST			/PATSETMDL
	! CANCEL SCOPE 					/PATSETSCO
	! CHECK_ECO_CMD ECO_LIST
	! CHECK_N_ECO_CMD ECO_LIST
	! DEFINE DEFINE_LIST
	! DELETE VERB_SWITCH_LIST DELETE_LIST
	! DELETE DELETE_LIST
	! DEPOSIT PAT_SWITCH_LIST DEPOSIT_LIST	
	! DEPOSIT DEPOSIT_LIST
	! EVALUATE VERB_SWITCH_LIST EVALUATE_LIST
	! EVALUATE EVALUATE_LIST
	! EXAMINE VERB_SWITCH_LIST EXAM_COMMA_LIST
	! EXAMINE VERB_SWITCH_LIST
	! EXAMINE EXAM_COMMA_LIST
	! EXAMINE
	! REPLACE VERB_SWITCH_LIST REPLACE_LIST
	! REPLACE REPLACE_LIST
	! IF_NUM_EXP1 THEN_PATCH_COMMAND	/PATIFT
	! INSERT VERB_SWITCH_LIST INSERT_LIST
	! INSERT INSERT_LIST
	! EXIT
	! SET_ECO_CMD NUM_EXP1
	! SET_ECO_CMD EOL_ECOPMT NUM_EXP1
	! SET MODE MODE_SWITCH_LIST		/PATSETMOD
	! SET MODULE MODULE_LIST		/PATSETMDL
	! SET PATCH_AREA NUM_EXP1		/PATSETPAT
	! SET PATCH_AREA EOL_NEWPMT NUM_EXP1	/PATSETPAT
	! SET SCOPE PATH_NAME			/PATSETSCO
	! SET SCOPE EOL_NEWPMT PATH_NAME	/PATSETSCO
	! SHOW MODE				/PATSETMOD
	! SHOW MODULE				/PATSETMDL
	! SHOW SCOPE				/PATSETSCO
	! GOTO ALPHA_STRING			/PATGOTOCM
	! UPDATE
	! VERIFY VERB_SWITCH_LIST VERIFY_LIST
	! VERIFY VERIFY_LIST ;

IF_EXPRESSION = IF NUM_EXP1			/PATIF
	! IF EOL_IFPMT				/PATIF;

THEN_PATCH_COMMAND = THEN PATCH_COMMAND	/PATTHN
	! THEN EOL_THNPMT			/PATTHN ;

EOL_IFPMT = EOL				/PATIFPMT ;
EOL_THNPMT = EOL			/PATTHNPMT ;

REPLACE_LIST = NUM_EXP1 EQUALS EXP1_COMMA_LIST EOL_LIST_END NEWPMT_LIST EXIT
	! NUM_EXP1 EOL_OLDPMT OLDPMT_LIST EXIT_INDICATOR EOL_NEWPMT NEWPMT_LIST EXIT
	! EOL_LOCPMT NUM_EXP1 EOL_OLDPMT OLDPMT_LIST EXIT_INDICATOR EOL_NEWPMT NEWPMT_LIST  EXIT ;

NEWPMT_LIST = NEWPMT_LIST NUM_EXP1 EOL_NEWPMT
	! NUM_EXP1 EOL_NEWPMT ;

OLDPMT_LIST = OLDPMT_LIST NUM_EXP1 EOL_OLDPMT
	! NUM_EXP1 EOL_OLDPMT ;

INSERT_LIST = NUM_EXP1 EQUALS NUM_EXP1 EOL_LIST_END NEWPMT_LIST EXIT
	! NUM_EXP1 EOL_OLDPMT NUM_EXP1 EOL_LIST_END NEWPMT_LIST EXIT
	! EOL_LOCPMT NUM_EXP1 EOL_OLDPMT NUM_EXP1 EOL_LIST_END NEWPMT_LIST EXIT ;

NAME_EXP1_LIST = NAME_EXP1_LIST COMMA DEFINE_NAME EQUALS EXP1	/PATDEFTWO
	! DEFINE_NAME EQUALS EXP1	/PATDEFZER ;

ALIGN_NAME = DEFINE_NAME			/PATALINM0
	! EOL_NAMPMT DEFINE_NAME		/PATALINM1 ;

DEFINE_NAME = ALPHA_STRING		/PATDEFNAM ;

EXP1_COMMA_LIST = EXP1_COMMA_LIST COMMA EXP1	/ PATEXPTWO
	! EXP1					/PATEXPZER ;

EXPPMT_LIST = EXPPMT_LIST NUM_EXP1 EOL_EXPPMT
	! NUM_EXP1 EOL_EXPPMT ;

EXAM_COMMA_LIST = EXAM_COMMA_LIST COMMA EXP1	/PATEXPTWO
	! EXP1					/PATEXPZER
	! EXAM_COMMA_LIST COMMA EXP1 COLON EXP1	/PATRANGE2
	! EXP1 COLON EXP1			/PATRANGE0 ;

DEFINE_LIST = NAME_EXP1_LIST
	! EOL_NAMPMT NAM_EXP1_PMT_LIST EXIT ;

NAM_EXP1_PMT_LIST = NAM_EXP1_PMT_LIST DEFINE_NAME EOL_NEWPMT EXP1 EOL_NAMPMT	/PATDEFONE
	! DEFINE_NAME EOL_NEWPMT EXP1 EOL_NAMPMT		/PATDEFZER ;

DEPOSIT_LIST = NUM_EXP1 EQUALS EXP1_COMMA_LIST
	! NUM_EXP1 EOL_NEWPMT NEWPMT_LIST EXIT
	! EOL_LOCPMT NUM_EXP1 EOL_NEWPMT NEWPMT_LIST EXIT ;

DELETE_LIST = NUM_EXP1 EQUALS EXP1_COMMA_LIST
	! NUM_EXP1 EOL_OLDPMT OLDPMT_LIST EXIT
	! EOL_LOCPMT NUM_EXP1 EOL_OLDPMT OLDPMT_LIST EXIT ;

EVALUATE_LIST = EXP1_COMMA_LIST
	! EOL_EXPPMT EXPPMT_LIST EXIT ;

EOL_LOCPMT = EOL		/PATLOCPMT;
EOL_NEWPMT = EOL		/PATNEWPMT;
EOL_OLDPMT = EOL		/PATOLDPMT;
EOL_NAMPMT = EOL		/PATNAMPMT;
EOL_EXPPMT = EOL		/PATEXPPMT;
EOL_ECOPMT = EOL		/PATECOPMT;

EOL_LIST_END = EOL_NEWPMT	/PATEXITOK;

EXIT_INDICATOR = EXIT		/PATEXITOK;

NUM_EXP1 = EXP1			/PATEXPZER;

EXP1 = EXP2
	! UP_ARROW			/PATUQUNAM ;

EXP2 = EXP3
	! EXP2 EQ EXP3			/PATEQEXPR
	! EXP2 NE EXP3			/PATNEEXPR
	! EXP2 LT EXP3			/PATLTEXPR
	! EXP2 LE EXP3			/PATLEEXPR
	! EXP2 GT EXP3			/PATGTEXPR
	! EXP2 GE EXP3			/PATGEEXPR
	! EXP2 PLUS EXP3		/PATADDEXP
	! EXP2 MINUS EXP3		/PATSUBEXP
	! EXP2 ASTERISK EXP3		/PATMULEXP
	! EXP2 SLASH EXP3		/PATDIVEXP
	! EXP2 AT_SIGN EXP3		/PATSHFEXP 
	! EXP2 OR EXP3			/PATOROPER
	! EXP2 AND EXP3			/PATANDOPR ;

EXP3 = EXP4
	! PLUS EXP3			/PATPOSEXP
	! MINUS EXP3			/PATNEGEXP
	! NOT EXP3			/PATNOTOPR
	! AT_SIGN EXP3			/PATINDEXP ;

EXP4 = SIMPLE_NAME
	! SIMPLE_NAME BIT_LANGLE NUMBER BIT_COLON NUMBER RANGLE	/PATEXTBIT
	! LANGLE EXP1 RANGLE		/PATREMPAR ;

BIT_LANGLE = LANGLE			/PATSETDEC;

BIT_COLON = COLON			/PATSETDEC;

MODULE_LIST = MODULE_NAME_LIST
	! EOL_NAMPMT NAMPMT_LIST EXIT ;

MODULE_NAME_LIST = MODULE_NAME_LIST COMMA MODULE_NAME	/PATEXPTWO
	! MODULE_NAME			/PATEXPZER;

NAMPMT_LIST = NAMPMT_LIST MODULE_NAME EOL_NAMPMT		/PATEXPONE
	! MODULE_NAME EOL_NAMPMT				/PATEXPZER ;

MODULE_NAME = ALPHA_STRING		/PATSAVMDL;

MODE_SWITCH_LIST = DATA_SWITCH_LIST
	! EOL_NEWPMT MODE_PMT_LIST EXIT ;

MODE_PMT_LIST = MODE_PMT_LIST DATA_SWITCH EOL_NEWPMT	/PATEXPONE
	! DATA_SWITCH EOL_NEWPMT				/PATEXPZER ;

DATA_SWITCH_LIST = DATA_SWITCH_LIST COMMA DATA_SWITCH	/PATEXPTWO
	! DATA_SWITCH			/PATEXPZER ;

DATA_SWITCH = HEXADECIMAL
	! OCTAL
	! DECIMAL
	! BYTE
	! WORD
	! LONG
	! INSTRUCTION
	! NOINSTRUCTION
	! ASCII
	! NOASCII
	! SYMBOLS
	! NOSYMBOLS
	! SCOPE
	! NOSCOPE
	! GLOBALS
	! NOGLOBALS ;

SET_ECO_CMD = SET ECO				/PATSETECO;

CHECK_ECO_CMD = CHECK ECO		/PATSETDEC;

CHECK_N_ECO_CMD = CHECK NOT ECO		/PATCHKNEC;

ECO_LIST = ECO_COMMA_LIST
	! EOL_ECOPMT ECOPMT_LIST EXIT ;

ECO_COMMA_LIST = ECO_COMMA_LIST COMMA NUMBER		/PATEXPTWO
	! NUMBER					/PATEXPZER
	! ECO_COMMA_LIST COMMA NUMBER COLON NUMBER	/PATRANGE2
	! NUMBER COLON NUMBER				/PATRANGE0 ;

ECOPMT_LIST = ECOPMT_LIST NUMBER EOL_ECOPMT		/PATEXPONE
	! NUMBER EOL_ECOPMT				/PATEXPZER
	! ECOPMT_LIST NUMBER COLON NUMBER EOL_ECOPMT	/PATRANGE1
	! NUMBER COLON NUMBER EOL_ECOPMT		/PATRANGE0 ;

NUMBER = DIGIT_STRING			/PATUQUNAM ;

SIMPLE_NAME = PATH_NAME			/PATTRNNAM
	! DIGIT_STRING			/PATUQUNAM
	! PERIOD			/PATUQUNAM
	! BACKSLASH			/PATUQUNAM
	! QUOTE				/PATQUOTEC ;

PATH_NAME = PATH_NAME BACKSLASH ALPHA_STRING	/PATSAVPAT
	! ALPHA_STRING			/PATSAVPAT ;

VERB_SWITCH_LIST = VERB_SWITCH_LIST SLASH DATA_SWITCH	/PATOVROP2
	! SLASH DATA_SWITCH		/PATOVROP1 ;

VERIFY_LIST = NUM_EXP1 EQUALS EXP1_COMMA_LIST		/PATEXITOK
	! NUM_EXP1 EOL_OLDPMT OLDPMT_LIST EXIT_INDICATOR
	! EOL_LOCPMT NUM_EXP1 EOL_OLDPMT OLDPMT_LIST EXIT_INDICATOR ;

PAT_SWITCH_LIST = PAT_SWITCH_LIST SLASH PAT_SWITCH	/PATOVROP2
	! SLASH PAT_SWITCH		/PATOVROP1 ;

PAT_SWITCH = DATA_SWITCH
	! PATCH_AREA			/PATSETPAT;

ALIGN_LIST = BYTE			/PATALIBYT
	! WORD				/PATALIWRD
	! LONG				/PATALILNG
	! QUAD				/PATALIQAD
	! PAGE				/PATALIPAG ;



END
