$ ! Command file to produce a cross reference listing of all of the
$ ! BLISS sources for the Run-time library.
$ !
$ ! Edit History:
$ !
$ ! 1-001  Initial creation.  JBS 27-NOV-78
$ ! 1-002  Use OBJ$: for temporary storage.  JBS 27-NOV-78
$ ! 1-003  Add BASRESTOR.B32.  JBS 28-NOV-78
$ ! 1-004  Add BASIC I/O modules.  JBS 29-NOV-78
$ ! 1-005 - Add BASCCPOS.  DGP 03-Dec-78
$ ! 1-006 - Add BASOPENDE. JBS 05-DEC-78
$ ! 1-007 - Add OTSDISTAB.  DGP 07-Dec-78
$ ! 1-008 - Add BASSIGNAL.  JBS 08-DEC-78
$ ! 1-009 - Put the individual cross reference files on LIS$, and do
$ !	   not delete them.  JBS 08-DEC-78
$ ! 1-010 - Add BASUDFRM.  DGP 20-Dec-78
$ ! 1-011 - Delete FORCB and add OTSCB.  JBS 29-DEC-78
$ ! 1-012 - Add BASCB and FORCB, and change OTSCB to OTSCCB.  JBS 09-JAN-1979
$ ! 1-013 - Add OTSPURIOB.  DGP 22-Jan-79
$ ! 1-014 - Add OTSCLOSEF and OTSEXITHA.  JBS 23-JAN-1979
$ ! 1-015 - Change OTSDISTAB to OTSDISPAT.  JBS 27-JAN-1979
$ ! 1-016 - Add BASVIRTUA.  JBS 03-FEB-1979
$ ! 1-017 - Add BASINIIOL.  JBS 08-FEB-1979
$ ! 1-018 - Add LIBDATETI.  JBS 19-FEB-1979
$ ! 1-019 - Add BASCLOSE.  JBS 19-FEB-1979
$ ! 1-020 - Add BASCTRLC.  JBS 19-FEB-1979
$ ! 1-021 - Add BASDATETI.  JBS 20-FEB-1979
$ ! 1-022 - Add BASGET and BASPUT.  DGP 20-Feb-79
$ ! 1-023 - Add BASCHANGE.  JBS 22-FEB-1979
$ ! 1-024 - Add BASRSTSCV.  JBS 26-FEB-1979
$ ! 1-025 - Add some BASIC string support.  RW 27-FEB-79
$ ! 1-026 - Add BASRSTSFI.  JBS 28-FEB-1979
$ ! 1-027 - Add BASDELETE, BASFIND, BASSCRATC, BASUPDATE.  DGP 28-Feb-79
$ ! 1-028 - Add BASNAMEAS.  JBS 01-MAR-1979
$ ! 1-029 - Add BASKILL.  JBS 01-MAR-1979
$ ! 1-030 - Add BASCMPAPP.  JBS 01-MAR-1979
$ ! 1-031 - Add BASFREE, BASUNLOCK.  DGP 02-Mar-79
$ ! 1-032 - Add String Arithmetic.  JBS 06-MAR-1979
$ ! 1-033 - Add STRALLOC.  JBS 13-MAR-1979
$ ! 1-034 - Add LIBSCOPY, OTSSCOPY, STRGETFRE.  JBS 15-MAR-1979
$ ! 1-035 - Change BASCONCAT to STRCONCAT.  JBS 19-MAR-1979
$ ! 1-036 - Add LIBCHAR and LIBARGCNT.  JBS 20-MAR-1979
$ ! 1-037 - Add remaining BL2 string functions and STR$.  RW  22-MAR-79
$ ! 1-038 - Add STRVM.  JBS 02-APR-1979
$ ! 1-039 - Add BASVIRTIO.  JBS 05-APR-1979
$ ! 1-040 - Add OTSTERMIO.  JBS 06-APR-1979
$ ! 1-041 - Add LIBTIMER.  JBS for SBL  09-APR-1979
$ ! 1-042 - Add BASWAIT.  JBS 10-APR-1979
$ ! 1-043 - Add BASBUFSIZ.  JBS 11-APR-1979
$ ! 1-044 - Add BASCOMPAR, BASRSET, BASSTRING.  RW  14-APR-79
$ ! 1-045 - Correct a typo in edit 040.  JBS 16-APR-1979
$ ! 1-046 - Add BASOPENZE.  JBS 17-APR-1979
$ ! 1-047 - Add BASECHO.  JBS 17-APR-1979
$ ! 1-048 - Add BASONECHR.  JBS 17-APR-1979
$ ! 1-049 - Add BASFSP.  JBS 19-APR-1979
$ ! 1-050 - Add BASCTRLO and BASSLEEP.  JBS 19-APR-1979
$ ! 1-051 - Add BASMAGTAP.  JBS 20-APR-1979
$ ! 1-052 - Add FOROPNKEY.  SBL 26-APR-1979
$ ! 1-053 - Add BASTAB.  JBS 01-MAY-1979
$ ! 1-054 - Add BASRAD50.  JBS 01-MAY-1979
$ ! 1-055 - Add BASCANTYP.  JBS 01-MAY-1979
$ ! 1-056 - Add BASRESTAR.  JBS 07-MAY-1979
$ ! 1-057 - Add BASSCALE.  JBS 08-MAY-1979
$ ! 1-058 - Add BASMARGIN.  JBS 08-MAY-1979
$ ! 1-059 - Add BASSTOP.  JBS 10-MAY-1979
$ ! 1-060 - Remove searching of REQUIRE files.  JBS 14-MAY-1979
$ ! 1-061 - Add BASUDFWF.  DGP 16-May-79
$ ! 1-062 - Add BASMOVE.  JBS 21-MAY-1979
$ ! 1-063 - Rename BASCHAR to BASCHR.  RW 21-MAY-79
$ ! 1-064 - Add BASFORINT.  DGP 21-MAY-79
$ ! 1-065 - Rename BASCHAR to BASCHR 2nd ref.  RW 22-MAY-79
$ ! 1-066 - Add BASFORTAB. DGP 25-May-79
$ ! 1-067 - Add BASRUNINI.  JBS 04-JUN-1979
$ ! 1-068 - Add BASUNWIND.  JBS 06-JUN-1979
$ ! 1-069 - Add FORDELETE, FORUNLOCK, LIBGETFOR.  SBL 18-Jun-1979
$ ! 1-070 - Add BASDISPAT and FORDISPAT, delete OTSDISPAT.
$ !	     JBS 26-JUN-1979
$ ! 1-071 - Use MSRC$ instead of SRC$.  SBL 6-Jul-1979
$ ! 1-072 - Add FORREADDU and FORWRITDU.  JBS 09-JUL-1979
$ ! 1-073 - Add BASCVTOUT.  DGP 10-Jul-79
$ ! 1-074 - Correct an error in edit 072.  JBS 14-JUL-1979
$ ! 1-075 - Add BASFORMAT.  RW 16-JUL-79
$ ! 1-076 - Add FORINQUIR.  SBL 14-Aug-1979
$ ! 1-077 - Add BASEXITHA, BASHANDLE, BASPURIOB, FOREXITHA and OTSCCBDAT,
$ !	     and delete OTSPURIOB and OTSEXITHA.  JBS 20-AUG-1979
$ ! 1-078 - Add BASMSGDEF.  JBS 21-AUG-1979
$ ! 1-079 - Remove BASHANDLE, it was rewritten in MACRO.  JBS 21-AUG-1979
$ ! 1-080 - Add BASMOVEAR.  JBS 31-AUG-1979
$ ! 1-081 - Add BASNOTIMP.  JBS 04-SEP-1979
$ ! 1-082 - Remove STRVM.  JBS 11-SEP-1979
$ ! 1-083 - Add BASMATIO and BASTERMIO.  DGP 11-Sep-79
$ ! 1-084 - Correct some typos in edit 083.  JBS 12-SEP-1979
$ ! 1-085 - Add LIBGETLPL.  SBL 13-Sept-1979
$ ! 1-086 - Change LIBGETLPL to LIBLPLINE  SBL 17-Sept-1979
$ ! 1-087 - Incorporated BLISS components of COBOL RTL as of 9/17/79
$ !	    RKR 17-SEPT-79
$ ! 1-088 - Add COBRESTVA, remove COBEXINIT and SYSRESTVA.
$ !	    RKR  28-SEPT-79
$ ! 1-089 - Add BASSYS.  JBS 01-OCT-1979
$ ! 1-090 - Add the BPA stuff from ESE for BASIC SYS.  JBS 02-OCT-1979
$ ! 1-091 - Correct some errors in edit 090.  JBS 03-OCT-1979
$ ! 1-092 - Increase the length of the match string for new BLSCRF.
$ !	     JBS 04-OCT-1979
$ ! 1-093 - Add FOROPENDE.  SBL 8-Oct-1979
$ ! 1-094 - Add BASCONCAT.  JBS 18-OCT-1979
$ ! 1-095 - Add LIBASCTIM, LIBFAO,LIBFAOL, LIBGETMSG and LIBTRNLOG.
$ !	    RKR  18-OCT-79
$ ! 1-096 - Add LIBCURREN, LIBDIGITS and LIBRADIXP, and fix a typo in
$ !	     edit 094.  JBS 19-OCT-1979
$ ! 1-097 - Add LIBSTATVM.  JBS 28-OCT-1979
$ ! 1-098 - Add STRSRCHIN.  JBS 29-OCT-1979
$ ! 1-099 - Add COBSETSWI.  RKR 30-OCT-1979
$ ! 1-100 - Add STRUNWDEQ.  JBS 30-OCT-1979
$ ! 1-101 - Add STRLEFT STRLENEXT STRPOSEXT STRPOSIT STRRIGHT
$ !		RW  1-NOV-79
$ ! 1-102 - Add STRTRIM STRDUPLCH, remove BASCOMPAR.  RW  7-Nov-79
$ ! 1-103 - Add BASCHAIN, LIBDOCOM and LIBRUNPRO.  JBS 26-NOV-1979
$ ! 1-104 - Add LIBCOMMON and BPASETPRI.  JBS 02-DEC-1979
$ ! 1-105 - Add BPAFSS.  JBS 03-DEC-1979
$ ! 1-106 - Add STRAPPEND, COMEQL, COMPAR, PREFIX, REPLAC, TRANSL, UPCASE
$ !		RW  3-DEC-79
$ ! 1-107 - Remove FORREADDU and FORWRITDU.  SBL 5-Dec-1979
$ ! 1-108 - Add LIBASNMBX.  SBL 6-Dec-1979
$ ! 1-109 - Delete LIBARGCNT.  SBL 22-Jan-1980
$ ! 1-110 - Add LIBSTRRET handler.  RW  22-Jan-1980
$ ! 1-111 - Add LIBFILSCA.	RKR 10-FEB-1981
$ ! 1-112 - Add LIBANASTR and STRCHESTA.  RKR 02-JUL-1981
$ ! 1-113 - Add COBDBEXCE.  LEB 29-JUL-1981
$ ! 1-114 - Remove OTSSCOPY.  It's now a .MAR   RKR 14-AUG-1981
$ ! 1-115 - Remove BASFORTAB.  DJB 24-Aug-1981
$ ! 1-116 - Add LIBCVTDX., LIBCVTMAC., LIBFINCVT.
$ ! 1-117 - Add FORINIUND and FORUNDERF.  JAW 29-Aug-1981
$ ! 1-118 - Add STRANASTR.  RKR 22-OCT-1981
$ ! 1-119 - Remove LIBANASTR and STRANASTR.  They're now .MARs.
$ !	    RKR 23-NOV-1981.
$ !--
$ !
$ !
$ DELETE OBJ$:*.MRG.*
$ DELETE OBJ$:*.XRF.*
$ DELETE LIS$:*.XRF.*
$ DELETE LIS$:CREFRTL.LIS.*
$ RUN SYS$SYSTEM:BLSCRF
MSRC$:BASBUFSIZ.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASBUFSIZ.MRG/OUTPUT:LIS$:BASBUFSIZ.XRF
MSRC$:BASCANTYP.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASCANTYP.MRG/OUTPUT:LIS$:BASCANTYP.XRF
MSRC$:BASCB.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASCB.MRG/OUTPUT:LIS$:BASCB.XRF
MSRC$:BASCCPOS.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASCCPOS.MRG/OUTPUT:LIS$:BASCCPOS.XRF
MSRC$:BASCHAIN.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASCHAIN.MRG/OUTPUT:LIS$:BASCHAIN.XRF
MSRC$:BASCHANGE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASCHANGE.MRG/OUTPUT:LIS$:BASCHANGE.XRF
MSRC$:BASCHR.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASCHR.MRG/OUTPUT:LIS$:BASCHR.XRF
MSRC$:BASCLOSE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASCLOSE.MRG/OUTPUT:LIS$:BASCLOSE.XRF
MSRC$:BASCMPAPP.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASCMPAPP.MRG/OUTPUT:LIS$:BASCMPAPP.XRF
MSRC$:BASCONCAT.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASCONCAT.MRG/OUTPUT:LIS$:BASCONCAT.XRF
MSRC$:BASCTRLC.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASCTRLC.MRG/OUTPUT:LIS$:BASCTRLC.XRF
MSRC$:BASCTRLO.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASCTRLO.MRG/OUTPUT:LIS$:BASCTRLO.XRF
MSRC$:BASCVTOUT.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASCVTOUT.MRG/OUTPUT:LIS$:BASCVTOUT.XRF
MSRC$:BASDATETI.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASDATETI.MRG/OUTPUT:LIS$:BASDATETI.XRF
MSRC$:BASDELETE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASDELETE.MRG/OUTPUT:LIS$:BASDELETE.XRF
MSRC$:BASDISPAT.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASDISPAT.MRG/OUTPUT:LIS$:BASDISPAT.XRF
MSRC$:BASECHO.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASECHO.MRG/OUTPUT:LIS$:BASECHO.XRF
MSRC$:BASEND.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASEND.MRG/OUTPUT:LIS$:BASEND.XRF
MSRC$:BASENDDEF.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASENDDEF.MRG/OUTPUT:LIS$:BASENDDEF.XRF
MSRC$:BASENDDFS.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASENDDFS.MRG/OUTPUT:LIS$:BASENDDFS.XRF
MSRC$:BASENDGSB.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASENDGSB.MRG/OUTPUT:LIS$:BASENDGSB.XRF
MSRC$:BASERROR.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASERROR.MRG/OUTPUT:LIS$:BASERROR.XRF
MSRC$:BASEXITHA.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASEXITHA.MRG/OUTPUT:LIS$:BASEXITHA.XRF
MSRC$:BASFIND.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASFIND.MRG/OUTPUT:LIS$:BASFIND.XRF
MSRC$:BASFOR?NT.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASFORINT.MRG/OUTPUT:LIS$:BASFORINT.XRF
MSRC$:BASFORMAT.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASFORMAT.MRG/OUTPUT:LIS$:BASFORMAT.XRF
MSRC$:BASFREE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASFREE.MRG/OUTPUT:LIS$:BASFREE.XRF
MSRC$:BASFSP.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASFSP.MRG/OUTPUT:LIS$:BASFSP.XRF
MSRC$:BASGET.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASGET.MRG/OUTPUT:LIS$:BASGET.XRF
MSRC$:BASINIDEF.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASINIDEF.MRG/OUTPUT:LIS$:BASINIDEF.XRF
MSRC$:BASINIDFS.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASINIDFS.MRG/OUTPUT:LIS$:BASINIDFS.XRF
MSRC$:BASINIGSB.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASINIGSB.MRG/OUTPUT:LIS$:BASINIGSB.XRF
MSRC$:BASINIGSC.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASINIGSC.MRG/OUTPUT:LIS$:BASINIGSC.XRF
MSRC$:BASINIIOL.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASINIIOL.MRG/OUTPUT:LIS$:BASINIIOL.XRF
MSRC$:BASINIONE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASINIONE.MRG/OUTPUT:LIS$:BASINIONE.XRF
MSRC$:BASINIT.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASINIT.MRG/OUTPUT:LIS$:BASINIT.XRF
MSRC$:BASINSTR.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASINSTR.MRG/OUTPUT:LIS$:BASINSTR.XRF
MSRC$:BASIOBEG.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASIOBEG.MRG/OUTPUT:LIS$:BASIOBEG.XRF
MSRC$:BASIOEND.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASIOEND.MRG/OUTPUT:LIS$:BASIOEND.XRF
MSRC$:BASKILL.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASKILL.MRG/OUTPUT:LIS$:BASKILL.XRF
MSRC$:BASLEFT.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASLEFT.MRG/OUTPUT:LIS$:BASLEFT.XRF
MSRC$:BASMAGTAP.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASMAGTAP.MRG/OUTPUT:LIS$:BASMAGTAP.XRF
MSRC$:BASMARGIN.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASMARGIN.MRG/OUTPUT:LIS$:BASMARGIN.XRF
MSRC$:BASMATIO.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASMATIO.MRG/OUTPUT:LIS$:BASMATIO.XRF
MSRC$:BASMID.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASMID.MRG/OUTPUT:LIS$:BASMID.XRF
MSRC$:BASMOVE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASMOVE.MRG/OUTPUT:LIS$:BASMOVE.XRF
MSRC$:BASMOVEAR.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASMOVEAR.MRG/OUTPUT:LIS$:BASMOVEAR.XRF
MSRC$:BASMSGDEF.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASMSGDEF.MRG/OUTPUT:LIS$:BASMSGDEF.XRF
MSRC$:BASNAMEAS.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASNAMEAS.MRG/OUTPUT:LIS$:BASNAMEAS.XRF
MSRC$:BASNOTIMP.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASNOTIMP.MRG/OUTPUT:LIS$:BASNOTIMP.XRF
MSRC$:BASNUM.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASNUM.MRG/OUTPUT:LIS$:BASNUM.XRF
MSRC$:BASNUM1.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASNUM1.MRG/OUTPUT:LIS$:BASNUM1.XRF
MSRC$:BASONECHR.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASONECHR.MRG/OUTPUT:LIS$:BASONECHR.XRF
MSRC$:BASOPEN.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASOPEN.MRG/OUTPUT:LIS$:BASOPEN.XRF
MSRC$:BASOPENDE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASOPENDE.MRG/OUTPUT:LIS$:BASOPENDE.XRF
MSRC$:BASOPENZE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASOPENZE.MRG/OUTPUT:LIS$:BASOPENZE.XRF
MSRC$:BASPURIOB.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASPURIOB.MRG/OUTPUT:LIS$:BASPURIOB.XRF
MSRC$:BASPOS.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASPOS.MRG/OUTPUT:LIS$:BASPOS.XRF
MSRC$:BASPUT.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASPUT.MRG/OUTPUT:LIS$:BASPUT.XRF
MSRC$:BASRAD50.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASRAD50.MRG/OUTPUT:LIS$:BASRAD50.XRF
MSRC$:BASRECPRO.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASRECPRO.MRG/OUTPUT:LIS$:BASRECPRO.XRF
MSRC$:BASRESTAR.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASRESTAR.MRG/OUTPUT:LIS$:BASRESTAR.XRF
MSRC$:BASRESTOR.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASRESTOR.MRG/OUTPUT:LIS$:BASRESTOR.XRF
MSRC$:BASRIGHT.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASRIGHT.MRG/OUTPUT:LIS$:BASRIGHT.XRF
MSRC$:BASRSET.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASRSET.MRG/OUTPUT:LIS$:BASRSET.XRF
MSRC$:BASRSTSCV.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASRSTSCV.MRG/OUTPUT:LIS$:BASRSTSCV.XRF
MSRC$:BASRSTSFI.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASRSTSFI.MRG/OUTPUT:LIS$:BASRSTSFI.XRF
MSRC$:BASRUNINI.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASRUNINI.MRG/OUTPUT:LIS$:BASRUNINI.XRF
MSRC$:BASSARITH.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASSARITH.MRG/OUTPUT:LIS$:BASSARITH.XRF
MSRC$:BASSCALE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASSCALE.MRG/OUTPUT:LIS$:BASSCALE.XRF
MSRC$:BASSCRATC.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASSCRATC.MRG/OUTPUT:LIS$:BASSCRATC.XRF
MSRC$:BASSEG.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASSEG.MRG/OUTPUT:LIS$:BASSEG.XRF
MSRC$:BASSIGNAL.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASSIGNAL.MRG/OUTPUT:LIS$:BASSIGNAL.XRF
MSRC$:BASSLEEP.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASSLEEP.MRG/OUTPUT:LIS$:BASSLEEP.XRF
MSRC$:BASSTOP.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASSTOP.MRG/OUTPUT:LIS$:BASSTOP.XRF
MSRC$:BASSTR.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASSTR.MRG/OUTPUT:LIS$:BASSTR.XRF
MSRC$:BASSTRING.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASSTRING.MRG/OUTPUT:LIS$:BASSTRING.XRF
MSRC$:BASTAB.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASTAB.MRG/OUTPUT:LIS$:BASTAB.XRF
MSRC$:BASSYS.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASSYS.MRG/OUTPUT:LIS$:BASSYS.XRF
MSRC$:BASTERMIO.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASTERMIO.MRG/OUTPUT:LIS$:BASTERMIO.XRF
MSRC$:BASUDFRL.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASUDFRL.MRG/OUTPUT:LIS$:BASUDFRL.XRF
MSRC$:BASUDFRM.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASUDFRM.MRG/OUTPUT:LIS$:BASUDFRM.XRF
MSRC$:BASUDFWF.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASUDFWF.MRG/OUTPUT:LIS$:BASUDFWF.XRF
MSRC$:BASUDFWL.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASUDFWL.MRG/OUTPUT:LIS$:BASUDFWL.XRF
MSRC$:BASUNLOCK.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASUNLOCK.MRG/OUTPUT:LIS$:BASUNLOCK.XRF
MSRC$:BASUNWIND.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASUNWIND.MRG/OUTPUT:LIS$:BASUNWIND.XRF
MSRC$:BASUPDATE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASUPDATE.MRG/OUTPUT:LIS$:BASUPDATE.XRF
MSRC$:BASVAL.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASVAL.MRG/OUTPUT:LIS$:BASVAL.XRF
MSRC$:BASVIRTIO.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASVIRTIO.MRG/OUTPUT:LIS$:BASVIRTIO.XRF
MSRC$:BASVIRTUA.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASVIRTUA.MRG/OUTPUT:LIS$:BASVIRTUA.XRF
MSRC$:BASWAIT.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BASWAIT.MRG/OUTPUT:LIS$:BASWAIT.XRF
MSRC$:BPAFSS.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BPAFSS.MRG/OUTPUT:LIS$:BPAFSS.XRF
MSRC$:BPAGETBLK.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BPAGETBLK.MRG/OUTPUT:LIS$:BPAGETBLK.XRF
MSRC$:BPAMESAG.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BPAMESAG.MRG/OUTPUT:LIS$:BPAMESAG.XRF
MSRC$:BPASETPRI.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BPASETPRI.MRG/OUTPUT:LIS$:BPASETPRI.XRF
MSRC$:BPASSDEAS.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BPASSDEAS.MRG/OUTPUT:LIS$:BPASSDEAS.XRF
MSRC$:BPAWAKEUP.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:BPAWAKEUP.MRG/OUTPUT:LIS$:BPAWAKEUP.XRF
MSRC$:COBACCDAT.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COBACCDAT.MRG/OUTPUT:LIS$:COBACCDAT.XRF
MSRC$:COBACCDAY.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COBACCDAY.MRG/OUTPUT:LIS$:COBACCDAY.XRF
MSRC$:COBACCDWK.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COBACCDWK.MRG/OUTPUT:LIS$:COBACCDWK.XRF
MSRC$:COBACCEPT.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COBACCEPT.MRG/OUTPUT:LIS$:COBACCEPT.XRF
MSRC$:COBACCTIM.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COBACCTIM.MRG/OUTPUT:LIS$:COBACCTIM.XRF
MSRC$:COBCALL.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COBCALL.MRG/OUTPUT:LIS$:COBCALL.XRF
MSRC$:COBCANCEL.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COBCANCEL.MRG/OUTPUT:LIS$:COBCANCEL.XRF
MSRC$:COBDBEXCE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COBDBEXCE.MRG/OUTPUT:LIS$:COBDBEXCE.XRF
MSRC$:COBDISPLA.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COBDISPLA.MRG/OUTPUT:LIS$:COBDISPLA.XRF
MSRC$:COBERROR.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COBERROR.MRG/OUTPUT:LIS$:COBERROR.XRF
MSRC$:COBFINDNA.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COBFINDNA.MRG/OUTPUT:LIS$:COBFINDNA.XRF
MSRC$:COBHANDLE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COBHANDLE.MRG/OUTPUT:LIS$:COBHANDLE.XRF
MSRC$:COBIOEXCE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COBIOEXCE.MRG/OUTPUT:LIS$:COBIOEXCE.XRF
MSRC$:COBLINAGE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COBLINAGE.MRG/OUTPUT:LIS$:COBLINAGE.XRF
MSRC$:COBPAUSE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COBPAUSE.MRG/OUTPUT:LIS$:COBPAUSE.XRF
MSRC$:COBRESTVA.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COBRESTVA.MRG/OUTPUT:LIS$:COBRESTVA.XRF
MSRC$:COBRMSBLO.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COBRMSBLO.MRG/OUTPUT:LIS$:COBRMSBLO.XRF
MSRC$:COBSETSWI.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COBSETSWI.MRG/OUTPUT:LIS$:COBSETSWI.XRF
MSRC$:COBSWITCH.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COBSWITCH.MRG/OUTPUT:LIS$:COBSWITCH.XRF
MSRC$:COMASSIGN.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COMASSIGN.MRG/OUTPUT:LIS$:COMASSIGN.XRF
MSRC$:COMCLOSE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COMCLOSE.MRG/OUTPUT:LIS$:COMCLOSE.XRF
MSRC$:COMERRSET.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COMERRSET.MRG/OUTPUT:LIS$:COMERRSET.XRF
MSRC$:COMERRTST.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COMERRTST.MRG/OUTPUT:LIS$:COMERRTST.XRF
MSRC$:COMFDBSET.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COMFDBSET.MRG/OUTPUT:LIS$:COMFDBSET.XRF
MSRC$:COMSETST.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:COMSETST.MRG/OUTPUT:LIS$:COMSETST.XRF
MSRC$:FORASSOC.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORASSOC.MRG/OUTPUT:LIS$:FORASSOC.XRF
MSRC$:FORBACKSP.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORBACKSP.MRG/OUTPUT:LIS$:FORBACKSP.XRF
MSRC$:FORCB.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORCB.MRG/OUTPUT:LIS$:FORCB.XRF
MSRC$:FORCLOSE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORCLOSE.MRG/OUTPUT:LIS$:FORCLOSE.XRF
MSRC$:FORDEFINE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORDEFINE.MRG/OUTPUT:LIS$:FORDEFINE.XRF
MSRC$:FORDELETE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORDELETE.MRG/OUTPUT:LIS$:FORDELETE.XRF
MSRC$:FORDISPAT.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORDISPAT.MRG/OUTPUT:LIS$:FORDISPAT.XRF
MSRC$:FORENDFIL.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORENDFIL.MRG/OUTPUT:LIS$:FORENDFIL.XRF
MSRC$:FORERROR.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORERROR.MRG/OUTPUT:LIS$:FORERROR.XRF
MSRC$:FOREXITHA.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FOREXITHA.MRG/OUTPUT:LIS$:FOREXITHA.XRF
MSRC$:FORERRSNS.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORERRSNS.MRG/OUTPUT:LIS$:FORERRSNS.XRF
MSRC$:FORFIND.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORFIND.MRG/OUTPUT:LIS$:FORFIND.XRF
MSRC$:FORFMTCP.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORFMTCP.MRG/OUTPUT:LIS$:FORFMTCP.XRF
MSRC$:FORFMTINT.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORFMTINT.MRG/OUTPUT:LIS$:FORFMTINT.XRF
MSRC$:FORINIUND.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORINIUND.MRG/OUTPUT:LIS$:FORINIUND.XRF
MSRC$:FORINQUIR.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORINQUIR.MRG/OUTPUT:LIS$:FORINQUIR.XRF
MSRC$:FORIOBEG.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORIOBEG.MRG/OUTPUT:LIS$:FORIOBEG.XRF
MSRC$:FORIOEND.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORIOEND.MRG/OUTPUT:LIS$:FORIOEND.XRF
MSRC$:FOROPEN.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FOROPEN.MRG/OUTPUT:LIS$:FOROPEN.XRF
MSRC$:FOROPENDE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FOROPENDE.MRG/OUTPUT:LIS$:FOROPENDE.XRF
MSRC$:FOROPNKEY.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FOROPNKEY.MRG/OUTPUT:LIS$:FOROPNKEY.XRF
MSRC$:FORPAUSE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORPAUSE.MRG/OUTPUT:LIS$:FORPAUSE.XRF
MSRC$:FORRECPRO.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORRECPRO.MRG/OUTPUT:LIS$:FORRECPRO.XRF
MSRC$:FORREWIND.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORREWIND.MRG/OUTPUT:LIS$:FORREWIND.XRF
MSRC$:FORSIGNAL.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORSIGNAL.MRG/OUTPUT:LIS$:FORSIGNAL.XRF
MSRC$:FORSTOP.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORSTOP.MRG/OUTPUT:LIS$:FORSTOP.XRF
MSRC$:FORUDFRF.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORUDFRF.MRG/OUTPUT:LIS$:FORUDFRF.XRF
MSRC$:FORUDFRL.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORUDFRL.MRG/OUTPUT:LIS$:FORUDFRL.XRF
MSRC$:FORUDFRU.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORUDFRU.MRG/OUTPUT:LIS$:FORUDFRU.XRF
MSRC$:FORUDFWF.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORUDFWF.MRG/OUTPUT:LIS$:FORUDFWF.XRF
MSRC$:FORUDFWL.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORUDFWL.MRG/OUTPUT:LIS$:FORUDFWL.XRF
MSRC$:FORUDFWU.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORUDFWU.MRG/OUTPUT:LIS$:FORUDFWU.XRF
MSRC$:FORUNDERF.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORUNDERF.MRG/OUTPUT:LIS$:FORUNDERF.XRF
MSRC$:FORUNLOCK.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORUNLOCK.MRG/OUTPUT:LIS$:FORUNLOCK.XRF
MSRC$:FORVM.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:FORVM.MRG/OUTPUT:LIS$:FORVM.XRF
MSRC$:LIBASCTIM.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBASCTIM.MRG/OUTPUT:LIS$:LIBASCTIM.XRF
MSRC$:LIBASNMBX.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBASNMBX.MRG/OUTPUT:LIS$:LIBASNMBX.XRF
MSRC$:LIBCHAR.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBCHAR.MRG/OUTPUT:LIS$:LIBCHAR.XRF
MSRC$:LIBCOMMON.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBCOMMON.MRG/OUTPUT:LIS$:LIBCOMMON.XRF
MSRC$:LIBCRCTAB.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBCRCTAB.MRG/OUTPUT:LIS$:LIBCRCTAB.XRF
MSRC$:LIBCURREN.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBCURREN.MRG/OUTPUT:LIS$:LIBCURREN.XRF
MSRC$:LIBCVTDX.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBCVTDX.MRG/OUTPUT:LIS$:LIBCVTDX.XRF
MSRC$:LIBDATETI.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBDATETI.MRG/OUTPUT:LIS$:LIBDATETI.XRF
MSRC$:LIBDECOVE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBDECOVE.MRG/OUTPUT:LIS$:LIBDECOVE.XRF
MSRC$:LIBDIGITS.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBDIGITS.MRG/OUTPUT:LIS$:LIBDIGITS.XRF
MSRC$:LIBDOCOM.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBDOCOM.MRG/OUTPUT:LIS$:LIBDOCOM.XRF
MSRC$:LIBESTABL.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBESTABL.MRG/OUTPUT:LIS$:LIBESTABL.XRF
MSRC$:LIBFAO.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBFAO.MRG/OUTPUT:LIS$:LIBFAO.XRF
MSRC$:LIBFAOL.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBFAOL.MRG/OUTPUT:LIS$:LIBFAOL.XRF
MSRC$:LIBFILSCA.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBFILSCA.MRG/OUTPUT:LIS$:LIBFILSCA.XRF
MSRC$:LIBFINCVT.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBFINCVT.MRG/OUTPUT:LIS$:LIBFINCVT.XRF
MSRC$:LIBFLTUND.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBFLTUND.MRG/OUTPUT:LIS$:LIBFLTUND.XRF
MSRC$:LIBGETFOR.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBGETFOR.MRG/OUTPUT:LIS$:LIBGETFOR.XRF
MSRC$:LIBGETINP.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBGETINP.MRG/OUTPUT:LIS$:LIBGETINP.XRF
MSRC$:LIBGETMSG.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBGETMSG.MRG/OUTPUT:LIS$:LIBGETMSG.XRF
MSRC$:LIBINTOVE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBINTOVE.MRG/OUTPUT:LIS$:LIBINTOVE.XRF
MSRC$:LIBLOOKUP.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBLOOKUP.MRG/OUTPUT:LIS$:LIBLOOKUP.XRF
MSRC$:LIBLPLINE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBLPLINE.MRG/OUTPUT:LIS$:LIBLPLINE.XRF
MSRC$:LIBMATCH.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBMATCH.MRG/OUTPUT:LIS$:LIBMATCH.XRF
MSRC$:LIBPUTOUT.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBPUTOUT.MRG/OUTPUT:LIS$:LIBPUTOUT.XRF
MSRC$:LIBRADIXP.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBRADIXP.MRG/OUTPUT:LIS$:LIBRADIXP.XRF
MSRC$:LIBREVERT.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBREVERT.MRG/OUTPUT:LIS$:LIBREVERT.XRF
MSRC$:LIBRUNPRO.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBRUNPRO.MRG/OUTPUT:LIS$:LIBRUNPRO.XRF
MSRC$:LIBSCOPY.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBSCOPY.MRG/OUTPUT:LIS$:LIBSCOPY.XRF
MSRC$:LIBSIGRET.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBSIGRET.MRG/OUTPUT:LIS$:LIBSIGRET.XRF
MSRC$:LIBSTATVM.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBSTATVM.MRG/OUTPUT:LIS$:LIBSTATVM.XRF
MSRC$:LIBSTRRET.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBSTRRET.MRG/OUTPUT:LIS$:LIBSTRRET.XRF
MSRC$:LIBTIMER.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBTIMER.MRG/OUTPUT:LIS$:LIBTIMER.XRF
MSRC$:LIBTRNLOG.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBTRNLOG.MRG/OUTPUT:LIS$:LIBTRNLOG.XRF
MSRC$:LIBVM.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:LIBVM.MRG/OUTPUT:LIS$:LIBVM.XRF
MSRC$:OTSCCBDAT.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:OTSCCBDAT.MRG/OUTPUT:LIS$:OTSCCBDAT.XRF
MSRC$:OTSCCB.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:OTSCCB.MRG/OUTPUT:LIS$:OTSCCB.XRF
MSRC$:OTSCLOSEF.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:OTSCLOSEF.MRG/OUTPUT:LIS$:OTSCLOSEF.XRF
MSRC$:OTSTERMIO.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:OTSTERMIO.MRG/OUTPUT:LIS$:OTSTERMIO.XRF
MSRC$:STRALLOC.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:STRALLOC.MRG/OUTPUT:LIS$:STRALLOC.XRF
MSRC$:STRAPPEND.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:STRAPPEND.MRG/OUTPUT:LIS$:STRAPPEND.XRF
MSRC$:STRARITH.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:STRARITH.MRG/OUTPUT:LIS$:STRARITH.XRF
MSRC$:STRCHESTA.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:STRCHESTA.MRG/OUTPUT:LIS$:STRCHESTA.XRF
MSRC$:STRCOMEQL.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:STRCOMEQL.MRG/OUTPUT:LIS$:STRCOMEQL.XRF
MSRC$:STRCOMPAR.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:STRCOMPAR.MRG/OUTPUT:LIS$:STRCOMPAR.XRF
MSRC$:STRCONCAT.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:STRCONCAT.MRG/OUTPUT:LIS$:STRCONCAT.XRF
MSRC$:STRCOPY.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:STRCOPY.MRG/OUTPUT:LIS$:STRCOPY.XRF
MSRC$:STRDUPLCH.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:STRDUPLCH.MRG/OUTPUT:LIS$:STRDUPLCH.XRF
MSRC$:STRGETFRE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:STRGETFRE.MRG/OUTPUT:LIS$:STRGETFRE.XRF
MSRC$:STRLEFT.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:STRLEFT.MRG/OUTPUT:LIS$:STRLEFT.XRF
MSRC$:STRLENEXT.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:STRLENEXT.MRG/OUTPUT:LIS$:STRLENEXT.XRF
MSRC$:STRPOSEXT.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:STRPOSEXT.MRG/OUTPUT:LIS$:STRPOSEXT.XRF
MSRC$:STRPOSIT.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:STRPOSIT.MRG/OUTPUT:LIS$:STRPOSIT.XRF
MSRC$:STRPREFIX.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:STRPREFIX.MRG/OUTPUT:LIS$:STRPREFIX.XRF
MSRC$:STRREPLAC.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:STRREPLAC.MRG/OUTPUT:LIS$:STRREPLAC.XRF
MSRC$:STRRIGHT.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:STRRIGHT.MRG/OUTPUT:LIS$:STRRIGHT.XRF
MSRC$:STRSRCHIN.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:STRSRCHIN.MRG/OUTPUT:LIS$:STRSRCHIN.XRF
MSRC$:STRTRANSL.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:STRTRANSL.MRG/OUTPUT:LIS$:STRTRANSL.XRF
MSRC$:STRTRIM.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:STRTRIM.MRG/OUTPUT:LIS$:STRTRIM.XRF
MSRC$:STRUNWDEQ.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:STRUNWDEQ.MRG/OUTPUT:LIS$:STRUNWDEQ.XRF
MSRC$:STRUPCASE.B32/NOSOURCE/NOREQUIRE/FLAG:(NOREQUIRE)/MERGE:OBJ$:STRUPCASE.MRG/OUTPUT:LIS$:STRUPCASE.XRF
$ !
$ SHOW TIME
$ COPY OBJ$:BASBUFSIZ.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASCANTYP.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASCB.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASCCPOS.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASCHAIN.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASCHANGE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASCHR.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASCLOSE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASCMPAPP.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASCONCAT.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASCTRLC.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASCTRLO.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASCVTOUT.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASDATETI.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASDELETE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASDISPAT.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASECHO.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASEND.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASENDDEF.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASENDDFS.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASENDGSB.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASEXITHA.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASERROR.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASFIND.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASFORINT.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASFORMAT.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASFREE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASFSP.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASGET.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASINIDEF.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASINIDFS.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASINIGSB.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASINIGSC.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASINIIOL.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASINIONE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASINIT.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASINSTR.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASIOBEG.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASIOEND.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASKILL.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASLEFT.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASMAGTAP.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASMARGIN.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASMATIO.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASMID.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASMOVE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASMOVEAR.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASMSGDEF.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASNAMEAS.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASNOTIMP.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASNUM.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASNUM1.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASONECHR.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASOPEN.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASOPENDE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASOPENZE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASPOS.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASPURIOB.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASPUT.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASRAD50.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASRECPRO.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASRESTAR.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASRESTOR.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASRIGHT.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASRSET.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASRSTSCV.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASRSTSFI.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASRUNINI.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASSARITH.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASSCALE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASSCRATC.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASSEG.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASSIGNAL.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASSLEEP.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASSTOP.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASSTR.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASSTRING.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASSYS.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASTAB.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASTERMIO.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASUDFRL.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASUDFRM.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASUDFWF.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASUDFWL.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASUNLOCK.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASUNWIND.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASUPDATE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASVAL.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASVIRTIO.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASVIRTUA.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BASWAIT.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BPAFSS.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BPAGETBLK.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BPAMESAG.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BPASETPRI.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BPASSDEAS.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:BPAWAKEUP.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COBACCDAT.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COBACCDAY.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COBACCDWK.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COBACCEPT.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COBACCTIM.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COBCALL.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COBCANCEL.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COBDBEXCE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COBDISPLA.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COBERROR.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COBFINDNA.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COBHANDLE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COBIOEXCE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COBLINAGE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COBPAUSE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COBRESTVA.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COBRMSBLO.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COBSETSWI.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COBSWITCH.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COMASSIGN.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COMCLOSE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COMERRSET.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COMERRTST.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COMFDBSET.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:COMSETST.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORASSOC.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORBACKSP.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORCB.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORCLOSE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORDEFINE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORDELETE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORDISPAT.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORENDFIL.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORERROR.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORERRSNS.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FOREXITHA.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORFIND.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORFMTCP.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORFMTINT.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORINIUND.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORINQUIR.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORIOBEG.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORIOEND.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FOROPEN.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FOROPENDE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FOROPNKEY.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORPAUSE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORRECPRO.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORREWIND.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORSIGNAL.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORSTOP.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORUDFRF.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORUDFRL.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORUDFRU.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORUDFWF.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORUDFWL.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORUDFWU.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORUNDERF.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORUNLOCK.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:FORVM.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBASCTIM.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBASNMBX.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBCHAR.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBCOMMON.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBCRCTAB.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBCURREN.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBCVTDX.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBDATETI.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBDECOVE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBDIGITS.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBDOCOM.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBESTABL.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBFAO.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBFAOL.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBFILSCA.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBFINCVT.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBFLTUND.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBGETFOR.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBGETINP.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBGETMSG.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBINTOVE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBLOOKUP.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBLPLINE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBMATCH.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBPUTOUT.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBRADIXP.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBREVERT.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBRUNPRO.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBSCOPY.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBSIGRET.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBSTATVM.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBSTRRET.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBTIMER.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBTRNLOG.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:LIBVM.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:OTSCCB.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:OTSCCBDAT.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:OTSCLOSEF.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:OTSTERMIO.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:STRALLOC.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:STRAPPEND.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:STRARITH.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:STRCHESTA.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:STRCOMEQL.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:STRCOMPAR.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:STRCONCAT.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:STRCOPY.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:STRDUPLCH.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:STRGETFRE.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:STRLEFT.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:STRLENEXT.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:STRPOSEXT.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:STRPOSIT.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:STRPREFIX.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:STRREPLAC.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:STRRIGHT.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:STRSRCHIN.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:STRTRANSL.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:STRTRIM.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:STRUNWDEQ.MRG OBJ$:RTL.XRF
$ APPEND OBJ$:STRUPCASE.MRG OBJ$:RTL.XRF
$ DELETE OBJ$:*.MRG.*
$ !
$ SHOW PROCESS/ACCOUNT
$ SORT /KEY:(POS:1,SIZE:63,CHAR,ASCENDING) OBJ$:RTL.XRF LIS$:CREFRTL.LIS
$ SHOW PROCESS/ACCOUNT
$ DELETE OBJ$:RTL.XRF.*
$ !
$ !	End of file CREF.COM
