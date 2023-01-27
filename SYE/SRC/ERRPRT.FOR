C
C	Version 'V03-002'
C
C****************************************************************************
C*									    *
C*  COPYRIGHT (c) 1978, 1980, 1982 BY					    *
C*  DIGITAL EQUIPMENT CORPORATION, MAYNARD, MASSACHUSETTS.		    *
C*  ALL RIGHTS RESERVED.						    *
C* 									    *
C*  THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED AND COPIED   *
C*  ONLY IN  ACCORDANCE WITH  THE  TERMS  OF  SUCH  LICENSE  AND WITH THE   *
C*  INCLUSION OF THE ABOVE COPYRIGHT NOTICE. THIS SOFTWARE OR  ANY  OTHER   *
C*  COPIES THEREOF MAY NOT BE PROVIDED OR OTHERWISE MADE AVAILABLE TO ANY   *
C*  OTHER PERSON.  NO TITLE TO AND OWNERSHIP OF  THE  SOFTWARE IS  HEREBY   *
C*  TRANSFERRED.							    *
C* 									    *
C*  THE INFORMATION IN THIS SOFTWARE IS  SUBJECT TO CHANGE WITHOUT NOTICE   *
C*  AND  SHOULD  NOT  BE  CONSTRUED AS  A COMMITMENT BY DIGITAL EQUIPMENT   *
C*  CORPORATION.							    *
C* 									    *
C*  DIGITAL ASSUMES NO RESPONSIBILITY FOR THE USE  OR  RELIABILITY OF ITS   *
C*  SOFTWARE ON EQUIPMENT WHICH IS NOT SUPPLIED BY DIGITAL.		    *
C* 									    *
C*									    *
C****************************************************************************
C
	PROGRAM	ERRPRT

C++
C
C	FACILITY:	ERROR LOGGING
C
C	ABSTRACT:
C
C
C	ENVIRONMENT:
C
C
C	AUTHOR:	WM P STOREY,	CREATION DATE: 9-JAN-78
C
C	FUNCTIONAL DESCRIPTION:
C
C			THIS MODULE IS THE MAIN DISPATCHING LOGIC
C			FOR THE ERRLOGGER.
C
C	MODIFIED BY:
C
C	v03-002	BP0017		Brian Porter,		14-APR-1982
C		Added filter to erllogmsg rollup.
C
C	v03-001	BP0016		Brian Porter,		07-FEB-1982
C		Added MSCP.
C**
C--
 
C
C	INCLUDE FILES:
C

	INCLUDE 'SRC$:MSGHDR.FOR /NOLIST'
	INCLUDE 'SRC$:DEVERR.FOR /NOLIST'
	include 'src$:emblmdef.for /nolist'
	include 'src$:embspdef.for /nolist'
	INCLUDE 'SRC$:VOLMOUNT.FOR /NOLIST'
	INCLUDE 'SRC$:SSMESSAGE.FOR /NOLIST'
	INCLUDE	'SRC$:SYECOM.FOR/NOLIST'
 
C
C	EQUATED SYMBOLS:
C

	PARAMETER	READV_NOECHO = '21'X

	parameter	ss$_normal = 1

	INTEGER*4	SELTIMELO(0:1)
	DATA		SELTIMELO(0)	/0/
	DATA		SELTIMELO(1)	/0/

	INTEGER*4	SELTIMEHI(0:1)
	DATA		SELTIMEHI(0)	/'FFFFFFFF'X/
	DATA		SELTIMEHI(1)	/'7FFFFFFF'X/

	INTEGER*4	TERM_DEV
	DATA		TERM_DEV	/'04'X/

	INTEGER*4	FIELD

	INTEGER*4	COMPRESS4

	integer*4	sye_mailbox_channel

	integer*4	sye_mailbox_unit

	integer*4	ss$_status

	character*11	sye_mailbox
	data		sye_mailbox	/'SYE_MAILBOX'/

	character*44	getchn_buffer_string

	byte		getchn_buffer_array(44)

	equivalence	(getchn_buffer_string,getchn_buffer_array)

	INTEGER*4	FNUM
	INTEGER*4	RMSSTS
	INTEGER*4	RMSSTV
	INTEGER*4	IUNIT
	INTEGER*4	CONDVAL

	INTEGER*4	RECPROC

	INTEGER*2	W_UNIT

	INTEGER*2	ERROR
	DATA		ERROR	/0/

	INTEGER*2	FILE_OPEN

	INTEGER		SYSLUN
	DATA		SYSLUN	/1/

	INTEGER		LSTLUN
	DATA		LSTLUN	/2/

	integer		sys$input
	data		sys$input	/3/

	integer		sys$output
	data		sys$output	/4/

	LOGICAL*1	UNKNOWN
	DATA		UNKNOWN	/.FALSE./

	logical*1	negate
	data		negate	/.false./

	logical*1	cpu
	data		cpu	/.false./

	LOGICAL*1	ENTRY
	DATA		ENTRY	/.FALSE./

	LOGICAL*1	CLASS
	DATA		CLASS	/.FALSE./

	LOGICAL*1	TYPE
	DATA		TYPE	/.FALSE./

	integer*4	record_length

	character*80	input_file_string

	character*80	output_file_string

	character*1	option

	character*8	option_string

	character*80	device_name_string

	character*1	device_name_array(80)

	equivalence	(device_name_array,device_name_string)

	character*24	after_date_string

	character*24	before_date_string

	integer*4	input_file_string_length

	integer*4	output_file_string_length

	integer*4	option_string_length

	integer*4	device_name_string_length

	integer*4	after_date_string_length

	integer*4	before_date_string_length

	character*41	input_file

	character*41	output_file

	character*41	device_name

	character*41	options

	character*41	after_date

	character*41	before_date

	data	input_file	/'_INPUT FILE  [SYS$ERRORLOG:ERRLOG.OLD]  ?'/

	data	output_file	/'_OUTPUT FILE    [SYS$OUTPUT]            ?'/

	data	options		/'_OPTIONS        [ROLL-UP]               ?'/

	data	device_name	/'_DEVICE NAME    [<CR>]                  ?'/

	data	after_date	/'_AFTER DATE     [FIRST ENTRY]           ?'/

	data	before_date	/'_BEFORE DATE    [LAST ENTRY]            ?'/

