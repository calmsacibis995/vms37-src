	subroutine mftape (lun)
C
C	Version 'V03-000'
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

C
C	Functional description:
C
C	This module displays error log entries for the TU78 tape drive.
C
C	Modified by:
C
C	v02-004	BP0004		Brian Porter,		07-FEB-1982
C		Corrected call to mba_control_etc..
C
C	v02-003	BP0003		Brian Porter,		18-NOV-1981
C		Added new mba code.  Minor edit.
C
C	v02-002	BP0002		Brian Porter,		06-NOV-1981
C		Added 'device attention' support.
C
C	v02-001	BP0001		Brian Porter,		01-JUL-1981
C		Added call to LOGGER and DHEAD.
C**

C
C	This is the format of the error log entry for the TU78.
C
C
C	+------------------------------+
C	|                              |
C	+--                          --+
C	|                              |
C	+--          header          --+
C	|                              |
C	+--                          --+
C	|                              |
C	+------------------------------+
C	|            mf cs1            |
C	+------------------------------+
C	|            mf is             |
C	+------------------------------+
C	|            mf tc             |
C	+------------------------------+
C	|            mf mr1            |
C	+------------------------------+
C	|            mf ab             |
C	+------------------------------+
C	|            mf bc             |
C	+------------------------------+
C	|            mf dt             |
C	+------------------------------+
C	|            mf ds             |
C	+------------------------------+
C	|            mf sn             |
C	+------------------------------+
C	|            mf mr2            |
C	+------------------------------+
C	|            mf mr3            |
C	+------------------------------+
C	|            mf ndta           |
C	+------------------------------+
C	|            mf ndt0           |
C	+------------------------------+
C	|            mf ndt1           |
C	+------------------------------+
C	|            mf ndt2           |
C	+------------------------------+
C	|            mf ndt3           |
C	+------------------------------+
C	|            mf id             |
C	+------------------------------+
C	|         ucb$l_mf_cmd         |
C	+------------------------------+
C	|                              |
C	+--                          --+
C	|                              |
C	+--                          --+
C	/         60 bytes             /
C	/  extended sense information  /
C	+--                          --+
C	|                              |
C	+--                          --+
C	|                              |
C	+------------------------------+
C




	include 'src$:msghdr.for /nolist'

	include 'src$:deverr.for /nolist'



	byte		lun

	integer*4	field

	integer*4	dt_fcode

	integer*4	ndt_fcode

	integer*4	dt_cmdaddr

	integer*4	ndt_cmdaddr

	integer*4	dt_intcode

	integer*4	ndt_intcode

	integer*4	dt_function

	integer*4	ndt_function

	integer*4	attn_bit_this_ucb

	integer*4	compress4

	integer*4	compressc

	integer*4	lib$extzv

	integer*4	lib$extv

	logical*1	diagnostic_mode

	integer*4	ucb$l_mf_cmd

	integer*4	selected_map_register

	integer*4	adapter_registers(7)

	integer*4	mf_cs1

	integer*4	mf_is

	integer*4	mf_tc

	integer*4	mf_mr1

	integer*4	mf_ab

	integer*4	mf_bc

	integer*4	mf_dt

	integer*4	mf_ds

	integer*4	mf_sn

	integer*4	mf_mr2

	integer*4	mf_mr3

	integer*4	mf_ndta

	integer*4	mf_ndt(0:3)

	integer*4	mf_id

	integer*4	ucb_unit_number

	byte		mf_exsns(60)

	character*27	v1interrupt_code(13)

	character*31	v2interrupt_code(15:28)

	character*18	fcode_intcode1(0:1)

	character*31	fcode_intcode3(3)

	character*32	fcode_intcode9(3)

	character*24	fcode_intcode13(4)

	character*28	fcode_intcode18(11)

	character*29	fcode_intcode28(2)

	character*31	v1ndt_function(19)

	character*20	v1dt_function(20:20)

	character*20	v2dt_function(23:25)

	character*15	v3dt_function(28:29)

	character*13	v4dt_function(31:31)

	character*23	v1mf_dt(10:11)

	character*22	v2mf_dt(14:15)

	character*32	v1mf_ds(4:4)

	character*15	v2mf_ds(6:15)
 
	character*27	mf_tc_format(0:6)

	character*29	v1mf_id(8:15)

	character*14	v1mf_is(8:8)

	character*7	v1mf_cs1(0:0)

	character*16	v2mf_cs1(11:11)

	character*29	v1mf_tc(15:15)

	character*22	v1mf_exsns5(0:7)

	character*17	v1mf_exsns13(0:7)

	character*30	v1mf_exsns18(0:7)

	character*21	v1mf_exsns30(0:7)

	character*18	v1mf_exsns32(3:7)

	character*15	v1mf_exsns33(0:7)

	character*21	v1mf_exsns34(0:7)

	character*29	v1mf_exsns47(3:7)

	character*33	v1mf_exsns48(0:7)

	character*13	v1mf_exsns49(0:7)

	character*14	v1mf_exsns50(0:7)

	character*21	v1mf_exsns51(5:7)

	character*20	v1mf_exsns54(2:7)

	character*26	v1mf_exsns56(5:7)

	character*30	v1mf_exsns57(0:7)

	character*8	v1tu_selx(2:5,0:1)

	character*6	reg_herald(0:16)

	equivalence	(emb$l_dv_regsav(0),adapter_registers)

	equivalence	(emb$l_dv_regsav(7),mf_cs1)

	equivalence	(emb$l_dv_regsav(8),mf_is)

	equivalence	(emb$l_dv_regsav(9),mf_tc)

	equivalence	(emb$l_dv_regsav(10),mf_mr1)

	equivalence	(emb$l_dv_regsav(11),mf_ab)

	equivalence	(emb$l_dv_regsav(12),mf_bc)

	equivalence	(emb$l_dv_regsav(13),mf_dt)

	equivalence	(emb$l_dv_regsav(14),mf_ds)

	equivalence	(emb$l_dv_regsav(15),mf_sn)

	equivalence	(emb$l_dv_regsav(16),mf_mr2)

	equivalence	(emb$l_dv_regsav(17),mf_mr3)

	equivalence	(emb$l_dv_regsav(18),mf_ndta)

	equivalence	(emb$l_dv_regsav(19),mf_ndt(0))

	equivalence	(emb$l_dv_regsav(23),mf_id)

	equivalence	(emb$l_dv_regsav(24),ucb$l_mf_cmd,ucb$w_mf_cmd)

	equivalence	(emb$l_dv_regsav(26),mf_exsns)



	DATA	V1INTERRUPT_CODE(1)	/'OPERATION COMPLETED*'/

	DATA	V1INTERRUPT_CODE(2)	/'UNEXPECTED TAPE MARK FOUND*'/

	DATA	V1INTERRUPT_CODE(3)	/'UNEXPECTED BOT*'/

	DATA	V1INTERRUPT_CODE(4)	/'TAPE AT OR BEYOND EOT*'/

	DATA	V1INTERRUPT_CODE(5)	/'UNEXPECTED LOGICAL EOT*'/

	DATA	V1INTERRUPT_CODE(6)	/'NO-OP COMPLETED*'/

	DATA	V1INTERRUPT_CODE(7)	/'TAPE UNIT REWINDING*'/

	DATA	V1INTERRUPT_CODE(8)	/'TAPE UNIT WRITE PROTECTED*'/

	DATA	V1INTERRUPT_CODE(9)	/'SUB-SYSTEM NOT READY*'/

	DATA	V1INTERRUPT_CODE(10)	/'TAPE UNIT NOT AVAILABLE*'/

	DATA	V1INTERRUPT_CODE(11)	/'TAPE UNIT OFF-LINE*'/

	DATA	V1INTERRUPT_CODE(12)	/'TAPE UNIT NON-EXISTENT*'/

	DATA	V1INTERRUPT_CODE(13)	/'SUB-SYSTEM NOT CAPABLE*'/



	DATA	V2INTERRUPT_CODE(15)	/'TAPE UNIT ON-LINE TRANSITION*'/

	DATA	V2INTERRUPT_CODE(16)	/'LONG RECORD*'/

	DATA	V2INTERRUPT_CODE(17)	/'SHORT RECORD*'/

	DATA	V2INTERRUPT_CODE(18)	/'RETRY*'/

	DATA	V2INTERRUPT_CODE(19)	/'RETRY OPPOSITE*'/

	DATA	V2INTERRUPT_CODE(20)	/'UNREADABLE*'/

	DATA	V2INTERRUPT_CODE(21)	/'ERROR (RETRIES SUPPRESSED)*'/

	DATA	V2INTERRUPT_CODE(22)	/'EOT ERROR (RETRIES SUPPRESSED)*'/

	DATA	V2INTERRUPT_CODE(23)	/'BAD TAPE*'/

	DATA	V2INTERRUPT_CODE(24)	/'TM FAULT A*'/

	DATA	V2INTERRUPT_CODE(25)	/'TU FAULT A*'/

	DATA	V2INTERRUPT_CODE(26)	/'TM FAULT B*'/

	DATA	V2INTERRUPT_CODE(27)	/'TU FAULT B*'/

	DATA	V2INTERRUPT_CODE(28)	/'MASSBUS CONTROL BUS FAULT*'/




	DATA	FCODE_INTCODE1(0)	/'EXSNS NOT UPDATED*'/

	DATA	FCODE_INTCODE1(1)	/'EXSNS UPDATED*'/



	DATA	FCODE_INTCODE3(1)	/'TAPE ALREADY AT BOT*'/

	DATA	FCODE_INTCODE3(2)	/'BOT DETECTED AFTER TAPE MOTION*'/

	DATA	FCODE_INTCODE3(3)	/'ARA ID DETECTED*'/



	DATA	FCODE_INTCODE9(1)	/'TAPE UNIT ON-LINE BUT NOT READY*'/

	DATA	FCODE_INTCODE9(2)	/'FATAL ERROR, TM CLEAR REQUIRED*'/

	DATA	FCODE_INTCODE9(3)	/'ACCESS ONLY, DRIVE BUSY*'/



	DATA	FCODE_INTCODE13(1)	/'BLANK TAPE*'/

	DATA	FCODE_INTCODE13(2)	/'ID MARKER NOT PE OR GCR*'/

	DATA	FCODE_INTCODE13(3)	/'ARA ID NOT FOUND*'/

	DATA	FCODE_INTCODE13(4)	/'NO GAP AFTER ID BURST*'/



	DATA	FCODE_INTCODE18(1)	/'GCR WRITE OPERATION FAILURE*'/

	DATA	FCODE_INTCODE18(2)	/'GCR READ OPERATION FAILURE*'/

	DATA	FCODE_INTCODE18(3)	/'PE READ OPERATION FAILURE*'/

	DATA	FCODE_INTCODE18(4)	/'PE WRITE OPERATION FAILURE*'/

	DATA	FCODE_INTCODE18(5)	/'ECCSTA BIT(S) SET*'/

	DATA	FCODE_INTCODE18(6)	/'PE WRITE OPERATION FAILURE*'/

	DATA	FCODE_INTCODE18(7)	/'GCR WRITE OPERATION FAILURE*'/

	DATA	FCODE_INTCODE18(8)	/'RSTAT CONTAINS BAD CODE*'/

	DATA	FCODE_INTCODE18(9)	/'PE WRITE OPERATION FAILURE*'/

	DATA	FCODE_INTCODE18(10)	/'MASSBUS DATA PARITY ERROR*'/

	DATA	FCODE_INTCODE18(11)	/'RETRY OPPOSITE FAILURE*'/



	DATA	FCODE_INTCODE28(1)	/'MASSBUS CONTROL PARITY ERROR*'/

	DATA	FCODE_INTCODE28(2)	/'ILLEGAL REGISTER REFERENCE*'/



	DATA	V1NDT_FUNCTION(1)	/'NO-OPERATION*'/

	DATA	V1NDT_FUNCTION(2)	/'UNLOAD*'/

	DATA	V1NDT_FUNCTION(3)	/'REWIND*'/

	DATA	V1NDT_FUNCTION(4)	/'SENSE*'/

	DATA	V1NDT_FUNCTION(5)	/'DSE*'/

	DATA	V1NDT_FUNCTION(6)	/'WRITE TM (PE)*'/

	DATA	V1NDT_FUNCTION(7)	/'WRITE TM (GCR)*'/

	DATA	V1NDT_FUNCTION(8)	/'SPACE FORWARD RECORD(S)*'/

	DATA	V1NDT_FUNCTION(9)	/'SPACE REVERSE RECORD(S)*'/

	DATA	V1NDT_FUNCTION(10)	/'SPACE FORWARD FILE(S)*'/

	DATA	V1NDT_FUNCTION(11)	/'SPACE REVERSE FILE(S)*'/

	DATA	V1NDT_FUNCTION(12)	/'SPACE FORWARD EITHER*'/

	DATA	V1NDT_FUNCTION(13)	/'SPACE REVERSE EITHER*'/

	DATA	V1NDT_FUNCTION(14)	/'EXTENDED RECORD GAP, SET PE*'/

	DATA	V1NDT_FUNCTION(15)	/'EXTENDED RECORD GAP, SET GCR*'/

	DATA	V1NDT_FUNCTION(16)	/'CLOSE FILE, PE*'/

	DATA	V1NDT_FUNCTION(17)	/'CLOSE FILE, GCR*'/

	DATA	V1NDT_FUNCTION(18)	/'SPACE TO LOGICAL EOT*'/

	DATA	V1NDT_FUNCTION(19)	/'SPACE FORWARD FILE/LOGICAL EOT*'/



	DATA	V1DT_FUNCTION(20)	/'WRITE CHECK FORWARD*'/



	DATA	V2DT_FUNCTION(23)	/'WRITE CHECK REVERSE*'/

	DATA	V2DT_FUNCTION(24)	/'WRITE PE*'/

	DATA	V2DT_FUNCTION(25)	/'WRITE GCR*'/



	DATA	V3DT_FUNCTION(28)	/'READ FORWARD*'/

	DATA	V3DT_FUNCTION(29)	/'EXTENDED SENSE*'/



	DATA	V4DT_FUNCTION(31)	/'READ REVERSE*'/



	DATA	V1MF_DT(10)		/'SLAVE PRESENT*'/

	DATA	V1MF_DT(11)		/'DRIVE REQUEST REQUIRED*'/



	DATA	V2MF_DT(14)		/'TAPE DRIVE*'/

	DATA	V2MF_DT(15)		/'NOT BLOCK ADDRESSABLE*'/



	DATA	V1MF_DS(4)		/'PERFORMING ERASE OF DES COMMAND*'/




	DATA	V2MF_DS(6)		/'TM SHARED*'/

	DATA	V2MF_DS(7)		/'TM AVAILABLE*'/

	DATA	V2MF_DS(8)		/'WRITE PROTECTED*'/

	DATA	V2MF_DS(9)		/'BEYOND EOT*'/

	DATA	V2MF_DS(10)		/'TAPE AT BOT*'/

	DATA	V2MF_DS(11)		/'PE MODE*'/

	DATA	V2MF_DS(12)		/'REWINDING*'/

	DATA	V2MF_DS(13)		/'ON-LINE*'/

	DATA	V2MF_DS(14)		/'POWER APPLIED*'/

	DATA	V2MF_DS(15)		/'READY*'/




	DATA	MF_TC_FORMAT(0)		/'11 NORMAL*'/

	DATA	MF_TC_FORMAT(1)		/'15 NORMAL*'/

	DATA	MF_TC_FORMAT(2)		/'10 COMPATIBLE*'/

	DATA	MF_TC_FORMAT(3)		/'10 CORE DUMP*'/

	DATA	MF_TC_FORMAT(4)		/'10 HIGH DENSITY COMPATIBLE*'/

	DATA	MF_TC_FORMAT(5)		/'IMAGE*'/

	DATA	MF_TC_FORMAT(6)		/'10 HIGH DENSITY DUMP*'/



	DATA	V1MF_ID(8)		/'HOLD*'/

	DATA	V1MF_ID(9)		/'HLDA*'/

	DATA	V1MF_ID(10)		/'EVEN PARITY*'/

	DATA	V1MF_ID(11)		/'MASSBUS CONTROL PARITY ERROR*'/

	DATA	V1MF_ID(12)		/'ILLEGAL REGISTER REFERENCE*'/

	DATA	V1MF_ID(13)		/'MICRO PROC. ROM PARITY ERROR*'/

	DATA	V1MF_ID(14)		/'TM CLEAR*'/

	DATA	V1MF_ID(15)		/'TM READY*'/



	DATA	V1MF_IS(8)		/'DRIVE PRESENT*'/



	DATA	V1MF_TC(15)		/'SUPPRESS ERROR REPOSITIONING*'/



	DATA	V1MF_CS1(0)		/'GO BIT*'/



	DATA	V2MF_CS1(11)		/'DRIVE AVAILABLE*'/




	DATA	V1MF_EXSNS5(0)		/'WRITE FAIL P*'/

	DATA	V1MF_EXSNS5(1)		/'STATISTICS SELECT*'/

	DATA	V1MF_EXSNS5(2)		/'CLOCK STOPPED*'/

	DATA	V1MF_EXSNS5(3)		/'BEGINNING OF PREAMBLE*'/

	DATA	V1MF_EXSNS5(4)		/'DATA NOT READY*'/

	DATA	V1MF_EXSNS5(5)		/'PREAMBLE ERROR*'/

	DATA	V1MF_EXSNS5(6)		/'STATUS VALID*'/

	DATA	V1MF_EXSNS5(7)		/'VELOCITY ok*'/



	DATA	V1MF_EXSNS13(0)		/'AMTIE P*'/

	DATA	V1MF_EXSNS13(1)		/'NOT DONE P*'/

	DATA	V1MF_EXSNS13(2)		/'ILLEGAL P*'/

	DATA	V1MF_EXSNS13(3)		/'MARK 2 P*'/

	DATA	V1MF_EXSNS13(4)		/'END P*'/

	DATA	V1MF_EXSNS13(5)		/'POST P*'/

	DATA	V1MF_EXSNS13(6)		/'DATA P*'/

	DATA	V1MF_EXSNS13(7)		/'CORRECTED DATA P*'/



	DATA	V1MF_EXSNS18(0)		/'SINGLE TRACK ERROR CORRECTION*'/

	DATA	V1MF_EXSNS18(1)		/'TWO TRACK ERROR CORRECTION*'/

	DATA	V1MF_EXSNS18(2)		/'UNCORRECTABLE*'/

	DATA	V1MF_EXSNS18(3)		/'POINTER MISMATCH*'/

	DATA	V1MF_EXSNS18(4)		/'ACRC ERROR*'/

	DATA	V1MF_EXSNS18(5)		/'AMTIE OCCURRED*'/

	DATA	V1MF_EXSNS18(6)		/'ECC ROM PARITY ERROR*'/

	DATA	V1MF_EXSNS18(7)		/'CRC ERROR*'/



	DATA	V1MF_EXSNS30(0)		/'AMTIE PARITY BIT*'/

	DATA	V1MF_EXSNS30(1)		/'READ PARITY BIT*'/

	DATA	V1MF_EXSNS30(2)		/'WCS PARITY BIT*'/

	DATA	V1MF_EXSNS30(3)		/'TACHOMETER*'/

	DATA	V1MF_EXSNS30(4)		/'TAPE UNIT PRESENT*'/

	DATA	V1MF_EXSNS30(5)		/'COMMAND PARITY ERROR*'/

	DATA	V1MF_EXSNS30(6)		/'WRITE DATA STROBE*'/

	DATA	V1MF_EXSNS30(7)		/'STATUS PARITY ERROR*'/



	DATA	V1MF_EXSNS32(3)		/'MASSBUS ATTN*'/

	DATA	V1MF_EXSNS32(4)		/'ILLEGAL REGISTER*'/

	DATA	V1MF_EXSNS32(5)		/'CAS PARITY ERROR*'/

	DATA	V1MF_EXSNS32(6)		/'TM READY*'/

	DATA	V1MF_EXSNS32(7)		/'CONTENTION*'/



	DATA	V1MF_EXSNS33(0)		/'ONLINE*'/

	DATA	V1MF_EXSNS33(1)		/'-5V OK*'/

	DATA	V1MF_EXSNS33(2)		/'LEFT*'/

	DATA	V1MF_EXSNS33(3)		/'MASSBUS FAIL*'/

	DATA	V1MF_EXSNS33(4)		/'MASSBUS INIT*'/

	DATA	V1MF_EXSNS33(5)		/'MASSBUS DEMAND*'/

	DATA	V1MF_EXSNS33(6)		/'MASSBUS TRA*'/

	DATA	V1MF_EXSNS33(7)		/'MASSBUS ATTN*'/



	DATA	V1MF_EXSNS34(0)		/'MASSBUS SCLK*'/

	DATA	V1MF_EXSNS34(1)		/'SCLK OUT*'/

	DATA	V1MF_EXSNS34(2)		/'MASSBUS RUN*'/

	DATA	V1MF_EXSNS34(3)		/'MASSBUS EXC*'/

	DATA	V1MF_EXSNS34(4)		/'MASSBUS EBL*'/

	DATA	V1MF_EXSNS34(5)		/'MASSBUS OCC*'/

	DATA	V1MF_EXSNS34(6)		/'MASSBUS WCLK*'/

	DATA	V1MF_EXSNS34(7)		/'MASSBUS WRITE ENABLE*'/



	DATA	V1MF_EXSNS47(3)		/'DR READ PARITY ERROR*'/

	DATA	V1MF_EXSNS47(4)		/'WMC ROM PARITY ERROR*'/

	DATA	V1MF_EXSNS47(5)		/'ERROR*'/

	DATA	V1MF_EXSNS47(6)		/'DR MASSBUS DATA PARITY ERROR*'/

	DATA	V1MF_EXSNS47(7)		/'DR NO WRITE CLOCK*'/



	DATA	V1MF_EXSNS48(0)		/'TRANSLATOR ROM PARITY ERROR*'/

	DATA	V1MF_EXSNS48(1)		/'PE WRITE PARITY ERROR*'/

	DATA	V1MF_EXSNS48(2)		/'MASSBUS B LOGIC NOT PRESENT*'/

	DATA	V1MF_EXSNS48(3)		/'MASSBUS A LOGIC NOT PRESENT*'/

	DATA	V1MF_EXSNS48(4)		/'WRITE DATA REGISTER PARITY BIT*'/

	DATA	V1MF_EXSNS48(5)		/'POWER OK*'/

	DATA	V1MF_EXSNS48(6)		/'MICRO-COMPUTER ROM PARITY ERROR*'/

	DATA	V1MF_EXSNS48(7)		/'MASSBUS PORT SELECT*'/



	DATA	V1MF_EXSNS49(0)		/'FILE PROTECT*'/

	DATA	V1MF_EXSNS49(1)		/'EOT*'/

	DATA	V1MF_EXSNS49(2)		/'BOT*'/

	DATA	V1MF_EXSNS49(3)		/'PES*'/

	DATA	V1MF_EXSNS49(4)		/'REWINDING*'/

	DATA	V1MF_EXSNS49(5)		/'ONLINE*'/

	DATA	V1MF_EXSNS49(6)		/'READY ON*'/

	DATA	V1MF_EXSNS49(7)		/'READY*'/



	DATA	V1MF_EXSNS50(0)		/'DSE*'/

	DATA	V1MF_EXSNS50(1)		/'MOT*'/

	DATA	V1MF_EXSNS50(2)		/'LWR*'/

	DATA	V1MF_EXSNS50(3)		/'WRITE INHIBIT*'/

	DATA	V1MF_EXSNS50(4)		/'WRITE*'/

	DATA	V1MF_EXSNS50(5)		/'REVERSE*'/

	DATA	V1MF_EXSNS50(6)		/'FORWARD*'/

	DATA	V1MF_EXSNS50(7)		/'MANUAL TEST*'/



	DATA	V1MF_EXSNS51(5)		/'ARA ERROR*'/

	DATA	V1MF_EXSNS51(6)		/'PEC*'/

	DATA	V1MF_EXSNS51(7)		/'CMD/STA PARITY ERROR*'/



	DATA	V1MF_EXSNS54(2)		/'HIGH READ THRESHOLD*'/

	DATA	V1MF_EXSNS54(3)		/'TACH*'/

	DATA	V1MF_EXSNS54(4)		/'EOT DETECTED*'/

	DATA	V1MF_EXSNS54(5)		/'READ ENABLE*'/

	DATA	V1MF_EXSNS54(6)		/'NOT WRITE*'/

	DATA	V1MF_EXSNS54(7)		/'NOT WRITE BIT 4*'/



	DATA	V1MF_EXSNS56(5)		/'INITIAL DIRECTION REVERSE*'/

	DATA	V1MF_EXSNS56(6)		/'INITIAL COMMAND READ*'/

	DATA	V1MF_EXSNS56(7)		/'LAST RETRY OPPOSITE*'/



	DATA	V1MF_EXSNS57(0)		/'DSE IN PROGRESS*'/

	DATA	V1MF_EXSNS57(1)		/'REWIND IN PROGRESS*'/

	DATA	V1MF_EXSNS57(2)		/'TAPE PRESENT, POWER ON*'/

	DATA	V1MF_EXSNS57(3)		/'NDT FROM mASSBUS IN PROGRESS*'/

	DATA	V1MF_EXSNS57(4)		/'LAST DIRECTION REVERSE*'/

	DATA	V1MF_EXSNS57(5)		/'LAST OPERATION INCLUDED WRITE*'/

	DATA	V1MF_EXSNS57(6)		/'LAST RECORD TAPE MARK*'/

	DATA	V1MF_EXSNS57(7)		/'LAST MASSBUS COMMAND PORT B*'/



	DATA	V1TU_SELX(2,0)		/'1 WRITE*'/

	DATA	V1TU_SELX(3,0)		/'0 WRITE*'/

	DATA	V1TU_SELX(4,0)		/'1 READ*'/

	DATA	V1TU_SELX(5,0)		/'0 READ*'/



	DATA	V1TU_SELX(2,1)		/'3 WRITE*'/

	DATA	V1TU_SELX(3,1)		/'2 WRITE*'/

	DATA	V1TU_SELX(4,1)		/'3 READ*'/

	DATA	V1TU_SELX(5,1)		/'2 READ*'/



	data	reg_herald(0)		/'CS1*'/

	data	reg_herald(1)		/'IS*'/

	data	reg_herald(2)		/'TC*'/

	data	reg_herald(3)		/'MR1*'/

	data	reg_herald(4)		/'AB*'/

	data	reg_herald(5)		/'BC*'/

	data	reg_herald(6)		/'DT*'/

	data	reg_herald(7)		/'DS*'/

	data	reg_herald(8)		/'SN*'/

	data	reg_herald(9)		/'MR2*'/

	data	reg_herald(10)		/'MR3*'/

	data	reg_herald(11)		/'NDTA*'/

	data	reg_herald(12)		/'NDT 0*'/

	data	reg_herald(13)		/'NDT 1*'/

	data	reg_herald(14)		/'NDT 2*'/

	data	reg_herald(15)		/'NDT 3*'/

	data	reg_herald(16)		/'ID*'/




	call frctof (lun)

	call dhead1 (lun,'MASSBUS')

	diagnostic_mode = .false.

	if (lib$extzv(5,1,mf_ds) .eq. 1) diagnostic_mode = .true.

	dt_cmdaddr = lib$extzv (0,2,mf_tc)

	dt_function = lib$extzv (1,5,mf_cs1)

	ucb_function  = lib$extzv (1,5,ucb$l_mf_cmd)

	ucb_unit_number = lib$extzv (0,8,emb$w_dv_unit)

	attn_bit_this_ucb = lib$extzv (ucb_unit_number,1,mf_ab)

	if (emb$w_hd_entry .ne. 98) then

	if (dt_cmdaddr .eq. ucb_unit_number
	1 .and.
	2 dt_function .eq. ucb_function
	3 .and.
	4 attn_bit_this_ucb .eq. 0) then

	ndt_function = 0

	call mba_control_registers (lun,5,adapter_registers,
	1 selected_map_register)

	call mba_mapping_register (lun,selected_map_register,
	1 adapter_registers(6))

	if (selected_map_register .gt. 0) then

	call mba_mapping_register (lun,(selected_map_register - 1),
	1 adapter_registers(7))
	endif
	endif
	endif

	call linchk (lun,2)

	write(lun,8) mf_cs1
