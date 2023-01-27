1	sub keypad(which_keypad$)
2     !****************************************************************************&
      !*									  *&
      !*  COPYRIGHT (c) 1978, 1980, 1982 BY					  *&
      !*  DIGITAL EQUIPMENT CORPORATION, MAYNARD, MASSACHUSETTS.		  *&
      !*  ALL RIGHTS RESERVED.							  *&
      !* 									  *&
      !*  THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED AND COPIED   *&
      !*  ONLY IN  ACCORDANCE WITH  THE  TERMS  OF  SUCH  LICENSE  AND WITH THE   *&
      !*  INCLUSION OF THE ABOVE COPYRIGHT NOTICE. THIS SOFTWARE OR  ANY  OTHER   *&
      !*  COPIES THEREOF MAY NOT BE PROVIDED OR OTHERWISE MADE AVAILABLE TO ANY   *&
      !*  OTHER PERSON.  NO TITLE TO AND OWNERSHIP OF  THE  SOFTWARE IS  HEREBY   *&
      !*  TRANSFERRED.								  *&
      !* 									  *&
      !*  THE INFORMATION IN THIS SOFTWARE IS  SUBJECT TO CHANGE WITHOUT NOTICE   *&
      !*  AND  SHOULD  NOT  BE  CONSTRUED AS  A COMMITMENT BY DIGITAL EQUIPMENT   *&
      !*  CORPORATION.								  *&
      !* 									  *&
      !*  DIGITAL ASSUMES NO RESPONSIBILITY FOR THE USE  OR  RELIABILITY OF ITS   *&
      !*  SOFTWARE ON EQUIPMENT WHICH IS NOT SUPPLIED BY DIGITAL.		  *&
      !* 									  *&
      !*									  *&
      !****************************************************************************&
      ! &
      !		Version V03-000 &
      ! &
      !****************************************************************************
      !
50    !	&
      !	****	Version 1.0	 7-Mar-79	original code &
      !		Version 1.1	18-Jul-79	changes to match EDT version 2 &
      !		Version 1.2	30-Mar-81	interface to template &
      !
100   !	&
      !	&
      !	****	Program Description &
      !
300   !	&
      !	****	Files &
      !
400   !	&
      !	****	Variable Directory &
      !
800   !	&
      !	****	Functions &
      !
900   !	&
      !	****	Dimension the arrays &
      !	&
    \	common (qiocom) fill%(7%), &
			escape$=1%, &
			terminal$=3%, &
			fill$=36%, &
			keypad$(22%,1%)=10% &
      !
1000  !	&
      !	****	Set up the values produced by the keypad. &
      !	&
      !	First decide which keypad they are asking for. &
      !	&
    \	goto 2000 if which_keypad$="CAI" &
    \	goto 3000 if which_keypad$="EDT" &
    \	goto 4000 if which_keypad$="SPECIAL" &
    \	subexit
2000  !	&
      !	Set up the CAI keypad. &
      !	&
    \	keypad$(0%,0%)="1" &
    \	goto 2100 if terminal$="V52" &
    \	goto 2200 if terminal$="VT1" or terminal$="VK1" &
    \	subexit