C
C	EXTERNAL ROUTINES:
C

	external	sys$input_open
	external	sys$output_open
	external	lstlun_open

	INTEGER*4	SYS$BINTIM
	LOGICAL*4	SYS$TRNLOG
	LOGICAL*4	SYS$NUMTIM
	logical*1	sys$derlmb
	logical*1	sys$getchn
	logical*1	sys$crembx
	INTEGER*4	TIMCMP
 
	DATA		FORMS		/.TRUE./

	DATA		PRINTER		/.FALSE./
 
C++
C
C	FUNCTIONAL DESCRIPTION:
C
C	Main program for SYE, the VAX/VMS Errlog display program.
 
C
C	FORMAL PARAMETERS:
C
C				None.
 
C
C	IMPLICIT INPUTS:
C
C				None.
 
C
C	IMPLICIT OUTPUTS:
C
C				None.
 
C
C	SIDE EFFECTS:
C
C				None.
C--
 
C
C	INITIALIZE RUNTIME STATISTICAL PACKAGE
C

	CALL TIMRB
 
C
C	IDENTIFY PROGRAM AND REVISION
C

	TYPE 25,'SYE VERSION 3.5'
25	FORMAT('0',A,/)

C
C	OPEN KEYBOARD AND CONVERT LOWER TO UPPER CASE
C

	open(	unit = sys$input,
	1	name = 'sys$input',
	1	type = 'new',
	1	access = 'sequential',
	1	form   = 'formatted',
	1	useropen = sys$input_open,
	1	carriagecontrol = 'fortran')

	open(	unit = sys$output,
	1	name = 'sys$output',
	1	type = 'new',
	1	access = 'sequential',
	1	form   = 'formatted',
	1	useropen = sys$output_open,
	1	carriagecontrol = 'fortran')

C
C	ESTABLISH INPUT FILE NAME AND OPEN FILE
C

90	continue

	write(sys$output,100) input_file
100	format('$',a)

	read(sys$input,105,end=110) input_file_string_length,
	1 input_file_string
105	format(q,a)

	if (input_file_string_length .eq. 0) then

110	input_file_string = 'SYS$ERRORLOG:ERRLOG.OLD'

	input_file_string_length = 30

	else if (input_file_string .eq. 'MAILBOX') then

	ss$_status = sys$crembx (,sye_mailbox_channel,,,,,sye_mailbox)

	if (ss$_status .ne. ss$_normal) then

	call lib$insv (3,0,3,ss$_status)

	call lib$signal (%val(ss$_status))

	goto 90
	endif

	ss$_status = 
	1 sys$getchn (%val(sye_mailbox_channel),,getchn_buffer_string,,)

	if (ss$_status .ne. ss$_normal) then

	call lib$insv (3,0,3,ss$_status)

	call lib$signal (%val(ss$_status))

	goto 90
	endif

	sye_mailbox_unit = lib$extzv(0,16,getchn_buffer_array(13))

	ss$_status = sys$derlmb (%val(sye_mailbox_unit))

	if (ss$_status .ne. ss$_normal) then

	call lib$insv (3,0,3,ss$_status)

	call lib$signal (%val(ss$_status))

	goto 90
	endif

	input_file_string = 'SYE_MAILBOX'

	input_file_string_length = 11
	endif

	FILE_OPEN = 1

	OPEN(	UNIT = SYSLUN,
	1	NAME = input_file_string(1:input_file_string_length),
	2	TYPE = 'OLD',	
	3	READONLY,
	4	RECORDSIZE = 512,
	5	ERR = 200)
 
	GOTO 225

200	CONTINUE

	CALL ERRSNS (FNUM,RMSSTS,RMSSTV,IUNIT,CONDVAL)

	IF (RMSSTS .EQ. 0) THEN

	CALL LIB$INSV (3,0,3,CONDVAL)

	CALL LIB$SIGNAL (%VAL(CONDVAL),%VAL(3),%VAL(IUNIT),
	1 input_file_string(1:input_file_string_length))
	ELSE

	CALL LIB$INSV (3,0,3,RMSSTS)

	CALL LIB$SIGNAL (%VAL(RMSSTS),%VAL(RMSSTV))
	ENDIF

	if (error .eq. 8) then

	WRITE(sys$output,215) ERROR
215	FORMAT(' ','-SYE-F-OPENERR, FATAL OPEN ERROR AFTER ',I1,' RETRIES')

	STOP '-SYE-I-UNSUCCOM, UNSUCCESSFUL COMPLETION'
	endif

	ERROR = ERROR + 1

	GOTO (90,250) FILE_OPEN

225	ERROR = 0

C
C	Establish output filename and open file.
C

250	continue

	file_open = 2

	write(sys$output,100) output_file

	read(sys$input,105,end=255) output_file_string_length,
	1 output_file_string

	if (index(output_file_string,'/NOFORMS') .ne. 0) then

	forms = .false.

	output_file_string_length = lib$locc ('/',output_file_string)-1
	endif

	if (output_file_string_length .ne. 0) then

	open(	unit = lstlun,
	1	name = output_file_string(1:output_file_string_length),
	1	err  = 200,
	1	type = 'new',
	1	access = 'sequential',
	1	form   = 'formatted',
	1	useropen = lstlun_open,
	1	carriagecontrol = 'fortran')

	IF (FORMS
	1 .AND.
	2 JIAND(DEV_CHAR,TERM_DEV) .EQ. 0) PRINTER = .TRUE.
	ELSE

255	lstlun = sys$output

	output_file_string = '<CR>'

	output_file_string_length = 4
	ENDIF

C
C	Establish options.
C

300	CONTINUE
 
	write(sys$output,100) options

	read(sys$input,105,end=305) option_string_length,option_string

	option = option_string(1:1)

	if (option_string_length .eq. 0) then

305	option = 'R'

	option_string = '<CR>'

	option_string_length = 4

	else if (
	1 option_string(1:1) .ne. 'R'
	1 .and.
	1 option_string(1:1) .ne. 'S'
	1 .and.
	1 option_string(1:1) .ne. 'B'
	1 .and.
	1 option_string(1:1) .ne. 'C'
	1 ) then

	write(sys$output,312)
312	FORMAT('0','OPTIONS AVAILABLE',/,
	1 '0','R - ROLL UP',/,
	2 '$','C - CRYPTIC',/,
	3 '$','B - BRIEF',/,
	4 '$','S - STANDARD',/)

	GOTO 300
	ENDIF

C
C	ESTABLISH DEVICE SELECTION PARAMETERS
C

	goto 320

315	write(sys$output,316)
316	format(' ','%SYE-E-INVDEVNAM, INVALID DEVICE NAME STRING')

320	write(sys$output,100) device_name

	read(sys$input,105,end=325) device_name_string_length,
	1 device_name_string

322	if (device_name_string_length .ne. 0) then

	if (device_name_string(1:1) .eq. '-') then

	device_name_string(1:) = device_name_string(2:)

	negate = .true.

	device_name_string_length = device_name_string_length - 1

	goto 322

	else if (device_name_string(1:1) .eq. '/') then

	if (
	1 device_name_string(2:device_name_string_length) .eq. 'BU'
	1 .or.
	1 device_name_string(2:device_name_string_length) .eq. 'BU=NO_ORS'
	1 .or.
	1 device_name_string(2:device_name_string_length) .eq. 'SY'
	1 .or.
	1 device_name_string(2:device_name_string_length) .eq. 'ME'
	1 .or.
	1 device_name_string(2:device_name_string_length) .eq. 'CP'
	1 ) then

	goto 330

	else if (
	1 device_name_string(2:device_name_string_length) .eq. 'UN'
	1 ) then

	if (.not. negate) unknown = .true.

	goto 330

	else if (
	1 device_name_string(2:5) .eq. 'DE=('
	1 .or.
	1 device_name_string(2:5) .eq. 'DT=('
	1 .or.
	1 device_name_string(2:5) .eq. 'DA=('
	1 .or.
	1 device_name_string(2:5) .eq. 'CO=('
	1 ) then
	
	if (device_name_string(device_name_string_length:) .ne. ')') goto 315

	call string_parse (device_name_string(6:(device_name_string_length-1)),
	1 negate,*315)

	goto 330

	else if (
	1 device_name_string(2:4) .eq. 'DE='
	1 .or.
	1 device_name_string(2:4) .eq. 'DT='
	1 .or.
	1 device_name_string(2:4) .eq. 'DA='
	1 .or.
	1 device_name_string(2:4) .eq. 'CO='
	1 ) then
	
	call name_parse (device_name_string(5:device_name_string_length),
	1 negate,*315)

	goto 330
	endif

	goto 315

	else if (
	1 device_name_string(1:1) .ge. 'A'
	1 .and.
	1 device_name_string(1:1) .le. 'Z'
	1 ) then

	call name_parse (device_name_string(1:device_name_string_length),
	1 negate,*315)

	else if (device_name_string(1:1) .eq. '*') then

	goto 330
	else

	goto 315
	endif
	else

325	device_name_string = '<CR>'

	device_name_string_length = 4
	endif

C
C	Establish time period to inspect.
C

330	write(sys$output,100) after_date

	read(sys$input,105,end=335) after_date_string_length,after_date_string

	IF (after_date_string_length .NE. 0) THEN

	ss$_status = sys$bintim (after_date_string(1:after_date_string_length),
	1 seltimelo)

	if (ss$_status .ne. ss$_normal) then

	CALL LIB$INSV (3,0,3,ss$_status)

	CALL LIB$SIGNAL (%VAL(ss$_status))

	GOTO 330
	ENDIF
	else

335	after_date_string = '<CR>'

	after_date_string_length = 4
	endif
 
345	WRITE(sys$output,100) before_date

	READ(sys$input,105,end=350) before_date_string_length,
	1 before_date_string

	if (before_date_string_length .ne. 0) then

	ss$_status = SYS$BINTIM (before_date_string
	1 (1:before_date_string_length),SELTIMEHI)

	IF (ss$_status .ne. ss$_normal) THEN

	CALL LIB$INSV (3,0,3,ss$_status)

	CALL LIB$SIGNAL (%VAL(ss$_status))

	GOTO 345
	ENDIF
	else

350	before_date_string = '<CR>'

	before_date_string_length = 4
	endif
 
397	IF (FORMS .AND. (LSTLUN .EQ. sys$output)) THEN

	CALL LIB$SCREEN_INFO(FIELD)

	IF (jiand(FIELD,'01'x) .EQ. 0) THEN

	call set_rab$v_rne

	write(sys$output,400)
400	format('0','ALIGN PAPER TO TOP OF FORM STRIKE <CR> WHEN READY')

	read(sys$input,405,end=410)
405	format(a1)

410	call clear_rab$v_rne
	ELSE

	FORMS = .FALSE.
	ENDIF
	ENDIF

C
C	ZERO BUFFER AT START AND BETWEEN MESSAGES
C

