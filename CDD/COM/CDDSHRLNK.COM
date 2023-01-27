$ !
$ !	Link dummy CDDSHR that ships with VMS kit
$ !
$ DELETE EXE$:CDDSHR.EXE;*, MAP$:CDDSHR.MAP;*
$ LINK /SHARE=EXE$:CDDSHR /MAP=MAP$:CDDSHR /FULL /CROSS -
	SYS$INPUT:/OPTION
!+
!
!	FILES THAT MAKE UP THE SHARED IMAGE
!
!-
CLUSTER	  =	CDDSHR,,,LIB$:CDD/INCLUDE=(CDD$ENTRY,CDD$TYPE,CDD$MSG,CDD$MSG2)
GSMATCH   =	LEQUAL,6,1
!++
!
!	SYMBOLS NEEDED TO USE THE PROGRAM INTERFACE
!
!	CDD entry points
!
UNIVERSAL =	CDD$CLEAR_CELL,-
		CDD$CREATE_ACL_ENTRY,-
		CDD$CREATE_DIR,-
		CDD$CREATE_ENTITY_ATT,-
		CDD$CREATE_ENTITY_LIST_ATT,-
		CDD$CREATE_FORWARD,-
		CDD$CREATE_HISTORY,-
		CDD$CREATE_NULL_ATT,-
		CDD$CREATE_NUM_ATT,-
		CDD$CREATE_STRING_ATT,-
		CDD$CREATE_STRING_LIST_ATT,-
		CDD$CREATE_TERM,-
		CDD$DELETE_ACL_ENTRY,-
		CDD$DELETE_ATT,-
		CDD$DELETE_NODE,-
		CDD$FILL_STRING_CELL,-
		CDD$FIND_NODE,-
		CDD$FORMAT_ACL_ENTRY,-
		CDD$GET_ACCESS_RIGHTS,-
		CDD$GET_ACL_ENTRY,-
		CDD$GET_ATT,-
		CDD$GET_ATTS,-
		CDD$GET_ENTITY_ATT,-
		CDD$GET_ENTITY_CELL,-
		CDD$GET_ENTITY_LIST_ATT,-
		CDD$GET_NEXT_ATT,-
		CDD$GET_NULL_ATT,-
		CDD$GET_NUM_ATT,-
		CDD$GET_STRING_ATT,-
		CDD$GET_STRING_CELL,-
		CDD$GET_STRING_LIST_ATT,-
		CDD$LOCK_NODE,-
		CDD$NEXT_NODE,-
		CDD$RENAME_NODE,-
		CDD$RLSE_LOCKS,-
		CDD$SET_DEFAULT,-
		CDD$SIGN_IN,-
		CDD$SIGN_OUT,-
		CDD$EXTEND_LIST

!--
!+
!	CDD security bits
!-

UNIVERSAL = 	CDD$K_PROT_C,-	! CONTROL access
		CDD$K_PROT_D,-	! LOCAL DELETE access
		CDD$K_PROT_G,-	! GLOBAL DELETE access
		CDD$K_PROT_H,-	! HISTORY list entry creation access
		CDD$K_PROT_P,-	! PASS THRU access
		CDD$K_PROT_S,-	! SEE (read) access
		CDD$K_PROT_U,-	! UPDATE terminal node access
		CDD$K_PROT_X,-	! EXTEND directory node access
    		CDD$K_PROT_F,-	! FORWARDing directory creation

!+
!	Other processor security bits
!-

!+
!	VAX-11 Datatrieve
!-

		CDD$K_DTR_PROT_E,-	! EXTEND file
		CDD$K_DTR_PROT_R,-	! READ file
		CDD$K_DTR_PROT_M,-	! MODIFY file
		CDD$K_DTR_PROT_W,-	! WRITE file
!+
!
!	USER LITERAL DEFINITIONS
!
!
!	These symbols are needed by users of the program interface.
!-


!+
!	System Defined Attribute Names
!-

		CDD$K_FILE,-		! Node's file name
		CDD$K_HISTORY,-		! History list head
		CDD$K_NAME,-		! Node's name
		CDD$K_PROTOCOL,-	! Node's protocol name
		CDD$K_TYPE,-		! Type of object pointed to by location code
		CDD$K_PATHNAME,-	! Node's complete pathname
		CDD$K_SHORT_PATHNAME,-	! Node's short pathname
		CDD$K_ORDER,-		! Directory's order


!+
!	Attribute and Entity Types
!-

		CDD$K_ENTITY,-
		CDD$K_ENTITY_LIST,-
		CDD$K_NULL,-
		CDD$K_NUMERIC,-
		CDD$K_STRING,-
		CDD$K_STRING_LIST,-
		CDD$K_DIRECTORY,-
		CDD$K_TERMINAL,-


!+
!	User's entity purge options
!-

		CDD$K_ALL,-
		CDD$K_ABORT,-
		CDD$K_CHECKPOINT,-


!+
!	User's node creation options
!-

		CDD$K_NOHISTORY,-	! Doesn't want history list cluster
		CDD$K_NOACL,-		! Prevent default ACL entry
		CDD$K_FIRST,-		! Insert as first node
		CDD$K_LAST,-		! Insert as last node


