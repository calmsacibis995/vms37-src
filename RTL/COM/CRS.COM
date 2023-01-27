$ ! File: CRS.COM - Generate S.MLB for RTL assembly...
$ ! 0-1 Put in alphabetic order.  TNH 2-May-78
$ ! 0-2 Get MDL output from LIB$:, not SRC$:.  TNH 20-July-78
$ ! 0-3 Don't delete .MAR files afterward.  TNH 20-July-78
$ ! 1-4 Look for UTLDEF.MAR on SRC$: for VAX II  JBS 15-NOV-78
$ ! 1-5 Change file names to conform to RTL standards  JBS 15-NOV-78
$ ! 1-006 Include BASMSG.MAR  JBS 27-NOV-78
$ ! 1-007 Include BASPAR.MAR and convert from MCP PIP to
$ !	   the RMS CONVERT utility.  We cannot use APPEND because
$ !	   the MDL output has FORTRAN record format but UTLDEF.MAR
$ !	   has carriage return record format.  JBS 29-NOV-78
$ ! 1-008 Change FORISB and FORLUB to OTSISB and OTSLUB,
$ !	   respectively.  JBS 07-DEC-78
$ ! 1-009 Divide RTLMSG up into OTSMSG, LIBMSG, FORMSG and MTHMSG.  JBS 11-DEC-78
$ ! 1-010 - Add COBMSG.  JBS 04-JAN-1979
$ ! 1-011 - Add INTPAR.  DGP 29-Jan-79
$ ! 1-012 - Add SRMDEF \\Temporary\\  SBL 12-Feb-79
$ ! 1-013 - Add STRMSG.  JBS 15-MAY-1979
$ ! 1-014 - Remove SRMDEF and UTLDEF.  JBS 22-JUN-1979
$ !
$ !--
$ !
$ !
$ SET VERIFY
$ DELETE LIB$:S.MAR.*,S.MLB.*
$ MCR CNV LIB$:S.MAR=LIB$:FORERR.MAR
$ MCR CNV LIB$:S.MAR/AP=LIB$:OTSISB.MAR
$ MCR CNV LIB$:S.MAR/AP=LIB$:OTSLUB.MAR
$ MCR CNV LIB$:S.MAR/AP=LIB$:FORPAR.MAR
$ MCR CNV LIB$:S.MAR/AP=LIB$:MTHERR.MAR
$ MCR CNV LIB$:S.MAR/AP=LIB$:OTSMSG.MAR
$ MCR CNV LIB$:S.MAR/AP=LIB$:STRMSG.MAR
$ MCR CNV LIB$:S.MAR/AP=LIB$:LIBMSG.MAR
$ MCR CNV LIB$:S.MAR/AP=LIB$:FORMSG.MAR
$ MCR CNV LIB$:S.MAR/AP=LIB$:MTHMSG.MAR
$ MCR CNV LIB$:S.MAR/AP=LIB$:BASMSG.MAR
$ MCR CNV LIB$:S.MAR/AP=LIB$:BASPAR.MAR
$ MCR CNV LIB$:S.MAR/AP=LIB$:COBMSG.MAR
$ MCR CNV LIB$:S.MAR/AP=LIB$:INTPAR.MAR
$ LIBRARY/CREATE/MACRO LIB$:S.MLB LIB$:S.MAR
$ DELETE LIB$:S.MAR.*
$ !
$ !	[End of CRS.COM]
