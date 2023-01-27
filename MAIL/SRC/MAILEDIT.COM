$ !++
$ ! Default command procedure to invoke an editor for MAIL.
$ !
$ ! Inputs:
$ !
$ !	P1 = Input file name.
$ !	P2 = Output file name.
$ !
$ ! Note that this procedure is run in the context of a subprocess, therefore
$ ! LOGIN.COM is not executed, creator process logical names do not exist,
$ ! and the default directory is the same as the creator process.
$ !--
$ ASSIGN/USER 'F$LOGICAL("SYS$OUTPUT")' SYS$INPUT
$ IF P1 .EQS. "" THEN GOTO NOINPUT
$ EDIT/OUTPUT='P2' 'P1'
$ EXIT
$NOINPUT:
$ EDIT 'P2'
