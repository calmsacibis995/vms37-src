	SUBROUTINE VAX750REG (LUN,REGISTER)

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
C
C	AUTHOR	BRIAN PORTER		CREATION DATE	16-AUG-1979
C
C	Functional description:
C
C	This module displays the Kernel cluster registers that appear
C	in various error log entries for the 11/750.
C
C	Modified by:
C
C	v02-005	BP0005		Brian Porter,		09-NOV-1981
C		Corrected mcesr register.
C
C	v02-004	BP0004		Brian Porter,		15-MAY-1981
C		Changed some register heralds.  Added diagnostic
C		mode.
C
C	v02-003	BP0003		Brian Porter,		15-MAY-1981
C		Made register output a 32 bit field.
C
C	v02-002	BP0002		Brian Porter,		15-MAY-1981
C		Corrected CMIER errors.		
C
C	v02-001	BP0001		Brian Porter,		30-AUG-1980
C		Removed call to UNUSED_BITS.
C**



	include 'src$:modes.for /nolist'

	BYTE		LUN

	INTEGER*4	REGISTER

	integer*4	lib$extzv

	INTEGER*4	COMPRESSC

	character*18	v1mcesr(0:0,0:1)

	character*27	v2mcesr(1:3)

	character*17	v1caer(0:3)

	CHARACTER*21	V1CMIER(0:3)

	CHARACTER*7	V2CMIER(4:4)

	character*17	v3cmier(8:11)

	CHARACTER*18	V4CMIER(12:12)

	CHARACTER*9	V5CMIER(18:19,0:1)

	CHARACTER*12	V6CMIER(20:20)





	data	v1mcesr(0,0)	/'OPERAND REFERENCE*'/

	data	v1mcesr(0,1)	/'XB REFERENCE*'/






	data	v2mcesr(1)	/'UNALIGNED UNIBUS REFERENCE*'/

	data	v2mcesr(2)	/'TB PARITY ERROR*'/

	data	v2mcesr(3)	/'BUS ERROR*'/




	data	v1caer(0)	/'CACHE HIT*'/

	data	v1caer(1)	/'2ND ERROR*'/

	data	v1caer(2)	/'DATA PARITY ERROR*'/

	data	v1caer(3)	/'TAG PARITY ERROR*'/





	DATA	V1CMIER(0)	/'CORRECTED READ DATA*'/

	DATA	V1CMIER(1)	/'LOST ERROR*'/

	DATA	V1CMIER(2)	/'READ DATA SUBSTITUTE*'/

	DATA	V1CMIER(3)	/'MEMORY ERROR*'/




	DATA	V2CMIER(4)	/'TB HIT*'/




	data	v3cmier(8)	/'TB G0 DATA ERROR*'/

	data	v3cmier(9)	/'TB G1 DATA ERROR*'/

	data	v3cmier(10)	/'TB G0 TAG ERROR*'/

	data	v3cmier(11)	/'TB G1 TAG ERROR*'/



	data	v4cmier(12)	/'READ LOCK TIMEOUT*'/




	data	v5cmier(18,0)	/'VIRTUAL*'/

	data	v5cmier(18,1)	/'PHYSICAL*'/

	data	v5cmier(19,0)	/'MODIFY*'/

	data	v5cmier(19,1)	/'READ*'/





	DATA	V6CMIER(20)	/'CMI DISABLE*'/



	ENTRY COMET_TBDR (LUN,REGISTER)



	CALL LINCHK (LUN,1)

	WRITE(LUN,10) REGISTER
10	FORMAT(' ',T8,'TBGDR',T24,Z8.8)

	if (iand(register,'0000000b'x) .ne. 0) then

	call linchk (lun,1)

	write(lun,15) 'DIAGNOSTIC MODE'
15	format(' ',t40,a)
	endif

	RETURN



	ENTRY COMET_CADR (LUN,REGISTER)



	CALL LINCHK (LUN,1)

	WRITE(LUN,20) REGISTER
20	FORMAT(' ',T8,'CGDR',T24,Z8.8)

	if (iand(register,'00000001'x) .ne. 0) then

	call linchk (lun,1)

	write(lun,25) 'DIAGNOSTIC MODE'
25	format(' ',t40,a)
	endif

	RETURN




	ENTRY COMET_MCESR (LUN,REGISTER)



	CALL LINCHK (LUN,1)

	WRITE(LUN,30) REGISTER
30	FORMAT(' ',T8,'MCESR',T24,Z8.8)

	call output (lun,register,v1mcesr,0,0,0,'2')

	call output (lun,register,v2mcesr,1,1,3,'0')

	RETURN




	ENTRY COMET_CAER (LUN,REGISTER)



	CALL LINCHK (LUN,1)

	WRITE(LUN,35) REGISTER
35	FORMAT(' ',T8,'CAER',T24,Z8.8)

	CALL OUTPUT (LUN,REGISTER,V1CAER,0,0,3,'0')

	RETURN

C
C	THE CMIER REGISTER IS USED BY SEVERAL MODULES.THE
C	MICRO-CODE WITHIN COMET SPLITS THE REGISTER INTO
C	INDIVIDUAL 4 BIT SLICES AND PUSHES THAT RIGHT
C	JUSTIFIED ONTO THE STACK WHEN A MACHINE CHECK
C	OCCURS.  ANY MODULE CALLING CMIER_XXX MUST
C	PRESENT THE BITS IN THEIR CORRECT POSITION.
C	ALSO THE MODULE MUST HANDLE THE UNUSED BITS
C	WITHIN THE BIT SLICE ITSELF.
C



	ENTRY CMIER_30 (LUN,REGISTER)



	CALL OUTPUT (LUN,REGISTER,V1CMIER,0,0,3,'0')

	RETURN



	ENTRY CMIER_74 (LUN,REGISTER)



	call output (lun,register,v2cmier,4,4,4,'0')

	RETURN



	ENTRY CMIER_118 (LUN,REGISTER)



	call output (lun,register,v3cmier,8,8,11,'0')

	RETURN



	ENTRY CMIER_1512 (LUN,REGISTER)



	CALL OUTPUT (LUN,REGISTER,V4CMIER,12,12,12,'0')

	RETURN



	ENTRY CMIER_1916 (LUN,REGISTER)




	CALL LINCHK (LUN,1)

	WRITE(LUN,75) modes(lib$extzv(16,2,register))
75	FORMAT(' ',T40,'CPU MODE = ',
	1 A<COMPRESSC (modes(lib$extzv(16,2,register)))>)

	call output (lun,register,v5cmier,18,18,19,'2')

	RETURN




	ENTRY CMIER_2320 (LUN,REGISTER)



	if (iand(register,'00100000'x) .ne. 0) then

	call linchk (lun,1)

	write(lun,80) 'DIAGNOSTIC MODE'
80	format(' ',t40,a)
	endif

	RETURN

	END
