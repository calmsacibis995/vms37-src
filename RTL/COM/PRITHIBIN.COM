$ ! Print the third binder of the VAX Common Run Time Library
$ ! 0-1	- DGP  01-Sep-78
$! 0-2	- Add ALLGBL.MAR.  DGP 27-Sep-78
$! 0-3	- Print ALLGBL.LIS instead.  TNH 27-Oct-78
$! 1-001 - Reorganize binders.  ALLGBL goes in binder 1.  SBL 30-Nov-78
$ @COM$:PRILIB		! General utility library
$ ! End of PRITHIBIN.COM
