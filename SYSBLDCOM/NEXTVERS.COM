$ !
$ ! N E X T V E R S . C O M   -   Update system version number
$ !
$ !	P1 = Directory holding SYS.OLB to be updated with the
$ !		new version number.  If not specified, then
$ !		no SYS.OLB is updated and the only effect is
$ !		to update the version number.
$ !
$ !	WRKD$:[SYS.SRC]VERSION.MAR is the permanent place which
$ !	holds the current system version number.
$ !
$ !	If the version number begins with "S" then the following digits
$ !	will be the base 36 representation of the hour since the beginning
$ !	of the year 1980.  If the version number begins with "X" then the seed
$ !	version number will be incremented and expressed in base 36.
$ !	Version numbers beginning with "S" are reserved for customer systems
$ !	generated from the VMS source kit.  Version numbers beginning with "X"
$ !	are reserved for DEC internal use.
$ !
$ ON CONTROL_Y THEN CONTINUE
$ ON ERROR THEN GOTO END
$ OPEN VERS WRKD$:[SYS.SRC]VERSION.MAR
$ OPEN/WRITE NEWVERS WRKD$:[SYS.SRC]VERSION.MAR
$NEXTLINE:
$ READ VERS BUFFER/END=NOTIFY_VER
$ L='F$LOC("%DATE",BUFFER)
$ IF L .GE. 'F$LEN(BUFFER) THEN GOTO CHECKVERS
$ DATE:='F$TIME()
$ L = 'F$LOCATE(".",DATE)'
$ L = L - 3
$ DATE:='F$EXT(0,L,DATE)
$ BUFFER:="	.ASCII	'"'DATE'"'	; %DATE"
$ GOTO WRTBUF
$CHECKVERS:
$ IF 'F$LOC("%VERSION",BUFFER) .GE. 'F$LEN(BUFFER) THEN GOTO CHECKINDENT
$ L='F$LOC("%=",BUFFER)+2
$ LEN='F$LEN(BUFFER)-L
$ VNUM='F$EXT(L,LEN,BUFFER)
$ VNUM=VNUM+1
$ L='F$LOC("^A",BUFFER)+3
$ VTYPE:='F$EXT(L,1,BUFFER)	! GET VERSION TYPE X=DEC; S=SOURCEKIT
$ IF VTYPE .EQS. "X" THEN GOTO SETBUF
$ L='F$LOC("-",DATE)
$ DAY='F$EXT(0,L,DATE)
$ L=L+1
$ MONTH:='F$EXT(L,3,DATE)
$ L=L+4
$ YEAR='F$EXT(L,4,DATE)
$ L=L+5
$ HOUR='F$EXT(L,2,DATE)
$ MONTAB:="JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC"
$ MONTH='F$LOC(MONTH,MONTAB)
$ DAYTAB:="000031059090120151181212243273304334"
$ DAY=DAY+'F$EXT(MONTH,3,DAYTAB)
$ L=YEAR/4
$ L=4*L
$ LEAP=0
$ IF L .EQ. YEAR THEN LEAP=1
$ IF DAY .GT. 60 THEN DAY=DAY+LEAP
$ YR=YEAR-1980
$ YRTAB:="01111222233334444555555556666"
$ YEAR=365*YR+'F$EXT(YR,1,YRTAB)
$ DAY=DAY+YEAR
$ VNUM=DAY*24+HOUR
$SETBUF:
$ V2=VNUM/(36*36)		! CONVERT TO BASE 36
$ V1=(VNUM-V2*36*36)/36
$ V0=(VNUM-V2*36*36-V1*36)
$ CHARS:="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
$ VSTR:='VTYPE''F$EXT(V2,1,CHARS)''F$EXT(V1,1,CHARS)''F$EXT(V0,1,CHARS)'
$ BUFFER:="SYS$K_VERSION==^A'"'VSTR'"'			; %VERSION%="'VNUM'
$ GOTO WRTBUF
$CHECKINDENT:
$ L='F$LOC(".IDENT",BUFFER)
$ IF L .GE. 'F$LEN(BUFFER) THEN GOTO WRTBUF
$ BUFFER:="	.IDENT	'"'VSTR'"'			; IDENT"
$WRTBUF:
$ WRITE NEWVERS BUFFER
$ GOTO NEXTLINE
$NOTIFY_VER:
$ WRITE SYS$OUTPUT "New system version is ",VSTR
$END:
$ SET NOON
$ CLOSE NEWVERS
$ CLOSE VERS
$ PURGE WRKD$:[SYS.SRC]VERSION.MAR/KEEP:2
$ MACRO/OBJ=WRKD$:[SYS.OBJ]VERSION/LIST=WRKD$:[SYS.LIS]VERSION -
	WRKD$:[SYS.SRC]VERSION
$ PURGE WRKD$:[SYS.OBJ]VERSION.OBJ,WRKD$:[SYS.LIS]VERSION.LIS
$ IF P1 .EQS. "" THEN EXIT		! SKIP IF OLB NOT SPECIFIED
$ LIB /NOGLOBALS OBJD$:['P1'.OBJ]SYS WRKD$:[SYS.OBJ]VERSION
