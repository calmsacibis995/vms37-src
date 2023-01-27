C	MAKELIST.FOR     -   Steven Lionel   - 2-April-1980
C
C	MAKELIST takes a file in non-listing format, such as
C	MDL files, and creates a paginated "listing" file
C	with the name LIS$:fname.ex where ex is the first two
C	characters of the input file extenstion.  For example,
C	if the input file is SSDEF.MDL, the output is 
C	LIS$:SSDEF.MD.
C
C	To use:
C		$ MAKELIST :== $SYSBLDCOM$:MAKELIST
C		$ MAKELIST filename
C
C
C
	CHARACTER*133 LINE
	CHARACTER*40 FILE
	CHARACTER*40 OUTFILE
	CHARACTER*23 TIME
	PARAMETER FF='0C'X
	INTEGER*4 PAGE
	INTEGER*4 LENGTH
	INTEGER*4 PAGE_SIZE

	CALL SYS$ASCTIM(,TIME,,)	! Get date and time
	CALL LIB$GET_FOREIGN(FILE,'File: ')	! Get file name
	OPEN (UNIT=1,FILE=FILE,STATUS='OLD',READONLY,FORM='FORMATTED')
	INQUIRE (UNIT=1,NAME=FILE)	! Get resultant name string
	OUTFILE=FILE			! Convert to LIS$:fname.ex
	N=LIB$LOCC(']',OUTFILE)
	OUTFILE(1:N)='LIS$:'
	FILE=FILE(N+1:)
	N=LIB$LOCC('.',OUTFILE)+2
	OUTFILE=OUTFILE(1:N)
	OPEN (UNIT=2,FILE=OUTFILE,STATUS='NEW',FORM='FORMATTED',
	1  CARRIAGECONTROL='LIST',RECORDTYPE='VARIABLE')
	PAGE=0
	PAGE_SIZE=LIB$LP_LINES()-9
	READ (1,103,END=900) LENGTH,LINE
	DO WHILE (.TRUE.)
	  PAGE=PAGE+1
	  WRITE (2,101) FF,FILE,TIME,PAGE	! Write header
101	  FORMAT(A1/A,T41,A,T73,'Page',I4//)
	  DO I=1,PAGE_SIZE
	    WRITE (2,102) LINE(1:LENGTH)	! Write text line
102	    FORMAT(A)
	    READ (1,103,END=900) LENGTH,LINE	! Read text line
103	    FORMAT(Q,A)
	    IF (LENGTH .EQ. 1) THEN		! Possible page mark?
	      IF (ICHAR(LINE) .EQ. FF) THEN
		READ (1,103,END=900) LENGTH,LINE
		GOTO 200
		END IF
	      END IF
	    END DO
200	  CONTINUE
	  END DO
900	CLOSE (UNIT=1)
	CLOSE (UNIT=2)
	END
