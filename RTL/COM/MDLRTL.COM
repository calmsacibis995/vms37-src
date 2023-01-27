$ ! MDLRTL.COM - Produce all MDL files for RTL
$ !
$ ! Edit History:
$ !
$ ! 1-003 - Produce BASMSG.MDL  JBS 27-NOV-78
$ ! 1-004 - Process BASPAR.MDL.  JBS 29-NOV-78
$ ! 1-005 - Change FORISB and FORLUB to OTSISB and OTSLUB.  JBS 06-DEC-78
$ ! 1-006 - Divide RTLMSG into OTSMSG, LIBMSG, FORMSG and MTHMSG.  JBS 11-DEC-78
$ ! 1-007 - Delete old output files before starting.  JBS 13-DEC-78
$ ! 1-008 - Add COBMSG.  JBS 04-JAN-1979
$ ! 1-009 - Add INTPAR.  DGP 29-Jan-79
$ ! 1-010 - Add SRMDEF \\Temporary\\  SBL 12-Feb-79
$ ! 1-011 - Remove building BASMSG.MDL.  It will now be done before the build
$ ! 	     is started, and placed on SRC$:.  JBS 22-MAR-1979
$ ! 1-012 - Add STRMSG.  JBS 15-MAY-1979
$ ! 1-013 - Remove SRMDEF.  JBS 27-JUN-1979
$ ! 1-014 - Replace building BASMSG.MDL.  SBL 14-Aug-1979
$ ! 1-015 - Compile from MSRC$:.  SBL 24-Aug-1979
$ ! 1-016 - Add BASMSG again.  It is build in RTLUPD.COM.  SBL 14-Sept-1979
$ ! 1-017 - Add PASFCB.  SBL 30-Jul-81
$ ! 1-018 - Add LIBDCFDEF.  SBL 29-Aug-1981
$ ! 1-019 - Add LIBCLIDEF.  SBL 14-Sep-1981
$ ! 1-020 - Remove LIBDCFDEF and LIBCLIDEF since they are created in the
$ !	    UPDATE phase.   SBL 10-Nov-1981
$ ! 1-021 - Remove PASFCB.  SBL 21-Dec-1981
$ !
$ !--
$ !
$ DELETE LIB$:FORERR.B32.*,FORERR.MAR.*
$ DELETE LIB$:OTSISB.B32.*,OTSISB.MAR.*
$ DELETE LIB$:OTSLUB.B32.*,OTSLUB.MAR.*
$ DELETE LIB$:FORPAR.B32.*,FORPAR.MAR.*
$ DELETE LIB$:MTHERR.B32.*,MTHERR.MAR.*
$ DELETE LIB$:BASPAR.MAR.*,BASPAR.B32.*
$ DELETE LIB$:INTPAR.B32.*,INTPAR.MAR.*
$ MCR MDL LIB$:BASPAR=SRC$:BASPAR
$ MCR MDL LIB$:INTPAR=SRC$:INTPAR
$ MCR MDL LIB$:FORERR=SRC$:FORERR
$ MCR MDL LIB$:OTSISB=SRC$:OTSISB
$ MCR MDL LIB$:OTSLUB=SRC$:OTSLUB
$ MCR MDL LIB$:FORPAR=SRC$:FORPAR
$ MCR MDL LIB$:MTHERR=SRC$:MTHERR
$ !
$ !	[ End of file MDLRTL ]
