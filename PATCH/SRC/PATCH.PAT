TERMINAL

ALIGN		= 1;
CANCEL		= 2;
CHECK		= 3;
CREATE		= 4;
DEFINE		= 5;
DELETE		= 6;
DEPOSIT		= 7;
EVALUATE	= 8;
EXAMINE		= 9;
EXIT		= 10;
HELP		= 11;
INSERT		= 12;
REPLACE		= 13;
SET		= 14;
SHOW		= 15;
UPDATE		= 16;
VERIFY		= 17;

ALL		= 18;
AND		= 19;
ASCII		= 20;
BYTE		= 21;
DECIMAL		= 22;
ECO		= 23;
GLOBALS		= 25;
HEXADECIMAL	= 27;
INSTRUCTION	= 28;
LITERAL		= 30;
LONG		= 31;
MODE		= 33;
MODULE		= 34;
NOASCII		= 36;
NOGLOBALS	= 37;
NOINSTRUCTION	= 38;
NOSCOPE		= 39;
NOSYMBOLS	= 40;
NOT		= 41;
OCTAL		= 42;
OR		= 43;
PAGE		= 44;
PATCH_AREA	= 45;
QUAD		= 46;
SCOPE		= 47;
SYMBOLS		= 48;
WORD		= 49;
INITIALIZE	= 50;

ASTERISK	= 60;
AT_SIGN		= 61;
BACKSLASH	= 62;
CL_PAREN	= 63;
COLON		= 64;
COMMA		= 65;
EQUALS		= 66;
HASH		= 67;
LANGLE		= 68;
LSQUARE		= 69;
MINUS		= 70;
ALPHA_STRING	= 71;
DIGIT_STRING	= 72;
OP_PAREN	= 73;
PERIOD		= 75;
PLUS		= 76;
QUOTE		= 77;
QTD_STG		= 78;
RANGLE		= 79;
RSQUARE		= 80;
SEMI_COLON	= 81;
SLASH		= 82;
UP_ARROW	= 83;

OLDPMT		= 91;
NEWPMT		= 92;
LOCPMT		= 93;
NAMPMT		= 94;
EXPPMT		= 95;
ECOPMT		= 96;

EOL		= 99;

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
	! CANCEL MODULE SLASH ALL			/PATSETMDL
	! CANCEL MODULE MODULE_LIST			/PATSETMDL
	! CANCEL SCOPE 					/PATSETSCO
	! CHECK_ECO_CMD ECO_LIST
	! CHECK_N_ECO_CMD ECO_LIST
	! CREATE					/PATGETFIL
	! DEFINE DEFINE_LIST
	! DELETE VERB_SWITCH_LIST DELETE_LIST
	! DELETE DELETE_LIST
	! DEPOSIT PAT_SWITCH_LIST DEPOSIT_LIST	
	! DEPOSIT DEPOSIT_LIST
	! EVALUATE EVAL_SWITCH_LIST EVALUATE_LIST
	! EVALUATE EVALUATE_LIST
	! EXAMINE VERB_SWITCH_LIST EXAM_COMMA_LIST
	! EXAMINE VERB_SWITCH_LIST
	! EXAMINE EXAM_COMMA_LIST
	! EXAMINE
	! HELP						/PATGETHLP
	! REPLACE VERB_SWITCH_LIST REPLACE_LIST
	! REPLACE REPLACE_LIST
	! INSERT VERB_SWITCH_LIST INSERT_LIST
	! INSERT INSERT_LIST
	! EXIT
	! SET_ECO_CMD NUM_EXP1
	! SET_ECO_CMD EOL_ECOPMT NUM_EXP1
	! SET MODE MODE_SWITCH_LIST		/PATSETMOD
	! SET MODULE SLASH ALL			/PATSETMDL
	! SET MODULE MODULE_LIST		/PATSETMDL
	! SET PATCH_AREA PATCH_ADDRESS
	! SET PATCH_AREA SLASH INITIALIZE EQUALS PATCH_SIZE PATCH_ADDRESS
	! SET SCOPE PATH_NAME			/PATSETSCO
	! SET SCOPE EOL_NEWPMT PATH_NAME	/PATSETSCO
	! SHOW MODE				/PATSETMOD
	! SHOW MODULE				/PATSETMDL
	! SHOW PATCH_AREA			/PATSETPAT
	! SHOW SCOPE				/PATSETSCO
	! UPDATE
	! VERIFY VERB_SWITCH_LIST VERIFY_LIST
	! VERIFY VERIFY_LIST ;