500	CALL MOVC5 (%VAL(0),%REF(EMB(0)),%VAL(0),%VAL(512),%REF(EMB(0)))

C
C	UPDATE NUMBER OF RECORDS READ
C

520	RECCNT	= RECCNT + 1		! EOF BOUNDARY CONDITIONS
 
C
C	READ ERRLOG RECORD
C

	READ(SYSLUN,525,ERR=90050,END=90100)
	1 record_length,(EMB(I),I=0,(MAX(0,(MIN(512,(record_length-1))))))
525	FORMAT(Q,<MAX(1,record_length)>A1)

c
c	check for supported cpu type and valid entry type
c

	call validate_cpu_and_entry (emb$l_hd_sid,emb$w_hd_entry,cpu,entry)

c
c	if a device entry check for supported device class and type
c

	if (
	1 emb$w_hd_entry .eq. 1
	1 .or.
	1 emb$w_hd_entry .eq. 96
	1 .or.
	1 emb$w_hd_entry .eq. 98
	1 ) then

	call validate_device_class_and_type (emb$b_dv_class,emb$b_dv_type,
	1 class,type)

	else if (emb$w_hd_entry .eq. 99) then

	call validate_device_class_and_type (emb$b_sp_class,emb$b_sp_type,
	1 class,type)

	else if (emb$w_hd_entry .eq. 100) then

	call validate_device_class_and_type (emb$b_lm_class,emb$b_lm_type,
	1 class,type)
	endif

c
c	update summaries
c

	call entry_summary_update (cpu,entry,class,type)

C
C	Time check beginning period.
C

550	continue

	if (after_date_string_length .ne. 0) then

	IF (TIMCMP(emb$q_hd_time,SELTIMELO))  500,570,570
 
570	CONTINUE
	endif
 
C
C	Time check ending period.
C

	if (before_date_string_length .ne. 0) then

	IF (TIMCMP(emb$q_hd_time,SELTIMEHI))  580,580,500
 
