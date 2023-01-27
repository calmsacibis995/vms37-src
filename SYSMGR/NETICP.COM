$ TYPE SYS$INPUT

		NETICP.COM

	DECnet Installation Checkout Procedure

$!	This procedure checks some common network functions with a remote
$!	node in the network.  More tests are performed with a vax node
$!	than with a node of another type.
$!	
$!
$!	Author : Darrell Duffy  Date: 10-April-1980
$!
$!	P1	Remote node name
$!	P2	Node type (VAX, RSX, RSTS, RT, IAS, DEC20)
$!	P3	Line speed for statistics only
$!	P4	User name for mail test. (VAX only)
$!	P5	User name for mail reply. (VAX only)
$!	P6	Userid for Set Host test (VAX only)
$!	P7	Password for Set Host test (VAX only)
$!
$	REMNODE 	:= 'P1
$ 	NODETYPE 	:= 'P2
$ 	LINESPEED	:= 'P3
$ 	REMMAIL		:= 'P4
$ 	LOCMAIL		:= 'P5
$ 	USERID		:= 'P6
$ 	PASSWORD	:= 'P7
$!
$	IF "'F$MODE()" .EQS. "BATCH" THEN GOTO STARTEST
$ 10$:	IF REMNODE .NES. "" THEN GOTO 20$
$	INQUIRE REMNODE -
	"Remote node for test                     (node name)"
$	GOTO 10$
$ 20$:	IF NODETYPE .NES. "" THEN GOTO 22$
$ 21$:	INQUIRE NODETYPE -
	"Type of remote node (VAX, RSX, IAS, RT, RSTS, DEC20)"
$ 22$:	IF NODETYPE .EQS. "VAX" THEN GOTO 30$
$	IF NODETYPE .EQS. "RSX" THEN GOTO 30$
$	IF NODETYPE .EQS. "IAS" THEN GOTO 30$
$	IF NODETYPE .EQS. "RSTS" THEN GOTO 30$
$	IF NODETYPE .EQS. "DEC20" THEN GOTO 30$
$	IF NODETYPE .EQS. "RT" THEN GOTO 30$
$	GOTO 21$
$ 30$:	IF LINESPEED .NES. "" THEN GOTO 40$
$	INQUIRE LINESPEED -
	"Speed of line for statistics                  (baud)"
$	GOTO 30$
$ 40$:	IF NODETYPE .NES. "VAX" THEN GOTO STARTEST
$ 50$:	IF REMMAIL .NES. "" THEN GOTO 60$
$	INQUIRE REMMAIL -
	"User name for mail to remote node                   "
$	GOTO 50$
$ 60$:	IF LOCMAIL .NES. "" THEN GOTO 70$
$	INQUIRE LOCMAIL -
	"User name for mail to local node                    "
$	GOTO 60$
$ 70$:	IF USERID .NES. "" THEN GOTO 80$
$	INQUIRE USERID -
	"User name for SET HOST to remote node               "
$	GOTO 70$
$ 80$:	IF PASSWORD .NES. "" THEN GOTO 90$
$	INQUIRE PASSWORD -
	"Password for SET HOST to remote node                "
$	GOTO 80$
$ 90$:
$ STARTEST:
$	LOCNODE := 'F$LOGICAL("SYS$NODE")
$!
$!	DTS/DTR are not normally available on RSTS, so skip test if RSTS.
$!
$	IF NODETYPE .EQS. "RSTS" THEN GOTO DCLTESTS
$ !
$ !	DTS command script used to test DECnet
$ !
$ TYPE SYS$INPUT

	DTS/DTR tests exercise the basic NSP level capabilities of a DECnet
	product by requesting common task-to-task communication functions.
	We will first test DTS to DTR on the local node and then test it
	to the remote node.