8	format('0',t8,'MF CS1',t24,z8.8)

	if (.not. diagnostic_mode) then

	if (
	1 dt_cmdaddr .eq. ucb_unit_number
	1 .and.
	1 dt_function .eq. ucb_function
	1 .and.
	1 attn_bit_this_ucb .eq. 0
	1 .and.
	1 emb$w_hd_entry .ne. 98
	1 ) then

	call mba_status_register16_31 (lun,mf_cs1,mf_cs1,0)

	call output (lun,mf_cs1,v1mf_cs1,0,0,0,'0')

	call linchk (lun,1)

	if (dt_function .eq. 20) then

	write(lun,10) v1dt_function(dt_function)
10	format(' ',t40,a<compressc (v1dt_function(dt_function))>)

	else if (
	1 dt_function .ge. 23
	1 .and.
	1 dt_function .le. 25
	1 ) then

	write(lun,11) v2dt_function(dt_function)
11	format(' ',t40,a<compressc (v2dt_function(dt_function))>)

	else if (
	1 (dt_function .eq. 28
	1 .or.
	1 dt_function .eq. 29)
	1 ) then

	write(lun,12) v3dt_function(dt_function)
12	format(' ',t40,a<compressc (v3dt_function(dt_function))>)

	else if (dt_function .eq. 31) then

	write(lun,15) v4dt_function(dt_function)
15	format(' ',t40,a<compressc (v4dt_function(dt_function))>)
	endif

	call output (lun,mf_cs1,v2mf_cs1,11,11,11,'0')
	endif
	endif

	call linchk (lun,1)

	write(lun,25) mf_is
25	format(' ',t8,'MF IS',t24,z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mf_cs1,mf_is,1)

	if (dt_cmdaddr .eq. ucb_unit_number
	1 .and.
	2 dt_function .eq. ucb_function
	3 .and.
	4 attn_bit_this_ucb .eq. 0) then

	dt_intcode = lib$extzv(0,6,mf_is)

	call linchk (lun,1)

	if (dt_intcode .ge. 1
	1 .and.
	2 dt_intcode .le. 4) then

	write(lun,30) v1interrupt_code(dt_intcode)
30	format(' ',t40,a<compressc (v1interrupt_code(dt_intcode))>)

	else if (dt_intcode .ge. 8
	1 .and.
	2 dt_intcode .le. 13) then

	write(lun,31) v1interrupt_code(dt_intcode)
31	format(' ',t40,a<compressc (v1interrupt_code(dt_intcode))>)

	else if (dt_intcode .ge. 16
	1 .and.
	2 dt_intcode .le. 25) then

	write(lun,32) v2interrupt_code(dt_intcode)
32	format(' ',t40,a<compressc (v2interrupt_code(dt_intcode))>)

	else if (lib$extzv(14,1,mf_id) .ne. 0) then

	write(lun,33) v2interrupt_code(dt_intcode)
33	format(' ',t40,a<compressc (v2interrupt_code(dt_intcode))>)
	endif

	call output (lun,mf_is,v1mf_is,8,8,8,'0')

	dt_fcode = lib$extzv (10,6,mf_is)

	call linchk (lun,1)

	if ((dt_intcode .eq. 1
	1 .or.	
	1 dt_intcode .eq. 4
	1 .or.
	1 dt_intcode .eq. 16
	1 .or.
	1 dt_intcode .eq. 17)
	1 .and.
	2 (dt_fcode .ge. 0
	3 .and.
	4 dt_fcode .le. 1)) then

	write(lun,40) fcode_intcode1(dt_fcode)
40	format(' ',t40,a<compressc (fcode_intcode1(dt_fcode))>)

	else if (dt_intcode .eq. 2
	1 .and.
	2 dt_fcode .ge. 1
	3 .and.
	4 dt_fcode .le. 3) then

	write(lun,45) fcode_intcode3(dt_fcode)
45	format(' ',t40,a<compressc (fcode_intcode3(dt_fcode))>)

	else if (dt_intcode .eq. 9
	1 .and.
	2 dt_fcode .ge. 1
	3 .and.
	4 dt_fcode .le. 3) then

	write(lun,50) fcode_intcode9(dt_fcode)
