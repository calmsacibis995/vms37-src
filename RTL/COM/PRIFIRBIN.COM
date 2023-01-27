$ ! Print the first binder of the VAX Common Run Time Library
$ !
$ ! Edit History:
$ !
$ ! 1-001 - Restored the printing of CRFRTL.XRF.  JBS 27-NOV-78
$ ! 1-002 - Print VMSRTL.MAP from MAP$:  JBS 27-NOV-78
$ ! 1-003 - Print the copyright notice.  JBS 29-NOV-78
$ ! 1-004 - Reorganize binders.  SBL 30-Nov-78
$ ! 1-005 - Remove extra @ signs from PRICOM and PRIREQ.  JBS 21-DEC-78
$ ! 1-006 - Delete MODULE.MAR.  JBS 02-JAN-1979
$ ! 1-007 - Add RTLPATCH.  JBS 25-JUN-1979
$ ! 1-008 - Delete MODULE.B32, add LIBTEMPLA.B32 and LIBTEMPLA.MAR.
$ !	     JBS 19-DEC-1979
$ ! 1-009 - Add RTLMACB32.REQ and RTLMACMAR.MAR.  JBS 19-DEC-1979
$ !
$ !--
$ !
$ PRINT/FLAG_PAGE/HEADER/NAME=RTL -
COM$:CONTENTS.TXT, -
SRC$:COPYRIGHT.TXT
$ @COM$:PRICOM		! Command and option files
$ @COM$:PRIREQ		! Require files
$ PRINT/FLAG_PAGE/NAME=RTL -
SRC$:RTLMACB32.REQ/HEADER, -
SRC$:RTLMACMAR.MAR/HEADER, -
LIS$:ALLGBL.LIS, -
SRC$:RTLVECTOR.MAR/HEADER, -
LIS$:RTLVECTOR.LIS, -
LIS$:RTLPATCH.LIS, -
SRC$:LIBTEMPLA.B32/HEADER, -
SRC$:LIBTEMPLA.MAR/HEADER, -
LIS$:CREFRTL.LIS/HEADER, -
LIS$:VMSRTL.MAP, -
SRC$:MTHLIB.DOC
$ !
$ !	End of file PRIFIRBIN.COM
