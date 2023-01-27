$ ! PRICOM.COM - Print all command files 
$ ! 0-1 - Add RTLBL7.CON, RTLCXF.CMD,RTLSXF.CMD.  TNH 1-May-78
$ ! 0-2	- Add COPYRTLDM.COM, COPYMDLDM.COM.  TNH 31-July-78
$ ! 0-3	- Delete RTLBL7.CON
$ !	  Add PRIFORCOM.COM, PRIFIRBIN.COM, PRISECBIN.COM, 
$ !	   PRITHIBIN.COM, PRIFOUBIN.COM, RUNPRIRTL.COM, RUNPRIRTL.OPT
$ !	   and UPDB2.COM.  DGP 01-Sep-78
$ ! 0-4	- Add about 10 missing modules.  DGP 26-Sep-78
$ ! 0-5	- Add RTLTAPE.COM -- JBS 27-Oct-78
$ ! 1-6	- Delete COPYDB2.COM, COPYMDLDM.COM and CRS.COM, and correct
$ !	   minor errors in alphabetical ordering.  JBS 14-NOV-78
$ ! 1-7	- Delete several command files which no longer work.  JBS 14-NOV-78
$ ! 1-8	- Add "headers" to the files to help find them in the binders  JBS 14-NOV-78
$ ! 1-009 - Change MARFOR.COM to MARSUP.COM.  JBS 29-NOV-78
$ ! 1-010 - Reformat as a single PRINT command and put in all missing
$ !	    modules (by taking a directory listing of COM$:)  JBS 29-NOV-78
$ ! 1-011 - Add job name, change some file names.  SBL 30-Nov-78
$ ! 1-012 - Add command files created when breaking the compilation and
$ !	    assembly up by component.  JBS 26-DEC-78
$ ! 1-013 - Add the OBSxxx files and BLIRTL300.  JBS 27-DEC-78
$ ! 1-014 - Add BASMSG.COM.  JBS 20-MAR-1979
$ ! 1-015 - Add DEFRTL.  JBS 07-JUN-1979
$ ! 1-016 - Remove BLIxxx and MARxxx (edit 012) and add a few files
$ !	     added to COM$: in the merge with TW.  JBS 25-JUN-1979
$ ! 1-017 - Change RTLGROUP.COM to RTLGROUP.DAT.  JBS 05-AUG-1979
$ ! 1-018 - Add VMSRTLLN2.OPT.  JBS 13-SEP-1979
$ !
$ !--
$ !
$ PRINT/HEADER/FLAG_PAGE/NAME=COM -
COM$:BACKUPRTL.COM, -
COM$:BASMSG.COM, -
COM$:CHANGEDEL.COM, -
COM$:COPYRTLDM.COM, -
COM$:CREF.COM, -
COM$:CREPRIRTL.COM, -
COM$:CROLB.COM, -
COM$:CRS.COM, -
COM$:CRSHRO.COM, -
COM$:CRSHRO.OPT, -
COM$:DEFRTL.COM, -
COM$:DELETE.COM, -
COM$:FASM.COM, -
COM$:GET.COM, -
COM$:IMAGETEST.COM, -
COM$:INSPRIRTL.COM, -
COM$:LNKNOSHAR.COM, -
COM$:LNKNOSHAR.OPT, -
COM$:LOGIN.COM
$ PRINT/HEADER/FLAG_PAGE/NAME=COM -
COM$:MDLRTL.COM, -
COM$:NETCOPY.COM, -
COM$:OBSBAS.COM, -
COM$:OBSCOB.COM, -
COM$:OBSCOM.COM, -
COM$:OBSFOR.COM, -
COM$:OBSLIB.COM, -
COM$:OBSMTH.COM, -
COM$:OBSOTS.COM, -
COM$:OBSRTL.COM, -
COM$:PRICOM.COM, -
COM$:PRIFIFBIN.COM, -
COM$:PRIFIRBIN.COM, -
COM$:PRIFOR.COM, -
COM$:PRIFORCMP.COM, -
COM$:PRIFOUBIN.COM, -
COM$:PRILIB.COM, -
COM$:PRIMTH.COM, -
COM$:PRIOTS.COM, -
COM$:PRIREQ.COM, -
COM$:PRIRTL.COM, -
COM$:PRISECBIN.COM
$ PRINT/HEADER/FLAG_PAGE/NAME=COM -
COM$:PRISIXBIN.COM, -
COM$:PRITHIBIN.COM, -
COM$:PUT.COM, -
COM$:RNO.COM, -
COM$:RNORTL.COM, -
COM$:RTLBAT.COM, -
COM$:RTLGROUP.DAT, -
COM$:RTLBLD.COM, -
COM$:RTLTAPE.COM, -
COM$:RUNPRIRTL.COM, -
COM$:RUNPRIRTL.OPT, -
COM$:SETDEF.COM, -
COM$:VMSRTLLNK.COM, -
COM$:VMSRTLLN2.OPT, -
COM$:VMSRTLLNK.OPT
$ !
$ !	[end of PRICOM.COM]