580	CONTINUE
	endif

	if (
	1 device_name_string(1:1) .eq. '<'
	1 .or.
	1 device_name_string(1:device_name_string_length) .eq. '*'
	1 ) then

	if (negate) goto 500

	if (
	1 .not. cpu
	1 .or.
	1 .not. entry
	1 ) goto 500

	if (
	1 emb$w_hd_entry .eq. 1
	1 .or.
	1 emb$w_hd_entry .eq. 96
	1 .or.
	1 emb$w_hd_entry .eq. 98
	1 .or.
	1 emb$w_hd_entry .eq. 99
	1 .or.
	1 emb$w_hd_entry .eq. 100
	1 ) then

	if (
	1 .not. class
	1 .or.
	1 .not. type
	1 ) goto 500
	endif

	goto 600

	else if (device_name_string(1:1) .eq. '/') then

	if (device_name_string(2:3) .eq. 'CP') then

	if (.not. negate) then

	if (emb$w_hd_entry .eq. 2) goto	600			! machine check

	if (emb$w_hd_entry .eq. 4) goto 600			! SBI fault

	if (emb$w_hd_entry .eq. 5) goto 600			! SBI alert

	if (emb$w_hd_entry .eq. 7) goto 600			! SBI asynchronous write

	if (emb$w_hd_entry .eq. 9) goto 600			! uba interrupt

	if (emb$w_hd_entry .eq. 11) goto 600			! uba error

	if (emb$w_hd_entry .eq. 12) goto 600			! mba interrupt

	if (emb$w_hd_entry .eq. 97) goto 600			! undefined interrupt

	else if (negate) then

	if (emb$w_hd_entry .eq. 2) goto	500			! machine check

	if (emb$w_hd_entry .eq. 4) goto 500			! SBI fault

	if (emb$w_hd_entry .eq. 5) goto 500			! SBI alert

	if (emb$w_hd_entry .eq. 7) goto 500			! SBI asynchronous write

	if (emb$w_hd_entry .eq. 9) goto 500			! uba interrupt

	if (emb$w_hd_entry .eq. 11) goto 500			! uba error

	if (emb$w_hd_entry .eq. 12) goto 500			! mba interrupt

	if (emb$w_hd_entry .eq. 97) goto 500			! undefined interrupt

	if (
	1 emb$w_hd_entry .eq. 1
	1 .or.
	1 emb$w_hd_entry .eq. 96
	1 .or.
	1 emb$w_hd_entry .eq. 98
	1 .or.
	1 emb$w_hd_entry .eq. 99
	1 .or.
	1 emb$w_hd_entry .eq. 100
	1 ) then

	if (
	1 .not. class
	1 .or.
	1 .not. type
	1 ) goto 500
	endif

	goto 600
	endif

	else if (device_name_string(2:device_name_string_length) .eq. 'ME')
	1 then

	if (.not. negate) then

	if (emb$w_hd_entry .eq. 6) goto 600			! memory error (scanning code)

	if (emb$w_hd_entry .eq. 8) goto 600			! rds (machine check code)

	else if (negate) then

	if (emb$w_hd_entry .eq. 6) goto 500			! memory error (scanning code)

	if (emb$w_hd_entry .eq. 8) goto 500			! rds (machine check code)

	if (
	1 emb$w_hd_entry .eq. 1
	1 .or.
	1 emb$w_hd_entry .eq. 96
	1 .or.
	1 emb$w_hd_entry .eq. 98
	1 .or.
	1 emb$w_hd_entry .eq. 99
	1 .or.
	1 emb$w_hd_entry .eq. 100
	1 ) then

	if (
	1 .not. class
	1 .or.
	1 .not. type
	1 ) goto 500
	endif

	goto 600
	endif

	else if (device_name_string(2:3) .eq. 'SY') then

	if (.not. negate) then

	if (emb$w_hd_entry .eq. 32) goto 600			! system start-up

	if (emb$w_hd_entry .eq. 33) goto 600			! operator shutdown

	if (emb$w_hd_entry .eq. 34) goto 600			! system power fail

	if (emb$w_hd_entry .eq. 35) goto 600			! errlog.sys created

	if (emb$w_hd_entry .eq. 36) goto 600			! power fail restart

	if (emb$w_hd_entry .eq. 38) goto 600			! periodic time-stamp

	if (emb$w_hd_entry .eq. 39) goto 600			! $snderr message

	if (emb$w_hd_entry .eq. 41) goto 600			! operator message

	if (emb$w_hd_entry .eq. 42) goto 600			! network message

	else if (negate) then

	if (emb$w_hd_entry .eq. 32) goto 500			! system start-up

	if (emb$w_hd_entry .eq. 33) goto 500			! operator shutdown

	if (emb$w_hd_entry .eq. 34) goto 500			! system power fail

	if (emb$w_hd_entry .eq. 35) goto 500			! errlog.sys created

	if (emb$w_hd_entry .eq. 36) goto 500			! power fail restart

	if (emb$w_hd_entry .eq. 38) goto 500			! periodic time-stamp

	if (emb$w_hd_entry .eq. 39) goto 500			! $snderr message

	if (emb$w_hd_entry .eq. 41) goto 500			! operator message

	if (emb$w_hd_entry .eq. 42) goto 500			! network message

	if (
	1 emb$w_hd_entry .eq. 1
	1 .or.
	1 emb$w_hd_entry .eq. 96
	1 .or.
	1 emb$w_hd_entry .eq. 98
	1 .or.
	1 emb$w_hd_entry .eq. 99
	1 .or.
	1 emb$w_hd_entry .eq. 100
	1 ) then

	if (
	1 .not. class
	1 .or.
	1 .not. type
	1 ) goto 500
	endif

	goto 600
	endif

	else if (device_name_string(2:3) .eq. 'BU') then

	if (.not. negate) then

	if (
	1 emb$w_hd_entry .eq. 37
	1 .and.
	1 device_name_string(4:10) .eq. '=NO_ORS'
	1 .and.
	1 emb(244) .eq. 116
	1 ) goto 500

	if (emb$w_hd_entry .eq. 37) goto 600			! fatal bugcheck

	if (emb$w_hd_entry .eq. 40) goto 600			! non-fatal bugcheck

	if (emb$w_hd_entry .eq. 112) goto 600			! user bugcheck

	else if (negate) then

	if (
	1 emb$w_hd_entry .eq. 37
	1 .and.
	1 device_name_string(4:10) .eq. '=NO_ORS'
	1 .and.
	1 emb(244) .eq. 116
	1 ) goto 600

	if (emb$w_hd_entry .eq. 37) goto 500			! fatal bugcheck

	if (emb$w_hd_entry .eq. 40) goto 500			! non-fatal bugcheck

	if (emb$w_hd_entry .eq. 112) goto 500			! user bugcheck

	if (
	1 emb$w_hd_entry .eq. 1
	1 .or.
	1 emb$w_hd_entry .eq. 96
	1 .or.
	1 emb$w_hd_entry .eq. 98
	1 .or.
	1 emb$w_hd_entry .eq. 99
	1 .or.
	1 emb$w_hd_entry .eq. 100
	1 ) then

	if (
	1 .not. class
	1 .or.
	1 .not. type
	1 ) goto 500
	endif

	goto 600
	endif

	else if (device_name_string(2:3) .eq. 'UN') then

	if (.not. negate) then

	if (.not. cpu) goto 90000

	if (.not. entry) goto 90000

	if (
	1 emb$w_hd_entry .eq. 1
	1 .or.
	1 emb$w_hd_entry .eq. 96
	1 .or.
	1 emb$w_hd_entry .eq. 98
	1 .or.
	1 emb$w_hd_entry .eq. 99
	1 .or.
	1 emb$w_hd_entry .eq. 100
	1 ) then

	if (
	1 .not. class
	1 .or.
	1 .not. type	
	1 ) then

	goto 90000
	endif
	endif
	endif

	if (negate) goto 600

	else if (device_name_string(2:3) .eq. 'CO') then

	if (
	1 emb$w_hd_entry .eq. 64
	1 .or.
	1 emb$w_hd_entry .eq. 65
	1 ) then

	call name_q (emb$t_vm_name(1:emb$b_vm_namlng),,
	1 lib$extzv(0,16,emb$w_vm_unit),,.true.,*582)

	if (negate) goto 500

	goto 600

582	if (negate) goto 600
	else

	if (
	1 emb$w_hd_entry .eq. 1
	1 .or.
	1 emb$w_hd_entry .eq. 96
	1 .or.
	1 emb$w_hd_entry .eq. 98
	1 .or.
	1 emb$w_hd_entry .eq. 99
	1 .or.
	1 emb$w_hd_entry .eq. 100
	1 ) then

	if (
	1 .not. class
	1 .or.
	1 .not. type
	1 ) goto 500
	endif
	endif

	if (negate) goto 600

	else if (device_name_string(2:3) .eq. 'DE') then	! device error

	if (emb$w_hd_entry .eq. 1) then

	if (
	1 .not. class
	1 .or.
	1 .not. type
	1 ) goto 500

	call name_q (emb$t_dv_name(1:emb$b_dv_namlng),,
	1 lib$extzv(0,16,emb$w_dv_unit),,.true.,*584)

	if (negate) goto 500

	goto 600

	else if (emb$w_hd_entry .eq. 99) then

	if (
	1 .not. class
	1 .or.
	1 .not. type
	1 ) goto 500

	call name_q (emb$t_sp_name(1:emb$b_sp_namlng),,
	1 lib$extzv(0,16,emb$w_sp_unit),,.true.,*584)

	if (negate) goto 500

	goto 600

	else if (emb$w_hd_entry .eq. 100) then

	if (
	1 .not. class
	1 .or.
	1 .not. type
	1 ) goto 500

	call name_q (emb$t_lm_name(1:emb$b_lm_namlng),,
	1 lib$extzv(0,16,emb$w_lm_unit),,.true.,*584)

	if (negate) goto 500

	goto 600
	endif

