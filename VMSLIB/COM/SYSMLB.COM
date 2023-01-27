$ !
$ !		[ VMSLIB.COM ] S Y S M L B . C O M
$ !
$ !	Build LIB.MLB and/or LIB.L32/LIB.REQ
$ !	Uses output from VMSLIBMDL.COM and VMSMLB.COM
$ !
$ !	P1 = MACRO to build just LIB.MLB
$ !	   = BLISS to build just LIB.L32/LIB.REQ
$ !	   = null to build both
$ !
$ IF P1 .EQS. "BLISS" THEN GOTO 10
$ !
$ !	NOTE: LIB should not contain anything that is in STARLET.
$ !
$ DELETE LIBD$:[SYS.OBJ]LIB.MLB;*
$ LIBRARY /MACRO /SQUEEZE /CREATE=(BLOCKS=410,MODULES=170) -
	LIBD$:[SYS.OBJ]LIB.MLB -
	LIB$:F11A, F11DEF, -
	LIB$:SYSDEF, SYSGMSG, -
	SHRLIB$:JBCMSG, -				! From JOBCTL
	SHRLIB$:MSGDEF, -				! From MSGFIL
	SHRLIB$:RMSFILSTR, -				! From RMS
	SHRLIB$:SYSMAR, -				! From SYS
	SHRLIB$:TTYDEF, -				! From TTDRVR
	SHRLIB$:NMADEF, -				! From NCP
	SHRLIB$:NETUSR					! From NETACP
$ !
$ !	Build LIB.L32 and LIB.REQ
$ !
$10:
$ IF P1 .EQS. "MACRO" THEN GOTO END
$ DELETE LIB$:LIB.REQ;*
$ COPY -
	LIB$:SYSDEF.B32,F11A,F11DEF, -
	SHRLIB$:RMSFILSTR.B32 -				! From RMS
  LIB$:LIB.REQ
$ DELETE LIB$:LIB.L32;*
$ BLISS/NOLIST/LIBRARY=LIB$:LIB LIB$:STARLET.REQ+LIB$:LIB.REQ
$END:
