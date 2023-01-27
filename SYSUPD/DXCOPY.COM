$ !
$ !	DXCOPY.COM - Copy files between console device and current directory
$ !		     The files copied are assumed to be text files.
$ !
$ WRITE SYS$OUTPUT "	Command file to copy ASCII files to/from the system"
$ WRITE SYS$OUTPUT "	console storage medium and the current directory."
$ WRITE SYS$OUTPUT " "
$ INQUIRE MOUNT "Is system console storage medium mounted (Y/N)?"
$ IF MOUNT THEN GOTO MOUNTED
$ WRITE SYS$OUTPUT "Please place the system console medium in the console drive"
$ INQUIRE MOUNT "and type <ret> when ready"
$ RUN SYS$SYSTEM:SYSGEN
CONNECT CONSOLE
$ MOUNT/SYSTEM/FOR/PROT=(SYSTEM:RWLP) CSA1: CONSOLE
$
$ MOUNTED:
$ INQUIRE DIR "Copy from console medium (Y/N)?"
$ IF DIR THEN GOTO FROMCON
$ INQUIRE SOURCE "Enter file name"
$ IF SOURCE .EQS. "" THEN GOTO EXIT
$ MCR FLX CS1:/RT='SOURCE'/RS
$ GOTO EXIT
$
$ FROMCON:
$ INQUIRE SOURCE "Enter console file name"
$ IF SOURCE .EQS. "" THEN GOTO EXIT
$ MCR FLX /RS=CS1:'SOURCE'/RT
$ EXIT:
