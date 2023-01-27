$ !
$ ! This command file will be called from the EDTCAI course, module 5.
$ ! It will copy a sample data file into the users directory, enter EDT
$ ! and allow the user to practice the various commands.  When finished,
$ ! the user will re-enter EDTCAI to continue with the instruction.
$ !
$ copy sys$instruction:edtexer5.dat exercise.dat
$ deassign sys$input
$ assign/user 'f$logical("SYS$COMMAND") sys$input
$ edit/edt/nocommand exercise.dat
$ delete exercise.dat;*
$ assign/user 'f$logical("SYS$COMMAND") sys$input
$ run sys$system:edtcai
$ exit
