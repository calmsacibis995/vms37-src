C
C	SYS$LIBRARY:FORIOSDEF.FOR - Define FORTRAN error numbers
C				    for use with IOSTAT and ERRSNS
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

	PARAMETER
	1 FOR$IOS_NOTFORSPE = 1		!  not a FORTRAN specific error
					!  ERRSNS only - IOSTAT can not
					!  return this value.

	PARAMETER
	1 FOR$IOS_SYNERRNAM = 17,	!  syntax error in NAMELIST input
	1 FOR$IOS_TOOMANVAL = 18,	!  too many values for NAMELIST variable
	1 FOR$IOS_INVREFVAR = 19,	!  invalid reference to variable
	1 FOR$IOS_REWERR    = 20,	!  REWIND error 
	1 FOR$IOS_DUPFILSPE = 21,	!  duplicate file specifications 
	1 FOR$IOS_INPRECTOO = 22,	!  input record too long 
	1 FOR$IOS_BACERR    = 23,	!  BACKSPACE error 
	1 FOR$IOS_ENDDURREA = 24,	!  end-of-file during read 
	1				!  (ERRSNS only - IOSTAT returns
	1				!  a negative value for this error)
	1 FOR$IOS_RECNUMOUT = 25,	!  record number outside range 
	1 FOR$IOS_OPEDEFREQ = 26,	!  OPEN or DEFINE FILE required
	1 FOR$IOS_TOOMANREC = 27,	!  too many records in I/O statement
	1 FOR$IOS_CLOERR    = 28,	!  CLOSE error 
	1 FOR$IOS_FILNOTFOU = 29	!  file not found 

	PARAMETER
	1 FOR$IOS_OPEFAI    = 30,	!  open failure 
	1 FOR$IOS_MIXFILACC = 31,	!  mixed file access modes 
	1 FOR$IOS_INVLOGUNI = 32,	!  invalid logical unit number 
	1 FOR$IOS_ENDFILERR = 33,	!  ENDFILE error 
	1 FOR$IOS_UNIALROPE = 34,	!  unit already open 
	1 FOR$IOS_SEGRECFOR = 35,	!  segmented record format error 
	1 FOR$IOS_ATTACCNON = 36,	!  attempt to access non-existent record
	1 FOR$IOS_INCRECLEN = 37,	!  inconsistent record length 
	1 FOR$IOS_ERRDURWRI = 38,	!  error during write 
	1 FOR$IOS_ERRDURREA = 39	!  error during read 

	PARAMETER
	1 FOR$IOS_RECIO_OPE = 40,	!  recursive I/O operation 
	1 FOR$IOS_INSVIRMEM = 41,	!  insufficient virtual memory 
	1 FOR$IOS_NO_SUCDEV = 42,	!  no such device 
	1 FOR$IOS_FILNAMSPE = 43,	!  file name specification error 
	1 FOR$IOS_INCRECTYP = 44,	!  inconsistent record type
	1 FOR$IOS_KEYVALERR = 45,	!  keyword value error in OPEN statement 
	1 FOR$IOS_INCOPECLO = 46,	!  inconsistent OPEN/CLOSE parameters
	1 FOR$IOS_WRIREAFIL = 47,	!  write to READONLY file 
	1 FOR$IOS_INVARGFOR = 48	!  invalid argument to FORTRAN Run-Time Library 
  
	PARAMETER
	1 FOR$IOS_INVKEYSPE = 49,	!  invalid key specification
	1 FOR$IOS_INCKEYCHG = 50,	!  inconsistent key change or duplicate key
	1 FOR$IOS_INCFILORG = 51,	!  inconsistent file organization
	1 FOR$IOS_SPERECLOC = 52,	!  specified record locked
	1 FOR$IOS_NO_CURREC = 53,	!  no current record
	1 FOR$IOS_REWRITERR = 54,	!  REWRITE error
	1 FOR$IOS_DELERR    = 55,	!  DELETE error
	1 FOR$IOS_UNLERR    = 56,	!  UNLOCK error
	1 FOR$IOS_FINERR    = 57	!  FIND error

	PARAMETER
	1 FOR$IOS_LISIO_SYN = 59,	!  list-directed I/O syntax error 
	1 FOR$IOS_INFFORLOO = 60,	!  infinite format loop 
	1 FOR$IOS_FORVARMIS = 61,	!  format/variable-type mismatch 
	1 FOR$IOS_SYNERRFOR = 62,	!  syntax error in format 
	1 FOR$IOS_OUTCONERR = 63,	!  output conversion error 
	1 FOR$IOS_INPCONERR = 64,	!  input conversion error 
	1 FOR$IOS_OUTSTAOVE = 66,	!  output statement overflows record 
	1 FOR$IOS_INPSTAREQ = 67,	!  input statement requires too much data 
	1 FOR$IOS_VFEVALERR = 68	!  variable format expression value error 

C	Error numbers 70-77 refer to hardware exceptions and are
C	not returned by IOSTAT.

	PARAMETER
	1 FOR$IOS_INTOVF    = 70,	!  integer overflow
	1 FOR$IOS_INTDIV    = 71,	!  integer divide by zero
	1 FOR$IOS_FLTOVF    = 72,	!  floating overflow
	1 FOR$IOS_FLTDIV    = 73,	!  floating/decimal divide by zero
	1 FOR$IOS_FLTUND    = 74,	!  floating underflow
	1 FOR$IOS_SUBRNG    = 77	!  subscript out of range

C	Error numbers 80-89 refer to Math Library reported errors and
C	are not returned by IOSTAT.

	PARAMETER
	1 FOR$IOS_WRONUMARG = 80,	!  wrong number of arguments
	1 FOR$IOS_INVARGMAT = 81,	!  invalid argument to math library
	1 FOR$IOS_UNDEXP    = 82,	!  undefined exponentiation
	1 FOR$IOS_LOGZERNEG = 83,	!  logarithm of zero or negative value
	1 FOR$IOS_SQUROONEG = 84,	!  square root of negative value
	1 FOR$IOS_SIGLOSMAT = 87,	!  significance lost in math library
	1 FOR$IOS_FLOOVEMAT = 88,	!  floating overflow in math library
	1 FOR$IOS_FLOUNDMAT = 89	!  floating underflow in math library

	PARAMETER
	1 FOR$IOS_ADJARRDIM = 93	!  adjustable array dimension error 

C
C	End of FORIOSDEF.FOR
C
