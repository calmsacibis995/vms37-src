C	BINCOMLPG - Binary Compare for LINEPAGE
C
C	This program is used by SYSBLDCOM$:TKBLPG.COM to generate
C	the data file reflecting the differences between two builds
C	of the same compatibility mode image with different parameter
C	values for the number of lines in the listing format.  This
C	data file is the input to LINEPAGE.COM
C
	BYTE BIN1(512),BIN2(512)
	INTEGER*2 IN1(256),IN2(256)
	EQUIVALENCE (IN1,BIN1),(IN2,BIN2)
	INTEGER VBN
	OPEN (UNIT=1,STATUS='OLD',READONLY,SHARED,FORM='FORMATTED')
	OPEN (UNIT=2,STATUS='OLD',READONLY,SHARED,FORM='FORMATTED')
	OPEN (UNIT=6,STATUS='UNKNOWN',FORM='FORMATTED',
	1  CARRIAGECONTROL='LIST',RECORDTYPE='VARIABLE')
	VBN=0
10	READ (1,110,END=200), (BIN1(I),I=1,512)
	READ (2,110), (BIN2(I),I=1,512)
	VBN=VBN+1
	DO 50 I=1,256
	IF (IN1(I) .EQ. IN2(I)) GOTO 50
	WRITE (6,100), VBN,2*(I-1),IN1(I),IN2(I)
50	CONTINUE
	GOTO 10
100	FORMAT (1X,O6,':',O3,'/',O7,'/',O7)
110	FORMAT (512A1)
200	END
