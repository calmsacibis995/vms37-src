$ !++
$ !
$ ! VMSMEDIA.COM - Build any VMS media kit.
$ !
$ ! Author:	Steve Jeffreys		5-MAR-1980
$ !
$ ! Abstract:	Build any VMS media kit.  This procedure assumes that
$ !		the media building command procedure specified by the
$ !		user exists in [SYSUPD] on the default disk.  If it 
$ !		doesn't, invoking it yields a recoverable error.
$ !
$ !		This procedure uses a special help library in conjunction
$ !		with the HELP command to inform the user how to use this
$ !		and any other media building command procedure.  When
$ !		new media building command procedures are created, the
$ !		help library, VMSMEDIA.HLB, should be updated.  The help
$ !		library must be in [SYSHLP] on the default disk.
$ !
$ ! Inputs:	P1 - Mounted source disk.  If not present, the current
$ !		     default disk is used.
$ ! 
$ ! Outputs:	None.
$ !
$ !--

$ OLD_VER   := 'F$VERIFY(0)
$ SAVED_DIR := "''F$LOG("SYS$DISK")'''F$DIR()'"
$ ON CONTROL_Y THEN GOTO RECOVER_CTRLY
$ ON ERROR     THEN GOTO RECOVER_ERROR
$ IF P1 .NES. "" THEN SET DEFAULT 'P1

$ COMMAND_LOOP:
$ !
$ ! Prompt the user for a command branch to the correct handler.
$ ! Commands are recognized either spelled out or as one letter.
$ !
$ INQUIRE COMMAND_LINE	"Command"
$ IF COMMAND_LINE .EQS. "" THEN GOTO COMMAND_LOOP	! Ignore blank lines
$ IF "''F$EXT(0,1,COMMAND_LINE)'" .EQS. "$" THEN GOTO ESCAPE
$ TMP = 'F$LOC(" ",COMMAND_LINE)			! Find first blank
$ COMMAND_VERB   := 'F$EXT(0,TMP,COMMAND_LINE)		! Get command verb
$ TMP = TMP + 1
$ COMMAND_PARAMS := 'F$EXT(TMP,999,COMMAND_LINE)	! Get command parameters
$ !
$ IF COMMAND_VERB .EQS. "USE"     THEN GOTO USE_COMMAND
$ IF COMMAND_VERB .EQS. "U"	  THEN GOTO USE_COMMAND
$ IF COMMAND_VERB .EQS. "HELP"    THEN GOTO HELP_COMMAND
$ IF COMMAND_VERB .EQS. "H"	  THEN GOTO HELP_COMMAND
$ IF COMMAND_VERB .EQS. "EXIT"    THEN GOTO EXIT_COMMAND
$ IF COMMAND_VERB .EQS. "E"	  THEN GOTO EXIT_COMMAND
$ !
$ ! If the command was not recognized, inform the user and reprompt.
$ !
$ WRITE SYS$OUTPUT "Unrecognized command.  Type 'HELP' for help."
$ GOTO COMMAND_LOOP

$ ESCAPE:
$ !
$ ! Execute a DCL command line.
$ !
$ DEASSIGN SYS$INPUT
$ DEFINE SYS$INPUT 'F$LOGICAL("SYS$COMMAND")
'COMMAND_LINE
$ GOTO COMMAND_LOOP

$ HELP_COMMAND:
$ !
$ ! Print informative text re: VMSMEDIA.COM to SYS$OUTPUT.
$ ! The help library must be in SYS$HELP.
$ !
$ DEFINE/USER SYS$INPUT 'F$LOGICAL("SYS$COMMAND")'
$ HELP/LIB=SYS$HELP:VMSMEDIA.HLB 'COMMAND_PARAMS
$ GOTO COMMAND_LOOP

$ USE_COMMAND:
$ !
$ ! Invoke an command procedure to build a VMS media kit.
$ ! The command procedure must reside in [SYSUPD] on the
$ ! default disk.
$ !
$ @[SYSUPD]'COMMAND_PARAMS
$ SET NOVERIFY
$ GOTO COMMAND_LOOP

$ RECOVER_ERROR:
$ !
$ ! Recover from an error condition.
$ !
$ ON ERROR THEN GOTO RECOVER_ERROR
$ WRITE SYS$OUTPUT "Error abort."
$ GOTO COMMAND_LOOP

$ RECOVER_CTRLY:
$ !
$ ! Recover from from a CTRL-Y
$ !
$ WRITE SYS$OUTPUT "CTRL-Y abort."
 
$ EXIT_COMMAND:
$ !
$ ! Exit the MEDIABLD command procedure.
$ !
$ SET DEF 'SAVED_DIR
$ IF OLD_VER THEN SET VERIFY
