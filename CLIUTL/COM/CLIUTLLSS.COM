$ ! COMMAND FILE TO CREATE A CONCATONATED LISTING OF THE VARIOUS CLI
$ ! UTILITY COMPONENTS.
$ !
$ ! DISABLE ERROR HANDLING IN CASE A FILE IS MISSING
$ !
$ SET NOON
$ !
$ ! CREATE CONCATONATED LISTING FOR GENERAL SUBROUTINES
$ !
$ CPYRESLIS LIS$:CHRSUB.LIS+CLIGBL0+CLIGBL1+CLIOPEN+CNVCLIATB+-
	CNVCLIFRM+CNVCLINUM+CNVCLITIM+MATCHKEY+PUTCLIMSG      -
	CLIUTLSUB.LSS
$ !
$ ! QUEUE MANAGER LISTING
$ !
$ CPYRESLIS LIS$:QUEMAN.LIS+DELQUAL+INIQUAL+STAQUAL+STOQUAL-
	QUEMAN.LSS
$ !
$ ! RTPAD LISTING
$ !
$ CPYRESLIS LIS$:RTPAD.LIS RTPAD.LSS
$ !
$ ! RUN/CANCEL LISTING
$ !
$ CPYRESLIS LIS$:RUNDET.LIS+RUNCVTUIC+RUNPRSFIL+RUNSRCKEY+CANCEL-
	RUNCAN.LSS
$ !
$ ! CREATE LISTING FOR SET
$ !
$ CPYRESLIS LIS$:SETCMDISP.LIS+SETACCNT+SETMSGTXT+SETPRINT+SETCARD+	-
		SETDEV+SETDEVUTL+SETLOGIN+SETMAG+SETPROCES+	-
		SETQUEUE+SETRMS+SETTERM+SETWRKSET+SHOMSGUTL+	-
		SETPRO	-
	SET.LSS
$ !
$ ! CREATE LISTING FOR SHOW
$ !
$ CPYRESLIS LIS$:SHOCMDISP.LIS+SHODEVCLI+SHODEVUTL+-
	SHOLOGICL+SHOMEMORY+SHOMSGTXT+SHOMSGUTL+SHOPROCES+SHOSYSTEM+-
	SHOWFILES+SHOWQUE+SHOWRKSET+SHOWRMS+SHOWTERM+SHOWPRINT+-
	SHOWMAGT	SHOW.LSS
$ !
$ ! CREATE LISTING FOR SUBMIT AND TYPE
$ !
$ CPYRESLIS LIS$:SUBMIT.LIS+SUBMITRWD+TYPE+TYPERWD SUBMTYPE.LSS
$ !
$ ! CREATE LISTING FOR RENAME AND CREATE
$ !
$ CPYRESLIS LIS$:RENAME.LIS RENAME.LSS
$ CPYRESLIS LIS$:CREATE.LIS CREATE.LSS
$ CPYRESLIS LIS$:UNLOCK.LIS UNLOCK.LSS
