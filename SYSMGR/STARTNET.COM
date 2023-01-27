$ !	STARTNET.COM
$ !
$ !	Use this file to start the network after the permanent databases
$ !	are configured.  Place @STARTNET in [SYSMGR]SYSTARTUP.COM to
$ !	automatically start the network on each rebootstrap.
$ !
$ REQUIRED_PRIVILEGES = "ACNT,DETACH,CMKRNL,LOG_IO,NETMBX,TMPMBX,SYSNAM,SYSPRV"
$ PREV_PRIVS = F$SETPRV(REQUIRED_PRIVILEGES)
$ IF .NOT. F$PRIVILEGE(REQUIRED_PRIVILEGES) THEN GOTO NO_PRIVILEGES
$ ON ERROR THEN GOTO EXIT
$ ON CONTROL_Y THEN GOTO EXIT
$ !
$ ! Load NETDRIVER
$ !
$ RUN SYS$SYSTEM:SYSGEN
CONNECT NET/NOADAPTER/DRIVER=NETDRIVER
$ !
$ ! Startup NETACP and configure the volatile data base
$ !
$ RUN SYS$SYSTEM:NCP
SET EXECUTOR ALL
SET KNOWN OBJECTS ALL
SET KNOWN LOGGING ALL
SET KNOWN LINES ALL
SET KNOWN CIRCUITS ALL
SET KNOWN NODES ALL
$ !
$ !	Start remote command terminal ACP and load RTTDRIVER
$ !
$ @SYS$MANAGER:RTTLOAD
$EXIT:
$ PREV_PRIVS = F$SETPRV(PREV_PRIVS)
$ EXIT
$
$NO_PRIVILEGES:
$ WRITE SYS$OUTPUT "Insufficient privileges to start the network"
$ WRITE SYS$OUTPUT "Requires ",REQUIRED_PRIVILEGES," privileges."
$ GOTO EXIT
