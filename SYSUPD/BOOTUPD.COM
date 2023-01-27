$ !
$ !	[SYSUPD] B O O T U P D . C O M - Update bootstrap image on console device
$ !
$ ! This command file will update the VMS bootstrap file "VMB.EXE" on the
$ ! console storage device.  It is assumed that the current default device is
$ ! the system device.  
$ !
$ WRITE SYS$OUTPUT "		 Command file to update bootstrap image"
$ WRITE SYS$OUTPUT "		  on console storage device."
$ WRITE SYS$OUTPUT " "
$ DIR:='F$DIRECTORY()
$ DISK:='F$LOG("SYS$DISK")
$ ON ERROR THEN GOTO 20
$ SET DEF SYS$SYSTEM
$ INQUIRE CONFIRM "Is system console medium mounted (Y/N)"
$ IF CONFIRM THEN GOTO 10
$ WRITE SYS$OUTPUT "Please place the system console medium in the console drive"
$ INQUIRE CONFIRM "and type <ret> when ready"
$ RUN SYSGEN
CONNECT CONSOLE
$ MOUNT/SYSTEM/FOR/PROT=(SYSTEM:RWLP) CSA1: CONSOLE
$
$ 10:
$ MCR FLX CS1:/RT/IM=VMB.EXE/RS
$ WRITE SYS$OUTPUT " "
$ WRITE SYS$OUTPUT "Bootstrap updated."
$
$ 20:
$ SET DEF 'DISK''DIR'