2100  !	&
      !	Now setup the names of the keypad keys for the VT52 terminal &
      !	&
    \	keypad$(1%,0%)="<UP>"			! UP arrow key &
    \	keypad$(2%,0%)="<DOWN>"			! DOWN arrow key &
    \	keypad$(3%,0%)="<RIGHT>"		! RIGHT arrow key &
    \	keypad$(4%,0%)="<LEFT>"			! LEFT arrow key &
    \	keypad$(5%,0%)="[ADVICE"		! ZERO key &
    \	keypad$(6%,0%)="[KEYPAD"		! ONE key &
    \	keypad$(7%,0%)="[MAP"			! TWO key &
    \	keypad$(8%,0%)="[OBJECTIVE"		! THREE key &
    \	keypad$(9%,0%)="[FORWARD"		! FOUR key &
    \	keypad$(10%,0%)="[REVIEW"		! FIVE key &
    \	keypad$(11%,0%)="[BACK"			! SIX key &
    \	keypad$(12%,0%)="[COMMENT"		! SEVEN key &
    \	keypad$(13%,0%)="[GLOSSARY"		! EIGHT key &
    \	keypad$(14%,0%)="[SUMMARY"		! NINE key &
    \	keypad$(15%,0%)="<NO KEY>"		! No key on a VT52 &
    \	keypad$(16%,0%)="<NO KEY>"		! No key on a VT52 &
    \	keypad$(17%,0%)="[PLOT"			! PERIOD key &
    \	keypad$(18%,0%)=""			! ENTER key &
    \	keypad$(19%,0%)="*GOLD"			! LEFT BLANK key &
    \	keypad$(20%,0%)="[HELP"			! CENTER BLANK key &
    \	keypad$(21%,0%)="[EXIT"			! RIGHT BLANK key &
    \	keypad$(22%,0%)="<NO KEY>"		! No key on a VT52 &
    \	keypad$(1%,1%)="<NO KEY>"		! *GOLD UP arrow &
    \	keypad$(2%,1%)="<NO KEY>"		! *GOLD DOWN arrow &
    \	keypad$(3%,1%)="<NO KEY>"		! *GOLD RIGHT arrow &
    \	keypad$(4%,1%)="<NO KEY>"		! *GOLD LEFT arrow &
    \	keypad$(5%,1%)="[VIEW"			! *GOLD ZERO &
    \	keypad$(6%,1%)="<NO KEY>"		! *GOLD ONE &
    \	keypad$(7%,1%)="<NO KEY>"		! *GOLD TWO &
    \	keypad$(8%,1%)="<NO KEY>"		! *GOLD THREE &
    \	keypad$(9%,1%)="<NO KEY>"		! *GOLD FOUR &
    \	keypad$(10%,1%)="<NO KEY>"		! *GOLD FIVE &
    \	keypad$(11%,1%)="<NO KEY>"		! *GOLD SIX &
    \	keypad$(12%,1%)="<NO KEY>"		! *GOLD SEVEN &
    \	keypad$(13%,1%)="<NO KEY>"		! *GOLD EIGHT &
    \	keypad$(14%,1%)="<NO KEY>"		! *GOLD NINE &
    \	keypad$(15%,1%)="<NO KEY>"		! No key on a VT52 &
    \	keypad$(16%,1%)="<NO KEY>"		! No key on a VT52 &
    \	keypad$(17%,1%)="<NO KEY>"		! *GOLD PERIOD &
    \	keypad$(18%,1%)="<NO KEY>"		! *GOLD ENTER &
    \	keypad$(19%,1%)="<NO KEY>"		! *GOLD LEFT BLANK key &
    \	keypad$(20%,1%)="<NO KEY>"		! *GOLD CENTER BLANK key &
    \	keypad$(21%,1%)="[QUIT"			! *GOLD RIGHT BLANK key &
    \	keypad$(22%,1%)="<NO KEY>"		! No key on a VT52 &
    \	subexit
2200  !	&
      !	Now setup the names of the keypad keys for the VT100 terminal &
      !	&
    \	keypad$(1%,0%)="<UP>"			! UP arrow key &
    \	keypad$(2%,0%)="<DOWN>"			! DOWN arrow key &
    \	keypad$(3%,0%)="<RIGHT>"		! RIGHT arrow key &
    \	keypad$(4%,0%)="<LEFT>"			! LEFT arrow key &
    \	keypad$(5%,0%)="[ADVICE"		! ZERO key &
    \	keypad$(6%,0%)="[KEYPAD"		! ONE key &
    \	keypad$(7%,0%)="[MAP"			! TWO key &
    \	keypad$(8%,0%)="[OBJECTIVE"		! THREE key &
    \	keypad$(9%,0%)="[FORWARD"		! FOUR key &
    \	keypad$(10%,0%)="[REVIEW"		! FIVE key &
    \	keypad$(11%,0%)="[BACK"			! SIX key &
    \	keypad$(12%,0%)="[COMMENT"		! SEVEN key &
    \	keypad$(13%,0%)="[GLOSSARY"		! EIGHT key &
    \	keypad$(14%,0%)="[SUMMARY"		! NINE key &
    \	keypad$(15%,0%)="<NO KEY>"		! - key &
    \	keypad$(16%,0%)="<NO KEY>"		! , key &
    \	keypad$(17%,0%)="[PLOT"			! PERIOD key &
    \	keypad$(18%,0%)=""			! ENTER key &
    \	keypad$(19%,0%)="*GOLD"			! PF1 key &
    \	keypad$(20%,0%)="[HELP"			! PF2 key &
    \	keypad$(21%,0%)="[EXIT"			! PF3 key &
    \	keypad$(22%,0%)="<NO KEY>"		! PF4 key &
    \	keypad$(1%,1%)="<NO KEY>"		! *GOLD UP arrow &
    \	keypad$(2%,1%)="<NO KEY>"		! *GOLD DOWN arrow &
    \	keypad$(3%,1%)="<NO KEY>"		! *GOLD RIGHT arrow &
    \	keypad$(4%,1%)="<NO KEY>"		! *GOLD LEFT arrow &
    \	keypad$(5%,1%)="[VIEW"			! *GOLD ZERO &
    \	keypad$(6%,1%)="<NO KEY>"		! *GOLD ONE &
    \	keypad$(7%,1%)="<NO KEY>"		! *GOLD TWO &
    \	keypad$(8%,1%)="<NO KEY>"		! *GOLD THREE &
    \	keypad$(9%,1%)="<NO KEY>"		! *GOLD FOUR &
    \	keypad$(10%,1%)="<NO KEY>"		! *GOLD FIVE &
    \	keypad$(11%,1%)="<NO KEY>"		! *GOLD SIX &
    \	keypad$(12%,1%)="<NO KEY>"		! *GOLD SEVEN &
    \	keypad$(13%,1%)="<NO KEY>"		! *GOLD EIGHT &
    \	keypad$(14%,1%)="<NO KEY>"		! *GOLD NINE &
    \	keypad$(15%,1%)="<NO KEY>"		! *GOLD - key &
    \	keypad$(16%,1%)="<NO KEY>"		! *GOLD , key &
    \	keypad$(17%,1%)="<NO KEY>"		! *GOLD PERIOD &
    \	keypad$(18%,1%)="<NO KEY>"		! *GOLD ENTER &
    \	keypad$(19%,1%)="<NO KEY>"		! *GOLD PF1 key &
    \	keypad$(20%,1%)="<NO KEY>"		! *GOLD PF2 key &
    \	keypad$(21%,1%)="[QUIT"			! *GOLD PF3 key &
    \	keypad$(22%,1%)="<NO KEY>"		! *GOLD PF4 key &
    \	subexit