$ RUN SYS$SYSTEM:DTSEND
CONNECT/TYPE=ACCEPT/NORETURN
DISCONNECT/TYPE=ABORT/RETURN=STANDARD
DATA/TYPE=SINK/SIZE=128/SECONDS=10
EXIT
$!
$!	Create a command procedure for remote access so that we can use
$!	the proper node name and linespeed.
$!
$ OPEN/WRITE DTSCMD NETICPDTS.TMP
$ WRITE DTSCMD "$ RUN SYS$SYSTEM:DTSEND"
$ WRITE DTSCMD "/NODENAME=",REMNODE,"/SPEED=",LINESPEED,-
"/STATISTICS/PRINT/NODISPLAY-"
$ WRITE DTSCMD "-!"
$ WRITE DTSCMD "-!	Connect tests"
$ WRITE DTSCMD "-!"
$ WRITE DTSCMD "CONNECT/TYPE=ACCEPT/NORETURN"
$ WRITE DTSCMD "CONNECT/TYPE=ACCEPT/RETURN=STANDARD"
$ WRITE DTSCMD "CONNECT/TYPE=ACCEPT/RETURN=RECEIVED"
$ WRITE DTSCMD "CONNECT/TYPE=REJECT/NORETURN"
$ WRITE DTSCMD "CONNECT/TYPE=REJECT/RETURN=STANDARD"
$ WRITE DTSCMD "CONNECT/TYPE=REJECT/RETURN=RECEIVED"
$ WRITE DTSCMD "-!"
$ WRITE DTSCMD "-!	Disconnect tests"
$ WRITE DTSCMD "-!"
$ WRITE DTSCMD "DISCONNECT/TYPE=SYNCHRONOUS/NORETURN"
$ WRITE DTSCMD "DISCONNECT/TYPE=SYNCHRONOUS/RETURN=STANDARD"
$ WRITE DTSCMD "DISCONNECT/TYPE=SYNCHRONOUS/RETURN=RECEIVED"
$ WRITE DTSCMD "DISCONNECT/TYPE=ABORT/NORETURN"
$ WRITE DTSCMD "DISCONNECT/TYPE=ABORT/RETURN=STANDARD"
$ WRITE DTSCMD "DISCONNECT/TYPE=ABORT/RETURN=RECEIVED"
$ WRITE DTSCMD "-!"
$ WRITE DTSCMD "-!	Data tests"
$ WRITE DTSCMD "-!"
$ IF NODETYPE .EQS. "DEC20" THEN GOTO 110$
$ IF NODETYPE .EQS. "RT"  THEN GOTO 120$
$ WRITE DTSCMD "DATA/TYPE=SINK/SIZE=128/SECONDS=10"
$ WRITE DTSCMD "DATA/TYPE=SEQUENCE/SIZE=128/SECONDS=10"
$ WRITE DTSCMD "DATA/TYPE=PATTERN/SIZE=128/SECONDS=10"
$ WRITE DTSCMD "DATA/TYPE=ECHO/SIZE=128/SECONDS=10"
$ GOTO 200$
$ 110$:			! Data tests for DECsystem 20
$ WRITE DTSCMD "DATA/TYPE=SINK/RQUEUE=8/FLOW=SEG/SIZE=128/SECONDS=10"
$ WRITE DTSCMD "DATA/TYPE=SEQUENCE/RQUEUE=8/FLOW=SEG/SIZE=128/SECONDS=10"
$ WRITE DTSCMD "DATA/TYPE=PATTERN/RQUEUE=8/FLOW=SEG/SIZE=128/SECONDS=10"
$ WRITE DTSCMD "DATA/TYPE=ECHO/RQUEUE=8/FLOW=SEG/SIZE=128/SECONDS=10"
$ 120$:			! Data tests for RT-11
$ WRITE DTSCMD "DATA/TYPE=SINK/FLOW=SEG/RQUEUE=1/SQUEUE=1/SIZE=128/SECONDS=10"
$ WRITE DTSCMD "DATA/TYPE=SEQUENCE/FLOW=SEG/SIZE=128/SECONDS=10"
$ WRITE DTSCMD "DATA/TYPE=PATTERN/FLOW=SEG/SIZE=128/SECONDS=10"
$ WRITE DTSCMD "DATA/TYPE=ECHO/FLOW=SEG/SIZE=128/SECONDS=10"
$ 200$:
$ WRITE DTSCMD "-!"
$ WRITE DTSCMD "-!	Interrupt tests"
$ WRITE DTSCMD "-!"
$ WRITE DTSCMD "INTERRUPT/TYPE=SINK/SIZE=16/SECONDS=10"
$ WRITE DTSCMD "INTERRUPT/TYPE=SEQUENCE/SIZE=16/SECONDS=10"
$ WRITE DTSCMD "INTERRUPT/TYPE=PATTERN/SIZE=16/SECONDS=10"
$ WRITE DTSCMD "INTERRUPT/TYPE=ECHO/SIZE=16/SECONDS=10"
$ WRITE DTSCMD "EXIT"
$ CLOSE DTSCMD
$!
$!	Execute the command procedure and delete it when done
$!
$ @NETICPDTS.TMP
$ DELETE NETICPDTS.TMP;*
$!
$ DCLTESTS:
$ TYPE SYS$INPUT

	Perform some simple file procedures with DCL.

	Create a file and copy it to the remote node.
	Copy it back and compare the file after the round trip to
	see if there were any changes. The file is copied back with
	both COPY and TYPE/OUT=.
	The file is deleted on the remote node after the test.

