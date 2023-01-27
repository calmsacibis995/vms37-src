$ ! PASCALBLD.COM - Build the VAX-11 PASCAL Run-Time Library
$ !
$ ! 1-002 - Add LNKLIB phase.  BLS 18-Jan-1981
$ ! 1-001 - Original.  Steven B. Lionel  14-Jan-1980
$ !
$ !
$ ON ERROR THEN GOTO FAIL
$ !
$ GOTO 'PHASE
$ !
$ !
$INIT:
$ !
$ @SYSBLDCOM$:CREATEDIR
$ GOTO EXIT
$ !
$ !
$UPDATE:
$ !
$ GOTO EXIT
$ !
$ !
$SRCLIB:
$ !
$ GOTO EXIT
$ !
$ !
$ASSEM:
$ !
$ DELETE OBJ$:*.*;*,LIS$:*.*;*
$ @SYSBLDCOM$:FASM PASCAL "" N 'UPDATES
$ !
$ COPY OBJ$:*.OBJ OBJ$:PASRTL.OBS
$ GOTO EXIT
$ !
$ !
$OBJLIB:
$ !
$ GOTO EXIT
$ !
$ !
$LNKLIB:
$ !
$ ! Null LNKLIB phase
$ !
$ GOTO EXIT
$
$LINK:
$ !
$ GOTO EXIT
$ !
$ !
$RESULT:
$ !
$ GOTO EXIT
$ !
$ !
$FAIL:
$ !
$ WRITE SYS$OUTPUT "%PASCAL-F-FAIL, >>>>>>>> PASCAL BUILD FAILURE <<<<<<<"
$ !
$EXIT:
