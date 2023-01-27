$ !
$ !  Run LPA-11 microcode loader process
$ !
$ RUN/UIC=[1,4]/PROCESS=LALOADER/OUTPUT=[SYSMGR]LPA11.LOG -
     SYS$SYSTEM:LALOADER
$ !
$ !  Set up a default assignment for LPA11$0
$ !
$ ASSIGN/SYSTEM _LAA0: LPA11$0:
