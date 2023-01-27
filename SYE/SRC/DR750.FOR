	Subroutine DR750 (lun)
C
C	V02-001
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
C
C	Author:	Sharon Reynolds			Creation date:	21-July-1981
C
C	Functional Description:
C
C	This module decodes and outputs the error information for the
C	DR750.
C
C	Modified by:
C
C	v02-001	BP0001			Brian Porter,		23-NOV-1981
C		Minor edit.
C**
c--

	Include 'SRC$:DR32COM.FOR /NOLIST'
	Include 'SRC$:DEVERR.FOR /NOLIST'
	Include	'SRC$:MSGHDR.FOR /NOLIST'

	Byte		lun

	Integer*4	dr_dcr
	Integer*4	dr_utl
	Integer*4	dr_wcs_adr
	Integer*4	dr_wcs_dat
	Integer*4	dr_cmi_adr
	Integer*4	dr_cmi_bcr
	Integer*4	dr_di_bcr
	Integer*4	dr_dsl
	Integer*4	dr_sbr
	Integer*4	dr_gbr
	Integer*4	dr_cb(1:3)
	Integer*4	dr_bb(1:3)
	Integer*4	dr_gpr(0:22)

	Integer*4	compressf
	Integer*4	compressc
	Integer*4	field
	Integer*4	reg_copy(0:5)

	Real		float

	Parameter	dr_750 = 48

	Character*24	dr_dcr1(11:12)
	Character*17	dr_dcr2(14:20)
	Character*32	dr_dcr3(22:31)
	Character*24	bus_func(0:7)
	Character*8	reg_herald(0:5)

C
C	Make the necessary information in the error log buffer available
C	to this module.
C
	Equivalence	(dr_dcr,EMB$L_DV_REGSAV(0))
	Equivalence	(dr_utl,EMB$L_DV_REGSAV(1))
	Equivalence	(dr_wcs_adr,EMB$L_DV_REGSAV(2))
	Equivalence	(dr_wcs_dat,EMB$L_DV_REGSAV(3))
	Equivalence	(dr_cmi_adr,EMB$L_DV_REGSAV(5))
	Equivalence	(dr_cmi_bcr,EMB$L_DV_REGSAV(6))
	Equivalence	(dr_di_bcr,EMB$L_DV_REGSAV(7))
	Equivalence	(dr_dsl,EMB$L_DV_REGSAV(8))
	Equivalence	(dr_sbr,EMB$L_DV_REGSAV(9))
	Equivalence	(dr_gbr,EMB$L_DV_REGSAV(10))
	Equivalence	(dr_cb,EMB$L_DV_REGSAV(11))
	Equivalence	(dr_bb,EMB$L_DV_REGSAV(14))
	Equivalence	(dr_gpr,EMB$L_DV_REGSAV(17))


	Data	dr_dcr1(11)	/'DATA INTERCONNECT STALL*'/
	Data	dr_dcr1(12)	/'JAM*'/


	Data	dr_dcr2(14)	/'NO CMI RESPONSE*'/
	Data	dr_dcr2(15)	/'RDS ERROR*'/
	Data	dr_dcr2(16)	/'CRD ERROR*'/
	Data	dr_dcr2(17)	/'HALT*'/
	Data	dr_dcr2(18)	/'DCR ABORT*'/
	Data	dr_dcr2(19)	/'PACKET INTERRUPT*'/
	Data	dr_dcr2(20)	/'INTERRUPT ENABLE*'/

	Data	dr_dcr3(22)	/'POWER UP*'/
	Data	dr_dcr3(23)	/'POWER DOWN*'/
	Data	dr_dcr3(24)	/'EXTERNAL ABORT*'/
	Data	dr_dcr3(25)	/'FORCE CI PARITY ERROR*'/
	Data	dr_dcr3(26)	/'FORCE DI PARITY ERROR*'/
	Data	dr_dcr3(27)	/'ENABLE DI PARITY ERROR ABORT*'/
	Data	dr_dcr3(28)	/'LOCAL PARITY ERROR*'/
	Data	dr_dcr3(29)	/'CI PARITY ERROR*'/
	Data	dr_dcr3(30)	/'DI PARITY ERROR*'/
	Data	dr_dcr3(31)	/'PARITY ERROR*'/

	Data	bus_func(0)	/'READ*'/
	Data	bus_func(1)	/'READ LOCK*'/
	Data	bus_func(2)	/'ILLEGAL FUNCTION*'/
	Data	bus_func(3)	/'ILLEGAL FUNCTION*'/
	Data	bus_func(4)	/'WRITE*'/
	Data	bus_func(5)	/'WRITE UNLOCK*'/
	Data	bus_func(6)	/'WRITE VECTOR*'/
	Data	bus_func(7)	/'ILLEGAL FUNCTION*'/

	Data	reg_herald(0)	/'DCR*'/
	Data	reg_herald(1)	/'UTL*'/
	Data	reg_herald(2)	/'BA*'/
	Data	reg_herald(3)	/'WCS ADR*'/
	Data	reg_herald(4)	/'WCS DAT*'/
	Data	reg_herald(5)	/'DSL*'/


