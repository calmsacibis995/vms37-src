$ !
$ ! FACNEWBLD - BUILD FACILITY FROM SLP FILES ON WRKD$ DISK.
$ !
$ !	P1 = FACILITY NAME
$ !	P2 = STARTING PHASE (DEFAULT IS UPDATE)
$ !	P3 = WORKING SET SIZE (DEFAULT IS 500)
$ !
$ @SYSBLDCOM$:FACTSTBLD 'P1' 'P2' MASD$: WRKD$: WRKD$: ENH 'P3'
