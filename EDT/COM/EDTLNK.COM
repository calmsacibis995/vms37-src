$ !
$ ! Command file to link EDT.
$ !
$ ! Modification history:
$ !
$ ! 1-001 - Original, dated 01-Apr-1980
$ ! 1-002 - Use EDT.OPT and VMSRTL.EXE.  JBS 17-Sep-1980
$ ! 1-003 - Don't use VMSRTL.EXE, so EDT can be used by users with
$ !	     very small working sets.  JBS 24-Sep-1980
$ !
$ DELETE EXE$:EDT.EXE;*,MAP$:EDT.MAP;*
$ T := "/NOTRACE"
$ IF P1 .NES. "" THEN T := "/DEBUG"
$ LINK 'T' /EXE=EXE$:EDT /MAP=MAP$:EDT /NOSYSSHR/FULL/CROSS COM$:EDT/OPTION
$ !
$ !	End of file EDTLNK.COM