C
C	Force a top of form to occur and construct the report header.
C
	Call FRCTOF (lun)

	Call DHEAD1 (lun,'DR32')

C
C	Decode and output the DR750 Control Register.
C
	Call LINCHK (lun,2)
	Write (lun,20) dr_dcr
20	Format ('0',T8,'DR DCR',T24,Z8.8)

	Field = LIB$EXTZV (0,8,dr_dcr)

	Call LINCHK (lun,1)
	If (field .ne. dr_750) then

	Write (lun,25)
25	Format (' ',T40,'ADAPTER NOT DR750')
	Else

	Write (lun,30)
30	Format (' ',T40,'ADAPTER IS DR750')
	Endif

	Call OUTPUT (lun,dr_dcr,dr_dcr1,11,11,12,'0')

	Call OUTPUT (lun,dr_dcr,dr_dcr2,14,14,20,'0')

	Call OUTPUT (lun,dr_dcr,dr_dcr3,22,22,31,'0')

C
C	Decode and output the DR750 Utility Register.
C
	Call LINCHK (lun,1)
	Write (lun,40) dr_utl
40	Format (' ',T8,'DR UTL',T24,Z8.8)

	Field = LIB$EXTZV (0,8,dr_utl)

c
c	See DR780 listing for explanation of speed calculation.
c

	If (field .le. 'FB'X) then

	Field = JIDIM (256,field)

	Float = FLOATJ(field)

	float = 40/float

	float = (1024*1024) / ((float*1024*1024)/4)

	Call LINCHK (lun,2)
	Write (lun,45) float
45	Format (' ',T40,'PERIOD = ',
	1 F<COMPRESSF (float,1)>.1,'. MICRO/SEC')

	Float = FLOATJ(field)

	float = (40/float)*1024

	Write (lun,50) float
50	Format (' ',T40,'TRANSFER = ',
	1 F<COMPRESSF (float,2)>.2,'. KB/SEC')
		
	Endif

	Field = LIB$EXTZV (11,1,dr_utl)

	Call LINCHK (lun,1)
	If (field .eq. 1) then

	Write (lun,60)
60	Format (' ',T40,'MICRO-CODE LOADED AND VALID')	
	Endif

	Field = LIB$EXTZV (8,3,dr_utl)
	Field1 = LIB$EXTZV (12,4,dr_utl)

	Call LIB$INSV (field,0,3,silo_byte_cnt)
	Call LIB$INSV (field1,3,4,silo_byte_cnt)

	Call LINCHK (lun,2)
	Write (lun,70) silo_byte_cnt
70	Format (' ',T40,'SILO BYTE COUNT = ',
	1 Z2)


C
C	Output the DR750 WCS Registers.
C
	Call LINCHK (lun,2)
	Write (lun,80) dr_wcs_adr
80	Format (' ',T8,'DR WCS',T24,Z8.8,/,
	1 T40,'WCS ADDRESS REGISTER')

	Call LINCHK (lun,2)	
	Write (lun,85) dr_wcs_dat
85	Format (' ',T8,'DR WCS',T24,Z8.8,/,
	1 T40,'WCS DATA REGISTER')

C
C	Decode and output the DR750 CMI Address Register.
C
	Call LINCHK (lun,1)
	Write (lun,100) dr_cmi_adr
100	Format (' ',T8,'DR BA',T24,Z8.8)

C
C	This is the CMI address
C
	Field = LIB$EXTZV (0,24,dr_cmi_adr)

C
C	Clear bits 0:1 of the CMI address
C
	Call LIB$INSV (0,0,2,field)

	Call LINCHK (lun,1)
	Write (lun,105) field
105	Format (' ',T40,'LONGWORD ADDRESS (HEX) = ',
	1 Z6)	

C
C	This is the CMI bus function.
C
	Field = LIB$EXTZV (25,3,dr_cmi_adr)

	Call LINCHK (lun,1)
	Write (lun,110) bus_func(field)
110	Format (' ',T40,'CMI BUS FUNCTION = ',
	1 A<COMPRESSC (bus_func(field))> )

C
C	This is the Byte mask (the dr750 will always read 32 bits (longwords)
C	but can mask which bytes to write).
C
	Field = LIB$EXTZV (28,4,dr_cmi_adr)



C
C	Decode and output the DR750 CMI Byte Count Register and the Data
C	Interconnect Byte Count Register.
C
	Call LINCHK (lun,2)
	Write (lun,150) dr_cmi_bcr
150	Format (' ',T8,'DR BC',T24,Z8.8,/,
	1 T40,'CMI BYTE COUNT')

	Call LINCHK (lun,2)
	Write (lun,160) dr_di_bcr
160	Format (' ',T8,'DR BC',T24,Z8.8,/,
	1 T40,'DATA INTERCONNECT BYTE COUNT')

C
C	 Decode and output the DR750 Status Longword
C
	Call LINCHK (lun,1)
	Write (lun,170) dr_dsl
170	Format (' ',T8,'DR DSL',T24,Z8.8)

	Call OUTPUT (lun,dr_dsl,V1dr_sl,0,0,14,'0')

	Field = LIB$EXTZV (16,8,dr_dsl)

	If (field .ne. 0) then

	Call LINCHK (lun,3)
	Write (lun,175) ('*', I = 0,32)
175	Format (' ',T40,33A1,/,T47,'FAR-END STATUS BYTE',/)

	Do 185, I = 0,4

	Field1 =  LIB$EXTZV (I,1,field)

	If (field1 .ne. 0) then

	Call LINCHK (lun,1)
	Write (lun,180) I
180	Format (' ',T40,'FAR-END DEVICE STATUS BIT ',I1,'. SET')
	Endif

185	Continue

	Call OUTPUT (lun,dr_dsl,V2dr_sl,21,21,23,'0')

	Call LINCHK (lun,1)
	Write (lun,190) ('*', I = 0,32)
190	Format (' ',T40,33A1)
	Endif

C
C	Output the DR750 System Base Register
C
	Call LINCHK (lun,2)
	Write (lun,200) dr_sbr
200	Format (' ',T8,'DR SBR',T24,Z8.8,/,
	1 T40,'DR SYSTEM BASE REG (PHY ADDR)')

C
C	Output the DR750 Global Base Register
C
	Call LINCHK (lun,2)
	Write (lun,210) dr_gbr
210	Format (' ',T8,'DR GBR',T24,Z8.8,/,
	1 T40,'DR GLOBAL BASE REG (VIRT ADDR)')	

C
C	Output the DR750 Command Block Information
C
	Call LINCHK (lun,3)
	Write (lun,220) 
220	Format ('0','DR CURRENT COMMAND BLOCK',/)

	Do 240 I = 1,3

	Call LINCHK (lun,2)
	Write (lun,230) I,dr_cb(I),v1dr_cb(I)
230	Format (' ',T8,'DR CB',I1,T24,Z8.8,/,
	1 T40,A<COMPRESSC (v1dr_cb(I))>)

240	Continue

C
C	Output the DR750 Buffer Block Information
C
	Call LINCHK (lun,3)
	Write (lun,250)
250	Format ('0','DR CURRENT BUFFER BLOCK',/)

	Do 270 I = 1,3

	Call LINCHK (lun,2)
	Write (lun,260) I,dr_bb(I),v1dr_bb(I)
260	Format (' ',T8,'DR BB',I1,T24,Z8.8,/,
	1 T40,A<COMPRESSC (v1dr_bb(I))>)

270	Continue

C
C	Output the remaining portion of the WCS contents
C

	Call LINCHK (lun,3)
	Write (lun,280)
280	Format ('0','DR GENERAL PURPOSE REGISTERS',/)

	Call LINCHK (lun,2)
	Write (lun,290) dr_gpr(0)
290	Format (' ',T8,'DR R0',T24,Z8.8,/,
	1 T40,'VIRTUAL ADDRESS')

	Call LINCHK (lun,2)
	Write (lun,295) dr_gpr(1)
295	Format (' ',T8,'DR R1',T24,Z8.8,/,
	1 T40,'PHYSICAL ADDRESS')

	Field = LIB$EXTZV (0,16,dr_gpr(2))

	Call LINCHK (lun,2)
	Write (lun,300) field
300	Format (' ',T8,'DR R2',T24,Z4.4,/,
	1 T40,'DEVICE STATUS REGISTER')

	Field = LIB$EXTZV (16,16,dr_gpr(2))

	Call LINCHK (lun,2)
	Write (lun,305) field
305	Format (T24,Z4.4,/,T40,'AREG')

	Call LINCHK (lun,2)
	Write (lun,310) dr_gpr(3)
310	Format (' ',T8,'DR R3',T24,Z8.8,/,
	1 T40,'CONTROL INTERCONNECT STATUS')

	Call LINCHK (lun,2)
	Write (lun,315) dr_gpr(4)
315	Format (' ',T8,'DR R4',T24,Z8.8,/,
	1 T40,'BUFFER ADDRESS')

	Call LINCHK (lun,2)
	Write (lun,320) dr_gpr(5)
320	Format (' ',T8,'DR R5',T24,Z8.8,/,
	1 T40,'RETURN ADDRESS, TRUE TEST RESULT')

	Call LINCHK (lun,6)
	Do 330, I = 6,8
	
	Write (lun,325) I,dr_gpr(I)
325	Format (' ',T8,'DR R',I1,T24,Z8.8,/,
	1 T40,'GENERAL PURPOSE REGISTER')

330	Continue

	Field = LIB$EXTZV (0,16,dr_gpr(9))

	Call LINCHK (lun,2)
	Write (lun,335) field
335	Format (' ',T8,'DR R9',T24,Z4.4,/,
	1 T40,'ADDRESS OF CURRENT BUFFER')

	Field = LIB$EXTZV (16,16,dr_gpr(9))

	Call LINCHK (lun,2)
	Write (lun,340) field
340	Format (T24,Z4.4,/,T40,'CURRENT BUFFER STATE')

	Field = LIB$EXTZV (0,16,dr_gpr(10)) 

	Call LINCHK (lun,2)
	Write (lun,345) field
345	Format (' ',T8,'DR R10',T24,Z4.4,/,
	1 T40,'ADDRESS OF NEXT BUFFER')

	Field = LIB$EXTZV (16,16,dr_gpr(10))

	Call LINCHK (lun,2)
	Write (lun,350) field
350	Format (T24,Z4.4,/,T40,'NEXT BUFFER STATUS')

	Field = LIB$EXTZV (0,16,dr_gpr(11))

	Call LINCHK (lun,2)
	Write (lun,355) field
355	Format (' ',T8,'DR R11',T24,Z4.4,/,
	1 T40,'ADDRESS OF FREE BUFFER')

	Field = LIB$EXTZV(16,16,dr_gpr(11))

	Call LINCHK (lun,2)
	Write (lun,360) field
360	Format (T24,Z4.4,/,T40,'FREE BUFFER STATUS')

	Call LINCHK (lun,2)

	Write (lun,365) dr_gpr(12)
365	Format (' ',T8,'DR R12',T24,Z8.8,/,
	1 T40,'REMAINDER OF DI BYTE COUNT')

	Call LINCHK (lun,2)
	Write (lun,370) dr_gpr(13)
