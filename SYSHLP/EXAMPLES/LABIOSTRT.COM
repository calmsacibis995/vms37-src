!File:	LABIOSTRT.COM
!
!Starts up the LABIO SYSTEM
!Runs the data acquisition process and connect process
!as detached tasks. Then runs the status program.
!
!Make the logical name assignments
$Assign/Group LABIO.LOG LABIO_LOG	!Log file
$Assign/Group LABIO.DAT LABIO_SEC_FILE	!Global Section File
$Assign/Group KWA0: LABIO_AD		!Connect-to-Interupt device is KW-11
$Set Noon				!Don't abort if we can't run a program
$					!It is probably already running!
$!Run the data acquisition program
$
$Run/Uic=	'F$USER()'-		!Run as a deatched process
/Ast_Limit=	20-			!We need a large AST quota
/Output	=	LABIOACQ.DAT-		!SYS$OUTPUT
/Priority=	17-			!High, Real-Time priority
/Process_name=	LABIO_DATA_ACQ-		!Name of Process
/Privileges=	SAME-			!Same privileges
 LABIOACQ				!Image to run
$
$!Run the connect program
$
$ RUN/Uic=	'F$USER()'-		!Run as a detached process
/Output=	LABIOCON.DAT-		!SYS$OUTPUT
/Priority=	15-			!Give it a high but not mighty priority
/Privilege=	SAME-
/Process_name=	LABIO_CONNECT-		!Name of the process
 LABIOCON
$
$!Run the status program
$Run LABIOSTAT
$Set On
