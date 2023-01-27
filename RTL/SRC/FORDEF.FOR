C
C	SYS$LIBRARY:FORDEF.FOR - Define FOR$ error symbols
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
	1 FOR$_SYNERRNAM = '18808C'X,	! 17 syntax error in NAMELIST input
	1 FOR$_TOOMANVAL = '188094'X,	! 18 too many values for NAMELIST variable
	1 FOR$_INVREFVAR = '18809C'X,	! 19 invalid reference to variable
	1 FOR$_REWERR    = '1880A4'X,	! 20 REWIND error 
	1 FOR$_DUPFILSPE = '1880AC'X,	! 21 duplicate file specifications 
	1 FOR$_INPRECTOO = '1880B4'X,	! 22 input record too long 
	1 FOR$_BACERR    = '1880BC'X,	! 23 BACKSPACE error 
	1 FOR$_ENDDURREA = '1880C4'X,	! 24 end-of-file during read 
	1 FOR$_RECNUMOUT = '1880CC'X,	! 25 record number outside range 
	1 FOR$_OPEDEFREQ = '1880D4'X,	! 26 OPEN or DEFINE FILE required
	1 FOR$_TOOMANREC = '1880DC'X,	! 27 too many records in I/O statement
	1 FOR$_MORONEREC = '1880DC'X,	! 27 obsolete error name
	1 FOR$_CLOERR    = '1880E4'X,	! 28 CLOSE error 
	1 FOR$_FILNOTFOU = '1880EC'X	! 29 file not found 

	PARAMETER
	1 FOR$_OPEFAI    = '1880F4'X,	! 30 open failure 
	1 FOR$_MIXFILACC = '1880FC'X,	! 31 mixed file access modes 
	1 FOR$_INVLOGUNI = '188104'X,	! 32 invalid logical unit number 
	1 FOR$_ENDFILERR = '18810C'X,	! 33 ENDFILE error 
	1 FOR$_UNIALROPE = '188114'X,	! 34 unit already open 
	1 FOR$_SEGRECFOR = '18811C'X,	! 35 segmented record format error 
	1 FOR$_ATTREANON = '188124'X,	! 36 obsolete error name
	1 FOR$_ATTACCNON = '188124'X,	! 36 attempt to access non-existent record
	1 FOR$_INCRECLEN = '18812C'X,	! 37 inconsistent record length 
	1 FOR$_ERRDURWRI = '188134'X,	! 38 error during write 
	1 FOR$_ERRDURREA = '18813C'X	! 39 error during read 

	PARAMETER
	1 FOR$_RECIO_OPE = '188144'X,	! 40 recursive I/O operation 
	1 FOR$_INSVIRMEM = '18814C'X,	! 41 insufficient virtual memory 
	1 FOR$_NO_SUCDEV = '188154'X,	! 42 no such device 
	1 FOR$_FILNAMSPE = '18815C'X,	! 43 file name specification error 
	1 FOR$_RECSPEERR = '188164'X,	! 44 obsolete error name
	1 FOR$_INCRECTYP = '188164'X,	! 44 inconsistent record type
	1 FOR$_KEYVALERR = '18816C'X,	! 45 keyword value error in OPEN statement 
	1 FOR$_INCOPECLO = '188174'X,	! 46 inconsistent OPEN/CLOSE parameters
	1 FOR$_WRIREAFIL = '18817C'X,	! 47 write to READONLY file 
	1 FOR$_INVARGFOR = '188184'X	! 48 invalid argument to FORTRAN Run-Time Library 
  
	PARAMETER
	1 FOR$_INVKEYSPE = '18818C'X,	! 49 invalid key specification
	1 FOR$_INCKEYCHG = '188194'X,	! 50 inconsistent key change or duplicate key
	1 FOR$_INCFILORG = '18819C'X,	! 51 inconsistent file organization
	1 FOR$_SPERECLOC = '1881A4'X,	! 52 specified record locked
	1 FOR$_NO_CURREC = '1881AC'X,	! 53 no current record
	1 FOR$_REWRITERR = '1881B4'X,	! 54 REWRITE error
	1 FOR$_DELERR    = '1881BC'X,	! 55 DELETE error
	1 FOR$_UNLERR    = '1881C4'X,	! 56 UNLOCK error
	1 FOR$_FINERR    = '1881CC'X	! 57 FIND error

	PARAMETER
	1 FOR$_LISIO_SYN = '1881DC'X,	! 59 list-directed I/O syntax error 
	1 FOR$_INFFORLOO = '1881E4'X,	! 60 infinite format loop 
	1 FOR$_FORVARMIS = '1881EC'X,	! 61 format/variable-type mismatch 
	1 FOR$_SYNERRFOR = '1881F4'X,	! 62 syntax error in format 
	1 FOR$_OUTCONERR = '1881FA'X,	! 63 output conversion error 
	1 FOR$_INPCONERR = '188204'X,	! 64 input conversion error 
	1 FOR$_OUTSTAOVE = '188214'X,	! 66 output statement overflows record 
	1 FOR$_INPSTAREQ = '18821C'X,	! 67 input statement requires too much data 
	1 FOR$_VFEVALERR = '188224'X,	! 68 variable format expression value error 
	1 FOR$_ADJARRDIM = '1882EC'X	! 93 adjustable array dimension error 

	PARAMETER
	1 FOR$_UNFIO_FMT = '188804'X,	! 256 unformatted I/O to unit open for formatted transfers
	1 FOR$_FMTIO_UNF = '18880C'X,	! 257 formatted I/O to unit open for unformatted transfers
	1 FOR$_DIRIO_KEY = '188814'X,	! 258 direct-access I/O to unit open for keyed access
	1 FOR$_SEQIO_DIR = '18881C'X,	! 259 sequential-access I/O to unit open for direct access
	1 FOR$_KEYIO_DIR = '188824'X,	! 260 keyed-access I/O to unit open for direct access
	1 FOR$_IO_NONFOR = '18882C'X,	! 261 I/O to non-FORTRAN unit
	1 FOR$_INVTEXREC = '188834'X,	! 262 invalid text is ... in record number ...
	1 FOR$_FLOUNDEXC = '18883B'X	! 263 nn floating underflow exceptions

C
C	End of FORDEF.FOR
C
