$ !
$ ! [ L B R . C O M ] L B R S H R L N K . C O M
$ !
$ !	Link the shareable image of library access procedures
$ !
$ !DELETE EXE$:LBRSHR.EXE;*, EXE$:LBRSHR.STB;*, MAP$:LBRSHR.MAP;*
$ LINK /NOSYSSHR /SHARE=EXE$:LBRSHR /MAP=MAP$:LBRSHR /FULL/CROSS -
	/SYMBOL=EXE$:LBRSHR SYS$INPUT:/OPTIONS
!
! Options for LBRSHRLNK.COM
!
LIB$:LBR/INCLUDE=(CACHE,-	!Cache routines	
GETMEM,-			!Memory allocation/deallocation
LBRMSG,-			!Message codes
LBR_DATA,-			!Global data
LBR_GETHELP,-			!Extract HELP text
LBR_GETPUT, -			!Read/write records
LBR_INDEX,-			!Index manipulation
LBR_OLDLIB,-			!VMS R1 format routines
LBR_OPENCLOSE,-			!Open/close library
LBR_OUTPUTHELP,-		!Prompting and library searching help
LBR_PUTCACHE,-			!Write cache to library
LBR_SUBS,-			!Subroutines
PAD),-				!Padding for expansion/patching
!
! Match name wild card routine from F11BACP
!
RESOBJ$:F11BACP/INCLUDE=MATCHNAME
!
! Put the transfer vector in its own cluster
!
CLUSTER=TRANSFER_VECTOR,,,LIB$:LBR/INCLUDE=LBR_TRANSFER
!
! Set Global Section match control
!
GSMATCH=LEQUAL,2,9
!
! Define universal symbols
!
UNIVERSAL= -
LBR$CLOSE,-		!Close library
LBR$DELETE_DATA,-	!Delete data
LBR$DELETE_KEY,-	!Delete key
LBR$FIND,-		!Lookup by RFA
LBR$GET_HEADER,-	!Return library header
LBR$GET_HELP,-		!Return HELP text
LBR$GET_HISTORY,-	!Return library history records
LBR$GET_RECORD,-	!Read text record
LBR$INI_CONTROL,-	!Initialize control
LBR$INSERT_TIME,-	!Insert date/time into module header
LBR$INSERT_KEY,-	!Insert key
LBR$LOOKUP_KEY,-	!Lookup key
LBR$OPEN,-		!Open library
LBR$OUTPUT_HELP,-	!Prompting and library searching help
LBR$PUT_END,-		!Terminate writing module text
LBR$PUT_HISTORY,-	!Build library update history
LBR$PUT_RECORD,-	!Write module text record
LBR$SEARCH,-		!Search index for given RFA
LBR$SET_INDEX,-		!Set current index
LBR$SET_LOCATE,-	!Set locate mode
LBR$SET_MODULE,-	!Return / update module header
LBR$SET_MOVE,-		!Set move mode
LBR$RET_RMSSTV,-	!Return RMS status value
LBR$GL_CONTROL,-	!Pointer to library context block
LBR$GL_RMSSTV,-		!RMS STV on errors
!
!	LBR messages
! Success
	lbr$_normal,-
	lbr$_keyindex,-
	lbr$_keyins,-
	lbr$_oldlibrary,-
! Informational codes
	lbr$_nohistory,-
	lbr$_emptyhist,-
! Warning codes
	lbr$_hdrtrunc,-
	lbr$_noupdhist,-
	lbr$_nulidx,-
	lbr$_oldmismch,-
	lbr$_rectrunc,-
	lbr$_stillkeys,-
	lbr$_typmismch,-
	lbr$_nomtchfou,-
	lbr$_errclose,-
	lbr$_endtopic,-
! Error codes
	lbr$_allwrngblk,-
	lbr$_dupkey,-
	lbr$_illctl,-
	lbr$_illcreopt,-
	lbr$_illidxnum,-
	lbr$_illfmt,-
	lbr$_illfunc,-
	lbr$_illop,-
	lbr$_illtyp,-
	lbr$_invkey,-
	lbr$_invnam,-
	lbr$_invrfa,-
	lbr$_keynotfnd,-
	lbr$_libnotopn,-
	lbr$_lkpnotdon,-
	lbr$_libopn,-
	lbr$_nofilnam,-
	lbr$_nohlptxt,-
	lbr$_nothlplib,-
	lbr$_reclng,-
	lbr$_refcntzero,-
	lbr$_rfapasteof,-
	lbr$_toomnylib,-
	lbr$_updurtrav,-
	lbr$_badparam,-
	lbr$_intrnlerr,-
	lbr$_writeerr,-
	lbr$_illoutrou,-
	lbr$_illoutwid,-
	lbr$_illinrou,-
	lbr$_toomnyarg,-
	lbr$_usrinperr

!
!
! Force LIB$CVT_ATB and LIB$PUT_OUTPUT to be in same
! isect as rest of LBR
!
PSECT = _LIB$CODE, NOPIC, NOSHR
PSECT = _LIB$DATA, NOPIC, NOSHR
