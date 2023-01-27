$ !
$ !	SETDEFBOO.COM - Command file to set default boot command file.
$ !
$ !		P1 - Type of CPU (optional parameter)
$ !		     (This feature is used by the V3.0 upgrade procedure.)
$ !			1 - 11/780
$ !			2 - 11/750
$ !			3 - 11/730
$ !
$ ON ERROR THEN GOTO ERR_EXIT
$DO_OVER:
$ WRITE SYS$OUTPUT ""
$ WRITE SYS$OUTPUT "	Command file to set default boot command file."
$ WRITE SYS$OUTPUT ""
$ CONSOLE_DEVICE := CS1:
$ IF (P1 .EQS. "") THEN P1 = 0
$ CPUTYPE = 'P1
$ IF (CPUTYPE .NE. 0) THEN GOTO UPGRADE_V24
$ CPUTYPE = F$GETSYI("CPU")
$UPGRADE_V24:
$ IF (CPUTYPE .EQ. 3) THEN CONSOLE_DEVICE := CS2:
$ RUN SYS$SYSTEM:SYSGEN
CONNECT CONSOLE
$ ON ERROR THEN CONTINUE
$ DISMOUNT 'CONSOLE_DEVICE'
$ ON ERROR THEN GOTO ERR_EXIT
$ WRITE SYS$OUTPUT "Please place the system console medium in the console drive."
$ AGAIN1:
$ INQUIRE READY "Is the console medium ready to be mounted? (Y/N)"
$ IF (READY .EQS. "") THEN GOTO AGAIN1
$ IF (.NOT. READY) THEN GOTO AGAIN1
$ MOUNT/SYSTEM/FOR/PROT=(SYSTEM:RWLP) 'CONSOLE_DEVICE' CONSOLE
$
$ MOUNTED:
$ INQUIRE NAME "Enter name of default boot command file"
$ MCR FLX /RS='CONSOLE_DEVICE''NAME'/RT
$ RENAME 'NAME' DEFBOO.CMD
$ MCR FLX 'CONSOLE_DEVICE'/RT=DEFBOO.CMD/RS
$ DELETE DEFBOO.CMD;0
$ WRITE SYS$OUTPUT "Default boot command file now replaced with "'NAME'"."
$AGAIN:
$ WRITE SYS$OUTPUT ""
$ INQUIRE OK -
"Are you satisfied with this file as the default boot command file? (Y/N)"
$ IF OK .EQS. "" THEN GOTO AGAIN
$ IF .NOT. OK THEN GOTO DO_OVER
$ WRITE SYS$OUTPUT ""
$ EXIT
$ERR_EXIT:
$ WRITE SYS$OUTPUT ""
$ INQUIRE OK "Error.  Do you want to try again? (Y/N)"
$ IF (OK .EQS. "") THEN GOTO ERR_EXIT
$ IF OK THEN GOTO DO_OVER
$ EXIT
