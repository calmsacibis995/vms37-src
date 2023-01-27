$ ! PRIREQ.COM - Print require files and ALLGBL
$ ! NOTE: Also add entries to RTLBLD.COM to make concatenated listing.
$ ! 0-1	- Print on LPA0.  TNH 1-May-78
$ ! 0-2	- Use device SRC$:.  TNH 1-May-78
$ ! 0-3	- Add FLUB.  tnh 02-MAY-78
$ ! 0-4	- add ALLGBL and FLNK.  TNH 19-June-78
$ ! 0-5	- add FORDEF.FOR, MTHDEF.FOR, LIBDEF.FOR, SIGDEF.FOR
$ ! 0-6 - Add P.MAR, remove ALLGBL.LIS.  TNH 29-July-78
$ ! 0-7 - Print results of MDL from LIB$:.  TNH 1-Sep-78
$ ! 1-8 - Change file names to conform to RTL standard  JBS 14-NOV-78
$ ! 1-9 - Put "headers" on the files to make them easier to find
$ !	   in the binder.  JBS 14-NOV-78
$ ! 1-010 - Make all one print command.  SBL 30-Nov-78
$ ! 1-011 - Change OTSPARAMS.MAR to MTHJACKET.MAR.  JBS 06-DEC-78
$ ! 1-012 - Divide RTLMSG up into OTSMSG, LIBMSG, FORMSG and MTHMSG.
$ !	     JBS 11-DEC-78
$ ! 1-013 - Change FORMAC to OTSMAC.  JBS 11-DEC-78
$ ! 1-014 - Change FORLUB and FORISB to OTSLUB and OTSISB.  JBS 21-DEC-78
$ ! 1-015 - Change FORLNK to OTSLNK.  JBS 21-DEC-78
$ ! 1-016 - Put in alphabetical order.  JBS 21-DEC-78
$ ! 1-017 - Delete LIBMAC.REQ.  JBS 02-JAN-1979
$ ! 1-018 - Add OTSCCB.  JBS 09-JAN-1979
$ ! 1-019 - Correct a minor typo which turned this whole command file
$ !	     into a no-operation.  JBS 11-JAN-1979
$ ! 1-020 - Add STRLNK.REQ and STRMACROS.REQ.  RW 27-FEB-79
$ ! 1-021 - Remove UTLDEF.  JBS 25-JUN-1979
$ ! 1-022 - Change OTSCCB.REQ to OTSCCBREQ.REQ.  JBS 05-AUG-1979
$ ! 1-023 - Add STRMSG.  RW  21-SEPT-79
$ !
$ !--
$ !
$ PRINT/HEADER/FLAG_PAGE/NAME=REQ -
SRC$:COMEST.REQ, -
SRC$:FORDEF.FOR, -
LIB$:FORERR.B32, LIB$:FORERR.MAR, SRC$:FORERR.MDL, -
SRC$:FORFMT.REQ, -
LIB$:FORMSG.B32, LIB$:FORMSG.MAR, SRC$:FORMSG.MDL, -
SRC$:FOROPN.REQ, -
LIB$:FORPAR.B32, LIB$:FORPAR.MAR, SRC$:FORPAR.MDL, -
SRC$:LIBDEF.FOR
$ PRINT/HEADER/FLAG_PAGE/NAME=REQ -
LIB$:LIBMSG.B32, LIB$:LIBMSG.MAR, SRC$:LIBMSG.MDL, -
SRC$:MTHDEF.FOR, -
LIB$:MTHERR.B32, LIB$:MTHERR.MAR, SRC$:MTHERR.MDL, -
SRC$:MTHJACKET.MAR, -
LIB$:MTHMSG.B32, LIB$:MTHMSG.MAR, SRC$:MTHMSG.MDL, -
SRC$:OTSCCBREQ.REQ, -
LIB$:OTSISB.B32, LIB$:OTSISB.MAR, SRC$:OTSISB.MDL, -
SRC$:OTSLNK.REQ, -
LIB$:OTSLUB.B32, LIB$:OTSLUB.MAR, SRC$:OTSLUB.MDL, -
SRC$:OTSMAC.REQ, -
LIB$:OTSMSG.B32, LIB$:OTSMSG.MAR, SRC$:OTSMSG.MDL, -
SRC$:RTLODBG.REQ, -
SRC$:RTLPSECT.REQ, -
SRC$:SIGDEF.FOR, -
SRC$:STRLNK.REQ, -
SRC$:STRMACROS.REQ, -
LIB$:STRMSG.B32, LIB$:STRMSG.MAR, SRC$:STRMSG.MDL
$ !
$ !	[End of PRIREQ.COM]
