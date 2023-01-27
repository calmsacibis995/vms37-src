1	sub intro
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
      !****************************************************************************
50    !	&
      !	****	Version	1.0	25-Jun-80	original code &
      !
100   !	&
      !	****	Program Description &
      !	&
      !		This is the introduction to the course, which explains about &
      !		the keypad, the options, and the menus. &
      !
300   !	&
      !	****	Files &
      !	&
      !
400   !	&
      !	****	Variable Directory &
      !
800   !	&
      !	****	Map, Common, and External Statements &
      !	&
    \	dim screen_location$(10%,1%) &
      !	&
    \	map (dsply) rec.num$=5%,rec.val$=4091% &
      !	&
    \	common (pasfil)				! common to hold passed values &
		pass_key%			! holds the return value for &
						! use in the ROUTER &
      !	&
    \	common (qiocom)				! common to hold QIO constants &
		fill%(7%), &
		escape$=1%,			! the escape character &
		terminal$=3%			! this persons terminal type &
      !
900   !	&
      !	****	Functions &
      !
910	def fn_setup$ &
      !	&
      !	This function will set up the constants necessary for this routine. &
      !	&
    \	if terminal$="V52" or terminal$="VT1" then &
		screen_location$(1%,0%)=fn_at$(8%,55%)  \ screen_location$(1%,1%)=fn_at$(3%,33%) &
    \		screen_location$(2%,0%)=fn_at$(9,55%)   \ screen_location$(2%,1%)=fn_at$(5%,33%) &
    \		screen_location$(3%,0%)=fn_at$(10%,55%) \ screen_location$(3%,1%)=fn_at$(7%,33%) &
    \		screen_location$(4%,0%)=fn_at$(11%,55%) \ screen_location$(4%,1%)=fn_at$(9%,33%) &
    \		screen_location$(5%,0%)=fn_at$(12%,55%) \ screen_location$(5%,1%)=fn_at$(11%,33%) &
    \		screen_location$(6%,0%)=fn_at$(13%,55%) \ screen_location$(6%,1%)=fn_at$(13%,33%) &
    \		screen_location$(7%,0%)=fn_at$(14%,55%) \ screen_location$(7%,1%)=fn_at$(15%,33%) &
    \		screen_location$(8%,0%)=fn_at$(15%,55%) \ screen_location$(8%,1%)=fn_at$(17%,33%) &
    \		screen_location$(9%,0%)=fn_at$(16%,55%) \ screen_location$(9%,1%)=fn_at$(19%,33%) &
    \		screen_location$(10%,0%)=fn_at$(17%,55%) \ screen_location$(10%,1%)=fn_at$(21%,33%) &
    \		cursor_string$=">" &
    \		erase_cursor$=" " &
    \		goto 912
911	if terminal$="VK1" then &
		screen_location$(1%,0%)="P[359,125]" \ screen_location$(1%,1%)="P[288,40]" &
    \		screen_location$(2%,0%)="P[359,150]" \ screen_location$(2%,1%)="P[288,80]" &
    \		screen_location$(3%,1%)="P[359,175]" \ screen_location$(3%,1%)="P[288,120]" &
    \		screen_location$(4%,0%)="P[359,200]" \ screen_location$(4%,1%)="P[288,160]" &
    \		screen_location$(5%,0%)="P[359,225]" \ screen_location$(5%,1%)="P[288,200]" &
    \		screen_location$(6%,0%)="P[359,250]" \ screen_location$(6%,1%)="P[288,240]" &
    \		screen_location$(7%,0%)="P[359,275]" \ screen_location$(7%,1%)="P[288,280]" &
    \		screen_location$(8%,0%)="P[359,300]" \ screen_location$(8%,1%)="P[288,320]" &
    \		screen_location$(9%,0%)="P[359,325]" \ screen_location$(9%,1%)="P[288,360]" &
    \		screen_location$(10%,0%)="P[359,350]" \ screen_location$(10%,1%)="P[288,400]" &
    \		cursor_string$="@AW(R,A0,I7)" &
    \		erase_cursor$="W(E)@AW(R)"
912   !	&
      !	Set up the other things necessary for this routine &
      !	&
    \	call setmod("ZO998","ZS998","ZM11",1%) &
    \	fnend
