$ OLDVFY='F$VERIFY()'
$ SET NOVERIFY
$ !
$ ! CPYRES - COPY TO RESULT DIRECTORY
$ !
$ ! INPUTS:
$ !
$ !	P1 = OUTPUT DEVICE AND DIRECTORY STRING
$ !	P2 = INPUT FILE LIST AS IF INPUT TO PIP
$ !	P3 = OUTPUT FILE NAME IF CONCATENATING (NO DEVICE OR DIRECTORY)
$ !
$ !	P3 may be a * if no concatenation is desired.
$ !	The destination file(s) will be purged.
$ !
$ SET VERIFY
$ COPY/PROT=(OWNER:RWED) 'P2'	'P1''P3'
$ SET NOVERIFY
$ IF P3 .EQS. "*" THEN GOTO 15
$ IF P3 .NES. "" THEN GOTO 20
$ P3:=""
$15:
$ !
$ ! Isolate input file name
$ !
$ K = 'F$LOCATE(":", P2)' + 1		! Assume no directory specified
$ IF K .GT. 'F$LENGTH(P2) THEN K=0
$ IF 'F$LOCATE("]",P2)' .LT. 'F$LENGTH(P2)' THEN K = 'F$LOCATE("]",P2)'+1
$ L = 'F$LENGTH(P2)'
$ IF L .GT. 'F$LOCATE("/",P2) THEN L = 'F$LOCATE("/",P2)
$ M='F$LOCATE(",",P2)
$ IF M .LT. L THEN L=M
$ L = L - K
$ P3 := 'P3''F$EXTRACT(K, L, P2)'
$ L='F$LENGTH(P2)
$ N='F$LOCATE(",",P2)
$ IF N .EQ. L THEN GOTO 20
$ L=L-N
$ N=N+1
$ P2:='F$EXTRACT(N,L,P2)
$ P3:='P3',
$ GOTO 15
$20:
$ PURGE 'P1''P3'
$! MCR PIP 'P1''P3'/PU
$ GOTO EXIT
$FAIL:
$ WRITE SYS$OUTPUT ***** INVALID PARAMETER TO COPY *****
$EXIT:
$ IF .NOT. OLDVFY THEN SET NOVERIFY
$ IF OLDVFY THEN SET VERIFY
$ EXIT