REPLACE_LIST = NUM_EXP1 EQUALS EXP1_COMMA_LIST EOL_LIST_END NEWPMT_LIST EXIT
	! NUM_EXP1 EOL_OLDPMT OLDPMT_LIST EXIT_INDICATOR EOL_NEWPMT NEWPMT_LIST EXIT
	! EOL_LOCPMT NUM_EXP1 EOL_OLDPMT OLDPMT_LIST EXIT_INDICATOR EOL_NEWPMT NEWPMT_LIST  EXIT ;

NEWPMT_LIST = NEWPMT_LIST ASC_NUM_EXP1 EOL_NEWPMT
	! ASC_NUM_EXP1 EOL_NEWPMT ;

OLDPMT_LIST = OLDPMT_LIST ASC_NUM_EXP1 EOL_OLDPMT
	! ASC_NUM_EXP1 EOL_OLDPMT ;

INSERT_LIST = NUM_EXP1 EQUALS ASC_NUM_EXP1 EOL_LIST_END NEWPMT_LIST EXIT
	! NUM_EXP1 EOL_OLDPMT ASC_NUM_EXP1 EOL_LIST_END NEWPMT_LIST EXIT
	! EOL_LOCPMT NUM_EXP1 EOL_OLDPMT ASC_NUM_EXP1 EOL_LIST_END NEWPMT_LIST EXIT ;

NAME_EXP1_LIST = NAME_EXP1_LIST COMMA DEFINE_NAME EQUALS EXP1	/PATDEFTWO
	! DEFINE_NAME EQUALS EXP1	/PATDEFZER ;

ALIGN_NAME = DEFINE_NAME			/PATALINM0
	! EOL_NAMPMT DEFINE_NAME		/PATALINM1 ;

DEFINE_NAME = ALPHA_STRING		/PATDEFNAM ;

EXP1_COMMA_LIST = EXP1_COMMA_LIST COMMA ASC_NUM_EXP1
	! ASC_NUM_EXP1 ;

EXPPMT_LIST = EXPPMT_LIST ASC_NUM_EXP1 EOL_EXPPMT
	! ASC_NUM_EXP1 EOL_EXPPMT ;

EXAM_COMMA_LIST = EXAM_COMMA_LIST COMMA NUM_EXP1
	! NUM_EXP1
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

ASC_NUM_EXP1 = EXP1			/PATEXPZER;

PATCH_ADDRESS = NUM_EXP1		/PATSETPAT
		! EOL_NEWPMT NUM_EXP1	/PATSETPAT;

PATCH_SIZE = NUM_EXP1			/PATSETINI
		! EOL_NEWPMT NUM_EXP1	/PATSETINI;

NUM_EXP1 = EXP1				/PATNUMZER;

EXP1 = EXP2
	! UP_ARROW			/PATUQUNAM ;

EXP2 = EXP3
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

MODE_PMT_LIST = MODE_PMT_LIST DATA_SWITCH EOL_NEWPMT	/PATNUMONE
	! DATA_SWITCH EOL_NEWPMT			/PATNUMZER ;

DATA_SWITCH_LIST = DATA_SWITCH_LIST COMMA DATA_SWITCH	/PATNUMTWO
	! DATA_SWITCH					/PATNUMZER ;

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

ECO_COMMA_LIST = ECO_COMMA_LIST COMMA NUMBER		/PATNUMTWO
	! NUMBER					/PATNUMZER
	! ECO_COMMA_LIST COMMA NUMBER COLON NUMBER	/PATRANGE2
	! NUMBER COLON NUMBER				/PATRANGE0 ;

ECOPMT_LIST = ECOPMT_LIST NUMBER EOL_ECOPMT		/PATNUMONE
	! NUMBER EOL_ECOPMT				/PATNUMZER
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

EVAL_SWITCH_LIST = EVAL_SWITCH_LIST SLASH LIT_SWITCH	/PATOVROP2
	! SLASH LIT_SWITCH		/PATOVROP1 ;

LIT_SWITCH = DATA_SWITCH
	! LITERAL			/PATSETLIT;

ALIGN_LIST = BYTE			/PATALIBYT
	! WORD				/PATALIWRD
	! LONG				/PATALILNG
	! QUAD				/PATALIQAD
	! PAGE				/PATALIPAG ;



END
