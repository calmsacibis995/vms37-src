$ ! Print the fifth binder of the VAX Common Run Time Library
$ ! 0-1	- DGP 01-Sep-78
$ ! 0-2	- Add LIS$:RTLVECTOR. DGP 16-Oct-78
$ ! 1-3 - Change P.MAR to RTLP.MAR  JBS 14-NOV-78
$ ! 1-004 - Reorganize binders.  SBL 30-Nov-78
$ ! 1-005 - Remove MTH.  JBS 16-JAN-1979
$ !
$ @COM$:PRIOTS		! General language support
$ !
$ !	[ End of PRIFIFBIN.COM ]