50	format(' ',t40,a<compressc (fcode_intcode9(dt_fcode))>)

	else if ((dt_intcode .eq. 18
	1 .or.
	1 dt_intcode .eq. 19
	1 .or.
	1 dt_intcode .eq. 20
	1 .or.
	1 dt_intcode .eq. 21
	1 .or.
	1 dt_intcode .eq. 22
	1 .or.
	1 dt_intcode .eq. 23)
	1 .and.
	2 dt_fcode .ge. 1
	3 .and.
	4 dt_fcode .le. 11) then

	write(lun,60) fcode_intcode18(dt_fcode)
60	format(' ',t40,a<compressc (fcode_intcode18(dt_fcode))>)

	else if (dt_intcode .eq. 24
	1 .and.
	2 (dt_fcode .ge. 1
	3 .and.
	4 dt_fcode .le. 19)) then

	write(lun,65) dt_fcode
65	format(' ',t40,'FAILURE CODE = ',o2.2,' (OCTAL)')

	else if (dt_intcode .eq. 25
	1 .and.
	2 (dt_fcode .ge. 1
	3 .and.
	4 dt_fcode .le. 15)) then

	write(lun,65) dt_fcode

	else if (dt_intcode .eq. 25
	1 .and.
	2 (dt_fcode .ge. 17
	3 .and.
	4 dt_fcode .le. 35)) then

	write(lun,65) dt_fcode

	else if (dt_intcode .eq. 28
	1 .and.
	2 dt_fcode .ge. 1
	3 .and.
	4 dt_fcode .le. 2) then

	write(lun,75) fcode_intcode28(dt_fcode)
75	format(' ',t40,a<compressc (fcode_intcode28(dt_fcode))>)
	endif
	endif
	endif

	call linchk (lun,1)

	write(lun,85) mf_tc
85	format(' ',t8,'MF TC',t24,z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mf_is,mf_tc,1)

	if (dt_cmdaddr .eq. ucb_unit_number
	1 .and.
	2 dt_function .eq. ucb_function
	3 .and.
	4 attn_bit_this_ucb .eq. 0) then

	call linchk (lun,1)

	write(lun,90) dt_cmdaddr
90	format(' ',t40,'DATA TRANSFER CMD ADDR UNIT = ',
	1 i<compress4 (dt_cmdaddr)>,'.')

	field = lib$extzv (2,6,mf_tc)

	call linchk (lun,1)

	write(lun,95) field
95	format(' ',t40,'RECORDS REMAINING = ',i<compress4 (field)>,'.')

	field = lib$extzv (8,4,mf_tc)

	call linchk (lun,1)

	write(lun,100) field
100	format(' ',t40,'SKIP COUNT = ',i<compress4 (field)>,'.')

	field = lib$extzv (12,3,mf_tc)

	if (field .ge. 0
	1 .and.
	2 field .le. 6) then

	call linchk (lun,1)

	write(lun,105) mf_tc_format(field)
105	format(' ',t40,'FORMAT = ',a<compressc (mf_tc_format(field))>)
	endif

	call output (lun,mf_tc,v1mf_tc,15,15,15,'0')
	endif
	endif

	call linchk (lun,1)

	write(lun,115) mf_mr1
115	format(' ',t8,'MF MR1',t24,z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mf_tc,mf_mr1,1)
	endif

	call linchk (lun,1)

	write(lun,120) mf_ab
120	format(' ',t8,'MF AB',t24,z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mf_mr1,mf_ab,1)

	do 128,i = 0,3

	if (lib$extzv(i,1,mf_ab) .eq. 1) then

	call linchk (lun,1)

	write(lun,125) i
125	format(' ',t40,'ATTENTION UNIT ',i1,'.')
	endif

128	continue
	endif

	call linchk (lun,1)

	write(lun,130) mf_bc
130	format(' ',t8,'MF BC',t24,z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mf_ab,mf_bc,1)

	if (dt_cmdaddr .eq. ucb_unit_number
	1 .and.
	2 dt_function .eq. ucb_function
	3 .and.
	4 attn_bit_this_ucb .eq. 0) then

	field = lib$extzv (0,16,mf_bc)

	call linchk (lun,1)

	write(lun,135) field