3000  !	&
      !	Set up the EDT keypad. &
      !	&
    \	keypad$(0%,0%)="2" &
    \	goto 3100 if terminal$="V52" &
    \	goto 3200 if terminal$="VT1" or terminal$="VK1" &
    \	subexit
3100  !	&
      !	Now setup the names of the keypad keys for the VT52 terminal &
      !	&
    \	keypad$(1%,0%)="<UP>"			! UP arrow key &
    \	keypad$(2%,0%)="<DOWN>"			! DOWN arrow key &
    \	keypad$(3%,0%)="<RIGHT>"		! RIGHT arrow key &
    \	keypad$(4%,0%)="<LEFT>"			! LEFT arrow key &
    \	keypad$(5%,0%)="<LINE>"			! ZERO key &
    \	keypad$(6%,0%)="<WORD>"			! ONE key &
    \	keypad$(7%,0%)="<EOL>"			! TWO key &
    \	keypad$(8%,0%)="<CUT>"			! THREE key &
    \	keypad$(9%,0%)="<ADVANCE>"		! FOUR key &
    \	keypad$(10%,0%)="<BACKUP>"		! FIVE key &
    \	keypad$(11%,0%)="<DEL C>"		! SIX key &
    \	keypad$(12%,0%)="<PAGE>"		! SEVEN key &
    \	keypad$(13%,0%)="<FNDNXT>"		! EIGHT key &
    \	keypad$(14%,0%)="<DEL W>"		! NINE key &
    \	keypad$(15%,0%)="<NO KEY>"		! No key on a VT52 &
    \	keypad$(16%,0%)="<NO KEY>"		! No key on a VT52 &
    \	keypad$(17%,0%)="<SELECT>"		! PERIOD key &
    \	keypad$(18%,0%)="<ENTER>"		! ENTER key &
    \	keypad$(19%,0%)="*GOLD"			! LEFT BLANK key &
    \	keypad$(20%,0%)="<HELP>"		! CENTER BLANK key &
    \	keypad$(21%,0%)="<DEL L>"		! RIGHT BLANK key &
    \	keypad$(22%,0%)="<NO KEY>"		! No key on a VT52 &
    \	keypad$(1%,1%)="<REPLACE>"		! *GOLD UP arrow &
    \	keypad$(2%,1%)="<SECT>"			! *GOLD DOWN arrow &
    \	keypad$(3%,1%)="<SPECINS>"		! *GOLD RIGHT arrow &
    \	keypad$(4%,1%)="<APPEND>"		! *GOLD LEFT arrow &
    \	keypad$(5%,1%)="<OPEN LINE>"		! *GOLD ZERO &
    \	keypad$(6%,1%)="<CHNGCASE>"		! *GOLD ONE &
    \	keypad$(7%,1%)="<DEL EOL>"		! *GOLD TWO &
    \	keypad$(8%,1%)="<PASTE>"		! *GOLD THREE &
    \	keypad$(9%,1%)="<BOTTOM>"		! *GOLD FOUR &
    \	keypad$(10%,1%)="<TOP>"			! *GOLD FIVE &
    \	keypad$(11%,1%)="<UND C>"		! *GOLD SIX &
    \	keypad$(12%,1%)="<COMMAND>"		! *GOLD SEVEN &
    \	keypad$(13%,1%)="<FIND>"		! *GOLD EIGHT &
    \	keypad$(14%,1%)="<UND W>"		! *GOLD NINE &
    \	keypad$(15%,1%)="<NO KEY>"		! No key on a VT52 &
    \	keypad$(16%,1%)="<NO KEY>"		! No key on a VT52 &
    \	keypad$(17%,1%)="<RESET>"		! *GOLD PERIOD &
    \	keypad$(18%,1%)="<SUBS>"		! *GOLD ENTER &
    \	keypad$(19%,1%)="<NO KEY>"		! *GOLD LEFT BLANK key &
    \	keypad$(20%,1%)="<NO KEY>"		! *GOLD CENTER BLANK key &
    \	keypad$(21%,1%)="<UND L>"		! *GOLD RIGHT BLANK key &
    \	keypad$(22%,1%)="<NO KEY>"		! No key on a VT52 &
    \	subexit				! all done, go to cleanup