584	if (negate) goto 600

	else if (device_name_string(2:3) .eq. 'DT') then	! device I/O timeout

	if (emb$w_hd_entry .eq. 96) then

	if (
	1 .not. class
	1 .or.
	1 .not. type
	1 ) goto 500

	call name_q (emb$t_dv_name(1:emb$b_dv_namlng),,
	1 lib$extzv(0,16,emb$w_dv_unit),,.true.,*586)

	if (negate) goto 500

	goto 600
	endif

586	if (negate) goto 600

	else if (device_name_string(2:3) .eq. 'DA') then	! device attention

	if (emb$w_hd_entry .eq. 98) then

	if (
	1 .not. class
	1 .or.
	1 .not. type
	1 ) goto 500

	call name_q (emb$t_dv_name(1:emb$b_dv_namlng),,
	1 lib$extzv(0,16,emb$w_dv_unit),,.true.,*588)

	if (negate) goto 500

	goto 600
	endif

588	if (negate) goto 600
	endif

	else if (
	1 emb$w_hd_entry .eq. 1
	1 .or.
	1 emb$w_hd_entry .eq. 96
	1 .or.
	1 emb$w_hd_entry .eq. 98
	1 ) then

	if (
	1 .not. class
	1 .or.
	1 .not. type
	1 ) goto 500

	call name_q (emb$t_dv_name(1:emb$b_dv_namlng),,
	1 lib$extzv(0,16,emb$w_dv_unit),,.true.,*590)

	if (negate) goto 500

	goto 600

590	if (negate) goto 600

	else if (
	1 emb$w_hd_entry .eq. 64
	1 .or.
	1 emb$w_hd_entry .eq. 65
	1 ) then

	call name_q (emb$t_vm_name(1:emb$b_vm_namlng),,
	1 lib$extzv(0,16,emb$w_vm_unit),,.true.,*592)

	if (negate) goto 500

	goto 600

592	if (negate) goto 600

	else if (emb$w_hd_entry .eq. 99) then

	if (
	1 .not. class
	1 .or.
	1 .not. type
	1 ) goto 500

	call name_q (emb$t_sp_name(1:emb$b_sp_namlng),,
	1 lib$extzv(0,16,emb$w_sp_unit),,.true.,*594)

	if (negate) goto 500

	goto 600

594	if (negate) goto 600

	else if (emb$w_hd_entry .eq. 100) then

	if (
	1 .not. class
	1 .or.
	1 .not. type
	1 ) goto 500

	call name_q (emb$t_lm_name(1:emb$b_lm_namlng),,
	1 lib$extzv(0,16,emb$w_lm_unit),,.true.,*596)

	if (negate) goto 500

	goto 600

596	if (negate) goto 600
	endif

c
c	mount or dismount, remember volume label
c

	if (emb$w_hd_entry .eq. 64) then

	call mount_volume (1,emb$l_hd_sid,emb$b_vm_namlng,emb$t_vm_name,
	1 emb$w_vm_unit,emb$t_vm_label,emb$l_vm_oprcnt,emb$l_vm_errcnt)

	else if (emb$w_hd_entry .eq. 65) then

	call dismount_volume (2,emb$l_hd_sid,emb$b_vm_namlng,emb$t_vm_name,
	1 emb$w_vm_unit,emb$t_vm_label,field,field)
	endif

	goto 500

600	continue

