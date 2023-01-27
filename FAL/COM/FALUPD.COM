$ !
$ !	[ F A L . C O M ] F A L U P D . C O M
$ !
$ !	This command file applies SLP correction files to all FAL
$ !	source modules.
$ !
$ !	Update modules that will be used to create the macro library.
$ !
$ DELETE SRC$:*.*;*
$ SRCUPDATE FALDEF.MDL
$ SRCUPDATE DAPDEF.MDL
$ SRCUPDATE FALMACROS.MAR