3200  !	&
      !	Now setup the names of the keypad keys for the VT100 terminal &
      !	&
    \	keypad$(1%,0%)="<UP>"			! UP arrow key &
    \	keypad$(2%,0%)="<DOWN>"			! DOWN arrow key &
    \	keypad$(3%,0%)="<RIGHT>"		! RIGHT arrow key &
    \	keypad$(4%,0%)="<LEFT>"			! LEFT arrow key &
    \	keypad$(5%,0%)="<LINE>"			! ZERO key &
    \	keypad$(6%,0%)="<WORD>"			! ONE key &
    \	keypad$(7%,0%)="<EOL>"			! TWO key &
    \	keypad$(8%,0%)="<CHAR>"			! THREE key &
    \	keypad$(9%,0%)="<ADVANCE>"		! FOUR key &
    \	keypad$(10%,0%)="<BACKUP>"		! FIVE key &
    \	keypad$(11%,0%)="<CUT>"			! SIX key &
    \	keypad$(12%,0%)="<PAGE>"		! SEVEN key &
    \	keypad$(13%,0%)="<SECT>"		! EIGHT key &
    \	keypad$(14%,0%)="<APPEND>"		! NINE key &
    \	keypad$(15%,0%)="<DEL W>"		! - key &
    \	keypad$(16%,0%)="<DEL C>"		! , key &
    \	keypad$(17%,0%)="<SELECT>"		! PERIOD key &
    \	keypad$(18%,0%)="<ENTER>"		! ENTER key &
    \	keypad$(19%,0%)="*GOLD"			! PF1 key &
    \	keypad$(20%,0%)="<HELP>"		! PF2 key &
    \	keypad$(21%,0%)="<FNDNXT>"		! PF3 key &
    \	keypad$(22%,0%)="<DEL L>"		! PF4 key &
    \	keypad$(1%,1%)="<NO KEY>"		! *GOLD UP arrow &
    \	keypad$(2%,1%)="<NO KEY>"		! *GOLD DOWN arrow &
    \	keypad$(3%,1%)="<NO KEY>"		! *GOLD RIGHT arrow &
    \	keypad$(4%,1%)="<NO KEY>"		! *GOLD LEFT arrow &
    \	keypad$(5%,1%)="<OPEN LINE>"		! *GOLD ZERO &
    \	keypad$(6%,1%)="<CHNGCASE>"		! *GOLD ONE &
    \	keypad$(7%,1%)="<DEL EOL>"		! *GOLD TWO &
    \	keypad$(8%,1%)="<SPECINS>"		! *GOLD THREE &
    \	keypad$(9%,1%)="<BOTTOM>"		! *GOLD FOUR &
    \	keypad$(10%,1%)="<TOP>"			! *GOLD FIVE &
    \	keypad$(11%,1%)="<PASTE>"		! *GOLD SIX &
    \	keypad$(12%,1%)="<COMMAND>"		! *GOLD SEVEN &
    \	keypad$(13%,1%)="<FILL>"		! *GOLD EIGHT &
    \	keypad$(14%,1%)="<REPLACE>"		! *GOLD NINE &
    \	keypad$(15%,1%)="<UND W>"		! *GOLD - key &
    \	keypad$(16%,1%)="<UND C>"		! *GOLD , key &
    \	keypad$(17%,1%)="<RESET>"		! *GOLD PERIOD &
    \	keypad$(18%,1%)="<SUBS>"		! *GOLD ENTER &
    \	keypad$(19%,1%)="<NO KEY>"		! *GOLD PF1 key &
    \	keypad$(20%,1%)="<NO KEY>"		! *GOLD PF2 key &
    \	keypad$(21%,1%)="<FIND>"		! *GOLD PF3 key &
    \	keypad$(22%,1%)="<UND L>"		! *GOLD PF4 key &
    \	subexit					! all done, go to cleanup
4000  !	&
      !	At this point, change the GOLD key from *GOLD to <GOLD> for the &
      !	special function of <GOLD> # <key> &
      !	&
    \	keypad$(19%,0%)="<GOLD>" &
    \	subexit
32000 !	&
      !	****	End routine &
      !
32767	subend
