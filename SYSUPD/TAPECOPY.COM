$ WRITE SYS$OUTPUT "Place source tape on MTA0 (write-ring out)."
$ WRITE SYS$OUTPUT "Place target tape on MTA1 (write-ring in)."
$AGAIN:
$ MOUNT MTA0:  VMS300
$5:
$ INQUIRE OK "Is MTA1 ready to be initialized? (Y/N)"
$ IF (OK .EQS. "") THEN GOTO 5
$ IF .NOT. OK THEN GOTO 5
$ INIT MTA1: VMS300
$ MOUNT MTA1: VMS300
$ COPY MTA0:*.* MTA1:*/LOG
$ DISM MTA1:
$ DISM/NOUNL MTA0:
$10:
$ INQUIRE OK "Tape copy complete.  Do you want to copy another? (Y/N)"
$ IF (OK .EQS. "") THEN GOTO 10
$ IF OK THEN GOTO AGAIN
