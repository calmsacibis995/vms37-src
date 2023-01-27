	SUBROUTINE UNKNOWN (LUN,HEADER)

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
C
C	AUTHOR	BRIAN PORTER		CREATION DATE	26-OCT-1979

C++
C	Functional desription:
C
C	This module displays entries that are not known to sye
C
C	Modified by:
C
C	v02-003	BP0003		Brian Porter,		02-NOV-1981
C		Added device attention support.
C
C	v02-002	BP0002		Brian Porter,		18-AUG-1981
C		Removed unused code.
C
C	v02-001	BP0001		Brian Porter,		01-MAY-1981
C		Added code to allow upper 16 bits of emb$l_dv_numreg to
C		be used as a flag word, but not cause integer o'flow in
C		this module.
C**
C--

	INCLUDE 'SRC$:MSGHDR.FOR /NOLIST'
	INCLUDE 'SRC$:DEVERR.FOR /NOLIST'
	INCLUDE 'SRC$:VOLMOUNT.FOR /NOLIST'




	BYTE		LUN

	BYTE		GROUP

	BYTE		MEMBER

	INTEGER*4	I

	INTEGER*4	FIELD

	INTEGER*4	COMPRESS4

	INTEGER*4	EMB$L_HD_TIME(0:1)
	EQUIVALENCE	(EMB$Q_HD_TIME,EMB$L_HD_TIME(0))

	INTEGER*4	DDB$L_NAME(0:3)
	EQUIVALENCE	(EMB(62),DDB$L_NAME)

	LOGICAL*4	SYS$FAO

	EXTERNAL	SYS$FAO

	CHARACTER*3	FAO_CONTROL1

	CHARACTER*(*)	HEADER

	CHARACTER*16	DEVICE_NAME

	CHARACTER*16	DDB$T_NAME
	EQUIVALENCE	(EMB(62),DDB$T_NAME)

	DATA	FAO_CONTROL1	/'!AF'/




	ENTRY UNKNOWN1 (LUN)



	CALL LINCHK (LUN,3)

	WRITE(LUN,2)
2	FORMAT('0','ERROR LOG RECORD',/)

	CALL LINCHK (LUN,2)

	WRITE(LUN,5) EMB$L_HD_SID
5	FORMAT(' ',T8,'ERF$L_SID',T24,Z8.8,/,T40,'SYSTEM ID REGISTER')

	CALL LINCHK (LUN,2)

	WRITE(LUN,10) EMB$W_HD_ENTRY
10	FORMAT(' ',T8,'ERL$W_ENTRY',T28,Z4.4,/,T40,'ERROR ENTRY TYPE')

	CALL LINCHK (LUN,2)

	WRITE(LUN,15) EMB$L_HD_TIME(0),EMB$L_HD_TIME(1)
15	FORMAT(' ',T8,'EXE$GQ_SYSTIME',T24,Z8.8,/,T24,Z8.8,T40,
	1 '64 BIT TIME WHEN ERROR LOGGED')

	CALL LINCHK (LUN,2)

	FIELD = LIB$EXTZV(0,16,EMB$W_HD_ERRSEQ)

	WRITE(LUN,20) EMB$W_HD_ERRSEQ,FIELD
20	FORMAT(' ',T8,'ERL$GL_SEQUENCE',T28,Z4.4,/,T40,
	1 'UNIQUE ERROR SEQUENCE = ',I<COMPRESS4 (FIELD)>,'.')

	RETURN



	ENTRY UNKNOWN2 (LUN)



	CALL LINCHK (LUN,2)

	FIELD = LIB$EXTZV(0,8,EMB$B_DV_ERTCNT)

	WRITE(LUN,25) EMB$B_DV_ERTCNT,FIELD
25	FORMAT(' ',T8,'UCB$B_ERTCNT',T30,Z2.2,/,
	1 T40,'REMAINING RETRIES = ',I<COMPRESS4 (FIELD)>,'.')

	CALL LINCHK (LUN,2)

	FIELD = LIB$EXTZV(0,8,EMB$B_DV_ERTMAX)

	WRITE(LUN,30) EMB$B_DV_ERTMAX,FIELD
30	FORMAT(' ',T8,'UCB$B_ERTMAX',T30,Z2.2,/,T40,
	1 'MAXIMUM RETRIES = ',I<COMPRESS4 (FIELD)>,'.')

	CALL LINCHK (LUN,2)

	WRITE(LUN,35) EMB$L_DV_IOSB1,EMB$L_DV_IOSB2
35	FORMAT(' ',T8,'IRP$Q_IOSB',T24,Z8.8,/,T24,Z8.8,T40,'FINAL IOSB')

	CALL LINCHK (LUN,2)

	WRITE(LUN,40) EMB$W_DV_STS
40	FORMAT(' ',T8,'UCB$W_STS',T28,Z4.4,/,T40,'DEVICE STATUS')

	CALL LINCHK (LUN,2)

	FIELD = LIB$EXTZV(0,8,EMB$B_DV_CLASS)

	WRITE(LUN,45) EMB$B_DV_CLASS,FIELD
45	FORMAT(' ',T8,'UCB$B_DEVCLASS',T30,Z2.2,/,T40,
	1 'DEVICE CLASS = ',I<COMPRESS4 (FIELD)>,'.')

	CALL LINCHK (LUN,2)

	FIELD = LIB$EXTZV(0,8,EMB$B_DV_TYPE)

	WRITE(LUN,50) EMB$B_DV_TYPE,FIELD
50	FORMAT(' ',T8,'UCB$B_DEVTYPE',T30,Z2.2,/,T40,
	1 'DEVICE TYPE = ',I<COMPRESS4 (FIELD)>,'.')

	CALL LINCHK (LUN,2)

	WRITE(LUN,55) EMB$L_DV_RQPID
55	FORMAT(' ',T8,'IRP$L_PID',T24,Z8.8,/,T40,
	1 'REQUESTING PROCESS ID')

	CALL LINCHK (LUN,2)

	FIELD = LIB$EXTZV(0,16,EMB$W_DV_BOFF)

	WRITE(LUN,60) EMB$W_DV_BOFF,FIELD
60	FORMAT(' ',T8,'IRP$W_BOFF',T28,Z4.4,/,T40,
	1 'TRANSFER BYTE OFFSET = ',I<COMPRESS4 (FIELD)>,'.')

	CALL LINCHK (LUN,2)

	FIELD = LIB$EXTZV(0,16,EMB$W_DV_BCNT)

	WRITE(LUN,65) EMB$W_DV_BCNT,FIELD
65	FORMAT(' ',T8,'IRP$W_BCNT',T28,Z4.4,/,T40,
	1 'TRANSFER BYTE COUNT = ',I<COMPRESS4 (FIELD)>,'.')

	CALL LINCHK (LUN,2)

	WRITE(LUN,70) EMB$L_DV_MEDIA
70	FORMAT(' ',T8,'UCB$L_MEDIA',T24,Z8.8,/,T40,
	1 'DEVICE DEPENDANT PHYSICAL ADDRESS')

	CALL LINCHK (LUN,2)

	FIELD = LIB$EXTZV(0,16,EMB$W_DV_UNIT)

	WRITE(LUN,75) EMB$W_DV_UNIT,FIELD
75	FORMAT(' ',T8,'UCB$W_UNIT',T28,Z4.4,/,T40,
	1 'PHYSICAL UNIT NUMBER = ',I<COMPRESS4 (FIELD)>,'.')

	CALL LINCHK (LUN,2)

	FIELD = LIB$EXTZV(0,16,EMB$W_DV_ERRCNT)

	WRITE(LUN,80) EMB$W_DV_ERRCNT,FIELD
80	FORMAT(' ',T8,'UCB$W_ERRCNT',T28,Z4.4,/,T40,
	1 'UNIT ERROR COUNT = ',I<COMPRESS4 (FIELD)>,'.')

	CALL LINCHK (LUN,1)

	WRITE(LUN,85) (EMB$L_DV_OPCNT,I = 1,2)
85	FORMAT(' ',T8,'UCB$L_OPCNT',T24,Z8.8,/,T40,
	1 'UNIT OPERATION COUNT = ',I<COMPRESS4 (EMB$L_DV_OPCNT)>,'.')

	CALL LINCHK (LUN,2)

	GROUP = LIB$EXTZV(16,8,EMB$L_DV_OWNUIC)

	MEMBER = LIB$EXTZV(0,8,EMB$L_DV_OWNUIC)

	WRITE(LUN,90) EMB$L_DV_OWNUIC,GROUP,MEMBER
90	FORMAT(' ',T8,'UCB$L_OWNUIC',T24,Z8.8,/,T40,
	1 'OWNER UIC = [',O3.3,',',O3.3,']')

	CALL LINCHK (LUN,2)

	WRITE(LUN,95) EMB$L_DV_CHAR
95	FORMAT(' ',T8,'UCB$L_DEVCHAR',T24,Z8.8,/,T40,
	1 'DEVICE CHARACTERISTICS')

	CALL LINCHK (LUN,2)

	FIELD = LIB$EXTZV(0,8,EMB$B_DV_SLAVE)

	WRITE(LUN,100) EMB$B_DV_SLAVE,FIELD
100	FORMAT(' ',T8,'UCB$B_SLAVE',T30,Z2.2,/,T40,
	1 'DEVICE SLAVE CONTROLLER = ',I<COMPRESS4 (FIELD)>,'.')

	CALL LINCHK (LUN,2)

	WRITE(LUN,105) EMB$W_DV_FUNC
105	FORMAT(' ',T8,'IRP$W_FUNC',T28,Z4.4,/,T40,
	1 'QIO FUNCTION CODE')

	CALL LINCHK (LUN,5)

C********************************************************************

C	THE FOLLOWING CODE IS DEDICATED TO VMS DEVELOPMENT WITH WHOSE
C	HELP IT WOULD HAVE BEEN UNNECESSARY.
C

	FIELD = LIB$EXTZV(0,8,EMB$B_DV_NAMLNG)

	IF ((FIELD+63) .LT. 77) THEN

	DO 108,I = (FIELD+63),77

	EMB(I) = 0