!+
!	User's node deletion options
!-

		CDD$K_CHECK,-		! Fail if directory has children
		CDD$K_SUBDICTIONARY,-	! Delete contents of subdictionaries


!+
!	Values of the CDD$K_ORDER attribute
!-

		CDD$K_SORTED,-		! Directory is sorted
		CDD$K_NONSORTED		! Directory is not sorted



!++
!
!	CONDITION STATUS VALUES
!
!--

UNIVERSAL =	CDD$_ACLNOTFND,-
		CDD$_ALLFAILED,-
		CDD$_ALLPATFND,-
		CDD$_ASYNCTRAP,-
		CDD$_ATTALREXI,-
		CDD$_ATTERROR,-
		CDD$_ATTNOTFND,-
		CDD$_BADCHKSUM,-
		CDD$_BADCLUSEQ,-
		CDD$_BADGRPSEQ,-
		CDD$_BADLINNUM,-
		CDD$_BADPATH,-
		CDD$_BADREFCOU,-
		CDD$_BADSTREAM,-
		CDD$_BADUIC,-
		CDD$_BADUSRCNX,-
		CDD$_BLKALREXI,-
		CDD$_BLKNOTFIT,-
		CDD$_BLKNOTFND,-
		CDD$_BLKTOOBIG,-
		CDD$_CCBWASACT,-
		CDD$_CDDNOTINS,-
		CDD$_CELNOTEMP,-
		CDD$_CELTOOBIG,-
		CDD$_CLOSEPER,-
		CDD$_CLOSERROR,-
		CDD$_CONSECPER,-
		CDD$_CORDATSTR,-
		CDD$_DENIED,-
		CDD$_ENDOFATT,-
		CDD$_ENDOFDIR,-
		CDD$_EMPTYCELL,-
		CDD$_EXTENDERR,-
		CDD$_FILALRACC,-
		CDD$_FILNOTCOR,-
		CDD$_FNDDIRNOD,-
		CDD$_FNDTOPNOD,-
		CDD$_FORFILDIR,-
		CDD$_ILLATTOPR,-
		CDD$_ILLDATTYP,-
		CDD$_ILLLOCCON,-
		CDD$_ILLLOCREQ,-
		CDD$_ILLNAMCHR,-
		CDD$_ILLNAMSIZ,-
		CDD$_ILLPURTYP,-
		CDD$_ILLSIBLNG,-
		CDD$_ILLVALSIZ,-
		CDD$_INCOMPVER,-
		CDD$_INSFILNAM,-
		CDD$_INV1STCHR,-
		CDD$_INVARGOPT,-
		CDD$_INVATTNAM,-
		CDD$_INVBLKTYP,-
		CDD$_INVBUFSIZ,-
		CDD$_INVCLOPAR,-
		CDD$_INVCELNUM,-
		CDD$_INVCONPTR,-
		CDD$_INVDELLOC,-
		CDD$_INVHISCIB,-
		CDD$_INVHYPHEN,-
		CDD$_INVLSTCHR,-
		CDD$_INVLOCTYP,-
		CDD$_INVNODNAM,-
		CDD$_INVOPNPAR,-
		CDD$_INVPARAM,-
		CDD$_INVPARNCB,-
		CDD$_INVPERIOD,-
		CDD$_INVRLSOPT,-
		CDD$_LCCNOTAVL,-
		CDD$_LCCNOTFND,-
		CDD$_LISALRACT,-
		CDD$_LOCKEDPAG,-
		CDD$_LOCNOTREL,-
		CDD$_LOCTOOLOW,-
		CDD$_NODALREXI,-
		CDD$_NODICT,-
		CDD$_NODHASCHI,-
		CDD$_NODNOTFND,-
		CDD$_NODNOTLOC,-
		CDD$_NOFREEBUF,-
		CDD$_NOFREEPAG,-
		CDD$_NOLCKTBL,-
		CDD$_NOLOGIN,-
		CDD$_NOPAGES,-
		CDD$_NOPRIV,-
		CDD$_NORLSENCB,-
		CDD$_NOSTORDIR,-
		CDD$_NOSUCHLIN,-
		CDD$_NOSUCHLOC,-
		CDD$_NOTASTREE,-
		CDD$_NOTDIRNOD,-
		CDD$_NOTLIST,-
		CDD$_NOTNODE,-
		CDD$_NOTOWNER,-
		CDD$_NOTPORPAG,-
		CDD$_NOTSYSNAM,-
		CDD$_NOUSRCNTX,-
		CDD$_NULNODNAM,-
		CDD$_PAGFULL,-
		CDD$_PAGNOTFND,-
		CDD$_PAGNOTMAP,-
		CDD$_PASTTOP,-
		CDD$_PERINPASS,-
		CDD$_READERROR,-
		CDD$_REAONLATT,-
		CDD$_READONLY,-
		CDD$_RMSERROR,-
		CDD$_SOMFAILED,-
		CDD$_TOOFEWPAR,-
		CDD$_TOOMANFIL,-
		CDD$_TOOMANLCC,-
		CDD$_TOOMANPAR,-
		CDD$_TOPNOTDEL,-
		CDD$_TOPNOTREN,-
		CDD$_VALTRUNC,-
		CDD$_WRITERROR,-
		CDD$_WRODATTYP,-
		CDD$_WRONGPAGE,-
		CDD$_WROPAGPTR