c
c	dispatch to the correct display module
c

	if (
	1 emb$w_hd_entry .eq. 1			! device error bit set
	1 .or.
	1 emb$w_hd_entry .eq. 96		! device I/O timeout
	1 .or.
	1 emb$w_hd_entry .eq. 98		! device attention
	1 ) then

	if (option .ne. 'C') then

	call rollup (emb$l_hd_sid,emb$b_dv_namlng,emb$t_dv_name,emb$w_dv_unit,
	1 emb$w_hd_entry,emb$l_dv_iosb1,emb$l_dv_opcnt,emb$w_dv_errcnt)
	endif
	
	call devices (lstlun,emb$b_dv_class,emb$b_dv_type,option)

	else if (emb$w_hd_entry .eq. 99) then	! erl$logstatus

	if (option .ne. 'C') then

	call rollup (emb$l_hd_sid,emb$b_sp_namlng,emb$t_sp_name,emb$w_sp_unit,
	1 emb$w_hd_entry,-1,emb$l_sp_opcnt,emb$w_sp_errcnt)
	endif

	call erl$logstatus_dispatcher (lstlun,record_length,reccnt,option)

	else if (emb$w_hd_entry .eq. 100) then	! erl$logmessage

	if (
	1 emb$w_lm_msgtyp .eq. 1
	1 .or.
	1 emb$w_lm_msgtyp .eq. 2
	1 .or.
	1 emb$w_lm_msgtyp .eq. 3
	1 .or.
	1 emb$w_lm_msgtyp .eq. 4
	1 .or.
	1 emb$w_lm_msgtyp .eq. 6
	1 .or.
	1 emb$w_lm_msgtyp .eq. 7
	1 ) then

	call rollup (emb$l_hd_sid,emb$b_lm_namlng,emb$t_lm_name,emb$w_lm_unit,
	1 emb$w_hd_entry,+1,-1,-1)
	endif

	call erl$logmessage_dispatcher (lstlun,record_length,reccnt,option)

	else if (emb$w_hd_entry .eq. 2) then	! machine check

	call mchecks (lstlun,option)

	else if (
	1 emb$w_hd_entry .eq. 4			! SBI fault
	1 .or.
	1 emb$w_hd_entry .eq. 7			! SBI asynchronous write
	1 ) then

	IF (OPTION .EQ. 'S') THEN

	CALL SBI (LSTLUN)

	ELSE IF (OPTION .EQ. 'B') THEN

	CALL B_SBI (LSTLUN)
	ENDIF

	else if (emb$w_hd_entry .eq. 5) then	! SBI alert

	call memory (lstlun,option)

	else if (
	1 emb$w_hd_entry .eq. 6			! memory error (scanning code)
	1 .or.
	1 emb$w_hd_entry .eq. 8			! rds error (machine check)
	1 ) then

	call memory (lstlun,option)

	else if (emb$w_hd_entry .eq. 9) then	! uba interrupt

	call uba_interrupts (lstlun,option)

	else if (emb$w_hd_entry .eq. 11) then	! uba error

	call uba_errors (lstlun,option)

	else if (emb$w_hd_entry .eq. 12) then	! mba interrupt

	call mba_interrupts (lstlun,option)

	else if (
	1 emb$w_hd_entry .eq. 32		! system start-up
	1 .or.
	1 emb$w_hd_entry .eq. 36		! system power fail recovery
	1 ) then

	IF (OPTION .EQ. 'S'
	1 .OR.
	2 OPTION .EQ. 'B') THEN

	call header (lstlun)

	IF (EMB$W_HD_ENTRY .EQ. '20'X) THEN

	call logger (lstlun,'SYSTEM START-UP')

	ELSE IF (EMB$W_HD_ENTRY .EQ. '24'X) THEN

	call logger (lstlun,'POWER-FAIL RESTART')
	ENDIF
	ENDIF

	IF (OPTION .EQ. 'S') THEN

	CALL LINCHK (LSTLUN,2)

	WRITE (LSTLUN,2111) (emb(16 + i),i = 3,0,-1)
2111	FORMAT('0','TIME OF DAY CLOCK',T24,4Z2.2)
	ENDIF
 
	else if (emb$w_hd_entry .eq. 34) then	! system power fail

	IF (OPTION .EQ. 'S'
	1 .OR.
	2 OPTION .EQ. 'B') THEN

	call header (lstlun)

	call logger (lstlun,'SYSTEM POWER-FAIL')
	ENDIF

	else if (
	1 emb$w_hd_entry .eq. 35		! errlog.sys created
	1 .or.
	1 emb$w_hd_entry .eq. 38		! time stamp
	1 ) then

	IF (OPTION .EQ. 'S'
	1 .OR.
	2 OPTION .EQ. 'B') THEN

	call header (lstlun)

	IF (EMB$W_HD_ENTRY .EQ. '23'X) THEN

	call logger (lstlun,'ERRLOG.SYS CREATED')

	ELSE IF (EMB$W_HD_ENTRY .EQ. '26'X) THEN

	call logger (lstlun,'TIME STAMP')
	ENDIF
	ENDIF
 
	else if (
	1 emb$w_hd_entry .eq. 37		! fatal bugcheck
	1 .or.
	1 emb$w_hd_entry .eq. 40		! non-fatal bugcheck
	1 .or.
	1 emb$w_hd_entry .eq. 112		! user bugcheck
	1 ) then
 
	IF (OPTION .EQ. 'S') THEN

	CALL BUGCHK (LSTLUN)

	ELSE IF (OPTION .EQ. 'B') THEN

	CALL B_BUGCHK (LSTLUN)
	ENDIF
 
	else if (
	1 emb$w_hd_entry .eq. 39		! $snderr message
	1 .or.
	1 emb$w_hd_entry .eq. 41		! operator message
	1 .or.
	1 emb$w_hd_entry .eq. 42		! network message
	1 ) then

	IF (OPTION .EQ. 'S'
	1 .OR.
	2 OPTION .EQ. 'B') THEN

	call header (lstlun)

	IF (EMB$W_HD_ENTRY .EQ. '27'X) THEN

	call logger (lstlun,'$SNDERR MESSAGE')

	ELSE IF (EMB$W_HD_ENTRY .EQ. '29'X) THEN

	call logger (lstlun,'OPERATOR MESSAGE')

	ELSE IF (EMB$W_HD_ENTRY .EQ. '2A'X) THEN

	call logger (lstlun,'NETWORK MESSAGE')
	ENDIF
	ENDIF

	if (
	1 option .eq. 'S'
	1 .or.
	1 option .eq. 'B'
	1 ) then

	CALL LINCHK (LSTLUN,3)

	WRITE(LSTLUN,2605)
2605	FORMAT('0','MESSAGE TEXT',/)

	IF (EMB$W_SS_MSGSZ .NE. 0) THEN

	DO 2615,I = 0,(EMB$W_SS_MSGSZ/56)

	J = I*56

	CALL LINCHK (LSTLUN,1)

	WRITE(LSTLUN,2610) EMB$T_SS_MSGTXT(MAX(1,J):
	1 (J + MIN(55,EMB$W_SS_MSGSZ - J)))
2610	FORMAT(' ',T8,A)
 
2615	CONTINUE
	ELSE

	CALL LINCHK (LSTLUN,1)

	WRITE(LSTLUN,2620)