108	CONTINUE
	ENDIF

C**********************************************************************

	IF (.NOT. SYS$FAO(FAO_CONTROL1,,DEVICE_NAME,%VAL(16),
	1 %REF(DDB$T_NAME))) DEVICE_NAME = 'SYS$FAO FAILURE'

	WRITE(LUN,110) (DDB$L_NAME(I),I = 0,3),DEVICE_NAME
110	FORMAT(' ',T8,'DDB$T_NAME',4(T24,Z8.8/),T40,'/',A,'/')

	DO 130,I = 0,MIN(432,(iand(EMB$L_DV_NUMREG,'0000ffff'x)*4)),4

	CALL LINCHK (LUN,2)

	FIELD = I/4 + 1

	WRITE(LUN,120) FIELD,(EMB(78+I+J),J = 3,0,-1)
120	FORMAT(' ',T8,'LONGWORD ',I<COMPRESS4 (FIELD)>,'.',T24,4Z2.2,/)

130	CONTINUE

	RETURN



	entry unknown3	(lun)



	call linchk (lun,2)

	write(lun,135) emb$w_dv_sts
135	format(' ',t8,'UCB$W_STS',t28,z4.4,/,t40,'DEVICE STATUS')

	call linchk (lun,2)

	field = lib$extzv(0,8,emb$b_dv_class)

	write(lun,140) emb$b_dv_class,field
140	format(' ',t8,'UCB$B_DEVCLASS',t30,z2.2,/,t40,
	1 'DEVICE CLASS = ',i<compress4 (field)>,'.')

	call linchk (lun,2)

	field = lib$extzv(0,8,emb$b_dv_type)

	write(lun,145) emb$b_dv_type,field
145	format(' ',t8,'UCB$B_DEVTYPE',t30,z2.2,/,t40,
	1 'DEVICE TYPE = ',i<compress4 (field)>,'.')

	call linchk (lun,2)

	field = lib$extzv(0,16,emb$w_dv_unit)

	write(lun,150) emb$w_dv_unit,field
150	format(' ',t8,'UCB$W_UNIT',t28,z4.4,/,t40,
	1 'PHYSICAL UNIT NUMBER = ',i<compress4 (field)>,'.')

	call linchk (lun,2)

	field = lib$extzv(0,16,emb$w_dv_errcnt)

	write(lun,155) emb$w_dv_errcnt,field
155	format(' ',t8,'UCB$W_ERRCNT',t28,z4.4,/,t40,
	1 'UNIT ERROR COUNT = ',i<compress4 (field)>,'.')

	call linchk (lun,1)

	write(lun,160) (emb$l_dv_opcnt,i = 1,2)
160	format(' ',t8,'UCB$L_OPCNT',t24,z8.8,/,t40,
	1 'UNIT OPERATION COUNT = ',i<compress4 (emb$l_dv_opcnt)>,'.')

	call linchk (lun,2)

	group = lib$extzv(16,8,emb$l_dv_ownuic)

	member = lib$extzv(0,8,emb$l_dv_ownuic)

	write(lun,165) emb$l_dv_ownuic,group,member
165	format(' ',t8,'UCB$L_OWNUIC',t24,z8.8,/,t40,
	1 'OWNER UIC = [',o3.3,',',o3.3,']')

	call linchk (lun,2)

	write(lun,170) emb$l_dv_char
170	format(' ',t8,'UCB$L_DEVCHAR',t24,z8.8,/,t40,
	1 'DEVICE CHARACTERISTICS')

	call linchk (lun,2)

	field = lib$extzv(0,8,emb$b_dv_slave)

	write(lun,175) emb$b_dv_slave,field
175	format(' ',t8,'UCB$B_SLAVE',t30,z2.2,/,t40,
	1 'DEVICE SLAVE CONTROLLER = ',i<compress4 (field)>,'.')

	call linchk (lun,5)

c********************************************************************

c	the following code is dedicated to vms development with whose
c	help it would have been unnecessary.
c

	field = lib$extzv(0,8,emb$b_dv_namlng)

	if ((field+63) .lt. 77) then

	do 180,i = (field+63),77

	emb(i) = 0

180	continue
	endif

c**********************************************************************

	if (.not. sys$fao(fao_control1,,device_name,%val(16),
	1 %ref(ddb$t_name))) device_name = 'SYS$FAO FAILURE'

	write(lun,185) (ddb$l_name(i),i = 0,3),device_name
185	format(' ',t8,'DDB$T_NAME',4(t24,z8.8/),t40,'/',a,'/')

	do 195,i = 0,min(432,(IAND(emb$l_dv_numreg,'0000FFFF'X)*4)),4

	call linchk (lun,2)

	field = i/4 + 1

	write(lun,190) field,(emb(78+i+j),j = 3,0,-1)
190	format(' ',t8,'LONGWORD ',i<compress4 (field)>,'.',t24,4z2.2,/)

195	continue

	return

	end