135	format(' ',t40,'BYTE COUNT = ',i<compress4 (field)>,'.')
	endif
	endif

	call linchk (lun,1)

	write(lun,140) mf_dt
140	format(' ',t8,'MF DT',t24,z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mf_bc,mf_dt,1)

	field = lib$extzv (0,8,mf_dt)

	if (field .eq. 65) then

	call linchk (lun,1)

	write(lun,145)
145	format(' ',t40,'DRIVE TYPE TU78')
	endif

	call output (lun,mf_dt,v1mf_dt,10,10,11,'0')

	call output (lun,mf_dt,v2mf_dt,14,14,15,'0')
	endif

	call linchk (lun,1)

	write(lun,155) mf_ds
155	format(' ',t8,'MF DS',t24,z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mf_dt,mf_ds,1)

	call output (lun,mf_ds,v1mf_ds,4,4,4,'0')

	call output (lun,mf_ds,v2mf_ds,6,6,15,'0')
	else

	call linchk (lun,1)

	write(lun,157) 'DAIGNOSTIC MODE'
157	format(' ',t40,a)
	endif

	call linchk (lun,1)

	write(lun,160) mf_sn
160	format(' ',t8,'MF SN',t24,z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mf_ds,mf_sn,1)
	endif

	call linchk (lun,1)

	write(lun,165) mf_mr2
165	format(' ',t8,'MF MR2',t24,z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mf_sn,mf_mr2,1)
	endif

	call linchk (lun,1)

	write(lun,170) mf_mr3
170	format(' ',t8,'MF MR3',t24,z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mf_mr2,mf_mr3,1)
	endif

	ndt_cmdaddr = lib$extzv (8,3,mf_ndta)

	call linchk (lun,1)

	write(lun,175) mf_ndta
175	format(' ',t8,'MF NDTA',t24,z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mf_mr3,mf_ndta,1)

	ndt_function = lib$extzv (1,5,mf_ndt(i))

	if ((ndt_cmdaddr .eq. ucb_unit_number
	1 .and.
	2 attn_bit_this_ucb .ne. 0
	2 .and.
	2 ndt_function .eq. ucb_function)
	3 .or.
	4 ucb$l_mf_cmd .lt. 0) then

	dt_function = 0

	ndt_intcode = lib$extzv (0,7,mf_ndta)

	call linchk (lun,1)

	if (ndt_intcode .ge. 1
	1 .and.
	2 ndt_intcode .le. 13) then

	write(lun,180) v1interrupt_code(ndt_intcode)
180	format(' ',t40,a<compressc (v1interrupt_code(ndt_intcode))>)

	else if (ndt_intcode .ge. 23
	1 .and.
	2 ndt_intcode .le. 25) then

	write(lun,181) v2interrupt_code(ndt_intcode)
181	format(' ',t40,a<compressc (v2interrupt_code(ndt_intcode))>)
	endif

	ndt_fcode = lib$extzv (8,3,mf_ndta)

	call linchk (lun,1)

	write(lun,190) ndt_fcode
190	format(' ',t40,'ATTENTION CMD ADDR UNIT = ',i1,'.')

	ndt_fcode = lib$extzv (10,6,mf_ndta)

	call linchk (lun,1)

	if ((ndt_intcode .eq. 1
	1 .or.
	1 ndt_intcode .eq. 4
	1 .or.
	1 ndt_intcode .eq. 16
	1 .or.
	1 ndt_intcode .eq. 17)
	1 .and.
	2 (ndt_fcode .ge. 0
	3 .and.
	4 ndt_fcode .le. 1)) then

	write(lun,195) fcode_intcode1(ndt_fcode)
195	format(' ',t40,a<compressc (fcode_intcode1(ndt_fcode))>)

	else if (ndt_intcode .eq. 3
	1 .and.
	2 ndt_fcode .ge. 1
	3 .and.
	4 ndt_fcode .le. 3) then

	write(lun,200) fcode_intcode3(ndt_fcode)
200	format(' ',t40,a<compressc (fcode_intcode3(ndt_fcode))>)

	else if (ndt_intcode .eq. 9
	1 .and.
	2 ndt_fcode .ge. 1
	3 .and.
	4 ndt_fcode .le. 3) then

	write(lun,205) fcode_intcode9(ndt_fcode)
205	format(' ',t40,a<compressc (fcode_intcode9(ndt_fcode))>)

	else if (ndt_intcode .eq. 13
	1 .and.
	2 ndt_fcode .ge. 1
	3 .and.
	4 ndt_fcode .le. 4) then

	write(lun,210) fcode_intcode13(ndt_fcode)
210	format(' ',t40,a<compressc (fcode_intcode13(ndt_fcode))>)

	else if ((ndt_intcode .eq. 19
	1 .or.
	1 ndt_intcode .eq. 20
	1 .or.
	1 ndt_intcode .eq. 21
	1 .or.
	1 ndt_intcode .eq. 22
	1 .or.
	1 ndt_intcode .eq. 23)
	1 .and.
	2 ndt_fcode .ge. 1
	3 .and.
	4 ndt_fcode .le. 11) then

	write(lun,215) fcode_intcode18(ndt_fcode)
215	format(' ',t40,a<compressc (fcode_intcode18(ndt_fcode))>)

	else if (ndt_intcode .eq. 24
	1 .and.
	2 (ndt_fcode .ge. 1
	3 .and.
	4 ndt_fcode .le. 19)) then

	write(lun,65) ndt_fcode

	else if (ndt_intcode .eq. 25
	1 .and.
	2 (ndt_fcode .ge. 1
	3 .and.
	4 ndt_fcode .ge. 15)) then

	write(lun,65) ndt_fcode

	else if (ndt_intcode .eq. 25
	1 .and.
	2 (ndt_fcode .ge. 17
	3 .and.
	4 ndt_fcode .le. 35)) then

	write(lun,65) ndt_fcode

	else if (ndt_intcode .eq. 28
	1 .and.
	2 ndt_fcode .ge. 1
	3 .and.
	4 ndt_fcode .le. 2) then

	write(lun,230) fcode_intcode28(ndt_fcode)
230	format(' ',t40,a<compressc (fcode_intcode28(ndt_fcode))>)
	endif
	endif
	endif

	do 250,i = 0,3

	call linchk (lun,1)

	write(lun,235) i,mf_ndt(i)
235	format(' ',t8,'MF NDT',i1,t24,z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mf_ndt(max(0,i-1)),mf_ndt(i),1)

	if (i .eq. ucb_unit_number
	1 .and.
	2 attn_bit_this_ucb .ne. 0
	3 .and.
	4 ndt_function .eq. ucb_function) then

	call linchk (lun,1)

	if (ndt_function .ge. 1
	1 .and.
	2 ndt_function .le. 19) then

	write(lun,240) v1ndt_function(ndt_function)
240	format(' ',t40,a<compressc (v1ndt_function(ndt_function))>)
	endif

	field = lib$extzv (8,8,mf_ndt(i))

	call linchk (lun,1)

	write(lun,245) field
245	format(' ',t40,'COMMAND COUNT = ',i<compress4 (field)>,'.')
	endif
	endif

250	continue

	call linchk (lun,1)

	write(lun,260) mf_id
260	format(' ',t8,'MF ID',t24,z8.8)

	if (.not. diagnostic_mode) then

	call mba_status_register16_31 (lun,mf_ndt(3),mf_id,1)

	call output (lun,mf_id,v1mf_id,8,8,15,'0')

	if (emb$w_hd_entry .ne. 96
	1 .and.
	1 ((dt_cmdaddr .eq. ucb_unit_number
	1 .and.
	2 attn_bit_this_ucb .eq. 0
	2 .and.
	2 dt_function .eq. ucb_function
	3 .and.
	3 dt_intcode .ne. 17
	3 .and.
	4 dt_fcode .ne. 0)
	5 .or.
	6 (ndt_cmdaddr .eq. ucb_unit_number
	7 .and.
	8 attn_bit_this_ucb .ne. 0
	8 .and.
	8 ndt_function .eq. ucb_function
	9 .and.
	1 ndt_intcode .ne. 5
	1 .and.
	1 ndt_intcode .ne. 6
	1 .and.
	1 ndt_intcode .ne. 7
	1 .and.
	1 ndt_fcode .ne. 0))
	1 .or.
	1 ucb_l_mf_cmd .lt. 0) then

	call linchk (lun,3)

	write(lun,265)
265	format('0','EXTENDED SENSE INFORMATION',/)

	call linchk (lun,8)

	write(lun,270) (mf_exsns(i),i = 1,5)
270	format(' ',t8,'BYTE 1',t30,z2.2,/,t40,'COMMAND CODE',/,
	1 t8,'BYTE 2',t30,z2.2,/,t40,'INTERRUPT CODE',/,
	2 t8,'BYTE 3',t30,z2.2,/,t40,'FAILURE CODE',/,
	3 t8,'RPFAIL',t30,z2.2,/,
	4 t8,'RPATH',t30,z2.2)

	call output (lun,mf_exsns(5),v1mf_exsns5,0,0,7,'0')

	call linchk (lun,2)

	write(lun,295) (mf_exsns(6),i = 1,2)
295	format(' ',t8,'RSTAT',t30,z2.2,/,t40,
	1 'RMC STATUS = ',o3.3,' (OCTAL)')

	call linchk (lun,7)

	write(lun,300) (mf_exsns(i),i = 7,13)
300	format(' ',t8,'RCMLP',t30,z2.2,/,
	1 t8,'RAMT',t30,z2.2,/,
	2 t8,'RDON',t30,z2.2,/,
	3 t8,'RILL',t30,z2.2,/,
	4 t8,'RMK2',t30,z2.2,/,
	5 t8,'EMK',t30,z2.2,/,
	6 t8,'RPSTA',t30,z2.2)

	call output (lun,mf_exsns(13),v1mf_exsns13,0,0,7,'0')

	call linchk (lun,5)

	write(lun,335) (mf_exsns(i),i = 14,18)
335	format(' ',t8,'RPOSTN',t30,z2.2,/,
	1 t8,'RDATA',t30,z2.2,/,
	2 t8,'CRCWRD',t30,z2.2,/,
	3 t8,'ECCOR',t30,z2.2,/,
	4 t8,'ECCSTA',t30,z2.2)

	call output (lun,mf_exsns(18),v1mf_exsns18,0,0,7,'0')

	do 365,i = 0,7

	call linchk (lun,1)

	write(lun,360) i,mf_exsns(19 + i)
360	format(' ',t8,'CH',i1,'TIE',t30,z2.2)

365	continue

	call linchk (lun,4)

	write(lun,370) (mf_exsns(i),i = 27,30)
370	format(' ',t8,'CHPTIE',t30,z2.2,/,
	1 t8,'RTIER',t30,z2.2,/,
	2 t8,'TAMT',t30,z2.2,/,
	3 t8,'PSTAT',t30,z2.2)

	call output (lun,mf_exsns(30),v1mf_exsns30,0,0,7,'0')

	call linchk (lun,2)

	write(lun,390) (mf_exsns(i),i = 31,32)
390	format(' ',t8,'PRDD',t30,z2.2,/,
	1 t8,'CASSTA',t30,z2.2)

	field = lib$extzv(0,3,mf_exsns(32))

	call linchk (lun,1)

	write(lun,400) field
400	format(' ',t40,'DRIVE SELECT = ',i<compress4 (field)>,'.')

	call output (lun,mf_exsns(32),v1mf_exsns32,3,3,7,'0')

	call linchk (lun,1)

	write(lun,410) mf_exsns(33)
410	format(' ',t8,'CBUSSTA',t30,z2.2)

	call output (lun,mf_exsns(33),v1mf_exsns33,0,0,7,'0')

	call linchk (lun,1)

	write(lun,415) mf_exsns(34)
415	format(' ',t8,'DBUSSTA',t30,z2.2)

	call output (lun,mf_exsns(34),v1mf_exsns34,0,0,7,'0')

	call linchk (lun,1)

	write(lun,420) mf_exsns(35)
420	format(' ',t8,'WMCSTA',t30,z2.2)

	field = lib$extzv (7,1,mf_exsns(36))

	do 430,i = 0,field

	call linchk (lun,2)

	write(lun,422) i,mf_exsns(36 + i)
422	format(' ',t8,'TUSEL ',i1,t30,z2.2)

	field = lib$extzv (0,2,mf_exsns(36 + i))

	write(lun,424) field
424	format(' ',t40,'TAPE UNIT SELECT = ',i<compress4 (field)>,'.')

	do 430,k = 2,5

	field = lib$extzv (k,1,mf_exsns(36 + i))

	if (field .ne. 0) then

	call linchk (lun,1)

	write(lun,426) v1tu_selx(k,i)
426	format(' ',t40,'TU PORT ',a<compressc (v1tu_selx(k,i))>,
	1 ' PATH ENABLED')
	endif

430	continue

	call linchk (lun,1)

	write(lun,435) mf_exsns(38)
435	format(' ',t8,'WRTDAT',t30,z2.2)

	call linchk (lun,3)

	write(lun,450) ((mf_exsns(39 + i + j),i = 1,0,-1),j = 0,4,2)
450	format(' ',t8,'BYTCNT',t28,2z2.2,/,
	1 t8,'PADCNT',t28,2z2.2,/,
	2 t8,'ERRCNT',t28,2z2.2)

	call linchk (lun,3)

	write(lun,455) (mf_exsns(45 + i),i = 0,2)
455	format(' ',t8,'DDR A',t30,z2.2,/,t8,'DDR B',t30,z2.2,/,
	1 t8,'DDR C',t30,z2.2)

	call output (lun,mf_exsns(47),v1mf_exsns47,3,3,7,'0')

	call linchk (lun,1)

	write(lun,465) mf_exsns(48)
465	format(' ',t8,'INSTA',t30,z2.2)

	call output (lun,mf_exsns(48),v1mf_exsns48,0,0,0,'0')

	if (dt_function .eq. 24) then

	call output (lun,mf_exsns(48),v1mf_exsns48,0,1,1,'0')
	endif

	call output (lun,mf_exsns(48),v1mf_exsns48,0,2,7,'0')

	call linchk (lun,1)

	write(lun,470) mf_exsns(49)
470	format(' ',t8,'MTA 0',t30,z2.2)

	call output (lun,mf_exsns(49),v1mf_exsns49,0,0,7,'0')

	call linchk (lun,1)

	write(lun,475) mf_exsns(50)
475	format(' ',t8,'MTA 1',t30,z2.2)

	call output (lun,mf_exsns(50),v1mf_exsns50,0,0,7,'0')

	call linchk (lun,1)

	write(lun,480) mf_exsns(51)