2620	FORMAT(' ',T8,'[NONE]')
	ENDIF
	ENDIF
 
	else if (emb$w_hd_entry .eq. 64) then			! mount volume

	call label (1,emb$l_hd_sid,emb$b_vm_namlng,emb$t_vm_name,
	1 emb$w_vm_unit,emb$t_vm_label,emb$l_vm_oprcnt,emb$l_vm_errcnt)

	call mount (lstlun,option)

	else if (emb$w_hd_entry .eq. 65) then			! dismount volume

	call label (2,emb$l_hd_sid,emb$b_vm_namlng,emb$t_vm_name,
	1 emb$w_vm_unit,emb$t_vm_label,emb$l_vm_oprcnt,emb$l_vm_errcnt)

	call dismount (lstlun,option)
 
	else if (emb$w_hd_entry .eq. 97) then			! undefined interrupt

	IF (OPTION .EQ. 'S') THEN

	CALL UNDEFINED (LSTLUN)

	ELSE IF (OPTION .EQ. 'B') THEN

	CALL B_UNDEFINED (LSTLUN)
	ENDIF
	endif

c
c	update records processed
c

	recproc = recproc + 1

c
c	update histogram for this cpu
c

	call processed_entries_histo_update

c
c	cancel control-o break-thru
c

c	call clear_rab$v_cco

c
c	get next record
c

	goto 500

C
C	UNKNOWN/UNSUPPORTED ENTRIES
C

90000	CONTINUE

	IF (UNKNOWN) THEN

	RECPROC = RECPROC + 1

	if (after_date_string_length .ne. 0) then

	IF (TIMCMP(emb$q_hd_time,SELTIMELO)) 500,90001,90001

90001	CONTINUE
	endif

	if (before_date_string_length .ne. 0) then

	IF (TIMCMP(emb$q_hd_time,SELTIMEHI)) 90002,90002,500

90002	CONTINUE
	endif

	if (
	1 option .eq. 'B'
	1 .or.
	1 option .eq. 'S'
	1 ) then

	call header (lstlun)

	if (
	1 cpu
	1 .and.
	1 .not. entry
	1 ) then

	call logger (lstlun,'UNKNOWN ENTRY')

	else if (
	1 cpu
	1 .and.
	1 (emb$w_hd_entry .eq. 1
	1 .or.
	1 emb$w_hd_entry .eq. 96
	1 .or.
	1 emb$w_hd_entry .eq. 98)
	1 .and.
	1 (.not. class
	1 .or.
	1 .not. type)
	1 ) then

	call logger (lstlun,'"UNKNOWN DEVICE" ENTRY')

	else if (.not. cpu) then

	call logger (lstlun,'"UNKNOWN CPU" ENTRY')
	endif
	ENDIF

	IF (OPTION .EQ. 'S') THEN

	CALL UNKNOWN1 (LSTLUN)

c
c	unknown device (class(?),type(?))
c

	if (
	1 emb$w_hd_entry .eq. 1
	1 .or.
	1 emb$w_hd_entry .eq. 96
	1 ) then

	CALL UNKNOWN2 (LSTLUN)

	else if (emb$w_hd_entry .eq. 98) then

	call unknown3 (lstlun)
	else

	CALL DUMPREG (LSTLUN,(((record_length + 3)/4) - 4),EMB(16))
	endif
	ENDIF
	endif
 
	GOTO 500
 
C
C	ERROR READING INPUT FILE
C

90050	CONTINUE

	WRITE(sys$output,90055)
90055	FORMAT('0','%SYE-F-FATIOERR, FATAL I/O ERROR READING INPUT FILE')

	WRITE(sys$output,90060)
90060	FORMAT(' ','%SYE-I-NOMOREPR, NO MORE RECORDS WILL BE PROCESSED',
	1 /)

C
C	END OF FILE ON INPUT FILE
C

90100	CONTINUE
 
	CLOSE (UNIT = SYSLUN)

c
c	Display any mscp messages
c

	call dudriver_mscp_dq (lstlun,option)
 
C
C	DISPLAY MAJOR ENTRY SUMMARIES BASED ON CONTENTS OF INPUT FILE
C

90300	CONTINUE
 
	if (option .ne. 'C') then

	call display_rollup (lstlun)

	call label_out (lstlun)

	call memory_display (lstlun)

	call entry_summary_output (lstlun)

C
C	DISPLAY 'SYE' EXECUTION STATISTICS
C

	call frctof (lstlun)

	if (printer) then

	call linchk (lstlun,8)

	write(lstlun,90325) 'FILE PROCESSING CONTROL PARAMETERS'
90325	format('0',a,/)

	write(lstlun,90327)
	1 input_file//input_file_string(1:input_file_string_length),
	1 output_file//output_file_string(1:output_file_string_length),
	1 options//option_string(1:option_string_length)

	if (negate) then

	write(lstlun,90327) device_name//'-'//
	1 device_name_string(1:device_name_string_length)
	else

	write(lstlun,90327)
	1 device_name//device_name_string(1:device_name_string_length)
	endif

	write(lstlun,90327)
	1 after_date//after_date_string(1:after_date_string_length),
	1 before_date//before_date_string(1:before_date_string_length)
90327	format(' ',(t8,a))
	endif

	CALL LINCHK (LSTLUN,3)

	WRITE(LSTLUN,90321)  RECPROC,RECCNT-1
90321	FORMAT('0',T8,'RECORDS PROCESSED',T<40 - compress4(recproc)>,
	1 i<compress4(recproc)>,'.',/,
	2 T8,'RECORDS READ',T<40 - compress4(reccnt-1)>,I<compress4(reccnt-1)>,
	3 '.')

	CALL TIMRE (LSTLUN)
	ENDIF
 
C
C	CLOSE FILES AND EXIT
C

	if (sys$output .ne. lstlun) then

	close (unit = sys$output)
	endif

	close (unit = sys$input)

	CLOSE (UNIT = LSTLUN)

	TYPE 90335,'%SYE-I-SUCCOM, SUCCESSFUL COMPLETION'
90335	FORMAT('0',A)

	END