$	CREATE NETICP.TMP
***
This is a file of several lines which has been copied to the
default decnet account on the remote node and back to check some
simple file transfers initiated at this node.
***
$!
$	COPY/LOG NETICP.TMP 'REMNODE'::*.*
$	COPY/LOG 'REMNODE'::NETICP.TMP NETICP.TM2
$	DIFFERENCES NETICP.TMP NETICP.TM2
$	TYPE SYS$INPUT

	Now use TYPE instead of COPY to move the file from the remote
	node to this node and then check for differences.

$	TYPE 'REMNODE'::NETICP.TMP/OUT=NETICP.TM3
$	DIFFERENCES NETICP.TMP NETICP.TM3
$	TYPE SYS$INPUT

	Now type the file from the remote node.

$	TYPE 'REMNODE'::NETICP.TMP
$!
$	TYPE SYS$INPUT

	Now delete the file on the remote node.

$!
$	DELETE/LOG 'REMNODE'::NETICP.TMP;
$!
$!
$	DELETE NETICP.TM2;*
$	DELETE NETICP.TM3;*
$	DELETE NETICP.TMP;*
$!
$	TYPE SYS$INPUT

	Now try some functions that will fail.
	Delete a file on the remote node that is not present.
	Copy a file from the remote node that is not present.

$	SET NOON
$	DELETE/LOG 'REMNODE'::FOOBARFOO.FOO;
$	COPY/LOG 'REMNODE'::FOOBARFOO.FOO *
$	SET ON
$
$!
$!	If the remote node is not a vax node the test is done.
$!
$	IF NODETYPE .NES. "VAX" THEN GOTO ENDICP
$!
$	TYPE SYS$INPUT

	Try a test of mail to the local node and to the remote node.
	Mail should arrive here soon from the local node.  You should
	check the default DECnet account on the remote node to see if
	it has received mail.

$	MAIL SYS$INPUT SYS$NODE::'LOCMAIL'/SUBJECT="DECnet Test"
Test of mail over DECnet to the local node.
$!
$	MAIL SYS$INPUT 'REMNODE'::'REMMAIL'/SUBJECT="DECnet Test"
Test of mail over DECnet to the remote node.
$!
$	TYPE SYS$INPUT

	Try a test of submit and mail on the remote node.
	The command procedure is created on the remote node
	with the DCL WRITE command.
	A batch stream should be running on the remote VAX node.
	Mail should arrive here soon from the remote node and a log
	should be printed on the remote node when the job completes.

$!
$	OPEN/WRITE REMFILE 'REMNODE'::NETICP.TMP
$	WRITE REMFILE "$!	Test mail from remote node to local node."
$	WRITE REMFILE "$!"
$	WRITE REMFILE "$	MAIL SYS$INPUT ",LOCNODE,LOCMAIL,-
	"/SUBJECT=""DECnet mail from remote node"""
$	WRITE REMFILE "DECnet mail from remote node"
$	CLOSE REMFILE
$	SUBMIT /REMOTE 'REMNODE'::NETICP.TMP
$!
$!	Mail should arrive here soon
$	TYPE SYS$INPUT

	Now for a test of remote terminals.  We will create a
	command procedure which logs into the remote node and
	mails us a message from there and then logs out.

$!
$	NODEACC := 'REMNODE'""""'USERID' 'PASSWORD'""""
$	OPEN/WRITE REMFILE NETICP.TMP
$ WRITE REMFILE "$ SET HOST ",REMNODE
$ WRITE REMFILE USERID
$ WRITE REMFILE PASSWORD
$ WRITE REMFILE "MAIL NETICP.TMP ",LOCNODE,LOCMAIL,-
	"/SUBJECT=""Remote terminals work from ",REMNODE,""""
$ WRITE REMFILE "LOG"
$ WRITE REMFILE "$ EXIT"
$	CLOSE  REMFILE
$	COPY NETICP.TMP 'NODEACC'::*
$	@ NETICP.TMP
$	DELETE 'NODEACC'::NETICP.TMP;*
$	DELETE NETICP.TMP;*
$!
$	TYPE SYS$INPUT

	Mail should arrive soon from the remote node.

$!
$ ENDICP:
$	TYPE SYS$INPUT

	End of DECnet Installation Checkout Procedure

$!