920	def fn_at$(x%,y%) &
      !	&
      !	This function will return the escape sequence to place the cursor at &
      !	the screen position X,Y for a VT52 or VT100 terminal. &
      !	&
    \	f_temp$=""				! clear the return value &
    \	f_temp$=escape$+"Y"+chr$(x%+31%)+chr$(y%+31%) if terminal$="V52" &
    \	f_temp$=escape$+"["+num1$(x%)+";"+num1$(y%)+"H" if terminal$="VT1" &
    \	fn_at$=f_temp$ &
    \	fnend
931	def fn_getanswer$ &
      !	&
      !	This function will simplify the calling of the GETANS routine. &
      !	&
    \	call getans(answer$,feedback$,3%,response$,advice$,-1%,result%) &
    \	fn_getanswer$=response$ &
    \	fnend
1000  !	&
      !	****	Main Routine &
      !	&
    \	on error goto 19000 &
    \	temp$=fn_setup$
2000  !	&
      !	Begin the introduction &
      !	&
    \	ptr%=1% &
    \	call plot("ZI100") &
    \	answer$="" &
    \	feedback$="" &
    \	advice$="+ZA100" &
    \	response$=fn_getanswer$ &
    \	if result% > 2% then 9900
2050	ptr%=2% &
    \	call plot("ZI101") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	if result% > 2% then 9900
2100	call plot("ZI102") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	if result% > 2% then 9900
5000  !	&
      ! ****    Begin standard introduction &
      !	&
    \	ptr%=51%
5100	call plot("ZI500") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	if result% > 2% then 9900
5150	call plot("ZI501") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	if result% > 2% then 9900
5200	call plot("ZI502") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	if result% > 2% then 9900 &
                else if seg$(response$,1%,1%)<>"M" then 5500
5250	call plot("ZI503") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	if result% > 2% then 9900
5300	call plot("ZI504") &
    \	answer$="your name." &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	goto 9900 if result%>2% &
    \	temp%=len(response$)+22% &
    \	call setloc("R",1%,0%,-1%,temp%) &
    \	call feedbk("  Ok.") &
    \	call plot("ZZ101") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	if result%>2% then 9900
5350	call plot("ZI505") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	if result% > 2% then 9900
5500	ptr%=52% &
    \	call plot("ZI510") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	if result% > 2% then 9900
6000	ptr%=53% &
    \	call plot("ZI520")
6010	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	on result% goto 6500,6015,9900
6015	goto 6050 if seg$(response$,1%,1%)="M" &
    \	call feedbk("Please type MORE or press RETURN") &
    \	goto 6010
6050	call plot("ZI521") &
    \	menu%=0% &
    \	max_cursor%=9% &
    \	cursor%=1% &
    \	gosub 10000 &
    \	goto 9900 if result% > 2%
6500	ptr%=54% &
    \	call plot("ZI530") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	if result% > 2% then 9900
7000	ptr%=55% &
    \	call plot("ZI531") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	if result% > 2% then 9900
7500	ptr%=56% &
    \	call plot("ZI540") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	if result% > 2% then 9900
7600	call plot("ZI541") &
    \	answer$="[A*DVICE" &
    \	feedback$="Please press the <ADVICE> key." &
    \	response$=fn_getanswer$ &
    \	if result% > 2% then 9900
7650	call plot("ZA541") &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	if result% > 2% then 9900
7700	call plot("ZI542") &
    \	answer$="[G*LOSSARY" &
    \	feedback$="Please press the <GLOSSARY> key." &
    \	response$=fn_getanswer$ &
    \	goto 9900 if result% > 2% &
    \	call glsry &
    \	call setloc("A",20%,5%,21%,5%) &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	if result% > 2% then 9900
8000	ptr%=57% &
    \	call plot("ZI550") &
    \	answer$="[H*ELP" &
    \	feedback$="Please press the <HELP MENU> key." &
    \	response$=fn_getanswer$ &
    \	if result% > 2% then 9900
8100	call plot("ZI551") &
    \	cursor%=1%
8105	menu%=1% &
    \	max_cursor%=9% &
    \	gosub 10000 &
    \	goto 9900 if result% > 2% &
    \	if cursor%<>8% then &
		call feedbk("Please move the cursor to INFORMATION features.") &
    \		goto 8105
8200	call plot("ZI552") &
    \	cursor%=1%
8205	menu%=1% &
    \	max_cursor%=9% &
    \	gosub 10000 &
    \	goto 9900 if result% > 2% &
    \	if cursor%<>2% then &
		call feedbk("Please move the cursor to COMMENT.") &
    \		goto 8205
8300	call plot("ZI553") &
    \	call getans("","",3%,response$,"-ZA100",-1%,result%) &
    \	goto 9900 if result% > 2%
8500	ptr%=58% &
    \	call plot("ZI560")
8510	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	goto 9000 if result%=3% &
    \	goto 9900 if result%>2% and result%<>6% &
    \	if result%<>6% or left$(rec.num$,3%)<>"ZK1" then &
		call feedbk("Press either the <KEYPAD> key or the <EXIT> key.") &
    \		goto 8510
8600	call plot("ZI565") &
    \	answer$="[E*XIT" &
    \	feedback$="Please press <EXIT>" &
    \	advice$="+ZA565" &
    \	response$=fn_getanswer$ &
    \	goto 9900 if result%>2%
9000	pass_key%=-3%				! set the flag as coming from &
						! the introduction &
						! and leave &
    \	subexit
9900  !	&
      !	****	Main option routine &
      !	&
      !	The returns from this routine are as follows: &
      !	&
      !		pass_key% = -3% the student completed the intro, give credit &
      !			     1% they [EXITed, so go back to the Main Menu &
      !			     3% they [QUIT, so quit &
      !	&
      !	pass_key% being set to -3% (completion) is handled at line 9000. &
      !	&
    \	goto 9905 if result% = 4% &
    \	goto 9990 if result% = 6% and (left$(rec.num$,3%) = "ZK1" or rec.num$ = "ZM11") &
    \	goto 9990 if result% = 7% and rec.num$ = "ZS998" &
    \	call plot("ZI700") if result% = 3% &
    \	call plot("ZI701") if result% = 5% &
    \	call plot("ZI702") if result% = 6% &
    \	call plot("ZI703") if result% = 7% &
    \	call plot("ZI704") if result% = 8% &
    \	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	goto 9990 if result% < 3%		! if they pressed return, send &
						! them to where they came from
9905	if result% = 3% then			! [EXIT &
		pass_key%=1%			! set the flag &
    \		subexit				! and leave
9910	if result% = 4% then			! [QUIT &
		pass_key%=3%			! set the flag &
    \		subexit				! and leave
9920	if result% = 5% or result% = 6% then	! [BACKUP UNIT & [REVIEW &
		ptr%=ptr%-1%			! back up a little &
    \		ptr%=1% if ptr% < 1%		! not too much &
    \		goto 9990
9930	if result% = 7% then			! [FORWARD &
		pass_key%=1%			! go forward out of the intro. &
						! of course they are not given &
						! credit for completing it... &
    \		subexit				! and leave
9940	if result% = 8% then			! [HELP MENU &
		pass_key%=8%			! set the flag &
    \		subexit
9990  !	&
      !	Here use the value of PTR% to go back to a starting place. &
      !	&
    \	if ptr%<50% then on ptr% goto 2000,2050 &
		else on ptr%-49% goto 2050,5000,5500,6000,6500,7000,7500,8000,8500
10000 !	&
      !	****	Subroutine to do cursor moving on a simulated menu &
      !	&
    \	first_flag%=0%
10005	answer$="" &
    \	feedback$="" &
    \	response$=fn_getanswer$ &
    \	return if result% > 2% &
    \	return if response$="" and first_flag%<>0% &
    \	if response$<>"<UP>" and response$<>"<DOWN>" then &
		temp$="Please press the UP or DOWN arrow key." &
    \		temp$=temp$+", or press RETURN to continue." if first_flag%<>0% &
    \		call feedbk(temp$) &
    \		goto 10005
10010	print screen_location$(cursor%,menu%)+erase_cursor$; &
    \	first_flag%=1% &
    \	cursor%=cursor%-1% if response$="<UP>" &
    \	cursor%=cursor%+1% if response$="<DOWN>" &
    \	cursor%=1% if cursor%>max_cursor% &
    \	cursor%=max_cursor% if cursor%<1% &
    \	print screen_location$(cursor%,menu%)+cursor_string$; &
    \	goto 10005
19000 !	&
      !	****	Error recovery routine &
      !	&
    \	resume 32000
32000 !	&
      !	****	Exit &
      !	&
    \	pass_key%=1%
32767	subend