370	Format (' ',T8,'DR R13',T24,Z8.8,/,
	1 T40,'CONTROL INTERCONNECT BYTE COUNT')

	Call LINCHK (lun,2)
	Write (lun,375) dr_gpr(14)
375	Format (' ',T8,'DR R14',T24,Z8.8,/,
	1 T40,'CONTROL INTERCONNECT VA')

	Call LINCHK (lun,2)
	Write (lun,380) dr_gpr(15)
380	Format (' ',T8,'DR R15',T24,Z8.8,/,
	1 T40,'CONTROL INTERCONNECT PA')

	Call LINCHK (lun,2)
	Write (lun,385) dr_gpr(16)
385	Format (' ',T8,'DR R16',T24,Z8.8,/,
	1 T40,'SILO MASK')

	Call LINCHK (lun,2)
	Write (lun,390) dr_gpr(17)
390	Format (' ',T8,'DR R17',T24,Z8.8,/,
	1 T40,'CURRENTLY EXECUTING SILO COMMAND')

	Call LINCHK (lun,2)
	Write (lun,400) dr_gpr(18)
400	Format (' ',T8,'DR R18',T24,Z8.8,/,
	1 T40,'LAST VALUE LOADED, DI BYTE COUNT')

	Call LINCHK (lun,2)
	Write (lun,405) dr_gpr(19)
405	Format (' ',T8,'DR R19',T24,Z8.8,/,
	1 T40,'LAST VALUE LOADED, CMI BYTE COUNT')

	Call LINCHK (lun,2)
	Write (lun,410) dr_gpr(20)
 410	Format (' ',T8,'DR R20',T24,Z8.8,/,
	1 T40,'CONTROL INTERCONNECT DATA WORD')

	Call LINCHK (lun,2)
	Write (lun,415) dr_gpr(21)
415	Format (' ',T8,'DR R21',T24,Z8.8,/,
	1 T40,'CONTROL INTERCONNECT DATA')

	Call LINCHK (lun,2)
	Write (lun,420) dr_gpr(22)
420	Format (' ',T8,'DR R22',T24,Z8.8,/,
	1 T40,'CONTROL INTERCONNECT INFORMATION')

	call linchk (lun,1)

	write(lun,425)
425	format(' ',:)

	call ucb$l_ownuic (lun,emb$l_dv_ownuic)

	call ucb$l_char (lun,emb$l_dv_char)

	call ucb$w_sts (lun,emb$w_dv_sts)

	call ucb$l_opcnt (lun,emb$l_dv_opcnt)

	call ucb$w_errcnt (lun,emb$w_dv_errcnt)

	if (emb$w_hd_entry .ne. 98) then

	call linchk (lun,1)

	write(lun,425)

	call xfdriver_qio (lun,emb$w_dv_func)

	call irp$w_bcnt (lun,emb$w_dv_bcnt)

	call irp$w_boff (lun,emb$w_dv_boff)

	call irp$l_pid (lun,emb$l_dv_rqpid)

	call irp$q_iosb (lun,emb$l_dv_iosb1)
	endif

	Return


	Entry B_DR750 (lun)

	Call DHEAD1 (lun,'DR32')

C
C	Make all of the registers to be output for the brief report 
C	contiguous.
C
	Reg_copy(0) = dr_dcr
	Reg_copy(1) = dr_utl
	Reg_copy(2) = dr_cmi_adr
	Reg_copy(3) = dr_wcs_adr
	Reg_copy(4) = dr_wcs_dat
	Reg_copy(5) = dr_dsl

	Call BRIEF32 (lun,6,reg_copy,reg_herald,
	1 EMB$T_DV_NAME, EMB$W_DV_UNIT)

	Return


	Entry C_DR750 (lun)

C
C	Make all of the registers to be output for the cryptic report
C	contiguous.
C

	Reg_copy(0) = dr_dcr
	Reg_copy(1) = dr_utl
	Reg_copy(2) = dr_cmi_adr
	Reg_copy(3) = dr_wcs_adr
	Reg_copy(4) = dr_wcs_dat
	Reg_copy(5) = dr_dsl

	Call CRYPTK (lun,32,6,reg_copy,reg_herald,
	1 EMB$T_DV_NAME,EMB$W_DV_UNIT)

	Return

	End