480	format(' ',t8,'MTA 2',t30,z2.2)

	field = lib$extzv (0,3,mf_exsns(51))

	call linchk (lun,1)

	if (field .eq. 6) then

	write(lun,485) 'A'
485	format(' ',t40,'PORT SELECT = MASSBUS ',a)

	else if (field .eq. 5) then

	write(lun,485) 'B'

	else if (field .eq. 3) then

	write(lun,485) 'A/B'
	else

	write(lun,490)
490	format(' ',t40,'NEITHER MASSBUS SELECTED')
	endif

	call linchk (lun,1)

	if (lib$extzv(3,2,mf_exsns(51)) .eq. 2) then

	write(lun,495)
495	format(' ',t40,'125 IPS TRANSPORT')
	else

	write(lun,500)
500	format(' ',t40,'NOT TU78 SPEED')
	endif

	call output (lun,mf_exsns(51),v1mf_exsns51,5,5,7,'0')

	do 515,i = 3,4

	call linchk (lun,1)

	write(lun,510) i,mf_exsns(49 + i)
510	format(' ',t8,'MTA ',i1,t30,z2.2)

515	continue

	call linchk (lun,1)

	write(lun,520) (mf_exsns(i),i = 52,53)
520	format(' ',t40,'SERIAL NUMBER = ',z2.2,z2.2)

	call linchk (lun,1)

	write(lun,525) mf_exsns(54)
525	format(' ',t8,'MTA 5',t30,z2.2)

	call linchk (lun,1)

	write(lun,530) lib$extzv(0,2,mf_exsns(54))
530	format(' ',t40,'THRESHOLD = ',i1,'.')

	call output (lun,mf_exsns(54),v1mf_exsns54,2,2,7,'0')

	field = lib$extzv (0,8,mf_exsns(55))

	call linchk (lun,2)

	write(lun,535) mf_exsns(55),field
535	format(' ',t8,'RETCNT',t30,z2.2,/,t40,
	1 'RETRY COUNT = ',i<compress4 (field)>,'.')

	call linchk (lun,1)

	write(lun,540) mf_exsns(56)
540	format(' ',t8,'RETCNT+1',t30,z2.2)

	if (field .ne. 0) then

	call output (lun,mf_exsns(56),v1mf_exsns56,5,5,7,'0')
	endif

	call linchk (lun,1)

	write(lun,545) mf_exsns(57)
545	format(' ',t8,'TUX',t30,z2.2)

	call output (lun,mf_exsns(57),v1mf_exsns57,0,0,7,'0')

	call linchk (lun,1)

	write(lun,550) mf_exsns(58)
550	format(' ',t8,'XFRCTL',t30,z2.2)

	call linchk (lun,1)

	write(lun,570) mf_exsns(59)
570	format(' ',t8,'XRETRY',t30,z2.2)

	call linchk (lun,1)

	write(lun,575) mf_exsns(60)
575	format(' ',t8,'ENAON',t30,z2.2)

	if (mf_exsns(60) .ne. 0) then

	call linchk (lun,1)

	write(lun,580)
580	format(' ',t40,'KEYPAD ENABLED')
	endif
	endif
	endif

	if (ucb$l_mf_cmd .ge. 0) then

	if (emb$w_hd_entry .ne. 98) then

	call linchk (lun,1)

	write(lun,585)
585	format(' ',:)

	if (emb$w_hd_entry .ne. 98) then

	call ucb$b_ertcnt (lun,emb$b_dv_ertcnt)

	call ucb$b_ertmax (lun,emb$b_dv_ertmax)
	endif

	call ucb$l_ownuic (lun,emb$l_dv_ownuic)

	call ucb$l_char (lun,emb$l_dv_char)

	call ucb$w_sts (lun,emb$w_dv_sts)

	call ucb$l_opcnt (lun,emb$l_dv_opcnt)

	call ucb$w_errcnt (lun,emb$w_dv_errcnt)

	if (emb$w_hd_entry .ne. 98) then

	call linchk (lun,1)

	write(lun,585)

	call mftape_qio (lun,emb$w_dv_func)

	call irp$w_bcnt (lun,emb$w_dv_bcnt)

	call irp$w_boff (lun,emb$w_dv_boff)

	call irp$l_pid (lun,emb$l_dv_rqpid)

	call irp$q_iosb (lun,emb$l_dv_iosb1)
	endif
	endif
	endif

	return



	entry b_mftape (lun)



	call dhead1 (lun,'MASSBUS')

	call brief16 (lun,(17),mf_cs1,reg_herald,emb$t_dv_name,emb$w_dv_unit)

	return



	entry c_mftape (lun)



	call cryptk (lun,16,(17),mf_cs1,reg_herald,emb$t_dv_name,emb$w_dv_unit)

	return

	end



	subroutine mftape_qio (lun,emb$w_dv_func)



	include 'src$:qiocommon.for /nolist'



	byte		lun

	integer*2	emb$w_dv_func

	integer*4	qiocode(0:1,0:63)




	if (qiocode(0,0) .eq. 0) then

	qiocode(1,00) = %loc(io$_nop)

	qiocode(1,01) = %loc(io$_unload)

	qiocode(1,02) = %loc(io$_spacefile)

	qiocode(1,03) = %loc(io$_recal)

	qiocode(1,04) = %loc(io$_drvclr)

	qiocode(1,06) = %loc(io$_erasetape)

	qiocode(1,08) = %loc(io$_packack)

	qiocode(1,09) = %loc(io$_spacerecord)

	qiocode(1,10) = %loc(io$_writecheck)

	qiocode(1,11) = %loc(io$_writepblk)

	qiocode(1,12) = %loc(io$_readpblk)

	qiocode(1,25) = %loc(io$_readpreset)

	qiocode(1,26) = %loc(io$_setchar)

	qiocode(1,27) = %loc(io$_sensechar)

	qiocode(1,28) = %loc(io$_writemark)

	qiocode(1,30) = %loc(io$_clean)

	qiocode(1,32) = %loc(io$_writelblk)

	qiocode(1,33) = %loc(io$_readlblk)

	qiocode(1,34) = %loc(io$_rewindoff)

	qiocode(1,35) = %loc(io$_setmode)

	qiocode(1,36) = %loc(io$_rewind)

	qiocode(1,37) = %loc(io$_skipfile)

	qiocode(1,38) = %loc(io$_skiprecord)

	qiocode(1,39) = %loc(io$_sensemode)

	qiocode(1,40) = %loc(io$_writeof)

	qiocode(1,48) = %loc(io$_writevblk)

	qiocode(1,49) = %loc(io$_readvblk)

	qiocode(1,50) = %loc(io$_access)

	qiocode(1,51) = %loc(io$_create)

	qiocode(1,52) = %loc(io$_deaccess)

	qiocode(1,53) = %loc(io$_delete)

	qiocode(1,54) = %loc(io$_modify)

	qiocode(1,56) = %loc(io$_acpcontrol)

	qiocode(1,57) = %loc(io$_mount)

	do 10,i = 0,63

	qiocode(0,i) = 33

	if (qiocode(1,i) .eq. 0) then

	qiocode(1,i) = %loc(qio_string)
	endif

10	continue
	endif

	call irp$w_func (lun,emb$w_dv_func,
	1 qiocode(0,lib$extzv(0,6,emb$w_dv_func)))

	return

	end
