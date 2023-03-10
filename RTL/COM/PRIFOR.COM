$ ! COM$:PRIFOR.COM - Print FORTRAN support (FOR$) library
$ !
$ ! 1-001 - Original.  SBL 30-Nov-78
$ ! 1-002 - Remove FORCB.  JBS 29-DEC-78
$ ! 1-003 - Restore FORCB.  JBS 09-JAN-1979
$ ! 1-004 - Remove FORCNVIR.  SBL 23-Jan-79
$ ! 1-005 - Remove FORCNVII, FORCNVOI.  SBL 26-Mar-79
$ ! 1-006 - Add FORLEX.  SBL 3-Apr-79
$ ! 1-007 - Add FOROPNKEY, FORDELETE.   SBL 14-May-1979
$ ! 1-008 - Add FORUNLOCK.  SBL 17-May-1979
$ ! 1-009 - Add FORDSPAT and FORENTRYO.  JBS 26-JUN-1979
$ ! 1-010 - Add FORCVTRT.  SBL 5-Jul-1979
$ ! 1-011 - Add the 28 UPI entry points.  JBS 09-JUL-1979
$ ! 1-012 - Correct a typo in edit 010.  JBS 05-AUG-1979
$ ! 1-013 - Add FOREXITHA.  JBS 20-AUG-1979
$ ! 1-014 - Add FOROPENDE.  SBL 8-Oct-1979
$ ! 1-015 - Add FORREADSN, FORWRITSN.  SBL 27-August-1980
$ ! 1-016 - Add FORNMLTAB, FORUDFRN, FORUDFWN.  SBL 11-Nov-1980
$ ! 1-017 - Add FORBITOPS.  JAW 06-Jun-1981
$ ! 1-018 - Add FORINIUND and FORUNDERF.  JAW 29-Aug-1981
$ !
$ !--
$ PRINT/FLAG_PAGE/NAME=FOR$ -
LIS$:FORASSOC, -
FORBACKSP, -
FORBITOPS, -
FORCB, -
FORCLOSE, -
FORCVTRT, -
FORDATE, -
FORDATEDS, -
FORDECOMF, -
FORDECOMO, -
FORENCOMF, -
FORENCOMO, -
FOREXITHA, -
FORDEFINE, -
FORDELETE, -
FORDISPAT, -
FORENDFIL, -
FORENODEF, -
FORERROR, -
FORERRSNS, -
FOREXIT, -
FORFIND, -
FORFMTCP, -
FORFMTINT
$ PRINT/FLAG_PAGE/NAME=FOR$ -
LIS$:FORIDATE, -
FORINIDES, -
FORINIUND, -
FORIOBEG, -
FORIOELEM, -
FORIOEND, -
FORJDATE, -
FORLEX, -
FORMSGDEF, -
FORNMLTAB, -
FOROPEN, -
FOROPENDE, -
FOROPNKEY, -
FORPAUSE, -
FORRANDOM, -
FORREADDF, -
FORREADDU, -
FORREADIF, -
FORREADIO, -
FORREADKF, -
FORREADKO, -
FORREADKU, -
FORREADSF, -
FORREADSL, -
FORREADSN, -
FORREADSO, -
FORREADSU, -
FORRECPRO, -
FORREWIND, -
FORREWRSF, -
FORREWRSO, -
FORREWRSU, -
FORSECNDS, -
FORSIGNAL, -
FORSTOP, -
FORTIME, -
FORTIMEDS, -
FORUDFRF, -
FORUDFRL, -
FORUDFRN, -
FORUDFRU, -
FORUDFWF, -
FORUDFWL, -
FORUDFWN
$ PRINT/FLAG_PAGE/NAME=FOR$ -
LIS$:FORUDFWU, -
FORUNDERF, -
FORUNLOCK, -
FORVM, -
FORWRITDF, -
FORWRITDO, -
FORWRITDU, -
FORWRITIF, -
FORWRITIO, -
FORWRITSF, -
FORWRITSL, -
FORWRITSN, -
FORWRITSO, -
FORWRITSU
$ !
$ !	[ End of file PRIFOR.COM ]
